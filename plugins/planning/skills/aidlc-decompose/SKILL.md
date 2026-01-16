---
name: aidlc-decompose
description: Decompose an approved Intent into User Stories and Units using parallel agents for story elaboration. Stories are clustered by theme, elaborated in parallel, then grouped into Units for human approval before Jira creation. (Triggers: decompose intent, break down intent, create units, unit decomposition, create stories, break into units, split intent, aidlc decompose)
---

# AI-DLC Decompose

Break down an approved Intent into User Stories and Units (Sub-epics) using parallel agents for efficient story elaboration. Stories are created as markdown files first for review and collaboration, then converted to Jira issues after approval. Do not create Bugs unless explicitly requested by a human.

> **CRITICAL: Markdown First, Jira Later**
>
> This skill has TWO distinct phases with a hard approval gate between them:
> - **Phase 1**: Elaborate stories as local markdown files using parallel agents. **NO Jira creation.**
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

- Use `../references/planning-shared.md` for templates, Bolt guidance, subagent prompts, and Jira tool names.

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

### Phase 1: Story Elaboration (Parallel Agents)

**In this phase, you will ONLY:**
- Read from Confluence and Jira (to understand the Intent)
- Spawn subagents to elaborate stories in parallel
- Create local markdown files for stories
- Discuss and refine with the user

**DO NOT in Phase 1:**
- Create any Jira issues (Sub-epics, Stories, Tasks, etc.)
- Update Jira labels or fields
- Modify Confluence workflow status

#### Step 1: Gather Context

Ask only for what is missing:
- Jira project key (no default)
- Intent Epic key
- Approved Confluence Level 1 doc link(s)
- Any known constraints, dependencies, or sequencing needs

#### Step 2: Ask for Story Output Location

Prompt the user for where to save story markdown files:
- Suggest a default path (e.g., `docs/stories/` or `.aidlc/stories/`)
- Explain these files can be committed to a repository for team visibility and review
- Confirm the directory path before creating files

#### Step 3: Identify Theme Clusters

Analyze the Intent and identify 3-5 theme clusters for parallel elaboration:
- Group related functionality/capabilities together
- Each cluster should have low coupling to other clusters
- Present the clusters to the user for confirmation

Example output:
```
Based on the Intent, I've identified these theme clusters:
1. **Authentication & Authorization** - Login, SSO, permissions (4 stories)
2. **API Layer** - Endpoints, validation, rate limiting (3 stories)
3. **Data Migration** - Schema changes, ETL, rollback (3 stories)

I'll spawn 3 subagents to elaborate these in parallel.
```

#### Step 4: Spawn Story Elaboration Subagents

For each theme cluster, spawn a subagent using the Task tool:
- Use `subagent_type: "general-purpose"`
- Pass the condensed Intent context (not full documents)
- Use the Story Elaboration Subagent Prompt Template from `../references/planning-shared.md`
- **Spawn all subagents in a single message** (parallel execution)

Each subagent will:
- Elaborate all stories for its assigned theme
- Return structured JSON with story content, risks, and dependencies
- Identify cross-cutting concerns that span themes

#### Step 5: Consolidate Subagent Results

After all subagents return:
1. Parse the JSON results from each subagent
2. Merge cross-cutting concerns into a unified risk list
3. Build a dependency graph across all stories
4. Surface any conflicts or gaps between themes

#### Step 6: Group Stories into Units

Organize the elaborated stories into cohesive Units:
- Start with theme boundaries as initial groupings
- Adjust based on dependency analysis (may merge or split themes)
- Apply loose coupling, high cohesion principles
- Each Unit should deliver independent value
- Surface dependencies between Units

#### Step 7: Plan Bolts

For each Unit, suggest rapid iteration cycles:
- Bolt boundaries based on testable increments
- Estimated duration (hours/days)
- Sequencing considerations
- See Bolt Planning Guidance in `../references/planning-shared.md`

#### Step 8: Write Markdown Files

Write all story files to the confirmed output location:
- Use the Story Markdown Template from `../references/planning-shared.md`
- File naming convention: `<unit-slug>-<story-number>-<short-title>.md`
- Create `_units-overview.md` summarizing:
  - All Units with their stories
  - Bolt plan per Unit
  - Merged risks and dependencies
  - Cross-cutting concerns

#### Step 9: Request Approval

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

#### Step 10: Prompt for Jira Creation

After user approves the markdown stories:
- Confirm the user wants to proceed with Jira creation
- Remind them that Units will be created as Sub-epics and Stories as sub-tasks

#### Step 11: Create Jira Artifacts

- Create Units as Sub-epics (or Epics if Sub-epic unavailable) linked to the Intent Epic
- Create Stories as sub-tasks under each Unit (Sub-epic)
- Include acceptance criteria, test notes, and links from the markdown files
- Use templates in `../references/planning-shared.md`
- Update Intent Epic label: `aidlc:decomposing` → `aidlc:decomposed`

#### Step 12: Update Workflow Status

Update the Confluence page status table:
- Set "Unit Decomposition" row to "✅ Complete" with today's date
- Add links to created Units in the Artifact column

#### Step 13: Update Markdown Files

Add Jira keys to the corresponding markdown files for traceability.

#### Step 14: Report Back

Provide created keys and ask for any refinements.

#### Step 15: Chain to Design

Ask whether to proceed with Domain Design for any Unit.
If yes, invoke `/planning:aidlc-design` with the Unit context.

## Workflow Chain

- **Previous**: `/planning:aidlc-create-epic` (Intent Epic creation)
- **Next**: `/planning:aidlc-design` (Domain and Logical Design)

## Definition of Done

### Phase 1 (Markdown Review)
- Theme clusters identified and confirmed with user
- Subagents spawned in parallel for story elaboration
- All subagent results consolidated
- User Stories elaborated as markdown files with acceptance criteria
- Stories grouped into cohesive Units in `_units-overview.md`
- Bolt plan suggested per Unit
- Risks and dependencies explicit (including cross-cutting concerns)
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
- **Subagent failure**: Report which theme cluster failed and offer to retry or elaborate manually.
- **Single theme identified**: Still spawn one subagent for consistency; workflow proceeds normally.
