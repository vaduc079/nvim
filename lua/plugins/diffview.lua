return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewRefresh",
    },
    keys = {
      { "<leader>vd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>vD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>v", group = "Diffview" })
    end,
  },
}
