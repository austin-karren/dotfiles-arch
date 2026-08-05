---
status: accepted
---

# One flat Stow package, adopted in place

The repo is a single Stow package whose paths mirror `$HOME` directly, rather
than the conventional per-application packages (`stow hypr waybar zed`). There is
exactly one machine and one profile to install, so per-package granularity would
buy selective installation nobody needs while making every path one level deeper.

Installation uses `stow --adopt`, which pulls the live files into the repo and
replaces them with symlinks — the only way to onboard a machine that was already
configured before the repo existed.

## Consequences

`--adopt` resolves conflicts by **overwriting the repo copy with the live file**,
silently. A `git diff` immediately after stowing is not optional; it is the only
place a wrong-direction adoption becomes visible.

Kept as a separate repo from the macOS dotfiles rather than sharing one with host
detection: the two platforms overlap on almost nothing but `.gitconfig`, and the
shell differs (bash here, zsh there).
