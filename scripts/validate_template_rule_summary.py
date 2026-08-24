#!/usr/bin/env python3
# km-unrepaired-tree: v1.48 | run against published main at 62c4e51 before any repair entered the working tree, where it fails with exit 1 and names three real statements: the summary has no entry for Rule 5 and none for Rule 6, and template/README.md:64 asserts 4 rules where the standard defines 6; coverage on that run was 6 rules derived, 4 entries found, 4 matched, 1 count phrase judged. Proved in both directions by tests/test_template_rule_summary.sh.
"""Fail when the hub template's landing page disagrees with the standard's own governance rule set.

WHY THIS EXISTS. `template/README.md` is copied verbatim into every hub this standard creates, so a
false statement on it is not one wrong page but one wrong page per hub, and the count grows with
adoption. It carried one: a four-item governance summary and the sentence "It checks all four rules
in one pass", while the standard has defined six rules since v1.22. A new hub was therefore handed a
governance model the standard had replaced, by the standard itself, on the first page its operator
reads. Nothing in this repository had ever compared the two enumerations.

WHAT IS COMPARED. Two things, and they are deliberately separate arms.
  - ENUMERATION: one summary entry on the landing page per rule the standard defines. A missing rule
    is named.
  - COUNT PHRASES: any count written immediately before the word "rules" on the landing page must
    equal the number of rules derived. This is the arm that catches the sentence, and it survives
    independently of the list: a page can carry six entries and still tell its reader the scan checks
    four, which is the same defect surviving its own repair.

THE RULE SET IS DERIVED, NEVER HELD HERE. There is no rule count, rule list or rule name in this
file. The set comes from the standard's own `### Rule N:` headings, so a rule added, removed or
renumbered there changes this check's answer with no edit to the instrument. A list kept beside a
check is a hand-maintained memory of the document it checks, which is the artifact class this
standard already records as the one that rots, and adding a second copy of the rule set to catch a
stale first copy would be that mistake wearing a check's clothes.

SCOPE IS THE HUB TEMPLATE'S LANDING PAGE, AND THAT IS A DECLARATION RATHER THAN AN OVERSIGHT. A sweep
of the tree for count phrases finds the standard itself, which is the home of record this check
derives from; a version-ledger row and an RFC, both dated records of what was true when they were
written, which this change would falsify by "correcting"; and the architecture set, which is already
right. Widening the count arm across the tree would fire on the dated records, and the only way to
quiet it would be an exemption list, which is the artifact this derivation exists to avoid.

FAIL CLOSED. The check exits 2, without a verdict, when the standard or the landing page cannot be
read or decoded, when the standard yields no rule heading, when the landing page carries no
governance-rule summary heading, or when that section yields no numbered entry. An unread page is not
a conformant one, and a summary that parsed to nothing looks exactly like one whose entries all match.

COVERAGE, STATED ON A PASSING RUN. Rules derived, summary entries found, entries matched, and count
phrases judged. A page that states no count at all is legitimate, and the run says so rather than
passing silently over an arm that found nothing to do.

LIMIT. This models one class: a landing page whose rule enumeration or rule count disagrees with the
standard's own rule set. It says nothing about whether an entry describes its rule correctly, whether
anything else on the page is true, whether an enforcement claim elsewhere is correctly narrowed, or
whether a descriptive document set is current. Terminology quality is a judgement, and a check that
scored it would be modelling the wrong class. Proving both directions proves this check fires on the
class it models, never that it models the right class.
"""
import argparse
import re
import sys
from pathlib import Path

RULE_HEADING = re.compile(r"^#{1,6}\s+Rule\s+(\d+)\s*:")
SUMMARY_HEADING = re.compile(r"^#{1,6}\s+Governance rules\b", re.I)
ANY_HEADING = re.compile(r"^#{1,6}\s")
NUMBERED_ENTRY = re.compile(r"^\s*(\d+)\.\s+\S")

NUMBER_WORDS = {
    "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
}
COUNT_PHRASE = re.compile(
    r"\b(?:all\s+)?(zero|one|two|three|four|five|six|seven|eight|nine|ten|\d+)"
    r"\s+(?:governance\s+)?rules\b",
    re.I,
)


class FailClosed(Exception):
    """The check could not evaluate its input and refuses to return a verdict."""


def read_lines(path, what):
    try:
        return path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        raise FailClosed("could not read the %s %s: %s" % (what, path, exc))


