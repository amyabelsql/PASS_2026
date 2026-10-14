# Guardrails

## Overview

Copilot is fast but it is not accountable for a production outage. You are. Guardrails do two things. They teach Copilot your rules so it gets things right more often, and they make sure anything Copilot writes still goes through the same checks and approvals as code a person wrote.

| Guardrail | Where it lives | Who it teaches or stops |
| --- | --- | --- |
| SQL review rules | [sql-review.instructions.md](../.github/instructions/sql-review.instructions.md) | Copilot code review and the cloud agent |
| Database instructions | `AGENTS.md` and `CONSTITUTION.md` extended properties | Copilot in SSMS |
| Prompt pack | [Copilot_Prompts_For_DBAs.md](../04_Automation/Copilot_Prompts_For_DBAs.md) | People writing prompts |
| SQL checks | [dba-approval-guardrails.yml](../.github/workflows/dba-approval-guardrails.yml) | Every pull request, AI or not |
| Approvals | [02_Approval_Process](../02_Approval_Process/00_Overview.md) | Every merge and every production deploy |

## Value for DBAs

- Copilot writes SQL that matches your standards from the first try more often
- AI written changes cannot skip review, checks, or the production approval
- One set of rules covers people and Copilot

## What it does and does not do

| Does | Does not |
| --- | --- |
| Gives Copilot your standards in every tool | Guarantee Copilot follows them every time |
| Blocks bad SQL with the same checks used for people | Catch logic mistakes such as the wrong WHERE clause |
| Keeps a DBA approval on every production deploy | Stop someone from pasting production data into a prompt |

## What you need

Nothing beyond the Copilot plan for each tool in this section and the approval setup in [02_Approval_Process](../02_Approval_Process/00_Overview.md).

## How to create it

1. Add `.github/instructions/sql-review.instructions.md` to the repo with your SQL standards.
2. Add a `CONSTITUTION.md` extended property to each shared database, see [02_Copilot_in_SSMS.md](02_Copilot_in_SSMS.md).
3. Keep the protected main branch and production environment from [02_Approval_Process](../02_Approval_Process/00_Overview.md) turned on.
4. Write down the team rules below and share them.

## How to use it

Team rules for working with Copilot

1. Never paste passwords, connection strings, or production data into a prompt.
2. Point Copilot at a dev or local database, never production.
3. Read every query before you run it, the same as one from a coworker.
4. Every change goes in a pull request, even when Copilot wrote all of it.
5. Say in the pull request that Copilot helped, so the reviewer knows to look closely.
