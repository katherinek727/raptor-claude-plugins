# Support Tools Plugin

Support tools for CPOMS/StaffSafe: diagnoses Sentry issues, fetches script documentation from Confluence, and recommends scripts with cascading diagnostic workflows.

## Usage

```
/diagnose <sentry-issue-url>
```

## Prerequisites

This plugin requires the following MCP servers to be configured:

| MCP Server | Purpose |
|------------|---------|
| `sentry` | Fetches Sentry issue details, stacktrace, and tags |
| `atlassian` | Fetches Confluence script documentation and gotchas |

## Installation

### 1. Clone the plugins repo

```bash
git clone git@gitlab.com:raptortech1/aidevops/claude-plugins.git ~/.claude/plugins
```

Or copy just this plugin:

```bash
cp -r plugins/support-tools ~/.claude/plugins/
```

### 2. Install Ruby dependencies

```bash
cd ~/.claude/plugins/support-tools/mcp-servers/gitlab-scripts
bundle install
```

### 3. Set GitLab token

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
export GITLAB_TOKEN="glpat-your-token-here"
```

Get a token from GitLab → Settings → Access Tokens with `read_repository` scope.

## What's Included

```
support-tools/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── .mcp.json                    # Bundled MCP server config
├── mcp-servers/
│   └── gitlab-scripts/
│       ├── server.rb            # GitLab scripts MCP server
│       ├── Gemfile
│       └── Gemfile.lock
├── skills/
│   └── diagnose/
│       └── SKILL.md             # The diagnose skill
└── README.md
```

## Bundled MCP Server

This plugin includes the `gitlab-scripts` MCP server which:

- Lists scripts from CPOMS (`raptortech1/raptor/cpoms/cpoms`)
- Lists scripts from StaffSafe (`raptortech1/raptor/cpoms/cpoms-scr`)
- Fetches full script source code and extracts options

## What the skill does

1. **Fetches Sentry issue** - Gets error details, stacktrace, and tenant (subdomain tag)
2. **Fetches script documentation** - Pulls Confluence page with gotchas and tips
3. **Lists available scripts** - Gets current scripts from CPOMS or StaffSafe
4. **Recommends workflow** - Suggests logging scripts first, then destructive scripts

## Key Points

- Scripts are **workarounds**, not fixes - they unblock customers while root cause is investigated
- Scripts are executed from **Manage**, not the terminal
- Always run **dry-run first** for destructive scripts
- Never search for customers by name in Manage - use LA/DfE or exact URL
