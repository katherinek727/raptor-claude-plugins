# AI-DLC Planning Shared Guidance

Use this reference for the AI-DLC Intent → Unit planning flow.

## Human-in-the-loop Gates

- Confirm understanding before drafting.
- Get explicit approval before creating or editing Confluence pages.
- Get explicit approval before creating Jira issues.
- Do not create Bugs unless explicitly requested by a human.

## Confluence Intent Template

- Intent Summary
- Problem / Opportunity
- Target Users
- Assigned Amigos
  - Product Owner
  - Tech Lead
  - Design Lead
- Initiative Profile
  - Pathway (green-field | brown-field | modernization | defect fix)
  - Scale (quick win | bounded delivery | strategic initiative)
  - Constraints (timeboxed, budget-limited, MVP-only, etc.)
  - Programme context (standalone | part of <programme name>)
- Outcomes (Business + User)
- Scope
  - In scope
  - Out of scope
- Technical Considerations
  - Known technical constraints
  - Key systems affected
  - Integration points (high-level)
- Designs & Diagrams (if available)
  - UI mockups / wireframes / prototypes
  - Flow diagrams (system or process)
- Non-Functional Requirements (NFRs)
- Measurement Criteria (OKR/KPI/SLI)
- Dependencies
- Risks (use Organizational Risk Taxonomy below; prioritize Data & Privacy and Security Posture)
- Assumptions
- Testing Strategy (see Testing Strategy Guidance below)
- Communication Plans
  - Progress Reporting Plan (how progress is tracked/reported)
  - Inter-team Comms Plan (shared channels, joint stand-ups, scrum of scrums)
- Enablement Checklist
  - [ ] Marketing materials needed?
  - [ ] Sales enablement needed?
  - [ ] Support flows / KBAs needed?
  - [ ] Training materials needed?
  - [ ] Customer comms needed?
- Open Questions
- Proposed Units (hypotheses only)
- Workflow Status (see Workflow Status Tracking below)

## Workflow Status Tracking

Track progress through the AI-DLC workflow with a status table in the Confluence doc and labels on Jira Units.

### Confluence Status Table

Include this table in the Level 1 Intent document:

| Phase | Status | Date | Artifact |
|-------|--------|------|----------|
| Intent | ⏳ Draft | - | - |
| Unit Decomposition | ⏳ Pending | - | - |
| Domain Design | ⏳ Pending | - | - |
| Verification | ⏳ Pending | - | - |

**Status values:**
- ⏳ Draft / Pending — Not started or in progress
- ✅ Approved / Complete — Phase finished
- 🔄 In Progress — Actively being worked
- ❌ Blocked — Waiting on dependency or decision

### Jira Unit Labels

Add labels to Units (Sub-epics) to track phase:
- `aidlc:unit` — Unit created from decomposition
- `aidlc:designed` — Domain design complete for this Unit

### Skill Responsibilities

Each skill updates the Confluence status table:
- `/aidlc:intent`: Set "Intent: ✅ Approved"
- `/aidlc:elaborate`: Set "Unit Decomposition: ✅ Complete" (Units remain in Confluence)
- `/aidlc:design`: Set "Domain Design: ✅ Complete"
- `/aidlc:verify`: Set "Verification: ✅ Complete", create Jira artifacts with appropriate labels

## Prerequisite Validation

Before proceeding with any skill (except `/planning:aidlc-plan`), validate that prerequisites are met.

### Validation Steps

1. **Check for required artifacts**
   - Ask for links/keys to prerequisite artifacts
   - Validate they exist using Atlassian MCP (fetch page, get issue)

2. **Check workflow status**
   - Fetch the Confluence Level 1 doc
   - Verify prior phases show "✅ Approved" or "✅ Complete"

3. **Handle missing prerequisites**
   - If artifacts don't exist: Offer to run the prior skill first
   - If status shows incomplete: Warn and ask for explicit confirmation to proceed
   - Allow override for recovery scenarios (e.g., resuming after interruption)

### Prerequisite Matrix

| Skill | Required Artifacts | Required Status |
|-------|-------------------|-----------------|
| `/aidlc:intent` | None (first step) | — |
| `/aidlc:elaborate` | Confluence Intent doc | "Intent: ✅ Approved" |
| `/aidlc:design` | Units Overview page with Unit/Task pages in Confluence | "Unit Decomposition: ✅ Complete" |
| `/aidlc:verify` | Units with design documentation | "Domain Design: ✅ Complete" (recommended) |

### Override Pattern

When prerequisites are incomplete but user wants to proceed:

```
⚠️ Prerequisites incomplete:
- [Missing artifact or status]

This may indicate a skipped step. Options:
1. Run [prior skill] first (recommended)
2. Proceed anyway (I have the artifacts elsewhere)
3. Cancel

Select an option to continue.
```

## Jira Artifact Hierarchy

When transferring from Confluence to Jira, use this hierarchy:

```
Sub-epic (Unit)
├── Story (Bolt) ← Groups related Tasks
│   ├── Sub-task (Task)
│   ├── Sub-task (Task)
└── Story (Bolt)
    └── Sub-task (Task)
```

