## Running agtermctl

`agtermctl` must be on PATH. On macOS, install it from agterm's **Help ▸ Install Command Line Tool…**;
on Linux, use **Preferences ▸ Integrations**. If it is not on PATH, the user can install it, or you
invoke it by absolute path.

- The socket path auto-resolves; usually no `--socket` is needed. To be explicit, pass
  `--socket "$AGTERM_SOCKET"`.
- `--socket` and other options go **after** the subcommand: `agtermctl tree --json`, not
  `agtermctl --json tree`.
- Add `--json` to any command to get the raw JSON response (machine-readable). Without it, ordinary
  mutations print `ok`, batch close/move prints the affected session count, and `tree`/`list` print a
  human listing.
- Commands other than `events` make one request per invocation. `events` polls with a fresh connection
  for each request. Mutating commands return the affected/new id; batch session mutations return the
  number actually changed. Create commands (`session new`, `session duplicate`, `workspace new`,
  `window new`) print the new id.
