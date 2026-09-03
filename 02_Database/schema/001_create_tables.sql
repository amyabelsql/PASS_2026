-- 001_create_tables.sql
-- Creates the demo schema objects for GitDemoDb.

SET NOCOUNT ON;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Orders;
END;

IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Customers;
END;

CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    EmailAddress NVARCHAR(255) NULL,
    CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderTotal DECIMAL(10,2) NOT NULL,
    OrderStatus NVARCHAR(30) NOT NULL DEFAULT N'Pending',
    CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Orders_Customers_CustomerID
        FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

CREATE INDEX IX_Orders_CustomerID ON dbo.Orders(CustomerID);
