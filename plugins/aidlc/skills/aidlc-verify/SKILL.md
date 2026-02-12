---
name: aidlc-verify
description: Verify documentation completeness and assess AI-execution confidence before transferring to Jira. Uses parallel sub-agents to review Intent, Units, Tasks, and Design docs. Refines Bolt groupings and transfers to Jira with proper hierarchy (Sub-epic → Story → Sub-task). (Triggers - verify docs, check readiness, transfer to jira, aidlc verify, ready for implementation, confidence check)
---

# AI-DLC Verify

Verify that all documentation (Intent, Units, Tasks, Design) is complete and provides sufficient context for AI tooling to execute successfully. Refine Bolt groupings and transfer to Jira only when confidence threshold is met.

## Completion Checklist

> **IMPORTANT**: Create tasks for each step at the start using `TodoWrite`. Mark tasks complete as you go using `TodoWrite`. Each task description should reference the corresponding Workflow step.

### Verification Phase

| # | Task | Depends On | Workflow Reference | Exit Criteria |
|---|------|------------|-------------------|---------------|
| 1 | Validate prerequisites | — | Prerequisites section | Units exist, decomposition complete |
| 2 | Fetch all documentation | 1 | Phase 1 > Step 2 | Intent, Units, Tasks, Design docs fetched |
| 3 | Spawn verification subagents | 2 | Phase 2 | One subagent per Unit launched |
| 4 | Consolidate results | 3 | Phase 3 | All scores calculated, gaps merged and ranked |
| 5 | Present assessment report | 4 | Phase 4 | Confidence score and gaps shown to user |
| 6 | Get decision from user | 5 | Phase 5 | User chooses: proceed / address gaps / cancel |

### Jira Transfer Phase (if approved)

| # | Task | Depends On | Workflow Reference | Exit Criteria |
|---|------|------------|-------------------|---------------|
| 7 | Confirm Jira transfer | 6 | Phase 6 > Step 1 | User confirms; Story Points field detected |
| 8 | Spawn task-creator agents | 7 | Phase 6 > Step 2b | N agents launched in parallel |
| 9 | Consolidate agent results | 8 | Phase 6 > Step 2c | Bolt map built, Story Points aggregated |
| 10 | Link Bolt dependencies | 9 | Phase 6 > Step 3 | Cross-Unit links created |
| 11 | Update Confluence | 10 | Phase 6 > Step 4 | Bolt Execution Plan backfilled |
| 12 | Update workflow status | 11 | Phase 6 > Step 5 | Status shows "Verification: ✅" |
| 13 | Delete Confluence pages | 12 | Phase 6 > Step 6 | Overview, Units, Tasks deleted |
| 14 | Report final results | 13 | Phase 6 > Step 7 | Aggregate results reported |

## Task Tracking

When this skill is invoked:

1. **Create tasks** for the Verification Phase checklist items using `TodoWrite`
   - Include a reference to the workflow step in the task description (content field)
   - Set activeForm appropriately (e.g., "Validating prerequisites" for content "Validate prerequisites")
   - Example: `"Validate prerequisites (See Prerequisites section)"`
2. **Mark task as in_progress** when starting each step using `TodoWrite` (update status)
3. **Mark task complete** when the exit criteria are met using `TodoWrite` (update status)
4. **If user approves transfer**, create tasks for the Jira Transfer Phase
5. **Verify all tasks complete** before finishing the skill

This ensures visibility into progress and prevents incomplete execution.

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI assesses** — Review all documentation and score confidence
2. **AI reports** — Present gaps and remediation suggestions
3. **Human decides** — Address gaps or approve transfer
4. **AI transfers** — Create Jira artifacts when confidence is sufficient

## Example Invocations

- "Verify the documentation is ready for implementation"
- "Check if we're ready to transfer to Jira"
- "Assess the confidence level for the authentication intent"
- "Are the units ready for AI execution?"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for templates, Jira tool names, and operational guidance.
- Use @${CLAUDE_PLUGIN_ROOT}/references/review-criteria.md for scoring rubrics, quality checklists, and confidence thresholds.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Intent document (ask for link)
   - Units Overview page with Unit and Task child pages
   - Proposed Bolt groupings (in Units Overview)
   - Design documentation (Domain model, ADRs) - optional but improves confidence
   - Fetch all using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Unit Decomposition" row shows "✅ Complete"
   - Check if "Domain Design" is complete (improves confidence score)

