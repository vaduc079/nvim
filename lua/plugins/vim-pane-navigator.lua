local directions = {
  h = { wincmd = "h", pane = "left", desc = "Navigate left (vim/pane)" },
  j = { wincmd = "j", pane = "down", desc = "Navigate down (vim/pane)" },
  k = { wincmd = "k", pane = "up", desc = "Navigate up (vim/pane)" },
  l = { wincmd = "l", pane = "right", desc = "Navigate right (vim/pane)" },
}

local function has_env(name)
  return vim.env[name] ~= nil and vim.env[name] ~= ""
end

local function in_herdr()
  return has_env("HERDR_PANE_ID")
end

local function in_rex()
  return has_env("REX_BLOCK")
end

local function in_pane_multiplexer()
  return in_herdr() or in_rex()
end

local function herdr_binary()
  if has_env("HERDR_BIN_PATH") then
    return vim.env.HERDR_BIN_PATH
  end

  if has_env("HERDR_BIN") then
    return vim.env.HERDR_BIN
  end

  return "herdr"
end

local function focus_herdr_pane(direction)
  local output = vim.fn.system({
    herdr_binary(),
    "pane",
    "focus",
    "--direction",
    direction,
    "--pane",
    vim.env.HERDR_PANE_ID,
  })

  return vim.v.shell_error, output
end

local function focus_rex_pane(direction)
  local output = vim.fn.system({ "rex", "focus", direction })

  return vim.v.shell_error, output
end

-- herdr wins when Neovim runs inside herdr inside Rex, since herdr owns the nearer panes.
local function focus_pane(direction)
  if in_herdr() then
    return focus_herdr_pane(direction)
  end

  return focus_rex_pane(direction)
end

local function navigate(item)
  local current_window = vim.api.nvim_get_current_win()

  vim.cmd("wincmd " .. item.wincmd)

  local moved_within_nvim = vim.api.nvim_get_current_win() ~= current_window
  if moved_within_nvim then
    return
  end

  focus_pane(item.pane)
end

local function set_keymap(lhs, item)
  vim.keymap.set("n", lhs, function()
    navigate(item)
  end, { silent = true, noremap = true, desc = item.desc })
end

local function setup_keymaps()
  set_keymap("<C-h>", directions.h)
  set_keymap("<C-j>", directions.j)
  set_keymap("<C-k>", directions.k)
  set_keymap("<C-l>", directions.l)
end

local function setup_keymaps_after_lazyvim()
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.schedule(setup_keymaps)
    end,
  })
end

local function setup_commands()
  vim.api.nvim_create_user_command("PaneNavigatorDebug", function()
    local lines = {
      "HERDR_PANE_ID=" .. tostring(vim.env.HERDR_PANE_ID),
      "HERDR_BIN=" .. tostring(vim.env.HERDR_BIN),
      "HERDR_BIN_PATH=" .. tostring(vim.env.HERDR_BIN_PATH),
      "REX_BLOCK=" .. tostring(vim.env.REX_BLOCK),
      "herdr_binary=" .. herdr_binary(),
      "in_herdr=" .. tostring(in_herdr()),
      "in_rex=" .. tostring(in_rex()),
    }

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_user_command("PaneNavigateLeft", function()
    navigate(directions.h)
  end, {})

  vim.api.nvim_create_user_command("PaneNavigateDown", function()
    navigate(directions.j)
  end, {})

  vim.api.nvim_create_user_command("PaneNavigateUp", function()
    navigate(directions.k)
  end, {})

  vim.api.nvim_create_user_command("PaneNavigateRight", function()
    navigate(directions.l)
  end, {})
end

return {
  {
    "christoomey/vim-tmux-navigator",
    cond = function()
      return not in_pane_multiplexer()
    end,
  },
  {
    "LazyVim/LazyVim",
    init = function()
      if not in_pane_multiplexer() then
        return
      end

      setup_keymaps_after_lazyvim()
      setup_commands()
    end,
  },
}
