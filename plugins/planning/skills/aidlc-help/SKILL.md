---
name: aidlc-help
description: Explain AI-DLC methodology, available skills, and how to use this plugin. Use when users ask "what is AI-DLC", "how do I use planning", "what skills are available", or need guidance on the workflow. (Triggers - aidlc help, what is aidlc, explain aidlc, planning help, how to plan, ai-dlc)
---

# AI-DLC Help

Explain the AI-DLC methodology and guide users through the planning plugin.

## References

- Use `../references/aidlc-methodology.md` for detailed methodology documentation
- Use `../references/planning-shared.md` for templates and operational guidance

## What is AI-DLC?

AI-DLC (AI-Driven Development Lifecycle) is a methodology that puts AI at the center of the development process. It was developed by AWS as an AI-native approach to software engineering.

### Core Idea

**Traditional methods:** Human initiates, AI assists
**AI-DLC:** AI proposes, human approves

This reversal allows developers to focus on high-value decision-making while AI handles planning, task decomposition, and execution.

### Key Principles

1. **Reimagine Rather Than Retrofit** - Don't force AI into old methods; design for AI capabilities
2. **Reverse the Conversation Direction** - AI drives workflows, humans validate and approve
3. **Integration of Design Techniques** - DDD, BDD, TDD are core, not optional add-ons
4. **Align with AI Capability** - Balance AI strengths with human oversight
5. **Build Complex Systems** - Designed for architectural complexity, not simple scripts
6. **Retain Human Symbiosis** - Keep artifacts that enable validation and risk mitigation
7. **Facilitate Transition** - Familiar concepts with modernized terminology
8. **Streamline Responsibilities** - Developers transcend traditional silos
9. **Minimize Stages, Maximize Flow** - Continuous iteration with strategic checkpoints
10. **No Opinionated Workflows** - AI recommends approach based on context

### Core Artifacts

| Artifact | Description | Analogy |
|----------|-------------|---------|
| **Intent** | High-level statement of purpose | Product vision / Epic description |
| **Unit** | Cohesive, self-contained work element | DDD Subdomain / Scrum Epic |
| **Bolt** | Smallest iteration cycle (hours/days) | Sprint (but much shorter) |
| **Domain Design** | Business logic model | DDD tactical patterns |
| **Logical Design** | Domain + NFRs + patterns | Architecture design |
| **Deployment Unit** | Packaged executable + config | Deployable artifact |

## Available Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/planning:aidlc-plan` | Create Level 1 Intent docs in Confluence | Starting a new initiative |
| `/planning:aidlc-decompose` | Break Intent into Stories & Units in Confluence | After Intent is approved |
| `/planning:aidlc-design` | Domain Design & ADRs with confidence assessment | After Units are created |
| `/planning:aidlc-verify` | Verify docs & transfer to Jira | After design, before implementation |
| `/planning:aidlc-help` | This help guide | When you need guidance |

## Workflow Order

```
1. /planning:aidlc-plan
   |
   v (Intent approved in Confluence)
2. /planning:aidlc-decompose
   |
   v (Stories & Units created in Confluence, reviewed, reorganized)
3. /planning:aidlc-design
   |
   v (Domain model & ADRs documented, confidence assessed)
4. /planning:aidlc-verify
   |
   v (Documentation verified, transferred to Jira)
5. Implementation
```

### Phase 1: Intent Documentation (`/planning:aidlc-plan`)

Creates a Level 1 Intent document in Confluence containing:
- Problem/Opportunity statement
- Target users and outcomes
- Scope (in/out)
- Technical considerations
- NFRs and measurement criteria
- Risks and assumptions
- Proposed Units (hypotheses)

**Output:** Approved Confluence document with workflow status tracking

### Phase 2: Decomposition (`/planning:aidlc-decompose`)

Breaks the Intent into actionable work using Mob Elaboration:
1. Theme clusters identified
2. Stories elaborated in parallel (subagents)
3. Stories grouped into Units
4. Confluence pages created for review
5. Team reviews and comments
6. Comments resolved, stories refined
7. Units reorganized based on domain principles

**Output:** Confluence pages for Units and Stories (Jira transfer happens later in verify phase)

### Phase 3: Design (`/planning:aidlc-design`)

Creates design artifacts for implementation with confidence assessment:
1. Assess context sufficiency (confidence check)
2. Domain models (aggregates, entities, value objects)
3. Logical design (patterns, NFR solutions)
4. Architecture Decision Records (ADRs)

**Output:** Design documentation linked to Units in Confluence

### Phase 4: Verification (`/planning:aidlc-verify`)

Verifies documentation completeness and transfers to Jira:
1. Spawn parallel sub-agents to assess each Unit
2. Calculate confidence score across all documentation
3. Identify gaps and provide remediation suggestions
4. If confidence ≥80%, transfer to Jira as Sub-epics and Stories
5. Clean up Confluence decomposition pages