3. **If prerequisites incomplete**
   - Offer to run `/aidlc-design` first if design is missing
   - Offer to run `/aidlc-elaborate` if Units are missing
   - Or allow override with explicit confirmation (see Override Pattern in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md)

## Confidence Assessment Framework

### Scoring Categories

| Category | Weight | Summary |
|----------|--------|---------|
| **Intent Clarity** | 20% | Problem/scope/outcomes clearly defined |
| **Task Completeness** | 25% | All Tasks have testable acceptance criteria |
| **Design Readiness** | 25% | Domain model documented, patterns chosen |
| **NFR Coverage** | 15% | Measurable targets with baselines |
| **Dependency Mapping** | 15% | Integration points identified, sequencing clear |

Full rubric definitions, sub-agent scoring dimensions, and gap categories: review-criteria.md **Part 3.3**

### Confidence Thresholds

Thresholds are defined in review-criteria.md **Part 1.2**. In summary:

- **High (80-100%)**: Proceed to Jira transfer
- **Medium (60-79%)**: List gaps, ask targeted questions, allow override
- **Low (<60%)**: STOP — must gather more context before continuing

## Workflow

### Phase 1: Gather Artifacts

1. **Collect references**
   Ask only for what is missing:
   - Confluence Intent document link
   - Jira project key (for transfer)
   - Any design documentation links (optional)

2. **Collect Jira configuration**
   Ask only for what is needed for transfer:
   - **Project routing**: Confirm the primary Jira project key. Ask if multi-project routing is needed (e.g., frontend project and backend project). Sub-tasks inherit their parent Story's project.
   - **Team assignment**: Ask which team(s) will work on this. Single team = apply to all artifacts. Multiple teams = map teams to Units or individual Bolts.

3. **Fetch all documentation**
   - Read Intent document
   - Read Units Overview page (including Proposed Bolts section)
   - Read all Unit pages and their Task child pages
   - Read Design documents if available (Domain model, ADRs)

### Phase 2: Spawn Verification Sub-agents

Spawn parallel sub-agents (one per Unit) to assess documentation quality.

Use `subagent_type: "doc-verifier"` (aidlc plugin agent) for each Unit.

**Pass to each sub-agent:**

- Unit page content
- Task pages content for this Unit
- Design documents (if available): Domain model, ADRs
- Intent context: Relevant sections from Level 1 Intent

The `doc-verifier` agent will score each criterion and return JSON with scores, gaps, strengths, and overall confidence.

### Phase 3: Consolidate Results

After all sub-agents return:

1. **Parse JSON results** from each sub-agent
2. **Calculate weighted score** using the category weights
3. **Merge gap lists** across all Units
4. **Identify cross-cutting gaps** that affect multiple Units
5. **Rank gaps by impact** (blocking issues first)
6. **Generate Bolt Execution Plan**:
   1. Collect all bolt groupings across all Units (from sub-agent results and Units Overview)
   2. Identify bolt-to-bolt dependencies (data, interface, infrastructure) using sub-agent `bolt_dependencies` data
   3. Assign **Phases** (sequential stages): Phase 0 = foundation/setup, then increasing phases for dependent work
   4. Assign **Lanes** within each phase (parallel slots): independent bolts in same phase get different lanes
   5. Identify **Critical Path** (longest dependency chain by estimated duration)
   6. Calculate **Parallelism Opportunities** (max parallel bolts per phase, teams needed)
   7. Generate the **Visual Summary** (ASCII phase/lane diagram)
   8. Flag circular dependencies as blocking gaps
   9. Assess bolt sizing (flag < 2 hours or > 3 days)

   Output: Full Bolt Execution Plan using the template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

### Phase 4: Present Assessment

Present the confidence assessment to the user:

