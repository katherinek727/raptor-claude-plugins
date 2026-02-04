---
name: aidlc-bolt
description: Guide implementation of a bolt (rapid iteration cycle) with TDD emphasis. Gathers context from Jira, creates a TDD-focused plan, stores it locally, and creates a feature branch for implementation. (Triggers - bolt, implement bolt, start bolt, bolt implementation, new bolt)
---

# AI-DLC Bolt Implementation

Guide the implementation of a bolt (rapid iteration cycle) with emphasis on Test-Driven Development (TDD). This skill helps developers execute focused, testable increments of work.

> **What is a Bolt?**
>
> A Bolt is the smallest iteration cycle in AI-DLC, typically lasting hours to days.
> It delivers a testable increment of functionality and follows the TDD rhythm:
> Red (write failing test) → Green (make it pass) → Refactor (improve code quality).

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI gathers** — Collect context from Jira artifact and repository
2. **AI plans** — Create TDD-focused implementation plan
3. **Human approves** — Review and approve the plan
4. **AI executes** — Create branch and begin implementation with progress tracking

## Example Invocations

- "Start a bolt for PROJ-123"
- "Implement the authentication story"
- "Begin a bolt for the API endpoint task"
- "New bolt for the database migration"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for Bolt guidance and templates.

## Workflow

### Phase 1: Context Gathering

#### Step 1: Gather Jira Context

Ask for the work context:
- Jira artifact (Bolt/Story key, e.g., PROJ-123)
- Fetch the Jira issue using the `acli` CLI (preferred for lower token usage):
  ```bash
  # First check acli is installed
  which acli || echo "acli not installed - see: https://developer.atlassian.com/cloud/acli/"

  # Fetch the Bolt (Story) with relevant fields
  acli jira workitem view PROJ-123 --fields summary,description,status,issuetype --json

  # Fetch child Tasks (Sub-tasks) for context
  acli jira workitem children PROJ-123 --json
  ```
- Extract acceptance criteria, description, and dependencies from the response
- Note the Tasks (Sub-tasks) that are part of this Bolt

If no Jira key provided, ask:
```
What Jira Bolt (Story) should I work on?
Please provide the issue key (e.g., PROJ-123).
```

#### Step 2: Validate Repository Context

Confirm the user is in the correct repository context:
1. Check current working directory
2. Verify the repository is relevant to the Jira artifact
3. If multiple repositories are needed, confirm they are cloned locally

Ask if needed:
```
I see you're in [current repo]. Is this the correct repository for this work?
If this bolt spans multiple services, please list the local paths to all repositories.
```

#### Step 2.5: Determine Sub-agent Strategy

Based on the Bolt's Tasks, decide whether to use parallel sub-agents:

**Single Task:** Proceed with single-agent exploration (Step 3).

**Multiple Tasks:** Spawn parallel Task Context Agents to explore in parallel.

Ask:
```
This Bolt has [N] Tasks. Should I explore the codebase for each Task in parallel?
(Recommended for efficiency - each Task gets focused exploration)

1. Yes, explore in parallel (recommended)
2. No, explore sequentially
```

#### Step 3: Explore Codebase (Parallel or Sequential)

**If single Task or user declines parallel:**

Understand the implementation area:
- Identify relevant files and modules
- Understand existing patterns and conventions
- Note any related tests that exist
- Identify integration points

**If multiple Tasks and parallel approved:**

1. Spawn one **Task Context Agent** per Task using the Task tool
2. Use `subagent_type: "general-purpose"`
3. Pass Task content + repo context to each agent
4. Use the **Task Context Subagent** template from `planning-shared.md`
5. Spawn all agents in a single message (parallel execution)

**After agents return:**
1. Parse JSON results from each agent
2. Merge relevant files lists (dedupe by path)
3. Combine existing patterns discovered
4. Surface any conflicting approaches
5. Present unified context summary:

```
## Codebase Context (Consolidated)

### Relevant Files
- [file1] - relates to [Task A, Task B]
- [file2] - relates to [Task C]

### Existing Patterns
- [pattern 1]
- [pattern 2]

### Related Tests
- [test file 1] - covers [related functionality]

### Integration Points
- [API/service/database]
```

---

### Phase 2: TDD-Focused Planning

#### Step 4: Plan Test Cases First