def derive_rules(standard):
    """The rule numbers the standard declares, read from its own rule headings."""
    lines = read_lines(standard, "standard")
    numbers = []
    for line in lines:
        match = RULE_HEADING.match(line)
        if match:
            number = int(match.group(1))
            if number not in numbers:
                numbers.append(number)
    if not numbers:
        raise FailClosed(
            "no rule heading was found in %s, so the set this verdict is drawn from could not be "
            "derived; an unread standard is not a standard with no rules" % standard
        )
    return sorted(numbers)


def read_summary(landing):
    """The numbered entries under the landing page's governance-rule summary heading."""
    lines = read_lines(landing, "landing page")
    start = None
    for number, line in enumerate(lines):
        if SUMMARY_HEADING.match(line):
            start = number + 1
            break
    if start is None:
        raise FailClosed(
            "no governance-rule summary heading was found in %s; the section the verdict is drawn "
            "from could not be located" % landing
        )
    entries = []
    for number in range(start, len(lines)):
        line = lines[number]
        if ANY_HEADING.match(line):
            break
        match = NUMBERED_ENTRY.match(line)
        if match:
            entries.append((int(match.group(1)), number + 1))
    if not entries:
        raise FailClosed(
            "the governance-rule summary in %s yielded no numbered entry; an empty summary is not a "
            "complete one" % landing
        )
    return lines, entries


def read_counts(lines):
    """[(line number, phrase, asserted count)] for every count written before the word rules."""
    found = []
    for number, line in enumerate(lines):
        for match in COUNT_PHRASE.finditer(line):
            token = match.group(1).lower()
            value = NUMBER_WORDS.get(token)
            if value is None:
                try:
                    value = int(token)
                except ValueError:
                    continue
            found.append((number + 1, match.group(0), value))
    return found


def check(standard, landing):
    rules = derive_rules(standard)
    lines, entries = read_summary(landing)
    counts = read_counts(lines)

    entry_numbers = [number for number, _ in entries]
    failures = []

    for rule in rules:
        if rule not in entry_numbers:
            failures.append(
                "%s: the standard defines Rule %d and the governance-rule summary has no entry for "
                "it; a hub scaffolded from this template is taught a governance model the standard "
                "has replaced" % (landing.name, rule)
            )
    for number, line_number in entries:
        if number not in rules:
            failures.append(
                "%s:%d: the summary carries an entry numbered %d and the standard defines no such "
                "rule" % (landing.name, line_number, number)
            )
    for line_number, phrase, value in counts:
        if value != len(rules):
            failures.append(
                "%s:%d: %r asserts %d rule(s) and the standard defines %d"
                % (landing.name, line_number, phrase, value, len(rules))
            )

    matched = len([number for number, _ in entries if number in rules])
    return rules, entries, counts, matched, failures


def print_coverage(rules, entries, counts, matched, stream):
    print(
        "  coverage: %d rule(s) derived from the standard's own rule headings, %d summary entry/ies "
        "found, %d matched, %d count phrase(s) judged"
        % (len(rules), len(entries), matched, len(counts)),
        file=stream,
    )
    if not counts:
        print(
            "  no rule count is written in the landing page's prose, so that arm judged nothing on "
            "this run; the enumeration arm above is the whole of the verdict",
            file=stream,
        )


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    default_root = Path(__file__).resolve().parent.parent
    parser.add_argument(
        "--standard",
        type=Path,
        default=None,
        help="the document whose rule headings the rule set is derived from "
             "(default: <root>/STANDARD.md)",
    )
    parser.add_argument(
        "--landing",
        type=Path,
        default=None,
        help="the hub template landing page whose summary is judged "
             "(default: <root>/template/README.md)",
    )
    args = parser.parse_args()
    standard = (args.standard if args.standard else default_root / "STANDARD.md").resolve()
    landing = (args.landing if args.landing else default_root / "template" / "README.md").resolve()

    try:
        rules, entries, counts, matched, failures = check(standard, landing)
    except FailClosed as exc:
        print("REFUSED template-rule-summary: %s" % exc, file=sys.stderr)
        return 2

    if failures:
        print(
            "TEMPLATE RULE SUMMARY DISAGREEMENT: %d statement(s) on the hub template's landing page "
            "do not match the standard's own rule set" % len(failures),
            file=sys.stderr,
        )
        for item in failures:
            print("  %s" % item, file=sys.stderr)
        print(
            "  This page is copied into every hub the standard creates, so the statement travels "
            "into each of them. Repair the page; the standard is the home of record.",
            file=sys.stderr,
        )
        print_coverage(rules, entries, counts, matched, sys.stderr)
        return 1

    print(
        "PASS template-rule-summary: the hub template's landing page enumerates every rule the "
        "standard defines and states no rule count that disagrees with it"
    )
    print_coverage(rules, entries, counts, matched, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
