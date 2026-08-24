#!/bin/bash
# km-unrepaired-tree: v1.50 | case 16 is the unrepaired-tree run: the check is run against published main at d0482ec, extracted from git rather than rebuilt, where it names seven RFCs left uncovered by a missing index, three stale banners (RFC-004 against v1.35, RFC-006 against v1.39, RFC-007 against v1.41), and the badge reading '2 adopted' while the ledger records three RFCs as implemented, eleven statements in all.
# Canaries for the RFC lifecycle check (scripts/validate_rfc_lifecycle.py), added in v1.50.
#
# rfc-reference-exempt: the fixtures name synthetic identifiers to exercise the coverage arms.
# published-not-draft-exempt: the fixtures quote status wording to exercise the banner arm.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves the check fires when an index does not cover the directory it describes, when an index
# names a document that is not there, when an index records as unimplemented a document the version
# ledger says a version implemented, when an index names an implementing version no ledger row
# carries, when a status banner does not name the version the ledger says implemented it, when the
# badge carries a count the index does not support, and when the badge's accessible text carries a
# count the image does not. It proves the check does NOT fire on a tree where every arm is satisfied.
# It proves the document set is derived from the directory and the implementation facts from the
# ledger, because adding a file to a fixture directory and adding a row to a fixture ledger each flip
# an unchanged index from passing to failing. It proves the generator and the validator are one
# derivation, because the badge written by --write-badge satisfies the validating run. It proves the
# check refuses rather than passes on input it could not evaluate, and that a passing run states its
# coverage.
#
# It does NOT prove that an index row describes a narrowing correctly, that a design should have been
# implemented, that an implementation was faithful to the design it names, or that an RFC that ought
# to exist was ever written. Those are judgements, and an instrument built over them would model
# whether a sentence had been edited. Proving both directions proves the check fires on the classes
# it models, never that it models the right ones.
#
# BOTH DIRECTIONS. The check reports a defect by finding one, so a clean run against the repaired
# repository proves nothing on its own. Cases 2 through 9 each inject one defect and require it to be
# named; case 10 gives the check a tree that is right in every arm and requires it NOT to fire; and
# case 16 runs it against the published branch as it stands before this change and requires it to
# fail there, naming the real findings. That last is the strongest available evidence that the
# instrument detects the defect it was written for rather than a synthetic likeness of it.
#
# ABSENT IS NOT UNPARSABLE. Case 9 requires an absent index to FAIL and case 13d requires a present
# but unreadable one to REFUSE. Folding the two together would have made the evidence run in case 16
# a refusal, which reports nothing about the badge or the banners, and the badge count is precisely
# what that run has to name.
#
# All fixture content is synthetic. No person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_rfc_lifecycle.py"
# Published v1.49: the state of the repository before the index landed, and the evidence anchor.
PRE_REPAIR_COMMIT="d0482ec"
# Seven uncovered RFCs, three stale banners, one badge finding.
PRE_REPAIR_EXPECTED=11

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

run_check() { python3 "$CHECK" --root "$1" 2>&1; }

make_std() {  # $1 = root, rest = "version|description" rows
  local root="$1"; shift
  mkdir -p "$root"
  {
    printf '# A fixture standard\n\nSome prose.\n\n## Version history\n\n'
    printf '| Version | Date | What it introduced |\n|---|---|---|\n'
    local row
    for row in "$@"; do
      printf '| %s | 2026-01-01 | %s |\n' "${row%%|*}" "${row#*|}"
    done
  } > "$root/STANDARD.md"
}

make_rfc() {  # $1 = root, $2 = identifier, $3 = banner sentence
  local root="$1" id="$2" banner="$3"
  mkdir -p "$root/rfcs"
  {
    printf -- '---\ntype: reference\ntitle: %s fixture\n---\n\n' "$id"
    printf '# %s: a fixture design\n\n' "$id"
    printf '> %s\n\n' "$banner"
    printf '## Body\n\nThe design would sit here.\n'
  } > "$root/rfcs/$id-fixture.md"
}

