---
status: accepted
---

# The wallpaper is pinned independently of the theme

Omarchy treats backgrounds as a property of the Theme: they live inside the theme
directory, and `omarchy-theme-set` repopulates that directory from the new theme
on every switch. A wallpaper chosen from a theme therefore cannot outlive it.
`~/.local/bin/pin-wallpaper` copies the chosen image to `~/.local/share/wallpapers`,
records it in `~/.local/state/omarchy/wallpaper-pin`, and a `theme-set.d` hook
re-applies it after every theme change.

Chosen over giving up and accepting the theme's wallpaper, because Appearance and
wallpaper are separate preferences here: switching light/dark should not change
the image.

## Consequences

A Pinned wallpaper outranks any theme's own background, including one we generate
ourselves (ADR-0008). A generated theme's wallpaper will not appear until
`pin-wallpaper --off`. This looks like a bug when you have forgotten the pin
exists, so the tooling says so out loud.

The restore hook cannot trust the `current/background` symlink alone. When a theme
ships no backgrounds at all, `omarchy-theme-bg-next` paints a flat
`swaybg --color '#000000'` and returns **without rewriting the symlink** — so the
link still points at a real image while the screen is black. A guard that compared
only the symlink concluded "already correct" and left the desktop black. It now
also requires that swaybg is genuinely rendering an image.

Hooks live in `~/.config/omarchy/hooks/theme-set.d/`, and `omarchy-hook` executes
**every** file there that is not named `*.sample`. A backup copy left in that
directory becomes a hook that runs on every theme change. Backups go to
`~/.local/state/omarchy/hook-backups/`.
