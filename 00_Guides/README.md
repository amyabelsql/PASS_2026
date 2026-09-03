# Start Here

This repo is meant to be followed in order.

## Reading order

1. [`01_Automatic-AI-Validation.md`](01_Automatic-AI-Validation.md)
2. [`02_Secret-Leak-Impact.md`](02_Secret-Leak-Impact.md)
3. [`03_Secret-Prevention.md`](03_Secret-Prevention.md)

## Repo order

1. `00_Guides/` — presentation and walkthrough markdown files
2. `01_Docker/` — start SQL Server and local environment scripts
3. `02_Database/` — schema, seed data, stored procedure, and change scripts
4. `03_Tests/` — SQL checks used before and after the AI-generated change
5. `04_Run/` — script that runs the end-to-end validation demo

## Quick setup

1. Copy `.env.example` to `.env`
2. Set `SA_PASSWORD`
3. Run `pre-commit install`
4. Add the GitHub Actions secret `SQL_SA_PASSWORD`

## Quick run

1. Start SQL Server
   - macOS: `bash 01_Docker/Mac/03-Start-SQL-Server.sh`
   - Windows: `pwsh -File 01_Docker/Windows/02-Start-Docker.ps1`
2. Wait for SQL Server: `bash 01_Docker/01_wait-for-sqlserver.sh`
3. Run the demo: `./04_Run/run-tests.sh`
