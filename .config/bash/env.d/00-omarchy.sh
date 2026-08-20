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

# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
#
# Upstream now does exactly this in default/bash/env-bootstrap ("single source
# of truth for OMARCHY_PATH + PATH"), and adopting that file collapses this
# block to one line. That swap changes remote shell behaviour on a live
# machine, so it is a separate, independently revertable change — this file
# carries the existing logic across unchanged.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
