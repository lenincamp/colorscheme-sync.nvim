local M = {}

function M.select(items, on_select)
  local selectable = {}
  for _, item in ipairs(items) do
    if item.source ~= "header" then
      selectable[#selectable + 1] = item
    end
  end

  local ok_picker, picker = pcall(require, "picker")
  if ok_picker and type(picker.select_items) == "function" then
    picker.select_items(selectable, {
      prompt = "Colorscheme",
      input_mode = true,
      format_item = function(item)
        return "★ " .. item.label
      end,
    }, function(item)
      if item then
        on_select(item)
      end
    end)
    return
  end

  vim.ui.select(items, {
    prompt = "Colorscheme",
    format_item = function(item)
      if item.source == "header" then return item.label end
      return "★ " .. item.label
    end,
  }, function(item)
    if item and item.source ~= "header" then
      on_select(item)
    end
  end)
end

return M
