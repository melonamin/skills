---
name: llm-review
description: Run independent Codex and Claude reviews when the user explicitly requests both providers, an LLM review, or this skill. Supports uncommitted changes or a base ref. Do not invoke from a reviewer or for ordinary review requests that do not need two providers.
---

# Two-provider code review

Resolve scripts/llm-review.sh relative to this skill directory. Run without arguments for the dirty patch, or pass the actual base ref for committed work. Both CLIs must be available and authenticated through their configured login or credentials; API keys are not inherently required.

If AGENT_REVIEW_ACTIVE is set, review directly without launching this workflow or another reviewer. The script exports the guard to its children and rejects nested helper calls.

1. Confirm the checkout and diff scope. Read repository review guidance.
2. Run the helper once and read both outputs. It preserves exact provider exit statuses and nonempty output even when one fails.
3. Check completion separately for each provider. Exit 0 means both processes returned nonempty output, not that either review is clean. Exit 2 means at least one reviewer failed or returned no output. Assess diagnostic-only text as incomplete even with a zero exit status.
4. Verify findings against the code. Prioritize by consequence and evidence; agreement between models does not determine severity.
5. Report a merged result, disagreements, and incomplete providers. For review-only requests, do not edit. If fixes are already authorized, apply accepted fixes without asking again.
6. After edits, rerun affected checks and only the necessary focused review. Never rerun an unchanged revision solely for confirmation.

The script uses native Codex diff review and Claude print mode with a supplied diff, skills disabled, and session hooks disabled. REVIEW_GUIDELINES.md at the repository root is included in Claude's prompt. Codex reads its own repository guidance. The two review contexts are not identical; report that limitation when it affects findings.
