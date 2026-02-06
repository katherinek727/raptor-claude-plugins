---
name: standards-load
description: "Load GitLab CI pipeline standards into context for Claude to apply during work. Triggers: load standards, load pipeline standards, standards context"
argument-hint: "[topic]"
---

# GitLab CI Standards - Load Context

Load comprehensive standards into Claude's context for applying during pipeline editing or review.

## Usage

- `/gitlab-ci:standards-load` — Load all standards into context
- `/gitlab-ci:standards-load job-ordering` — Load job ordering standards only

## Available Topics

- `job-ordering` — Pipeline job ordering with `needs` vs `dependencies`

## Related Commands

- `/gitlab-ci:standards-view` — Display standards summary to the user
- `/gitlab-ci:standards-audit` — Analyze repo for standards violations

## References

If `$ARGUMENTS` specifies a topic, load that standard. Otherwise, load all standards.

### Job Ordering

@${CLAUDE_PLUGIN_ROOT}/references/standards/job-ordering.md

<!-- Future standards will be added here -->
<!-- ### Variable Naming -->
<!-- @${CLAUDE_PLUGIN_ROOT}/references/standards/variable-naming.md -->
