#!/bin/bash
# km-unrepaired-tree: v1.41 | every scope-bypass case was run against the UNREPAIRED scanner and passed there (exit 0, "closed scope of N hub(s)"), which is what makes them evidence rather than decoration.
# Canaries for template/reader/reader-scan.sh (v1.41) - the Reader-context declaration validator.
#
# WHY THIS FILE EXISTS
#
# reader-scan.sh reports a malformed declaration by FINDING a defect, so a well-formed reader and a
# broken check produce the same "OK". This proves the check fires on each defect class it models
# (missing marker, wrong tier, missing contract file, missing outputs, open scope) AND that it stays
# quiet on genuinely well-formed input (a full reader and a scoped reader with a closed list). It also
# proves the check REFUSES (exit 2) on input it cannot evaluate, rather than passing it.
#
# WHAT A CANARY CANNOT DO - the stated limit
#
# These cases prove the check fires on the declaration-shape classes it models. They say nothing about
# isolation: reader-scan.sh validates the DECLARATION, not whether a scoped reader can physically read
# outside its scope, which is a hosting fact the check never consults and its coverage line says so.
#
# They also prove the right class only as far as the class was understood when they were written. The
# original suite proved an exact `*` and an exact `all` and never a LIST carrying one, so the scope
# bypass passed a green suite. The bypass cases below were run against the unrepaired scanner and
# failed there before the repair was written; a canary that passes against both forms proves nothing.
#
# All fixture content is synthetic. No real person, organization, or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAFFOLD="$ROOT/template/reader"
SCAN="$SCAFFOLD/reader-scan.sh"

work="$(mktemp -d "${TMPDIR:-/tmp}/km-reader-canary.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

[ -f "$SCAN" ] || { echo "FAIL: reader-scan.sh not found at $SCAN"; exit 1; }

# Build one clean fixture from the shipped scaffold.
# It FAILS CLOSED: a fixture built from a source that yielded nothing is not a clean fixture, it is a
# broken extraction, and a suite that runs on it reports the check's silence rather than the check.
mkfixture() {
  local dst="$1"
  rm -rf "$dst"
  mkdir -p "$dst"
  cp "$SCAFFOLD/.km-tier" "$dst/.km-tier"
  cp "$SCAFFOLD/CLAUDE.md" "$dst/CLAUDE.md"
  cp "$SCAFFOLD/AGENTS.md" "$dst/AGENTS.md"
  mkdir -p "$dst/outputs"
  fixture_ok "$dst" || { echo "FAIL: fixture extraction produced nothing usable at $dst"; exit 1; }
}

# fixture_ok <dir> - true only when the extraction actually produced the material the cases assert on.
fixture_ok() {
  local d="$1"
  [ -s "$d/.km-tier" ] && [ -s "$d/CLAUDE.md" ] && [ -s "$d/AGENTS.md" ] && [ -d "$d/outputs" ]
}

# run_case <desc> <dir> <expected-exit> [required-substring]
run_case() {
  local desc="$1" dir="$2" want="$3" needle="${4:-}"
  local out rc
  out="$(bash "$SCAN" "$dir" 2>&1)"; rc=$?
  if [ "$rc" -ne "$want" ]; then
    die "$desc - expected exit $want, got $rc"
    return
  fi
  if [ -n "$needle" ] && ! printf '%s' "$out" | grep -qi "$needle"; then
    die "$desc - exit $rc correct but output did not mention '$needle'"
    return
  fi
  pass "$desc"
}

# --- Direction 1: the shipped scaffold and well-formed variants PASS (exit 0) ---
run_case "shipped scaffold (full reader) passes" "$SCAFFOLD" 0 "RESULT: OK"

# coverage line must be present and must disclaim isolation
if bash "$SCAN" "$SCAFFOLD" 2>&1 | grep -qi "NOT isolation"; then
  pass "passing run states its coverage and disclaims isolation"
else
  die "passing run did not state coverage/isolation limit"
fi

clean="$work/clean"; mkfixture "$clean"
run_case "clean fixture (full reader) passes" "$clean" 0 "RESULT: OK"

scoped="$work/scoped"; mkfixture "$scoped"
printf 'reader\nscope: hub-alpha, hub-beta\n' > "$scoped/.km-tier"
run_case "scoped reader with closed list passes" "$scoped" 0 "closed scope of 2"

# --- Direction 2: each defect class ERRORs (exit 1) with a naming line ---
c="$work/no-marker"; mkfixture "$c"; rm -f "$c/.km-tier"
run_case "missing .km-tier errors" "$c" 1 ".km-tier marker missing"

