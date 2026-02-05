---
name: standards
description: "Comprehensive GitLab CI pipeline standards documentation with detailed examples, anti-patterns, and checklists. Triggers: gitlab-ci standards, pipeline standards, needs vs dependencies, pipeline ordering"
---

# GitLab CI Pipeline Standards

This document defines the standards for GitLab CI pipeline configuration in Raptor Platform projects.

---

## Pipeline Job Ordering: The Intra-Stage `needs` Pattern

**Use stages for cross-stage ordering and `needs` only for intra-stage ordering.**

### Key Concepts

| Keyword | Controls | Execution Behavior |
|---------|----------|-------------------|
| `needs` | Execution order | Job becomes DAG-scheduled, bypasses stage ordering entirely |
| `dependencies` | Artifact downloading | No effect on execution order, job remains stage-scheduled |
| No `needs` | Stage ordering | Job waits for ALL jobs in previous stage to complete |

### The Rule

**If a job has ANY `needs`, it is entirely DAG-scheduled and will NOT wait for stage boundaries.**

This means a job with `needs: [jobA]` will start as soon as `jobA` completes, regardless of what stage `jobA` is in or whether other jobs in previous stages have completed.

### Correct Pattern

1. **Cross-stage ordering**: Let stage boundaries handle it (no `needs` to jobs in other stages)
2. **Intra-stage ordering**: Use `needs` only for jobs within the same stage
3. **Artifact downloading**: Use `dependencies` when you need artifacts but not ordering

### Example: deploy-prod Stage

```yaml
# CORRECT: Entry-point jobs have no needs (stage-scheduled)
push-docker-images-prod:
  stage: deploy-prod
  # No needs - waits for ALL prod-gate jobs (including test-ui-staging AND manual-approval-prod)
  dependencies:
    - calculate-version    # Artifacts only
    - docker-build-job     # Artifacts only

deploy-migrations-prod:
  stage: deploy-prod
  # No needs - waits for ALL prod-gate jobs

# CORRECT: Intra-stage ordering with needs
deploy-prod-job:
  stage: deploy-prod
  needs:
    - job: push-docker-images-prod    # Same stage - OK
    - job: deploy-migrations-prod     # Same stage - OK
      optional: true

upload-api-prod:
  stage: deploy-prod
  needs:
    - job: deploy-prod-job            # Same stage - OK
  dependencies:
    - generate-swagger-job            # Artifacts only
```

### Anti-Pattern: Cross-Stage `needs`

```yaml
# WRONG: Cross-stage needs bypasses stage gate
push-docker-images-prod:
  stage: deploy-prod
  needs:
    - job: manual-approval-prod       # WRONG - cross-stage (prod-gate)
    - job: calculate-version          # WRONG - cross-stage (build-artifacts)
    - job: docker-build-job           # WRONG - cross-stage (build-artifacts)
```

**Why this is wrong:** This job will start as soon as `manual-approval-prod` completes, but it will NOT wait for `test-ui-staging` (also in prod-gate) to complete. This allows production deployment to proceed while staging tests are still running.

### Why This Matters

Consider this stage order:
```
deploy-lower → prod-gate → deploy-prod
```

With jobs:
- `prod-gate`: `test-ui-staging`, `manual-approval-prod`
- `deploy-prod`: `push-docker-images-prod`, `deploy-prod-job`

**Intended behavior:** Both `test-ui-staging` AND `manual-approval-prod` must pass before any deploy-prod job starts.

**With cross-stage `needs`:** If `push-docker-images-prod` has `needs: [manual-approval-prod]`, it becomes DAG-scheduled and will start as soon as `manual-approval-prod` completes—even if `test-ui-staging` is still running or has failed.

**With no `needs` (stage-scheduled):** `push-docker-images-prod` waits for ALL prod-gate jobs to complete before starting, ensuring both gates are enforced.

---

## When to Use Each Keyword

| Scenario | Use |
|----------|-----|
| Job must wait for another job in the **same stage** | `needs` |
| Job must wait for all jobs in the **previous stage** | No `needs` (stage-scheduled) |
| Job needs **artifacts** from an earlier stage | `dependencies` |
| Job needs **artifacts** AND **ordering** from same stage | `needs` (artifacts included by default) |

---

## Common Intra-Stage Dependencies

These are valid uses of `needs` within the same stage:

| Stage | Job | Needs | Reason |
|-------|-----|-------|--------|
| build-artifacts | `generate-swagger-job` | `docker-build-job` | Swagger extraction requires built image |
| deploy-lower | `deploy-k8s-lower` | `push-docker-images-lower` | Can't deploy until images are in ACR |
| deploy-lower | `deploy-k8s-lower` | `deploy-migrations-lower` | DB schema before app deployment |
| deploy-lower | `upload-api-lower` | `deploy-k8s-lower` | APIM update after k8s is ready |
| deploy-prod | `deploy-prod-job` | `push-docker-images-prod` | Can't deploy until images are in ACR |
| deploy-prod | `deploy-prod-job` | `deploy-migrations-prod` | DB schema before app deployment |
| deploy-prod | `upload-api-prod` | `deploy-prod-job` | APIM update after k8s is ready |

---

## Checklist for Pipeline Changes

When modifying `.gitlab-ci.yml`:

- [ ] Does the job have `needs` pointing to a job in a **different stage**? If yes, remove it.
- [ ] Does the job need artifacts from an earlier stage? Use `dependencies`, not `needs`.
- [ ] Does the job need to wait for a specific job in the **same stage**? Use `needs`.
- [ ] Are all entry-point jobs in each stage free of cross-stage `needs`?
- [ ] Will all gates in the previous stage be enforced before this job runs?

---

## Additional Guidelines

### `allow_failure` Usage

Do NOT use `allow_failure: true` on jobs that should block the pipeline on failure. If APIM upload fails in lower environments, you want to know before it fails in production.

### `optional: true` in `needs`

Use `optional: true` when:
- The needed job might be skipped by `rules:changes` (e.g., migration jobs that only run when SQL files change)
- The needed job might not exist in all pipeline configurations

```yaml
deploy-k8s-lower:
  needs:
    - job: push-docker-images-lower
    - job: deploy-migrations-lower
      optional: true  # Migrations may be skipped if no SQL changes
```

### Review Apps

Review app jobs (`deploy-review-app-job`) should NOT have `needs` pointing to earlier stages. Let them be stage-scheduled so they wait for all build-artifacts jobs (including tests) to pass.

---

## Analyzing a Pipeline for Compliance

To check if a pipeline follows these standards:

1. **Find all `needs` declarations**: `grep -A4 "needs:" .gitlab-ci.yml`
2. **For each job with `needs`**:
   - Identify the job's stage
   - Check each dependency's stage
   - If any dependency is in a different stage, it's a violation
3. **Entry-point jobs** (first jobs in each stage that others depend on) should have NO `needs`
