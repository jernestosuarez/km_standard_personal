#!/bin/bash
# km-unrepaired-tree: v1.29 | case 3 is the unrepaired-tree run: against the v1.28 instrument the ignored boundary construct returned exit 0 on a tree full of matches, and the case now requires 1 or 2 and never 0.
# Canaries for tests/test_canonical_leakage.sh (v1.29), the canonical leakage instrument.
#
# The instrument reports leakage by matching, so its failure mode is "found nothing" — the same shape
# as a clean tree. A check whose pass and whose breakage look identical has to be proven in BOTH
# directions or its output means nothing, which is exactly how v1.28 shipped an instrument that
# printed "canonical leakage check passed" against a tree full of matches.
#
# Nine cases, each an assertion that can fail:
#   1. A real violation in a tracked file is CAUGHT (exit 1) and named.
#   2. A genuinely clean tree PASSES (exit 0).
#   3. The v1.28 defect never recurs: a boundary construct the engine ignores can never produce a
#      pass. Asserted portably — caught (1) or refused (2), never 0 — so the test holds on a host
#      whose engine does honour the construct.
#   4. The case-insensitive half of a denylist is expressible with -i, and is off without it.
#   5. -w actually bounds the match, and its absence is genuinely the looser mode.
#   6. An empty scan set is REFUSED, not passed: an unread tree is not a clean tree.
#   7. A tree that is not a readable repository is REFUSED, not passed.
#   8. Usage errors are refused (no argument, empty pattern, unknown flag).
#   9. Exit codes are read unpiped, so a pipeline cannot mask them (this file's own discipline).
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTRUMENT="$ROOT/tests/test_canonical_leakage.sh"

work="$(mktemp -d "${TMPDIR:-/tmp}/km-leak-guard.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# Build a fixture tree that carries its own copy of the instrument at the same relative path, so the
# instrument resolves its ROOT to the fixture and never to the real repository.
make_tree() {
  local name="$1"
  local body="$2"
  local tree="$work/$name"
  mkdir -p "$tree/tests"
  cp "$INSTRUMENT" "$tree/tests/test_canonical_leakage.sh"
  chmod +x "$tree/tests/test_canonical_leakage.sh"
  printf '%s\n' "$body" > "$tree/doc.md"
  git -C "$tree" init -q
  git -C "$tree" config user.name 'KM Test'
  git -C "$tree" config user.email 'km-test@example.invalid'
  git -C "$tree" add -A
  git -C "$tree" commit -qm 'fixture'
  printf '%s' "$tree"
}

# Run the instrument against a fixture tree. Sets $out and $st. The status is captured directly from
# the command, never through a pipe, because a pipeline's exit status is the last command's.
run() {
  local tree="$1"; shift
  out="$("$tree/tests/test_canonical_leakage.sh" "$@" 2>&1)"
  st=$?
}

dirty="$(make_tree dirty 'a line that contains zorbnix in the middle')"
clean="$(make_tree clean 'a line with nothing of interest in it')"
cased="$(make_tree cased 'a line that contains Zorbnix capitalised')"
substr="$(make_tree substr 'a line that contains zorbnixx as a prefix only')"

# --- 1. catches a real violation ----------------------------------------------------------------
run "$dirty" -w 'zorbnix'
if [ "$st" -eq 1 ] && printf '%s' "$out" | grep -q 'doc.md'; then
  pass "1 violation caught: exit 1 and the file named (exit=$st)"
else
  die "1 violation NOT caught: exit=$st out=[$out]"
fi

# --- 2. passes on genuinely clean input ---------------------------------------------------------
run "$clean" -w 'zorbnix'
if [ "$st" -eq 0 ] && printf '%s' "$out" | grep -q 'canonical leakage check passed'; then
  pass "2 clean tree passes: exit 0 with the scan set stated (exit=$st)"
else
  die "2 clean tree did not pass: exit=$st out=[$out]"
fi

