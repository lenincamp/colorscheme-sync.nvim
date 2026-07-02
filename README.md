# colorscheme-sync.nvim

Neovim plugin for colorscheme management, persistence, system dark/light sync, and external tool synchronization.

Works with **any** Neovim colorscheme — no curated list required.

## Features

- **Universal**: Any `:colorscheme name` works automatically — extracts palette from highlight groups
- **Persistence**: Saves your last colorscheme choice to `stdpath("state")/colorscheme.json`
- **System sync**: Automatically detects macOS dark/light mode changes and switches between theme variants
- **External tools**: Syncs colors to tmux, alacritty, delta, iTerm2, lazygit, starship, eza, btop, zellij, lazydocker, and custom tools
- **Transparency**: Manages background transparency across highlight groups
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
      sync_tools = { tools.tmux, tools.delta, tools.alacritty, tools.iterm2, tools.shell_env },
      system_sync = true,
    })
  end,
}
```

### Minimal (zero config)

```lua
{ "lcampoverde/colorscheme-sync.nvim", lazy = false, config = true }
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

csync.apply("tokyonight")          -- Apply any colorscheme
csync.toggle_background()          -- Toggle dark/light
csync.set_background_mode("light") -- Set specific mode
csync.set_transparency(true)       -- Enable transparency
csync.is_transparent()             -- Query transparency state
csync.current_theme()              -- Get current resolved theme
csync.select()                     -- Open picker
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default` | `string` | `"habamax"` | Fallback colorscheme key |
| `transparent_groups` | `string[]` | (common groups) | HL groups to clear bg |
| `transparency_default` | `boolean` | `false` | Default transparency state |
| `state_file` | `string` | `stdpath("state")/colorscheme.json` | Persistence path |
| `system_sync` | `boolean` | `false` | Auto-detect system dark/light |
| `system_poll_ms` | `number` | `8000` | Poll interval for system mode |
| `sync_profiles` | `table` | `{}` | Per-theme overrides for tool colors |
| `sync_tools` | `function[]` | all built-in | Sync tool callbacks |
| `on_change` | `function` | `nil` | Post-change hook |

### sync_profiles (optional overrides)

The plugin extracts colors automatically from highlight groups. Use `sync_profiles` only when you need to override specific colors for a theme:

```lua
sync_profiles = {
  ["catppuccin-mocha"] = {
    terminal = { background = "#1e1e2e", foreground = "#cdd6f4" },
    accent = "#89b4fa",
  },
},
```

### sync_tools

By default, all built-in tools are synced. To sync only specific tools:

```lua
local tools = require("colorscheme-sync.tools")
sync_tools = { tools.tmux, tools.delta, tools.iterm2 }
```

## How It Works

1. **Palette extraction**: Reads `Normal`, `Keyword`, `Comment`, `Visual`, `Diagnostic*` highlight groups to derive `bg`, `fg`, `accent`, `border`, `selection`, `warn`, `error`
2. **Tmux sync**: Sets `status-style`, `status-left`, `status-right` (with zoom indicator `[Z]`), `window-status-current-format` (accent background for active window), pane borders, and message style — all from the palette
3. **Persistence**: Saves theme key and transparency state to disk, restores on next startup
4. **Initial sync**: Colors are applied to external tools immediately on Neovim startup

## Custom Sync Tools

```lua
local function my_custom_sync(ctx)
  -- ctx.theme   = resolved theme table (key, scheme, opts)
  -- ctx.profile = sync_profiles[theme.key] or auto-derived palette
  -- ctx.config  = full plugin config
  local profile = ctx.profile
  local bg = profile.terminal.background
  local fg = profile.terminal.foreground
  -- Apply to your tool
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
