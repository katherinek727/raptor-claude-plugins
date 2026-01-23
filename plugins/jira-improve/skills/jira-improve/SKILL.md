---
name: jira-improve
description: Find and improve poorly written Jira issues using a quality rubric. Analyze a whole project, a single issue, or an Epic with all its children. Scores issues and helps improve with codebase context or user interviews. (Triggers - jira improve, fix jira, improve issues, jira quality, backlog cleanup, improve epic)
allowed-tools: [Bash, Read, Grep, Glob, Task, mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql, mcp__plugin_atlassian_atlassian__getJiraIssue, mcp__plugin_atlassian_atlassian__editJiraIssue, mcp__plugin_atlassian_atlassian__getVisibleJiraProjects, mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources, mcp__plugin_atlassian_atlassian__getJiraProjectIssueTypesMetadata, mcp__plugin_atlassian_atlassian__addCommentToJiraIssue, AskUserQuestion]
argument-hint: "[PROJECT-KEY or ISSUE-KEY]"
---

# Jira Issue Improvement Skill

Help POs, QAs, and developers find and improve poorly written Jira issues using a quality rubric.

## Reference Documents

Before proceeding, read the following reference documents:
- Quality Rubric: `{{SKILL_DIR}}/../../references/rubric.md`
- Improvement Templates: `{{SKILL_DIR}}/../../references/templates.md`

---

## Phase 1: Prerequisites Check

Check for required tools in this order:

### 1.1 Check for acli (Preferred)

```bash
acli --version 2>/dev/null
```

**If acli is available:**
- Note: "Using Atlassian CLI (acli) for Jira operations"
- acli uses less context than MCP tools

**If acli is NOT available:**
- Fall back to Atlassian MCP tools
- Test MCP availability by calling `getAccessibleAtlassianResources`

### 1.2 Check MCP Fallback

If acli is not available, call `getAccessibleAtlassianResources` to verify Atlassian MCP is configured.

**If MCP fails:**
- STOP and inform user: "Atlassian integration not configured. Please either:
  1. Install acli: https://confluence.atlassian.com/acli
  2. Configure Atlassian MCP server in your Claude Code settings"

### 1.3 Check for Codebase Context (Optional)

Check if we're in a git repository:
```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

Note if codebase context is available for the "codebase dive" option later.

---

## Phase 2: Input Detection and Configuration

The user can provide either:
- **Project key** (e.g., `CHAT`, `UKE`) - Search across entire project
- **Issue key** (e.g., `CHAT-123`) - Focus on specific issue and/or its children

### 2.1 Detect Input Type

**Pattern detection:**
- **Issue key format:** Contains hyphen followed by numbers (e.g., `PROJ-123`, `CHAT-4567`)
- **Project key format:** Letters only, no hyphen (e.g., `PROJ`, `CHAT`)

```
Input provided: {USER_INPUT}

Detecting format...
- Contains "-" followed by digits? → Issue key
- Letters only? → Project key
```

If no input provided, prompt user:

```
What would you like to analyze?

(1) Enter a project key (e.g., CHAT) - Search for issues across the project
(2) Enter an issue key (e.g., CHAT-123) - Analyze a specific issue or Epic with children
(3) Browse available projects

Select an option:
```

---

### 2.2 Branch A: Specific Issue Key Provided

When an issue key is detected (e.g., `CHAT-123`):

#### 2.2.1 Fetch the Issue

Use `getJiraIssue` (or `acli jira issue get {ISSUE_KEY}`) to retrieve the issue details.

**Extract:**
- Issue type (Epic, Story, Bug, Task, Chore, etc.)
- Project key (for field discovery)
- Parent/child relationships

#### 2.2.2 Determine Scope Based on Issue Type

**If Epic or Sub-Epic (has children):**
```
{ISSUE_KEY} is an Epic: "{ISSUE_SUMMARY}"

This Epic has {N} child issues.

