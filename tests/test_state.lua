-- tests/test_state.lua: TDD for state persistence
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. vim.fn.getcwd() .. "/tests/?.lua;" .. package.path

local t = require("harness")
local state = require("colorscheme-sync.state")

local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")

-- TEST: load returns nil for missing file
t.eq(nil, state.load(tmpdir .. "/nonexistent.json"), "load nonexistent returns nil")

-- TEST: load returns nil for empty file
local empty_file = tmpdir .. "/empty.json"
vim.fn.writefile({}, empty_file)
t.eq(nil, state.load(empty_file), "load empty file returns nil")

-- TEST: load returns nil for invalid json
local bad_json = tmpdir .. "/bad.json"
vim.fn.writefile({ "not json" }, bad_json)
t.eq(nil, state.load(bad_json), "load bad json returns nil")

-- TEST: load returns valid key
local valid_file = tmpdir .. "/valid.json"
vim.fn.writefile({ '{"key":"catppuccin-mocha","transparent":true}' }, valid_file)
local result = state.load(valid_file)
t.eq("catppuccin-mocha", result.key, "load returns key")
t.eq(true, result.transparent, "load returns transparent")

-- TEST: load returns any key (no theme_map filter)
local unknown_file = tmpdir .. "/unknown.json"
vim.fn.writefile({ '{"key":"nonexistent-theme"}' }, unknown_file)
local unknown_result = state.load(unknown_file)
t.eq("nonexistent-theme", unknown_result.key, "load returns any key")

-- TEST: load reads transparency field (legacy compat)
local legacy_file = tmpdir .. "/legacy.json"
vim.fn.writefile({ '{"key":"catppuccin-mocha","transparency":false}' }, legacy_file)
local legacy_result = state.load(legacy_file)
t.eq(false, legacy_result.transparent, "load reads legacy transparency field")

-- TEST: persist writes valid json
local persist_file = tmpdir .. "/persisted.json"
state.persist(persist_file, "gruvbox-hard", true)
t.ok(vim.fn.filereadable(persist_file) == 1, "persist creates file")
local content = table.concat(vim.fn.readfile(persist_file), "\n")
local decoded = vim.json.decode(content)
t.eq("gruvbox-hard", decoded.key, "persist writes key")
t.eq(true, decoded.transparent, "persist writes transparent")
t.ok(decoded.updated_at ~= nil, "persist writes updated_at")

-- TEST: persist skips empty key/transparent
local skip_file = tmpdir .. "/skip.json"
state.persist(skip_file, nil, nil)
t.ok(vim.fn.filereadable(skip_file) ~= 1, "persist skips when both nil")

-- Cleanup
vim.fn.delete(tmpdir, "rf")

local success = t.report()
if not success then vim.cmd("cq!") end
