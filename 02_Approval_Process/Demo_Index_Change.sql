-- 005_index_change_demo.sql
-- Index change used in the approvals demo. make approvals-demo copies this file
-- into 02_Database/changes/ in the demo repo and opens a pull request with it.

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate
ON dbo.Orders (CustomerID, OrderDate DESC)
INCLUDE (OrderTotal, OrderStatus);
GO

-- Rollback
-- DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;
