# Claude Config

Personal [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration synced across machines.

Based on [everything-claude-code](https://github.com/affaan-m/everything-claude-code) with personal customizations.

## What's included

| Directory | Contents |
|-----------|----------|
| `CLAUDE.md` | Global user-level instructions loaded for every project |
| `settings.json` | Claude Code settings |
| `package-manager.json` | Package manager config |
| `agents/` | 13 specialized subagents (planner, architect, code-reviewer, security-reviewer, etc.) |
| `rules/` | Modular rules: common + python + typescript + golang |
| `commands/` | 31 slash commands (/plan, /tdd, /code-review, /build-fix, etc.) |
| `skills/` | 32 skill directories (python-patterns, tdd-workflow, security-review, etc.) |
| `contexts/` | Context presets for dev, research, review modes |
| `hooks/` | Lifecycle hook configurations |
| `mcp-configs/` | MCP server configurations |
| `schemas/` | JSON schemas for hooks, plugins, package-manager |
| `scripts/` | CI validators, hook scripts, utility libraries |
| `tests/` | Test suites for hooks, integration, utilities |
| `plugins/` | Plugin documentation |
| `examples/` | Example CLAUDE.md files for reference |
| `guides/` | Longform guide, shortform guide, llms.txt |
| `assets/` | Images for the guides |

## Setup on a new machine

```bash
git clone git@github.com:apratim3490/claude-config.git
cd claude-config
./setup.sh
```

## Updating

Edit files in this repo, then commit and push:

```bash
cd ~/Developer/claude-config
git add -A && git commit -m "Update config" && git push
```

On other machines, pull to get the latest:

```bash
cd ~/Developer/claude-config
git pull
```
