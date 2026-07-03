#!/usr/bin/env bash
set -euo pipefail

# Waits for SQL Server to accept connections.
# Defaults align with this demo, but can be overridden by environment vars.

SQL_SERVER="${SQL_SERVER:-localhost}"
SQL_PORT="${SQL_PORT:-1433}"
SQL_USER="${SQL_USER:-sa}"
SQL_PASSWORD="${SQL_PASSWORD:-REMOVED-PASSWORD}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-60}"

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

echo "Waiting for SQL Server at ${SQL_SERVER},${SQL_PORT} (timeout: ${WAIT_TIMEOUT_SECONDS}s)..."

start_time="$(date +%s)"
while true; do
  if "${SQLCMD_BIN}" \
      -S "${SQL_SERVER},${SQL_PORT}" \
      -U "${SQL_USER}" \
      -P "${SQL_PASSWORD}" \
      -C \
      -b \
      -l 1 \
      -Q "SELECT 1;" >/dev/null 2>&1; then
    echo "SQL Server is ready."
    exit 0
  fi

  now="$(date +%s)"
  elapsed="$((now - start_time))"
  if [ "${elapsed}" -ge "${WAIT_TIMEOUT_SECONDS}" ]; then
    echo "ERROR: SQL Server did not become available within ${WAIT_TIMEOUT_SECONDS} seconds." >&2
    exit 1
  fi

  sleep 1
done
