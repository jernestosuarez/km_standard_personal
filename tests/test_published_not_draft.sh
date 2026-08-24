#!/bin/bash
# km-unrepaired-tree: v1.52 | re-stated for the anchoring repair, and case 11 is its evidence: over the tree at 1444b15 with the v1.50 row's opener flipped to its published stamp, the unrepaired check reported "49 published, 2 unpublished" and exited 0, exempting three real stale markings that name v1.50; the repaired check exits 1 and names all three, and still leaves the same tree's genuine v1.50 markings alone when the opener is left as it stands. The v1.42 run stands unchanged in case 10: against 40f3829 the check names 15 real stale markings across five files, with the count asserted rather than a bare non-zero exit.
# Canaries for the published-not-draft check (scripts/validate_published_not_draft.py), added in
# v1.42.
#
# published-not-draft-exempt: the instrument's own fixtures carry stale markings on purpose.
# Scanning this file would report every fixture it needs as a defect.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that the check fires on a draft marking naming a version the STANDARD.md version-history
# table records as published, WHEREVER that marking sits in the governed surface and not only in
# STANDARD.md; that it does NOT fire on a marking naming a version that table records as
# unpublished; that the published set is read from the table rather than held in the check (the same
# body text flips verdict when only its table row flips, in both directions); that the check refuses
# rather than passes on input it could not evaluate; that template and unversioned text are counted
# and excluded rather than silently dropped; that a file exemption must carry a reason and is named
# on the passing run; and that a passing run states its coverage in files as well as in markings.
#
# It does NOT prove that the version-history table is honest. If a row claims a version published
# that the owner never pushed, this check agrees with the row. The table is the only publication
# record the repository has, and a check cannot audit its own oracle.
#
# BOTH DIRECTIONS. A check that reports a problem passes by absence, so a clean run against the real
# repository proves nothing on its own:
#   - cases 2 and 5 inject stale markings, in STANDARD.md and in shipped surfaces, and require the
#     check to catch them;
#   - cases 3 and 6 give it legitimate markings for an unpublished version, in the same places, and
#     require it NOT to fire, since a check that matches everything proves as little as one that
#     matches nothing;
#   - case 10 runs the check against the whole repository as it stood at the commit BEFORE the v1.42
#     repair and requires it to fail there, naming the real markings in STANDARD.md and in the
#     shipped files. That is the strongest available evidence that the instrument detects the defect
#     it was written for rather than a synthetic likeness of it.
#
# All fixture content is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_published_not_draft.py"
# The published commit of v1.41: the last state of the repository before the v1.42 repair, and the
# evidence anchor for case 10.
PRE_REPAIR_COMMIT="40f3829"
# The markings that commit carries with an explicit version attached: eight in STANDARD.md and seven
# across four shipped files. Two further bare binds-nothing clauses are unversioned by design and
# are reached through their own headings instead; see the check's docstring.
PRE_REPAIR_EXPECTED=15
# The v1.50 draft commit, added in v1.52: its row opens with a draft declaration and reproduces the
# v1.23 declaration verbatim further along the same cell, which is the material the scope defect was
# found in.
QUOTING_COMMIT="1444b15"
# With only that row's opener flipped to the published stamp, three markings in STANDARD.md name
# v1.50: the lead paragraph, and the drafted section body twice.
QUOTING_FLIPPED_EXPECTED=3

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

# ── fixture roots: a minimal repository shape, table last as in the real STANDARD.md ─────────────
# v9.1 is published; v9.2's status is set per fixture.

