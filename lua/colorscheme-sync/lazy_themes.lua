-- Standalone theme specs for lazy.nvim (no internal requires).
-- dofile() this from your plugins spec to declare themes as lazy top-level specs.
-- They load on demand when colorscheme-sync calls require("lazy").load().
return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "scottmckendry/cyberdream.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "craftzdog/solarized-osaka.nvim", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
}
