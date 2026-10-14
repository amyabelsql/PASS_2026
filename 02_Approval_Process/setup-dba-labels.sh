#!/usr/bin/env bash
set -euo pipefail

if (($# != 1)); then
  cat <<'EOF'
Usage:
  bash 02_Approval_Process/setup-dba-labels.sh <owner/repo>

Example:
  bash 02_Approval_Process/setup-dba-labels.sh amyabelsql/PASS_2026
EOF
  exit 1
fi

repo="$1"

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

upsert_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  if gh label create "${name}" --repo "${repo}" --color "${color}" --description "${description}" >/dev/null 2>&1; then
    echo "Created label: ${name}"
  else
    gh label edit "${name}" --repo "${repo}" --color "${color}" --description "${description}" >/dev/null
    echo "Updated label: ${name}"
  fi
}

upsert_label "dba-approved" "0E8A16" "DBA reviewer approved the change."
upsert_label "index-change" "5319E7" "PR/issue includes index create/drop/alter."
upsert_label "change-control" "1D76DB" "Tracked under formal DBA change control."
upsert_label "needs-rollout-window" "FBCA04" "Needs scheduling in deployment window."

echo "DBA approval labels are ready in ${repo}."
