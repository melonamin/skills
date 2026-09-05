---
name: agterm
description: Control or troubleshoot the agterm desktop terminal through agtermctl: sessions, panes, workspaces, windows, overlays, HUD, native picker, inline images, keymaps, and status events. Use for explicit agterm operations or an agterm session's control socket; not generic terminal commands or browser screenshots.
---

# agterm control

Check AGTERM_ENABLED and the actual socket/session environment before assuming control is available. Inspect agtermctl tree --json and resolve the target before mutation. For operations on this agent's session, pass --target "$AGTERM_SESSION_ID"; active means the user's selected GUI session and is usually not yours.

Read [environment and inherited-daemon pitfalls](guide-am-i-inside-agterm.md) and [addressing](guide-addressing.md) before session operations. Long-lived daemons can inherit stale AGTERM_* identifiers; scrub those variables before launching such daemons and verify the actual target.

Launch programs with session new --command or scratch --command. Do not type shell commands into a shared input buffer as a launcher. Read [launching programs](guide-launching-a-program-in-a-session.md) for the exact form.

Use agtermctl <area> <command> --help for current flags. Options follow the subcommand. Preserve the requested session/window state and verify mutations through the control tree. Do not post bug reports without authorization.

## Read only the relevant guide

- [Introduction](guide-introduction.md)
- [Am I inside agterm?](guide-am-i-inside-agterm.md)
- [Running agtermctl](guide-running-agtermctl.md)
- [The model](guide-the-model.md)
- [Addressing](guide-addressing.md)
- [Launching a program in a session](guide-launching-a-program-in-a-session.md)
- [Command summary (74 commands)](guide-command-summary-74-commands.md)
- [Displaying an image inline](guide-displaying-an-image-inline.md)
- [Troubleshooting and reporting](guide-troubleshooting-and-reporting.md)
- [Linux integration management](guide-linux-integration-management.md)
- [Reference files](guide-reference-files.md)
