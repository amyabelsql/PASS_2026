# Repo Template

## Overview

A repo template is a normal repo with one setting turned on. Every new repo created from it starts with a copy of its files, so each database repo begins with the same issue forms, pull request template, CODEOWNERS, and SQL check workflows.

## Value for DBAs

- Every database repo starts with the same checks and reviewers
- Fix a control once in the template instead of in every repo
- New repos are ready in seconds instead of set up by hand

## What it does and does not do

| Copied to the new repo | Not copied, set up separately |
| --- | --- |
| All files and folders on the default branch | Labels |
| GitHub Actions workflows | Branch protection and rulesets |
| Issue forms and the pull request template | Secrets and variables |
| CODEOWNERS | Collaborators and team access |
| README and docs | Project boards |
| Issue chooser settings in `config.yml` | Webhooks and deploy keys |
| `.gitignore` and `.pre-commit-config.yaml` | Environments |
| `.env.example`, never real secrets | GitHub App access |
| Makefile and scripts | Git history, tags, and releases |
| LICENSE | Git LFS files |
| Other branches, only if Include all branches is checked | Repo settings such as merge options |

> [!IMPORTANT]
> *CODEOWNERS is copied but does not require reviews on its own. Add a branch protection rule or ruleset that requires code owner review in each new repo.*

Repos created from the template do not pick up later changes to it. Update existing repos with a pull request.

## How to create it

1. Open the repo you want to use as the template.
2. Click Settings.
3. On the General page, check Template repository.

A Use this template button now appears on the repo's Code tab.

## How to use it

1. On the Code tab, click Use this template, then Create a new repository.
2. Name the repo, choose Private, and click Create repository.
3. In the new repo, open Actions, choose Set up DBA labels, and click Run workflow.
4. In `.github/CODEOWNERS`, replace `@amyabelsql` with your own user or team.
