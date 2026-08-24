#!/usr/bin/env python3
# km-unrepaired-tree: v1.45 | run against published main at c3e4ffe before the RFC landed, where it fails and names all nine real dangling references; proved in both directions by tests/test_rfc_reference_integrity.sh.
"""Fail when text in the governed surface names an RFC that does not exist in `rfcs/`.

rfc-reference-exempt: this instrument's own docstring names identifiers to define what it matches.

Scanning this file would report its own definitions as violations of itself.

WHY THIS EXISTS. Published `main` cited `rfcs/RFC-005` in `STANDARD.md` while `rfcs/` carried
RFC-001, 002, 003, 004, 006 and 007. The document existed only on an unmerged branch, so the
published standard named a design document a reader could not open, and two RFCs rested on it. The
reference escaped every check the repository ships because it is written as a code-formatted path
rather than a Markdown link: a walk over hyperlinks never saw it. A reference is a promise the reader
can open the thing named, and nothing was keeping that promise mechanically.

WHAT IS MATCHED, AND WHY EACH FORM. Three written forms carry an RFC reference in this repository,
and a check that read only the third would reproduce the defect it exists to close.
  - A bare identifier in running prose or in a version-ledger row.
  - A code-formatted path with no filename, which is how the standard's own text cites an RFC when it
    does not link to it. This is the form that got through.
  - A path naming a file, whether or not it sits inside a Markdown link. A path is held to a stricter
    test than an identifier: the named file must exist, so a path carrying a real identifier under a
    filename that has been renamed away is reported rather than resolved by its number.

THE EXISTING SET IS DERIVED, NEVER HELD HERE. The identifiers that exist are read from the names of
the files in `rfcs/`. There is deliberately no list of known identifiers in this file, so adding,
renaming or removing an RFC changes this check's answer with no edit to it. A list held here would be
a hand-maintained memory of directory state, which is the artifact class this standard already
records as the one that rots.

WHAT IS IN SCOPE. Every file with a scanned suffix under the roots in SCAN_ROOTS. Unlike the
published-not-draft check, `rfcs/` IS scanned here: an RFC's dependency and provenance sections are
exactly where one design document names another, and three of the nine references this check was
written for sat there.

FAIL CLOSED. The check exits 2, without a verdict about references, when `rfcs/` is missing or
cannot be listed, when it yields no RFC at all, when no file was scanned, when the scan parsed no
identifier anywhere, when a scanned file cannot be decoded, when a file exempts itself with no
reason, or when every file in scope is exempt. An unread directory is not an empty one, and a pattern
that has stopped matching produces the same silence as a tree that cites nothing.

COVERAGE, STATED ON A PASSING RUN. The passing line names how many references were found and how many
distinct identifiers they resolve to, how many files were scanned and how many were exempt, and how
many RFCs are present in the directory the set was derived from, naming them. A recorded pass that
does not state those numbers is void rather than clean.

LIMIT. This models one class: a reference whose target is not in the tree. It says nothing about
whether a resolvable reference characterises its target correctly, whether the target is current, or
whether an RFC that should have been cited was not cited at all. Proving both directions proves it
fires on the class it models, never that it models the right class.
"""
import argparse
import re
import sys
from pathlib import Path

RFC_DIR = "rfcs"

# A bare identifier. The boundary in front keeps `SUB-RFC-001` and `xRFC-001` out; the boundary
# behind keeps `RFC-0051` from reading as `RFC-005`.
IDENTIFIER = re.compile(r"(?<![A-Za-z0-9_-])RFC-(\d+)(?![0-9])")
# A path reference, with or without a filename, with or without a Markdown link around it.
PATH_REF = re.compile(r"(?<![A-Za-z0-9._/-])rfcs/(RFC-\d+[A-Za-z0-9._-]*)")
# The identifier an RFC file's own name declares.
FILENAME_ID = re.compile(r"^(RFC-\d+)")
EXEMPT = re.compile(r"rfc-reference-exempt:\s*(.*)$")

SCAN_ROOTS = (
    "STANDARD.md",
    "README.md",
    "agents",
    "components",
    "contracts",
    "docs",
    "rfcs",
    "scripts",
    "skills",
    "template",
    "tests",
    "tools",
)
SUFFIXES = (".md", ".sh", ".py", ".toml", ".yaml", ".yml", ".json", ".txt")
SKIP_DIRS = {".git", "openspec", "outputs", "work", "node_modules", "__pycache__", ".venv"}
EXEMPT_SCAN_LINES = 60


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def read_lines(path, label):
    try:
        return path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read %s: %s" % (label, exc))


