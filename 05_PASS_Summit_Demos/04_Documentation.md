# 4. Documentation

This demo turns operational knowledge into reusable assets for onboarding and incident response.

## 4A. Wikis

### How to create it

1. Enable Wiki in repository settings.
2. Clone the wiki repo:

```bash
git clone https://github.com/<owner>/<repo>.wiki.git
```

3. Seed with the example pages in `05_PASS_Summit_Demos/04_Documentation/wiki/`.

### Why it matters

Wikis give DBAs a lightweight space for runbooks and architecture notes that evolve quickly.

### How to use it

Use wiki pages for operational guides (backup, restore, failover, release checks).

### What a DBA gains

Faster incident handling and better team continuity during handoffs.

## 4B. Mermaid diagrams

### How to create it

Use Mermaid markdown files like:

- `05_PASS_Summit_Demos/04_Documentation/mermaid/dba-change-flow.md`

### Why it matters

Visual flow diagrams make review and approval logic easier for mixed audiences.

### How to use it

Render the Mermaid block in GitHub markdown and present the flow during reviews.

### What a DBA gains

Clear communication of controls and dependencies across engineering and operations.

## 4C. Gists

### How to create it

Publish reusable snippets as gists:

```bash
gh gist create 05_PASS_Summit_Demos/04_Documentation/gist/dba-hotfix-checklist.md --public -d "DBA hotfix checklist"
```

### Why it matters

Gists are easy to share during incidents, reviews, and training sessions.

### How to use it

Keep short checklists and emergency snippets in gist form and link them in incidents.

### What a DBA gains

Portable operational knowledge that can be reused across repos and teams.
