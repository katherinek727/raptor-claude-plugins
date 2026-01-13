# Planning Shared Guidance

Use this reference for both initiative briefs and phase plans.

## Iteration Loop

1. Ask targeted questions to fill gaps.
2. Summarize understanding (5-8 bullets).
3. Ask for confirmation or corrections.
4. Draft the document.
5. Share for review and revise.

## Context Discovery (Questions + Suggestions)

Ask only what is missing and suggest common gaps:

- What problem are we solving and who are the users?
- What repositories/services are in scope?
- Are there existing docs or prior initiatives to reference?
- Known constraints (timeline, compliance, security, infra)?
- Dependencies on other teams or systems?
- Preferred success metric format (OKR/KPI/SLI)?
- Any technology choices already decided?

When helpful, suggest likely additions (e.g., analytics, migration plan, rollout strategy, support readiness).

## Repo/Code Context Sources

Prefer local repos when available; otherwise use GitLab MCP or `glab`.

**Local repo**:
- Ask for the local path or confirm which repos are checked out.
- Read README and any `docs/` or architecture notes.

**GitLab MCP**:
- Find project by path or name.
- Fetch README and key docs (architecture, ADRs, onboarding).

**glab CLI** (if available):
- Use `glab repo view <group/project>` to confirm repo metadata.
- Use `glab api` to fetch README or docs when MCP is unavailable.

## Atlassian MCP Tool Names (Rovo)

Use these tool names from the Atlassian Rovo MCP Server. In Claude Code, tools are namespaced with the `mcp__plugin_atlassian_atlassian__` prefix.

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

## GitLab MCP Tool Names

If using GitLab MCP, common tools include (namespacing varies by client):

| Tool | Purpose |
|------|---------|
| `getProject` | Get project metadata by path or ID |
| `getProjectReadme` | Fetch the README file content |
| `getRepositoryTree` | List files/directories in a repo |
| `getFileContent` | Read a specific file from the repo |
| `searchProjects` | Search for projects by name |

**glab CLI fallback**: If GitLab MCP is unavailable, use the `glab` CLI:
- `glab repo view <group/project>` - View repo metadata
- `glab api projects/:id/repository/files/:path/raw` - Fetch file content

## Confluence Initiative Brief Template

- Overview
- Problem / Opportunity
- Objectives
- Scope
  - In scope
  - Out of scope
- Acceptance Criteria
- Success Metrics
- Testing Strategy
- Dependencies
- Risks
- Assumptions
- Open Questions

## Example Initiative Brief (SaaS feature)

### Overview
Add usage-based alerts for enterprise tenants to reduce unexpected overages and improve account retention.

### Problem / Opportunity
Enterprise customers discover overages after the fact, creating billing disputes and churn risk.

### Objectives
- Reduce overage disputes by 40% within two quarters.
- Give admins real-time visibility into usage thresholds.

### Scope
In scope:
- Alert thresholds per workspace
- Email + in-app notifications
- Admin UI for managing thresholds

Out of scope:
- Billing plan changes
- SMS notifications

### Acceptance Criteria
- Admins can set thresholds at 50/75/90% of monthly quota.
- Alerts are delivered within 5 minutes of threshold crossing.
- Audit log records threshold changes and alert sends.

### Success Metrics
- KPI: % of overage disputes per month
- SLI: Alert delivery latency p95 < 5 minutes

### Testing Strategy
- Automated tests in CI/CD for rules and notification delivery
- Manual QA for admin UI flows
- E2E tests only for the admin UI surface

### Dependencies
- Usage aggregation service API
- Notification service templates

### Risks
- Usage aggregation delays may cause late alerts.

### Assumptions
- Usage data is available within 2 minutes of event ingestion.

### Open Questions
- Should alerts be configurable per team or workspace only?

## Phase Plan Template

- Delivery Approach (summary)
- Phases
  - Phase N: Name
    - Objective
    - Scope
    - Deliverables
    - Parallel Workstreams
    - Dependencies
    - Technology Choices
    - Testing Strategy
    - Exit Criteria
- Cross-Cutting Concerns
  - Security / Compliance
  - Observability / Metrics
  - Documentation

## Testing Guidance

- Always include automated tests in CI/CD
- Include manual QA for exploratory testing
- Add E2E tests only for user-facing frontends
- Avoid E2E for internal tooling unless explicitly requested
- Call out integration/contract tests when services interact
