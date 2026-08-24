#!/bin/bash
# km-unrepaired-tree: unrecorded | added in v1.19, before this declaration was required; the file records no run against an unrepaired hub-scan and one is not reconstructed here.
# Fixtures for the [ CORRECTIONS ] block (v1.19) in template/hub-scan.sh.
#
# The block binds the estate corrections registry at hub session start, but ONLY in a multi-hub
# estate (the workspace root also holds _KM_Supervisor/). Two things must hold, and each is a
# check that can fail:
#   1. In an estate layout the block prints, immediately after [ HANDOVER ], and its active count
#      counts lifecycle: active notes only (retired/superseded excluded).
#   2. In a standalone hub the block is silent, so a single-hub deployment is unaffected.
# All content here is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# --- Estate layout: workspace root holds a sibling _KM_Supervisor/corrections ---
estate="$work/estate"
hub="$estate/hub"
corr="$estate/_KM_Supervisor/corrections"
mkdir -p "$hub" "$corr"
cp "$ROOT/template/hub-scan.sh" "$hub/hub-scan.sh"
printf '# seed handover\n' > "$hub/HANDOVER.md"
printf 'lifecycle: active\nrule: alpha\n'   > "$corr/a.md"
printf 'lifecycle: retired\nrule: beta\n'   > "$corr/b.md"
printf 'lifecycle: active\nrule: gamma\n'   > "$corr/c.md"

out=$(bash "$hub/hub-scan.sh" 2>&1)

if printf '%s\n' "$out" | grep -qF '[ CORRECTIONS ]'; then
  pass "estate layout prints the [ CORRECTIONS ] block"
else
  die "estate layout did NOT print the [ CORRECTIONS ] block"
fi

if printf '%s\n' "$out" | grep -qF '(2 active)'; then
  pass "active count is 2 (retired note excluded)"
else
  die "active count wrong (expected '(2 active)'); got: $(printf '%s\n' "$out" | grep -F 'active' | head -1)"
fi

# Ordering: [ CORRECTIONS ] must appear after [ HANDOVER ] and before [ INBOX ].
order=$(printf '%s\n' "$out" | grep -nE '\[ (HANDOVER|CORRECTIONS|INBOX) \]' | head -3 | sed -E 's/.*\[ ([A-Z]+) \].*/\1/' | tr '\n' ' ')
if [ "$order" = "HANDOVER CORRECTIONS INBOX " ]; then
  pass "block sits between [ HANDOVER ] and [ INBOX ]"
else
  die "block ordering wrong; got: $order"
fi

# --- Standalone hub: no sibling _KM_Supervisor/ ---
solo="$work/solo/hub"
mkdir -p "$solo"
cp "$ROOT/template/hub-scan.sh" "$solo/hub-scan.sh"
printf '# seed handover\n' > "$solo/HANDOVER.md"

solo_out=$(bash "$solo/hub-scan.sh" 2>&1)
if printf '%s\n' "$solo_out" | grep -qF '[ CORRECTIONS ]'; then
  die "standalone hub printed the [ CORRECTIONS ] block (should be silent)"
else
  pass "standalone hub is silent (single-hub deployment unaffected)"
fi

if [ "$fail" -eq 0 ]; then
  echo "corrections binding fixtures passed"
  exit 0
else
  echo "corrections binding fixtures FAILED"
  exit 1
fi
