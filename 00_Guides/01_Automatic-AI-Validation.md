# 1. Automatically Testing AI-Generated Database Changes

This walkthrough shows how to **treat AI output like any other pull request change**: run it, compare behavior, and fail the build when it breaks expectations.

## Goal

Show that AI-generated SQL should be validated with repeatable tests before merge.

## What this part demonstrates

1. A known-good change can pass the same checks every time.
2. A bad AI-generated change can be caught before merge.
3. The same validation runs locally and in GitHub Actions.

## Files involved

- `02_Database/changes/004_ai_generated_good_change.sql`
- `02_Database/changes/004_ai_generated_bad_change.sql`
- `03_Tests/before.sql`
- `03_Tests/after.sql`
- `03_Tests/validate.sql`
- `04_Run/run-tests.sh`
- `.github/workflows/database-pr-tests.yml`

## Local demo flow

1. Start SQL Server.
   - macOS: `bash 01_Docker/Mac/03-Start-SQL-Server.sh`
   - Windows: `pwsh -File 01_Docker/Windows/02-Start-Docker.ps1`
2. Wait for the instance: `bash 01_Docker/01_wait-for-sqlserver.sh`
3. Run the default good change: `./04_Run/run-tests.sh`
4. Re-run with the bad change:

```bash
CHANGE_SCRIPT=02_Database/changes/004_ai_generated_bad_change.sql ./04_Run/run-tests.sh
```

## What to point out while presenting

1. `00_before.sql` captures the baseline.
2. The selected AI change is applied in an isolated database.
3. `01_after.sql` captures the post-change behavior.
4. `02_validate.sql` decides pass or fail.
5. CI repeats the exact same logic on pull requests.

## The message for the audience

AI can help write code faster, but it does **not** remove the need for regression checks. The safest pattern is:

1. Generate the change.
2. Run automated validation.
3. Review the results.
4. Merge only when the checks pass.
