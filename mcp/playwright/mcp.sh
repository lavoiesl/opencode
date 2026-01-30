#!/bin/bash
set -e

# ==============================================================================
# Playwright MCP Server
# ==============================================================================
#
# Browser automation using Playwright's accessibility tree (no vision models needed)
#
# Repository: https://github.com/microsoft/playwright-mcp
# Docs:       https://github.com/microsoft/playwright-mcp#readme
# NPM:        https://www.npmjs.com/package/@playwright/mcp
#
# Credentials: None required
#
# ==============================================================================

exec npx @playwright/mcp@latest \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
