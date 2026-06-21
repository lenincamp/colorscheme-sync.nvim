-- colorscheme-sync/presets/init.lua
-- Combines catalog, integrations, and lazy.nvim dependency specs.
local M = {}

local catalog = require("colorscheme-sync.presets.catalog")
local integrations = require("colorscheme-sync.presets.integrations")

--- Returns the built-in catalog defaults ready for config.set().
---@return table
function M.defaults()
  return {
    themes = catalog.themes,
    aliases = catalog.aliases,
    sync_profiles = catalog.sync_profiles,
    transparent_groups = catalog.transparent_groups,
  }
end

--- Built-in load_plugin callback.
--- Sets globals → packadd the theme plugin → runs integration setup.
---@param theme table The theme entry from the catalog (has .plugin, .opts, etc.)
function M.load_plugin(theme)
  local theme_opts = theme.opts or {}
  local plugin_name = theme.plugin
  if not plugin_name then return end

  -- Map logical plugin name → pack directory name
  local pack_names = {
    ["catppuccin"] = "catppuccin",
    ["gruvbox"] = "gruvbox.nvim",
    ["tokyonight"] = "tokyonight.nvim",
    ["kanagawa"] = "kanagawa.nvim",
    ["rose-pine"] = "rose-pine",
    ["solarized-osaka"] = "solarized-osaka.nvim",
    ["cyberdream"] = "cyberdream.nvim",
  }

  -- Set well-known globals consumed by colorscheme plugins
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

  -- Load the plugin on demand
  local pack_name = pack_names[plugin_name] or plugin_name
  if vim.fn.exists(":Lazy") == 2 then
    require("lazy").load({ plugins = { pack_name } })
  else
    pcall(vim.cmd.packadd, pack_name)
  end

  -- Run built-in integration setup
  local setup_fn = integrations[plugin_name]
  if setup_fn then
    setup_fn(theme_opts)
  end
end

--- Returns a lazy.nvim compatible dependencies list for all built-in themes.
---@return table[] Array of lazy.nvim plugin specs
function M.lazy_dependencies()
  return {
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "craftzdog/solarized-osaka.nvim", lazy = true },
    { "scottmckendry/cyberdream.nvim", lazy = true },
  }
end

--- Returns a full lazy.nvim plugin spec for colorscheme-sync with all deps.
--- Usage in lazy.nvim:
---   require("colorscheme-sync.presets").lazy_spec({ ... setup opts ... })
---@param setup_opts? table Options passed to colorscheme-sync.setup()
---@return table lazy.nvim plugin spec
function M.lazy_spec(setup_opts)
  return {
    "colorscheme-sync.nvim",
    dir = (function()
      local info = debug.getinfo(1, "S")
      if info and info.source then
        local plugin_root = info.source:gsub("^@", ""):match("(.+)/lua/")
        if plugin_root then return plugin_root end
      end
      return nil
    end)(),
    priority = 1000,
    lazy = false,
    dependencies = M.lazy_dependencies(),
    config = function()
      require("colorscheme-sync").setup(setup_opts or {})
    end,
  }
end

return M
