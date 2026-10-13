# 2. Approvals and Automation

This demo shows how to automate policy checks so risky SQL never merges by accident.

## 2A. Automation that checks for bad requests

### How to create it

1. Guardrail script: `05_PASS_Summit_Demos/scripts/sql_guardrails.sh`
2. PR workflow: `.github/workflows/dba-approval-guardrails.yml`

### Why it matters

The script catches dangerous patterns early (for example, `UPDATE` or `DELETE` without `WHERE`, and `DROP TABLE` without explicit waiver tags).

### How to use it

Run locally:

```bash
bash 05_PASS_Summit_Demos/scripts/sql_guardrails.sh 02_Database/changes/004_ai_generated_good_change.sql
```

In pull requests, the workflow automatically runs guardrails against changed SQL files.

### What a DBA gains

A reproducible safety net that blocks high-risk SQL before code review fatigue can miss it.

## 2B. Copilot and automated checks

### How to create it

1. Use Copilot to draft SQL changes.
2. Keep CI checks as the final gate (`database-pr-tests.yml` + `dba-approval-guardrails.yml`).
3. Capture prompts/edits in the change request form field.
4. Use the prompt pack in `05_PASS_Summit_Demos/Copilot_Prompts_For_DBAs.md`.

### Why it matters

Copilot speeds draft creation; automation protects production reliability.

### How to use it

Generate a draft, refine manually, then rely on automated checks to validate behavior.

### What a DBA gains

Faster development without trading away operational confidence.

## 2C. Pre-commit hooks

### How to create it

The local hook is registered in `.pre-commit-config.yaml`:

- `dba-sql-guardrails` runs before commits for `02_Database/changes/*.sql`.

### Why it matters

Feedback happens before pushing, reducing noisy PR churn.

### How to use it

```bash
pre-commit install
pre-commit run dba-sql-guardrails --all-files
```

### What a DBA gains

Shorter fix cycles and fewer CI failures caused by preventable SQL mistakes.

## 2D. Service containers

### How to create it

Service-container test execution is already demonstrated in:

- `.github/workflows/database-pr-tests.yml`

It launches SQL Server in CI and runs the same validation scripts used locally.

### Why it matters

Every PR gets a clean, repeatable database environment.

### How to use it

Open a PR touching database scripts and inspect the **Run SQL validation tests** job output.

### What a DBA gains

Reliable regression checks with no dependency on shared dev databases.
