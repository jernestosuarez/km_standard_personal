#!/bin/bash
# km-unrepaired-tree: v1.35 | the NEG case is the unrepaired-tree run: with tombstone detection removed the scan reports the quarantine and no tombstone, so the case-A assertions are shown to detect a dead block.
# Canaries for hub merge (v1.35) — RFC-004 Part II.
#
# WHY THIS FILE EXISTS
#
# The one schema change Part II requires is a `merged` registry status with a `merged-into` column,
# and the classification rule it enforces: a hub-shaped directory ABSENT from the registry is
# quarantined by the estate scan, but a tombstoned hub must report a TOMBSTONE, not a quarantine.
# The per-hub scan mechanises the tombstone side: `template/hub-scan.sh`'s [ DEPLOYMENT ] block
# detects a `MERGED-INTO.md` tombstone and reports a TOMBSTONE finding in place of the interview and
# keyword checks a live hub runs, so a merged hub is expected not to scan green (a green scan would
# assert the directory is still a live hub).
#
# BOTH DIRECTIONS
#
#   A  a merged (tombstoned) hub with an otherwise valid live binding reports TOMBSTONE, names the
#      survivor, does not report the HUB NOT INITIATED quarantine, and does not go green.
#   A2 a tombstoned hub whose binding would OTHERWISE quarantine (no interview date) still reports
#      TOMBSTONE and not the quarantine — the tombstone classification takes precedence, which is
#      what "a tombstone, not a quarantine" means.
#   B  the same uninterviewed hub WITHOUT the tombstone reports the HUB NOT INITIATED quarantine and
#      NOT a tombstone — the two classifications are distinguished.
#   C  a valid live hub with no tombstone reports no TOMBSTONE and scans green — the block does not
#      over-fire.
#   NEG a scan with the tombstone detection removed, run on the case-A2 hub, does NOT report
#      TOMBSTONE and the quarantine reappears — proving the case-A assertions detect a dead block.
#      The shipped scan is never modified; a copy is neutered and discarded.
#
# The skill-mode conformance cases prove `skills/km-init/SKILL.md` declares the merge mode reruns the
# interview with the union as pre-fill and the withdrawal mode does not re-interview, at the level the
# standard's tests operate for a prose skill. Each matcher is proven live against its literal string
# so a narrowed assertion cannot go dead, and the file is required non-empty so nothing passes by
# reading nothing.
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/km-merge-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

CANONICAL_REVISION="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

[ -d "$ROOT/template" ] || fail "template not found at $ROOT/template"

# Build a clean, green hub from the template, exactly as test_hub_deployment_binding.sh does.
prepare_hub() {
  local name="$1"
  local hub="$TEST_ROOT/$name"
  mkdir -p "$hub"
  cp -R "$ROOT/template/." "$hub/"

  while IFS= read -r -d '' file; do
    sed -i.bak -e 's|{{INIT_DATE}}|2026-08-01|g' "$file"
    rm -f "$file.bak"
  done < <(find "$hub" -type f -print0)

  sed -i.bak \
    -e 's|{{ROUTING_KEYWORDS}}|alpha, beta, gamma|g' \
    -e 's|{{KM_STANDARD_VERSION}}|1.14|g' \
    -e "s|{{KM_STANDARD_REVISION}}|$CANONICAL_REVISION|g" \
    -e 's|{{KM_STANDARD_SOURCE}}|https://example.invalid/km-standard.git|g' \
    "$hub/km-deployment.md"
  rm -f "$hub/km-deployment.md.bak"

  git -C "$hub" init -q
  git -C "$hub" add -A
  git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
    commit -qm 'init: merge test hub'
  printf '%s\n' "$hub"
}

strip_interview() { # <hub>
  sed -i.bak -e 's|^initiation-interview: .*|initiation-interview: ""|' "$1/km-deployment.md"
  rm -f "$1/km-deployment.md.bak"
}

