# Working agreements for this repo

Repo-level instructions for agents working in `shokupan`. The architectural
decisions live in `docs/adr/`; this file holds the rules that govern how work
gets done, not what was decided.

## Cite ADRs repo-qualified, never bare across repos

ADR numbers are one shared, interleaved space across several repos — `shokupan`,
`omarchy-desktop-on-cachyos`, `shokupan-plugins` and `crumb` — and the
2026-08-18 split moved records between them without moving the citations. A bare
`ADR-0044` does not say which repo to look in, and the file is often not in the
one you are standing in.

Write the repo name first:

- `shokupan ADR-0002`
- `omarchy-desktop-on-cachyos ADR-0035`
- `shokupan-plugins ADR-0044`
- `crumb ADR-0001`

Every citation that crosses a repo boundary must carry the repo name — in prose,
in a code comment, and in a commit message. A bare dangling `ADR-0044` cost a
full session an hour on 2026-08-19. Citing an ADR that lives in this repo may
stay bare, but qualifying it is never wrong.

Do not add a relative markdown link to an ADR in another repo — the path will
not resolve from here. Name the repo and the number instead.

## Never post upstream without an explicit go

Proposed issues and PRs to Omarchy and other upstreams live as drafts in
`docs/upstream/`. They are written for review and posted only on Austin's
explicit, per-item go — never automatically, never as a side effect of finishing
the draft. The same applies to marketplace and plugin-directory submissions.

This is the operational half of **shokupan-plugins ADR-0044 rule 5**, restated
here because agents read this file every session and that ADR now lives in
another repo. The ADR remains authoritative for the reasoning.
