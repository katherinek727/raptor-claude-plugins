---
name: trunk-plan
description: "Preview the trunk-based migration execution plan before making changes. Shows files to create, modify, and delete. Triggers: trunk plan, migration plan, show plan, preview migration"
argument-hint: "<config.yaml path>"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Trunk Migration Plan

You are the planning skill for trunk-based migration. Your job is to read the migration config, evaluate decision trees, and present a detailed execution plan for user review BEFORE any changes are made.

**This skill does NOT modify any files.** It only reads and reports.

## Input

`$ARGUMENTS` may contain a path to `trunk-migration-config.yaml`. If not provided:
1. Check for `trunk-migration-config.yaml` in the repository root
2. If not found, prompt the user to run `/dotnet:trunk-discover` first

Read the config file and validate it against the schema at @${CLAUDE_PLUGIN_ROOT}/references/config-schema.md

## Step 1: Evaluate Decision Trees

Based on the config, evaluate all 5 decision trees:

### Decision Tree 1: API Versioning
```
multi_version: {true/false}
→ {Single version: 1 swagger job, simple APIM | Multi-version: matrix swagger, matrix APIM with per-version API_IDs (existing values from Azure APIM, provided by user)}
```

### Decision Tree 2: Auth0
```
auth0.enabled: {true/false}
→ {Enabled: auth0-deploy-lower + auth0-deploy-prod jobs | Disabled: no Auth0 jobs}
```

### Decision Tree 3: NuGet
```
nuget.enabled: {true/false}
→ {Enabled: nuget-pack jobs for each package | Disabled: no NuGet jobs, remove publish-packages stage}
```

### Decision Tree 4: UI Regression Tests
```
ui_tests.enabled: {true/false}
→ {Enabled: test-ui-staging job in prod-gate stage and/or test-ui-prod job in post-deploy stage | Disabled: no UI test jobs}
```

### Decision Tree 5: EF Migrations
```
ef_migrations.enabled: {true/false}
→ {Enabled: migration validation + deploy jobs, dotnet-tools.json, migration.sql | Disabled: no migration jobs}
```

## Step 2: Calculate File Changes

Present a clear summary of ALL file operations:

### Files to Create

```
k8s/base/
  deployment.yaml
  service.yaml
  ingressroute.yaml
  hpa.yaml
  namespace.yaml
  kustomization.yaml

k8s/overlays/dev/kustomization.yaml
k8s/overlays/staging/kustomization.yaml
k8s/overlays/prod/kustomization.yaml
k8s/overlays/prod/hpa-patch.yaml

k8s/overlays/review/
  kustomization.yaml.template
  add-nodeselector.patch.yaml.template
  patch-api-deployment.yaml.template
  patch-api-service.yaml.template
  patch-api-hpa.yaml.template
  patch-https-route.yaml.template
  resources/https-route.yaml
  resources/http-to-https-redirect.yaml

k8s/{region}/{environment}/kustomization.yaml (for each combination)
```

Count and list region kustomizations:
- `k8s/us/dev/kustomization.yaml`
- `k8s/us/staging/kustomization.yaml`
- `k8s/us/prod/kustomization.yaml`
- `k8s/uk/dev/kustomization.yaml`
- `k8s/uk/staging/kustomization.yaml`
- `k8s/uk/prod/kustomization.yaml`

Conditional files:
- `.config/dotnet-tools.json` (if EF migrations enabled)
- `{data_project_path}/migration.sql` (if EF migrations enabled)

### Files to Modify

- `.gitlab-ci.yml` — Complete rewrite to trunk-based workflow

### Files to Delete

Scan for and list:
- `k8s/dev/*.yaml` (old manifests)
- `k8s/stag/*.yaml` (old manifests)
- `k8s/prod/*.yaml` (old manifests)
- `.gitlab-ci/` directory (old CI includes)
- `package.json` (no longer needed with v5 semantic-release)
- `package-lock.json` (no longer needed)
- `release.config.js` (no longer needed)

## Step 3: Pipeline Structure Preview

Show the planned CI/CD stages and jobs:

```
Stages:
  1. build-artifacts
     - docker-build-job (matrix: api)
     - test-job
     - generate-swagger-job {single/matrix}
     - validate-migration-script-job {if EF enabled}
     - calculate-version (from semantic-release template)

  2. publish-packages {if NuGet enabled}
     - nuget-pack-{package} (for each package, main branch only)

  3. review
     - deploy-review-app-job (MR only)
     - cleanup-review-app-job (MR close)

  4. deploy-lower (main branch only)
     - push-docker-images-lower (matrix: regions x lower-envs)
     - deploy-migrations-lower {if EF enabled} (matrix: regions x lower-envs)
     - auth0-deploy-lower {if Auth0 enabled} (matrix: regions x lower-envs)
     - deploy-k8s-lower (matrix: regions x lower-envs)
     - upload-api-lower (matrix: depends on versioning)

  5. prod-gate
     - verify-staging-no-op
     - test-ui-staging {optional}
     - manual-approval-prod

  6. deploy-prod (after manual approval)
     - push-docker-images-prod (matrix: regions)
     - deploy-migrations-prod {if EF enabled} (matrix: regions)
     - auth0-deploy-prod {if Auth0 enabled} (matrix: regions)
     - deploy-prod-job (matrix: regions)
     - upload-api-prod (matrix: depends on versioning)

  7. post-deploy
     - test-ui-prod {optional}
     - (semantic-release tag creation)
```

## Step 4: Summary Statistics

Present:
- Total files to create: {count}
- Total files to modify: {count}
- Total files to delete: {count}
- Pipeline jobs on MR: {count}
- Pipeline jobs on main: {count}
- APIM matrix size: {count} (region x env x version combinations)
- Region/environment combinations: {count}

## Step 5: Approval Gate

Ask the user:

```
The migration plan is ready for review. Key highlights:
- {count} new Kustomize manifests
- Complete .gitlab-ci.yml rewrite
- {conditional features summary}

Would you like to proceed with the migration?
- Run /dotnet:trunk-migrate to execute this plan
- Run /dotnet:trunk-discover to update the configuration
- Or ask me any questions about the plan
```

Do NOT proceed to migration automatically. The user must explicitly invoke `/dotnet:trunk-migrate`.
