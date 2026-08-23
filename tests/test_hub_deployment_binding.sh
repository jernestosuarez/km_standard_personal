#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/km-deployment-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

CANONICAL_REVISION="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

prepare_hub() {
  local name="$1" state="$2" revision="$3" profile_id="$4" profile_revision="$5"
  local namespace="$6" contract_revision="$7"
  local hub="$TEST_ROOT/$name"
  mkdir -p "$hub"
  cp -R "$ROOT/template/." "$hub/"

  while IFS= read -r -d '' file; do
    sed -i.bak -e 's|{{INIT_DATE}}|2026-08-01|g' "$file"
    rm -f "$file.bak"
  done < <(find "$hub" -type f -print0)

  local binding="$hub/km-deployment.md"
  sed -i.bak \
    -e 's|{{ROUTING_KEYWORDS}}|alpha, beta, gamma|g' \
    -e 's|{{KM_STANDARD_VERSION}}|1.14|g' \
    -e "s|{{KM_STANDARD_REVISION}}|$revision|g" \
    -e 's|{{KM_STANDARD_SOURCE}}|https://example.invalid/km-standard.git|g' \
    -e "s|deployment-state: canonical|deployment-state: $state|" \
    -e "s|organization-profile-id: \"\"|organization-profile-id: \"$profile_id\"|" \
    -e "s|organization-profile-revision: \"\"|organization-profile-revision: \"$profile_revision\"|" \
    -e "s|enterprise-namespace: \"\"|enterprise-namespace: \"$namespace\"|" \
    -e "s|enterprise-contract-revision: \"\"|enterprise-contract-revision: \"$contract_revision\"|" \
    "$binding"
  rm -f "$binding.bak"

  git -C "$hub" init -q
  git -C "$hub" add -A
  git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
    commit -qm 'init: deployment test hub'
  printf '%s\n' "$hub"
}

run_case() {
  local name="$1" state="$2" revision="$3" profile_id="$4" profile_revision="$5"
  local namespace="$6" contract_revision="$7" expected_status="$8" expected_text="$9"
  local hub output status
  hub=$(prepare_hub "$name" "$state" "$revision" "$profile_id" "$profile_revision" \
    "$namespace" "$contract_revision")

  set +e
  output=$(bash "$hub/hub-scan.sh" 2>&1)
  status=$?
  set -e

  if [ "$status" -ne "$expected_status" ]; then
    printf '%s\n' "$output" >&2
    fail "$name returned $status, expected $expected_status"
  fi
  if ! printf '%s\n' "$output" | grep -Fq "$expected_text"; then
    printf '%s\n' "$output" >&2
    fail "$name did not report: $expected_text"
  fi
}

run_case \
  valid-canonical canonical "$CANONICAL_REVISION" "" "" "" "" \
  0 "OK: canonical standard binding is complete; no organization profile applied"

run_case \
  valid-organization-bound organization-bound "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "contract-7" \
  0 "OK: canonical and organization profile bindings are complete"

run_case \
  partial-organization-bound organization-bound "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "" \
  1 "organization-bound deployment requires all organization and enterprise fields"

run_case \
  invalid-canonical-revision canonical "abc123" "" "" "" "" \
  1 "canonical-standard-revision must be a full 40-character lowercase Git revision"

run_case \
  canonical-with-organization-values canonical "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "contract-7" \
  1 "canonical deployment must not contain organization or enterprise binding values"

# Hub species axes (Rule 6, v1.23) — optional fields on the same binding.
# Absent is already covered: every case above carries neither field and passes or fails on
# other grounds. Here: declared valid values pass; an out-of-enum value is an error.
declare_species() {
  local hub="$1"; shift
  awk -v lines="$*" '1; /^deployment-state: canonical$/ { n=split(lines, a, ";"); for (i=1; i<=n; i++) print a[i] }' \
    "$hub/km-deployment.md" > "$hub/km-deployment.md.new"
  mv "$hub/km-deployment.md.new" "$hub/km-deployment.md"
  git -C "$hub" add km-deployment.md
  git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
    commit -qm 'apply: declare hub species'
}

