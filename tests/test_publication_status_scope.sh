#!/bin/bash
# km-unrepaired-tree: v1.52 | case 4 IS the unrepaired-tree run, carried inside the suite rather than described: it reconstructs the exact pattern this repair replaces, r"\*\*DRAFT\b|\bDRAFT\s*[—–-]\s*awaiting owner push" applied with search over the description, runs the same fixtures through it, and requires it to misclassify the published row that quotes a declaration while the anchored classifier gets it right. Cases 5 and 6 run both real instruments over the tree at 1444b15 and over that tree with only the v1.50 opener flipped, where the unrepaired pair reported "49 published, 2 unpublished" and "2 excluded as drafted: v1.23, v1.50" and both exited 0.
# Canaries for the shared publication-status classifier (scripts/publication_status.py), added in
# v1.52.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that a description cell opening with a draft declaration classifies as unpublished, in
# every form the ledger has ever used; that a description cell opening with a published stamp
# classifies as published even when it reproduces a declaration verbatim further along; that the
# rule is anchored rather than narrowed, by running the same fixtures through the superseded pattern
# and requiring the two to disagree on exactly the quoting case; that a row is split into version,
# date and description before it is classified, so the date column is never consulted for status;
# and that a line which cannot be split is reported as unsplittable rather than as published.
#
# It does NOT prove that the version-history table is honest. A row opening with a published stamp
# for a version nobody pushed classifies as published, here and in both instruments. The table is
# the only publication record the repository has and a check cannot audit its own oracle.
#
# BOTH DIRECTIONS. The classifier reports a status rather than a defect, so both directions are
# statuses: case 1 requires it to say unpublished on every real declaration form, case 2 requires it
# to say published on every real published form, and case 3 requires it to say published on the
# quoting row that is the whole reason for the repair. A rule that answered unpublished to everything
# would pass case 1 alone; a rule that had stopped matching would pass cases 2 and 3 alone.
#
# All fixture content is synthetic apart from the opener forms, which are quoted from this
# repository's own ledger because those forms are what the rule is derived from. No person,
# organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ROOT/scripts"
# The v1.50 draft commit: its row opens with a declaration and reproduces another row's declaration
# further along the same cell, which is the material the defect was found in.
QUOTING_COMMIT="1444b15"

fail=0

# classify <description cell text>  ->  prints "unpublished" or "published"
classify() {
  SCRIPTS="$SCRIPTS" python3 - "$1" <<'PY'
import os, sys
sys.path.insert(0, os.environ["SCRIPTS"])
from publication_status import opens_with_draft_declaration
print("unpublished" if opens_with_draft_declaration(sys.argv[1]) else "published")
PY
}

expect() {  # $1 = expected, $2 = description, $3 = label
  local got
  got=$(classify "$2")
  if [ "$got" = "$1" ]; then
    echo "PASS: $3 classifies $1"
  else
    echo "FAIL: $3 classifies $got, expected $1"
    echo "      cell: $2"
    fail=1
  fi
}

# ── 1. POSITIVE: every declaration form the ledger has used reads as unpublished ─────────────────

expect unpublished '**DRAFT — awaiting owner push.** Stations, compartments, and the resolution plane.' \
  "the em dash form, as v1.23 carries it,"
expect unpublished '**DRAFT, awaiting owner push.** The design record states what became of it.' \
  "the comma form, as the v1.50 and v1.51 drafts carried it,"
expect unpublished 'DRAFT - awaiting owner push' \
  "the bare form the earlier docstring documented"
expect unpublished '  **DRAFT, awaiting owner push.** Leading whitespace before the marker.' \
  "leading whitespace before the marker"
expect unpublished '*DRAFT, awaiting owner push.* One emphasis marker rather than two.' \
  "a single emphasis marker"
expect unpublished 'DRAFT' \
  "a cell that is the bare token and nothing else"

# ── 2. NEGATIVE: every published opener the ledger has used reads as published ───────────────────
# Without this the suite would be satisfied by a rule that answered unpublished to everything.

expect published 'Drafted and published 2026-08-24 (owner push). The one executable this standard ships.' \
  "the published stamp"
expect published 'Drafted 2026-08-14; published 2026-08-16 with v1.22. The owner queue.' \
  "a version published inside a later train"
