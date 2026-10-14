# Presenter Commands

## Overview

This demo hands a real DBA task to Copilot. An issue asks for a validation script for the new index, Copilot is assigned, and it opens a pull request with the script. Run it from the repo root after `make approvals-demo`, because it uses the same `pass-dba-approvals` repo.

## Before the first run

```bash
gh auth login
make approvals-demo
```

You need Copilot Pro or higher. Copilot Free does not include the cloud agent.

## Commands

| Command | What it does |
| --- | --- |
| `make ai-demo` | Opens the validation query issue in `pass-dba-approvals` and assigns it to Copilot |
| `make approvals-reset` | Deletes `pass-dba-approvals`, including the issue and Copilot's pull request |

## Timing

In testing, Copilot opened a draft pull request about 15 seconds after it was assigned and finished in about 2 and a half minutes. Run `make ai-demo` about 10 minutes before the session so a finished pull request is ready, then run it again live so the audience sees it start.

## Run the demo

1. Open the issue and show that Copilot is listed under Assignees.
2. Open Pull requests and show the draft pull request Copilot opened on its own `copilot/` branch.
3. Click into the pull request and show the session log, where Copilot explains what it is doing.
4. Switch to the finished pull request from before the session.
5. Show Files changed. The script checks the index with the system catalog views, uses schema names, and avoids SELECT *, because the issue asked for that. A clear issue gets a better result.
6. Point out that the pull request is still a draft. Copilot does not merge its own work. Click Ready for review, and the protected main branch still needs a person to approve it.
