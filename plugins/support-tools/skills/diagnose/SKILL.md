---
name: diagnose
description: Diagnose a Sentry issue, analyze root cause using CPOMS codebase, and recommend scripts with cascading diagnostic workflows
argument-hint: "<sentry-issue-url>"
---

# Diagnose Sentry Issue

Given the Sentry issue URL: `$ARGUMENTS`

## Overview

This skill performs intelligent diagnosis of Sentry errors by:
1. Fetching and analyzing the Sentry issue
2. Fetching script documentation for gotchas and tips
3. Exploring the CPOMS codebase to understand root cause
4. Recommending a **diagnostic workflow** (logging scripts first, then destructive scripts)

## Important Context

**Scripts are workarounds, not fixes.** They resolve data issues caused by underlying bugs or defects, allowing customers to continue using the system while the root cause is investigated. If the root cause of an issue is unknown, recommend that the user investigates further - the script just unblocks the customer.

## Script Categories

There are two types of scripts:

| Type | Purpose | Examples |
|------|---------|----------|
| **Logging** | Output data only - useful for debugging or revealing internal IDs needed by other scripts | `log_*`, `find_*`, `print_*`, `show_*` |
| **Destructive** | Modify data (destroy, update, create) | `dedupe_*`, `destroy_*`, `fix_*`, `bulk_*` |

**Important**: Logging scripts often reveal IDs or state needed to run destructive scripts correctly. Always recommend the diagnostic workflow.

## Script Execution

Scripts are executed from within **Manage** (not the terminal). When recommending scripts, provide:
- Script name
- Customer identifier (subdomain from Sentry tags)
- Required arguments
- Whether to enable dry-run

---

## Phase 1: Gather Context (Run in Parallel)

### 1.1 Fetch Sentry Issue

Use `mcp__sentry__get_issue_details` with the provided URL to extract:
- **Error type**: The exception class (e.g., `RuntimeError`, `ActiveRecord::RecordNotUnique`)
- **Error message**: The full error description
- **Model name**: If the error involves a specific model (extract from message)
- **Tenant**: From the `subdomain` tag
- **Location**: The file and line where the error originated
- **Stacktrace**: Full call stack for code analysis

### 1.2 Fetch Script Documentation

Use `mcp__atlassian__getConfluencePage` to fetch the script reference documentation:
- **cloudId**: `raptortech1.atlassian.net`
- **pageId**: `258444595`
- **contentFormat**: `markdown`

This page contains:
- Descriptions of permitted 2nd line scripts
- Script-specific gotchas and tips
- Use cases for each script
- Required arguments
- Cascading relationships (e.g., "run X first, then Y")

**Extract and use this information when making recommendations.**

### 1.3 List Available Scripts

Use `mcp__scripts__list_scripts_tool` for project `cpoms` to get the current list of available scripts.

---

## Phase 2: CPOMS Codebase Analysis

**This is critical for intelligent diagnosis.** Use the Explore agent to understand:

1. **The error location**: Read the file/method where the error was raised
2. **The data flow**: Trace how data gets to that point (especially for imports)
3. **The model involved**: Understand the model's relationships and constraints
4. **Known issues**: Search for related JIRA issues or TODOs in the codebase

Example exploration prompts:
- "Read lib/import/sync/importer.rb around line 1077 to understand why it raises on multiple instances"
- "Find how Sen records are created and what constraints exist"
- "Search for known issues with duplicate {model} records"

---

## Phase 3: Script Matching & Workflow

### 3.1 Match Scripts to Error

Based on the error analysis and the Confluence documentation:

1. **Identify the error pattern** from the Sentry issue
2. **Find matching scripts** from the Confluence page that address this pattern
3. **Check for cascading relationships** - some scripts should be run before others
4. **Note any logging scripts** that should be run first to gather information

### 3.2 Fetch Script Details

Use `mcp__scripts__get_script_tool` for each relevant script to understand:
- What it does (from source code)
- What options/arguments it accepts
- Whether it supports dry-run mode
- Any script-specific logic that affects recommendations

---

## Phase 4: Present Diagnostic Workflow

Structure the output as a **workflow**, not just a single script recommendation:

```markdown
## Issue Summary
- **Error**: <error message>
- **Tenant**: <subdomain>
- **Occurrences**: <count>
- **Location**: <file:line>

## Root Cause Analysis
<explanation based on codebase analysis>

If the root cause is **unknown or unclear**, state this explicitly and recommend investigation:
> The root cause of this issue is not yet determined. The recommended script will unblock the customer,
> but further investigation is needed to identify and fix the underlying bug.

## Diagnostic Workflow

### Step 1: Gather Information (Logging Scripts)
> Run these first in Manage to understand the current state and gather IDs if needed

| Field | Value |
|-------|-------|
| **Script** | `<logging_script_name>` |
| **Customer** | `<subdomain>` |
| **Purpose** | <what information it reveals> |
| **Arguments** | <any required arguments> |

### Step 2: Apply Fix (Destructive Scripts)
> Run in Manage after reviewing Step 1 output. Always dry-run first if supported.

| Field | Value |
|-------|-------|
| **Script** | `<destructive_script_name>` |
| **Customer** | `<subdomain>` |
| **Purpose** | <what it fixes> |
| **Dry Run** | `true` (run first to verify) |
| **Arguments** | <any required arguments> |

After verifying dry-run output, run again with Dry Run disabled.

### Gotchas & Tips
- <script-specific warnings from Confluence page>
- <tips from Confluence page>

### Follow-up Investigation
If root cause is unknown:
- <suggested areas to investigate>
- <potential JIRA ticket to create>
```

---

## Important Notes

1. **Always recommend dry-run first** for destructive scripts (unless the Confluence page indicates the script doesn't support it)
2. **Never search for customer by name** in Manage - use LA/DfE or exact CPOMS URL
3. **If no matching script exists**, explain what a fix would need to do and suggest creating one
4. **If multiple scripts could apply**, list all options with explanations
5. **Include the tenant name** from Sentry tags so the engineer can target the right school
6. **For cascading workflows**, clearly indicate the dependency between scripts
7. **Always check the Confluence page** for the latest gotchas - this information changes over time
8. **Scripts are workarounds** - always consider whether the root cause needs investigation
