#!/bin/bash
# km-unrepaired-tree: v1.45 | run against published main at c3e4ffe before the RFC landed, where it names all nine real dangling references at their exact lines and reports only RFC-005, so the failure is selective.
# Canaries for the RFC reference-integrity check (scripts/validate_rfc_references.py), added in
# v1.45.
#
# rfc-reference-exempt: the instrument's own fixtures name identifiers that do not exist on purpose.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that the check fires on an identifier with no file behind it, in each of the written
# forms a reference takes in this repository: a bare identifier in prose, the code-formatted path
# with no filename that is the form the real defect wore, a version-ledger row, and a path naming a
# file that is not there. It proves the check does NOT fire on a tree in which every reference
# resolves. It proves the existing set is derived from the directory rather than held in the check,
# because adding the file alone flips the same fixture text from fail to pass. It proves the check
# refuses rather than passes on input it could not evaluate. And it proves a passing run states its
# coverage.
#
# It does NOT prove that a resolvable reference is a reference to the right document, that the cited
# document is current, or that a document which should have been cited was cited. The check models
# openability, and proving both directions proves it fires on the class it models, never that it
# models the right class.
#
# BOTH DIRECTIONS. A check that reports a problem passes by absence, so a clean run against the real
# repository proves nothing on its own:
#   - cases 2 to 5 inject dangling references, one per written form, and require the check to catch
#     each one;
#   - case 6 gives it a tree in which every reference resolves, in all three forms, and requires it
#     NOT to fire, since a check that matches everything proves as little as one that matches
#     nothing;
#   - case 9 runs the check against published `main` as it stood BEFORE this change and requires it
#     to fail there, naming the nine real RFC-005 references in STANDARD.md and in the two RFCs that
#     depend on it. That is the strongest available evidence that the instrument detects the defect
#     it was written for rather than a synthetic likeness of it.
#
# ONE REFUSAL BRANCH IS NOT REACHED BY A CANARY, AND IS NAMED RATHER THAN COUNTED. The check refuses
# when no file was scanned at all. While `rfcs/` is itself a scan root, a tree that satisfies the
# derivation step necessarily carries at least one scannable file, so that branch is unreachable from
# a fixture and is defence in depth rather than a proved behaviour. The reachable form of the same
# guard, every file in scope declaring an exemption, IS proved, in case 8.
#
# All fixture content is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/validate_rfc_references.py"
# Published v1.44: the last state of the repository before RFC-005 landed, and the evidence anchor
# for case 9.
PRE_REPAIR_COMMIT="c3e4ffe"
# The dangling references that commit carries: two in STANDARD.md (the editions section and the
# v1.39 ledger row) and seven across the two RFCs that depend on RFC-005.
PRE_REPAIR_EXPECTED=9

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

run_check() {  # $1 = root; prints combined output, returns the check exit status
  python3 "$CHECK" --root "$1" 2>&1
}

# ── fixture roots: a minimal repository shape carrying two real RFCs ─────────────────────────────

