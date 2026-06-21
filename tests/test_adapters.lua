-- tests/test_adapters.lua
-- Unit tests for adapter text manipulation functions (no I/O, no side effects)

local function setup_rtp()
  local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
  vim.opt.rtp:prepend(plugin_dir)
end
setup_rtp()

local pass, fail = 0, 0
local function assert_eq(a, b, msg)
  if a == b then
    pass = pass + 1
  else
    fail = fail + 1
    print(string.format("FAIL: %s\n  expected: %s\n  got:      %s", msg, tostring(b), tostring(a)))
  end
end
local function assert_true(v, msg)
  if v then
    pass = pass + 1
  else
    fail = fail + 1
    print("FAIL: " .. msg)
  end
end

-- ===== adapters/common =====
local common = require("colorscheme-sync.adapters.common")

do
  assert_eq(common.sanitize_key("My Theme/2"), "my-theme-2", "sanitize_key basic")
  assert_eq(common.sanitize_key("  hello  WORLD  "), "hello-world", "sanitize_key spaces")
  assert_eq(common.sanitize_key("a__b"), "a__b", "sanitize_key underscores preserved")
end

-- ===== adapters/alacritty =====
local alacritty = require("colorscheme-sync.adapters.alacritty")

do
  local toml = table.concat({
    "[font]",
    "size = 14",
    "",
    "[colors.primary]",
    'background = "#1e1e2e"',
    'foreground = "#cdd6f4"',
    "",
    "[colors.cursor]",
    'text = "#000000"',
  }, "\n") .. "\n"

  local updated, changed = alacritty.replace_primary_values(toml, { bg = "#ffffff", fg = "#000000" })
  assert_true(changed, "alacritty replace changed")
  assert_true(updated:find('"#ffffff"') ~= nil, "alacritty bg updated")
  assert_true(updated:find('"#000000"') ~= nil, "alacritty fg updated")
  -- Ensure cursor section not modified
  assert_true(updated:find('[colors.cursor]', 1, true) ~= nil, "alacritty cursor preserved")
end

do
  -- No [colors.primary] section → no change
  local toml = "[font]\nsize = 14\n"
  local updated, changed = alacritty.replace_primary_values(toml, { bg = "#fff", fg = "#000" })
  assert_true(not changed, "alacritty no primary section → no change")
  assert_eq(updated, toml, "alacritty content unchanged")
end

-- ===== adapters/btop =====
local btop = require("colorscheme-sync.adapters.btop")

do
  assert_eq(btop.theme_for_mode("light"), "catppuccin_latte", "btop light theme")
  assert_eq(btop.theme_for_mode("dark"), "catppuccin_mocha", "btop dark theme")
end

do
  local content = 'color_theme = "default"\nshow_cpu = true\n'
  local updated = btop.replace_color_theme(content, "catppuccin_latte")
  assert_true(updated:find('color_theme = "catppuccin_latte"') ~= nil, "btop replace works")
  assert_true(updated:find("show_cpu = true") ~= nil, "btop preserves other lines")
end

-- ===== adapters/zellij =====
local zellij = require("colorscheme-sync.adapters.zellij")

do
  assert_eq(zellij.theme_for_mode("light"), "catppuccin-latte", "zellij light theme")
  assert_eq(zellij.theme_for_mode("dark"), "catppuccin-macchiato", "zellij dark theme")
end

do
  local content = 'pane_frames true\ntheme "catppuccin-mocha"\ndefault_layout "compact"\n'
  local updated = zellij.replace_theme(content, "catppuccin-latte")
  assert_true(updated:find('theme "catppuccin-latte"', 1, true) ~= nil, "zellij replace works")
  assert_true(updated:find("pane_frames true") ~= nil, "zellij preserves other lines")
end

-- ===== adapters/delta =====
local delta = require("colorscheme-sync.adapters.delta")

do
  local features = delta.features_for("catppuccin-mocha")
  assert_true(features:find("catppuccin%-mocha") ~= nil, "delta features contains palette")
  assert_true(features:find("side%-by%-side") ~= nil, "delta features contains sbs")
  assert_true(features:find("line%-numbers") ~= nil, "delta features contains line-numbers")
end

-- ===== adapters/starship =====
local starship = require("colorscheme-sync.adapters.starship")

