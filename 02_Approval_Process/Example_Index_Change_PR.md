# Example: Index Change PR (What it looks like)

Title:

`Improve order history query with covering index`

Sample PR body:

## Change summary

Adds `IX_Orders_CustomerID_OrderDate` to improve read performance for customer order history.

## Linked issue

Closes #145

## Deployment and rollback

- Deployment window: 2026-11-10 01:00-01:30 UTC
- Rollback command/script:
  - `DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;`
- Data backout plan: N/A (index-only change)

## Validation evidence

- [x] Local SQL checks executed
- [x] Existing CI workflows passed
- [x] Risk and mitigation documented in issue #145

## Index-change evidence (required for index changes)

- Before metrics: 125,000 logical reads, 1800 ms P95 duration
- After metrics (or expected target): expected <75,000 reads, <900 ms P95
- Index rollback command:
  - `DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;`

## Approval checklist

- [x] `dba-approved` label applied
- [x] `index-change` label applied
- [x] Non-author reviewer approved
- [x] Change explained to on-call DBA