make_index() {  # $1 = root, rest = "id|title|status|versions|notes" rows
  local root="$1"; shift
  mkdir -p "$root/rfcs"
  {
    printf '# RFC index\n\n'
    printf '| RFC | Title | Status | Implemented by | Decided | Notes |\n|---|---|---|---|---|---|\n'
    local row id title status versions notes rest
    for row in "$@"; do
      id="${row%%|*}"; rest="${row#*|}"
      title="${rest%%|*}"; rest="${rest#*|}"
      status="${rest%%|*}"; rest="${rest#*|}"
      versions="${rest%%|*}"; notes="${rest#*|}"
      printf '| %s | %s | %s | %s | 2026-01-01 | %s |\n' \
        "$id" "$title" "$status" "$versions" "$notes"
    done
  } > "$root/rfcs/README.md"
}

make_badge() {  # $1 = root, $2 = message
  mkdir -p "$1/assets/badges"
  printf '<svg xmlns="http://www.w3.org/2000/svg" width="125" height="20">\n<text x="23" y="14">rfcs</text>\n<text x="85" y="14" font-weight="bold">%s</text></svg>' \
    "$2" > "$1/assets/badges/rfcs.svg"
}

make_readme() {  # $1 = root, $2 = alt text
  printf '# A fixture package\n\n<img src="assets/badges/rfcs.svg" alt="%s"/>\n' "$2" > "$1/README.md"
}

# A tree that satisfies every arm. Every firing case below is this tree with one thing changed, so
# each failure is attributable to the one change and not to the fixture being broadly wrong.
build_clean() {  # $1 = root
  local root="$1"
  make_std "$root" \
    "v1.1|A first fixture version." \
    "v1.2|A fixture version implementing \`rfcs/RFC-201\`."
  make_rfc "$root" "RFC-201" "**Status: ADOPTED.** Implemented by v1.2."
  make_rfc "$root" "RFC-202" "**Status: DESIGN ONLY.** No normative edits ride this document."
  make_index "$root" \
    "RFC-201|A fixture adopted design|ADOPTED|v1.2|Adopted whole." \
    "RFC-202|A fixture open design|DESIGN ONLY| |Not taken up."
  # The badge is written by the generator, which is also the round-trip proof of case 14.
  mkdir -p "$root/assets/badges"
  python3 "$CHECK" --root "$root" --write-badge > /dev/null
  make_readme "$root" "RFCs: 1 adopted, 0 partial, 1 open"
}

fires() {  # $1 = label, $2 = root, $3... = expected fragments
  local label="$1" root="$2"; shift 2
  local out status ok=1 fragment
  out=$(run_check "$root"); status=$?
  [ "$status" -eq 1 ] || ok=0
  printf '%s' "$out" | grep -q "^RFC LIFECYCLE METADATA IS STALE:" || ok=0
  for fragment in "$@"; do
    printf '%s' "$out" | grep -qF "$fragment" || ok=0
  done
  if [ "$ok" -eq 1 ]; then
    echo "PASS: fires on $label"
  else
    echo "FAIL: did not fire as expected on $label (exit $status)"
    printf '%s\n' "$out"
    fail=1
  fi
}

refuses() {  # $1 = label, $2 = root, $3 = expected fragment
  local label="$1" root="$2" fragment="$3"
  local out status
  out=$(run_check "$root"); status=$?
  if [ "$status" -eq 2 ] \
     && printf '%s' "$out" | grep -q "^REFUSED rfc-lifecycle:" \
     && printf '%s' "$out" | grep -qF "$fragment"; then
    echo "PASS: refuses on $label"
  else
    echo "FAIL: did not refuse on $label (exit $status)"
    printf '%s\n' "$out"
    fail=1
  fi
}

# 1. The repaired repository passes, and the passing line states its coverage.
# A pass that does not say how much it looked at is void rather than clean, so the numbers are
# asserted and not merely printed.