c="$work/wrong-tier"; mkfixture "$c"; printf 'hub\n' > "$c/.km-tier"
run_case "wrong tier name errors" "$c" 1 "expected 'reader'"

c="$work/no-contract"; mkfixture "$c"; rm -f "$c/CLAUDE.md" "$c/AGENTS.md"
run_case "missing contract file errors" "$c" 1 "governing contract file"

c="$work/no-outputs"; mkfixture "$c"; rm -rf "$c/outputs"
run_case "missing outputs area errors" "$c" 1 "outputs/ area missing"

c="$work/open-star"; mkfixture "$c"; printf 'reader\nscope: *\n' > "$c/.km-tier"
run_case "open scope '*' errors" "$c" 1 "OPEN token"

c="$work/open-all"; mkfixture "$c"; printf 'reader\nscope: all\n' > "$c/.km-tier"
run_case "open scope 'all' errors" "$c" 1 "OPEN token"

c="$work/open-empty"; mkfixture "$c"; printf 'reader\nscope:\n' > "$c/.km-tier"
run_case "empty scope errors" "$c" 1 "scope declared but empty"

# --- Direction 3: REFUSE (exit 2) on input that cannot be evaluated ---
run_case "nonexistent context refuses (not a pass)" "$work/does-not-exist" 2 "REFUSED"

# --- Direction 2b: the scope BYPASS class - a token hidden in a list ---
#
# These are the cases the original suite did not have, which is why the defect shipped: it proved an
# exact '*' and an exact 'all' and never a LIST containing one. Every case below was run against the
# unrepaired scanner and passed there (exit 0, "closed scope of N hub(s)"), which is what makes them
# evidence rather than decoration.

scope_case() { # scope_case <desc> <scope-line-value> <expected-exit> <needle>
  local desc="$1" value="$2" want="$3" needle="$4"
  local d="$work/scope-$(echo "$desc" | tr -c 'a-zA-Z0-9' '-')"
  mkfixture "$d"
  printf 'reader\nscope: %s\n' "$value" > "$d/.km-tier"
  run_case "$desc" "$d" "$want" "$needle"
}

scope_case "open token first in a list errors"  '*, hub-alpha'              1 "OPEN"
scope_case "open token last in a list errors"   'hub-alpha, *'              1 "OPEN"
scope_case "open token inside a list errors"    'hub-alpha, all, hub-beta'  1 "OPEN"
scope_case "uppercase open token errors"        'hub-alpha, ALL'            1 "OPEN"

# the offending token must be named, not merely counted
c="$work/scope-names-token"; mkfixture "$c"
printf 'reader\nscope: *, hub-alpha\n' > "$c/.km-tier"
if bash "$SCAN" "$c" 2>&1 | grep -q "'\*'"; then
  pass "rejection names the offending open token"
else
  die "rejection did not name the offending open token"
fi

# and it must NOT report the bypassed scope as closed
if bash "$SCAN" "$c" 2>&1 | grep -qi "closed scope of"; then
  die "a list carrying an open token was still reported as a closed scope"
else
  pass "a list carrying an open token is not reported as a closed scope"
fi

scope_case "trailing delimiter errors"          'hub-alpha,'                1 "empty entry"
scope_case "leading delimiter errors"           ', hub-alpha'               1 "empty entry"
scope_case "repeated delimiter errors"          'hub-alpha,, hub-beta'      1 "empty entry"
scope_case "duplicate token errors"             'hub-alpha, hub-alpha'      1 "duplicate"
scope_case "malformed identifier errors"        'hub-alpha, ../etc'         1 "not a well formed hub identifier"
scope_case "identifier with a space errors"     'hub alpha'                 1 "not a well formed hub identifier"

# a delimiter must never become part of a hub name
c="$work/scope-no-delimiter-in-name"; mkfixture "$c"
printf 'reader\nscope: hub-alpha,\n' > "$c/.km-tier"
if bash "$SCAN" "$c" 2>&1 | grep -q "hub-alpha,"; then
  die "a trailing delimiter was carried into a reported hub name"
else
  pass "a trailing delimiter never becomes part of a hub name"
fi

# the duplicate must be named
c="$work/scope-names-duplicate"; mkfixture "$c"
printf 'reader\nscope: hub-alpha, hub-alpha\n' > "$c/.km-tier"
dup_out="$(bash "$SCAN" "$c" 2>&1)"
if printf '%s' "$dup_out" | grep -qi "duplicate" && printf '%s' "$dup_out" | grep -q "hub-alpha"; then
  pass "rejection names the duplicated token"
else
  die "rejection did not name the duplicated token"
fi