```markdown
## Confidence Assessment Report

### Overall Confidence: XX%

| Unit | Scope | Tasks | Technical | NFRs | Dependencies | Bolts | Score |
|------|-------|-------|-----------|------|--------------|-------|-------|
| Unit 1 | 85 | 90 | 70 | 60 | 80 | 75 | 77% |
| Unit 2 | 90 | 85 | 85 | 75 | 90 | 85 | 85% |
| **Weighted Average** | | | | | | | **81%** |

### Gaps Identified

**High Priority (blocking):**
1. [Unit 1] Task "User Login" missing acceptance criteria
   - Suggestion: Add testable conditions for success/failure

**Medium Priority:**
2. [Unit 1] NFR "performance" lacks specific target
   - Suggestion: Define response time target (e.g., <200ms p95)

### Bolt Execution Plan

#### Phase 0: Foundation
| Lane | Bolt | Unit | Summary | Depends On |
|------|------|------|---------|------------|
| A | Bolt 1.1 | Unit 1 | ... | — |
| B | Bolt 2.1 | Unit 2 | ... | — |

#### Phase 1: Core Domain
| Lane | Bolt | Unit | Summary | Depends On |
|------|------|------|---------|------------|
| A | Bolt 1.2 | Unit 1 | ... | Bolt 1.1 |

#### Critical Path
`Bolt 1.1 → Bolt 1.2 → ...` (X days)

#### Parallelism Opportunities
| Phase | Max Parallel Bolts | Teams Needed |
|-------|-------------------|--------------|
| Phase 0 | 2 | 2 |
| Phase 1 | 1 | 1 |

#### Visual Summary
Phase 0:  [Bolt 1.1]  [Bolt 2.1]
              ↓
Phase 1:  [Bolt 1.2]
              ...

#### Recommendations
1. Start with Phase 0 — foundation bolts unblock everything
2. Critical path bottleneck: [specific bolt]

### Bolt Refinements Needed

1. [Unit 1] Bolt "Auth Flow" contains unrelated Tasks
   - Suggestion: Move Task 3 to a separate Bolt

### Strengths
- Clear scope boundaries across all Units
- Dependencies well-documented
- Tasks follow proper format

### Recommendation

[Based on score: proceed / address gaps / gather more context]
```

### Phase 5: Decision Gate

Based on confidence level:

**If High (≥80%):**
```
Confidence is HIGH (XX%). Ready to proceed with Jira transfer.

Bolt Execution Plan: X phases, critical path = X days
Project routing: PROJ (+ FRONT if multi-project)
Team assignment: [Team Name(s)]
Bolt dependencies to link: X

Do you want to:
1. Proceed with Jira transfer
2. Address gaps first anyway
3. Adjust project/team routing
4. Cancel
```

**If Medium (60-79%):**
```
Confidence is MEDIUM (XX%). Some gaps identified.

Bolt Execution Plan: X phases, critical path = X days
Project routing: PROJ (+ FRONT if multi-project)
Team assignment: [Team Name(s)]
Bolt dependencies to link: X

Gaps to address:
- [List top 3 gaps]

Do you want to:
1. Address gaps first (recommended)
2. Proceed anyway (override)
3. Adjust project/team routing
4. Cancel
```

**If Low (<60%):**
```
Confidence is LOW (XX%). Significant gaps prevent reliable AI execution.

Critical gaps:
- [List blocking gaps]

Recommended actions:
1. Run `/aidlc-design` if design is missing
2. Update Tasks with missing acceptance criteria
3. Define measurable NFRs
4. Refine Bolt groupings if needed

Cannot proceed to Jira transfer until confidence reaches 60%.
```

### Phase 6: Jira Transfer (if approved)

This phase creates Jira artifacts from the verified Confluence documentation using the AI-DLC hierarchy:

```
Epic (Intent)
├── Sub-epic (Unit)
│   ├── Story (Bolt) ← Groups related Tasks
│   │   ├── Sub-task (Task)
│   │   ├── Sub-task (Task)
│   └── Story (Bolt)
│       └── Sub-task (Task)
└── Sub-epic (Unit)
    └── Story (Bolt)
        └── Sub-task (Task)
```

