#!/bin/bash
# km-unrepaired-tree: v1.48 | case 10 is the unrepaired-tree run: the check is run against template/README.md and STANDARD.md as they stood at published main 62c4e51, read out of git rather than rebuilt, where it names Rule 5 and Rule 6 as unenumerated and names the phrase 'all four rules' with both counts, reporting exactly three statements so the failure is selective rather than a blanket match.
# Canaries for the template rule-summary check (scripts/validate_template_rule_summary.py), added in v1.48.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves the check fires when the hub template's landing page fails to enumerate a rule the
# standard defines, and when a count written before the word "rules" on that page disagrees with the
# number of rules the standard defines. It proves the two arms are independent, because a page can
# carry every entry and still state a wrong count. It proves the check does NOT fire on a page that
# enumerates every rule and states a correct count. It proves the rule set is derived from the
# standard rather than held in the check, because adding a rule to a fixture standard flips the same
# unchanged landing page from passing to failing. It proves the check refuses rather than passes on
# input it could not evaluate, and that a passing run states its coverage.
#
# It does NOT prove that a summary entry describes its rule correctly, that anything else on the page
# is true, that an enforcement claim elsewhere in the repository is correctly narrowed, or that a
# descriptive document set is current. Terminology quality is a judgement and is deliberately not
# scored. Proving both directions proves the check fires on the class it models, never that it models
# the right class.
#
# BOTH DIRECTIONS. The check reports a defect by finding one, so a clean run against the repaired
# repository proves nothing on its own:
#   - case 2 removes one rule's entry from a fixture landing page and requires the check to name it;
#   - case 3 gives it a page carrying every entry and one wrong count phrase, and requires the count
#     arm to fire on its own, so a repair to the list alone cannot be mistaken for a repair;
#   - case 4 gives it a page that is right in both arms and requires it NOT to fire, since a check
#     that fires on everything proves as little as one that fires on nothing;
#   - case 10 runs the check against the landing page and the standard as they stood BEFORE this
#     change and requires it to fail there, naming both missing rules and the false count. That is
#     the strongest available evidence that the instrument detects the defect it was written for
#     rather than a synthetic likeness of it.
#
# THE DERIVATION CASE IS NOT DECORATION. Case 5 holds the landing page still and adds a seventh rule
# to a fixture standard. The page must go from passing to failing with no edit to the check. A check
# holding its own copy of the rule set would pass both times, and that copy is the artifact class the
# defect under repair belongs to.
#
# All fixture content is synthetic. No person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_template_rule_summary.py"
# Published v1.47: the last state of the repository before the landing page was repaired, and the
# evidence anchor for case 10.
PRE_REPAIR_COMMIT="62c4e51"
# The three statements that commit's landing page carries which the standard's rule set does not support.
PRE_REPAIR_EXPECTED=3

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

run_check() {  # $1 = standard path, $2 = landing page path
  python3 "$CHECK" --standard "$1" --landing "$2" 2>&1
}

make_standard() {  # $1 = path, $2... = rule numbers
  local path="$1"; shift
  mkdir -p "$(dirname "$path")"
  {
    printf '# A fixture standard\n\nProse that declares no rule.\n\n'
    printf '## Governance Layer\n\n'
    local n
    for n in "$@"; do
      printf '### Rule %s: A fixture rule\n\nIts body.\n\n' "$n"
    done
  } > "$path"
}

make_landing() {  # $1 = path, $2 = trailing sentence (may be empty), $3... = entry numbers
  local path="$1" sentence="$2"; shift 2
  mkdir -p "$(dirname "$path")"
  {
    printf '# A fixture hub\n\n## Hub contents\n\nA table would sit here.\n\n'
    printf '## Governance rules (summary)\n\n'
    local n
    for n in "$@"; do
      printf '%s. **A fixture rule** its one-line summary\n' "$n"
    done
    printf '\n'
    [ -n "$sentence" ] && printf '%s\n\n' "$sentence"
    printf '## How to work with this hub\n\nSome closing prose.\n'
  } > "$path"
}

refuses() {  # $1 = label, $2 = standard, $3 = landing, $4 = expected fragment
  local label="$1" std="$2" land="$3" fragment="$4"
  local out status
  out=$(run_check "$std" "$land"); status=$?
  if [ "$status" -eq 2 ] \
     && printf '%s' "$out" | grep -q "^REFUSED template-rule-summary:" \
     && printf '%s' "$out" | grep -q "$fragment"; then
    echo "PASS: refuses on $label"
  else
    echo "FAIL: did not refuse on $label (exit $status)"
    printf '%s\n' "$out"
    fail=1
  fi
}

# 1. The repaired repository passes, and the passing line states coverage
# A check declares its own coverage in its passing line. A pass that does not say how much it looked
# at is void rather than clean, so the numbers are asserted and not merely printed.

real_out=$(python3 "$CHECK" 2>&1); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS template-rule-summary:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* rule\(s\) derived" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* summary entry/ies found" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* matched" \
   && printf '%s' "$real_out" | grep -qE "count phrase\(s\) judged"; then
  echo "PASS: the repository's own landing page enumerates every rule and states coverage"
  printf '%s\n' "$real_out" | sed 's/^/      /'
