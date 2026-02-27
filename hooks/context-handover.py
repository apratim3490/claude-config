#!/usr/bin/env python3
"""
Context Handover Hook

Tracks tool call count as a proxy for context usage.
At ~75% estimated capacity, outputs a HANDOVER REQUIRED message
that instructs Claude to write .handover.md and suggest a new session.

Hook type: PreToolUse (fires on every tool call)

Configuration (environment variables):
  HANDOVER_THRESHOLD  - Tool calls before handover trigger (default: 75)
  HANDOVER_WARN       - Tool calls for early warning (default: 60)

How it works:
  - Counts every tool invocation via a temp file scoped to the session
  - At HANDOVER_WARN (default 60), prints a soft warning
  - At HANDOVER_THRESHOLD (default 75), prints HANDOVER REQUIRED
  - Every 10 calls after threshold, repeats the handover reminder
"""

import math
import os
import sys
import tempfile


def main() -> None:
    stdin_data = sys.stdin.read()

    warn_at = int(os.environ.get("HANDOVER_WARN", "60"))
    threshold = int(os.environ.get("HANDOVER_THRESHOLD", "75"))

    session_id = os.environ.get("CLAUDE_SESSION_ID") or str(os.getppid()) or "default"
    counter_file = os.path.join(tempfile.gettempdir(), f"claude-context-handover-{session_id}.count")

    count = 0
    try:
        if os.path.exists(counter_file):
            count = int(open(counter_file).read().strip() or "0")
    except (ValueError, OSError):
        count = 0

    count += 1

    try:
        with open(counter_file, "w") as f:
            f.write(str(count))
    except OSError:
        pass

    if count == warn_at:
        pct = math.floor((count / threshold) * 100)
        sys.stderr.write(
            f"\n[ContextHandover] WARNING: {count} tool calls reached (~{pct}% of handover threshold).\n"
            f"[ContextHandover] Consider wrapping up the current logical unit soon.\n"
            f"[ContextHandover] Handover will trigger at {threshold} tool calls.\n\n"
        )

    if count == threshold:
        sys.stderr.write(
            "\n"
            "========================================\n"
            "[ContextHandover] HANDOVER REQUIRED\n"
            "========================================\n"
            "Context usage is estimated at ~75%.\n"
            "You MUST now:\n"
            '  1. Write .handover.md in the project root (follow the Handover File Format in CLAUDE.md)\n'
            "  2. Save any durable decisions to auto-memory\n"
            '  3. Tell the user: "Context is at ~75%. I\'ve created a handover file. Recommend starting a new session."\n'
            "  4. Continue ONLY if the user explicitly says to keep going\n"
            "========================================\n\n"
        )

    if count > threshold and count % 10 == 0:
        sys.stderr.write(
            f"\n[ContextHandover] REMINDER: {count} tool calls ({count - threshold} past handover threshold).\n"
            f"[ContextHandover] Quality may degrade. Strongly recommend new session with .handover.md.\n\n"
        )

    sys.stdout.write(stdin_data)


if __name__ == "__main__":
    main()
