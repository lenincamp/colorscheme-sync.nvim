-- tests/test_presets.lua: TDD for presets module (catalog, integrations, lazy spec)
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local presets = require("colorscheme-sync.presets")
local catalog = require("colorscheme-sync.presets.catalog")
local integrations = require("colorscheme-sync.presets.integrations")

-- TEST: catalog.themes is populated
t.ok(#catalog.themes > 0, "catalog has themes")
t.eq(17, #catalog.themes, "catalog has 17 built-in themes")

-- TEST: each theme has required fields
for _, theme in ipairs(catalog.themes) do
  t.ok(type(theme.key) == "string" and theme.key ~= "", "theme.key is non-empty string: " .. tostring(theme.key))
  t.ok(type(theme.label) == "string", "theme.label is string: " .. theme.key)
  t.ok(type(theme.scheme) == "string", "theme.scheme is string: " .. theme.key)
  t.ok(type(theme.opts) == "table", "theme.opts is table: " .. theme.key)
  t.ok(theme.opts.background == "dark" or theme.opts.background == "light", "theme.opts.background is dark/light: " .. theme.key)
end

-- TEST: aliases resolve to valid theme keys
local theme_keys = {}
for _, theme in ipairs(catalog.themes) do
  theme_keys[theme.key] = true
end
for alias, target in pairs(catalog.aliases) do
  t.ok(theme_keys[target], "alias '" .. alias .. "' points to valid theme key '" .. target .. "'")
end

-- TEST: sync_profiles exist for all plugin-based themes
for _, theme in ipairs(catalog.themes) do
  t.ok(catalog.sync_profiles[theme.key] ~= nil, "sync_profile exists for " .. theme.key)
end

-- TEST: sync_profiles have required fields
for key, profile in pairs(catalog.sync_profiles) do
  t.ok(type(profile.tmux) == "string", "sync_profile[" .. key .. "].tmux is string")
  t.ok(type(profile.delta) == "string", "sync_profile[" .. key .. "].delta is string")
  t.ok(type(profile.iterm2) == "string", "sync_profile[" .. key .. "].iterm2 is string")
end

-- TEST: transparent_groups is non-empty
t.ok(#catalog.transparent_groups > 0, "transparent_groups is non-empty")

-- TEST: integrations has functions for all plugin-based themes
local plugin_names = {}
for _, theme in ipairs(catalog.themes) do
  if theme.plugin then plugin_names[theme.plugin] = true end
end
for plugin_name in pairs(plugin_names) do
  t.ok(type(integrations[plugin_name]) == "function", "integration exists for plugin: " .. plugin_name)
end

-- TEST: presets.defaults() returns all catalog data
local defs = presets.defaults()
t.eq(17, #defs.themes, "presets.defaults() has 17 themes")
t.ok(type(defs.aliases) == "table", "presets.defaults() has aliases")
t.ok(type(defs.sync_profiles) == "table", "presets.defaults() has sync_profiles")
t.ok(type(defs.transparent_groups) == "table", "presets.defaults() has transparent_groups")

-- TEST: presets.load_plugin is a function
t.ok(type(presets.load_plugin) == "function", "presets.load_plugin is callable")

-- TEST: load_plugin sets globals for catppuccin
vim.g.catppuccin_flavour = nil
presets.load_plugin({ key = "catppuccin-mocha", scheme = "catppuccin", plugin = "catppuccin", opts = { flavour = "mocha", background = "dark" } })
t.eq("mocha", vim.g.catppuccin_flavour, "load_plugin sets catppuccin_flavour")

-- TEST: load_plugin sets globals for tokyonight
vim.g.pure_tokyonight_style = nil
presets.load_plugin({ key = "tokyonight-night", scheme = "tokyonight", plugin = "tokyonight", opts = { style = "night", background = "dark" } })
t.eq("night", vim.g.pure_tokyonight_style, "load_plugin sets tokyonight style")

-- TEST: load_plugin sets globals for kanagawa
vim.g.pure_kanagawa_theme = nil
presets.load_plugin({ key = "kanagawa-dragon", scheme = "kanagawa-dragon", plugin = "kanagawa", opts = { theme = "dragon", background = "dark" } })
t.eq("dragon", vim.g.pure_kanagawa_theme, "load_plugin sets kanagawa theme")

-- TEST: load_plugin sets globals for cyberdream variant
vim.g.pure_cyberdream_variant = nil
presets.load_plugin({ key = "cyberdream", scheme = "cyberdream", plugin = "cyberdream", opts = { variant = "default", background = "dark" } })
t.eq("default", vim.g.pure_cyberdream_variant, "load_plugin sets cyberdream variant")

-- TEST: load_plugin sets globals for gruvbox contrast
vim.g.pure_gruvbox_contrast = nil
presets.load_plugin({ key = "gruvbox-hard", scheme = "gruvbox", plugin = "gruvbox", opts = { contrast = "hard", background = "dark" } })
t.eq("hard", vim.g.pure_gruvbox_contrast, "load_plugin sets gruvbox contrast")

-- TEST: lazy_dependencies returns valid specs
local deps = presets.lazy_dependencies()
t.ok(#deps >= 7, "lazy_dependencies has at least 7 entries")
for _, dep in ipairs(deps) do
  t.ok(type(dep[1]) == "string", "dep has source string")
  t.eq(true, dep.lazy, "dep is lazy loaded")
end

-- TEST: lazy_spec returns valid plugin spec
local spec = presets.lazy_spec({ system_sync = true })
t.eq(1000, spec.priority, "lazy_spec priority is 1000")
t.eq(false, spec.lazy, "lazy_spec is not lazy (loads immediately)")
t.ok(type(spec.dependencies) == "table", "lazy_spec has dependencies")
t.ok(type(spec.config) == "function", "lazy_spec has config function")

local success = t.report()
if not success then vim.cmd("cq!") end