Following TDD principles, identify what tests need to be written:

1. **Unit Tests**
   - What functions/methods need tests?
   - What edge cases should be covered?
   - What mocks/stubs are needed?

2. **Integration Tests** (if applicable)
   - What API endpoints need testing?
   - What database interactions need verification?
   - What external service interactions need mocking?

3. **Acceptance Tests** (if applicable)
   - How will acceptance criteria be verified?
   - What end-to-end scenarios should be tested?

Present the test plan:
```
## Proposed Test Cases

### Unit Tests
1. [Test description] - verifies [acceptance criterion]
2. [Test description] - handles [edge case]

### Integration Tests
1. [Test description] - verifies [integration point]

### Test Files to Create/Modify
- tests/unit/test_[feature].py
- tests/integration/test_[feature]_api.py
```

#### Step 4.5: Parallel Test Planning (Multi-Task Bolts)

**If Bolt has multiple Tasks:**

1. Spawn one **Task Test Planning Agent** per Task using the Task tool
2. Use `subagent_type: "general-purpose"`
3. Pass Task content + context from Phase 1 to each agent
4. Use the **Task Test Planning Subagent** template from `planning-shared.md`
5. Spawn all agents in a single message (parallel execution)

**Consolidation:**
1. Merge test plans into unified structure
2. Identify shared test fixtures/utilities
3. Resolve any conflicting approaches
4. Present combined test plan for approval

**Optional: Expert Perspectives**

For high-risk Tasks (security-sensitive, performance-critical, complex domain logic):

Ask:
```
This Bolt includes [security-sensitive/performance-critical/complex] Tasks.
Would you like expert perspectives on:
1. Security (OWASP, auth, input validation)
2. Performance (latency, memory, scalability)
3. Domain (business rules, edge cases)
4. All of the above
5. Skip expert review
```

If yes, spawn Expert Perspective Agents in parallel using templates from `planning-shared.md`, then integrate their recommendations into the test plan.

#### Step 5: Plan Implementation Steps

Create a detailed implementation plan structured as TDD cycles:

```
## Implementation Plan

### Cycle 1: [Feature slice]
1. RED: Write failing test for [specific behavior]
2. GREEN: Implement [minimal code to pass]
3. REFACTOR: [Specific improvements]

### Cycle 2: [Next feature slice]
1. RED: Write failing test for [specific behavior]
2. GREEN: Implement [minimal code to pass]
3. REFACTOR: [Specific improvements]

...
```

---

### Phase 3: Plan Approval

#### Step 6: Present Plan for Approval

Present the complete plan to the user:
- Summary of the Jira artifact
- Test cases to be written
- Implementation cycles (Red → Green → Refactor)
- Estimated files to be created/modified
- Any risks or dependencies identified

**Ask explicitly:**
```
Does this plan look correct? Please approve or suggest changes before I proceed.
```

Do NOT proceed until explicit approval is received.

---

### Phase 4: Local Plan Storage

#### Step 7: Prompt for Plan File Location

Ask where to store the plan:
```
Where should I save the implementation plan?

Suggested locations:
1. ./bolt-plan.md (current directory)
2. ./docs/bolts/[jira-key].md
3. Custom path

Please specify or press enter for the default (./bolt-plan.md).
```

#### Step 8: Save Plan to Local File

Create the plan file with:
- Jira context and link
- Full implementation plan
- Progress tracking checklist
- Test cases with checkboxes

**Plan File Template:**
```markdown
# Bolt: [Jira Key] - [Summary]

**Jira:** [Link to issue]
**Branch:** [branch-name]
**Created:** [date]

## Context

[Brief description from Jira]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Test Plan

### Unit Tests
- [ ] [Test 1]
- [ ] [Test 2]

### Integration Tests
- [ ] [Test 1]

## Implementation Progress

### Cycle 1: [Description]
- [ ] RED: Write failing test
- [ ] GREEN: Make test pass
- [ ] REFACTOR: Clean up

### Cycle 2: [Description]
- [ ] RED: Write failing test
- [ ] GREEN: Make test pass
- [ ] REFACTOR: Clean up

## Notes

[Space for implementation notes]
```

---

### Phase 5: Feature Branch Creation

#### Step 9: Prompt for Base Branch

