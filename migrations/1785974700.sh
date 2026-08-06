#!/bin/bash

echo "Remove repo-only paths that Stow leaked into \$HOME"

# .stow-local-ignore only excluded README and packages.txt, so CONTEXT.md and
# docs/ were symlinked into $HOME alongside the real config. The ignore file now
# excludes them, but Stow will not clean up links it already made — and ~/docs in
# particular is a name likely to collide with a real directory later.
#
# Only removes the link if it still points into the repo. A real ~/docs that the
# user created on purpose is left alone.

for name in CONTEXT.md README.md docs packages migrations; do
  path="$HOME/$name"
  [[ -L $path ]] || continue
  case "$(readlink "$path")" in
  *dotfiles/*)
    rm "$path"
    echo "  removed ~/$name"
    ;;
  esac
done
