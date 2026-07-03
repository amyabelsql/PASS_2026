-- 004_ai_generated_good_change.sql
-- Simulates an AI-generated change that is valid and useful.
-- Enhancement: include CustomerName in the output.

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
        c.CustomerName,
        o.OrderDate,
        o.OrderTotal,
        o.OrderStatus
    FROM dbo.Orders AS o
    INNER JOIN dbo.Customers AS c
        ON c.CustomerID = o.CustomerID
    WHERE o.CustomerID = @CustomerID
    ORDER BY o.OrderDate DESC, o.OrderID DESC;
END;
GO
