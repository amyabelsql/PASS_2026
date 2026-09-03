-- after.sql
-- Captures procedure behavior after the selected change.

SET NOCOUNT ON;

PRINT '=== AFTER CHANGE: dbo.usp_GetCustomerOrders @CustomerID = 1 ===';
EXEC dbo.usp_GetCustomerOrders @CustomerID = 1;
