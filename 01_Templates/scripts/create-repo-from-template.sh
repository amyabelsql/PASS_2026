#!/usr/bin/env bash
set -euo pipefail

if (($# < 2 || $# > 3)); then
  cat <<'EOF'
Usage:
  bash 01_Templates/scripts/create-repo-from-template.sh <template-owner/repo> <new-owner/repo> [public|private|internal]

Example:
  bash 01_Templates/scripts/create-repo-from-template.sh amyabelsql/PASS_2026 amyabelsql/pass-dba-demo private
EOF
  exit 1
fi

template_repo="$1"
new_repo="$2"
visibility="${3:-private}"

case "${visibility}" in
  public) visibility_flag="--public" ;;
  private) visibility_flag="--private" ;;
  internal) visibility_flag="--internal" ;;
  *)
    echo "Invalid visibility: ${visibility}. Use public, private, or internal."
    exit 1
    ;;
esac

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

gh repo create "${new_repo}" --template "${template_repo}" "${visibility_flag}" --clone

echo "Repository created from template: ${new_repo}"