make_root() {  # $1 = root dir, $2 = STANDARD.md body block, $3 = v9.2 row prefix
  mkdir -p "$1/skills/km-fixture" "$1/template"
  cat > "$1/STANDARD.md" <<EOF
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

write_shipped() {  # $1 = root dir, $2 = marking text for the skill and the scan
  cat > "$1/skills/km-fixture/SKILL.md" <<EOF
---
name: km-fixture
description: Synthetic skill for the published-not-draft canaries.
---

## A mode $2
EOF
  cat > "$1/template/fixture-scan.sh" <<EOF
#!/bin/bash
# A shipped check. Mode $2
echo "fixture"
EOF
}

LEGIT_MARKING='## A drafted section (added in v9.2, drafted and unpublished)

This section binds nothing until v9.2 publishes.'

STALE_MARKING='## A published section, wrongly marked (added in v9.1, drafted and unpublished)

This section binds nothing until v9.1 publishes.'

PUBLISHED_ROW="Drafted and published 2026-01-02 (owner push)."
DRAFT_ROW='**DRAFT — awaiting owner push.**'

run_check() {  # $1 = root; prints combined output, returns the check exit status
  python3 "$CHECK" --root "$1" 2>&1
}

# ── 1. The real repository passes, and the passing line states coverage ──────────────────────────
# MSS: a check declares its own coverage in its passing line. A pass that does not say how much it
# looked at is void rather than clean, so the numbers are asserted and not merely printed. Coverage
# here is files as well as markings, because the defect this check exists for reached shipped files.

real_out=$(run_check "$ROOT"); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS published-not-draft:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* versions classified" \
   && printf '%s' "$real_out" | grep -qE "[0-9]+ published, [0-9]+ unpublished" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]{1,} file\(s\) scanned" \
   && printf '%s' "$real_out" | grep -qE "[0-9]+ exempt by declaration" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* judged against the table" \
   && printf '%s' "$real_out" | grep -q "out of scope by declaration: rfcs/"; then
  echo "PASS: the governed surface carries no stale draft marking, and the run states its coverage"
  printf '%s\n' "$real_out" | sed 's/^/      /'
else
  echo "FAIL: the check did not pass with a coverage-stating line against the real repository"
  printf '%s\n' "$real_out"
  fail=1
fi

# ── 2. POSITIVE DIRECTION in STANDARD.md: a stale marking for a published version is caught ──────

make_root "$work/stale" "$STALE_MARKING" "$PUBLISHED_ROW"
stale_out=$(run_check "$work/stale"); stale_status=$?
if [ "$stale_status" -eq 1 ] \
   && printf '%s' "$stale_out" | grep -q "STALE DRAFT MARKINGS" \
   && printf '%s' "$stale_out" | grep -q "STANDARD.md:.*v9.1 is published"; then
  echo "PASS: a draft marking naming a published version is caught, and the file and version named"
else
  echo "FAIL: a stale marking for a published version was not caught (exit $stale_status)"
  printf '%s\n' "$stale_out"
  fail=1
fi

# ── 3. NEGATIVE DIRECTION in STANDARD.md: a legitimate marking does not fire ─────────────────────
# Without this, case 2 would be satisfied by a check that flags every occurrence of the phrase.

make_root "$work/legit" "$LEGIT_MARKING" "$DRAFT_ROW"
legit_out=$(run_check "$work/legit"); legit_status=$?
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

make_root "$work/flipped" "$LEGIT_MARKING" "$PUBLISHED_ROW"
flipped_out=$(run_check "$work/flipped"); flipped_status=$?
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
make_root "$work/exemptrow" "$STALE_MARKING" "$DRAFT_ROW"
exemptrow_out=$(run_check "$work/exemptrow"); exemptrow_status=$?
if [ "$exemptrow_status" -eq 1 ] && printf '%s' "$exemptrow_out" | grep -q "v9.1 is published"; then
  echo "PASS: the exemption follows the row's own declaration and is not pinned to a version number"
else
  echo "FAIL: the exemption did not follow the declaring row (exit $exemptrow_status)"
  printf '%s\n' "$exemptrow_out"
  fail=1
fi

# ── 5. POSITIVE DIRECTION in the SHIPPED surfaces, which is why the check was widened ────────────
# STANDARD.md is clean here. The false claim sits only in a skill and in a template scan, which is
# exactly the shape that reached deployments: a check green on STANDARD.md alone would certify this.

make_root "$work/shipped" "## A clean section (added in v9.1)" "$DRAFT_ROW"
write_shipped "$work/shipped" "(v9.1, drafted and unpublished)"
shipped_out=$(run_check "$work/shipped"); shipped_status=$?
if [ "$shipped_status" -eq 1 ] \
   && printf '%s' "$shipped_out" | grep -q "skills/km-fixture/SKILL.md:.*v9.1 is published" \
   && printf '%s' "$shipped_out" | grep -q "template/fixture-scan.sh:.*v9.1 is published" \
   && ! printf '%s' "$shipped_out" | grep -q "STANDARD.md:"; then
  echo "PASS: a stale marking in a shipped skill and in a shipped shell script is caught with a"
  echo "      clean STANDARD.md, so the widened scope is real and not decorative"
else
  echo "FAIL: the check missed a stale marking outside STANDARD.md (exit $shipped_status)"
  printf '%s\n' "$shipped_out"
  fail=1
fi

# ── 6. NEGATIVE DIRECTION in the shipped surfaces ────────────────────────────────────────────────

make_root "$work/shippedok" "## A clean section (added in v9.1)" "$DRAFT_ROW"
write_shipped "$work/shippedok" "(v9.2, drafted and unpublished)"
shippedok_out=$(run_check "$work/shippedok"); shippedok_status=$?
if [ "$shippedok_status" -eq 0 ] \
   && printf '%s' "$shippedok_out" | grep -q "2 judged against the table"; then
  echo "PASS: the same shipped files marked for a genuinely unpublished version do not fire, and"
  echo "      both markings were judged rather than skipped"
else
  echo "FAIL: the check fired on legitimate shipped markings, or skipped them (exit"
  echo "      $shippedok_status)"
  printf '%s\n' "$shippedok_out"
  fail=1
fi

# ── 7. Template and unversioned text are excluded, counted, and reported ─────────────────────────
# The publish ritual has to quote the marking it governs, and the convention is stated in general
# terms elsewhere. Neither is a status claim about a release. Excluding them silently would be a
# hole, so the counts are asserted: the check must say it saw them.

make_root "$work/template" '## The ritual (added in v9.2, drafted and unpublished)

While drafting, mark the section `(added in vX.Y, drafted and unpublished)`.

A drafted section binds nothing until its own owner push, and the publishing commit clears it.' \
  "$DRAFT_ROW"
tmpl_out=$(run_check "$work/template"); tmpl_status=$?
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

# ── 8. A file exemption must carry a reason, is honoured, and is named on the passing run ────────
# An exclusion nobody can see is how a check comes to certify the wrong class. So the reason is
# mandatory, and the pass prints every exempt file.

make_root "$work/exfile" "## A clean section (added in v9.1)" "$DRAFT_ROW"
write_shipped "$work/exfile" "(v9.1, drafted and unpublished)"
sed -i.bak '2i\
# published-not-draft-exempt: synthetic fixture, marked stale on purpose
' "$work/exfile/template/fixture-scan.sh" && rm -f "$work/exfile/template/fixture-scan.sh.bak"
exfile_out=$(run_check "$work/exfile"); exfile_status=$?
if [ "$exfile_status" -eq 1 ] \
   && ! printf '%s' "$exfile_out" | grep -q "template/fixture-scan.sh" \
   && printf '%s' "$exfile_out" | grep -q "skills/km-fixture/SKILL.md"; then
  echo "PASS: a declared exemption is honoured for that file alone and does not silence the others"
else
  echo "FAIL: the exemption was ignored, or silenced a file that did not declare one (exit"
  echo "      $exfile_status)"
  printf '%s\n' "$exfile_out"
  fail=1
fi

make_root "$work/exnamed" "## A clean section (added in v9.1)" "$DRAFT_ROW"
write_shipped "$work/exnamed" "(v9.2, drafted and unpublished)"
sed -i.bak '2i\
# published-not-draft-exempt: synthetic fixture with a stated reason
' "$work/exnamed/template/fixture-scan.sh" && rm -f "$work/exnamed/template/fixture-scan.sh.bak"
exnamed_out=$(run_check "$work/exnamed"); exnamed_status=$?
if [ "$exnamed_status" -eq 0 ] \
   && printf '%s' "$exnamed_out" | grep -q "1 exempt by declaration" \
   && printf '%s' "$exnamed_out" | grep -q "exempt: template/fixture-scan.sh (synthetic fixture"; then
  echo "PASS: the passing run names every exempt file with its reason, so no exclusion is silent"
else
  echo "FAIL: an exempt file was not named with its reason on the passing run (exit"
  echo "      $exnamed_status)"
  printf '%s\n' "$exnamed_out"
  fail=1
fi

# ── 9. FAIL CLOSED: input the check cannot evaluate refuses, and never passes ────────────────────
# A parser that returns "no violations" because it read nothing looks exactly like a clean tree.

mkdir -p "$work/empty" && : > "$work/empty/STANDARD.md"
empty_out=$(run_check "$work/empty"); empty_status=$?

mkdir -p "$work/noheading"
printf '# No history here\n\nA marking: drafted and unpublished at v9.1.\n' \
  > "$work/noheading/STANDARD.md"
nohead_out=$(run_check "$work/noheading"); nohead_status=$?

mkdir -p "$work/norows"
cat > "$work/norows/STANDARD.md" <<'EOF'
# Fixture

A marking: drafted and unpublished at v9.1.

## Version history

| Version | Date | Change |
|---|---|---|
EOF
norows_out=$(run_check "$work/norows"); norows_status=$?

mkdir -p "$work/duplicate"
cat > "$work/duplicate/STANDARD.md" <<'EOF'
# Fixture

A marking: drafted and unpublished at v9.1.

## Version history

| Version | Date | Change |
|---|---|---|
| v9.1 | 2026-01-01 | Drafted and published 2026-01-01 (owner push). A published fixture version. |
| v9.1 | 2026-01-02 | **DRAFT — awaiting owner push.** The same number, twice. |
EOF
dup_out=$(run_check "$work/duplicate"); dup_status=$?

make_root "$work/unknown" 'A marking: drafted and unpublished at v9.7.' "$DRAFT_ROW"
unknown_out=$(run_check "$work/unknown"); unknown_status=$?

make_root "$work/noreason" "## A clean section (added in v9.1)" "$DRAFT_ROW"
write_shipped "$work/noreason" "(v9.2, drafted and unpublished)"
sed -i.bak '2i\
# published-not-draft-exempt:
' "$work/noreason/template/fixture-scan.sh" && rm -f "$work/noreason/template/fixture-scan.sh.bak"
noreason_out=$(run_check "$work/noreason"); noreason_status=$?

make_root "$work/allexempt" "## A clean section (added in v9.1)" "$DRAFT_ROW"
sed -i.bak '2i\
published-not-draft-exempt: everything in scope opts out
' "$work/allexempt/STANDARD.md" && rm -f "$work/allexempt/STANDARD.md.bak"
allexempt_out=$(run_check "$work/allexempt"); allexempt_status=$?

closed=0
expected=7
for pair in "empty:$empty_status" "no-heading:$nohead_status" "no-rows:$norows_status" \
            "duplicate-version:$dup_status" "unrecorded-version:$unknown_status" \
            "exemption-without-a-reason:$noreason_status" "everything-exempt:$allexempt_status"; do
  name="${pair%%:*}"; status="${pair##*:}"
  if [ "$status" -eq 2 ]; then
    closed=$((closed + 1))
  else
    echo "FAIL: the check returned $status on $name input instead of refusing"
    fail=1
  fi
done
if [ "$closed" -eq "$expected" ]; then
  echo "PASS: all $expected unevaluable inputs refuse with a REFUSED line rather than a verdict"
fi
for out in "$empty_out" "$nohead_out" "$norows_out" "$dup_out" "$unknown_out" "$noreason_out" \
           "$allexempt_out"; do
  if ! printf '%s' "$out" | grep -q "^REFUSED published-not-draft:"; then
    echo "FAIL: a refusal did not say what it could not evaluate"
    printf '%s\n' "$out"
    fail=1
  fi
done

# ── 10. THE REAL DEFECT: the check fails against the repository as it stood before the repair ────
# Cases 2 to 9 use synthetic input, which proves the mechanism and not the fit. This case proves the
# fit against the tree the defect was actually found in. An unresolvable commit is reported as a
# coverage gap and is never folded into the verdict.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT^{commit}" 2>/dev/null; then
  mkdir -p "$work/pre-repair"
  git -C "$ROOT" archive "$PRE_REPAIR_COMMIT" | tar -x -C "$work/pre-repair"
  pre_out=$(run_check "$work/pre-repair"); pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -c "is published, but this text still marks it")
  if [ "$pre_status" -eq 1 ] && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -q "STANDARD.md:.*v1.40 is published" \
     && printf '%s' "$pre_out" | grep -q "STANDARD.md:.*v1.39 is published" \
     && printf '%s' "$pre_out" | grep -q "skills/km-init/SKILL.md:.*v1.35 is published" \
     && printf '%s' "$pre_out" | grep -q "hub-registry.md:.*v1.35 is published" \
     && printf '%s' "$pre_out" | grep -q "template/hub-scan.sh:.*v1.35 is published" \
     && printf '%s' "$pre_out" | grep -q "tests/test_hub_merge.sh:.*v1.35 is published"; then
    echo "PASS: against the repository at $PRE_REPAIR_COMMIT the check fails, naming $found real"
    echo "      stale markings in STANDARD.md and in all four shipped files"
  else
    echo "FAIL: the check did not detect the defect it was written for in the pre-repair tree"
    echo "      (exit $pre_status, $found markings named, $PRE_REPAIR_EXPECTED expected)"
    printf '%s\n' "$pre_out"
    fail=1
  fi
  # The v1.23 markings in the same tree are legitimate and must survive the run untouched.
  if ! printf '%s' "$pre_out" | grep -q "v1.23 is published"; then
    echo "PASS: the v1.23 markings in the same tree were left alone, so the pre-repair failure is"
    echo "      selective and not a blanket match on the phrase"
  else
    echo "FAIL: the check flagged the legitimate v1.23 markings in the pre-repair tree"
    fail=1
  fi
