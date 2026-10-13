#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash 05_PASS_Summit_Demos/scripts/sql_guardrails.sh [sql_file ...]

Behavior:
  - With file arguments: validates only those SQL files.
  - Without arguments: validates staged SQL files under 02_Database/changes/.

Guardrails:
  - DELETE without WHERE (unless -- DBA_ALLOW_FULL_TABLE_CHANGE)
  - UPDATE without WHERE (unless -- DBA_ALLOW_FULL_TABLE_CHANGE)
  - DROP TABLE (unless -- DBA_ALLOW_DROP)
  - Any statement can be bypassed with -- DBA_ALLOW_UNSAFE (for emergency demos only)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

declare -a sql_files=()
if (($# > 0)); then
  sql_files=("$@")
else
  mapfile -t sql_files < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '^02_Database/changes/.*\.sql$' || true)
fi

if ((${#sql_files[@]} == 0)); then
  echo "SQL guardrails: no SQL files to validate."
  exit 0
fi

failures=0
for file in "${sql_files[@]}"; do
  [[ "${file}" == *.sql ]] || continue
  [[ -f "${file}" ]] || continue

  while IFS=$'\t' read -r rule snippet; do
    [[ -z "${rule}" ]] && continue
    ((failures += 1))
    if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
      echo "::error file=${file}::${rule}: ${snippet}"
    else
      echo "ERROR ${file}: ${rule}: ${snippet}"
    fi
  done < <(
    awk '
      BEGIN {
        IGNORECASE = 1;
        RS = ";";
        ORS = "\n";
      }

      function trim(value) {
        sub(/^[[:space:]]+/, "", value);
        sub(/[[:space:]]+$/, "", value);
        return value;
      }

      {
        raw = $0;
        raw_upper = toupper(raw);

        if (raw ~ /^[[:space:]]*$/) {
          next;
        }
        if (index(raw_upper, "DBA_ALLOW_UNSAFE") > 0) {
          next;
        }

        compact = raw;
        gsub(/--[^\n]*/, " ", compact);
        gsub(/[[:space:]]+/, " ", compact);
        compact = trim(compact);
        upper = toupper(compact);

        if (upper == "") {
          next;
        }

        if (upper ~ /^DELETE[[:space:]]+FROM[[:space:]]/ &&
            upper !~ /[[:space:]]WHERE[[:space:]]/ &&
            index(raw_upper, "DBA_ALLOW_FULL_TABLE_CHANGE") == 0) {
          print "delete-without-where\t" substr(compact, 1, 180);
        }

        if (upper ~ /^UPDATE[[:space:]]+[^[:space:]]+[[:space:]]+SET[[:space:]]/ &&
            upper !~ /[[:space:]]WHERE[[:space:]]/ &&
            index(raw_upper, "DBA_ALLOW_FULL_TABLE_CHANGE") == 0) {
          print "update-without-where\t" substr(compact, 1, 180);
        }

        if (upper ~ /DROP[[:space:]]+TABLE[[:space:]]/ &&
            index(raw_upper, "DBA_ALLOW_DROP") == 0) {
          print "drop-table-without-allow-tag\t" substr(compact, 1, 180);
        }
      }
    ' "${file}"
  )
done

if ((failures > 0)); then
  cat <<'EOF'
SQL guardrails blocked this change.
Add one of these waiver tags only after explicit DBA review:
  -- DBA_ALLOW_FULL_TABLE_CHANGE
  -- DBA_ALLOW_DROP
  -- DBA_ALLOW_UNSAFE
EOF
  exit 1
fi

echo "SQL guardrails passed for ${#sql_files[@]} file(s)."
