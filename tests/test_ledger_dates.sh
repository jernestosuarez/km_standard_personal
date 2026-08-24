#!/bin/bash
# km-unrepaired-tree: v1.52 | re-stated for the anchoring repair, and case 10 is its evidence: over the ledger at 1444b15 with the v1.50 row's opener flipped to its published stamp, the unrepaired check reported "2 excluded as drafted: v1.23, v1.50" and exited 0, never opening v1.50's date column, because the row quotes another row's declaration mid-description; the repaired check excludes v1.23 alone, compares v1.50 by tag, and catches a wrong date on it. Case 9 stands unchanged as the v1.47 run: against published main at a2756e2 the check names both real disagreements (v1.33 2026-08-20 against 16109ea 2026-08-21, v1.40 2026-08-22 against 9c14f85 2026-08-23) and reports exactly two, so the failure is selective rather than a blanket match.
# Canaries for the ledger date-integrity check (scripts/validate_ledger_dates.py), added in v1.47.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that the check fires when a version-history row's date column disagrees with the author
# date of the commit that published that version, and that it names the version, both dates, the
# commit and the method that resolved it. It proves the check does NOT fire on a ledger whose dates
# all agree. It proves the version-to-commit mapping is derived from the repository, by resolving the
# same fixture text through an annotated tag in one case and through a commit-subject search in
# another, and by reporting which one resolved each version. It proves the comparison is made in the
# commit's own recorded offset rather than in UTC. It proves the check refuses rather than passes on
# input it could not evaluate. And it proves a passing run states its coverage and names the versions
# it could not cover.
#
# It does NOT prove that the stamp inside a row's prose is correct, that a row describes what the
# version actually did, that a resolved commit is the right commit, or that a version published with
# no row at all would be noticed. The check models the date column, and proving both directions
# proves it fires on the class it models, never that it models the right class.
#
# BOTH DIRECTIONS. A check that reports a problem passes by absence, so a clean run against the real
# repository proves nothing on its own:
#   - case 2 alters one real date by one day in a fixture ledger and requires the check to catch it;
#   - case 3 gives it the same fixture with every date correct and requires it NOT to fire, since a
#     check that fires on everything proves as little as one that fires on nothing;
#   - case 9 runs the check against the version-history table of published `main` as it stood BEFORE
#     this change and requires it to fail there, naming the two real rows. That is the strongest
#     available evidence that the instrument detects the defect it was written for rather than a
#     synthetic likeness of it.
#
# THE TIMEZONE CASE IS NOT DECORATION. Case 4 requires v1.33 to resolve to 2026-08-21. Its publish
# commit is 2026-08-21 00:24:40 +0200, which is 2026-08-20 in UTC, so a check reading UTC would have
# certified the false row as correct. The case fails if the offset handling ever changes.
#
# ONE BRANCH IS NAMED RATHER THAN COUNTED. The check refuses when git returns an error for a reason
# other than the root not being a repository. Case 8 reaches the non-repository form; a git that is
# present, runnable and failing for some other reason is not reproducible from a fixture, and that
# arm is defence in depth rather than a proved behaviour.
#
# All fixture content is synthetic apart from the version identifiers and dates, which are real
# because the mapping under test is derived from this repository's own tags and commit subjects. No
# person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_ledger_dates.py"
# Published v1.46: the last state of the repository before either row was corrected, and the
# evidence anchor for case 9.
PRE_REPAIR_COMMIT="a2756e2"
# The two rows that commit carries whose date column its publish commit does not support.
PRE_REPAIR_EXPECTED=2
# The v1.50 draft commit, added in v1.52: its row opens with a draft declaration and reproduces the
# v1.23 declaration verbatim further along the same cell, which is the material the scope defect was
# found in.
QUOTING_COMMIT="1444b15"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

run_check() {  # $1 = ledger path; resolution always runs against the real repository
  python3 "$CHECK" --root "$ROOT" --ledger "$1" 2>&1
}

make_ledger() {  # $1 = path, $2... = row bodies already formatted as "| vX.Y | DATE | text |"
  local path="$1"; shift
  mkdir -p "$(dirname "$path")"
  {
    printf '# A fixture ledger\n\nSome prose that is not a table.\n\n'
    printf '## Version history\n\n'
    printf '| Version | Date | What it introduced |\n|---|---|---|\n'
    printf '%s\n' "$@"
    printf '\n### A following heading\n\nThe table ends above this line.\n'
  } > "$path"
}

# ── 1. The real repository passes, and the passing line states coverage ──────────────────────────
# A check declares its own coverage in its passing line. A pass that does not say how much it looked
# at is void rather than clean, so the numbers and the named gap are asserted, not merely printed.

