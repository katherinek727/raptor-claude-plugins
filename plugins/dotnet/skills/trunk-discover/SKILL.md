---
name: trunk-discover
description: "Scan the current .NET repo to auto-detect service configuration and generate trunk-migration-config.yaml. Triggers: trunk discover, discover service, analyze repo, scan for migration"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - AskUserQuestion
  - Task
---

# Trunk Migration Discovery

You are the discovery skill for trunk-based migration. Your job is to scan the current repository, detect its configuration, ask the user for any missing information, and produce a complete `trunk-migration-config.yaml` file.

Reference the config schema at: @${CLAUDE_PLUGIN_ROOT}/references/config-schema.md

## Phase 1: Auto-Scan

Scan the repository to detect as much configuration as possible. Use Glob, Grep, and Read tools to find:

### 1.1 Service Information

- **Solution file**: Glob for `*.sln` or `*.slnx` in repo root
- **API project**: Glob for `src/*Api*/*.csproj` or similar patterns
- **DLL name**: Read the `.csproj` to find `<AssemblyName>` or infer from project name
- **Dockerfile**: Glob for `**/Dockerfile` to find the `ENTRYPOINT` which reveals the DLL path
- **Service name**: Infer from existing K8s manifests (`metadata.name` in deployment.yaml) or from Dockerfile

### 1.2 Current CI/CD Configuration

- **Read `.gitlab-ci.yml`**: Identify current stages, variables, includes, and job definitions
- **Pipeline template version**: Check `ref:` values in include blocks
- **Existing variables**: Extract `APP_NAME`, `SERVICE_NAME`, `PROJECT_PATH`, etc.

### 1.3 Kubernetes Manifests

- **Glob for `k8s/**/*.yaml`**: Read existing manifests
- **Extract namespace**: Read `metadata.namespace` from base deployment.yaml — this is the Kubernetes namespace used for deployments (commonly `platform`). This value is critical for review overlay patch matching and secret creation
- **Extract from deployments**: Environment variables, secret references, resource limits/requests, health check endpoints, ports, node selectors
- **Identify regions**: Check for `k8s/dev/`, `k8s/stag/`, `k8s/prod/` patterns or region-specific directories

### 1.4 Decision Tree Detection

- **Auth0**: Check if `auth0/` directory exists with `Glob("auth0/**/*")`
- **NuGet packages**: Check for `.Client`, `.Shared`, `.Maps` project directories with `Glob("src/**/*.csproj")`
- **EF Migrations**: Check for `DataMigrations` project with `Glob("src/**/*DataMigrations*/*.csproj")`
- **API versions**: Check for `[ApiVersion]` attributes or versioned controllers with `Grep("ApiVersion|\\[Route.*v[0-9]")`
- **UI regression tests**: Check if existing `.gitlab-ci.yml` contains a `test-ui-staging` or `test-ui-prod` job, or references a QA automation trigger project. If found, set `decisions.ui_tests.enabled: true` and extract the `trigger.project` path and `SCHEDULE_NAME` variable values if present (staging and prod may have different schedule names).

### 1.5 Database Configuration

- **DbContext name**: Grep for `DbContext` class definitions
- **Connection string key**: Grep for `GetConnectionString` or `ConnectionStrings:` references
- **Data project path**: Found during NuGet/EF detection

### 1.6 Gateway Configuration

- **Detect gateway controller**: Search existing HTTPRoute manifests for `parentRefs` to identify the gateway controller in use
  - Look in `k8s/**/*.yaml` and `k8s/overlays/review/**/*.yaml` for `kind: HTTPRoute` with `parentRefs`
  - Extract `name` and `namespace` from the parentRef (e.g., `name: gateway`, `namespace: azure-alb` for Azure ALB Gateway)
  - If no HTTPRoute exists, check for IngressRoute (Traefik) or Ingress (nginx) resources
- If no gateway is detected, ask the user which gateway controller the cluster uses. If they confirm platform defaults, use Azure ALB Gateway (`name: gateway`, `namespace: azure-alb`)

### 1.7 Existing Resource Configuration

- **Resource limits**: Extract from current deployment manifests
- **Health check paths**: Extract from current readiness/liveness probes
- **Ports**: Extract from container port definitions
- **Environment variables**: Extract full list from current deployments

## Phase 2: Interactive Gap-Fill

After scanning, identify what could NOT be auto-detected. Use `AskUserQuestion` to gather missing information. Common gaps include:

### Required Information (always ask if not found)

1. **ACR registry names** for each region/environment (6 values for us/uk x dev/staging/prod)
2. **AKS cluster names** for each region/environment
3. **AKS cluster resource groups** for each region/environment
4. **Azure App Config names** for each region/environment
5. **Jira ticket ID** for the migration work
6. **Connection string key** (if EF migrations detected but key not found in code)
7. **APIM API_IDs** for each region/environment/version combination (these are existing values from Azure APIM — do NOT generate new ones, ask the user to provide them)
8. **UI regression tests** — ALWAYS ask the user: "Does this service have UI regression tests that should run after staging deployment? And after production deployment?" If yes for either (or if auto-detected from `.gitlab-ci.yml`), set `decisions.ui_tests.enabled: true` and ask for:
   - `trigger_project` — the GitLab project path for the QA automation framework (e.g., `raptortech1/raptor/quality-assurance/qa-automation/web-ui-framework-2-platform`)
   - `schedule_name` — staging schedule name (e.g., "CICD - Client Building Service - P0,P1 - Staging"), leave empty if no staging UI tests
   - `schedule_name_prod` — prod schedule name (e.g., "CICD - Client Building Service - P0,P1 - Prod"), leave empty if no prod UI tests

### Validation Questions

Present detected values to the user for confirmation:

```
I detected the following configuration:
- Service name: clientbuilding-api
- App name: clientbuilding
- Kubernetes namespace: platform
- Gateway: gateway (namespace: azure-alb)
- API versions: v1, v2
- Auth0: enabled
- NuGet packages: Client, Shared, Maps
- UI Tests: enabled (staging: "CICD - Client Building Service - P0,P1 - Staging", prod: "CICD - Client Building Service - P0,P1 - Prod")
- EF Migrations: enabled (ClientsDBContext)

Is this correct? What needs to be changed?
```

## Phase 3: Generate Config

After collecting all information, write the complete `trunk-migration-config.yaml` to the repository root.

Use the schema from @${CLAUDE_PLUGIN_ROOT}/references/config-schema.md as the template.

### Output

Write the file and inform the user:

```
Created trunk-migration-config.yaml with:
- Service: {service_name}
- Regions: {regions}
- Decision trees: Auth0={yes/no}, NuGet={yes/no}, EF={yes/no}, Multi-version API={yes/no}
- Environments: dev, staging, prod

Next step: Run /dotnet:trunk-plan to preview the migration execution plan.
```

## Error Handling

- If the repository doesn't appear to be a .NET project (no `.sln` or `.csproj`), inform the user this plugin is for .NET API services
- If no existing K8s manifests are found, note this is a greenfield migration and more information will be needed
- If `.gitlab-ci.yml` doesn't exist, warn that CI/CD will be created from scratch

## Config File Argument

If `$ARGUMENTS` contains a path to an existing config file, read it and validate against the schema instead of running discovery. Report any missing required fields.
