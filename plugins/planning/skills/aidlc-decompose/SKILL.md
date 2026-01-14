---
name: aidlc-decompose
description: Decompose an approved Intent into User Stories and Units, with human-in-the-loop validation, risk surfacing, and Bolt planning. Default approach elaborates Stories first, then groups into Units. Use when asked to break down an Intent or create Units and stories in Jira. (Triggers: decompose intent, break down intent, create units, unit decomposition, create stories, break into units, split intent, aidlc decompose)
---

# AI-DLC Decompose

Break down an approved Intent into User Stories and Units (Sub-epics). Default approach: elaborate Stories first, then group into cohesive Units. Do not create Bugs unless explicitly requested by a human.

## Example Invocations

- "Break down the authentication intent into stories and units"
- "Decompose the billing epic"
- "Create units and stories for the API migration intent"
- "Split the approved intent into work items"

## References

- Use `../references/planning-shared.md` for templates, Bolt guidance, and Jira tool names.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Level 1 Intent document (ask for link)
   - Jira Intent Epic (ask for key)
   - Fetch both using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Intent Epic" row shows "✅ Created"

3. **If prerequisites incomplete**
   - Offer to run `/aidlc-create-epic` first (or `/aidlc-plan` if Confluence doc missing)
   - Or allow override with explicit confirmation (see Override Pattern in `../references/planning-shared.md`)

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Jira project key (no default)
   - Intent Epic key
   - Approved Confluence Level 1 doc link(s)
   - Any known constraints, dependencies, or sequencing needs
   - **Decomposition approach preference**:
     - Stories-first (default): Elaborate all Stories, then group into Units
     - Units-first: Define Unit boundaries, then elaborate Stories per Unit

2. **Elaborate User Stories** (Stories-first, default)
   From the Intent and Level 1 documentation:
   - Propose User Stories with Acceptance Criteria
   - Surface risks and dependencies per Story
   - Identify cross-cutting concerns
   - Ask for validation before grouping

   **OR Units-first** (if selected):
   - Propose Units with clear boundaries first
   - Then elaborate Stories for each Unit

3. **Group into Units**
   Organize Stories into cohesive Units:
   - Apply loose coupling, high cohesion principles
   - Each Unit should deliver independent value
   - Surface dependencies between Units
   - Confirm grouping before creation

4. **Plan Bolts**
   For each Unit, suggest rapid iteration cycles:
   - Bolt boundaries based on testable increments
   - Estimated duration (hours/days)
   - Sequencing considerations
   - See Bolt Planning Guidance in `../references/planning-shared.md`

5. **Confirm understanding**
   Summarize the full decomposition:
   - Stories grouped by Unit
   - Bolt plan per Unit
   - Dependencies and risks
   Ask for approval before creating Jira items.

6. **Create Jira artifacts**
   - Create Units as Sub-epics (or Epics if Sub-epic unavailable)
   - Create Stories/Chores under each Unit
   - Include acceptance criteria, test notes, and links
   - Use templates in `../references/planning-shared.md`
   - Update Intent Epic label: `aidlc:decomposing` → `aidlc:decomposed`

7. **Update workflow status**
   Update the Confluence page status table:
   - Set "Unit Decomposition" row to "✅ Complete" with today's date
   - Add links to created Units in the Artifact column

8. **Report back**
   Provide created keys and ask for any refinements.

9. **Chain to Design**
   Ask whether to proceed with Domain Design for any Unit.
   If yes, invoke `/aidlc-design` with the Unit context.

## Workflow Chain

- **Previous**: `/aidlc-create-epic` (Intent Epic creation)
- **Next**: `/aidlc-design` (Domain and Logical Design)

## Definition of Done

- User Stories elaborated with acceptance criteria
- Stories grouped into cohesive Units (Sub-epics)
- Units linked to Intent Epic
- Bolt plan suggested per Unit
- Risks and dependencies explicit

## Troubleshooting

- **Sub-epic not supported**: Use Epic + issue links or parent field; ask for preferred structure.
- **Missing issue types**: Use `getJiraProjectIssueTypesMetadata` and confirm available types.
- **Too many Stories**: Consider splitting into multiple Units or deferring lower-priority Stories.
