local MODES = {
  explorer = "explorer",
  git = "git",
}
local SIDEBAR_SOURCE_BY_MODE = {
  [MODES.explorer] = "explorer",
  [MODES.git] = "git_status",
}
local SIDEBAR_SOURCES = vim.tbl_values(SIDEBAR_SOURCE_BY_MODE)

local function get_sidebar_mode()
  return vim.g.snacks_sidebar_mode or MODES.explorer
end

local function source_for_mode(mode)
  return SIDEBAR_SOURCE_BY_MODE[mode]
end

local function close_snacks_sidebars()
  for _, source in ipairs(SIDEBAR_SOURCES) do
    for _, picker in ipairs(Snacks.picker.get({ source = source }) or {}) do
      picker:close()
    end
  end
end

local function open_snacks_sidebar(mode)
  close_snacks_sidebars()
  vim.schedule(function()
    if mode == MODES.git then
      Snacks.picker.git_status()
    else
      Snacks.picker.explorer()
    end
  end)
end

local function toggle_snacks_sidebar_mode()
  local current = get_sidebar_mode()
  local next_mode = current == MODES.explorer and MODES.git or MODES.explorer
  vim.g.snacks_sidebar_mode = next_mode

  open_snacks_sidebar(next_mode)
end

local SIDEBAR_LIST_KEYS = {
  ["<a-g>"] = toggle_snacks_sidebar_mode,
}

return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>e",
      function()
        local sidebar_mode = get_sidebar_mode()
        local source = source_for_mode(sidebar_mode)

        local picker = (Snacks.picker.get({ source = source }) or {})[1]
        if picker == nil then
          open_snacks_sidebar(sidebar_mode)
        elseif picker:is_focused() == true then
          picker:close()
        else
          picker:focus("list", { show = true })
        end
      end,
      desc = "Snacks Sidebar (tree/git mode)",
    },
  },
  opts = {
    scroll = { enabled = false },
    picker = {
      sources = {
        explorer = {
          focus = "list",
          layout = { layout = { position = "right" } },
          hidden = true,
          ignored = true,
          win = {
            list = {
              keys = SIDEBAR_LIST_KEYS,
            },
          },
        },
        git_status = {
          focus = "list",
          layout = { preset = "sidebar", hidden = { "preview" }, layout = { position = "right" } },
          win = {
            list = {
              keys = SIDEBAR_LIST_KEYS,
            },
          },
        },
        files = { hidden = true },
      },
    },
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║
██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║
██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
       keys = {
         { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
         { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
         { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
         { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
         { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = " ", key = "s", desc = "Restore Session", section = "session" },
         { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
         { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
         { icon = " ", key = "q", desc = "Quit", action = ":qa" },
       },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git --no-pager diff --stat -B -M -C",
          height = 10,
          padding = 1,
          ttl = 60,
          indent = 3,
        },
        {
          pane = 2,
          section = "terminal",
          cmd = "pokemon-colorscripts -r --no-title",
          random = 10,
          height = 20,
          indent = 4,
        },
      },
    },
  },
}