real_out=$(python3 "$CHECK" 2>&1); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS rfc-lifecycle:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* RFC\(s\) present in rfcs/" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* index row\(s\) read" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* implementation claim\(s\) read" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* banner\(s\) verified" \
   && printf '%s' "$real_out" | grep -q "LOWER BOUND"; then
  echo "PASS: the repository passes and the passing line states its coverage"
  printf '%s\n' "$real_out" | sed 's/^/      /'
else
  echo "FAIL: the repository did not pass with coverage stated (exit $real_status)"
  printf '%s\n' "$real_out"
  fail=1
fi

# 2. An RFC present in the directory with no index row.

t="$work/c2"; build_clean "$t"
make_index "$t" "RFC-201|A fixture adopted design|ADOPTED|v1.2|Adopted whole."
fires "an RFC the index does not cover" "$t" \
  "RFC-202 is present in rfcs/ and has no row in rfcs/README.md"

# 3. An index row naming a document that is not in the tree.

t="$work/c3"; build_clean "$t"
make_index "$t" \
  "RFC-201|A fixture adopted design|ADOPTED|v1.2|Adopted whole." \
  "RFC-202|A fixture open design|DESIGN ONLY| |Not taken up." \
  "RFC-203|A design that does not exist|DESIGN ONLY| |Nothing behind it."
fires "an index row with no document behind it" "$t" \
  "has a row for RFC-203 and no file in rfcs/ carries that identifier"

# 4. The index contradicts the ledger: an implemented document recorded as design only.

t="$work/c4"; build_clean "$t"
make_index "$t" \
  "RFC-201|A fixture adopted design|DESIGN ONLY| |Wrongly recorded." \
  "RFC-202|A fixture open design|DESIGN ONLY| |Not taken up."
fires "an index recording an implemented design as unimplemented" "$t" \
  "records RFC-201 as DESIGN ONLY and the version ledger records v1.2 as implementing it"

# 5. The index names an implementing version the ledger does not carry.

t="$work/c5"; build_clean "$t"
make_index "$t" \
  "RFC-201|A fixture adopted design|ADOPTED|v1.2, v9.9|Adopted whole." \
  "RFC-202|A fixture open design|DESIGN ONLY| |Not taken up."
fires "an index naming a version that is in no ledger row" "$t" \
  "the row for RFC-201 names v9.9, which is in no version-history row"

# 6. A status banner that does not name the version the ledger says implemented it. This is the
#    class the three real stale banners belong to.

t="$work/c6"; build_clean "$t"
make_rfc "$t" "RFC-201" "**Status: DRAFT, design document only.** No normative edits ride this RFC."
fires "a banner the ledger contradicts" "$t" \
  "the version ledger records v1.2 as implementing RFC-201 and the status banner names no such version" \
  "it still reads 'no normative edits ride'"

# 7. The badge carries a count the index does not support.

t="$work/c7"; build_clean "$t"
make_badge "$t" "2 adopted"
fires "a badge the index does not support" "$t" \
  "reads '2 adopted' and the index derives '1 adopted, 0 partial, 1 open'"

# 8. The image is right and its accessible text is not. The two arms are independent, because the
#    reader who receives only the alt text is the one left with the false claim.

t="$work/c8"; build_clean "$t"
make_readme "$t" "RFCs: 2 adopted"
fires "an alt text the index does not support" "$t" \
  "the alt text for assets/badges/rfcs.svg reads 'RFCs: 2 adopted'"

# 9. No index at all. This FAILS rather than refuses: the directory was read, the documents were
#    found, and none is covered. The badge arm must still speak, against the ledger this time.

t="$work/c9"; build_clean "$t"
rm "$t/rfcs/README.md"
make_badge "$t" "0 adopted"
fires "a tree with no index" "$t" \
  "RFC-201 is present in rfcs/ and no index covers it; rfcs/README.md does not exist" \
  "RFC-202 is present in rfcs/ and no index covers it" \
  "no index exists to derive it from; the version ledger records 1 RFC(s) as implemented (RFC-201)"