write_tombstone() { # <hub> <survivor>
  cat > "$1/MERGED-INTO.md" <<EOF
---
type: reference
title: This hub is merged into $2
description: This hub was absorbed into $2 and is tombstoned. Nothing in this directory is current.
tags: [tombstone, merged]
timestamp: 2026-08-22
lifecycle: active
merged-into: $2
---

# Merged into $2

This hub was absorbed into $2 on 2026-08-22 under the owner's authority.
Nothing in this directory is current. Its content lives in the survivor.
EOF
}

commit_hub() { # <hub> <msg>
  git -C "$1" add -A
  git -C "$1" -c user.name='KM Test' -c user.email='km-test@example.invalid' commit -qm "$2"
}

# hub-scan.sh derives HUB from its own directory (`dirname "$0"`), so any scan script this test runs
# must live inside the hub it should scan. The shipped copy already does; the neutered copy is written
# into the hub for the same reason.
run_scan() { # <hub> [scan-script] ; sets OUT and RC ; defaults to the hub's shipped scan
  local hub="$1"
  local scan="${2:-$hub/hub-scan.sh}"
  set +e
  OUT=$(bash "$scan" 2>&1)
  RC=$?
  set -e
}

# hub-scan.sh takes no path argument; it derives HUB from its own location. Confirm the invocation
# shape once so a wrong call cannot make every case pass by producing empty, tombstone-free output.
probe=$(prepare_hub probe)
run_scan "$probe"
[ -n "$OUT" ] || fail "scan produced no output on a clean hub — every case below would read nothing"
[ "$RC" -eq 0 ] || { printf '%s\n' "$OUT" >&2; fail "clean probe hub did not scan green (rc=$RC)"; }
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" && { printf '%s\n' "$OUT" >&2; fail "clean hub reported a TOMBSTONE"; }
pass "clean hub scans green and reports no tombstone"

# --- Case A: a realistic merged hub (valid live binding + tombstone) ---
hubA=$(prepare_hub caseA)
write_tombstone "$hubA" "survivor-hub"
commit_hub "$hubA" 'merge: tombstone caseA into survivor-hub'
run_scan "$hubA"
[ -n "$OUT" ] || fail "caseA produced no scan output"
[ "$RC" -ne 0 ] || { printf '%s\n' "$OUT" >&2; fail "caseA scanned green — a tombstoned hub must not go green"; }
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" || { printf '%s\n' "$OUT" >&2; fail "caseA did not report a TOMBSTONE"; }
printf '%s\n' "$OUT" | grep -Fq "survivor-hub" || { printf '%s\n' "$OUT" >&2; fail "caseA tombstone did not name the survivor"; }
printf '%s\n' "$OUT" | grep -Fq "HUB NOT INITIATED" && { printf '%s\n' "$OUT" >&2; fail "caseA reported the quarantine; a merged hub reports a tombstone, not a quarantine"; }
pass "a merged hub reports a TOMBSTONE naming the survivor, not the quarantine, and does not go green"

# --- Case A2: tombstone takes precedence over a would-be quarantine ---
hubA2=$(prepare_hub caseA2)
strip_interview "$hubA2"
write_tombstone "$hubA2" "survivor-hub"
commit_hub "$hubA2" 'merge: tombstone an uninterviewed caseA2 into survivor-hub'
run_scan "$hubA2"
[ -n "$OUT" ] || fail "caseA2 produced no scan output"
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" || { printf '%s\n' "$OUT" >&2; fail "caseA2 did not report a TOMBSTONE"; }
printf '%s\n' "$OUT" | grep -Fq "HUB NOT INITIATED" && { printf '%s\n' "$OUT" >&2; fail "caseA2 reported the quarantine; the tombstone must take precedence"; }
pass "a tombstone takes precedence over a binding that would otherwise quarantine"

# --- Case B: the same uninterviewed hub without a tombstone is the quarantine, not a tombstone ---
hubB=$(prepare_hub caseB)
strip_interview "$hubB"
commit_hub "$hubB" 'apply: strip interview date, no tombstone (fixture)'
run_scan "$hubB"
[ -n "$OUT" ] || fail "caseB produced no scan output"
printf '%s\n' "$OUT" | grep -Fq "HUB NOT INITIATED" || { printf '%s\n' "$OUT" >&2; fail "caseB did not report the quarantine"; }
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" && { printf '%s\n' "$OUT" >&2; fail "caseB reported a tombstone with no MERGED-INTO.md present"; }
pass "a hub-shaped directory with no tombstone reports the quarantine, not a tombstone"

