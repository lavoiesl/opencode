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
- 1Password account with access to a vault (default: "MCP")

### Setup

1. **Configure 1Password account**:
   ```bash
   cp mcp/_config.sh.example mcp/_config.sh
   ```
   
   Edit `mcp/_config.sh` with your 1Password settings:
   ```bash
   VAULT="MCP"  # or your preferred vault name
   ACCOUNT="your-account.1password.com"
   ```

2. **Create 1Password items for MCP servers requiring secrets**:
   
   - Create items in your 1Password vault with names matching the script filenames (e.g., `slack` for `mcp/slack.sh`)
   - Add fields with UPPERCASE names matching expected environment variables (e.g., `API_KEY`, `BOT_TOKEN`)
   - The `_common.sh` utilities automatically extract fields matching the pattern `^[A-Z][A-Z0-9_]+$`

3. **How it works**:
   - Each `mcp/*.sh` script is a wrapper that launches an MCP server
   - Scripts needing secrets source `_common.sh` and use `run_with_secrets`
   - This generates `op://` references (e.g., `op://MCP/slack/SLACK_BOT_TOKEN`)
   - `op run` resolves references at runtime, injecting secrets as environment variables
   - **Secrets never written to disk** - only exist in process memory

### MCP Script Structure

Each MCP server has a corresponding shell script in `mcp/`. Scripts requiring secrets follow this pattern:

```bash
#!/bin/bash
set -e
source "$(dirname "$0")/_common.sh"

name=$(basename "$0" .sh)  # Matches 1Password item name

run_with_secrets "$name" \
  npx some-mcp-server@latest
```

Scripts without secrets are simpler:

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
