## Launching a program in a session

**Bind it at creation.** `session new --command` (and `scratch --command`) makes the program the session
process, so no shell line is involved:

```bash
agtermctl session new --cwd ~/proj --name worker \
  --command "zsh -lc 'claude \"\$(cat ~/brief.md)\"'"   # GUI PATH: wrap a non-default binary
```

`session type` drives an ALREADY-RUNNING program — it is not a launcher. Its keystrokes land in a line
buffer you do not own: a newline submits (a multi-line brief becomes N premature Enters), and the user
or a concurrent agent writes to that same buffer. An untargeted `session type` from another agent hits
whatever is `active`, and `session new` focuses — so a just-created session is briefly `active`, a stray
prompt concatenates with yours, and the program starts on the merged line. (`--no-select` skips the
focus, but the newline and shared-buffer hazards of `type`-as-launcher remain — `--command` is still the
rule.) After `--command`, confirm in `tree --json` that the new node's `foreground` shows your program running, not a bare shell prompt.
