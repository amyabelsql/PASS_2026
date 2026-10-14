# Presenter Commands

## Overview

These commands set up the automation demo and run it. Run them from the repo root.

## Before the first run

```bash
gh auth login
brew install pre-commit
make automation
```

## Commands

| Command | What it does |
| --- | --- |
| `make automation` | Adds a random SQL_SA_PASSWORD secret to the repo if it is missing and installs the pre-commit hooks |
| `make automation-demo` | Runs the guardrails on the risky script and the good change, then starts the database tests on GitHub for both AI changes |
| `make automation-teardown` | Removes the pre-commit hooks and the SQL_SA_PASSWORD secret |

## Run the demo

1. Run `make automation-demo`. Show the three BLOCKED statements and point out that the tagged TRUNCATE was allowed.
2. Show the hook stopping a commit.

```bash
cp 04_Automation/Demo_Risky_Change.sql 02_Database/changes/006_risky.sql
git add 02_Database/changes/006_risky.sql
git commit -m "Clean up orders"
```

3. Clean up after the hook blocks it.

```bash
git restore --staged 02_Database/changes/006_risky.sql
rm 02_Database/changes/006_risky.sql
```

4. Open the two Database Pull Request Tests runs that `make automation-demo` printed. They take about two minutes, so start them before you talk about the hook.
5. Show the good run passing and the bad run failing on the made up column.
6. Download database-test-results from the good run to show the saved output.
