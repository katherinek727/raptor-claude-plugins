# Context Init Templates & Reference

This file contains templates and guides used by the `/context-init` skill.

---

## CLAUDE.md Template

Use this template when generating the project CLAUDE.md file. Replace placeholders with actual values.

```markdown
# CLAUDE.md

This file configures Claude Code for the **{{PROJECT_NAME}}** project.

## Project Overview

{{PROJECT_DESCRIPTION}}

### Key Stakeholders

{{STAKEHOLDERS}}

---

## Repositories

{{#if REPOSITORIES}}
| Repository | Description | Path |
|------------|-------------|------|
{{#each REPOSITORIES}}
| {{name}} | {{description}} | `./{{folder}}` |
{{/each}}
{{else}}
No repositories cloned. Clone repos with `git clone <url>`.
{{/if}}

---

## Confluence Integration

{{#if CONFLUENCE_CONFIGURED}}
### Space: {{CONFLUENCE_SPACE_KEY}}

Access project documentation using the Atlassian MCP tools.

**Key Pages:**
{{#each CONFLUENCE_PAGES}}
- **{{title}}** (ID: {{id}})
{{/each}}

### Example Queries

Search for content:
```
Use mcp__plugin_atlassian_atlassian__search with query: "{{PROJECT_NAME}} requirements"
```

Get a specific page:
```
Use mcp__plugin_atlassian_atlassian__getConfluencePage with:
- cloudId: (from getAccessibleAtlassianResources)
- pageId: "<page-id>"
```

List pages in space:
```
Use mcp__plugin_atlassian_atlassian__getPagesInConfluenceSpace with:
- cloudId: (from getAccessibleAtlassianResources)
- spaceId: "<space-id>"
```
{{else}}
Confluence integration not configured. To set up:
1. Ensure Atlassian MCP is configured in Claude Code settings
2. Run `/context-init` to add Confluence space
{{/if}}

---

## Jira Integration

{{#if JIRA_CONFIGURED}}
### Project: {{JIRA_PROJECT_KEY}}

Track and manage work using the Atlassian MCP tools.

**Useful JQL Queries:**

| Query | JQL |
|-------|-----|
| All open issues | `project = {{JIRA_PROJECT_KEY}} AND status != Done` |
| My assigned issues | `project = {{JIRA_PROJECT_KEY}} AND assignee = currentUser()` |
| Recent updates | `project = {{JIRA_PROJECT_KEY}} AND updated >= -7d` |
{{#if JIRA_EPICS}}
| Epic: {{EPIC_NAME}} | `"Epic Link" = {{EPIC_KEY}}` |
{{/if}}

### Example Queries

Search issues:
```
Use mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql with:
- cloudId: (from getAccessibleAtlassianResources)
- jql: "project = {{JIRA_PROJECT_KEY}} AND status != Done"
```

Get issue details:
```
Use mcp__plugin_atlassian_atlassian__getJiraIssue with:
- cloudId: (from getAccessibleAtlassianResources)
- issueIdOrKey: "{{JIRA_PROJECT_KEY}}-123"
```

Create an issue:
```
Use mcp__plugin_atlassian_atlassian__createJiraIssue with:
- cloudId: (from getAccessibleAtlassianResources)
- projectKey: "{{JIRA_PROJECT_KEY}}"
- issueTypeName: "Story"
- summary: "Issue title"
- description: "Issue description"
```
{{else}}
Jira integration not configured. To set up:
1. Ensure Atlassian MCP is configured in Claude Code settings
2. Run `/context-init` to add Jira project
{{/if}}

---

## AI-DLC Planning Skills

Use these skills to plan and document your initiative:

| Skill | When to Use |
|-------|-------------|
| `/planning:aidlc-plan` | Create Level 1 Intent documentation |
| `/planning:aidlc-decompose` | Break Intent into User Stories and Units |
| `/planning:aidlc-design` | Domain design and Architecture Decision Records |
| `/planning:aidlc-verify` | Verify documentation completeness before Jira transfer |
| `/planning:aidlc-help` | Get help with the AI-DLC methodology |

### Recommended Workflow

1. **Start with Intent**: Run `/planning:aidlc-plan` to create your Level 1 Intent document
2. **Decompose**: Once Intent is approved, run `/planning:aidlc-decompose` to create Units and Stories
3. **Design**: Use `/planning:aidlc-design` for technical design (usually with engineering)
4. **Verify**: Run `/planning:aidlc-verify` before transferring to Jira

---

## Working with Claude

### Context Loading

When starting a new conversation, Claude will automatically read this file. You can also:
- Share specific files: "Look at the README in repo-name"
- Reference Confluence: "Search Confluence for the requirements doc"
- Query Jira: "Show me open stories in {{JIRA_PROJECT_KEY}}"

### Best Practices

1. **Be specific**: "Create a story for user login" vs "Add login"
2. **Provide context**: Reference relevant docs or decisions
3. **Review before committing**: Always review generated content before creating Jira issues or Confluence pages

{{#if ADDITIONAL_CONTEXT}}
---

## Additional Context

{{ADDITIONAL_CONTEXT}}
{{/if}}
```

