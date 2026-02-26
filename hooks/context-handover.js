#!/usr/bin/env node
/**
 * Context Handover Hook
 *
 * Tracks tool call count as a proxy for context usage.
 * At ~75% estimated capacity, outputs a HANDOVER REQUIRED message
 * that instructs Claude to write .handover.md and suggest a new session.
 *
 * Hook type: PreToolUse (fires on every tool call)
 *
 * Configuration (environment variables):
 *   HANDOVER_THRESHOLD  - Tool calls before handover trigger (default: 75)
 *   HANDOVER_WARN       - Tool calls for early warning (default: 60)
 *
 * How it works:
 *   - Counts every tool invocation via a temp file scoped to the session
 *   - At HANDOVER_WARN (default 60), prints a soft warning
 *   - At HANDOVER_THRESHOLD (default 75), prints HANDOVER REQUIRED
 *   - Every 10 calls after threshold, repeats the handover reminder
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// Read stdin (hook receives tool context via stdin)
let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
  const WARN_AT = parseInt(process.env.HANDOVER_WARN || '60', 10);
  const THRESHOLD = parseInt(process.env.HANDOVER_THRESHOLD || '75', 10);

  // Session-scoped counter file
  // Use CLAUDE_SESSION_ID if available, otherwise fallback to parent PID
  const sessionId = process.env.CLAUDE_SESSION_ID || process.ppid || 'default';
  const counterFile = path.join(os.tmpdir(), `claude-context-handover-${sessionId}.count`);

  // Read or initialize counter
  let count = 0;
  try {
    if (fs.existsSync(counterFile)) {
      count = parseInt(fs.readFileSync(counterFile, 'utf8').trim(), 10) || 0;
    }
  } catch (e) {
    count = 0;
  }

  // Increment
  count += 1;

  // Write back
  try {
    fs.writeFileSync(counterFile, String(count), 'utf8');
  } catch (e) {
    // Silently continue if we can't write
  }

  // Early warning at ~80% of threshold
  if (count === WARN_AT) {
    process.stderr.write(
      `\n[ContextHandover] WARNING: ${count} tool calls reached (~${Math.round((count / THRESHOLD) * 100)}% of handover threshold).\n` +
      `[ContextHandover] Consider wrapping up the current logical unit soon.\n` +
      `[ContextHandover] Handover will trigger at ${THRESHOLD} tool calls.\n\n`
    );
  }

  // Handover trigger
  if (count === THRESHOLD) {
    process.stderr.write(
      `\n` +
      `========================================\n` +
      `[ContextHandover] HANDOVER REQUIRED\n` +
      `========================================\n` +
      `Context usage is estimated at ~75%.\n` +
      `You MUST now:\n` +
      `  1. Write .handover.md in the project root (follow the Handover File Format in CLAUDE.md)\n` +
      `  2. Save any durable decisions to auto-memory\n` +
      `  3. Tell the user: "Context is at ~75%. I've created a handover file. Recommend starting a new session."\n` +
      `  4. Continue ONLY if the user explicitly says to keep going\n` +
      `========================================\n\n`
    );
  }

  // Repeated reminders every 10 calls past threshold
  if (count > THRESHOLD && count % 10 === 0) {
    process.stderr.write(
      `\n[ContextHandover] REMINDER: ${count} tool calls (${count - THRESHOLD} past handover threshold).\n` +
      `[ContextHandover] Quality may degrade. Strongly recommend new session with .handover.md.\n\n`
    );
  }

  // Pass through the input unchanged (hook must output the input to not block)
  process.stdout.write(input);
});
