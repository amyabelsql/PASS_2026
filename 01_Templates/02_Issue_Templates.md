# Issue Templates

## What

Issue templates/form templates standardize incoming change requests and incidents.

This repo includes:

- `.github/ISSUE_TEMPLATE/01_dba-change-request.yml`
- `.github/ISSUE_TEMPLATE/02_dba-incident.yml`
- `.github/ISSUE_TEMPLATE/03_dba-maintenance.md`
- `.github/ISSUE_TEMPLATE/config.yml`

## Why

DBA work is reliability-sensitive. If risk, rollback, and validation are not captured at intake, review quality drops and production risk rises.

## How (GitHub UI + repo files)

1. In the repository, create `.github/ISSUE_TEMPLATE/`.
2. Add one or more templates:
   - **Issue form** (`.yml`) for structured required fields
   - **Markdown template** (`.md`) for flexible tasks
3. Add `.github/ISSUE_TEMPLATE/config.yml` to control blank issues/contact links.
4. Commit changes.
5. Test in GitHub:
   - Click **New issue**
   - Confirm template chooser appears
   - Confirm required form fields block incomplete submissions

## What to capture in DBA issue forms

1. Change summary and change type
2. Risk level
3. Deployment window
4. Validation plan
5. Rollback plan
6. Copilot prompt/edits (if AI-assisted)

## Best practices for DBAs

1. Make rollback and validation fields required.
2. Keep forms short enough for fast intake, strict enough for safe delivery.
3. Separate planned changes from incidents using different templates.
4. Disable blank issues unless your team has a strong reason to allow them.
5. Review template quality quarterly as process matures.
