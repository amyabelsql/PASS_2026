# SQL Guardrails

## Overview

[sql_guardrails.sh](sql_guardrails.sh) reads SQL files and blocks the statements DBAs fear most. It runs on your laptop, as a pre-commit hook, and in the DBA Approval Guardrails workflow on every pull request. When a DBA has reviewed a statement and it is meant to touch the whole table, a tag in a comment lets that one statement through.

| Rule | Blocks | Tag that allows it |
| --- | --- | --- |
| delete-without-where | `DELETE FROM dbo.Orders` with no WHERE | `-- DBA_ALLOW_FULL_TABLE_CHANGE` |
| update-without-where | `UPDATE dbo.Orders SET ...` with no WHERE | `-- DBA_ALLOW_FULL_TABLE_CHANGE` |
| truncate-table | `TRUNCATE TABLE` | `-- DBA_ALLOW_FULL_TABLE_CHANGE` |
| drop-table | `DROP TABLE` | `-- DBA_ALLOW_DROP` |

## Value for DBAs

- The most expensive mistakes are stopped before anyone reviews the pull request
- It gives the file and line number, so the fix is quick
- Every allowed exception is written in the SQL with a tag, so reviewers can see it

## What it does and does not do

| Does | Does not |
| --- | --- |
| Checks each statement, split by semicolons, GO, or a new statement on a new line | Parse the SQL, it reads it as text |
| Ignores SQL inside `--` and `/* */` comments | Catch a WHERE that is only inside a subquery |
| Accepts a tag on the statement or on the line above it | Catch broken SQL such as a column that does not exist, the database tests do that |
| Works with the Mac's built-in bash and on GitHub's Linux runners | Check files outside `02_Database/changes/` in the hook and the workflow |

## What you need

Bash and awk, which come with macOS and Linux. On Windows, use Git Bash or WSL.

## How to create it

1. Copy [sql_guardrails.sh](sql_guardrails.sh) into `04_Automation/` in your repo.
2. Copy [dba-approval-guardrails.yml](../.github/workflows/dba-approval-guardrails.yml) into `.github/workflows/` so it runs on every pull request.
3. Follow [02_Pre_Commit_Hooks.md](02_Pre_Commit_Hooks.md) so it also runs on every commit.

## How to use it

1. Check one or more files.

```bash
bash 04_Automation/sql_guardrails.sh 04_Automation/Demo_Risky_Change.sql
```

2. Read each BLOCKED line. It shows the file, the line number, the rule, and the statement.
3. Fix the statement. If a DBA has reviewed it and it is meant to touch the whole table, add the tag on the line above it.

```sql
-- DBA_ALLOW_FULL_TABLE_CHANGE
TRUNCATE TABLE dbo.Staging;
```

4. Run it again. It ends with SQL guardrails passed when nothing is blocked.

## If it does not work

| What you see | What to do |
| --- | --- |
| `mapfile: command not found` | You have the old copy of the script. Use the one in this folder. |
| A safe statement is blocked | Check that the WHERE is part of the same statement and not in a later one |
| A risky statement was not blocked | Put a semicolon or GO after each statement, then open an issue with the SQL |
