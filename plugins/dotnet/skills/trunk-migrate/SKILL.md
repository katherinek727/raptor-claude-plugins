---
name: trunk-migrate
description: "Execute the full trunk-based development migration for a .NET API service. Creates Kustomize manifests, updates CI/CD, and prepares MR. Triggers: trunk migrate, migrate to trunk, trunk-based migration, execute migration"
argument-hint: "<config.yaml path>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Task
  - TodoWrite
---

# Trunk Migration Execution

You are the migration execution skill. You perform the actual migration of a .NET API service from GitLab Flow to trunk-based development.

**IMPORTANT**: This skill modifies the repository. Ensure the user has reviewed the plan via `/dotnet:trunk-plan` first.

## Prerequisites

**Required plugin:** This skill depends on the `gitlab-ci` plugin for pipeline standards.

Before proceeding, check if the gitlab-ci plugin is installed by attempting to verify the `/gitlab-ci:standards` command is available. If not installed, tell the user:

> The `gitlab-ci` plugin is required for this migration. Please install it first:
> ```
> /plugin install gitlab-ci
> ```
> Then run `/dotnet:trunk-migrate` again.

Do not proceed with the migration until the gitlab-ci plugin is confirmed available.

## References

Reference templates at: @${CLAUDE_PLUGIN_ROOT}/references/migration-templates.md
Reference config schema at: @${CLAUDE_PLUGIN_ROOT}/references/config-schema.md

## Input

`$ARGUMENTS` may contain a path to `trunk-migration-config.yaml`. If not provided:
1. Check for `trunk-migration-config.yaml` in the repository root
2. If not found, prompt the user to run `/dotnet:trunk-discover` first
3. If found, read and parse the config

## Execution Steps

Create a TodoWrite list to track all migration steps. Mark each step as completed as you go.

### Step 0: Preparation

1. **Read existing configuration**: Read `.gitlab-ci.yml`, existing K8s manifests, and any auth0 configs to understand current values
2. **Create migration branch** (if not already on one):
   - Branch name must include the Jira ticket key: `migrate/{jira_ticket}-trunk-based-development` (e.g., `migrate/PLT-2763-trunk-based-development`)
   - Before creating, check if the branch already exists locally or on remote:
     ```bash
     BRANCH="migrate/${JIRA_TICKET}-trunk-based-development"
     if git show-ref --verify --quiet refs/heads/$BRANCH || git ls-remote --heads origin $BRANCH | grep -q .; then
       # Branch exists — append short suffix to make unique
       BRANCH="${BRANCH}-$(date +%s | tail -c 5)"
     fi
     git checkout -b $BRANCH
     ```
3. **Validate config**: Ensure all required fields are populated

### Step 1: Create Kustomize Base Manifests

Create the `k8s/base/` directory with 6 files. Use the templates from @${CLAUDE_PLUGIN_ROOT}/references/migration-templates.md, substituting all `SERVICE_NAME` and other placeholders with values from the config.

Files to create:
- `k8s/base/deployment.yaml` — Main deployment with security context, probes, env vars
- `k8s/base/service.yaml` — ClusterIP service mapping port 80 to 8080
- `k8s/base/ingressroute.yaml` — Traefik IngressRoute
- `k8s/base/hpa.yaml` — HorizontalPodAutoscaler
- `k8s/base/namespace.yaml` — Platform namespace
- `k8s/base/kustomization.yaml` — Base kustomization referencing all resources

**SECURITY REQUIREMENTS for deployment.yaml:**
- `runAsNonRoot: true`, `runAsUser: 1000`, `runAsGroup: 1000`, `fsGroup: 1000`
- `allowPrivilegeEscalation: false`
- Container port `8080` (non-privileged)
- `ASPNETCORE_URLS: "http://+:8080"`
- All secrets via `secretKeyRef` (NOT hardcoded)

**Customization from existing manifests:**
- Copy resource limits from existing deployment (or use config values)
- Copy all environment variables from existing deployment
- Copy health check path from existing probes
- Preserve any additional secret references

### Step 2: Create Environment Overlays

Create overlay kustomizations for each environment tier:
- `k8s/overlays/dev/kustomization.yaml` — HPA: 1-4 replicas
- `k8s/overlays/staging/kustomization.yaml` — HPA: 1-4 replicas
- `k8s/overlays/prod/kustomization.yaml` — References hpa-patch.yaml
- `k8s/overlays/prod/hpa-patch.yaml` — HPA: 4-20 replicas

