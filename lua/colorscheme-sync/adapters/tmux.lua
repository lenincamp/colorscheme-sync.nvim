-- colorscheme-sync/adapters/tmux.lua
-- Sets tmux colors directly from palette. No plugin dependency.
local M = {}

local function tmux_set(option, value)
  vim.fn.system({ "tmux", "set-option", "-gq", option, value })
  return vim.v.shell_error == 0
end

local function ensure_hex(hex)
  if type(hex) ~= "string" then return nil end
  if hex:match("^#%x%x%x%x%x%x$") then return hex end
  local r, g, b = hex:match("^#?(%x%x)(%x%x)(%x%x)$")
  if not r then return nil end
  return "#" .. r .. g .. b
end

function M.sync(ctx)
  if vim.fn.executable("tmux") ~= 1 then return end

  local track = (type(ctx.theme) == "table" and ctx.theme.key) or "unknown"
  if vim.g._csync_tmux_last == track then return end

  local profile = ctx.profile
  local colors = type(profile) == "table" and profile.terminal or {}
  if type(colors) ~= "table" then colors = {} end

  local bg = ensure_hex(colors.background) or "#1e1e2e"
  local fg = ensure_hex(colors.foreground) or "#cdd6f4"
  local accent = ensure_hex(profile.accent) or "#89b4fa"
  local border = ensure_hex(profile.border) or "#6c7086"
  local selection = ensure_hex(profile.selection) or "#313244"
  local error = ensure_hex(profile.error) or "#f38ba8"
  local warn = ensure_hex(profile.warn) or "#f9e2af"

  -- Status bar background and default fg
  tmux_set("status-style", "bg=" .. bg .. ",fg=" .. fg)
  tmux_set("status-interval", "5")

  -- Left status: session name with accent pill
  tmux_set("status-left-length", "40")
  tmux_set("status-left",
    "#[fg=" .. bg .. ",bg=" .. accent .. "]" ..
    "#[fg=" .. accent .. ",bg=" .. bg .. ",bold] #S " ..
    "#[fg=" .. fg .. ",bg=" .. bg .. "] ")

  -- Right status: leader indicator + zoom indicator + time
  tmux_set("status-right-length", "80")
  tmux_set("status-right",
    "#[fg=" .. accent .. ",bg=" .. bg .. "]" ..
    "#{?client_prefix,[L] ,}" ..
    "#[fg=" .. accent .. ",bg=" .. bg .. ",bold]" ..
    "#{?#{m:*Z*,#{window_flags}},[Z] ,}" ..
    "#[fg=" .. border .. ",bg=" .. bg .. "]" ..
    " %H:%M ")

  -- Window format: current window gets accent bg for visual distinction
  tmux_set("window-status-format",
    "#[fg=" .. border .. ",bg=" .. bg .. "] #I:#W ")
  tmux_set("window-status-current-format",
    "#[fg=" .. bg .. ",bg=" .. accent .. ",bold] #I:#W ")

  -- Pane borders
  tmux_set("pane-border-style", "fg=" .. border)
  tmux_set("pane-active-border-style", "fg=" .. accent)
  tmux_set("display-panes-active-colour", accent)
  tmux_set("display-panes-colour", border)

  -- Message and mode
  tmux_set("message-style", "bg=" .. selection .. ",fg=" .. fg)
  tmux_set("message-command-style", "bg=" .. selection .. ",fg=" .. fg)
  tmux_set("mode-style", "bg=" .. accent .. ",fg=" .. bg)

  vim.fn.system({ "tmux", "refresh-client", "-S" })
  vim.g._csync_tmux_last = track
end

return M
