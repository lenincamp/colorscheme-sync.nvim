-- colorscheme-sync/adapters/lazydocker.lua
local common = require("colorscheme-sync.adapters.common")

local M = {}

function M.config_paths(mode)
  local base = vim.fn.expand("~/Library/Application Support/lazydocker")
  local src = base .. ((mode == "light") and "/config-light.yml" or "/config-dark.yml")
  return src, base .. "/config.yml"
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
  local src, target = M.config_paths(mode)
  pcall(common.copy_text_file_if_changed, src, target)
end

return M
