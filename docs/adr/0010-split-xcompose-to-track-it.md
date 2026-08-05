---
status: proposed
---

# Split ~/.XCompose so its identity lines can stay untracked

`~/.XCompose` is the last config deliberately left untracked purely because of
identity: it defines `<Multi_key> <space> <e>` as a literal email expansion, and
the repo is public. The proposal is to apply the ADR-0003 pattern rather than keep
excluding the file — track a `.XCompose` that ends with an include of a
machine-side `~/.XCompose.local` holding only the identity expansions.

XCompose already supports this natively; the current file uses `include` to pull
in Omarchy's emoji table, so no new mechanism is needed.

## To settle at grill time

- Whether an identity *expansion* is even worth tracking. The tracked remainder
  would be one `include` line plus whatever non-identity shortcuts get added
  later — arguably not worth a file until there is something else in it.
- Whether `~/.XCompose.local` joins `~/.gitconfig.local` in `.gitignore` and in
  the README's "Required" section, since a missing include here fails loudly
  (dead keybind) rather than silently.
- `omarchy-restart-xcompose` must run to apply changes; whether that belongs in
  the install flow.
