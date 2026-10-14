#!/usr/bin/env bash
# Builds, runs, and removes the Automation demo. Run it through make from the repo root.
#
#   make automation            build      Add the SQL password secret to the repo and install the pre-commit hooks
#   make automation-demo       demo       Run the guardrails on a risky script, then run the database tests on GitHub
#   make automation-teardown   teardown   Remove the pre-commit hooks and the SQL password secret
set -euo pipefail

# Settings. If you forked this repo, change OWNER to your GitHub user name.
OWNER="${OWNER:-amyabelsql}"
REPO="${REPO:-${OWNER}/PASS_2026}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

check_tools() {
  command -v gh >/dev/null || { echo "Install the GitHub CLI with 'brew install gh'."; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first."; exit 1; }
}

has_secret() {
  gh secret list -R "${REPO}" --json name --jq '.[].name' | grep -qx SQL_SA_PASSWORD
}

build() {
  if has_secret; then
    echo "SQL_SA_PASSWORD secret already exists in ${REPO}"
  else
    echo "Adding a random SQL_SA_PASSWORD secret to ${REPO}"
    # The password only lives in the GitHub secret and the throwaway test container.
    printf '%s' "$(openssl rand -base64 24 | tr -d '/+=')Aa1!" | gh secret set SQL_SA_PASSWORD -R "${REPO}"
  fi

  if command -v pre-commit >/dev/null; then
    echo "Installing the pre-commit hooks"
    pre-commit install >/dev/null
  else
    echo "Install pre-commit with 'brew install pre-commit', then run 'make automation' again."
  fi
  echo "Done."
}

demo() {
  local good bad
  echo "Guardrails on 04_Automation/Demo_Risky_Change.sql"
  echo
  bash 04_Automation/sql_guardrails.sh 04_Automation/Demo_Risky_Change.sql || true
  echo
  echo "Guardrails on the good AI change"
  bash 04_Automation/sql_guardrails.sh 02_Database/changes/004_ai_generated_good_change.sql
  echo

  has_secret || { echo "Run 'make automation' first so the database tests have a password."; exit 1; }
  echo "Starting the database tests on GitHub for the good and the bad AI change"
  gh workflow run database-pr-tests.yml -R "${REPO}" -f change=good
  gh workflow run database-pr-tests.yml -R "${REPO}" -f change=bad
  sleep 5
  echo
  echo "Runs"
  gh run list -R "${REPO}" -w database-pr-tests.yml -L 2 --json url,displayTitle --jq '.[].url'
  echo
  echo "The good run passes and the bad run fails on the made up column. Each takes about two minutes."
}

teardown() {
  read -r -p "This removes the pre-commit hooks and the SQL_SA_PASSWORD secret from ${REPO}. Type yes to continue: " answer
  [[ "${answer}" == "yes" ]] || { echo "Nothing was changed."; exit 1; }
  command -v pre-commit >/dev/null && pre-commit uninstall >/dev/null
  if has_secret; then gh secret delete SQL_SA_PASSWORD -R "${REPO}"; fi
  echo "Teardown finished."
}

check_tools
case "${1:-}" in
  build|demo|teardown) "$1" ;;
  *) echo "Usage: bash 04_Automation/automation.sh build|demo|teardown"; exit 1 ;;
esac
