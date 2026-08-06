#!/bin/bash

# Tests for the rice CLI.
#
# No framework on purpose. `rice heal` runs from Omarchy's post-update.d hook, so
# anything needed to test it would become a dependency of the update path. This
# emits TAP and follows the shape of Omarchy's own test/omarchy-cli-test.sh.
#
# Every test builds a throwaway home under $BUILD and points RICE_HOME at it, so
# nothing here can touch the real one. `pacman` and the Omarchy tree are stubbed;
# `git` and `stow` are real, because what they do to a fixture is exactly what
# they would do to the machine.
#
# Run: test/rice-test.sh

set -uo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT

tests=0
failures=0

pass() {
  tests=$((tests + 1))
  printf 'ok %d - %s\n' "$tests" "$1"
}

fail() {
  tests=$((tests + 1))
  failures=$((failures + 1))
  printf 'not ok %d - %s\n' "$tests" "$1"
  local detail
  for detail in "${@:2}"; do printf '  # %s\n' "$detail"; done
}

assert_contains() {
  if [[ $2 == *"$3"* ]]; then
    pass "$1"
  else
    fail "$1" "expected to find: $3" "in output: ${2:-<empty>}"
  fi
}

assert_not_contains() {
  if [[ $2 != *"$3"* ]]; then
    pass "$1"
  else
    fail "$1" "expected NOT to find: $3" "in output: $2"
  fi
}

assert_equals() {
  if [[ $2 == "$3" ]]; then
    pass "$1"
  else
    fail "$1" "expected: $3" "actual:   $2"
  fi
}

assert_symlink() {
  if [[ -L $2 ]]; then
    pass "$1"
  else
    fail "$1" "not a symlink: $2"
  fi
}

assert_file_exists() {
  if [[ -e $2 ]]; then
    pass "$1"
  else
    fail "$1" "missing: $2"
  fi
}

# ---------------------------------------------------------
# Fixture
# ---------------------------------------------------------

# Builds a complete fake machine: a home, a rice repo inside it with one tracked
# config file, a stubbed Omarchy checkout carrying the bridge's CachyOS
# adaptations, and a stubbed pacman that reports every package installed.
# Returns the home path on stdout.
make_home() {
  # mktemp, not a counter: this function is called as $(make_home), so it runs in
  # a subshell and any counter it incremented would be discarded — every fixture
  # would silently be the same directory, and state would leak between tests.
  local home
  home=$(mktemp -d "$BUILD/home-XXXXXX")

  # Everything in here is setup noise, and this function communicates by echoing
  # the home path — so a stray line of git output would be captured as part of
  # the path by the caller. Silence the lot, and echo the path outside the block.
  {
    mkdir -p "$home/.config/hypr" "$home/.local/state"

  # The rice repo
    local repo="$home/dotfiles"
    mkdir -p "$repo/.config/hypr" "$repo/packages" "$repo/migrations"
    echo "# tracked config" >"$repo/.config/hypr/looknfeel.conf"
    printf 'bat\n' >"$repo/packages/chosen.packages"
    # Mirrors the real repo: without this, stow symlinks packages/ and
    # migrations/ into the fixture home and doctor correctly reports them as
    # leaks — a fixture artefact rather than the condition under test.
    printf '^/packages$\n^/migrations$\n^/CONTEXT\\.md$\n^/docs$\n' \
      >"$repo/.stow-local-ignore"
    git -C "$repo" init -q 2>/dev/null
    git -C "$repo" config user.email test@example.com
    git -C "$repo" config user.name test
    git -C "$repo" add -A
    git -C "$repo" commit -qm fixture

  # The Omarchy checkout, with the bridge adaptations applied
    local omarchy="$home/.local/share/omarchy"
    mkdir -p "$omarchy/install/preflight" "$omarchy/bin"
    git -C "$omarchy" init -q 2>/dev/null
    printf 'eza\n' >"$omarchy/install/omarchy-base.packages" # tldr correctly absent
    printf 'run_logged other.sh\n' >"$omarchy/install/preflight/all.sh"
    git -C "$omarchy" add -A 2>/dev/null
    git -C "$omarchy" -c user.email=t@e.c -c user.name=t commit -qm base 2>/dev/null

  # The bridge, with the ADR-0001 path fix applied
    mkdir -p "$home/omarchy-on-cachyos/bin"
    printf 'TARGET_DIR="$SCRIPT_DIR/../omarchy"\n' >"$home/omarchy-on-cachyos/bin/fetch-omarchy.sh"
    printf 'OMARCHY_DIR="$SCRIPT_DIR/../omarchy"\n' >"$home/omarchy-on-cachyos/bin/install-omarchy-on-cachyos.sh"
  } >/dev/null 2>&1

  echo "$home"
}