# 10. The negative direction. A check that fires on everything proves as little as one that fires on
#     nothing, so a tree right in every arm must produce silence.

t="$work/c10"; build_clean "$t"
out=$(run_check "$t"); status=$?
if [ "$status" -eq 0 ] && printf '%s' "$out" | grep -q "^PASS rfc-lifecycle:"; then
  echo "PASS: does not fire on a tree that satisfies every arm"
else
  echo "FAIL: fired on a clean fixture tree (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi

# 11. Derivation, the directory. The index is held still and a document is added beside it. A check
#     holding its own list of identifiers would pass both times, and that list is the artifact class
#     the defect under repair belongs to.

t="$work/c11"; build_clean "$t"
make_rfc "$t" "RFC-203" "**Status: DESIGN ONLY.** No normative edits ride this document."
fires "an RFC added to the directory, with the index unchanged" "$t" \
  "RFC-203 is present in rfcs/ and has no row in rfcs/README.md"

# 12. Derivation, the ledger. The index and the banners are held still and a ledger row is added.

t="$work/c12"; build_clean "$t"
make_std "$t" \
  "v1.1|A first fixture version." \
  "v1.2|A fixture version implementing \`rfcs/RFC-201\`." \
  "v1.3|A fixture version implementing \`rfcs/RFC-202\`."
fires "an implementation claim added to the ledger, with the index unchanged" "$t" \
  "records RFC-202 as DESIGN ONLY and the version ledger records v1.3 as implementing it" \
  "the version ledger records v1.3 as implementing RFC-202 and the status banner names no such version"

# 13. Refusals. Each asserts the refusal status and a line saying what could not be evaluated.
#     An unread directory is not an empty one, and an unparsable index is not an index describing
#     nothing.

t="$work/c13a"; build_clean "$t"; rm "$t/STANDARD.md"
refuses "an unreadable standard" "$t" "could not read STANDARD.md"

t="$work/c13b"; build_clean "$t"
printf '# A fixture standard\n\nNo table here.\n' > "$t/STANDARD.md"
refuses "a standard with no version-history heading" "$t" "carries no version-history heading"

t="$work/c13c"; build_clean "$t"
printf '# A fixture standard\n\n## Version history\n\nThe table is gone.\n' > "$t/STANDARD.md"
refuses "a version-history table with no row" "$t" "yielded no row"

t="$work/c13d"; build_clean "$t"
printf '# RFC index\n\nProse and no table.\n' > "$t/rfcs/README.md"
refuses "a present but unparsable index" "$t" "exists and yielded no parsable row"

t="$work/c13e"; build_clean "$t"
make_index "$t" \
  "RFC-201|A fixture adopted design|MOSTLY ADOPTED|v1.2|An invented status." \
  "RFC-202|A fixture open design|DESIGN ONLY| |Not taken up."
refuses "an index row with a status outside the vocabulary" "$t" "which is outside the vocabulary"

t="$work/c13f"; build_clean "$t"; rm -r "$t/rfcs"
refuses "a missing RFC directory" "$t" "the set of RFCs could not be derived"

t="$work/c13g"; build_clean "$t"; rm "$t"/rfcs/RFC-*.md
refuses "an RFC directory holding no RFC" "$t" "an empty set is not a verdict about the tree"

t="$work/c13h"; build_clean "$t"; rm "$t/assets/badges/rfcs.svg"
refuses "a missing badge" "$t" "there is no count surface to judge"

t="$work/c13i"; build_clean "$t"
printf '<svg xmlns="http://www.w3.org/2000/svg"></svg>' > "$t/assets/badges/rfcs.svg"
refuses "a badge with no message text" "$t" "yielded no message text"

t="$work/c13j"; build_clean "$t"
printf '# A fixture package\n\nNo badge is referenced here.\n' > "$t/README.md"
refuses "a page that does not reference the badge" "$t" "the accessible text could not be judged"

