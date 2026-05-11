---
name: llm-review
description: Run an LLM code review (OpenAI Codex + Anthropic Claude in parallel) on uncommitted changes or against a base ref. Use when user asks to "review my changes", "review uncommitted", "review against <ref>", "code review", "LLM review", "review branch vs <ref>", "second opinion on this diff".
allowed-tools: Bash, Read
---

# LLM Code Review

Runs **two independent LLM reviewers in parallel** (OpenAI Codex CLI and Anthropic Claude CLI) on the current diff and presents both reviews. Cross-vendor coverage catches issues a single model misses.

## Activation Triggers

- "review my changes", "review uncommitted"
- "review against <ref>", "review vs <ref>", "review branch vs main"
- "code review", "LLM review", "second opinion on this diff"
- "run the reviewers"

## Usage

```bash
~/.claude/skills/llm-review/scripts/llm-review.sh           # uncommitted
~/.claude/skills/llm-review/scripts/llm-review.sh master    # current branch vs master
~/.claude/skills/llm-review/scripts/llm-review.sh HEAD~3    # last 3 commits
```

## Workflow

1. **Run the script** with the appropriate arg.
2. **Read both reviews end-to-end** — they're printed under `Codex (OpenAI)` and `Claude (Anthropic)` headers. They will overlap on critical issues and diverge on judgment calls.
3. **Synthesize for the user**: present a merged summary with these sections:
   - **Critical (both flagged)** — high confidence, fix first
   - **Critical (one flagged)** — investigate, may be a false positive but worth checking
   - **Important** — should fix
   - **Minor** — optional
   - **Disagreements** — where the two reviewers conflict, with your read on which is right
4. **Wait for user approval** before making any code changes. Never start editing based on the review output without an explicit go-ahead.
5. **After fixes**, re-run the script to verify the issues were addressed and no regressions were introduced.

## Project Customization

If the repo has a `REVIEW_GUIDELINES.md` at the git root, the script appends its contents to the review prompt automatically. Use this for project-specific patterns (sqlc usage, error wrapping, test conventions, etc.).

## Tuning the Review Prompt

The prompt in `scripts/llm-review.sh` (between `PROMPT_EOF` markers) is sent **only to Claude**. Codex's `review` subcommand does not accept custom prompts when used with `--uncommitted` or `--base` (CLI restriction), so codex uses its built-in review prompt. This means the two reviewers may emphasize different things — that's actually useful for cross-coverage.

## Failure Handling

- If **one** reviewer fails (network, rate limit, missing key), the script still prints the other and exits 0.
- If **both** fail, the script exits 1.
- Common causes: `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` not set, codex/claude not on PATH, ref doesn't exist.

## Requirements

- `codex` CLI on PATH (OpenAI Codex CLI)
- `claude` CLI on PATH
- `OPENAI_API_KEY` env var
- `ANTHROPIC_API_KEY` env var
- Git repo with the requested diff scope

## Notes

- Claude is invoked with `--bare -p` to skip hooks, plugins, and memory loading — the subprocess won't recursively trigger your parent session's hooks.
- Codex uses its built-in `codex review --uncommitted` / `codex review --base <ref>` modes, which compute the diff themselves; we don't pipe it.
- The script does not modify any files. It only reads the diff and prints to stdout.
