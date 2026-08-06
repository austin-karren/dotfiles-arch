#!/bin/bash

echo "Remove repo-only paths that Stow leaked into \$HOME"

# .stow-local-ignore only excluded README and packages.txt, so CONTEXT.md and
# docs/ were symlinked into $HOME alongside the real config. The ignore file now
# excludes them, but Stow will not clean up links it already made — and ~/docs in
# particular is a name likely to collide with a real directory later.
#
# Only removes the link if it still points into the repo. A real ~/docs that the
# user created on purpose is left alone.
#
# The repo basename is read from LOAF_ROOT rather than hardcoded: this migration
# was written when the repo was ~/dotfiles, and a literal would have quietly
# stopped matching when it became ~/shokupan — a no-op that looks like success.

repo=$(basename "${LOAF_ROOT:-$HOME/shokupan}")

for name in CONTEXT.md README.md docs packages migrations; do
  path="${LOAF_HOME:-$HOME}/$name"
  [[ -L $path ]] || continue
  case "$(readlink "$path")" in
  *"$repo"/* | *dotfiles/*)
    rm "$path"
    echo "  removed ~/$name"
    ;;
  esac
done
