return {
  {
    "mason-org/mason.nvim",
    init = function()
      vim.g.lazyvim_prettier_needs_config = true
    end,
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "biome",
      },
    },
  },
}
