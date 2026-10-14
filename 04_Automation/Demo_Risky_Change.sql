-- Demo_Risky_Change.sql
-- A cleanup script with the kind of mistakes AI and tired people both make.
-- make automation-demo runs the SQL guardrails on it. Never run it against a real database.

-- Meant to remove cancelled orders, but the WHERE clause was left off.
DELETE FROM dbo.Orders;

-- Meant to update one customer.
UPDATE dbo.Customers
SET EmailAddress = NULL;

DROP TABLE dbo.Customers;

-- A DBA reviewed this one, so the tag lets it through.
-- DBA_ALLOW_FULL_TABLE_CHANGE
TRUNCATE TABLE dbo.Orders;
