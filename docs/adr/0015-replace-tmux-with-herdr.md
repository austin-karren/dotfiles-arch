---
status: proposed
---

# Replace tmux with herdr

Intent: drop tmux and use **herdr** for session management instead. The tracked
`~/.config/tmux/tmux.conf` is 104 lines and would go with it.

> **Intent recorded, not yet grilled.** The *want* is settled; the *how* is
> deliberately undecided. Nothing below has been agreed — treat it as the
> question list for a later session, not as a plan.

## Unverified

`herdr` is not installed on this machine and I have not confirmed the project, so
nothing here should be treated as established: not its feature set, not whether it
is a tmux replacement in the persistent-remote-session sense or only a local
pane/window manager. **First step at grill time is identifying the actual project
and reading its docs** — the name is close enough to several other tools that
guessing would be worse than asking.

## What the decision depends on

- **Whether it can hold a session open across an SSH disconnect.** This is the
  load-bearing question, and it is entangled with ADR-0016: the main reason to keep
  a multiplexer at all is attaching to work left running on this machine from the
  MacBook. If herdr does not do that, removing tmux costs remote work sessions and
  the two ADRs conflict.
- **What in the current tmux config is actually load-bearing.** The Ghostty config
  carries two keybinds that exist *specifically* for tmux — `shift+enter` and
  `alt+shift+enter` are sent as CSI-u so tmux can distinguish them from plain
  Enter. Those become dead config, or need re-aiming at herdr.
- Overlap with ADR-0014: Ghostty splits, tmux panes, and Hyprland tiling are three
  ways to do one thing. Deciding this alongside the Ghostty binds avoids picking
  twice.
