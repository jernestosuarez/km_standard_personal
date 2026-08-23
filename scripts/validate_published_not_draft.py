#!/usr/bin/env python3
"""Fail when STANDARD.md marks a section as drafted-and-unpublished for a version the
version-history table records as published.

WHY THIS EXISTS. The publish ritual flipped the frontmatter title, the H1, the lead paragraph, the
version-history row, `README.md` and the badge, and never the section bodies. So a section marked
`(added in vX.Y, drafted and unpublished)` while it was drafted kept that marking after the owner
pushed it. The standard's own convention says a section marked that way binds nothing until its own
owner push, so published text told a reader that binding sections carried no obligation.

HOW THE PUBLISHED SET IS DERIVED. From the version-history table in the document under test, never
from a list held here. A row is unpublished only when its description opens with an explicit draft
declaration (`**DRAFT`, or `DRAFT - awaiting owner push`); every other row is published. Defaulting
an unrecognised row to published is the strict direction: it can raise a false alarm a maintainer
resolves by reading the row, and it can never let a stale marking through. Because the set comes
from the table, the check keeps working as versions publish, with no edit here.

HOW A MARKING IS ATTRIBUTED TO A VERSION. Markings and version identifiers are often on different
source lines ("remains drafted\\nand unpublished"), so the body is read in blocks of consecutive
non-blank lines, whitespace-joined, with blockquote markers stripped. A marking is judged only when
a version identifier sits close enough to it, and is attributed to the nearest one. The window is
asymmetric: BACK_WINDOW characters behind the phrase, FORWARD_WINDOW ahead of it, because a marking
either follows its version at a distance or is followed by it immediately, and a version turning up
in the next sentence is not what the marking is about.
Two kinds of text are deliberately not judged, are counted separately, and are reported:

  - TEMPLATE text, where the nearest identifier is a placeholder such as `vX.Y`. The publish ritual
    has to quote the marking it governs, and a quotation is not a status claim.
  - UNVERSIONED text, where no identifier sits within the window. The draft convention is stated in
    general terms in several places ("binds nothing until its own owner push"), and a general
    statement of the convention names no release and cannot be stale.

The cost of that choice is stated rather than hidden: a bare "binds nothing until its own owner
push" clause inside a section whose own heading is stale is not caught on its own. It is caught
through the heading, which is where the version is named.

FAIL CLOSED. The check exits 2, without a verdict about markings, when the file cannot be read, is
empty, carries no version-history heading, yields no parsable rows, records no published version at
all, records a version twice, or attributes a marking to a version the table does not record.

COVERAGE, STATED ON A PASSING RUN. The passing line names how many versions were classified and how
they split, how many markings were found and how they split between judged, template and
unversioned, and how many version-history rows were excluded from the body. A recorded pass that
does not state those numbers is void rather than clean.

LIMIT. This models one class: a publication-status claim in STANDARD.md contradicted by that
document's own version-history table. It reads one file, so the same class of stale marking in a
shipped skill, template, RFC or test header is out of its reach. It cannot audit the version-history
table itself, which is the only publication record the document has. And proving both directions
proves it fires on the class it models, never that it models the right class.
"""
import argparse
import re
import sys
from pathlib import Path

HISTORY_HEADING = re.compile(r"^#{1,6}\s+Version history\b")
HISTORY_ROW = re.compile(r"^\|\s*(v\d+\.\d+)\s*\|(.*)$")
DRAFT_ROW = re.compile(r"\*\*DRAFT\b|\bDRAFT\s*[—–-]\s*awaiting owner push")
VERSION_ID = re.compile(r"\bv\d+\.\d+\b")
PLACEHOLDER = re.compile(r"\bv[XN]\.[YMZ]\b")
BLOCK_PREFIX = re.compile(r"^[>\s]+")
MARKING = re.compile(
    r"drafted,?\s+and\s+unpublished"
    r"|\bunpublished\s+draft\b"
    r"|\bbinds?\s+nothing\s+until\b",
    re.IGNORECASE,
)
# How close a version identifier must sit to a marking for the marking to read as a status claim
# about that version. The windows are asymmetric because the forms are: in every real marking the
# version either precedes the phrase at some distance ("**v1.23** (stations, compartments, and the
# resolution plane) **remains drafted and unpublished**") or follows it immediately ("drafted and
# unpublished (v1.35)", "bind nothing until v1.39's own owner push"). A version that merely turns up
# in the next sentence is not what the marking is about, and a symmetric window swallowed exactly
# that case in the lead paragraph, where a general statement of the convention is followed by the
# current published version.
BACK_WINDOW = 80
FORWARD_WINDOW = 12


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def classify_versions(lines):
    """Return ({version: published?}, {line indexes of table rows}) from the version history."""
    heading_at = None
    for index, line in enumerate(lines):
        if HISTORY_HEADING.match(line):
            heading_at = index
            break
    if heading_at is None:
        raise FailClosed("no version-history heading found; the published set cannot be derived")

    published = {}
    row_lines = set()
    for index in range(heading_at + 1, len(lines)):
        match = HISTORY_ROW.match(lines[index])
        if not match:
            continue
        version, description = match.group(1), match.group(2)
        if version in published:
            raise FailClosed(
                "version %s appears twice in the version-history table; the table is ambiguous"
                % version
            )
        published[version] = not DRAFT_ROW.search(description)
        row_lines.add(index)

    if not published:
        raise FailClosed("the version-history table yielded no rows; nothing could be classified")
    if not any(published.values()):
        raise FailClosed("no version-history row reads as published; the table did not parse")
    return published, row_lines


