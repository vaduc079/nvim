local ts_filetypes = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
}

return {
  {
    "mason-org/mason.nvim",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "typescript-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { enabled = false },
        ts_ls = { enabled = false },
        tsserver = { enabled = false },
        tsgo = { enabled = false },
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    ft = ts_filetypes,
    keys = {
      { "gD", "<cmd>TSToolsGoToSourceDefinition<cr>", desc = "Goto Source Definition", ft = ts_filetypes },
      { "gR", "<cmd>TSToolsFileReferences<cr>", desc = "File References", ft = ts_filetypes },
      { "<leader>cM", "<cmd>TSToolsAddMissingImports<cr>", desc = "Add missing imports", ft = ts_filetypes },
      { "<leader>cD", "<cmd>TSToolsFixAll<cr>", desc = "Fix all diagnostics", ft = ts_filetypes },
      { "<leader>co", "<cmd>TSToolsOrganizeImports<cr>", desc = "Organize Imports", ft = ts_filetypes },
    },
    opts = {
      settings = {
        complete_function_calls = true,
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "literals",
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = false,
          quotePreference = "auto",
        },
      },
    },
  },
}
