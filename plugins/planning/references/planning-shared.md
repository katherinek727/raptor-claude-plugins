# AI-DLC Planning Shared Guidance

Use this reference for the AI-DLC Intent → Unit planning flow.

## Human-in-the-loop Gates

- Confirm understanding before drafting.
- Get explicit approval before creating or editing Confluence pages.
- Get explicit approval before creating Jira issues.
- Do not create Bugs unless explicitly requested by a human.

## Confluence Level 1 Intent Template

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

Track progress through the AI-DLC workflow with a status table in the Confluence doc and labels on the Jira Intent Epic.

### Confluence Status Table

Include this table in the Level 1 Intent document:

| Phase | Status | Date | Artifact |
|-------|--------|------|----------|
| Level 1 Intent | ⏳ Draft | - | - |
| Intent Epic | ⏳ Pending | - | - |
| Unit Decomposition | ⏳ Pending | - | - |
| Domain Design | ⏳ Pending | - | - |

**Status values:**
- ⏳ Draft / Pending — Not started or in progress
- ✅ Approved / Complete — Phase finished
- 🔄 In Progress — Actively being worked
- ❌ Blocked — Waiting on dependency or decision

### Jira Epic Labels

Add labels to the Intent Epic to track phase:
- `aidlc:epic-created` — Epic exists, ready for decomposition
- `aidlc:decomposing` → `aidlc:decomposed` — Unit/Story creation
- `aidlc:designing` → `aidlc:designed` — Domain design phase

### Skill Responsibilities

Each skill updates both tracking mechanisms:
- `/planning:aidlc-plan`: Initialize status table with "Level 1 Intent: ✅ Approved"
- `/planning:aidlc-create-epic`: Update table + add `aidlc:epic-created` label
- `/planning:aidlc-decompose`: Update table + transition labels
- `/planning:aidlc-design`: Update table + transition labels

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
| `/planning:aidlc-plan` | None (first step) | — |
| `/planning:aidlc-create-epic` | Confluence Level 1 doc | "Level 1 Intent: ✅ Approved" |
| `/planning:aidlc-decompose` | Intent Epic, Confluence doc | "Intent Epic: ✅ Created" |
| `/planning:aidlc-design` | Unit(s), Intent Epic, Confluence doc | "Unit Decomposition: ✅ Complete" |

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

## Jira Intent Epic Template

- Summary: "Intent: <Intent Name>"
- Description:
  - Intent summary
  - Confluence link(s)
  - Outcomes
  - NFRs
  - Measurement criteria
  - Risks and assumptions

## Jira Unit (Sub-epic) Template

- Summary: "Unit: <Unit Name>"
- Description:
  - Scope summary
  - Acceptance criteria
  - NFRs specific to the Unit
  - Risks and dependencies
  - Testing approach (which test types apply, test environment needs)
  - Links to Intent Epic + Confluence

## Jira Work Item Template (Story/Chore)

- Summary: "<Verb> <Outcome>"
- Description:
  - Context
  - Acceptance criteria
  - Dependencies
  - Test notes (if needed)

## Story Page Template (Confluence)

Use this template when creating Story pages in Confluence. Each story is a child page under its Unit page.

**Page Title**: `<Story Title>` (this becomes the Jira summary when transferred)

**Page Content**:

```markdown
**Status**: Draft | Approved | Transferred

## Summary

<Brief description of what this story delivers>

## User Story

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

- <Dependency 1>
- <Dependency 2>

## Risks

- <Risk 1>
- <Risk 2>

## Test Notes

<Guidance for testing this story>
```

**Note**: When transferred to Jira, the page title becomes the Jira summary and all content becomes the description.

## Units Overview Page Template (Confluence)

Use this template for the Units Overview page in Confluence. This page is a child of the Level 1 Intent document.

**Page Title**: `Units Overview`

**Page Content**:

```markdown
**Intent**: <Intent Name>
**Intent Epic**: <Jira Epic key>
**Date**: <Creation date>
**Status**: Draft | In Review | Approved | Transferred

## Unit Summary

| Unit | Stories | Bolts | Dependencies |
|------|---------|-------|--------------|
| <Unit 1 Name> | <count> | <count> | <list> |
| <Unit 2 Name> | <count> | <count> | <list> |

**Total Stories**: <count>

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

- [Level 1 Intent](<Confluence link>)
- [Intent Epic](<Jira link>)
```

## Unit Page Template (Confluence)

