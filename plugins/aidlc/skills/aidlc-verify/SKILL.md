---
name: aidlc-verify
description: Verify documentation completeness and assess AI-execution confidence before transferring to Jira. Uses parallel sub-agents to review Intent, Units, Tasks, and Design docs. Refines Bolt groupings and transfers to Jira with proper hierarchy (Sub-epic → Story → Sub-task). (Triggers - verify docs, check readiness, transfer to jira, aidlc verify, ready for implementation, confidence check)
---

# AI-DLC Verify

Verify that all documentation (Intent, Units, Tasks, Design) is complete and provides sufficient context for AI tooling to execute successfully. Refine Bolt groupings and transfer to Jira only when confidence threshold is met.

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

**When constructing the sub-agent prompt:** Read review-criteria.md and inject the Verification Readiness Rubric (Part 3.3) and Shared Quality Checklists (Part 2) into the Scoring Instructions section below.

**Sub-agent Prompt Template:**

```markdown
Review the following Unit documentation for AI-execution readiness.

## Unit: <Unit Name>
<Unit page content>

## Tasks
<Task pages content for this Unit>

## Proposed Bolts
<Bolt groupings from Units Overview for this Unit>

## Design Documents (if available)
<Domain model, ADRs relevant to this Unit>

## Intent Context
<Relevant sections from Intent>

## Scoring Instructions

Rate each dimension 0-100:

1. **Scope Clarity** — Is the Unit scope bounded with specific, measurable deliverables?
2. **Task Quality** — Do all Tasks have testable acceptance criteria in proper format?
3. **Technical Readiness** — Are integration points, data models, and error handling documented?
4. **NFR Specificity** — Are performance, security, and availability targets measurable?
5. **Dependency Clarity** — Are blockers, prerequisites, and sequencing documented?
6. **Bolt Grouping Quality** — Are Tasks grouped into cohesive Bolts with clear scope? Are bolt-to-bolt dependencies explicitly identified? Is each Bolt appropriately sized (2h-3d)?

[Inject: Verification Readiness Rubric details (Part 3.3) and Shared Quality Checklists (Part 2) from review-criteria.md]

## Return Format

Return your assessment as JSON:

{
  "unit": "<unit name>",
  "scores": {
    "scope_clarity": <0-100>,
    "task_quality": <0-100>,
    "technical_readiness": <0-100>,
    "nfr_specificity": <0-100>,
    "dependency_clarity": <0-100>,
    "bolt_grouping": <0-100>
  },
  "gaps": [
    {
      "category": "<scope_clarity|task_quality|technical_readiness|nfr_specificity|dependency_clarity|bolt_grouping>",
      "issue": "<specific gap description>",
      "location": "<Task title or section>",
      "suggestion": "<how to fix>"
    }
  ],
  "bolt_refinements": [
    {
      "current_bolt": "<Bolt name>",
      "issue": "<problem with current grouping>",
      "suggestion": "<recommended adjustment>"
    }
  ],
  "bolt_dependencies": [
    {
      "bolt": "<Bolt name>",
      "depends_on": ["<Bolt name>"],
      "dependency_type": "data|interface|infrastructure",
      "rationale": "<why this dependency exists>"
    }
  ],
  "strengths": [
    "<well-documented aspect>"
  ],
  "overall_confidence": <0-100>
}
```

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
Sub-epic (Unit)
├── Story (Bolt) ← Groups related Tasks
│   ├── Sub-task (Task)
│   ├── Sub-task (Task)
└── Story (Bolt)
    └── Sub-task (Task)
```

#### Step 1: Confirm Jira Transfer

Confirm the user is ready:
- Remind them of the Jira hierarchy: Units → Sub-epics, Bolts → Stories, Tasks → Sub-tasks
- Confirm the Bolt Execution Plan (phases, lanes, critical path)
- Confirm project keys and multi-project routing (if applicable)
- Confirm team assignments
- Show the number of dependency links that will be created
- Confirm the refined Bolt groupings are final

#### Step 2: Create Jira Artifacts

**Preferred: Use `acli` CLI** (lower token usage than Atlassian MCP):

```bash
# First check acli is installed
which acli || echo "acli not installed - see: https://developer.atlassian.com/cloud/acli/"
```

**Step 2a: Create Sub-epics (Units)**

For each Unit:
- Summary: Unit page title
- Description: Unit page content including:
  - Scope summary and acceptance criteria
  - NFRs, risks, dependencies
  - ADR links/references (if design documentation exists)
  - Design document links (domain model, context maps)
  - Link to Intent Confluence doc
- Label: `aidlc:unit`
- If design exists, add label: `aidlc:designed`
- Team field: Set if team assignment was configured

```bash
acli jira workitem create --project "PROJ" --type "Sub-epic" \
  --summary "Unit: [Name]" \
  --description-file unit-description.md \
  --label "aidlc:unit" \
  --json
