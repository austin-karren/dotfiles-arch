#!/bin/bash

echo "Make Flatpak apps reachable from the Launcher, and .flatpakref files openable"

# Two pieces of machine-side state that stowing cannot reach.
#
# 1. Export directories.
#
# A Flatpak app becomes visible to Elephant by exporting a .desktop file into
# `exports/share/applications` under the Flatpak installation. Elephant watches
# that path — but a watch can only be attached to a directory that already
# exists, and Flatpak does not create one until the first app is installed.
#
# The failure this prevents: install the first Flatpak, and it never appears in
# the Launcher, because Elephant started at boot with nothing to watch. It shows
# up only after Elephant is restarted, which reads as the Launcher being broken
# rather than as a watch that was never established. Creating the directories
# up front means the watch is attached at every boot, whether or not anything is
# installed there yet. The system path already exists once anything is
# installed; the per-user one usually does not.
#
# 2. Ref handler.
#
# flathub.org's Install button hands the browser a `flatpak+https://` URL, and
# the downloaded fallback is a `.flatpakref` file. Shelly claims the URL scheme
# but not the file type, and routes the scheme to its own GUI. Both are pointed
# at `flatpakref-install` instead — see ADR-0032.
#
# Idempotent: mkdir -p is a no-op on existing directories, and xdg-mime default
# rewrites the association in place.

home="${LOAF_HOME:-$HOME}"

for dir in \
  "$home/.local/share/flatpak/exports/share/applications" \
  "$home/.local/share/flatpak/exports/share/icons"; do
  [[ -d $dir ]] && continue
  mkdir -p "$dir"
  echo "  created ${dir#"$home"/}"
done

if command -v xdg-mime &>/dev/null; then
  for type in x-scheme-handler/flatpak+https application/vnd.flatpak.ref; do
    current=$(xdg-mime query default "$type" 2>/dev/null)
    [[ $current == flatpakref-install.desktop ]] && continue
    xdg-mime default flatpakref-install.desktop "$type"
    echo "  $type -> flatpakref-install.desktop"
  done
else
  echo "  xdg-mime not installed — ref handler not registered"
fi