do
  local content = 'palette = "default"\n'
  local updated, changed = starship.replace_first(content, 'palette%s*=%s*"[^"]+"', 'palette = "mocha"')
  assert_true(changed, "starship replace_first changed")
  assert_true(updated:find('palette = "mocha"') ~= nil, "starship replace_first value")
end

do
  local content = '[directory]\nstyle = "bold blue"\ntruncation_length = 3\n'
  local updated, changed = starship.replace_section_value(content, "directory", "style", "bold #ff0000")
  assert_true(changed, "starship replace_section_value changed")
  assert_true(updated:find("bold #ff0000") ~= nil, "starship section value updated")
end

do
  local content = '[format]\nformat = "$all"\n'
  local block = { "[palettes.test_theme]", 'text = "#cdd6f4"' }
  local updated = starship.upsert_palette_block(content, "test_theme", block)
  assert_true(updated:find("%[palettes.test_theme%]") ~= nil, "starship upsert inserts block")
  assert_true(updated:find('#cdd6f4') ~= nil, "starship upsert inserts values")
end

do
  -- Update existing palette block
  local content = '[palettes.test_theme]\ntext = "#old"\n\n[other]\nfoo = "bar"\n'
  local block = { "[palettes.test_theme]", 'text = "#new"' }
  local updated = starship.upsert_palette_block(content, "test_theme", block)
  assert_true(updated:find('#new') ~= nil, "starship upsert replaces existing")
  assert_true(updated:find('#old') == nil, "starship upsert removes old values")
  assert_true(updated:find("%[other%]") ~= nil, "starship upsert keeps other sections")
end

-- ===== adapters/iterm2 =====
local iterm2 = require("colorscheme-sync.adapters.iterm2")

do
  local val = iterm2.color_value("#ff0000")
  assert_true(val ~= nil, "iterm2 color_value not nil")
  -- #ff0000 → red=255*257=65535, green=0, blue=0
  assert_eq(val, "{65535, 0, 0, 65535}", "iterm2 color_value red")
end

do
  local val = iterm2.color_value("#00ff00")
  assert_eq(val, "{0, 65535, 0, 65535}", "iterm2 color_value green")
end

do
  local val = iterm2.color_value(nil)
  assert_eq(val, nil, "iterm2 color_value nil input")
end

do
  local val = iterm2.color_value("invalid")
  assert_eq(val, nil, "iterm2 color_value invalid input")
end

-- ===== adapters/eza =====
local eza = require("colorscheme-sync.adapters.eza")

do
  local colors = {
    fg = "#cdd6f4", bg = "#1e1e2e", border = "#585b70", accent = "#89b4fa",
    selection = "#313244", ok = "#a6e3a1", warn = "#f9e2af", error = "#f38ba8",
    ok_bg = "#1e3a2e", ok_emph_bg = "#2a4a3e", error_bg = "#3a1e2e", error_emph_bg = "#4a2a3e",
  }
  local lines = eza.color_lines(colors)
  assert_true(#lines > 20, "eza color_lines has many lines: " .. #lines)
  assert_true(lines[1]:find("Auto%-generated") ~= nil, "eza header comment")
  local joined = table.concat(lines, "\n")
  assert_true(joined:find("#89b4fa") ~= nil, "eza uses accent color")
  assert_true(joined:find("#a6e3a1") ~= nil, "eza uses ok color")
end

-- ===== adapters/shell =====
local shell = require("colorscheme-sync.adapters.shell")

do
  local opts_dark = shell.fzf_opts_for_mode("dark")
  assert_true(opts_dark:find("--layout=reverse") ~= nil, "shell fzf dark has layout")
  assert_true(opts_dark:find("1e1e2e") ~= nil, "shell fzf dark has dark bg")

  local opts_light = shell.fzf_opts_for_mode("light")
  assert_true(opts_light:find("eff1f5") ~= nil, "shell fzf light has light bg")
end

-- ===== adapters/lazydocker =====
local lazydocker = require("colorscheme-sync.adapters.lazydocker")

do
  local src_dark, target_dark = lazydocker.config_paths("dark")
  assert_true(src_dark:find("config%-dark%.yml") ~= nil, "lazydocker dark src")
  assert_true(target_dark:find("config%.yml") ~= nil, "lazydocker target")

  local src_light, target_light = lazydocker.config_paths("light")
  assert_true(src_light:find("config%-light%.yml") ~= nil, "lazydocker light src")
  assert_eq(target_dark, target_light, "lazydocker same target for both modes")
end

print(string.format("\ntest_adapters: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(1) end
