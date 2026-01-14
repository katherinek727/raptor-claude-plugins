---
name: aidlc-plan
description: Create and iteratively refine the AI-DLC Level 1 Intent documentation in Confluence, with human-in-the-loop validation, risk surfacing, NFRs, and measurement criteria. Use when asked to draft or update an Intent/Level 1 plan, initiative doc, or Confluence planning document before Jira work is created. (Triggers: create intent, level 1 doc, intent document, new initiative, draft intent, planning doc, intent brief, confluence intent, aidlc plan)
---

# AI-DLC Plan Intent

Produce the Level 1 Intent documentation in Confluence as the single source of truth for the project idea. Emphasize iteration, human approval, and risk visibility before any Jira artifacts are created.

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

- "Create a Level 1 Intent doc for the new authentication system"
- "Draft an intent document for adding dark mode"
- "Help me create a Confluence intent brief for the billing overhaul"
- "Start a new initiative doc for the API migration"

## References

- Use `references/planning-shared.md` for templates, prompts, and Jira/Confluence tool names.

## Optional Artifacts

### PRFAQ (Press Release / FAQ)
If requested, generate a PRFAQ to communicate the Intent's value proposition:
- **Press Release**: What is being built and why it matters
- **FAQ**: Anticipated questions from stakeholders

Include in Confluence doc as a collapsible section or separate child page. See PRFAQ Template in `references/planning-shared.md`.

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
   When the Intent involves code changes, follow the Repo Context Gathering guidance in `references/planning-shared.md` to understand the technical landscape.

3. **Confirm understanding**
   Summarize in 5-8 bullets and ask for corrections before drafting.

4. **Draft Level 1 documentation**
   Use the template in `references/planning-shared.md`. Keep it concise and scannable.

5. **Review and iterate**
   Share the draft and ask for approval. Revise until approved.

6. **Create or update the Confluence page**
   Use Atlassian MCP to create or update the page in the chosen space. If a parent page is needed, ask where to place it.

7. **Approval gate**
   Explicitly ask whether the Level 1 documentation is approved.

8. **Chain to Epic creation**
   If approved and the user wants to proceed to Jira, invoke `/aidlc-create-epic` with the Confluence page link. Pass along the Intent name and any context gathered.

## Workflow Chain

- **This is the first step** in the AI-DLC planning workflow
- **Next**: `/aidlc-create-epic` (Intent Epic creation)

## Definition of Done

- Confluence Level 1 Intent document exists and is approved.
- Risks, NFRs, measurement criteria, and testing strategy are explicitly documented.
- Approval to proceed to Jira is explicitly confirmed.

## Troubleshooting

- **Space not found**: Confirm the space key and permissions.
- **Parent page missing**: Ask for the correct parent or create at space root.
- **Conflicting docs**: Ask whether to update or create a new page.
