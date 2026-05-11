#!/usr/bin/env bash
set -euo pipefail

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: ./init.sh [--force]

Create/verify symlinks so Claude Code, Pi, and Codex use this shared skills repo.

Options:
  --force   Replace conflicting files/directories with symlinks after backing them up.
USAGE
  exit 0
elif [[ -n "${1:-}" ]]; then
  echo "Unknown argument: $1" >&2
  exit 2
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CANONICAL_DIR="${SKILLS_DIR:-$HOME/.agents/skills}"
BACKUP_DIR="$HOME/.skills-init-backup-$(date +%Y%m%d-%H%M%S)"

backup_path() {
  local path="$1"
  mkdir -p "$BACKUP_DIR$(dirname "${path#$HOME}")"
  mv "$path" "$BACKUP_DIR${path#$HOME}"
}

ensure_link() {
  local link="$1"
  local target="$2"
  mkdir -p "$(dirname "$link")"

  if [[ -L "$link" ]]; then
    local current
    current="$(readlink "$link")"
    if [[ "$current" == "$target" || "$(readlink -f "$link" 2>/dev/null || true)" == "$(readlink -f "$target" 2>/dev/null || true)" ]]; then
      echo "ok: $link -> $target"
      return 0
    fi
  elif [[ ! -e "$link" ]]; then
    ln -s "$target" "$link"
    echo "created: $link -> $target"
    return 0
  fi

  if [[ "$FORCE" == "1" ]]; then
    backup_path "$link"
    ln -s "$target" "$link"
    echo "replaced: $link -> $target"
  else
    echo "warn: $link exists and is not the expected symlink; rerun with --force to replace" >&2
  fi
}

# If this repo is not already at ~/.agents/skills, make ~/.agents/skills point here.
if [[ "$REPO_DIR" != "$(mkdir -p "$(dirname "$CANONICAL_DIR")" && cd "$(dirname "$CANONICAL_DIR")" && pwd -P)/$(basename "$CANONICAL_DIR")" ]]; then
  ensure_link "$CANONICAL_DIR" "$REPO_DIR"
fi

# Omarchy ships its own skill. Keep it external and link it into the canonical dir when available.
OMARCHY_SKILL="$HOME/.local/share/omarchy/default/omarchy-skill"
if [[ -d "$OMARCHY_SKILL" ]]; then
  ensure_link "$CANONICAL_DIR/omarchy" "$OMARCHY_SKILL"
fi

mapfile -t SKILLS < <(
  find "$CANONICAL_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md -type f -printf '%h\n' \
    | xargs -r -n1 basename \
    | sort -u
)

if [[ -L "$CANONICAL_DIR/omarchy" || -f "$CANONICAL_DIR/omarchy/SKILL.md" ]]; then
  SKILLS+=("omarchy")
fi

HARNESS_DIRS=(
  "$HOME/.pi/agent/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

for harness_dir in "${HARNESS_DIRS[@]}"; do
  mkdir -p "$harness_dir"
  for skill in "${SKILLS[@]}"; do
    ensure_link "$harness_dir/$skill" "$CANONICAL_DIR/$skill"
  done
done

if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backups written to: $BACKUP_DIR"
fi

echo "Done. Shared skills are in: $CANONICAL_DIR"
