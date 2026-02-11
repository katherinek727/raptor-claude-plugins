---
name: aidlc-progress
description: Generate confidence, risk, and progress assessment for an Initiative. Visual dashboard showing documentation quality, team readiness, execution evidence, code health, and actionable recommendations. Works at any phase from Intent through implementation. (Triggers - check progress, initiative status, how are we doing, project health, aidlc progress)
---

# AI-DLC Progress

Generate a comprehensive progress report for an Initiative, showing confidence, risk, and progress metrics with actionable recommendations. Can be run at any phase of the AI-DLC workflow.

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI gathers** — Collect Initiative reference (Confluence URL or Jira Epic key)
2. **AI detects phase** — Determine current workflow phase from artifacts present
3. **AI spawns assessors** — Parallel sub-agents assess documentation, Jira, and code
4. **AI consolidates** — Merge results into headline metrics and detailed breakdown
5. **AI reports** — Present visual dashboard with recommendations

## Example Invocations

- "Check the progress of the authentication initiative"
- "How are we doing on PROJ-123?"
- "Show me the project health dashboard"
- "What's the risk level for this initiative?"
- "/aidlc-progress https://confluence.example.com/wiki/spaces/PROJ/pages/12345"
- "/aidlc-progress PROJ-123"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for Jira/Confluence tool guidance and templates.
- Use @${CLAUDE_PLUGIN_ROOT}/references/review-criteria.md for shared quality checklists and scoring foundations.

## Tool Preference

- **CLI-first**: Prefer `acli` (Atlassian CLI) and `glab` (GitLab CLI) as they use fewer tokens.
- **MCP fallback**: Use Atlassian MCP when CLI is unavailable or insufficient.

---

## Workflow

### Phase 1: Gather Initiative Reference

Ask for the Initiative identifier:

```
Please provide the Initiative to assess:

- Confluence Intent page URL, OR
- Jira Epic key (e.g., PROJ-123)

I'll fetch all related artifacts and generate a progress report.
```

### Phase 2: Detect Current Workflow Phase

Fetch the Initiative and determine the current phase based on artifacts present:

| Phase | Artifacts Present | Metrics Available |
|-------|------------------|-------------------|
| **Planning** | Intent doc only | Documentation quality, Ambiguity |
| **Elaboration** | Intent + Units/Tasks in Confluence | Above + Task completeness |
| **Design** | Above + Design docs/ADRs | Above + Technical readiness |
| **Verification** | Above + Jira issues created | Above + Team readiness, Progress |
| **Implementation** | Above + Code/PRs/MRs | All metrics including Code health |

**Detection logic:**

1. Fetch Intent document (Confluence)
2. Check for Units Overview and Unit child pages
3. Check for Design documents (Domain model, ADRs)
4. Check Workflow Status table in Intent
5. Search for linked Jira Epic/Sub-epics
6. If Jira exists, check for linked PRs/MRs

Report the detected phase to the user:
```
Detected phase: [Implementation]
Artifacts found: Intent, 3 Units, 8 Tasks, Design docs, Jira Epic with 3 Sub-epics, 5 linked MRs
```

### Phase 3: Spawn Assessment Sub-agents

Spawn parallel sub-agents based on the detected phase. Use the Task tool with `subagent_type: "general-purpose"`.

**Spawn all applicable sub-agents in a single message for parallel execution.**

---

#### Sub-agent A: Documentation Assessor

**Always spawn** — assesses Confluence documentation quality.

```markdown
You are assessing AI-DLC documentation quality for a progress report.

## Initiative Context

**Intent Document:**
<intent content>

**Units (if present):**
<unit pages content>

**Tasks (if present):**
<task pages content>

**Design Documents (if present):**
<design doc content>

## Scoring Dimensions

Rate each dimension 0-100:

1. **Documentation Completeness** — All required sections present for the current phase
2. **Content Quality** — Clear, specific, actionable; no vague language (see Part 2.2 of review-criteria)
3. **NFR Measurability** — Performance/security/availability targets are specific and measurable
4. **Ambiguity Level** — Lower ambiguity = higher score; boundaries and terms clear

## Return Format

Return as JSON:

{
  "phase_detected": "<planning|elaboration|design|verification|implementation>",
  "scores": {
    "documentation_completeness": <0-100>,
    "content_quality": <0-100>,
    "nfr_measurability": <0-100>,
    "ambiguity_level": <0-100>
  },
  "gaps": [
    {
      "severity": "<high|medium|low>",
      "area": "<section or document>",
      "issue": "<description>",
      "suggestion": "<remediation>"
    }
  ],
  "open_questions": [
    "<question from the documentation>"
  ],
  "strengths": [
    "<well-documented aspect>"
  ],
  "overall_confidence": <0-100>
}
```