def existing_rfcs(root):
    """Derive {identifier: filename} from the directory. Never from a list held in this file."""
    directory = root / RFC_DIR
    if not directory.is_dir():
        raise FailClosed(
            "%s/ is missing or is not a directory; the set of existing RFCs could not be derived, "
            "so no reference could be judged" % RFC_DIR
        )
    try:
        entries = sorted(directory.iterdir())
    except OSError as exc:
        raise FailClosed("%s/ could not be listed: %s" % (RFC_DIR, exc))

    found = {}
    for entry in entries:
        if not entry.is_file() or entry.suffix != ".md":
            continue
        match = FILENAME_ID.match(entry.name)
        if not match:
            continue
        found.setdefault(match.group(1), entry.name)
    if not found:
        raise FailClosed(
            "%s/ holds no file naming an RFC; an empty set is not a verdict about the tree"
            % RFC_DIR
        )
    return found


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


def scan_file(lines, label, known, files_present):
    """Return (references, paths, dangling), one entry per occurrence.

    A path form is judged on the filename it names; the identifier inside it is counted and judged
    by the identifier pass below, so the two tests are complementary rather than duplicated.
    """
    references = []
    paths = []
    dangling = []
    for number, line in enumerate(lines, start=1):
        for match in PATH_REF.finditer(line):
            tail = match.group(1)
            if tail.endswith(".md"):
                paths.append(tail)
                if tail not in files_present:
                    dangling.append(
                        "%s:%d: path reference %r names no file in %s/"
                        % (label, number, "%s/%s" % (RFC_DIR, tail), RFC_DIR)
                    )
        for match in IDENTIFIER.finditer(line):
            identifier = "RFC-%s" % match.group(1)
            references.append(identifier)
            if identifier not in known:
                dangling.append(
                    "%s:%d: %s is named here and no file in %s/ carries that identifier"
                    % (label, number, identifier, RFC_DIR)
                )
    return references, paths, dangling


def check(root, explicit):
    known = existing_rfcs(root)
    files_present = set(known.values())

    files = collect(root, explicit)
    if not files:
        raise FailClosed("no file was scanned; the scope resolved to nothing")

    references = []
    paths = []
    dangling = []
    exempt = []
    scanned = 0

    for path in files:
        try:
            label = str(path.relative_to(root))
        except ValueError:
            label = str(path)
        lines = read_lines(path, label)
        reason = exemption(lines)
        if reason is not None:
            if not reason:
                raise FailClosed("%s declares an rfc-reference exemption with no reason" % label)
            exempt.append((label, reason))
            continue
        scanned += 1
        file_references, file_paths, file_dangling = scan_file(lines, label, known, files_present)
        references.extend(file_references)
        paths.extend(file_paths)
        dangling.extend(file_dangling)

    if scanned == 0:
        raise FailClosed("every file in scope declared an exemption; nothing was evaluated")
    if not references:
        raise FailClosed(
            "%d file(s) were scanned and no RFC reference was found in any of them; a pattern that "
            "has stopped matching looks exactly like a tree that cites nothing" % scanned
        )
    return known, scanned, exempt, references, paths, dangling


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root holding rfcs/ and the governed surfaces",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="optional explicit files to scan instead of the declared scope",
    )
    args = parser.parse_args()
    root = args.root.resolve()

    try:
        known, scanned, exempt, references, paths, dangling = check(root, args.paths)
    except FailClosed as exc:
        print("REFUSED rfc-reference-integrity: %s" % exc, file=sys.stderr)
        return 2

    if dangling:
        print(
            "DANGLING RFC REFERENCES: %d reference(s) name a document that is not in %s/"
            % (len(dangling), RFC_DIR),
            file=sys.stderr,
        )
        for item in dangling:
            print("  %s" % item, file=sys.stderr)
        print(
            "  A reference is a promise the reader can open the thing named. Land the document, or "
            "remove the reference, before the text publishes.",
            file=sys.stderr,
        )
        return 1

    print(
        "PASS rfc-reference-integrity: %d RFC reference(s) found across %d file(s) scanned, "
        "resolving to %d distinct identifier(s); %d of them written as a path naming a file, and "
        "every named file present; %d file(s) exempt by declaration; "
        "%d RFC(s) present in %s/ (%s)"
        % (
            len(references),
            scanned,
            len(set(references)),
            len(paths),
            len(exempt),
            len(known),
            RFC_DIR,
            ", ".join(sorted(known)),
        )
    )
    for label, reason in exempt:
        print("  exempt: %s (%s)" % (label, reason))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
