#!/usr/bin/env python3
# km-unrepaired-tree: v1.50 | run against published main at d0482ec, extracted from git rather than rebuilt, where it fails with 11 statements: seven RFCs present and no index covering any of them, three stale banners (RFC-004 against v1.35, RFC-006 against v1.39, RFC-007 against v1.41, each still reading 'no normative edits ride'), and the badge reading '2 adopted' while the ledger records three RFCs as implemented; proved in both directions by tests/test_rfc_lifecycle_index.sh.
"""Fail when the design record misdescribes its own disposition: an index that does not cover the
RFC directory, a status the version ledger contradicts, or a count surface the index does not
support.

rfc-reference-exempt: this instrument names identifiers only in the patterns that recognise them.
published-not-draft-exempt: this instrument quotes status wording to define what it matches.

WHY THIS EXISTS. Three surfaces in this repository spoke about RFC disposition and none of them had
a home of record behind it: a badge counted by hand, a package-overview paragraph written when there
were two RFCs, and seven status banners each maintained by whoever last touched that file. The badge
read `2 adopted` over seven RFCs while the version ledger recorded three of them as implemented in
its own words. RFC-004, RFC-006 and RFC-007 each still declared that no normative edits rode them,
while v1.35, v1.39 and v1.41 said in the ledger that they had implemented them. There was no index
at all, so a reader forking this repository had nowhere to learn which designs are live. That is
audit finding F-09.

WHAT IS DERIVED, AND FROM WHERE. Nothing here is held as a list.
  - The set of RFCs is derived by listing `rfcs/` and taking each identifier from the name of a file
    actually present. Adding, renaming or removing an RFC changes this check's answer with no edit.
  - What has been implemented is derived from the version-history table of `STANDARD.md`, from a row
    whose text binds an implementation verb to an RFC reference.
  - The count on the badge is derived from the index, by the same code that validates it. Run with
    `--write-badge` this file renders the badge; run any other way it asserts that the committed
    badge and the README `alt` text are exactly what it would render. So the count is regenerated
    rather than maintained, and a hand edit to either surface fails the release gate.
  - An index row's implementing versions are read from its fourth column and from nowhere else. A
    version named in a Notes cell is prose about history, and letting a mention satisfy a claim
    would make the arm pass on a word rather than on a declaration.

THE LEDGER DERIVATION IS A LOWER BOUND, AND SAYS SO. The ledger has never used one phrase for
adoption. The v1.22 row records RFC-001 as "Full rationale ... in `rfcs/RFC-001-...md`" and the v1.32
row records RFC-004 Part I as "designed in `rfcs/RFC-004`". Neither carries an implementation verb,
so neither is in the derived set. Widening the pattern until it caught them would also catch the
v1.45 row, which names an RFC while recounting a dangling reference and implements nothing. The
check therefore fires on a contradiction it can see and stays silent on an adoption the ledger never
claimed in those words; the passing line states the bound rather than leaving a reader to infer it.

HOW A STALE BANNER IS DETECTED. Prose cannot be diffed against truth, but a corrected banner has one
property a stale one lacks: it names the version that implemented the document. So for every RFC the
ledger claims a version implemented, that version's identifier must appear in the RFC's own status
banner, defined as the first run of blockquote lines after the H1. No particular wording is required,
the original sentence may stand, and the design body is never read. That is exactly the correction
pattern v1.45 established: leave the dated statement alone and add a dated note recording what has
happened since.

FAIL VERSUS REFUSE, AND THE DIFFERENCE MATTERS. An ABSENT index is a fully evaluated finding: the
directory was read, the RFCs were found, none is covered. That is the defect under repair and it is
reported as a failure naming every uncovered RFC. A PRESENT index that yields no parsable row, or one
carrying a status outside the declared vocabulary, is input the check could not evaluate, and it
refuses rather than reporting a coverage verdict it never actually computed.

FAIL CLOSED. The check exits 2, without a verdict about disposition, when `STANDARD.md` cannot be
read or carries no version-history table, when that table yields no row, when `rfcs/` is missing or
cannot be listed, when it yields no RFC, when a present index yields no parsable row, when an index
row declares a status outside the vocabulary, when the badge is missing or yields no message text,
and when `README.md` cannot be read or does not reference the badge.

COVERAGE, STATED ON A PASSING RUN. The passing line names how many RFCs are present and which, how
many index rows were read and how the statuses split, how many implementation claims were read from
the ledger, how many banners were verified against them, and the value derived for the badge. A
recorded pass that does not state those numbers is void rather than clean.

LIMIT. This models three classes: an index that does not cover its directory, a declared status the
version ledger contradicts, and a count surface the index does not support. It says nothing about
whether an index row describes a narrowing correctly, whether a design should have been implemented,
or whether an RFC that should exist was never written. Proving both directions proves it fires on the
classes it models, never that it models the right ones.
"""
import argparse
import re
import sys
from pathlib import Path

