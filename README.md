# Arch Dotfiles (CachyOS + Omarchy)

Configuration for my CachyOS machine running [Omarchy](https://omarchy.org) on
Hyprland. Managed with [GNU Stow](https://www.gnu.org/software/stow/), same as my
[macOS dotfiles](https://github.com/austin-karren/dotfiles) — but kept as a
separate repo, because the two platforms share almost nothing beyond `.gitconfig`.

The shell here is bash (Omarchy's), not the zsh setup from the macOS repo.

## Layout

This is a single flat Stow package: paths mirror `$HOME` directly.

```
.bashrc                 -> ~/.bashrc
.config/hypr/*.conf     -> ~/.config/hypr/*.conf
.config/waybar/*        -> ~/.config/waybar/*
...
```

## Install

```bash
cd ~
gh repo clone austin-karren/dotfiles-arch dotfiles
cd dotfiles
sudo pacman -S --needed stow
stow --adopt .   # --adopt takes ownership of existing files in place
git diff         # review what --adopt pulled in from the live system
```

`--adopt` moves your existing config files into the repo and replaces them with
symlinks. If the live files differ from what's committed, `--adopt` **overwrites
the repo copy with the live one** — so always `git diff` afterwards and decide
which version you actually want.

## Required: git identity

`.config/git/config` deliberately contains no email. It ends with:

```gitconfig
[include]
	path = ~/.gitconfig.local
```

Create that file (it is gitignored, and never committed):

```gitconfig
[user]
	email = your.email@example.com
```

A missing include fails **silently** — git will not warn you, it will just reject
commits with "please tell me who you are". If you see that, this file is why.

Note: git reads `~/.gitconfig` only when `~/.config/git/config` does not exist.
Since this repo installs the latter, a stray `~/.gitconfig` is ignored entirely.

## What's here

| Path | Notes |
|---|---|
| `.config/hypr/` | Hyprland: bindings, monitors, looknfeel, windows, idle/lock/sunset |
| `.config/waybar/` | Bar config, styles, and theme override |
| `.config/walker/` | Launcher |
| `.config/ghostty/`, `alacritty/`, `foot/` | Terminals. Ghostty sources Omarchy's dynamic theme path, which stays machine-side |
| `.config/zed/` | Editor + agent settings |
| `.config/git/config` | Aliases, delta pager, zdiff3, rerere |
| `.config/uwsm/` | Session env (incl. making snap apps visible to walker) |
| `.config/starship.toml`, `.config/tmux/` | Prompt and multiplexer |
| `.bashrc` | Thin — sources Omarchy's `default/bash/rc` |
| `.local/bin/` | Scripts a keybinding depends on: `close-surface`, `tile-resize`. The rest of `~/.local/bin` is untracked — see the to-do |

### Deliberately not tracked

- **`~/.config/nvim`** — unmodified LazyVim starter. Nothing of mine in it yet.
- **`~/.XCompose`** — contains a literal email expansion; kept out of a public repo.
- **`*.bak.<timestamp>`** — Omarchy migration artifacts, not config.

## Packages

`packages.txt` is the raw output of `pacman -Qqe` — every explicitly-installed
package on the machine.

**It is a record, not an install list.** Most of those 300 entries are the
CachyOS base install and Omarchy's own dependencies, not deliberate choices of
mine. Feeding the whole file to `pacman -S` on a fresh machine is not the
intended use.

Packages I actually added on top of the CachyOS + Omarchy baseline:

```bash
sudo pacman -S --needed \
  bat eza tldr \        # Omarchy's bash config expects these three
  git-delta git-lfs \   # git pager + LFS
  stow \                # this repo
  figlet lolcat \       # shell banner
  zed                   # editor
```

`bat` in particular is not optional on an Omarchy box: `default/bash/envs`
exports `MANPAGER="sh -c 'col -bx | bat -l man -p'"` unconditionally, so without
it `man` pipes into a missing binary in any interactive terminal.

Language runtimes are handled by [mise](https://mise.jdx.dev), not pacman —
`~/.config/mise/config.toml` pins those per-project.

## Why things are the way they are

[`CONTEXT.md`](./CONTEXT.md) is the glossary. Worth reading first if you are going
to touch the menus or the bar — Omarchy, Hyprland, Walker and this repo all use
"theme", "menu" and "toggle" to mean different things, and three of the four menus
are one modifier apart.

[`docs/adr/`](./docs/adr/) records the decisions. Accepted ones explain existing
behaviour that looks odd on purpose; proposed ones are decisions not yet made, and
are the to-do list.

| ADR | Decision | Status |
|---|---|---|
| [0001](./docs/adr/0001-omarchy-on-cachyos-not-the-omarchy-iso.md) | Omarchy layered onto CachyOS, not the Omarchy ISO — includes the installer path fix | accepted |
| [0002](./docs/adr/0002-single-flat-stow-package.md) | One flat Stow package, adopted in place | accepted |
| [0003](./docs/adr/0003-identity-behind-untracked-includes.md) | Identity behind untracked includes | accepted |
| [0004](./docs/adr/0004-waybar-modules-dismiss-on-second-click.md) | Bar modules dismiss on a second click | accepted |
| [0005](./docs/adr/0005-waybar-supervised-by-a-userspace-watchdog.md) | Waybar supervised by a polling watchdog | accepted |
| [0006](./docs/adr/0006-calendar-hidden-on-its-own-special-workspace.md) | Calendar on its own special workspace | accepted |
| [0007](./docs/adr/0007-wallpaper-pinned-independently-of-the-theme.md) | Wallpaper pinned independently of the theme | accepted |
| [0008](./docs/adr/0008-aether-confined-to-generated-named-themes.md) | Aether may generate themes, not apply them | accepted |
| [0009](./docs/adr/0009-waybar-stays-dark-in-every-theme.md) | The bar stays dark in every theme | accepted |
| [0010](./docs/adr/0010-split-xcompose-to-track-it.md) | Split `~/.XCompose` so it can be tracked | proposed |
| [0011](./docs/adr/0011-extend-second-click-dismissal-to-audio-and-cpu.md) | Second-click dismissal for audio and CPU | proposed |
| [0012](./docs/adr/0012-unify-launcher-and-palette-on-elephant-menus.md) | Unify Launcher and System Palette | proposed |
| [0013](./docs/adr/0013-promote-the-ratio-toggle-to-the-bar.md) | Ratio toggle onto the bar | proposed |
| [0014](./docs/adr/0014-ghostty-split-keybinds.md) | Ghostty split keybinds, and bind `close_surface` | accepted |
| [0015](./docs/adr/0015-replace-tmux-with-herdr.md) | Replace tmux with herdr | proposed |
| [0016](./docs/adr/0016-remote-access-from-the-macbook.md) | Reach this machine from the MacBook over Tailscale | proposed |
| [0017](./docs/adr/0017-druk-as-the-terminal-editor.md) | Bake off druk, Helix and Neovim as the terminal editor | proposed |
| [0018](./docs/adr/0018-worktrunk-for-git-worktrees.md) | Manage worktrees with worktrunk | proposed |
| [0019](./docs/adr/0019-idle-timings-for-a-remote-first-machine.md) | Retune the idle chain, keep the machine reachable | proposed |
| [0020](./docs/adr/0020-super-w-closes-the-smallest-surface.md) | `SUPER+W` closes the smallest surface, not the window | accepted |
| [0021](./docs/adr/0021-floating-mode-as-a-real-mode.md) | Make floating a real mode, toggleable from the bar | proposed |
| [0022](./docs/adr/0022-cycle-split-ratios-with-arrow-keys.md) | Cycle tiled window sizes along a Size ladder | accepted |
| [0023](./docs/adr/0023-arrow-modifiers-encode-scope.md) | Arrow-key modifiers encode what you are acting on | accepted |

## To do

- Prune `packages.txt` down to a real, declarative package manifest
- Work through the proposed ADRs above
- Track the rest of `~/.local/bin` — `quick-menu`, `waybar-watchdog`, `pin-wallpaper`,
  `calendar-toggle`, `window-toggle`, `menu-toggle`, `toggle-appearance`,
  `aether-theme`. Only `close-surface` and `tile-resize` are in the repo, so ADRs
  0005, 0007 and 0012 currently document behaviour that a rebuild would not reproduce
- Settle wrap versus clamp for the Size ladder (ADR-0022) after using both, and put
  the switch in the Toggle Menu instead of `tile-resize --toggle-mode`
