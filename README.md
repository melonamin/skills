# Skills

Shared Agent Skills for Claude Code, Pi, and Codex.

This repository is intended to be the single source of truth for user-managed skills. The local canonical path is:

```text
~/.agents/skills
```

Pi discovers `~/.agents/skills` automatically. Claude Code and Codex are wired by symlinking each skill from their harness-specific skill directories.

## Install

Clone the repo to the canonical location:

```bash
git clone https://github.com/melonamin/skills.git ~/.agents/skills
cd ~/.agents/skills
./init.sh
```

If you already have harness-specific skill directories and want to replace conflicting entries with symlinks into this repo:

```bash
./init.sh --force
```

## What `init.sh` does

- Verifies this repo can be used as `~/.agents/skills`.
- Creates missing harness skill directories:
  - `~/.pi/agent/skills`
  - `~/.claude/skills`
  - `~/.codex/skills`
- Symlinks each skill into those harness directories.
- Leaves Codex built-in skills under `~/.codex/skills/.system` untouched.
- If Omarchy is installed, links the bundled Omarchy skill from:

```text
~/.local/share/omarchy/default/omarchy-skill
```

## Layout

Each skill follows the Agent Skills directory format:

```text
skill-name/
  SKILL.md
  scripts/
  references/
```

`SKILL.md` must contain frontmatter with at least:

```md
---
name: skill-name
description: What this skill does and when to use it.
---
```

The `name` should match the directory name.

## Notes

- `omarchy` is intentionally not tracked here. It is bundled with Omarchy itself and linked by `init.sh` when present.
- Keep helper paths inside skills relative to the skill directory.
- Avoid putting harness-specific assumptions into shared skills unless the instructions explicitly branch by harness.
