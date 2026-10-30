vim.api.nvim_create_user_command("RexPalette", function()
  require("rex").refresh()
end, { desc = "Read the terminal palette again and reload the rex colorscheme" })