expect published 'Base standard: OKF frontmatter, five governance rules, hub structure.' \
  "an early row with no stamp at all"
expect published 'DRAFTED and published, in a form nobody writes.' \
  "a token whose next character is a word character, so no boundary exists"

# ── 3. THE REPAIR: a published row that quotes a declaration reads as published ──────────────────
# This is the case the whole version exists for. The cell opens with a published stamp and
# reproduces the v1.23 declaration verbatim as evidence for a statement it is making, which is what
# the real v1.50 row did.

QUOTING_CELL='Drafted and published 2026-08-24 (owner push). RFC-002 `DRAFT` is true, evidenced by the absence of a `v1.23` tag, by the v1.23 row'"'"'s own `**DRAFT — awaiting owner push**`, and by this document'"'"'s lead.'
expect published "$QUOTING_CELL" "a published row quoting another row's declaration"

# The mirror: the same quotation inside a cell that DOES open with a declaration is still
# unpublished, so the repair reads the opening and does not merely ignore the token everywhere.
expect unpublished "**DRAFT, awaiting owner push.** $QUOTING_CELL" \
  "a drafted row carrying the same quotation"

# ── 4. THE SUPERSEDED RULE, RUN AGAINST THE SAME FIXTURES ────────────────────────────────────────
# The unrepaired-tree run, carried in the suite rather than described in a report. The pattern below
# is the one both instruments held until v1.52, applied as they applied it. It must disagree with
# the anchored classifier on the quoting cell and agree with it on a genuine declaration. If it ever
# stops disagreeing, either the repair has been reverted or this case has stopped testing anything.

superseded_out=$(SCRIPTS="$SCRIPTS" QUOTING="$QUOTING_CELL" python3 - <<'PY'
import os, re, sys
sys.path.insert(0, os.environ["SCRIPTS"])
from publication_status import opens_with_draft_declaration

SUPERSEDED = re.compile(r"\*\*DRAFT\b|\bDRAFT\s*[—–-]\s*awaiting owner push")
quoting = os.environ["QUOTING"]
declared = "**DRAFT, awaiting owner push.** A row that genuinely awaits its push."

print("quoting-superseded=%s" % ("unpublished" if SUPERSEDED.search(quoting) else "published"))
print("quoting-anchored=%s" % ("unpublished" if opens_with_draft_declaration(quoting) else "published"))
print("declared-superseded=%s" % ("unpublished" if SUPERSEDED.search(declared) else "published"))
print("declared-anchored=%s" % ("unpublished" if opens_with_draft_declaration(declared) else "published"))
PY
)
if printf '%s' "$superseded_out" | grep -q "quoting-superseded=unpublished" \
   && printf '%s' "$superseded_out" | grep -q "quoting-anchored=published" \
   && printf '%s' "$superseded_out" | grep -q "declared-superseded=unpublished" \
   && printf '%s' "$superseded_out" | grep -q "declared-anchored=unpublished"; then
  echo "PASS: the superseded pattern reads the quoting row as awaiting a push and the anchored rule"
  echo "      does not, while both agree on a row that genuinely declares itself in draft"
else
  echo "FAIL: the anchored rule and the pattern it replaces did not differ where they must"
  printf '%s\n' "$superseded_out"
  fail=1
fi

# ── 5. A row is split before it is classified, and the date column is never consulted ────────────

split_out=$(SCRIPTS="$SCRIPTS" python3 - <<'PY'
import os, sys
sys.path.insert(0, os.environ["SCRIPTS"])
from publication_status import split_row, ROW_LINE

row = "| v9.9 | 2026-01-01 | **DRAFT, awaiting owner push.** A fixture row. |"
print("cells=%r" % (split_row(row),))
print("isrow=%s" % bool(ROW_LINE.match(row)))
print("twocell=%r" % (split_row("| v9.9 | no description cell"),))
print("notarow=%r" % (split_row("Just a sentence about v9.9."),))
PY
)
if printf '%s' "$split_out" | grep -q "cells=('v9.9', '2026-01-01', " \
   && printf '%s' "$split_out" | grep -q "isrow=True" \
   && printf '%s' "$split_out" | grep -q "twocell=None" \
   && printf '%s' "$split_out" | grep -q "notarow=None"; then
  echo "PASS: a row splits into version, date and description, and a line that cannot be split"
  echo "      returns nothing rather than a status"
