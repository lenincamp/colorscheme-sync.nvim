local M = {}

function M.is_enabled()
  if vim.g.transparent_background == nil then vim.g.transparent_background = true end
  return vim.g.transparent_background == true
end

function M.apply(groups)
  if not M.is_enabled() then return end
  for _, group in ipairs(groups or {}) do
    local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and type(highlight) == "table" then
      highlight.bg = nil
      highlight.ctermbg = nil
      vim.api.nvim_set_hl(0, group, highlight)
    end
  end
end

return M
