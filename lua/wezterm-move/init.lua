local wezterm_move = {}

local wezterm_directions = { h = "Left", j = "Down", k = "Up", l = "Right" }
local outward_direction_by_position = {
  left = "h",
  right = "l",
  top = "k",
  bottom = "j",
}

local function get_open_pickers()
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    return {}
  end

  return snacks.picker.get({ tab = true })
end

local function is_picker_window(picker, win)
  return picker.list.win.win == win or picker.input.win.win == win or picker.preview.win.win == win
end

-- Snacks sidebars are picker UIs, not normal split windows, so we need to
-- detect them from the picker-owned windows instead of using winnr()/wincmd.
local function current_picker()
  local current_win = vim.api.nvim_get_current_win()

  for _, picker in ipairs(get_open_pickers()) do
    if is_picker_window(picker, current_win) then
      return picker
    end
  end

  return nil
end

local function picker_accepts_direction(picker, direction)
  local position = picker.layout.root.opts.position
  return outward_direction_by_position[position] == direction
end

-- When focus is already inside a picker, some directions should leave Neovim
-- immediately instead of trying to navigate the picker layout first.
local function should_send_from_picker(picker, direction)
  if not picker then
    return false
  end

  if picker.opts.source == "explorer" and (direction == "j" or direction == "k") then
    return true
  end

  return picker_accepts_direction(picker, direction)
end

-- From a normal editing window, allow moving into an already-open sidebar by
-- focusing the picker directly. This avoids false terminal handoff when the
-- sidebar lives on the target edge.
local function focus_picker_in_direction(direction)
  local current_win = vim.api.nvim_get_current_win()
  for _, picker in ipairs(get_open_pickers()) do
    local enters_picker = picker_accepts_direction(picker, direction)
    local is_current_picker = is_picker_window(picker, current_win)

    if enters_picker and not is_current_picker then
      picker:focus("list", { show = true })
      return vim.api.nvim_get_current_win() ~= current_win
    end
  end

  return false
end

-- @param direction: string (h, j, k, l)
local function move_inside_nvim(direction)
  local current_win = vim.api.nvim_get_current_win()
  local ok = pcall(vim.cmd, "wincmd " .. direction)

  if not ok then
    return false
  end

  return vim.api.nvim_get_current_win() ~= current_win
end

-- @param direction: string (h, j, k, l)
local function send_key_to_wezterm(direction)
  vim.fn.system({ "wezterm", "cli", "activate-pane-direction", wezterm_directions[direction] })
end

-- @param direction: string (h, j, k, l)
wezterm_move.move = function(direction)
  local picker = current_picker()

  -- Routing order matters:
  -- 1. if we're already in a picker edge case, hand off to WezTerm
  -- 2. otherwise try a normal Neovim window move
  -- 3. then focus an open picker on that edge
  -- 4. finally fall back to WezTerm
  if should_send_from_picker(picker, direction) then
    send_key_to_wezterm(direction)
    return
  end

  if move_inside_nvim(direction) then
    return
  end

  if focus_picker_in_direction(direction) then
    return
  end

  send_key_to_wezterm(direction)
end

return wezterm_move
