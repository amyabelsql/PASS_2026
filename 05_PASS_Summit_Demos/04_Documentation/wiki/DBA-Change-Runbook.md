# DBA Change Runbook

## Pre-deployment

1. Confirm linked issue has risk, validation, and rollback plan.
2. Confirm PR has `dba-approved` label and non-author approval.
3. Confirm CI checks are green.

## Deployment

1. Announce start in operations channel.
2. Execute change script.
3. Run validation queries and compare to baseline.

## Post-deployment

1. Capture metrics and query latency.
2. Close issue with evidence links.
3. Record follow-up actions for improvements.
