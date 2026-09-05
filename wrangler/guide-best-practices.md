## Best Practices

1. **Version control `wrangler.jsonc`**: Treat as source of truth for Worker config.
2. **Use automatic provisioning**: Use the project's established resource provisioning and explicit environment targeting; opt into automatic provisioning only when intended.
3. **Run `wrangler types` in CI**: Add to build step to catch binding mismatches.
4. **Use environments**: Separate staging/production with `env.staging`, `env.production`.
5. **Set `compatibility_date`**: Advance deliberately after reviewing runtime changes and validating the application, not as an incidental CLI task.
6. **Use `.dev.vars` for local secrets**: Never commit secrets to config.
7. **Test locally first**: `wrangler dev` with local bindings before deploying.
8. **Use `--dry-run` before major deploys**: Validate changes without deployment.
9. **Never embed secrets in commands**: Use interactive prompts (`wrangler secret put`), file-based input (`wrangler secret bulk`), or secure CI environment variables. Never echo, log, or pass secret values as CLI arguments.
