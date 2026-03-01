# Prep Workspace Setup Guide

Recreate the prep workspace on a fresh machine using only the GitHub repos.

Works on **macOS**, **Linux**, and **Windows**.

## Prerequisites

| Tool | Why | macOS / Linux | Windows |
|------|-----|---------------|---------|
| Git | Clone repos | `brew install git` | `winget install Git.Git` |
| Python 3.8+ | Hooks use Python | `brew install python` | `winget install Python.Python.3.12` |
| Node.js 18+ | Hooks use Node | `brew install node` | `winget install OpenJS.NodeJS.LTS` |
| GitHub CLI | Push/pull, API | `brew install gh` | `winget install GitHub.cli` |
| Claude Code | The CLI itself | `npm install -g @anthropic-ai/claude-code` | same |

After installing, authenticate GitHub CLI:

```bash
gh auth login
```

### Pick your workspace root

Choose where you want the prep workspace. This guide uses a variable so all
commands work on any OS:

```bash
# macOS / Linux
PREP_DIR="$HOME/Developer/prep"

# Windows (Git Bash)
PREP_DIR="/c/Developer/prep"
```

Set this in your shell before running the steps below, or substitute your own
path wherever you see `$PREP_DIR`.

---

## Step 1: Set Up Claude Code Config (Global)

Clone `claude-config` and run the setup script. This symlinks all shared config
(rules, hooks, agents, skills, etc.) into `~/.claude/`.

<details>
<summary><strong>macOS / Linux</strong></summary>

```bash
git clone https://github.com/apratim3490/claude-config.git ~/claude-config
cd ~/claude-config
./setup.sh
```

</details>

<details>
<summary><strong>Windows (PowerShell — requires Admin or Developer Mode)</strong></summary>

```powershell
git clone https://github.com/apratim3490/claude-config.git $env:USERPROFILE\claude-config
cd $env:USERPROFILE\claude-config
.\setup.ps1
```

</details>

This creates symlinks so `~/.claude/` points back to the cloned repo. Any
future `git pull` in `~/claude-config` updates your config everywhere.

### What gets linked

| Source (repo) | Target (`~/.claude/`) |
|---------------|----------------------|
| `CLAUDE.md` | `CLAUDE.md` |
| `settings.json` | `settings.json` |
| `hooks/` | `hooks/` |
| `rules/` | `rules/` |
| `rules-lang/` | `rules-lang/` |
| `agents/` | `agents/` |
| `commands/` | `commands/` |
| `skills/` | `skills/` |
| `scripts/` | `scripts/` |
| ...and more | (see setup script for full list) |

---

## Step 2: Create the Workspace Directory

```bash
mkdir -p "$PREP_DIR"
```

This is a plain folder — **not** a git repo. It's just a container for the
study repos and shared Claude config.

---

## Step 3: Clone the Study Repos

```bash
cd "$PREP_DIR"
git clone https://github.com/apratim3490/ant-prep.git
git clone https://github.com/apratim3490/leetcode-prep.git
```

| Repo | Contents |
|------|----------|
| `ant-prep` | Observability, K8s, system design, distributed tracing, study plans |
| `leetcode-prep` | Python LeetCode practice with pytest, templates, dev tooling |

---

## Step 4: Add the Teaching Persona CLAUDE.md

Copy the prep-specific `CLAUDE.md` from `claude-config`:

```bash
cp ~/claude-config/prep/CLAUDE.md "$PREP_DIR/CLAUDE.md"
```

This file activates the **Coding Teacher Persona** — the LINE / EXPLANATION /
THINK OF IT LIKE / REMEMBER format — for anything opened in this workspace.

---

## Step 5: Enable Python Language Rules

Run `enable-lang.sh` to create `.claude/rules/python/` symlinks pointing to
the shared Python rules in `~/.claude/rules-lang/python/`.

<details>
<summary><strong>macOS / Linux</strong></summary>

```bash
~/claude-config/enable-lang.sh python "$PREP_DIR"
```

</details>

<details>
<summary><strong>Windows (Git Bash)</strong></summary>

```bash
~/claude-config/enable-lang.sh python "$PREP_DIR"
```

If symlinks fail (no Admin / no Developer Mode), copy the files instead:

```powershell
$src = "$env:USERPROFILE\.claude\rules-lang\python"
$dst = "$env:USERPROFILE\Developer\prep\.claude\rules\python"  # adjust to your PREP_DIR
New-Item -ItemType Directory -Path $dst -Force
Copy-Item "$src\*" $dst
```