RFC_DIR = "rfcs"
INDEX_NAME = "README.md"
BADGE_REL = "assets/badges/rfcs.svg"
BADGE_LABEL = "rfcs"
ALT_PREFIX = "RFCs: "

# The identifier an RFC file's own name declares. `README.md` does not match, so the index is not
# mistaken for one of the documents it indexes.
FILENAME_ID = re.compile(r"^(RFC-\d+)-.*\.md$")
VERSION = re.compile(r"v\d+\.\d+")
# A version-history row: `| vX.Y | date | description |`.
LEDGER_ROW = re.compile(r"^\|\s*(v\d+\.\d+)\s*\|([^|]*)\|(.*)$")
VERSION_HISTORY_HEADING = re.compile(r"^#+\s+Version history", re.IGNORECASE)
# An implementation claim: an implementation verb bound to an RFC reference a few characters later.
# The window is short on purpose. A verb and a reference in the same long row are not a claim.
IMPLEMENTS = re.compile(r"implement(?:s|ing)\s+[`\[]{0,2}(?:rfcs/)?(RFC-\d+)")
# An index row: the first cell names an RFC, optionally as a link.
INDEX_ROW = re.compile(r"^\|\s*(?:\[)?\**\s*(RFC-\d+)\b")
H1 = re.compile(r"^#\s+\S")

STATUS_ADOPTED = "ADOPTED"
STATUS_PARTIAL = "PARTIALLY ADOPTED"
STATUS_DRAFT = "DRAFT"
STATUS_DESIGN = "DESIGN ONLY"
# The vocabulary is fixed and an unknown term is refused. A vocabulary anything can join is not one.
STATUSES = (STATUS_ADOPTED, STATUS_PARTIAL, STATUS_DRAFT, STATUS_DESIGN)
IMPLEMENTED_STATUSES = (STATUS_ADOPTED, STATUS_PARTIAL)


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def read_text(path, label):
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read %s: %s" % (label, exc))


# --- derivation: the RFC set, from the directory --------------------------------------------------


def existing_rfcs(root):
    """{identifier: filename}, derived by listing the directory. Never from a list held here."""
    directory = root / RFC_DIR
    if not directory.is_dir():
        raise FailClosed(
            "%s/ is missing or is not a directory; the set of RFCs could not be derived, so no "
            "disposition could be judged" % RFC_DIR
        )
    try:
        entries = sorted(directory.iterdir())
    except OSError as exc:
        raise FailClosed("%s/ could not be listed: %s" % (RFC_DIR, exc))
    found = {}
    for entry in entries:
        if not entry.is_file():
            continue
        match = FILENAME_ID.match(entry.name)
        if match:
            found.setdefault(match.group(1), entry.name)
    if not found:
        raise FailClosed(
            "%s/ holds no file naming an RFC; an empty set is not a verdict about the tree" % RFC_DIR
        )
    return found


# --- derivation: implementation claims, from the version ledger -----------------------------------


def ledger_claims(root, standard_rel):
    """(versions, claims) where claims maps identifier -> sorted list of versions claiming it."""
    text = read_text(root / standard_rel, standard_rel)
    lines = text.splitlines()
    start = None
    for number, line in enumerate(lines):
        if VERSION_HISTORY_HEADING.match(line):
            start = number
            break
    if start is None:
        raise FailClosed(
            "%s carries no version-history heading; the implementation facts have no other home of "
            "record" % standard_rel
        )
    versions = []
    claims = {}
    for line in lines[start:]:
        match = LEDGER_ROW.match(line)
        if not match:
            continue
        version = match.group(1)
        versions.append(version)
        for hit in IMPLEMENTS.finditer(match.group(3)):
            claims.setdefault(hit.group(1), [])
            if version not in claims[hit.group(1)]:
                claims[hit.group(1)].append(version)
    if not versions:
        raise FailClosed(
            "%s's version-history table yielded no row; a table that has stopped parsing looks "
            "exactly like a ledger claiming nothing" % standard_rel
        )
    return versions, claims


