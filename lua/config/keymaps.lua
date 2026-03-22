-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", function()
  require("wezterm-move").move("h")
end, { desc = "Go to Left Window" })
vim.keymap.set("n", "<C-j>", function()
  require("wezterm-move").move("j")
end, { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", function()
  require("wezterm-move").move("k")
end, { desc = "Go to Upper Window" })
vim.keymap.set("n", "<C-l>", function()
  require("wezterm-move").move("l")
end, { desc = "Go to Right Window", remap = true })