**Output:** Jira artifacts (Sub-epics and Stories) linked to Intent

## Quick Start Guide

### Starting Fresh?

> "I want to plan a new feature for user authentication"
> Use `/planning:aidlc-plan`

This will:
1. Gather requirements through clarifying questions
2. Draft a Level 1 Intent document
3. Create the Confluence page for team review

### Have an Approved Intent?

> "Break down the authentication intent into stories"
> Use `/planning:aidlc-decompose`

This will:
1. Validate the Intent is approved
2. Identify theme clusters
3. Spawn parallel agents to elaborate stories
4. Create Confluence pages for Stories and Units
5. Guide you through review and reorganization

> **Note:** Jira transfer happens later in `/planning:aidlc-verify` after design is complete.

### Ready to Design?

> "Create the domain model for the auth unit"
> Use `/planning:aidlc-design`

This will:
1. Validate Units exist in Confluence
2. Assess context sufficiency (confidence check)
3. Create domain models using DDD principles
4. Document logical design decisions
5. Create ADRs for architectural choices

### Ready to Transfer to Jira?

> "Verify documentation and transfer to Jira"
> Use `/planning:aidlc-verify`

This will:
1. Spawn sub-agents to assess each Unit's documentation
2. Calculate confidence score (needs ≥80% to proceed)
3. Identify gaps and suggest fixes
4. Transfer Units as Sub-epics and Stories to Jira
5. Clean up Confluence decomposition pages

## Key Concepts Explained

### Intent vs Epic

| Intent | Epic |
|--------|------|
| Confluence document | Jira artifact |
| Captures WHAT and WHY (lightweight) | Tracks work items |
| Created first | Created later (if at all) |
| Living document | Work tracking |

### Unit vs Epic

| Unit | Sub-epic |
|------|----------|
| Cohesive work grouping (like DDD Subdomain) | Jira representation of a Unit |
| Designed for loose coupling | Created in Phase 5 of decomposition |
| Enables parallel development | Tracks stories in Jira |

### Bolt vs Sprint

| Bolt | Sprint |
|------|--------|
| Hours to days | 2-4 weeks |
| Intense focus | Planned capacity |
| Testable increment | Shippable increment |
| Multiple per Unit | One at a time |

### Mob Elaboration

A collaborative ritual where AI and humans work together:
- Single room (physical or virtual) with shared screen
- AI proposes breakdown of Intent into Stories and Units
- Team reviews, challenges, and refines
- Condenses weeks of work into hours

## Response Behavior

When this skill is invoked:

1. **Greet the user** and acknowledge their question
2. **Determine their need**:
   - General methodology questions -> Reference `aidlc-methodology.md`
   - Specific skill usage -> Provide targeted guidance
   - Workflow questions -> Explain the process flow
   - Getting started -> Suggest the appropriate skill
3. **Provide clear, concise guidance**
4. **Suggest next steps** based on their context

### Example Interactions

**User:** "What is AI-DLC?"
**Response:** Explain the core concept, key principles, and how it differs from traditional methods.

**User:** "How do I start planning a new feature?"
**Response:** Recommend `/planning:aidlc-plan`, explain what it does, and what they'll need (project context, stakeholder info).

**User:** "What's the difference between a Unit and an Epic?"
**Response:** Explain that Units are cohesive work elements from AI-DLC, while Epics are Jira's work tracking. Units become Sub-epics in Jira.

**User:** "Explain Mob Elaboration"
**Response:** Describe the collaborative ritual, its participants, AI's role, and the outputs.

## Troubleshooting

### "I don't have a Confluence doc yet"

Start with `/planning:aidlc-plan` to create the Level 1 Intent document.

### "I have a Confluence doc but it's not approved"

Review the Workflow Status table in the doc. If "Level 1 Intent" is not "Approved", gather stakeholder approval before proceeding to decomposition.

### "I want to skip the Confluence phase"

While possible with explicit override, Confluence-first is recommended for:
- Team collaboration and review
- Comment resolution before Jira creation
- Traceability between artifacts

### "The skill said my prerequisites are incomplete"

Check that prior phases are complete:
- For `/planning:aidlc-decompose`: Need approved Level 1 Intent in Confluence
- For `/planning:aidlc-design`: Need Units created in Confluence (from decompose phase)
- For `/planning:aidlc-verify`: Need design documentation complete

## Further Reading

For detailed methodology documentation, ask about specific topics:
- "Tell me about the 10 key principles"
- "Explain the Construction Phase"
- "What are Domain Design artifacts?"
- "How does AI-DLC handle brown-field development?"

The methodology reference contains the complete AWS AI-DLC method definition with examples and prompts.
