-- tests/test_avante.lua: Avante groups are derived from the active theme palette
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")

-- Seed a deterministic "theme".
vim.o.background = "dark"
vim.api.nvim_set_hl(0, "Normal", { fg = "#cdd6f4", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6c7086" })
vim.api.nvim_set_hl(0, "Visual", { bg = "#313244" })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#cba6f7" })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f38ba8" })
vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a6e3a1" })

vim.g.transparent_background = true
require("colorscheme-sync.integrations.avante").setup()

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- TEST: badge-style groups get both fg and bg (not the One Dark hardcode)
for _, g in ipairs({ "AvanteTitle", "AvanteSubtitle", "AvanteConfirmTitle", "AvanteButtonDefault" }) do
  local h = hl(g)
  t.ok(h.fg ~= nil and h.bg ~= nil, g .. " has fg and bg from palette")
end

-- TEST: AvanteTitle uses the theme's "ok"/green-ish accent, not #98c379 One Dark
t.ok(hl("AvanteTitle").bg ~= 0x98c379, "AvanteTitle bg is theme-derived, not One Dark")

-- TEST: logo gradient is fully populated
for i = 1, 14 do
  t.ok(hl("AvanteLogoLine" .. i).fg ~= nil, "AvanteLogoLine" .. i .. " has fg")
end

-- TEST: pending-delete keeps strikethrough
t.ok(hl("AvanteToBeDeleted").strikethrough == true, "AvanteToBeDeleted strikethrough preserved")

-- TEST: Ask/prompt input popup stays opaque (it links nothing transparent and is
-- pinned to the elevated surface so it reads even over buffer text)
t.ok(hl("AvantePromptInput").bg ~= nil, "AvantePromptInput has opaque bg")
t.ok(hl("AvantePromptInputBorder").bg ~= nil, "AvantePromptInputBorder has opaque bg")

-- TEST: sidebar + separators follow transparency (NONE when on), unlike prompt input
t.ok(hl("AvanteSidebarNormal").bg == nil, "AvanteSidebarNormal transparent when toggle on")
t.ok(hl("AvanteSidebarWinSeparator").bg == nil, "AvanteSidebarWinSeparator transparent when toggle on")
t.ok(hl("AvanteSidebarWinHorizontalSeparator").bg == nil, "AvanteSidebarWinHorizontalSeparator transparent when toggle on")

-- TEST: popup hint stays opaque (floats over buffer text)
t.ok(hl("AvantePopupHint").bg ~= nil, "AvantePopupHint has opaque bg")

vim.g.transparent_background = false
require("colorscheme-sync.integrations.avante").setup()
t.ok(hl("AvanteSidebarNormal").bg ~= nil, "AvanteSidebarNormal opaque when toggle off")
t.ok(hl("AvanteSidebarWinSeparator").bg ~= nil, "AvanteSidebarWinSeparator opaque when toggle off")
vim.g.transparent_background = true
require("colorscheme-sync.integrations.avante").setup()

-- TEST: reversed normal swaps Normal fg/bg
local rn = hl("AvanteReversedNormal")
t.eq(0x1e1e2e, rn.fg, "AvanteReversedNormal fg = Normal bg")
t.eq(0xcdd6f4, rn.bg, "AvanteReversedNormal bg = Normal fg")

local success = t.report()
if not success then vim.cmd("cq!") end
