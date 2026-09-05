## Am I inside agterm?

Each shell agterm spawns gets these environment variables. Check `AGTERM_ENABLED` before assuming
the control channel is available:

- `AGTERM_ENABLED=1` — this shell runs inside agterm.
- `AGTERM_SESSION_ID` — the current session's UUID (the session this shell belongs to).
- `AGTERM_WINDOW_ID` / `AGTERM_WORKSPACE_ID` — the owning window / workspace UUIDs.
- `AGTERM_SOCKET` — the absolute path to the control socket this app bound.
- `AGTERM_PANE` / `AGTERM_PANE_ID` — the surface's pane role (`left`|`right`|`scratch`) and a stable
  per-surface token; the agent-status hook forwards them as `session status --pane` / `--pane-id`. The
  token resolves the pane's LIVE slot, so a promoted-then-re-split agent still tags the right pane.

The quick terminal is scratch (not in the tree), so it only gets `AGTERM_ENABLED`, `AGTERM_WINDOW_ID`,
and `AGTERM_SOCKET` (no session/workspace ids).

These variables are inherited by every process the session's shell spawns — including long-lived
daemons that outlive the shell. A tmux/screen server, a session manager (agent-deck and the like), or
any background service started from inside a session captures the spawning session's `AGTERM_*` and
passes it to every child it ever creates, so status hooks running in those children resolve
`$AGTERM_SESSION_ID` to the session that happened to start the daemon and report to the WRONG session.
Before starting such a process from inside agterm, scrub the variables
(`env -u AGTERM_ENABLED -u AGTERM_PANE -u AGTERM_PANE_ID -u AGTERM_SESSION_ID -u AGTERM_SOCKET -u AGTERM_WINDOW_ID -u AGTERM_WORKSPACE_ID <cmd>`);
see troubleshooting.md ("agent-status glyph updates the wrong session") for diagnosing and fixing an
already-poisoned tmux server.
