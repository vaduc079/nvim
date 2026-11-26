-- Program Resume Protocol (OSC 7577): keep a session file for this Neovim and report
-- `nvim -S <file>`, so a terminal that restores its panes reopens it with its windows. The
-- terminal resumes it only if it trusts the command.
-- https://www.superlogical.com/rex/docs/build/program-resume
--
-- Each instance has its own file, so several Neovims in one directory come back as they were.
-- persistence.nvim's per-directory session is left alone.

-- Take the token out of the environment, so processes Neovim starts can't report as it.
local token = vim.env.OSC7577_TOKEN
vim.env.OSC7577_TOKEN = nil
if not token then
  return
end

local DIR = vim.fn.stdpath("state") .. "/osc7577-sessions"
local MAX_AGE_DAYS = 30

vim.fn.mkdir(DIR, "p")

-- Remove files no instance has saved for a while. Not on exit: Neovim also exits when the
-- terminal shuts down, which is when the file is needed. Runs after this instance's first save,
-- so a file resumed after a long break is refreshed before it could count as old.
local function prune()
  for name, type in vim.fs.dir(DIR) do
    local path = DIR .. "/" .. name
    local stat = type == "file" and vim.uv.fs_stat(path)
    if stat and os.time() - stat.mtime.sec > MAX_AGE_DAYS * 86400 then
      os.remove(path)
    end
  end
end

local session_file ---@type string?
local pruned = false

local function get_session_file()
  if not session_file then
    local loaded = vim.v.this_session
    if vim.startswith(loaded, DIR .. "/") and vim.uv.fs_stat(loaded) then
      session_file = loaded
    else
      local id = vim.uv.random(4):gsub(".", function(c)
        return ("%02x"):format(c:byte())
      end)
      session_file = ("%s/%s-%s.vim"):format(DIR, os.date("%Y%m%d-%H%M%S"), id)
    end
  end
  return session_file
end

local function report(file)
  local argv = { "nvim", "-S", file }
  for i, arg in ipairs(argv) do
    argv[i] = vim.base64.encode(arg)
  end
  -- This process is Neovim's server. The terminal runs its parent, the TUI.
  local body = ("pid=%d:time=%d:argv=%s"):format(vim.uv.os_getppid(), os.time(), table.concat(argv, ","))
  local mac = vim.fn.sha256(body .. ":" .. token)
  -- Through the UI, not stderr: a raw write can land in the middle of the TUI's own output.
  vim.api.nvim_ui_send("\27]7577;" .. body .. ":mac=" .. mac .. "\27\\")
end

-- Nothing to restore from the dashboard or git's commit editor.
local function has_file_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and not vim.tbl_contains({ "gitcommit", "gitrebase", "jj" }, vim.bo[buf].filetype)
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      return true
    end
  end
  return false
end

local function save()
  -- While a session loads, each restored buffer fires BufEnter; saving then would overwrite the
  -- file Neovim is still reading.
  if vim.g.SessionLoad == 1 or not has_file_buffer() then
    return
  end
  local file = get_session_file()
  -- :mksession points v:this_session at the file; put it back for plugins that read it.
  local previous = vim.v.this_session
  local ok = pcall(vim.cmd.mksession, { args = { file }, bang = true })
  vim.v.this_session = previous
  if ok then
    report(file)
    if not pruned then
      prune()
      pruned = true
    end
  end
end

-- The terminal drops the record once Neovim exits, so save and report while it runs.
-- UIEnter, not VimEnter: the report goes through the UI, which isn't attached at VimEnter.
vim.api.nvim_create_autocmd({ "UIEnter", "BufEnter", "BufWritePost", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("Osc7577", { clear = true }),
  desc = "Save this Neovim's session and report it for OSC 7577 resume",
  callback = save,
})
