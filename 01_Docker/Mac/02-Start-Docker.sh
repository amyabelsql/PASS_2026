#!/usr/bin/env bash
# start.sh — start or create the SQL Server Docker container only
#
# Usage: bash start.sh [options]
#
# Options:
#   --sql-port     PORT   SQL Server port  (default: 1433)
#   --password     PASS   SA password  (default: SA_PASSWORD from .env or shell)
#   --container    NAME   Docker container name  (default: pass-test)
#   --no-restore          Only check DB status, don't restore
#   -h, --help            Show this help
#
# Override via env vars (see root Makefile for the canonical defaults):
#   CONTAINER=pass-test PORT=1433 SA_PASSWORD='...' bash start.sh

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
IMAGE="${IMAGE:-mcr.microsoft.com/mssql/server:2022-latest}"
NO_RESTORE="${NO_RESTORE:-0}"

# ── Argument parsing ──────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: bash start.sh [options]

Options:
  --sql-port     PORT   SQL Server port  (default: 1433)
  --password     PASS   SA password  (default: SA_PASSWORD from .env or shell)
  --container    NAME   Docker container name  (default: pass-test)
  --no-restore          Only check DB status, don't restore
  -h, --help            Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sql-port)  PORT="$2";        shift 2 ;;
        --password)  SA_PASSWORD="$2"; shift 2 ;;
        --container) CONTAINER="$2";   shift 2 ;;
        --no-restore) NO_RESTORE=1;    shift ;;
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
fail()    { printf '\n  \033[31m✘  %s\033[0m\n' "$1"; exit 1; }

[ -n "$SA_PASSWORD" ] || fail "SA_PASSWORD is not set. Copy .env.example to .env or pass --password."

run_sqlcmd() {
    docker exec -i "$CONTAINER" /opt/mssql-tools18/bin/sqlcmd -No -S localhost -U "$SA_USERNAME" -P "$SA_PASSWORD" "$@" 2>/dev/null \
        || docker exec -i "$CONTAINER" /opt/mssql-tools/bin/sqlcmd       -S localhost -U "$SA_USERNAME" -P "$SA_PASSWORD" "$@" 2>/dev/null
}

# ── Prerequisites ─────────────────────────────────────────────────────────────
section "Prerequisites"
info "Environment: $ENV_DIR"

command -v docker >/dev/null 2>&1 || fail "Docker not found — see $ENV_DIR/01-Install-Docker.sh"

# Check if Docker is running, auto-start on macOS if not
if ! docker info >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
        # Detect which Docker provider is installed (avoid conflicts)
        HAS_DOCKER_DESKTOP=0
        HAS_ORBSTACK=0
        [ -d "/Applications/Docker.app" ] && HAS_DOCKER_DESKTOP=1
        [ -d "$HOME/Applications/Docker.app" ] && HAS_DOCKER_DESKTOP=1
        [ -d "/Applications/OrbStack.app" ] && HAS_ORBSTACK=1

        # Auto-start only Docker Desktop (safer, avoids OrbStack integrity issues)
        if [ "$HAS_DOCKER_DESKTOP" -eq 1 ]; then
            info "Starting Docker Desktop..."
            if [ -d "/Applications/Docker.app" ]; then
                open -a Docker
            else
                open -a Docker "$HOME/Applications/Docker.app"
            fi
        else
            # No Docker Desktop found - tell user to start their Docker manually
            fail "Docker is not running. Please start Docker Desktop or your Docker provider manually."
        fi
    else
        fail "Docker daemon not running — please start Docker manually"
    fi

    # Wait for Docker to become ready
    info "Waiting for Docker to start..."
    WAITED=0
    printf '  → '
    until docker info >/dev/null 2>&1; do
        [ "$WAITED" -ge 60 ] && echo && fail "Docker did not start after 60s — please check Docker Desktop"
        sleep 2; WAITED=$((WAITED+2)); printf '.'
    done
    echo
    ok "Docker is now running (${WAITED}s)"
else
    ok "Docker is running"
fi

# ── SQL Server container ──────────────────────────────────────────────────────
section "SQL Server"

# Check if container already exists and reuse it
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
        ok "Container '$CONTAINER' already running — using existing"
    else
        info "Starting existing container '$CONTAINER'"
        docker start "$CONTAINER" >/dev/null || fail "Failed to start container"
        ok "Container '$CONTAINER' started"
    fi
else
    info "Creating new SQL Server container..."
    info "Pulling $IMAGE"
    docker pull "$IMAGE" || fail "Could not pull image"
    
    docker run -d \
        --name "$CONTAINER" \
        -e "ACCEPT_EULA=Y" \
        -e "MSSQL_SA_PASSWORD=$SA_PASSWORD" \
        -p "$PORT:1433" \
        "$IMAGE" >/dev/null || fail "Failed to start container"
    ok "Container '$CONTAINER' created and started"
fi

section "Waiting for SQL Server"
WAITED=0
printf '  → '
until run_sqlcmd -Q "SELECT 1" >/dev/null 2>&1; do
    [ "$WAITED" -ge 90 ] && echo && fail "SQL Server did not become ready after 90s"
    sleep 3; WAITED=$((WAITED+3)); printf '.'
done
echo
ok "SQL Server ready (${WAITED}s)"

