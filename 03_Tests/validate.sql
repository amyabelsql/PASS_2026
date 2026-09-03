-- validate.sql
-- Verifies the procedure exists and executes successfully.

SET NOCOUNT ON;

IF OBJECT_ID('dbo.usp_GetCustomerOrders', 'P') IS NULL
BEGIN
    THROW 50001, 'Validation failed: dbo.usp_GetCustomerOrders does not exist.', 1;
END;

PRINT 'Validation check: procedure exists.';
PRINT 'Validation check: executing dbo.usp_GetCustomerOrders @CustomerID = 1.';

EXEC dbo.usp_GetCustomerOrders @CustomerID = 1;

PRINT 'Validation passed.';