else
  echo "GAP: commit $PRE_REPAIR_COMMIT is not present in this clone, so the pre-repair evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

# ── 11. THE QUOTED DECLARATION: a published row that reproduces one is still published ──────────
# Added in v1.52. Until then the check searched the declaration token anywhere in everything after
# the version cell, so a published row that quoted another row's declaration classified as
# unpublished and every marking naming that version was exempted from judgement while the run
# exited 0. Quoting the text a rule governs is ordinary practice here, which is why this is a case
# and not a footnote.

QUOTING_PUBLISHED_ROW='Drafted and published 2026-01-02 (owner push). Evidence for the claim above: the other row carries `**DRAFT — awaiting owner push**` of its own.'
QUOTING_DRAFT_ROW='**DRAFT — awaiting owner push.** Evidence for the claim above: the other row carries `**DRAFT — awaiting owner push**` of its own.'

# 11a POSITIVE: the row is published and quotes a declaration, so the v9.2 marking is stale.
make_root "$work/quotepub" "$LEGIT_MARKING" "$QUOTING_PUBLISHED_ROW"
quotepub_out=$(run_check "$work/quotepub"); quotepub_status=$?
if [ "$quotepub_status" -eq 1 ] \
   && printf '%s' "$quotepub_out" | grep -q "v9.2 is published"; then
  echo "PASS: a quotation of a declaration inside a published row does not make that row a draft,"
  echo "      so the markings naming it are judged rather than exempted"
