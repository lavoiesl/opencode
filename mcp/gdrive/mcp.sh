#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/_common.sh"

# ==============================================================================
# Google Workspace MCP Server (Gmail, Drive, Docs, Sheets, Calendar, etc.)
# ==============================================================================
#
# Complete Google Workspace integration: Gmail, Drive, Docs, Sheets, Calendar,
# Forms, Slides, Chat, Tasks, and Custom Search
#
# Repository: https://github.com/taylorwilsdon/google_workspace_mcp
# Docs:       https://workspacemcp.com/docs
# Quick Start: https://workspacemcp.com/quick-start
#
# Credentials (1Password: gdrive):
#   USER_GOOGLE_EMAIL         - Your Google email address
#   GOOGLE_OAUTH_CLIENT_ID    - OAuth 2.0 Client ID
#   GOOGLE_OAUTH_CLIENT_SECRET - OAuth 2.0 Client Secret
#
# How to get credentials:
#   1. Go to Google Cloud Console: https://console.cloud.google.com/
#   2. Create a new project (or select existing)
#   3. Enable APIs: Gmail, Drive, Docs, Sheets, Calendar, etc.
#   4. Go to "APIs & Services" -> "Credentials"
#   5. Create OAuth 2.0 Client ID (Desktop application)
#   6. Download JSON or copy Client ID and Client Secret
#
# Full OAuth setup guide:
#   https://developers.google.com/identity/protocols/oauth2
#
# ==============================================================================

env_run "$SCRIPT_DIR/op.env" \
  uvx workspace-mcp
