vim.api.nvim_create_user_command("RexPalette", function()
  require("rex").sync({ manual = true })
end, { desc = "Read the terminal palette again and reload the rex colorscheme" })

local group = vim.api.nvim_create_augroup("RexThemeChange", { clear = true })

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = group,
  desc = "Check for a Rex theme change",
  callback = function()
    require("rex").sync()
  end,
})

-- Rex notifies light/dark switches (DEC mode 2031); Neovim then sets 'background' from a new
-- OSC 11 reply. Neovim also sets it, unchanged, on every OSC 11 reply, including those to sync's
-- own queries, so only a real change may trigger a sync.
vim.api.nvim_create_autocmd("OptionSet", {
  group = group,
  pattern = "background",
  desc = "Check for a Rex theme change after a light/dark switch",
  callback = function()
    if vim.v.option_old ~= vim.v.option_new then
      require("rex").sync()
    end
  end,
})

require("rex").setup()
