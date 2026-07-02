---
name: worktree
description: Manage git worktrees with the gt utility for parallel feature development — create, switch, merge, and clean up worktrees without stashing or branch-switching.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Glob
---

# Git Worktree Management with gt

`gt` (v0.5.0+) manages worktrees stored in `.worktrees/` inside the repo by
default. The location is configurable (`~/.config/gt/config.json`,
`worktree_dir`), so always resolve paths via `git worktree list` rather than
assuming.

## Agent-safe usage — read first

- NEVER run bare `gt` — it opens an interactive TUI.
- NEVER run `gt <name>` without `-x` — it spawns an interactive shell after
  creating the worktree. Always pass a no-op command instead:

```bash
gt <name> main -x true        # create worktree non-interactively
git worktree list             # find its path, then cd into it
```

## Commands

| Command | Effect |
|---|---|
| `gt <name> <base> -x true` | Create NEW branch `<name>` from `<base>` + worktree |
| `gt <name> -x true` | Reuse local branch `<name>`; else track remote `<name>` (fetches if needed); else create from current HEAD |
| `gt --merge <branch>` | ff-only merge into default branch, then delete worktree AND branch |
| `gt --merge <branch> --squash` | Squash-merge variant (single commit) |

Caveats:

- `gt <name>` reuses existing branches (git switch-style guessing). To
  guarantee a fresh branch, always pass the base: `gt <name> main`.
- `gt --merge` runs pre-flight checks (dirty tree, ahead/behind, ff-possible)
  and works from anywhere in the repo — but it checks out the default branch
  in the main worktree as a side effect.
- A `post_create` hook from config (e.g. `npm install`) runs automatically on
  creation; expect its output.

## Workflows

**Start a feature:** `gt <feature-name> main -x true`, then cd to the new
worktree (path from `git worktree list`). Work there; the original worktree
stays untouched.

**Finish a feature:** commit everything (`git status` clean), then
`gt --merge <feature-branch>`. Use `--squash` for a single-commit history.
This replaces manual merge + `git worktree remove` + `git branch -d`.

**Clean up without merging:** `git worktree remove <path>` (add `--force` if
dirty), then `git branch -D <branch>` if the branch should go too.

## When User Asks To...

- "work on feature X" / "start feature X" → `gt <feature-name> main -x true`, then cd in
- "switch to feature X" → find path via `git worktree list`, cd there
- "finish this feature" / "merge back" → commit, then `gt --merge <branch>`
- "clean up" / "delete worktree" → `git worktree remove <path>` (+ delete branch if asked)

## Notes

- Worktrees share one `.git`: commits made in any worktree are instantly
  visible to all. One branch = one worktree; gt enforces this.
- Run agents in parallel by giving each its own worktree:
  `gt <task> main -x true` per task.
