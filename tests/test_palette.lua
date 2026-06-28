-- tests/test_palette.lua
-- Verify palette.build returns all expected semantic keys

local function setup_rtp()
  local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
  vim.opt.rtp:prepend(plugin_dir)
end
setup_rtp()

local palette = require("colorscheme-sync.palette")

local pass, fail = 0, 0
local function assert_eq(a, b, msg)
  if a == b then
    pass = pass + 1
  else
    fail = fail + 1
    print(string.format("FAIL: %s — expected %s, got %s", msg, tostring(b), tostring(a)))
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

-- Test hex_to_rgb
do
  local r, g, b = palette.hex_to_rgb("#ff8800")
  assert_eq(r, 255, "hex_to_rgb red")
  assert_eq(g, 136, "hex_to_rgb green")
  assert_eq(b, 0, "hex_to_rgb blue")
end

-- Test hex_to_rgb without hash
do
  local r, g, b = palette.hex_to_rgb("00ff00")
  assert_eq(r, 0, "hex_to_rgb no-hash red")
  assert_eq(g, 255, "hex_to_rgb no-hash green")
  assert_eq(b, 0, "hex_to_rgb no-hash blue")
end

-- Test blend_hex
do
  local blended = palette.blend_hex("#000000", "#ffffff", 0.5)
  assert_true(type(blended) == "string", "blend_hex returns string")
  assert_true(#blended == 7, "blend_hex returns 7 chars")
  -- midpoint of black and white should be approximately #808080 (or #7f7f7f)
  local r, g, b = palette.hex_to_rgb(blended)
  assert_true(r >= 127 and r <= 128, "blend_hex midpoint r=" .. r)
  assert_true(g >= 127 and g <= 128, "blend_hex midpoint g=" .. g)
  assert_true(b >= 127 and b <= 128, "blend_hex midpoint b=" .. b)
end

-- Test build returns all expected keys
do
  -- Set up minimal highlights so palette.build can derive colors
  vim.cmd("colorscheme habamax")
  local colors = palette.build("dark")
  assert_true(type(colors) == "table", "build returns table")

  local expected_keys = {
    "fg", "bg", "border", "accent", "selection",
    "ok", "ok_bg", "ok_emph_bg",
    "warn",
    "error", "error_bg", "error_emph_bg",
  }
  for _, key in ipairs(expected_keys) do
    assert_true(colors[key] ~= nil, "build has key: " .. key)
    assert_true(type(colors[key]) == "string", "build key is string: " .. key)
    assert_true(colors[key]:match("^#%x%x%x%x%x%x$") ~= nil, "build key is hex color: " .. key .. " = " .. tostring(colors[key]))
  end
end

-- Test build("light") also works
do
  vim.o.background = "light"
  local colors = palette.build("light")
  assert_true(type(colors) == "table", "build light returns table")
  assert_true(colors.fg ~= nil, "build light has fg")
  assert_true(colors.bg ~= nil, "build light has bg")
end

-- Test build recovers the captured theme bg when Normal.bg is stripped (transparency)
do
  local transparency = require("colorscheme-sync.transparency")
  vim.o.background = "dark"
  vim.g.transparent_background = true
  vim.g._csync_theme_bg = nil
  vim.api.nvim_set_hl(0, "Normal", { fg = "#cdd6f4", bg = "#282828" })
  vim.api.nvim_set_hl(0, "Pmenu", {})
  vim.api.nvim_set_hl(0, "NormalFloat", {})
  transparency.apply({ "Normal" })
  assert_eq(vim.g._csync_theme_bg, "#282828", "transparency.apply captures theme bg before strip")
  assert_eq(palette.build("dark").bg, "#282828", "build recovers captured theme bg when Normal stripped")
end

print(string.format("\ntest_palette: %d passed, %d failed", pass, fail))
if fail > 0 then os.exit(1) end
