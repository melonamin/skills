## Key Guidelines

- **Use `wrangler.jsonc`**: Prefer JSON config over TOML. Newer features are JSON-only.
- **Set `compatibility_date`**: Preserve the existing date unless the task requires changing runtime behavior. Choose a supported date for a new project; review compatibility changes and test before advancing it. Check https://developers.cloudflare.com/workers/configuration/compatibility-dates/
- **Generate types after config changes**: Run `wrangler types` to update TypeScript bindings.
- **Local dev defaults to local storage**: Bindings use local simulation unless `remote: true`.
- **Profile Worker startup**: Run `wrangler check startup` to measure startup time and detect scripts that exceed the startup time limit.
- **Use environments for staging/prod**: Define `env.staging` and `env.production` in config.
