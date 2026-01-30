#!/bin/bash
set -e

# ==============================================================================
# Atlassian MCP Server (Jira, Confluence)
# ==============================================================================
#
# Official Atlassian MCP server for Jira and Confluence integration
#
# Remote MCP: https://mcp.atlassian.com/v1/sse
# Docs:       https://developer.atlassian.com/cloud/mcp/
#
# Credentials: OAuth (browser-based, no secrets needed)
#
# How to authenticate:
#   1. First connection will open browser for Atlassian OAuth
#   2. Sign in with your Atlassian account
#   3. Grant permissions to the MCP server
#   4. Token is cached locally for future use
#
# ==============================================================================

exec npx mcp-remote \
  "https://mcp.atlassian.com/v1/sse"
