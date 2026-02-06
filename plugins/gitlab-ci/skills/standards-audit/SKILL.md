---
name: standards-audit
description: "Audit a repository's GitLab CI pipeline against standards. Reports violations with line numbers and recommendations. Triggers: audit pipeline, check pipeline standards, pipeline compliance, standards audit"
argument-hint: "[topic]"
---

# GitLab CI Standards Audit

Analyze a repository's `.gitlab-ci.yml` for compliance with GitLab CI standards.

## Usage

- `/gitlab-ci:standards-audit` — Audit against all standards
- `/gitlab-ci:standards-audit job-ordering` — Audit job ordering only

## Available Topics

- `job-ordering` — Pipeline job ordering with `needs` vs `dependencies`

## Related Commands

- `/gitlab-ci:standards-view` — Display standards summary to the user
- `/gitlab-ci:standards-load` — Load full standards into context

## References

@${CLAUDE_PLUGIN_ROOT}/references/core-rules.md

## Audit Process

1. **Find the pipeline file**: Search for `.gitlab-ci.yml` in the repository root
2. **Load relevant standards**: Based on `$ARGUMENTS` or all standards if not specified
3. **Analyze the pipeline**: Check each job against the standards
4. **Report findings**:

### Report Format

```
## Standards Audit Report

### Summary
- **Compliant**: X patterns
- **Violations**: Y issues found
- **Recommendations**: Z suggestions

### Violations

#### [VIOLATION] Cross-stage `needs` detected
- **File**: .gitlab-ci.yml
- **Line**: 45
- **Job**: `push-docker-images-prod`
- **Issue**: Job has `needs: [manual-approval-prod]` which is in a different stage (prod-gate)
- **Impact**: Job will bypass stage gate and may run before all prod-gate jobs complete
- **Fix**: Remove the `needs` entry and use `dependencies` if artifacts are required

### Compliant Patterns

- `deploy-prod-job` correctly uses intra-stage `needs` for `push-docker-images-prod`
- Entry-point jobs in `deploy-lower` have no cross-stage `needs`

### Recommendations

- Consider adding `optional: true` to migration job dependencies
```

## Job Ordering Audit Checks

When auditing `job-ordering`, check for:

1. **Cross-stage `needs`**: Any job with `needs` pointing to a job in a different stage
2. **Entry-point jobs with `needs`**: First jobs in each stage should have no `needs`
3. **Missing `optional: true`**: Jobs that `need` conditional jobs (like migrations)
4. **Incorrect artifact handling**: Using `needs` when `dependencies` would suffice

For each violation, provide:
- Exact line number
- The problematic configuration
- Why it violates the standard
- Specific fix with corrected YAML
