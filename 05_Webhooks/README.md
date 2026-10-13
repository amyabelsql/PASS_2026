# 05_Webhooks

This section demonstrates webhook-first integration with external operational systems.

## How to create it

Create a webhook with:

```bash
WEBHOOK_SECRET=your-secret bash 05_Webhooks/scripts/create-webhook.sh <owner/repo> <https://listener-url> pull_request,issues
```

## Why it matters

Webhooks push GitHub events to systems outside GitHub (incident tools, CMDB, chatops, ticketing).

## How to use it

1. Point webhook to a test endpoint (for example, webhook.site).
2. Trigger events (open issue, update PR).
3. Inspect payload shape and map it to downstream automation.

## What a DBA gains

- Real-time operational visibility.
- Easier integration with existing production tooling.
- Better event traceability during incidents.
