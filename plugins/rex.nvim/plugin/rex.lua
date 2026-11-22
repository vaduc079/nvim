vim.api.nvim_create_user_command("RexPalette", function()
  require("rex").refresh()
end, { desc = "Read the terminal palette again and reload the rex colorscheme" })

local group = vim.api.nvim_create_augroup("RexThemeChange", { clear = true })

vim.api.nvim_create_autocmd("TermResponse", {
  group = group,
  desc = "Reload the rex colorscheme when the Rex theme changes",
  callback = function(ev)
    require("rex").on_term_response(ev.data.sequence)
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  desc = "Check for a Rex theme change when Neovim regains focus",
  callback = function()
    require("rex").check_theme()
  end,
})

require("rex").setup()