Use this template for Unit pages in Confluence. Each Unit page is a child of the Units Overview page.

**Page Title**: `Unit <N>: <Unit Name>`

**Page Content**:

```markdown
**Description**: <Brief scope summary>

**Status**: Draft | In Review | Approved | Transferred

## Stories

| # | Story | Status |
|---|-------|--------|
| 1 | <Story title> | Draft |
| 2 | <Story title> | Draft |

*(Stories are child pages of this Unit)*

## Bolt Plan

| Bolt | Scope | Stories | Estimate |
|------|-------|---------|----------|
| Bolt 1 | <Description> | 1, 2, 3 | X hours |
| Bolt 2 | <Description> | 4, 5 | X hours |

## Dependencies

- **Depends on**: <other units or external>
- **Blocks**: <units that depend on this>

## Risks

- <Risk specific to this Unit>
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
    ↓ linked in Epic description
Jira Intent Epic
    ↓ parent link
Jira Unit (Sub-epic)
    ↓ parent link
Jira Story/Chore
    ↓ referenced in design docs
Domain Design / ADRs
```

Each artifact should reference:
- **Forward**: What it decomposes into
- **Backward**: What it derives from

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

**For Jira operations:**
1. Confirm the Jira project key (never assume a default)
2. Verify issue types using `getJiraProjectIssueTypesMetadata`
3. Get field metadata using `getJiraIssueTypeMetaWithFields` if custom fields are needed
4. Create issues using `createJiraIssue`
5. Link issues to Confluence pages in the description field

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

## Story Elaboration Subagent

The `/planning:aidlc-decompose` skill uses parallel subagents to elaborate stories by theme cluster. This section defines the prompt template and expected return format.

### Theme Clustering Guidance

When identifying theme clusters from an Intent:
- Aim for 3-5 clusters (fewer for small intents, more for complex ones)
- Group by functional area, capability, or technical domain
- Each cluster should have low coupling to other clusters
- Example themes: Authentication, API Layer, Data Migration, UI Components, Reporting

### Subagent Prompt Template

Use this template when spawning story elaboration subagents via the Task tool:

```markdown
You are elaborating User Stories for the "<THEME_NAME>" theme cluster.

## Intent Context

**Intent Summary:** <brief summary of the overall intent>

**Target Users:** <user personas affected>

**NFRs:** <relevant non-functional requirements>

**Constraints:** <any constraints or limitations>

## Stories to Elaborate

Elaborate the following stories for this theme:
<list of story titles/scopes>

## Instructions

For each story:
1. Write the full story content using the Story Markdown Template format
2. Identify risks specific to this story
3. Identify dependencies:
   - Within this theme cluster
   - Cross-cluster dependencies (reference other themes by name)

## Story Markdown Template

Use this format for each story:

# Story: <Story Title>

**Unit**: _pending_ <!-- Assigned after grouping -->
**Jira Key**: _pending_ <!-- Updated after Jira creation -->
**Status**: Draft

## Summary
<Brief description of what this story delivers>

## User Story
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
<Guidance for testing this story>

## Return Format

Return your results as JSON in this exact structure:

{
  "theme": "<THEME_NAME>",
  "stories": [
    {
      "title": "<story title>",
      "content": "<full markdown content for the story>",
      "risks": ["<risk 1>", "<risk 2>"],
      "dependencies": {
        "within_theme": ["<story title in same theme>"],
        "cross_theme": ["<Theme Name>: <story or capability>"]
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
| `stories` | array | Array of elaborated stories |
| `stories[].title` | string | Story title |
| `stories[].content` | string | Full markdown content for the story file |
| `stories[].risks` | array | Risks specific to this story |
| `stories[].dependencies.within_theme` | array | Dependencies on other stories in the same theme |
| `stories[].dependencies.cross_theme` | array | Dependencies on other themes (format: "Theme: capability") |
| `cross_cutting_concerns` | array | Concerns that span multiple themes |

### Consolidation Logic

After collecting results from all subagents, the parent agent:

1. **Parse results**: Extract stories from each subagent's JSON response
2. **Merge risks**: Combine all `cross_cutting_concerns` into a unified list
3. **Build dependency graph**: Map `cross_theme` dependencies to actual stories
4. **Identify conflicts**: Flag stories with conflicting assumptions or overlapping scope
5. **Group into Units**:
   - Start with theme boundaries
   - Merge themes with tight coupling
   - Split themes with clear sub-boundaries
6. **Assign Unit slugs**: Add unit prefix to each story filename
