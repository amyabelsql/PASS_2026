# Prompt Pack

## Overview

These prompts work in any Copilot chat, including SSMS, VS Code, the CLI, and GitHub. Each one says exactly what to change and what not to touch, which gets a better result than a vague request. They use the sample database in `02_Database/`.

## Value for DBAs

- The same prompt gives the same kind of answer every time
- Each prompt keeps Copilot inside the change you asked for
- New team members can start with prompts that already work

## What it does and does not do

| Does | Does not |
| --- | --- |
| Gives Copilot a clear task, limits, and output format | Guarantee the SQL is correct, you still review and test it |
| Keeps changes small enough to review | Know your servers, data, or business rules unless you add them |

## What you need

Any Copilot plan, including Free.

## How to create it

Copy a prompt below into Copilot chat. Change the object names to match your database.

Safe procedure update

```text
Update dbo.usp_GetCustomerOrders to include CustomerName from dbo.Customers.
Keep existing input parameters and ordering behavior.
Do not introduce schema changes.
Return only SQL.
```

Validation query

```text
Write a SQL validation query that confirms usp_GetCustomerOrders returns only rows for the requested @CustomerID and that CustomerName is populated.
Return only SQL.
```

Rollback script

```text
Generate a rollback script that restores the previous definition of dbo.usp_GetCustomerOrders.
Assume the previous version is available in source control.
Return only SQL.
```

Risk and test plan

```text
Summarize potential risks for this procedure change and list the exact pre-deploy and post-deploy checks.
Use concise bullet points.
```

## How to use it

1. Run one prompt at a time and read the SQL Copilot returns.
2. Save the change under `02_Database/changes/`.
3. Run the SQL guardrails and database tests from [04_Automation](../04_Automation/00_Overview.md).
4. Open a pull request and say which prompt you used.
