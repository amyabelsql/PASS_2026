# Slack and Teams

## Overview

GitHub has a free app for Slack and a free app for Microsoft Teams. You subscribe a channel to a repo, and the channel gets a message for new pull requests, review requests, and deployments that are waiting. When a deployment is waiting on you, the message has a button so you can approve it from the chat.

## Value for DBAs

- Change requests land in the DBA channel the team already watches
- A label filter keeps the channel to index and schema changes only
- Deployments can be approved from the chat on a laptop or phone

## What it does and does not do

| Does | Does not |
| --- | --- |
| Posts pull requests, issues, reviews, and workflow runs to a channel | Post workflow runs until you subscribe to `workflows`, it is off by default |
| Lets a required reviewer approve a waiting deployment from the message | Let anyone approve who is not a required reviewer on the environment |
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

1. Go to [github.com/integrations/slack](https://github.com/integrations/slack) and click Add to Slack. A Slack workspace admin may need to approve the app.
2. In your DBA channel, type `/invite @github`.
3. Type `/github signin` and connect your GitHub account.
4. Type `/github subscribe OWNER/REPO reviews`, replacing OWNER/REPO with your repo.
5. Type `/github subscribe OWNER/REPO workflows:{name:"Deploy database change" event:"push" branch:"main"}`. The first time, GitHub asks you to give the app access to Actions.
6. To limit the channel to index changes, type `/github subscribe OWNER/REPO +label:"index-change"`.

Teams

1. In Teams, click Apps, search for GitHub, and click Add. A Teams admin may need to allow it in the Teams admin center under Teams apps, then Manage apps.
2. Add the app to your DBA channel, then type `@GitHub` and follow the prompts to connect your GitHub account.
3. Type `@GitHub subscribe OWNER/REPO reviews`.
4. Type `@GitHub subscribe OWNER/REPO workflows:{name:"Deploy database change" event:"push" branch:"main"}`.
5. To limit the channel to index changes, type `@GitHub subscribe OWNER/REPO +label:"index-change"`.

## How to use it

1. Merge a database pull request.
2. The channel gets a message that Deploy database change is waiting for approval.
3. A required reviewer clicks Approve in the message. The deploy job starts and the message updates.
4. Type `/github subscribe list features` in Slack or `@GitHub subscribe list features` in Teams to see what the channel is subscribed to.
