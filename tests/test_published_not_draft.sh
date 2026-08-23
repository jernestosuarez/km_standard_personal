#!/bin/bash
# Canaries for the published-not-draft check (scripts/validate_published_not_draft.py), added in
# v1.42.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that the check fires on a draft marking naming a version the version-history table
# records as published, that it does NOT fire on a draft marking naming a version that table
# records as unpublished, that the published set is read from the table rather than held in the
# check (the same body text flips verdict when only its table row flips, in both directions), that
# the check refuses rather than passes on input it could not evaluate, that template and unversioned
# text are counted and excluded rather than silently dropped, and that a passing run states its
# coverage.
#
# It does NOT prove that the version-history table is honest. If a row claims a version published
# that the owner never pushed, this check agrees with the row. The table is the only publication
# record the document has, and a check cannot audit its own oracle.
#
# It also reads one file. The same class of stale marking in a shipped skill, template, RFC or test
# header is outside its reach, and that gap is stated in the check's own module docstring rather
# than left for a reader to discover.
#
# BOTH DIRECTIONS. A check that reports a problem passes by absence, so a clean run against the real
# STANDARD.md proves nothing on its own:
#   - case 2 injects a stale marking for a published version and requires the check to catch it;
#   - case 3 gives it a legitimate marking for an unpublished version and requires it NOT to fire,
#     since a check that matches everything proves as little as one that matches nothing;
#   - case 6 runs the check against STANDARD.md as it stood at the commit BEFORE the v1.42 repair
#     and requires it to fail there, naming the real markings. That is the strongest available
#     evidence that the instrument detects the defect it was written for rather than a synthetic
#     likeness of it.
#
# All fixture content is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_published_not_draft.py"
STANDARD="$ROOT/STANDARD.md"
# The published commit of v1.41: the last state of STANDARD.md before the v1.42 repair, and the
# evidence anchor for case 6.
PRE_REPAIR_COMMIT="40f3829"
# The number of real stale markings that commit carries with an explicit version attached. The
# ninth, a bare binds-nothing clause inside the same blockquote, is unversioned by design and is
# reached through its own heading instead; see the check's docstring.
PRE_REPAIR_EXPECTED=8

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

# ── the fixture document: a minimal STANDARD.md shape, table last as in the real file ────────────
# v9.1 is published; v9.2's status is set per fixture. Both are named by a body marking, so one
# fixture shape exercises both directions of the verdict.

write_fixture() {  # $1 = destination, $2 = body marking block, $3 = v9.2 row prefix
  cat > "$1" <<EOF
# Fixture standard

Lead paragraph.

## A published section (added in v9.1)

Body text.

$2

## Version history

| Version | Date | Change |
|---|---|---|
| v9.1 | 2026-01-01 | Drafted and published 2026-01-01 (owner push). A published fixture version. |
| v9.2 | 2026-01-02 | $3 A fixture version. |
EOF
}

LEGIT_MARKING='## A drafted section (added in v9.2, drafted and unpublished)

This section binds nothing until v9.2 publishes.'

STALE_MARKING='## A published section, wrongly marked (added in v9.1, drafted and unpublished)

This section binds nothing until v9.1 publishes.'

PUBLISHED_ROW="Drafted and published 2026-01-02 (owner push)."
DRAFT_ROW='**DRAFT — awaiting owner push.**'

run_check() {  # $1 = file; prints combined output, returns the check exit status
  python3 "$CHECK" "$1" 2>&1
}

# ── 1. The real STANDARD.md passes, and the passing line states coverage ─────────────────────────
# MSS: a check declares its own coverage in its passing line. A pass that does not say how much it
# looked at is void rather than clean, so the numbers are asserted and not merely printed.

real_out=$(run_check "$STANDARD"); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS published-not-draft:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* versions classified" \
   && printf '%s' "$real_out" | grep -qE "[0-9]+ published, [0-9]+ unpublished" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* draft marking\(s\) found" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* judged against the table"; then
  echo "PASS: STANDARD.md carries no stale draft marking, and the run states its coverage"
  echo "      $real_out"
else
  echo "FAIL: the check did not pass with a coverage-stating line against the real STANDARD.md"
  printf '%s\n' "$real_out"
  fail=1
fi

# ── 2. POSITIVE DIRECTION: a stale marking for a published version is caught ─────────────────────