## Jira Unit (Sub-epic) Template

- Summary: "Unit: <Unit Name>"
- Description:
  - Scope summary
  - Acceptance criteria (use checkbox format: `- [ ] Criterion`)
  - NFRs specific to the Unit (use table: Category | Requirement | Target)
  - Risks (use table: Risk | Impact | Likelihood | Mitigation)
  - Dependencies (use bulleted list with references)
  - Testing approach (which test types apply, test environment needs)
  - Link to Intent Confluence doc
- Label: `aidlc:unit`

See **Template Standardization** section for format details.

## Jira Bolt (Story) Template

- Summary: "Bolt: <Bolt Description>"
- Description:
  - Scope summary (what this Bolt delivers)
  - Tasks included (list of child sub-tasks)
  - Dependencies (other Bolts or external)
  - Estimated duration
- Parent: The Unit Sub-epic
- Label: `aidlc:bolt`

## Jira Task (Sub-task) Template

- Summary: "<Verb> <Outcome>"
- Description:
  - Context
  - Acceptance criteria (use checkbox format: `- [ ] Criterion`)
  - Dependencies (use bulleted list with references)
  - Test notes (bulleted list of test scenarios)
- Parent: The Bolt Story

See **Template Standardization** section for format details.

## Task Page Template (Confluence)

Use this template when creating Task pages in Confluence. Each Task is a child page under its Unit page.

**Page Title**: `<Task Title>` (this becomes the Jira sub-task summary when transferred)

**Page Content**:

```markdown
**Status**: Draft | Approved | Transferred

## Summary

<Brief description of what this Task delivers>

## Task

As a <user type>,
I want <goal/action>,
So that <benefit/value>.

## Acceptance Criteria

- [ ] <Criterion 1>
- [ ] <Criterion 2>
- [ ] <Criterion 3>

## Context

<Additional context, background, or technical notes>

## Dependencies

- [PROJ-123] <Dependency 1 with reference>
- [Unit: <Name>] <Dependency 2 with unit reference>

## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| <Risk 1> | High/Medium/Low | High/Medium/Low | <Mitigation> |
| <Risk 2> | High/Medium/Low | High/Medium/Low | <Mitigation> |

## Test Notes

- <Test scenario 1>
- <Test scenario 2>
```

**Note**: When transferred to Jira, the page title becomes the sub-task summary and all content becomes the description. Tasks are grouped into Bolts (Stories) based on the Proposed Bolts table in the Units Overview.

## Units Overview Page Template (Confluence)

Use this template for the Units Overview page in Confluence. This page is a child of the Intent document.

**Page Title**: `Units Overview`

**Page Content**:

```markdown
**Intent**: <Intent Name>
**Date**: <Creation date>
**Status**: Draft | In Review | Approved | Transferred

## Unit Summary

| Unit | Tasks | Bolts | Dependencies |
|------|-------|-------|--------------|
| <Unit 1 Name> | <count> | <count> | <list> |
| <Unit 2 Name> | <count> | <count> | <list> |

**Total Tasks**: <count>

---

## Proposed Bolts

Initial groupings of Tasks into Bolts for each Unit. These are proposals that will be refined during `/aidlc:verify`.

### Unit 1: <Name>

| Bolt | Description | Tasks | Est. Duration |
|------|-------------|-------|---------------|
| Bolt 1.1 | <Scope description> | 1, 2, 3 | X hours/days |
| Bolt 1.2 | <Scope description> | 4, 5 | X hours/days |

### Unit 2: <Name>

| Bolt | Description | Tasks | Est. Duration |
|------|-------------|-------|---------------|
| Bolt 2.1 | <Scope description> | 1, 2 | X hours/days |

---

## Dependency Graph

```
Unit 1: <Name>
    │
    ├──► Unit 2: <Name>
    │        │
    │        └──► Unit 3: <Name>
    │
    └──► Unit 4: <Name>
```

---

## Key Technical Decisions

- <Decision 1>
- <Decision 2>

---

## Cross-Cutting Acceptance Criteria

- [ ] <Criterion that applies to all Units>
- [ ] <Criterion that applies to all Units>

---

## Links

- [Intent](<Confluence link>)
```

## Unit Page Template (Confluence)

Use this template for Unit pages in Confluence. Each Unit page is a child of the Units Overview page.

**Page Title**: `Unit <N>: <Unit Name>`

**Page Content**:

```markdown
**Description**: <Brief scope summary>

**Status**: Draft | In Review | Approved | Transferred

## Tasks

| # | Task | Status |
|---|------|--------|
| 1 | <Task title> | Draft |
| 2 | <Task title> | Draft |

*(Tasks are child pages of this Unit)*

## Bolt Plan

| Bolt | Scope | Tasks | Estimate |
|------|-------|-------|----------|
| Bolt 1 | <Description> | 1, 2, 3 | X hours |
| Bolt 2 | <Description> | 4, 5 | X hours |

## Dependencies

- **Depends on:** [Unit: <Name>] <description>
- **Blocks:** [Unit: <Name>] <description>
- **External:** <External dependency>

## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| <Risk specific to this Unit> | High/Medium/Low | High/Medium/Low | <Mitigation> |
```