else
  echo "FAIL: a published row quoting a declaration was still read as unpublished (exit"
  echo "      $quotepub_status)"
  printf '%s\n' "$quotepub_out"
  fail=1
fi

# 11b NEGATIVE: the same quotation inside a row that genuinely opens with a declaration. Without
# this, 11a would be satisfied by a rule that had simply stopped recognising declarations.
make_root "$work/quotedraft" "$LEGIT_MARKING" "$QUOTING_DRAFT_ROW"
quotedraft_out=$(run_check "$work/quotedraft"); quotedraft_status=$?
if [ "$quotedraft_status" -eq 0 ] \
   && printf '%s' "$quotedraft_out" | grep -q "1 unpublished" \
   && printf '%s' "$quotedraft_out" | grep -q "2 judged against the table"; then
  echo "PASS: a row that opens with a declaration and quotes another one is still unpublished, so"
  echo "      the repair reads the opening rather than ignoring the token everywhere"
else
  echo "FAIL: a genuinely drafted row carrying a quotation was misread (exit $quotedraft_status)"
  printf '%s\n' "$quotedraft_out"
  fail=1
fi

# 11c THE REAL MATERIAL. The tree at $QUOTING_COMMIT is the v1.50 draft, whose row opens with a
# declaration and reproduces the v1.23 declaration further along the same cell. Two runs: as it
# stands, where v1.50 is genuinely awaiting its push and must stay exempt; and with only the opener
# flipped to the published stamp, which is the single edit a publishing commit makes, where the
# three markings naming v1.50 must be caught. The second run is the state the v1.50 publish was
# measured in, and the unrepaired check passed it.
if git -C "$ROOT" cat-file -e "$QUOTING_COMMIT^{commit}" 2>/dev/null; then
  mkdir -p "$work/quoting-plain" "$work/quoting-flipped"
  git -C "$ROOT" archive "$QUOTING_COMMIT" | tar -x -C "$work/quoting-plain"
  cp -R "$work/quoting-plain/." "$work/quoting-flipped/"
  python3 - "$work/quoting-flipped/STANDARD.md" <<'FLIP'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
