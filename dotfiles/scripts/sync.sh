#!/usr/bin/env bash
# Sync copy-mode dotfiles from the live $HOME into the repo.
#
# Files tracked in "copy" mode (everything not symlinked via install.sh) drift
# silently: the repo copy goes stale while `config status` still looks clean.
# Run this before committing so the repo reflects reality.
#
# Live-linked paths (symlinks into the repo) are skipped — they cannot drift.
# Read-only by default; pass --write to actually copy.
set -euo pipefail

REPO="${DOTFILES_REPO:-$HOME/Developer/github.com/melonamin/dotfiles}"
WRITE=0
[[ "${1:-}" == "--write" ]] && WRITE=1

[[ -d "$REPO/.git" ]] || { echo "not a repo: $REPO" >&2; exit 1; }

drifted=0 missing=0 skipped=0

while IFS= read -r rel; do
    [[ "$rel" == "install.sh" ]] && continue
    live="$HOME/$rel"

    # Live-linked: the path in $HOME resolves back into the repo (the file itself
    # is a symlink, or it sits under a symlinked directory). It IS the repo file,
    # so it cannot drift.
    if [[ -e "$live" ]] && [[ "$(realpath -- "$live" 2>/dev/null)" == "$REPO"/* ]]; then
        skipped=$((skipped + 1))
        continue
    fi

    if [[ ! -e "$live" ]]; then
        echo "gone:    $rel (in repo, not in \$HOME — 'config rm --cached' it?)"
        missing=$((missing + 1))
        continue
    fi

    if ! diff -q "$live" "$REPO/$rel" >/dev/null 2>&1; then
        drifted=$((drifted + 1))
        if (( WRITE )); then
            cp -- "$live" "$REPO/$rel"
            echo "synced:  $rel"
        else
            echo "drifted: $rel"
        fi
    fi
done < <(git -C "$REPO" ls-files)

echo
echo "drifted: $drifted   gone: $missing   live-linked (skipped): $skipped"
if (( WRITE )); then
    echo "Review with: git -C \"$REPO\" diff"
    echo "The repo is PUBLIC — check added lines for secrets before committing."
elif (( drifted )); then
    echo "Re-run with --write to copy them into the repo."
fi
