---
name: confluence-initiative-brief
description: Create and iteratively refine Confluence initiative briefs for SaaS feature or service projects, focused on outline, objectives, acceptance criteria, success metrics, and testing strategy. Use when asked to draft or update an initiative document in Confluence, validate understanding, and then publish via Atlassian MCP. (Triggers: create initiative, write initiative brief, new confluence initiative, draft project brief, initiative document, project proposal)
---

# Confluence Initiative Brief

Create a high-level initiative document in Confluence. Emphasize iteration: confirm understanding before writing, and revise until the user is satisfied.

## Example Invocations

- "Create an initiative brief for the new authentication system"
- "Draft a project proposal for adding dark mode"
- "Write an initiative document for the API migration"
- "Help me create a Confluence brief for the billing overhaul"

## References

- Use `references/planning-shared.md` for the shared templates, testing guidance, and context questions.

## Workflow

1. **Gather context**
   Ask only for missing essentials. Prefer short questions.
   - Initiative name / working title
   - Problem/opportunity and target users
   - Objectives (business + user outcomes)
   - Scope boundaries (in/out)
   - Constraints (timeline, compliance, infra)
   - Success metrics preference (OKR/KPI/SLI, etc.)
   - Testing posture (automation in CI/CD, manual QA for exploratory, E2E only if user-facing)
   - Any known dependencies/risks
   - Which repositories/services are in scope (local path if available)
   - Existing Confluence pages or Jira issues to reference (links or search terms)
   - Whether to search Confluence/Jira for related context before drafting
   - **Confluence space** for the initiative (default: `raptorepd`, or ask if unsure)

2. **Gather repo context (if useful)**
   Use the local repo when available; otherwise use GitLab MCP or `glab` to fetch README/docs. See `references/planning-shared.md`.

3. **Gather Atlassian context (if useful)**
   Search Confluence and Jira for prior docs/issues that inform the brief. Prefer user-provided links, otherwise use `search` or CQL/JQL queries. See `references/planning-shared.md`.

4. **Confirm understanding**
   Summarize in 5-8 bullets and ask for confirmation before creating/updating the page.

5. **Locate the Confluence parent**
   - Use Atlassian MCP to find the Confluence space (default: `raptorepd`, or use user-specified space).
   - Locate the parent page titled "Initiatives" in the chosen space.
   - If the initiative already exists (matching title), ask whether to update it or create a new page.

6. **Draft the brief**
   Use the template in `references/planning-shared.md`. Keep it concise, scannable, and business-relevant.

7. **Create or update the Confluence page**
   Use Atlassian MCP to create or update the page under the "Initiatives" parent.

8. **Report back and invite iteration**
   Provide the page link and ask for any revisions or missing sections.
   Repeat steps 1-3 as needed.

## Content Guidance

- **Objectives**: Use outcome-based statements (user + business impact).
- **Acceptance criteria**: Bullet list, testable, unambiguous.
- **Success metrics**: Choose the most appropriate format for the project (OKR/KPI/SLI). Include baseline if known and target timeframe.
- **Testing strategy**: Use guidance in `references/planning-shared.md`.

## Prompt List (ask as needed)

- Any existing Confluence pages to reference (links or page titles)?
- Any Jira issues/epics already created (keys or links)?
- Should I run a Confluence/Jira search for related context before drafting?
- Which repos/services are in scope (local paths or GitLab projects)?

## Atlassian MCP Notes

- Use Atlassian MCP to:
  - get the Confluence cloudId
  - find the target space (default: `raptorepd`, or user-specified)
  - locate the "Initiatives" parent page ID (use `searchConfluenceUsingCql` or `search`)
  - create or update the initiative page
- If the MCP expects Confluence storage format, keep HTML simple with headings and lists.

## Tool Names

Use the tool names listed in `references/planning-shared.md`.

In Claude Code, Atlassian tools use the `mcp__plugin_atlassian_atlassian__` prefix (e.g., `mcp__plugin_atlassian_atlassian__createConfluencePage`).

## Definition of Done

- Confluence page exists under the target space → "Initiatives"
- Sections filled with clear, concise content
- User has confirmed understanding and approved the draft

## Troubleshooting

- **"Initiatives" parent page not found**: Ask the user if the parent page has a different name, or offer to create the page at the space root level.
- **Space not found**: Verify the space key with `getConfluenceSpaces`. Common issues: typos, case sensitivity, or permissions.
- **Permission denied**: The user may not have write access to the space. Suggest they check with their Confluence admin or choose a different space.
- **Page already exists**: Ask the user whether to update the existing page or create a new one with a modified title (e.g., "Initiative Name v2").
