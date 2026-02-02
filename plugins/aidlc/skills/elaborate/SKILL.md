---
name: elaborate
description: Decompose an approved Intent into User Stories and Units using Mob Elaboration. Stories are created as Confluence pages for collaborative review, re-assessed using domain knowledge and loose coupling/high cohesion principles, then transferred to Jira after approval. (Triggers - decompose intent, break down intent, create units, unit decomposition, create stories, break into units, split intent, aidlc decompose, mob elaboration)
---

# AI-DLC Decompose (Mob Elaboration)

Break down an approved Intent into User Stories and Units using the AI-DLC Mob Elaboration ritual. This skill uses parallel agents for efficient story elaboration. Stories are created as Confluence pages (child pages under the Level 1 Intent) for collaborative team review, then transferred to Jira only after Unit Re-assessment is complete. Do not create Bugs unless explicitly requested by a human.

> **AI-DLC Mob Elaboration**
>
> Per AI-DLC methodology: "AI plays a central role in proposing an initial breakdown
> of the Intent into User Stories, Acceptance Criteria and Units, leveraging domain
> knowledge, and the principles of loose coupling and high cohesion for rapid
> parallel execution downstream."
>
> Units are cohesive, self-contained work elements (analogous to Subdomains in DDD).
> They are NOT Jira Epics - Jira artifacts are created only in Phase 5 after re-assessment.

> **CRITICAL: Confluence First, Jira Later**
>
> This skill has FIVE phases with approval gates between them:
> - **Phase 1**: Elaborate stories and create Confluence pages (Overview → Units → Stories). **NO Jira creation.**
> - **Phase 2**: Team reviews in Confluence, adding inline and footer comments. *(Human activity)*
> - **Phase 3**: Comment resolution session - address feedback, update content, resolve comments.
> - **Phase 4**: Reorganization - regroup stories into units based on delivery needs.
> - **Phase 5**: Transfer to Jira - create sub-epics and stories, delete Confluence pages.
>
> **DO NOT** create Jira issues until Phase 5.
> **DO NOT** skip phases without explicit user approval.

## Example Invocations

- "Break down the authentication intent into stories and units"
- "Decompose the billing epic"
- "Create units and stories for the API migration intent"
- "Split the approved intent into work items"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for templates, Bolt guidance, subagent prompts, and Jira tool names.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Level 1 Intent document (ask for link)
   - Fetch using Atlassian MCP to confirm it exists

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Level 1 Intent" row shows "✅ Approved"

3. **If prerequisites incomplete**
   - Offer to run `/aidlc:intent` first if Confluence doc is missing or not approved
   - Or allow override with explicit confirmation (see Override Pattern in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md)

## Confluence Page Hierarchy

Stories are organized as a page hierarchy under the Level 1 Intent document:

```
Level 1 Intent Document (existing)
└── Units Overview (child of Intent)
    ├── Unit 1: [Name] (child of Overview)
    │   ├── Story 1.1 (child of Unit)
    │   ├── Story 1.2 (child of Unit)
    │   └── ...
    ├── Unit 2: [Name] (child of Overview)
    │   ├── Story 2.1 (child of Unit)
    │   └── ...
    └── ...
```

## Workflow

### Phase 1: Story Decomposition to Confluence

**In this phase, you will:**
- Read from Confluence and Jira (to understand the Intent)
- Spawn subagents to elaborate stories in parallel
- Create Confluence pages for Units Overview, Units, and Stories
- Discuss and refine with the user

**DO NOT in Phase 1:**
- Create any Jira issues (Sub-epics, Stories, Tasks, etc.)
- Update Jira labels or fields
- Modify Confluence workflow status

#### Step 1: Gather Context

Ask only for what is missing:
- Approved Confluence Level 1 doc link (this will be the parent for the Units Overview)
- Jira project key (for later transfer in Phase 5 - no default)
- Any known constraints, dependencies, or sequencing needs

#### Step 2: Identify Theme Clusters

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

#### Step 3: Spawn Story Elaboration Subagents

For each theme cluster, spawn a subagent using the Task tool:
- Use `subagent_type: "general-purpose"`
- Pass the condensed Intent context (not full documents)
- Use the Story Elaboration Subagent Prompt Template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md
- **Spawn all subagents in a single message** (parallel execution)

Each subagent will:
- Elaborate all stories for its assigned theme
- Return structured JSON with story content, risks, and dependencies
- Identify cross-cutting concerns that span themes

