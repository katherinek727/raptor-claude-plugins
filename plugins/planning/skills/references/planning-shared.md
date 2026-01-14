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
- Pathway Type (green-field | brown-field | modernization | defect fix)
- Outcomes (Business + User)
- Scope
  - In scope
  - Out of scope
- Constraints
- Non-Functional Requirements (NFRs)
- Measurement Criteria (OKR/KPI/SLI)
- Dependencies
- Risks (use Organizational Risk Taxonomy below; prioritize Data & Privacy and Security Posture)
- Assumptions
- Testing Strategy (see Testing Strategy Guidance below)
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
- `/aidlc-plan`: Initialize status table with "Level 1 Intent: ✅ Approved"
- `/aidlc-create-epic`: Update table + add `aidlc:epic-created` label
- `/aidlc-decompose`: Update table + transition labels
- `/aidlc-design`: Update table + transition labels

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

- Performance/latency targets
- Availability/SLA
- Security and privacy
- Compliance (SOC2, HIPAA, GDPR, etc.)
- Reliability/recovery objectives
- Observability requirements
- Cost constraints

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

When using Atlassian MCP tools, follow this sequence:

**For Confluence operations:**
1. Get the Confluence cloud ID (may be implicit in some MCP configurations)
2. Find the target space using `getConfluenceSpaces` or user-provided space key
3. Locate the parent page using `searchConfluenceUsingCql` or `getPagesInConfluenceSpace`
4. Create or update the page using `createConfluencePage` or `updateConfluencePage`
5. If the page already exists, ask whether to update or create a new version

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
