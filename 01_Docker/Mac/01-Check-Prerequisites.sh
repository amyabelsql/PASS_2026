#!/usr/bin/env bash
# check.sh — verify your system can run DBA Garage
#
# Works on macOS and Linux. On Windows, use PowerShell: .\1-Check-Prerequisites.ps1

set -uo pipefail

section() { printf '\n\033[1;36m══  %s\033[0m\n' "$1"; }
ok()      { printf '  \033[32m✔\033[0m  %s\n' "$1"; }
info()    { printf '  \033[2m→\033[0m  %s\n' "$1"; }
warn()    { printf '  \033[33m⚠\033[0m  %s\n' "$1"; }
fail()    { printf '  \033[31m✘\033[0m  %s\n' "$1"; }

EXIT_CODE=0
ERRORS=0

section "DBA Garage — System Check"

# Docker
docker --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ok "Docker installed"
    docker info >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        ok "Docker daemon running"
    else
        fail "Docker daemon not running — start Docker Desktop"
        ERRORS=$((ERRORS+1))
    fi
else
    fail "Docker not found — install Docker Desktop"
    ERRORS=$((ERRORS+1))
fi

# Git
git --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ok "Git installed"
else
    fail "Git not found — install from git-scm.com"
    ERRORS=$((ERRORS+1))
fi

# Make
make --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ok "Make installed"
else
    fail "Make not found — install via Xcode CLI tools (macOS: xcode-select --install) or build-essential (Linux)"
    ERRORS=$((ERRORS+1))
fi

# Go (needed for building the app)
go version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    ok "Go installed"
else
    fail "Go not found — install from https://go.dev/dl/"
    ERRORS=$((ERRORS+1))
fi

# Disk space
if [ "$(uname -s)" = "Darwin" ]; then
    FREE_GB=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
else
    FREE_GB=$(df --block-size=1G / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
fi

if [ "$FREE_GB" -ge 10 ] || [ -z "$FREE_GB" ]; then
    ok "Disk space sufficient (10GB+ recommended)"
else
    warn "Disk space: ${FREE_GB}GB free (10GB+ recommended)"
fi

section "Summary"

if [ $ERRORS -eq 0 ]; then
    ok "All checks passed! Run 'make start' to begin."
else
    fail "$ERRORS check(s) failed. Fix above and run again."
    EXIT_CODE=1
fi

exit $EXIT_CODE
