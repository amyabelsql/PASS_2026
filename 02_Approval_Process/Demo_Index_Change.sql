-- 005_index_change_demo.sql
-- Demo index change to show approval + issue-link controls.
-- Replace issue reference with a real issue in your PR:
-- Related issue: #<issue-number>

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate
ON dbo.Orders (CustomerID, OrderDate DESC)
INCLUDE (OrderTotal, OrderStatus);
GO

-- Rollback command for documentation:
-- DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;