flipped = text.replace(
    "| v1.50 | 2026-08-24 | **DRAFT, awaiting owner push.** The design record",
    "| v1.50 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The design record", 1)
if flipped == text:
    raise SystemExit("the v1.50 opener was not found; the fixture no longer models the defect")
open(path, "w", encoding="utf-8").write(flipped)
FLIP
  flip_prepared=$?
  plain_out=$(run_check "$work/quoting-plain"); plain_status=$?
  flipped_out=$(run_check "$work/quoting-flipped"); flipped_status=$?
  flipped_found=$(printf '%s' "$flipped_out" | grep -c "v1.50 is published, but this text still marks it")
  if [ "$flip_prepared" -eq 0 ] \
     && [ "$plain_status" -eq 0 ] \
     && printf '%s' "$plain_out" | grep -q "2 unpublished" \
     && [ "$flipped_status" -eq 1 ] \
     && [ "$flipped_found" -eq "$QUOTING_FLIPPED_EXPECTED" ] \
     && printf '%s' "$flipped_out" | grep -q "STANDARD.md:12: v1.50 is published" \
     && ! printf '%s' "$flipped_out" | grep -q "v1.23 is published"; then
    echo "PASS: at $QUOTING_COMMIT the real v1.50 row stays exempt while its opener declares it, and"
    echo "      naming $flipped_found stale markings the moment the opener alone is flipped, with"
    echo "      the quotation untouched and v1.23 left alone"
  else
    echo "FAIL: the real quoting row was not read correctly in both states (exit $plain_status /"
    echo "      $flipped_status, $flipped_found markings named, $QUOTING_FLIPPED_EXPECTED expected)"
    printf '%s\n' "$plain_out"
    printf '%s\n' "$flipped_out"
    fail=1
  fi
else
  echo "GAP: commit $QUOTING_COMMIT is not present in this clone, so the quoted-declaration evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

if [ "$fail" -eq 0 ]; then
  echo "published-not-draft canaries passed"
  exit 0
else
  exit 1
fi
