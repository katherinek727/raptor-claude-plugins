---
name: aidlc-verify
description: Verify documentation completeness and assess AI-execution confidence before transferring to Jira. Uses parallel sub-agents to review Intent, Units, Stories, and Design docs. Identifies gaps and provides remediation suggestions. (Triggers - verify docs, check readiness, transfer to jira, aidlc verify, ready for implementation, confidence check)
---

# AI-DLC Verify

Verify that all documentation (Intent, Units, Stories, Design) is complete and provides sufficient context for AI tooling to execute successfully. Transfer to Jira only when confidence threshold is met.

## AI-Drives-Conversation Pattern

This skill follows the AI-DLC principle where AI initiates and directs the conversation:

1. **AI assesses** — Review all documentation and score confidence
2. **AI reports** — Present gaps and remediation suggestions
3. **Human decides** — Address gaps or approve transfer
4. **AI transfers** — Create Jira artifacts when confidence is sufficient

## Example Invocations

- "Verify the documentation is ready for implementation"
- "Check if we're ready to transfer to Jira"
- "Assess the confidence level for the authentication intent"
- "Are the units ready for AI execution?"

## References

- Use @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md for templates, Jira tool names, and operational guidance.

## Prerequisites

Before starting, validate:

1. **Required artifacts**
   - Confluence Level 1 Intent document (ask for link)
   - Units Overview page with Unit and Story child pages
   - Design documentation (Domain model, ADRs) - optional but improves confidence
   - Fetch all using Atlassian MCP to confirm they exist

2. **Required status**
   - Check the Workflow Status table in the Confluence doc
   - Verify "Unit Decomposition" row shows "✅ Complete"
   - Check if "Domain Design" is complete (improves confidence score)

3. **If prerequisites incomplete**
   - Offer to run `/planning:aidlc-design` first if design is missing
   - Offer to run `/planning:aidlc-decompose` if Units are missing
   - Or allow override with explicit confirmation (see Override Pattern in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md)

## Confidence Assessment Framework

### Scoring Categories

| Category | Weight | Criteria |
|----------|--------|----------|
| **Intent Clarity** | 20% | Problem/scope/outcomes clearly defined, no vague language |
| **Story Completeness** | 25% | All stories have testable acceptance criteria |
| **Design Readiness** | 25% | Domain model documented, patterns chosen, ADRs for key decisions |
| **NFR Coverage** | 15% | Measurable targets (not "fast", "secure"), baselines documented |
| **Dependency Mapping** | 15% | Integration points identified, APIs/services listed, sequencing clear |

### Confidence Thresholds

| Level | Score | Action |
|-------|-------|--------|
| **High** | 80-100% | Proceed to Jira transfer |
| **Medium** | 60-79% | List gaps, ask targeted questions, allow override |
| **Low** | <60% | STOP - must gather more context before continuing |

### Gap Categories

When identifying gaps, categorize them:

| Gap Type | Example | Remediation |
|----------|---------|-------------|
| **Vague scope** | "and more features" | Define explicit boundaries |
| **Missing AC** | Story without acceptance criteria | Add testable conditions |
| **Unmeasurable NFR** | "should be fast" | Add specific target (e.g., <200ms) |
| **Unknown integration** | "connects to backend" | Identify specific APIs/services |
| **Missing design** | No domain model | Run `/planning:aidlc-design` |

## Workflow

### Phase 1: Gather Artifacts

1. **Collect references**
   Ask only for what is missing:
   - Confluence Level 1 Intent document link
   - Jira project key (for transfer)
   - Any design documentation links (optional)

2. **Fetch all documentation**
   - Read Intent document
   - Read Units Overview page
   - Read all Unit pages and their Story child pages
   - Read Design documents if available (Domain model, ADRs)

### Phase 2: Spawn Verification Sub-agents

Spawn parallel sub-agents (one per Unit) to assess documentation quality.

**Sub-agent Prompt Template:**

```markdown
Review the following Unit documentation for AI-execution readiness.

## Unit: <Unit Name>
<Unit page content>

## Stories
<Story pages content for this Unit>

## Design Documents (if available)
<Domain model, ADRs relevant to this Unit>

## Intent Context
<Relevant sections from Level 1 Intent>

## Scoring Instructions

Rate each criterion 0-100:

1. **Scope Clarity** (0-100)
   - Is the Unit scope bounded? (no "and more", "etc.", vague outcomes)
   - Are deliverables specific and measurable?
   - Deduct points for open-ended language

2. **Story Quality** (0-100)
   - Do all stories have acceptance criteria?
   - Are acceptance criteria testable (not vague)?
   - Are user stories in proper format?

3. **Technical Readiness** (0-100)
   - Are integration points identified (APIs, services, databases)?
   - Are data models or schemas referenced?
   - Are error handling expectations documented?

4. **NFR Specificity** (0-100)
   - Are performance targets measurable (e.g., <200ms, not "fast")?
   - Are security requirements specific?
   - Are availability/reliability targets defined?

5. **Dependency Clarity** (0-100)
   - Are blockers and prerequisites documented?
   - Is sequencing clear (what comes first)?
   - Are external dependencies identified?

## Return Format

Return your assessment as JSON:

{
  "unit": "<unit name>",
  "scores": {
    "scope_clarity": <0-100>,
    "story_quality": <0-100>,
    "technical_readiness": <0-100>,
    "nfr_specificity": <0-100>,
    "dependency_clarity": <0-100>
  },
  "gaps": [
    {
      "category": "<scope_clarity|story_quality|technical_readiness|nfr_specificity|dependency_clarity>",
      "issue": "<specific gap description>",
      "location": "<story title or section>",
      "suggestion": "<how to fix>"
    }
  ],
  "strengths": [
    "<well-documented aspect>"
  ],
  "overall_confidence": <0-100>
}
```

