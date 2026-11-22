-- Rex: colors come from the terminal palette, so they follow the Rex terminal theme.
-- Groups name palette slots; rex.palette turns them into the exact colors Rex reported
-- (run :RexPalette after changing the Rex theme). Slots also go to ctermfg/ctermbg, so the scheme
-- still follows the terminal with termguicolors off.
-- 0-15 are the theme's ANSI colors. 16-231 and 232-255 are Rex's generated palette: 16 is the
-- background, 16 + 36r + 6g + b tints it toward red/green/blue, 232-255 ramp from background to
-- foreground. Slots were picked as the nearest match to Kanagawa Wave's colors.
local rex_palette = require("rex.palette")

local M = {}

local hl = {
  -- Editor
  Normal = { fg = "fg" },
  NormalFloat = { fg = "fg" },
  FloatBorder = { fg = 8 },
  FloatTitle = { fg = 4, bold = true },
  Cursor = { reverse = true },
  CursorLine = { bg = 233 },
  CursorColumn = { bg = 233 },
  ColorColumn = { bg = 233 },
  CursorLineNr = { fg = 11, bold = true },
  LineNr = { fg = 8 },
  SignColumn = {},
  FoldColumn = { fg = 8 },
  Folded = { fg = 8, bg = 233 },
  NonText = { fg = 238 },
  Whitespace = { fg = 238 },
  SpecialKey = { fg = 238 },
  EndOfBuffer = { fg = 16 },
  Conceal = { fg = 8 },
  WinSeparator = { fg = 236 },
  StatusLine = { fg = 7, bg = 233 },
  StatusLineNC = { fg = 8, bg = 233 },
  TabLine = { fg = 8, bg = 233 },
  TabLineFill = {},
  TabLineSel = { fg = 15, bg = 235, bold = true },
  WinBar = { fg = 7 },
  WinBarNC = { fg = 8 },
  Visual = { bg = 17 },
  Search = { bg = 18 },
  IncSearch = { fg = 0, bg = 11 },
  CurSearch = { fg = 0, bg = 11, bold = true },
  Substitute = { fg = 0, bg = 1 },
  MatchParen = { fg = 11, bold = true },
  QuickFixLine = { bg = 233 },
  Pmenu = { bg = 17 },
  PmenuSel = { bg = 18, bold = true },
  PmenuSbar = { bg = 17 },
  PmenuThumb = { bg = 18 },
  PmenuKind = { fg = 13, bg = 17 },
  PmenuExtra = { fg = 8, bg = 17 },
  Directory = { fg = 4 },
  Title = { fg = 4, bold = true },
  Question = { fg = 4 },
  MoreMsg = { fg = 4 },
  ModeMsg = { fg = 11, bold = true },
  WarningMsg = { fg = 11 },
  ErrorMsg = { fg = 9 },
  SpellBad = { undercurl = true },
  SpellCap = { undercurl = true },
  SpellLocal = { undercurl = true },
  SpellRare = { undercurl = true },

  -- Diff and VCS
  DiffAdd = { bg = 28 },
  DiffDelete = { fg = 1, bg = 52 },
  DiffChange = { bg = 232 },
  DiffText = { bg = 237 },
  Added = { fg = 2 },
  Changed = { fg = 3 },
  Removed = { fg = 1 },
  diffAdded = { link = "Added" },
  diffChanged = { link = "Changed" },
  diffRemoved = { link = "Removed" },

  -- Syntax
  Comment = { fg = 8, italic = true },
  Constant = { fg = 214 },
  String = { fg = 10 },
  Character = { fg = 10 },
  Number = { fg = 205 },
  Boolean = { fg = 214, bold = true },
  Float = { link = "Number" },
  Identifier = { fg = 11 },
  Function = { fg = 4 },
  Statement = { fg = 5 },
  Keyword = { fg = 5 },
  Conditional = { fg = 5 },
  Repeat = { fg = 5 },
  Label = { fg = 5 },
  Exception = { fg = 1 },
  Operator = { fg = 3 },
  PreProc = { fg = 1 },
  Type = { fg = 14 },
  Special = { fg = 12 },
  Delimiter = { fg = 105 },
  Tag = { fg = 12 },
  Underlined = { fg = 12, underline = true },
  Todo = { fg = 0, bg = 12, bold = true },
  Error = { fg = 9 },

  -- Treesitter (groups not listed fall back to the defaults linked to the groups above)
  ["@variable"] = {},
  ["@variable.builtin"] = { fg = 1, italic = true },
  ["@variable.parameter"] = { fg = 13 },
  ["@variable.member"] = { fg = 11 },
  ["@property"] = { fg = 11 },
  ["@constructor"] = { fg = 12 },
  ["@keyword.return"] = { fg = 1, italic = true },
  ["@keyword.exception"] = { fg = 1 },
  ["@keyword.operator"] = { fg = 3, bold = true },
  ["@string.regexp"] = { fg = 3 },
  ["@string.escape"] = { fg = 3, bold = true },
  ["@punctuation.bracket"] = { fg = 105 },
  ["@punctuation.delimiter"] = { fg = 105 },
  ["@tag.attribute"] = { fg = 11 },
  ["@markup.heading"] = { fg = 4, bold = true },
  ["@markup.link.url"] = { fg = 12, underline = true },
  ["@markup.raw"] = { fg = 10 },
  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },

  -- Diagnostics and LSP
  DiagnosticError = { fg = 9 },
  DiagnosticWarn = { fg = 11 },
  DiagnosticInfo = { fg = 12 },
  DiagnosticHint = { fg = 6 },
  DiagnosticOk = { fg = 2 },
  DiagnosticUnderlineError = { undercurl = true, sp = 9 },
  DiagnosticUnderlineWarn = { undercurl = true, sp = 11 },
  DiagnosticUnderlineInfo = { undercurl = true, sp = 12 },
  DiagnosticUnderlineHint = { undercurl = true, sp = 6 },
  LspReferenceText = { bg = 17 },
  LspReferenceRead = { bg = 17 },
  LspReferenceWrite = { bg = 17, underline = true },
  LspInlayHint = { fg = 8 },
}

