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
├── opencode.jsonc          # Main config file
└── mcp/
    ├── _config.sh          # 1Password account config (gitignored)
    ├── _config.sh.example  # Template for _config.sh
    ├── _common.sh          # Shared utilities
    ├── <server>/           # One folder per MCP server
    │   ├── mcp.sh         # Server launch script
    │   └── op.env         # 1Password secret references (if needed)
    └── ...
```

## opencode.jsonc MCP Configuration

Each MCP server is configured as a local command pointing to a wrapper script:

```jsonc
{
  "mcp": {
    "<name>": {
      "type": "local",
      "command": ["/Users/<user>/.config/opencode/mcp/<name>/mcp.sh"],
      "enabled": true
    }
  }
}
```

## Common Utilities

### _config.sh

Configuration file for 1Password account settings (gitignored):

```bash
ACCOUNT="your-account.1password.com"
```

Copy `_config.sh.example` to `_config.sh` and update with your values.

**Note**: The `VAULT` configuration was removed. Vault names are now part of the full `op://` references in each server's `op.env` file.

### _common.sh

The `_common.sh` file provides utilities for secret management:

```bash
#!/bin/bash
# Common utilities for MCP scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_config.sh"

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
```

Key features:
- `env_run` accepts an explicit path to the `op.env` file
- The `op.env` file contains full `op://vault/item/field` references (not just field names)
- `op run` resolves the references at runtime, injecting secrets into env vars
- Secrets never written to disk - only exist in process memory

## MCP Server Script Pattern

Each MCP server lives in its own folder: `mcp/<server>/`

### With Secrets (requires op.env)

```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common.sh"

# <Description> MCP
env_run "$SCRIPT_DIR/op.env" \
  <command> [args...]
```

The `op.env` file in the same folder contains full references:
```bash
# mcp/<server>/op.env
SOME_TOKEN=op://MyVault/item-name/SOME_TOKEN
API_KEY=op://MyVault/item-name/API_KEY
```

### Without Secrets

```bash
#!/bin/bash
set -e

# <Description> MCP - no secrets required

exec <command> [args...]
```

No `op.env` file needed.

## 1Password Setup

1. Create items in 1Password with fields matching expected env vars (e.g., `GITHUB_PERSONAL_ACCESS_TOKEN`)
2. Copy `mcp/_config.sh.example` to `mcp/_config.sh` and update with your 1Password account
3. For each MCP server needing secrets:
   - Create folder: `mcp/<server>/`
   - Create `mcp/<server>/mcp.sh` (the server launch script)
   - Create `mcp/<server>/op.env` with full `op://vault/item/field` references

Example `op.env`:
```bash
SLACK_BOT_TOKEN=op://MyVault/slack/SLACK_BOT_TOKEN
SLACK_APP_TOKEN=op://MyVault/slack/SLACK_APP_TOKEN
```

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

Folder structure:
```
mcp/playwright/
└── mcp.sh
```

### Local MCP (with secrets)
```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common.sh"

# Slack MCP
env_run "$SCRIPT_DIR/op.env" \
  npx -y slack-mcp-server@latest \
    --transport stdio
```

Folder structure:
```
mcp/slack/
├── mcp.sh
└── op.env    # Contains: SLACK_BOT_TOKEN=op://MyVault/slack/SLACK_BOT_TOKEN
```

### Remote MCP (OAuth, no secrets)
```bash
#!/bin/bash
set -e

# Atlassian MCP - uses OAuth, no secrets needed here

exec npx mcp-remote \
  "https://mcp.atlassian.com/v1/sse"
```

Folder structure:
```
mcp/atlassian/
└── mcp.sh
```

### Remote MCP (with API key)
```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common.sh"

# GitHub MCP
env_run "$SCRIPT_DIR/op.env" \
  npx mcp-remote \
    "https://api.githubcopilot.com/mcp/" \
    --header "Authorization:Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}"
```

Folder structure:
```
mcp/github/
├── mcp.sh
└── op.env    # Contains: GITHUB_PERSONAL_ACCESS_TOKEN=op://MyVault/github/GITHUB_PERSONAL_ACCESS_TOKEN
```

## When to use me

Use this skill when:
- Setting up a new MCP server for OpenCode
- Migrating secrets from hardcoded values to 1Password
- Creating wrapper scripts for MCP servers
- Troubleshooting MCP server configuration
