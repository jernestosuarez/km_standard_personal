#!/usr/bin/env python3
# km-unrepaired-tree: v1.42 | run against the repository at 40f3829 before the repair, where it fails and names 15 real stale draft markings across five files; proved in both directions by tests/test_published_not_draft.sh.
"""Fail when any governed surface marks material as drafted-and-unpublished for a version the
STANDARD.md version-history table records as published.

published-not-draft-exempt: the instrument's own docstring quotes real markings to define them.
Scanning this file would report its own definitions as violations of itself.

WHY THIS EXISTS. The publish ritual flipped the frontmatter title, the H1, the lead paragraph, the
version-history row, `README.md` and the badge, and never the section bodies or the shipped files a
version touched. So material marked `(added in vX.Y, drafted and unpublished)` while it was drafted
kept that marking after the owner pushed it. The standard's own convention says material marked that
way binds nothing until its own owner push, so published text told a reader that binding obligations
carried none. The shipped surfaces matter most: a skill, a template registry, or a hub scan carrying
the false claim installs it into a deployment.

ONE HOME OF RECORD. Publication status is read from the version-history table of `STANDARD.md` and
from nowhere else, then applied to every scanned file. A row is unpublished only when its description
opens with an explicit draft declaration (`**DRAFT`, or `DRAFT - awaiting owner push`); every other
row is published. Defaulting an unrecognised row to published is the strict direction: it can raise a
false alarm a maintainer resolves by reading the row, and it can never let a stale marking through.
Because the set comes from the table, the check keeps working as versions publish, with no edit here.

WHAT IS IN SCOPE. Every file with a scanned suffix under the roots in SCAN_ROOTS: the standard
itself, the README, the shipped skills, the hub template, the components, the agent contracts, the
architecture docs, the scripts, the tools, and the tests. The boundary is declared here rather than
left implicit, and the passing line reports how many files were actually read.

WHAT IS OUT OF SCOPE, AND WHY.
  - `rfcs/` is not scanned. An RFC is a dated design record that states what the standard's status
    was when the ruling was captured, so freezing its prose to current publication status would
    falsify the record rather than repair it. It is design input, not a surface a deployment
    installs.
  - `outputs/` and `work/` are excluded everywhere, as the deployment profile requires.
  - A file may exempt itself with a line reading `published-not-draft-exempt: <reason>` in its first
    EXEMPT_SCAN_LINES lines. The exemption exists for the instrument's own fixtures and docstrings,
    which quote markings by construction and would otherwise make every fixture a violation. An
    exemption with no reason is refused, and every exempt file is named with its reason on the
    passing run, so no exclusion is silent.

HOW A MARKING IS ATTRIBUTED TO A VERSION. Markings and version identifiers are often on different
source lines ("remains drafted\nand unpublished"), so each file is read in blocks of consecutive
non-blank lines, whitespace-joined, with blockquote and comment markers stripped. A marking is judged
only when a version identifier sits close enough to it, and is attributed to the nearest one. The
window is asymmetric, BACK_WINDOW characters behind the phrase and FORWARD_WINDOW ahead of it,
because a marking either follows its version at a distance or is followed by it immediately, and a
version turning up in the next sentence is not what the marking is about. Two kinds of text are not
judged, are counted separately, and are reported:

  - TEMPLATE text, where the nearest identifier is a placeholder such as `vX.Y`. The publish ritual
    has to quote the marking it governs, and a quotation is not a status claim.
  - UNVERSIONED text, where no identifier sits within the window. The convention is stated in general
    terms in several places ("binds nothing until its own owner push"), and a general statement names
    no release and cannot be stale.

The cost of that choice is stated rather than hidden: a bare "binds nothing until its own owner push"
clause inside a section whose own heading is stale is not caught on its own. It is caught through the
heading, which is where the version is named.

FAIL CLOSED. The check exits 2, without a verdict about markings, when `STANDARD.md` cannot be read
or is empty, when it carries no version-history heading, when the table yields no rows or no
published row, when a version is recorded twice, when a scanned file cannot be decoded, when an
exemption declares no reason, when no file was scanned at all, or when any marking is attributed to
a version the table does not record.

COVERAGE, STATED ON A PASSING RUN. The passing line names how many versions were classified and how
they split, how many files were scanned and how many were exempt, and how many markings were found
and how they divide between judged, template and unversioned. A recorded pass that does not state
those numbers is void rather than clean.

LIMIT. This models one class: a publication-status claim contradicted by the standard's own
version-history table. It cannot audit that table, which is the only publication record the
repository has. And proving both directions proves it fires on the class it models, never that it
models the right class.
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
BLOCK_PREFIX = re.compile(r"^[>#\s]*[>#]\s*|^\s+")
EXEMPT = re.compile(r"published-not-draft-exempt:\s*(.*)$")
MARKING = re.compile(
    r"drafted,?\s+and\s+unpublished"
    r"|\bunpublished\s+draft\b"
    r"|\bbinds?\s+nothing\s+until\b",
    re.IGNORECASE,
)

# The governed surface this check covers. Declared here so the boundary is readable, and reported on
# every run so a pass states what it actually looked at.
SCAN_ROOTS = (
    "STANDARD.md",
    "README.md",
    "agents",
    "components",
    "contracts",
    "docs",
    "scripts",
    "skills",
    "template",
    "tests",
    "tools",
)
SUFFIXES = (".md", ".sh", ".py", ".toml", ".yaml", ".yml", ".json", ".txt")
SKIP_DIRS = {".git", "openspec", "outputs", "work", "node_modules", "__pycache__", ".venv"}
EXEMPT_SCAN_LINES = 60
HOME_OF_RECORD = "STANDARD.md"

# How close a version identifier must sit to a marking for the marking to read as a status claim
# about that version. Wide enough behind for "**v1.23** (stations, compartments, and the resolution
# plane) **remains drafted and unpublished**", narrow ahead so that a version named in the next
# sentence does not capture a general statement of the convention.
BACK_WINDOW = 80
FORWARD_WINDOW = 12


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def read_lines(path):
    try:
        return path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read %s: %s" % (path, exc))


def history_row_lines(lines):
    """Line indexes of version-history rows, which narrate draft history legitimately."""
    rows = set()
    for index, line in enumerate(lines):
        if HISTORY_HEADING.match(line):
            for later in range(index + 1, len(lines)):
                if HISTORY_ROW.match(lines[later]):
                    rows.add(later)
            break
    return rows


def classify_versions(lines, source):
    """Return {version: published?} read from the version-history table of the home of record."""
    heading_at = None
    for index, line in enumerate(lines):
        if HISTORY_HEADING.match(line):
            heading_at = index
            break
    if heading_at is None:
        raise FailClosed(
            "no version-history heading in %s; the published set cannot be derived" % source
        )

    published = {}
    for index in range(heading_at + 1, len(lines)):
        match = HISTORY_ROW.match(lines[index])
        if not match:
            continue
        version, description = match.group(1), match.group(2)
        if version in published:
            raise FailClosed(
                "version %s appears twice in the version-history table of %s; the table is "
                "ambiguous" % (version, source)
            )
        published[version] = not DRAFT_ROW.search(description)

    if not published:
        raise FailClosed(
            "the version-history table of %s yielded no rows; nothing could be classified" % source
        )
    if not any(published.values()):
        raise FailClosed(
            "no version-history row in %s reads as published; the table did not parse" % source
        )
    return published


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
        # Blockquote markers, shell comment markers and indentation are stripped before joining: a
        # marking is regularly split across two quoted or commented lines ("and binds\n> nothing
        # until"), and leaving the marker in the joined text hides the phrase from the pattern,
        # which looks exactly like clean text.
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


def exemption(lines):
    """Return the declared exemption reason, or None. An empty reason is refused by the caller."""
    for line in lines[:EXEMPT_SCAN_LINES]:
        match = EXEMPT.search(line)
        if match:
            return match.group(1).strip().rstrip("'\"`")
    return None


def collect(root, explicit):
    if explicit:
        return sorted(Path(item).resolve() for item in explicit)
    found = []
    for entry in SCAN_ROOTS:
        target = root / entry
        if target.is_file():
            found.append(target)
            continue
        if not target.is_dir():
            continue
        for path in sorted(target.rglob("*")):
            if not path.is_file() or path.suffix not in SUFFIXES:
                continue
            if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
                continue
            found.append(path)
    return found


def scan_file(path, lines, published, label):
    violations = []
    gaps = []
    counts = {"total": 0, "judged": 0, "template": 0, "unversioned": 0}
    skip = history_row_lines(lines)

    for block_text, offsets in blocks(lines, skip):
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
                    "%s:%d: marking %r attributed to %s, which the version-history table does not "
                    "record" % (label, line_number, phrase, version)
                )
                continue
            counts["judged"] += 1
            if published[version]:
                violations.append(
                    "%s:%d: %s is published, but this text still marks it %r"
                    % (label, line_number, version, phrase)
                )
    return counts, violations, gaps


def check(root, explicit):
    home = root / HOME_OF_RECORD
    home_lines = read_lines(home)
    if not [line for line in home_lines if line.strip()]:
        raise FailClosed("%s is empty; there was nothing to check" % home)
    published = classify_versions(home_lines, HOME_OF_RECORD)

    files = collect(root, explicit)
    if not files:
        raise FailClosed("no file was scanned; the scope resolved to nothing")

    totals = {"total": 0, "judged": 0, "template": 0, "unversioned": 0}
    violations = []
    gaps = []
    exempt = []
    scanned = 0

    for path in files:
        try:
            label = str(path.relative_to(root))
        except ValueError:
            label = str(path)
        lines = home_lines if path == home else read_lines(path)
        reason = exemption(lines)
        if reason is not None:
            if not reason:
                raise FailClosed(
                    "%s declares a published-not-draft exemption with no reason" % label
                )
            exempt.append((label, reason))
            continue
        scanned += 1
        counts, file_violations, file_gaps = scan_file(path, lines, published, label)
        for key in totals:
            totals[key] += counts[key]
        violations.extend(file_violations)
        gaps.extend(file_gaps)

    if gaps:
        raise FailClosed("; ".join(gaps))
    if scanned == 0:
        raise FailClosed("every file in scope declared an exemption; nothing was evaluated")
    return published, scanned, exempt, totals, violations


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root holding STANDARD.md and the governed surfaces",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="optional explicit files to scan instead of the declared scope",
    )
    args = parser.parse_args()
    root = args.root.resolve()

    try:
        published, scanned, exempt, totals, violations = check(root, args.paths)
    except FailClosed as exc:
        print("REFUSED published-not-draft: %s" % exc, file=sys.stderr)
        return 2

    if violations:
        print(
            "STALE DRAFT MARKINGS: %d marking(s) claim a published version is unpublished"
            % len(violations),
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
        "PASS published-not-draft: %d versions classified from the version-history table of %s "
        "(%d published, %d unpublished); %d file(s) scanned across the declared governed surface, "
        "%d exempt by declaration; %d draft marking(s) found, %d judged against the table, "
        "%d template text naming no release, %d unversioned statements of the convention"
        % (
            len(published),
            HOME_OF_RECORD,
            published_count,
            len(published) - published_count,
            scanned,
            len(exempt),
            totals["total"],
            totals["judged"],
            totals["template"],
            totals["unversioned"],
        )
    )
    for label, reason in exempt:
        print("  exempt: %s (%s)" % (label, reason))
    print("  out of scope by declaration: rfcs/ (dated design records, not an installed surface)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
