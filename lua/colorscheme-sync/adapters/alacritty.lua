-- colorscheme-sync/adapters/alacritty.lua
local common = require("colorscheme-sync.adapters.common")
local palette = require("colorscheme-sync.palette")

local M = {}

function M.replace_primary_values(content, colors)
  local has_final_newline = content:sub(-1) == "\n"
  local lines = vim.split(content, "\n", { plain = true })
  local in_primary = false
  local background_updated = false
  local foreground_updated = false

  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  for index, line in ipairs(lines) do
    local section = line:match("^%s*%[([^%]]+)%]%s*$")
    if section then
      in_primary = section == "colors.primary"
    elseif in_primary then
      local updated_line = line
      if not background_updated then
        local prefix, suffix = updated_line:match('^(%s*background%s*=%s*")[^"]*(".*)$')
        if prefix then
          updated_line = prefix .. colors.bg .. suffix
          background_updated = true
        end
      end
      if not foreground_updated then
        local prefix, suffix = updated_line:match('^(%s*foreground%s*=%s*")[^"]*(".*)$')
        if prefix then
          updated_line = prefix .. colors.fg .. suffix
          foreground_updated = true
        end
      end
      lines[index] = updated_line
    end
  end

  if not background_updated or not foreground_updated then
    return content, false
  end

  local updated = table.concat(lines, "\n")
  if has_final_newline then updated = updated .. "\n" end
  return updated, true
end

function M.terminal_primary_colors(ctx)
  local profile = ctx.profile
  local terminal = type(profile.terminal) == "table" and profile.terminal or {}
  local mode = M._theme_mode(ctx)
  local colors = palette.build(mode)
  return {
    bg = terminal.background or colors.bg,
    fg = terminal.foreground or colors.fg,
  }
end

function M._theme_mode(ctx)
  local theme = ctx.theme
  if type(theme) == "table" and theme.opts and theme.opts.background then
    return theme.opts.background
  end
  return vim.o.background or "dark"
end

function M.sync(ctx)
  local colors = M.terminal_primary_colors(ctx)
  local path = ctx.config and ctx.config.alacritty_config_path
    or vim.fn.expand("~/.config/alacritty/alacritty.toml")
  local content = common.read_text_file(path)
  if type(content) ~= "string" then return end

  local updated, changed = M.replace_primary_values(content, colors)
  if changed then
    pcall(common.write_text_file_if_changed, path, updated)
  end
end

return M
