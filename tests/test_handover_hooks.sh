#!/bin/bash
# km-unrepaired-tree: unrecorded | added in v1.18, before this declaration was required; the file records no run against an unrepaired handover hook and one is not reconstructed here.
# Isolated guard tests for template/handover-hooks.sh (v1.18, hub handover write side).
#
# The Stop gate can BLOCK a session from ending, so it must be proven to fire exactly when it should
# and never when it should not: a gate that cannot block is not enforcement, and a gate that blocks
# on the turn that answers it is an infinite loop. Six cases cover the guard's whole truth table.
# All fixtures are synthetic; no real person, organization, or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SRC="$ROOT/template/handover-hooks.sh"

work="$(mktemp -d "${TMPDIR:-/tmp}/km-hov-test.XXXXXX")"
markers="$(mktemp -d "${TMPDIR:-/tmp}/km-hov-markers.XXXXXX")"
trap 'rm -rf "$work" "$markers"' EXIT

hub="$work/hub"
mkdir -p "$hub"
cp "$HOOK_SRC" "$hub/handover-hooks.sh"
chmod +x "$hub/handover-hooks.sh"

git -C "$hub" init -q
git -C "$hub" config user.name 'KM Test'
git -C "$hub" config user.email 'km-test@example.invalid'
printf 'seed\n' > "$hub/HANDOVER.md"
printf 'seed\n' > "$hub/01_project-brief.md"
git -C "$hub" add -A
git -C "$hub" commit -qm 'init: guard-test hub'

fail=0
pass() { printf 'PASS: %s\n' "$1"; }
bad()  { printf 'FAIL: %s\n' "$1" >&2; fail=1; }

# Drive a subcommand with a JSON stdin payload; markers isolated via TMPDIR.
run() { # run <mode> <json>
  printf '%s' "$2" | TMPDIR="$markers" bash "$hub/handover-hooks.sh" "$1" 2>/dev/null
}
commit_nonhandover() { # advance HEAD without touching HANDOVER.md
  printf 'change %s\n' "$1" >> "$hub/01_project-brief.md"
  git -C "$hub" add 01_project-brief.md
  git -C "$hub" commit -qm "work $1"
}
commit_handover() {
  printf 'refresh %s\n' "$1" >> "$hub/HANDOVER.md"
  git -C "$hub" add HANDOVER.md
  git -C "$hub" commit -qm "handover $1"
}
blocks() { printf '%s' "$1" | grep -q '"decision": "block"'; }

# 1 — no baseline recorded → cannot judge, must not block.
out="$(run check '{"session_id":"c1"}')"
blocks "$out" && bad "no-baseline blocked (should stay silent)" || pass "no baseline → no block"

# 2 — baseline, but HEAD unchanged (no work) → must not block.
run baseline '{"session_id":"c2"}' >/dev/null
out="$(run check '{"session_id":"c2"}')"
blocks "$out" && bad "no-work blocked" || pass "baseline + no work → no block"

# 3 — work committed, HANDOVER.md untouched → block exactly once.
run baseline '{"session_id":"c3"}' >/dev/null
commit_nonhandover c3
out="$(run check '{"session_id":"c3"}')"
blocks "$out" && pass "work without handover → block" || bad "work without handover did NOT block"

# 4 — same session, second Stop → one-shot nudge guard, must not block again.
out="$(run check '{"session_id":"c3"}')"
blocks "$out" && bad "re-blocked same session (loop)" || pass "nudge one-shot → no second block"

# 5 — stop_hook_active=true → the gate must never re-enter its own block.
run baseline '{"session_id":"c5"}' >/dev/null
commit_nonhandover c5
out="$(run check '{"session_id":"c5","stop_hook_active":true}')"
blocks "$out" && bad "blocked while stop_hook_active" || pass "stop_hook_active → no block"

# 6 — work committed, and HANDOVER.md touched in-range → must not block.
run baseline '{"session_id":"c6"}' >/dev/null
commit_handover c6
out="$(run check '{"session_id":"c6"}')"
blocks "$out" && bad "blocked though handover was updated" || pass "handover touched → no block"

if [ "$fail" -eq 0 ]; then
  echo "handover hook guard tests passed (6/6)"
  exit 0
fi
echo "handover hook guard tests FAILED" >&2
exit 1
