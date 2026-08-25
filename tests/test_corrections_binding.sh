#!/bin/bash
# km-unrepaired-tree: v1.57 | the two counter cases were run against the UNREPAIRED template/hub-scan.sh first and both fail there: over a registry of two real rules plus a README and a generated index, neither carrying a rule:, the block printed "(4 active)" and claimed "every lifecycle: active note's rule: is in force in this hub". The v1.19 estate-layout, ordering and standalone-silence cases predate this declaration and no run against their own unrepaired tree is reconstructed here.
# Fixtures for the [ CORRECTIONS ] block (v1.19) in template/hub-scan.sh.
#
# The block binds the estate corrections registry at hub session start, but ONLY in a multi-hub
# estate (the workspace root also holds _KM_Supervisor/). Two things must hold, and each is a
# check that can fail:
#   1. In an estate layout the block prints, immediately after [ HANDOVER ], and its active count
#      counts lifecycle: active notes only (retired/superseded excluded).
#   2. In a standalone hub the block is silent, so a single-hub deployment is unaffected.
#   3. The count is of RULES IN FORCE: a note that is not scaffold, carries a rule:, and is
#      lifecycle: active. Scaffold and a note whose rule has been retired or superseded are
#      excluded, and the printed line states that predicate rather than a wider claim. (Added in
#      v1.57, drafted and unpublished: this material binds nothing until its own owner push.)
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
# v1.57 fixtures. `lifecycle:` records whether a DOCUMENT is current; it does not make a note a
# binding rule. `rule:` is what does — STANDARD.md §"`rule:` is the whole point", and the v1.19
# section already specified the count as the active notes "whose rule: is in force". A scaffold
# document in the registry carries `lifecycle: active` and no `rule:`, and before v1.57 the count
# read it as a rule that binds, drifting by one more with every scaffold file ever added.
printf 'type: reference\nlifecycle: active\n' > "$corr/README.md"
# A generated folder index carries `lifecycle: active` by construction (v1.15), so it is the
# second scaffold shape the count must not read as a rule.
printf 'type: index\nlifecycle: active\n'     > "$corr/index.md"
# A note carrying a rule that is no longer current is not counted either: both halves must hold.
printf 'lifecycle: superseded\nrule: delta\n' > "$corr/d.md"

out=$(bash "$hub/hub-scan.sh" 2>&1)

if printf '%s\n' "$out" | grep -qF '[ CORRECTIONS ]'; then
  pass "estate layout prints the [ CORRECTIONS ] block"
else
  die "estate layout did NOT print the [ CORRECTIONS ] block"
fi

# The count is of RULES IN FORCE, and the printed line has to say what the predicate judges.
# Two notes qualify here: a.md and c.md. Excluded, each for its own reason and each of them a
# distinct arm of the predicate: README.md and index.md are scaffold carrying no `rule:`, b.md is
# retired, d.md is superseded. Before v1.57 the count was 4: it read the two scaffold files as rules that bind.
if printf '%s\n' "$out" | grep -qF '(2 active rule(s))'; then
  pass "active-rule count is 2 (scaffold, retired and superseded notes excluded)"
else
  die "active-rule count wrong (expected '(2 active rule(s))'); got: $(printf '%s\n' "$out" | grep -F 'active' | head -1)"
fi

# The printed claim must not outrun the predicate. A line saying every lifecycle: active note's
# rule: is in force describes a predicate this block does not run, and a check whose printed claim
# outruns what it counts is the class this repository has spent twelve versions repairing.
if printf '%s\n' "$out" | grep -qF 'not scaffold, carry a rule:, and are lifecycle: active'; then
  pass "the printed line states the predicate actually counted"
else
  die "the printed line does not state the predicate actually counted; got: $(printf '%s\n' "$out" | grep -F 'in force' | head -1)"
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
