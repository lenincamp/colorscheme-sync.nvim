-- colorscheme-sync/adapters/iterm2.lua
local M = {}

function M.color_value(hex)
  if type(hex) ~= "string" then return nil end
  local red, green, blue = hex:match("#?(%x%x)(%x%x)(%x%x)")
  if not red or not green or not blue then return nil end
  return string.format(
    "{%d, %d, %d, 65535}",
    tonumber(red, 16) * 257,
    tonumber(green, 16) * 257,
    tonumber(blue, 16) * 257
  )
end

function M.set_primary_colors(colors)
  if type(colors) ~= "table" then return false end
  if vim.fn.executable("osascript") ~= 1 then return false end

  local background = M.color_value(colors.bg)
  local foreground = M.color_value(colors.fg)
  if not background or not foreground then return false end

  local script = table.concat({
    'tell application "iTerm2"',
    "if (count of windows) == 0 then error \"No active iTerm2 window\"",
    "tell current session of current tab of current window",
    "set background color to " .. background,
    "set foreground color to " .. foreground,
    "end tell",
    "end tell",
  }, "\n")

  vim.fn.system({ "osascript", "-e", script })
  return vim.v.shell_error == 0
end

function M.sync(ctx)
  local term_program = vim.env.TERM_PROGRAM
  local in_iterm2 = term_program == "iTerm.app"
  local force_sync = vim.g.pure_iterm2_sync_always == true
  if not in_iterm2 and not force_sync then return false end

  local alacritty_adapter = require("colorscheme-sync.adapters.alacritty")
  local colors = alacritty_adapter.terminal_primary_colors(ctx)
  local theme_key = type(ctx.theme) == "table" and ctx.theme.key or ""
  local cache_key = table.concat({ theme_key, colors.bg or "", colors.fg or "" }, "|")
  if vim.g._csync_iterm2_last == cache_key then return true end

  if M.set_primary_colors(colors) then
    vim.g._csync_iterm2_last = cache_key
    return true
  end

  vim.g._csync_iterm2_last = cache_key
  return false
end

return M
