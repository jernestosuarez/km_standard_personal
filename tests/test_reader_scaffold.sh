#!/bin/bash
# Canaries for template/reader/reader-scan.sh (v1.40) - the Reader-context declaration validator.
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
mkfixture() {
  local dst="$1"
  rm -rf "$dst"
  mkdir -p "$dst"
  cp "$SCAFFOLD/.km-tier" "$dst/.km-tier"
  cp "$SCAFFOLD/CLAUDE.md" "$dst/CLAUDE.md"
  cp "$SCAFFOLD/AGENTS.md" "$dst/AGENTS.md"
  mkdir -p "$dst/outputs"
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
run_case "open scope '*' errors" "$c" 1 "scope is OPEN"

c="$work/open-all"; mkfixture "$c"; printf 'reader\nscope: all\n' > "$c/.km-tier"
run_case "open scope 'all' errors" "$c" 1 "scope is OPEN"

c="$work/open-empty"; mkfixture "$c"; printf 'reader\nscope:\n' > "$c/.km-tier"
run_case "empty scope errors" "$c" 1 "scope is OPEN"

# --- Direction 3: REFUSE (exit 2) on input that cannot be evaluated ---
run_case "nonexistent context refuses (not a pass)" "$work/does-not-exist" 2 "REFUSED"

echo
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
  exit 0
else
  echo "SOME FAILED"
  exit 1
fi