write_fixture "$work/stale.md" "$STALE_MARKING" "$PUBLISHED_ROW"
stale_out=$(run_check "$work/stale.md"); stale_status=$?
if [ "$stale_status" -eq 1 ] \
   && printf '%s' "$stale_out" | grep -q "STALE DRAFT MARKINGS" \
   && printf '%s' "$stale_out" | grep -q "v9.1 is published"; then
  echo "PASS: a draft marking naming a published version is caught and the version is named"
else
  echo "FAIL: a stale marking for a published version was not caught (exit $stale_status)"
  printf '%s\n' "$stale_out"
  fail=1
fi

# ── 3. NEGATIVE DIRECTION: a legitimate marking for an unpublished version does not fire ─────────
# Without this, case 2 would be satisfied by a check that flags every occurrence of the phrase.

write_fixture "$work/legit.md" "$LEGIT_MARKING" "$DRAFT_ROW"
legit_out=$(run_check "$work/legit.md"); legit_status=$?
if [ "$legit_status" -eq 0 ] \
   && printf '%s' "$legit_out" | grep -q "1 unpublished" \
   && printf '%s' "$legit_out" | grep -q "2 judged against the table"; then
  echo "PASS: a draft marking naming a genuinely unpublished version does not fire, and both its"
  echo "      markings were judged rather than skipped"
else
  echo "FAIL: the check fired on a legitimate marking, misclassified the draft row, or skipped the"
  echo "      markings instead of judging them (exit $legit_status)"
  printf '%s\n' "$legit_out"
  fail=1
fi

# ── 4. The published set comes from the table, not from the check ────────────────────────────────
# The body text is byte-identical to case 3. Only the v9.2 row changes, from a draft declaration to
# a published stamp. If the verdict flips, the classification is being read from the table, which is
# what keeps the check working as later versions publish.

write_fixture "$work/flipped.md" "$LEGIT_MARKING" "$PUBLISHED_ROW"
flipped_out=$(run_check "$work/flipped.md"); flipped_status=$?
if [ "$flipped_status" -eq 1 ] && printf '%s' "$flipped_out" | grep -q "v9.2 is published"; then
  echo "PASS: publishing the row alone turns the same body marking into a violation, so the"
  echo "      published set is derived from the version-history table"
else
  echo "FAIL: flipping only the version-history row did not change the verdict (exit"
  echo "      $flipped_status); the published set may be hardcoded"
  printf '%s\n' "$flipped_out"
  fail=1
fi

# The mirror of the same claim: a stale marking stays a violation whichever other row is drafted, so
# the exemption follows the declaring row and is not pinned to a version number.
write_fixture "$work/exempt.md" "$STALE_MARKING" "$DRAFT_ROW"
exempt_out=$(run_check "$work/exempt.md"); exempt_status=$?
if [ "$exempt_status" -eq 1 ] && printf '%s' "$exempt_out" | grep -q "v9.1 is published"; then
  echo "PASS: the exemption follows the row's own declaration and is not pinned to a version number"
else
  echo "FAIL: the exemption did not follow the declaring row (exit $exempt_status)"
  printf '%s\n' "$exempt_out"
  fail=1
fi

# ── 5. Template and unversioned text are excluded, counted, and reported ─────────────────────────
# The publish ritual has to quote the marking it governs, and the convention is stated in general
# terms elsewhere. Neither is a status claim about a release. Excluding them silently would be a
# hole, so the counts are asserted: the check must say it saw them.

write_fixture "$work/template.md" \
  '## The ritual (added in v9.2, drafted and unpublished)

While drafting, mark the section `(added in vX.Y, drafted and unpublished)`.

A drafted section binds nothing until its own owner push, and the publishing commit clears it.' \
  "$DRAFT_ROW"
tmpl_out=$(run_check "$work/template.md"); tmpl_status=$?
if [ "$tmpl_status" -eq 0 ] \
   && printf '%s' "$tmpl_out" | grep -q "1 template text naming no release" \
   && printf '%s' "$tmpl_out" | grep -q "1 unversioned statements of the convention"; then
  echo "PASS: a quoted vX.Y marking and a general statement of the convention are excluded, counted"
  echo "      and reported rather than judged or silently dropped"
else
  echo "FAIL: template or unversioned text was not counted and reported (exit $tmpl_status)"
  printf '%s\n' "$tmpl_out"
  fail=1
fi

# ── 6. FAIL CLOSED: input the check cannot evaluate refuses, and never passes ────────────────────
# A parser that returns "no violations" because it read nothing looks exactly like a clean document.