---

## Installation Guides

### Git Installation

#### macOS

**Option 1: Xcode Command Line Tools (Recommended)**
```bash
xcode-select --install
```

**Option 2: Homebrew**
```bash
brew install git
```

#### Windows

**Option 1: winget (Windows 10/11)**
```bash
winget install Git.Git
```

**Option 2: Download installer**
Download from: https://git-scm.com/download/win

#### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install git
```

#### Linux (Fedora/RHEL)
```bash
sudo dnf install git
```

**Verify installation:**
```bash
git --version
```

---

### glab CLI Installation

glab is the official GitLab CLI tool for working with GitLab from the command line.

#### macOS (Homebrew)
```bash
brew install glab
```

#### Windows (winget)
```bash
winget install GLab.GLab
```

#### Linux (Homebrew)
```bash
brew install glab
```

#### Alternative: Download binary
Download from: https://gitlab.com/gitlab-org/cli/-/releases

**Authentication:**
```bash
# Interactive login (opens browser)
glab auth login

# Or with token
glab auth login --token <your-token>
```

**Verify:**
```bash
glab --version
glab auth status
```

---

### Atlassian MCP Configuration

The Atlassian MCP (Model Context Protocol) server allows Claude Code to interact with Confluence and Jira.

#### Step 1: Get Atlassian API Token

1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name (e.g., "Claude Code")
4. Copy the token (you won't see it again)

#### Step 2: Configure Claude Code

Add to your Claude Code settings (`.claude/settings.json` or via UI):

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@anthropic/claude-code-atlassian-mcp"],
      "env": {
        "ATLASSIAN_SITE_URL": "https://your-site.atlassian.net",
        "ATLASSIAN_USER_EMAIL": "your-email@example.com",
        "ATLASSIAN_API_TOKEN": "your-api-token"
      }
    }
  }
}
```

Replace:
- `your-site` with your Atlassian site name
- `your-email@example.com` with your Atlassian email
- `your-api-token` with the token from Step 1

#### Step 3: Verify

Restart Claude Code, then test:
- Ask Claude: "List my Confluence spaces"
- Or: "Show my Jira projects"

If it works, you'll see your spaces/projects listed.

---

## .context-init.json Schema

This marker file tracks the context initialization state for future updates.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "version": {
      "type": "string",
      "description": "Schema version (e.g., '1.0.0')"
    },
    "created": {
      "type": "string",
      "format": "date-time",
      "description": "ISO timestamp when context was first created"
    },
    "updated": {
      "type": "string",
      "format": "date-time",
      "description": "ISO timestamp of last update"
    },
    "projectName": {
      "type": "string",
      "description": "Human-readable project name"
    },
    "workspacePath": {
      "type": "string",
      "description": "Absolute path to workspace directory"
    },
    "repositories": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": { "type": "string" },
          "url": { "type": "string" },
          "description": { "type": "string" },
          "defaultBranch": { "type": "string" }
        },
        "required": ["name", "url"]
      },
      "description": "List of cloned repositories"
    },
    "confluence": {
      "type": "object",
      "properties": {
        "spaceKey": { "type": "string" },
        "spaceId": { "type": "string" },
        "keyPages": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": { "type": "string" },
              "title": { "type": "string" }
            }
          }
        }
      },
      "description": "Confluence configuration"
    },
    "jira": {
      "type": "object",
      "properties": {
        "projectKey": { "type": "string" },
        "projectId": { "type": "string" },
        "epics": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "key": { "type": "string" },
              "name": { "type": "string" }
            }
          }
        }
      },
      "description": "Jira configuration"
    },
    "additionalContext": {
      "type": "string",
      "description": "Any additional context provided by user"
    }
  },
  "required": ["version", "created", "projectName"]
}
```

**Example:**
```json
{
  "version": "1.0.0",
  "created": "2024-01-15T10:30:00Z",
  "updated": "2024-01-15T10:30:00Z",
  "projectName": "Customer Portal Redesign",
  "workspacePath": "/Users/jane/Projects/customer-portal",
  "repositories": [
    {
      "name": "portal-frontend",
      "url": "https://gitlab.com/acme/portal-frontend",
      "description": "React frontend for customer portal",
      "defaultBranch": "main"
    },
    {
      "name": "portal-api",
      "url": "https://gitlab.com/acme/portal-api",
      "description": "Backend API services",
      "defaultBranch": "main"
    }
  ],
  "confluence": {
    "spaceKey": "CP",
    "spaceId": "12345",
    "keyPages": [
      { "id": "67890", "title": "Project Overview" },
      { "id": "67891", "title": "Requirements Document" }
    ]
  },
  "jira": {
    "projectKey": "CP",
    "projectId": "10001",
    "epics": [
      { "key": "CP-100", "name": "Phase 1: Authentication" }
    ]
  }
}
```
