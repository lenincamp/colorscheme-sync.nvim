-- tests/test_catalog.lua: TDD for catalog/model logic
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local config = require("colorscheme-sync.config")
local catalog = require("colorscheme-sync.catalog")

local test_themes = {
  { key = "gruvbox-hard", label = "Gruvbox Hard", scheme = "gruvbox", plugin = "gruvbox", opts = { background = "dark" } },
  { key = "gruvbox-light", label = "Gruvbox Light", scheme = "gruvbox", plugin = "gruvbox", opts = { background = "light" } },
  { key = "catppuccin-mocha", label = "Catppuccin Mocha", scheme = "catppuccin", plugin = "catppuccin", opts = { background = "dark" } },
  { key = "catppuccin-latte", label = "Catppuccin Latte", scheme = "catppuccin", plugin = "catppuccin", opts = { background = "light" } },
  { key = "habamax", label = "Habamax", scheme = "habamax", opts = { background = "dark" }, fixed_background = true },
}

config.set({
  default = "habamax",
  themes = test_themes,
  aliases = {
    catppuccin = "catppuccin-mocha",
    gruvbox = "gruvbox-hard",
  },
})

catalog.build_map(test_themes)

-- TEST: build_map creates lookup
local map = catalog.theme_map()
t.ok(map["gruvbox-hard"] ~= nil, "build_map indexes gruvbox-hard")
t.ok(map["catppuccin-mocha"] ~= nil, "build_map indexes catppuccin-mocha")
t.ok(map["nonexistent"] == nil, "build_map does not index nonexistent")

-- TEST: resolve by key
local resolved = catalog.resolve("gruvbox-hard")
t.eq("gruvbox-hard", resolved.key, "resolve by exact key")

-- TEST: resolve by alias
local alias_resolved = catalog.resolve("catppuccin")
t.eq("catppuccin-mocha", alias_resolved.key, "resolve by alias")

-- TEST: resolve table passthrough
local table_item = { key = "custom", label = "Custom", scheme = "custom" }
t.eq(table_item, catalog.resolve(table_item), "resolve table passthrough")

-- TEST: resolve unknown falls to default
local unknown = catalog.resolve("zzz_nonexistent_theme_zzz")
t.eq("habamax", unknown.key, "resolve unknown falls to default")

-- TEST: resolve by scheme name
local by_scheme = catalog.resolve("catppuccin")
t.eq("catppuccin-mocha", by_scheme.key, "resolve by alias then scheme")

-- TEST: family_key
t.eq("gruvbox", catalog.family_key(test_themes[1]), "family_key plugin-based")
t.eq("builtin:habamax", catalog.family_key(test_themes[5]), "family_key builtin-based")

-- TEST: find_family_variant dark->light
local light_variant = catalog.find_family_variant(test_themes[1], "light")
t.ok(light_variant ~= nil, "find_family_variant returns light variant")
t.eq("gruvbox-light", light_variant.key, "find_family_variant gruvbox light")

-- TEST: find_family_variant light->dark
local dark_variant = catalog.find_family_variant(test_themes[2], "dark")
t.eq("gruvbox-hard", dark_variant.key, "find_family_variant gruvbox dark")

-- TEST: find_family_variant nil for fixed_background with no variant
local no_variant = catalog.find_family_variant(test_themes[5], "light")
t.eq(nil, no_variant, "find_family_variant nil for habamax light (no light variant)")

-- TEST: options returns dark/light grouped
local options = catalog.options()
t.ok(#options > 0, "options returns items")
local found_dark_header = false
local found_light_header = false
for _, item in ipairs(options) do
  if item.key == "_header_dark" then found_dark_header = true end
  if item.key == "_header_light" then found_light_header = true end
end
t.ok(found_dark_header, "options has dark header")
t.ok(found_light_header, "options has light header")

local success = t.report()
if not success then vim.cmd("cq!") end
