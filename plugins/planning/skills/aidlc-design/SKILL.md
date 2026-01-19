---
name: aidlc-design
description: Guide the Construction Phase with Domain Design, Logical Design, and Architecture Decision Records (ADRs). Use after Units and Stories are created to bridge planning to implementation. (Triggers - domain design, logical design, create ADR, architecture decision, aidlc design, construction phase, model domain)
---

# AI-DLC Design

Bridge from planning to implementation by creating Domain Designs, Logical Designs, and ADRs for approved Units.

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI proposes** — Present domain models, patterns, and trade-offs
2. **Human approves** — Validate, select, or adjust
3. **AI elaborates** — Expand designs based on feedback
4. **Human confirms** — Final approval before documentation

## Example Invocations

- "Create the domain model for the authentication unit"
- "Design the logical architecture for the billing service"
- "Generate ADRs for the API migration"
- "Help me model the recommendation engine domain"
- "What architectural patterns should we use for this unit?"

## References

- Use `../references/planning-shared.md` for DDD guidance, ADR templates, and tool names.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Level 1 Intent document (ask for link)
   - Jira Intent Epic (ask for key)
   - At least one Jira Unit (Sub-epic) with Stories (ask for key)
   - Fetch all using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Unit Decomposition" row shows "✅ Complete"

3. **If prerequisites incomplete**
   - Offer to run `/planning:aidlc-decompose` first (or earlier skills if those are missing)
   - Or allow override with explicit confirmation (see Override Pattern in `../references/planning-shared.md`)

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Unit key and linked Intent Epic
   - User Stories within the Unit
   - Relevant NFRs (performance, security, scalability, etc.)
   - Existing codebase context (for brown-field)
   - Any architectural constraints or preferences

2. **Domain Design** (DDD)
   AI proposes domain model using DDD principles:
   - Identify Bounded Context boundaries
   - Define Aggregates and Aggregate Roots
   - Model Entities and Value Objects
   - Identify Domain Events
   - Define Repositories and Factories
   - Apply Ubiquitous Language from the Intent

   Present the model and ask for validation before proceeding.

3. **Logical Design**
   Extend domain model for NFRs:
   - Recommend architectural patterns (CQRS, Event Sourcing, Saga, etc.)
   - Propose integration patterns (API Gateway, Circuit Breaker, etc.)
   - Suggest data storage approach
   - Address security architecture
   - Consider observability requirements

   Present trade-offs and ask for decisions.

4. **Create ADRs**
   For each significant decision, create an ADR:
   - Context: What prompted this decision?
   - Decision: What was decided?
   - Consequences: Trade-offs and implications
   - Alternatives considered

   Use the ADR Template in `../references/planning-shared.md`.

5. **Confirm understanding**
   Summarize:
   - Domain model components
   - Architectural patterns selected
   - Key ADRs
   Ask for approval before storing artifacts.

6. **Store artifacts**
   - Domain model: Markdown or diagram in Confluence (child of Intent doc)
   - ADRs: Confluence pages or repo `docs/adr/` folder
   - Link back to Unit in Jira
   - Update Unit description with design doc links
   - Update Intent Epic label: `aidlc:designing` → `aidlc:designed`

7. **Update workflow status**
   Update the Confluence page status table:
   - Set "Domain Design" row to "✅ Complete" with today's date
   - Add links to design docs in the Artifact column

8. **Report back**
   Provide links to created artifacts and ask for any refinements.

## Brown-Field Considerations

For existing systems, add these steps before Domain Design:

1. **Reverse engineer existing models**
   - Static models: Components, responsibilities, relationships
   - Dynamic models: How components interact for key use cases

2. **Design Anti-Corruption Layer**
   - Translate between legacy and new domain models
   - Isolate the new domain from legacy quirks
   - Enable gradual migration

## Workflow Chain

- **Previous**: `/planning:aidlc-decompose` (Unit and Story creation)
- **Next**: Implementation (Bolts, code generation)

## Definition of Done

- Domain model documented and approved
- Logical design with architectural patterns documented
- ADRs created for key decisions
- Artifacts linked to Unit and Intent
- Brown-field ACL designed (if applicable)

## Troubleshooting

- **Complex domain**: Break into smaller Bounded Contexts; consider multiple Units
- **Conflicting NFRs**: Surface trade-offs explicitly; create ADR for resolution
- **Legacy integration**: Design ACL before extending domain model
- **Missing context**: Gather more repo context or request architecture diagrams