make_root() {  # $1 = root dir, $2 = STANDARD.md body, $3 = extra ledger row text
  mkdir -p "$1/rfcs"
  cat > "$1/rfcs/RFC-101-first.md" <<'EOF'
# RFC-101: a fixture design document

This document exists.
EOF
  cat > "$1/rfcs/RFC-102-second.md" <<'EOF'
# RFC-102: a second fixture design document

It depends on RFC-101 and on nothing else.
EOF
  cat > "$1/STANDARD.md" <<EOF
# Fixture standard

$2

## Version history

| Version | Date | What it introduced |
|---|---|---|
| v9.1 | 2026-01-01 | A fixture version implementing \`rfcs/RFC-101\`. $3 |
EOF
}

land_rfc() {  # $1 = root dir, $2 = identifier -> make the named RFC exist
  cat > "$1/rfcs/$2-late.md" <<EOF
# $2: a fixture design document that landed later

This document now exists.
EOF
}

# ── 1. The real repository passes, and the passing line states coverage ──────────────────────────
# MSS: a check declares its own coverage in its passing line. A pass that does not say how much it
# looked at is void rather than clean, so the numbers are asserted and not merely printed.

real_out=$(run_check "$ROOT"); real_status=$?
if [ "$real_status" -eq 0 ] \
   && printf '%s' "$real_out" | grep -q "^PASS rfc-reference-integrity:" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* RFC reference\(s\) found" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* file\(s\) scanned" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* distinct identifier\(s\)" \
   && printf '%s' "$real_out" | grep -qE "[1-9][0-9]* RFC\(s\) present in rfcs/" \
   && printf '%s' "$real_out" | grep -q "RFC-005" \
   && printf '%s' "$real_out" | grep -q "exempt: scripts/validate_rfc_references.py"; then
  echo "PASS: every RFC reference in the repository resolves, and the run states its coverage"
  printf '%s\n' "$real_out" | sed 's/^/      /'
else
  echo "FAIL: the check did not pass with a coverage-stating line against the real repository"
  printf '%s\n' "$real_out"
  fail=1
fi

# ── 2. POSITIVE: a bare identifier in running prose ──────────────────────────────────────────────

make_root "$work/prose" "This section does not implement the routines designed in RFC-105." ""
prose_out=$(run_check "$work/prose"); prose_status=$?
if [ "$prose_status" -eq 1 ] \
   && printf '%s' "$prose_out" | grep -q "DANGLING RFC REFERENCES" \
   && printf '%s' "$prose_out" | grep -q "STANDARD.md:3: RFC-105 is named here"; then
  echo "PASS: a bare identifier in prose with no file behind it is caught, with file and line"
else
  echo "FAIL: a dangling bare identifier in prose was not caught (exit $prose_status)"
  printf '%s\n' "$prose_out"
  fail=1
fi

# ── 3. POSITIVE: the code-formatted path, which is the form the real defect wore ─────────────────
# The published reference was written as `rfcs/RFC-005`, inside backticks and inside no link, so a
# walk over Markdown hyperlinks never saw it. This case is the whole reason the check exists.

make_root "$work/coded" "It does not implement the routines (\`rfcs/RFC-105\`); it references them." ""
coded_out=$(run_check "$work/coded"); coded_status=$?
if [ "$coded_status" -eq 1 ] \
   && printf '%s' "$coded_out" | grep -q "STANDARD.md:3: RFC-105 is named here"; then
  echo "PASS: a code-formatted path carrying no filename is caught, which a hyperlink walk misses"
else
  echo "FAIL: the code-formatted path form was not caught (exit $coded_status)"
  printf '%s\n' "$coded_out"
  fail=1
fi

# ── 4. POSITIVE: a version-ledger row, which is published text like any other ────────────────────

make_root "$work/ledger" "A clean section citing RFC-101." \
  "Neither the reader nor the routines (\`rfcs/RFC-105\`) is implemented here."
ledger_out=$(run_check "$work/ledger"); ledger_status=$?
if [ "$ledger_status" -eq 1 ] \
   && printf '%s' "$ledger_out" | grep -q "STANDARD.md:9: RFC-105 is named here"; then
  echo "PASS: a dangling identifier inside a version-ledger row is caught"
else
  echo "FAIL: a dangling identifier in a ledger row was not caught (exit $ledger_status)"
  printf '%s\n' "$ledger_out"
  fail=1
fi

# ── 5. POSITIVE: a path naming a file that is not there, under an identifier that IS there ───────
# The identifier resolving is not the path resolving. Without this arm a rename inside rfcs/ would
# leave every link to the old filename passing on the strength of the number in it.

make_root "$work/path" \
  "See [\`rfcs/RFC-101\`](rfcs/RFC-101-renamed-away.md) for the full rationale." ""
path_out=$(run_check "$work/path"); path_status=$?
if [ "$path_status" -eq 1 ] \
   && printf '%s' "$path_out" | grep -q "path reference 'rfcs/RFC-101-renamed-away.md' names no file" \
   && ! printf '%s' "$path_out" | grep -q "RFC-101 is named here"; then
  echo "PASS: a path naming an absent file is caught even though its identifier exists, and the"
  echo "      identifier itself is not additionally reported"
else
  echo "FAIL: the path form was not judged on its filename (exit $path_status)"
  printf '%s\n' "$path_out"
  fail=1
fi

# ── 6. NEGATIVE DIRECTION: every reference resolves, in all three forms ──────────────────────────
# Without this, cases 2 to 5 would be satisfied by a check that flags every identifier it sees.

make_root "$work/clean" \
  "Designed in RFC-101, cited as \`rfcs/RFC-102\`, and linked as [RFC-102](rfcs/RFC-102-second.md)." ""
clean_out=$(run_check "$work/clean"); clean_status=$?
if [ "$clean_status" -eq 0 ] \
   && printf '%s' "$clean_out" | grep -q "^PASS rfc-reference-integrity:" \
   && printf '%s' "$clean_out" | grep -q "2 RFC(s) present in rfcs/ (RFC-101, RFC-102)" \
   && printf '%s' "$clean_out" | grep -q "1 of them written as a path naming a file"; then
  echo "PASS: a tree in which every reference resolves does not fire, and the pass states coverage"
else
  echo "FAIL: the check fired on a tree with no dangling reference (exit $clean_status)"
  printf '%s\n' "$clean_out"
  fail=1
fi

# ── 7. The existing set is derived from the directory, not held in the check ─────────────────────
# The fixture text is byte-identical across the two runs. Only the directory changes. If the verdict
# flips, the set is being read from rfcs/, which is what keeps the check working as RFCs are added.

make_root "$work/derived" "This section references \`rfcs/RFC-105\` and nothing else new." ""
derived_before=$(run_check "$work/derived"); derived_before_status=$?
land_rfc "$work/derived" "RFC-105"
derived_after=$(run_check "$work/derived"); derived_after_status=$?
if [ "$derived_before_status" -eq 1 ] && [ "$derived_after_status" -eq 0 ] \
   && printf '%s' "$derived_after" | grep -q "3 RFC(s) present in rfcs/ (RFC-101, RFC-102, RFC-105)"; then
  echo "PASS: landing the file alone flips the same text from dangling to resolved, so the existing"
  echo "      set is derived from rfcs/ and no list is held in the check"
else
  echo "FAIL: adding the RFC file did not change the verdict for identical text (before"
  echo "      $derived_before_status, after $derived_after_status)"
  printf '%s\n' "$derived_before"
  printf '%s\n' "$derived_after"
  fail=1
fi

# The mirror of the same claim: removing a file makes references to it dangle again.
rm "$work/derived/rfcs/RFC-105-late.md"
derived_removed=$(run_check "$work/derived"); derived_removed_status=$?
if [ "$derived_removed_status" -eq 1 ] \
   && printf '%s' "$derived_removed" | grep -q "RFC-105 is named here"; then
  echo "PASS: removing the file again makes the same references dangle, in both directions"
else
  echo "FAIL: removing the RFC file did not restore the dangling verdict (exit"
  echo "      $derived_removed_status)"
  printf '%s\n' "$derived_removed"
  fail=1
fi

# ── 8. FAIL CLOSED: every unevaluable input refuses rather than returning a verdict ──────────────
# An unread directory is not an empty one, and a pattern that has stopped matching produces the same
# silence as a tree that cites nothing. Each of these must refuse, and say what it could not do.

# (a) no rfcs/ directory at all
mkdir -p "$work/nodir"
printf '# Fixture\n\nReferences RFC-101.\n' > "$work/nodir/STANDARD.md"
nodir_out=$(run_check "$work/nodir"); nodir_status=$?

# (b) rfcs/ present and holding no RFC
mkdir -p "$work/emptydir/rfcs"
printf 'not an RFC\n' > "$work/emptydir/rfcs/README.md"
printf '# Fixture\n\nReferences RFC-101.\n' > "$work/emptydir/STANDARD.md"
emptydir_out=$(run_check "$work/emptydir"); emptydir_status=$?

# (c) nothing parsed: the surface names no identifier at all. The near-misses here also prove the
#     match boundary, since `xRFC-101` and a bare `rfcs/` must not read as references.
make_root "$work/silent" "This text mentions rfcs/ and xRFC-101 and RFC on its own." ""
# The fixture's own RFC files name identifiers in their bodies, and the ledger row cites one, so
# both are replaced with prose that names none. What remains is a tree whose files exist and whose
# text carries only near-misses.
printf '# A fixture design document\n\nIt names no identifier.\n' \
  > "$work/silent/rfcs/RFC-101-first.md"
printf '# A second fixture design document\n\nIt names no identifier either.\n' \
  > "$work/silent/rfcs/RFC-102-second.md"
printf '# Fixture standard\n\nThis text mentions rfcs/ and xRFC-101 and RFC on its own.\n' \
  > "$work/silent/STANDARD.md"
silent_out=$(run_check "$work/silent"); silent_status=$?

# (d) a file in scope that cannot be decoded
make_root "$work/binary" "A clean section citing RFC-101." ""
printf 'a\000\377\376b\n' > "$work/binary/rfcs/RFC-101-first.md"
binary_out=$(run_check "$work/binary"); binary_status=$?

# (e) an exemption declaring no reason
make_root "$work/noreason" "A clean section citing RFC-101." ""
printf 'rfc-reference-exempt:\n' > "$work/noreason/rfcs/RFC-102-second.md"
noreason_out=$(run_check "$work/noreason"); noreason_status=$?

# (f) every file in scope exempt: the reachable form of "nothing was evaluated"
make_root "$work/allexempt" "rfc-reference-exempt: fixture" ""
printf 'rfc-reference-exempt: fixture\n' > "$work/allexempt/rfcs/RFC-101-first.md"
printf 'rfc-reference-exempt: fixture\n' > "$work/allexempt/rfcs/RFC-102-second.md"
allexempt_out=$(run_check "$work/allexempt"); allexempt_status=$?

closed=0
expected=6
for pair in "no rfcs directory:$nodir_status" "rfcs holds no RFC:$emptydir_status" \
            "nothing parsed:$silent_status" "undecodable file:$binary_status" \
            "exemption with no reason:$noreason_status" "everything exempt:$allexempt_status"; do
  name="${pair%:*}"; status="${pair##*:}"
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
for out in "$nodir_out" "$emptydir_out" "$silent_out" "$binary_out" "$noreason_out" \
           "$allexempt_out"; do
  if ! printf '%s' "$out" | grep -q "^REFUSED rfc-reference-integrity:"; then
    echo "FAIL: a refusal did not say what it could not evaluate"
    printf '%s\n' "$out"
    fail=1
  fi
done
if printf '%s' "$silent_out" | grep -q "no RFC reference was found"; then
  echo "PASS: text carrying rfcs/, xRFC-101 and a bare RFC yields no reference, so the match"
  echo "      boundary holds and an unmatched surface refuses instead of passing"
else
  echo "FAIL: the boundary case did not refuse for the stated reason"
  printf '%s\n' "$silent_out"
  fail=1
fi

# ── 9. THE REAL DEFECT: the check fails against published main as it stood before this change ────
# Cases 2 to 8 use synthetic input, which proves the mechanism and not the fit. This case proves the
# fit against the tree the defect was actually found in. An unresolvable commit is reported as a
# coverage gap and is never folded into the verdict.

if git -C "$ROOT" cat-file -e "$PRE_REPAIR_COMMIT^{commit}" 2>/dev/null; then
  mkdir -p "$work/pre-repair"
  git -C "$ROOT" archive "$PRE_REPAIR_COMMIT" | tar -x -C "$work/pre-repair"
  pre_out=$(run_check "$work/pre-repair"); pre_status=$?
  found=$(printf '%s' "$pre_out" | grep -c "RFC-005 is named here")
  if [ "$pre_status" -eq 1 ] && [ "$found" -eq "$PRE_REPAIR_EXPECTED" ] \
     && printf '%s' "$pre_out" | grep -q "STANDARD.md:3962: RFC-005" \
     && printf '%s' "$pre_out" | grep -q "STANDARD.md:4213: RFC-005" \
     && printf '%s' "$pre_out" | grep -q "rfcs/RFC-006-editions.md:11: RFC-005" \
     && printf '%s' "$pre_out" | grep -q "rfcs/RFC-007-reader-tier.md:11: RFC-005"; then
    echo "PASS: against published main at $PRE_REPAIR_COMMIT the check fails, naming $found real"
    echo "      RFC-005 references in STANDARD.md and in the two RFCs that depend on it"
  else
    echo "FAIL: the check did not detect the defect it was written for in the pre-repair tree"
    echo "      (exit $pre_status, $found references named, $PRE_REPAIR_EXPECTED expected)"
    printf '%s\n' "$pre_out"
    fail=1
  fi
  # The other six identifiers in the same tree resolve and must survive the run untouched, or the
  # pre-repair failure would be a blanket match rather than a finding.
  others=$(printf '%s' "$pre_out" | grep -c "is named here" )
  if [ "$others" -eq "$PRE_REPAIR_EXPECTED" ]; then
    echo "PASS: only RFC-005 is reported in the pre-repair tree, so the failure is selective"
  else
    echo "FAIL: the pre-repair run reported $others identifiers, not only the RFC-005 references"
    printf '%s\n' "$pre_out"
    fail=1
  fi
else
  echo "GAP: commit $PRE_REPAIR_COMMIT is not present in this clone, so the pre-repair evidence"
  echo "     case could not be run. This is a coverage gap in this run, not a verdict."
fi

if [ "$fail" -eq 0 ]; then
  echo "rfc-reference-integrity canaries passed"
  exit 0
else
  exit 1
fi
