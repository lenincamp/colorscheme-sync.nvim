-- Built-in catalog: themes, aliases, sync profiles, transparent groups.
-- Users can override or extend via setup({ themes = ..., sync_profiles = ... }).
local M = {}

M.themes = {
  { key = "default", label = "Default (Vim)", scheme = "default", opts = { background = "dark" }, fixed_background = true },
  { key = "unokai", label = "Unokai (Vim)", scheme = "unokai", opts = { background = "dark" }, fixed_background = true },
  { key = "habamax", label = "Habamax (Vim)", scheme = "habamax", opts = { background = "dark" }, fixed_background = true },
  { key = "catppuccin-mocha", label = "Catppuccin Mocha", scheme = "catppuccin", plugin = "catppuccin", opts = { flavour = "mocha", background = "dark" } },
  { key = "catppuccin-latte", label = "Catppuccin Latte", scheme = "catppuccin", plugin = "catppuccin", opts = { flavour = "latte", background = "light" } },
  { key = "gruvbox-hard", label = "Gruvbox Hard", scheme = "gruvbox", plugin = "gruvbox", opts = { contrast = "hard", background = "dark" } },
  { key = "gruvbox-light", label = "Gruvbox Light", scheme = "gruvbox", plugin = "gruvbox", opts = { contrast = "soft", background = "light" } },
  { key = "tokyonight-night", label = "TokyoNight Night", scheme = "tokyonight", plugin = "tokyonight", opts = { style = "night", background = "dark" } },
  { key = "tokyonight-day", label = "TokyoNight Day", scheme = "tokyonight", plugin = "tokyonight", opts = { style = "day", background = "light" } },
  { key = "solarized-osaka-night", label = "Solarized Osaka Night", scheme = "solarized-osaka", plugin = "solarized-osaka", opts = { style = "night", background = "dark" } },
  { key = "solarized-osaka-day", label = "Solarized Osaka Day", scheme = "solarized-osaka", plugin = "solarized-osaka", opts = { style = "day", background = "light" } },
  { key = "kanagawa-dragon", label = "Kanagawa Dragon", scheme = "kanagawa-dragon", plugin = "kanagawa", opts = { theme = "dragon", background = "dark" } },
  { key = "kanagawa-lotus", label = "Kanagawa Lotus", scheme = "kanagawa-lotus", plugin = "kanagawa", opts = { theme = "lotus", background = "light" } },
  { key = "rose-pine-moon", label = "Rose Pine Moon", scheme = "rose-pine", plugin = "rose-pine", opts = { variant = "moon", background = "dark" } },
  { key = "rose-pine-dawn", label = "Rose Pine Dawn", scheme = "rose-pine", plugin = "rose-pine", opts = { variant = "dawn", background = "light" } },
  { key = "cyberdream", label = "Cyberdream", scheme = "cyberdream", plugin = "cyberdream", opts = { variant = "default", background = "dark" } },
  { key = "cyberdream-light", label = "Cyberdream Light", scheme = "cyberdream", plugin = "cyberdream", opts = { variant = "light", background = "light" } },
}

M.aliases = {
  deafult = "default",
  unokai = "unokai",
  habamax = "habamax",
  catppuccin = "catppuccin-mocha",
  gruvbox = "gruvbox-hard",
  tokyonight = "tokyonight-night",
  ["solarized-osaka"] = "solarized-osaka-night",
  kanagawa = "kanagawa-dragon",
  ["rose-pine"] = "rose-pine-moon",
  cyberdream = "cyberdream",
}

-- Editor chrome stays transparent. Floating windows and popup menus are
-- intentionally excluded: colorscheme-sync.popups owns their surface and honors
-- the transparency toggle itself (transparent -> bg NONE, opaque -> elevated),
-- so it must not be double-stripped here.
M.transparent_groups = {
  "Normal", "NormalNC",
  "SignColumn", "FoldColumn", "LineNr", "CursorLineNr",
  "TabLine", "TabLineFill", "WinBar", "WinBarNC",
  "WinSeparator",
}

