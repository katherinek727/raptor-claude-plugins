---
name: context-init
description: Set up a project context environment for non-developers (product owners, managers). Creates a workspace with cloned repos, generates CLAUDE.md, and configures Confluence/Jira integration. (Triggers - context init, project setup, workspace setup, initialize project, context setup)
allowed-tools: [Bash, Read, Write, Glob, Grep, mcp__plugin_atlassian_atlassian__search, mcp__plugin_atlassian_atlassian__getConfluenceSpaces, mcp__plugin_atlassian_atlassian__getConfluencePage, mcp__plugin_atlassian_atlassian__getVisibleJiraProjects, mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources, AskUserQuestion]
argument-hint: "[project-name or folder-path]"
---

# Context Initialization Skill

You are helping a **non-developer** (product owner, manager, or similar role) set up a project context environment. Your goal is to create a workspace where they can effectively use Claude Code for planning, documentation, and project management tasks.

## Interaction Style

- **AI-Drives-Conversation**: You propose actions, user approves, then you execute
- **Phase gates**: Get explicit user approval before major operations
- **Graceful degradation**: If tools are missing, offer alternatives or skip gracefully
- **Non-technical language**: Avoid jargon, explain what each step accomplishes

## Workflow Phases

### Phase 1: Prerequisites Check

Check for required tools. Present results in a summary table:

| Tool | Status | Purpose |
|------|--------|---------|
| Git | ✅/❌ | Clone repositories |
| glab CLI | ✅/❌ | GitLab integration |
| Atlassian MCP | ✅/❌ | Confluence & Jira access |

**Check commands:**
```bash
# Git
git --version

# glab CLI
glab --version

# glab authentication
glab auth status
```

**For Atlassian MCP**, attempt to call `mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources`. If it fails, MCP is not configured.

**If tools are missing**, consult `{{SKILL_DIR}}/../references/templates.md` for installation guides and present platform-appropriate instructions.

**Flow:**
- Git missing → Show install guide, cannot proceed without Git
- glab missing → Offer: (1) Install glab, (2) Skip GitLab features, use manual clone URLs
- glab not authenticated → Guide: `glab auth login`
- Atlassian MCP missing → Offer: (1) Show setup guide, (2) Skip Confluence/Jira features

### Phase 2: Workspace Setup

**Quick Setup Detection:**
First, check if there's an existing `.context-init.json` in the current directory or specified path:

```bash
ls -la .context-init.json 2>/dev/null || echo "Not found"
```

If found:
1. Read existing config and present current state
2. Ask user: "I found an existing context configuration. Would you like to: (1) Update it, (2) Replace it completely, (3) View current config?"

**New Setup:**
1. Ask user for project name if not provided as argument
2. Determine workspace location:
   - If argument provided: Use that path
   - Otherwise: Propose `~/Projects/<project-name>` (or appropriate platform default)
3. Create the parent folder:

```bash
mkdir -p "<workspace-path>"
cd "<workspace-path>"
```

4. Confirm workspace created and display path

### Phase 3: Repository Cloning

**Goal:** Clone relevant GitLab repositories into the workspace.

1. Ask user: "What GitLab repositories should I clone? You can provide:
   - Full URLs (e.g., https://gitlab.com/group/project)
   - Project paths (e.g., group/project)
   - Or say 'search' to find repos by name"

2. For each repository:
   - Clone using `git clone` or `glab repo clone`
   - Capture description if available
   - Note default branch

3. If glab is available and user wants to search:
```bash
glab repo list --search "<query>" --mine
# or for group repos:
glab repo list --group "<group-name>"
```

4. Build repository inventory for CLAUDE.md:
```
| Repository | Description | Default Branch |
|------------|-------------|----------------|
| repo-name | Description | main |
```

### Phase 4: Generate CLAUDE.md

**Goal:** Create a project configuration file that helps Claude Code understand the context.

1. Gather information:
   - Project name (from Phase 2)
   - Cloned repositories (from Phase 3)
   - Ask: "In 2-3 sentences, what is this project about?"
   - Ask: "Who are the main stakeholders or team members I should know about?"

2. Use the template from `{{SKILL_DIR}}/../references/templates.md` to generate CLAUDE.md

3. Write to `<workspace>/CLAUDE.md`

4. Show user the generated content and ask for any corrections

### Phase 5: Confluence Integration

**Skip if Atlassian MCP is not available.**

1. List accessible Confluence spaces:
   - Use `mcp__plugin_atlassian_atlassian__getConfluenceSpaces` to get available spaces

2. Ask user: "Which Confluence space contains your project documentation?"
   - Present list of available spaces with their keys
   - User selects one or provides space key

3. Once space is selected, ask: "What are the key pages I should reference? Common examples:
   - Project overview/wiki home
   - Architecture decisions
   - Requirements documents
   - Meeting notes location"

4. For each key page:
   - Use `mcp__plugin_atlassian_atlassian__search` or get page ID
   - Verify page exists
   - Add to CLAUDE.md with page title and ID

5. Update CLAUDE.md with Confluence section including:
   - Space key
   - Key page references with IDs
   - Example MCP queries

### Phase 6: Jira Integration

**Skip if Atlassian MCP is not available.**

1. List accessible Jira projects:
   - Use `mcp__plugin_atlassian_atlassian__getVisibleJiraProjects`

2. Ask user: "Which Jira project tracks work for this initiative?"
   - Present list of available projects with keys
   - User selects one or provides project key

3. Once project selected, gather useful queries:
   - Ask: "What are common labels or components used in this project?"
   - Ask: "Are there specific epic(s) I should track?"

4. Update CLAUDE.md with Jira section including:
   - Project key
   - Useful JQL queries
   - Epic references if provided

### Phase 7: Additional Context

Ask user: "Is there any additional context I should know about?
- Meeting notes or recordings to review?
- External documentation links?
- Key decisions already made?
- Constraints or guidelines to follow?"

Add any additional context to CLAUDE.md.

### Phase 8: Finalization

1. Generate `.context-init.json` marker file:
```json
{
  "version": "1.0.0",
  "created": "<ISO timestamp>",
  "updated": "<ISO timestamp>",
  "projectName": "<name>",
  "repositories": ["<repo-list>"],
  "confluenceSpace": "<space-key>",
  "jiraProject": "<project-key>"
}
```

2. Present summary:

```
## Context Setup Complete

**Workspace:** <path>
**Repositories cloned:** <count>
**Confluence space:** <space-key> (or "Not configured")
**Jira project:** <project-key> (or "Not configured")

### Files Created
- CLAUDE.md - Project configuration for Claude Code
- .context-init.json - Configuration marker (for future updates)

### Next Steps
1. Open this folder in Claude Code: `cd <path>`
2. Start planning with: `/planning:aidlc-plan`
3. Review project docs in Confluence using the examples in CLAUDE.md
```

## Error Handling

### Git Clone Failures
- Check if URL is correct
- Verify network connectivity
- Check authentication for private repos

### glab Authentication Issues
- Guide user through `glab auth login`
- Offer alternative: manual clone with HTTPS URLs

### Atlassian MCP Failures
- Verify MCP is configured in Claude Code settings
- Check authentication status
- Offer to proceed without Confluence/Jira features

## Templates Reference

All templates and installation guides are in: `{{SKILL_DIR}}/../references/templates.md`
