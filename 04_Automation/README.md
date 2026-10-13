# 04_Automation

This section automates quality checks so bad SQL patterns are blocked quickly and consistently.

## A. Automation that checks for bad requests

### How to create it

1. Guardrail script: `04_Automation/scripts/sql_guardrails.sh`
2. PR workflow: `.github/workflows/dba-approval-guardrails.yml`

### Why it matters

It blocks high-risk SQL patterns before merge.

### How to use it

```bash
bash 04_Automation/scripts/sql_guardrails.sh 02_Database/changes/004_ai_generated_good_change.sql
```

### What a DBA gains

Automated protection against common destructive mistakes.

## B. Copilot and automated checks

### How to create it

1. Use Copilot to draft SQL.
2. Keep CI checks as final gate.
3. Capture prompt and edits in the change request issue.
4. Use `04_Automation/Copilot_Prompts_For_DBAs.md`.

### Why it matters

Copilot accelerates drafting, automation preserves reliability.

### How to use it

Generate, review, run checks, then submit PR.

### What a DBA gains

Higher throughput without relaxing quality standards.

## C. Pre-commit hooks

### How to create it

`.pre-commit-config.yaml` runs `dba-sql-guardrails` on `02_Database/changes/*.sql`.

### Why it matters

Fast local feedback catches errors before CI.

### How to use it

```bash
pre-commit install
pre-commit run dba-sql-guardrails --all-files
```

### What a DBA gains

Fewer failed PR cycles.

## D. Service containers

### How to create it

Use `.github/workflows/database-pr-tests.yml` with SQL Server service container.

### Why it matters

Every PR is validated in a clean, reproducible database runtime.

### How to use it

Open a PR with SQL changes and review the workflow output.

### What a DBA gains

Environment-consistent validation without shared-instance drift.
