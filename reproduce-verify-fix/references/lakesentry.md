# LakeSentry Reproduce/Verify Reference

Use this only in the `lakesentry/lakesentry` repo.

## Local Dev

Common commands:

```bash
just docker-up-db
just db-migrate
just db-reset
just seed-e2e-user
```

Start local API and web on alternate ports to avoid conflicts:

```bash
(cd api && PORT=8099 WEB_PORT=3099 go run ./cmd/api)
(cd web && WEB_PORT=3099 PORT=8099 WEB_API_PROXY_TARGET=http://localhost:8099 yarn dev --host 127.0.0.1)
```

Stop both long-running sessions before final response.

Suggested artifact directory:

```bash
mkdir -p .tmp/repro-verify/$(date +%Y%m%d-%H%M%S)
```

## API Verification

Focused Go checks commonly used for Jobs & Pipelines:

```bash
cd api && go test ./internal/api ./internal/workers
cd api && go test -tags=integration ./internal/integration -run 'TestWorkUnitAPI|TestWorkUnitRunsSelectedPeriodP95Tags|TestLedgerTransformWorkUnitNameReconciliation'
```

If a temporary worktree lacks generated raw system schemas:

```bash
uv run --with pyyaml scripts/generate_system_schemas.py
```

## Web Verification

Focused web checks:

```bash
yarn --cwd web lint
yarn --cwd web typecheck
yarn --cwd web vitest run src/__tests__/<test>.test.ts
PLAYWRIGHT_BASE_URL=http://127.0.0.1:3099 WEB_PORT=3099 PLAYWRIGHT_WORKERS=1 yarn --cwd web playwright test tests/e2e/<spec>.spec.ts --project=authenticated -g '<test name>'
```

Playwright auth setup depends on `just seed-e2e-user`.

For manual browser verification, use the `agent-browser` skill. Save screenshots under the repro-verify artifact directory, and generate an HTML report only if screenshots were captured.

## GitHub Context

Inspect GitHub issues/PRs for context only. Do not post comments from this skill.

```bash
gh issue view <id> --json number,title,body,state,labels,url
gh pr view <id> --json url,headRefName,baseRefName,commits,state,title
```