local color_keys = { "fg", "bg", "sp" }

-- Background this instance last applied. Theme checks compare against it, not the cache file,
-- because another Neovim may already have written the new palette there.
local applied_bg

-- Applies the colorscheme from the cached palette; called by colors/rex.lua.
function M.load()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "rex"

  local palette = rex_palette.load()
  applied_bg = palette.bg
  for group, slots in pairs(hl) do
    local spec = vim.deepcopy(slots)
    for _, key in ipairs(color_keys) do
      local slot = slots[key]
      if slot ~= nil then
        spec[key] = palette[slot] or rex_palette.fallback[slot]
        if type(slot) == "number" and key ~= "sp" then
          spec["cterm" .. key] = slot
        end
      end
    end
    vim.api.nvim_set_hl(0, group, spec)
  end
end

local refreshing = false

-- Reads the palette slots the groups use from the terminal again, then reloads the colorscheme.
function M.refresh(opts)
  opts = opts or {}
  if refreshing then
    return
  end
  refreshing = true
  local used = {}
  for _, spec in pairs(hl) do
    for _, key in ipairs(color_keys) do
      if type(spec[key]) == "number" then
        used[spec[key]] = true
      end
    end
  end
  rex_palette.refresh(vim.tbl_keys(used), function(ok, err)
    refreshing = false
    if not ok then
      if not opts.silent then
        vim.notify(err, vim.log.levels.WARN)
      end
      return
    end
    -- An automatic refresh must not switch back to rex if another scheme was picked meanwhile.
    if opts.silent and vim.g.colors_name ~= "rex" then
      return
    end
    vim.cmd.colorscheme("rex")
    if not opts.silent then
      vim.notify("Rex palette refreshed")
    end
  end)
end

-- No DEC mode 2031 handler is needed: Neovim enables the mode and re-queries OSC 11 on
-- light/dark switches, and those replies arrive here like any other.
function M.on_term_response(seq)
  if refreshing or vim.g.colors_name ~= "rex" then
    return
  end
  local r, g, b = seq:match("^\027%]11;rgba?:(%x%x)%x*/(%x%x)%x*/(%x%x)")
  if not r then
    return
  end
  if ("#" .. r .. g .. b):lower() ~= (applied_bg or ""):lower() then
    M.refresh({ silent = true })
  end
end

function M.check_theme()
  if refreshing or vim.g.colors_name ~= "rex" then
    return
  end
  vim.api.nvim_ui_send("\027]11;?\027\\")
end

local defaults = {
  -- How often to check for a Rex theme change, in milliseconds. 0 or false turns polling off.
  poll_interval = 60 * 1000,
}

local poll_timer

-- Runs twice: with defaults from plugin/rex.lua, then with lazy.nvim's opts.
function M.setup(opts)
  M.config = vim.tbl_extend("force", defaults, opts or {})
  if poll_timer then
    poll_timer:stop()
    poll_timer:close()
    poll_timer = nil
  end
  local interval = M.config.poll_interval
  if interval and interval > 0 then
    poll_timer = vim.uv.new_timer()
    poll_timer:start(interval, interval, vim.schedule_wrap(M.check_theme))
  end
end

return M
