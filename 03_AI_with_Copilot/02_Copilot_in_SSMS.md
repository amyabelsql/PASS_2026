# Copilot in SSMS

## Overview

SQL Server Management Studio 22 has GitHub Copilot built in. It uses the connection in your query window, so it can answer questions about the actual database you are on. It writes and explains T-SQL, suggests code as you type, and can remember business rules that you store in the database as database instructions.

## Value for DBAs

- Ask "which tables have no clustered index" in plain English and get the query
- Explain an inherited stored procedure in seconds
- Store rules such as "never use SELECT *" in the database so every Copilot user gets them

## What it does and does not do

| Does | Does not |
| --- | --- |
| Chats about the database you are connected to | Work in SSMS 21 or older |
| Suggests T-SQL as you type, starting in SSMS 22.2 | Run changes in Ask mode, it gives you the script to run yourself |
| Reads database instructions stored as extended properties, starting in SSMS 22.3 | Know your business rules unless you add them as database instructions |
| Runs queries for you in Agent mode, which is in preview starting in SSMS 22.7 | Keep your prompts or responses, according to Microsoft |

## What you need

| Item | What to know |
| --- | --- |
| SSMS | Version 22 or later with the AI Assistance workload |
| Copilot plan | Copilot Free works with monthly limits. Any paid plan removes the limits. |
| Organization accounts | Admins can turn Copilot off in GitHub Copilot settings, starting with SSMS 22.4.1 |

## How to create it

1. Install or update to SSMS 22.
2. Open SSMS and connect to a server.
3. Click the GitHub Copilot badge in the upper right corner and choose Open Chat Window to Sign In.
4. If it says Copilot is not installed, click Install Copilot, or open the Visual Studio Installer and add the AI Assistance workload to SSMS.
5. Sign in with your GitHub account, or choose Sign up for Copilot Free.

Database instructions

1. In Copilot chat, describe the rule, such as `Add an instruction for dbo.Orders that OrderStatus values are Pending, Shipped, and Cancelled.`
2. Copilot writes a `sp_addextendedproperty` statement with the name `AGENTS.md`. Review it and run it yourself.
3. For a rule that covers the whole database, add one extended property named `CONSTITUTION.md` at the database level.

```sql
EXECUTE sp_addextendedproperty
    @name = N'CONSTITUTION.md',
    @value = N'Do not use SELECT *. Always use schema names. Every index change needs a rollback statement.';
```

## How to use it

1. Open a query window on the database you want to work with.
2. Ask a question in the chat window, such as `Which indexes on dbo.Orders have not been used since the last restart?`
3. Read the query Copilot writes before you run it.
4. Save any change scripts you keep into `02_Database/changes/` and open a pull request so they go through the normal approvals.

## If it does not work

| What you see | What to do |
| --- | --- |
| No GitHub Copilot badge | Update to SSMS 22 or later |
| Copilot will not run your change | You are in Ask mode. Copy the script and run it yourself. |
| Copilot ignores your rules | Check that the extended property is named exactly `AGENTS.md` or `CONSTITUTION.md` |
