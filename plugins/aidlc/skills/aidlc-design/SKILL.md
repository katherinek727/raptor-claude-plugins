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

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for DDD guidance, ADR templates, and tool names.
- Use @${CLAUDE_PLUGIN_ROOT}/references/technical-guidance/global.md for universal architectural standards.
- Use @${CLAUDE_PLUGIN_ROOT}/references/technical-guidance/dotnet.md for .NET projects (in addition to global)

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Intent document (ask for link)
   - Units Overview page with Unit and Task child pages in Confluence
   - Fetch all using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Unit Decomposition" row shows "✅ Complete"

3. **If prerequisites incomplete**
   - Offer to run `/aidlc-elaborate` first (or `/aidlc-intent` if Confluence doc missing)
   - Or allow override with explicit confirmation (see Override Pattern in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md)

## Workflow

1. **Gather context**
   Ask only for what is missing:
   - Unit to design (from Confluence Units Overview page)
   - Tasks within the Unit (from Confluence child pages)
   - Relevant NFRs (performance, security, scalability, etc.)
   - Existing codebase context (for brown-field)
   - Project-level technical guidance (from Intent doc "Technical Guidance" section)

2. **Detect and confirm project type**
   Check if the project is .NET by looking for markers:

   | Markers | Project Type | Guidance Applied |
   |---------|--------------|------------------|
   | *.csproj, *.sln, *.slnx, *.cs, global.json | .NET | Global + .NET |
   | Any other stack | Other | Global only |

   Present the detection and ask for confirmation:
   > Based on the repository, this appears to be a **.NET** project.
   >
   > Applicable technical guidance:
   > - Global standards (all projects)
   > - .NET standards (ASP.NET Core, EF Core, etc.)
   > - Project-level guidance (from Intent doc)
   >
   > Is this correct?

   If not a .NET project:
   > This project will use **Global standards** only, plus any project-level guidance from the Intent doc.
   >
   > Applicable technical guidance:
   > - Global standards (all projects)
   > - Project-level guidance (from Intent doc)

3. **Assess confidence**
   Before proceeding to Domain Design, assess whether you have sufficient context.

   ### Required Context Checklist

   For the Unit being designed, verify:
   - [ ] Unit scope is bounded (no "and more", "etc.", open-ended language)
   - [ ] At least 2 Tasks exist with acceptance criteria
   - [ ] NFRs have measurable targets (not just "fast" or "secure")
   - [ ] Integration points are identified (APIs, services, databases)
   - [ ] For brownfield: existing code patterns are understood

   ### Confidence Scoring

   Rate each factor 0-20 points:

   | Factor | Score | Notes |
   |--------|-------|-------|
   | Unit scope clarity | /20 | Clear boundaries, defined outcomes |
   | Task quality | /20 | Testable acceptance criteria |
   | NFR specificity | /20 | Measurable targets with baselines |
   | Technical context | /20 | Integration points, dependencies known |
   | Architectural constraints | /20 | Patterns, limitations documented |
   | **Total** | /100 | |

   ### Confidence Thresholds

   - **≥60%**: Proceed with design, noting any gaps in the design documentation
   - **<60%**: STOP - ask targeted questions before continuing

   If confidence is low, ask specific questions like:
   - "What is the expected response time for this API?"
   - "Which existing services will this Unit integrate with?"
   - "Are there security requirements beyond standard authentication?"
   - "What data storage approach is preferred (SQL, NoSQL, etc.)?"

4. **Domain Design** (DDD)
   AI proposes domain model using DDD principles:
   - Identify Bounded Context boundaries
   - Define Aggregates and Aggregate Roots
   - Model Entities and Value Objects
   - Identify Domain Events
   - Define Repositories and Factories
   - Apply Ubiquitous Language from the Intent

   Present the model and ask for validation before proceeding.