real_out=$(python3 "$CHECK" 2>&1); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS ledger-date-integrity:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* row\(s\) read" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* compared" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* resolved by tag" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* by subject search" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* excluded as drafted" \
   && printf '%s' "$real_out" | grep -q "COVERAGE GAP" \
   && printf '%s' "$real_out" | grep -q "excluded (the ledger declares them drafted"; then
  echo "PASS: every compared row in the repository agrees, and the run states its coverage and gap"
  printf '%s\n' "$real_out" | sed 's/^/      /'
else
  echo "FAIL: the check did not pass with a coverage-stating line against the real repository"
  printf '%s\n' "$real_out"
  fail=1
fi

# ── 2. POSITIVE: one real date altered by one day ────────────────────────────────────────────────
# v1.44 published on 2026-08-23. The row claims the day before, which is exactly the shape of the
# defect: a publishing session that ran past midnight and a date that was never re-derived.

make_ledger "$work/wrong/L.md" \
  "| v1.44 | 2026-08-22 | A fixture row claiming the day before the push. |" \
  "| v1.45 | 2026-08-24 | A fixture row whose date is correct. |"
wrong_out=$(run_check "$work/wrong/L.md"); wrong_status=$?
if [ "$wrong_status" -eq 1 ] \
   && printf '%s' "$wrong_out" | grep -q "LEDGER DATE DISAGREEMENT" \
   && printf '%s' "$wrong_out" | grep -q "v1.44 claims 2026-08-22 in its date column" \
   && printf '%s' "$wrong_out" | grep -q "is authored 2026-08-23" \
   && printf '%s' "$wrong_out" | grep -q "(resolved by tag)" \
   && [ "$(printf '%s' "$wrong_out" | grep -c 'claims 2026')" -eq 1 ]; then
  echo "PASS: a row whose date disagrees with its publish commit is caught, naming both dates"
else
  echo "FAIL: a disagreeing date column was not caught (exit $wrong_status)"
  printf '%s\n' "$wrong_out"
  fail=1
fi

# ── 3. NEGATIVE: the same fixture with every date correct ────────────────────────────────────────
# A check that fires on everything proves as little as one that fires on nothing.

make_ledger "$work/right/L.md" \
  "| v1.44 | 2026-08-23 | A fixture row whose date is correct. |" \
  "| v1.45 | 2026-08-24 | A fixture row whose date is correct. |"
right_out=$(run_check "$work/right/L.md"); right_status=$?
if [ "$right_status" -eq 0 ] \
   && printf '%s' "$right_out" | grep -q "^PASS ledger-date-integrity:" \
   && ! printf '%s' "$right_out" | grep -q "DISAGREEMENT"; then
  echo "PASS: a ledger whose dates all agree does not fire"
else
  echo "FAIL: the check fired on a correct ledger, or refused it (exit $right_status)"
  printf '%s\n' "$right_out"
  fail=1
fi

# ── 4. The comparison is made in the commit's own offset, not in UTC ─────────────────────────────
# v1.33's publish commit is 2026-08-21 00:24:40 +0200, which is 2026-08-20 in UTC. The row that was
# wrong claimed 2026-08-20, so a UTC comparison would have certified the defect as correct. The
# firing case and the non-firing case are both asserted, because only the pair pins the offset.

make_ledger "$work/tzbad/L.md" \
  "| v1.33 | 2026-08-20 | The UTC day, which is the wrong day. |"
tzbad_out=$(run_check "$work/tzbad/L.md"); tzbad_status=$?
make_ledger "$work/tzgood/L.md" \
  "| v1.33 | 2026-08-21 | The day in the offset the commit records. |"
tzgood_out=$(run_check "$work/tzgood/L.md"); tzgood_status=$?
if [ "$tzbad_status" -eq 1 ] \
   && printf '%s' "$tzbad_out" | grep -q "v1.33 claims 2026-08-20" \
   && printf '%s' "$tzbad_out" | grep -q "is authored 2026-08-21" \
   && [ "$tzgood_status" -eq 0 ]; then
  echo "PASS: a post-midnight publish is judged in the commit's own offset, and UTC would not do"
else
  echo "FAIL: the offset handling is not what the check claims (exit $tzbad_status/$tzgood_status)"
  printf '%s\n' "$tzbad_out"
  printf '%s\n' "$tzgood_out"
  fail=1
fi

# ── 5. The mapping is derived: a version with no tag resolves through the commit subject ─────────
# Tagging began at v1.22. v1.16 has no tag and its publish commit's subject opens with `v1.16:`, so
# it must resolve by subject search and the method must say so. A check holding a table of dates
# could not tell these two routes apart, and there is deliberately no such table in it.

make_ledger "$work/subj/L.md" \
  "| v1.16 | 2026-08-01 | A fixture row claiming the wrong day for an untagged version. |"
subj_out=$(run_check "$work/subj/L.md"); subj_status=$?
if [ "$subj_status" -eq 1 ] \
   && printf '%s' "$subj_out" | grep -q "v1.16 claims 2026-08-01" \
   && printf '%s' "$subj_out" | grep -q "is authored 2026-08-03" \
   && printf '%s' "$subj_out" | grep -q "(resolved by subject)" \
   && printf '%s' "$subj_out" | grep -qE "0 resolved by tag, 1 by subject search"; then
  echo "PASS: an untagged version resolves through its commit subject, and the method is reported"
else
  echo "FAIL: subject-search resolution did not work or was not reported (exit $subj_status)"
  printf '%s\n' "$subj_out"
  fail=1
fi

# ── 6. A drafted version is excluded, and is not reported as a gap ───────────────────────────────
# A version awaiting its owner push has no publish commit by construction. Reporting it as a gap
# would be a gap that can never close, and a permanent false gap trains a reader to stop reading
# gaps. The row's own draft declaration is the source, so publication status has one home of record.

make_ledger "$work/draft/L.md" \
  "| v1.44 | 2026-08-23 | A fixture row whose date is correct. |" \
  "| v9.9 | 2026-01-01 | **DRAFT — awaiting owner push.** A fixture version that has not published. |"
draft_out=$(run_check "$work/draft/L.md"); draft_status=$?
if [ "$draft_status" -eq 0 ] \
   && printf '%s' "$draft_out" | grep -qE "1 excluded as drafted" \
   && printf '%s' "$draft_out" | grep -q "excluded (the ledger declares them drafted" \
   && printf '%s' "$draft_out" | grep -q "v9.9" \
   && ! printf '%s' "$draft_out" | grep -q "COVERAGE GAP"; then
  echo "PASS: a drafted row is excluded by name and is not counted as a coverage gap"
else
  echo "FAIL: a drafted row was not excluded correctly (exit $draft_status)"
  printf '%s\n' "$draft_out"
  fail=1
fi

# ── 7. An unresolvable version is a coverage gap and not a verdict ───────────────────────────────
# It is neither passed nor failed. The run that carries it still passes on the rows it could judge,
# and the gap is printed with the unresolvable version named.

make_ledger "$work/gap/L.md" \
  "| v1.44 | 2026-08-23 | A fixture row whose date is correct. |" \
  "| v1.20 | 2026-08-16 | A version published inside a later version's commit, with none of its own. |"
gap_out=$(run_check "$work/gap/L.md"); gap_status=$?
if [ "$gap_status" -eq 0 ] \
   && printf '%s' "$gap_out" | grep -q "COVERAGE GAP: 1 version(s)" \
   && printf '%s' "$gap_out" | grep -q "v1.20" \
   && printf '%s' "$gap_out" | grep -q "neither passed nor failed"; then
  echo "PASS: an unresolvable version is reported as a stated gap, not folded into the verdict"
else
  echo "FAIL: an unresolvable version was not reported as a gap (exit $gap_status)"
  printf '%s\n' "$gap_out"
  fail=1
fi

# ── 8. REFUSALS: the check returns no verdict on input it could not evaluate ─────────────────────
# An unread table is not a clean one, and an empty resolution set looks exactly like a repository in
# which every date agrees.

refuses() {  # $1 = label, $2 = ledger path, $3 = expected fragment, $4 = optional root override
  local out status root="${4:-$ROOT}"
  out=$(python3 "$CHECK" --root "$root" --ledger "$2" 2>&1); status=$?
  if [ "$status" -eq 2 ] \
     && printf '%s' "$out" | grep -q "^REFUSED ledger-date-integrity:" \
     && printf '%s' "$out" | grep -q "$3"; then
    echo "PASS: refuses on $1"
  else
    echo "FAIL: did not refuse on $1 (exit $status)"
    printf '%s\n' "$out"
    fail=1
  fi
}

refuses "a ledger that is not there" "$work/absent/nothing.md" "could not read the ledger"

mkdir -p "$work/noheading"
printf '# A fixture with no version history\n\n| v1.44 | 2026-08-23 | orphan row |\n' \
  > "$work/noheading/L.md"
refuses "a ledger with no version-history heading" "$work/noheading/L.md" \
  "no version-history heading was found"

mkdir -p "$work/norows"
printf '## Version history\n\n| Version | Date | What it introduced |\n|---|---|---|\n' \
  > "$work/norows/L.md"
refuses "a version-history table holding no row" "$work/norows/L.md" "yielded no version row"

make_ledger "$work/badrow/L.md" \
  "| v1.44 | last Tuesday | A row whose date column is not a date. |"
refuses "a row whose date column is not a date" "$work/badrow/L.md" \
  "which is not a date"

make_ledger "$work/unparsable/L.md" \
  "| v1.44 2026-08-23 A row with no cell boundaries at all"
refuses "a row that cannot be parsed into a version and a date" "$work/unparsable/L.md" \
  "could not be parsed into a version and a date"

make_ledger "$work/nothingresolves/L.md" \
  "| v9.1 | 2026-01-01 | A fixture version this repository never published. |" \
  "| v9.2 | 2026-01-02 | Another one. |"
refuses "a table in which no version resolves to a publish commit" "$work/nothingresolves/L.md" \
  "empty resolution set"

mkdir -p "$work/notarepo"
make_ledger "$work/notarepo/L.md" \
  "| v1.44 | 2026-08-23 | A fixture row whose date is correct. |"
refuses "a root that is not a git repository" "$work/notarepo/L.md" \
  "an unread repository is not an empty one" "$work/notarepo"

# ── 9. THE EVIDENCE CASE: published main before the correction ───────────────────────────────────
# The strongest direction available. The ledger is the real published table at $PRE_REPAIR_COMMIT,
# byte for byte, judged against the real tag set. Both dates are asserted for each row, and the
# count is asserted rather than a bare non-zero exit, so a blanket match cannot pass as a finding.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT:STANDARD.md" 2>/dev/null; then
  mkdir -p "$work/prerepair"
  git -C "$ROOT" show "$PRE_REPAIR_COMMIT:STANDARD.md" > "$work/prerepair/STANDARD.md"
  pre_out=$(run_check "$work/prerepair/STANDARD.md"); pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -c 'claims 2026')
  if [ "$pre_status" -eq 1 ] \
     && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -q "v1.33 claims 2026-08-20 in its date column and its publish commit 16109ea is authored 2026-08-21" \
     && printf '%s' "$pre_out" | grep -q "v1.40 claims 2026-08-22 in its date column and its publish commit 9c14f85 is authored 2026-08-23"; then
    echo "PASS: against published main at $PRE_REPAIR_COMMIT the check names both real rows,"
    echo "      with all four dates, and reports exactly $PRE_REPAIR_EXPECTED disagreements"
    printf '%s\n' "$pre_out" | sed 's/^/      /'
  else
    echo "FAIL: the pre-repair evidence case did not reproduce the defect"
    echo "      (exit $pre_status, $found disagreements named, $PRE_REPAIR_EXPECTED expected)"
    printf '%s\n' "$pre_out"
    fail=1
  fi