## Organizational Risk Taxonomy

Surface risks aligned to these categories. Prioritize **Data & Privacy** and **Security Posture** — these are critical for our organization.

### Data & Privacy (Critical)
- **Sensitive data exposure** — unintended access to PII, PHI, credentials, or business-critical data
- **Data residency violations** — data leaving approved regions or jurisdictions
- **Retention policy violations** — keeping data longer than permitted
- **PII/PHI in logs or errors** — sensitive data leaking into observability systems
- **Non-prod data masking gaps** — production data in dev/test without adequate masking

### Security Posture (Critical)
- **3rd party library introduction** — new dependencies increase supply chain attack surface; require security review
- **CVE exposure** — changes that introduce or fail to remediate known vulnerabilities
- **RBAC/permission changes** — new permissions, roles, or access patterns require explicit review
- **Secrets exposure** — API keys, credentials, tokens in code, config, or logs
- **Auth bypass paths** — changes that could allow authentication or authorization circumvention
- **Injection vectors** — SQL, command, XSS, SSRF, or other injection vulnerabilities
- **Audit logging gaps** — missing audit trail for sensitive operations (compliance/forensics)

### Compliance
- **Regulatory control gaps** — SOC2, HIPAA, GDPR, or other framework control failures
- **Consent mechanism changes** — modifications to user consent or opt-out flows
- **Audit trail completeness** — changes affecting compliance evidence collection

### Operational
- **Rollback capability** — can the change be quickly reverted if issues arise?
- **Observability blind spots** — can we detect and diagnose issues post-deployment?
- **Availability/SLA impact** — risk of service degradation or downtime
- **Backward compatibility** — breaking changes to APIs, schemas, or contracts
- **Infrastructure cost** — unexpected cost increases from resource consumption

### Delivery
- **External dependency risk** — reliance on external services, vendors, or deprecated APIs
- **Knowledge concentration** — single point of failure on team (bus factor)
- **Integration complexity** — underestimated effort for cross-system changes
- **Scope uncertainty** — unclear requirements leading to rework

## Risk Surfacing Prompts

Use these prompts to elicit risks during Intent and Unit planning:

- Does this change introduce or modify access to sensitive data?
- Are new 3rd party libraries or services being introduced?
- Does this change RBAC, permissions, or authentication flows?
- Are there known CVEs in dependencies this change touches?
- What could cause unintended data exposure?
- What could materially delay delivery?
- What could cause rework or scope churn?
- What operational risks apply (availability, cost, observability)?
- What dependencies are least certain?
- Can this change be rolled back quickly if needed?

## NFR Checklist (prompt as needed)

- Performance/latency targets (see Raptor Performance Standards below)
- Availability/SLA
- Security and privacy
- Compliance (SOC2, HIPAA, GDPR, etc.)
- Reliability/recovery objectives
- Observability requirements
- Cost constraints

### Raptor Performance Standards

