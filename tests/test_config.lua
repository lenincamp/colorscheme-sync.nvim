-- tests/test_config.lua: TDD for config module
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local config = require("colorscheme-sync.config")

-- TEST: defaults returns valid structure
local defaults = config.defaults()
t.eq("habamax", defaults.default, "defaults has habamax as default")
t.ok(type(defaults.themes) == "table", "defaults has themes table")
t.ok(type(defaults.aliases) == "table", "defaults has aliases table")
t.ok(type(defaults.transparent_groups) == "table", "defaults has transparent_groups")
t.eq(false, defaults.transparency_default, "defaults transparency_default is false")
t.ok(defaults.state_file:find("colorscheme.json", 1, true), "defaults state_file ends in colorscheme.json")
t.eq(true, defaults.system_sync, "defaults system_sync is true")
t.eq(8000, defaults.system_poll_ms, "defaults system_poll_ms is 8000")

-- TEST: set merges with defaults
config.set({ default = "catppuccin-mocha", system_poll_ms = 5000 })
local cfg = config.get()
t.eq("catppuccin-mocha", cfg.default, "set overrides default")
t.eq(5000, cfg.system_poll_ms, "set overrides system_poll_ms")
t.eq(true, cfg.system_sync, "set preserves system_sync from defaults")
t.ok(type(cfg.transparent_groups) == "table" and #cfg.transparent_groups > 0, "set preserves transparent_groups")

-- TEST: set_default changes default
config.set_default("gruvbox-hard")
t.eq("gruvbox-hard", config.get().default, "set_default updates default")

-- TEST: set resets to defaults when called again
config.set({})
local fresh = config.get()
t.eq("habamax", fresh.default, "set with empty opts resets to defaults")

-- TEST: deep extend does not mutate defaults
config.set({ themes = { { key = "test", label = "Test", scheme = "test" } } })
local after = config.get()
t.eq(1, #after.themes, "custom themes override")
local defaults_after = config.defaults()
t.eq(0, #defaults_after.themes, "defaults themes not mutated")

local success = t.report()
if not success then vim.cmd("cq!") end
