---
name: project-phase-planner
description: Break an approved initiative into phased delivery with parallel workstreams, dependencies, and technology choices. Use when the user wants a phase plan, sequencing, staffing considerations, and test strategy per phase, then publish the plan to Confluence and optionally create Jira epics via Atlassian MCP. (Triggers: phase plan, delivery plan, project phases, break down initiative, create epics, sequencing plan, staffing plan, roadmap phases)
---

# Project Phase Planner

Turn an approved initiative brief into a phased delivery plan. Emphasize sequencing, parallelization based on team size, and testing in every phase.

## Example Invocations

- "Create a phase plan for the auth initiative"
- "Break down this initiative into delivery phases"
- "Help me plan the sequencing for the API migration"
- "Create epics for each phase of the billing project"
- "Draft a delivery roadmap with parallel workstreams"

## References

- Use `references/planning-shared.md` for the shared templates, testing guidance, and context questions.

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Link/title of the initiative brief
   - Team size and roles (e.g., 3 backend, 1 frontend, 1 infra)
   - Target timeline or milestones
   - Known dependencies or blockers
   - Technology choices or constraints
   - Which repositories/services are in scope (local path if available)

2. **Gather repo context (if useful)**
   Use the local repo when available; otherwise use GitLab MCP or `glab` to fetch README/docs. See `references/planning-shared.md`.

3. **Gather Atlassian context (if useful)**
   Fetch the initiative brief from Confluence if a link was provided. Search for related Jira epics or issues that may inform the phase plan. See `references/planning-shared.md`.

4. **Confirm understanding**
   Summarize in 5-8 bullets and ask for confirmation before drafting.

5. **Draft the phase plan**
   - Propose 3-6 phases with clear goals and exit criteria
   - Identify parallel workstreams based on staffing
   - Call out dependencies between phases and streams
   - Include testing strategy per phase

6. **Confirm artifact destinations**
   Before creating any artifacts, ask the user where they want the plan published:
   - **Confluence only**: Publish as a page or child page under the initiative
   - **Jira only**: Create Epics (one per phase) with sub-tasks or sub-epics for workstreams
   - **Both**: Publish to Confluence and create linked Jira Epics

   Also confirm:
   - For Confluence: Add to existing initiative page or create a child page?
   - For Jira: Which project? Create sub-epics for workstreams or just the phase Epics?

7. **Publish to Confluence** (if selected)
   - Add a "Delivery Plan" section to the initiative page or create a child page
   - Use Atlassian MCP to update or create the page under the target space (default: `raptorepd`) → "Initiatives"

8. **Create Jira Epics** (if selected)
   - Create one Epic per phase
   - Optionally create sub-epics or stories for parallel workstreams within each phase
   - Link each Epic to the Confluence page URL (if created) in the description
   - Invite revisions and repeat steps 1-5 as needed

## Jira Epic Guidance

**Phase Epics:**
- Issue type: Epic
- Summary: "Phase N - <Phase Name>"
- Description: Phase objective + key deliverables + link to Confluence (if created)

**Sub-Epics for Workstreams** (if requested):
- Issue type: Epic (or Story, depending on project configuration)
- Summary: "Phase N - <Workstream Name>"
- Parent: Link to the phase Epic
- Description: Workstream scope + dependencies on other workstreams

## Tool Names

Use the tool names listed in `references/planning-shared.md`.

In Claude Code, Atlassian tools use the `mcp__plugin_atlassian_atlassian__` prefix (e.g., `mcp__plugin_atlassian_atlassian__createJiraIssue`).

## Definition of Done

- Phase plan drafted with clear phases, workstreams, and exit criteria
- Dependencies and parallel streams identified
- Testing strategy included per phase
- Artifacts created in user's chosen destination(s):
  - Confluence page published (if selected)
  - Jira Epics/sub-epics created (if selected)

## Troubleshooting

- **Initiative brief not found**: Ask for the exact page title or URL. Use `search` or `searchConfluenceUsingCql` to locate it.
- **"Initiatives" parent page not found**: Ask the user if the parent page has a different name, or offer to create the page at the space root level.
- **Space not found**: Verify the space key with `getConfluenceSpaces`. Common issues: typos, case sensitivity, or permissions.
- **Permission denied**: The user may not have write access to the space or Jira project. Suggest they check with their admin.
- **Epic creation failed**: Verify the Jira project key and that the user has permission to create Epics. Use `getVisibleJiraProjects` to confirm access.
- **Missing issue type**: Some Jira projects may not have "Epic" as an issue type. Use `getJiraProjectIssueTypesMetadata` to see available types.
