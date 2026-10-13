# 03_Approvals

This section focuses on what “approved” means for DBA-grade reliability.

## How to create it

1. Use label policy: `dba-approved`.
2. Require at least one non-author reviewer approval for SQL changes.
3. Enforce both in `.github/workflows/dba-approval-guardrails.yml`.

## Why it matters

Approval standards must be objective and enforceable, not optional guidance.

## How to use it

1. Reviewers confirm risk, rollback, and validation quality.
2. Reviewer applies/keeps `dba-approved` label.
3. Workflow blocks merge when label or approval conditions are missing.

## What a DBA gains

- Reliable merge gates for production-impacting changes.
- Reduced chance of self-approved risky SQL.
- Clear approval evidence for post-incident review.
