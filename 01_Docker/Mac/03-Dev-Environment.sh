#!/usr/bin/env bash
# dev.sh — spin up SQL Server + dba-garage for local development
# Ctrl+C (or SIGTERM) stops the app and tears down the container.
#
# Mirrors the defaults in the root Makefile.
# Override via env vars:
#   CONTAINER=pass-test PORT=1433 SA_PASSWORD='...' DB_NAME=PlayGround APP_PORT=8080 bash dev.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [ -f "${ENV_FILE}" ]; then
    set -a
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    set +a
fi

# ── Config (env-var defaults, all overridable via flags below) ────────────────
CONTAINER="${CONTAINER:-pass-test}"
PORT="${PORT:-1433}"
SA_USERNAME="${SA_USERNAME:-sa}"
SA_PASSWORD="${SA_PASSWORD:-}"
DB_NAME="${DB_NAME:-AdventureWorks2022}"
IMAGE="${IMAGE:-mcr.microsoft.com/mssql/server:2022-latest}"
APP_PORT="${APP_PORT:-8080}"

# UI prefill — default to the SQL Server we're about to start
UI_HOST=""          # derived after PORT is known (see below)
UI_USERNAME="$SA_USERNAME"
UI_PASSWORD="$SA_PASSWORD"
UI_OUTPUT_PATH="dba-garage-reports"

# ── Argument parsing ──────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: bash dev.sh [options]

Options:
  --host         HOST   Host shown in the UI  (default: localhost,PORT)
  --username     USER   Username shown in the UI  (default: sa)
  --password     PASS   Password shown in the UI  (default: SA_PASSWORD)
  --output-path  PATH   Output path shown in the UI  (default: ./)
  --sql-port     PORT   SQL Server port  (default: 1433)
  --app-port     PORT   Web UI port  (default: 8080)
  --container    NAME   Docker container name  (default: pass-test)
  -h, --help            Show this help
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)        UI_HOST="$2";        shift 2 ;;
        --username)    UI_USERNAME="$2";    shift 2 ;;
        --password)    UI_PASSWORD="$2"; SA_PASSWORD="$2"; shift 2 ;;
        --output-path) UI_OUTPUT_PATH="$2"; shift 2 ;;
        --sql-port)    PORT="$2";           shift 2 ;;
        --app-port)    APP_PORT="$2";       shift 2 ;;
        --container)   CONTAINER="$2";      shift 2 ;;
        -h|--help)    usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

# Default host uses the resolved PORT
: "${UI_HOST:=localhost,$PORT}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$PROJECT_ROOT/src"

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

# ── Cleanup (runs on Ctrl+C, SIGTERM, or any exit) ────────────────────────────
APP_PID=""
CLEANED=0
cleanup() {
    [ "$CLEANED" -eq 1 ] && return
    CLEANED=1
    printf '\n'
    section "Shutting down"
    if [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
        kill "$APP_PID" 2>/dev/null
        wait "$APP_PID" 2>/dev/null || true
        ok "App stopped"
    fi
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
        info "Container '$CONTAINER' left running (use 'make stop' to remove)"
    fi
}
trap cleanup INT TERM EXIT

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

# ── Check/Restore AdventureWorks2022 ───────────────────────────────────────
section "Database Check"

# Check if database already exists and has data
DB_EXISTS=$(run_sqlcmd -Q "SELECT 1 FROM sys.databases WHERE name = 'AdventureWorks2022'" 2>/dev/null | grep -c 1 || echo 0)
TABLE_COUNT=0
if [ "$DB_EXISTS" -eq 1 ]; then
    TABLE_COUNT=$(run_sqlcmd -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM AdventureWorks2022.sys.tables" 2>/dev/null | tail -1 | tr -d '[:space:]' || echo 0)
fi

if [ "$DB_EXISTS" -eq 1 ] && [ "$TABLE_COUNT" -gt 0 ]; then
    ok "Database 'AdventureWorks2022' exists with $TABLE_COUNT tables — skipping restore"
elif [ "$DB_EXISTS" -eq 1 ] && [ "$TABLE_COUNT" -eq 0 ]; then
    info "Database exists but is empty — will restore from backup"
    # Drop empty database so we can restore
    run_sqlcmd -Q "DROP DATABASE [AdventureWorks2022];" >/dev/null 2>&1
else
    info "Database not found — will restore from backup"
fi

# Restore if database doesn't exist or was empty (dropped above)
if ! run_sqlcmd -Q "SELECT 1 FROM sys.databases WHERE name = 'AdventureWorks2022'" 2>/dev/null | grep -q 1; then
    # Database doesn't exist or is empty — restore it
    section "Restoring AdventureWorks2022"

    # Download backup directly into the container
    BACKUP_FILE="AdventureWorks2022.bak"
    BACKUP_URL="https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak"

    info "Downloading AdventureWorks2022 directly into container (~175MB)..."

    # Install curl in container if needed, then download directly into container
    docker exec "$CONTAINER" bash -c "
        if ! command -v curl >/dev/null 2>&1; then
            apt-get update >/dev/null 2>&1 && apt-get install -y curl >/dev/null 2>&1
        fi
        cd /var/opt/mssql/data && curl -L -o '$BACKUP_FILE' '$BACKUP_URL' 2>/dev/null || echo 'DOWNLOAD_FAILED'
    " > /tmp/download_result.txt 2>/dev/null

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

# ── Build ─────────────────────────────────────────────────────────────────────
section "Building App"
if command -v go >/dev/null 2>&1; then
    info "Building natively with local Go..."
    mkdir -p "$PROJECT_ROOT/build"
    (cd "$APP_DIR" && make internal/web/static/dist && go build -ldflags="-s -w" -o "$PROJECT_ROOT/build/dba-garage" .) || fail "Build failed"
else
    info "Building with Docker (no local Go found)..."
    (cd "$PROJECT_ROOT" && make docker-build) || fail "Build failed"
    if [[ "$(file "$PROJECT_ROOT/build/dba-garage" 2>/dev/null)" == *ELF* ]]; then
        fail "Docker produced a Linux binary — cannot run on macOS. Please install Go: brew install go"
    fi
fi
ok "Binary ready at $PROJECT_ROOT/build/dba-garage"

# ── Run ───────────────────────────────────────────────────────────────────────
section "Starting dba-garage"
info "http://localhost:$APP_PORT"
info "Pre-filled connection: $UI_HOST  /  $UI_USERNAME  →  $UI_OUTPUT_PATH"
printf '\n  Press Ctrl+C to stop and tear down.\n\n'

"$PROJECT_ROOT/build/dba-garage" serve \
    --port                "$APP_PORT" \
    --reports-dir         "dba-garage-reports" \
    --prefill-host        "$UI_HOST" \
    --prefill-username    "$UI_USERNAME" \
    --prefill-password    "$UI_PASSWORD" \
    --prefill-output-path "$UI_OUTPUT_PATH" &
APP_PID=$!

wait "$APP_PID" 2>/dev/null || true