#### Step 1: Confirm Jira Transfer

Confirm the user is ready:
- Remind them of the Jira hierarchy: Intent → Epic, Units → Sub-epics, Bolts → Stories, Tasks → Sub-tasks
- Confirm the Bolt Execution Plan (phases, lanes, critical path)
- Confirm project keys and multi-project routing (if applicable)
- Confirm team assignments
- Show the number of dependency links that will be created
- Confirm the refined Bolt groupings are final

#### Step 1a: Detect Story Points Field

Attempt to find the Story Points field for sub-tasks in the target Jira project:

**Primary approach (acli):**
```bash
# Get any existing issue to discover fields
acli jira workitem search --project "PROJ" --limit 1 --json
# Extract issue key from results
acli jira workitem fields PROJ-123 --json
```

Parse JSON output for fields matching:
- Name patterns: `/story[\s_-]*point/i`, `/estimate/i`
- Field type: numeric
- Common field IDs: `customfield_10016`, `customfield_10026`, `customfield_10000`

**Fallback approach (Atlassian MCP):**
```javascript
// If acli unavailable
getJiraProjectIssueTypesMetadata({
  cloudId: "<cloud-id>",
  projectIdOrKey: "PROJ"
})
// Find Sub-task issue type ID

getJiraIssueTypeMetaWithFields({
  cloudId: "<cloud-id>",
  projectIdOrKey: "PROJ",
  issueTypeId: "<sub-task-type-id>"
})
// Filter for schema.type === "number" and name matching patterns
```

**Outcomes:**
- ✅ Field found: Store field name/ID for sub-task creation
  - Inform user: "✓ Story Points field detected: [field-name]"
- ⚠️ Field not found: Continue without Story Points
  - Inform user: "⚠️ Story Points field not configured in project"
  - Note in final report under recommendations

**Store for session:** Field name or ID (e.g., `"Story Points"` or `"customfield_10016"`)

#### Step 2: Create Jira Artifacts

**Preferred: Use `acli` CLI** (lower token usage than Atlassian MCP):

```bash
# First check acli is installed
which acli || echo "acli not installed - see: https://developer.atlassian.com/cloud/acli/"
```

**Step 2a: Create Epic (Intent)**

Create the parent Epic that will group all Units:

```bash
# Create Epic for the Intent
acli jira workitem create --project "PROJ" --type "Epic" \
  --summary "<Intent Name>" \
  --description-file intent-epic.md \
  --label "aidlc:intent" \
  --json
```

The Epic description should include:
- Intent Summary (from Confluence)
- Problem/Opportunity (condensed)
- Target Users
- Outcomes (business + user)
- Scope Summary
- NFRs table
- Top risks
- Measurement criteria
- **Link to full Intent Confluence doc**

Use the Jira Epic (Intent) Template from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

Save the Epic key (e.g., PROJ-100) for linking Sub-epics.

**Step 2b: Spawn Task-Creator Agents (PARALLEL)**

For each Unit, spawn a task-creator agent to create all Jira artifacts (Sub-epic → Stories → Sub-tasks) for that Unit in parallel.

**Prepare input for each agent:**

1. **Fetch Unit content:**
   - Read the Unit's Confluence page
   - Store full markdown content

2. **Fetch all Task pages for this Unit:**
   - Query Confluence for all Task pages under this Unit
   - Store each Task's title and full markdown content

3. **Extract Bolt metadata from Bolt Execution Plan:**
   - Filter Bolts for current Unit: `WHERE unit == current_unit_name`
   - For each Bolt, collect:
     - `bolt_name` (e.g., "Bolt 1.1: Login Flow")
     - `project_key` (from multi-project routing if configured, else primary project)
     - `phase` (execution phase number)
     - `lane` (parallel lane identifier)
     - `team` (optional team assignment)
     - `depends_on` (array of Bolt names this Bolt depends on)
     - `estimated_duration` (e.g., "2 days")
     - `on_critical_path` (boolean)
     - `tasks` (array of Task titles in this Bolt)