#### Step 4: Consolidate Subagent Results

After all subagents return:
1. Parse the JSON results from each subagent
2. Merge cross-cutting concerns into a unified risk list
3. Build a dependency graph across all stories
4. Surface any conflicts or gaps between themes

#### Step 5: Group Stories into Units

Organize the elaborated stories into cohesive Units:
- Start with theme boundaries as initial groupings
- Adjust based on dependency analysis (may merge or split themes)
- Apply loose coupling, high cohesion principles
- Each Unit should deliver independent value
- Surface dependencies between Units

#### Step 6: Plan Bolts

For each Unit, suggest rapid iteration cycles:
- Bolt boundaries based on testable increments
- Sequencing considerations
- See Bolt Planning Guidance in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

#### Step 7: Create Confluence Pages (Parallel)

Create the page hierarchy under the Level 1 Intent document using parallel sub-agents for efficiency.

**Phase A: Create Units Overview (sequential)**

1. **Create Units Overview page** (child of Level 1 Intent)
   - Use the Units Overview Template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md
   - Include: Intent name, Unit summary table, dependency graph, technical decisions, acceptance criteria
   - **This must complete first** to provide the parent page ID for Units

**Phase B: Create Unit + Stories (parallel, one agent per Unit)**

2. **Spawn one sub-agent per Unit** using the Task tool:
   - Use `subagent_type: "general-purpose"`
   - Pass the Units Overview page ID as the parent
   - Use the Confluence Page Creation Subagent Prompt Template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md
   - **Spawn all sub-agents in a single message** (parallel execution)

   Each sub-agent creates:
   - The Unit page (child of Units Overview)
   - All Story pages for that Unit (children of Unit page)
   - Uses Unit Page Template and Story Page Template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

3. **Consolidate sub-agent results**:
   - Collect all Unit page IDs and Story page IDs
   - Verify all pages were created successfully
   - Report any failures and offer to retry

#### Step 8: Request Review

Summarize the full decomposition:
- Stories grouped by Unit (with links to Confluence pages)
- Bolt plan per Unit
- Dependencies and risks

**Ask explicitly**: "The stories are now in Confluence for team review. Please add inline and footer comments, then return for comment resolution."

---

### ⛔ STOP — Review Gate

**Phase 1 is complete.** The team will now review the stories in Confluence.

**This is a human activity that happens outside of Claude.**

Team members should:
- Review each story page
- Add inline comments on specific text that needs clarification or changes
- Add footer comments for general feedback
- Reply to existing comments to discuss

**Wait for the user to return and request comment resolution before continuing to Phase 2.**

---

### Phase 2: Team Review in Confluence

*(Human activity - no Claude involvement)*

The team reviews stories in Confluence by:
- Adding **inline comments** on specific text selections
- Adding **footer comments** for general page feedback
- Replying to comments for discussion

---

### Phase 3: Comment Resolution

**This phase is typically run in a NEW Claude session after the team has completed their review.**

#### Step 9: Fetch All Comments

For each page (Units Overview, Unit pages, Story pages):
1. Fetch inline comments using `getConfluencePageInlineComments`
2. Fetch footer comments using `getConfluencePageFooterComments`
3. **Include replies** - comments have threaded replies that must be read

Present a summary of all comments organized by page.

#### Step 10: Address Feedback

For each comment:
1. Analyze the feedback and any reply thread
2. Determine the appropriate action:
   - Update story content if the feedback is valid
   - Clarify if the feedback is based on a misunderstanding
   - Escalate if the feedback requires a decision beyond scope

#### Step 11: Update Content

Update the Confluence pages to address feedback:
- Use `updateConfluencePage` to modify story content
- Ensure changes address the specific feedback

#### Step 12: Reply to Comments

Reply to each comment explaining how it was addressed:
- Use `createConfluenceInlineComment` (with `parentCommentId`) for inline comment replies
- Use `createConfluenceFooterComment` (with `parentCommentId`) for footer comment replies

#### Step 13: Mark Comments Resolved

After addressing feedback, comments should be marked as resolved.
Note: Confluence inline comments have a resolution status; footer comments are resolved by the reply thread.

---

### ⛔ STOP — Reorganization Gate

**Phase 3 is complete.** Before proceeding to design, the team may need to reorganize stories into different Units.

**Ask**: "Are you ready to proceed with the current Unit groupings, or do you need to reorganize stories first?"