5. **Logical Design**
   Incorporate technical guidance (in precedence order):

   | Tier | Source | Precedence |
   |------|--------|------------|
   | Global | `references/technical-guidance/global.md` | Baseline (all projects) |
   | .NET | `references/technical-guidance/dotnet.md` | Extends global (.NET projects only) |
   | Project-Level | Intent doc "Technical Guidance" section | Highest precedence |

   **Guidance application:**
   - Load global guidance as the baseline
   - If .NET project: layer .NET-specific guidance
   - Apply project-level overrides from the Intent doc
   - When guidance conflicts, project-level > .NET > global

   **Conflict detection:**
   When project-level or project-type guidance contradicts a higher tier:
   1. Surface the conflict explicitly:
      > **Guidance Conflict Detected**
      >
      > - **Global standard:** [standard from global.md]
      > - **Project guidance:** [conflicting guidance from Intent doc]
      >
      > This deviation will require an ADR. Proceed with the project-level guidance?
   2. If confirmed, flag for ADR creation in step 6

   **Design recommendations:**
   Using the merged guidance, extend the domain model for NFRs:
   - Recommend architectural patterns (CQRS, Event Sourcing, Saga, etc.)
   - Propose integration patterns (API Gateway, Circuit Breaker, etc.)
   - Suggest data storage approach aligned with guidance
   - Address security architecture per guidance standards
   - Consider observability requirements from guidance

   Present trade-offs and ask for decisions.

6. **Create ADRs**
   For each significant decision, create an ADR:
   - Context: What prompted this decision?
   - Decision: What was decided?
   - Consequences: Trade-offs and implications
   - Alternatives considered

   **Guidance deviation ADRs:**
   For each conflict flagged in step 5, create an ADR with:
   - **Context:** Reference the specific standard being deviated from (tier, section)
   - **Decision:** The project-level choice and why it takes precedence
   - **Consequences:** Include risks of deviating from organizational standards
   - **Alternatives:** Document "follow the standard" as a rejected alternative with rationale

   Example title: "ADR-NNN: Use GraphQL instead of REST (deviation from Global API Standards)"

   Use the ADR Template in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md.

7. **Confirm understanding**
   Summarize:
   - Domain model components
   - Architectural patterns selected
   - Technical guidance applied (with tiers noted)
   - Any guidance deviations and their ADRs
   - Key ADRs
   Ask for approval before storing artifacts.

8. **Store artifacts**
   - Domain model: Markdown or diagram in Confluence (child of Intent doc)
   - ADRs: Confluence pages or repo `docs/adr/` folder
   - Guidance deviation ADRs: Include reference to the standard being deviated from
   - Link back to Unit page in Confluence
   - Update Unit page with design doc links

9. **Update workflow status**
   Update the Confluence page status table:
   - Set "Domain Design" row to "✅ Complete" with today's date
   - Add links to design docs in the Artifact column

10. **Report back and chain to verify**
    Provide links to created artifacts and ask for any refinements.
    When design is complete, offer to run `/aidlc-verify` to assess readiness for Jira transfer.

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

- **Previous**: `/aidlc-elaborate` (Unit and Task creation in Confluence)
- **Next**: `/aidlc-verify` (Verification and Jira transfer)

## Definition of Done

- Project type detected (.NET or other) and confirmed
- Technical guidance loaded (global, + .NET if applicable, + project-level)
- Confidence assessment completed (≥60% to proceed)
- Domain model documented and approved
- Logical design with architectural patterns documented
- Guidance conflicts surfaced and confirmed
- ADRs created for key decisions
- Deviation ADRs created for any guidance conflicts
- Artifacts linked to Unit page in Confluence and Intent doc
- Brown-field ACL designed (if applicable)
- Workflow status table updated in Confluence

## Troubleshooting

- **Complex domain**: Break into smaller Bounded Contexts; consider multiple Units
- **Conflicting NFRs**: Surface trade-offs explicitly; create ADR for resolution
- **Legacy integration**: Design ACL before extending domain model
- **Missing context**: Gather more repo context or request architecture diagrams
