#!/usr/bin/env bash
set -euo pipefail

if (($# != 3)); then
  cat <<'EOF'
Usage:
  bash 06_Actions/scripts/send-repository-dispatch.sh <owner/repo> <ticket-id> <environment>

Example:
  bash 06_Actions/scripts/send-repository-dispatch.sh amyabelsql/PASS_2026 DBA-447 prod
EOF
  exit 1
fi

repo="$1"
ticket="$2"
environment="$3"

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

gh api --method POST "repos/${repo}/dispatches" \
  -f event_type="dba-change-request" \
  -f client_payload[ticket]="${ticket}" \
  -f client_payload[environment]="${environment}" >/dev/null

echo "repository_dispatch sent to ${repo} (ticket=${ticket}, environment=${environment})"
