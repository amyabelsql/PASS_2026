# Change Records

## Overview

A change record answers who asked for the change, who approved it, what ran, and when. GitHub can be the change record on its own, or it can wait on a change request in ServiceNow or Jira Service Management before it deploys.

| Option | Where the record lives |
| --- | --- |
| GitHub only | The issue, the pull request, and the deploy run |
| ServiceNow | A change request in ServiceNow that GitHub waits on |
| Jira Service Management | A change request in Jira that GitHub waits on |

## Value for DBAs

- One link shows the request, the review, the approval, and the deploy log
- Teams that already run a CAB can keep it, and GitHub waits for the CAB approval
- Auditors get a history that nobody can edit after the fact

## What it does and does not do

| Does | Does not |
| --- | --- |
| Links the issue to the pull request with `Closes #123` and closes it on merge | Create a ServiceNow or Jira ticket without their app installed |
| Shows every deployment and who approved it under Environments | Work with ServiceNow or Jira in a private repo unless you are on GitHub Enterprise Cloud |
| Lets ServiceNow or Jira approve or reject the deployment | Replace your CAB process, it connects to it |

## What you need

| Option | What you need |
| --- | --- |
| GitHub only | Any GitHub plan |
| ServiceNow | ServiceNow ITSM and DevOps Change Velocity, plus a public repo or GitHub Enterprise Cloud |
| Jira Service Management | Jira Service Management Premium or Enterprise, plus a public repo or GitHub Enterprise Cloud |

## How to create it

GitHub only

1. Use the index change form in [04_index-change-request.yml](../.github/ISSUE_TEMPLATE/04_index-change-request.yml) for the request.
2. Put `Closes #` and the issue number in the pull request so the two are linked.
3. Add the issue to the DBA Change Control board from [01_Templates](../01_Templates/03_Project_Board.md).
4. Set up the production environment from [02_Deployment_Approvals.md](02_Deployment_Approvals.md) so each deploy is recorded with its approver.

ServiceNow or Jira

1. Install the GitHub app from ServiceNow or Atlassian on your GitHub organization.
2. In the repo, click Settings, then Environments, then production.
3. Under Deployment protection rules, check the ServiceNow or Jira rule and click Save protection rules.
4. Finish the setup on their side with [ServiceNow DevOps for GitHub](https://www.servicenow.com/docs/) or [Jira deployment gating with GitHub](https://support.atlassian.com/jira-service-management-cloud/docs/use-deployment-gating-with-github/).

## How to use it

1. Open the issue to see the request, the linked pull request, and the approvals.
2. In the repo, click Deployments on the right side of the Code tab to see each production deploy, when it ran, and the run that did it.
3. With ServiceNow or Jira, the deploy job shows Waiting until the change request is approved there.