# Stubbed pacman, so tests never consult the real package database.
mkdir -p "$BUILD/stub"
cat >"$BUILD/stub/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Qq) exit 0 ;;    # every package is installed
  -Qqe) echo bat ;; # the record
esac
STUB
chmod +x "$BUILD/stub/pacman"

# Run a rice command against a fixture home.
rice_run() {
  local home=$1 cmd=$2
  shift 2
  RICE_HOME="$home" RICE_ROOT="$home/dotfiles" \
    OMARCHY_PATH="$home/.local/share/omarchy" \
    BRIDGE_ROOT="$home/omarchy-on-cachyos" \
    XDG_STATE_HOME="$home/.local/state" \
    PATH="$BUILD/stub:$ROOT/.local/bin:$PATH" \
    "rice-$cmd" "$@" 2>&1
}

# ---------------------------------------------------------
# doctor
# ---------------------------------------------------------

home=$(make_home)
(cd "$home/dotfiles" && stow --no-folding -t "$home" . 2>/dev/null)

out=$(rice_run "$home" doctor)
status=$?
assert_contains "doctor: clean fixture reports no problems" "$out" "No problems"
assert_equals "doctor: clean fixture exits 0" "$status" "0"
assert_contains "doctor: confirms bridge patch intact" "$out" "path fix intact"
assert_contains "doctor: confirms cachyos adaptations intact" "$out" "adaptations intact"

# A displaced symlink — the failure the whole thing exists for. Note git stays
# clean throughout, which is why nothing else would catch this.
home=$(make_home)
(cd "$home/dotfiles" && stow --no-folding -t "$home" . 2>/dev/null)
rm "$home/.config/hypr/looknfeel.conf"
echo "upstream default" >"$home/.config/hypr/looknfeel.conf"

out=$(rice_run "$home" doctor)
status=$?
assert_contains "doctor: detects a displaced symlink" "$out" "replaced by real files"
assert_equals "doctor: exits non-zero on drift" "$status" "1"

# A repo-only path leaked into $HOME by stow
home=$(make_home)
touch "$home/CONTEXT.md"
out=$(rice_run "$home" doctor)
assert_contains "doctor: detects a leaked repo-only path" "$out" "repo-only path"

# A reverted CachyOS adaptation
home=$(make_home)
printf 'tldr\n' >>"$home/.local/share/omarchy/install/omarchy-base.packages"
out=$(rice_run "$home" doctor)
assert_contains "doctor: detects a reverted bridge adaptation" "$out" "conflicts with tealdeer"

# The stale clone ADR-0001 warns about
home=$(make_home)
mkdir -p "$home/omarchy"
out=$(rice_run "$home" doctor)
assert_contains "doctor: detects the stale ~/omarchy clone" "$out" "stale clone"

# Read-only by construction: a dirty fixture must be unchanged afterwards.
home=$(make_home)
touch "$home/CONTEXT.md"
before=$(find "$home" -not -path '*/.git/*' | sort | md5sum)
rice_run "$home" doctor >/dev/null
after=$(find "$home" -not -path '*/.git/*' | sort | md5sum)
assert_equals "doctor: changes nothing on disk" "$before" "$after"

# ---------------------------------------------------------
# heal
# ---------------------------------------------------------

# The critical one. A bug here costs real data, so it is asserted directly:
# the displaced file must still exist, with its contents, after healing.
home=$(make_home)
(cd "$home/dotfiles" && stow --no-folding -t "$home" . 2>/dev/null)
rm "$home/.config/hypr/looknfeel.conf"
echo "upstream default" >"$home/.config/hypr/looknfeel.conf"

