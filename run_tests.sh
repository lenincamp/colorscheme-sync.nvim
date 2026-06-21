#!/bin/bash
# Run all tests in headless Neovim
set -e

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

run_test() {
  local test_file="$1"
  local name=$(basename "$test_file" .lua)
  printf "Running %-25s ... " "$name"
  if nvim --headless -u NONE \
    --cmd "set rtp+=$PLUGIN_DIR" \
    -c "cd $PLUGIN_DIR" \
    -c "luafile $test_file" \
    -c "qa" 2>&1; then
    echo "✓"
  else
    echo "✗"
    exit 1
  fi
}

echo "colorscheme-sync.nvim test suite"
echo "================================"

for test in "$PLUGIN_DIR"/tests/test_*.lua; do
  run_test "$test"
done

echo ""
echo "All tests passed!"
