# Slack and Teams

## Overview

GitHub has a free app for Slack and a free app for Microsoft Teams. You subscribe a channel to a repo, and the channel gets a message for new pull requests, review requests, and deployments that are waiting. When a deployment is waiting on you, the thread under the message has a button so you can approve it from the chat.

## Value for DBAs

- Change requests land in the DBA channel the team already watches
- A label filter keeps the channel to index and schema changes only
- Deployments can be approved from the chat on a laptop or phone

## What it does and does not do

| Does | Does not |
| --- | --- |
| Posts pull requests, issues, reviews, and workflow runs to a channel | Post workflow runs until you subscribe to `workflows`, it is off by default |
| Lets a required reviewer approve a waiting deployment from the message thread | Let anyone approve who is not a required reviewer on the environment |
| Filters pull requests, issues, and reviews by one label per repo | Filter workflow runs by label |
| Links each person's chat account to their GitHub account | Work in a Teams or Slack tenant where the admin blocks third party apps |

## What you need

The GitHub app is free in both Slack and Teams. The repo still has to meet the plan rules in [02_Deployment_Approvals.md](02_Deployment_Approvals.md) for the Approve button to show up.

| Slack | What to know |
| --- | --- |
| Free plan | Limited to 10 apps, so the GitHub app may push you over |
| Pro and above | No app limit |
| Admin approval | A workspace admin may need to approve the app |

| Teams | What to know |
| --- | --- |
| Account | Use a work or school account. GitHub's docs do not cover the free personal version of Teams. |
| Admin approval | A Teams admin must allow third party apps in the Teams admin center |
| Developer preview | GitHub's docs currently list Microsoft Public Developer Preview as a requirement, so test it in your tenant before you rely on it |

[Slack pricing](https://slack.com/pricing) and [Teams pricing](https://www.microsoft.com/microsoft-teams/compare-microsoft-teams-business-options)

## How to create it

Slack

1. Go to [github.com/integrations/slack](https://github.com/integrations/slack) and click Add to Slack. Pick your workspace and click Allow. A Slack workspace admin may need to approve the app.
2. Create a channel for approvals, such as `dba-approvals`, and leave it public. The steps below do not work in a direct message or in the GitHub app's own chat.
3. In that channel, type `/invite @github`.
4. Type `/github signin` and finish connecting your GitHub account. Slack only shows the Approve button to people it can match to a required reviewer.
5. Type `/github subscribe OWNER/REPO`, replacing OWNER/REPO with your repo. If Slack replies with a link to install or configure the GitHub app, open it, give the app access to the repo, and run the command again.
6. Type `/github subscribe OWNER/REPO reviews workflows:{event:"push","workflow_dispatch"}`. Put each event in its own quotes. One set of quotes around both events matches nothing.
7. The first time you subscribe to workflows, GitHub asks you to give the Slack app access to Actions. If you missed the prompt, go to [github.com/settings/installations](https://github.com/settings/installations), click Configure next to Slack, and accept the permissions request.
8. Type `/github subscribe list features`. The repo should be listed with `workflows`. If it says no repos are subscribed, go back to step 5.
9. To limit pull request and issue messages to index changes, type `/github subscribe OWNER/REPO +label:"index-change"`. Workflow runs are not filtered by label.

Teams

1. In Teams, click Apps, search for GitHub, and click Add. A Teams admin may need to allow it in the Teams admin center under Teams apps, then Manage apps.
2. Add the app to a channel, not a chat, then type `@GitHub` and follow the prompts to connect your GitHub account.
3. Type `@GitHub subscribe OWNER/REPO`. If Teams replies with a link to install or configure the GitHub app, open it, give the app access to the repo, and run the command again.
4. Type `@GitHub subscribe OWNER/REPO reviews workflows:{event:"push","workflow_dispatch"}` and accept the Actions permissions request if GitHub asks.
5. Type `@GitHub subscribe list features` to check that the repo is listed with `workflows`.
6. To limit pull request and issue messages to index changes, type `@GitHub subscribe OWNER/REPO +label:"index-change"`.

## How to use it

1. Merge a database pull request, or start the deploy workflow from Actions with Run workflow.
2. The channel gets a message for the Deploy database change run. Only runs that start after you subscribe are posted.
3. Open the thread under that message. The approval request is posted there as a reply.
4. A required reviewer clicks Approve in the thread. The deploy job starts and the thread gets an update when the run finishes.

## If it does not work

| What you see | What to do |
| --- | --- |
| `/invite @github` says you cannot perform this action | You are in a direct message or the GitHub app chat. Create a channel and run it there. |
| No Integrations tab when you click the channel name | Same cause, you are in a direct message and not a channel |
| `/github subscribe list features` says no repos are subscribed | Run `/github subscribe OWNER/REPO` in that channel and follow the link it replies with |
| The channel is subscribed but no run messages show up | Accept the Actions permissions request under [github.com/settings/installations](https://github.com/settings/installations) and start a new run |
| Messages show up but there is no Approve button | Open the thread under the message, run `/github signin`, and check that you are a required reviewer on the environment |
| Nothing works and the commands get no reply | A workspace admin is blocking the app. Ask them to approve GitHub for Slack. |
