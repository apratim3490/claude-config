#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Directories to symlink
dirs=(agents rules rules-lang commands contexts hooks mcp-configs schemas scripts skills tests plugins examples guides assets)

for dir in "${dirs[@]}"; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    rm -rf "$CLAUDE_DIR/$dir"
    ln -sfn "$SCRIPT_DIR/$dir" "$CLAUDE_DIR/$dir"
    echo "Linked $dir/"
  fi
done

# Individual files to symlink
files=(CLAUDE.md settings.json package-manager.json)

for file in "${files[@]}"; do
  if [ -f "$SCRIPT_DIR/$file" ]; then
    ln -sf "$SCRIPT_DIR/$file" "$CLAUDE_DIR/$file"
    echo "Linked $file"
  fi
done

echo ""
echo "Done. Claude Code config is now synced from $SCRIPT_DIR"
echo ""
echo "Language rules (python, golang, typescript) are NOT loaded globally."
echo "To enable them for a project, run:"
echo "  $SCRIPT_DIR/enable-lang.sh <python|golang|typescript|all> /path/to/project"
