# 02_Approval_Process

This section defines a practical approval process for database changes before merge and deployment.

## How to create it

1. Define ownership in `.github/CODEOWNERS`.
2. Require operational detail in `.github/PULL_REQUEST_TEMPLATE.md`.
3. Configure branch protection to require:
   - status checks
   - code owner review
   - up-to-date branch before merge
4. Require issue linkage to the change request form.

## Why it matters

A documented process prevents urgent but unsafe changes from bypassing review discipline.

## How to use it

1. Open issue form first (risk + rollback + validation).
2. Open PR with linked issue.
3. Reviewer verifies rollback and validation evidence.
4. Merge only when guardrail checks and approvals are complete.

## What a DBA gains

- Lower production change failure risk.
- Better auditability for regulated environments.
- Clearer accountability on who approved what and why.
