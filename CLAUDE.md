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

### Rules (`~/.claude/rules/`)

| Directory | Contents |
|-----------|----------|
| `common/` | agents, coding-style, git-workflow, hooks, patterns, performance, security, testing |
| `python/` | PEP 8, type hints, black/ruff, pytest conventions |
| `typescript/` | TS strict mode, ESLint, patterns, testing |
| `golang/` | Go idioms, go vet/staticcheck, table-driven tests |

### Agents (`~/.claude/agents/`)

| Agent | When to Use |
|-------|-------------|
| `planner` | Complex features, multi-step implementation |
| `architect` | System design, scalability decisions |
| `tdd-guide` | New features, bug fixes (test-first) |
| `code-reviewer` | After writing or modifying code |
| `python-reviewer` | Python-specific code review |
| `security-reviewer` | Before commits touching auth, input handling, APIs |
| `build-error-resolver` | When build/type-check fails |
| `e2e-runner` | Critical user flow validation |
| `refactor-cleaner` | Dead code removal, code maintenance |
| `doc-updater` | Keeping documentation in sync |
| `database-reviewer` | DB queries, schema changes, migrations |
| `go-build-resolver` | Go compilation failures |
| `go-reviewer` | Go-specific code review |

### Commands (`~/.claude/commands/`)

Key slash commands available: `/plan`, `/tdd`, `/code-review`, `/python-review`, `/build-fix`, `/e2e`, `/verify`, `/checkpoint`, `/refactor-clean`, `/test-coverage`, `/update-docs`, `/orchestrate`, `/learn`, `/eval`, `/evolve`, `/sessions`

### Skills (`~/.claude/skills/`)

Language/framework skills for deep reference: `python-patterns`, `python-testing`, `golang-patterns`, `golang-testing`, `frontend-patterns`, `backend-patterns`, `security-review`, `tdd-workflow`, `verification-loop`, `strategic-compact`, `continuous-learning-v2`, and more.

## Agent Orchestration

### Automatic Delegation

Delegate to agents without waiting for user prompt:
1. **Complex feature requests** → `planner` agent first, then implement
2. **Code just written/modified** → `code-reviewer` or `python-reviewer`
3. **Bug fix or new feature** → `tdd-guide` agent
4. **Architectural decision** → `architect` agent
5. **Build failure** → `build-error-resolver` agent

### Parallel Execution

ALWAYS launch independent agent tasks in parallel using multiple Task tool calls in a single message. Never run agents sequentially when their work is independent.

### Model Selection for Subagents

| Task | Model | Rationale |
|------|-------|-----------|
| File exploration, search | Haiku | Fast, cheap, sufficient |
| Simple single-file edits | Haiku | Clear instructions, low complexity |
| Multi-file implementation | Sonnet | Best coding balance |
| Code review, PR review | Sonnet | Catches nuance, understands context |
| Architecture, complex debug | Opus | Deep reasoning required |
| Security analysis | Opus | Cannot afford to miss vulnerabilities |
| Documentation writing | Haiku | Structural, straightforward |

Default to **Sonnet** for 90% of coding tasks. Upgrade to **Opus** when: first attempt failed, task spans 5+ files, architectural decisions, or security-critical code.

## Context & Token Management

### Protect the Context Window

- Disable unused MCPs and plugins - they eat context even when idle
- Prefer CLI tools wrapped in commands over always-loaded MCPs
- Keep active tools under 80 to avoid performance degradation
- Avoid the last 20% of context window for complex multi-file work

### Proactive Compacting Triggers

Compact BEFORE being forced. Use `/compact <topic>` with a focused topic:

| When to Compact | Compact Topic Example |
|-----------------|----------------------|
| After Plan Mode exploration, before execution | `/compact implementing the auth module per plan` |
| After completing a milestone/phase | `/compact phase 1 done, starting phase 2` |
| After a long debugging session | `/compact bug found and fixed, resuming feature work` |
| After extensive code review feedback | `/compact review feedback addressed` |
| When switching between unrelated tasks | `/compact switching from backend to frontend` |

