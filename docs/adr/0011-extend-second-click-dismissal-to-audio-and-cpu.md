---
status: proposed
---

# Extend second-click dismissal to the audio and CPU modules

ADR-0004 gave Second-click dismissal to `custom/omarchy`, `bluetooth`, `network`
and `custom/calendar`. Two right-side modules were never converted and still call
their launcher raw, so clicking them a second time does nothing:

| Module | Current `on-click` | Opens |
|---|---|---|
| `pulseaudio` | `omarchy-launch-audio` | wiremix |
| `cpu` | `omarchy-launch-or-focus-tui btop` | btop |

Both are the same shape as `bluetooth` and `network` — a TUI in a floating
toplevel, cheap to restart, showing live state that should not go stale in a
hidden window — so both want `window-toggle`, the closing variant, not
`calendar-toggle`'s hiding variant.

## To settle at grill time

- The window class for each. `window-toggle` matches on `.class` from
  `hyprctl clients`, and the existing entries use Omarchy's own reverse-DNS
  classes (`org.omarchy.bluetui`, `org.omarchy.impala`). The audio and btop
  classes need reading off a live window, not guessing — `omarchy-launch-audio`
  runs wiremix, and `omarchy-launch-or-focus-tui` sets the class itself.
- Whether `cpu`'s existing `on-click-right = alacritty` stays. It looks like a
  leftover rather than a decision.
- `battery` is deliberately excluded: its `on-click` is `omarchy-menu power`, a
  Walker menu, not a window. If it ever wants dismissal it needs the
  `menu-toggle` grace-window treatment, not `window-toggle`.
