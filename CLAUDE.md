# Development Guidelines

## Philosophy

### Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious
- **Agent-first design** - Delegate to specialized agents for complex work
- **Plan before execute** - Use Plan Mode for non-trivial operations

### Simplicity

- **Single responsibility** per function/class
- **Avoid premature abstractions**
- **No clever tricks** - choose the boring solution
- If you need to explain it, it's too complex

## Modular Configuration

Detailed guidelines are split into modular rule files. Do NOT duplicate their content here.

### Rules

Global rules in `rules/common/` load on every session. Language rules are **opt-in per project**.

| Directory | Scope | Contents |
|-----------|-------|----------|
| `rules/common/` | Global (always loaded) | agents, coding-style, git-workflow, hooks, patterns, performance, security, testing |
| `rules-lang/python/` | Per-project opt-in | PEP 8, type hints, black/ruff, pytest conventions |
| `rules-lang/typescript/` | Per-project opt-in | TS strict mode, ESLint, patterns, testing |
| `rules-lang/golang/` | Per-project opt-in | Go idioms, go vet/staticcheck, table-driven tests |

Enable language rules: `enable-lang.sh <python|golang|typescript|all> /path/to/project`

### Agents, Commands, Skills

- **Agents**: See `rules/common/agents.md` for full list, delegation rules, and model selection
- **Commands**: `/plan`, `/tdd`, `/code-review`, `/python-review`, `/build-fix`, `/e2e`, `/verify`, `/checkpoint`, `/refactor-clean`, `/test-coverage`, `/update-docs`, `/orchestrate`, `/learn`, `/eval`, `/evolve`, `/sessions`
- **Skills**: `python-patterns`, `python-testing`, `golang-patterns`, `golang-testing`, `frontend-patterns`, `backend-patterns`, `security-review`, `tdd-workflow`, `strategic-compact`, `continuous-learning-v2`, and more

## Context & Token Management

### Protect the Context Window

- Disable unused MCPs and plugins - they eat context even when idle
- Managed MCPs (Gmail, etc.) must be toggled off via `/mcp` when not needed — each adds ~2K tokens
- Prefer CLI tools wrapped in commands over always-loaded MCPs
- Keep active tools under 80 to avoid performance degradation
- Avoid the last 20% of context window for complex multi-file work

### Proactive Compacting Triggers

Compact BEFORE being forced. Use `/compact <topic>` with a focused topic.

**NEVER** compact mid-implementation or mid-debugging. Finish the logical unit first.

### 75% Context Handover Protocol

A `context-handover.py` hook fires on every tool call, tracking cumulative count as a context usage proxy. When the hook outputs `[ContextHandover] HANDOVER REQUIRED`, you MUST:

1. **Finish the current atomic unit** (don't stop mid-edit)
2. **Write `.handover.md`** in the project root using the template in `guides/handover-template.md`
3. **Save durable decisions** to `~/.claude/projects/<project>/memory/MEMORY.md`
4. **Update TodoWrite** so the todo list reflects current state (it persists)
5. **Tell the user**: "Context is at ~75%. I've created `.handover.md`. I recommend starting a new session with `/resume` or by pasting the handover."
6. **Continue ONLY if the user explicitly says to keep going**

If the user says to continue, use `/compact <current task summary>` immediately to reclaim space, then proceed.

### Pre-Compact Checkpoint Protocol

**BEFORE every `/compact`**, write a handover file to preserve state:

1. Write `.handover.md` in the project root (overwrite previous)
2. Save durable decisions to auto-memory
3. Then run `/compact <topic>`

### Auto-Memory Integration

Save to memory when you've discovered something the hard way twice:

| What to Save | Where |
|-------------|-------|
| Architectural decisions | `~/.claude/projects/<project>/memory/MEMORY.md` |
| Recurring debugging patterns | `~/.claude/projects/<project>/memory/debugging.md` |
| User preferences discovered | `~/.claude/projects/<project>/memory/MEMORY.md` |
| Project-specific conventions | Project-level `CLAUDE.md` |

### Post-Compaction Recovery

After every context compaction, you MUST (in this order):
1. Re-read ALL CLAUDE.md files (user-level AND project-level)
2. Re-read `.handover.md` in the project root (if it exists)
3. Re-read `~/.claude/projects/<project>/memory/MEMORY.md` (if it exists)
4. Re-apply any output format, tone, teaching style, or behavioral rules from CLAUDE.md
5. Announce: "Context recovered from handover. Resuming: [task summary]"
6. Do NOT revert to default behavior — CLAUDE.md instructions are mandatory

### Session Continuity (Cross-Session)

When ending a session or hitting hard context limits:
1. Write `.handover.md` using the template in `guides/handover-template.md`
2. Commit or leave unstaged for next session to pick up
3. Next session: read `.handover.md` FIRST before doing anything else
4. Clean up `.handover.md` after successfully resuming

## Project Integration

### Project Summary (`project.md`)

Every project should have a `project.md` in its root as a quick-reference summary.

1. **Create if missing**: At the start of a session, explore the codebase and create one summarizing: purpose, architecture, key modules, data flow, dependencies, testing strategy, and notable design decisions.
2. **Read first**: Read `project.md` first before running exploratory commands. Only dig deeper if it doesn't answer the question.
3. **Keep it current**: After significant changes, update `project.md` to reflect the current state.

### Learn the Codebase

- Find similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns

### Tooling & Code Style

- Use project's existing build system, test framework, formatter/linter settings
- Don't introduce new tools without strong justification
- Follow existing conventions; refer to linter configs and .editorconfig if present
- Text files should always end with an empty line

## Important Reminders

**NEVER**:
- Use `--no-verify` to bypass commit hooks
- Disable tests instead of fixing them
- Commit code that doesn't compile
- Make assumptions - verify with existing code
- Add co-authored-by claude in any commit message
- Silently swallow exceptions or errors
- Create mega-files (800+ lines) when smaller modules work

**ALWAYS**:
- Commit working code incrementally
- Update plan documentation as you go
- Learn from existing implementations
- Stop after 3 failed attempts and reassess
- Validate at system boundaries (user input, external APIs)
- Clean up temporary files after task completion

## AI Behavior

### Investigate Before Answering

- **Read and understand** relevant files before proposing code edits
- **Never speculate** about code you have not inspected
- If the user references a specific file/path, **open and inspect it** before explaining or proposing fixes

### Think Before Acting

- **Don't jump into implementation** unless clearly instructed to make changes
- When intent is ambiguous, default to **research and recommendations** rather than taking action
- Do what has been asked; **nothing more, nothing less**

### Task Completion

- Before finishing, **verify your solution** (run tests, check build)
- After completing a task, **provide a quick summary** of what was done
- Clean up temporary files after task completion
- Perform **multiple independent operations simultaneously** rather than sequentially

## Bash Tool Preferences

Prefer fast modern tools over slow legacy ones.

```
List files    → fd . -t f  OR  rg --files
Search code   → rg "pattern"
Find by name  → fd "filename"
JSON          → jq . file.json
```

**Banned**: `tree` (not installed), `find` (use fd), `grep -r` (use rg), `ls -R` (use fd), `cat | grep` (use rg)
