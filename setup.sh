#!/bin/bash
# Symlinks CLAUDE.md from this repo into ~/.claude/
# Run this after cloning on a new machine.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude"

if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
    echo "Backing up existing CLAUDE.md to CLAUDE.md.bak"
    mv "$TARGET" "$TARGET.bak"
fi

ln -sf "$SCRIPT_DIR/CLAUDE.md" "$TARGET"
echo "Symlinked $TARGET -> $SCRIPT_DIR/CLAUDE.md"
