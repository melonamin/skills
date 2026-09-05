## The model

A **window** is the top level: a named bundle rendered in its own on-screen native window. Each window
holds a tree of **workspaces**, each holding **sessions**. A session has a primary shell and can also
have: a **split** pane (a second shell side by side), a **scratch** terminal (a third full-coverage
shell, toggled like the split), and an ephemeral **overlay** (runs one program on top, then vanishes).
An overlay covers the whole session, or with `--pane left|right` exactly one split pane, leaving the
sibling pane visible and usable. The same session-wide slot also holds a **HUD** (`session hud`), a small
passive panel carrying a message instead of a program: the session keeps focus and stays typable under it.
One slot, so a session shows either a HUD or a program overlay, never both. Separately, each window has one
**quick terminal** (a scratch overlay at 90% of the window, not part of the tree).

Inspect the live tree any time with `agtermctl tree --json` (workspaces → sessions, each with
`id`, `name`, `cwd`, `title`, `active`, `split`, `overlay`, `hud`, `scratch`, `status`, `background`, `surfaces`). `title` is the raw OSC
terminal title (e.g. a remote host over SSH), omitted when none was reported — read it when a
session's local `cwd` is stale because it's connected to a remote. `surfaces[].id` is the
control address for `surface zoom` (`left`, `right`, `scratch`, `overlay`, `overlay-left`, or
`overlay-right`), including hidden-but-alive split/scratch surfaces. The tree object also carries five
read-only top-level fields: `idleMs` (ms since the last user input in the window), `autoFollowMs`
(the Auto-follow timeout in ms, omitted when Disabled), `sidebarVisible` (whether the window's
sidebar is currently shown — the read side of the write-only `sidebar` command), `sidebarMode`
(`tree` or `flagged` — the read side of `sidebar mode`), and `quickVisible` (whether the window's quick
terminal is shown — the read side of the write-only `quick` command). List windows with
`agtermctl window list --json`; each window also reports `autoFollowMs`, `sidebarVisible`, `geometry`
(the live frame `{x, y, width, height, display}` in the units `window move`/`window resize` take — the
read side, so record it then restore the exact frame), and `fullscreen`/`zoomed`/`minimized` (the read side
of `window fullscreen`/`window zoom`/`window minimize`, so a script can act idempotently) — all omitted for
a closed window, but not the live `idleMs`, which is `tree`-only. A MINIMIZED window still reports its
`geometry` (the frame it comes back to), so a re-align script can include it.

On the GTK Linux frontend, window size is restored and clamped to a connected display, but `geometry`
is omitted because GTK4 cannot reliably read and restore x/y placement. Wayland compositors own window
positioning, and the frontend does not fabricate coordinates on X11.
