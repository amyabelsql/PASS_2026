## Change summary

Describe the database change in plain language and link the ticket or issue.

## Linked issue

Use GitHub linkage keywords when possible (example: `Closes #123`).

## Deployment and rollback

- Deployment window:
- Rollback command or script:
- Data backout plan (if data migration is involved):

## Validation evidence

- [ ] Local SQL checks executed
- [ ] Existing CI workflows passed
- [ ] Any intentional risk and mitigation are documented

## Index-change evidence (required for index changes)

- Before metrics:
- After metrics (or expected target):
- Index rollback command:

## Approval checklist

- [ ] PR includes the `dba-approved` label for SQL changes
- [ ] PR includes `index-change` label for index add/drop/alter work
- [ ] At least one non-author reviewer approved
- [ ] Change can be explained in under 2 minutes to an on-call DBA
