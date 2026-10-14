# Mobile App and Email

## Overview

The GitHub mobile app for iPhone and Android sends a push notification when someone requests your review or when a deployment is waiting on your approval. You can approve the pull request or the deployment from the app. Email still works for anyone who wants it, and GitHub can send work email to a different address than personal email.

## Value for DBAs

- Approve a change from a phone without opening a laptop or VPN
- Pending deployments show up in the app inbox, not buried in email
- Email can be routed by organization so work requests go to a work address

## What it does and does not do

| Does | Does not |
| --- | --- |
| Pushes review requests and deployment approvals to your phone | Change who is allowed to approve, that comes from the ruleset and environment |
| Lets you approve or reject a deployment from the notification | Send push notifications unless you turn them on in the app |
| Lets you approve, comment on, or request changes to a pull request | Replace email, both can be on at the same time |

## What you need

The GitHub mobile app and email notifications are free on every GitHub plan. You can only approve a deployment from the app if the repo meets the plan rules in [02_Deployment_Approvals.md](02_Deployment_Approvals.md).

## How to create it

1. Install GitHub from the App Store or Google Play and sign in.
2. In the app, open Settings, then Notifications, and allow push notifications when your phone asks.
3. Turn on the push notification types for review requests and deployment reviews.
4. For email, go to github.com, click your profile picture, then Settings, then Notifications.
5. Under Default notifications email, pick the address to use.
6. Under Custom routing, add your work organization and pick your work email.

## How to use it

1. When a deployment is waiting, a push notification arrives.
2. Tap it to open the waiting run, pick production, and approve it.
3. For a pull request, tap the notification, read the SQL in the changed files, then submit an approving review.
