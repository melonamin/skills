## Displaying an image inline

This skill bundles `scripts/show-image.sh`. It opens an overlay (a real terminal) and renders the
image there via the kitty graphics protocol, which ghostty draws natively — no kitty binary and no
external image tool, just `base64` + `printf`. Run it with the image path (optional size percent,
default 60):

The script sits next to this file, so resolve `scripts/show-image.sh` against the directory this
`SKILL.md` was loaded from — not against your working directory. That one form is correct wherever
the skill came from: a plugin install (`~/.claude/plugins/cache/…`, `~/.codex/plugins/cache/…`) or the
app's own **Help ▸ Install Agent Skill…** copy (`~/.claude/skills/agterm/`, `~/.codex/skills/agterm/`).

```bash
bash <this-skill-directory>/scripts/show-image.sh <image> [size-percent]
```

The size percent sizes the overlay PANEL; the image itself is scaled to fit that panel and centered
in it, so a large screenshot needs no resizing beforehand.

Do NOT print graphics escapes to your own tool stdout (the agent harness escapes the control bytes)
and do NOT run an image viewer in your tool shell (no controlling terminal). The overlay is what makes
it render. Outside agterm (`AGTERM_ENABLED` unset) there is no overlay — fall back to `open <image>`.
