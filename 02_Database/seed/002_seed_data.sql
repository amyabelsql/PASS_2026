-- 002_seed_data.sql
-- Seeds demo data: 3 customers and 5 orders.

SET NOCOUNT ON;

INSERT INTO dbo.Customers (CustomerName, EmailAddress)
VALUES
    (N'Amy Adams', N'amy.adams@example.com'),
    (N'Ben Carter', N'ben.carter@example.com'),
    (N'Casey Diaz', N'casey.diaz@example.com');

INSERT INTO dbo.Orders (CustomerID, OrderDate, OrderTotal, OrderStatus)
VALUES
    (1, '2026-01-10', 150.00, N'Complete'),
    (1, '2026-02-14', 225.50, N'Shipped'),
    (2, '2026-02-20', 90.00, N'Pending'),
    (3, '2026-03-02', 410.25, N'Complete'),
    (2, '2026-03-18', 75.99, N'Cancelled');
