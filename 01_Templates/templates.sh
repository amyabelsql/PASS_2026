#!/usr/bin/env bash
# Builds and tears down the Templates demo. Run it through make from the repo root.
#
#   make templates            build      Mark this repo as a template, add labels, build the board
#   make templates-demo       demo       Create a demo repo from the template with sample issues
#   make templates-reset      reset      Delete the demo repo and its board items
#   make templates-teardown   teardown   Reset, delete the board, and turn off the template setting
set -euo pipefail

# Settings. If you forked this repo, change OWNER to your GitHub user name.
OWNER="${OWNER:-amyabelsql}"
TEMPLATE_REPO="${TEMPLATE_REPO:-${OWNER}/PASS_2026}"
DEMO_REPO="${DEMO_REPO:-${OWNER}/pass-dba-demo}"
BOARD="${BOARD:-DBA Change Control}"

# Helpers

check_tools() {
  command -v gh >/dev/null || { echo "Install the GitHub CLI with 'brew install gh'."; exit 1; }
  command -v jq >/dev/null || { echo "Install jq with 'brew install jq'."; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first."; exit 1; }
  for scope in project delete_repo; do
    gh auth status 2>&1 | grep -q "'${scope}'" || { echo "Run 'gh auth refresh -s project,delete_repo' first."; exit 1; }
  done
}

board_number() {
  gh project list --owner "${OWNER}" --limit 100 --format json \
    --jq ".projects[] | select(.title == \"${BOARD}\") | .number" | head -n 1
}

confirm() {
  read -r -p "$1 Type yes to continue: " answer
  [[ "${answer}" == "yes" ]] || { echo "Nothing was changed."; exit 1; }
}

add_labels() {
  local repo="$1"
  gh label create dba-change      -R "${repo}" --force --color 1D76DB --description "Planned database change"
  gh label create index-change    -R "${repo}" --force --color 5319E7 --description "Index create, drop, or rebuild"
  gh label create dba-incident    -R "${repo}" --force --color B60205 --description "Production database incident"
  gh label create production      -R "${repo}" --force --color D93F0B --description "Affects production"
  gh label create dba-maintenance -R "${repo}" --force --color 0E8A16 --description "Recurring maintenance task"
  gh label create needs-triage    -R "${repo}" --force --color FBCA04 --description "Not reviewed by a DBA yet"
  gh label create dba-approved    -R "${repo}" --force --color 0E8A16 --description "Approved by a DBA"
}

build_board() {
  local number fields status_id
  number="$(board_number)"
  if [[ -z "${number}" ]]; then
    number="$(gh project create --owner "${OWNER}" --title "${BOARD}" --format json --jq .number)"
  fi
  fields="$(gh project field-list "${number}" --owner "${OWNER}" --limit 50 --format json)"

  # Replace the default Status values. Reuse the Todo and Done ids so the
  # built in board automations keep working.
  status_id="$(jq -r '.fields[] | select(.name == "Status") | .id' <<<"${fields}")"
  local todo done_id
  todo="$(jq -r '.fields[] | select(.name == "Status") | .options[] | select(.name == "Todo" or .name == "Intake") | .id' <<<"${fields}")"
  done_id="$(jq -r '.fields[] | select(.name == "Status") | .options[] | select(.name == "Done") | .id' <<<"${fields}")"
  jq -n --arg field "${status_id}" --arg todo "${todo}" --arg done "${done_id}" '{
    query: "mutation($field: ID!, $options: [ProjectV2SingleSelectFieldOptionInput!]) { updateProjectV2Field(input: {fieldId: $field, singleSelectOptions: $options}) { clientMutationId } }",
    variables: { field: $field, options: [
      ((if $todo == "" then {} else {id: $todo} end) + {name: "Intake", color: "GRAY", description: "Not reviewed yet"}),
      {name: "Needs Evidence",                  color: "YELLOW", description: "Missing validation or rollback plan"},
      {name: "Ready for Approval",              color: "BLUE",   description: "Waiting on a DBA reviewer"},
      {name: "Approved",                        color: "GREEN",  description: "Approved by a DBA"},
      {name: "Scheduled",                       color: "PURPLE", description: "Booked into a deployment window"},
      ((if $done == "" then {} else {id: $done} end) + {name: "Done", color: "GREEN", description: "Deployed and verified"})
    ]}
  }' | gh api graphql --input - >/dev/null

  add_field() {
    jq -e --arg n "$1" '.fields[] | select(.name == $n)' <<<"${fields}" >/dev/null && return
    gh project field-create "${number}" --owner "${OWNER}" --name "$1" --data-type SINGLE_SELECT --single-select-options "$2" >/dev/null
  }
  add_field "Risk" "Low,Medium,High"
  add_field "Environment" "Dev,QA,Prod"
  add_field "Rollback Ready" "Yes,No"

  gh project edit "${number}" --owner "${OWNER}" --visibility PUBLIC >/dev/null
  gh project link "${number}" --owner "${OWNER}" --repo "${TEMPLATE_REPO}" >/dev/null 2>&1 || true
}

