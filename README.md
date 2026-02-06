<!-- AI_SUGGESTION_MARKER_20260204100611 -->
# Raptortech Claude Code Plugins

A collection of plugins that extend [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview)'s capabilities for development workflows, project planning, and AI-assisted coding. Claude Code is Anthropic's agentic coding tool that helps developers write, understand, and improve code through AI assistance. These plugins add specialized capabilities for structured planning, issue tracking, code quality, and more.

## Why Use These Plugins?

- **Structured Planning** — Create detailed project plans with AI-DLC methodology, from Intent documents through to Jira tickets
- **Issue Management** — Streamline Jira issue creation, GitLab MRs, and release notes generation
- **Code Quality** — Run Rubocop with intelligent auto-fixing and violation handling
- **Backlog Health** — Find and improve poorly written Jira issues using quality rubrics
- **Second Opinions** — Get feedback from multiple AI providers (Grok, ChatGPT, Gemini) on your code
- **Evidence-Based Reasoning** — Enforce `[FACT]`/`[INFERRED]`/`[ASSUMED]` labeling for rigorous analysis
- **Behavioral Diff** - Detect logic inversions and behavioral changes in code diffs
- **.NET Migration** — Automate trunk-based development migration for .NET API services with Kustomize and GitLab CI/CD
- **Security Scanning** — vulnerability scanning, secrets detection, SAST analysis checking against OWASP Top 10 and CWE Top 25
- **GitLab CI Standards** — Pipeline best practices for job ordering, `needs` vs `dependencies`, and stage-based gates

## Usage Examples

**Start a new project initiative:**
```
/aidlc-intent
Create an intent for adding user authentication with OAuth2 support
```

**Improve Jira backlog quality:**
```
/jira-improve:jira-improve PROJ
```
Analyzes issues in the PROJ project, scores them against a quality rubric, and helps rewrite poorly written tickets.

**Get a second opinion on your code:**
```
Review this authentication implementation with Grok and Gemini
```
The pair-programming skill auto-triggers and queries multiple AI providers.

**Create a GitLab MR for your current branch:**
```
/issues:create-mr
```

**Run Rubocop with intelligent fixes:**
```
/ruby:rubocop app/models/user.rb
```

**Check for behavioral logic inversions:**
```
/behavioral-diff:review
```

**Migrate a .NET service to trunk-based development:**
```
/dotnet:trunk-discover
/dotnet:trunk-plan
/dotnet:trunk-migrate
```

