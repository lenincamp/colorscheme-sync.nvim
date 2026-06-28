-- Avante recolor, theme-agnostic.
--
-- avante.nvim hardcodes One Dark accents for its titles, buttons, spinners,
-- task list, logo and pending-diff markers and never re-derives them from the
-- active colorscheme (see avante/highlights.lua). We define those groups from
-- the theme palette so Avante matches whatever theme is selected, on every
-- switch. Groups that Avante links to theme groups (Comment/Keyword/NormalFloat)
-- are left to Avante's own setup so they keep tracking the theme automatically.
--
-- Because colorscheme-sync loads at startup (before Avante, which is lazy), the
-- first apply() seeds these groups; Avante's first `highlights.setup()` then
-- records them as already-set and never clobbers them, and this callback
-- refreshes them from the new palette on each ColorScheme.
local highlights = require("colorscheme-sync.highlights")
local surface = require("colorscheme-sync.surface")
local palette = require("colorscheme-sync.palette")
local transparency = require("colorscheme-sync.transparency")

local M = {}

local function apply()
  local s = surface.build()
  local p = s.palette
  local float_bg = s.float_bg
  -- Sidebar follows the transparency toggle like NormalFloat/popups. The active
  -- colorscheme (e.g. catppuccin) sets AvanteSidebarNormal to an opaque bg, and
  -- Avante records it as already-set so it never re-links it to NormalFloat;
  -- we override it here (csync appliers run after the colorscheme) so the
  -- sidebar stays transparent when transparency is on.
  local sidebar_bg = transparency.is_enabled() and "NONE" or s.float_bg

  local function set(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end
  local function on(bg)
    return surface.readable_on(bg)
  end

  -- Titles / subtitles
  set("AvanteTitle", { fg = on(p.ok), bg = p.ok, bold = true })
  set("AvanteReversedTitle", { fg = p.ok, bg = float_bg })
  set("AvanteSubtitle", { fg = on(p.accent), bg = p.accent })
  set("AvanteReversedSubtitle", { fg = p.accent, bg = float_bg })
  set("AvanteThirdTitle", { fg = p.fg, bg = p.selection })
  set("AvanteReversedThirdTitle", { fg = p.selection, bg = float_bg })
  set("AvanteConfirmTitle", { fg = on(p.error), bg = p.error, bold = true })

  -- Buttons: neutral base, semantic hover
  set("AvanteButtonDefault", { fg = on(p.border), bg = p.border })
  set("AvanteButtonDefaultHover", { fg = on(p.ok), bg = p.ok })
  set("AvanteButtonPrimary", { fg = on(p.border), bg = p.border })
  set("AvanteButtonPrimaryHover", { fg = on(p.accent), bg = p.accent })
  set("AvanteButtonDanger", { fg = on(p.border), bg = p.border })
  set("AvanteButtonDangerHover", { fg = on(p.error), bg = p.error })

  -- State spinners (filled badges)
  set("AvanteStateSpinnerGenerating", { fg = on(p.warn), bg = p.warn })
  set("AvanteStateSpinnerToolCalling", { fg = on(p.accent), bg = p.accent })
  set("AvanteStateSpinnerFailed", { fg = on(p.error), bg = p.error })
  set("AvanteStateSpinnerSucceeded", { fg = on(p.ok), bg = p.ok })
  set("AvanteStateSpinnerSearching", { fg = on(p.accent), bg = p.accent })
  set("AvanteStateSpinnerThinking", { fg = on(p.accent), bg = p.accent })
  set("AvanteStateSpinnerCompacting", { fg = on(p.accent), bg = p.accent })

  -- Task list / thinking (text only, transparent background)
  set("AvanteTaskRunning", { fg = p.accent })
  set("AvanteTaskCompleted", { fg = p.ok })
  set("AvanteTaskFailed", { fg = p.error })
  set("AvanteThinking", { fg = p.accent })

  -- Pending diff markers
  set("AvanteToBeDeleted", { bg = p.error_bg, strikethrough = true })
  set("AvanteToBeDeletedWOStrikethrough", { bg = p.error_emph_bg })

  -- Reversed normal: swap Normal fg/bg
  set("AvanteReversedNormal", { fg = p.bg, bg = p.fg })

  -- Ask/prompt input popup: this is the one Avante float that reads badly when
  -- transparent -- it floats over buffer text (with winblend) so a see-through
  -- input is unreadable. Pin it to the opaque elevated surface. The sidebar and
  -- other Avante floats link to NormalFloat, so they follow the transparency
  -- toggle like normal popups.
  set("AvantePromptInput", { fg = p.fg, bg = float_bg })
  set("AvantePromptInputBorder", { fg = p.border, bg = float_bg })

  -- Sidebar normal: match buffer transparency (NONE when transparent), elevated
  -- opaque surface otherwise. Mirrors NormalFloat/popups behavior.
  set("AvanteSidebarNormal", { fg = p.fg, bg = sidebar_bg })

  -- Popup hint floats over buffer text -> keep opaque like the prompt input.
  set("AvantePopupHint", { fg = p.border, bg = float_bg })

  -- Sidebar separators: it's a split, so follow the sidebar transparency.
  set("AvanteSidebarWinSeparator", { fg = p.border, bg = sidebar_bg })
  set("AvanteSidebarWinHorizontalSeparator", { fg = p.border, bg = sidebar_bg })

  -- Logo gradient: fade from border to fg across the 14 lines
  for i = 1, 14 do
    local t = (i - 1) / 13
    set("AvanteLogoLine" .. i, { fg = palette.blend_hex(p.fg, p.border, t) })
  end
end

function M.setup()
  highlights.register("avante", apply)
end

return M