Ask which branch to use as the base:
```
Which branch should I create the feature branch from?

1. main (recommended for trunk-based development)
2. master
3. dev/develop
4. Other (please specify)
```

Default to `main` if user presses enter.

#### Step 10: Create Feature Branch

Create the feature branch with naming convention:
- Format: `<jira-key>-<description>`
- Example: `PROJ-123-add-user-authentication`

```bash
git checkout [base-branch]
git pull origin [base-branch]
git checkout -b [jira-key]-[short-description]
```

Report branch creation:
```
Created feature branch: PROJ-123-add-user-authentication
Based on: main

Ready to begin implementation. The plan is saved at [plan-file-path].
```

---

### Phase 6: Begin Implementation

#### Step 10.5: Determine Implementation Strategy

**If single Task:** Proceed with sequential TDD cycles (Step 11).

**If multiple Tasks:**

1. Analyze Task dependencies from Phase 1 context
2. Identify which Tasks are independent (no shared file modifications, no sequential dependencies)
3. Offer parallel implementation for independent Tasks

Ask:
```
Based on the context gathered:

**Independent Tasks** (can run in parallel):
- [Task A] - touches [files]
- [Task B] - touches [files]

**Dependent Tasks** (must run sequentially):
- [Task C] depends on [Task A]

Should I implement the independent Tasks in parallel using separate agents?
(Recommended for efficiency - each Task gets focused TDD cycles)

1. Yes, implement in parallel (recommended)
2. No, implement sequentially
```

**Important Constraints:**
- Only parallelize Tasks with no shared file modifications
- Each agent owns its TDD cycles (Red → Green → Refactor)
- Main agent coordinates merging and resolves conflicts

#### Step 11: Execute TDD Cycles (Parallel or Sequential)

**Sequential (single Task or dependent Tasks):**

Begin with the first test case:
1. Create the test file if it doesn't exist
2. Write the first failing test
3. Run the test to confirm it fails (RED)
4. Report status and await approval to continue

**At each step, update the plan file** to mark completed items.

**Parallel (independent Tasks):**

1. Spawn one **Task Implementation Agent** per independent Task using the Task tool
2. Use `subagent_type: "general-purpose"`
3. Pass Task content + test plan + context to each agent
4. Use the **Task Implementation Subagent** template from `planning-shared.md`
5. Spawn all agents in a single message (parallel execution)
6. Agents commit independently with meaningful messages

**After parallel agents complete:**
1. Parse JSON results from each agent
2. Verify no file conflicts between agents
3. Merge any overlapping changes (rare if dependencies analyzed correctly)
4. Run full test suite to verify integration
5. Update plan file with combined progress
6. Report completion status for all Tasks:

```
## Implementation Progress

### Task A: [Title] ✅ Complete
- Cycles completed: 3
- Files modified: [list]
- Tests passing: Yes

### Task B: [Title] ✅ Complete
- Cycles completed: 2
- Files modified: [list]
- Tests passing: Yes

### Integration Verification
- Full test suite: ✅ Passing
- Conflicts resolved: None
```

#### Step 12: Continue TDD Cycles (Sequential Mode)

For each cycle (when running sequentially):
1. Write failing test (RED) - run to confirm failure
2. Implement minimal code (GREEN) - run to confirm pass
3. Refactor if needed - run to confirm still passing
4. Update plan file progress
5. Commit with meaningful message

Commit message format:
```
[JIRA-KEY] [type]: [description]

- [detail 1]
- [detail 2]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

---

## Workflow Chain

- **Previous**: Bolt (Story) in Jira with Tasks (Sub-tasks) from `/aidlc-verify`
- **Next**: Pull/Merge Request (manual or via `/issues:create-mr`)

## Definition of Done

- Jira context gathered and understood
- TDD-focused plan created with test cases first
- Plan approved by user
- Plan saved to local file with progress tracking
- Feature branch created from specified base
- Implementation proceeds with TDD rhythm
- Plan file updated as progress is made

## Troubleshooting

- **No Jira access**: Allow manual entry of acceptance criteria and description
- **Multiple repositories**: Confirm which repo to work in first; can switch later
- **Existing branch**: Ask whether to use existing or create new
- **Tests failing unexpectedly**: Investigate before proceeding; may indicate design issue
- **Plan file location conflict**: Offer alternative paths or append timestamp
