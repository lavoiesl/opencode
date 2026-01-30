# OpenCode Configuration

Personal OpenCode configuration repository with custom plugins, MCP servers, and agent configurations.

## Overview

This repository contains my personal OpenCode setup, including:

- **Custom agent configurations** via oh-my-opencode
- **MCP server integrations**
- **OpenCode plugins** for enhanced functionality
- **Custom commands and skills** for specialized workflows

## Prerequisites

- [OpenCode](https://opencode.ai) installed
- [pnpm](https://pnpm.io) for package management
- [GitHub CLI](https://cli.github.com) (`gh`) for GitHub operations
- Access to various service APIs (see MCP Configuration section)

## Installation

1. Clone this repository to your OpenCode configuration directory:
   ```bash
   git clone https://github.com/lavoiesl/opencode.git ~/.config/opencode
   cd ~/.config/opencode
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

3. Configure MCP servers (see [MCP Configuration](#mcp-configuration))

## MCP Configuration

MCP (Model Context Protocol) servers provide external integrations. Secrets are managed securely using **1Password CLI**.

### Prerequisites

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/) (`op`) installed and configured
- 1Password account (vault name will be specified in each server's `op.env`)

### Setup

1. **Configure 1Password account**:
   ```bash
   cp mcp/_config.sh.example mcp/_config.sh
   ```
   
   Edit `mcp/_config.sh` with your 1Password settings:
   ```bash
   ACCOUNT="your-account.1password.com"
   ```

2. **Create MCP server folders and configuration**:
   
   For each MCP server requiring secrets:
   - Create folder: `mcp/<server>/`
   - Create `mcp/<server>/mcp.sh` (server launch script)
   - Create `mcp/<server>/op.env` with full `op://vault/item/field` references
   
   Example `mcp/slack/op.env`:
   ```bash
   SLACK_BOT_TOKEN=op://MyVault/slack/SLACK_BOT_TOKEN
   SLACK_APP_TOKEN=op://MyVault/slack/SLACK_APP_TOKEN
   ```

3. **How it works**:
   - Each MCP server has its own folder: `mcp/<server>/`
   - The `mcp.sh` script launches the server
   - If secrets needed, `op.env` contains full `op://` references
   - Scripts source `_common.sh` and use `env_run`
   - `op run` resolves references at runtime, injecting secrets as environment variables
   - **Secrets never written to disk** - only exist in process memory

### MCP Script Structure

Each MCP server has its own folder with these files:

**With secrets:**
```
mcp/<server>/
├── mcp.sh      # Server launch script
└── op.env      # Full op:// secret references
```

**Without secrets:**
```
mcp/<server>/
└── mcp.sh      # Server launch script only
```

Example `mcp.sh` requiring secrets:

```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_common.sh"

env_run "$SCRIPT_DIR/op.env" \
  npx some-mcp-server@latest
```

Example `mcp.sh` without secrets:

```bash
#!/bin/bash
set -e

exec npx @playwright/mcp@latest
```

## Custom Commands

Located in `command/`:

- **`supermemory-init.md`**: Initialize comprehensive codebase knowledge
- **`plannotator-review.md`**: Interactive code review workflow

## Custom Skills

Located in `skills/`:

- **`mcp-server-setup/`**: Skill for configuring MCP servers with 1Password secret management

## Usage

### Basic Workflow

1. Start OpenCode with your preferred interface
2. The configuration will automatically load
3. Use specialized agents via delegation:
   ```
   # Visual/Frontend work
   Use category: "visual-engineering" with skill: "frontend-ui-ux"
   
   # Complex logic
   Use category: "ultrabrain"
   
   # Quick fixes
   Use category: "quick"
   ```

### Using MCP Servers

Once configured, MCP servers are available automatically through OpenCode's integrations.

## Contributing

This is a personal configuration repository. Feel free to fork and adapt to your needs.

## License

MIT (or specify your preferred license)

## Links

- [OpenCode Documentation](https://opencode.ai/docs)
- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)
- [MCP Protocol](https://modelcontextprotocol.io)