---

#### Sub-agent B: Jira Assessor

**Spawn if Jira issues exist** — assesses team readiness and progress.

```markdown
You are assessing Jira issue health for an Initiative progress report.

## Jira Artifacts

**Epic/Sub-epics:**
<jira epic and sub-epic details>

**Stories (Bolts):**
<story details with status, assignee, points>

**Sub-tasks (Tasks):**
<sub-task details with status, assignee>

## Scoring Dimensions

Rate each dimension 0-100:

1. **Progress (Task Completion)** — Done issues / Total issues as percentage
2. **Progress (Story Points)** — Completed points / Total points as percentage
3. **Team Readiness** — Issues assigned, no blockers, dependencies mapped
4. **Blocker Count** — Fewer blockers = higher score (100 = no blockers)

## Return Format

Return as JSON:

{
  "progress": {
    "task_completion": {
      "done": <count>,
      "total": <count>,
      "percentage": <0-100>
    },
    "story_points": {
      "completed": <points>,
      "total": <points>,
      "percentage": <0-100>
    }
  },
  "team_readiness": {
    "score": <0-100>,
    "unassigned_count": <count>,
    "blocker_count": <count>,
    "blocked_issues": ["<issue keys>"]
  },
  "status_breakdown": {
    "to_do": <count>,
    "in_progress": <count>,
    "done": <count>,
    "blocked": <count>
  },
  "unit_progress": [
    {
      "unit": "<sub-epic name>",
      "tasks_done": <count>,
      "tasks_total": <count>,
      "points_done": <points>,
      "points_total": <points>,
      "status": "<not_started|in_progress|done>"
    }
  ],
  "risks": [
    {
      "severity": "<high|medium|low>",
      "issue": "<description>",
      "suggestion": "<remediation>"
    }
  ]
}
```

---

#### Sub-agent C: Code Assessor

**Spawn if PRs/MRs are linked** — assesses code health and risk.

For each linked MR, fetch the diff and assess:

```markdown
You are assessing code health for an Initiative progress report.

## Linked Merge Requests

<list of MRs with status, file changes>

## MR Diffs (summarised)

<key changes from each MR>

## Project Context

<CLAUDE.md, linter configs, test directory structure>

## Scoring Dimensions

Rate each dimension 0-100:

1. **Test Coverage Estimate** — Based on test files present, test-to-code ratio
2. **Code Complexity** — Large files, deep nesting, high method counts = lower score
3. **MR Health** — Merged vs open, CI status, review status

## Return Format

Return as JSON:

{
  "mr_summary": {
    "total": <count>,
    "merged": <count>,
    "open": <count>,
    "ci_passing": <count>,
    "ci_failing": <count>
  },
  "scores": {
    "test_coverage_estimate": <0-100>,
    "code_complexity": <0-100>,
    "mr_health": <0-100>
  },
  "risk_factors": [
    {
      "severity": "<high|medium|low>",
      "area": "<file or component>",
      "issue": "<description>",
      "suggestion": "<remediation>"
    }
  ],
  "strengths": [
    "<positive code health aspect>"
  ]
}
```

---

### Phase 4: Consolidate Results

After all sub-agents return:

1. **Parse JSON results** from each sub-agent
2. **Calculate headline metrics:**

**Confidence Score** (weighted composite):
| Component | Weight | Source |
|-----------|--------|--------|
| Documentation Completeness | 25% | Doc Assessor |
| Content Quality | 20% | Doc Assessor |
| Team Readiness | 25% | Jira Assessor (or N/A) |
| Execution Evidence | 20% | Code Assessor (or N/A) |
| Ambiguity (inverted) | 10% | Doc Assessor |

**Risk Score** (weighted composite):
| Component | Weight | Source |
|-----------|--------|--------|
| Test Coverage (inverted) | 35% | Code Assessor (or N/A) |
| Code Complexity | 25% | Code Assessor (or N/A) |
| Blocker Count | 25% | Jira Assessor (or N/A) |
| Dependency Issues | 15% | Doc + Jira Assessors |

**Progress Score:**
- If story points available: weighted average of (60% points + 40% task completion)
- If no points: task completion percentage
- If no Jira: N/A

3. **Merge recommendations** from all assessors, ranked by severity
4. **Identify phase-appropriate actions**

---

### Phase 5: Present Dashboard

Present the progress report:

