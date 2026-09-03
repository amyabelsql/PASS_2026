#!/usr/bin/env bash
# test.sh — verify SQL Server container is running and accessible
#
# Usage: bash test.sh [options]
#
# Options:
#   --sql-port     PORT   SQL Server port  (default: 1433)
#   --password     PASS   SA password  (default: SA_PASSWORD from .env or shell)
#   --container    NAME   Docker container name  (default: pass-test)
#   -h, --help            Show this help

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    set +a
fi

# ── Config ────────────────────────────────────────────────────────────────────
CONTAINER="${CONTAINER:-pass-test}"
PORT="${PORT:-1433}"
SA_USERNAME="${SA_USERNAME:-sa}"
SA_PASSWORD="${SA_PASSWORD:-}"
DB_NAME="${DB_NAME:-AdventureWorks2022}"

# ── Argument parsing ──────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: bash test.sh [options]

Options:
  --sql-port     PORT   SQL Server port  (default: 1433)
  --password     PASS   SA password  (default: SA_PASSWORD from .env or shell)
  --container    NAME   Docker container name  (default: pass-test)
  -h, --help            Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sql-port)  PORT="$2";        shift 2 ;;
        --password)  SA_PASSWORD="$2"; shift 2 ;;
        --container) CONTAINER="$2";   shift 2 ;;
        -h|--help)    usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

# ── Platform detection ────────────────────────────────────────────────────────
case "$(uname -s)" in
  Darwin) ENV_DIR="$SCRIPT_DIR" ;;
  *)      ENV_DIR="$SCRIPT_DIR" ;;  # Linux uses same Docker setup
esac

# ── Helpers ───────────────────────────────────────────────────────────────────
section() { printf '\n\033[1;36m══  %s\033[0m\n' "$1"; }
ok()      { printf '  \033[32m✔\033[0m  %s\n' "$1"; }
info()    { printf '  \033[2m→\033[0m  %s\n' "$1"; }
warn()    { printf '  \033[33m⚠\033[0m  %s\n' "$1"; }
fail()    { printf '\n  \033[31m✘  %s\033[0m\n' "$1"; }

[ -n "$SA_PASSWORD" ] || { fail "SA_PASSWORD is not set. Copy .env.example to .env or pass --password."; exit 1; }

run_sqlcmd() {
    docker exec -i "$CONTAINER" /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U "$SA_USERNAME" -P "$SA_PASSWORD" "$@" 2>/dev/null \
        || docker exec -i "$CONTAINER" /opt/mssql-tools/bin/sqlcmd       -S localhost -U "$SA_USERNAME" -P "$SA_PASSWORD" "$@" 2>/dev/null
}

EXIT_CODE=0

# ── Test 1: Docker running ───────────────────────────────────────────────────
section "Test 1: Docker Daemon"

if ! command -v docker >/dev/null 2>&1; then
    fail "Docker not found"
    info "Install Docker: see $ENV_DIR/01-Install-Docker.sh"
    echo ""
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    fail "Docker daemon not running"
    info "Start Docker Desktop and try again"
    echo ""
    exit 1
fi

ok "Docker is running"

# ── Test 2: Container exists ─────────────────────────────────────────────────
section "Test 2: Container '$CONTAINER'"

if ! docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
    fail "Container '$CONTAINER' does not exist"
    echo ""
    info "Start the SQL Server container:"
    info "  make start"
    echo ""
    exit 1
fi

# ── Test 3: Container is running ─────────────────────────────────────────────
section "Test 3: Container Status"

if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
    fail "Container '$CONTAINER' is stopped"
    warn "The container exists but is not running"
    echo ""
    info "To start it, run:"
    info "  docker start $CONTAINER"
    echo ""
    info "Or recreate it with:"
    info "  bash start.sh"
    echo ""
    exit 1
fi

ok "Container '$CONTAINER' is running"

# ── Test 4: SQL Server responsive ────────────────────────────────────────────
section "Test 4: SQL Server Connection"

info "Testing connection to localhost:$PORT..."

if ! run_sqlcmd -Q "SELECT 1" >/dev/null 2>&1; then
    fail "Cannot connect to SQL Server"
    warn "The container is running but SQL Server is not responding"
    echo ""
    info "Possible causes:"
    info "  - SQL Server is still starting up (wait 30-60 seconds)"
    info "  - Wrong SA password"
    info "  - Port conflict (another service using port $PORT)"
    echo ""
    info "To check container logs:"
    info "  docker logs $CONTAINER"
    echo ""
    info "To recreate the container:"
    info "  bash stop.sh && bash start.sh"
    echo ""
    exit 1
fi

ok "SQL Server is responding"

# ── Test 5: Database exists ──────────────────────────────────────────────────
section "Test 5: Database Check"

DB_COUNT=$(run_sqlcmd -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'AdventureWorks2022'" 2>/dev/null | tail -1 | tr -d '[:space:]')

if [[ "$DB_COUNT" == "1" ]]; then
    ok "Database 'AdventureWorks2022' exists"
    
    # Check if it has data (tables)
    TABLE_COUNT=$(run_sqlcmd -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM AdventureWorks2022.sys.tables" 2>/dev/null | tail -1 | tr -d '[:space:]')
    if [[ "$TABLE_COUNT" -gt 0 ]]; then
        info "Database has $TABLE_COUNT tables (restored from backup)"
    else
        fail "Database is EMPTY — AdventureWorks2022 backup was not restored"
        echo ""
        info "To restore the database, run:"
        info "  make setup    # Reset container and restore AdventureWorks2022"
        EXIT_CODE=1
    fi
else
    fail "Database 'AdventureWorks2022' not found"
    echo ""
    info "The database should have been created."
    info "To create container and restore database, run:"
    info "  make setup"
    EXIT_CODE=1
fi

# ── Summary ────────────────────────────────────────────────────────────────────
section "Test Summary"

if [[ $EXIT_CODE -eq 0 ]]; then
    ok "All tests passed!"
    echo ""
    info "Connection details:"
    info "  Server:   localhost,$PORT"
    info "  Database: AdventureWorks2022"
    info "  User:     $SA_USERNAME"
    echo ""
else
    warn "Some tests failed. Check the errors above."
fi

exit $EXIT_CODE
