#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
demo_sql_source="${repo_root}/02_Approval_Process/Demo_Index_Change.sql"
demo_sql_target="${repo_root}/02_Database/changes/005_index_change_demo.sql"
repo="${1:-}"

if [[ ! -f "${demo_sql_source}" ]]; then
  echo "Missing demo SQL source: ${demo_sql_source}"
  exit 1
fi

cp "${demo_sql_source}" "${demo_sql_target}"
echo "Prepared demo SQL at: ${demo_sql_target}"

if [[ -n "${repo}" ]]; then
  bash "${repo_root}/02_Approval_Process/setup-dba-labels.sh" "${repo}"
fi

cat <<'EOF'

Approval demo is ready. Show this flow in GitHub:

1. Open issue form: "DBA index change request"
2. Create a PR that includes:
   - 02_Database/changes/005_index_change_demo.sql
   - linked issue text: Closes #<issue>
3. Remove required labels to show failing check
4. Add labels + approval to show passing check

Helpful artifacts to show:
- 02_Approval_Process/Example_Index_Change_Issue.md
- 02_Approval_Process/Example_Index_Change_PR.md
- 02_Approval_Process/Example_Approval_Checks.md

Enforcement files to open in GitHub:
- .github/workflows/dba-approval-guardrails.yml
- .github/PULL_REQUEST_TEMPLATE.md
- .github/ISSUE_TEMPLATE/04_index-change-request.yml
EOF