else
  echo "GAP: commit $PRE_REPAIR_COMMIT is not present in this clone, so the pre-repair evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

# ── 10. THE QUOTED DECLARATION: a published row that reproduces one is still compared ────────────
# Added in v1.52. Until then the exclusion searched the declaration token anywhere in the
# description, so a published row that quoted another row's declaration was excluded from
# comparison and its date column was never opened, while the run exited 0. An exclusion is a silent
# withdrawal of coverage, which is the worst shape for this defect to take.

# 10a POSITIVE: the row is published, quotes a declaration, and its date is wrong. It must be
# caught, which it can only be if it was compared at all.
make_ledger "$work/quotewrong/L.md" \
  "| v1.44 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). Evidence: the other row carries \`**DRAFT — awaiting owner push**\` of its own. |"
quotewrong_out=$(run_check "$work/quotewrong/L.md"); quotewrong_status=$?
if [ "$quotewrong_status" -eq 1 ] \
   && printf '%s' "$quotewrong_out" | grep -q "v1.44 claims 2026-08-22 in its date column" \
   && printf '%s' "$quotewrong_out" | grep -q "is authored 2026-08-23"; then
  echo "PASS: a published row quoting a declaration is compared rather than excluded, so a wrong"
  echo "      date in it is still caught"
