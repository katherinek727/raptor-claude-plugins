---
name: pipeline-edit
description: "Lightweight GitLab CI pipeline editing guidelines. Triggers: update pipeline, modify pipeline, create pipeline, update gitlab-ci, modify gitlab-ci, edit gitlab-ci, add job, add stage, new job, new stage, pipeline job, pipeline stage"
---

# GitLab CI Pipeline Editing Guidelines

When editing `.gitlab-ci.yml` files, follow this core rule for job ordering:

## The Intra-Stage `needs` Pattern

**Use stages for cross-stage ordering and `needs` only for intra-stage ordering.**

| Keyword | Purpose | Effect |
|---------|---------|--------|
| `needs` | Execution order | Job becomes DAG-scheduled, **bypasses stage ordering entirely** |
| `dependencies` | Artifact downloading | No effect on execution order |
| No `needs` | Stage ordering | Job waits for ALL jobs in previous stage |

### Rules

1. **Cross-stage ordering**: Do NOT use `needs` to reference jobs in earlier stages. Let stage boundaries handle it.
2. **Intra-stage ordering**: Use `needs` only for jobs within the same stage that must run in sequence.
3. **Artifacts**: Use `dependencies` when you need artifacts from earlier stages without affecting execution order.

### Why This Matters

If a job has `needs` pointing to a job in an earlier stage, it becomes DAG-scheduled and will **skip the stage gate**. This can cause issues like:
- Production deployment starting before staging tests complete
- Jobs running before all required gates pass

### Quick Example

```yaml
# CORRECT: Entry-point jobs have no needs (stage-scheduled)
push-docker-images-prod:
  stage: deploy-prod
  # No needs - waits for ALL prod-gate jobs
  dependencies:
    - calculate-version    # Artifacts only
    - docker-build-job     # Artifacts only

# CORRECT: Intra-stage ordering
deploy-prod-job:
  stage: deploy-prod
  needs:
    - job: push-docker-images-prod    # Same stage - OK
    - job: deploy-migrations-prod     # Same stage - OK
      optional: true
```

For comprehensive documentation with detailed examples and checklists, run `/gitlab-ci:standards`.
