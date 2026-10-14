#!/usr/bin/env bash
# Builds and removes the Approvals demo. Run it through make from the repo root.
#
#   make approvals-demo    demo    Create a public demo repo with a protected main branch,
#                                  a production environment, an index change issue, and a pull request
#   make approvals-reset   reset   Delete the demo repo
#
# The demo repo is public because environment approvals only work in private repos
# on GitHub Enterprise Cloud.
set -euo pipefail

# Settings. If you forked this repo, change OWNER to your GitHub user name.
OWNER="${OWNER:-amyabelsql}"
DEMO_REPO="${DEMO_REPO:-${OWNER}/pass-dba-approvals}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# Helpers

check_tools() {
  command -v gh >/dev/null || { echo "Install the GitHub CLI with 'brew install gh'."; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first."; exit 1; }
  for scope in workflow delete_repo; do
    gh auth status 2>&1 | grep -q "'${scope}'" || { echo "Run 'gh auth refresh -s workflow,delete_repo' first."; exit 1; }
  done
}

confirm() {
  read -r -p "$1 Type yes to continue: " answer
  [[ "${answer}" == "yes" ]] || { echo "Nothing was changed."; exit 1; }
}

put_file() { # repo path, local file, branch, commit message
  gh api -X PUT "repos/${DEMO_REPO}/contents/$1" \
    -f message="$4" -f branch="$3" -f content="$(base64 < "$2" | tr -d '\n')" >/dev/null
}

add_labels() {
  gh label create dba-change   -R "${DEMO_REPO}" --force --color 1D76DB --description "Planned database change"
  gh label create index-change -R "${DEMO_REPO}" --force --color 5319E7 --description "Index create, drop, or rebuild"
  gh label create needs-triage -R "${DEMO_REPO}" --force --color FBCA04 --description "Not reviewed by a DBA yet"
  gh label create dba-approved -R "${DEMO_REPO}" --force --color 0E8A16 --description "Approved by a DBA"
}

add_environment() {
  local user_id
  user_id="$(gh api "users/${OWNER}" --jq .id)"
  gh api -X PUT "repos/${DEMO_REPO}/environments/production" --input - >/dev/null <<EOF
{
  "reviewers": [{ "type": "User", "id": ${user_id} }],
  "prevent_self_review": false,
  "deployment_branch_policy": null
}
EOF
}

add_ruleset() {
  # Admins can bypass so a solo presenter can still merge. Remove the bypass in a real repo.
  gh api -X POST "repos/${DEMO_REPO}/rulesets" --input - >/dev/null <<'EOF'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "bypass_actors": [{ "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false } }
  ]
}
EOF
}

# Commands

demo() {
  local issue_url issue main_sha pr_url
  gh repo view "${DEMO_REPO}" >/dev/null 2>&1 && { echo "${DEMO_REPO} already exists. Run 'make approvals-reset' first."; exit 1; }

  echo "Creating ${DEMO_REPO}"
  gh repo create "${DEMO_REPO}" --public --add-readme \
    --description "PASS Summit demo of DBA approvals in GitHub" >/dev/null
  for _ in $(seq 1 15); do gh api "repos/${DEMO_REPO}/contents/README.md" >/dev/null 2>&1 && break; sleep 2; done

  echo "Adding the deploy workflow, CODEOWNERS, issue form, and pull request template"
  printf '* @%s\n' "${OWNER}" > "${WORK}/CODEOWNERS"
  put_file .github/CODEOWNERS "${WORK}/CODEOWNERS" main "Add CODEOWNERS"
  put_file .github/workflows/dba-deploy-approval.yml "${ROOT}/.github/workflows/dba-deploy-approval.yml" main "Add deploy workflow"
  put_file .github/ISSUE_TEMPLATE/04_index-change-request.yml "${ROOT}/.github/ISSUE_TEMPLATE/04_index-change-request.yml" main "Add index change form"
  put_file .github/PULL_REQUEST_TEMPLATE.md "${ROOT}/.github/PULL_REQUEST_TEMPLATE.md" main "Add pull request template"

  echo "Adding labels, the production environment, and the main branch ruleset"
  add_labels >/dev/null
  add_environment
  add_ruleset

  echo "Opening the index change issue"
  issue_url="$(gh issue create -R "${DEMO_REPO}" \
    --title "[Index Change] Add IX_Orders_CustomerID_OrderDate" \
    --label "dba-change,index-change,needs-triage" \
    --body-file - <<'EOF'
### Target table

dbo.Orders

### Index name

IX_Orders_CustomerID_OrderDate

### Change operation

Create index

### Why this index change is needed

The customer order history query does a key lookup on every row and reads 125,000 pages at peak.

### Before change evidence

Duration P95 is 1,800 ms, CPU P95 is 900 ms, and logical reads are 125,000. The plan shows a seek plus key lookup.

### Expected success criteria

Logical reads drop by at least 40 percent and duration P95 is below 900 ms.

### Rollback plan

```sql
DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;
```
EOF
)"
  issue="${issue_url##*/}"

  echo "Opening the pull request"
  main_sha="$(gh api "repos/${DEMO_REPO}/git/ref/heads/main" --jq .object.sha)"
  gh api -X POST "repos/${DEMO_REPO}/git/refs" -f ref=refs/heads/index-change -f sha="${main_sha}" >/dev/null
  put_file 02_Database/changes/005_index_change_demo.sql "${ROOT}/02_Approval_Process/Demo_Index_Change.sql" \
    index-change "Add IX_Orders_CustomerID_OrderDate"
  pr_url="$(gh pr create -R "${DEMO_REPO}" --head index-change --base main \
    --title "Add covering index for the order history query" \
    --label "dba-change,index-change" \
    --body-file - <<EOF
## Change summary

Adds IX_Orders_CustomerID_OrderDate so the order history query stops doing key lookups.

## Linked issue

Closes #${issue}

## Deployment and rollback

- Deployment window: next Tuesday 01:00 to 01:30 UTC
- Rollback command: \`DROP INDEX IX_Orders_CustomerID_OrderDate ON dbo.Orders;\`
- Data backout plan: none needed, this is an index only change

## Index-change evidence

- Before metrics: 125,000 logical reads and 1,800 ms P95 duration
- Expected target: under 75,000 logical reads and under 900 ms P95 duration
EOF
)"

  cat <<EOF

Demo is ready.
  Repo           https://github.com/${DEMO_REPO}
  Issue          ${issue_url}
  Pull request   ${pr_url}
  Environment    https://github.com/${DEMO_REPO}/settings/environments

Optional chat setup, run once in the channel you will show
  Slack   /github subscribe ${DEMO_REPO} reviews workflows:{event:"push","workflow_dispatch"}
  Teams   @GitHub subscribe ${DEMO_REPO} reviews workflows:{event:"push","workflow_dispatch"}
EOF
}

reset() {
  [[ "${DEMO_REPO}" != "${OWNER}/PASS_2026" ]] || { echo "DEMO_REPO cannot be this repo."; exit 1; }
  confirm "This deletes ${DEMO_REPO}."
  if gh repo view "${DEMO_REPO}" >/dev/null 2>&1; then
    gh repo delete "${DEMO_REPO}" --yes
  fi
  echo "Reset finished."
}

check_tools
case "${1:-}" in
  demo|reset) "$1" ;;
  *) echo "Usage: bash 02_Approval_Process/approvals.sh demo|reset"; exit 1 ;;
esac