# --- Case C: a valid live hub with no tombstone does not over-fire and stays green ---
hubC=$(prepare_hub caseC)
run_scan "$hubC"
[ "$RC" -eq 0 ] || { printf '%s\n' "$OUT" >&2; fail "caseC did not scan green (rc=$RC)"; }
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" && { printf '%s\n' "$OUT" >&2; fail "caseC reported a tombstone on a live hub"; }
pass "a live hub with no tombstone stays green and reports no tombstone"

# --- Negative direction: a scan with tombstone detection removed fails the case-A assertions ---
# The shipped scan is copied and the tombstone branch is neutered; the copy is discarded. This proves
# the case-A/A2 assertions detect a dead block rather than passing over a scan that never looked.
neutered="$hubA2/hub-scan-neutered.sh"
# Delete the `if [ -f "$merged_tombstone" ]; then ... elif [ ! -f "$deployment_file" ];` head down to
# just the original `if [ ! -f "$deployment_file" ]`, restoring the pre-v1.35 behaviour.
awk '
  /^if \[ -f "\$merged_tombstone" \]; then$/ { skipping=1 }
  skipping && /^elif \[ ! -f "\$deployment_file" \]; then$/ {
    print "if [ ! -f \"$deployment_file\" ]; then"; skipping=0; next
  }
  !skipping { print }
' "$ROOT/template/hub-scan.sh" > "$neutered"
# Prove the neutering actually removed the branch, or the negative test is vacuous.
grep -Fq 'merged_tombstone" ]; then' "$neutered" && fail "neutering did not remove the tombstone branch"
grep -Fq 'TOMBSTONE:' "$neutered" && fail "neutering left the TOMBSTONE report in place"
run_scan "$hubA2" "$neutered"
[ -n "$OUT" ] || fail "neutered scan produced no output"
printf '%s\n' "$OUT" | grep -Fq "TOMBSTONE" && { printf '%s\n' "$OUT" >&2; fail "neutered scan still reported a TOMBSTONE — the branch was not the cause"; }
printf '%s\n' "$OUT" | grep -Fq "HUB NOT INITIATED" || { printf '%s\n' "$OUT" >&2; fail "neutered scan did not fall back to the quarantine — the negative direction is not established"; }
pass "with tombstone detection removed the scan reports the quarantine and no tombstone (dead-block detected); shipped scan untouched"

# --- Skill-mode conformance: merge and withdrawal modes are declared in the initiation skill ---
skill="$ROOT/skills/km-init/SKILL.md"
[ -s "$skill" ] || fail "skills/km-init/SKILL.md is missing or empty — the checks below would read nothing"

assert_skill() { # <literal-substring> <human-description>
  # Prove the matcher fires on its own literal first, so a typo cannot make the assertion pass dead.
  printf '%s\n' "$1" | grep -Fq "$1" || fail "skill matcher is dead for: $2"
  grep -Fq "$1" "$skill" || fail "km-init SKILL.md does not declare: $2"
}

assert_skill "Re-run the interview on the survivor" "merge mode re-runs the initiation interview"
assert_skill "union of the two hubs' answers is the **pre-fill**" "merge mode uses the union as pre-fill, never the answer"
assert_skill "**No re-interview**" "withdrawal mode does not re-interview the receiving hub"
assert_skill "**Not a merge.**" "the three-case routing refuses the overlap case"
assert_skill "Merge mode: \`--merge" "the merge mode is named"
assert_skill "Withdrawal mode: \`--withdraw" "the withdrawal mode is named"
assert_skill "tombstone, not a quarantine" "the tombstone-not-quarantine rule is stated in the skill"
pass "km-init declares the merge and withdrawal modes with the interview-rerun, union-pre-fill, and no-re-interview behaviour"

echo "hub merge tests passed"
