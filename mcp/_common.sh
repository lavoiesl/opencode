#!/bin/bash
# Common utilities for MCP scripts

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$COMMON_DIR/_config.sh"

# Run a command with secrets from 1Password using op.env file
# Usage: env_run <env_file> <command> [args...]
#
# env_file: Path to the op.env file containing op:// secret references
# op.env contains op:// references that `op run` resolves at runtime
# (secrets never written to disk)
env_run() {
  local env_file="$1"
  shift
  
  if [[ ! -f "$env_file" ]]; then
    echo "Error: $env_file not found" >&2
    exit 1
  fi

  exec op run --account "$ACCOUNT" --env-file="$env_file" -- "$@"
}
