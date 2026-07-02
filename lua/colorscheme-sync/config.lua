local M = {}

local defaults = {
  default = "habamax",
  themes = {},
  aliases = {},
  transparent_groups = { "Normal", "SignColumn", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "WinBar", "WinBarNC" },
  transparency_default = false,
  state_file = vim.fn.stdpath("state") .. "/colorscheme.json",
  system_sync = true,
  system_poll_ms = 8000,
  sync_profiles = {},
  sync_tools = nil,
  load_plugin = nil,
  on_change = nil,
}

local current = vim.deepcopy(defaults)

function M.set(opts)
  current = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  if opts and opts.load_plugin then
    current.load_plugin = opts.load_plugin
  end
end

function M.get()
  return current
end

function M.set_default(key)
  current.default = key
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
