# 06_Actions

This section covers workflow execution inside GitHub: workflows, runners, secrets, and action reuse.

## A. Workflow

### How to create it

Use `.github/workflows/dba-event-observer.yml`.

### Why it matters

It gives a reproducible event-processing demo for DBA operations.

### How to use it

Run manually from Actions UI or trigger by dispatch:

```bash
bash 06_Actions/scripts/send-repository-dispatch.sh <owner/repo> DBA-9001 prod
```

### What a DBA gains

Predictable, auditable automation flows.

## B. Runners

### How to create it

Set `runs-on: ubuntu-latest` (or self-hosted runners if needed).

### Why it matters

Runner consistency reduces environment-specific failures.

### How to use it

Read runner metadata from workflow logs.

### What a DBA gains

Confidence in repeatability across runs.

## C. Secrets

### How to create it

Store sensitive values in repository secrets (for example, `DEMO_WEBHOOK_SHARED_SECRET`).

### Why it matters

Credentials stay out of source control and logs.

### How to use it

Reference with `${{ secrets.NAME }}` in workflows.

### What a DBA gains

Safer operational automation.

## D. Actions

### How to create it

Use trusted marketplace actions (`checkout`, `upload-artifact`, `github-script`) in workflows.

### Why it matters

Reusable actions reduce custom scripting complexity.

### How to use it

Combine built-in actions with repo scripts for event handling and policy checks.

### What a DBA gains

Faster pipeline assembly and easier maintenance.

## E. Webhooks vs Actions (why use one)

| Use | Best for |
| --- | --- |
| **Actions** | In-repo CI, policy enforcement, and controlled automation |
| **Webhooks** | Event fan-out to external systems and platforms |

Use both together: actions for internal gates, webhooks for external integration.
