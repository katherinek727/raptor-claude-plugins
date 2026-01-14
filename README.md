# Raptortech Claude Code Plugins

A curated marketplace of Claude Code plugins for development workflows, project planning, and AI-assisted coding.

## Quick Start

Add this marketplace to Claude Code:

```bash
claude plugin marketplace add git@gitlab.com:raptortech1/aidevops/claude-plugins.git
```

Or from within Claude Code:

```
/plugin marketplace add git@gitlab.com:raptortech1/aidevops/claude-plugins.git
```

Then install individual plugins:

```
/plugin install planning
/plugin install issues
```

## Available Plugins

### Planning (`/aidlc-*`)

AI-DLC (AI-Driven Development Lifecycle) workflow for structured project planning with human-in-the-loop validation.

| Skill | Description |
|-------|-------------|
| `/aidlc-plan` | Create Level 1 Intent documentation in Confluence |
| `/aidlc-create-epic` | Create Jira Intent Epic from approved Confluence doc |
| `/aidlc-decompose` | Break down Intent into Units and User Stories |
| `/aidlc-design` | Domain design, logical architecture, and ADRs |

**Workflow:** Intent Doc → Epic → Units → Stories → Design → Implementation

**Requires:** Atlassian MCP (Confluence + Jira)

---

### Issues (`/create-jira-issue`, `/create-mr`, `/release-notes`)

Issue tracking and code review integrations.

| Skill | Description |
|-------|-------------|
| `/create-jira-issue` | Create a Jira issue from context or description |
| `/create-mr` | Create a GitLab merge request for current branch |
| `/release-notes` | Generate release notes from commits, MRs, and Jira tickets |

**Requires:** Atlassian MCP, GitLab MCP

---

### Pair Programming (`/ai-pair-programmer`)

Get second opinions from multiple AI providers on your code, plans, or architecture decisions.

```
"Review this implementation with Grok"
"Get ChatGPT's opinion on this approach"
"Ask all AIs to review my PR"
```

**Supported providers:** Grok (xAI), ChatGPT (OpenAI), Gemini (Google)

**Requires:** API keys for desired providers (`XAI_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`)

---

### Ruby (`/rubocop`)

Run Rubocop on files with intelligent auto-fixing.

```
/rubocop app/models/user.rb
```

Automatically fixes violations where possible, adds disable comments only when the rule would be incorrect or dangerous.

**Requires:** Ruby project with Rubocop configured

---

### Epistemic Reasoning

Enforces evidence-based reasoning by requiring `[FACT]`, `[INFERRED]`, and `[ASSUMED]` labels on all claims. Automatically enabled via session hooks.

- `[FACT]` — Directly verified from code, files, or user statements
- `[INFERRED]` — Logical conclusion with reasoning shown
- `[ASSUMED]` — Cannot verify; must ask clarifying question before proceeding

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- Git access to this repository

### Add the Marketplace

```bash
# Via CLI
claude plugin marketplace add git@gitlab.com:raptortech1/aidevops/claude-plugins.git

# Or within Claude Code
/plugin marketplace add git@gitlab.com:raptortech1/aidevops/claude-plugins.git
```

### Install Plugins

```bash
# List available plugins
/plugin list

# Install specific plugins
/plugin install planning
/plugin install issues
/plugin install pair-programming
/plugin install ruby
/plugin install epistemic-reasoning

# Reload after changes
/plugin
```

### Configure MCP Servers

Some plugins require MCP servers. Add to your Claude Code settings:

**Atlassian MCP** (for planning, issues):
```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-atlassian"]
    }
  }
}
```

**GitLab MCP** (for issues):
```json
{
  "mcpServers": {
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-gitlab"]
    }
  }
}
```

## Creating a New Plugin

### Plugin Structure

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── skills/                # Slash command definitions
│   └── <skill-name>/
│       └── SKILL.md
├── hooks/                 # Optional: lifecycle hooks
│   └── hooks.json
└── references/            # Optional: shared documentation
    └── shared.md
```

### Plugin Manifest (`plugin.json`)

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" },
  "license": "MIT",
  "keywords": ["relevant", "keywords"],
  "skills": "./skills/"
}
```

### Skill Definition (`SKILL.md`)

```yaml
---
name: my-skill
description: "Brief description for Claude to decide when to use this skill"
allowed-tools: [Read, Write, Bash]
argument-hint: "<file_path>"
---

# My Skill

Instructions for Claude when this skill is invoked...
```

**Important:**
- `name` must match the folder name (lowercase, hyphens only)
- `name` is required for slash command invocation
- Keep `description` under 1024 characters
- Every folder in `skills/` must contain a `SKILL.md`

### Register in Marketplace

Add your plugin to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "What it does",
      "version": "1.0.0",
      "author": { "name": "Your Name" }
    }
  ]
}
```

## Contributing

1. Create a feature branch: `git checkout -b add-my-plugin`
2. Add your plugin following the structure above
3. Test locally with `/plugin` to reload
4. Verify skills appear in autocomplete when typing `/`
5. Create a merge request

## Troubleshooting

**Skill not appearing as slash command:**
- Ensure `name:` field exists in SKILL.md frontmatter
- Verify name matches folder name exactly
- Run `/plugin` to reload

**"Unknown skill" error:**
- Check for non-skill folders directly inside `skills/` (move them outside)
- Verify SKILL.md frontmatter syntax is valid YAML

**MCP tools not available:**
- Confirm MCP server is configured in Claude Code settings
- Check MCP server is running (`/mcp` to see status)

## License

MIT
