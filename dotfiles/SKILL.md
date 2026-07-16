---
name: dotfiles
description: >
  Managing Sasha's dotfiles: where they live, the two tracking modes (live-linked vs
  copied), how to add a new file, and how to commit and push. Use when adding, updating,
  or committing any tracked config (~/.config/*, ~/.claude/*, ~/.aliases, ~/.exports,
  ~/.gitconfig, ~/.local/bin, ~/.local/agent-wrappers), when `config status` looks wrong,
  or when a config change should be persisted to the dotfiles repo.
---

# Dotfiles

## Where things live

| What | Path | Repo |
|---|---|---|
| Dotfiles | `~/Developer/github.com/melonamin/dotfiles` | `melonamin/dotfiles` (**PUBLIC**) |
| Agent skills | `~/.agents/skills` | `melonamin/skills` |
| Claude harness dir | `/mnt/agents/claude` (via `~/.claude` symlink) | tracked as `.claude/*` in dotfiles |

Aliases (`~/.aliases`):

```bash
config    # git -C ~/Developer/github.com/melonamin/dotfiles
dotfiles  # cd to the repo
```

`config` is a plain `git -C`, **not** a bare repo. Stage **repo-relative** paths
(`config add .config/foo/bar`), never `$HOME` ones.

## The two tracking modes — this is the thing to get right

**1. Live-linked** — the repo file is symlinked into `$HOME`, so edits are picked up
automatically and never drift. The manifest is the `PATHS` array in `install.sh`:

```bash
PATHS=( .aliases .local/agent-wrappers )
```

`./install.sh` is idempotent: it creates the symlink, backs up an existing regular file to
`<path>.bak` first, and leaves correct symlinks alone. Run it after adding to `PATHS`.

**2. Copied (archive)** — everything else (`.config/*`, `.claude/*`, `.exports`,
`.gitconfig`, `.local/bin/*`). The repo holds a **copy**, so the live file and the repo copy
**drift apart silently**. `config status` looks clean while the repo is stale.

> **Always run `scripts/sync.sh` before committing a copied file**, or you will commit a
> stale version. (17 files had drifted for 3 weeks before the 2026-07-16 reconcile.)

## Recipes

Update an already-tracked config:

```bash
bash ~/.agents/skills/dotfiles/scripts/sync.sh    # live $HOME -> repo copies
config status                                     # review
config add .config/foo/bar && config commit -m "chore(foo): ..." && config push
```

Track a **new** file (copy mode — the default):

```bash
dotfiles
mkdir -p .config/foo && cp ~/.config/foo/config .config/foo/config
config add .config/foo/config
config commit -m "feat(foo): add foo config" && config push
```

Make a file **live-linked** instead (no drift — prefer for things you edit often):

```bash
dotfiles
# move the real file in, then add its path to the PATHS array in install.sh
git mv/cp as needed && $EDITOR install.sh
./install.sh        # creates the symlink, backs up the original to <path>.bak
```

Delete a file from the live system: also `config rm --cached <path>` so the repo matches
reality; git history keeps it.

## Rules

- **The repo is PUBLIC.** Scan added lines for secrets before committing anything —
  especially `.exports`, `.gitconfig`, `.claude/settings.json`, `.config/zed/settings.json`.
  (`SSH_AUTH_SOCK` pointing at the 1Password agent socket is a path, not a secret.)
- **Commit style: Conventional Commits** (`feat(herdr): add herdr config`). Match the repo,
  not the older `Add …` style from the retired bare repo.
- Stage only what you intend; the tree often carries unrelated pending edits.
- `git`/`ssh` may hang on a 1Password approval prompt — that is the SSH agent, not a failure.
- Skills are **not** dotfiles: they live in `~/.agents/skills` (its own repo) and are
  symlinked into each harness by that repo's `init.sh`.

## History note

A `.cfg` **bare repo** (`git --git-dir=$HOME/.cfg --work-tree=$HOME`) was the old system,
retired 2026-07-16. It tracked the same files in place, drifted 3 weeks behind, and reported
phantom `deleted:`/`typechange:` entries once paths became symlinks. Its unique history is
archived on the remote branch **`legacy/bare-repo`**; the local copy was moved to
`~/.cfg.retired-20260716`. If a `~/.cfg` reappears or `config` is repointed at
`--git-dir`, something has regressed.
