# Presenter Commands

## Overview

These commands build the approvals demo before the session and remove it afterwards. Run them from the repo root. The demo repo is public because deployment approvals in a private repo need GitHub Enterprise Cloud.

## Before the first run

```bash
gh auth login
gh auth refresh -s workflow,delete_repo
```

Install the GitHub mobile app on your phone and turn on push notifications for deployment reviews.

## Slack or Teams before every session

`make approvals-demo` creates a brand new repo each time, so the chat subscription has to be set up again after every build.

1. Run `make approvals-demo`.
2. Go to [github.com/settings/installations](https://github.com/settings/installations), click Configure next to Slack or Teams, and make sure `pass-dba-approvals` has access. If the app is set to only selected repositories, add it.
3. In your approvals channel, run the subscribe command that `make approvals-demo` printed.
4. Run `/github subscribe list features` and check that `pass-dba-approvals` is listed with `workflows`.
5. Start a test run from Actions with Run workflow and approve it from the thread so you know it works before you go on stage.

Follow [04_Slack_and_Teams.md](04_Slack_and_Teams.md) for the first time setup and the table of fixes.

## Commands

| Command | What it does |
| --- | --- |
| `make approvals-demo` | Creates `pass-dba-approvals` with a protected main branch, a production environment that needs your approval, an index change issue, and a pull request |
| `make approvals-reset` | Deletes `pass-dba-approvals` |

## Run the demo

1. Open the pull request. The merge box says a code owner review is required.
2. Show Files changed so the audience sees the index SQL and the linked issue.
3. If you have Copilot, click the gear next to Reviewers and pick Copilot. Show the overview comment with the summary and the rollback check from the SQL review rules. Request it a few minutes before the session so the review is already there.
4. Merge it with the bypass checkbox. As the only person in the repo you cannot approve your own pull request, so explain that a second DBA would approve here.
5. Open Actions. Deploy database change is waiting for review.
6. Approve it from the push notification on your phone, or from the thread under the Slack or Teams message.
7. Show the deploy job finishing and the approval on the run summary.
8. Open the issue to show it closed itself when the pull request merged.

Run `make approvals-reset` and then `make approvals-demo` to run it again.