**NEVER** compact mid-implementation or mid-debugging. Finish the logical unit first.

### 75% Context Handover Protocol

A `context-handover.js` hook fires on every tool call, tracking cumulative count as a context usage proxy. When the hook outputs `[ContextHandover] HANDOVER REQUIRED`, you MUST:

1. **Finish the current atomic unit** (don't stop mid-edit)
2. **Write `.handover.md`** in the project root using the Handover File Format below
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

### Handover File Format (`.handover.md`)

Write `.handover.md` with this exact structure. Every section is MANDATORY — write "N/A" if truly not applicable, never skip a section:

```markdown
# Session Handover — [DATE]

## Original Request
[Paste or quote the user's original request verbatim. If it evolved during the session, include both the original and the refined version.]

## Current Task
[One-line summary of what we're actively doing RIGHT NOW]

## Status
- Phase: [planning | implementing | testing | debugging | reviewing]
- Progress: [X of Y steps complete]
- Blockers: [none | description]
- Confidence: [high | medium | low] — [why]

## Approach Chosen
[Describe the architecture/strategy/pattern being used and WHY it was chosen]

### Alternatives Considered & Rejected
- [Alternative 1] — rejected because [reason]
- [Alternative 2] — rejected because [reason]

## Key Decisions Made
- [Decision 1] — WHY: [rationale]
- [Decision 2] — WHY: [rationale]

## What's Done (with evidence)
- [Completed item 1] — verified by [test name / build output / manual check]
- [Completed item 2] — verified by [test name / build output / manual check]

## What Failed / Dead Ends
- [Attempt 1] — failed because [reason] — DO NOT retry this approach
- [Attempt 2] — failed because [reason] — workaround: [what worked instead]

## What Remains (ordered by dependency)
1. [Next step — priority 1] — depends on: [nothing | step X]
2. [Following step — priority 2] — depends on: [step 1]
3. [Further step — priority 3] — depends on: [step 1, 2]

## Open Questions / Unknowns
- [Question 1] — needs user input / needs investigation
- [Question 2] — tentative answer: [guess], confidence: [low/medium]

## Test State
- Tests passing: [list or count]
- Tests failing: [list with reason]
- Tests not yet written: [what coverage is missing]
- How to run: [exact command]

## Git State
- Branch: [branch name]
- Last commit: [SHA + message]
- Uncommitted changes: [list of files or "none"]
- Stashed work: [yes/no — description if yes]

## Active Files (being modified)
- [file1.ts] — [what was changed / what still needs changing]
- [file2.ts] — [what was changed / what still needs changing]

## Reference Files (read-only context)
- [config.ts] — [why this file matters for the task]
- [types.ts] — [key types/interfaces being used]

## Critical Context & Gotchas
- [Gotcha 1: e.g., "The API returns snake_case but the frontend expects camelCase"]
- [Gotcha 2: e.g., "Must use Node 18+ because of fetch API"]
- [Pattern: e.g., "All services follow the repository pattern in src/repos/"]

## Environment
- Runtime: [Node 20 / Python 3.12 / Go 1.22 / etc.]
- Key env vars needed: [list, NOT values]
- Package manager: [npm / pnpm / yarn / bun]
- Build command: [exact command]

## Current TodoWrite State
[Copy the current todo list here as a snapshot — even though TodoWrite persists, this ensures cross-session continuity]
- [x] Step 1 — done
- [x] Step 2 — done
- [ ] Step 3 — in progress
- [ ] Step 4 — pending
```

**Thoroughness rule**: The handover must be detailed enough that a completely fresh Claude session with ZERO prior context can resume the task without asking the user any clarifying questions about what was already done or decided.

### Auto-Memory Integration

Some context should survive not just compaction but entire sessions. Save to memory when:

| What to Save | Where |
|-------------|-------|
| Architectural decisions | `~/.claude/projects/<project>/memory/MEMORY.md` |
| Recurring debugging patterns | `~/.claude/projects/<project>/memory/debugging.md` |
| User preferences discovered | `~/.claude/projects/<project>/memory/MEMORY.md` |
| Project-specific conventions | Project-level `CLAUDE.md` |

**Rule**: If you've discovered something the hard way twice, it belongs in memory.

### Post-Compaction Recovery

After every context compaction, you MUST (in this order):
1. Re-read ALL CLAUDE.md files (user-level `~/.claude/CLAUDE.md` AND project-level `CLAUDE.md`)
2. Re-read `.handover.md` in the project root (if it exists)
3. Re-read `~/.claude/projects/<project>/memory/MEMORY.md` (if it exists)
4. Re-read the TodoWrite state (it persists across compaction automatically)
5. Re-apply any output format, tone, teaching style, or behavioral rules from CLAUDE.md
6. Announce: "Context recovered from handover. Resuming: [task summary]"
7. Do NOT revert to default behavior — CLAUDE.md instructions are mandatory and persist across the entire session

### Session Continuity (Cross-Session)

When ending a session or hitting hard context limits:
1. Run the Pre-Compact Checkpoint Protocol above (write `.handover.md`)
2. Commit `.handover.md` to git (or leave unstaged for next session to pick up)
3. Next session: read `.handover.md` FIRST before doing anything else
4. Clean up `.handover.md` after successfully resuming

## Technical Standards

### Architecture Principles

- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

### Error Handling

- **Fail fast** with descriptive messages
- **Include context** for debugging
- **Handle errors** at appropriate level
- **Never** silently swallow exceptions

## Project Integration

### Project Summary (`project.md`)

Every project should have a `project.md` in its root as a quick-reference summary.

1. **Create if missing**: At the start of a session, if `project.md` does not exist in the project root, explore the codebase and create one summarizing: purpose, architecture, key modules, data flow, dependencies, testing strategy, and any notable design decisions.
2. **Read first**: When trying to understand project structure, intent, or architecture, **read `project.md` first** before running any exploratory commands (grep, glob, file reads). Only dig deeper if `project.md` doesn't answer the question.
3. **Keep it current**: After any significant change (new modules, architectural shifts, dependency changes, new phases/milestones), update `project.md` to reflect the current state of the project.

### Learn the Codebase

- Find similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns

### Tooling

- Use project's existing build system and test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification

### Code Style

- Follow existing conventions in the project
- Refer to linter configurations and .editorconfig, if present
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
- Be rigorous and persistent in searching code for key facts

### Think Before Acting

- **Don't jump into implementation** unless clearly instructed to make changes
- When intent is ambiguous, default to **research and recommendations** rather than taking action
- After receiving tool results, **reflect on quality** and determine optimal next steps before proceeding
- Do what has been asked; **nothing more, nothing less**

### Task Completion

- Before finishing, **verify your solution** (run tests, check build)
- After completing a task, **provide a quick summary** of what was done
- If you create any temporary files or scripts for iteration, **clean them up** at the end of the task
- For maximum efficiency, perform **multiple independent operations simultaneously** rather than sequentially

## Bash Tool Preferences

When using the Bash tool, prefer fast modern tools over slow legacy ones.

### Quick Reference

```
List files    → fd . -t f  OR  rg --files
Search code   → rg "pattern"
Find by name  → fd "filename"
JSON          → jq . file.json
```

### Banned Tools

- `tree` - NOT INSTALLED, use `fd` instead
- `find` - use `fd` or `rg --files`
- `grep` / `grep -r` - use `rg` instead
- `ls -R` - use `rg --files` or `fd`
- `cat file | grep` - use `rg pattern file`

### Search Strategy

1. Start broad, then narrow: `rg "partial" | rg "specific"`
2. Filter by type early: `rg -t py "def function_name"`
3. Batch patterns: `rg "(pattern1|pattern2|pattern3)"`
4. Limit scope: `rg "pattern" src/`
