-- tests/test_apply.lua: TDD for apply/colorscheme switching
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local config = require("colorscheme-sync.config")
local catalog = require("colorscheme-sync.catalog")
local apply = require("colorscheme-sync.apply")

local test_themes = {
  { key = "habamax", label = "Habamax", scheme = "habamax", opts = { background = "dark" }, fixed_background = true },
  { key = "default-dark", label = "Default Dark", scheme = "default", opts = { background = "dark" } },
  { key = "default-light", label = "Default Light", scheme = "default", opts = { background = "light" } },
}

local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")
local state_file = tmpdir .. "/state.json"

config.set({
  default = "habamax",
  themes = test_themes,
  aliases = {},
  state_file = state_file,
  sync_tools = {},
  system_sync = false,
})
catalog.build_map(test_themes)

-- TEST: apply sets colorscheme and vim globals
vim.g.transparent_background = false
local ok = apply.apply("habamax", { notify = false })
t.eq(true, ok, "apply returns true on success")
t.eq("habamax", vim.g.pure_colorscheme, "apply sets pure_colorscheme global")
t.eq("dark", vim.o.background, "apply sets background")

-- TEST: apply persists state
local content = table.concat(vim.fn.readfile(state_file), "\n")
local decoded = vim.json.decode(content)
t.eq("habamax", decoded.key, "apply persists key")
t.eq(false, decoded.transparent, "apply persists transparent")

-- TEST: apply fails gracefully for non-existent scheme
local fail_ok = apply.apply({ key = "bad", label = "Bad", scheme = "zzz_nonexistent_scheme_zzz", opts = {} }, { notify = false })
t.eq(false, fail_ok, "apply returns false for bad scheme")

-- TEST: apply guards against reentrancy
vim.g._csync_applying = true
local reenter_ok = apply.apply("habamax", { notify = false })
t.eq(false, reenter_ok, "apply returns false during reentrancy")
vim.g._csync_applying = false

-- TEST: toggle_background switches dark/light within family
vim.g.transparent_background = false
apply.apply("default-dark", { notify = false })
t.eq("dark", vim.o.background, "starts dark")
apply.toggle_background()
t.eq("light", vim.o.background, "toggles to light")
t.eq("default-light", vim.g.pure_colorscheme, "toggles to light variant")

-- TEST: toggle_background blocked for fixed_background
apply.apply("habamax", { notify = false })
local toggle_result = apply.set_background_mode("light")
t.eq(false, toggle_result, "set_background_mode blocked for fixed_background")

-- TEST: on_change callback fires
local changed_to = nil
config.set({
  default = "habamax",
  themes = test_themes,
  aliases = {},
  state_file = state_file,
  sync_tools = {},
  system_sync = false,
  on_change = function(item) changed_to = item.key end,
})
catalog.build_map(test_themes)
apply.apply("default-dark", { notify = false })
t.eq("default-dark", changed_to, "on_change fires with applied theme")

-- Cleanup
vim.fn.delete(tmpdir, "rf")
vim.g.transparent_background = nil
vim.g.pure_colorscheme = nil
vim.g._csync_applying = nil

local success = t.report()
if not success then vim.cmd("cq!") end
