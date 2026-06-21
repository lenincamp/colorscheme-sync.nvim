-- tests/test_transparency.lua: TDD for transparency module
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local transparency = require("colorscheme-sync.transparency")

-- TEST: is_enabled reads vim.g.transparent_background
vim.g.transparent_background = true
t.eq(true, transparency.is_enabled(), "is_enabled true when global is true")

vim.g.transparent_background = false
t.eq(false, transparency.is_enabled(), "is_enabled false when global is false")

-- TEST: is_enabled defaults to true when nil
vim.g.transparent_background = nil
t.eq(true, transparency.is_enabled(), "is_enabled defaults to true")
t.eq(true, vim.g.transparent_background, "is_enabled sets global when nil")

-- TEST: apply removes bg from highlight groups
vim.g.transparent_background = true
vim.api.nvim_set_hl(0, "TestTranspGroup", { fg = "#ff0000", bg = "#000000" })
transparency.apply({ "TestTranspGroup" })
local hl = vim.api.nvim_get_hl(0, { name = "TestTranspGroup", link = false })
t.eq(nil, hl.bg, "apply removes bg from group")
t.ok(hl.fg ~= nil, "apply preserves fg")

-- TEST: apply does nothing when disabled
vim.g.transparent_background = false
vim.api.nvim_set_hl(0, "TestTranspGroupB", { fg = "#ff0000", bg = "#000000" })
transparency.apply({ "TestTranspGroupB" })
local hl2 = vim.api.nvim_get_hl(0, { name = "TestTranspGroupB", link = false })
t.ok(hl2.bg ~= nil, "apply preserves bg when disabled")

-- Cleanup
vim.g.transparent_background = nil

local success = t.report()
if not success then vim.cmd("cq!") end
