# 1. Templates and Approval Process for DBAs

This demo standardizes change intake so every SQL request is complete, reviewable, and auditable.

## 1A. Templates to create repositories

### How to create it

1. Mark a repository as a template in GitHub Settings.
2. Use the helper script:

```bash
bash 05_PASS_Summit_Demos/scripts/create-repo-from-template.sh <template-owner/repo> <new-owner/repo> private
```

### Why it matters

A template repo gives every new DBA project the same starting controls: workflows, issue forms, pre-commit hooks, and approval patterns.

### How to use it

Create a fresh demo repo from template before each workshop to avoid drift.

### What a DBA gains

Consistent guardrails across projects without manually rebuilding process each time.

## 1B. Templates for issues

### How to create it

Classic issue templates are stored in `.github/ISSUE_TEMPLATE/03_dba-maintenance.md`.

### Why it matters

Recurring work (index maintenance, stats updates, post-release checks) becomes structured instead of ad-hoc.

### How to use it

Select **DBA maintenance task** when opening an issue and fill in environment, window, and validation fields.

### What a DBA gains

Clearer handoffs and less back-and-forth for routine operational work.

## 1C. Issue forms

### How to create it

Structured issue forms are in:

- `.github/ISSUE_TEMPLATE/01_dba-change-request.yml`
- `.github/ISSUE_TEMPLATE/02_dba-incident.yml`
- `.github/ISSUE_TEMPLATE/config.yml`

### Why it matters

Required fields enforce risk level, rollback strategy, and validation criteria before work begins.

### How to use it

Open a new issue and choose **DBA change request** or **DBA incident report**.

### What a DBA gains

Safer production changes because missing rollback plans are caught before implementation.

## 1D. Project boards

### How to create it

Create a project board with:

```bash
bash 05_PASS_Summit_Demos/scripts/create-project-board.sh <owner> "DBA Change Control"
```

### Why it matters

Project views make it obvious which requests are waiting for risk review, approval, scheduling, or deployment.

### How to use it

Add change-request issues to the board and group by status/risk.

### What a DBA gains

One operational surface for prioritization, scheduling, and release readiness.

## Suggested approval process for DBAs

### How to create it

1. Add code ownership in `.github/CODEOWNERS`.
2. Require PR details via `.github/PULL_REQUEST_TEMPLATE.md`.
3. Enforce checks in `.github/workflows/dba-approval-guardrails.yml`.
4. In branch protection, require status checks and code-owner review.

### Why it matters

Approvals become policy-driven instead of personality-driven.

### How to use it

Reviewers approve only when change summary, rollback steps, and validation evidence are present.

### What a DBA gains

Lower change-failure rate and stronger auditability for compliance-heavy environments.
