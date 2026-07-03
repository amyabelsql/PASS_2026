-- 003_create_stored_procedure.sql
-- Initial version of dbo.usp_GetCustomerOrders.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        o.OrderTotal,
        o.OrderStatus
    FROM dbo.Orders AS o
    WHERE o.CustomerID = @CustomerID
    ORDER BY o.OrderDate DESC, o.OrderID DESC;
END;
GO
