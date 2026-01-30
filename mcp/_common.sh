#!/bin/bash
# Common utilities for MCP scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_config.sh"

# Generate env file content with op:// references for an item
# Usage: get_env_refs <1password_item_name>
# Output: ENV_VAR=op://VAULT/ITEM/ENV_VAR (one per line)
get_env_refs() {
  local item_name="$1"
  op item get "$item_name" --vault "$VAULT" --account "$ACCOUNT" --format json | \
    jq -r --arg vault "$VAULT" --arg item "$item_name" \
      '.fields[] | select(.value and (.label | test("^[A-Z][A-Z0-9_]+$"))) | "\(.label)=op://\($vault)/\($item)/\(.label)"'
}

# Run a command with secrets from 1Password
# Usage: run_with_secrets <1password_item_name> <command> [args...]
#
# Generates op:// references that `op run` resolves at runtime
# (secrets never written to disk)
run_with_secrets() {
  local item_name="$1"
  shift

  exec op run --account "$ACCOUNT" --no-masking --env-file=<(get_env_refs "$item_name") -- "$@"
}
