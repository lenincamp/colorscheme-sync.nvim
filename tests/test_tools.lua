-- tests/test_tools.lua: TDD for built-in sync tool adapters
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local tools = require("colorscheme-sync.tools")

-- TEST: shell_env sets environment variables
tools.shell_env({
  theme = { key = "catppuccin-mocha", opts = { background = "dark" } },
  profile = {},
})
t.eq("catppuccin-mocha", vim.env.COLORSCHEME, "shell_env sets COLORSCHEME")
t.eq("dark", vim.env.COLORSCHEME_BG, "shell_env sets COLORSCHEME_BG")

tools.shell_env({
  theme = { key = "catppuccin-latte", opts = { background = "light" } },
  profile = {},
})
t.eq("catppuccin-latte", vim.env.COLORSCHEME, "shell_env updates COLORSCHEME")
t.eq("light", vim.env.COLORSCHEME_BG, "shell_env updates COLORSCHEME_BG")

-- TEST: delta writes theme file
local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")
local delta_path = tmpdir .. "/delta-theme"

-- Mock expand to use temp path
local orig_expand = vim.fn.expand
vim.fn.expand = function(path)
  if path == "~/.config/git/delta-theme" then return delta_path end
  return orig_expand(path)
end

tools.delta({
  theme = { key = "catppuccin-mocha" },
  profile = { delta = "catppuccin-mocha" },
})
t.ok(vim.fn.filereadable(delta_path) == 1, "delta creates theme file")
local delta_content = vim.trim(table.concat(vim.fn.readfile(delta_path), "\n"))
t.eq("catppuccin-mocha", delta_content, "delta writes correct theme")

-- TEST: delta skips when same theme
tools.delta({
  theme = { key = "catppuccin-mocha" },
  profile = { delta = "catppuccin-mocha" },
})
-- Should not error, just skip

-- TEST: delta skips when no profile.delta
tools.delta({
  theme = { key = "gruvbox" },
  profile = {},
})
-- Should not error or create file

-- Restore
vim.fn.expand = orig_expand
vim.fn.delete(tmpdir, "rf")

-- TEST: tmux skips when no profile.tmux
-- (can't test actual tmux without it installed, just verify no crash)
vim.g._csync_tmux_last = nil
tools.tmux({
  theme = { key = "test" },
  profile = {},
})
-- Should not error

-- TEST: iterm2 skips when not in iTerm
local orig_term = vim.env.TERM_PROGRAM
vim.env.TERM_PROGRAM = "not-iterm"
vim.g.pure_iterm2_sync_always = nil
tools.iterm2({
  theme = { key = "test" },
  profile = { iterm2 = "Catppuccin Mocha" },
})
-- Should not error or output
vim.env.TERM_PROGRAM = orig_term

local success = t.report()
if not success then vim.cmd("cq!") end
