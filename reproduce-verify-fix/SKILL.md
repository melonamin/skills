---
name: reproduce-verify-fix
description: Use after a fix or PR branch is already implemented when the user asks Codex to independently reproduce the original issue on a pre-fix baseline, apply the current branch's fix, reload/reset local data if needed, verify the actual corrected behavior through both data-level checks and realistic browser/UI flows when user-visible behavior is involved, investigate any remaining failures, and report evidence back without changing product code. Triggers include "reproduce then test the fix", "verify this branch locally", "prove the issue is gone", "use local dev env", "test API and browser", "make screenshots", "human test this", or "generate a report".
---

# Reproduce Verify Fix

## Objective

Act as a post-implementation verifier. Do not implement product fixes. Prove whether the already-existing branch fixes the reported issue.

Required outcome:

1. Restore or create a pre-fix baseline environment.
2. Reproduce the original issue on that baseline.
3. Apply the fix from the current branch or switch back to the fixed branch.
4. Reload/reset data if needed.
5. Verify the issue is gone at the data/API level.
6. If the behavior is user-visible, verify it through the actual browser path a human would use.
7. Cross-check browser-visible values against API/database evidence.
8. Investigate and report any remaining issues without patching product code.

## Hard Rules

- Do not change product code to make verification pass.
- Do not commit, push, or post to GitHub.
- Do not edit the PR branch except for temporary, explicitly disposable artifacts under `.tmp/`, `tmp/`, or `/tmp`.
- Do not treat broad green tests as enough unless they cover the reported behavior.
- Do not treat a page-load smoke check as UI verification. For UI-facing fixes, inspect the actual affected screen, rows, cells, links, controls, and states.
- Do not use mocked UI routes as the primary proof when the bug depends on real backend data. Route mocks are supporting evidence only.
- Do not claim "safe to merge" unless the original behavior was reproduced, the fixed behavior was verified through representative data, and every user-visible effect was exercised in the browser.
- If verification fails, investigate the nature of the failure and report it. Stop short of implementing the fix unless the user explicitly changes the task.
- Use `agent-browser` for manual browser verification of user-visible behavior, even when Playwright also runs.
- Take screenshots for UI verification of the actual affected state, not just generic app pages.
- Generate an HTML report only when UI screenshots are present. Otherwise report in the final response or a plain text/Markdown artifact if useful.

## Workflow

### 1. Define Verification Scope

Restate concrete success criteria:

- Issues, review comments, or symptoms to reproduce.
- Baseline ref that should fail: merge base, `master`, previous PR commit, or tagged release.
- Fixed ref: usually the current branch/HEAD.
- Required verification surfaces: API, database, workers, browser, CLI, background jobs.
- Local data requirements: seed, reset, reload, backfill, mock API routes, or imported fixtures.
- Representative records that must be inspected by ID/name in both data/API and UI.
- Expected UI observations: table values, tags, badges, disabled states, link hrefs, network calls, drill-down pages, chart points, or error states.
- Report artifacts requested or implied.

For each issue, create a verification matrix before testing:

```text
Issue/symptom:
Baseline proof:
Fixed data/API proof:
Fixed browser proof:
Representative record(s):
Screenshots/network evidence:
```

Inspect linked issue/PR context when available, but do not post comments.

### 2. Preserve and Isolate State

Start with:

```bash
git status --short --branch
git log --oneline -5
```

Prefer disposable worktrees for baseline reproduction:

```bash
git worktree add .worktrees/repro-base <baseline-ref>
```

Use separate temp files for verification-only harnesses:

- `/tmp/<task>-regression.patch`
- `.tmp/repro-verify/<timestamp>/`

If the current branch has uncommitted user changes, do not overwrite them. Use worktrees or read-only inspection.

### 3. Reproduce on Baseline

Restore the local environment to the pre-fix state as needed:

- Checkout/use the baseline worktree.
- Reset or reload the database only when the user allowed it or the task requires it.
- Seed the smallest data that shows the bug.
- Run the narrowest command or browser path that should fail.
- When the bug affects displayed data, identify the exact database rows or API objects that should be wrong before opening the UI.

If the current branch already contains regression tests, copy only those tests or a temporary verifier into the baseline worktree. Do not copy product code.