# ── Restore AdventureWorks2022 ────────────────────────────────────────────────
section "Restoring AdventureWorks2022"

# Check if database already exists and has data
DB_CHECK=$(run_sqlcmd -Q "SELECT 1 FROM sys.databases WHERE name = 'AdventureWorks2022'" 2>/dev/null)
DB_EXISTS=0
if echo "$DB_CHECK" | grep -q "1"; then
    DB_EXISTS=1
fi
TABLE_COUNT=0
if [ "$DB_EXISTS" -eq 1 ]; then
    # Get table count - handle SQL output with potential empty lines
    TABLE_OUTPUT=$(run_sqlcmd -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM AdventureWorks2022.sys.tables" 2>/dev/null)
    # Extract just the number from the last non-empty line
    TABLE_COUNT=$(echo "$TABLE_OUTPUT" | grep -Eo '[0-9]+' | tail -1)
    # Default to 0 if empty or not a number
    if [ -z "$TABLE_COUNT" ]; then
        TABLE_COUNT=0
    fi
fi

if [ "$DB_EXISTS" -eq 1 ] && [ "$TABLE_COUNT" -gt 0 ]; then
    ok "Database 'AdventureWorks2022' exists with $TABLE_COUNT tables"
elif [ "$DB_EXISTS" -eq 1 ] && [ "$TABLE_COUNT" -eq 0 ]; then
    if [ "$NO_RESTORE" -eq 1 ]; then
        warn "Database exists but is empty — run 'make setup' to restore AdventureWorks2022"
    else
        info "Database exists but is empty — will restore from backup"
        # Drop empty database so we can restore
        run_sqlcmd -Q "DROP DATABASE [AdventureWorks2022];" >/dev/null 2>&1
        sleep 2
    fi
else
    if [ "$NO_RESTORE" -eq 1 ]; then
        warn "Database 'AdventureWorks2022' not found — run 'make setup' to create and restore"
    else
        info "Database not found — will restore from backup"
    fi
fi

# Restore if database doesn't exist or was empty (dropped above) and NO_RESTORE is not set
if [ "$NO_RESTORE" -ne 1 ] && ! run_sqlcmd -Q "SELECT 1 FROM sys.databases WHERE name = 'AdventureWorks2022'" 2>/dev/null | grep -q 1; then
    # Download backup directly into the container
    BACKUP_FILE="AdventureWorks2022.bak"
    BACKUP_URL="https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak"

    info "Downloading AdventureWorks2022 directly into container (~175MB)..."
    info "URL: $BACKUP_URL"

    # First ensure curl is installed (SQL Server container doesn't have it by default)
    info "Installing curl in container..."
    docker exec -u root "$CONTAINER" bash -c "apt-get update -qq && apt-get install -y -qq curl" || warn "Could not install curl, trying anyway..."

    # Download the backup file with progress
    info "Starting download..."
    docker exec "$CONTAINER" curl -fsSL --progress-bar -o "/var/opt/mssql/data/$BACKUP_FILE" "$BACKUP_URL"

    # Check download result and file size
    if docker exec "$CONTAINER" test -f "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null; then
        FILE_SIZE=$(docker exec "$CONTAINER" stat -c%s "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null || echo 0)
        FILE_SIZE_MB=$((FILE_SIZE / 1048576))

        if [ "$FILE_SIZE_MB" -lt 100 ]; then
            warn "Downloaded file is only ${FILE_SIZE_MB}MB (expected ~175MB)"
            warn "Removing incomplete download..."
            docker exec "$CONTAINER" rm -f "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null
        fi
    fi

    # Restore if download succeeded
    if docker exec "$CONTAINER" test -f "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null; then
        FILE_SIZE=$(docker exec "$CONTAINER" stat -c%s "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null || echo 0)
        FILE_SIZE_MB=$((FILE_SIZE / 1048576))

        info "Verified: $BACKUP_FILE (${FILE_SIZE_MB}MB)"
        info "Restoring database (this may take a minute)..."
        if run_sqlcmd -Q "RESTORE DATABASE [AdventureWorks2022] FROM DISK = '/var/opt/mssql/data/$BACKUP_FILE' WITH MOVE 'AdventureWorks2022' TO '/var/opt/mssql/data/AdventureWorks2022.mdf', MOVE 'AdventureWorks2022_log' TO '/var/opt/mssql/data/AdventureWorks2022_log.ldf', REPLACE" 2>/dev/null; then
            ok "Database 'AdventureWorks2022' restored successfully"
            # Clean up backup file after successful restore to save space
            docker exec "$CONTAINER" rm -f "/var/opt/mssql/data/$BACKUP_FILE" 2>/dev/null
        else
            warn "Restore failed - creating empty database instead"
            run_sqlcmd -Q "CREATE DATABASE [AdventureWorks2022];" >/dev/null 2>&1
            ok "Empty database 'AdventureWorks2022' created"
        fi
    else
        info "Backup download failed - creating empty database"
        run_sqlcmd -Q "CREATE DATABASE [AdventureWorks2022];" >/dev/null 2>&1
        ok "Empty database 'AdventureWorks2022' created"
    fi
fi

section "Done"
info "SQL Server is running at: localhost,$PORT"
info "Container: $CONTAINER"
info "Database:  $DB_NAME (create/restore if needed)"
info "User:      $SA_USERNAME"
echo