### Step 3: Create Region-Specific Kustomizations

For each region/environment combination (typically 6: us/uk x dev/staging/prod), create a kustomization file at `k8s/{region}/{env}/kustomization.yaml`.

Each region kustomization MUST include:
1. Reference to the environment overlay (`../../overlays/{env}`)
2. Image replacement with region-specific ACR
3. **Complete** IngressRoute patch with `match`, `kind`, AND `services` (all 3 fields required)
4. `NEW_RELIC_APP_NAME` deployment patch with region/env suffix

Use the region kustomization template from @${CLAUDE_PLUGIN_ROOT}/references/migration-templates.md.

**Region/Environment New Relic naming convention:**
| Region | Env | Suffix |
|--------|-----|--------|
| US | dev | `-dev` |
| US | staging | `-stag` |
| US | prod | `-prod` |
| UK | dev | `-devuk` |
| UK | staging | `-staguk` |
| UK | prod | `-produk` |

### Step 4: Create Review Overlay

Create the review overlay with `.template` files that the review-app pipeline template will process:

- `k8s/overlays/review/kustomization.yaml.template`
- `k8s/overlays/review/add-nodeselector.patch.yaml.template`
- `k8s/overlays/review/patch-api-deployment.yaml.template`
- `k8s/overlays/review/patch-api-service.yaml.template`
- `k8s/overlays/review/patch-api-hpa.yaml.template`
- `k8s/overlays/review/patch-https-route.yaml.template`
- `k8s/overlays/review/resources/https-route.yaml`
- `k8s/overlays/review/resources/http-to-https-redirect.yaml`

**CRITICAL for patch-api-deployment.yaml.template:**
- Include `valueFrom: null` for every environment variable to override base `secretKeyRef`
- Use `{{placeholder}}` syntax for runtime substitution
- Set review-appropriate resource limits (300Mi/200m)

### Step 5: Delete Old Files

Delete files that are replaced by the new structure:

```bash
rm -rf k8s/dev/ k8s/stag/ k8s/prod/    # Old per-environment manifests
rm -rf .gitlab-ci/                       # Old CI includes
rm -f package.json package-lock.json     # No longer needed with v5 semantic-release
rm -f release.config.js                  # No longer needed
```

**Only delete files that actually exist.** Check before deleting.

### Step 6: Create .gitlab-ci.yml

This is the most complex step. Create the complete `.gitlab-ci.yml` using templates from @${CLAUDE_PLUGIN_ROOT}/references/migration-templates.md.

The CI/CD config is built conditionally based on decision trees:

#### Always include:
- Workflow rules (target main branch)
- YAML anchors for regions and lower-environments
- Stages
- Variables block
- Core template includes (verify-staging, prod-gate, semantic-release, docker/build, coverage)
- Docker build job
- Test job
- Coverage job (`coverage-job` extending `.coverage`)
- Kustomize deployment jobs (lower + prod)
- Review app jobs
- Production docker push with manual-approval-prod gate

#### Conditional on `decisions.api_versioning.multi_version`:
- **true**: Multi-version swagger generation (parallel matrix), multi-version APIM deployment (explicit matrix per region/env/version)
- **false**: Single swagger generation job, simple APIM deployment

#### Conditional on `decisions.auth0.enabled`:
- **true**: Auth0 deploy lower + prod jobs with secure secret injection
- **false**: Omit Auth0 jobs entirely

#### Conditional on `decisions.nuget.enabled`:
- **true**: NuGet pack jobs for each package (main branch only rules)
- **false**: Omit NuGet jobs, can omit publish-packages stage

#### Conditional on `decisions.ui_tests.enabled`:
- **true**: Include `test-ui-staging` job in `prod-gate` stage if `schedule_name` is set, and `test-ui-prod` job in `post-deploy` stage if `schedule_name_prod` is set. Both trigger the QA framework with their respective `SCHEDULE_NAME` from config.
- **false**: Omit UI test jobs entirely