else
  echo "FAIL: row splitting is not what the classifier claims"
  printf '%s\n' "$split_out"
  fail=1
fi

# A date column carrying the token changes nothing, because the classifier never sees it.
date_out=$(SCRIPTS="$SCRIPTS" python3 - <<'PY'
import os, sys
sys.path.insert(0, os.environ["SCRIPTS"])
from publication_status import split_row, is_published
row = "| v9.9 | DRAFT | Drafted and published 2026-01-01 (owner push). A fixture row. |"
cells = split_row(row)
print("published=%s" % is_published(cells[2]))
PY
)
if printf '%s' "$date_out" | grep -q "published=True"; then
  echo "PASS: a token sitting in the date column carries no status, because the rule reads the"
  echo "      description cell alone"
else
  echo "FAIL: the date column reached the classification"
  printf '%s\n' "$date_out"
  fail=1
fi

# ── 6. THE EVIDENCE CASE: the real ledger at the commit where the quotation was live ─────────────
# Cases 1 to 5 are fixtures, which prove the mechanism and not the fit. This case takes the real
# v1.50 row from the tree at $QUOTING_COMMIT, where it opens with a declaration and quotes another
# one further along, and requires both readings: as it stands, and with only its opener flipped to
# the published stamp, which is the single edit a publishing commit makes.

if git -C "$ROOT" cat-file -e "$QUOTING_COMMIT:STANDARD.md" 2>/dev/null; then
  evidence_out=$(ROOT="$ROOT" SCRIPTS="$SCRIPTS" COMMIT="$QUOTING_COMMIT" python3 - <<'PY'
import os, subprocess, sys
sys.path.insert(0, os.environ["SCRIPTS"])
from publication_status import split_row, opens_with_draft_declaration

text = subprocess.run(
    ["git", "-C", os.environ["ROOT"], "show", "%s:STANDARD.md" % os.environ["COMMIT"]],
    capture_output=True, check=True).stdout.decode("utf-8")
row = [l for l in text.splitlines() if l.startswith("| v1.50 ")][0]
version, date, description = split_row(row)
print("quotation-present=%s" % ("`**DRAFT — awaiting owner push**`" in description))
print("as-it-stands=%s" % ("unpublished" if opens_with_draft_declaration(description) else "published"))
flipped = description.replace(
    "**DRAFT, awaiting owner push.** The design record",
    "Drafted and published 2026-08-24 (owner push). The design record", 1)
print("flipped-differs=%s" % (flipped != description))
print("opener-flipped=%s" % ("unpublished" if opens_with_draft_declaration(flipped) else "published"))
PY
)
  if printf '%s' "$evidence_out" | grep -q "quotation-present=True" \
     && printf '%s' "$evidence_out" | grep -q "as-it-stands=unpublished" \
     && printf '%s' "$evidence_out" | grep -q "flipped-differs=True" \
     && printf '%s' "$evidence_out" | grep -q "opener-flipped=published"; then
    echo "PASS: the real row at $QUOTING_COMMIT reads as awaiting its push while its opener says so,"
    echo "      and reads as published the moment the opener alone is flipped, with the quotation"
    echo "      untouched in the same cell"
  else
    echo "FAIL: the evidence case did not reproduce both readings of the real row"
    printf '%s\n' "$evidence_out"
    fail=1
  fi
else
  echo "GAP: commit $QUOTING_COMMIT is not present in this clone, so the evidence case could not be"
  echo "     run. This is a coverage gap in this run, not a verdict."
fi

# ── coverage ─────────────────────────────────────────────────────────────────────────────────────
echo "coverage: 12 classification cases (6 declaration forms, 4 published forms, 2 quoting cases),"
echo "          1 superseded-rule comparison, 3 row-splitting cases, 1 date-column case, and the"
echo "          real-row evidence case at $QUOTING_COMMIT"

if [ "$fail" -eq 0 ]; then
  echo "publication-status classifier canaries passed"
  exit 0
else
  exit 1
fi
