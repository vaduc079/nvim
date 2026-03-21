return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>e",
      function()
        if Snacks.picker.get({ source = "explorer" })[1] == nil then
          Snacks.picker.explorer()
        elseif Snacks.picker.get({ source = "explorer" })[1]:is_focused() == true then
          Snacks.picker.explorer()
        elseif Snacks.picker.get({ source = "explorer" })[1]:is_focused() == false then
          Snacks.picker.get({ source = "explorer" })[1]:focus()
        end
      end,
      desc = "Explorer Snacks (root dir)",
    },
  },
  opts = {
    scroll = { enabled = false },
    picker = {
      sources = {
        explorer = {
          layout = { layout = { position = "right" } },
          hidden = true,
          ignored = true,
        },
        files = { hidden = true },
      },
    },
  },
}