</details>

This creates:

```
$PREP_DIR/.claude/rules/python/
├── coding-style.md   → ~/.claude/rules-lang/python/coding-style.md
├── hooks.md          → ~/.claude/rules-lang/python/hooks.md
├── patterns.md       → ~/.claude/rules-lang/python/patterns.md
├── security.md       → ~/.claude/rules-lang/python/security.md
└── testing.md        → ~/.claude/rules-lang/python/testing.md
```

---

## Step 6: Create Local Permissions

Create `.claude/settings.local.json` to allow common tools without prompting:

```bash
mkdir -p "$PREP_DIR/.claude"
cat > "$PREP_DIR/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(gh repo:*)",
      "Bash(gh api:*)",
      "Bash(python3:*)",
      "Bash(python:*)",
      "Bash(node:*)",
      "Bash(git:*)"
    ]
  }
}
EOF
```

---

## Step 7: Set Up leetcode-prep Dev Environment (Optional)

<details>
<summary><strong>macOS / Linux</strong></summary>

```bash
cd "$PREP_DIR/leetcode-prep"
./setup-dev.sh
```

Or manually:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
```

</details>

<details>
<summary><strong>Windows</strong></summary>

```bash
cd "$PREP_DIR/leetcode-prep"
python -m venv .venv
.venv/Scripts/activate       # Git Bash
# or: .venv\Scripts\Activate.ps1   # PowerShell
pip install -r requirements-dev.txt
```

</details>

---

## Step 8: Verify

Open Claude Code in the workspace and confirm everything loads:

```bash
cd "$PREP_DIR"
claude
```

You should see in the init hook output:
- `[Init] USER CLAUDE.md:` — global config loaded
- `[Init] PROJECT CLAUDE.md:` — teaching persona loaded

Run a quick tool call and check that `[ContextHandover]` does **not** appear
(it only fires at 60+ tool calls).

---

## Final Structure

```
$PREP_DIR/                                ← Workspace (not a git repo)
├── CLAUDE.md                             ← Teaching persona (from claude-config/prep/)
├── .claude/
│   ├── settings.local.json               ← Local permission allowlist
│   └── rules/python/                     ← Symlinks → ~/.claude/rules-lang/python/
│       ├── coding-style.md
│       ├── hooks.md
│       ├── patterns.md
│       ├── security.md
│       └── testing.md
├── ant-prep/                             ← git repo (observability/system design)
│   ├── .git/
│   ├── STUDY-PLAN.md
│   ├── observability-fundamentals/
│   ├── kubernetes-fundamentals/
│   ├── system-design-interviews/
│   └── ...
└── leetcode-prep/                        ← git repo (Python LeetCode practice)
    ├── .git/
    ├── CLAUDE.md                         ← Repo-specific instructions
    ├── pyproject.toml
    ├── basics/
    └── ...
```

---

## Keeping Things Updated

```bash
# Update global Claude config
cd ~/claude-config && git pull

# Update study repos
cd "$PREP_DIR/ant-prep" && git pull
cd "$PREP_DIR/leetcode-prep" && git pull
```

Since `setup.sh` / `setup.ps1` uses symlinks, pulling `claude-config`
automatically updates `~/.claude/` — no re-running needed.

---

## Quick Reference: All Commands (Copy-Paste)

Set `PREP_DIR` first, then run these in order:

```bash
# 1. Global config
git clone https://github.com/apratim3490/claude-config.git ~/claude-config
cd ~/claude-config && ./setup.sh    # or .\setup.ps1 on Windows

# 2. Workspace
mkdir -p "$PREP_DIR"
cd "$PREP_DIR"

# 3. Study repos
git clone https://github.com/apratim3490/ant-prep.git
git clone https://github.com/apratim3490/leetcode-prep.git

# 4. Teaching persona
cp ~/claude-config/prep/CLAUDE.md "$PREP_DIR/CLAUDE.md"

# 5. Python rules
~/claude-config/enable-lang.sh python "$PREP_DIR"

# 6. Local permissions
mkdir -p "$PREP_DIR/.claude"
cat > "$PREP_DIR/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(gh repo:*)",
      "Bash(gh api:*)",
      "Bash(python3:*)",
      "Bash(python:*)",
      "Bash(node:*)",
      "Bash(git:*)"
    ]
  }
}
EOF

# 7. Verify
cd "$PREP_DIR" && claude
```
