-- colorscheme-sync/adapters/zellij.lua
local common = require("colorscheme-sync.adapters.common")

local M = {}

function M.theme_for_mode(mode)
  return (mode == "light") and "catppuccin-latte" or "catppuccin-macchiato"
end

function M.replace_theme(content, zellij_theme)
  return content:gsub('theme%s+"[^"]+"', 'theme "' .. zellij_theme .. '"', 1)
end

function M._theme_mode(ctx)
  local theme = ctx.theme
  if type(theme) == "table" and theme.opts and theme.opts.background then
    return theme.opts.background
  end
  return vim.o.background or "dark"
end

function M.sync(ctx)
  local mode = M._theme_mode(ctx)
  local path = ctx.config and ctx.config.zellij_config_path
    or vim.fn.expand("~/.config/zellij/config.kdl")
  local content = common.read_text_file(path)
  if type(content) ~= "string" then return end

  local updated = M.replace_theme(content, M.theme_for_mode(mode))
  -- Strip trailing blank lines to prevent file growth
  updated = updated:gsub("\n+$", "\n")
  pcall(common.write_text_file_if_changed, path, updated)
end

return M
