# Prep Workspace Setup Guide

Recreate the `C:\Developer\prep` workspace on a fresh machine using only the GitHub repos.

## Prerequisites

| Tool | Why | Install |
|------|-----|---------|
| Git | Clone repos | `winget install Git.Git` / `brew install git` |
| Python 3.8+ | Hooks use Python | `winget install Python.Python.3.12` / `brew install python` |
| Node.js 18+ | Hooks use Node | `winget install OpenJS.NodeJS.LTS` / `brew install node` |
| GitHub CLI | Push/pull, API | `winget install GitHub.cli` / `brew install gh` |
| Claude Code | The CLI itself | `npm install -g @anthropic-ai/claude-code` |

After installing, authenticate GitHub CLI:

```bash
gh auth login
```

## Step 1: Set Up Claude Code Config (Global)

Clone `claude-config` and run the setup script. This symlinks all shared config
(rules, hooks, agents, skills, etc.) into `~/.claude/`.

**macOS / Linux:**

```bash
git clone https://github.com/apratim3490/claude-config.git ~/claude-config
cd ~/claude-config
./setup.sh
```

**Windows (PowerShell as Admin, or with Developer Mode enabled):**

```powershell
git clone https://github.com/apratim3490/claude-config.git $env:USERPROFILE\claude-config
cd $env:USERPROFILE\claude-config
.\setup.ps1
```

This creates symlinks so `~/.claude/` points back to the cloned repo. Any
future `git pull` in `~/claude-config` updates your config everywhere.

### What `setup.sh` / `setup.ps1` links

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

## Step 2: Create the Workspace Directory

```bash
mkdir -p /c/Developer/prep    # Windows (Git Bash)
# or
mkdir -p ~/Developer/prep     # macOS / Linux
```

This is a plain folder — **not** a git repo. It's just a container for the
study repos and shared Claude config.

## Step 3: Clone the Study Repos

```bash
cd /c/Developer/prep           # or ~/Developer/prep

git clone https://github.com/apratim3490/ant-prep.git
git clone https://github.com/apratim3490/leetcode-prep.git
```

| Repo | Contents |
|------|----------|
| `ant-prep` | Observability, K8s, system design, distributed tracing, study plans |
| `leetcode-prep` | Python LeetCode practice with pytest, templates, dev tooling |

## Step 4: Add the Teaching Persona CLAUDE.md

Copy the prep-specific `CLAUDE.md` from `claude-config`:

```bash
cp ~/claude-config/prep/CLAUDE.md /c/Developer/prep/CLAUDE.md
```

This file activates the **Coding Teacher Persona** — the LINE / EXPLANATION /
THINK OF IT LIKE / REMEMBER format — for anything opened in this workspace.

## Step 5: Enable Python Language Rules

Run `enable-lang.sh` to create `.claude/rules/python/` symlinks pointing to
the shared Python rules in `~/.claude/rules-lang/python/`:

```bash
~/claude-config/enable-lang.sh python /c/Developer/prep
```

This creates:

```
prep/.claude/rules/python/
├── coding-style.md   → ~/.claude/rules-lang/python/coding-style.md
├── hooks.md          → ~/.claude/rules-lang/python/hooks.md
├── patterns.md       → ~/.claude/rules-lang/python/patterns.md
├── security.md       → ~/.claude/rules-lang/python/security.md
└── testing.md        → ~/.claude/rules-lang/python/testing.md
```

**Windows note:** If symlinks fail, copy the files instead:

```powershell
$src = "$env:USERPROFILE\.claude\rules-lang\python"
$dst = "C:\Developer\prep\.claude\rules\python"
New-Item -ItemType Directory -Path $dst -Force
Copy-Item "$src\*" $dst
```

## Step 6: Create Local Permissions

Create `.claude/settings.local.json` to allow common tools without prompting:

```bash
mkdir -p /c/Developer/prep/.claude
cat > /c/Developer/prep/.claude/settings.local.json << 'EOF'
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

## Step 7: Set Up leetcode-prep Dev Environment (Optional)

```bash
cd /c/Developer/prep/leetcode-prep
./setup-dev.sh          # Creates venv, installs deps
```

Or manually:

```bash
python -m venv .venv
source .venv/bin/activate   # or .venv\Scripts\activate on Windows
pip install -r requirements-dev.txt
```

## Step 8: Verify

Open Claude Code in the workspace and confirm everything loads:

```bash
cd /c/Developer/prep
claude
```

You should see in the init hook output:
- `[Init] USER CLAUDE.md:` — global config loaded
- `[Init] PROJECT CLAUDE.md:` — teaching persona loaded

Run a quick tool call and check that `[ContextHandover]` does **not** appear
(it only fires at 60+ tool calls).

## Final Structure

```
C:\Developer\prep/                        ← Workspace (not a git repo)
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

## Keeping Things Updated

```bash
# Update global Claude config
cd ~/claude-config && git pull

# Update study repos
cd /c/Developer/prep/ant-prep && git pull
cd /c/Developer/prep/leetcode-prep && git pull
```

Since `setup.sh` uses symlinks, pulling `claude-config` automatically updates
`~/.claude/` — no re-running needed.