#### Conditional on `decisions.ef_migrations.enabled`:
- **true**: Migration validation job, deploy-migrations-lower, deploy-migrations-prod, include ef-migrations.yml and sql-script-deploy.yml templates
- **false**: Omit migration jobs and templates, remove migration `needs:` from deploy jobs

**CRITICAL CI/CD RULES** (for full documentation, run `/gitlab-ci:standards`):
- Use `needs` ONLY for intra-stage ordering (jobs within the same stage). NEVER add cross-stage `needs`.
- Entry-point jobs in each stage (e.g., `push-docker-images-prod`, `deploy-migrations-prod`) must have NO `needs` — they are stage-scheduled and will wait for ALL jobs in the previous stage to complete. This ensures gates like `test-ui-staging` and `manual-approval-prod` are both enforced.
- Use `dependencies` (not `needs`) when a job needs artifacts from an earlier stage without affecting execution order.
- `NAMESPACE: platform` must be job-level variable (NOT global) to avoid conflicts with review-app template
- Use `v5` for all template jobs

### Step 7: Create EF Migrations Assets (Conditional)

**Only if `decisions.ef_migrations.enabled: true`:**

1. Create `.config/dotnet-tools.json` with dotnet-ef and swashbuckle tools
2. Generate `migration.sql`:
   ```bash
   dotnet tool restore
   dotnet ef migrations script --idempotent \
     --output {data_project_path}/migration.sql \
     --project {data_project_path} \
     --startup-project {project_path}
   ```

### Step 8: Validate Kustomize Builds

Run kustomize build for all region/environment combinations:
```bash
for region in us uk; do
  for env in dev staging prod; do
    echo "Testing $region/$env..."
    kustomize build k8s/$region/$env > /dev/null
    if [ $? -eq 0 ]; then
      echo "✓ $region/$env builds successfully"
    else
      echo "✗ $region/$env build FAILED"
    fi
  done
done
```

If any build fails, diagnose and fix before proceeding. Reference @${CLAUDE_PLUGIN_ROOT}/references/troubleshooting-guide.md for common issues.

### Step 9: User Review and Commit

**STOP and ask the user to review changes before committing.**

Present a summary:
```
Migration complete. Changes summary:

Files created: {count}
- k8s/base/* ({count} files)
- k8s/overlays/**/* ({count} files)
- k8s/{regions}/**/* ({count} files)
- [conditional files]

Files modified:
- .gitlab-ci.yml (complete rewrite)
- [test files with skipped tests]

Files deleted:
- [list deleted files]

Kustomize validation: {pass/fail for each region/env}

Would you like me to commit and push these changes?
```

### Step 10: Commit and Push

After user approval:

```bash
git add .
git commit -m "feat: migrate to trunk-based development with Kustomize

- Migrate K8s manifests to Kustomize structure (base + overlays)
- Update CI/CD pipeline to trunk-based workflow with v5.x templates
- Add semantic release for automated versioning
- Add review apps support
- Configure production manual approval gates
{conditional lines based on decision trees}

Security improvements:
- Run containers as non-root (UID 1000)
- Use non-privileged port 8080
- Disable privilege escalation
- Implement proper health probe strategy
- Manage secrets via Kubernetes secretKeyRef

Resolves {jira_ticket}"

git push -u origin HEAD
```

### Step 11: Create Merge Request

Use glab CLI to create the MR:

```bash
glab mr create \
  --title "feat: migrate to trunk-based development with Kustomize" \
  --description "## Changes
- Migrated K8s manifests to Kustomize structure (base + overlays)
- Updated CI/CD pipeline to trunk-based workflow with v5.x templates
- Added semantic release for automated versioning
- Added review apps for MR testing
{conditional lines}

## Security Improvements
- Containers run as non-root (UID 1000)
- Using non-privileged port 8080
- Privilege escalation disabled
- Proper health probe strategy implemented
- Secrets managed via Kubernetes secretKeyRef

## Resolves
- {jira_ticket}

## Verification
- [x] Kustomize builds work for all regions/environments
- [ ] MR pipeline runs successfully
- [ ] Review app deploys correctly
- [ ] All tests pass (or flaky tests documented)
- [ ] Production manual approval gate works
{conditional checkboxes}" \
  --target-branch main \
  --squash-before-merge \
  --remove-source-branch
```

Inform the user of the MR URL and suggest running `/dotnet:trunk-validate` after the pipeline completes.
