#!/usr/bin/env bash
# Daily sync: pull latest config from GitHub and re-run setup.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cross-platform log directory
case "$(uname -s)" in
  Darwin) LOG_DIR="$HOME/Library/Logs" ;;
  *)      LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-config" ;;
esac
LOG_FILE="$LOG_DIR/claude-config-sync.log"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" >> "$LOG_FILE"
}

log "--- sync started ---"

cd "$SCRIPT_DIR"

# Abort if there are local uncommitted changes
if ! git diff --quiet HEAD 2>/dev/null; then
  log "SKIPPED: local uncommitted changes detected. Commit or stash first."
  exit 1
fi

if git pull --ff-only origin main >> "$LOG_FILE" 2>&1; then
  log "git pull succeeded"
else
  log "ERROR: git pull failed (likely diverged). Resolve manually."
  exit 1
fi

"$SCRIPT_DIR/setup.sh" >> "$LOG_FILE" 2>&1
log "--- sync complete ---"