else
  echo "FAIL: the check did not pass with a coverage-stating line against the real repository"
  printf '%s\n' "$real_out"
  fail=1
fi

# 2. POSITIVE, enumeration: a rule the standard defines has no entry
# This is the shape of the real defect: the standard grew to six rules and the inherited landing page
# stayed at four, so every hub scaffolded from it was taught the older model.

make_standard "$work/enum/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/enum/README.md" "" 1 2 3 4
enum_out=$(run_check "$work/enum/STANDARD.md" "$work/enum/README.md"); enum_status=$?
if [ "$enum_status" -eq 1 ] \
   && printf '%s' "$enum_out" | grep -q "TEMPLATE RULE SUMMARY DISAGREEMENT" \
   && printf '%s' "$enum_out" | grep -q "the standard defines Rule 5 and the governance-rule summary has no entry" \
   && printf '%s' "$enum_out" | grep -q "the standard defines Rule 6 and the governance-rule summary has no entry" \
   && [ "$(printf '%s' "$enum_out" | grep -c 'has no entry for it')" -eq 2 ]; then
  echo "PASS: a rule with no summary entry is caught and named"
else
  echo "FAIL: an unenumerated rule was not caught (exit $enum_status)"
  printf '%s\n' "$enum_out"
  fail=1
fi

# 3. POSITIVE, count: every entry present and the prose still asserts the old count
# The two arms are separate on purpose. A maintainer who extends the list and leaves the sentence has
# repaired the visible half of the defect and shipped the other half, which is the defect surviving
# its own repair.

make_standard "$work/count/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/count/README.md" "Run the scan at session start. It checks all four rules in one pass." 1 2 3 4 5 6
count_out=$(run_check "$work/count/STANDARD.md" "$work/count/README.md"); count_status=$?
if [ "$count_status" -eq 1 ] \
   && printf '%s' "$count_out" | grep -q "'all four rules' asserts 4 rule(s) and the standard defines 6" \
   && ! printf '%s' "$count_out" | grep -q "has no entry for it"; then
  echo "PASS: a wrong count fires on its own, with every summary entry present"
else
  echo "FAIL: the count arm did not fire independently of the enumeration arm (exit $count_status)"
  printf '%s\n' "$count_out"
  fail=1
fi

# 4. NEGATIVE: every rule enumerated and the count correct
# A check that fires on everything proves as little as one that fires on nothing.

make_standard "$work/clean/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/clean/README.md" "The scan covers all six rules at session start." 1 2 3 4 5 6
clean_out=$(run_check "$work/clean/STANDARD.md" "$work/clean/README.md"); clean_status=$?
if [ "$clean_status" -eq 0 ] \
   && printf '%s' "$clean_out" | grep -q "^PASS template-rule-summary:" \
   && ! printf '%s' "$clean_out" | grep -q "DISAGREEMENT"; then
  echo "PASS: a landing page that enumerates every rule and counts correctly does not fire"
else
  echo "FAIL: the check fired on a conformant page, or refused it (exit $clean_status)"
  printf '%s\n' "$clean_out"
  fail=1
fi

# 5. The rule set is derived: the same page flips when the standard gains a rule
# The landing page is byte-identical across both runs. Only the standard changes. A check holding its
# own copy of the rule set would return the same answer twice.

make_standard "$work/derive/six/STANDARD.md" 1 2 3 4 5 6
make_standard "$work/derive/seven/STANDARD.md" 1 2 3 4 5 6 7
make_landing "$work/derive/README.md" "The scan covers all six rules at session start." 1 2 3 4 5 6
six_out=$(run_check "$work/derive/six/STANDARD.md" "$work/derive/README.md"); six_status=$?
seven_out=$(run_check "$work/derive/seven/STANDARD.md" "$work/derive/README.md"); seven_status=$?
if [ "$six_status" -eq 0 ] \
   && [ "$seven_status" -eq 1 ] \
   && printf '%s' "$seven_out" | grep -q "the standard defines Rule 7 and the governance-rule summary has no entry" \
   && printf '%s' "$seven_out" | grep -q "'all six rules' asserts 6 rule(s) and the standard defines 7"; then
  echo "PASS: one unchanged landing page passes against six rules and fails against seven"
else
  echo "FAIL: the rule set is not derived from the standard (exit $six_status/$seven_status)"
  printf '%s\n' "$seven_out"
  fail=1
fi

# 6. A count written as a numeral is read the same way as a spelled-out one
# A page repaired by a later hand may write the figure. The defect is the disagreement, not the
# spelling, and a check that read only words would report a clean page for the form it does not read.

make_standard "$work/numeral/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/numeral/README.md" "The scan covers 4 rules at session start." 1 2 3 4 5 6
num_out=$(run_check "$work/numeral/STANDARD.md" "$work/numeral/README.md"); num_status=$?
if [ "$num_status" -eq 1 ] \
   && printf '%s' "$num_out" | grep -q "'4 rules' asserts 4 rule(s) and the standard defines 6"; then
  echo "PASS: a count written as a numeral is judged like a spelled-out one"