What would you like to analyze?
(1) The Epic and all its children ({N+1} issues total)
(2) Only the child issues ({N} issues)
(3) Only the Epic itself
```

Use JQL to fetch children:
```jql
"Epic Link" = {ISSUE_KEY} OR parent = {ISSUE_KEY}
ORDER BY type ASC, key ASC
```

**If Story, Bug, Task, or Chore (leaf issue):**
```
{ISSUE_KEY} is a {ISSUE_TYPE}: "{ISSUE_SUMMARY}"

Analyzing this single issue.
```

Set issue list to just this one issue. Skip to Phase 2.4 (Field Discovery).

#### 2.2.3 Skip Search Parameters

When analyzing a specific issue or Epic:
- **Skip** issue count question (analyze all relevant issues)
- **Skip** issue type filter (already determined by the Epic's children)
- **Skip** status filter (analyze all statuses for these specific issues)
- **Skip** date filter (not relevant for specific issues)

Proceed directly to Field Discovery (Phase 2.4).

---

### 2.3 Branch B: Project Key Provided

When a project key is detected (e.g., `CHAT`):

#### 2.3.1 Validate Project

Verify project exists using `getVisibleJiraProjects` filtered by the key.

If not found:
```
Project "{PROJECT_KEY}" not found or you don't have access.

Available projects:
1. PROJ - Project Name
2. TEAM - Team Project

Select a project or enter a different key:
```

#### 2.3.2 Search Parameters

Ask user for search configuration:

```
## Search Configuration for {PROJECT_KEY}

How many issues should I analyze?
(1) 5 issues
(2) 10 issues (Recommended)
(3) 20 issues
(4) Custom number

Which issue types should I include?
[x] Story
[x] Bug
[x] Task
[ ] Chore
[ ] Spike
[ ] Epic

Status filter:
(1) Open issues only (Recommended)
(2) In Progress
(3) Backlog
(4) All statuses

Date filter (optional):
(1) No date filter
(2) Created in last 6 months
(3) Created in last 3 months
(4) Custom JQL date filter
```

#### 2.3.3 Construct JQL

Build the JQL query based on selections:

```jql
project = {PROJECT_KEY}
AND type IN ({ISSUE_TYPES})
AND status IN ({STATUSES})
[AND created > {DATE_FILTER}]
ORDER BY created DESC
```

---

### 2.4 Field Discovery

After determining the target issues (either from specific issue or project search):

1. Extract project key from the issues
2. Call `getJiraProjectIssueTypesMetadata` with the project
3. Identify custom fields (Acceptance Criteria, Steps to Reproduce, etc.)
4. Ask user which fields to score:

```
I found these fields for issues in {PROJECT}:
- Summary (standard)
- Description (standard)
- Acceptance Criteria (custom field)
- Steps to Reproduce (custom field)
- Story Points (custom field)

Which fields should I include in quality scoring?
(1) Summary + Description only (default)
(2) All fields above
(3) Let me select specific fields
```

---

## Phase 3: Fetch Issues and Parallel Analysis

### 3.1 Fetch Issues

**If project search (Branch B):**
Use `searchJiraIssuesUsingJql` (or `acli jira issue search --jql "..."`) with:
- The constructed JQL from Phase 2.3.3
- `maxResults` set to user-specified limit
- Request fields: summary, description, issuetype, status, created, plus any custom fields selected

**If specific issue (Branch A - single issue):**
- Issue already fetched in Phase 2.2.1
- No additional search needed

**If Epic with children (Branch A - Epic):**
Use `searchJiraIssuesUsingJql` with the child issues JQL:
```jql
"Epic Link" = {EPIC_KEY} OR parent = {EPIC_KEY}
ORDER BY type ASC, key ASC
```
- Include the Epic itself if user selected that option
- Request same fields as project search

### 3.2 Parallel Analysis

For each issue found, spawn a sub-agent to score it against the quality rubric.

**Sub-agent prompt template:**

```
Analyze this Jira issue against the Quality Rubric from {{SKILL_DIR}}/../../references/rubric.md