```markdown
## Initiative Progress Report

### [Initiative Name]

**Phase:** [Implementation] | **Assessed:** [YYYY-MM-DD HH:MM]

---

### Summary

| Metric | Score | Interpretation |
|--------|-------|----------------|
| **Confidence** | XX% | [High/Medium/Low] — [one-line summary] |
| **Risk** | XX% | [High/Medium/Low] — [one-line summary] |
| **Progress** | XX% | [ahead/on track/behind] — [one-line summary] |

---

### Confidence Breakdown

| Dimension | Score | Notes |
|-----------|-------|-------|
| Documentation Completeness | XX% | [brief note] |
| Content Quality | XX% | [brief note] |
| Team Readiness | XX% | [brief note or N/A] |
| Execution Evidence | XX% | [brief note or N/A] |
| Ambiguity Level | XX% | [brief note] |

---

### Risk Breakdown

| Dimension | Score | Notes |
|-----------|-------|-------|
| Test Coverage | XX% | [brief note or N/A] |
| Code Complexity | XX% | [brief note or N/A] |
| Active Blockers | XX% | [count or N/A] |
| Dependency Issues | XX% | [brief note] |

---

### Progress by Unit

| Unit | Tasks | Points | Status |
|------|-------|--------|--------|
| Unit 1: [Name] | X/Y (XX%) | X/Y (XX%) | [status emoji] [In Progress] |
| Unit 2: [Name] | X/Y (XX%) | X/Y (XX%) | [status emoji] [Not Started] |
| Unit 3: [Name] | X/Y (XX%) | X/Y (XX%) | [status emoji] [Done] |
| **Total** | **X/Y (XX%)** | **X/Y (XX%)** | — |

Status indicators: ✅ Done | 🔄 In Progress | ⏳ Not Started | ❌ Blocked

---

### Recommendations

**High Priority:**
1. [Action] — [why it matters]

**Medium Priority:**
2. [Action] — [why it matters]

**Low Priority:**
3. [Action] — [why it matters]

---

### Open Questions

1. [Question from Intent or docs]
2. [Question identified during assessment]

---

### Strengths

- [Positive aspect 1]
- [Positive aspect 2]
```

---

## Score Interpretation

### Confidence Thresholds

| Level | Score | Meaning |
|-------|-------|---------|
| **High** | 80-100% | Initiative is well-defined and execution is on track |
| **Medium** | 60-79% | Some concerns to address but manageable |
| **Low** | <60% | Significant gaps; recommend addressing before continuing |

### Risk Thresholds

| Level | Score | Meaning |
|-------|-------|---------|
| **Low** | 0-30% | Risk well-managed |
| **Medium** | 31-60% | Notable risks to monitor |
| **High** | >60% | High risk; recommend mitigation actions |

### Progress Interpretation

| Status | Criteria |
|--------|----------|
| **Ahead** | Progress > expected for elapsed time |
| **On Track** | Progress within 10% of expected |
| **Behind** | Progress > 10% below expected |

---

## Handling Missing Data (Staged Assessment)

When data is unavailable for the current phase:

| Situation | Handling |
|-----------|----------|
| No Jira issues | Progress = N/A, Team Readiness = N/A; focus on documentation metrics |
| No linked MRs | Code health = N/A, Risk focuses on documentation/Jira only |
| No design docs | Technical readiness scores lower; flag as recommendation |
| No story points | Use task completion only for progress |
| Intent only | Show documentation metrics only; note early phase |

Display N/A clearly in the dashboard:
```
| Test Coverage | N/A | No code artifacts linked yet |
```

---

## Workflow Chain

- **Previous**: Any AI-DLC skill (can be invoked at any phase)
- **Next**: Address recommendations, continue with implementation

## Definition of Done

- Initiative reference collected (Confluence URL or Jira key)
- Current phase detected and reported
- All applicable sub-agents spawned and returned
- Headline metrics calculated (Confidence, Risk, Progress)
- Detailed breakdown tables rendered
- Recommendations prioritised and listed
- Dashboard presented to user

## Troubleshooting

- **No `acli` available**: Fall back to Atlassian MCP tools.
- **Cannot detect phase**: Ask user to confirm which artifacts exist.
- **Jira access denied**: Show documentation metrics only; note Jira was inaccessible.
- **MR links not found**: Check Jira issue links field; ask user to provide MR URLs manually.
- **Sub-agent timeout**: Report which assessor failed and offer to retry or skip that dimension.
- **Conflicting data**: Report the conflict in recommendations (e.g., Jira says done but no MR merged).
- **Very early phase**: If only Intent exists, show limited dashboard with phase-appropriate metrics.
