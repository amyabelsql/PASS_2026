# Pull Request Approvals

## Overview

A ruleset on the main branch blocks merging until someone approves the pull request. When CODEOWNERS lists a DBA or a DBA team for the database folders, that approval has to come from them. The DBA Approval Guardrails workflow in this repo adds a second check that looks for the `dba-approved` label, a linked issue, and index evidence.

## Value for DBAs

- No schema or index change reaches main without a DBA approval
- The approval, comments, and the exact SQL that was approved stay in the pull request
- Reviews can be done from the GitHub website or the mobile app

## What it does and does not do

| Does | Does not |
| --- | --- |
| Blocks the merge until the required approvals are in | Deploy anything, see [02_Deployment_Approvals.md](02_Deployment_Approvals.md) |
| Requires a code owner to approve changes to the files they own | Let the author approve their own pull request |
| Throws away old approvals when new commits are pushed, if you turn it on | Apply to private repos on GitHub Free |

## What you need

| Repo | GitHub plan |
| --- | --- |
| Public | Any plan, including Free |
| Private | Pro, Team, or Enterprise Cloud |

[GitHub pricing](https://github.com/pricing)

## How to create it

1. In `.github/CODEOWNERS`, add a line such as `02_Database/ @your-org/dba-team` and commit it. A team must have write access to the repo or GitHub ignores the line.
2. In the repo, click Settings, then Rules, then Rulesets.
3. Click New ruleset, then New branch ruleset.
4. Name it Protect main and set Enforcement status to Active.
5. Under Target branches, click Add target, then Include default branch.
6. Check Require a pull request before merging.
7. Set Required approvals to 1 and check Require review from Code Owners.
8. Check Dismiss stale pull request approvals when new commits are pushed.
9. Click Create.

## How to use it

1. Open a pull request that changes a file in `02_Database/changes/`.
2. GitHub requests a review from the code owner and the merge box shows that a review is required.
3. The DBA opens the pull request, clicks Files changed, then Review changes, picks Approve, and clicks Submit review.
4. The merge button turns green.
