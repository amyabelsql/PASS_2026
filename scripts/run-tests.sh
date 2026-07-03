#!/usr/bin/env bash
set -euo pipefail

# run-tests.sh
# End-to-end local/CI database test flow for SQL change validation.

SQL_SERVER="${SQL_SERVER:-localhost}"
SQL_PORT="${SQL_PORT:-1433}"
SQL_USER="${SQL_USER:-sa}"
SQL_PASSWORD="${SQL_PASSWORD:-REMOVED-PASSWORD}"
DB_NAME="${DB_NAME:-GitDemoDb}"
CHANGE_SCRIPT="${CHANGE_SCRIPT:-database/changes/004_ai_generated_good_change.sql}"
RESULTS_DIR="${RESULTS_DIR:-test-results}"

if command -v sqlcmd >/dev/null 2>&1; then
  SQLCMD_BIN="sqlcmd"
elif [ -x "/opt/mssql-tools18/bin/sqlcmd" ]; then
  SQLCMD_BIN="/opt/mssql-tools18/bin/sqlcmd"
elif [ -x "/opt/mssql-tools/bin/sqlcmd" ]; then
  SQLCMD_BIN="/opt/mssql-tools/bin/sqlcmd"
else
  echo "ERROR: sqlcmd not found. Install mssql-tools18 (or mssql-tools)." >&2
  exit 1
fi

echo "==============================================="
echo "Trust but Verify demo: running SQL test flow..."
echo "SQL Server: ${SQL_SERVER},${SQL_PORT}"
echo "Database: ${DB_NAME}"
echo "Change script: ${CHANGE_SCRIPT}"
echo "==============================================="

mkdir -p "${RESULTS_DIR}"

run_sql_file() {
  local sql_file="$1"
  local db_name="$2"

  echo "Running: ${sql_file} (db=${db_name})"
  "${SQLCMD_BIN}" \
    -S "${SQL_SERVER},${SQL_PORT}" \
    -U "${SQL_USER}" \
    -P "${SQL_PASSWORD}" \
    -C \
    -b \
    -d "${db_name}" \
    -i "${sql_file}"
}

echo ""
echo "[1/9] Waiting for SQL Server..."
./scripts/wait-for-sqlserver.sh

echo ""
echo "[2/9] Recreating database ${DB_NAME}..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d master \
  -Q "IF DB_ID('${DB_NAME}') IS NOT NULL BEGIN ALTER DATABASE [${DB_NAME}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [${DB_NAME}]; END; CREATE DATABASE [${DB_NAME}];"

echo ""
echo "[3/9] Applying schema..."
run_sql_file "database/schema/001_create_tables.sql" "${DB_NAME}"

echo ""
echo "[4/9] Applying seed data..."
run_sql_file "database/seed/002_seed_data.sql" "${DB_NAME}"

echo ""
echo "[5/9] Creating baseline stored procedure..."
run_sql_file "database/procedures/003_create_stored_procedure.sql" "${DB_NAME}"

echo ""
echo "[6/9] Capturing BEFORE results..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "tests/before.sql" \
  > "${RESULTS_DIR}/before-results.txt"

echo ""
echo "[7/9] Applying selected change script..."
run_sql_file "${CHANGE_SCRIPT}" "${DB_NAME}"

echo ""
echo "[8/9] Capturing AFTER results..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "tests/after.sql" \
  > "${RESULTS_DIR}/after-results.txt"

echo ""
echo "[9/9] Running validation checks..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "tests/validate.sql" \
  > "${RESULTS_DIR}/validation-results.txt"

echo ""
echo "Done. Test outputs:"
echo " - ${RESULTS_DIR}/before-results.txt"
echo " - ${RESULTS_DIR}/after-results.txt"
echo " - ${RESULTS_DIR}/validation-results.txt"
echo ""
echo "SUCCESS: SQL test flow completed."
