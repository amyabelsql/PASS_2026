#!/usr/bin/env bash
# remove.sh — Remove Docker and SQL Server container on macOS
#
# Runs the platform-specific removal script to clean up Docker
# and optionally uninstall it.
#
# Usage:
#   bash Docker/remove.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOVE_SCRIPT="$SCRIPT_DIR/06-Remove-Docker.sh"

if [ ! -f "$REMOVE_SCRIPT" ]; then
    echo "Error: Remove script not found at: $REMOVE_SCRIPT" >&2
    exit 1
fi

echo ""
echo "WARNING: This will quit and uninstall Docker Desktop from your system."
read -r -p "Continue? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    bash "$REMOVE_SCRIPT"
    exit $?
else
    echo "Cancelled."
    exit 0
fi
