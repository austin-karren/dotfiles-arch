---
status: proposed
---

# Cycle tiled window sizes along a ladder with arrow keys

Intent: a modifier plus an arrow key steps the focused tiled window through a **Size
ladder** of thirds and halves, with the rest of the layout absorbing the change.
Left/right shrink and grow along that ladder.

> **Intent recorded, not yet grilled.** The want is clear and the primitive exists.
> The rule originally proposed for *which windows are affected* does not survive
> contact with dwindle, and that is the substance of this ADR.

## The primitive already exists

```
hyprctl dispatch layoutmsg splitratio <arg>
```

It acts on the **parent split of the focused window**, and dwindle redistributes
everything on the far side of that split proportionally, by itself.

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

## The genuinely hard part: axis

Not the counting — the orientation.

`splitratio` acts on the parent split **whatever its orientation**, and Hyprland does
not expose that orientation through `hyprctl`. So for a vertically stacked pair,
pressing *left* would resize *vertically*: the layout changes, in the wrong
dimension, with no feedback explaining why.

Options, none yet chosen:

- Infer orientation from geometry — check whether a neighbour shares a vertical edge
  with the focused window. Works, fiddly, and needs care at monitor edges.
- Use `resizeactive` with a computed pixel delta instead. Hyprland picks the right
  axis for a width change on its own, so the ambiguity disappears — but the delta has
  to be computed against the **parent container's** width to land on a true third,
  and the parent's width is exactly what the tree does not tell us. Approximating it
  with the monitor width is correct for the common two-column case and wrong under
  nested splits.
- Restrict the binding to left/right and accept a no-op (or a vertical resize) when
  the parent split is horizontal.

## Notes for grill time

- **Naming.** This is a *Size ladder*, not a **Ratio** — the glossary already gives
  "Ratio" to `single_window_aspect_ratio`, the lone-window 1:1 constraint. Two
  unrelated sizing features one word apart is exactly the collision `CONTEXT.md`
  exists to prevent.
- **Which modifier.** Every `SUPER`+arrow combination is taken (focus movement,
  workspace switching, and `SUPER CTRL`+left/right for macOS-style Spaces). Ghostty
  also claims `CTRL+ALT`+arrows and `SUPER CTRL SHIFT`+arrows for its own splits, so
  a chord chosen carelessly will either be swallowed by the compositor or collide
  inside the terminal.
- **Interaction with Floating mode** (ADR-0021): this is meaningless for floating
  windows, which want half/edge snapping instead. Two different sizing gestures for
  two modes, on possibly the same keys.