M.sync_profiles = {
  ["default"] = { tmux = "nord", delta = "ansi", iterm2 = "Dark High Contrast", lualine = { provider = "auto" } },
  ["unokai"] = { tmux = "dracula", delta = "ansi", iterm2 = "Dark High Contrast", lualine = { provider = "auto" } },
  ["habamax"] = { tmux = "gruvbox", delta = "ansi", iterm2 = "Dark High Contrast", lualine = { provider = "auto" } },
  ["catppuccin-mocha"] = { tmux = "mocha", delta = "catppuccin-mocha", iterm2 = "Catppuccin Mocha", terminal = { background = "#1e1e2e", foreground = "#cdd6f4" }, lualine = { provider = "catppuccin", flavour = "mocha" } },
  ["catppuccin-latte"] = { tmux = "latte", delta = "catppuccin-latte", iterm2 = "Catppuccin Latte", terminal = { background = "#eff1f5", foreground = "#4c4f69" }, lualine = { provider = "catppuccin", flavour = "latte" } },
  ["gruvbox-hard"] = { tmux = "gruvbox", delta = "gruvbox-dark", iterm2 = "Gruvbox Dark", terminal = { background = "#1d2021", foreground = "#ebdbb2" }, lualine = { provider = "builtin", name = "gruvbox" } },
  ["gruvbox-light"] = { tmux = "gruvbox", delta = "gruvbox-light", iterm2 = "Gruvbox Light", terminal = { background = "#fbf1c7", foreground = "#3c3836" }, lualine = { provider = "builtin", name = "gruvbox" } },
  ["tokyonight-night"] = { tmux = "tokyo-night", delta = "tokyonight-night", iterm2 = "TokyoNight", terminal = { background = "#1a1b26", foreground = "#c0caf5" }, lualine = { provider = "builtin", name = "tokyonight" } },
  ["tokyonight-day"] = { tmux = "tokyo-night", delta = "tokyonight-day", iterm2 = "TokyoNight Day", terminal = { background = "#e1e2e7", foreground = "#3760bf" }, lualine = { provider = "builtin", name = "tokyonight" } },
  ["solarized-osaka-night"] = { tmux = "solarized-osaka", delta = "Solarized (dark)", iterm2 = "Solarized Dark", terminal = { background = "#00141a", foreground = "#93a1a1" }, lualine = { provider = "auto" } },
  ["solarized-osaka-day"] = { tmux = "solarized-osaka-day", delta = "Solarized (light)", iterm2 = "Solarized Light", terminal = { background = "#fdf6e3", foreground = "#586e75" }, lualine = { provider = "auto" } },
  ["kanagawa-dragon"] = { tmux = "nord", delta = "kanagawa", iterm2 = "Kanagawa", terminal = { background = "#181616", foreground = "#c5c9c5" }, lualine = { provider = "auto" } },
  ["kanagawa-lotus"] = { tmux = "nord", delta = "kanagawa-lotus", iterm2 = "Kanagawa Lotus", terminal = { background = "#f2ecbc", foreground = "#545464" }, lualine = { provider = "auto" } },
  ["rose-pine-moon"] = { tmux = "dracula", delta = "rose-pine-moon", iterm2 = "Rose Pine Moon", terminal = { background = "#232136", foreground = "#e0def4" }, lualine = { provider = "builtin", name = "rose-pine" } },
  ["rose-pine-dawn"] = { tmux = "dracula", delta = "rose-pine-dawn", iterm2 = "Rose Pine Dawn", terminal = { background = "#faf4ed", foreground = "#575279" }, lualine = { provider = "builtin", name = "rose-pine" } },
  ["cyberdream"] = { tmux = "tokyo-night", delta = "tokyonight-night", iterm2 = "Cyberdream", terminal = { background = "#16181a", foreground = "#ffffff" }, lualine = { provider = "auto" } },
  ["cyberdream-light"] = { tmux = "tokyo-night", delta = "tokyonight-day", iterm2 = "Cyberdream Light", terminal = { background = "#ffffff", foreground = "#16181a" }, lualine = { provider = "auto" } },
}

return M
