# Copilot on GitHub

## Overview

On GitHub, Copilot can do the work behind an issue. You assign the issue to Copilot, it works in its own cloud environment, and it opens a pull request for you to review. This is called the Copilot cloud agent. You can also start it from a failed Actions run with Fix with Copilot, from the GitHub mobile app, or from Slack and Teams. Pull request [#1](https://github.com/amyabelsql/PASS_2026/pull/1) in this repo is a real example, where Copilot fixed the failing Gitleaks workflow and opened the pull request on its own.

## Value for DBAs

- Small requests such as a validation query or a missing rollback script get done without a DBA writing them
- Failing workflows can be investigated and fixed with one click
- The work arrives as a normal pull request, so the approvals from [02_Approval_Process](../02_Approval_Process/00_Overview.md) still apply

## What it does and does not do

| Does | Does not |
| --- | --- |
| Reads the issue, plans the change, edits files, and opens a pull request | Merge its own pull request |
| Works on its own `copilot/` branch | Push to main or skip your rulesets |
| Follows the instructions files in `.github/instructions/` | Connect to your SQL Servers, it only sees the repo |
| Changes its work when you mention `@copilot` in a pull request comment | Read comments added to the issue after it starts |
| Waits for you to click Approve and run workflows before Actions run on its pull request | Work longer than 59 minutes on one task |
| Starts from an issue, a failed run, the mobile app, Slack, or Teams | Change more than one repo or open more than one pull request per task |

## What you need

| Item | What to know |
| --- | --- |
| Copilot plan | Pro, Pro+, Max, Business, or Enterprise. Copilot Free does not include the cloud agent. |
| Cost | Each task uses AI credits from your plan and GitHub Actions minutes |
| Organization repos | The org owner must allow the cloud agent |

## How to create it

1. Write a clear issue. Say which file to change, what done looks like, and what not to touch.
2. Make sure `.github/instructions/sql-review.instructions.md` is in the repo so Copilot follows the same SQL rules as the reviewers.
3. Nothing else is needed for a personal repo with a Copilot Pro plan.

## How to use it

From an issue

1. Open the issue and click Assignees in the right sidebar.
2. Pick Copilot. Add extra instructions in the prompt box if you want, then confirm.
3. Copilot opens a pull request and requests your review when it finishes.
4. Read the changes, then click Approve and run workflows so the SQL checks run.
5. To ask for changes, comment on the pull request and start the comment with `@copilot`.
6. Approve and merge the pull request like any other change.

From a failed workflow

1. Open the failed run in Actions and click the failed job.
2. Click Fix with Copilot.
3. Review the pull request it opens.

## If it does not work

| What you see | What to do |
| --- | --- |
| Copilot is not in the Assignees list | Your plan does not include the cloud agent, or it is turned off for the repo or org |
| Checks never run on Copilot's pull request | Click Approve and run workflows in the merge box |
| Copilot ignores a comment | Start the comment with `@copilot` and post it on the pull request, not the issue |
| Copilot changed the wrong thing | Close the pull request and rewrite the issue with the exact file and expected result |
