# Claude Config

Personal [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration synced across machines.

## What's included

- **CLAUDE.md** - Global instructions loaded by Claude Code for every project (`~/.claude/CLAUDE.md`)
- **setup.sh** - Script to symlink the config into place on a new machine

## Setup on a new machine

```bash
git clone git@github.com:apratim3490/claude-config.git
cd claude-config
./setup.sh
```

This creates a symlink from `~/.claude/CLAUDE.md` to the repo, so edits stay in sync with git.

## Updating

Edit `CLAUDE.md` in this repo (or via the symlink at `~/.claude/CLAUDE.md`), then commit and push:

```bash
cd ~/Developer/claude-config  # or wherever you cloned it
git add -A && git commit -m "Update CLAUDE.md" && git push
```

On other machines, pull to get the latest:

```bash
cd ~/Developer/claude-config
git pull
```