# Commands

build() {
  echo "Marking ${TEMPLATE_REPO} as a template"
  gh repo edit "${TEMPLATE_REPO}" --template
  echo "Adding labels"
  add_labels "${TEMPLATE_REPO}" >/dev/null
  echo "Building the ${BOARD} board"
  build_board
  echo
  echo "Done. Board is at $(gh project view "$(board_number)" --owner "${OWNER}" --format json --jq .url)"
}

demo() {
  local number project_id fields
  number="$(board_number)"
  [[ -n "${number}" ]] || { echo "Run 'make templates' first."; exit 1; }
  gh repo view "${DEMO_REPO}" >/dev/null 2>&1 && { echo "${DEMO_REPO} already exists. Run 'make templates-reset' first."; exit 1; }

  echo "Creating ${DEMO_REPO} from ${TEMPLATE_REPO}"
  gh repo create "${DEMO_REPO}" --template "${TEMPLATE_REPO}" --private >/dev/null
  for _ in $(seq 1 15); do gh api "repos/${DEMO_REPO}/contents/README.md" >/dev/null 2>&1 && break; sleep 2; done
  add_labels "${DEMO_REPO}" >/dev/null

  project_id="$(gh project view "${number}" --owner "${OWNER}" --format json --jq .id)"
  fields="$(gh project field-list "${number}" --owner "${OWNER}" --limit 50 --format json)"
  set_field() { # item field value
    gh project item-edit --id "$1" --project-id "${project_id}" \
      --field-id "$(jq -r --arg f "$2" '.fields[] | select(.name == $f) | .id' <<<"${fields}")" \
      --single-select-option-id "$(jq -r --arg f "$2" --arg v "$3" '.fields[] | select(.name == $f) | .options[] | select(.name == $v) | .id' <<<"${fields}")" >/dev/null
  }
  add_issue() { # title labels status risk rollback body
    local url item
    url="$(gh issue create -R "${DEMO_REPO}" --title "$1" --label "$2" --body "$6")"
    item="$(gh project item-add "${number}" --owner "${OWNER}" --url "${url}" --format json --jq .id)"
    set_field "${item}" "Status" "$3"
    set_field "${item}" "Risk" "$4"
    set_field "${item}" "Rollback Ready" "$5"
    echo "  ${url}"
  }

  echo "Adding sample issues to the board"
  add_issue "[DBA Change] Add CustomerName to dbo.usp_GetCustomerOrders" "dba-change,needs-triage" \
    "Intake" "Low" "Yes" "Return CustomerName so the app stops making a second call per order."
  add_issue "[Index Change] Add IX_Orders_CustomerID_OrderDate" "dba-change,index-change" \
    "Needs Evidence" "Medium" "No" "Key lookup on every row. Before and after logical reads are still missing."
  add_issue "[DBA Maintenance] Rebuild fragmented indexes on dbo.Orders" "dba-maintenance" \
    "Scheduled" "Low" "Yes" "Fragmentation is above 40 percent. Booked for the Sunday maintenance window."
}

reset() {
  local number
  [[ "${DEMO_REPO}" != "${TEMPLATE_REPO}" ]] || { echo "DEMO_REPO cannot be the template repo."; exit 1; }
  [[ "${1:-}" == "--confirmed" ]] || confirm "This deletes ${DEMO_REPO} and its issues."
  number="$(board_number)"
  if [[ -n "${number}" ]]; then
    gh project item-list "${number}" --owner "${OWNER}" --limit 200 --format json \
      --jq ".items[] | select(.content.repository == \"${DEMO_REPO}\") | .id" |
      while read -r id; do gh project item-delete "${number}" --owner "${OWNER}" --id "${id}" >/dev/null; done
  fi
  if gh repo view "${DEMO_REPO}" >/dev/null 2>&1; then
    gh repo delete "${DEMO_REPO}" --yes
  fi
  echo "Reset finished."
}

teardown() {
  local number
  confirm "This deletes ${DEMO_REPO}, the ${BOARD} board, and turns off the template setting on ${TEMPLATE_REPO}."
  reset --confirmed
  number="$(board_number)"
  [[ -z "${number}" ]] || gh project delete "${number}" --owner "${OWNER}" >/dev/null
  gh repo edit "${TEMPLATE_REPO}" --template=false
  echo "Teardown finished."
}

check_tools
case "${1:-}" in
  build|demo|reset|teardown) "$1" ;;
  *) echo "Usage: bash 01_Templates/templates.sh build|demo|reset|teardown"; exit 1 ;;
esac