# Set team if configured
acli jira workitem edit PROJ-123 --field "Team" --value "Team Name"
```

**Step 2b: Create Stories (Bolts)**

For each Bolt, create in the correct project (respecting multi-project routing):
- Summary: Bolt name/description from Units Overview
- Description: Include:
  - Scope summary (what this Bolt delivers)
  - Phase and Lane assignment (e.g., "Phase 1, Lane A")
  - Tasks included (list of child sub-tasks)
  - Dependencies (other Bolts — blocks/blocked by)
  - Whether on the critical path (yes/no)
  - Team assignment (if specified)
  - Estimated duration
- Parent: The Unit's Sub-epic
- Label: `aidlc:bolt`

```bash
acli jira workitem create --project "PROJ" --type "Story" \
  --summary "Bolt: [Description]" \
  --description-file bolt-description.md \
  --parent "PROJ-123" \
  --label "aidlc:bolt" \
  --json
```

**Step 2c: Create Sub-tasks (Tasks)**

For each Task, ensure **complete information transfer**:
- Summary: Task page title
- Description: Full Task content including:
  - User story (As a... I want... So that...)
  - **ALL** acceptance criteria (every checkbox — do not summarize or omit any)
  - Context section
  - Dependencies with references
  - Risks
  - **Test notes** (all test scenarios from the Task page)
- Parent: The Bolt's Story (inherits project from parent)

```bash
acli jira workitem create --project "PROJ" --type "Sub-task" \
  --summary "[Task Title]" \
  --description-file task-description.md \
  --parent "PROJ-456"
```

Use templates in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

#### Step 3: Link Bolt Dependencies

After all Bolts are created, use the Bolt Execution Plan to create dependency links between Stories:

1. Map bolt names to their Jira Story keys (from Step 2b output)
2. Iterate through all "Depends On" entries in the execution plan
3. For each dependency, create a link:

```bash
# For each dependency in the execution plan:
# Bolt 1.2 (PROJ-456) is blocked by Bolt 1.1 (PROJ-455):
acli jira workitem link PROJ-456 PROJ-455 --link-type "blocks"
```

4. Verify links were created successfully

**Fallback**: If `acli` is not available or linking fails, document all dependencies in each Story's description with the format:
```
**Blocked by:** PROJ-455 (Bolt 1.1)
**Blocks:** PROJ-460 (Bolt 2.2)
```

#### Step 4: Update Bolt Execution Plan in Confluence

Backfill the Bolt Execution Plan on the Units Overview page with created Jira Story keys:

| Lane | Bolt | Unit | Summary | Depends On | Jira Story |
|------|------|------|---------|------------|------------|
| A | Bolt 1.1 | Unit 1 | ... | — | PROJ-455 |
| B | Bolt 2.1 | Unit 2 | ... | — | PROJ-458 |

This makes the Confluence plan a live reference with links to Jira.

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

Provide:
- Created Jira keys (Sub-epics, Stories/Bolts, Sub-tasks/Tasks)
- Links to the Jira artifacts
- Bolt Execution Plan summary (phases, critical path duration)
- Dependency links created (count + list of linked pairs)
- Team/project routing applied (which teams, which projects)
- Execution order recommendation (start with Phase 0, then Phase 1, etc.)
- Confirmation that Confluence pages have been cleaned up
- Final confidence score for reference

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
- Units created as Sub-epics with `aidlc:unit` label
- Bolts created as Stories under their respective Sub-epics with `aidlc:bolt` label
- Tasks created as Sub-tasks under their respective Bolts/Stories
- All acceptance criteria and test notes transferred completely to Sub-tasks
- Bolt-to-bolt dependency links created ("blocks"/"is blocked by")
- Team field set on all artifacts (if configured)
- Multi-project routing applied (if configured)
- ADR and design doc links included in Sub-epic descriptions
- Design label added if design exists (`aidlc:designed`)
- Bolt Execution Plan updated with Jira Story keys in Confluence
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
