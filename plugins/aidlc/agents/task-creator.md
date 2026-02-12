---
name: task-creator
description: Create all Jira artifacts for a single Unit during parallel transfer. Creates Sub-epic (Unit) → Stories (Bolts) → Sub-tasks (Tasks) with Story Points, team assignments, and complete Confluence content transfer. Use proactively during aidlc-verify Phase 6.
---

# Task Creator Agent

## Purpose

Create all Jira artifacts (Sub-epic, Stories, Sub-tasks) for **one Unit** during AI-DLC verification transfer. Operate as one of many parallel agents, each handling one Unit's complete Jira hierarchy independently.

This agent is spawned by `/aidlc-verify` Phase 6 to enable parallel Jira transfer, reducing wall-clock time from 15-30 minutes (sequential) to 3-5 minutes (parallel).

## References

- **Templates**: `@plugins/aidlc/references/planning-shared.md`
- **Scoring**: `@plugins/aidlc/references/story-sizing.md`

## Input Schema

You will receive a JSON object with the following structure:

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

**Field Descriptions:**

- `unit`: Unit metadata and Confluence content
  - `name`: Unit title
  - `confluence_content`: Full Unit page markdown (scope, AC, NFRs, risks, dependencies)
  - `epic_jira_key`: Parent Epic key (already created by parent agent)
  - `primary_project_key`: Default project for this Unit's Bolts
- `bolts`: Array of Bolts in this Unit
  - `bolt_name`: Bolt identifier (e.g., "Bolt 1.1: Login Flow")
  - `project_key`: Jira project key for this Bolt (may differ from primary_project_key)
  - `phase`: Execution phase number (0-based)
  - `lane`: Parallel lane identifier (A, B, C, etc.)
  - `team`: Optional team assignment
  - `depends_on`: Array of Bolt names this Bolt depends on (parent will map to Jira keys)
  - `estimated_duration`: Duration estimate (e.g., "2 days")
  - `on_critical_path`: Boolean indicating if on critical path
  - `tasks`: Array of Task titles in this Bolt
- `tasks`: Array of all Tasks in this Unit
  - `task_title`: Task title (matches entries in `bolts[].tasks`)
  - `confluence_content`: Full Task page markdown (user story, AC, context, dependencies, risks)
- `story_points_field`: Story Points field configuration (or `null` if not configured)
  - `field_name`: Human-readable field name (e.g., "Story Points")
  - `field_id`: Jira field ID (e.g., "customfield_10016")
- `cloud_id`: Atlassian Cloud ID for API calls
- `region_url`: Optional Sentry region URL

## Operations

Execute these operations **sequentially** (order matters):

### Step 1: Create Sub-epic (Unit)

**[FACT]** Create the Sub-epic (Unit) as the parent container for all Bolts in this Unit.

**Write unit description to file:**

```bash
cat > /tmp/unit-description.md << 'EOF'
<unit.confluence_content>
EOF
```

**Create Sub-epic using acli:**

```bash
acli jira workitem create \
  --project "<unit.primary_project_key>" \
  --type "Sub-epic" \
  --summary "Unit: <unit.name>" \
  --description-file /tmp/unit-description.md \
  --parent "<unit.epic_jira_key>" \
  --label "aidlc:unit" \
  --label "aidlc:designed" \
  --json
```

**Parse response to extract:**
- `unit_jira_key` (e.g., "PROJ-123")
- `unit_url` (e.g., "https://jira.example.com/browse/PROJ-123")

**Error Handling:**
- **CRITICAL failure** → Abort agent immediately
- Return error JSON: `{"error": "sub_epic_creation_failed", "message": "<error details>"}`
- Parent will retry this agent for this Unit

**[INFERRED]** If the `aidlc:designed` label should only be applied when design artifacts exist, check the unit content for design links before adding the label. For now, apply it if design content is present in the Confluence markdown.

### Step 2: For Each Bolt (Sequential Loop)

For each Bolt in `bolts` array:

**Write bolt description to file:**