Reference: [Performance Standards](https://raptortech1.atlassian.net/wiki/spaces/EN/pages/1086914569/Performance+Standards)

When defining performance NFRs, apply these standards where applicable:

| Category | Standard |
|----------|----------|
| Browser (Core Web Vitals) | LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 (75th percentile) |
| Mobile Apps | Screen Transition ≤100ms (good), Crash Rate ≤1% |
| Traditional APIs | Response Time <100ms (75th percentile) |
| Feature Specific | Team-defined (track in addition to standards) |
| Background Jobs | Team-defined (queue depth, custom metrics) |

Performance is monitored via New Relic Service Levels. Trend performance is measured over 7 days at 75th percentile.

## Measurement Criteria Prompts

- Primary business outcome metric
- User impact metric
- Baseline and target timeframe
- Leading indicators

## Testing Strategy Guidance

Include a testing strategy appropriate to the pathway type and scope:

- **Automated tests**: Unit, integration, and contract tests in CI/CD pipelines
- **Manual/exploratory QA**: For user-facing flows and edge cases
- **E2E tests**: Only when user-facing flows are in scope; prefer contract tests for service boundaries
- **Performance/load tests**: When NFRs include latency or throughput targets
- **Security testing**: When security or compliance NFRs apply

For each Unit, specify:
- Which test types apply
- Acceptance criteria that are testable
- Any test environment or data dependencies

## Repo Context Gathering

When the Intent involves code changes, gather repo context to inform the documentation:

1. **Local repo available**: Read README, docs, and relevant source files to understand architecture
2. **GitLab/GitHub MCP available**: Fetch README and docs from the remote repository
3. **CLI fallback**: Use `glab` or `gh` to fetch repo information if MCP is unavailable

Include in the Intent documentation:
- Repositories/services in scope (with paths or URLs)
- Key architectural patterns or constraints discovered
- Existing testing infrastructure

## PRFAQ Template (Optional)

Generate a PRFAQ when requested to communicate the Intent's value proposition.

### Press Release
- **Headline**: One-line value proposition
- **Subheadline**: Who benefits and how
- **Problem**: What pain point is being addressed
- **Solution**: How this Intent solves it
- **Quote**: Stakeholder perspective on the value
- **Call to Action**: What success looks like

### FAQ
- Q: Who is the target user?
- Q: What are the key success metrics?
- Q: What are the main risks?
- Q: What is out of scope?
- Q: What dependencies exist?

## Bolt Planning Guidance

Bolts are rapid iteration cycles (hours to days) for implementing Units.

When planning Bolts:
- Each Bolt should deliver a testable increment
- Bolts within a Unit can run sequentially or in parallel
- Suggest Bolt boundaries based on:
  - Natural breakpoints in functionality
  - Integration points requiring validation
  - Risk areas needing early feedback

Example Bolt structure for a Unit:
- Bolt 1: Core domain logic + unit tests (4-8 hours)
- Bolt 2: API/integration layer (4-8 hours)
- Bolt 3: Security hardening + compliance checks (2-4 hours)

## Mob Elaboration Guidance

Mob Elaboration is a collaborative ritual for requirements elaboration.

**Setup:**
- Single room (physical or virtual) with shared screen
- Participants: Product Owner, Developers, QA, relevant stakeholders
- AI as central participant proposing and refining

**Flow:**
1. Present the Intent and gather clarifying questions
2. AI proposes initial User Stories and Acceptance Criteria
3. Mob reviews, challenges, and refines
4. AI groups Stories into cohesive Units
5. Mob validates Unit boundaries and dependencies
6. Capture NFRs, Risks, and Measurement Criteria
7. Approve final structure before Jira creation

**Duration:** 2-4 hours for a typical Intent

## Artifact Traceability

Maintain bidirectional links between artifacts:

```
Confluence Level 1 Intent
    ↓ linked in Unit description
Jira Unit (Sub-epic)
    ↓ parent link
Jira Story/Chore
    ↓ referenced in design docs
Domain Design / ADRs
```

Each artifact should reference:
- **Forward**: What it decomposes into
- **Backward**: What it derives from

**Confluence to Jira Mapping:**
```
Confluence Intent Document → Reference (not transferred)
Confluence Unit Page → Jira Sub-epic
Confluence Task Page → Jira Sub-task (under Bolt/Story)
Proposed Bolts (Units Overview) → Jira Stories (grouping sub-tasks)
```

This enables:
- Impact analysis when requirements change
- Audit trail for compliance
- Context retrieval for AI assistance

## Domain-Driven Design Guidance

When creating Domain Designs, apply these DDD principles:

### Strategic Design
- **Bounded Context**: Define clear boundaries for the Unit's domain
- **Context Map**: Identify relationships with other Units (upstream/downstream)
- **Ubiquitous Language**: Use consistent terminology from the Intent

### Tactical Design
- **Aggregate**: Cluster of entities with a root; transaction boundary
- **Entity**: Object with identity that persists over time
- **Value Object**: Immutable object defined by attributes, not identity
- **Domain Event**: Something significant that happened in the domain
- **Repository**: Abstraction for aggregate persistence
- **Factory**: Encapsulates complex object creation

### Anti-Corruption Layer
For brown-field scenarios, design an ACL to:
- Translate between legacy and new domain models
- Isolate the new domain from legacy system quirks
- Enable gradual migration

## ADR Template

Use this template for Architecture Decision Records.

### ADR-NNN: <Decision Title>

**Status:** Proposed | Accepted | Deprecated | Superseded

**Context:**
What is the issue or question that motivated this decision?

**Decision:**
What is the decision that was made?

**Consequences:**
What are the trade-offs and implications?
- Positive:
- Negative:
- Risks:

**Alternatives Considered:**
What other options were evaluated?

**Related:**
- Intent: <link>
- Unit: <link>
- Related ADRs: <links>

## Atlassian MCP Operational Guidance

**Atlassian Domain:** `raptortech1.atlassian.net`
**Atlassian Cloud ID:** `7c795d89-53db-46c0-896a-d6333239676d`

When using Atlassian MCP tools, follow this sequence:

**For Confluence operations:**
1. Use the Cloud ID above for all Atlassian MCP tool calls
2. Find the target space using `getConfluenceSpaces` or user-provided space key
3. Locate the parent page using `searchConfluenceUsingCql` or `getPagesInConfluenceSpace`
4. Create or update the page using `createConfluencePage` or `updateConfluencePage`
5. If the page already exists, ask whether to update or create a new version

**When reviewing a Confluence page:**
Before reading, prompt the user:
> "Would you like me to include comments (inline and footer) and their replies, or just the page content?"

- **Page content only**: Use `getConfluencePage`
- **With comments**: Also fetch `getConfluencePageInlineComments` and `getConfluencePageFooterComments`

**For Jira operations (prefer `acli` CLI - lower token usage):**

First, check if `acli` is installed:
```bash
which acli || echo "acli not installed - see: https://developer.atlassian.com/cloud/acli/"
```

If `acli` is available, use it for Jira operations:
1. Confirm the Jira project key (never assume a default)
2. View issues: `acli jira workitem view PROJ-123 --json`
3. Create issues: `acli jira workitem create --project "PROJ" --type "Story" --summary "Title" --description-file desc.md`
4. Edit issues: `acli jira workitem edit PROJ-123 --label "aidlc:unit"`
5. Search issues: `acli jira workitem search --project "PROJ" --jql "type = Story"`

If `acli` is not available, fall back to Atlassian MCP:
1. Verify issue types using `getJiraProjectIssueTypesMetadata`
2. Get field metadata using `getJiraIssueTypeMetaWithFields` if custom fields are needed
3. Create issues using `createJiraIssue`
4. Link issues to Confluence pages in the description field

**Common issues:**
- Space/project not found: Verify key spelling and permissions
- Missing issue type: Check project configuration; Epic or Sub-epic may not be available
- Permission denied: User may lack write access; suggest admin contact

## Comment Resolution Guidance

When resolving comments during the decomposition review phase, follow this process:

### Fetching Comments

For each page in the decomposition hierarchy (Overview, Units, Stories):

1. **Inline comments**: `getConfluencePageInlineComments`
   - These are attached to specific text selections
   - Check `resolutionStatus` field: `open`, `resolved`, `reopened`, `dangling`
   - Dangling means the highlighted text was modified/deleted

2. **Footer comments**: `getConfluencePageFooterComments`
   - These are general page-level comments
   - No resolution status - resolved by discussion in reply thread

3. **Replies**: Both inline and footer comments can have threaded replies
   - Always read the full thread to understand the discussion
   - Later replies may supersede earlier feedback

### Addressing Feedback

For each comment thread:

| Feedback Type | Action |
|---------------|--------|
| Valid correction | Update page content, reply confirming change |
| Clarification needed | Reply with clarification, update content if needed |
| Disagreement | Reply explaining rationale, may need escalation |
| Question | Reply with answer, update content if answer reveals gap |
| Out of scope | Reply acknowledging, note for future consideration |

### Reply Templates

**Feedback addressed:**
> ✅ Updated. Changed [specific text] to [new text] based on this feedback.

**Clarification provided:**
> The intent here is [explanation]. I've updated the wording to make this clearer.

**Escalation needed:**
> This requires a decision from [role/person]. Flagging for discussion.

**Out of scope:**
> Good point, but this is out of scope for this Intent. Added to Open Questions for future consideration.

### Marking Resolved

- **Inline comments**: Confluence has a "Resolve" action - mention this to the user
- **Footer comments**: Considered resolved when the reply thread indicates agreement

### Best Practices

- Address comments in order: Overview → Units → Stories (top-down)
- Group related comments that can be addressed with a single content update
- If multiple comments conflict, surface the conflict and ask for resolution
- Keep replies concise but informative
- Always update content before replying (so the reply can reference the change)

## Atlassian MCP Tool Names (Rovo)

In Claude Code, tools are namespaced with the `mcp__plugin_atlassian_atlassian__` prefix.

| Base Tool Name | Claude Code Namespaced Name |
|----------------|----------------------------|
| `search` | `mcp__plugin_atlassian_atlassian__search` |
| `searchConfluenceUsingCql` | `mcp__plugin_atlassian_atlassian__searchConfluenceUsingCql` |
| `searchJiraIssuesUsingJql` | `mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql` |
| `getConfluenceSpaces` | `mcp__plugin_atlassian_atlassian__getConfluenceSpaces` |
| `getConfluencePage` | `mcp__plugin_atlassian_atlassian__getConfluencePage` |
| `getPagesInConfluenceSpace` | `mcp__plugin_atlassian_atlassian__getPagesInConfluenceSpace` |
| `createConfluencePage` | `mcp__plugin_atlassian_atlassian__createConfluencePage` |
| `updateConfluencePage` | `mcp__plugin_atlassian_atlassian__updateConfluencePage` |
| `getVisibleJiraProjects` | `mcp__plugin_atlassian_atlassian__getVisibleJiraProjects` |
| `getJiraProjectIssueTypesMetadata` | `mcp__plugin_atlassian_atlassian__getJiraProjectIssueTypesMetadata` |
| `getJiraIssueTypeMetaWithFields` | `mcp__plugin_atlassian_atlassian__getJiraIssueTypeMetaWithFields` |
| `createJiraIssue` | `mcp__plugin_atlassian_atlassian__createJiraIssue` |
| `editJiraIssue` | `mcp__plugin_atlassian_atlassian__editJiraIssue` |
| `addCommentToJiraIssue` | `mcp__plugin_atlassian_atlassian__addCommentToJiraIssue` |
| `lookupJiraAccountId` | `mcp__plugin_atlassian_atlassian__lookupJiraAccountId` |

## Atlassian CLI (`acli`) Commands (Preferred for Jira)

**Why prefer `acli` for Jira?** The Atlassian CLI uses significantly fewer tokens than the MCP tools, making it more efficient for Jira operations. Use MCP for Confluence (richer tooling) and `acli` for Jira.

**Installation check:**
```bash
which acli || echo "Not installed - see: https://developer.atlassian.com/cloud/acli/"
```

**Authentication:**
```bash
acli auth login  # Interactive login (one-time setup)
```

### Common Jira Commands

| Operation | Command |
|-----------|---------|
| View issue | `acli jira workitem view PROJ-123 --json` |
| View with fields | `acli jira workitem view PROJ-123 --fields summary,description,status,issuetype --json` |
| Search issues | `acli jira workitem search --project "PROJ" --jql "type = Story AND status = Open"` |
| Create issue | `acli jira workitem create --project "PROJ" --type "Story" --summary "Title" --description "Body"` |
| Create from file | `acli jira workitem create --project "PROJ" --type "Story" --summary "Title" --description-file desc.md` |
| Create with parent | `acli jira workitem create --project "PROJ" --type "Story" --summary "Title" --parent "PROJ-100"` |
| Edit issue | `acli jira workitem edit PROJ-123 --summary "New Title"` |
| Add label | `acli jira workitem edit PROJ-123 --label "aidlc:unit"` |
| Add comment | `acli jira workitem comment add PROJ-123 --body "Comment text"` |
| Transition | `acli jira workitem transition PROJ-123 --transition "In Progress"` |
| List projects | `acli jira project list` |

### Example: Create Sub-epic with Stories

```bash
# Create Sub-epic (Unit)
acli jira workitem create \
  --project "PROJ" \
  --type "Sub-epic" \
  --summary "Unit: Authentication" \
  --description-file unit-auth.md \
  --label "aidlc:unit" \
  --json

# Parse the key from JSON output, then create child stories
acli jira workitem create \
  --project "PROJ" \
  --type "Story" \
  --summary "Implement login form" \
  --description-file story-login.md \
  --parent "PROJ-123"
```

## Task Elaboration Subagent

The `/aidlc:elaborate` skill uses parallel subagents to elaborate Tasks by theme cluster. This section defines the prompt template and expected return format.

### Theme Clustering Guidance

When identifying theme clusters from an Intent:
- Aim for 3-5 clusters (fewer for small intents, more for complex ones)
- Group by functional area, capability, or technical domain
- Each cluster should have low coupling to other clusters
- Example themes: Authentication, API Layer, Data Migration, UI Components, Reporting

### Subagent Prompt Template

Use this template when spawning Task elaboration subagents via the Task tool:

```markdown
You are elaborating Tasks for the "<THEME_NAME>" theme cluster.

## Intent Context

**Intent Summary:** <brief summary of the overall intent>

**Target Users:** <user personas affected>

**NFRs:** <relevant non-functional requirements>

**Constraints:** <any constraints or limitations>

## Tasks to Elaborate

Elaborate the following Tasks for this theme:
<list of Task titles/scopes>

## Instructions

For each Task:
1. Write the full Task content using the Task Markdown Template format
2. Identify risks specific to this Task
3. Identify dependencies:
   - Within this theme cluster
   - Cross-cluster dependencies (reference other themes by name)

## Task Markdown Template

Use this format for each Task:

# Task: <Task Title>

**Unit**: _pending_ <!-- Assigned after grouping -->
**Bolt**: _pending_ <!-- Assigned after Bolt grouping -->
**Jira Key**: _pending_ <!-- Updated after Jira creation -->
**Status**: Draft

## Summary
<Brief description of what this Task delivers>

## Task
As a <user type>,
I want <goal/action>,
So that <benefit/value>.

## Acceptance Criteria
- [ ] <Criterion 1>
- [ ] <Criterion 2>

## Context
<Additional context, background, or technical notes>

## Dependencies
- <Dependency 1>

## Risks
- <Risk 1>

## Test Notes
<Guidance for testing this Task>

## Return Format

Return your results as JSON in this exact structure:

{
  "theme": "<THEME_NAME>",
  "tasks": [
    {
      "title": "<Task title>",
      "content": "<full markdown content for the Task>",
      "risks": ["<risk 1>", "<risk 2>"],
      "dependencies": {
        "within_theme": ["<Task title in same theme>"],
        "cross_theme": ["<Theme Name>: <Task or capability>"]
      }
    }
  ],
  "cross_cutting_concerns": [
    "<concern that spans multiple themes or the entire intent>"
  ]
}
```

### Subagent Return Format

Each subagent returns structured JSON with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `theme` | string | The theme cluster name |
| `tasks` | array | Array of elaborated Tasks |
| `tasks[].title` | string | Task title |
| `tasks[].content` | string | Full markdown content for the Task file |
| `tasks[].risks` | array | Risks specific to this Task |
| `tasks[].dependencies.within_theme` | array | Dependencies on other Tasks in the same theme |
| `tasks[].dependencies.cross_theme` | array | Dependencies on other themes (format: "Theme: capability") |
| `cross_cutting_concerns` | array | Concerns that span multiple themes |

### Consolidation Logic

After collecting results from all subagents, the parent agent:

1. **Parse results**: Extract Tasks from each subagent's JSON response
2. **Merge risks**: Combine all `cross_cutting_concerns` into a unified list
3. **Build dependency graph**: Map `cross_theme` dependencies to actual Tasks
4. **Identify conflicts**: Flag Tasks with conflicting assumptions or overlapping scope
5. **Group into Units**:
   - Start with theme boundaries
   - Merge themes with tight coupling
   - Split themes with clear sub-boundaries
6. **Propose Bolt groupings**: Group Tasks into Bolts based on cohesive scope
7. **Assign Unit slugs**: Add unit prefix to each Task filename

## Confluence Page Creation Subagent

The `/aidlc:elaborate` skill uses parallel subagents to create Confluence pages efficiently. After the Units Overview page is created, one subagent is spawned per Unit to create that Unit's page and all its Task pages in parallel.

### Subagent Prompt Template

Use this template when spawning Confluence page creation subagents via the Task tool:

```markdown
You are creating a Unit page and its Task pages in Confluence.

## Context

**Cloud ID:** <cloudId>
**Parent Page ID:** <unitsOverviewPageId> (Units Overview page)

## Unit Data

**Unit Name:** <unitName>
**Unit Description:** <description>
**Status:** Draft

### Bolt Plan

| Bolt | Scope | Tasks | Estimate |
|------|-------|-------|----------|
<bolt plan rows>

### Dependencies

- **Depends on:** <other units or external>
- **Blocks:** <units that depend on this>

### Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
<risk rows>

## Tasks to Create

<JSON array of Tasks with full content>

## Instructions

1. Create the Unit page as child of Units Overview using the Unit Page Template
2. For each Task, create a Task page as child of the Unit page using the Task Page Template
3. Return the Unit page ID and all Task page IDs

## Templates

Use the templates from planning-shared.md:
- Unit Page Template (for the Unit)
- Task Page Template (for each Task)

## Return Format

Return your results as JSON in this exact structure:

{
  "unit": {
    "name": "<unit name>",
    "pageId": "<unit page ID>",
    "pageUrl": "<unit page URL>"
  },
  "tasks": [
    { "title": "<Task title>", "pageId": "<Task page ID>", "pageUrl": "<Task page URL>" }
  ]
}
```

### Subagent Return Format

Each subagent returns structured JSON with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `unit.name` | string | The Unit name |
| `unit.pageId` | string | Confluence page ID for the Unit |
| `unit.pageUrl` | string | URL to the Unit page |
| `tasks` | array | Array of created Task pages |
| `tasks[].title` | string | Task title |
| `tasks[].pageId` | string | Confluence page ID for the Task |
| `tasks[].pageUrl` | string | URL to the Task page |

### Consolidation After Page Creation

After collecting results from all page creation subagents:

1. **Verify all pages created**: Check that each subagent returned valid page IDs
2. **Handle failures**: If any subagent failed, report which Unit/Tasks failed and offer to retry
3. **Compile page links**: Build a summary of all created pages for the user
4. **Update Units Overview**: Add links to Unit pages in the summary table

## Bolt Implementation Subagents

The `/aidlc:bolt` skill uses parallel subagents for efficient, accurate implementation of multi-Task Bolts. Sub-agents operate per-Task when a Bolt contains multiple Tasks.

### Task Context Subagent (Phase 1)

Use this template when spawning Task Context Agents to explore the codebase for each Task in parallel:

```markdown
You are gathering implementation context for a single Task within a Bolt.

## Task: <Task Title>

<Task content: user story, acceptance criteria>

## Repository Context

**Repo Path:** <path>
**Tech Stack:** <languages, frameworks>
**Key Directories:** <src/, tests/, etc.>

## Instructions

1. Search for existing code related to this Task's domain
2. Identify relevant files, modules, and patterns
3. Find existing tests that cover related functionality
4. Note any integration points or dependencies

## Return Format

Return your results as JSON in this exact structure:

{
  "task": "<task title>",
  "relevant_files": [
    { "path": "<file path>", "relevance": "<why this file is relevant>" }
  ],
  "existing_patterns": [
    "<pattern description>"
  ],
  "related_tests": [
    { "path": "<test file path>", "coverage": "<what it tests>" }
  ],
  "integration_points": [
    "<service/API/database>"
  ],
  "technical_notes": "<observations about implementation approach>"
}
```

### Task Test Planning Subagent (Phase 2)

Use this template when spawning Task Test Planning Agents to design test cases for each Task:

```markdown
You are planning TDD test cases for a single Task.

## Task: <Task Title>

<Task content: user story, acceptance criteria>

## Context from Phase 1

**Relevant Files:** <list>
**Existing Patterns:** <list>
**Related Tests:** <list>

## Instructions

1. Design unit tests for each acceptance criterion
2. Identify edge cases and error scenarios
3. Design integration tests if applicable
4. Suggest mocks/stubs needed
5. Plan Red-Green-Refactor cycles

## Return Format

Return your results as JSON in this exact structure:

{
  "task": "<task title>",
  "unit_tests": [
    { "name": "<test name>", "verifies": "<what it verifies>", "approach": "<how to test>" }
  ],
  "edge_cases": [
    "<edge case description>"
  ],
  "integration_tests": [
    { "name": "<test name>", "verifies": "<what it verifies>" }
  ],
  "mocks_needed": [
    "<mock/stub description>"
  ],
  "tdd_cycles": [
    { "cycle": 1, "red": "<failing test>", "green": "<implementation>", "refactor": "<improvements>" }
  ]
}
```

### Expert Perspective Subagents (Phase 2)

For high-risk Tasks, spawn Expert Perspective Agents to catch blind spots:

| Expert | Focus | Adds |
|--------|-------|------|
| Security | OWASP, auth, input validation | Security-focused test cases |
| Performance | Latency, memory, scalability | Performance test scenarios |
| Domain | Business rules, edge cases | Domain-specific scenarios |

**Security Expert Prompt:**
```markdown
You are reviewing test coverage from a security perspective.

## Task: <Task Title>
## Proposed Tests: <test plan from Tier 1>

Identify missing security test cases for:
- Input validation and sanitization
- Authentication/authorization boundaries
- Injection vulnerabilities (SQL, XSS, command)
- Sensitive data handling

Return additional test cases in the same JSON format as Task Test Planning.
```

**Performance Expert Prompt:**
```markdown
You are reviewing test coverage from a performance perspective.

## Task: <Task Title>
## Proposed Tests: <test plan from Tier 1>

Identify missing performance test cases for:
- Response time targets
- Memory usage
- Concurrent access
- Data volume edge cases

Return additional test cases in the same JSON format as Task Test Planning.
```

### Task Implementation Subagent (Phase 6)

Use this template when spawning Task Implementation Agents to execute TDD for independent Tasks in parallel:

```markdown
You are implementing a single Task using TDD.

## Task: <Task Title>

<Task content: user story, acceptance criteria>

## Test Plan from Phase 2

**TDD Cycles:**
<cycle details>

**Test Cases:**
<test case list>

## Implementation Context

**Relevant Files:** <list>
**Patterns to Follow:** <list>

## Instructions

1. For each TDD cycle:
   - RED: Write failing test, verify it fails
   - GREEN: Write minimal code to pass
   - REFACTOR: Improve code quality
2. Commit after each cycle with meaningful message
3. Update progress tracking

## Return Format

Return your results as JSON in this exact structure:

{
  "task": "<task title>",
  "status": "complete|blocked|partial",
  "cycles_completed": [
    { "cycle": 1, "test_file": "<path>", "impl_file": "<path>", "commit": "<commit hash or message>" }
  ],
  "files_modified": [
    "<file path>"
  ],
  "blockers": [
    "<blocker description>"
  ],
  "notes": "<implementation notes>"
}
```

### Subagent Consolidation Logic

After collecting results from all subagents:

**Phase 1 (Context) Consolidation:**
1. Parse JSON results from each agent
2. Merge relevant files lists (dedupe by path)
3. Combine existing patterns discovered
4. Surface any conflicting approaches
5. Present unified context summary

**Phase 2 (Planning) Consolidation:**
1. Merge test plans into unified structure
2. Identify shared test fixtures/utilities
3. Resolve any conflicting approaches
4. Integrate expert recommendations
5. Present combined test plan for approval

**Phase 6 (Implementation) Consolidation:**
1. Verify no file conflicts between agents
2. Merge any overlapping changes
3. Run full test suite to verify integration
4. Update plan file with combined progress
5. Report completion status for all Tasks

## Template Standardization

All templates must use consistent formatting for common sections.

### Section Format Reference

| Section | Required Format | Example |
|---------|-----------------|---------|
| **Acceptance Criteria** | Checkbox list (`- [ ]`) | `- [ ] User can log in with SSO` |
| **Risks** | Table with columns: Risk, Impact, Likelihood, Mitigation | See Risks Table Format |
| **Dependencies** | Bulleted list with link/reference | `- [AUTH-123] SSO provider setup` |
| **Status** | Bold label + current value | `**Status:** Draft` |
| **Task** | "As a... I want... So that..." format | Standard user story format |
| **NFRs** | Table with columns: Category, Requirement, Target | See NFRs Table Format |
| **Test Notes** | Bulleted list of test scenarios | `- Verify login with valid credentials` |
| **Context** | Prose paragraph(s) | Free-form text |

### Risks Table Format

Always use this table format for risks:

```markdown
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| <Risk description> | High/Medium/Low | High/Medium/Low | <Mitigation strategy> |
```

### NFRs Table Format

Always use this table format for non-functional requirements:

```markdown
| Category | Requirement | Target |
|----------|-------------|--------|
| Performance | Response time | < 200ms |
| Security | Authentication | OAuth 2.0 |
| Availability | Uptime | 99.9% |
```

### Acceptance Criteria Format

Always use checkbox format for acceptance criteria:

```markdown
## Acceptance Criteria

- [ ] Criterion 1: Specific, testable requirement
- [ ] Criterion 2: Another testable requirement
- [ ] Criterion 3: Edge case handling
```

### Dependencies Format

Always use bulleted list with references:

```markdown
## Dependencies

- [PROJ-123] Prerequisite work item
- [Unit: Authentication] Must complete first
- External: Third-party API availability
```