else
  echo "FAIL: a published row quoting a declaration was excluded from comparison (exit"
  echo "      $quotewrong_status)"
  printf '%s\n' "$quotewrong_out"
  fail=1
fi

# 10b NEGATIVE: the same quotation inside a row that genuinely opens with a declaration. Without
# this, 10a would be satisfied by a check that had stopped excluding anything at all.
make_ledger "$work/quotedraft/L.md" \
  "| v1.44 | 2026-08-23 | A fixture row whose date is correct. |" \
  "| v9.9 | 2026-01-01 | **DRAFT — awaiting owner push.** Evidence: the other row carries \`**DRAFT — awaiting owner push**\` of its own. |"
quotedraft_out=$(run_check "$work/quotedraft/L.md"); quotedraft_status=$?
if [ "$quotedraft_status" -eq 0 ] \
   && printf '%s' "$quotedraft_out" | grep -qE "1 excluded as drafted" \
   && printf '%s' "$quotedraft_out" | grep -q "v9.9" \
   && ! printf '%s' "$quotedraft_out" | grep -q "COVERAGE GAP"; then
  echo "PASS: a row that opens with a declaration and quotes another one is still excluded, so the"
  echo "      repair reads the opening rather than ignoring the token everywhere"
else
  echo "FAIL: a genuinely drafted row carrying a quotation was misread (exit $quotedraft_status)"
  printf '%s\n' "$quotedraft_out"
  fail=1
