---
status: accepted
---

# Cycle tiled window sizes along a ladder with arrow keys

`SUPER+CTRL+ALT` plus an arrow steps the focused tiled window through a **Size
ladder** of `1/3, 1/2, 2/3` of the screen, with the rest of the layout absorbing the
change. Left/right act on width, up/down on height. Implemented as
[`tile-resize`](../../.local/bin/tile-resize).

The key's direction is spatial — right widens, down heightens — so no key ever means
two things depending on context.

## Neither Hyprland primitive does this on its own

This is the substance of the ADR, because the obvious one-liner does not work and the
reasons are not documented anywhere obvious. Measured on this machine:

**`layoutmsg splitratio` is delta-only.** `exact` is rejected outright with
`failed to parse "exact" as a delta`. Its scale is 0–2 where `1.0` is a 50/50 split,
so a child's fraction is `ratio / 2`.

**Neither primitive is relative to the focused window.** A positive delta always grows
the **first** child of the split, whichever window has focus:

    focus left  window, resizeactive +200  ->  left  window 1136 -> 1336  (grew)
    focus right window, resizeactive +200  ->  right window 1136 ->  936  (shrank)

`layoutmsg splitratio +0.2` behaves identically. So the correct sign depends on which
side of the boundary the focused window is on, and **Hyprland does not expose the
dwindle tree through `hyprctl`** — there is no way to simply ask.

**`resizeactive exact` is not a way out.** It computes its own delta internally and so
inherits the inversion. On a second child, asking for `33%` produces `67%`.

**And the delta is bounds-checked against the wrong thing.** Hyprland validates the
request against the focused window's own size but applies it to the boundary inverted.
Growing a 766px second child by 767px means requesting `-767`, which is rejected
because `766 - 767 < 0` — so a second child can only grow by roughly its own current
size per call, and larger moves must be chunked.

**The two primitives fail in complementary ways on axis.** `splitratio` acts on the
immediate parent split, so pressing *left* on a vertically stacked window changes its
*height*. `resizeactive` walks up to the nearest ancestor with the matching
orientation and gets the axis right. That is why the implementation uses
`resizeactive` despite the clamping, and why a horizontal key on a stacked window
correctly resizes the whole column instead of doing something vertical.

## How the sign is resolved

Guess geometrically, then verify and correct. The guess is "a tiled window abuts my
low edge, so I am the second child", which is right for two windows, a 2x2 grid, and
one window beside a stack — and wrong only for a window in the middle of a nested run
of columns. Rather than reconstruct the tree to catch that, the move is measured and
the sign flipped once if the window travelled away from the target.

The same loop absorbs the chunking requirement from the bounds check. Ordinary
layouts settle in one dispatch; awkward ones take two or three. Measured at ~96ms per
keypress.

## Window count is the wrong invariant

The rule first proposed was: *an odd number of windows affects multiple sibling
windows; an even number affects one sibling, because there is no conflicting grid.*
This should not be built, because dwindle is a binary tree and the count of windows
says nothing about the tree's shape. Two counter-examples, both trivially reachable:

- **Four windows**, as one on the left and three stacked on the right. Focus the left
  one and resize: all three right-hand windows move. Even count, multiple siblings.
- **Three windows**, as three columns. Focus the middle one and resize leftward: only
  the left neighbour moves. Odd count, one sibling.

The rule is broken in both directions, and the same window count can produce either
outcome depending only on the order the windows were opened.

**What actually decides it is the parent split**, and a binary tree has exactly two
sides: the focused window's side, and everything else. So the question the original
design treats as hardest — "what about 3 windows? what about 4?" — does not need
answering. Nothing is enumerated, no special case is written, and the reported
behaviour for the 1-left/2-right case is what `splitratio` already does unaided.

This is the rare case where the correct design is *smaller* than the proposed one.

## The traversal is a wrapping carousel

