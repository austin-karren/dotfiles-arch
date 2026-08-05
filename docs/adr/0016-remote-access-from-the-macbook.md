---
status: proposed
---

# Reach this machine from the MacBook over Tailscale

This desktop is currently being used *instead of* the work MacBook only because
remote access is not set up. The intent is Tailscale for the network layer, then
SSH over it, so the MacBook becomes the client and this machine keeps being the
place the work actually runs.

> **Intent recorded, not yet grilled.** The *want* is settled; the *how* is
> deliberately undecided. Nothing below has been agreed — treat it as the
> question list for a later session, not as a plan.

## Current state

Nothing is in place yet:

- `tailscale` — not installed.
- `sshd` — installed but **disabled and inactive**. It has never been enabled.

One piece already exists: `~/.config/ghostty/config` sets
`shell-integration-features = no-cursor,ssh-env`, which propagates terminfo into
SSH sessions. That was configured for this, and it only helps when Ghostty is the
*client* — i.e. on the MacBook, whose config is a separate repo.

## To settle at grill time

- **Tailscale SSH or plain sshd over the tailnet.** Tailscale SSH moves
  authentication to the tailnet ACLs and avoids exposing or managing host keys;
  plain sshd over Tailscale keeps standard tooling and works with anything that
  speaks SSH. Not the same decision as installing Tailscale.
- **Whether sshd is exposed on the LAN at all,** or bound only to the tailnet
  interface. Enabling it broadly is the easy mistake here.
- **Work context.** This is for work, so whether a work machine may join a personal
  tailnet — and whose account owns the node — is a policy question, not a technical
  one, and worth settling before the tailnet exists.
- **What "remote" needs to reach.** A shell is straightforward. The Hyprland
  session is not: these configs assume a local seat, and nothing here is set up for
  remote *desktop*. If the answer is "shell plus long-running processes", that lands
  squarely on ADR-0015 and its multiplexer question.
- Neither `tailscaled` nor `sshd` being enabled is tracked by this repo — they are
  systemd units, not dotfiles. Where that provisioning gets recorded (README, a
  bootstrap script, or `packages.txt`) needs deciding, or a rebuild loses it.
