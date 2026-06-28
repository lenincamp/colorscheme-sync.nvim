-- Theme-derived surface for floating windows and popup menus. Honors the
-- transparency toggle: when transparent, floats/popups inherit the terminal
-- background (bg = NONE) like normal buffers; when opaque, they get an elevated,
-- theme-derived surface so they read as "lifted". Registered on ColorScheme so
-- it tracks every theme switch.
local highlights = require("colorscheme-sync.highlights")
local surface = require("colorscheme-sync.surface")
local transparency = require("colorscheme-sync.transparency")

local M = {}

local function apply()
  local s = surface.build()
  local p = s.palette
  local float_bg = transparency.is_enabled() and "NONE" or s.float_bg

  local function set(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  set("NormalFloat", { fg = p.fg, bg = float_bg })
  set("FloatBorder", { fg = p.border, bg = float_bg })
  set("FloatTitle", { fg = p.accent, bg = float_bg, bold = true })

  set("Pmenu", { fg = p.fg, bg = float_bg })
  set("PmenuBorder", { fg = p.border, bg = float_bg })
  set("PmenuSel", { fg = p.fg, bg = p.selection, bold = true })
  set("PmenuSbar", { bg = float_bg })
  set("PmenuThumb", { bg = p.border })
end

function M.setup()
  highlights.register("popups", apply)
end

return M
