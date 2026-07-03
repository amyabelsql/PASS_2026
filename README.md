# Trust but Verify: Testing AI-Generated SQL

Step-by-step lab for a PASS Summit webinar. This repo shows how to test SQL changes before merge using Docker, shell scripts, pre-commit hooks, and GitHub Actions.

## Lab flow

1. Start SQL Server in Docker.
2. Run the baseline database setup.
3. Apply the good AI-generated change.
4. Re-run the same flow with the bad AI-generated change.
5. Open a pull request and watch GitHub Actions run the same checks.

## What’s in this repo

```text
database/      schema, seed, stored proc, good/bad change scripts
tests/         before.sql, after.sql, validate.sql
scripts/       wait-for-sqlserver.sh, run-tests.sh
test-results/  output logs from each run
.github/       PR workflow for database tests
```

## Prerequisites

- IntelliJ
- Docker Desktop
- Git
- GitHub account
- GitHub Copilot plugin
- Optional: pre-commit
- `sqlcmd`

## SQL Server settings

This demo uses:

- `ACCEPT_EULA=Y`
- `MSSQL_SA_PASSWORD=REMOVED-PASSWORD`
- SQL Server 2022 Docker image
- `GitDemoDb`

## Step 1. Start SQL Server

From the repo root:

```bash
docker rm -f pass2026-sql >/dev/null 2>&1 || true
docker run -d \
  --name pass2026-sql \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=REMOVED-PASSWORD \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest
```

## Step 2. Run the lab

Make scripts executable once:

```bash
chmod +x scripts/wait-for-sqlserver.sh scripts/run-tests.sh
```

Run the default flow:

```bash
./scripts/run-tests.sh
```

This:

1. Waits for SQL Server
2. Recreates `GitDemoDb`
3. Applies schema
4. Applies seed data
5. Creates `dbo.usp_GetCustomerOrders`
6. Runs `tests/before.sql`
7. Applies the selected change
8. Runs `tests/after.sql`
9. Runs `tests/validate.sql`

## Step 3. Run the good change

The good change is the default:

```bash
./scripts/run-tests.sh
```

It uses:

`database/changes/004_ai_generated_good_change.sql`

Expected result: the run succeeds and logs are written to `test-results/`.

## Step 4. Run the bad change

```bash
CHANGE_SCRIPT=database/changes/004_ai_generated_bad_change.sql ./scripts/run-tests.sh
```

Expected result: the script fails because the procedure references a column that does not exist.

## Step 5. Run pre-commit hooks

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

## Step 6. Push to GitHub

```bash
git add .
git commit -m "Add PASS webinar SQL validation demo"
git push origin <your-branch>
```

## Step 7. Open a pull request

1. Open a PR to `main`.
2. Watch **Database Pull Request Tests** start.
3. Review the uploaded `database-test-results` artifact.
4. Compare `before-results.txt`, `after-results.txt`, and `validation-results.txt`.

## How to explain the demo

- AI writes the first draft.
- Tests prove whether the draft is safe.
- Good SQL passes.
- Bad SQL fails before merge.
- Artifacts keep the proof.

## Windows notes

- Use **Git Bash** or **WSL**.
- Keep `.sh` files with LF line endings.
- Make sure Docker Desktop is running.

## Troubleshooting

See `TROUBLESHOOTING.md`.
