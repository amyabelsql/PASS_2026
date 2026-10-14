# Example: Index Change Issue (What it looks like)

Title:

`[Index Change] Add IX_Orders_CustomerID_OrderDate for order-history query`

Labels:

- `dba-change`
- `index-change`
- `change-control`

Sample body:

## Target table

`dbo.Orders`

## Index name

`IX_Orders_CustomerID_OrderDate`

## Change operation

Create index

## Why this index change is needed

Customer order history query is doing key lookups and high logical reads during peak traffic.

## Before-change evidence

- Duration P95: 1800 ms
- CPU P95: 900 ms
- Logical reads: 125,000
- Plan: `seek + key lookup` (plan link attached in issue)

## Expected success criteria

- Logical reads reduced by at least 40%
- Duration P95 below 900 ms
- CPU P95 reduced by at least 25%

## Rollback plan

```sql
DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;
```
