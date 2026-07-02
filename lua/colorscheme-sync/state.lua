local M = {}

function M.load(path)
  if vim.fn.filereadable(path) ~= 1 then return nil end

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read or type(lines) ~= "table" or #lines == 0 then return nil end

  local ok_decode, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_decode or type(data) ~= "table" then return nil end

  local result = {}

  local key = data.key
  if type(key) == "string" and key ~= "" then
    result.key = key
  end

  local transparent = data.transparent
  if type(transparent) ~= "boolean" then
    transparent = data.transparency
  end
  if type(transparent) == "boolean" then
    result.transparent = transparent
  end

  if next(result) == nil then return nil end
  return result
end

function M.persist(path, key, transparent)
  local payload = {
    updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  }

  if type(key) == "string" and key ~= "" then
    payload.key = key
  end

  if type(transparent) == "boolean" then
    payload.transparent = transparent
  end

  if payload.key == nil and payload.transparent == nil then
    return
  end

  local ok_encode, encoded = pcall(vim.json.encode, payload)
  if not ok_encode or type(encoded) ~= "string" then return end

  local dir = vim.fn.fnamemodify(path, ":h")
  vim.fn.mkdir(dir, "p")
  pcall(vim.fn.writefile, vim.split(encoded, "\n"), path)
end

return M