else
  echo "FAIL: a numeral count was not judged (exit $num_status)"
  printf '%s\n' "$num_out"
  fail=1
fi

# 7. A page that states no count at all passes, and says the arm judged nothing
# Silence is a legitimate page and is not a silent pass: the coverage line reports that the count arm
# found nothing to judge, so a reader can tell an empty arm from a satisfied one.

make_standard "$work/nocount/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/nocount/README.md" "Run the scan at the start of every session." 1 2 3 4 5 6
noc_out=$(run_check "$work/nocount/STANDARD.md" "$work/nocount/README.md"); noc_status=$?
if [ "$noc_status" -eq 0 ] \
   && printf '%s' "$noc_out" | grep -q "0 count phrase(s) judged" \
   && printf '%s' "$noc_out" | grep -q "no rule count is written in the landing page's prose"; then
  echo "PASS: a page stating no count passes and reports that the count arm judged nothing"
else
  echo "FAIL: an absent count was folded into the verdict rather than reported (exit $noc_status)"
  printf '%s\n' "$noc_out"
  fail=1
fi

# 8. An entry numbered for a rule the standard does not define
# The comparison runs in both directions. A page carrying a seventh entry against a six-rule standard
# is describing a rule nobody can read, which is the same class pointing the other way.

make_standard "$work/extra/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/extra/README.md" "" 1 2 3 4 5 6 7
extra_out=$(run_check "$work/extra/STANDARD.md" "$work/extra/README.md"); extra_status=$?
if [ "$extra_status" -eq 1 ] \
   && printf '%s' "$extra_out" | grep -q "an entry numbered 7 and the standard defines no such rule"; then
  echo "PASS: an entry for a rule the standard does not define is caught"
else
  echo "FAIL: a surplus entry was not caught (exit $extra_status)"
  printf '%s\n' "$extra_out"
  fail=1
fi

# 9. Refusals: five inputs the check cannot evaluate
# An unread page is not a conformant one, and a summary that parsed to nothing looks exactly like one
# whose entries all match. Each case asserts the refusal status and a line saying what failed.

make_standard "$work/ref/STANDARD.md" 1 2 3 4 5 6
make_landing "$work/ref/README.md" "" 1 2 3 4 5 6

refuses "a standard that is not there" \
  "$work/ref/absent-standard.md" "$work/ref/README.md" "could not read the standard"

refuses "a landing page that is not there" \
  "$work/ref/STANDARD.md" "$work/ref/absent-landing.md" "could not read the landing page"

printf '# A fixture standard\n\nProse and no rule heading anywhere.\n' > "$work/ref/norules.md"
refuses "a standard yielding no rule heading" \
  "$work/ref/norules.md" "$work/ref/README.md" "no rule heading was found"

printf '# A fixture hub\n\n## Hub contents\n\nNo summary heading here.\n' > "$work/ref/nosection.md"
refuses "a landing page with no governance-rule summary" \
  "$work/ref/STANDARD.md" "$work/ref/nosection.md" "no governance-rule summary heading was found"

printf '# A fixture hub\n\n## Governance rules (summary)\n\nProse, and not one numbered entry.\n\n## Next\n' \
  > "$work/ref/noentries.md"
refuses "a summary section yielding no numbered entry" \
  "$work/ref/STANDARD.md" "$work/ref/noentries.md" "yielded no numbered entry"

# 10. THE EVIDENCE CASE: published main before the repair
# The strongest direction available. Both inputs are the real published files at $PRE_REPAIR_COMMIT,
# byte for byte, taken from git rather than rebuilt. The count is asserted rather than a bare
# non-zero exit, so a blanket match cannot pass as a finding.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT:template/README.md" 2>/dev/null; then
  mkdir -p "$work/prerepair/template"
  git -C "$ROOT" show "$PRE_REPAIR_COMMIT:STANDARD.md" > "$work/prerepair/STANDARD.md"
  git -C "$ROOT" show "$PRE_REPAIR_COMMIT:template/README.md" > "$work/prerepair/template/README.md"
  pre_out=$(run_check "$work/prerepair/STANDARD.md" "$work/prerepair/template/README.md")
  pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -cE 'has no entry for it|asserts [0-9]+ rule')
  if [ "$pre_status" -eq 1 ] \
     && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -q "the standard defines Rule 5 and the governance-rule summary has no entry" \
     && printf '%s' "$pre_out" | grep -q "the standard defines Rule 6 and the governance-rule summary has no entry" \
     && printf '%s' "$pre_out" | grep -q "'all four rules' asserts 4 rule(s) and the standard defines 6"; then
    echo "PASS: against published main at $PRE_REPAIR_COMMIT the check names both unenumerated rules"
    echo "      and the false count, reporting exactly $PRE_REPAIR_EXPECTED statements"
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
  echo "template-rule-summary canaries passed"
  exit 0
else
  exit 1
fi