def build_block(pairs):
    text_parts = []
    offsets = []
    position = 0
    for index, stripped in pairs:
        offsets.append((position, index + 1))
        text_parts.append(stripped)
        position += len(stripped) + 1
    return " ".join(text_parts), offsets


def blocks(lines, skip):
    """Yield (joined_text, [(offset, line_number), ...]) for each block of non-blank lines."""
    current = []
    for index, line in enumerate(lines):
        # Blockquote markers and indentation are stripped before joining: a marking is regularly
        # split across two quoted lines ("and binds\n> nothing until"), and leaving the ">" in the
        # joined text hides the phrase from the pattern, which looks exactly like clean text.
        stripped = BLOCK_PREFIX.sub("", line).rstrip()
        if index in skip or not stripped:
            if current:
                yield build_block(current)
                current = []
            continue
        current.append((index, stripped))
    if current:
        yield build_block(current)


def line_of(offsets, position):
    line_number = offsets[0][1]
    for offset, number in offsets:
        if offset <= position:
            line_number = number
        else:
            break
    return line_number


def gap_between(span, position, length):
    """Signed distance from a marking span to a candidate: negative when the candidate precedes."""
    if position + length <= span[0]:
        return -(span[0] - (position + length))
    if position >= span[1]:
        return position - span[1]
    return 0


def in_window(distance):
    if distance < 0:
        return -distance <= BACK_WINDOW
    return distance <= FORWARD_WINDOW


def check(path):
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read %s: %s" % (path, exc))
    if not text.strip():
        raise FailClosed("%s is empty; there was nothing to check" % path)

    lines = text.splitlines()
    published, row_lines = classify_versions(lines)

    violations = []
    gaps = []
    counts = {"total": 0, "judged": 0, "template": 0, "unversioned": 0}

    for block_text, offsets in blocks(lines, row_lines):
        candidates = [
            (m.start(), len(m.group(0)), m.group(0)) for m in VERSION_ID.finditer(block_text)
        ]
        candidates += [
            (m.start(), len(m.group(0)), None) for m in PLACEHOLDER.finditer(block_text)
        ]
        for marking in MARKING.finditer(block_text):
            counts["total"] += 1
            span = (marking.start(), marking.end())
            phrase = marking.group(0)
            line_number = line_of(offsets, marking.start())
            near = []
            for position, length, version in candidates:
                distance = gap_between(span, position, length)
                if in_window(distance):
                    near.append((abs(distance), version))
            if not near:
                counts["unversioned"] += 1
                continue
            version = min(near, key=lambda item: item[0])[1]
            if version is None:
                counts["template"] += 1
                continue
            if version not in published:
                gaps.append(
                    "line %d: marking %r attributed to %s, which the version-history table does "
                    "not record" % (line_number, phrase, version)
                )
                continue
            counts["judged"] += 1
            if published[version]:
                violations.append(
                    "line %d: %s is published, but this text still marks it %r"
                    % (line_number, version, phrase)
                )

    if gaps:
        raise FailClosed("; ".join(gaps))
    return published, counts, len(row_lines), violations


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "standard",
        nargs="?",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "STANDARD.md",
        help="path to the STANDARD.md under test",
    )
    args = parser.parse_args()

    try:
        published, counts, rows, violations = check(args.standard)
    except FailClosed as exc:
        print("REFUSED published-not-draft: %s" % exc, file=sys.stderr)
        return 2

    if violations:
        print(
            "STALE DRAFT MARKINGS in %s: %d marking(s) claim a published version is unpublished"
            % (args.standard, len(violations)),
            file=sys.stderr,
        )
        for violation in violations:
            print("  %s" % violation, file=sys.stderr)
        print(
            "  Published text binds. Clear the draft parenthetical and any accompanying "
            '"binds nothing until its own owner push" clause, keeping the version attribution.',
            file=sys.stderr,
        )
        return 1

    published_count = sum(1 for value in published.values() if value)
    print(
        "PASS published-not-draft: %d versions classified from the version-history table "
        "(%d published, %d unpublished); %d draft marking(s) found in the body, %d judged against "
        "the table, %d template text naming no release, %d unversioned statements of the "
        "convention; %d version-history row(s) excluded from the body"
        % (
            len(published),
            published_count,
            len(published) - published_count,
            counts["total"],
            counts["judged"],
            counts["template"],
            counts["unversioned"],
            rows,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
