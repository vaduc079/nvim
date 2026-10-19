local function open_mdv()
  local path = vim.api.nvim_buf_get_name(0)

  vim.cmd.update()
  Snacks.terminal({ "mdv", path }, {
    cwd = vim.fs.dirname(path),
    win = {
      position = "float",
      width = 0,
      height = 0,
      border = "none",
      backdrop = false,
    },
  })
end

return {
  {
    "mdv",
    virtual = true,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
        pattern = "*.md",
        callback = function(event)
          vim.api.nvim_buf_create_user_command(event.buf, "Mdv", open_mdv, {
            desc = "Open current Markdown file in mdv",
          })
        end,
      })
    end,
  },
}
