# shellcheck shell=bash
# A sourced fragment, so there is no shebang for shellcheck to read the
# dialect from — and the two files sourced below are machine state, not
# repo inputs it can follow.
# shellcheck disable=SC1091

# The rice's Omarchy arm, extracted from .bashrc so the .bashrc itself can
# become desktop-agnostic and live in crumb. Everything Omarchy-coupled stays
# here; crumb knows nothing about Omarchy and only provides the seam that reads
# this directory. The dependency points one way on purpose.
#
# Numbered 00- because this is the FIRST tier: ~/.config/bash/env.d/*.sh is
# sourced before the `[[ $- != *i* ]] && return` interactivity guard, so
# `ssh box somecommand` — which runs no interactive shell — still gets
# OMARCHY_PATH. Sourcing the pre-crumb .bashrc non-interactively left it unset,
# where upstream's own bashrc yields /usr/share/omarchy.

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

# Guarded, which the .bashrc line this replaces was not: a bare
# `source "$OMARCHY_PATH/default/bash/rc"` errors on every single shell when
# Omarchy is absent, and a no-Omarchy machine is the whole reason crumb exists.
# Guard shape copied from upstream's own /usr/share/omarchy/default/bashrc:
#
#   [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
#
# Recorded as a `watch` in packages/forks: this loads upstream's file whole and
# depends on it continuing to exist under that name.
[[ -r "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"
