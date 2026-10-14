# Example: Approval Checks (What to show in GitHub)

## Failing scenario to demo

Show a PR that has:

- SQL change in `02_Database/changes/`
- missing `dba-approved` label
- no linked issue in PR body

Expected result:

- `DBA Approval Guardrails` workflow fails with explicit messages.

## Passing scenario to demo

Show a PR that has:

- linked issue (`Closes #...`)
- `dba-approved` label
- `index-change` label when index SQL is present
- non-author approval

Expected result:

- `DBA Approval Guardrails` workflow passes.
- reviewers can merge with confidence.