# --- 3. the v1.28 defect: an ignored boundary can never report a pass ---------------------------
for bad in '\bzorbnix\b' '\<zorbnix\>' '[[:<:]]zorbnix[[:>:]]'; do
  run "$dirty" "$bad"
  # Deliberately narrow: 1 (caught) or 2 (refused as inert) only. `-ne 0` would also be satisfied by
  # 127 from a fixture that never ran, which is a broken test reporting a pass — the same defect
  # class this file exists to catch, one level up.
  if { [ "$st" -eq 1 ] || [ "$st" -eq 2 ]; } && ! printf '%s' "$out" | grep -q 'check passed'; then
    pass "3 boundary construct '$bad' on a dirty tree never passes (exit=$st)"
  else
    die "3 FALSE PASS or broken fixture on '$bad': exit=$st out=[$out]"
  fi
done

# --- 4. the case-insensitive half of the denylist -----------------------------------------------
run "$cased" -i -w 'zorbnix'
if [ "$st" -eq 1 ]; then
  pass "4a -i catches a differently-cased term (exit=$st)"
else
  die "4a -i did not catch a differently-cased term: exit=$st out=[$out]"
fi
run "$cased" -w 'zorbnix'
if [ "$st" -eq 0 ]; then
  pass "4b case-sensitive is still the default (exit=$st)"
else
  die "4b case sensitivity leaked into the default mode: exit=$st out=[$out]"
fi

# --- 5. -w actually bounds the match ------------------------------------------------------------
run "$substr" -w 'zorbnix'
if [ "$st" -eq 0 ]; then
  pass "5a -w does not fire on a longer word (exit=$st)"
else
  die "5a -w fired on a substring: exit=$st out=[$out]"
fi
run "$substr" 'zorbnix'
if [ "$st" -eq 1 ]; then
  pass "5b without -w the same pattern matches the substring, so -w is doing work (exit=$st)"
else
  die "5b -w appears to be a no-op: exit=$st out=[$out]"
fi

# --- 6. an empty scan set is refused, not passed ------------------------------------------------
empty="$work/empty"
mkdir -p "$empty/tests"
cp "$INSTRUMENT" "$empty/tests/test_canonical_leakage.sh"
chmod +x "$empty/tests/test_canonical_leakage.sh"
git -C "$empty" init -q
run "$empty" -w 'zorbnix'
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'REFUSED'; then
  pass "6 empty scan set refused (exit=$st)"
else
  die "6 empty scan set was not refused: exit=$st out=[$out]"
fi

# --- 7. an unreadable repository is refused, not passed -----------------------------------------
norepo="$work/norepo"
mkdir -p "$norepo/tests"
cp "$INSTRUMENT" "$norepo/tests/test_canonical_leakage.sh"
chmod +x "$norepo/tests/test_canonical_leakage.sh"
printf 'zorbnix is here\n' > "$norepo/doc.md"
run "$norepo" -w 'zorbnix'
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'REFUSED'; then
  pass "7 tree that is not a repository refused (exit=$st)"
else
  die "7 non-repository was not refused: exit=$st out=[$out]"
fi

# --- 8. usage errors ----------------------------------------------------------------------------
run "$dirty"
[ "$st" -eq 2 ] && pass "8a no argument refused (exit=$st)" || die "8a no argument: exit=$st"
run "$dirty" ''
[ "$st" -eq 2 ] && pass "8b empty pattern refused (exit=$st)" || die "8b empty pattern: exit=$st"
run "$dirty" -Z 'zorbnix'
[ "$st" -eq 2 ] && pass "8c unknown flag refused (exit=$st)" || die "8c unknown flag: exit=$st"

# --- 9. the exit code is readable unpiped -------------------------------------------------------
# A pipeline reports the last command's status, so an instrument tested only through a pipe is
# untested. Prove the instrument's own status survives on its own.
"$dirty/tests/test_canonical_leakage.sh" -w 'zorbnix' >/dev/null 2>&1
direct=$?
"$dirty/tests/test_canonical_leakage.sh" -w 'zorbnix' 2>/dev/null | tail -1 >/dev/null
piped=$?
if [ "$direct" -eq 1 ] && [ "$piped" -eq 0 ]; then
  pass "9 unpiped status is 1 while the same run through a pipe reports 0 (masking demonstrated)"
else
  die "9 exit-code masking assertion did not hold: direct=$direct piped=$piped"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "test_canonical_leakage_guard.sh: all canaries passed"
  exit 0
fi
echo "test_canonical_leakage_guard.sh: FAILURES above"
exit 1
