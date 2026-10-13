# Project Board

## What

A project board gives DBAs one operational view for change intake, approval status, scheduling, and deployment readiness.

## Why

Without a board, requests are scattered across issues/PRs and priorities become unclear during release windows.

## How (GitHub UI first)

1. In GitHub, go to **Projects** (user or org level).
2. Click **New project**.
3. Name it (example: `DBA Change Control`).
4. Add fields:
   - **Status** (Intake, Review, Approved, Scheduled, Deployed)
   - **Risk** (Low, Medium, High)
   - **Environment** (Dev, QA, Prod)
   - **Rollback Ready** (Yes/No)
5. Add views:
   - Incoming Requests
   - Ready for Approval
   - Scheduled This Week
   - Post-Deploy Verification
6. Add issues from the DBA issue forms into this board.

## Optional accelerator

Create a project quickly with:

```bash
bash 01_Templates/scripts/create-project-board.sh <owner> "DBA Change Control"
```

## Best practices for DBAs

1. Keep **Status** values aligned with your approval workflow.
2. Add automation so new `dba-change` issues are added to the board automatically.
3. Track high-risk items with explicit SLA/owner fields.
4. Keep one view specifically for “waiting on rollback plan.”
5. Review board aging weekly to prevent stuck change requests.