**Get GitLab CI pipeline standards:**
```
/gitlab-ci:standards-view
/gitlab-ci:standards-load job-ordering
/gitlab-ci:standards-audit
```
Or just ask about pipeline editing—the skill auto-triggers on phrases like "add a new job" or "update the pipeline".

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
/plugin install aidlc
/plugin install issues
```

## Available Plugins

### AIDLC (`/aidlc-*`)

AI-DLC (AI-Driven Development Lifecycle) workflow for structured project planning with human-in-the-loop validation.

| Command | Triggers | Description |
|---------|----------|-------------|
| `/aidlc-intent` | `create intent`, `intent document`, `new initiative`, `draft intent`, `aidlc plan` | Create Intent documentation in Confluence |
| `/aidlc-elaborate` | `decompose intent`, `break down intent`, `create units`, `create tasks`, `mob elaboration` | Break Intent into Units and Tasks via Mob Elaboration, propose Bolt groupings |
| `/aidlc-design` | `domain design`, `logical design`, `create ADR`, `architecture decision`, `aidlc design` | Domain/Logical Design and Architecture Decision Records |
| `/aidlc-verify` | `verify docs`, `check readiness`, `transfer to jira`, `confidence check` | Verify docs, refine Bolts, transfer to Jira (Unit→Sub-epic, Bolt→Story, Task→Sub-task) |
| `/aidlc-bolt` | `bolt`, `implement bolt`, `start bolt`, `bolt implementation`, `new bolt` | Guide implementation of a Bolt with TDD emphasis |
| `/aidlc-help` | `aidlc help`, `what is aidlc`, `explain aidlc`, `planning help` | Explain AI-DLC methodology and available skills |

**Workflow:** Intent → Units → Tasks → Design → Verify → Jira (Sub-epic → Story → Sub-task) → Bolt Implementation

**Requires:** Atlassian MCP (Confluence + Jira)

---

### Issues (`/issues:*`)

Issue tracking and code review integrations.

| Command | Description |
|---------|-------------|
| `/issues:create-jira-issue` | Create a Jira issue from context or description |
| `/issues:create-mr` | Create a GitLab merge request for current branch |
| `/issues:release-notes` | Generate release notes from commits, MRs, and Jira tickets |

**Requires:** Atlassian MCP, GitLab MCP

---

### Pair Programming (`/pair-programming:*`)

Get second opinions from multiple AI providers on your code, plans, or architecture decisions.

| Command | Triggers |
|---------|----------|
| `/pair-programming:ai-pair-programmer` | `review with grok`, `review with gemini`, `review with chatgpt`, `pair program`, `second opinion`, `ai review` |

```
"Review this implementation with Grok"
"Get ChatGPT's opinion on this approach"
"Ask all AIs to review my PR"
```

**Supported providers:** Grok (xAI), ChatGPT (OpenAI), Gemini (Google)

**Requires:** API keys for desired providers (`XAI_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`)

---

### Ruby (`/ruby:*`)

Run Rubocop on files with intelligent auto-fixing.

| Command | Description |
|---------|-------------|
| `/ruby:rubocop` | Run Rubocop on specified file and fix violations |

```
/ruby:rubocop app/models/user.rb
```

Automatically fixes violations where possible, adds disable comments only when the rule would be incorrect or dangerous.

**Requires:** Ruby project with Rubocop configured

---

### Context Init (`/context-init:*`)

Set up project context environments for non-developers (product owners, managers) with GitLab repos, CLAUDE.md generation, and Confluence/Jira integration.

| Command | Triggers |
|---------|----------|
| `/context-init:context-init` | `context init`, `project setup`, `workspace setup`, `initialize project`, `context setup` |

**Requires:** GitLab MCP, Atlassian MCP (optional)

---

### Jira Improve (`/jira-improve:*`)

Find and improve poorly written Jira issues using a quality rubric. Analyze a whole project, a single issue, or an Epic with all its children.

| Command | Triggers |
|---------|----------|
| `/jira-improve:jira-improve` | `jira improve`, `fix jira`, `improve issues`, `jira quality`, `backlog cleanup`, `improve epic` |

Features:
- Score issues against quality rubric (completeness, clarity, structure, context, testability)
- Gather context from codebase or user interviews
- Generate improved issue descriptions with previews
- Batch improve multiple issues

**Requires:** Atlassian MCP (or `acli` CLI tool)

---

### Behavioral Diff (`/behavioral-diff:*`)

Detect logic inversions, control flow changes, and semantic alterations that could break business logic. Uses a dual-analyzer architecture (control-flow + business-logic) with context-aware confidence scoring.

| Command | Triggers |
|---------|----------|
| `/behavioral-diff:review` | `review diff`, `check inversions`, `behavioral review`, `logic check` |

**Arguments:**

| Argument | Behavior |
|----------|----------|
| `--staged` (default) | Review staged changes |
| `--branch` | Review current branch vs main |
| `--commit` | Review last commit |
| `--strict` (default) | Maximum sensitivity, more false positives |
| `--normal` | Reduced sensitivity, fewer false positives |
| `file_path` | Limit review to specific file(s) |

**What Gets Flagged:**
- **CRITICAL:** Boolean inversions (`if (x)` → `if (!x)`), swapped if/else branches, equality inversions (`==` → `!=`)
- **HIGH:** Comparison operator changes, null check inversions, guard clause inversions, authorization/validation changes
- **MEDIUM:** Loop bound changes, LINQ semantic changes, ternary swaps, state machine modifications

```
/behavioral-diff:review --branch
/behavioral-diff:review src/Services/OrderService.cs
```

**Requires:** Git repository with staged changes or commits to analyze

---

### .NET (`/dotnet:*`)

Trunk-based development migration tools for .NET API services. Automates the migration from GitLab Flow to trunk-based development with Kustomize, shared pipeline templates, review apps, and production approval gates.

| Command | Triggers | Description |
|---------|----------|-------------|
| `/dotnet:trunk-help` | `trunk help`, `what is trunk migration`, `how to migrate` | Overview of the migration plugin and workflow |
| `/dotnet:trunk-discover` | `trunk discover`, `discover service`, `analyze repo` | Scan repo and generate migration config YAML |
| `/dotnet:trunk-plan` | `trunk plan`, `migration plan`, `show plan` | Preview migration execution plan |
| `/dotnet:trunk-migrate` | `trunk migrate`, `migrate to trunk`, `trunk-based migration` | Execute the full migration |
| `/dotnet:trunk-validate` | `trunk validate`, `validate migration`, `check migration` | Run 6 validation checks on the migration |
| `/dotnet:trunk-troubleshoot` | `trunk troubleshoot`, `trunk fix`, `migration issue` | Diagnose and fix common migration issues |
| `/dotnet:trunk-post-migrate` | `trunk post-migrate`, `post migration`, `cleanup migration` | Post-merge cleanup, monitoring, and hardening |

**Workflow:** Discover → Plan → Migrate → Validate → (MR merge) → Post-Migrate

**Requires:** .NET 8 project with GitLab CI/CD, `kustomize` CLI, `gitlab-ci` plugin (for pipeline standards)

---

### Security (`/security:*`)

Security audit tools for vulnerability scanning, secrets detection, and compliance checking.

| Command | Description |
|---------|-------------|
| `/security:scan` | Scan codebase for vulnerabilities using OWASP Top 10 and CWE Top 25 |
| `/security:secrets` | Detect hardcoded secrets, API keys, and credentials |

**Requires:** Git repository with code to scan

---

### GitLab CI (`/gitlab-ci:*`)

Pipeline standards, best practices, and guidelines for Raptor projects.

| Command | Triggers | Description |
|---------|----------|-------------|
| `/gitlab-ci:standards-view` | `view standards`, `show standards`, `what are the standards` | Display standards summary to the user |
| `/gitlab-ci:standards-load` | `load standards`, `standards context` | Load full standards into Claude's context |
| `/gitlab-ci:standards-audit` | `audit pipeline`, `pipeline compliance`, `standards audit` | Audit repo for standards violations |

**Auto-triggered skill:** The `pipeline-edit` skill automatically activates when you mention pipeline editing tasks:
- `update pipeline`, `modify pipeline`, `create pipeline`
- `update gitlab-ci`, `edit gitlab-ci`
- `add job`, `add stage`, `new job`, `new stage`

**Current standards topics:**
- `job-ordering` — Use stages for cross-stage ordering and `needs` only for intra-stage ordering

---

### Epistemic Reasoning (hook-based)

Enforces evidence-based reasoning by requiring `[FACT]`, `[INFERRED]`, and `[ASSUMED]` labels on all claims. Automatically enabled via `SessionStart` hook—no slash commands needed.

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
/plugin install aidlc
/plugin install issues
/plugin install pair-programming
/plugin install ruby
/plugin install epistemic-reasoning
/plugin install context-init
/plugin install jira-improve
/plugin install behavioral-diff
/plugin install dotnet
/plugin install security
/plugin install gitlab-ci

# Reload after changes
/plugin
```

### Configure MCP Servers

Some plugins require MCP servers. Add to your Claude Code settings:

**Atlassian MCP** (for aidlc, issues):
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
