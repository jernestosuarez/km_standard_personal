#!/usr/bin/env python3
# km-unrepaired-tree: v1.52 | re-stated for the anchoring repair. Run against the tree at 1444b15 with the v1.50 row's opener flipped to its published stamp, the state the v1.50 publish was measured in, the unrepaired check reports "2 excluded as drafted: v1.23, v1.50" and exits 0, never comparing v1.50's date column, because the row quotes another row's declaration mid-description. The repaired check reports 1 excluded, compares v1.50 and resolves it by tag. The v1.47 run this declaration replaces still holds: against a2756e2 the check fails and names both real disagreements, v1.33 claiming 2026-08-20 against 16109ea authored 2026-08-21 and v1.40 claiming 2026-08-22 against 9c14f85 authored 2026-08-23, and case 9 still asserts it. Both directions in tests/test_ledger_dates.sh.
"""Fail when a version-history row's date column disagrees with the commit that published it.

WHY THIS EXISTS. The version-history table of `STANDARD.md` is this repository's only record of when
a version was published, and two of its rows stated a day on which nothing happened. `v1.40` claimed
2026-08-22 in its date column and its stamp, while its draft commit, its publish commit and the
overlay re-pin that adopted it were all on 2026-08-23: a staging brief carried the previous day's
date, the session ran past midnight, and nobody re-derived the date from the tree. `v1.33` claimed
2026-08-20 while its publish commit, its commit subject and its tag all read 2026-08-21: the
publishing commit derived the stamp and left the date column at the draft date, so the row
contradicted itself in published text. A false date in a version-history row is a false statement in
published text. Nothing in this repository had ever opened that column.

WHAT IS COMPARED. One thing: the row's date column against the author date of the commit that
published that version. The stamp inside the row's description is deliberately not parsed; see LIMIT.

THE MAPPING IS DERIVED, NEVER HELD HERE. There is no table of versions, commits or dates in this
file. A version resolves to its publish commit through the repository, in two ways, and which one
resolved it is reported:
  - An ANNOTATED TAG bearing the version identifier. This is the strongest evidence: someone
    performed a deliberate act naming that version and pointing it at one commit.
  - A COMMIT SUBJECT that opens with the version identifier and a colon, for versions published
    before this repository began tagging. A subject naming a draft never resolves as a publication.
    Where a subject search returns candidates that disagree about the date, the version is reported
    unresolved and AMBIGUOUS rather than resolved to either of them.
A mapping written into this file would be a date held in a document instead of derived from the tree,
which is the artifact class this check exists to remove.

THE TIMEZONE IS THE COMMIT'S OWN, AND THIS IS THE DECISION THE CHECK TURNS ON. The author date is
read as git records it, in the offset the commit itself carries, never normalised to UTC and never
shifted into the reader's locale. The v1.33 publish commit is 2026-08-21 00:24:40 +0200; in UTC it is
2026-08-20, and a check comparing UTC would have certified the false row as correct. A publication is
an act a person performed on a day, and the day is the one in the offset they were in.

THREE OUTCOMES, KEPT APART. Folding any two of these together produces a wrong instrument.
  - EXCLUDED: the row declares itself still in draft. The rule that decides that is not in this
    file: it is `publication_status.py`, which `validate_published_not_draft.py` reads as well, so
    publication status has one home of record in fact and not only in intent. A version awaiting its
    push has no publish commit by construction; reporting it as a gap would be a gap that can never
    close, and a permanent false gap trains a reader to stop reading gaps. The rule is ANCHORED: a
    row is excluded when its DESCRIPTION CELL OPENS WITH a declaration, and a declaration reproduced
    further along the same cell is a quotation. Until v1.52 this file held its own copy of the rule
    and searched the token anywhere in the description, so the v1.50 row, which evidenced a statement
    by reproducing the v1.23 row's declaration verbatim, was excluded from date comparison after its
    own opener had been flipped to a published stamp. This check reported "2 excluded as drafted" and
    exited 0 over a version whose date it had never opened.
  - UNRESOLVED: no tag and no subject resolves it. This is a STRUCTURAL coverage gap, not a pass and
    not a failure. The ledger runs back to v1.0 and tagging began at v1.22, and four further versions
    were published inside a later version's train and have no commit of their own. It is reported on
    every run, including a passing one, and the versions are named. Attributing one of them to the
    train's commit would be this check inventing the evidence it was written to demand.
  - COMPARED: everything else.

FAIL CLOSED. The check exits 2, without a verdict about dates, when the ledger cannot be read, when
the version-history heading cannot be found, when the table yields no version row, when a row cannot
be parsed into a version and a date, when git cannot be executed or returns an error, or when no
version at all resolved to a publish commit. An unread table is not a clean one, and an empty
resolution set looks exactly like a repository in which every date agrees.

COVERAGE, STATED ON A PASSING RUN. The passing line names rows read, versions resolved by tag,
resolved by subject search, excluded as drafted, and unresolved, and the unresolved and excluded ones
are named rather than counted only. A recorded pass that does not state those numbers is void rather
than clean.

LIMIT. This models one class: a date column that disagrees with the commit that published the
version. It says nothing about whether the stamp inside a row's prose is right, whether the row
describes what the version did, whether the resolved commit is the right commit, or whether a version
was published and given no row at all. The stamp is excluded on purpose: it is written in several
prose forms across the ledger's history, and parsing those would be a prose validator with a much
larger false-positive surface. That cost is real, and it is exactly the half of the v1.33 row that
happened to be correct. The ritual answers it rather than this file: both fields are derived from the
same commit in the same act, so they cannot disagree unless someone edits one alone. Proving both
directions proves this check fires on the class it models, never that it models the right class.
"""
import argparse
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from publication_status import (  # noqa: E402  the path is set immediately above
    HISTORY_HEADING,
    opens_with_draft_declaration,
    split_row,
)

