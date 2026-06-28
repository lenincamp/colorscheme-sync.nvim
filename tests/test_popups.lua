-- tests/test_popups.lua: opaque, theme-derived popup/float surface
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")

-- Seed a deterministic "theme" so palette.build reads stable colors.
vim.o.background = "dark"
vim.api.nvim_set_hl(0, "Normal", { fg = "#cdd6f4", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6c7086" })
vim.api.nvim_set_hl(0, "Visual", { bg = "#313244" })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#cba6f7" })

-- TEST: float/pmenu groups are NOT in transparent_groups (popups.lua owns them)
local catalog = require("colorscheme-sync.presets.catalog")
local stripped = {}
for _, g in ipairs(catalog.transparent_groups) do
  stripped[g] = true
end
for _, g in ipairs({ "NormalFloat", "FloatBorder", "FloatTitle", "Pmenu", "PmenuBorder" }) do
  t.ok(not stripped[g], g .. " excluded from transparent_groups")
end
t.ok(stripped["Normal"], "Normal still transparent")

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- TEST: with transparency ON, floats/popups inherit the terminal bg (no bg)
vim.g.transparent_background = true
require("colorscheme-sync.popups").setup()

t.eq(nil, hl("NormalFloat").bg, "NormalFloat transparent when transparency on")
t.eq(nil, hl("Pmenu").bg, "Pmenu transparent when transparency on")
t.ok(hl("PmenuSel").bg ~= nil, "PmenuSel keeps a selection bg even when transparent")
t.ok(hl("FloatBorder").fg ~= nil, "FloatBorder has fg")

-- TEST: with transparency OFF, floats get an opaque, elevated surface
vim.g.transparent_background = false
require("colorscheme-sync.highlights").apply()

local nf = hl("NormalFloat")
t.ok(nf.bg ~= nil, "NormalFloat has opaque bg when transparency off")
t.ok(nf.bg ~= 0x1e1e2e, "NormalFloat bg is elevated above Normal")
t.ok(hl("Pmenu").bg ~= nil, "Pmenu opaque when transparency off")

vim.g.transparent_background = nil

local success = t.report()
if not success then vim.cmd("cq!") end
