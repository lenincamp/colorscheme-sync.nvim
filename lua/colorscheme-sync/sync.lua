local M = {}

local config = require("colorscheme-sync.config")

local pending = false
local pending_theme = nil

local function resolve_tools(cfg)
  local tools = cfg.sync_tools
  if tools == nil then
    -- Default: all built-in tools
    local t = require("colorscheme-sync.tools")
    return { t.tmux, t.delta, t.lazygit, t.alacritty, t.iterm2, t.shell, t.starship, t.eza, t.btop, t.zellij, t.lazydocker, t.shell_env }
  end
  return tools
end

function M.request(theme)
  local cfg = config.get()
  local tools = resolve_tools(cfg)

  if type(tools) ~= "table" or #tools == 0 then return end

  if #vim.api.nvim_list_uis() == 0 then
    M._run_tools(theme, tools)
    return
  end

  pending_theme = theme
  if pending then return end

  pending = true
  vim.defer_fn(function()
    pending = false
    local target = pending_theme
    pending_theme = nil
    if target then
      M._run_tools(target, tools)
    end
  end, 20)
end

function M.force(theme)
  local cfg = config.get()
  local tools = resolve_tools(cfg)
  if type(tools) ~= "table" or #tools == 0 then return end
  M._run_tools(theme, tools)
end

--- Build a fallback profile from palette colors for themes without explicit config.
---@param theme table Theme item
---@return table profile
local function dynamic_profile(theme)
  local palette = require("colorscheme-sync.palette")
  local mode = "dark"
  if type(theme) == "table" and theme.opts and theme.opts.background then
    mode = theme.opts.background
  else
    mode = vim.o.background or "dark"
  end
  local colors = palette.build(mode)
  return {
    terminal = { background = colors.bg, foreground = colors.fg },
    accent = colors.accent,
    border = colors.border,
    selection = colors.selection,
    warn = colors.warn,
    error = colors.error,
    lualine = { provider = "auto" },
  }
end

function M._run_tools(theme, tools)
  local cfg = config.get()
  local theme_key = (type(theme) == "table" and theme.key) or theme
  local profile = cfg.sync_profiles[theme_key]
  if not profile or next(profile) == nil then
    profile = dynamic_profile(theme)
  end
  local ctx = {
    theme = theme,
    profile = profile,
    config = cfg,
  }

  for _, tool in ipairs(tools) do
    if type(tool) == "function" then
      local ok, err = pcall(tool, ctx)
      if not ok then
        vim.notify("colorscheme-sync tool error: " .. tostring(err), vim.log.levels.DEBUG)
      end
    end
  end
end

return M
