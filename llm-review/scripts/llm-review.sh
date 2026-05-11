#!/usr/bin/env bash
# llm-review.sh — parallel LLM code review using codex (OpenAI) + claude (Anthropic).
# Usage:
#   llm-review.sh             # uncommitted (staged + unstaged + untracked)
#   llm-review.sh <ref>       # current branch vs <ref> (e.g. master, main, HEAD~3)
#
# Requires: codex on PATH, claude on PATH, OPENAI_API_KEY, ANTHROPIC_API_KEY.

set -euo pipefail

REF="${1:-}"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# ---- Review prompt (shared by both reviewers) -------------------------------
# Edit the priorities/format here to tune what the reviews focus on.
read -r -d '' PROMPT <<'PROMPT_EOF' || true
Perform a code review of the changes. Prioritize findings in this order:

1. Correctness bugs — off-by-one, nil deref, race conditions, swallowed errors,
   incorrect concurrency, broken edge cases.
2. Security — injection, auth bypass, secret leakage, unsafe deserialization,
   missing validation on trust boundaries.
3. Architecture / design — over-engineering, inconsistent patterns vs the rest
   of the codebase, leaky abstractions, premature generalization.
4. Performance — N+1 queries, unnecessary allocations, blocking I/O on hot path.

Skip pure style nits unless they hurt maintainability. Reference file:line where
possible. Be direct and brief. No filler ("It's important to note...", "overall
this is a great change", etc.).

Output format:
- **Critical** — must fix (numbered list, file:line, what + why + suggestion)
- **Important** — should fix
- **Minor** — nice to have
- **Verdict** — one sentence: ship, ship-with-fixes, or block.

Omit any section that has no findings. If everything is clean, just write
"Verdict: ship" and stop.
PROMPT_EOF

# Append project-specific guidelines if present (looked up at git root).
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$GIT_ROOT" && -f "$GIT_ROOT/REVIEW_GUIDELINES.md" ]]; then
  PROMPT+=$'\n\n--- Project review guidelines ---\n'
  PROMPT+=$(cat "$GIT_ROOT/REVIEW_GUIDELINES.md")
fi

# ---- Decide mode and build claude diff -------------------------------------
if [[ -z "$REF" ]]; then
  CODEX_FLAGS=(--uncommitted)
  MODE="uncommitted (staged + unstaged + untracked)"
  CLAUDE_DIFF=$(git diff HEAD)
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    CLAUDE_DIFF+=$'\n\n=== '"$f"$' (untracked) ===\n'
    if file --mime "$f" 2>/dev/null | grep -q "charset=binary"; then
      CLAUDE_DIFF+="[binary file omitted]"
    else
      CLAUDE_DIFF+=$(sed 's/^/+/' "$f" 2>/dev/null || echo "[unreadable]")
    fi
  done < <(git ls-files --others --exclude-standard)
else
  if ! git rev-parse --verify "$REF" >/dev/null 2>&1; then
    echo "error: ref '$REF' not found" >&2
    exit 2
  fi
  CODEX_FLAGS=(--base "$REF")
  MODE="HEAD vs $REF"
  CLAUDE_DIFF=$(git diff "$REF"...HEAD)
fi

if [[ -z "${CLAUDE_DIFF// }" ]]; then
  echo "no changes to review (mode: $MODE)" >&2
  exit 0
fi

echo "Reviewing: $MODE" >&2
echo "Running codex (OpenAI) and claude (Anthropic) in parallel..." >&2

# ---- Run both reviewers in parallel ----------------------------------------
# Note: `codex review --uncommitted` and `codex review --base <ref>` cannot
# accept a custom prompt arg (mutually exclusive in codex CLI). Codex uses its
# built-in review prompt for these modes. Claude uses our custom $PROMPT below
# with the diff bundled in. Asymmetric but unavoidable.
(
  codex review "${CODEX_FLAGS[@]}" \
    >"$TMPDIR/codex.out" 2>"$TMPDIR/codex.err"
  echo $? >"$TMPDIR/codex.rc"
) &
CODEX_PID=$!

CLAUDE_PROMPT="$PROMPT

--- Mode ---
$MODE

--- Diff ---
\`\`\`diff
$CLAUDE_DIFF
\`\`\`"

(
  printf '%s' "$CLAUDE_PROMPT" | claude --bare -p \
    >"$TMPDIR/claude.out" 2>"$TMPDIR/claude.err"
  echo $? >"$TMPDIR/claude.rc"
) &
CLAUDE_PID=$!

wait $CODEX_PID || true
wait $CLAUDE_PID || true

CODEX_RC=$(cat "$TMPDIR/codex.rc" 2>/dev/null || echo 1)
CLAUDE_RC=$(cat "$TMPDIR/claude.rc" 2>/dev/null || echo 1)

# ---- Print both reviews ----------------------------------------------------
print_section() {
  local title="$1" rc="$2" out="$3" err="$4"
  echo
  echo "═══════════════════════════════════════════════════════════════"
  echo "  $title"
  echo "═══════════════════════════════════════════════════════════════"
  if [[ "$rc" -eq 0 ]]; then
    cat "$out"
  else
    echo "[$title failed with exit $rc]"
    cat "$err" >&2 || true
  fi
}

print_section "Codex (OpenAI)"     "$CODEX_RC"  "$TMPDIR/codex.out"  "$TMPDIR/codex.err"
print_section "Claude (Anthropic)" "$CLAUDE_RC" "$TMPDIR/claude.out" "$TMPDIR/claude.err"

# Exit non-zero only if BOTH failed (single-reviewer output is still useful).
if [[ "$CODEX_RC" -ne 0 && "$CLAUDE_RC" -ne 0 ]]; then
  exit 1
fi