4. **Pass Story Points field config:**
   - Field name and ID from Step 1a (or `null` if not detected)

5. **Pass Epic Jira key:**
   - Epic key created in Step 2a

6. **Pass Atlassian credentials:**
   - `cloud_id` and optional `region_url`

**Spawn all agents in parallel:**

```
Use Task tool with subagent_type="task-creator" (AIDLC plugin agent) for each Unit.

Spawn ALL agents in a single Task tool call with multiple agents (parallel execution).
```

**Agent input schema:**

```json
{
  "unit": {
    "name": "User Authentication",
    "confluence_content": "<full Unit page markdown>",
    "epic_jira_key": "PROJ-100",
    "primary_project_key": "PROJ"
  },
  "bolts": [
    {
      "bolt_name": "Bolt 1.1: Login Flow",
      "project_key": "PROJ",
      "phase": 0,
      "lane": "A",
      "team": "Backend Team",
      "depends_on": [],
      "estimated_duration": "2 days",
      "on_critical_path": true,
      "tasks": ["Implement password validation", "Add login API"]
    }
  ],
  "tasks": [
    {
      "task_title": "Implement password validation",
      "confluence_content": "<full Task page markdown>"
    }
  ],
  "story_points_field": {
    "field_name": "Story Points",
    "field_id": "customfield_10016"
  },
  "cloud_id": "<atlassian-cloud-id>",
  "region_url": "https://us.sentry.io"
}
```

**Wait for all agents to complete** before proceeding to Step 2c.

**Step 2c: Consolidate Agent Results**

After all task-creator agents return, consolidate their results:

1. **Parse JSON results** from each agent

   Each agent returns:
   ```json
   {
     "unit_name": "User Authentication",
     "unit_jira_key": "PROJ-123",
     "unit_url": "https://jira.../PROJ-123",
     "bolts": [
       {
         "bolt_name": "Bolt 1.1: Login Flow",
         "story_jira_key": "PROJ-124",
         "story_url": "https://jira.../PROJ-124",
         "project_key": "PROJ",
         "phase": 0,
         "lane": "A",
         "team": "Backend Team",
         "depends_on": ["Bolt 1.2"],
         "on_critical_path": true,
         "tasks": [
           {
             "task_name": "Implement password validation",
             "subtask_jira_key": "PROJ-125",
             "subtask_url": "https://jira.../PROJ-125",
             "story_points": 5,
             "story_points_applied": true
           }
         ]
       }
     ],
     "story_points_summary": {
       "total_points": 42,
       "task_count": 8,
       "average_points": 5.25,
       "distribution": {"3": 2, "5": 4, "8": 1, "13": 1},
       "large_tasks": [
         {"key": "PROJ-130", "points": 13, "title": "Complex auth flow"}
       ]
     },
     "errors": []
   }
   ```

2. **Build bolt_name → story_key map** for dependency linking:

   Iterate through all agents' results and collect:
   ```json
   {
     "Bolt 1.1": {
       "story_key": "PROJ-124",
       "depends_on": []
     },
     "Bolt 1.2": {
       "story_key": "PROJ-128",
       "depends_on": ["Bolt 1.1"]
     },
     "Bolt 2.1": {
       "story_key": "PROJ-135",
       "depends_on": ["Bolt 1.1", "Bolt 1.2"]
     }
   }
   ```

3. **Aggregate Story Points** across all Units:

   - `total_points`: Sum of all Units' `story_points_summary.total_points`
   - `task_count`: Sum of all Units' `story_points_summary.task_count`
   - `average_points`: `total_points / task_count`
   - `distribution`: Merge all Units' distributions
   - `large_tasks`: Concatenate all Units' `large_tasks` arrays

4. **Collect errors** from all agents:

   Group by error type:
   - Unit-level failures (agent aborted)
   - Story creation failures
   - Sub-task creation failures
   - Story Points write failures

5. **Report partial success** if any agents failed:

   Example:
   ```
   ✅ Successfully created artifacts for Units: 1, 2, 4, 5
   ❌ Failed for Unit: 3 (error: API timeout)

   Retry Unit 3? (y/n)
   ```

