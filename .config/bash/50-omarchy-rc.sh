# shellcheck shell=bash
# A sourced fragment, so there is no shebang for shellcheck to read the
# dialect from — and Omarchy's rc is machine state, not a repo input it can
# follow.
# shellcheck disable=SC1091

# The rice's Omarchy arm, second tier: Omarchy's interactive shell — aliases,
# functions, completions, key bindings, prompt.
#
# TIER: ~/.config/bash/*.sh, sourced AFTER crumb's
# `[[ $- != *i* ]] && return`, which is where upstream puts this same source in
# /usr/share/omarchy/default/bashrc (environment above the guard, rc below it).
# Post-guard on purpose, two reasons:
#
#   - None of what rc pulls in — envs, shell, aliases, functions, init, and
#     `bind -f inputrc` — has any business in a non-interactive shell. Pre-guard
#     it would run `mise activate bash`, `zoxide init` and bash-completion on
#     every `ssh box somecommand` for ~28 ms it never needed.
#   - rc's last line is `[[ $- == *i* ]] && bind -f ...`, so sourcing it
#     non-interactively returns 1. Pre-guard that left $? at 1 for whatever
#     crumb's drop-in loop did next.
#
# OMARCHY_PATH is already exported by the first tier,
# .config/bash/env.d/00-omarchy.sh. Numbered 50- to sit after anything crumb
# wants to establish first and before anything that overrides an Omarchy alias.

# Guarded, which the .bashrc line this replaces was not: a bare
# `source "$OMARCHY_PATH/default/bash/rc"` errors on every single shell when
# Omarchy is absent, and a no-Omarchy machine is the whole reason crumb exists.
# Guard shape copied from upstream's own /usr/share/omarchy/default/bashrc:
#
#   [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap
#
# Recorded as a `watch` in packages/forks against THIS file, since this is the
# one that loads upstream's rc whole and depends on its internal structure.
[[ -r "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"