: > "$work/empty.md"
empty_out=$(run_check "$work/empty.md"); empty_status=$?

printf '# No history here\n\nA marking: drafted and unpublished at v9.1.\n' > "$work/noheading.md"
nohead_out=$(run_check "$work/noheading.md"); nohead_status=$?

cat > "$work/norows.md" <<'EOF'
# Fixture

A marking: drafted and unpublished at v9.1.

## Version history

| Version | Date | Change |
|---|---|---|
EOF
norows_out=$(run_check "$work/norows.md"); norows_status=$?

cat > "$work/duplicate.md" <<'EOF'
# Fixture

A marking: drafted and unpublished at v9.1.

## Version history

| Version | Date | Change |
|---|---|---|
| v9.1 | 2026-01-01 | Drafted and published 2026-01-01 (owner push). A published fixture version. |
| v9.1 | 2026-01-02 | **DRAFT — awaiting owner push.** The same number, published twice. |
EOF
dup_out=$(run_check "$work/duplicate.md"); dup_status=$?

cat > "$work/unknown.md" <<'EOF'
# Fixture

A marking: drafted and unpublished at v9.7.

## Version history

| Version | Date | Change |
|---|---|---|
| v9.1 | 2026-01-01 | Drafted and published 2026-01-01 (owner push). A published fixture version. |
EOF
unknown_out=$(run_check "$work/unknown.md"); unknown_status=$?

closed=0
for pair in "empty:$empty_status" "no-heading:$nohead_status" "no-rows:$norows_status" \
            "duplicate-version:$dup_status" "unrecorded-version:$unknown_status"; do
  name="${pair%%:*}"; status="${pair##*:}"
  if [ "$status" -eq 2 ]; then
    closed=$((closed + 1))
  else
    echo "FAIL: the check returned $status on $name input instead of refusing"
    fail=1
  fi
done
if [ "$closed" -eq 5 ]; then
  echo "PASS: all 5 unevaluable inputs refuse with a REFUSED line rather than returning a verdict"
fi
for out in "$empty_out" "$nohead_out" "$norows_out" "$dup_out" "$unknown_out"; do
  if ! printf '%s' "$out" | grep -q "^REFUSED published-not-draft:"; then
    echo "FAIL: a refusal did not say what it could not evaluate"
    printf '%s\n' "$out"
    fail=1
  fi
done

# ── 7. THE REAL DEFECT: the check fails against STANDARD.md as it stood before the repair ────────
# Cases 2 to 5 use synthetic input, which proves the mechanism and not the fit. This case proves the
# fit against the document the defect was actually found in. An unresolvable commit is reported as a
# coverage gap and is never folded into the verdict.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT:STANDARD.md" 2>/dev/null; then
  git -C "$ROOT" show "$PRE_REPAIR_COMMIT:STANDARD.md" > "$work/pre-repair.md"
  pre_out=$(run_check "$work/pre-repair.md"); pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -c "is published, but this text still marks it")
  if [ "$pre_status" -eq 1 ] && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -q "v1.35 is published" \
     && printf '%s' "$pre_out" | grep -q "v1.39 is published" \
     && printf '%s' "$pre_out" | grep -q "v1.40 is published"; then
    echo "PASS: against STANDARD.md at $PRE_REPAIR_COMMIT the check fails, naming $found real stale"
    echo "      markings across v1.35, v1.39 and v1.40"
  else
    echo "FAIL: the check did not detect the defect it was written for in the pre-repair document"
    echo "      (exit $pre_status, $found markings named, $PRE_REPAIR_EXPECTED expected)"
    printf '%s\n' "$pre_out"
    fail=1
  fi
  # The v1.23 markings in the same document are legitimate and must survive the run untouched.
  if ! printf '%s' "$pre_out" | grep -q "v1.23 is published"; then
    echo "PASS: the v1.23 markings in the same document were left alone, so the pre-repair failure"
    echo "      is selective and not a blanket match on the phrase"
  else
    echo "FAIL: the check flagged the legitimate v1.23 markings in the pre-repair document"
    fail=1
  fi
else
  echo "GAP: commit $PRE_REPAIR_COMMIT is not present in this clone, so the pre-repair evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

if [ "$fail" -eq 0 ]; then
  echo "published-not-draft canaries passed"
  exit 0
else
  exit 1
fi