# --- derivation: the index ------------------------------------------------------------------------


def parse_index(root):
    """Return None when no index file exists, else {identifier: (status, [versions])}.

    Absent and unparsable are different states. Absent is a finding; unparsable is a refusal.
    """
    path = root / RFC_DIR / INDEX_NAME
    if not path.exists():
        return None
    text = read_text(path, "%s/%s" % (RFC_DIR, INDEX_NAME))
    rows = {}
    for line in text.splitlines():
        match = INDEX_ROW.match(line)
        if not match:
            continue
        identifier = match.group(1)
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 4:
            raise FailClosed(
                "%s/%s: the row for %s has fewer than four cells, so its status and its implementing "
                "versions could not both be read" % (RFC_DIR, INDEX_NAME, identifier)
            )
        status = re.sub(r"[`*_]", "", cells[2]).strip().upper()
        if status not in STATUSES:
            raise FailClosed(
                "%s/%s: the row for %s declares status %r, which is outside the vocabulary (%s)"
                % (RFC_DIR, INDEX_NAME, identifier, cells[2].strip(), ", ".join(STATUSES))
            )
        # Versions are read from the fourth column alone. A version named in a Notes cell is prose
        # about history, and letting it satisfy an implementation claim would make the arm pass on a
        # mention rather than on a declaration.
        versions = []
        for hit in VERSION.finditer(cells[3]):
            if hit.group(0) not in versions:
                versions.append(hit.group(0))
        if identifier in rows:
            raise FailClosed(
                "%s/%s: %s has more than one row, so the index states two dispositions for it"
                % (RFC_DIR, INDEX_NAME, identifier)
            )
        rows[identifier] = (status, versions)
    if not rows:
        raise FailClosed(
            "%s/%s exists and yielded no parsable row; an index that cannot be read is not an index "
            "describing nothing" % (RFC_DIR, INDEX_NAME)
        )
    return rows


# --- derivation: the banner -----------------------------------------------------------------------


def banner_of(path, label):
    """The first run of blockquote lines after the H1. Status lives there; design does not."""
    lines = read_text(path, label).splitlines()
    seen_h1 = False
    collected = []
    for line in lines:
        if not seen_h1:
            if H1.match(line):
                seen_h1 = True
            continue
        stripped = line.strip()
        if stripped.startswith(">"):
            collected.append(stripped.lstrip("> ").rstrip())
            continue
        if collected and stripped == "":
            break
        if collected:
            break
    return " ".join(collected)


STALE_PHRASES = (
    "no normative edits ride",
    "design document only",
    "DRAFT",
)


def stale_wording(banner):
    for phrase in STALE_PHRASES:
        if phrase.lower() in banner.lower():
            return phrase
    return None


# --- the badge ------------------------------------------------------------------------------------


def badge_message(rows):
    """The one derived string. Every count surface is rendered from it and compared against it."""
    adopted = sum(1 for status, _ in rows.values() if status == STATUS_ADOPTED)
    partial = sum(1 for status, _ in rows.values() if status == STATUS_PARTIAL)
    openned = sum(1 for status, _ in rows.values() if status in (STATUS_DRAFT, STATUS_DESIGN))
    return "%d adopted, %d partial, %d open" % (adopted, partial, openned)


def render_badge(message):
    """An SVG in the shape the repository's other badges already take."""
    label_w = 46
    msg_w = int(round(6.3 * len(message))) + 12
    total = label_w + msg_w
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="20" '
        'font-family="Verdana,Helvetica,sans-serif" font-size="11">\n'
        '<rect width="%d" height="20" fill="#2C3E50"/>'
        '<rect x="%d" width="%d" height="20" fill="#A23B2A"/>\n'
        '<text x="%d" y="14" fill="#EAF1F7" text-anchor="middle">%s</text>\n'
        '<text x="%d" y="14" fill="#FFFFFF" text-anchor="middle" font-weight="bold">%s</text></svg>'
        % (
            total,
            label_w,
            label_w,
            msg_w,
            label_w // 2,
            BADGE_LABEL,
            label_w + msg_w // 2,
            message,
        )
    )


