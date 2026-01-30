#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# ==============================================================================
# Context7 MCP Server
# ==============================================================================
#
# Up-to-date documentation and code examples for programming libraries
#
# Website:    https://context7.com
# Remote MCP: https://mcp.context7.com/mcp
#
# Credentials (1Password: context7):
#   CONTEXT7_API_KEY - API key for Context7 service
#
# How to get credentials:
#   1. Go to https://context7.com
#   2. Sign up / Sign in
#   3. Navigate to API settings
#   4. Generate or copy your API key
#
# ==============================================================================

name=$(basename "$0" .sh)

run_with_secrets "$name" \
  npx mcp-remote \
    "https://mcp.context7.com/mcp" \
    --header "CONTEXT7_API_KEY:\${CONTEXT7_API_KEY}"
