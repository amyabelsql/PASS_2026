# Deployment Approvals

## Overview

An environment is a named target such as production. When a workflow job uses an environment that has required reviewers, the job stops and waits. GitHub notifies the reviewers, and the job only runs after one of them approves it. This is the closest match to a DBA signing off on a change request right before it runs.

## Value for DBAs

- The DBA approves the actual deployment, not just the code
- Production secrets are only released to the job after the approval
- Every approval and rejection is kept in the workflow run with the name, time, and comment

## What it does and does not do

| Does | Does not |
| --- | --- |
| Pauses the job until one required reviewer approves | Work in private repos unless you are on GitHub Enterprise Cloud |
| Allows up to six people or teams as reviewers | Require more than one approval, the first approval wins |
| Fails the workflow if a reviewer rejects it | Wait forever, a run is cancelled after 35 days including the wait |
| Can stop people from approving a run they started | Check the SQL itself, that is what the pull request review is for |

## What you need

| Repo | GitHub plan |
| --- | --- |
| Public | Any plan, including Free |
| Private | Enterprise Cloud |

[GitHub pricing](https://github.com/pricing)

## How to create it

1. In the repo, click Settings, then Environments, then New environment.
2. Name it `production` and click Configure environment.
3. Check Required reviewers and add the DBAs or the DBA team.
4. Check Prevent self-review if the person who starts a deployment should not approve it.
5. Under Deployment branches and tags, choose Protected branches only so only main can deploy.
6. Add the production connection details as environment secrets and click Save protection rules.
7. Add the workflow [dba-deploy-approval.yml](../.github/workflows/dba-deploy-approval.yml) to `.github/workflows/`. The line `environment: production` is what makes the job wait.

## How to use it

1. Merge a pull request that adds a file to `02_Database/changes/`. To test without a pull request, open Actions, click Deploy database change, and click Run workflow.
2. Open Actions and click the Deploy database change run. It shows Waiting for review.
3. The reviewer clicks Review deployments, checks production, adds a comment, and clicks Approve and deploy.
4. The deploy job runs. The reviewer's name and comment are saved on the run summary as the record of the approval.
