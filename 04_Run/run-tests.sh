#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [ -f "${ENV_FILE}" ]; then
  set -a
  # shellcheck disable=SC1090
  . "${ENV_FILE}"
  set +a
fi

SQL_SERVER="${SQL_SERVER:-localhost}"
SQL_PORT="${SQL_PORT:-1433}"
SQL_USER="${SQL_USER:-sa}"
SQL_PASSWORD="${SQL_PASSWORD:-${SA_PASSWORD:-}}"
DB_NAME="${DB_NAME:-GitDemoDb}"
CHANGE_SCRIPT="${CHANGE_SCRIPT:-${REPO_ROOT}/02_Database/changes/004_ai_generated_good_change.sql}"
RESULTS_DIR="${RESULTS_DIR:-${REPO_ROOT}/test-results}"

if [ -z "${SQL_PASSWORD}" ]; then
  echo "ERROR: SQL_PASSWORD is not set. Copy .env.example to .env or export SQL_PASSWORD." >&2
  exit 1
fi

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

echo "================================================"
echo "Trust but Verify demo: running SQL test flow..."
echo "SQL Server: ${SQL_SERVER},${SQL_PORT}"
echo "Database: ${DB_NAME}"
echo "Change script: ${CHANGE_SCRIPT}"
echo "================================================"

mkdir -p "${RESULTS_DIR}"

echo "[1/9] Waiting for SQL Server..."
"${REPO_ROOT}/01_Docker/01_wait-for-sqlserver.sh"

echo "[2/9] Recreating database ${DB_NAME}..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d master \
  -Q "IF DB_ID('${DB_NAME}') IS NOT NULL BEGIN ALTER DATABASE [${DB_NAME}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [${DB_NAME}]; END; CREATE DATABASE [${DB_NAME}];"

echo "[3/9] Applying schema..."
run_sql_file "${REPO_ROOT}/02_Database/schema/001_create_tables.sql" "${DB_NAME}"

echo "[4/9] Applying seed data..."
run_sql_file "${REPO_ROOT}/02_Database/seed/002_seed_data.sql" "${DB_NAME}"

echo "[5/9] Creating baseline stored procedure..."
run_sql_file "${REPO_ROOT}/02_Database/procedures/003_create_stored_procedure.sql" "${DB_NAME}"

echo "[6/9] Capturing BEFORE results..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "${REPO_ROOT}/03_Tests/before.sql" \
  > "${RESULTS_DIR}/before-results.txt"

echo "[7/9] Applying selected change script..."
run_sql_file "${CHANGE_SCRIPT}" "${DB_NAME}"

echo "[8/9] Capturing AFTER results..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "${REPO_ROOT}/03_Tests/after.sql" \
  > "${RESULTS_DIR}/after-results.txt"

echo "[9/9] Running validation checks..."
"${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -d "${DB_NAME}" \
  -i "${REPO_ROOT}/03_Tests/validate.sql" \
  > "${RESULTS_DIR}/validation-results.txt"

echo "Done."
