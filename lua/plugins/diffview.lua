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
    opts = function()
      local actions = require("diffview.actions")

      return {
        keymaps = {
          view = {
            { "n", "<leader>ca", false },
            { "n", "<leader>cA", false },
            {
              "n",
              "<leader>ma",
              actions.conflict_choose("all"),
              { desc = "Choose all versions of the current conflict" },
            },
            {
              "n",
              "<leader>mA",
              actions.conflict_choose_all("all"),
              { desc = "Choose all conflict versions in the file" },
            },
          },
          file_panel = {
            { "n", "<leader>cA", false },
            {
              "n",
              "<leader>mA",
              actions.conflict_choose_all("all"),
              { desc = "Choose all conflict versions in the file" },
            },
          },
        },
      }
    end,
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
