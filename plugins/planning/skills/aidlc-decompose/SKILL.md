---
name: aidlc-decompose
description: Decompose an approved Intent into Units and Jira work items (Sub-epic → Story/Chore), with human-in-the-loop validation, risk surfacing, and acceptance criteria. Use when asked to break down an Intent or create Units and stories in Jira. (Triggers: decompose intent, break down intent, create units, unit decomposition, create stories, break into units, split intent, aidlc decompose)
---

# AI-DLC Decompose Units

Break down an approved Intent into Units (Sub-epics) and work items (Story/Chore). Do not create Bugs unless explicitly requested by a human.

## Example Invocations

- "Break down the authentication intent into units"
- "Decompose the billing epic into stories"
- "Create units and stories for the API migration intent"
- "Split the approved intent into sub-epics and work items"

## References

- Use `references/planning-shared.md` for templates, prompts, and Jira tool names.

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Jira project key (no default)
   - Intent Epic key
   - Approved Confluence Level 1 doc link(s)
   - Any known constraints, dependencies, or sequencing needs

2. **Propose Units**
   Suggest loosely coupled, cohesive Units with clear value boundaries. Surface risks and dependencies per Unit.

3. **Confirm understanding**
   Summarize Units + rationale in 5-8 bullets and ask for approval before creating Jira items.

4. **Create Units (Sub-epics)**
   Use the template in `references/planning-shared.md` and include:
   - Scope summary
   - Acceptance criteria
   - NFRs relevant to the Unit
   - Risks and dependencies
   - Testing approach for this Unit (reference Testing Strategy Guidance in shared ref)
   - Link to Intent Epic and Confluence docs

5. **Create work items**
   For each Unit, create Stories/Chores with acceptance criteria and test notes where applicable. Ask before creating any Bugs.

6. **Report back**
   Provide created keys and ask for any refinements or sequencing changes.

## Workflow Chain

- **Previous**: `/aidlc-create-epic` (Intent Epic creation)
- **This is the final step** in the AI-DLC planning workflow

## Definition of Done

- Units created as Sub-epics linked to the Intent Epic.
- Stories/Chores created under each Unit with acceptance criteria.
- Risks and dependencies are explicit.

## Troubleshooting

- **Sub-epic not supported**: Use Epic + issue links or parent field and ask for the preferred structure.
- **Missing issue types**: Use `getJiraProjectIssueTypesMetadata` and confirm available types.
