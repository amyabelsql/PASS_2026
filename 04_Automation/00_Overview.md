# Automation Overview

Automation checks every database change the same way, whether a person or Copilot wrote it. The same guardrail script runs in three places, so a risky statement is caught on your laptop first, then again on the pull request. The database tests then run the change against a real SQL Server to catch SQL that is not risky but simply broken.

| File | What it checks | When it runs |
| --- | --- | --- |
| [01_SQL_Guardrails.md](01_SQL_Guardrails.md) | DELETE or UPDATE with no WHERE, TRUNCATE TABLE, and DROP TABLE | On demand, on commit, and on every pull request |
| [02_Pre_Commit_Hooks.md](02_Pre_Commit_Hooks.md) | Guardrails, secrets, private keys, YAML, and large files | Every `git commit` on your laptop |
| [03_Database_Tests.md](03_Database_Tests.md) | The change actually runs and the procedure still works | Every pull request that changes database files |
| [04_Presenter_Commands.md](04_Presenter_Commands.md) | Build and run the demo with `automation.sh` | Before and during the session |

The demo uses [Demo_Risky_Change.sql](Demo_Risky_Change.sql) for the guardrails and the two AI changes in [02_Database/changes/](../02_Database/changes/) for the database tests.
