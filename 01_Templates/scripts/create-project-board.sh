#!/usr/bin/env bash
set -euo pipefail

if (($# != 2)); then
  cat <<'EOF'
Usage:
  bash 01_Templates/scripts/create-project-board.sh <owner> "<project title>"

Example:
  bash 01_Templates/scripts/create-project-board.sh amyabelsql "DBA Change Control"
EOF
  exit 1
fi

owner="$1"
title="$2"

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

project_number="$(gh project create --owner "${owner}" --title "${title}" --format json --jq '.number')"
project_url="$(gh project view "${project_number}" --owner "${owner}" --format json --jq '.url')"

echo "Created project #${project_number}: ${project_url}"
echo
echo "Recommended next steps:"
echo "1. Add custom fields: Risk, Environment, Rollback Ready."
echo "2. Save views: Incoming Requests, Ready for Approval, Scheduled, Deployed."
echo "3. Add issue automation from this repository's issue forms."
