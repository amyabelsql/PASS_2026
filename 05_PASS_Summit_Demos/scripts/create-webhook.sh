#!/usr/bin/env bash
set -euo pipefail

if (($# < 2 || $# > 3)); then
  cat <<'EOF'
Usage:
  WEBHOOK_SECRET=... bash 05_PASS_Summit_Demos/scripts/create-webhook.sh <owner/repo> <https://listener.example.com/github> [event1,event2,...]

Example:
  WEBHOOK_SECRET=demo123 bash 05_PASS_Summit_Demos/scripts/create-webhook.sh amyabelsql/PASS_2026 https://webhook.site/your-id pull_request,issues
EOF
  exit 1
fi

repo="$1"
webhook_url="$2"
events_csv="${3:-pull_request,issues}"

if [[ -z "${WEBHOOK_SECRET:-}" ]]; then
  echo "Set WEBHOOK_SECRET in your environment before running this script."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

IFS=',' read -r -a events <<< "${events_csv}"
event_args=()
for event_name in "${events[@]}"; do
  trimmed_event="$(echo "${event_name}" | tr -d '[:space:]')"
  if [[ -n "${trimmed_event}" ]]; then
    event_args+=("-f" "events[]=${trimmed_event}")
  fi
done

hook_id="$(
  gh api --method POST "repos/${repo}/hooks" \
    -f name="web" \
    -f active=true \
    -f config[url]="${webhook_url}" \
    -f config[content_type]="json" \
    -f config[insecure_ssl]="0" \
    -f config[secret]="${WEBHOOK_SECRET}" \
    "${event_args[@]}" \
    --jq '.id'
)"

echo "Created webhook ${hook_id} on ${repo} -> ${webhook_url}"
