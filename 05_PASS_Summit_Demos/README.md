# PASS Summit DBA Governance Demos

This track adds five demos that are easy to present, easy to reproduce, and focused on database reliability workflows in GitHub.

## Demo order

1. [Templates and Approval Process](01_Templates_And_Approval_Process.md)
2. [Approvals and Automation](02_Approvals_And_Automation.md)
3. [Webhooks and GitHub Actions](03_Webhooks_And_GitHub_Actions.md)
4. [Documentation (Wiki, Mermaid, Gist)](04_Documentation.md)
5. [Tips and Tricks](05_Tips_And_Tricks.md)

## What each demo answers

Each section is structured around:

- **How to create it**
- **Why it matters**
- **How to use it**
- **What a DBA gains**

## Fast start

1. Use the issue forms under `.github/ISSUE_TEMPLATE/`.
2. Open a pull request and follow `.github/PULL_REQUEST_TEMPLATE.md`.
3. Watch guardrails run in:
   - `.github/workflows/dba-approval-guardrails.yml`
   - `.github/workflows/database-pr-tests.yml`
4. Use scripts in `05_PASS_Summit_Demos/scripts/` for template repos, project boards, and webhooks.
5. Use `05_PASS_Summit_Demos/Copilot_Prompts_For_DBAs.md` for repeatable Copilot demos.
