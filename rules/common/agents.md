# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| python-reviewer | Python-specific review | Python code changes |
| go-reviewer | Go-specific review | Go code changes |
| security-reviewer | Security analysis | Before commits touching auth, input, APIs |
| build-error-resolver | Fix build errors | When build/type-check fails |
| go-build-resolver | Go compilation fixes | Go build failures |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |
| database-reviewer | DB review | Queries, schema changes, migrations |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests → **planner** agent first, then implement
2. Code just written/modified → **code-reviewer** (or **python-reviewer** / **go-reviewer**)
3. Bug fix or new feature → **tdd-guide** agent
4. Architectural decision → **architect** agent
5. Build failure → **build-error-resolver** (or **go-build-resolver**)

## Model Selection for Subagents

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

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
