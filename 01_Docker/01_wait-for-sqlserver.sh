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
SQLCMD_TIMEOUT="${SQLCMD_TIMEOUT:-90}"

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

echo "Waiting for SQL Server at ${SQL_SERVER},${SQL_PORT}..."

elapsed=0
until "${SQLCMD_BIN}" \
  -S "${SQL_SERVER},${SQL_PORT}" \
  -U "${SQL_USER}" \
  -P "${SQL_PASSWORD}" \
  -C \
  -b \
  -Q "SELECT 1" >/dev/null 2>&1; do
  if [ "${elapsed}" -ge "${SQLCMD_TIMEOUT}" ]; then
    echo "ERROR: SQL Server did not become ready after ${SQLCMD_TIMEOUT}s." >&2
    exit 1
  fi

  sleep 3
  elapsed=$((elapsed + 3))
done

echo "SQL Server is ready."
