#!/usr/bin/env bash
# macOS Docker setup (checks + installs Docker). Run with:  bash 01-Install-Docker.sh
# Optional: PORT=1433 REQUIRED_MEMORY_GB=2 bash 01-Install-Docker.sh

set -uo pipefail

PORT="${PORT:-1433}"
REQUIRED_MEMORY_GB="${REQUIRED_MEMORY_GB:-2}"
FAILURES=0

section() { printf '\n\033[36m%s\033[0m\n' "$1"; }
ok()      { printf '  \033[32m[OK]\033[0m   %s\n' "$1"; }
warn()    { printf '  \033[33m[WARN]\033[0m %s\n' "$1"; }
fail()    { printf '  \033[31m[FAIL]\033[0m %s\n' "$1"; FAILURES=$((FAILURES+1)); }

docker_running() { docker info >/dev/null 2>&1; }

section "Environment"
printf '  [..]   OS: macOS %s\n' "$(sw_vers -productVersion 2>/dev/null)"

section "Docker"
if command -v docker >/dev/null 2>&1; then
    ok "$(docker --version)"
else
    echo
    echo "Docker not found."
    if ! command -v brew >/dev/null 2>&1; then
        echo "  Homebrew is also not installed."
        echo "  This will install Homebrew, then Docker Desktop."
    else
        echo "  This will install Docker Desktop via Homebrew."
    fi
    read -r -p "Proceed? (Y/N): " ANSWER
    if [[ ! "$ANSWER" =~ ^[Yy] ]]; then
        fail "Install cancelled"
    else
        if ! command -v brew >/dev/null 2>&1; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
        fi
        if command -v brew >/dev/null 2>&1; then
            echo "Installing Docker Desktop via Homebrew (you may be prompted for your password)..."
            brew install --cask docker
            export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
            if command -v docker >/dev/null 2>&1; then
                ok "Docker installed via Homebrew"
            else
                fail "Docker install failed. Install manually: https://docker.com/products/docker-desktop"
            fi
        else
            fail "Homebrew install failed. Install manually from https://brew.sh, then re-run"
        fi
    fi
fi

section "Docker Daemon"
if ! command -v docker >/dev/null 2>&1; then
    warn "Skipping - Docker not found"
    RUNNING=0
elif docker_running; then
    ok "Daemon running"
    RUNNING=1
else
    printf '  [..]   Starting Docker Desktop...'
    [ -d /Applications/Docker.app ] && open -a Docker
    WAITED=0
    while ! docker_running && [ "$WAITED" -lt 180 ]; do
        sleep 5; WAITED=$((WAITED+5)); printf '.'
    done
    echo
    if docker_running; then ok "Started (${WAITED}s)"; RUNNING=1
    else fail "Failed to start after 180s"; RUNNING=0; fi
fi

section "Port $PORT"
if lsof -iTCP:"$PORT" -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    warn "Port $PORT in use"
else
    ok "Available"
fi

section "Memory"
PAGE_SIZE=$(sysctl -n hw.pagesize 2>/dev/null)
VM=$(vm_stat 2>/dev/null)
if [ -n "$VM" ] && [ -n "$PAGE_SIZE" ]; then
    FREE=$(echo "$VM"        | awk '/Pages free/        {gsub(/\./,"",$3); print $3}')
    INACTIVE=$(echo "$VM"    | awk '/Pages inactive/    {gsub(/\./,"",$3); print $3}')
    SPECULATIVE=$(echo "$VM" | awk '/Pages speculative/ {gsub(/\./,"",$3); print $3}')
    AVAIL_PAGES=$((FREE + INACTIVE + SPECULATIVE))
    AVAIL_GB=$(echo "scale=1; $AVAIL_PAGES * $PAGE_SIZE / 1073741824" | bc)
    if (( $(echo "$AVAIL_GB < $REQUIRED_MEMORY_GB" | bc -l) )); then
        fail "${AVAIL_GB}GB free (need ${REQUIRED_MEMORY_GB}GB)"
    else
        ok "${AVAIL_GB}GB available"
    fi
else
    warn "Could not check memory"
fi

section "Docker Hub"
if [ "${RUNNING:-0}" -eq 1 ]; then
    if ping -c 1 -t 3 hub.docker.com >/dev/null 2>&1 || nc -z -w 3 hub.docker.com 443 >/dev/null 2>&1; then
        ok "Reachable"
    else
        warn "Not reachable (pulls may fail)"
    fi
else
    warn "Skipping - Docker not running"
fi

section "Summary"
if [ "$FAILURES" -eq 0 ]; then
    printf '  \033[32m[OK]\033[0m   Docker ready\n'
else
    printf '  \033[31m[FAIL]\033[0m %s check(s) failed\n' "$FAILURES"
fi
exit "$FAILURES"
