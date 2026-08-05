---
status: proposed
---

# Retune the idle chain, and keep the machine reachable

Two goals: the screensaver arrives too soon, and the gap before locking should be
much longer. Separately, this machine needs to stay reachable and keep long-running
processes (Claude, Vite dev servers) alive for the remote workflow in ADR-0016.

## Sanity check: nothing is killing your background processes

The belief that idle behaviour kills background processes does not hold up. What
the machine actually does:

- **Nothing auto-suspends it.** `~/.config/hypr/hypridle.conf` has no suspend
  listener at all — only screensaver and lock. `logind`'s `IdleAction` is left at
  its default of `ignore`, and there are no suspend timers. Suspend is *available*
  (and hibernation is too), but only ever fires when asked for by hand.
- **The one suspend on record was manual**: `PM: suspend entry (s2idle)` at
  Aug 3 23:45, resumed 09:48 the next morning. Bedtime, not idle.
- **Locking cannot kill a process.** `omarchy-system-lock` runs hyprlock, a
  fullscreen surface. It has no relationship to process lifetime.
- **Suspending does not kill them either.** s2idle freezes processes in RAM and
  restores them; hibernate writes them to swap and restores them. A Vite server or
  Claude session is still running after resume.

What genuinely breaks across a suspend is **network state, not processes**: open
sockets die, so an in-flight API call fails and HMR websockets drop until the
browser reconnects. And while suspended the machine is simply unreachable — which
is the real conflict with ADR-0016, and an argument for never suspending rather
than for changing timings.

So the timings are worth changing because 2.5 minutes is annoying, not because
anything is being lost.

## Standing requirement

The machine must stay usable from away over SSH, with long-running processes still
alive. That is a fixed requirement for anything decided here, not an open question —
so no change may introduce an idle suspend. The specifics are deliberately deferred;
this ADR only records the constraint so a future change does not violate it.

## The trap in the current config

The two timeouts are **not independent**, which makes the numbers look wrong:

```
listener { timeout = 150   on-timeout = pidof hyprlock || omarchy-launch-screensaver }
listener { timeout = 152   on-timeout = omarchy-system-lock }
```

Launching the screensaver resets the idle timer — it dispatches
`focusmonitor` and spawns a terminal per monitor, which registers as activity. So
the second listener does not fire 2 seconds after the first; it fires 152 seconds
after the *reset*, putting the lock at roughly 302s ≈ 5 minutes. Hence the config's
"half + 2s margin" comment.

The upside of that coupling is that the second number reads directly as "time from
screensaver to lock", which is exactly the knob wanted here. Bumping the first to
`300` and the second to e.g. `1800` gives a 5-minute screensaver and a lock 30
minutes later. Re-firing the first listener after the reset is harmless:
`omarchy-launch-screensaver` exits early when `org.omarchy.screensaver` is already
running.

This reset behaviour is documented from observation, not from hypridle's docs, so
it should be re-measured after any change rather than trusted.

## To settle at grill time

- **The two numbers.** "Slightly too fast" and "much longer" need actual values.
- **Whether to lock on idle at all**, given the remote goal. A machine you SSH into
  does not benefit from its local screen locking — but it is a physical desktop, so
  this is a security decision, not a technical one.
- **Whether to remove Sleep from the System Palette.** It is currently one keystroke
  and two clicks away, and it is the only thing that makes this machine unreachable.
  Hibernate has the same problem and is also offered.
- **Whether display-off should exist.** There is no DPMS listener today; the
  screensaver stays lit indefinitely. A monitor that never sleeps is its own cost.
- `inhibit_sleep = 3` already makes hypridle wait for the lock to appear before
  sleeping, so the lock-then-sleep ordering is not a concern.