t="$work/c13k"; build_clean "$t"
printf '# RFC index\n\n| RFC | Title | Status |\n|---|---|---|\n| RFC-201 | A title | ADOPTED |\n' \
  > "$t/rfcs/README.md"
refuses "an index row with too few cells" "$t" "has fewer than four cells"

t="$work/c13l"; build_clean "$t"
{ cat "$t/rfcs/README.md"; printf '| RFC-201 | A duplicate | ADOPTED | v1.2 | 2026-01-01 | Twice. |\n'; } \
  > "$t/rfcs/README.tmp" && mv "$t/rfcs/README.tmp" "$t/rfcs/README.md"
refuses "an index stating two dispositions for one RFC" "$t" "has more than one row"

# 14. The round trip. The generator and the validator are one derivation, so what --write-badge
#     writes is what the validating run demands. A generator that drifted from its validator would
#     reintroduce the hand-maintained count by another route.

t="$work/c14"; build_clean "$t"
make_badge "$t" "wrong on purpose"
python3 "$CHECK" --root "$t" --write-badge > /dev/null
out=$(run_check "$t"); status=$?
if [ "$status" -eq 0 ]; then
  echo "PASS: a badge written by --write-badge satisfies the validating run"
else
  echo "FAIL: the generated badge did not satisfy the validator (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi

# 15. --write-badge refuses when there is nothing to derive from, rather than writing a count it
#     invented.

t="$work/c15"; build_clean "$t"; rm "$t/rfcs/README.md"
out=$(python3 "$CHECK" --root "$t" --write-badge 2>&1); status=$?
if [ "$status" -eq 2 ] && printf '%s' "$out" | grep -q "there is nothing to derive the badge from"; then
  echo "PASS: --write-badge refuses when no index exists"
else
  echo "FAIL: --write-badge did not refuse without an index (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi

# 16. THE EVIDENCE CASE: the check against published main as it stands before this change.
# The strongest direction available. The tree is the real published one at $PRE_REPAIR_COMMIT,
# extracted from git rather than rebuilt. The count is asserted rather than a bare non-zero exit, so
# a blanket match cannot pass as a finding.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT:STANDARD.md" 2>/dev/null; then
  mkdir -p "$work/prerepair"
  git -C "$ROOT" archive "$PRE_REPAIR_COMMIT" STANDARD.md README.md rfcs assets/badges/rfcs.svg \
    | tar -x -C "$work/prerepair"
  pre_out=$(run_check "$work/prerepair"); pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -cE 'no index covers it|status banner names no such version|no index exists to derive it from')
  if [ "$pre_status" -eq 1 ] \
     && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -qF "records v1.35 as implementing RFC-004" \
     && printf '%s' "$pre_out" | grep -qF "records v1.39 as implementing RFC-006" \
     && printf '%s' "$pre_out" | grep -qF "records v1.41 as implementing RFC-007" \
     && printf '%s' "$pre_out" | grep -qF "reads '2 adopted' and no index exists to derive it from" \
     && printf '%s' "$pre_out" | grep -qF "the version ledger records 3 RFC(s) as implemented"; then
    echo "PASS: against published main at $PRE_REPAIR_COMMIT the check names seven uncovered RFCs,"
    echo "      the three stale banners with their implementing versions, and the false badge count,"
    echo "      reporting exactly $PRE_REPAIR_EXPECTED statements"
    printf '%s\n' "$pre_out" | sed 's/^/      /'
  else
    echo "FAIL: the pre-repair evidence case did not reproduce the defect"
    echo "      (exit $pre_status, $found statements named, $PRE_REPAIR_EXPECTED expected)"
    printf '%s\n' "$pre_out"
    fail=1
  fi
else
  echo "GAP: commit $PRE_REPAIR_COMMIT is not present in this clone, so the pre-repair evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

if [ "$fail" -eq 0 ]; then
  echo "rfc-lifecycle canaries passed"
  exit 0
else
  exit 1
fi
