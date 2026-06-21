# colorscheme-sync.nvim

Neovim plugin for colorscheme management, persistence, system dark/light sync, and external tool synchronization.

## Features

- **Persistence**: Saves your last colorscheme choice to `stdpath("state")/colorscheme.json`
- **System sync**: Automatically detects macOS dark/light mode changes and switches between theme variants
- **External tools**: Syncs theme to tmux, alacritty, delta, iTerm2, lazygit, and custom tools
- **Transparency**: Manages background transparency across highlight groups
- **Family variants**: Automatically switches between dark/light variants within the same theme family
- **Extensible**: Add custom sync tools via simple callback functions

## Installation

### lazy.nvim

```lua
{
  "lcampoverde/colorscheme-sync.nvim",
  priority = 1000,
  config = function()
    local tools = require("colorscheme-sync.tools")
    require("colorscheme-sync").setup({
      default = "catppuccin-mocha",
      themes = {
        { key = "catppuccin-mocha", label = "Catppuccin Mocha", scheme = "catppuccin", plugin = "catppuccin", opts = { flavour = "mocha", background = "dark" } },
        { key = "catppuccin-latte", label = "Catppuccin Latte", scheme = "catppuccin", plugin = "catppuccin", opts = { flavour = "latte", background = "light" } },
        { key = "gruvbox-hard", label = "Gruvbox Hard", scheme = "gruvbox", plugin = "gruvbox", opts = { contrast = "hard", background = "dark" } },
        { key = "gruvbox-light", label = "Gruvbox Light", scheme = "gruvbox", plugin = "gruvbox", opts = { contrast = "soft", background = "light" } },
      },
      aliases = {
        catppuccin = "catppuccin-mocha",
        gruvbox = "gruvbox-hard",
      },
      sync_profiles = {
        ["catppuccin-mocha"] = { tmux = "mocha", delta = "catppuccin-mocha", iterm2 = "Catppuccin Mocha", terminal = { background = "#1e1e2e", foreground = "#cdd6f4" } },
        ["catppuccin-latte"] = { tmux = "latte", delta = "catppuccin-latte", iterm2 = "Catppuccin Latte", terminal = { background = "#eff1f5", foreground = "#4c4f69" } },
        ["gruvbox-hard"] = { tmux = "gruvbox", delta = "gruvbox-dark", terminal = { background = "#1d2021", foreground = "#ebdbb2" } },
        ["gruvbox-light"] = { tmux = "gruvbox-light", delta = "gruvbox-light", terminal = { background = "#fbf1c7", foreground = "#3c3836" } },
      },
      sync_tools = { tools.tmux, tools.delta, tools.alacritty, tools.shell_env, tools.iterm2 },
      system_sync = true,
      system_poll_ms = 8000,
      on_change = function(item)
        -- reload lualine, statusline, etc.
      end,
    })
  end,
}
```

### Manual / packadd

```lua
vim.cmd.packadd("colorscheme-sync.nvim")
require("colorscheme-sync").setup({ ... })
```

## Commands

| Command | Description |
|---------|-------------|
| `:ColorScheme [name]` | Switch colorscheme (picker if no arg) |
| `:ColorSchemeSync` | Force sync to external tools |
| `:ColorSchemeToggleBg` | Toggle dark/light background |
| `:ColorSchemeTransparency [on\|off]` | Toggle/set transparency |

## API

```lua
local csync = require("colorscheme-sync")

csync.apply("catppuccin-mocha")       -- Apply a theme by key
csync.toggle_background()             -- Toggle dark/light
csync.set_background_mode("light")    -- Set specific mode
csync.set_transparency(true)          -- Enable transparency
csync.is_transparent()                -- Query transparency state
csync.current_theme()                 -- Get current resolved theme
csync.theme_profile("catppuccin-mocha") -- Get sync profile
csync.lualine_theme()                 -- Get lualine theme name
csync.select()                        -- Open picker
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default` | `string` | `"habamax"` | Fallback colorscheme key |
| `themes` | `table[]` | `{}` | Theme definitions |
| `aliases` | `table` | `{}` | Alias → key mappings |
| `transparent_groups` | `string[]` | (common groups) | HL groups to clear bg |
| `transparency_default` | `boolean` | `true` | Default transparency state |
| `state_file` | `string` | `stdpath("state")/colorscheme.json` | Persistence path |
| `system_sync` | `boolean` | `true` | Auto-detect system dark/light |
| `system_poll_ms` | `number` | `8000` | Poll interval for system mode |
| `sync_profiles` | `table` | `{}` | Per-theme sync tool config |
| `sync_tools` | `function[]` | `{}` | Sync tool callbacks |
| `load_plugin` | `function` | `nil` | Plugin loader callback |
| `on_change` | `function` | `nil` | Post-change hook |

## Theme Definition

```lua
{
  key = "catppuccin-mocha",      -- Unique identifier
  label = "Catppuccin Mocha",    -- Display name
  scheme = "catppuccin",         -- vim colorscheme name
  plugin = "catppuccin",         -- Plugin name (for family grouping)
  opts = {                       -- Theme-specific options
    flavour = "mocha",
    background = "dark",         -- "dark" or "light"
  },
  fixed_background = false,      -- Block background toggle
}
```

## Custom Sync Tools

```lua
local function my_custom_sync(ctx)
  -- ctx.theme = resolved theme table
  -- ctx.profile = sync_profiles[theme.key] or {}
  -- ctx.config = full plugin config
  local profile = ctx.profile
  -- Do your sync logic here
end

require("colorscheme-sync").setup({
  sync_tools = { my_custom_sync },
})
```

## Running Tests

```bash
bash run_tests.sh
```

## License

MIT
