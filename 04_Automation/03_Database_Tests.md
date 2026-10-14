# Database Tests

## Overview

The guardrails catch risky SQL but not broken SQL. The Database Pull Request Tests workflow in [database-pr-tests.yml](../.github/workflows/database-pr-tests.yml) starts a fresh SQL Server 2022 container on GitHub, builds the sample database, applies the change, and runs the checks in [03_Tests/](../03_Tests/). If the change fails, the pull request shows a red check. The repo has a good AI change and a bad AI change that uses a column that does not exist, so you can see both results.

## Value for DBAs

- Every change is tested on a clean SQL Server, not a shared dev box
- Broken SQL from people or Copilot fails before review
- The before, after, and validation results are saved with each run

## What it does and does not do

| Does | Does not |
| --- | --- |
| Runs on every pull request that changes database or test files | Test against your production data or size |
| Builds the database from `02_Database/` every time | Keep the database after the run |
| Saves the results as a download called database-test-results | Catch slow queries, only errors and failed checks |
| Can be run by hand for the good or the bad change | Run without the SQL_SA_PASSWORD secret |

## What you need

| Item | What to know |
| --- | --- |
| GitHub Actions | Free for public repos. Private repos use the minutes included in your plan. |
| Runner | A GitHub hosted Linux runner, which service containers require |
| Secret | A repository secret named SQL_SA_PASSWORD |

## How to create it

1. In the repo, click Settings, then Secrets and variables, then Actions.
2. Click New repository secret, name it `SQL_SA_PASSWORD`, and enter a strong password with upper and lower case letters, a number, and a symbol.
3. Copy [database-pr-tests.yml](../.github/workflows/database-pr-tests.yml) into `.github/workflows/`.
4. Copy `01_Docker/01_wait-for-sqlserver.sh`, `04_Run/run-tests.sh`, `02_Database/`, and `03_Tests/` into the same places in your repo.

Or run `make automation`, which adds the secret with a random password.

## How to use it

1. Open a pull request that changes a file in `02_Database/`. The workflow starts on its own.
2. To try it by hand, open Actions, click Database Pull Request Tests, click Run workflow, pick good or bad, and click Run workflow.
3. Open the run. The good change passes. The bad change fails at Run database tests with an invalid column name error.
4. Scroll to Artifacts at the bottom of the run summary and download database-test-results to see the before, after, and validation output.

To run the same tests on your laptop, start SQL Server with `make setup` and run `./04_Run/run-tests.sh`.

## If it does not work

| What you see | What to do |
| --- | --- |
| Add a SQL_SA_PASSWORD repository secret | Add the secret, or run `make automation` |
| Wait for SQL Server times out | The password is too simple for SQL Server. Use upper and lower case, a number, and a symbol. |
| Run workflow is not shown | The workflow file has to be on the main branch first |
