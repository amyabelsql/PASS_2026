#!/usr/bin/env bash
# Runs the Copilot cloud agent demo. Run it through make from the repo root.
#
#   make ai-demo   demo   Open an issue in the approvals demo repo and assign it to Copilot
#
# Needs the repo from make approvals-demo. make approvals-reset removes everything this creates.
set -euo pipefail

# Settings. If you forked this repo, change OWNER to your GitHub user name.
OWNER="${OWNER:-amyabelsql}"
DEMO_REPO="${DEMO_REPO:-${OWNER}/pass-dba-approvals}"

command -v gh >/dev/null || { echo "Install the GitHub CLI with 'brew install gh'."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first."; exit 1; }
gh repo view "${DEMO_REPO}" >/dev/null 2>&1 || { echo "Run 'make approvals-demo' first."; exit 1; }

demo() {
  local url
  url="$(gh issue create -R "${DEMO_REPO}" \
    --title "Add a validation query for IX_Orders_CustomerID_OrderDate" \
    --label dba-change \
    --body-file - <<'EOF'
Add a validation script for the new index.

Create `03_Tests/validate_IX_Orders_CustomerID_OrderDate.sql` that

- confirms the index exists on dbo.Orders with the key columns CustomerID and OrderDate DESC
- confirms OrderTotal and OrderStatus are included columns
- prints PASS or FAIL for each check
- uses schema names and does not use SELECT *

Only add this one file. Do not change any other files.
EOF
)"
  gh issue edit "${url##*/}" -R "${DEMO_REPO}" --add-assignee @copilot >/dev/null
  cat <<EOF

Issue assigned to Copilot.
  Issue          ${url}
  Pull requests  https://github.com/${DEMO_REPO}/pulls

Copilot opens a draft pull request within a minute and asks for your review when it is done.
EOF
}

case "${1:-}" in
  demo) demo ;;
  *) echo "Usage: bash 03_AI_with_Copilot/ai.sh demo"; exit 1 ;;
esac
