#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

# ==============================================================================
# Slack MCP Server
# ==============================================================================
#
# Slack workspace integration with channels, DMs, threads, and message search
#
# Repository: https://github.com/korotovsky/slack-mcp-server
# Docs:       https://github.com/korotovsky/slack-mcp-server#readme
# Auth Setup: https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md
#
# Credentials (1Password: slack):
#   SLACK_MCP_XOXC_TOKEN - Browser token (xoxc-...)
#   SLACK_MCP_XOXD_TOKEN - Browser cookie 'd' (xoxd-...)
#
# How to get tokens (Stealth Mode - no permissions required):
#   1. Open Slack in your browser and sign in
#   2. Open Developer Tools (F12) -> Application -> Cookies
#   3. Find cookie 'd' -> copy value (this is SLACK_MCP_XOXD_TOKEN)
#   4. Go to Console tab, run: window.prompt("", TS.boot_data.api_token)
#   5. Copy the value (this is SLACK_MCP_XOXC_TOKEN)
#
# Alternative: OAuth mode with xoxp- or xoxb- tokens (requires Slack App setup)
#
# ==============================================================================

name=$(basename "$0" .sh)

run_with_secrets "$name" \
  npx -y slack-mcp-server@latest \
    --transport stdio
