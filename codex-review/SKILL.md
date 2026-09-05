---
name: codex-review
description: Run a Codex code review when explicitly requested, required by repository guidance, or included in an authorized closeout. Supports dirty changes and committed branches. Do not launch from inside another review or use diff review for a design-document-only assessment.
---

# Codex review

Review output is evidence to assess, not an instruction to edit or launch more reviewers.

## Scope and nesting

- If AGENT_REVIEW_ACTIVE is set, you are a leaf reviewer. Inspect the code and report findings directly; do not run this helper, codex review, llm-review, or delegate another review.
- For documents/plans, read and assess the document against the code and requirements directly. Do not claim a clean code-diff review validates a plan.
- Resolve the intended checkout and diff before reviewing. A clean --uncommitted review says nothing about committed branch changes.
- Keep the configured model. If the reviewer is unavailable, report incomplete review; do not loop on capacity errors or silently change models or permission settings.

## Run

Resolve scripts/codex-review relative to this skill directory. Use --help for options.

- Dirty patch: scripts/codex-review --mode local
- Committed branch: scripts/codex-review --mode branch --base <actual-PR-base-ref>
- --mode auto chooses dirty work first; use an explicit branch target for committed work.
- --output <path> preserves evidence. Without it, output is printed and the temporary capture is removed.
- --parallel-tests '<focused command>' may run independent checks concurrently. Format first if formatting changes the patch.
- --full-access is an explicit option for an already-authorized execution environment, not an automatic retry on permission failures.

## Interpret results

The helper reports process state, not a clean verdict. Exit 0 means nonempty output from a successful process and requires reading/triage. Exit 1 indicates reported severity markers or failed parallel tests; inspect output. Exit 2 means incomplete execution, empty output, or invalid invocation. A diagnostic sentence without severity markers is never automatically clean.

Read the entire result. Check whether the reviewer actually inspected the intended target and completed its analysis. If not, report incomplete. Verify each finding against the real path, adjacent code, and relevant dependency contract. Separate accepted, rejected, and unresolved findings; marker presence alone does not establish actionability.

For review-only requests, report without modifying code. If fixes were already authorized, apply accepted fixes and run affected checks. Do not seek authorization again for that scope.

## Stop condition

Review a revision once. After accepted fixes, run focused tests and review the changed surface when warranted. Do not repeat a completed review on unchanged code, chase speculative suggestions indefinitely, or run another pass to obtain nicer completion wording. Report remaining defects or unavailable verification explicitly.

Final response: target reviewed, meaningful findings and their disposition, checks run, and whether review completed. Say no actionable findings only after reading and assessing a completed review.