species_hub=$(prepare_hub species-valid canonical "$CANONICAL_REVISION" "" "" "" "")
declare_species "$species_hub" "station: org-core;exposure: never-public"
set +e
output=$(bash "$species_hub/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
  printf '%s\n' "$output" >&2
  fail "species-valid returned $status, expected 0"
fi
if ! printf '%s\n' "$output" | grep -Fq "OK: canonical standard binding is complete"; then
  printf '%s\n' "$output" >&2
  fail "species-valid did not report a complete canonical binding"
fi

# The purpose interview gate (v1.25) — the canary proving the check fires: a hub whose
# binding carries no initiation-interview date is quarantined (error), never scanned green.
uninterviewed=$(prepare_hub uninterviewed canonical "$CANONICAL_REVISION" "" "" "" "")
sed -i.bak -e 's|^initiation-interview: .*|initiation-interview: ""|' \
  "$uninterviewed/km-deployment.md"
rm -f "$uninterviewed/km-deployment.md.bak"
git -C "$uninterviewed" add km-deployment.md
git -C "$uninterviewed" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
  commit -qm 'apply: strip interview date (fixture)'
set +e
output=$(bash "$uninterviewed/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 1 ]; then
  printf '%s\n' "$output" >&2
  fail "uninterviewed returned $status, expected 1"
fi
if ! printf '%s\n' "$output" | grep -Fq "HUB NOT INITIATED"; then
  printf '%s\n' "$output" >&2
  fail "uninterviewed did not report the quarantine"
fi
# One defect, not two: the keyword check is withheld while the interview date is itself missing,
# so the hub is told about the one act that fixes both.
#
# Scoped to the [ DEPLOYMENT ] block rather than the whole scan (narrowed in v1.32). The assertion
# is about the deployment block WITHHOLDING ITS ERROR, and it was written as a substring search over
# the entire output, which also matched any other block that happens to NAME the field — [ PROJECTION ]
# lists routing-keywords among the fact classes it did not compare. Matching a coverage line is not
# evidence that the error fired, so the scope is narrowed and the error line itself is asserted
# absent, which is a stricter test of the same rule.
deployment_block=$(printf '%s\n' "$output" | awk '/^\[ DEPLOYMENT \]/{f=1;next} /^\[ /{f=0} f')
# Fail closed on an empty extraction: if the block header ever changes, awk returns nothing and the
# search below passes over evidence it never read, which is the same "found nothing" pass the
# standard forbids. And prove the matcher itself fires, so a narrowed assertion cannot go dead.
if [ -z "$deployment_block" ]; then
  printf '%s\n' "$output" >&2
  fail "the [ DEPLOYMENT ] block could not be extracted — the check below would pass by reading nothing"
fi
if ! printf '  ! routing-keywords is empty\n' | grep -Fq "routing-keywords"; then
  fail "the routing-keywords matcher does not fire on a known violation (dead assertion)"
fi
if printf '%s\n' "$deployment_block" | grep -Fq "routing-keywords"; then
  printf '%s\n' "$output" >&2
  fail "uninterviewed also reported routing-keywords (should be withheld until the date is valid)"
fi

# The routing-keywords gate (v1.28) — two canaries proving the check fires on each way the field
# can be wrong, on a hub whose interview date is otherwise valid.
mutate_binding() { # <hub> <sed-expression> <commit-msg>
  sed -i.bak -e "$2" "$1/km-deployment.md"
  rm -f "$1/km-deployment.md.bak"
  git -C "$1" add km-deployment.md
  git -C "$1" -c user.name='KM Test' -c user.email='km-test@example.invalid' commit -qm "$3"
}

nokeywords=$(prepare_hub nokeywords canonical "$CANONICAL_REVISION" "" "" "" "")
mutate_binding "$nokeywords" 's|^routing-keywords: .*|routing-keywords: ""|' \
  'apply: empty routing keywords (fixture)'
set +e
output=$(bash "$nokeywords/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 1 ]; then
  printf '%s\n' "$output" >&2
  fail "nokeywords returned $status, expected 1"
fi
if ! printf '%s\n' "$output" | grep -Fq "routing-keywords is empty"; then
  printf '%s\n' "$output" >&2
  fail "nokeywords did not report the empty keyword field"
fi

placeholder=$(prepare_hub keywords-placeholder canonical "$CANONICAL_REVISION" "" "" "" "")
mutate_binding "$placeholder" 's|^routing-keywords: .*|routing-keywords: "{{ROUTING_KEYWORDS}}"|' \
  'apply: unsubstituted routing keywords (fixture)'
set +e
output=$(bash "$placeholder/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 1 ]; then
  printf '%s\n' "$output" >&2
  fail "keywords-placeholder returned $status, expected 1"
fi
if ! printf '%s\n' "$output" | grep -Fq "routing-keywords still carries an unsubstituted placeholder"; then
  printf '%s\n' "$output" >&2
  fail "keywords-placeholder did not report the unsubstituted value"
fi

# The per-token gate (added in v1.44, drafted and unpublished; defect D6): four cases, and the
# pair of directions is the point of them.
#
# routing-keywords is a comma-separated LIST, and until v1.44 the gate tested the whole value: an
# empty arm matching only "" and a substring arm matching "{{". A value of ", ," is neither, so it
# fell through every arm and the hub scanned green carrying no keyword at all, which is precisely
# the state v1.28 added the gate to prevent. The consuming surfaces drop empty tokens silently, so
# nothing anywhere reported the hub as unattributable.
#
# Two cases prove the gate fires on the class, and two prove it does not fire on a legitimate
# declaration, because a check that matches everything proves as little as one that matches
# four were run against the UNREPAIRED scan first, where the two firing cases fail, which is what
# makes them evidence that the gate detects the defect rather than agreeing with whatever the scan
# already did.
keywords_case() { # <name> <value> <expect-status> <expect-text>
  local hub output status
  hub=$(prepare_hub "$1" canonical "$CANONICAL_REVISION" "" "" "" "")
  mutate_binding "$hub" "s|^routing-keywords: .*|routing-keywords: \"$2\"|" \
    "apply: routing keywords fixture ($1)"
  # Assert the fixture actually carries the value under test. A sed that silently matched nothing
  # would leave the template default in place, and the case would then pass by testing a hub that
  # never carried the defect.
  if ! grep -Fq "routing-keywords: \"$2\"" "$hub/km-deployment.md"; then
    fail "$1: the fixture does not carry routing-keywords: \"$2\" (the mutation did not apply)"
  fi
  set +e
  output=$(bash "$hub/hub-scan.sh" 2>&1)
  status=$?
  set -e
  if [ "$status" -ne "$3" ]; then
    printf '%s\n' "$output" >&2
    fail "$1 returned $status, expected $3"
  fi
  if ! printf '%s\n' "$output" | grep -Fq "$4"; then
    printf '%s\n' "$output" >&2
    fail "$1 did not report: $4"
  fi
}

# Fires: every token trims to nothing. Neither empty nor placeholder-bearing as a whole value.
keywords_case keywords-all-empty-tokens ', ,' 1 \
  "routing-keywords carries no usable keyword"
# Fires: a lone delimiter, which leaves no real keyword on either side of it.
keywords_case keywords-lone-delimiter ',' 1 \
  "routing-keywords carries no usable keyword"
# Does NOT fire: a legitimate multi-keyword list. The deployment block reports its own OK line.
# The value differs from the one prepare_hub substitutes, so the fixture mutation is a real edit
# and the guard above is testing a hub that was actually changed.
keywords_case keywords-legitimate-list 'delta, epsilon, zeta' 0 \
  "OK: canonical standard binding is complete"
# Does NOT fire: one legitimate keyword and no delimiter at all.
keywords_case keywords-single 'alpha' 0 \
  "OK: canonical standard binding is complete"

# A stray empty entry BESIDE real keywords is named but does not quarantine the hub. One usable
# keyword is all a surface needs to attribute the hub, so a trailing or repeated comma is a typo
# worth seeing rather than grounds to stop a hub scanning. Asserted so the threshold cannot drift
# in either direction without a test saying so.
stray=$(prepare_hub keywords-stray-entry canonical "$CANONICAL_REVISION" "" "" "" "")
mutate_binding "$stray" 's|^routing-keywords: .*|routing-keywords: "alpha, , beta"|' \
  'apply: stray empty entry (fixture)'
set +e
output=$(bash "$stray/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
  printf '%s\n' "$output" >&2
  fail "keywords-stray-entry returned $status, expected 0 (an advisory, never a quarantine)"
fi
if ! printf '%s\n' "$output" | grep -Fq "routing-keywords entry 2 is empty"; then
  printf '%s\n' "$output" >&2
  fail "keywords-stray-entry did not name the empty entry"
fi

species_bad=$(prepare_hub species-invalid canonical "$CANONICAL_REVISION" "" "" "" "")
declare_species "$species_bad" "station: everywhere"
set +e
output=$(bash "$species_bad/hub-scan.sh" 2>&1)
status=$?
set -e
if [ "$status" -ne 1 ]; then
  printf '%s\n' "$output" >&2
  fail "species-invalid returned $status, expected 1"
fi
if ! printf '%s\n' "$output" | grep -Fq "station must be org-core, domain, engagement or publication"; then
  printf '%s\n' "$output" >&2
  fail "species-invalid did not report the station enum error"
fi

echo "deployment binding tests passed"
