---
applyTo: "02_Database/**/*.sql"
---

# SQL review rules for DBAs

When you review SQL Server changes in this repo, start the overview with a short summary a DBA can read in under a minute. List each object that is created, altered, or dropped, say whether the change is low, medium, or high risk, and say whether a rollback statement is included.

Flag these in review comments.

- DROP TABLE, DROP COLUMN, or TRUNCATE TABLE. These are high risk and need a DBA.
- CREATE, DROP, or ALTER INDEX without a rollback statement in a comment.
- UPDATE or DELETE without a WHERE clause.
- Large UPDATE or DELETE statements that are not batched.
- SELECT * in views, procedures, or functions.
- Object names without a schema, such as Orders instead of dbo.Orders.
- NOLOCK or READ UNCOMMITTED hints.
- Functions wrapped around columns in WHERE or JOIN clauses, which stop index seeks.
- New columns that are NOT NULL without a default on an existing table.
- Hard coded passwords, connection strings, or server names.

Only treat a change as low risk if it adds an index with a rollback, adds a nullable column, or changes a comment.