### Phase 3: Consolidate Results

After all sub-agents return:

1. **Parse JSON results** from each sub-agent
2. **Calculate weighted score** using the category weights
3. **Merge gap lists** across all Units
4. **Identify cross-cutting gaps** that affect multiple Units
5. **Rank gaps by impact** (blocking issues first)

### Phase 4: Present Assessment

Present the confidence assessment to the user:

```markdown
## Confidence Assessment Report

### Overall Confidence: XX%

| Unit | Scope | Stories | Technical | NFRs | Dependencies | Score |
|------|-------|---------|-----------|------|--------------|-------|
| Unit 1 | 85 | 90 | 70 | 60 | 80 | 77% |
| Unit 2 | 90 | 85 | 85 | 75 | 90 | 85% |
| **Weighted Average** | | | | | | **81%** |

### Gaps Identified

**High Priority (blocking):**
1. [Unit 1] Story "User Login" missing acceptance criteria
   - Suggestion: Add testable conditions for success/failure

**Medium Priority:**
2. [Unit 1] NFR "performance" lacks specific target
   - Suggestion: Define response time target (e.g., <200ms p95)

### Strengths
- Clear scope boundaries across all Units
- Dependencies well-documented
- User stories follow proper format

### Recommendation

[Based on score: proceed / address gaps / gather more context]
```

### Phase 5: Decision Gate

Based on confidence level:

**If High (≥80%):**
```
Confidence is HIGH (XX%). Ready to proceed with Jira transfer.

Do you want to:
1. Proceed with Jira transfer
2. Address gaps first anyway
3. Cancel
```

**If Medium (60-79%):**
```
Confidence is MEDIUM (XX%). Some gaps identified.

Gaps to address:
- [List top 3 gaps]

Do you want to:
1. Address gaps first (recommended)
2. Proceed anyway (override)
3. Cancel
```

**If Low (<60%):**
```
Confidence is LOW (XX%). Significant gaps prevent reliable AI execution.

Critical gaps:
- [List blocking gaps]

Recommended actions:
1. Run `/planning:aidlc-design` if design is missing
2. Update stories with missing acceptance criteria
3. Define measurable NFRs

Cannot proceed to Jira transfer until confidence reaches 60%.
```

### Phase 6: Jira Transfer (if approved)

This phase creates Jira artifacts from the verified Confluence documentation.

#### Step 1: Confirm Jira Transfer

Confirm the user is ready:
- Remind them that Units will be created as Sub-epics and Stories under each Sub-epic
- Confirm the Jira project key

#### Step 2: Create Jira Artifacts

For each Unit:

1. **Create Sub-epic** (or Epic if Sub-epic unavailable)
   - Summary: Unit page title
   - Description: Unit page content + link to Level 1 Intent Confluence doc
   - Label: `aidlc:unit`
   - If design exists, add label: `aidlc:designed`

2. **Create Stories** under each Sub-epic
   - Summary: Story page title
   - Description: Everything else from the story page (user story, acceptance criteria, context, dependencies, risks, test notes)

Use templates in @${CLAUDE_PLUGIN_ROOT}/references/planning-shared.md

#### Step 3: Update Workflow Status

Update the Confluence Level 1 Intent page status table:
- Set "Verification" row to "✅ Complete" with today's date
- Add links to created Sub-epics in the Artifact column

#### Step 4: Delete Confluence Story Pages

After successful Jira creation, delete the Confluence pages to avoid confusion:
- Delete all Story pages
- Delete all Unit pages
- Delete the Units Overview page

**Important**: Keep the Level 1 Intent document and Design documents - only delete the decomposition pages.

#### Step 5: Report Back

Provide:
- Created Jira keys (Sub-epics and Stories)
- Links to the Jira artifacts
- Confirmation that Confluence pages have been cleaned up
- Final confidence score for reference

## Workflow Chain

- **Previous**: `/planning:aidlc-design` (Domain and Logical Design)
- **Next**: Implementation

## Definition of Done

### Verification Complete
- All Units assessed by verification sub-agents
- Confidence score calculated with weighted average
- Gaps identified and categorized
- Assessment report presented to user

### Jira Transfer Complete (if approved)
- Units created as Sub-epics with `aidlc:unit` label
- Stories created under their respective Sub-epics
- Design label added if design exists (`aidlc:designed`)
- Confluence decomposition pages deleted (Overview, Units, Stories)
- Level 1 Intent page status table updated

## Troubleshooting

- **Sub-epic not supported**: Use Epic + issue links or parent field; ask for preferred structure.
- **Missing issue types**: Use `getJiraProjectIssueTypesMetadata` and confirm available types.
- **Low confidence score**: Guide user to address specific gaps; offer to re-run verification after updates.
- **Sub-agent failure**: Report which Unit verification failed and offer to retry or assess manually.
- **Confluence page deletion fails**: Verify permissions; may need admin to delete pages.
- **Design missing**: Confidence will be lower; recommend running `/planning:aidlc-design` first but allow override.
- **User wants to skip verification**: Allow with explicit confirmation, but warn that AI execution quality may suffer.