BADGE_TEXT = re.compile(r"<text[^>]*font-weight=\"bold\"[^>]*>([^<]*)</text>")


def badge_committed(root):
    path = root / BADGE_REL
    if not path.is_file():
        raise FailClosed("%s is missing; there is no count surface to judge" % BADGE_REL)
    text = read_text(path, BADGE_REL)
    match = BADGE_TEXT.search(text)
    if not match:
        raise FailClosed(
            "%s yielded no message text; a badge that cannot be read is not a badge stating nothing"
            % BADGE_REL
        )
    return text, match.group(1).strip()


ALT_OF_BADGE = re.compile(re.escape(BADGE_REL) + r"\"\s+alt=\"([^\"]*)\"")


def readme_alt(root, readme_rel):
    text = read_text(root / readme_rel, readme_rel)
    match = ALT_OF_BADGE.search(text)
    if not match:
        raise FailClosed(
            "%s does not reference %s with an alt attribute; the accessible text could not be judged"
            % (readme_rel, BADGE_REL)
        )
    return match.group(1).strip()


# --- the check ------------------------------------------------------------------------------------


def check(root, standard_rel, readme_rel):
    known = existing_rfcs(root)
    versions, claims = ledger_claims(root, standard_rel)
    rows = parse_index(root)
    badge_svg, badge_msg = badge_committed(root)
    alt = readme_alt(root, readme_rel)

    problems = []

    # 1. Coverage.
    if rows is None:
        for identifier in sorted(known):
            problems.append(
                "%s is present in %s/ and no index covers it; %s/%s does not exist"
                % (identifier, RFC_DIR, RFC_DIR, INDEX_NAME)
            )
    else:
        for identifier in sorted(known):
            if identifier not in rows:
                problems.append(
                    "%s is present in %s/ and has no row in %s/%s"
                    % (identifier, RFC_DIR, RFC_DIR, INDEX_NAME)
                )
        for identifier in sorted(rows):
            if identifier not in known:
                problems.append(
                    "%s/%s has a row for %s and no file in %s/ carries that identifier"
                    % (RFC_DIR, INDEX_NAME, identifier, RFC_DIR)
                )

    # 2. The ledger contradicts a declared status.
    banners_checked = 0
    for identifier in sorted(claims):
        claiming = claims[identifier]
        if identifier in known:
            label = "%s/%s" % (RFC_DIR, known[identifier])
            banner = banner_of(root / RFC_DIR / known[identifier], label)
            banners_checked += 1
            named = [v for v in claiming if v in banner]
            if not named:
                phrase = stale_wording(banner)
                problems.append(
                    "%s: the version ledger records %s as implementing %s and the status banner "
                    "names no such version%s"
                    % (
                        label,
                        " and ".join(claiming),
                        identifier,
                        "; it still reads %r" % phrase if phrase else "",
                    )
                )
        if rows is None:
            continue
        if identifier not in rows:
            continue
        status, declared = rows[identifier]
        if status not in IMPLEMENTED_STATUSES:
            problems.append(
                "%s/%s records %s as %s and the version ledger records %s as implementing it"
                % (RFC_DIR, INDEX_NAME, identifier, status, " and ".join(claiming))
            )
        missing = [v for v in claiming if v not in declared]
        if missing:
            problems.append(
                "%s/%s: the row for %s does not name %s, which the ledger records as implementing it"
                % (RFC_DIR, INDEX_NAME, identifier, " and ".join(missing))
            )

    # 3. The index names a version the ledger does not record, or a status with no version behind it.
    if rows is not None:
        for identifier in sorted(rows):
            status, declared = rows[identifier]
            for version in declared:
                if version not in versions:
                    problems.append(
                        "%s/%s: the row for %s names %s, which is in no version-history row"
                        % (RFC_DIR, INDEX_NAME, identifier, version)
                    )
            if status in IMPLEMENTED_STATUSES and not declared:
                problems.append(
                    "%s/%s: the row for %s declares %s and names no version that implemented it"
                    % (RFC_DIR, INDEX_NAME, identifier, status)
                )

    # 4. The count surface.
    if rows is None:
        supported = len([i for i in claims if i in known])
        numbers = [int(n) for n in re.findall(r"\d+", badge_msg)]
        if supported not in numbers:
            problems.append(
                "%s reads %r and no index exists to derive it from; the version ledger records %d "
                "RFC(s) as implemented (%s), which the badge does not state"
                % (
                    BADGE_REL,
                    badge_msg,
                    supported,
                    ", ".join(sorted(i for i in claims if i in known)),
                )
            )
        if alt != ALT_PREFIX + badge_msg:
            problems.append(
                "%s: the alt text for %s reads %r and the badge renders %r"
                % (readme_rel, BADGE_REL, alt, badge_msg)
            )
        derived = None
    else:
        derived = badge_message(rows)
        if badge_msg != derived:
            problems.append(
                "%s reads %r and the index derives %r; the badge is generated from the index, never "
                "maintained beside it" % (BADGE_REL, badge_msg, derived)
            )
        if badge_svg.strip() != render_badge(derived).strip():
            problems.append(
                "%s is not byte-equal to what the index renders; regenerate it with "
                "--write-badge" % BADGE_REL
            )
        if alt != ALT_PREFIX + derived:
            problems.append(
                "%s: the alt text for %s reads %r and the index derives %r"
                % (readme_rel, BADGE_REL, alt, ALT_PREFIX + derived)
            )

    return known, versions, claims, rows, banners_checked, derived, problems


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root holding rfcs/, STANDARD.md, README.md and the badge",
    )
    parser.add_argument("--standard", default="STANDARD.md", help="path of the version ledger")
    parser.add_argument("--readme", default="README.md", help="path of the page carrying the alt text")
    parser.add_argument(
        "--write-badge",
        action="store_true",
        help="render the badge from the index and write it, then exit. The same derivation the "
             "validating run asserts, so generator and validator cannot drift apart",
    )
    args = parser.parse_args()
    root = args.root.resolve()

    if args.write_badge:
        try:
            rows = parse_index(root)
            if rows is None:
                raise FailClosed(
                    "%s/%s does not exist; there is nothing to derive the badge from"
                    % (RFC_DIR, INDEX_NAME)
                )
            message = badge_message(rows)
            (root / BADGE_REL).write_text(render_badge(message), encoding="utf-8")
        except (FailClosed, OSError) as exc:
            print("REFUSED rfc-lifecycle: %s" % exc, file=sys.stderr)
            return 2
        print("WROTE %s: %s (alt: %s%s)" % (BADGE_REL, message, ALT_PREFIX, message))
        return 0

    try:
        known, versions, claims, rows, banners, derived, problems = check(
            root, args.standard, args.readme
        )
    except FailClosed as exc:
        print("REFUSED rfc-lifecycle: %s" % exc, file=sys.stderr)
        return 2

    if problems:
        print(
            "RFC LIFECYCLE METADATA IS STALE: %d statement(s) about disposition are false or "
            "underived" % len(problems),
            file=sys.stderr,
        )
        for item in problems:
            print("  %s" % item, file=sys.stderr)
        print(
            "  The index is the home of record for disposition, the ledger is the home of record "
            "for what published, and the badge is rendered from the index with --write-badge.",
            file=sys.stderr,
        )
        return 1

    split = {}
    for status, _ in rows.values():
        split[status] = split.get(status, 0) + 1
    print(
        "PASS rfc-lifecycle: %d RFC(s) present in %s/ (%s); %d index row(s) read (%s); %d "
        "implementation claim(s) read from %d version-history row(s) (%s); %d banner(s) verified "
        "against them; badge derives %r and the alt text agrees. The ledger-derived set is a LOWER "
        "BOUND: a row recording an adoption without an implementation verb is not counted, so the "
        "index carries those under a maintainer's judgement."
        % (
            len(known),
            RFC_DIR,
            ", ".join(sorted(known)),
            len(rows),
            ", ".join("%d %s" % (split[s], s) for s in STATUSES if s in split),
            sum(len(v) for v in claims.values()),
            len(versions),
            ", ".join("%s by %s" % (i, "/".join(claims[i])) for i in sorted(claims)),
            banners,
            derived,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
