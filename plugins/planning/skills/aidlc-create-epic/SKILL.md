---
name: aidlc-create-epic
description: Create the Jira Intent Epic after the Level 1 Confluence documentation is approved, linking to Confluence and capturing risks, NFRs, and measurement criteria. Use when asked to create an Intent Epic or move the approved Intent into Jira. (Triggers: create intent epic, jira epic, move intent to jira, create epic from intent, intent epic, aidlc epic)
---

# AI-DLC Create Epic

Create the Intent Epic only after the Confluence Level 1 documentation is approved. The Epic should reference the Confluence page(s) and capture the key alignment and risk information.

## Example Invocations

- "Create the Intent Epic for the authentication initiative"
- "Move the approved billing intent into Jira"
- "Create a Jira epic from the API migration intent doc"
- "Set up the Intent Epic linked to our Confluence page"

## References

- Use `references/planning-shared.md` for templates, prompts, and Jira tool names.

## Workflow

1. **Verify approval**
   Confirm that the Confluence Level 1 documentation is approved and ask for the page link(s).

2. **Collect Jira context**
   Ask for the Jira project key (no default) and confirm Epic is an available issue type.

3. **Confirm understanding**
   Summarize the Epic content in 4-6 bullets and ask for approval before creation.

4. **Create the Intent Epic**
   Use the template in `references/planning-shared.md` and include:
   - Intent summary
   - Confluence link(s)
   - NFRs
   - Measurement criteria
   - Risks and assumptions

5. **Report back**
   Provide the Epic key and confirm success.

6. **Chain to Unit decomposition**
   Ask whether to proceed with Unit decomposition. If yes, invoke `/aidlc-decompose` with the Epic key, Confluence link(s), and Jira project key.

## Workflow Chain

- **Previous**: `/aidlc-plan` (Level 1 Intent documentation)
- **Next**: `/aidlc-decompose` (Unit and Story creation)

## Definition of Done

- Jira Intent Epic created in the specified project.
- Epic links to approved Confluence Level 1 documentation.
- Risks, NFRs, and measurement criteria included.

## Troubleshooting

- **Epic issue type missing**: Use `getJiraProjectIssueTypesMetadata` and ask how to proceed.
- **Permissions error**: Ask for a project with Epic creation permissions.
