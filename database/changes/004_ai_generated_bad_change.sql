-- 004_ai_generated_bad_change.sql
-- Simulates an AI-generated mistake:
-- references a non-existent column (o.AI_Made_Up_Column).

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
        o.AI_Made_Up_Column, -- Intentional error for demo.
        o.OrderDate,
        o.OrderTotal,
        o.OrderStatus
    FROM dbo.Orders AS o
    WHERE o.CustomerID = @CustomerID
    ORDER BY o.OrderDate DESC, o.OrderID DESC;
END;
GO
