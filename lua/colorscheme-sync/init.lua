local M = {}

local config = require("colorscheme-sync.config")
local state = require("colorscheme-sync.state")
local catalog = require("colorscheme-sync.catalog")
local apply = require("colorscheme-sync.apply")
local sync = require("colorscheme-sync.sync")
local transparency = require("colorscheme-sync.transparency")
local system_bg = require("colorscheme-sync.system_background")

M._initialized = false

function M.setup(opts)
  config.set(opts or {})
  local cfg = config.get()

  catalog.build_map(cfg.themes)

  local persisted = state.load(cfg.state_file, cfg.aliases, catalog.theme_map())
  if persisted and persisted.key then
    cfg.default = persisted.key
    config.set_default(persisted.key)
  end

  if vim.g.transparent_background == nil then
    if persisted and type(persisted.transparent) == "boolean" then
      vim.g.transparent_background = persisted.transparent
    else
      vim.g.transparent_background = cfg.transparency_default
    end
  end

  if type(vim.g.pure_colorscheme) ~= "string" or vim.g.pure_colorscheme == "" then
    vim.g.pure_colorscheme = cfg.default
  end

  M._setup_autocmds()
  M._initialized = true
end

function M._setup_autocmds()
  if M._autocmd_ready then return end
  M._autocmd_ready = true

  local cfg = config.get()
  local group = vim.api.nvim_create_augroup("ColorschemeSync", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      if vim.g._csync_applying or vim.g._csync_vim_leaving then return end
      transparency.apply(cfg.transparent_groups)
      sync.request(M.current_theme())
    end,
  })

  if cfg.system_sync then
    vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
      group = group,
      callback = function()
        M.sync_with_system()
      end,
    })

    system_bg.start_watcher(M, function() M.sync_with_system() end, cfg.system_poll_ms)
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      system_bg.stop_watcher(M)
      vim.g._csync_vim_leaving = true
    end,
  })

  M._setup_commands()

  if cfg.system_sync then
    vim.schedule(function()
      M.sync_with_system({ force = true })
    end)
  end
end

function M._setup_commands()
  vim.api.nvim_create_user_command("ColorScheme", function(cmd_opts)
    local arg = vim.trim(cmd_opts.args or "")
    if arg == "" then
      M.select()
    else
      M.apply(arg)
    end
  end, {
    nargs = "?",
    desc = "Switch colorscheme",
    complete = function()
      return vim.tbl_map(function(item) return item.key end, config.get().themes)
    end,
    force = true,
  })

  vim.api.nvim_create_user_command("ColorSchemeSync", function()
    sync.force(M.current_theme())
  end, { desc = "Force external tools sync", force = true })

  vim.api.nvim_create_user_command("ColorSchemeToggleBg", function()
    M.toggle_background()
  end, { desc = "Toggle dark/light background", force = true })

  vim.api.nvim_create_user_command("ColorSchemeTransparency", function(cmd_opts)
    local arg = vim.trim(cmd_opts.args or ""):lower()
    if arg == "on" or arg == "true" or arg == "1" then
      M.set_transparency(true)
    elseif arg == "off" or arg == "false" or arg == "0" then
      M.set_transparency(false)
    else
      M.set_transparency(not transparency.is_enabled())
    end
  end, {
    nargs = "?",
    desc = "Toggle/set transparency",
    complete = function() return { "on", "off", "toggle" } end,
    force = true,
  })
end

function M.current_theme(theme_key)
  return catalog.resolve(theme_key or vim.g.pure_colorscheme or vim.g.colors_name or config.get().default)
end

function M.apply(theme, opts)
  return apply.apply(theme, opts)
end

function M.select()
  local items = catalog.options()
  local picker_ok, picker = pcall(require, "colorscheme-sync.picker")
  if picker_ok then
    picker.select(items, function(item)
      if item then M.apply(item) end
    end)
  else
    vim.ui.select(items, {
      prompt = "Colorscheme",
      format_item = function(item) return item.label end,
    }, function(item)
      if item then M.apply(item) end
    end)
  end
end

function M.toggle_background()
  return apply.toggle_background()
end

function M.set_background_mode(mode, opts)
  return apply.set_background_mode(mode, opts)
end

function M.set_transparency(enabled)
  vim.g.transparent_background = enabled == true
  M.apply(vim.g.pure_colorscheme or config.get().default)
end

function M.is_transparent()
  return transparency.is_enabled()
end

function M.is_dark_background()
  return vim.o.background == "dark"
end

function M.toggle_dark_background()
  local dark = not M.is_dark_background()
  M.set_background_mode(dark and "dark" or "light")
  return dark
end

function M.toggle_transparent_background()
  local transparent = not M.is_transparent()
  M.set_transparency(transparent)
  return transparent
end

function M.sync_with_system(opts)
  return system_bg.sync(opts, {
    default = config.get().default,
    resolve = catalog.resolve,
    set_background_mode = M.set_background_mode,
  })
end

function M.theme_profile(theme_key)
  local item = M.current_theme(theme_key)
  local cfg = config.get()
  local profile = cfg.sync_profiles[item.key] or {}
  return vim.tbl_extend("force", { key = item.key, scheme = item.scheme, plugin = item.plugin }, profile)
end

function M.lualine_theme(theme_key)
  local item = M.current_theme(theme_key)
  local cfg = config.get()
  local profile = cfg.sync_profiles[item.key] or {}
  local lualine_profile = profile.lualine or { provider = "auto" }

  if lualine_profile.provider == "catppuccin" then
    local ok, cat_lualine = pcall(require, "catppuccin.utils.lualine")
    if ok and type(cat_lualine) == "function" then
      return cat_lualine(lualine_profile.flavour or "mocha")
    end
  end

  if lualine_profile.provider == "builtin" and type(lualine_profile.name) == "string" then
    local ok = pcall(require, "lualine.themes." .. lualine_profile.name)
    if ok then return lualine_profile.name end
  end

  return "auto"
end

return M
