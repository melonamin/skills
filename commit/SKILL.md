---
name: commit
description: Create a git commit when requested or already authorized by the task. Use before staging and committing task changes; not for pushing, merging, or publishing.
---

# Commit task changes

1. Confirm the checkout, branch, upstream, and dirty state with git status, git branch -vv, and the relevant diff. Inspect the existing index separately from the working tree.
2. Determine the intended changes from the task, explicit paths, and session history. Stage only task-owned files or hunks. Unspecified paths do not mean every dirty file belongs in the commit.
3. Preserve unrelated staged and unstaged changes. If a file mixes task changes with other work, stage only the intended hunks; do not reset the user's index. Ask only when ownership cannot be resolved from evidence.
4. Run appropriate repository checks. Inspect the staged diff, including new files, for scope and unintended content before committing. Do not bypass hooks.
5. Commit using repository conventions. Default to a concise Conventional Commits subject: type(scope): imperative summary, at most 72 characters, no trailing period. Add a body only when useful. Do not add sign-offs unless requested or required by the repository.
6. Verify the resulting commit's file list and remaining git status. Report the commit and any excluded unrelated work. Do not push unless that action was also authorized.

When the index contains unrelated work, a plain git commit would include it. Use an isolated temporary index or a path-limited commit only after verifying that it captures exactly the intended patch and preserves the user's staged content. Never silently commit the entire index.
