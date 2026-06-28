-- Shared surface helpers: derive an opaque, theme-aware popup/float background
-- and pick legible foregrounds. Used by colorscheme-sync.popups and the Avante
-- integration so floats and Avante share one consistent surface across themes.
local palette = require("colorscheme-sync.palette")

local M = {}

--- Relative luminance (0..1) of a hex color, sRGB-weighted approximation.
---@param hex string
---@return number
local function luminance(hex)
  local r, g, b = palette.hex_to_rgb(hex)
  if not r then return 0.5 end
  return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
end

--- Pick a foreground that stays legible on top of `bg_hex`.
---@param bg_hex string
---@param dark_fg? string fallback dark text (default "#11111b")
---@param light_fg? string fallback light text (default "#f5f5f5")
---@return string
function M.readable_on(bg_hex, dark_fg, light_fg)
  dark_fg = dark_fg or "#11111b"
  light_fg = light_fg or "#f5f5f5"
  if luminance(bg_hex) > 0.55 then
    return dark_fg
  end
  return light_fg
end

--- Build the popup surface for the active theme/background.
---@return { mode: string, palette: table, float_bg: string }
function M.build()
  local mode = vim.o.background == "light" and "light" or "dark"
  local p = palette.build(mode)
  -- Lift the editor background slightly toward the foreground so floats read as
  -- "elevated" and stay opaque even when Normal is transparent.
  local alpha = mode == "light" and 0.08 or 0.06
  return {
    mode = mode,
    palette = p,
    float_bg = palette.blend_hex(p.fg, p.bg, alpha),
  }
end

M.luminance = luminance

return M