fi

# 10c THE REAL MATERIAL. The ledger at $QUOTING_COMMIT is the v1.50 draft, whose row opens with a
# declaration and reproduces the v1.23 declaration further along the same cell. Three runs: as it
# stands, where v1.50 is genuinely awaiting its push and must stay excluded; with only the opener
# flipped to the published stamp, where it must be compared; and with the opener flipped and the
# date column moved back a day, where the restored coverage must actually catch something. The
# second run is the state the v1.50 publish was measured in, and the unrepaired check passed it
# while reporting v1.50 among the versions it had excluded.
if git -C "$ROOT" cat-file -e "$QUOTING_COMMIT:STANDARD.md" 2>/dev/null; then
  mkdir -p "$work/quoting"
  git -C "$ROOT" show "$QUOTING_COMMIT:STANDARD.md" > "$work/quoting/plain.md"
  python3 - "$work/quoting/plain.md" "$work/quoting/flipped.md" "$work/quoting/flipped-wrong.md" <<'FLIP'
import sys
plain = open(sys.argv[1], encoding="utf-8").read()
flipped = plain.replace(
    "| v1.50 | 2026-08-24 | **DRAFT, awaiting owner push.** The design record",
    "| v1.50 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The design record", 1)
if flipped == plain:
    raise SystemExit("the v1.50 opener was not found; the fixture no longer models the defect")
wrong = flipped.replace(
    "| v1.50 | 2026-08-24 | Drafted and published",
    "| v1.50 | 2026-08-23 | Drafted and published", 1)
open(sys.argv[2], "w", encoding="utf-8").write(flipped)
open(sys.argv[3], "w", encoding="utf-8").write(wrong)
FLIP
  quoting_prepared=$?
  qplain_out=$(run_check "$work/quoting/plain.md"); qplain_status=$?
  qflip_out=$(run_check "$work/quoting/flipped.md"); qflip_status=$?
  qwrong_out=$(run_check "$work/quoting/flipped-wrong.md"); qwrong_status=$?
  if [ "$quoting_prepared" -eq 0 ] \
     && [ "$qplain_status" -eq 0 ] \
     && printf '%s' "$qplain_out" | grep -qE "2 excluded as drafted" \
     && printf '%s' "$qplain_out" | grep -q "publish commit): v1.23, v1.50" \
     && [ "$qflip_status" -eq 0 ] \
     && printf '%s' "$qflip_out" | grep -qE "1 excluded as drafted" \
     && printf '%s' "$qflip_out" | grep -qE "publish commit\): v1.23$" \
     && [ "$qwrong_status" -eq 1 ] \
     && printf '%s' "$qwrong_out" | grep -q "v1.50 claims 2026-08-23 in its date column" \
     && printf '%s' "$qwrong_out" | grep -q "is authored 2026-08-24"; then
    echo "PASS: at $QUOTING_COMMIT the real v1.50 row stays excluded while its opener declares it,"
    echo "      is compared the moment the opener alone is flipped, and a wrong date in that"
    echo "      compared row is caught, so the restored coverage is real"
  else
    echo "FAIL: the real quoting row was not read correctly in all three states (exit"
    echo "      $qplain_status / $qflip_status / $qwrong_status)"
    printf '%s\n' "$qplain_out"
    printf '%s\n' "$qflip_out"
    printf '%s\n' "$qwrong_out"
    fail=1
  fi
else
  echo "GAP: commit $QUOTING_COMMIT is not present in this clone, so the quoted-declaration evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

if [ "$fail" -eq 0 ]; then
  echo "ledger-date-integrity canaries passed"
  exit 0
else
  exit 1
fi
