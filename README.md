# Trust but Verify: Testing AI-Generated SQL

This repo is organized to be easy to follow in order.

Start with the markdown guides in [`00_Guides/`](00_Guides/README.md), then move through setup, database files, tests, and the run script.

| Part | Focus | Start here |
| --- | --- | --- |
| 0 | Start here | [`00_Guides/README.md`](00_Guides/README.md) |
| 1 | Automatically testing AI-generated database changes | [`00_Guides/01_Automatic-AI-Validation.md`](00_Guides/01_Automatic-AI-Validation.md) |
| 2 | What happens when secrets get committed, why that is dangerous, and how to reproduce it safely | [`00_Guides/02_Secret-Leak-Impact.md`](00_Guides/02_Secret-Leak-Impact.md) |
| 3 | Preventing password and secret leaks | [`00_Guides/03_Secret-Prevention.md`](00_Guides/03_Secret-Prevention.md) |
| 4 | PASS Summit governance demo order | [`00_Guides/PASS_Summit_Demo_Order.md`](00_Guides/PASS_Summit_Demo_Order.md) |
| 5 | Webinar quick path | [`Webinar/00_Guide/README.md`](Webinar/00_Guide/README.md) |

## Repo layout

- `00_Guides/` — reader-facing markdown walkthroughs
- `01_Docker/` — Docker and SQL Server setup scripts
- `02_Database/` — schema, seed data, stored procedure, and AI change scripts
- `03_Tests/` — before/after/validation SQL checks
- `04_Run/` — main script to run the SQL validation flow
- `01_Templates/` — repository templates, issue templates/forms, and project board setup
- `02_Approval_Process/` pull request and deployment approvals, mobile, Slack, Teams, and change records
- `03_AI_with_Copilot/` GitHub Copilot on GitHub, in SSMS, in VS Code, in the terminal, and the guardrails around it
- `04_Automation/` — guardrails, pre-commit, Copilot prompts, CI automation
- `05_Webhooks/` — webhook setup and external integration demo
- `06_Actions/` — GitHub Actions workflow/runners/secrets demo
- `07_Documentation/` — wiki, Mermaid, and gist documentation assets
- `08_Tips_and_Tricks/` — presenter and operator shortcuts
- `Webinar/` — webinar-focused quick track (`00_Guide`, `01_Secrets`)
- `.github/workflows/` — pull request and secret scanning automation

## Prerequisites

- Docker Desktop
- Git
- GitHub account
- GitHub Copilot plugin
- `pre-commit`
- `sqlcmd`

## One-time setup

1. Copy `.env.example` to `.env`
2. Set a strong local SQL password in `SA_PASSWORD`
3. Add the repository secret `SQL_SA_PASSWORD` in GitHub Actions
4. Install local hooks with `pre-commit install`

Example local `.env` values:

```dotenv
SA_PASSWORD=replace-with-a-strong-local-password
SQL_PASSWORD=replace-with-a-strong-local-password
SQL_SERVER=localhost
SQL_PORT=1433
SQL_USER=sa
DB_NAME=GitDemoDb
```

## Quick start

1. Start SQL Server
   - macOS: `bash 01_Docker/Mac/03-Start-SQL-Server.sh`
   - Windows: `pwsh -File 01_Docker/Windows/02-Start-Docker.ps1`
2. Wait for SQL Server: `bash 01_Docker/01_wait-for-sqlserver.sh`
3. Run the validation flow: `./04_Run/run-tests.sh`

To demonstrate a failing AI-generated change:

```bash
CHANGE_SCRIPT=02_Database/changes/004_ai_generated_bad_change.sql ./04_Run/run-tests.sh
```
