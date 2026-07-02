-- tests/test_integration.lua: Integration test for full setup flow
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")

-- Reset all state
vim.g.transparent_background = nil
vim.g.pure_colorscheme = nil
vim.g._csync_applying = nil
vim.g._csync_vim_leaving = nil
vim.g._csync_system_mode_last = nil
vim.g.loaded_colorscheme_sync = nil

-- Force fresh require
for key in pairs(package.loaded) do
  if key:find("colorscheme%-sync", 1, true) then
    package.loaded[key] = nil
  end
end

local csync = require("colorscheme-sync")

local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")
local state_file = tmpdir .. "/state.json"

local synced = {}
local function tmux_sync(ctx)
  table.insert(synced, { tool = "tmux", theme = ctx.theme })
end

-- TEST: full setup flow
csync.setup({
  default = "habamax",
  themes = {
    { key = "habamax", label = "Habamax", scheme = "habamax", opts = { background = "dark" }, fixed_background = true },
    { key = "default-dark", label = "Default Dark", scheme = "default", opts = { background = "dark" } },
    { key = "default-light", label = "Default Light", scheme = "default", opts = { background = "light" } },
  },
  aliases = {},
  state_file = state_file,
  system_sync = false,
  sync_tools = { tmux_sync },
  sync_profiles = {
    habamax = { tmux = "gruvbox" },
  },
})

t.eq(true, csync._initialized, "setup completes")
t.eq("habamax", vim.g.pure_colorscheme, "setup sets pure_colorscheme")

-- TEST: apply through public API
synced = {}
local ok = csync.apply("default-dark", { notify = false })
t.eq(true, ok, "apply through public API returns true")
t.eq("default-dark", vim.g.pure_colorscheme, "apply updates global")

-- TEST: current_theme resolves
local current = csync.current_theme()
t.eq("default-dark", current.key, "current_theme resolves")

-- TEST: toggle_background
csync.toggle_background()
t.eq("light", vim.o.background, "toggle_background switches to light")

-- TEST: set_transparency
csync.set_transparency(false)
t.eq(false, csync.is_transparent(), "set_transparency to false")
csync.set_transparency(true)
t.eq(true, csync.is_transparent(), "set_transparency to true")

-- TEST: theme_profile
local profile = csync.theme_profile("habamax")
t.eq("habamax", profile.key, "theme_profile key")
t.eq("gruvbox", profile.tmux, "theme_profile tmux")

-- TEST: commands exist
local scheme_cmd = vim.api.nvim_get_commands({})["ColorScheme"]
t.ok(scheme_cmd ~= nil, "ColorScheme command registered")
local sync_cmd = vim.api.nvim_get_commands({})["ColorSchemeSync"]
t.ok(sync_cmd ~= nil, "ColorSchemeSync command registered")
local toggle_cmd = vim.api.nvim_get_commands({})["ColorSchemeToggleBg"]
t.ok(toggle_cmd ~= nil, "ColorSchemeToggleBg command registered")
local transp_cmd = vim.api.nvim_get_commands({})["ColorSchemeTransparency"]
t.ok(transp_cmd ~= nil, "ColorSchemeTransparency command registered")

-- Cleanup
vim.fn.delete(tmpdir, "rf")
vim.g.transparent_background = nil
vim.g.pure_colorscheme = nil

local success = t.report()
if not success then vim.cmd("cq!") end
