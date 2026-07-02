local M = {}

local config = require("colorscheme-sync.config")

local _theme_map = {}

function M.build_map(themes)
  _theme_map = {}
  for _, item in ipairs(themes or {}) do
    _theme_map[item.key] = item
  end
end

function M.theme_map()
  return _theme_map
end

--- Resolve any theme name, creating a dynamic entry for unknown schemes.
---@param name string|table Theme name or table
---@return table theme item with .key, .label, .scheme, .opts, ._dynamic
function M.resolve_any(name)
  if type(name) == "table" then return name end

  local cfg = config.get()
  local key = cfg.aliases[name] or name

  -- Check registered catalog
  if _theme_map[key] then return _theme_map[key] end
  for _, item in ipairs(cfg.themes) do
    if item.key == key or item.scheme == key then return item end
  end

  -- Unknown theme: create a dynamic entry so the colorscheme loads
  return {
    key = key,
    label = key,
    scheme = key,
    opts = { background = vim.o.background or "dark" },
    _dynamic = true,
  }
end

return M
