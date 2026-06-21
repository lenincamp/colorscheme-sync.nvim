-- Sync tool registry — re-exports adapter sync functions
-- Usage: sync_tools = { tools.tmux, tools.delta, tools.shell, ... }
local M = {}

function M.tmux(ctx)
  return require("colorscheme-sync.adapters.tmux").sync(ctx)
end

function M.delta(ctx)
  return require("colorscheme-sync.adapters.delta").sync(ctx)
end

function M.alacritty(ctx)
  return require("colorscheme-sync.adapters.alacritty").sync(ctx)
end

function M.lazygit(ctx)
  return require("colorscheme-sync.adapters.lazygit").sync(ctx)
end

function M.iterm2(ctx)
  return require("colorscheme-sync.adapters.iterm2").sync(ctx)
end

function M.shell(ctx)
  return require("colorscheme-sync.adapters.shell").sync(ctx)
end

function M.starship(ctx)
  return require("colorscheme-sync.adapters.starship").sync(ctx)
end

function M.eza(ctx)
  return require("colorscheme-sync.adapters.eza").sync(ctx)
end

function M.btop(ctx)
  return require("colorscheme-sync.adapters.btop").sync(ctx)
end

function M.zellij(ctx)
  return require("colorscheme-sync.adapters.zellij").sync(ctx)
end

function M.lazydocker(ctx)
  return require("colorscheme-sync.adapters.lazydocker").sync(ctx)
end

function M.shell_env(ctx)
  local theme = ctx.theme
  local key = type(theme) == "table" and theme.key or theme
  local mode = "dark"
  if type(theme) == "table" and theme.opts and theme.opts.background then
    mode = theme.opts.background
  end
  vim.env.COLORSCHEME = key
  vim.env.COLORSCHEME_BG = mode
end

return M
