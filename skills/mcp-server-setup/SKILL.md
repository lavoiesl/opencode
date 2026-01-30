---
name: mcp-server-setup
description: Set up and configure MCP servers for OpenCode with 1Password secret management
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
---

## What I do

- Configure MCP servers in OpenCode's `opencode.json`
- Create wrapper shell scripts for MCP servers
- Manage secrets securely using 1Password CLI (`op`)
- Set up remote MCP servers using `mcp-remote` npm package

## Directory Structure

```
~/.config/opencode/
├── opencode.json           # Main config file
└── mcp/
    ├── _config.sh          # 1Password account config (gitignored)
    ├── _config.sh.example  # Template for _config.sh
    ├── _common.sh          # Shared utilities
    ├── <server>.sh         # One script per MCP server
    └── ...
```

## opencode.json MCP Configuration

Each MCP server is configured as a local command pointing to a wrapper script:

```json
{
  "mcp": {
    "<name>": {
      "type": "local",
      "command": ["/Users/<user>/.config/opencode/mcp/<name>.sh"],
      "enabled": true
    }
  }
}
```

## Common Utilities

### _config.sh

Configuration file for 1Password account settings (gitignored):

```bash
VAULT="MCP"
ACCOUNT="your-account.1password.com"
```

Copy `_config.sh.example` to `_config.sh` and update with your values.

### _common.sh

The `_common.sh` file provides utilities for secret management:

```bash
#!/bin/bash
# Common utilities for MCP scripts

source "$(dirname "$0")/_config.sh"

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

  exec op run --account "$ACCOUNT" --env-file=<(get_env_refs "$item_name") -- "$@"
}
```

Key features:
- `get_env_refs` generates `op://` secret references (not actual values)
- `op run` resolves the references at runtime, injecting secrets into env vars
- Process substitution `<(...)` avoids writing anything sensitive to disk
- The jq filter `^[A-Z][A-Z0-9_]+$` extracts only uppercase env var fields, filtering out 1Password metadata

## MCP Server Script Pattern

Scripts that require secrets follow this pattern:

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/_common.sh"

name=$(basename "$0" .sh)

# <Description> MCP
run_with_secrets "$name" \
  <command> [args...]
```

The `name` variable automatically matches the script filename (without `.sh`), which should match the 1Password item name.

Scripts without secrets are simpler:

```bash
#!/bin/bash
set -e

# <Description> MCP - no secrets required

exec <command> [args...]
```

## 1Password Setup

1. Create a vault named "MCP" in 1Password (or configure a different vault in `_config.sh`)
2. Create items with names matching the script filenames (e.g., "slack", "github", "gdrive")
3. Add fields with uppercase names matching expected env vars (e.g., `GITHUB_PERSONAL_ACCESS_TOKEN`)
4. Copy `mcp/_config.sh.example` to `mcp/_config.sh` and update with your 1Password account

## Remote MCP Servers (mcp-remote)

For MCP servers that expose an SSE endpoint, use `mcp-remote` to bridge:

```bash
npx mcp-remote \
  "https://example.com/mcp/sse" \
  --header "Authorization:Bearer \${TOKEN}"
```

Note: Use `\${VAR}` (escaped) for env var substitution in headers.

## Examples

### Local MCP (no secrets)
```bash
#!/bin/bash
set -e

# Playwright MCP - no secrets required

exec npx @playwright/mcp@latest \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

### Local MCP (with secrets)
```bash
#!/bin/bash
set -e
source "$(dirname "$0")/_common.sh"

name=$(basename "$0" .sh)

# Slack MCP
run_with_secrets "$name" \
  npx -y slack-mcp-server@latest \
    --transport stdio
```

### Remote MCP (OAuth, no secrets)
```bash
#!/bin/bash
set -e

# Atlassian MCP - uses OAuth, no secrets needed here

exec npx mcp-remote \
  "https://mcp.atlassian.com/v1/sse"
```

### Remote MCP (with API key)
```bash
#!/bin/bash
set -e
source "$(dirname "$0")/_common.sh"

name=$(basename "$0" .sh)

# GitHub MCP
run_with_secrets "$name" \
  npx mcp-remote \
    "https://api.githubcopilot.com/mcp/" \
    --header "Authorization:Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}"
```

## When to use me

Use this skill when:
- Setting up a new MCP server for OpenCode
- Migrating secrets from hardcoded values to 1Password
- Creating wrapper scripts for MCP servers
- Troubleshooting MCP server configuration
