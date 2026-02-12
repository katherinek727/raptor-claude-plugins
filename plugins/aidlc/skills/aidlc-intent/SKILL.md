---
name: aidlc-intent
description: Create and iteratively refine the AI-DLC Intent documentation in Confluence, with human-in-the-loop validation, risk surfacing, NFRs, and measurement criteria. Use when asked to draft or update an Intent, initiative doc, or Confluence planning document before Jira work is created. (Triggers - create intent, intent document, new initiative, draft intent, planning doc, intent brief, confluence intent, aidlc plan)
---

# AI-DLC Plan Intent

Produce the Intent documentation in Confluence as the single source of truth for the project idea. Emphasize iteration, human approval, and risk visibility before any Jira artifacts are created.

> **IMPORTANT: Keep Intent Docs Lightweight**
>
> Intent documents capture WHAT needs to be achieved, not HOW to break it down.
> - Do NOT include detailed unit decomposition or Task breakdowns
> - Do NOT create Jira artifacts at this stage
> - Unit breakdown happens later in `/aidlc-elaborate` (Mob Elaboration)
> - You may include "Proposed Units (hypotheses only)" as rough scope indicators

## Completion Checklist

> **IMPORTANT**: Create tasks for each step at the start using `TodoWrite`. Mark tasks complete as you go using `TodoWrite`. Each task description should reference the corresponding Workflow step.

| # | Task | Depends On | Workflow Reference | Exit Criteria |
|---|------|------------|-------------------|---------------|
| 1 | Gather context | — | Workflow > Step 1 | All required fields collected (name, users, pathway, scope, NFRs, risks) |
| 2 | Gather repo context | 1 | Workflow > Step 2 | Repo README and key files read, or N/A confirmed |
| 3 | Confirm understanding | 1, 2 | Workflow > Step 3 | User confirms 5-8 bullet summary is correct |
| 4 | Draft Level 1 doc | 3 | Workflow > Step 4 | Draft follows template, all sections populated |
| 5 | Review and iterate | 4 | Workflow > Step 5 | User says "approved" or "looks good" |
| 6 | Create Confluence page | 5 | Workflow > Step 6 | Page created, URL returned |
| 7 | Get explicit approval | 6 | Workflow > Step 7 | User explicitly approves the Intent |
| 8 | Update workflow status | 7 | Workflow > Step 8 | Status table shows "Level 1 Intent: ✅ Approved" |

## Task Tracking

When this skill is invoked:

1. **Create tasks** for the current phase's checklist items using `TodoWrite`
   - Include a reference to the workflow step in the task description (content field)
   - Set activeForm appropriately (e.g., "Gathering context" for content "Gather context (See Workflow > Step 1)")
   - Example: `"Gather context (See Workflow > Step 1)"`
2. **Mark task as in_progress** when starting each step using `TodoWrite` (update status)
3. **Mark task complete** when the exit criteria are met using `TodoWrite` (update status)
4. **Verify all tasks complete** before finishing the skill

This ensures visibility into progress and prevents incomplete execution.

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI proposes** — Present options, recommendations, and trade-offs
2. **Human approves** — Validate, select, or adjust
3. **AI elaborates** — Expand on approved direction
4. **Human confirms** — Final approval before artifact creation

At each step, AI should:
- Ask clarifying questions proactively
- Propose multiple options where applicable
- Surface risks and trade-offs upfront
- Request explicit approval before proceeding

## Example Invocations

- "Create an Intent doc for the new authentication system"
- "Draft an intent document for adding dark mode"
- "Help me create a Confluence intent brief for the billing overhaul"
- "Start a new initiative doc for the API migration"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for templates, prompts, and Jira/Confluence tool names.

## Optional Artifacts

### PRFAQ (Press Release / FAQ)
If requested, generate a PRFAQ to communicate the Intent's value proposition:
- **Press Release**: What is being built and why it matters
- **FAQ**: Anticipated questions from stakeholders

Include in Confluence doc as a collapsible section or separate child page. See PRFAQ Template in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md.

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Intent name and short description
   - Target users and business outcomes
   - Pathway type (green-field, brown-field, modernization, defect fix)
   - Scope boundaries (in/out)
   - NFRs (performance, reliability, security, compliance, privacy)
   - Measurement criteria (KPIs/OKRs/SLIs + baseline if known)
   - Known dependencies and assumptions
   - Known risks (use Organizational Risk Taxonomy in shared ref; prioritize Data & Privacy and Security Posture)
   - Testing strategy preferences (see Testing Strategy Guidance in shared ref)
   - Existing Confluence pages or Jira issues to reference
   - Confluence space (default `raptorepd` unless specified)
   - Whether to search Confluence for related docs
   - Repositories/services in scope (local paths or remote URLs)
   - Whether to generate a PRFAQ (optional)

2. **Gather repo context (if applicable)**
   When the Intent involves code changes, follow the Repo Context Gathering guidance in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md to understand the technical landscape.

3. **Confirm understanding**
   Summarize in 5-8 bullets and ask for corrections before drafting.

4. **Draft Intent documentation**
   Use the template in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md. Keep it concise and scannable.

5. **Review and iterate**
   Share the draft and ask for approval. Revise until approved.

6. **Create or update the Confluence page**
   Use Atlassian MCP to create or update the page in the chosen space. If a parent page is needed, ask where to place it.
   Include the Workflow Status table from @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md.

7. **Approval gate**
   Explicitly ask whether the Intent documentation is approved.

8. **Update workflow status**
   When approved, update the Confluence page status table:
   - Set "Intent" row to "✅ Approved" with today's date

9. **Chain to Decompose**
   If approved and the user wants to proceed, invoke `/aidlc-elaborate` with the Confluence page link. Pass along the Intent name and any context gathered. Note: Jira artifacts are created later, after Mob Elaboration and Unit Re-assessment.

## Workflow Chain

- **This is the first step** in the AI-DLC planning workflow
- **Next**: `/aidlc-elaborate` (Mob Elaboration - Unit and Task decomposition)

## Definition of Done

- Confluence Intent document exists and is approved.
- Risks, NFRs, measurement criteria, and testing strategy are explicitly documented.
- Approval to proceed to elaboration is explicitly confirmed.

## Troubleshooting

- **Space not found**: Confirm the space key and permissions.
- **Parent page missing**: Ask for the correct parent or create at space root.
- **Conflicting docs**: Ask whether to update or create a new page.
