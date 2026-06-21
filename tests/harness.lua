-- Test harness: minimal assert framework for headless nvim tests
local M = {}

local results = { passed = 0, failed = 0, errors = {} }

function M.eq(expected, actual, msg)
  if expected == actual then
    results.passed = results.passed + 1
  else
    results.failed = results.failed + 1
    local err = string.format("FAIL: %s\n  expected: %s\n  actual:   %s", msg or "?", vim.inspect(expected), vim.inspect(actual))
    table.insert(results.errors, err)
  end
end

function M.ok(condition, msg)
  if condition then
    results.passed = results.passed + 1
  else
    results.failed = results.failed + 1
    table.insert(results.errors, "FAIL: " .. (msg or "condition was falsy"))
  end
end

function M.report()
  for _, err in ipairs(results.errors) do
    print(err)
  end
  print(string.format("\nResults: %d passed, %d failed", results.passed, results.failed))
  return results.failed == 0
end

function M.reset()
  results = { passed = 0, failed = 0, errors = {} }
end

return M
