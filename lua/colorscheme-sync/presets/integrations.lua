-- Built-in theme integrations: setup functions for each colorscheme plugin.
-- Called by load_plugin when a theme is applied.
local M = {}

local function is_transparent()
  return vim.g.transparent_background == true
end

function M.catppuccin(opts)
  local ok, catppuccin = pcall(require, "catppuccin")
  if not ok then return end

  local flavour = opts.flavour or "mocha"
  local transparent = is_transparent()

  catppuccin.setup({
    flavour = flavour,
    background = { light = "latte", dark = "mocha" },
    transparent_background = transparent,
    show_end_of_buffer = false,
    term_colors = true,
    dim_inactive = { enabled = false, shade = "dark", percentage = 0.15 },
    styles = {
      comments = { "italic" },
      functions = { "bold" },
      keywords = { "italic" },
      operators = { "bold" },
      conditionals = { "bold" },
      loops = { "bold" },
      booleans = { "bold", "italic" },
      numbers = {},
      types = {},
      strings = {},
      variables = {},
      properties = {},
    },
    integrations = {
      avante = true,
      blink_cmp = true,
      dap = true,
      gitsigns = true,
      mason = true,
      mini = { enabled = true, indentscope_color = "" },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
      },
      treesitter_context = true,
      notifier = true,
      treesitter = true,
      render_markdown = true,
    },
    highlight_overrides = {
      all = function(cp)
        -- NormalFloat / FloatBorder / Pmenu* are intentionally NOT set here:
        -- colorscheme-sync.popups owns the opaque popup/float surface so the
        -- behaviour is identical across every theme. Setting them here would
        -- fight that single source of truth.
        return {
          CursorLineNr = { fg = cp.green },
          DiagnosticVirtualTextError = { bg = cp.none },
          DiagnosticVirtualTextWarn = { bg = cp.none },
          DiagnosticVirtualTextInfo = { bg = cp.none },
          DiagnosticVirtualTextHint = { bg = cp.none },
          LspInfoBorder = { link = "FloatBorder" },
          MasonNormal = { link = "NormalFloat" },
          NotifyBackground = { bg = cp.none },
          DapBreakpoint = { fg = cp.red, bg = cp.none },
          DapBreakpointCondition = { fg = cp.peach, bg = cp.none },
          DapLogPoint = { fg = cp.teal, bg = cp.none },
          DapStopped = { fg = cp.green, bg = cp.none },
          DapStoppedLine = { bg = cp.surface0 },
          DapBreakpointRejected = { fg = cp.overlay0, bg = cp.none },
          WinBar = { fg = cp.overlay2, bg = cp.none },
          WinBarNC = { fg = cp.surface2, bg = cp.none },
          WinBarIcon = { fg = cp.blue, bg = cp.none },
          WinBarPath = { fg = cp.overlay0, bg = cp.none },
          WinBarSep = { fg = cp.surface1, bg = cp.none },
          WinBarFile = { fg = cp.overlay2, bg = cp.none },
          WinBarMod = { fg = cp.overlay0, bg = cp.none },
          WinBarLine = { fg = cp.surface2, bg = cp.none },
        }
      end,
    },
  })
end

function M.gruvbox(opts)
  local ok, gruvbox = pcall(require, "gruvbox")
  if not ok then return end

  local transparent = is_transparent()
  local contrast = opts.contrast or "hard"

  gruvbox.setup({
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = true,
      emphasis = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    inverse = true,
    contrast = contrast,
    palette_overrides = {},
    overrides = transparent and {
      Normal = { bg = "none" },
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      SignColumn = { bg = "none" },
    } or {},
    dim_inactive = false,
    transparent_mode = transparent,
  })
end

function M.tokyonight(opts)
  local ok, tokyonight = pcall(require, "tokyonight")
  if not ok then return end

  local transparent = is_transparent()
  local style = opts.style or "moon"

  tokyonight.setup({
    style = style,
    transparent = transparent,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl)
      hl.NormalFloat = { bg = "none" }
      hl.FloatBorder = { bg = "none" }
      hl.SignColumn = { bg = "none" }
    end,
  })
end

function M.kanagawa(opts)
  local ok, kanagawa = pcall(require, "kanagawa")
  if not ok then return end

  local transparent = is_transparent()
  local theme = opts.theme or "wave"

  kanagawa.setup({
    compile = false,
    transparent = transparent,
    terminalColors = true,
    dimInactive = false,
    theme = theme,
    background = { dark = theme, light = "lotus" },
    colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
    overrides = function(colors)
      local t = colors.theme
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { fg = t.ui.float.fg_border, bg = "none" },
        SignColumn = { bg = "none" },
      }
    end,
  })
end

M["rose-pine"] = function(opts)
  local ok, rose_pine = pcall(require, "rose-pine")
  if not ok then return end

  local transparent = is_transparent()
  local variant = opts.variant or "moon"

  rose_pine.setup({
    variant = variant,
    dark_variant = variant,
    dim_inactive_windows = false,
    extend_background_behind_borders = false,
    styles = { bold = true, italic = true, transparency = transparent },
    highlight_groups = transparent and {
      Normal = { bg = "none" },
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
      SignColumn = { bg = "none" },
    } or {},
  })
end

M["solarized-osaka"] = function(opts)
  local ok, solarized_osaka = pcall(require, "solarized-osaka")
  if not ok then return end

  local transparent = is_transparent()
  local style = opts.style or "night"

  solarized_osaka.setup({
    style = style,
    transparent = transparent,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl)
      hl.NormalFloat = { bg = "none" }
      hl.FloatBorder = { bg = "none" }
      hl.SignColumn = { bg = "none" }
    end,
  })
end

function M.cyberdream(opts)
  local ok, cyberdream = pcall(require, "cyberdream")
  if not ok then return end

  local variant = opts.variant or "default"

  cyberdream.setup({
    transparent = false,
    variant = variant,
    italic_comments = true,
    overrides = function(colors)
      local bg = colors.bg
      return {
        Normal = { bg = bg },
        NormalNC = { bg = bg },
        NormalFloat = { bg = bg },
        FloatBorder = { bg = bg },
        SignColumn = { bg = bg },
        StatusLine = { bg = bg },
        StatusLineNC = { bg = bg },
        TabLine = { bg = bg },
        TabLineFill = { bg = bg },
        WinBar = { bg = bg },
        WinBarNC = { bg = bg },
      }
    end,
  })
end

return M
