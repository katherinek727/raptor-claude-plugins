# Support Tools Plugin

Support tools for CPOMS/StaffSafe: diagnoses Sentry issues, fetches script documentation from Confluence, and recommends scripts with cascading diagnostic workflows.

## Usage

```
/diagnose <sentry-issue-url>
```

## Prerequisites

This plugin requires the following tools to be configured:

| Dependency | Purpose | Installation |
|------------|---------|-------------|
| `sentry` MCP server | Fetches Sentry issue details, stacktrace, and tags | Configure in Claude Code MCP settings |
| `atlassian` MCP server | Fetches Confluence script documentation and gotchas | Configure in Claude Code MCP settings |
| `glab` CLI | Fetches scripts from CPOMS/StaffSafe GitLab repositories | See below |

### Installing glab (GitLab CLI)

**macOS:**
```bash
brew install glab
```

**Windows:**
```powershell
winget install --id GitLab.Glab
```
Or via Scoop: `scoop install glab` / Chocolatey: `choco install glab`

**Linux:**
See https://gitlab.com/gitlab-org/cli#installation

### Authenticating glab

```bash
glab auth login
```

Select `gitlab.com`, choose your preferred authentication method (browser or token), and follow the prompts. Verify access:

```bash
glab api "projects/raptortech1%2Fraptor%2Fcpoms%2Fcpoms/repository/tree?path=app/services/scripts&per_page=1"
```

## What's Included

```
support-tools/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/
│   └── diagnose/
│       └── SKILL.md             # The diagnose skill
└── README.md
```

## What the skill does

1. **Fetches Sentry issue** - Gets error details, stacktrace, and tenant (subdomain tag)
2. **Fetches script documentation** - Pulls Confluence page with gotchas and tips
3. **Lists available scripts** - Gets current scripts from CPOMS or StaffSafe via `glab`
4. **Recommends workflow** - Suggests logging scripts first, then destructive scripts

## Key Points

- Scripts are **workarounds**, not fixes - they unblock customers while root cause is investigated
- Scripts are executed from **Manage**, not the terminal
- Always run **dry-run first** for destructive scripts
- Never search for customers by name in Manage - use LA/DfE or exact URL