**Validation:**
- Verify all Units have `unit_jira_key` (or are in errors)
- Verify bolt_name → story_key map is complete
- Check for duplicate Bolt names (should not happen)

**Store for Step 3:** bolt_name → story_key map
**Store for Step 4:** Aggregated Bolt metadata with Jira keys
**Store for Step 7:** Aggregate Story Points summary and errors

#### Step 3: Link Bolt Dependencies

Use the bolt_name → story_key map from Step 2c to create dependency links between Stories:

1. **Iterate through bolt_name → story_key map**

   For each Bolt with non-empty `depends_on` array:

2. **Lookup Jira keys:**
   - Current Bolt: `bolt_name → story_key` (e.g., "Bolt 1.2" → "PROJ-456")
   - Each dependency: `depends_on[i] → story_key` (e.g., "Bolt 1.1" → "PROJ-455")

3. **Create link for each dependency:**

   ```bash
   # Bolt 1.2 (PROJ-456) is blocked by Bolt 1.1 (PROJ-455):
   acli jira workitem link PROJ-456 PROJ-455 --link-type "blocks"
   ```

   **Link type:** "blocks" (the dependency blocks the current Bolt)

4. **Verify links were created:**

   Optional verification:
   ```bash
   acli jira workitem view PROJ-456 --fields "issuelinks" --json
   ```

5. **Handle cross-project dependencies:**

   Links work across projects (no special handling needed)

**Fallback:** If `acli` is not available or linking fails, dependencies are already documented in each Story's description by the task-creator agents:
```
**Blocked by:** Bolt 1.1 (Jira key will be linked by parent agent)
```

Update these descriptions with actual Jira keys:
```
**Blocked by:** PROJ-455 (Bolt 1.1)
```

#### Step 4: Update Bolt Execution Plan in Confluence

Backfill the Bolt Execution Plan on the Units Overview page with created Jira Story keys from Step 2c:

1. **Read the Units Overview page** (contains Bolt Execution Plan table)

2. **Parse existing plan table** to locate each Bolt row

3. **Lookup Jira Story keys** from consolidated results (bolt_name → story_key map)

