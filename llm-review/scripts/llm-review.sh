#!/usr/bin/env bash
# llm-review.sh — parallel LLM code review using codex (OpenAI) + claude (Anthropic).
# Usage:
#   llm-review.sh             # uncommitted (staged + unstaged + untracked)
#   llm-review.sh <ref>       # current branch vs <ref> (e.g. master, main, HEAD~3)
#
# Requires authenticated codex and claude CLIs on PATH.
# Exit 0: both processes produced output; triage required (not a clean verdict).
# Exit 2: invalid invocation, nested review, or incomplete provider output.

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo 'usage: llm-review.sh [base-ref]' >&2
  exit 2
fi
if [[ -n "${AGENT_REVIEW_ACTIVE:-}" ]]; then
  echo 'review incomplete: nested review helper invocation refused; inspect code directly' >&2
  exit 2
fi
REF="${1:-}"
review_tmp_dir=$(mktemp -d)
CODEX_PID=
CLAUDE_PID=
cleanup() {
  # Only terminate children launched by this invocation, if still running.
  for pid in "$CODEX_PID" "$CLAUDE_PID"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  rm -rf "$review_tmp_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# ---- Review prompt (shared by both reviewers) -------------------------------
# Edit the priorities/format here to tune what the reviews focus on.
read -r -d '' PROMPT <<'PROMPT_EOF' || true
You are a leaf reviewer. Inspect code directly; do not invoke review helpers, codex review, or delegate another review. Do not edit files.

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
  while IFS= read -r -d '' f; do
    [[ -z "$f" ]] && continue
    CLAUDE_DIFF+=$'\n\n=== '"$f"$' (untracked) ===\n'
    if file --mime "$f" 2>/dev/null | grep -q "charset=binary"; then
      CLAUDE_DIFF+="[binary file omitted]"
    else
      CLAUDE_DIFF+=$(sed 's/^/+/' "$f" 2>/dev/null || echo "[unreadable]")
    fi
  done < <(git ls-files --others --exclude-standard -z)
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
AGENT_REVIEW_ACTIVE=1 codex review "${CODEX_FLAGS[@]}" \
  >"$review_tmp_dir/codex.out" 2>"$review_tmp_dir/codex.err" &
CODEX_PID=$!

CLAUDE_PROMPT="$PROMPT

--- Mode ---
$MODE

--- Diff ---
\`\`\`diff
$CLAUDE_DIFF
\`\`\`"

printf '%s' "$CLAUDE_PROMPT" >"$review_tmp_dir/claude.prompt"
AGENT_REVIEW_ACTIVE=1 claude --disable-slash-commands --no-session-persistence \
  --settings '{"disableAllHooks":true}' -p <"$review_tmp_dir/claude.prompt" \
  >"$review_tmp_dir/claude.out" 2>"$review_tmp_dir/claude.err" &
CLAUDE_PID=$!

CODEX_RC=0
wait "$CODEX_PID" || CODEX_RC=$?
CODEX_PID=
CLAUDE_RC=0
wait "$CLAUDE_PID" || CLAUDE_RC=$?
CLAUDE_PID=

# ---- Print both reviews ----------------------------------------------------
print_section() {
  local title="$1" rc="$2" out="$3" err="$4"
  echo
  echo "═══════════════════════════════════════════════════════════════"
  echo "  $title"
  echo "═══════════════════════════════════════════════════════════════"
  printf 'process exit: %s\n' "$rc"
  cat "$out"
  if [[ "$rc" -ne 0 ]]; then
    echo "[$title incomplete]"
  elif ! grep -q '[^[:space:]]' "$out"; then
    echo "[$title incomplete: no output]"
  else
    echo "[$title result requires triage; process success is not a clean verdict]"
  fi
  if [[ -s "$err" ]]; then cat "$err" >&2; fi
}

print_section "Codex (OpenAI)"     "$CODEX_RC"  "$review_tmp_dir/codex.out"  "$review_tmp_dir/codex.err"
print_section "Claude (Anthropic)" "$CLAUDE_RC" "$review_tmp_dir/claude.out" "$review_tmp_dir/claude.err"

# Preserve partial results, but never report partial execution as successful.
if [[ "$CODEX_RC" -ne 0 || "$CLAUDE_RC" -ne 0 ]] ||
   ! grep -q '[^[:space:]]' "$review_tmp_dir/codex.out" ||
   ! grep -q '[^[:space:]]' "$review_tmp_dir/claude.out"; then
  echo 'review incomplete: at least one provider failed or returned no output' >&2
  exit 2
fi
echo 'review verdict: untriaged; read both outputs and assess completion/findings'
