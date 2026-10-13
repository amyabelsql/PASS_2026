# Copilot Prompt Pack for DBAs

Use these prompts during the automation demo so Copilot generation stays consistent across sessions.

## Prompt 1: Safe procedure update

```text
Update dbo.usp_GetCustomerOrders to include CustomerName from dbo.Customers.
Keep existing input parameters and ordering behavior.
Do not introduce schema changes.
Return only SQL.
```

## Prompt 2: Add a validation query

```text
Write a SQL validation query that confirms usp_GetCustomerOrders returns only rows for the requested @CustomerID and that CustomerName is populated.
Return only SQL.
```

## Prompt 3: Rollback script

```text
Generate a rollback script that restores the previous definition of dbo.usp_GetCustomerOrders.
Assume the previous version is available in source control.
Return only SQL.
```

## Prompt 4: Explain risk and test strategy

```text
Summarize potential risks for this procedure change and list the exact pre-deploy and post-deploy checks.
Use concise bullet points.
```

## How to use these prompts

1. Run one prompt at a time and review generated SQL manually.
2. Place generated SQL under `02_Database/changes/`.
3. Run guardrails and tests before opening a PR.
4. Include the prompt and your edits in the issue form for traceability.
