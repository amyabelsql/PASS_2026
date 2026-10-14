#!/usr/bin/env bash
# Blocks risky SQL before it reaches a pull request or production.
#
#   bash 04_Automation/sql_guardrails.sh file.sql ...   Check these files
#   bash 04_Automation/sql_guardrails.sh                Check staged files in 02_Database/changes/
#
# Rules
#   delete-without-where     DELETE with no WHERE clause
#   update-without-where     UPDATE with no WHERE clause
#   truncate-table           TRUNCATE TABLE
#   drop-table               DROP TABLE
#
# A DBA can allow one statement by putting a tag in a comment on it or on the line above it
#   -- DBA_ALLOW_FULL_TABLE_CHANGE   allows DELETE or UPDATE with no WHERE, and TRUNCATE TABLE
#   -- DBA_ALLOW_DROP                allows DROP TABLE
#
# This reads the SQL as text. It does not parse it, so it can miss a WHERE that is
# only inside a subquery. The database tests are the second line of defense.
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

sql_files=()
if (($# > 0)); then
  sql_files=("$@")
else
  while IFS= read -r file; do
    sql_files+=("${file}")
  done < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '^02_Database/changes/.*\.sql$' || true)
fi

if ((${#sql_files[@]} == 0)); then
  echo "SQL guardrails found no SQL files to check."
  exit 0
fi

failures=0
for file in "${sql_files[@]}"; do
  [[ "${file}" == *.sql && -f "${file}" ]] || continue

  while IFS=$'\t' read -r rule line snippet; do
    ((failures += 1))
    if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
      echo "::error file=${file},line=${line}::${rule} ${snippet}"
    else
      echo "BLOCKED ${file} line ${line} ${rule}"
      echo "        ${snippet}"
    fi
  done < <(
    awk '
      function trim(v) { sub(/^[ \t\r]+/, "", v); sub(/[ \t\r]+$/, "", v); return v }
      function has(text, word) { return toupper(text) ~ ("(^|[^A-Z0-9_])" word "([^A-Z0-9_]|$)") }
      function report(rule) { printf "%s\t%d\t%s\n", rule, start, substr(stmt, 1, 160) }

      function flush(   u, r) {
        u = toupper(stmt)
        r = toupper(raw)
        if (u != "") {
          if (index(r, "DBA_ALLOW_FULL_TABLE_CHANGE") == 0) {
            if (u ~ /^DELETE([^A-Z0-9_]|$)/ && !has(u, "WHERE")) report("delete-without-where")
            if (u ~ /^UPDATE([^A-Z0-9_]|$)/ && has(u, "SET") && !has(u, "WHERE")) report("update-without-where")
            if (u ~ /^TRUNCATE TABLE /) report("truncate-table")
          }
          if (u ~ /^DROP TABLE / && index(r, "DBA_ALLOW_DROP") == 0) report("drop-table")
        }
        stmt = ""
        raw = ""
      }

      # A new statement starts when one of these words begins a piece of code.
      # SELECT also starts one, unless it belongs to an INSERT or sits inside open parentheses.
      function starts_statement(p,   u, o, c, tmp) {
        u = toupper(p)
        if (u ~ /^(DELETE|UPDATE|TRUNCATE|DROP|INSERT|MERGE|CREATE|ALTER|EXEC|EXECUTE|DECLARE|PRINT|IF|RETURN|GRANT|REVOKE|DENY|USE)([^A-Z0-9_]|$)/) return 1
        if (u !~ /^SELECT([^A-Z0-9_]|$)/ || toupper(stmt) ~ /^INSERT/) return 0
        tmp = stmt; o = gsub(/\(/, "", tmp)
        tmp = stmt; c = gsub(/\)/, "", tmp)
        return o <= c
      }

      function add(piece) {
        piece = trim(piece)
        if (piece == "") return
        if (stmt != "" && starts_statement(piece)) flush()
        if (stmt == "") { start = NR; raw = lead } else { raw = raw lead }
        stmt = (stmt == "" ? piece : stmt " " piece)
        gsub(/[ \t\r]+/, " ", stmt)
        raw = raw "\n" $0
        lead = ""
      }

      BEGIN { inblock = 0; stmt = ""; raw = ""; lead = "" }

      {
        # Remove /* */ and -- comments from the code, but keep the full line in raw for the tags.
        code = ""
        rest = $0
        while (rest != "") {
          if (inblock) {
            j = index(rest, "*/")
            if (j == 0) { rest = "" } else { rest = substr(rest, j + 2); inblock = 0 }
            continue
          }
          b = index(rest, "/*")
          d = index(rest, "--")
          if (b == 0 && d == 0) { code = code rest; rest = "" }
          else if (d != 0 && (b == 0 || d < b)) { code = code substr(rest, 1, d - 1); rest = "" }
          else { code = code substr(rest, 1, b - 1); rest = substr(rest, b + 2); inblock = 1 }
        }

        t = trim(code)
        if (toupper(t) ~ /^GO( +[0-9]+)?$/) { flush(); lead = ""; next }
        if (t == "") { lead = lead "\n" $0; next }

        while ((k = index(t, ";")) > 0) {
          add(substr(t, 1, k - 1))
          flush()
          t = substr(t, k + 1)
        }
        add(t)
      }

      END { flush() }
    ' "${file}"
  )
done

if ((failures > 0)); then
  echo
  echo "SQL guardrails blocked ${failures} statement(s)."
  echo "If a DBA has reviewed the statement, add -- DBA_ALLOW_FULL_TABLE_CHANGE or -- DBA_ALLOW_DROP above it."
  exit 1
fi

echo "SQL guardrails passed for ${#sql_files[@]} file(s)."
