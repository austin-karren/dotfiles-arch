---
status: accepted
---

# Personal identity lives behind untracked includes, not in the repo

The repo is public, so no tracked file may contain a name or email address.
Rather than templating or scrubbing on install, tracked configs end with an
include of a machine-side Identity file that the repo never sees:
`~/.config/git/config` includes `~/.gitconfig.local`, which is gitignored.

Chosen over the alternatives — a private repo (loses the ability to share the
rice), or `git config --local` per clone (does not apply to a home directory).

## Consequences

A missing include fails **silently**. Git does not warn about an unreadable
include path; it just rejects the commit with "please tell me who you are". That
is the symptom to recognise, and the README documents it as the first thing to
check on a fresh machine.

Because the repo installs `~/.config/git/config`, git ignores `~/.gitconfig`
entirely — it reads the latter only when the former does not exist. A stray
`~/.gitconfig` is a red herring.

Not yet applied to `~/.XCompose`, which holds a literal email expansion and is
therefore still untracked rather than split. See ADR-0010.
