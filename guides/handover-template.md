# Handover File Template (`.handover.md`)

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
