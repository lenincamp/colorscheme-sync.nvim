local M = {}

local presets = require("colorscheme-sync.presets")
local preset_defaults = presets.defaults()

local defaults = {
  default = "catppuccin-mocha",
  themes = preset_defaults.themes,
  aliases = preset_defaults.aliases,
  transparent_groups = preset_defaults.transparent_groups,
  transparency_default = true,
  state_file = vim.fn.stdpath("state") .. "/colorscheme.json",
  system_sync = true,
  system_poll_ms = 8000,
  sync_profiles = preset_defaults.sync_profiles,
  sync_tools = nil, -- nil = use all built-in tools
  load_plugin = presets.load_plugin,
  on_change = nil,
}

local current = vim.deepcopy(defaults)

function M.set(opts)
  current = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  -- load_plugin is a function; tbl_deep_extend won't copy it properly
  if opts and opts.load_plugin then
    current.load_plugin = opts.load_plugin
  elseif not current.load_plugin then
    current.load_plugin = defaults.load_plugin
  end
end

function M.get()
  return current
end

function M.set_default(key)
  current.default = key
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
