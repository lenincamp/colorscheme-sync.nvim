-- colorscheme-sync/adapters/btop.lua
local common = require("colorscheme-sync.adapters.common")

local M = {}

function M.theme_for_mode(mode)
  return (mode == "light") and "catppuccin_latte" or "catppuccin_mocha"
end

function M.replace_color_theme(content, color_theme)
  return content:gsub('color_theme%s*=%s*"[^"]+"', 'color_theme = "' .. color_theme .. '"', 1)
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
  local path = ctx.config and ctx.config.btop_config_path
    or vim.fn.expand("~/.config/btop/btop.conf")
  local content = common.read_text_file(path)
  if type(content) ~= "string" then return end

  local updated = M.replace_color_theme(content, M.theme_for_mode(mode))
  pcall(common.write_text_file_if_changed, path, updated)
end

return M
