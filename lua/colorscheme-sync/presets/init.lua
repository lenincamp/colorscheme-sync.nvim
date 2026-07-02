local M = {}

local integrations = require("colorscheme-sync.presets.integrations")

--- Built-in load_plugin callback.
--- Sets globals → packadd the theme plugin → runs integration setup.
---@param theme table The theme entry (has .plugin, .opts, etc.)
function M.load_plugin(theme)
  local theme_opts = theme.opts or {}
  local plugin_name = theme.plugin
  if not plugin_name then return end

  local pack_names = {
    ["catppuccin"] = "catppuccin",
    ["gruvbox"] = "gruvbox.nvim",
    ["tokyonight"] = "tokyonight.nvim",
    ["kanagawa"] = "kanagawa.nvim",
    ["rose-pine"] = "rose-pine",
    ["solarized-osaka"] = "solarized-osaka.nvim",
    ["cyberdream"] = "cyberdream.nvim",
  }

  if theme_opts.flavour then vim.g.catppuccin_flavour = theme_opts.flavour end
  if theme_opts.style then
    local varname = "pure_" .. plugin_name:gsub("-", "_") .. "_style"
    vim.g[varname] = theme_opts.style
  end
  if theme_opts.theme then
    local varname = "pure_" .. plugin_name:gsub("-", "_") .. "_theme"
    vim.g[varname] = theme_opts.theme
  end
  if theme_opts.variant then
    local varname = "pure_" .. plugin_name:gsub("-", "_") .. "_variant"
    vim.g[varname] = theme_opts.variant
  end
  if theme_opts.contrast then
    local varname = "pure_" .. plugin_name:gsub("-", "_") .. "_contrast"
    vim.g[varname] = theme_opts.contrast
  end

  local pack_name = pack_names[plugin_name] or plugin_name
  if vim.fn.exists(":Lazy") == 2 then
    require("lazy").load({ plugins = { pack_name } })
  else
    pcall(vim.cmd.packadd, pack_name)
  end

  local setup_fn = integrations[plugin_name]
  if setup_fn then
    setup_fn(theme_opts)
  end
end

return M