ANY_HEADING = re.compile(r"^#{1,6}\s")
SEPARATOR_ROW = re.compile(r"^\|[\s:|-]+$")
HEADER_ROW = re.compile(r"^\|\s*Version\s*\|", re.I)
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
DRAFT_SUBJECT = re.compile(r"\(draft\)", re.I)

UNIT = "\x1f"


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def git(root, args):
    try:
        proc = subprocess.run(
            ["git", "-C", str(root)] + list(args), capture_output=True
        )
    except OSError as exc:
        raise FailClosed("git could not be executed: %s" % exc)
    if proc.returncode != 0:
        raise FailClosed(
            "git %s failed in %s (%s); an unread repository is not an empty one"
            % (args[0], root, proc.stderr.decode("utf-8", "replace").strip())
        )
    return proc.stdout.decode("utf-8", "replace")


def read_rows(ledger):
    """Parse the version-history table. Refuse rather than skip anything unparsable."""
    try:
        lines = ledger.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read the ledger %s: %s" % (ledger, exc))

    start = None
    for number, line in enumerate(lines):
        if HISTORY_HEADING.match(line):
            start = number + 1
            break
    if start is None:
        raise FailClosed(
            "no version-history heading was found in %s; the table the verdict is drawn from could "
            "not be located" % ledger
        )

    rows = []
    for number in range(start, len(lines)):
        line = lines[number]
        if ANY_HEADING.match(line):
            break
        if not line.startswith("|"):
            continue
        if SEPARATOR_ROW.match(line) or HEADER_ROW.match(line):
            continue
        cells = split_row(line)
        if cells is None:
            raise FailClosed(
                "%s:%d: a table row could not be parsed into a version and a date: %r"
                % (ledger.name, number + 1, line[:80])
            )
        version, date, rest = cells
        if not DATE.match(date):
            raise FailClosed(
                "%s:%d: row %s has %r in its date column, which is not a date; a row that cannot be "
                "read is not a row that agrees" % (ledger.name, number + 1, version, date)
            )
        rows.append((version, date, rest, number + 1))

    if not rows:
        raise FailClosed(
            "the version-history table in %s yielded no version row; an empty table is not a clean "
            "one" % ledger
        )
    return rows


def tag_commits(root):
    """{tag name: commit sha} for every tag in the repository."""
    out = git(root, ["for-each-ref", "--format=%(refname:short)" + UNIT + "%(objectname)",
                     "refs/tags"])
    found = {}
    for line in out.splitlines():
        if UNIT not in line:
            continue
        name, _ = line.split(UNIT, 1)
        peeled = git(root, ["rev-parse", "--verify", "--quiet", name + "^{commit}"]).strip()
        if peeled:
            found[name.strip()] = peeled
    return found


def subject_index(root):
    """[(sha, author date, subject)] over every reachable commit, read once."""
    out = git(root, ["log", "--all", "--no-merges", "--date=short",
                     "--format=%H" + UNIT + "%ad" + UNIT + "%s"])
    entries = []
    for line in out.splitlines():
        parts = line.split(UNIT, 2)
        if len(parts) != 3:
            continue
        entries.append((parts[0], parts[1], parts[2]))
    if not entries:
        raise FailClosed("git log returned no commit; the repository could not be read")
    return entries


def author_date(root, sha):
    """The author date in the offset the commit itself records. Never UTC, never the reader's."""
    out = git(root, ["log", "-1", "--date=short", "--format=%ad", sha]).strip()
    if not DATE.match(out):
        raise FailClosed("the author date of %s could not be read as a date (%r)" % (sha[:7], out))
    return out


