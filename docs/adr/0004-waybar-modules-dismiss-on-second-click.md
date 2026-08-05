---
status: accepted
---

# Waybar launcher modules dismiss on a second click

Omarchy's bar modules call `omarchy-launch-*` / `omarchy-launch-or-focus-tui`,
which by design *focus* an existing window instead of dismissing it. Since Waybar
takes no keyboard focus, the window was usually already focused, so clicking a
module whose panel was open appeared to do nothing. Every such module now goes
through a Toggle wrapper that makes the second click a dismissal.

## Consequences

Each wrapper decides for itself whether "dismiss" means close or hide, based on
restart cost — this is deliberately not uniform:

- `window-toggle <class> <cmd…>` **closes**. Used for `bluetooth` and `network`.
  bluetui and impala are cheap to restart and poll live hardware, so a stale
  hidden copy would be worse than a fresh one.
- `calendar-toggle` **hides**, on a dedicated `calendar` special workspace.
  GNOME Calendar talks to evolution-data-server on startup, so a cold launch
  costs seconds, and hiding also preserves the scrolled-to month. See ADR-0006.
- `menu-toggle` closes, and additionally needs a 400 ms grace window.

That grace window is the subtle part. Waybar dispatches `on-click` from a GTK
gesture that completes on button **release**, while Walker can already be tearing
itself down from having lost focus on button **press**. By the time the handler
runs there may be no Walker process left to find, so a naive check reopens the
menu — indistinguishable from "the second click did nothing". `menu-toggle`
therefore records when the menu last went away and refuses to reopen inside the
grace window. Omarchy's own `toggle_existing_menu()` is correct from a shell and
insufficient from a click for exactly this reason.

A related trap, found the hard way: `pgrep -f` matches whole command lines, so it
also matches any shell whose text merely *contains* the pattern — including the
wrapper's own callers. Candidates are confirmed against `/proc/PID/comm`. Before
that, it closed menus that were never open and killed two shells outright.

Incomplete: `pulseaudio` and `cpu` are still wired straight to their launchers.
See ADR-0011.