Issue Details:
- Key: {ISSUE_KEY}
- Type: {ISSUE_TYPE}
- Summary: {SUMMARY}
- Description: {DESCRIPTION}
- Custom Fields: {CUSTOM_FIELDS_IF_ANY}

Team Pattern: {DESCRIPTION_ONLY or CUSTOM_FIELDS based on Phase 2.3}

Score each dimension 0-100 based on the rubric criteria. Return your analysis as JSON:

{
  "issueKey": "{ISSUE_KEY}",
  "issueType": "{ISSUE_TYPE}",
  "overallScore": <calculated weighted score>,
  "scores": {
    "completeness": <0-100>,
    "clarity": <0-100>,
    "structure": <0-100>,
    "context": <0-100>,
    "testability": <0-100>
  },
  "gaps": [
    {
      "dimension": "<dimension name>",
      "issue": "<specific problem found>",
      "suggestion": "<how to fix it>"
    }
  ],
  "strengths": ["<positive aspect 1>", "<positive aspect 2>"],
  "redFlags": ["<vague term found>", "<missing required element>"]
}
```

**Batching:** Process up to 10 issues in parallel using Task tool with sub-agents.

### 3.3 Consolidate Results

Aggregate scores from all sub-agents and rank by overall score (lowest = needs most improvement).

---

## Phase 4: Results Presentation

Display the ranked results table:

```
## Issues Needing Improvement

Found {N} issues. Here are the results ranked by quality score (lowest = needs most work):

| Rank | Issue | Score | Type | Summary | Key Gaps |
|------|-------|-------|------|---------|----------|
| 1 | PROJ-123 | 25 | Bug | Fix login bug | Missing repro steps, vague description |
| 2 | PROJ-456 | 38 | Story | User feature | No acceptance criteria |
| 3 | PROJ-789 | 42 | Task | Update config | Ambiguous scope |
...

### Score Legend
- 0-30: Critical - needs immediate improvement
- 31-50: Poor - significant improvement needed
- 51-70: Adequate - could benefit from improvement
- 71-85: Good - minor refinements optional
- 86-100: Excellent - ready for implementation

---

What would you like to do?
(1) Improve all issues below score 50
(2) Improve all issues
(3) Select specific issues to improve
(4) Export results and exit
(5) Cancel
```

---

## Phase 5: Context Gathering

For each issue selected for improvement:

### 5.1 Ask Context Source

```
## Gathering Context for {ISSUE_KEY}

"{ISSUE_SUMMARY}"

Current Score: {SCORE}
Key Gaps: {GAPS}

How should I gather additional context to improve this issue?

(1) Dive into codebase - Search for related code, PRs, and technical context
(2) Interview me - I'll ask you targeted questions based on the gaps
(3) Both - Codebase search + interview
(4) Skip context - Improve based on rubric and templates only
```

### 5.2 Codebase Dive (if selected)

If user selected codebase context:

1. Extract keywords from issue title and description
2. Search for related code using Grep and Glob:
   - Search for component/module names mentioned
   - Look for related file names
   - Search for error messages or function names
3. If the issue references PRs or commits, fetch those
4. Summarize findings:

```
## Codebase Context Found

Related files:
- src/auth/login.ts - Contains login handler
- src/components/LoginForm.tsx - UI component

Recent changes:
- PR #123: "Refactored auth flow" (merged 2 weeks ago)