The arrows cycle a **list**, they do not mean "grow" and "shrink" directly. Left
traverses the list one way, right the other. Read that way, the sequence originally
described for the left arrow — `1/3`, then `2/3`, then `1/2` — is a descending
traversal **with a wrap**, not an arbitrary order:

    left  from 1/2:   1/3  ->  (wrap)  2/3  ->  1/2  ->  1/3 ...
    right from 1/2:   2/3  ->  (wrap)  1/3  ->  1/2  ->  2/3 ...

Each key keeps exactly one meaning — one step down the ladder, or one step up — and
the apparent reversal is only the wrap becoming visible. This is **not** the
inverted-controls objection from ADR-0017; that was about a consistent mapping
pointing the wrong way, and this mapping is consistent and points the right way.

Still to choose:

- **Wrap or clamp.** Wrapping reaches every size from a single key, which is worth
  real ergonomic money, and with three rungs the wrap costs at most two extra
  presses. Clamping never surprises anyone but requires both keys to move freely.
  Current preference: wrap.
- **Off-ladder starting positions.** A border dragged with the mouse leaves the split
  at something like 0.42, where an index-based carousel has no current position to
  advance from. Snapping to the nearest rung **in the direction of travel** answers
  this and composes with wrapping unchanged.
- **How many rungs.** Three keeps the wrap cheap. A fourth or fifth value makes
  wrapping progressively more annoying and starts to argue for clamping instead, so
  the two choices are not independent.

## Verified behaviour

Exercised against throwaway windows in every layout that matters:

| Case | Result |
|---|---|
| Two windows, focus first child, wrap | `0.494 → 1/3 → 2/3 → 1/2 → 1/3` |
| Two windows, focus second child, wrap | `0.655 → 1/2 → 1/3 → 2/3 → 1/2` |
| Clamp mode, five presses each way | Stops at `1/3` and at `2/3` |
| One left + two stacked right, width from a stacked window | `0.321 → 0.667`, widths `1533/739/739 → 739/1533/1533` — the whole column moved |
| Height ladder on a stacked window | `0.490 → 0.666 → 0.500` |
| Horizontal key on a horizontally-split window | Height unchanged |
| Single tiled window | No-op, leaves **Ratio** alone |

The fourth row is the case the original design worried about, working with no
window-counting anywhere in the implementation.

## Keybinding

`SUPER+CTRL+ALT` + arrows. It is the only arrow chord free at **both** levels: `SUPER`,
`SUPER+SHIFT`, `SUPER+ALT` and `SUPER+SHIFT+ALT` arrows are taken by Hyprland, while
Ghostty claims `CTRL+SHIFT`, `CTRL+ALT` and `SUPER+CTRL+SHIFT` arrows for its own tabs
and splits. A chord chosen carelessly is either swallowed by the compositor or
collides inside the terminal.

Wrap/clamp is switched with `tile-resize --toggle-mode`, which flag-files into
`~/.local/state/omarchy/toggles/` like Omarchy's own toggles. Deliberately not bound
to a key — it is an occasional A/B switch, and `SUPER+CTRL+ALT+R` was already taken.
It belongs in the Toggle Menu eventually (ADR-0013).

## Still open

- **Wrap versus clamp is not settled.** Both are implemented so they can be compared
  in real use rather than argued about. Wrap is the default.
- **Naming.** This is a *Size ladder*, not a **Ratio** — the glossary gives "Ratio" to
  `single_window_aspect_ratio`, the lone-window 1:1 constraint. Two unrelated sizing
  features one word apart is exactly the collision `CONTEXT.md` exists to prevent.
- **Rung count interacts with wrap.** Three rungs keep wrapping cheap — at most two
  extra presses. A fourth or fifth value makes wrapping progressively more annoying
  and argues for clamping, so the two are not independent decisions.
- **Nested splits are approximate.** Rungs are fractions of the *screen*, but a
  deeply nested window's parent container is smaller, so a third of the screen may be
  unreachable. The loop clamps harmlessly rather than oscillating, but the landing
  will not be a true third.
- **Interaction with Floating mode** (ADR-0021): meaningless for floating windows,
  which want half/edge snapping instead. Two sizing gestures for two modes, possibly
  on the same keys.