def resolve(root, version, tags, subjects):
    """(sha, date, method) or (None, None, reason). Tag first, then the subject search."""
    if version in tags:
        sha = tags[version]
        return sha, author_date(root, sha), "tag"

    opener = re.compile(r"^%s\s*:" % re.escape(version))
    candidates = [
        (sha, date, subject)
        for sha, date, subject in subjects
        if opener.match(subject) and not DRAFT_SUBJECT.search(subject)
    ]
    if not candidates:
        return None, None, "no tag bears this version and no commit subject opens with it"
    dates = set(date for _, date, _ in candidates)
    if len(dates) > 1:
        return None, None, (
            "ambiguous: %d commit subjects open with this version and they disagree about the date "
            "(%s)" % (len(candidates), ", ".join(sorted(dates)))
        )
    sha, date, _ = candidates[-1]
    return sha, date, "subject"


def check(root, ledger):
    rows = read_rows(ledger)
    tags = tag_commits(root)
    subjects = subject_index(root)

    compared = []
    disagreements = []
    excluded = []
    unresolved = []
    by_method = {"tag": 0, "subject": 0}

    for version, date, rest, line_number in rows:
        # The status rule lives in publication_status.py and reads the opening of the description.
        # Searching the whole description is what excluded a published version from comparison
        # because its row quoted another row's declaration; see THREE OUTCOMES above.
        if opens_with_draft_declaration(rest):
            excluded.append((version, date))
            continue
        sha, commit_date, method = resolve(root, version, tags, subjects)
        if sha is None:
            unresolved.append((version, date, method))
            continue
        by_method[method] += 1
        compared.append((version, date, commit_date, sha, method))
        if date != commit_date:
            disagreements.append(
                "%s:%d: %s claims %s in its date column and its publish commit %s is authored "
                "%s (resolved by %s)"
                % (ledger.name, line_number, version, date, sha[:7], commit_date, method)
            )

    if not compared:
        raise FailClosed(
            "%d row(s) were read and no version resolved to a publish commit; a verdict drawn from "
            "an empty resolution set is drawn from nothing" % len(rows)
        )
    return rows, compared, disagreements, excluded, unresolved, by_method


def print_coverage(rows, compared, excluded, unresolved, by_method, stream):
    print(
        "  coverage: %d row(s) read, %d compared (%d resolved by tag, %d by subject search), "
        "%d excluded as drafted, %d unresolved"
        % (len(rows), len(compared), by_method["tag"], by_method["subject"],
           len(excluded), len(unresolved)),
        file=stream,
    )
    if excluded:
        print(
            "  excluded (the ledger declares them drafted, so they have no publish commit): %s"
            % ", ".join(version for version, _ in excluded),
            file=stream,
        )
    if unresolved:
        print(
            "  COVERAGE GAP: %d version(s) have no resolvable publish commit and were neither "
            "passed nor failed: %s"
            % (len(unresolved), ", ".join(version for version, _, _ in unresolved)),
            file=stream,
        )
        print(
            "  The ledger runs back to v1.0 and tagging began at v1.22; some versions published "
            "inside a later version's commit and have none of their own. This gap is structural.",
            file=stream,
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    default_root = Path(__file__).resolve().parent.parent
    parser.add_argument(
        "--root",
        type=Path,
        default=default_root,
        help="repository whose tags and commit subjects the mapping is derived from",
    )
    parser.add_argument(
        "--ledger",
        type=Path,
        default=None,
        help="the markdown file holding the version-history table (default: <root>/STANDARD.md)",
    )
    args = parser.parse_args()
    root = args.root.resolve()
    ledger = (args.ledger if args.ledger is not None else root / "STANDARD.md").resolve()

    try:
        rows, compared, disagreements, excluded, unresolved, by_method = check(root, ledger)
    except FailClosed as exc:
        print("REFUSED ledger-date-integrity: %s" % exc, file=sys.stderr)
        return 2

    if disagreements:
        print(
            "LEDGER DATE DISAGREEMENT: %d version-history row(s) name a date their publish commit "
            "does not support" % len(disagreements),
            file=sys.stderr,
        )
        for item in disagreements:
            print("  %s" % item, file=sys.stderr)
        print(
            "  A version-history row is this repository's only publication record. Derive the date "
            "from the publishing commit; do not carry it in from a brief or a prior field.",
            file=sys.stderr,
        )
        print_coverage(rows, compared, excluded, unresolved, by_method, sys.stderr)
        return 1

    print(
        "PASS ledger-date-integrity: every compared version-history row agrees with its publish "
        "commit's author date, read in the commit's own recorded offset"
    )
    print_coverage(rows, compared, excluded, unresolved, by_method, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
