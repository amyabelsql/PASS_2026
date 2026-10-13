# 07_Documentation

This section shows how to package operational knowledge so DBAs can reuse it quickly.

## A. Wikis

### How to create it

1. Enable Wiki in repo settings.
2. Clone:

```bash
git clone https://github.com/<owner>/<repo>.wiki.git
```

3. Seed from `07_Documentation/wiki/`.

### Why it matters

Wikis are a fast place for runbooks and process notes.

### How to use it

Maintain backup, restore, failover, and deployment runbooks in wiki pages.

### What a DBA gains

Faster incident response and smoother team onboarding.

## B. Mermaid

### How to create it

Use diagrams from `07_Documentation/mermaid/dba-change-flow.md`.

### Why it matters

Visual process maps are easier to explain in approvals and postmortems.

### How to use it

Render Mermaid in GitHub markdown and use it in walkthroughs.

### What a DBA gains

Clear communication across engineering, SRE, and leadership.

## C. Gist

### How to create it

```bash
gh gist create 07_Documentation/gist/dba-hotfix-checklist.md --public -d "DBA hotfix checklist"
```

### Why it matters

Gists are shareable and portable for fast operational reuse.

### How to use it

Share checklists/snippets directly in incidents and change tickets.

### What a DBA gains

Reusable, searchable operational assets across repositories.
