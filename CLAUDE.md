# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace repository containing custom plugins that extend Claude Code's capabilities. Plugins provide skills (slash commands), hooks (session lifecycle events), and integrations with external tools.

## Architecture

### Plugin Structure

Each plugin lives in `plugins/<plugin-name>/` with this structure:

```
plugins/<plugin-name>/
  .claude-plugin/
    plugin.json          # Plugin manifest (name, description, skills path)
  skills/                # Optional: skill definitions
    <skill-name>/
      SKILL.md           # Skill definition with frontmatter
  hooks/                 # Optional: lifecycle hooks
    hooks.json
  references/            # Optional: shared docs (MUST be outside skills/)
```

### Marketplace Registry

`.claude-plugin/marketplace.json` at the repo root registers all plugins for distribution.

### Current Plugins

| Plugin | Purpose |
|--------|---------|
| `planning` | AI-DLC workflow: Intent docs → Jira Epics → Units → Stories |
| `issues` | Jira issue creation, GitLab MRs, release notes |
| `pair-programming` | Get second opinions from Grok/ChatGPT/Gemini |
| `epistemic-reasoning` | Enforces [FACT]/[INFERRED]/[ASSUMED] labeling |
| `ruby` | Rubocop linting with auto-fix |
| `context-init` | Project setup for non-developers with repo cloning and MCP config |

### Plugin Skills Reference

#### Planning (`/planning:*`)

| Command | Triggers | Description |
|---------|----------|-------------|
| `/planning:aidlc-plan` | `create intent`, `level 1 doc`, `intent document`, `new initiative`, `draft intent`, `aidlc plan` | Create Level 1 Intent documentation in Confluence |
| `/planning:aidlc-decompose` | `decompose intent`, `break down intent`, `create units`, `create stories`, `mob elaboration` | Break Intent into Units and Stories via Mob Elaboration |
| `/planning:aidlc-design` | `domain design`, `logical design`, `create ADR`, `architecture decision`, `aidlc design` | Domain/Logical Design and Architecture Decision Records |
| `/planning:aidlc-verify` | `verify docs`, `check readiness`, `transfer to jira`, `aidlc verify`, `confidence check` | Verify doc completeness before Jira transfer |
| `/planning:aidlc-help` | `aidlc help`, `what is aidlc`, `explain aidlc`, `planning help`, `how to plan` | Explain AI-DLC methodology and available skills |

#### Issues (`/issues:*`)

| Command | Description |
|---------|-------------|
| `/issues:create-jira-issue` | Create a Jira issue from current context or description |
| `/issues:create-mr` | Create a GitLab merge request for the current branch |
| `/issues:release-notes` | Generate release notes from commits, MRs, and Jira tickets |

#### Pair Programming (`/pair-programming:*`)

| Command | Triggers | Description |
|---------|----------|-------------|
| `/pair-programming:ai-pair-programmer` | `review with grok`, `review with gemini`, `review with chatgpt`, `pair program`, `second opinion`, `ai review` | Get second opinions from AI providers on code or architecture |

#### Ruby (`/ruby:*`)

| Command | Description |
|---------|-------------|
| `/ruby:rubocop` | Run Rubocop on specified file and fix violations |

#### Context Init (`/context-init:*`)

| Command | Triggers | Description |
|---------|----------|-------------|
| `/context-init:context-init` | `context init`, `project setup`, `workspace setup`, `initialize project` | Set up project context for non-developers |

#### Epistemic Reasoning (hook-based)

No slash commands. Automatically activates via `SessionStart` hook to enforce `[FACT]`, `[INFERRED]`, `[ASSUMED]` labeling.

## Skill File Format (SKILL.md)

```yaml
---
name: skill-name              # REQUIRED for slash command invocation
description: "What it does"   # REQUIRED, max 1024 chars
allowed-tools: [Tool1, Tool2] # Optional: tools allowed without permission
argument-hint: "<args>"       # Optional: hint shown in UI
---

# Skill Title

Instructions for Claude when skill is invoked...
```

**Critical rules:**
- `name:` field is required for the skill to appear as a slash command
- Name must match folder name, use lowercase/hyphens only
- Every direct child folder of `skills/` must contain a SKILL.md (non-skill folders like `references/` break the loader)

## Hook Format (hooks.json)

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "..." }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "..." }] }]
  }
}
```

Use `${CLAUDE_PLUGIN_ROOT}` to reference files relative to the plugin directory.

## Template Variables

- `{{SKILL_DIR}}` - Path to the skill's folder (use in SKILL.md for relative paths)
- `${CLAUDE_PLUGIN_ROOT}` - Plugin root directory (use in hooks.json)

## Versioning

**IMPORTANT**: Bump the plugin version for every plugin update in **both** locations:

1. `plugins/<plugin-name>/.claude-plugin/plugin.json`
2. `.claude-plugin/marketplace.json` (root marketplace registry)

Use [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, typo corrections
- **MINOR** (1.0.1 → 1.1.0): New features, new skills, workflow changes
- **MAJOR** (1.1.0 → 2.0.0): Breaking changes, major restructuring

## Testing Changes

After modifying plugins:
1. Run `/plugin` in Claude Code to reload plugins
2. Type `/` to verify skills appear in autocomplete
3. Invoke the skill to test functionality