---

### Phase 4: Unit Re-assessment and Reorganization

This phase applies domain knowledge and architectural principles to validate and refine Unit boundaries before proceeding to design.

#### Step 14: Apply Unit Re-assessment Criteria

Evaluate each Unit against these AI-DLC principles:

| Criterion | Question | Action if Failed |
|-----------|----------|------------------|
| **Domain Alignment** | Does each Unit map to a coherent subdomain? | Split or merge Units to align with domain boundaries |
| **Loose Coupling** | Are cross-Unit dependencies minimized? | Regroup stories to reduce dependencies |
| **High Cohesion** | Are related stories grouped together? | Move stories between Units |
| **Independent Value** | Can each Unit deliver value independently? | Ensure each Unit has a clear deliverable |
| **Parallel Execution** | Can Units be built in parallel by different teams? | Resolve blocking dependencies |

Present the re-assessment findings to the user:
- Which Units pass all criteria
- Which Units need adjustment and why
- Proposed regrouping (if any)

#### Step 15: Regroup into Units

If regrouping is needed based on re-assessment:
1. **Move story pages** between Unit pages (update parent page ID)
2. **Rename/repurpose Unit pages** where possible (avoid creating new pages unnecessarily)
3. **Create new Unit pages** only when necessary
4. **Archive Unit pages** that are no longer needed
5. **Document the rationale** for Unit boundaries in the Units Overview

#### Step 16: Update Units Overview

Update the Units Overview page to reflect the new groupings:
- Update the Unit summary table
- Update the dependency graph
- Update story counts
- Add "Unit Boundary Rationale" section documenting why Units are grouped this way

#### Step 17: Update Workflow Status

Update the Confluence Level 1 Intent page status table:
- Set "Unit Decomposition" row to "✅ Complete" with today's date
- Add note that Units are ready for design phase

#### Step 18: Chain to Design

Report back with:
- Summary of Units and their Stories (with Confluence links)
- Boundary rationale for each Unit
- Any cross-cutting concerns or dependencies

Ask whether to proceed with Domain Design for any Unit.
If yes, invoke `/aidlc:design` with the Unit context.

> **Note**: Jira transfer happens later in `/aidlc:verify` after design is complete and documentation has been verified.

## Workflow Chain

- **Previous**: `/aidlc:intent` (Level 1 Intent documentation)
- **Next**: `/aidlc:design` (Domain and Logical Design)

## Definition of Done

### Phase 1 (Confluence Pages Created)
- Theme clusters identified and confirmed with user
- Subagents spawned in parallel for story elaboration
- All subagent results consolidated
- Units Overview page created as child of Level 1 Intent
- Unit pages created as children of Units Overview
- Story pages created as children of their respective Units
- All pages include acceptance criteria, dependencies, risks
- Bolt plan suggested per Unit
- User notified to begin team review

### Phase 2 (Team Review)
- Team has reviewed all story pages in Confluence
- Inline and footer comments added
- Comment threads include replies/discussion

### Phase 3 (Comment Resolution)
- All comments fetched (inline + footer + replies)
- Story content updated to address feedback
- Replies posted explaining how feedback was addressed
- Comments marked as resolved

### Phase 4 (Unit Re-assessment and Reorganization)
- All Units evaluated against re-assessment criteria (domain alignment, loose coupling, high cohesion, independent value, parallel execution)
- Stories regrouped based on domain knowledge and architectural principles
- Story pages moved between Units as needed
- Unit pages renamed/repurposed (not duplicated)
- Units Overview updated with new groupings and boundary rationale
- Workflow status table updated in Confluence
- User informed that next step is `/aidlc:design`

> **Note**: Jira transfer (Sub-epics and Stories) happens later in `/aidlc:verify` after design and verification are complete.

## Troubleshooting

- **Too many Stories**: Consider splitting into multiple Units or deferring lower-priority Stories.
- **User wants to skip Confluence phase**: Allow override but recommend Confluence for team collaboration.
- **Subagent failure**: Report which theme cluster failed and offer to retry or elaborate manually.
- **Single theme identified**: Still spawn one subagent for consistency; workflow proceeds normally.
- **Comment resolution in same session**: If user wants to resolve comments immediately (no new session), proceed with Phase 3 in the current session.
- **Moving pages between Units**: Use `updateConfluencePage` with a new `parentId` to move story pages.
