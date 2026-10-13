# 3. Webhooks and GitHub Actions

This demo connects event-driven automation to DBA change control workflows.

## 3A. Workflow

### How to create it

Workflow file: `.github/workflows/dba-event-observer.yml`

It supports:

- `workflow_dispatch` (manual demo runs)
- `repository_dispatch` (external webhook-style events)

### Why it matters

You can standardize event handling for planned changes, approvals, and incident notifications.

### How to use it

Run from GitHub Actions UI or trigger through `repository_dispatch`.

### What a DBA gains

Observable, repeatable orchestration for operational events.

## 3B. Runners

### How to create it

The workflow uses `runs-on: ubuntu-latest`.

### Why it matters

Runners define execution environment consistency and are part of reliability engineering.

### How to use it

Read runner metadata in the job output (`runner_os`, `runner_arch`).

### What a DBA gains

Confidence that checks run predictably across pull requests and environments.

## 3C. Secrets

### How to create it

Add repository secrets (for example, `DEMO_WEBHOOK_SHARED_SECRET`) in GitHub Settings.

### Why it matters

Webhooks and integrations need secure credentials without exposing them in code.

### How to use it

The workflow shows whether a secret is configured, without printing the value.

### What a DBA gains

Safer operational automation and cleaner audit posture.

## 3D. Webhooks

### How to create it

```bash
WEBHOOK_SECRET=your-secret bash 05_PASS_Summit_Demos/scripts/create-webhook.sh <owner/repo> <https://listener-url> pull_request,issues
```

### Why it matters

Webhooks notify external systems in near real time for incident tooling, CMDB updates, or chat alerts.

### How to use it

Point the webhook to a listener (for demo, webhook.site) and watch payloads arrive on events.

### What a DBA gains

Immediate integration with operational tooling outside GitHub.

## 3E. Actions

### How to create it

Use standard marketplace actions in workflows (checkout, upload-artifact, github-script).

### Why it matters

Actions are native in-repo automation for tests, approvals, and deployment guardrails.

### How to use it

Send a dispatch event with:

```bash
bash 05_PASS_Summit_Demos/scripts/send-repository-dispatch.sh <owner/repo> DBA-9001 prod
```

### What a DBA gains

A controlled automation pipeline without building custom schedulers or job runners.

## 3F. Webhooks vs Actions: when to use which

### How to decide

| Choose | Best use |
| --- | --- |
| **GitHub Actions** | In-repo checks, CI, policy enforcement, release workflow |
| **Webhooks** | Notify external systems, trigger cross-platform automation |

### Why this split works

Actions own internal verification; webhooks fan out events to external platforms.

### What a DBA gains

Cleaner architecture boundaries and easier troubleshooting during incidents.
