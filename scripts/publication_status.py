#!/usr/bin/env python3
# km-unrepaired-tree: v1.52 | run against the tree at 1444b15 with the v1.50 row's opener flipped to its published stamp, which is the state the v1.50 publish was measured in: the pattern this classifier replaces reads that row as still in draft, and both instruments built on it withdrew coverage while exiting 0 (validate_ledger_dates reporting "2 excluded as drafted: v1.23, v1.50" and validate_published_not_draft reporting "49 published, 2 unpublished"). The anchored classifier reads the same row as published and leaves the genuinely drafted v1.23 alone. Proved in both directions by tests/test_publication_status_scope.sh.
# km-gate-instrument: tests/test_publication_status_scope.sh | this file is the shared classifier two checks import, not a check. Run with no arguments it would exit 0 whatever it contained, which is a check that cannot fail, so it declares itself here and names the canaries that prove it instead.
"""Where a version's publication status is declared, and what is only a quotation of a declaration.

ONE HOME OF RECORD FOR THE RULE. Two checks read publication status out of the version-history table
of `STANDARD.md`: `validate_published_not_draft.py`, which applies the status to draft markings
across the governed surface, and `validate_ledger_dates.py`, which excludes an unpublished version
from date comparison because such a version has no publish commit. They must never disagree about a
row. Until v1.52 each held its own copy of the rule, the two copies were byte-identical, and each
applied it to a different slice of the row, which is what a copied rule looks like just before it
diverges. The rule now lives here and neither check holds a pattern.

THE RULE. A row is unpublished when its DESCRIPTION CELL OPENS WITH a draft declaration: optional
whitespace, an optional run of emphasis markers, then the literal token `DRAFT` at a word boundary.
Anything else opening the cell reads as published.

WHY IT IS ANCHORED, AND THIS IS THE WHOLE OF v1.52. The earlier rule searched the token anywhere in
the row. The v1.50 row argued that another design record's `DRAFT` banner was true and evidenced it
by reproducing the v1.23 row's declaration verbatim, mid-description. Once v1.50's own opener was
flipped to its published stamp, that quotation went on classifying v1.50 as a version awaiting its
push, so one check stopped comparing its date and the other stopped judging any marking that named
it, and both exited 0. Quoting the text a rule governs is ordinary practice here, in version rows, in
check docstrings and in canary fixtures, so the earlier rule was disarmed by house style rather than
by an unusual input.

WHAT "OPENS WITH" TOLERATES, DERIVED FROM THE ROWS THAT EXIST.
  unpublished  `**DRAFT — awaiting owner push.**`     the published convention, em dash form
  unpublished  `**DRAFT, awaiting owner push.**`      the same convention, comma form
  unpublished  `DRAFT - awaiting owner push`          the bare form
  published    `Drafted and published <date> (owner push).`
  published    `Drafted <date>; published <date> with <version>.`
Emphasis is presentation and is skipped; any other text before the token means the declaration is
not what the cell opens with. The token is matched in upper case, which is the only case the
convention or the ledger has ever used.

THE STRICT DIRECTION, STATED BECAUSE AN INSTRUMENT HAS TO BEHAVE SAFELY ON IT. An opener this rule
does not recognise classifies as published. In `validate_published_not_draft.py` that can raise a
false alarm a maintainer clears by reading the row, and can never let a stale marking through. In
`validate_ledger_dates.py` it sends the version to the resolver, where a version that never published
resolves to nothing and is named in the coverage gap. Neither instrument passes by that route.

WHAT THIS FILE DOES NOT DO. It does not read the table, walk a tree, or return a verdict; each check
does its own refusing and its own coverage reporting. And it cannot audit its oracle: a row opening
with a published stamp for a version nobody pushed is agreed with, which is a limit both checks
already state.
"""
import re

# The version-history table's own heading, so both checks locate the same table.
HISTORY_HEADING = re.compile(r"^#{1,6}\s+Version history\b")

# A line that is a version-history row. Deliberately loose: it answers "is this a row", which is a
# different question from "can this row be read", and a check that needs the second asks split_row.
ROW_LINE = re.compile(r"^\|\s*(v\d+\.\d+)\s*\|")

# A row split into version, date and description. The description is everything after the second
# cell boundary, so a description carrying pipes survives.
ROW_CELLS = re.compile(r"^\|\s*(v\d+\.\d+)\s*\|\s*([^|]*?)\s*\|(.*)$")

# The declaration, anchored. `[*_]{0,3}` covers `**DRAFT`, `*DRAFT` and `DRAFT`; the trailing word
# boundary is what keeps `Drafted and published` out, since the character after `DRAFT` there is a
# word character and no boundary exists at that point.
DRAFT_OPENER = re.compile(r"^\s*[*_]{0,3}\s*DRAFT\b")


def split_row(line):
    """(version, date, description) for a readable version-history row, or None.

    None means the line is not a row this rule can classify. It never means the row is published:
    the caller decides whether an unreadable row is a refusal, a skip, or a reported gap, because
    the two checks answer that differently and neither answer belongs here.
    """
    match = ROW_CELLS.match(line)
    if not match:
        return None
    return match.group(1), match.group(2), match.group(3)


def opens_with_draft_declaration(description):
    """True when this description cell opens with a draft declaration.

    A declaration further along the cell is a quotation and returns False. That is the repair.
    """
    return bool(DRAFT_OPENER.match(description))


def is_published(description):
    """The classification both checks read. Every opener that is not a declaration is published."""
    return not opens_with_draft_declaration(description)
