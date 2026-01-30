#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/_common.sh"

# ==============================================================================
# GitHub MCP Server (via GitHub Copilot)
# ==============================================================================
#
# GitHub integration through the Copilot MCP endpoint
#
# Remote MCP: https://api.githubcopilot.com/mcp/
# Docs:       https://docs.github.com/en/copilot
#
# Credentials (1Password: github):
#   GITHUB_PERSONAL_ACCESS_TOKEN - Personal Access Token (classic or fine-grained)
#
# How to get credentials:
#   1. Go to https://github.com/settings/tokens
#   2. Generate new token (classic) or fine-grained token
#   3. Select required scopes:
#      - repo (full control of private repositories)
#      - read:org (read org membership)
#      - read:user (read user profile data)
#      - Or use fine-grained token with specific permissions
#   4. Copy the generated token (shown only once!)
#
# Token documentation:
#   https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
#
# ==============================================================================

env_run "$SCRIPT_DIR/op.env" \
  npx mcp-remote \
    "https://api.githubcopilot.com/mcp/" \
    --header "Authorization:Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}"
