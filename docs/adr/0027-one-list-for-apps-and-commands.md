---
status: accepted
---

# One list for applications and system commands

The Launcher (`ALT+SPACE`, applications) and the System Palette (`SUPER+SPACE`, a
hand-written list of Omarchy commands) are now the same list. Both keys open Walker with
two providers merged: `menus:palette` and `desktopapplications`.

Supersedes the direction in ADR-0012.

## It is a provider, not a hand-built list

The obvious implementation — generate one big list and pipe it to `walker --dmenu`, as
`quick-menu` and `omarchy-menu` both do — was rejected. It would mean enumerating
applications by hand, and application discovery is not trivial here: snap `.desktop`
files are only visible because `.config/uwsm/env` adds `/var/lib/snapd/desktop` to
`XDG_DATA_DIRS`, a fix that was itself needed once already. Re-implementing that is how
Slack goes missing again. It would also lose real application icons, pinning, and
frecency.

Defining a menu provider keeps all of that native and adds nothing to maintain.

## Two undocumented mechanisms make the ordering work

Both established by querying elephant directly; neither is in the docs.

**With an empty query, Walker merges every provider into one list sorted by text.**
Provider order in the query string has no effect — verified by swapping it and getting
identical output. So commands would scatter alphabetically among applications:
`Catppuccin` landed between `Calendar` and `Chromium` in the test.

**A leading space in each entry's `Text` fixes that.** It sorts below every letter, so
the palette clusters above `Aether` and the applications follow in their own run.
Measured: with the space, position 0; without it, position 49 of 65. This is the whole
reason every label in `palette.lua` begins with a space, and deleting it would silently
scatter the commands.

**`FixedOrder = true` survives the merge.** Without it the palette's own entries would be
alphabetised too, losing Omarchy's Toggle Menu order. Verified by feeding in
Zebra/Apple/Mango and getting them back in that order at the top.

Together they give exactly the requested behaviour: commands first in Omarchy's order
when the box is empty, and normal scoring across everything once you type.

## Lua, not TOML

The menus provider accepts either. Lua is required here because entries are dynamic:
*Switch to Dark* versus *Switch to Light* depends on the active theme, Hibernate only
appears when `omarchy-hibernation-available` succeeds, and Sleep is hidden when suspend is
disabled. Omarchy uses Lua for its own dynamic menus and TOML for static ones.

Note this is unrelated to whether *applications* appear — that is the
`desktopapplications` provider and `XDG_DATA_DIRS`, not the menu format.

## Naming: Omarchy wins

Omarchy's Toggle Menu entries come first, in Omarchy's order and under Omarchy's names,
because those are canonical. This rice's commands follow.

One genuine collision: **both lists had "Screensaver", with the same glyph and different
actions** — Omarchy's toggles the feature on or off, `quick-menu`'s starts it now. Under
the precedence rule Omarchy keeps the name; ours became **Start Screensaver**. Worth
noticing because the two would have been indistinguishable in a merged list.

## min_score

Elephant's matcher is a loose subsequence match over a composite of an entry's fields, so
at the default threshold `term` matched *Theme*, *Wallpaper* and *Nightlight* — burying
applications under commands that merely share letters. `min_score = 60` in
`~/.config/elephant/menus.toml` raises the bar.

Behaviour after: `theme`, `zen`, `lock` reach the commands, `chrom` gives Chromium first,
`term` returns nothing — which is what the application provider does alone, since
`desktopapplications` matches on application *name* only and never matched "term" either.

## Still open

- **Favourites.** Walker already ships pinning for applications (`state: unpinned`, a
  `pin` action). Whether menu entries can be pinned too is unverified, and pinning is what
  would deliver the "favourites at the top" half of the original Raycast ask.
- **`quick-menu` is now unused** but still present and still bound to nothing. Remove it
  once the merged list has been lived with.
- The stopword case (`the`) still ranks commands above applications. Low priority — it is
  not a query anyone types deliberately.
