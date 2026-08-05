---
status: proposed
---

# Decide the Ghostty split keybinds, and bind close_surface

Splits are currently unusable in practice: every process gets its own window, and
splits happen by accident with no obvious way out of one. The cause is concrete
and worth recording, because it is a **missing** binding rather than a wrong one.

## What the bindings actually are today

Ghostty's defaults, none of them overridden in `~/.config/ghostty/config`:

| Keys | Action |
|---|---|
| `ctrl+shift+o` | `new_split:right` |
| `ctrl+shift+e` | `new_split:down` |
| `ctrl+alt+←/↑/→/↓` | `goto_split:<dir>` |
| `super+ctrl+[` / `]` | `goto_split:previous` / `next` |
| `super+ctrl+shift+arrows` | `resize_split:<dir>,10` |
| `ctrl+shift+w` | **`close_tab:this`** |

The tracked config adds only `super+ctrl+shift+alt+arrows` for `resize_split:…,100`
— a coarser resize. It binds nothing for creating or closing.

**`close_surface` is not bound at all.** It exists as an action, but no default
key invokes it. `ctrl+shift+w` is `close_tab:this`, which closes the tab and every
split inside it — exactly the "can't close a pane without losing the whole window"
symptom. Binding `close_surface` is the fix, and it needs no new concepts.

Also unbound and relevant: `toggle_split_zoom` (temporarily fullscreen one pane)
and `equalize_splits`.

## To settle at grill time

- **The accidental splits.** `ctrl+shift+e` and `ctrl+shift+o` are easy to hit
  reaching for `ctrl+shift+c`/`ctrl+shift+t`. Rebind to something deliberate, or
  keep the defaults now that closing works? A pane you can close cheaply is a much
  smaller mistake.
- **Splits versus tmux versus the window manager.** Three things here can split a
  screen: Ghostty, tmux (ADR-0015 proposes removing it), and Hyprland itself. Doing
  it in Ghostty means the WM cannot manage those panes and they do not survive
  detach. This decision should be taken *with* ADR-0015, not before it — if
  multiplexing moves to a persistent session tool, Ghostty splits may not be wanted
  at all.
- `confirm-close-surface = false` is already set, so a `close_surface` bind will
  take effect with no prompt. Fine for a pane, worth a thought for the last one.
