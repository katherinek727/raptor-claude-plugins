---
name: standards-review
description: "Comprehensive GitLab CI pipeline standards documentation with detailed examples, anti-patterns, and checklists. Triggers: gitlab-ci standards, pipeline standards, needs vs dependencies, pipeline ordering, standards review"
argument-hint: "[topic]"
---

# GitLab CI Standards Review

Comprehensive documentation for GitLab CI pipeline standards.

## Usage

- `/gitlab-ci:standards-review` — Review all standards
- `/gitlab-ci:standards-review job-ordering` — Review job ordering standards only

## Available Topics

- `job-ordering` — Pipeline job ordering with `needs` vs `dependencies`

## References

If `$ARGUMENTS` specifies a topic, load that standard. Otherwise, load all standards.

### Job Ordering

@${CLAUDE_PLUGIN_ROOT}/references/standards/job-ordering.md

<!-- Future standards will be added here -->
<!-- ### Variable Naming -->
<!-- @${CLAUDE_PLUGIN_ROOT}/references/standards/variable-naming.md -->
