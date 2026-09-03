-- before.sql
-- Captures baseline procedure behavior before the change.

SET NOCOUNT ON;

PRINT '=== BEFORE CHANGE: dbo.usp_GetCustomerOrders @CustomerID = 1 ===';
EXEC dbo.usp_GetCustomerOrders @CustomerID = 1;