out=$(rice_run "$home" heal)
assert_symlink "heal: restores the displaced symlink" "$home/.config/hypr/looknfeel.conf"
displaced=$(find "$home/.config/hypr" -name 'looknfeel.conf.displaced.*' | head -1)
assert_file_exists "heal: NEVER deletes the file it displaced" "$displaced"
assert_equals "heal: displaced file keeps its contents" "$(cat "$displaced" 2>/dev/null)" "upstream default"
assert_equals "heal: restored symlink points at the repo" \
  "$(cat "$home/.config/hypr/looknfeel.conf")" "# tracked config"

# Dry run must not touch anything
home=$(make_home)
(cd "$home/dotfiles" && stow --no-folding -t "$home" . 2>/dev/null)
rm "$home/.config/hypr/looknfeel.conf"
echo "upstream default" >"$home/.config/hypr/looknfeel.conf"
before=$(find "$home" -not -path '*/.git/*' | sort | md5sum)
out=$(rice_run "$home" heal --dry-run)
after=$(find "$home" -not -path '*/.git/*' | sort | md5sum)
assert_equals "heal: --dry-run changes nothing" "$before" "$after"
assert_contains "heal: --dry-run still reports what it would do" "$out" "would restore"

# Migrations: applied once, recorded, never re-applied
home=$(make_home)
cat >"$home/dotfiles/migrations/1000000000.sh" <<'M'
echo "test migration"
echo ran >>"$RICE_HOME/migration-ran"
M
out=$(rice_run "$home" heal)
assert_contains "heal: applies a pending migration" "$out" "applied 1000000000.sh"
assert_equals "heal: migration ran exactly once" "$(wc -l <"$home/migration-ran")" "1"

out=$(rice_run "$home" heal)
assert_contains "heal: second run reports none pending" "$out" "none pending"
assert_equals "heal: migration still ran only once" "$(wc -l <"$home/migration-ran")" "1"
assert_contains "heal: records the migration in the ledger" \
  "$(cat "$home/.local/state/rice/applied")" "1000000000.sh"

# A failing migration must not be recorded, so it retries
home=$(make_home)
printf 'exit 1\n' >"$home/dotfiles/migrations/1000000001.sh"
out=$(rice_run "$home" heal)
status=$?
assert_contains "heal: reports a failed migration" "$out" "will retry"
assert_equals "heal: exits non-zero when a migration fails" "$status" "1"
assert_not_contains "heal: does NOT record a failed migration" \
  "$(cat "$home/.local/state/rice/applied" 2>/dev/null)" "1000000001.sh"

# Idempotence: healing a healthy machine is a no-op
home=$(make_home)
(cd "$home/dotfiles" && stow --no-folding -t "$home" . 2>/dev/null)
rice_run "$home" heal >/dev/null
before=$(find "$home" -not -path '*/.git/*' -not -name last-heal | sort | md5sum)
out=$(rice_run "$home" heal)
after=$(find "$home" -not -path '*/.git/*' -not -name last-heal | sort | md5sum)
assert_equals "heal: is idempotent" "$before" "$after"
assert_contains "heal: says so" "$out" "Nothing to heal"

# ---------------------------------------------------------
# dispatch
# ---------------------------------------------------------

home=$(make_home)
out=$(RICE_HOME="$home" PATH="$ROOT/.local/bin:$PATH" rice 2>&1)
assert_contains "rice: lists doctor" "$out" "doctor"
assert_contains "rice: lists heal" "$out" "heal"
assert_contains "rice: shows summaries from the rice:summary= line" "$out" "without changing anything"

out=$(RICE_HOME="$home" PATH="$ROOT/.local/bin:$PATH" rice nonesuch 2>&1)
status=$?
assert_contains "rice: rejects an unknown command" "$out" "no such command"
assert_equals "rice: exits non-zero on an unknown command" "$status" "1"

# ---------------------------------------------------------

printf '\n1..%d\n' "$tests"
if ((failures)); then
    printf '\n%d of %d failed.\n' "$failures" "$tests"
  exit 1
fi
printf '\nAll %d passed.\n' "$tests"
