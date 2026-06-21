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

function M.options()
  local cfg = config.get()
  local dark_items = {}
  local light_items = {}

  for _, theme in ipairs(cfg.themes) do
    local item = vim.tbl_extend("force", {}, theme)
    if (theme.opts and theme.opts.background) == "light" then
      table.insert(light_items, item)
    else
      table.insert(dark_items, item)
    end
  end

  table.sort(dark_items, function(a, b) return a.label < b.label end)
  table.sort(light_items, function(a, b) return a.label < b.label end)

  local items = {}
  if #dark_items > 0 then
    table.insert(items, { key = "_header_dark", label = "──── Dark ────", source = "header" })
    vim.list_extend(items, dark_items)
  end
  if #light_items > 0 then
    table.insert(items, { key = "_header_light", label = "──── Light ────", source = "header" })
    vim.list_extend(items, light_items)
  end

  return items
end

function M.resolve(theme)
  if type(theme) == "table" then return theme end

  local cfg = config.get()
  local key = cfg.aliases[theme] or theme or cfg.default

  if _theme_map[key] then return _theme_map[key] end

  for _, item in ipairs(cfg.themes) do
    if item.key == key or item.scheme == key then return item end
  end

  return _theme_map[cfg.default] or { key = cfg.default, label = cfg.default, scheme = cfg.default }
end

function M.family_key(item)
  return item.plugin or ("builtin:" .. (item.scheme or "default"))
end

function M.find_family_variant(item, mode)
  local cfg = config.get()
  local family = M.family_key(item)
  local wanted = mode == "light" and "light" or "dark"
  local options = {}

  for _, theme in ipairs(cfg.themes) do
    if M.family_key(theme) == family and ((theme.opts and theme.opts.background) or "dark") == wanted then
      table.insert(options, theme)
    end
  end

  if #options == 0 then return nil end
  return options[1]
end

return M
