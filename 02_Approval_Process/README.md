# 02_Approval_Process

This directory now combines **approval process** and **approval controls** in one place.

## What is in this directory (demo-first assets)

| File | Use in demo |
| --- | --- |
| `run-approval-demo.sh` | Prepares demo SQL and prints the exact GitHub flow to show |
| `setup-dba-labels.sh` | Creates/updates required labels (`dba-approved`, `index-change`, etc.) |
| `Demo_Index_Change.sql` | Real index-change SQL used to trigger approval checks |
| `Example_Index_Change_Issue.md` | Example issue content to show stakeholders |
| `Example_Index_Change_PR.md` | Example PR body with required evidence sections |
| `Example_Approval_Checks.md` | Fail/pass scenarios for live workflow demonstration |

## Why this matters for DBAs

- Enforces change control, not just documentation.
- Ties SQL/index changes to issues and explicit approvals.
- Produces clear, auditable evidence in GitHub.

## How to run the approval demo

From repository root:

```bash
bash 02_Approval_Process/run-approval-demo.sh <owner/repo>
```

This will:

1. Copy demo index SQL into `02_Database/changes/005_index_change_demo.sql`
2. Configure required approval labels in the target repo (if repo argument is provided)
3. Print the exact steps to show fail/pass behavior in GitHub

## What to show in GitHub (live)

1. Open issue form: **DBA index change request**.
2. Open PR that includes:
   - `02_Database/changes/005_index_change_demo.sql`
   - `Closes #<issue-number>` in PR body
3. Show a failing check by removing:
   - `dba-approved` label, or
   - issue link, or
   - `index-change` label when index SQL is present
4. Add required labels and non-author approval.
5. Show passing `DBA Approval Guardrails` workflow.

## GitHub controls this demo depends on

- `.github/ISSUE_TEMPLATE/04_index-change-request.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/dba-approval-guardrails.yml`

## Best practices

1. Require index evidence and rollback command in both issue and PR.
2. Keep approval rules in workflow code so policy is enforced, not optional.
3. Use one failing and one passing PR in every presentation.
4. Keep labels consistent across repositories via `setup-dba-labels.sh`.
