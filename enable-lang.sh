#!/usr/bin/env bash
set -euo pipefail

# Enable language-specific Claude Code rules for a project.
# Usage: enable-lang.sh <language> [project-dir]
#   language: python | golang | typescript | all
#   project-dir: defaults to current directory
#
# Creates .claude/rules/<lang>/ symlinks pointing to the shared
# rule definitions in ~/.claude/rules-lang/<lang>/. This keeps
# language rules out of global context and loads them only when
# Claude Code opens the project.

LANG_DIR="$HOME/.claude/rules-lang"

usage() {
  echo "Usage: $(basename "$0") <python|golang|typescript|all> [project-dir]"
  exit 1
}

[ $# -lt 1 ] && usage

LANG="$1"
PROJECT_DIR="${2:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
RULES_DIR="$PROJECT_DIR/.claude/rules"

enable_lang() {
  local lang="$1"
  if [ ! -d "$LANG_DIR/$lang" ]; then
    echo "Error: $LANG_DIR/$lang does not exist. Run setup.sh first."
    exit 1
  fi
  mkdir -p "$RULES_DIR"
  ln -sfn "$LANG_DIR/$lang" "$RULES_DIR/$lang"
  echo "Enabled $lang rules for $PROJECT_DIR"
}

case "$LANG" in
  python|golang|typescript)
    enable_lang "$LANG"
    ;;
  all)
    for l in python golang typescript; do
      enable_lang "$l"
    done
    ;;
  *)
    usage
    ;;
esac