Acceptable reproduction evidence:

- Failing API/integration/unit command with relevant assertion.
- Direct database query showing the incorrect stored or derived state.
- Direct API request returning wrong shape/status/data.
- Browser screenshot and/or network trace showing the wrong user-visible behavior on the actual affected page.
- Logs proving worker/data-pipeline failure.

Record exact commands, refs, data setup, and key failure lines.

### 4. Apply Current Branch Fix

Return to the fixed branch or apply its diff to the disposable baseline environment.

Preferred options:

- Verify directly on the current branch/HEAD.
- Or apply branch diff into the baseline worktree when you need the exact same seeded environment:

```bash
git diff <baseline-ref>...HEAD > /tmp/current-branch-fix.patch
(cd .worktrees/repro-base && git apply /tmp/current-branch-fix.patch)
```

Reload/recompute data if the fix affects migrations, transforms, materialized metrics, caches, or frontend bundles.

### 5. Verify the Fix

Run the same reproduction check again after applying the fix. Then add any supporting gates that cover the changed surface.

Use this priority order:

- Database queries for the exact corrected rows or derived records.
- Direct API requests for the exact endpoint and payload the UI consumes.
- Worker/transform commands when persisted or derived data is part of the fix.
- Browser tests and `agent-browser` sessions for UI correctness.
- Screenshots for actual UI state changes, disabled/enabled controls, charts, table cells, links, or layout.
- Lint/typecheck only as supporting evidence, not the main proof.

Required minimum proof:

- Backend-only fix: baseline failure plus fixed data/API proof against representative records.
- UI-only fix: baseline failure plus browser proof on the actual affected page, with network or DOM evidence.
- Full-stack or user-visible backend fix: baseline failure plus both fixed data/API proof and fixed browser proof. The API/database values must be tied to what is seen in the browser.

For browser work:

- Start local dev servers when needed.
- Prefer realistic local data; use route mocks only when they directly isolate the UI behavior under test.
- Navigate as a user would: login if needed, open the relevant list/detail page, select filters/time ranges/tabs, click the affected links or controls, and inspect the visible result.
- If seeded data does not naturally expose the issue, create or load representative local data, then verify it through the same API and browser path.
- Capture network requests or DOM text when screenshots alone do not prove the behavior.
- Capture screenshots into `.tmp/repro-verify/<timestamp>/screenshots/`.
- If screenshots are captured, generate `.tmp/repro-verify/<timestamp>/report.html` with: scope, baseline failure, fixed result, screenshots, commands, and unresolved findings.

Do not count these as sufficient browser proof:

- Only loading the homepage, overview page, or unrelated list page.
- Only confirming the dev server starts.
- Only relying on a Playwright route mock when real API/database behavior is in scope.
- Only checking that no console errors appear.

### 6. Investigate Failures Without Fixing

If the fixed branch still fails:

- Determine whether it is a product regression, bad test, bad fixture, environment issue, or incomplete data reload.
- Inspect code, logs, network requests, API responses, DB rows, and screenshots as needed.
- Rerun narrowly after correcting only environment/test harness mistakes.
- Do not patch product code.
- Report the suspected root cause and the smallest evidence trail.

### 7. Cleanup

Before final response:

- Stop local servers.
- Remove temporary worktrees unless they contain artifacts the user asked to keep.
- Keep report/screenshots if generated.
- Confirm `git status --short --branch`.
- List any remaining temp artifacts.

## Final Report Shape

Use this structure:

```text
Scope:
- <issues/symptoms verified>

Baseline reproduction:
- Ref: <baseline-ref>
- Data/env: <reset/seed/reload summary>
- Result: failed as expected, <key evidence>

Fixed verification:
- Ref: <fixed-ref>
- Data/API result: passed/failed, <record IDs, endpoint, key values>
- Browser result: passed/failed/not applicable, <page path, UI state, screenshots>

Commands:
- <command>: <passed/failed>

Browser/UI evidence:
- <screenshot path or HTML report path, only if applicable>

Findings:
- <remaining issue or "No remaining issue found in verified data/API and browser scope">

Cleanup:
- <servers stopped/worktrees removed/status clean>
```

## Product References

For LakeSentry-specific local commands, read `references/lakesentry.md`.
