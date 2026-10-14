# Presenter Commands

## Overview

These commands build the approvals demo before the session and remove it afterwards. Run them from the repo root. The demo repo is public because deployment approvals in a private repo need GitHub Enterprise Cloud.

## Before the first run

```bash
gh auth login
gh auth refresh -s workflow,delete_repo
```

Install the GitHub mobile app on your phone and turn on push notifications for deployment reviews. If you want to show Slack or Teams, install the GitHub app there and use the subscribe commands that `make approvals-demo` prints.

## Commands

| Command | What it does |
| --- | --- |
| `make approvals-demo` | Creates `pass-dba-approvals` with a protected main branch, a production environment that needs your approval, an index change issue, and a pull request |
| `make approvals-reset` | Deletes `pass-dba-approvals` |

## Run the demo

1. Open the pull request. The merge box says a code owner review is required.
2. Show Files changed so the audience sees the index SQL and the linked issue.
3. Merge it with the bypass checkbox. As the only person in the repo you cannot approve your own pull request, so explain that a second DBA would approve here.
4. Open Actions. Deploy database change is waiting for review.
5. Approve it from the push notification on your phone, or from the Slack or Teams message.
6. Show the deploy job finishing and the approval on the run summary.
7. Open the issue to show it closed itself when the pull request merged.

Run `make approvals-reset` and then `make approvals-demo` to run it again.
