---
name: worktree
description: Create, locate, switch to, merge, or remove git worktrees when the user requests those operations or task isolation requires one. Use the existing checkout when appropriate; finishing implementation alone does not authorize merge or cleanup.
---

# Worktree operations

Inspect git status --short --branch, git branch -vv, and git worktree list --porcelain before choosing a target. Resolve the repository's actual base branch and upstream; do not assume main or matching local/remote names.

## Create or reuse

- Reuse the task's existing worktree when it already exists. Preserve other active worktrees and dirty changes.
- For a new branch with gt, use gt <branch> <resolved-base> -x true. Bare gt opens a TUI; gt <branch> without -x can open an interactive shell.
- Locate the resulting path with git worktree list rather than assuming .worktrees. Creation hooks can install dependencies; inspect their results.
- If gt is unavailable, use git worktree add -b <branch> <path> <resolved-base>.

## Switch

Locate the existing worktree and use its directory. Do not change the branch in another active worktree. Inside BB, when moving this thread, use the environment-directory update tool and stop the turn after it succeeds so the next turn has the correct working directory.

## Finish implementation

Complete the authorized changes and validation. Commit, push, or open a PR only according to existing authorization. The phrase "finish this feature" does not itself authorize merging, deleting a branch, or removing a worktree.

## Merge

When merge is authorized, verify source, destination, dirty state, and checks. Use the repository's merge/PR workflow. gt --merge <branch> also checks out the default branch in the main worktree and deletes the source worktree AND branch; use it only if that entire action set is intended and the destination worktree is available. Otherwise merge separately and retain the worktree.

## Cleanup

Remove only the requested disposable worktree after checking its status and contents. Use git worktree remove <path> without --force. Dirty or untracked content requires preservation or explicit discard authorization, not an automatic force retry. Delete a branch only when requested or already authorized; prefer git branch -d, and inspect unmerged commits before any forced deletion.

Worktrees share repository refs and objects. Changes to one branch's history and shared git configuration can affect other worktrees; keep operations scoped to the task.
