-- colorscheme-sync/adapters/tmux.lua
local M = {}

function M.sync(ctx)
  local profile = ctx.profile
  local tmux_theme = profile.tmux
  if type(tmux_theme) ~= "string" or tmux_theme == "" then return end
  if vim.fn.executable("tmux") ~= 1 then return end

  local track = (type(ctx.theme) == "table" and ctx.theme.key) or tmux_theme
  if vim.g._csync_tmux_last == track then return end

  vim.fn.system({ "tmux", "set-option", "-gq", "@tmux_theme", tmux_theme })
  if vim.v.shell_error ~= 0 then return end

  local tmux_plugin = vim.fn.expand("~/.tmux/plugins/tmux/scripts/plugin.sh")
  if vim.fn.filereadable(tmux_plugin) == 1 then
    vim.fn.system({ "bash", tmux_plugin })
    vim.fn.system({ "tmux", "refresh-client", "-S" })
  end

  vim.g._csync_tmux_last = track
end

function M.sync_async(ctx)
  local profile = ctx.profile
  local tmux_theme = profile.tmux
  if type(tmux_theme) ~= "string" or tmux_theme == "" then return end
  if vim.fn.executable("tmux") ~= 1 then return end

  local track = (type(ctx.theme) == "table" and ctx.theme.key) or tmux_theme
  if vim.g._csync_tmux_last == track then return end

  local tmux_plugin = vim.fn.expand("~/.tmux/plugins/tmux/scripts/plugin.sh")
  local has_plugin = vim.fn.filereadable(tmux_plugin) == 1

  vim.system({ "tmux", "set-option", "-gq", "@tmux_theme", tmux_theme }, { text = true }, function(result)
    if result.code ~= 0 then return end
    if has_plugin then
      vim.system({ "bash", tmux_plugin }, { text = true }, function()
        vim.system({ "tmux", "refresh-client", "-S" })
      end)
    end
    vim.g._csync_tmux_last = track
  end)
end

return M
