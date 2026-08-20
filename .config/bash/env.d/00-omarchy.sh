# shellcheck shell=bash
# A sourced fragment, so there is no shebang for shellcheck to read the
# dialect from — and /etc/omarchy.conf is machine state, not a repo input it
# can follow.
# shellcheck disable=SC1091

# The rice's Omarchy arm, first tier — extracted from .bashrc so the .bashrc
# itself can become desktop-agnostic and live in crumb. Everything
# Omarchy-coupled stays in the rice; crumb knows nothing about Omarchy and only
# provides the seam that reads this directory. The dependency points one way on
# purpose.
#
# TIER: ~/.config/bash/env.d/*.sh, sourced BEFORE crumb's
# `[[ $- != *i* ]] && return`. Only the environment belongs here — the variable
# is what a non-interactive shell needs. `ssh box somecommand` runs no
# interactive shell, and sourcing the pre-crumb .bashrc that way left
# OMARCHY_PATH unset where upstream's own bashrc yields /usr/share/omarchy.
# This file is that fix.
#
# Numbered 00- because it must run before anything that reads OMARCHY_PATH,
# which includes the second-tier .config/bash/50-omarchy-rc.sh that loads
# Omarchy's interactive rc from under it.
#
# This is the same division upstream draws in /usr/share/omarchy/default/bashrc:
# the environment above the interactivity guard, the rc below it. The aliases,
# functions, completions and key bindings in that rc have no business running
# in a non-interactive shell.

# Upstream's own single source of truth for OMARCHY_PATH + PATH, sourced by
# /etc/profile.d/omarchy.sh, /etc/skel/.bashrc, /usr/share/uwsm/env.d/10-omarchy
# and default/bash/envs. It carries the /etc/omarchy.conf dev-link staleness
# handling this file used to hand-roll — /etc/omarchy.conf is written by
# omarchy-dev-link and reset by omarchy-dev-unlink, and when absent the packaged
# default is forced rather than a stale inherited value preserved — for the same
# reason and with the same result. By the stock-first rule the hand-rolled block
# stopped earning its keep once upstream absorbed it.
#
# It also does PATH work the old block did not: the dev-link `$OMARCHY_PATH/bin`
# prepend (production installs skip it — the binaries are already /usr/bin/omarchy-*),
# and an APPEND of ~/.local/share/mise/shims and ~/.local/bin so system binaries
# keep precedence. Both appends land behind /usr/bin, and behind whatever crumb's
# own env.d/10-pnpm.sh and env.d/20-local-bin.sh prepend after this file runs.
# On a machine carrying Omarchy's PAM PATH line (install/config/ssh-command-path.sh)
# the two appends are already satisfied and PATH comes out byte-identical.
#
# Guard shape copied from upstream's own /etc/skel/.bashrc. The trailing `:` is
# ours: this is the last line of a drop-in that crumb's tier-1 loop sources, and
# a false guard on the last line would hand $? = 1 to whatever ran next on a
# machine without Omarchy — the same trap that keeps 50-omarchy-rc.sh post-guard.
#
# Recorded as a `watch` in packages/forks against THIS file: nothing is copied,
# but the path and the variables it establishes are depended on whole.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
:
