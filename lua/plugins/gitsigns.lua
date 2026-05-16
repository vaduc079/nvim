return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    opts.current_line_blame = true
    opts.current_line_blame_opts = vim.tbl_deep_extend("error", opts.current_line_blame_opts or {}, {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 150,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    })

    local on_attach = opts.on_attach
    opts.on_attach = function(buffer)
      if on_attach then
        on_attach(buffer)
      end

      local gitsigns = require("gitsigns")

      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc, silent = true })
      end

      map("}", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next Hunk")

      map("{", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Prev Hunk")
    end
  end,
}
