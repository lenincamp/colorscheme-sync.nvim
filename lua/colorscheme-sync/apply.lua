local M = {}

local config = require("colorscheme-sync.config")
local catalog = require("colorscheme-sync.catalog")
local state = require("colorscheme-sync.state")
local transparency = require("colorscheme-sync.transparency")
local sync = require("colorscheme-sync.sync")

function M.apply(theme, opts)
  opts = opts or {}
  if vim.g._csync_applying then return false end

  local item = type(theme) == "table" and theme or catalog.resolve_any(theme)
  local cfg = config.get()
  local previous_key = vim.g.pure_colorscheme
  local item_bg = (item.opts and item.opts.background) or "dark"
  local transparency_pref = transparency.is_enabled()

  vim.g._csync_applying = true
  vim.g.pure_colorscheme = item.key
  vim.o.background = item_bg

  if item.plugin and cfg.load_plugin then
    cfg.load_plugin(item)
  end

  local ok, err = pcall(vim.cmd.colorscheme, item.scheme)
  -- A third-party ColorScheme autocmd (e.g. Neovim core's lsp document_color,
  -- which asserts on a stale LSP client) can throw even when the scheme itself
  -- loaded fine. Treat the scheme as applied if colors_name actually changed.
  local loaded = vim.g.colors_name == item.scheme
  if not ok and not loaded then
    vim.g.pure_colorscheme = previous_key
    vim.g.transparent_background = transparency_pref
    vim.g._csync_applying = false
    vim.notify("Colorscheme failed [" .. item.scheme .. "]: " .. tostring(err), vim.log.levels.WARN)
    return false
  end
  if not ok then
    vim.notify("Colorscheme autocmd error [" .. item.scheme .. "]: " .. tostring(err), vim.log.levels.DEBUG)
  end

  vim.g.transparent_background = transparency_pref
  transparency.apply(cfg.transparent_groups)
  state.persist(cfg.state_file, item.key, transparency_pref)

  if opts.sync_external ~= false then
    sync.request(item)
  end

  if opts.notify ~= false then
    vim.notify("Colorscheme: " .. item.label, vim.log.levels.INFO)
  end

  if type(cfg.on_change) == "function" then
    pcall(cfg.on_change, item)
  end

  vim.g._csync_applying = false
  return true
end

function M.toggle_background()
  if vim.o.background == "dark" then
    return M.set_background_mode("light")
  end
  return M.set_background_mode("dark")
end

function M.set_background_mode(mode, opts)
  local current = catalog.resolve_any(vim.g.pure_colorscheme or vim.g.colors_name or config.get().default)
  local current_mode = (current.opts and current.opts.background) or "dark"

  if current.fixed_background and mode ~= current_mode then
    return false
  end

  if current_mode == mode then
    return false
  end

  local new_theme = vim.tbl_extend("force", {}, current, {
    opts = vim.tbl_extend("force", {}, current.opts or {}, { background = mode }),
  })
  return M.apply(new_theme, opts)
end

return M