4. **Update table** with Jira keys:

   | Lane | Bolt | Unit | Summary | Depends On | Jira Story |
   |------|------|------|---------|------------|------------|
   | A | Bolt 1.1 | Unit 1 | ... | — | [PROJ-455](https://jira.../PROJ-455) |
   | B | Bolt 2.1 | Unit 2 | ... | Bolt 1.1 | [PROJ-458](https://jira.../PROJ-458) |

5. **Update Confluence page** using `updateConfluencePage` tool

**Result:** Bolt Execution Plan becomes a live reference with clickable links to Jira Stories.

#### Step 5: Update Workflow Status

Update the Confluence Intent page status table:
- Set "Verification" row to "✅ Complete" with today's date
- Add links to created Sub-epics in the Artifact column

#### Step 6: Delete Confluence Task Pages

After successful Jira creation, delete the Confluence pages to avoid confusion:
- Delete all Task pages
- Delete all Unit pages
- Delete the Units Overview page

**Important**: Keep the Intent document and Design documents — only delete the decomposition pages.

#### Step 7: Report Back

Provide aggregate results from all task-creator agents:

**Created Jira Artifacts:**
- **Epic (Intent):** [PROJ-100](https://jira.../PROJ-100) "<Intent Name>"
- **Sub-epics (Units):** X Units created
  - Unit 1: [PROJ-123](https://jira.../PROJ-123)
  - Unit 2: [PROJ-135](https://jira.../PROJ-135)
  - ...
- **Stories (Bolts):** X Bolts created across Y projects
  - Example: [PROJ-124](https://jira.../PROJ-124) "Bolt 1.1: Login Flow"
- **Sub-tasks (Tasks):** X Tasks created

**Aggregate Story Points Summary (if field detected):**
- **Total points:** XX points across YY sub-tasks (all Units)
- **Average per sub-task:** X.X points
- **Distribution:** X tasks @ 3pts, X @ 5pts, X @ 8pts, X @ 13pts
- **⚠️ Large tasks (13+ points):** [PROJ-789 (13pts), PROJ-790 (21pts)]
  - Recommendation: Consider splitting these tasks in future iterations or during implementation

**If Story Points field not detected:**
- ⚠️ Story Points field not configured in project PROJ
- Recommendation: Configure Story Points field in Jira project settings → Issue Types → Sub-task → Fields

**Errors (if any):**

- **Unit-level errors (agent failures):**
  - Unit 3 (User Authentication): API timeout during Sub-epic creation
  - Action: Retry agent for Unit 3, or create manually

- **Story/Sub-task creation failures:**
  - X Stories failed to create (see errors array)
  - Y Sub-tasks failed to create (see errors array)

- **Story Points write failures:**
  - Z Sub-tasks created without Story Points (field not writable)
  - Recommendation: Check Jira field permissions

**Bolt Execution Plan:**
- **Phases:** X phases identified
- **Critical path:** Bolts X.X → Y.Y → Z.Z (estimated XX days)
- **Parallelism:** Up to Y teams can work in parallel during Phase Z
- **Updated in Confluence:** Bolt Execution Plan table backfilled with Jira Story keys

**Dependency Links:**
- **Created:** X dependency links between Bolts
- **Examples:**
  - PROJ-456 (Bolt 1.2) blocked by PROJ-455 (Bolt 1.1)
  - PROJ-460 (Bolt 2.2) blocked by PROJ-458 (Bolt 2.1)

**Team/Project Routing:**
- **Projects:** Artifacts created in X projects (PROJ, FRONT, API, etc.)
- **Teams:** Y teams assigned to Bolts (Backend Team, Frontend Team, etc.)

**Execution Order Recommendation:**
- Start with Phase 0 Bolts (no dependencies)
- Lanes A, B, C can execute in parallel
- Phase 1 begins after all Phase 0 Bolts complete
- Follow critical path to minimize overall duration

**Confluence Cleanup:**
- ✅ Units Overview page deleted
- ✅ All Unit pages deleted (X pages)
- ✅ All Task pages deleted (Y pages)
- ✅ Intent page status table updated to "Verification: ✅ Complete"

**Final Confidence Score:** X.XX / 5.00 (for reference)

**Next Steps:**
1. Review Jira Epic and Sub-epics to verify completeness
2. Assign Bolts to teams based on Lane assignments
3. Begin implementation starting with Phase 0
4. Use `/aidlc-bolt` to guide TDD implementation of each Bolt

## Workflow Chain

- **Previous**: `/aidlc-design` (Domain and Logical Design)
- **Next**: Implementation

## Definition of Done

### Verification Complete
- All Units assessed by verification sub-agents
- Confidence score calculated with weighted average
- Gaps identified and categorized
- Bolt groupings reviewed and refined
- Bolt Execution Plan generated with phases, lanes, critical path
- Parallelism opportunities documented (teams per phase)
- Bolt sizing validated (2h-3d range)
- Circular dependencies flagged
- Assessment report presented to user

### Jira Transfer Complete (if approved)
- Intent created as Epic with `aidlc:intent` label
- One task-creator agent spawned per Unit (parallel execution)
- Units created as Sub-epics linked to the Intent Epic with `aidlc:unit` label
- Bolts created as Stories under their respective Sub-epics with `aidlc:bolt` label
- Tasks created as Sub-tasks under their respective Bolts/Stories
- Story Points field detected (or gracefully handled if missing)
- Tasks scored using Fibonacci scale (1, 2, 3, 5, 8, 13, 21+)
- Story Points applied to sub-tasks (if field configured)
- Large tasks (13+) flagged in aggregate report
- Story Points aggregated across all Units in final report
- All acceptance criteria and test notes transferred completely to Sub-tasks
- Bolt-to-bolt dependency links created across Units ("blocks"/"is blocked by")
- Team assignments applied (if configured)
- Multi-project routing applied (if configured)
- ADR and design doc links included in Sub-epic descriptions
- Design label added if design exists (`aidlc:designed`)
- Bolt Execution Plan updated with Jira Story keys in Confluence
- Agent errors collected and reported
- Partial success handled (some Units succeed, some fail)
- Confluence decomposition pages deleted (Overview, Units, Tasks)
- Intent page status table updated

## Troubleshooting

- **Sub-epic not supported**: Use Epic + issue links or parent field; ask for preferred structure.
- **Story type not available**: Some projects may use different names (Task, Issue); use `getJiraProjectIssueTypesMetadata` to find the right type for Bolts.
- **Sub-task not supported**: Use Story with parent link or issue links instead.
- **Missing issue types**: Use `getJiraProjectIssueTypesMetadata` and confirm available types.
- **Low confidence score**: Guide user to address specific gaps; offer to re-run verification after updates.
- **Sub-agent failure**: Report which Unit verification failed and offer to retry or assess manually.
- **Confluence page deletion fails**: Verify permissions; may need admin to delete pages.
- **Design missing**: Confidence will be lower; recommend running `/aidlc-design` first but allow override.
- **User wants to skip verification**: Allow with explicit confirmation, but warn that AI execution quality may suffer.
- **Bolt groupings unclear**: Review proposed Bolts in Units Overview; may need to regroup Tasks before transfer.
- **Tasks span multiple Bolts**: Each Task should belong to exactly one Bolt; resolve before Jira transfer.
- **`acli` not installed for linking**: Document dependencies in Story descriptions instead; instruct user to manually create links later.
- **Team field not found in Jira**: Use `acli jira workitem fields PROJ-123` to discover the correct field name for team assignment.
- **Cross-project Sub-tasks**: Jira constraint — Sub-tasks must be in the same project as their parent Story. Route at the Story (Bolt) level, not Sub-task level.
- **Circular bolt dependencies detected**: Flag as blocking gap. Must restructure into a DAG (directed acyclic graph) before transfer.
- **Too many phases in execution plan**: Consolidate phases where bolts have no actual inter-phase dependencies.
- **Single lane per phase (no parallelism)**: Flag for team to consider splitting bolts or adjusting dependencies to enable parallel work.
- **Story Points field not found**: Cause: Jira project doesn't have Story Points field configured. Resolution: Workflow continues without Story Points. Recommend team enable Story Points field in project settings. Check: Use Jira admin interface → Project Settings → Issue Types → Sub-task → Fields
- **Story Points field is read-only**: Cause: Jira permissions or field configuration. Resolution: Sub-tasks created without Story Points. Recommend manual addition or permission update.
- **Story Points value rejected**: Cause: Jira field validation rules (e.g., only allows 0.5, 1, 2, 3, 5, 8, 13). Resolution: Use default value 5 or skip Story Points for that task. Check: Verify field configuration allows Fibonacci values (1, 2, 3, 5, 8, 13, 21)
- **Unit-creator agent fails entirely**: Cause: Critical error (Sub-epic creation failed). Resolution: Retry agent for that Unit only. Other Units' artifacts are preserved. Check agent error output for specific failure reason (API timeout, permissions, invalid parent Epic key).
- **Partial Unit success**: Cause: Some Bolts/Tasks created, others failed during agent execution. Resolution: Partial Jira artifacts exist for this Unit. Manual creation needed for failed items. Check `errors` array in agent output to identify failed Stories/Sub-tasks. Query Jira: `labels = aidlc:unit AND parent = PROJ-100` to see what was created.
- **Agent timeout**: Cause: Large Unit with 50+ Tasks, network latency, or Jira API rate limiting. Resolution: Retry agent with same Epic parent key. Duplicate detection: Check for existing Sub-epic with `aidlc:unit` label and matching Epic parent before creating. If Sub-epic exists, skip Sub-epic creation and resume at Story creation.
- **Bolt dependency linking fails**: Cause: `acli` not installed, network issue, or invalid Story keys in bolt map. Resolution: Dependencies already documented in Story descriptions by agents ("Blocked by: Bolt 1.1"). Manually create links later using Jira Query: `labels = aidlc:bolt` to find all Bolt Stories, then use UI or `acli jira workitem link` to create links.
