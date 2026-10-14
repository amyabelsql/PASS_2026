# Copilot Reviews

## Overview

GitHub Copilot can review a pull request the moment it is opened. It posts an overview comment that summarizes what changed, leaves comments on the lines it has concerns about, and says whether it thinks the pull request is ready to approve. You tell it what a DBA cares about with an instructions file in the repo, such as [sql-review.instructions.md](../.github/instructions/sql-review.instructions.md). For low risk requests, Copilot can also approve the pull request itself, but only for the file paths you allow.

## Value for DBAs

- Every database pull request gets a plain summary before a DBA opens it
- Common problems such as missing rollbacks, SELECT *, or NOLOCK are flagged automatically
- Low risk changes such as docs or tests can be approved without waiting on a DBA
- DBAs spend their review time on the high risk changes

## What it does and does not do

| Does | Does not |
| --- | --- |
| Summarizes the changes in an overview comment | Run the SQL or check it against a real database, it only reads the change |
| Comments on lines that break the rules in your instructions file | Catch everything, a clean review is not proof the change is safe |
| Reviews every pull request automatically when a ruleset turns it on | Count as a code owner, GitHub's docs do not say it does, so keep a human code owner on database folders |
| Approves pull requests when approvals are turned on and every changed file matches your allowed paths | Approve deployments, environment reviewers must be people or teams |
| Drops its approval when new commits are pushed, the same as a person | Count its "ready to approve" note as an approval, only a real approving review counts |
| Reviews SQL, YAML, scripts, and docs | Review dependency files, log files, or SVG files |

## What you need

| Item | What to know |
| --- | --- |
| Copilot plan | Copilot Pro, Pro+, Max, Business, or Enterprise. Copilot Free does not include code review. |
| Cost | Each review uses AI credits from your plan. Bigger pull requests cost more. |
| Copilot approvals | Public preview, so it can change. In an organization, the org owner and enterprise owner must allow it before the repo setting works. |
| Repo | Works in public and private repos |

[Copilot plans](https://github.com/features/copilot/plans)

## How to create it

Instructions file

1. In the repo, click Add file, then Create new file.
2. Name it `.github/instructions/sql-review.instructions.md`.
3. Paste the contents of [sql-review.instructions.md](../.github/instructions/sql-review.instructions.md). The `applyTo` line at the top limits it to SQL files under `02_Database/`.
4. Click Commit changes.

Automatic reviews

1. In the repo, click Settings, then Rules, then Rulesets.
2. Open the Protect main ruleset from [01_Pull_Request_Approvals.md](01_Pull_Request_Approvals.md), or click New ruleset, then New branch ruleset.
3. Under Target branches, make sure the default branch is included.
4. Check Automatically request Copilot code review.
5. Check Review new pushes so Copilot reviews again after every change.
6. Click Save changes.

Approvals for low risk requests

1. In the repo, click Settings, then Copilot, then Code review.
2. Turn on Allow Copilot to approve pull requests.
3. Turn on Allow Copilot approvals to count toward merge requirements.
4. Under File paths, add one pattern per line for the files Copilot may approve, such as `**/*.md` and `03_Tests/**`. Copilot's approval only counts when every changed file matches a pattern.
5. Do not add `02_Database/**`. Schema and index changes should always get a DBA approval.

Summary on demand

1. Open a pull request and click into an empty description box.
2. Click the Copilot icon in the box's toolbar and choose Summary.
3. Read it, fix anything that is wrong, and click Update comment.

## How to use it

1. Open a pull request. Copilot shows up under Reviewers and posts its review within a few minutes.
2. Read the overview comment at the top of the review for the summary and the ready to approve note. Copilot usually leaves line comments only for the most serious problems and mentions smaller ones such as NOLOCK in the summary, so read the whole summary.
3. Fix or reply to each line comment, then resolve it.
4. For a docs or test change that matches the allowed paths, Copilot's approval unlocks the merge button.
5. For a database change, a DBA still reviews and approves it, starting from Copilot's summary.
6. To review again after a push without the ruleset, click the gear next to Reviewers and pick Copilot.

## If it does not work

| What you see | What to do |
| --- | --- |
| Copilot is not in the Reviewers list | Your account does not have a Copilot plan that includes code review |
| Copilot ignores your SQL rules | Check that the file name ends in `.instructions.md` and the `applyTo` pattern matches the changed files |
| Copilot approved but the merge is still blocked | Turn on the second toggle, check that every changed file matches a file path pattern, and check for a code owner requirement |
| The approval disappeared | A new commit was pushed. Request a new review from Copilot. |
| No Copilot settings under the repo Settings | In an organization, the org or enterprise owner has not allowed Copilot code review or approvals |
