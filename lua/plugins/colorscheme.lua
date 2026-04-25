return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    enabled = true,
    opts = {
      contrast = "hard",
      transparent_mode = true,
      overrides = {
        -- Diffview uses these groups for added lines depending on mode.
        DiffAdd = { bg = "#2E3D32" },
        DiffDelete = { bg = "#4A2A2A" },
        DiffviewDiffAdd = { bg = "#2E3D32" },
        DiffviewDiffDelete = { bg = "#4A2A2A" },
        DiffChange = { bg = "#2E3D32" },
        DiffText = { fg = "NONE", bg = "#435e43" },
        -- DiffviewDiffText = { fg = "NONE" },
      },
    },
  },
  { "jacoborus/tender.vim", lazy = true, enabled = false },
  { "kepano/flexoki-neovim", lazy = true, enabled = false },
  {
    "AlexvZyl/nordic.nvim",
    lazy = true,
    enabled = false,
    opts = {
      transparent = {
        -- Enable transparent background.
        bg = false,
        -- Enable transparent background for floating windows.
        float = true,
      },
      -- Enable brighter float border.
      bright_border = true,
      -- Reduce the overall amount of blue in the theme (diverges from base Nord).
      reduced_blue = true,
    },
  },
  { "savq/melange-nvim", lazy = true, enabled = false },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    enabled = false,
    opts = {
      transparent = false,
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },

          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
