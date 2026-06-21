-- tests/test_sync.lua: TDD for external sync module
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local config = require("colorscheme-sync.config")
local sync = require("colorscheme-sync.sync")

local synced_themes = {}

local function mock_tool(ctx)
  table.insert(synced_themes, ctx.theme)
end

config.set({
  default = "habamax",
  themes = { { key = "habamax", label = "Habamax", scheme = "habamax" } },
  aliases = {},
  sync_tools = { mock_tool },
  sync_profiles = {
    habamax = { tmux = "gruvbox", delta = "ansi" },
  },
})

-- TEST: request runs tools in headless (no UIs)
synced_themes = {}
sync.request({ key = "habamax", label = "Habamax", scheme = "habamax" })
t.eq(1, #synced_themes, "request runs tool in headless mode")
t.eq("habamax", synced_themes[1].key, "request passes theme to tool")

-- TEST: force runs tools immediately
synced_themes = {}
sync.force({ key = "habamax", label = "Habamax", scheme = "habamax" })
t.eq(1, #synced_themes, "force runs tool immediately")

-- TEST: _run_tools handles tool errors gracefully
local function bad_tool(_)
  error("intentional test error")
end

config.set({
  default = "habamax",
  themes = { { key = "habamax", label = "Habamax", scheme = "habamax" } },
  aliases = {},
  sync_tools = { bad_tool, mock_tool },
  sync_profiles = {},
})

synced_themes = {}
sync._run_tools({ key = "habamax" }, { bad_tool, mock_tool })
t.eq(1, #synced_themes, "_run_tools continues after tool error")

local success = t.report()
if not success then vim.cmd("cq!") end
