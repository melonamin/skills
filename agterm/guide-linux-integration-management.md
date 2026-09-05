## Linux integration management

Linux builds expose local installation inspection separately from the 60 runtime control commands.
These commands never connect to the socket and work while agterm is stopped:

```bash
agtermctl integration status [--json]
agtermctl integration install hooks [--dry-run] [--json]
agtermctl integration install skill [--dry-run] [--json]
```

Use `--dry-run` before a mutation and show the user the plan when acting on their environment.
The engine refuses unrelated executables, hooks, settings, and skills rather than overwriting them.
See **reference.md** for the JSON shapes, states, package behavior, and exit statuses.
