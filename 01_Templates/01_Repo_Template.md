# Repo Template

## What

A **repository template** is a starter repo that already includes your DBA governance defaults (workflows, issue forms, hooks, docs, CODEOWNERS).

## Why

Without a template, every new database repo starts differently. That inconsistency causes missing checks, weak approvals, and onboarding friction.

## How (GitHub UI first)

1. Open the source repo in GitHub.
2. Go to **Settings** → **General**.
3. In **Template repository**, enable **Template repository**.
4. Return to the repo home page and click **Use this template**.
5. Choose owner, new repo name, and visibility.
6. Create the new repo and verify:
   - `.github/workflows/` files exist
   - issue templates exist
   - `CODEOWNERS` exists
   - README links still resolve

## Optional accelerator

You can create from template via CLI:

```bash
bash 01_Templates/scripts/create-repo-from-template.sh <template-owner/repo> <new-owner/repo> private
```

## Best practices for DBAs

1. Keep one **golden template** repo and version it intentionally.
2. Add template release notes so teams know what governance changed.
3. Keep template repos small and focused on controls, not app-specific code.
4. Validate branch protection and required checks immediately after creating each new repo.
5. Run one “intentional bad change” in each new repo to prove gates are working.
