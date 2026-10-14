# Issue Templates

## Overview

Issue templates control what people see when they click New issue. Issue forms are YAML files that show text boxes, dropdowns, and required fields. Markdown templates pre-fill the issue with text such as a checklist.

| File in `.github/ISSUE_TEMPLATE/` | Used for |
| --- | --- |
| `01_dba-change-request.yml` | Schema, procedure, data, or permission changes |
| `02_dba-incident.yml` | Production incidents |
| `03_dba-maintenance.md` | Recurring maintenance |
| `04_index-change-request.yml` | Index changes with before and after evidence |
| `config.yml` | Turns off blank issues |

## Value for DBAs

- No request arrives without a rollback plan and validation plan
- Every request uses the same format
- Labels are added automatically so requests are easy to filter

## What it does and does not do

| Does | Does not |
| --- | --- |
| Blocks submission until required fields are filled in | Check that the answers are correct |
| Adds labels to the new issue | Create the labels if they do not exist |
| Sets a default title prefix | Require fields in Markdown templates |
| Hides the blank issue option when `config.yml` says so | Apply to pull requests, which use the pull request template |

## How to create it

1. In your repo, click Add file, then Create new file.
2. Name the file `.github/ISSUE_TEMPLATE/01_dba-change-request.yml`. GitHub creates the folders as you type.
3. Paste the contents of [01_dba-change-request.yml](../.github/ISSUE_TEMPLATE/01_dba-change-request.yml) and click Commit changes.
4. Repeat for each form you want.
5. To turn off blank issues, add `.github/ISSUE_TEMPLATE/config.yml` with the line `blank_issues_enabled: false`.
6. Create the labels the forms use. In a repo made from this template, run the Set up DBA labels workflow.

## How to use it

1. Click Issues, then New issue.
2. Choose a form, fill in the fields, and click Create.
