local M = {}

local SIDEBAR_MODES = {
  all = "all",
  git_only = "git_only",
}

local function get_sidebar_mode()
  return vim.g.snacks_sidebar_mode or SIDEBAR_MODES.all
end

local function in_cwd(cwd, path)
  return path == cwd or path:find(cwd .. "/", 1, true) == 1
end

-- Build changed paths from `git status -uall` so untracked files inside new dirs are included.
local function get_git_changed_paths(cwd)
  local root = Snacks.git.get_root(cwd)
  if not root then
    return {}
  end

  local cmd = {
    "git",
    "--no-pager",
    "--no-optional-locks",
    "status",
    "--porcelain=v1",
    "-z",
    "-uall",
  }

  local raw = ""
  local code = 0
  if vim.system then
    local res = vim.system(cmd, { cwd = root, text = false }):wait()
    raw = res.stdout or ""
    code = res.code or 1
  else
    raw = vim.fn.system(cmd)
    code = vim.v.shell_error
  end
  if code ~= 0 then
    return {}
  end

  local ret = {}
  -- `vim.fn.system()` replaces NUL with SOH; normalize then split in plain mode.
  raw = raw:gsub("\1", "\0")
  local tokens = vim.split(raw, "\0", { plain = true, trimempty = true })

  local function add_relative(rel)
    if rel == nil or rel == "" then
      return
    end
    local cleaned = rel:gsub("/$", "")
    if cleaned == "" then
      return
    end
    local abs = vim.fs.normalize(root .. "/" .. cleaned)
    if in_cwd(cwd, abs) then
      ret[abs] = true
    end
  end

  local i = 1
  while i <= #tokens do
    local token = tokens[i]
    if #token >= 4 then
      local xy = token:sub(1, 2)
      local path = token:sub(4)
      if xy ~= "!!" then
        add_relative(path)
      end
      if xy:find("R", 1, true) or xy:find("C", 1, true) then
        i = i + 1
        add_relative(tokens[i])
      end
    end
    i = i + 1
  end

  return ret
end

-- In git_only mode, keep changed nodes and ancestor dirs so the tree stays navigable.
local function build_git_only_keep_set(cwd, changed_paths)
  local Tree = require("snacks.explorer.tree")
  local keep = {}

  for path in pairs(changed_paths) do
    local node = Tree:find(path)
    local current = node
    while current do
      keep[current.path] = true
      if current.path == cwd then
        break
      end
      current = current.parent
    end
  end

  keep[cwd] = true
  return keep
end

-- Ensure dirs containing git changes are opened so git_only view is visible immediately.
local function expand_to_changed_paths(changed_paths)
  local Tree = require("snacks.explorer.tree")
  for path in pairs(changed_paths) do
    Tree:open(path)
  end
end

local function refresh_picker_view(picker)
  if picker.list then
    picker.list:set_target()
  end
  picker:find()
end

local function refresh_git_only_view(picker, cwd)
  local changed_paths = get_git_changed_paths(cwd)
  picker.opts.git_only_changed_paths = changed_paths
  expand_to_changed_paths(changed_paths)
  refresh_picker_view(picker)
end

local function set_mode_git_only(picker)
  local cwd = picker:cwd()
  refresh_git_only_view(picker, cwd)
  require("snacks.explorer.git").update(cwd, {
    untracked = picker.opts.git_untracked,
    force = true,
    on_update = function()
      if picker.closed then
        return
      end
      refresh_git_only_view(picker, cwd)
    end,
  })
end

local function set_mode_all(picker)
  picker.opts.git_only_changed_paths = nil
  refresh_picker_view(picker)
end

local function apply_sidebar_mode(picker, mode)
  picker.opts.sidebar_mode = mode
  if mode == SIDEBAR_MODES.git_only then
    set_mode_git_only(picker)
  else
    set_mode_all(picker)
  end
end

local function open_sidebar(mode)
  if mode == SIDEBAR_MODES.git_only then
    local cwd = vim.fn.getcwd()
    Snacks.picker.explorer({
      sidebar_mode = mode,
      git_only_changed_paths = get_git_changed_paths(cwd),
    })
    return
  end
  Snacks.picker.explorer({ sidebar_mode = mode })
end

-- Resolve the active explorer picker regardless of key callback arg shape.
local function get_active_explorer_picker(candidate)
  if candidate and candidate.opts and candidate.opts.source == "explorer" and candidate.find then
    return candidate
  end
  return (Snacks.picker.get({ source = "explorer", tab = true }) or {})[1]
    or (Snacks.picker.get({ source = "explorer" }) or {})[1]
end

local function toggle_sidebar_mode(candidate)
  local picker = get_active_explorer_picker(candidate)
  local current = (picker and picker.opts.sidebar_mode) or get_sidebar_mode()
  local next_mode = current == SIDEBAR_MODES.all and SIDEBAR_MODES.git_only or SIDEBAR_MODES.all
  vim.g.snacks_sidebar_mode = next_mode

  if picker then
    apply_sidebar_mode(picker, next_mode)
  end
end

local function move_wezterm(direction)
  return function()
    require("wezterm-move").move(direction)
  end
end

local movement_key_descriptions = {
  h = "Go to Left Window",
  j = "Go to Lower Window",
  k = "Go to Upper Window",
  l = "Go to Right Window",
}

-- Explorer list buffers need local mappings because picker windows can handle
-- control keys differently from normal editing buffers.
local function movement_keys()
  return {
    -- ["<c-h>"] = { move_wezterm("h"), desc = movement_key_descriptions.h },
    -- ["<c-j>"] = { move_wezterm("j"), desc = movement_key_descriptions.j },
    -- -- Some terminals send Ctrl-j as <NL> inside picker buffers.
    -- ["<nl>"] = { move_wezterm("j"), desc = movement_key_descriptions.j },
    -- ["<c-k>"] = { move_wezterm("k"), desc = movement_key_descriptions.k },
    -- ["<c-l>"] = { move_wezterm("l"), desc = movement_key_descriptions.l },
  }
end

function M.list_keys()
  return vim.tbl_extend("force", movement_keys(), {
    ["<a-g>"] = function(...)
      toggle_sidebar_mode(select(1, ...))
    end,
  })
end

function M.keymaps()
  return {
    {
      "<leader>e",
      function()
        local sidebar_mode = get_sidebar_mode()
        local picker = (Snacks.picker.get({ source = "explorer" }) or {})[1]
        if picker == nil then
          open_sidebar(sidebar_mode)
        elseif picker:is_focused() == true then
          picker:close()
        else
          picker:focus("list", { show = true })
        end
      end,
      desc = "Snacks Sidebar (tree/git-only mode)",
    },
  }
end

function M.explorer_source_opts()
  return {
    focus = "list",
    layout = { layout = { position = "right" }, auto_hide = { "input" } },
    sidebar_mode = get_sidebar_mode(),
    hidden = true,
    ignored = true,
    transform = function(item, ctx)
      local mode = ctx.picker.opts.sidebar_mode or SIDEBAR_MODES.all
      if mode ~= SIDEBAR_MODES.git_only then
        return item
      end
      local changed_paths = ctx.picker.opts.git_only_changed_paths or {}
      ctx.meta.git_only_keep = build_git_only_keep_set(ctx.filter.cwd, changed_paths)
      if ctx.meta.git_only_keep[item.file] then
        return item
      end
      return false
    end,
    win = {
      list = {
        keys = M.list_keys(),
      },
    },
  }
end

return M