```bash
cat > /tmp/bolt-description.md << 'EOF'
## Scope

<bolt_name>

## Execution Details

- **Phase:** <phase>
- **Lane:** <lane>
- **Team:** <team> (if configured)
- **Estimated Duration:** <estimated_duration>
- **Critical Path:** <"Yes" if on_critical_path else "No">

## Tasks

<for each task in bolt.tasks>
- <task_title>
</for>

## Dependencies

<if depends_on is not empty>
This Bolt is blocked by:
<for each dep in depends_on>
- <dep> (Jira key will be linked by parent agent)
</for>
<else>
No dependencies
</if>

## Additional Context

(Include any relevant context from Unit page or Bolt Execution Plan)
EOF
```

**Create Story using acli:**

```bash
acli jira workitem create \
  --project "<bolt.project_key>" \
  --type "Story" \
  --summary "Bolt: <bolt.bolt_name>" \
  --description-file /tmp/bolt-description.md \
  --parent "<unit_jira_key>" \
  --label "aidlc:bolt" \
  --json
```

**Parse response to extract:**
- `story_jira_key` (e.g., "PROJ-124")
- `story_url`

**If team is configured, set team field:**

```bash
acli jira workitem edit <story_jira_key> --field "Team" --value "<bolt.team>"
```

**Error Handling:**
- **HIGH severity** → Log error, continue with next Bolt
- Add to errors array: `{"type": "story_creation_failed", "bolt_name": "<bolt.bolt_name>", "message": "<error>"}`
- **[INFERRED]** Team field may not exist in all Jira configurations → treat as non-critical error

### Step 3: For Each Task in Bolt (Sequential Loop)

For each Task title in `bolt.tasks`:

#### Step 3a: Score Task (Internal)

**[FACT]** Apply Fibonacci scale from `@plugins/aidlc/references/story-sizing.md`:
- **Scale:** 1, 2, 3, 5, 8, 13, 21+
- **Criteria:**
  - **Effort:** How many components/files/integrations are involved?
  - **Risk:** Integration complexity, external dependencies, new technology?
  - **Uncertainty:** Is the solution known, or does it require research?

**Scoring Guidelines:**

| Points | Effort | Risk | Uncertainty | Example |
|--------|--------|------|-------------|---------|
| 1 | Trivial (1 file, config change) | None | Known | Update env var |
| 2 | Simple (1-2 files) | Low | Known | Add validation rule |
| 3 | Moderate (2-3 files) | Low | Known | New API endpoint (CRUD) |
| 5 | **Medium (3-5 files, moderate integration)** | Medium | Mostly known | Auth flow with session |
| 8 | Large (5+ files, multiple integrations) | Medium-High | Some unknowns | Payment gateway integration |
| 13 | Very large (cross-cutting, many integrations) | High | Significant unknowns | Real-time notification system |
| 21+ | Extremely large (requires decomposition) | Very high | Major unknowns | Microservice migration |

**Default if unscoreable:** 5 (medium)

**[INFERRED]** If Task content is minimal or ambiguous, default to 5 points. If Task mentions "research", "investigate", or "spike", score at least 8 points due to uncertainty.

#### Step 3b: Create Sub-task

**Lookup Task content:**

Find the Task object in `tasks` array where `task_title` matches the current Task title.

**Write task description to file:**

```bash
cat > /tmp/task-description.md << 'EOF'
<task.confluence_content>
EOF
```

**IMPORTANT:** Transfer **ALL** acceptance criteria from Task page. Do **NOT** summarize or truncate. The Sub-task description must contain the complete Task content.

**Create Sub-task using acli:**

```bash
acli jira workitem create \
  --project "<bolt.project_key>" \
  --type "Sub-task" \
  --summary "<task_title>" \
  --description-file /tmp/task-description.md \
  --parent "<story_jira_key>" \
  --json
```

**If Story Points field is configured:**

```bash
acli jira workitem edit <subtask_jira_key> \
  --field "<story_points_field.field_name>" \
  --value "<score>"
```

**Parse response to extract:**
- `subtask_jira_key` (e.g., "PROJ-125")
- `subtask_url`

**Error Handling:**

