#!/usr/bin/env bash
# macOS Docker removal. Run with:  bash Remove-Docker.sh

set -uo pipefail

section() { printf '\n\033[36m%s\033[0m\n' "$1"; }
ok()      { printf '  \033[32m[OK]\033[0m   %s\n' "$1"; }
info()    { printf '  [..]   %s\n' "$1"; }
warn()    { printf '  \033[33m[WARN]\033[0m %s\n' "$1"; }

section "Confirm"
echo "This will quit and uninstall Docker Desktop and remove its config files."
read -r -p "Proceed? (Y/N): " ANSWER
if [[ ! "$ANSWER" =~ ^[Yy] ]]; then
    info "Cancelled"
    exit 0
fi

section "Stopping Docker Processes"
osascript -e 'quit app "Docker"' >/dev/null 2>&1 || true
pkill -f 'Docker Desktop' >/dev/null 2>&1 || true
pkill -x 'com.docker.backend' >/dev/null 2>&1 || true
ok "Processes stopped"

section "Uninstalling Docker Desktop"
if command -v brew >/dev/null 2>&1 && brew list --cask docker >/dev/null 2>&1; then
    brew uninstall --cask docker
    ok "Uninstalled via Homebrew"
elif [ -x "/Applications/Docker.app/Contents/MacOS/uninstall" ]; then
    info "Running Docker's built-in uninstaller (may prompt for your password)..."
    sudo /Applications/Docker.app/Contents/MacOS/uninstall
    ok "Uninstaller completed"
else
    info "Docker not installed via Homebrew; removing app bundle directly"
    sudo rm -rf /Applications/Docker.app
fi

section "Removing Leftover Files"
PATHS=(
    "$HOME/.docker"
    "$HOME/Library/Group Containers/group.com.docker"
    "$HOME/Library/Containers/com.docker.docker"
    "$HOME/Library/Application Support/Docker Desktop"
    "$HOME/Library/Preferences/com.docker.docker.plist"
    "$HOME/Library/Logs/Docker Desktop"
    "$HOME/Library/Caches/com.docker.docker"
)
for p in "${PATHS[@]}"; do
    if [ -e "$p" ]; then
        rm -rf "$p"
        info "Removed: $p"
    fi
done

section "Removing CLI Symlinks"
for bin in docker docker-compose docker-credential-desktop docker-credential-ecr-login docker-credential-osxkeychain hub-tool kubectl.docker; do
    for dir in /usr/local/bin /opt/homebrew/bin; do
        if [ -L "$dir/$bin" ] || [ -e "$dir/$bin" ]; then
            sudo rm -f "$dir/$bin"
            info "Removed: $dir/$bin"
        fi
    done
done

section "Verification"
if command -v docker >/dev/null 2>&1; then
    warn "docker still on PATH"
else
    ok "docker removed from PATH"
fi

if [ -d /Applications/Docker.app ]; then
    warn "/Applications/Docker.app still exists"
else
    ok "/Applications/Docker.app removed"
fi
