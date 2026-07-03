-- before.sql
-- Captures baseline procedure behavior before applying AI-generated change.

SET NOCOUNT ON;

PRINT '=== BEFORE CHANGE: dbo.usp_GetCustomerOrders @CustomerID = 1 ===';
EXEC dbo.usp_GetCustomerOrders @CustomerID = 1;
