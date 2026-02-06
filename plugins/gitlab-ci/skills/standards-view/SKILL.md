---
name: standards-view
description: "Display GitLab CI pipeline standards summary to the user. Triggers: view standards, show standards, display standards, what are the standards"
argument-hint: "[topic]"
---

# GitLab CI Standards - View

Display a human-readable summary of GitLab CI standards to the user.

## Usage

- `/gitlab-ci:standards-view` — Show summary of all standards
- `/gitlab-ci:standards-view job-ordering` — Show job ordering standards

## Available Topics

- `job-ordering` — Pipeline job ordering with `needs` vs `dependencies`

## Related Commands

- `/gitlab-ci:standards-load` — Load full standards into context
- `/gitlab-ci:standards-audit` — Analyze repo for standards violations

## Instructions

When this skill is invoked, output a concise summary of the standards for the user to read.

### Job Ordering Summary

**Core Rule:** Use stages for cross-stage ordering and `needs` only for intra-stage ordering.

| Keyword | Use When |
|---------|----------|
| `needs` | Ordering jobs within the **same stage** |
| `dependencies` | Getting artifacts from **earlier stages** (no ordering effect) |
| No `needs` | Entry-point jobs that should wait for **all** previous stage jobs |

**Why it matters:** If a job has `needs` pointing to an earlier stage, it bypasses stage gates entirely. This can cause production deployments to start before staging tests complete.

**Quick check:** Before adding `needs` to a job, ask: Is the dependency in the same stage?
- **Yes** → Use `needs`
- **No** → Don't use `needs`. Use `dependencies` if you need artifacts.

**Example:**
```yaml
# CORRECT: Entry-point job with no needs
push-docker-images-prod:
  stage: deploy-prod
  dependencies:
    - calculate-version  # Artifacts only

# CORRECT: Intra-stage needs
deploy-prod-job:
  stage: deploy-prod
  needs:
    - job: push-docker-images-prod  # Same stage - OK
```

For full documentation with anti-patterns and checklists, run `/gitlab-ci:standards-load`.
