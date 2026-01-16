---
name: aidlc-decompose
description: Decompose an approved Intent into User Stories and Units, with human-in-the-loop validation, risk surfacing, and Bolt planning. Stories are first created as markdown files for review, then converted to Jira issues after approval. (Triggers: decompose intent, break down intent, create units, unit decomposition, create stories, break into units, split intent, aidlc decompose)
---

# AI-DLC Decompose

Break down an approved Intent into User Stories and Units (Sub-epics). Stories are created as markdown files first for review and collaboration, then converted to Jira issues after approval. Do not create Bugs unless explicitly requested by a human.

> **CRITICAL: Markdown First, Jira Later**
>
> This skill has TWO distinct phases with a hard approval gate between them:
> - **Phase 1**: Elaborate stories as local markdown files. **NO Jira creation.**
> - **Phase 2**: After explicit user approval, create Jira artifacts.
>
> **DO NOT** create Sub-epics, Stories, or any Jira issues during Phase 1.
> **DO NOT** proceed to Phase 2 without explicit user approval of the markdown files.

## Example Invocations

- "Break down the authentication intent into stories and units"
- "Decompose the billing epic"
- "Create units and stories for the API migration intent"
- "Split the approved intent into work items"

## References

- Use `../references/planning-shared.md` for templates, Bolt guidance, and Jira tool names.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Level 1 Intent document (ask for link)
   - Jira Intent Epic (ask for key)
   - Fetch both using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Intent Epic" row shows "✅ Created"

3. **If prerequisites incomplete**
   - Offer to run `/planning:aidlc-create-epic` first (or `/planning:aidlc-plan` if Confluence doc missing)
   - Or allow override with explicit confirmation (see Override Pattern in `../references/planning-shared.md`)

## Workflow

### Phase 1: Story Elaboration (Markdown Files)

**In this phase, you will ONLY:**
- Read from Confluence and Jira (to understand the Intent)
- Create local markdown files for stories
- Discuss and refine with the user

**DO NOT in Phase 1:**
- Create any Jira issues (Sub-epics, Stories, Tasks, etc.)
- Update Jira labels or fields
- Modify Confluence workflow status

1. **Gather context**
   Ask only for what is missing:
   - Jira project key (no default)
   - Intent Epic key
   - Approved Confluence Level 1 doc link(s)
   - Any known constraints, dependencies, or sequencing needs

2. **Ask for story output location**
   Prompt the user for where to save story markdown files:
   - Suggest a default path (e.g., `docs/stories/` or `.aidlc/stories/`)
   - Explain these files can be committed to a repository for team visibility and review
   - Confirm the directory path before creating files

3. **Elaborate User Stories**
   From the Intent and Level 1 documentation:
   - Create each Story as a markdown file using the Story Markdown Template in `../references/planning-shared.md`
   - File naming convention: `<story-number>-<short-title>.md` (unit slug added after grouping)
   - Surface risks and dependencies per Story
   - Identify cross-cutting concerns

4. **Group Stories into Units**
   Organize Stories into cohesive Units:
   - Apply loose coupling, high cohesion principles
   - Each Unit should deliver independent value
   - Surface dependencies between Units
   - Create a `_units-overview.md` file summarizing the grouping

5. **Plan Bolts**
   For each Unit, suggest rapid iteration cycles:
   - Bolt boundaries based on testable increments
   - Estimated duration (hours/days)
   - Sequencing considerations
   - See Bolt Planning Guidance in `../references/planning-shared.md`

6. **Request approval**
   Summarize the full decomposition:
   - Stories grouped by Unit (with links to markdown files)
   - Bolt plan per Unit
   - Dependencies and risks

   **Ask explicitly**: "Please review the story files and confirm you're ready to create these in Jira."

---

### ⛔ STOP — Approval Gate

**Phase 1 is complete.** Do not proceed until the user explicitly confirms:
- They have reviewed the markdown story files
- They approve the Unit groupings
- They want to create Jira issues

**Wait for explicit approval before continuing to Phase 2.**

---

### Phase 2: Jira Creation (After Approval)

7. **Prompt for Jira creation**
   After user approves the markdown stories:
   - Confirm the user wants to proceed with Jira creation
   - Remind them that Units will be created as Sub-epics and Stories as sub-tasks

8. **Create Jira artifacts**
   - Create Units as Sub-epics (or Epics if Sub-epic unavailable) linked to the Intent Epic
   - Create Stories as sub-tasks under each Unit (Sub-epic)
   - Include acceptance criteria, test notes, and links from the markdown files
   - Use templates in `../references/planning-shared.md`
   - Update Intent Epic label: `aidlc:decomposing` → `aidlc:decomposed`

9. **Update workflow status**
   Update the Confluence page status table:
   - Set "Unit Decomposition" row to "✅ Complete" with today's date
   - Add links to created Units in the Artifact column

10. **Update markdown files**
    Add Jira keys to the corresponding markdown files for traceability.

11. **Report back**
    Provide created keys and ask for any refinements.

12. **Chain to Design**
    Ask whether to proceed with Domain Design for any Unit.
    If yes, invoke `/planning:aidlc-design` with the Unit context.

## Workflow Chain

- **Previous**: `/planning:aidlc-create-epic` (Intent Epic creation)
- **Next**: `/planning:aidlc-design` (Domain and Logical Design)

## Definition of Done

### Phase 1 (Markdown Review)
- User Stories elaborated as markdown files with acceptance criteria
- Stories grouped into cohesive Units in `_units-overview.md`
- Bolt plan suggested per Unit
- Risks and dependencies explicit
- User has reviewed and approved the story files

### Phase 2 (Jira Creation)
- Units created as Sub-epics linked to Intent Epic
- Stories created as sub-tasks under their respective Units
- Markdown files updated with Jira keys for traceability
- Confluence status table updated

## Troubleshooting

- **Sub-epic not supported**: Use Epic + issue links or parent field; ask for preferred structure.
- **Missing issue types**: Use `getJiraProjectIssueTypesMetadata` and confirm available types.
- **Too many Stories**: Consider splitting into multiple Units or deferring lower-priority Stories.
- **User wants to skip markdown phase**: Allow override but recommend markdown for team visibility.