**If Story Points field write fails:**
1. Log warning: "Story Points field not writable for <subtask_jira_key>"
2. Set `story_points_applied: false` in output
3. **Continue with next Task** (do not abort)

**If Sub-task creation fails:**
1. **MEDIUM severity** → Log error, continue with next Task
2. Add to errors array: `{"type": "subtask_creation_failed", "task_title": "<task_title>", "message": "<error>"}`

**[INFERRED]** Sub-tasks automatically inherit project from parent Story (Jira constraint), so we use `bolt.project_key` consistently.

### Step 4: Build Output JSON

After processing all Bolts and Tasks, construct the output JSON:

```json
{
  "unit_name": "User Authentication",
  "unit_jira_key": "PROJ-123",
  "unit_url": "https://jira.example.com/browse/PROJ-123",
  "bolts": [
    {
      "bolt_name": "Bolt 1.1: Login Flow",
      "story_jira_key": "PROJ-124",
      "story_url": "https://jira.example.com/browse/PROJ-124",
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
          "subtask_url": "https://jira.example.com/browse/PROJ-125",
          "story_points": 5,
          "story_points_applied": true
        },
        {
          "task_name": "Add login API",
          "subtask_jira_key": "PROJ-126",
          "subtask_url": "https://jira.example.com/browse/PROJ-126",
          "story_points": 8,
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
      {
        "key": "PROJ-130",
        "points": 13,
        "title": "Complex auth flow with SSO"
      }
    ]
  },
  "errors": [
    {
      "type": "story_points_write_failed",
      "task_key": "PROJ-127",
      "message": "Field 'Story Points' not writable for this issue type"
    }
  ]
}
```

**Story Points Summary Calculation:**

- `total_points`: Sum of all Task Story Points
- `task_count`: Total number of Sub-tasks created
- `average_points`: `total_points / task_count` (rounded to 2 decimals)
- `distribution`: Count of tasks at each point level (e.g., `{"3": 2, "5": 4}`)
- `large_tasks`: Array of tasks with 13+ points (flag for potential decomposition)

**Errors Array:**

Include all non-critical errors encountered during execution:
- Story/Sub-task creation failures
- Story Points field write failures
- Team field write failures

**[FACT]** Return this JSON as the final output of the agent.

## Error Severity Reference

| Error Type | Severity | Action | Parent Response |
|------------|----------|--------|-----------------|
| Sub-epic creation fails | **CRITICAL** | Abort agent | Retry agent for this Unit |
| Story creation fails | **HIGH** | Log, continue with next Bolt | Partial success |
| Sub-task creation fails | **MEDIUM** | Log, continue with next Task | Partial success |
| Story Points write fails | **LOW** | Retry without field, continue | Continue |
| Team field not found | **LOW** | Log warning, continue | Continue |

## Output Validation

Before returning output JSON, verify:

1. **[FACT]** `unit_jira_key` exists and is not null
2. **[FACT]** `bolts` array contains at least one Bolt (or empty if all failed)
3. **[FACT]** Each Bolt has `story_jira_key` or is listed in `errors`
4. **[FACT]** Each Task has `subtask_jira_key` or is listed in `errors`
5. **[FACT]** `story_points_summary.total_points` equals sum of all Task Story Points
6. **[FACT]** `large_tasks` includes all tasks with 13+ points

## Notes

- **[FACT]** This agent is stateless and isolated from other agents
- **[FACT]** Parent agent will map `depends_on` Bolt names to Jira keys for linking
- **[FACT]** Story Points scoring happens internally (not passed to parent for scoring)
- **[INFERRED]** Multi-project routing is handled by using `bolt.project_key` for each Story
- **[ASSUMED]** If `acli` is not available, operations will fail → parent should check `acli` availability before spawning agents

## Performance Expectations

- **[FACT]** Each agent processes one Unit independently
- **[FACT]** 5 agents running in parallel should complete in 3-5 minutes (same as 1 agent)
- **[INFERRED]** Token usage per agent: 5,000-8,000 tokens (depends on Unit size)
- **[INFERRED]** Agents can be retried individually without affecting other Units