# --- Direction 1b: legitimate closed scopes still pass, so the check does not simply match everything ---
scope_case "three-hub closed scope passes"      'hub-alpha, hub-beta, hub-gamma' 0 "closed scope of 3"
scope_case "single-hub closed scope passes"     'hub-alpha'                      0 "closed scope of 1"
scope_case "digits in a hub identifier pass"    'hub-alpha, q3-launch-2026'      0 "closed scope of 2"

c="$work/scope-absent"; mkfixture "$c"
printf 'reader\n' > "$c/.km-tier"
run_case "absent scope reports a full reader" "$c" 0 "full reader"

# --- Direction 3b: REFUSE (exit 2) on a declaration that cannot be evaluated ---
#
# A scope line the parser cannot evaluate is a coverage gap, never a pass. Two forms are modelled: a
# marker declaring the scope more than once (which of the two governs is not answerable), and a scope
# line carrying control characters (tokenisation cannot be trusted on bytes the parser cannot read).

c="$work/scope-two-declarations"; mkfixture "$c"
printf 'reader\nscope: hub-alpha\nscope: hub-beta\n' > "$c/.km-tier"
run_case "two scope declarations refuse (not a pass)" "$c" 2 "REFUSED"

c="$work/scope-control-chars"; mkfixture "$c"
printf 'reader\nscope: hub-alpha,\thub\001beta\n' > "$c/.km-tier"
run_case "unevaluable scope line refuses (not a pass)" "$c" 2 "REFUSED"

# a refusal must say it could not evaluate, rather than reporting a verdict
if bash "$SCAN" "$work/scope-two-declarations" 2>&1 | grep -qi "could not be evaluated\|coverage gap"; then
  pass "a refusal reports that the declaration could not be evaluated"
else
  die "a refusal did not report an evaluation failure"
fi

c="$work/marker-unreadable"; mkfixture "$c"; chmod 000 "$c/.km-tier"
run_case "unreadable marker refuses (not a pass)" "$c" 2 "REFUSED"
chmod 644 "$c/.km-tier"

# --- Distribution guarantees: the mirrors, and generated output ---
#
# The scaffold states that CLAUDE.md and AGENTS.md carry the same contract and differ only by the
# mirror note AGENTS.md opens with. A stated equivalence that nothing checks drifts, so check it.

mirror_note_last=6   # lines 3-6: the blockquote AGENTS.md opens with, plus its trailing blank line
if diff -q <(sed "3,${mirror_note_last}d" "$SCAFFOLD/AGENTS.md") "$SCAFFOLD/CLAUDE.md" >/dev/null 2>&1; then
  pass "instruction mirrors carry the same contract apart from the documented mirror note"
else
  die "instruction mirrors differ beyond the documented mirror note"
fi

# and the check must be able to fail: a contract edit made in one mirror only is a defect
m="$work/mirror-drift"; mkfixture "$m"
printf '\nAn edit made in one mirror only.\n' >> "$m/CLAUDE.md"
if diff -q <(sed "3,${mirror_note_last}d" "$m/AGENTS.md") "$m/CLAUDE.md" >/dev/null 2>&1; then
  die "mirror check did not fire on a one-sided contract edit"
else
  pass "mirror check fires on a one-sided contract edit"
fi

# Generated reader output must not surface as untracked material; the shipped convention doc must.
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  gen="$SCAFFOLD/outputs/.km-canary-generated-output.md"
  printf 'synthetic generated output\n' > "$gen"
  if git -C "$ROOT" check-ignore -q "$gen"; then
    pass "generated reader output is ignored, so it cannot surface as untracked material"
  else
    die "generated reader output would surface as untracked material"
  fi
  rm -f "$gen"
  if git -C "$ROOT" ls-files --error-unmatch "template/reader/outputs/README.md" >/dev/null 2>&1; then
    pass "the shipped outputs/ convention document stays tracked"
  else
    die "the shipped outputs/ convention document is not tracked"
  fi
else
  echo "SKIP: git unavailable or not a work tree; distribution-ignore cases not run (coverage gap, not a pass)"
fi

# --- The suite's own fail-closed proof ---
#
# mkfixture exits the suite when the extraction yields nothing. Prove the guard fires rather than
# trusting it, because a fixture that silently produced nothing makes every case above vacuous.
empty="$work/empty-extraction"; mkdir -p "$empty"
if fixture_ok "$empty"; then
  die "fixture guard accepted an empty extraction"
else
  pass "fixture guard rejects an empty extraction (the suite fails closed)"
fi

echo

echo
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
else
  echo "SOME FAILED"
  exit 1
fi
