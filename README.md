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

## To do

- Prune `packages.txt` down to a real, declarative package manifest
- Fold in my running list of system tweaks and fixes
