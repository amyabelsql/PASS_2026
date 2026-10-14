# Approvals Overview

DBAs care most about approving schema and index changes before they reach production. Most teams handle this with email today. GitHub can hold the approval in the pull request and in the deployment itself, and it can send the request to the GitHub mobile app, Slack, or Teams so a DBA can approve it from a phone. Each topic lists the GitHub, Slack, or Teams plan it needs.

| File | Topic |
| --- | --- |
| [01_Pull_Request_Approvals.md](01_Pull_Request_Approvals.md) | Require a DBA to approve the pull request before it merges |
| [02_Deployment_Approvals.md](02_Deployment_Approvals.md) | Pause the deployment until a DBA approves it |
| [03_Mobile_and_Email.md](03_Mobile_and_Email.md) | Approve from the GitHub mobile app and tune email |
| [04_Slack_and_Teams.md](04_Slack_and_Teams.md) | Send approval requests to Slack or Teams |
| [05_Change_Records.md](05_Change_Records.md) | Keep change records in GitHub, ServiceNow, or Jira |
| [06_Presenter_Commands.md](06_Presenter_Commands.md) | Build and remove the demo with `approvals.sh` |

The demo uses the index change in [Demo_Index_Change.sql](Demo_Index_Change.sql) and the deploy workflow in [dba-deploy-approval.yml](../.github/workflows/dba-deploy-approval.yml).
