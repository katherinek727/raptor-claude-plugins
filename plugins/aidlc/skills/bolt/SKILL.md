---
name: bolt
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
- Jira artifact (story or sub-epic key, e.g., PROJ-123)
- Fetch the Jira issue using Atlassian MCP
- Extract acceptance criteria, description, and dependencies

If no Jira key provided, ask:
```
What Jira story or sub-epic should I work on?
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

#### Step 3: Explore Codebase

Understand the implementation area:
- Identify relevant files and modules
- Understand existing patterns and conventions
- Note any related tests that exist
- Identify integration points

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

#### Step 11: Start First TDD Cycle

Begin with the first test case:
1. Create the test file if it doesn't exist
2. Write the first failing test
3. Run the test to confirm it fails (RED)
4. Report status and await approval to continue

**At each step, update the plan file** to mark completed items.

#### Step 12: Continue TDD Cycles

For each cycle:
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

- **Previous**: Story/Task in Jira (from `/aidlc:verify` or manual creation)
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