Code snippets that may be relevant:
[Include brief relevant snippets]
```

### 5.3 User Interview (if selected)

Ask targeted questions based on the gaps identified in Phase 3:

**For Bugs:**
- "What are the exact steps to reproduce this bug?"
- "What error message or behavior do you see?"
- "What should happen instead?"
- "Which browsers/environments is this confirmed in?"

**For Stories:**
- "Who is the user persona for this story?"
- "What does 'done' look like? What behavior should be observable?"
- "Are there any edge cases or error scenarios to consider?"
- "Are there designs or mockups available?"

**For Tasks:**
- "What specific files or components need to be changed?"
- "What does completion look like? How will we know it's done?"
- "Are there any dependencies or blockers?"

**For Chores:**
- "Why is this maintenance work needed now?"
- "What are the boundaries of this work?"
- "What are the risks if this isn't done?"

### 5.4 Synthesize Context

Combine codebase findings and user answers into a context summary that will inform the improvement.

---

## Phase 6: Improvement Proposal and Application

For each issue selected for improvement:

### 6.1 Generate Improved Content

Using:
- The quality rubric requirements
- The appropriate template from `{{SKILL_DIR}}/../../references/templates.md`
- The gathered context from Phase 5
- The team pattern (Description-only vs Custom fields)

Generate improved content for each field.

### 6.2 Preview Changes

Present a clear diff-style preview:

```
## Proposed Improvement for {ISSUE_KEY}

**Current Score:** {OLD_SCORE} → **Projected Score:** {NEW_SCORE}

---

### Summary
**Current:**
> {CURRENT_SUMMARY}

**Proposed:**
> {IMPROVED_SUMMARY}

---

### Description
**Current:**
> {CURRENT_DESCRIPTION}

**Proposed:**
> {IMPROVED_DESCRIPTION}

---

### {Custom Field Name} (if applicable)
**Current:**
> {CURRENT_VALUE or "(empty)"}

**Proposed:**
> {IMPROVED_VALUE}

---

Apply this improvement?
(Y) Yes - Apply changes
(N) No - Skip this issue
(E) Edit - Let me modify the proposed changes
(A) Apply all remaining - Apply this and all subsequent improvements without asking
```

### 6.3 Apply Changes

On approval:

1. **Update the issue** using `editJiraIssue` (or `acli jira issue update`):
   - Update each changed field

2. **Add a comment** using `addCommentToJiraIssue`:
   ```
   This issue was improved with AI assistance via `/jira-improve`.

   Changes made:
   - {List of fields updated}

   View previous version in issue history if needed.
   ```

3. **Track changes** for the summary report

---

## Phase 7: Summary Report

After all improvements are applied (or skipped):

```
## Improvement Session Complete

### Results

| Issue | Type | Before | After | Status | Fields Updated |
|-------|------|--------|-------|--------|----------------|
| PROJ-123 | Bug | 25 | 78 | Applied | Summary, Description |
| PROJ-456 | Story | 38 | 85 | Applied | Description, AC |
| PROJ-789 | Task | 42 | -- | Skipped | -- |

### Summary
- Issues analyzed: {N}
- Issues improved: {M}
- Issues skipped: {K}
- Average score improvement: {OLD_AVG} → {NEW_AVG}

### Next Steps
- Review improved issues in Jira to verify changes
- Run `/jira-improve` again to find more issues
- Consider adding custom fields to improve team workflow
- Share quality rubric with team for better issue writing

### Quick Links
{Links to each improved issue}
```

---

## Error Handling

### Jira API Errors

If Jira operations fail:
- Retry once with exponential backoff
- If still failing, inform user and offer to continue with remaining issues
- Never leave an issue in a partially updated state

### No Issues Found

If search returns no issues:
```
No issues found matching your criteria.

Try:
- Expanding the date range
- Including more issue types
- Checking a different project
- Reducing status filters
```

### Rate Limiting

If rate limited:
- Pause between operations
- Inform user of delay
- Continue when limits reset

---

## acli Command Reference

When acli is available, use these commands instead of MCP tools:

| Operation | acli Command |
|-----------|--------------|
| List projects | `acli jira project list` |
| Search issues | `acli jira issue search --jql "{JQL}" --limit {N}` |
| Get issue | `acli jira issue get {ISSUE_KEY}` |
| Update issue | `acli jira issue update {ISSUE_KEY} --summary "{SUMMARY}" --description "{DESC}"` |
| Add comment | `acli jira issue comment {ISSUE_KEY} --body "{COMMENT}"` |
| Get project metadata | `acli jira project get {PROJECT_KEY}` |

Parse acli output (usually JSON or table format) and handle errors appropriately.
