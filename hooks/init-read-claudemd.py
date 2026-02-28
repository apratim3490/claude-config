#!/usr/bin/env python3
"""
Init Hook — Read CLAUDE.md Files on Session Start

Fires on the first tool call of each session and outputs the contents
of both the user-level (~/.claude/CLAUDE.md) and project-level CLAUDE.md
to stderr, ensuring Claude re-reads and follows all instructions every session.

Hook type: PreToolUse (first invocation only, per session)

Portability: Python 3.8+, Windows/macOS/Linux

How it works:
  - Uses a temp file keyed by CLAUDE_SESSION_ID to track first-run
  - On first tool call: reads both CLAUDE.md files and prints them to stderr
  - On subsequent calls: passes through silently
  - Always passes stdin through to stdout unchanged
"""

from __future__ import annotations

import os
import sys
import tempfile
from typing import Optional


def get_session_id() -> str:
    """Get a stable session identifier, portable across OS."""
    session_id = os.environ.get("CLAUDE_SESSION_ID", "")
    if session_id:
        return session_id
    # os.getppid() is unavailable on some Windows builds
    try:
        return str(os.getppid())
    except (AttributeError, OSError):
        return str(os.getpid())


def get_user_claude_md() -> str:
    """Return the path to the user-level CLAUDE.md, portable across OS."""
    return os.path.join(os.path.expanduser("~"), ".claude", "CLAUDE.md")


def find_project_claude_md() -> Optional[str]:
    """Walk up from CWD to find the nearest CLAUDE.md."""
    current = os.getcwd()
    while True:
        candidate = os.path.join(current, "CLAUDE.md")
        if os.path.isfile(candidate):
            return candidate
        parent = os.path.dirname(current)
        if parent == current:
            break
        current = parent
    return None


def read_file(path: str) -> Optional[str]:
    """Read a file and return its contents, or None on failure."""
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError:
        return None


def main() -> None:
    stdin_data = sys.stdin.read()

    session_id = get_session_id()
    marker_file = os.path.join(
        tempfile.gettempdir(), "claude-init-claudemd-{}.done".format(session_id)
    )

    if not os.path.exists(marker_file):
        # First tool call this session — mark as done
        try:
            with open(marker_file, "w", encoding="utf-8") as f:
                f.write("1")
        except OSError:
            pass

        # --- User-level CLAUDE.md ---
        user_claude_md = get_user_claude_md()
        if os.path.isfile(user_claude_md):
            contents = read_file(user_claude_md)
            if contents:
                sys.stderr.write(
                    "\n"
                    "========================================\n"
                    "[Init] USER CLAUDE.md: " + user_claude_md + "\n"
                    "========================================\n"
                    "\n"
                    + contents
                    + "\n"
                    "========================================\n"
                    "\n"
                )
            else:
                sys.stderr.write(
                    "\n[Init] Failed to read user CLAUDE.md: {}\n\n".format(
                        user_claude_md
                    )
                )
        else:
            sys.stderr.write(
                "\n[Init] No user-level CLAUDE.md found at {}\n\n".format(
                    user_claude_md
                )
            )

        # --- Project-level CLAUDE.md ---
        project_claude_md = find_project_claude_md()
        if project_claude_md and os.path.normpath(project_claude_md) != os.path.normpath(user_claude_md):
            contents = read_file(project_claude_md)
            if contents:
                sys.stderr.write(
                    "========================================\n"
                    "[Init] PROJECT CLAUDE.md: " + project_claude_md + "\n"
                    "========================================\n"
                    "\n"
                    + contents
                    + "\n"
                    "========================================\n"
                    "\n"
                )
            else:
                sys.stderr.write(
                    "\n[Init] Failed to read project CLAUDE.md: {}\n\n".format(
                        project_claude_md
                    )
                )
        elif not project_claude_md:
            sys.stderr.write(
                "[Init] No project-level CLAUDE.md found in CWD or parents.\n\n"
            )

        sys.stderr.write(
            "========================================\n"
            "[Init] You MUST follow ALL instructions from both CLAUDE.md files above.\n"
            "========================================\n"
            "\n"
        )

    # Always pass through stdin unchanged
    sys.stdout.write(stdin_data)


if __name__ == "__main__":
    main()
