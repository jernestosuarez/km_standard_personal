#!/usr/bin/env python3
# km-release-gate: the one command that runs the whole gate and returns one verdict.
#
# km-unrepaired-tree: v1.60 | re-stated for the phase-derivation repair, which edits this file. Run against the unrepaired gate at 73f89e8 (published v1.59) before the repair was written, through the rewritten case 21j of tests/test_release_gate.sh. That case injects the external reviewer's own verdict phase -- check_text, reading tracked *.txt files through a TUPLE pathspec, git_tracked(root, ("*.txt",)), lifted byte for byte from reproduce-phase-derivation-false-pass.sh (sha256 2610ce370cf3869d02cd9a7cca33663d01cdf13f07e23ecf8753f7dac3be88ed) -- into a copy of this file, and runs it over a fixture whose discovered suite appends to notes.txt mid-run. On the unrepaired gate: PASS release-gate, exit 0, over a tracked input the run had just READ, reported by the case as 'expected exit 2, got 0'. The reviewer's own script, run here unmodified against a detached clone at 73f89e8 on an environment identical to theirs (macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6), printed 'PASS: 21h. a file in no input class is NOT caught (KNOWN GAP)', 'PASS: 21j. every phase takes its pathspecs from the structure the fingerprint iterates', 'suite_exit=0' and REPRODUCED -- the v1.59 form of 21j grepped this file for git_(tracked|untracked)\(root, \[ and a tuple walked past it, so the check certifying the guarantee was green while the guarantee was false, and 21h then accepted notes.txt mutating mid-run at a moment when notes.txt WAS an input to this gate. The repaired gate answers the same fixture with REFUSED at exit 2 naming 'notes.txt changed content', with no edit to any list and no edit to the case; 21j2 requires the same added phase over a stable tree to keep passing and it does; and 21h still passes on the UNMODIFIED gate, which is limit 5 re-drawn as what this run never read. On the tree at 73f89e8 the covered set was every INPUT_CLASS glob; it is now every pathspec the run enumerated and every path it opened, recorded by git_tracked, git_untracked and read_text as they hand them out. The residual that remains enforced by nothing is stated in limit 5 rather than here: a phase that obtained a file WITHOUT going through those three accessors is outside the ledger and no check detects it. The v1.59 declaration this replaces still holds in full: v1.59 | re-stated for the fingerprint-scope repair and the branch-identity repair. Run against the unrepaired gate at be6e4bf (published v1.58) before either repair was written, through the assertions added and rewritten as cases 21d-21j of tests/test_release_gate.sh. A fixture whose discovered suite switches to a new branch AT THE SAME COMMIT: PASS release-gate, exit 0, because git rev-parse HEAD returns one value for two branches standing at one commit, so the branch change this file's own fingerprint docstring claimed to catch was invisible and what it caught was commit movement. That case is the external reviewer's own script reproduce-same-commit-branch-switch.sh run here unmodified against a be6e4bf snapshot, on an environment identical to theirs (macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6): it printed exit=0, branch=km-other, and REPRODUCED. The repaired gate answers the same script with REFUSED at exit 2 naming the checked-out ref changed from refs/heads/main to refs/heads/km-other. A fixture whose suite edits a tracked markdown file the link phase had already resolved: PASS, exit 0. The same for a tracked JSON file the parse phase had read, for a shell file and for a Python file outside tests/ and scripts/ that the syntax phases had read: PASS, exit 0 in every case, over a tree in which the thing checked no longer looks the way it looked when it was checked. On the tree at be6e4bf the uncovered set was 172 markdown files, 5 JSON and JSON-LD files, 31 shell and 11 Python files; the fingerprint covered the 33 discovered checks alone. The repaired gate refuses each at exit 2 naming what moved, a detached HEAD still passes, and a file in NO input class still passes, which is limit 5 and is pinned as a gap by case 21h. The v1.58 declaration this replaces still holds in full: re-stated for the tree-stability repair and the limits-definition repair. Run against the unrepaired gate at 510cf03 before either repair was written, through the four fixtures added as cases 21a-21d of tests/test_release_gate.sh. A fixture whose discovered suite edits another discovered check mid-run: PASS release-gate, exit 0. A fixture whose suite creates a new check-shaped file mid-run: PASS release-gate, exit 0, over a check the gate had never discovered, never held to the declaration rule and never executed. A fixture whose suite moves HEAD with no file content differing: PASS release-gate, exit 0. All three are the reviewer's observed case in miniature, where this gate began on a clean branch, the branch changed at 14:16, tests/test_restricted_lint.sh was modified at ~14:18, and the gate returned PASS after ~900s still reporting zero changed declarations. The repaired gate refuses each of the three at exit 2 naming what moved, and a fixture changed OUTSIDE the discovery set still passes, which is limit 5 and is pinned as a gap by case 21e. On the limits, the unrepaired file typed 'the same four limits' in prose 185 lines below its own claim that the count is not restated in prose anywhere, argued four numbered limits a second time in the header in file order 1, 3, 2, 4, and pointed twice at GATE_LIMITS, which nothing defined. The v1.56 declaration this replaces still holds: re-stated because this version edits this file. The edit is to the header block alone, correcting a claim that the CI workflow carries a copy of the limits when v1.55 deleted that copy, and removing the prose count of them; no arm of the gate changes, so there is no new unrepaired-tree run to record for the gate itself and none is invented. The v1.55 declaration this re-states still holds in full: re-stated for the exemption-anchoring repair, and run against the unrepaired tree first: with README.md given a broken relative link and a fenced text block quoting km-gate-link-exempt, check_links reported 0 failures, "153 of 154 markdown files scanned, 1 exempt" and 88 links resolved; the same tree without the fenced example reported 1 failure naming the broken link and 113 links resolved. A quotation removed a document from the scan and 25 links from the count at exit 0. The repaired reader reports the failure in both shapes and still honours a real declaration at the start of a line. The v1.54 declaration this replaces still holds: re-stated for the discovery-scope repair, and run against the unrepaired tree first: with an untracked tests/test_zz_probe.sh holding a line bash -n rejects, this gate reported "33 check(s) discovered" and "PASS release-gate", exit 0, the same count and the same verdict as the clean tree, having neither run nor named the check. Earlier, under v1.46, it was run against deliberately broken trees (a suite made to fail, a suite made unexecutable, an emptied discovery set, a stripped declaration) and refused or failed in each; see tests/test_release_gate.sh.
#
# Standard: STANDARD.md §"Publishing a version" step 5, and §"Standard Maintainer" under
# "A gate runs before publication, and it declares what it cannot do".
#
#   python3 tools/km-release-gate.py [--root PATH] [--no-suites] [--limits]
#
# Exit: 0  PASS     everything discovered ran and every phase passed; the coverage line says what
#                     was looked at
#       1  FAIL     a suite, a validator, a syntax check, a parse, a link, or a required
#                     unrepaired-tree declaration failed
#       2  REFUSED  the gate could not evaluate: no repository, an empty discovery set, an
#                     unreadable or undecodable file, a discovered check that could not be executed,
#                     an exemption the gate could not honour, or a tree that changed while the gate
#                     ran (v1.58), which makes the verdict one about no tree that exists
#
# Neither 1 nor 2 is a pass. The distinction says whether the tree is bad or the gate was blind, and
# a gate that reported "blind" as "clean" would be the absence-shaped pass this repository has
# already been bitten by three times.
#
# ------------------------------------------------------------------------------------------------
# WHAT THIS GATE CANNOT DO. Read LIMITS below, or run `--limits`. That structure is the ONLY place
# the limits are defined, and it carries each limit's full argument beside the words every surface
# prints, so there is nothing here to keep in step with it (reduced to one definition in v1.58).
#
# Until v1.58 the same set was maintained in three places: the LIMITS tuple; a numbered prose block
# HERE that argued each limit again; and four hardcoded `grep -Fq` assertions in
# tests/test_release_gate.sh that pinned this block's exact wording. The tuple's own comment said
# "Adding a fifth limit is an edit to this tuple and to nothing else", which was FALSE ON THE DAY IT
# WAS WRITTEN at v1.55 -- both other places already stood on that tree -- so it is corrected here
# under the v1.47 rule rather than dated under v1.56's. Two smaller symptoms of the same separate
# maintenance came with it: this block pointed twice at `GATE_LIMITS`, a name nothing defined, and
# claimed the count "is not restated in prose anywhere" while the tuple's comment 185 lines below
# said "the same four limits". The block's own entries had drifted into file order 1, 3, 2, 4.
#
# The repair reduces the count of maintained definitions rather than describing the drift, and the
# proof is this version's own work: v1.58 adds a fifth limit, and adding it was an edit to LIMITS
# and to nothing else. Cases 15a, 15b and 15c of tests/test_release_gate.sh keep it at one, and all
# three derive -- none of them names a limit.
#
# ------------------------------------------------------------------------------------------------
# DISCOVERY, AND WHY IT IS NOT A LIST, AND WHICH TREE IT READS.
#
# Every `*.sh` and `*.py` file in any directory named `tests/` or `scripts/`, at the root or nested
# anywhere in the tree, is a discovered check. The two directory names are a scope declaration; the
# checks themselves are never enumerated here, so a suite added tomorrow is picked up with no edit to
# this file. A list held beside a runner is a hand-maintained memory of directory state, which is the
# artifact class this standard records as the one that rots.
#
# The scope is deliberately not limited to the root `tests/` and `scripts/`. A suite sitting in a
# component's own `tests/` directory is a suite, and a gate that looked only at the root would report
# a clean tree for the place it never looked, which is the failure class this repository already
# names.
#
# DISCOVERY READS THE WORKING TREE, NOT THE INDEX (v1.54). The set is tracked files UNION untracked
# files that the ignore rules do not exclude. Until v1.54 it was tracked files alone, and that was
# wrong for a reason with a schedule attached to it: the maintainer contract orders this gate to run
# BEFORE explicit staging, so a check authored in the change being gated is untracked at exactly the
# moment the gate runs. Measured on the tree at eb57f0f, an untracked `tests/test_zz_probe.sh`
# holding a line `bash -n` rejects left the count at "33 check(s) discovered" and the verdict at
# "PASS release-gate", exit 0. The file was neither run nor named. A gate that has not seen a check
# has not run it, whatever its verdict says; the sentence was written by the v1.48 drafting agent
# when it hit this, and the gap was reported and left open until an external reviewer reproduced it.
#
# So the tree this gate is a verdict about is the tree the maintainer is about to commit from, and
# each discovered check carries whether it is tracked. The count of untracked discovered checks is
# on the coverage line and each one is named on the run, because a coverage line exists so that a
# recorded pass says what was looked at, and a number that merges what the repository ships with
# what it does not says less than it appears to.
#
# THE TRADE, STATED. A scratch file shaped like a check and sitting where checks live will be
# discovered, will be required to carry a declaration, and will be executed. That is the cost, it is
# accepted deliberately, and the reason is that the repository has no other convention for what a
# check is: the two directory names ARE the scope declaration. The union is confined to discovery.
# The JSON parse and relative-link phases stay index-scoped, so a half-written markdown file in the
# working tree does not redden the gate, and that narrower scope is a choice rather than an
# oversight.
#
# ------------------------------------------------------------------------------------------------
# WHAT THE GATE READS IS WIDER THAN WHAT IT DISCOVERS, AND THE FINGERPRINT FOLLOWS THE READING.
# (v1.59.)
#
# Discovery answers "what will be RUN". It is one input class among several. The gate also resolves
# relative links across every tracked markdown file, parses every tracked JSON and JSON-LD file, and
# syntax-checks every tracked shell and Python file wherever in the tree it sits. INPUT_CLASSES
# below holds the classes known at the start of a run, and it is the OPENING baseline rather than
# the guarantee: from v1.60 (DRAFT; binds nothing until that version's own owner push) the accessors record what they hand
# out, so the closing fingerprint
# covers what the run ACTUALLY READ. A phase added later is covered because it cannot obtain a file
# without the ledger seeing it -- not because a list beside it was kept in step, and not because a
# grep over this file's source text said so. See the Reads class.
#
# From v1.58 to v1.59 the fingerprint hashed the discovery class alone, so a broken link, an
# unparseable JSON file or a syntax error introduced after its own phase had run survived into the
# final working tree with a PASS over it. That was a narrow SPECIFICATION rather than an
# implementation that drifted from it, and case 21e of tests/test_release_gate.sh shipped asserting
# the gap; it is a control now.
#
# v1.59 then held every phase to that structure with a GREP over this file -- and a phase spelling
# its pathspec any other way walked past it, so the check certifying the guarantee was green while
# the guarantee was false. v1.60 removes the need for the grep rather than lengthening it.
#
# The fingerprint over each class is tracked union untracked-not-ignored, which is deliberately
# WIDER than the index-scoped phases above read. An untracked markdown file is still not scanned;
# it is merely hashed, so it costs nothing until it MOVES mid-run, and hashing it is what keeps a
# check-shaped file appearing mid-run from being invisible. The ignore rules are honoured on both
# sides, because the suites and the tools legitimately write inside the tree and a fingerprint over
# their artifacts would make this gate refuse itself.
#
# Nothing discovered is ever silently dropped. A discovered check that cannot self-run because it
# takes required arguments declares itself:
#
#   km-gate-instrument: <canary-path> | <reason>
#
# The gate then reports it as discovered-but-skipped with its reason, and REFUSES unless the named
# canary is itself a discovered check that will run in this same pass. Without that pairing,
# "instrument" would be a way to delete a check from the gate by writing one comment line.
#
# A markdown file may exempt itself from the relative-link scan with:
#
#   km-gate-link-exempt: <reason>
#
# The reason is required and is printed on the passing run, so no exclusion is silent.
#
# ------------------------------------------------------------------------------------------------
# EXEMPTIONS ARE DECLARED, NEVER QUOTED. (v1.55.)
#
# A declaration is a LINE, never a mention. The exemption above is honoured only when the token
# begins its own line, after optional whitespace and at most one comment marker, only outside a
# fenced code block, and only within the first EXEMPT_SCAN_LINES lines of the file. All three
# conditions are needed, and the same rule now governs `published-not-draft-exempt:` and
# `rfc-reference-exempt:` in scripts/, so the three instruments read their exemptions by one rule
# rather than three.
#
# Until v1.55 this read was `re.search` over the RAW markdown, before strip_fenced and with no
# anchor at all. Measured on the tree at 13dec55: README.md given a broken relative link and a
# fenced `text` block quoting the token reported 0 link failures, `153 of 154 markdown files
# scanned, 1 exempt`, 88 links resolved. The same tree without the fenced example reported 1 failure
# naming the broken link and 113 links resolved. A quotation removed a document from the scan and 25
# links from the count, at exit 0.
#
# This is the class v1.52 repaired in scripts/validate_published_not_draft.py, where a quoted
# draft-declaration token silenced two publication checks and the repair anchored the read to where
# the declaration is made. It was repaired there and left standing here, which is the more useful
# finding than either instance: a directive read from raw text is a defect of the READER, so every
# reader of every directive token in a repository is in scope the first time one of them is found.
#
# ------------------------------------------------------------------------------------------------
# THE UNREPAIRED-TREE DECLARATION.
#
#   km-unrepaired-tree: <version|none|unrecorded> | <result>
#
# One line, machine-read, in the file's LEADING COMMENT BLOCK: the run of shebang, blank and comment
# lines at the top of the file, and nowhere else. The same scope applies to `km-gate-instrument:`.
# The scope is not decoration. A canary file legitimately writes these tokens into the fixtures it
# builds, and a whole-file search reads a fixture's declaration as the canary's own. The result text
# is required and must be non-empty.
#
#   vX.Y        the check was run against the unrepaired tree under that version, and the result
#               text records what it found there;
#   none        no unrepaired tree existed for this check, and the result text says why;
#   unrecorded  the check predates this requirement and no such run was recorded. Every
#               `unrecorded` declaration is counted and printed on the passing line, so the debt is
#               visible rather than hidden, and it is refused outright on a check this change adds.
#
# CURRENCY, in two sub-rules, because "adds a check" and "changes a check" are different acts and
# only one of them can be held to a fresh run. Both need a base revision; when none is resolvable
# both are reported as a COVERAGE GAP on the passing line and neither is folded into the verdict.
#
#   ADDED.    A discovered check absent at the base revision SHALL declare the version currently
#             drafted in `STANDARD.md`, or `none` with a reason. `unrecorded` is refused: a check
#             born in this change has no history to plead, and this is the case the whole finding
#             rests on.
#   CHANGED.  A discovered check that exists at the base and differs from it SHALL have its own
#             `km-unrepaired-tree` line among the lines this change added. Editing a check without
#             touching its declaration is how a check quietly stops meaning what its declaration
#             says. This does not force a fresh run for a typo fix; it forces the maintainer to
#             re-state the declaration deliberately, which is the same move as requiring a reason
#             on an exemption.
#
# The limit both sub-rules share is stated in limit 2 above: the gate checks that a declaration was
# made and re-stated. It cannot check that the run behind it happened.
#
# Running a new check against the unrepaired tree has caught something real four times in this
# repository's remediation sequence: the Reader scope bypass, the MCP quarantine, the skill parity
# check and the RFC reference check. It is the highest-yield step in the loop and the one most
# easily skipped, which is why it is the one the gate makes mandatory.
#
# Proven in both directions by tests/test_release_gate.sh.

import argparse
import collections
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

CHECK_DIRS = ("tests", "scripts")
CHECK_SUFFIXES = (".sh", ".py")

DECL_RE = re.compile(r"km-unrepaired-tree:[ \t]*(v[0-9]+\.[0-9]+|none|unrecorded)[ \t]*\|[ \t]*(.*)")
INSTRUMENT_RE = re.compile(r"km-gate-instrument:[ \t]*(\S+)[ \t]*\|[ \t]*(.*)")
# Anchored, and not read from a fence. See EXEMPTIONS ARE DECLARED, NEVER QUOTED above.
EXEMPT_SCAN_LINES = 60
LINK_EXEMPT_RE = re.compile(r"^[ \t]*(?:#+|//+|<!--|\*|-)?[ \t]*km-gate-link-exempt:[ \t]*(.*)$", re.M)
# The H1 carries "(v1.46)" when published and "(v1.46 draft)" while drafted. The version being
# drafted is the same number either way, so both forms are read.
H1_VERSION_RE = re.compile(r"^# .*\((v[0-9]+\.[0-9]+)(?: draft)?\)\s*$", re.M)

INLINE_LINK_RE = re.compile(r"\[[^\]]*\]\(\s*<?([^)<>\s]+)>?(?:\s+[\"'][^)]*[\"'])?\s*\)")
REF_DEF_RE = re.compile(r"^[^\S\n]{0,3}\[[^\]]+\]:[^\S\n]*(\S+)[^\S\n]*$", re.M)
FENCE_RE = re.compile(r"^\s*(```|~~~)")
NON_RELATIVE_RE = re.compile(r"^(https?:|mailto:|ftp:|tel:|data:|#)", re.I)


# ------------------------------------------------------------------------------------------------
# THE LIMITS, AND THIS IS THE ONLY PLACE THEY ARE DEFINED. (v1.55; reduced to one definition in
# v1.58.)
#
# Each entry carries its own STATEMENT, the SUMMARY lines every surface prints beside it, and the
# full ARGUMENT for it. The argument used to live in a numbered prose block in the header, which
# made this "definition" one of three; it is here now so that a limit and the reasoning for it
# cannot drift apart, and so that adding one is genuinely an edit to this structure alone.
#
# `statement` and `summary` are printed in three places -- the passing verdict, the failing
# verdict's one-line summary, and `--limits`, which exists so .github/workflows/release-gate.yml
# can show them in the CI log instead of carrying a hand copy. It carried one, it documented two of
# them, and it had already drifted when an external reviewer read it. `argument` is not printed:
# a CI log wants the statement, and a maintainer wants the reasoning, and the reasoning is here
# where the statement is rather than in a second file that would rot.
#
# NO SURFACE STATES A COUNT OF THESE IN PROSE. Every count is len(LIMITS). Case 15a of
# tests/test_release_gate.sh holds this file to that, because the sentence claiming it and the
# sentence breaking it used to sit 185 lines apart in this same file.
Limit = collections.namedtuple("Limit", "statement summary argument")

LIMITS = (
    Limit(
        "This gate does not run an organisation leakage scan and cannot.",
        ("The denylist is generated from an organisation's own entity names and is kept outside",
         "this repository by design. The instrument's canaries prove the instrument; the",
         "deployment's own fail-closed pre-push hook is the only thing that scans a push."),
        """That scan needs a denylist generated from a real organisation's own entity names, and
        that denylist lives outside this repository BY DESIGN: carrying it here would itself be the
        leakage the guard exists to prevent. So this gate runs the leakage instrument's canaries
        and proves the INSTRUMENT works. It can never prove that a given push is clean. The
        fail-closed pre-push hook on a deployment's own clone is the only thing that scans an
        actual push, and it is local and untracked. This is a stated limit of the gate, not a
        defect awaiting a fix.""",
    ),
    Limit(
        "No runner supplies a second actor.",
        ("The gate requires the unrepaired-tree declaration and cannot verify that an adversarial",
         "pass by someone other than the author took place, nor that any declaration it read is",
         "true."),
        """The minimum viable independence is an adversarial pass, by someone other than the
        change's author, against the specific class being repaired. No runner verifies that it
        happened, and this one does not pretend to. What it CAN do is require the declaration:
        every check under the discovery scope carries a machine-read `km-unrepaired-tree:` line
        recording what happened when it was run against the tree it was written to catch, and a
        missing or malformed line fails the gate. That converts an unverifiable process property
        into a checkable one, which is the move this standard already makes for exemptions, where
        an exemption with no stated reason is refused. The gate checks that a declaration was MADE.
        It cannot check that it is TRUE.""",
    ),
    Limit(
        "This gate reads a check's exit status and cannot see inside it.",
        ("A check that fails internally and returns success passes here. Canaries are what reach",
         "inside a check; this reaches only its verdict."),
        """Found by running this gate against a deliberately broken tree rather than reasoned
        about: a real suite was given a command that does not exist, and the gate PASSED, because
        the suite is not run under `set -e`, swallowed the 127, and exited 0 on its own accounting.
        The gate reported exactly what the check reported. Nothing here reaches a check that fails
        internally and returns success, and no runner that treats a check as a black box can. That
        is what the canary rule the standard already carries is for, and it is why this is a stated
        limit rather than a defect on a list. The refusal on 127 below catches only the case where
        the PROCESS itself ends on the missing command.""",
    ),
    Limit(
        "Discovery reads the working tree but honours the ignore rules.",
        ("A check-shaped file under an ignored path is not discovered. An ignored file is not one",
         "this repository ships; the cost is that a path added to .gitignore leaves the gate",
         "without any edit to the gate or to the check."),
        """That line is drawn on purpose: an ignored file is not a file the repository ships, and a
        gate that ran a vendored dependency's own `tests/` directory would be unusable. The cost is
        real and is stated rather than hidden: a path added to `.gitignore` leaves the gate, by an
        edit to a file that is neither the gate nor the check. Case 19j of
        tests/test_release_gate.sh pins this as a gap and not as a control, so a later change that
        closes it fails there loudly instead of quietly redefining the scope. This is the residual
        scope of the v1.54 discovery repair, written down rather than left to be found.""",
    ),
    Limit(
        "A stable fingerprint is not a stable tree.",
        ("The gate hashes every file it reads, plus the commit and the ref standing at it, before",
         "and after the run and refuses on any difference. A file that changes and changes back",
         "inside the window is identical at both ends and invisible; a file THIS RUN NEVER READ --",
         "one only a discovered check opens -- is not fingerprinted, so a PASS names the inputs it",
         "judged and never the whole tree."),
        """Added in v1.58, widened in v1.59, and it is the residual of the tree-stability repair
        rather than a defect awaiting a fix.
        The run takes about twenty minutes on this repository, which is a wide window for a
        maintainer editing alongside it, and until v1.58 nothing established that the tree at the
        verdict was the tree that was read: an external reviewer watched this gate begin on a clean
        branch, saw the branch change and a discovered check be edited underneath it, and saw it
        return PASS after ~900s still reporting zero changed declarations. What the fingerprint
        buys is a REFUSAL naming what moved. What it does not buy is stated here, in three parts.
        A before/after comparison cannot see a change that is undone inside the window, because
        both ends are identical by construction and no evidence of the middle survives; catching
        that needs a watcher rather than a pair of reads, which is a different instrument with a
        different cost. Two different detached-HEAD states at one commit are indistinguishable for
        the same reason. And the fingerprint covers what THIS RUN READ, which from v1.60 (draft; binds nothing until that version's own owner push) is a
        runtime fact rather than a list: the accessors record every pathspec they enumerate and
        every path they open, so a phase added later is inside the covered set by construction. A
        file NO phase of this gate reads -- a `.yml` workflow, a `.txt`, a licence, a template
        asset that only a discovered check opens -- can still change mid-run unseen, and that is
        the residual now, narrower and differently drawn than the v1.59 one it replaces: it is a
        statement about what was read rather than about which globs a table happened to name.
        Widening it to the whole tree was considered and refused for a mechanical reason rather
        than a stylistic one: the suites and the tools legitimately write inside the tree, so a
        fingerprint over everything, ignored artifacts included, would turn this into a gate that
        refuses every run, which is the failure mode that gets a gate switched off. The ignore
        rules are therefore honoured on both sides. What remains enforced by nothing at all is
        stated rather than implied closed: a phase that obtained a file WITHOUT going through
        git_tracked, git_untracked or read_text -- an `open()` on a path it built itself -- would
        be outside the ledger, and no check in this repository detects that. It is narrower than
        the v1.59 residual, which any unrecognised spelling of a pathspec escaped, and it is not
        zero. A process-wide audit hook was weighed as the way to close it and refused: it would
        record the gate's own source, every temporary file the suites write and every path git
        touches, which is a gate that refuses itself. Case 21h of tests/test_release_gate.sh pins
        what remains outside as a gap and not as a control; cases 21e, 21g, 21g2 and 21g3 hold one
        input class each; and 21j is a REAL added phase reading a class no table names, which must
        be covered with no edit to the case.""",
    ),
)


def print_limits(indent="    "):
    """Print every limit in LIMITS, numbered. The only renderer; there is no second copy."""
    for i, limit in enumerate(LIMITS, 1):
        print("{}{}. {}".format(indent, i, limit.statement))
        for line in limit.summary:
            print("{}   {}".format(indent, line))


class Refusal(Exception):
    """The gate could not evaluate something. Never folded into a verdict."""


def refuse(message):
    raise Refusal(message)


class Reads(object):
    """WHAT THIS RUN ACTUALLY READ, RECORDED AS IT HAPPENED. (v1.60 draft; binds nothing until that version's own owner push.)

    THE GUARANTEE THIS REPLACES WAS A GREP. From v1.59 the covered set was DERIVED from
    INPUT_CLASSES, and the thing that held every phase to it was case 21j of
    tests/test_release_gate.sh grepping this file for `git_tracked(root, [` and requiring no match.
    That check was proved in both directions and it still modelled the wrong class: it enforced a
    SPELLING where its own title claimed a PROPERTY. An external reviewer walked past it in one
    line by writing a real `.txt`-reading phase with a TUPLE pathspec -- `git_tracked(root,
    ("*.txt",))` -- and 21j certified the guarantee while the guarantee was false. Case 21h then
    accepted `notes.txt` mutating mid-run, at which point `notes.txt` WAS an input to this gate, so
    the pin on what lies outside the inputs was certifying the wrong thing as well. This
    repository's own published doctrine says it: proving a check in both directions proves it fires
    on the class it models, never that it models the right class (v1.29/v1.30).

    A STRICTER GREP IS THE SAME DEFECT WITH A LONGER PATTERN. More spellings, a regex over call
    forms -- the next reviewer writes a helper, or a variable, or a comprehension. So the need for
    static analysis is removed instead of being met more carefully: the accessors below RECORD what
    they hand out, and the closing fingerprint covers what was actually read. A phase added
    tomorrow is covered BY CONSTRUCTION, with no list to keep in step and no source-text claim to
    check, and 21j becomes a real added phase that must be covered without an edit to the case.

    Two things are recorded, because the drift report needs both:

      specs  -- every pathspec group enumerated, so the closing read can re-enumerate it and see a
                file APPEAR or DISAPPEAR in a class no static list names.
      first  -- every path handed out or read, digested at the moment it was first seen, so a class
                outside the opening baseline still has a before-value to compare against.

    `first` is EARLIEST-OBSERVATION-WINS and the opening baseline is earlier than any of it, so the
    baseline takes precedence where both hold a path. Recording never refuses: an unreadable input
    is refused by read_text or by the fingerprint on their own terms, and a ledger that raised here
    would turn bookkeeping into a verdict.
    """

    def __init__(self):
        self.specs = []
        self.first = {}

    def spec(self, patterns):
        group = tuple(patterns)
        if group not in self.specs:
            self.specs.append(group)

    def observe(self, root, rel):
        if rel in self.first:
            return
        try:
            self.first[rel] = hashlib.sha256((root / rel).read_bytes()).hexdigest()
        except OSError:
            pass


READS = Reads()


def _git_ls(root, patterns, others):
    """The raw enumeration, recording nothing. The fingerprint uses this; phases do not.

    Kept separate from the recording accessors on purpose: the closing fingerprint enumerates the
    very pathspecs the ledger holds, and an enumerator that recorded its own reads would grow the
    ledger while reading it.
    """
    cmd = ["git", "-C", str(root), "ls-files", "-z"]
    if others:
        cmd += ["--others", "--exclude-standard"]
    cmd += ["--"] + list(patterns)
    try:
        proc = subprocess.run(cmd, capture_output=True)
    except OSError as exc:
        refuse("git could not be executed: {}".format(exc))
    if proc.returncode != 0:
        refuse(
            "git ls-files{} failed in {} ({}); an unlisted {} is not an empty one".format(
                " --others" if others else "", root,
                proc.stderr.decode("utf-8", "replace").strip(),
                "working tree" if others else "repository",
            )
        )
    out = proc.stdout.decode("utf-8", "surrogateescape")
    return sorted(p for p in out.split("\0") if p)


def git_tracked(root, patterns):
    """Tracked paths under root matching the given pathspecs, NUL-separated so a filename carrying
    a space is not split into two names that both fail to exist.

    RECORDS WHAT IT HANDS OUT (v1.60 draft; binds nothing until that version's own owner push). This is the accessor
    every phase uses, and the recording is
    the whole guarantee that the fingerprint covers the phases: see Reads above.
    """
    rels = _git_ls(root, patterns, others=False)
    READS.spec(patterns)
    for rel in rels:
        READS.observe(root, rel)
    return rels


def git_untracked(root, patterns):
    """Untracked, non-ignored paths under root matching the given pathspecs. Records, as its
    tracked mirror does.

    It exists for one reason: the contract orders this gate to run before explicit staging, so a
    check written in the change being gated is untracked at exactly the moment the gate runs.
    `--exclude-standard` keeps the ignore rules honoured, which is limit 4 in the header rather than
    an accident.
    """
    rels = _git_ls(root, patterns, others=True)
    READS.spec(patterns)
    for rel in rels:
        READS.observe(root, rel)
    return rels


def read_text(root, rel):
    """Read a path, and RECORD that it was read (v1.60 draft; binds nothing until that version's own owner push).

    The enumerating accessors above cover every path a phase obtains through a pathspec. This
    covers the other route: a phase that reads a path it derived some other way is still inside the
    covered set, because the set is what was read rather than what a list predicted would be read.
    """
    path = root / rel
    READS.observe(root, rel)
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        refuse("{} is tracked but absent from the working tree".format(rel))
    except UnicodeDecodeError:
        refuse("{} could not be decoded as UTF-8; it is skipped into no verdict".format(rel))
    except OSError as exc:
        refuse("{} could not be read ({})".format(rel, exc))


# --- discovery ----------------------------------------------------------------------------------


def header_of(text):
    """The file's leading comment block: the run of shebang, blank and comment lines at the top.

    Declarations are read from here and nowhere else. A canary file legitimately contains the
    declaration syntax deep in its body, inside the fixtures it writes, and a whole-file search
    reads those as declarations of the canary file itself. The gate found exactly that in its own
    canaries on its first full run. Scoping the search to the header fixes the class rather than
    exempting the one file, and it matches where every check in this repository already puts its
    header material.
    """
    out = []
    for line in text.split("\n"):
        stripped = line.strip()
        if stripped == "" or stripped.startswith("#"):
            out.append(line)
            continue
        break
    return "\n".join(out)


class Check(object):
    def __init__(self, rel, text, tracked=True):
        text = header_of(text)
        self.rel = rel
        self.tracked = tracked
        self.instrument_canary = None
        self.instrument_reason = None
        self.declaration = None
        self.declaration_result = None

        m = INSTRUMENT_RE.search(text)
        if m:
            self.instrument_canary = m.group(1)
            self.instrument_reason = m.group(2).strip()

        m = DECL_RE.search(text)
        if m:
            self.declaration = m.group(1)
            self.declaration_result = m.group(2).strip()

    @property
    def runs(self):
        return self.instrument_canary is None


def check_patterns():
    """The pathspecs that define the DISCOVERY scope: what the gate will run as a check."""
    patterns = []
    for d in CHECK_DIRS:
        for suffix in CHECK_SUFFIXES:
            patterns.append("{}/*{}".format(d, suffix))
            patterns.append("*/{}/*{}".format(d, suffix))
    return patterns


# THE INPUT CLASSES, AND WHY EVERY PHASE TAKES ITS PATHSPECS FROM HERE. (v1.59.)
#
# Every phase of this gate reads one of these classes today, and this structure is what the OPENING
# fingerprint enumerates, so a file is baselined from t=0 rather than from the moment its phase
# happens to reach it. It is NOT the guarantee. From v1.60 (DRAFT; binds nothing until that version's own owner push)
# the guarantee is the READS ledger: the
# accessors record every pathspec they enumerate and every path they open, and the closing
# fingerprint covers that. A phase that reads a class this table does not name is covered anyway --
# see case 21j of tests/test_release_gate.sh, which is a real added phase rather than a grep.
#
# Until v1.59 the fingerprint hashed the discovery class alone, and each phase carried its own
# literal. The gate reads far more than the checks it discovers -- it resolved 112 relative links
# across 172 markdown files, parsed 5 JSON and JSON-LD files and syntax-checked 31 shell and 11
# Python files on the tree at be6e4bf -- so a broken link, an unparseable JSON file or a syntax
# error introduced AFTER its phase had run survived into the final working tree with a PASS over it.
# The specification was the narrow part, not the implementation: the v1.58 brief asked for a
# fingerprint covering the set discovery covers, and that is what was built and honestly registered
# as a residual. A control whose scope is narrower than the thing it certifies is the class this
# repository keeps finding, and here it was written into the instruction.
#
# The v1.59 repair introduced this table AND a grep requiring every phase to draw from it. The
# table was right; the grep was the same class one level up -- a control enforcing a spelling where
# it claimed a property. v1.60 keeps the table as a baseline and makes the property structural.
INPUT_CLASSES = collections.OrderedDict((
    ("checks", check_patterns()),
    ("shell", ["*.sh"]),
    ("python", ["*.py"]),
    ("json", ["*.json", "*.jsonld"]),
    ("markdown", ["*.md"]),
))


def git_identity(root):
    """WHAT IS CHECKED OUT: the commit AND the ref standing at it. (v1.59.)

    Never refuses. An unborn branch and a detached HEAD are real, stable states, and what matters
    here is that the two reads are comparable, not that either resolves.

    Until v1.59 this read `git rev-parse HEAD` alone and the fingerprint's docstring claimed that
    "a branch change is caught even when every file happens to match". That claim was false as
    written: two branches standing at the same commit return the same value, so a same-commit branch
    switch -- the reviewer's own observed case -- was invisible, and what the read actually caught
    was commit movement. Narrowing the claim to commit movement was the other honest repair
    available and it was refused: switching branch IS a change in what is being gated even when the
    commit matches, because the branch is what the maintainer is about to commit to and what a
    reader of the verdict takes the verdict to be about. The promise the docstring made is the one
    worth keeping, so the identity is widened to keep it rather than the sentence narrowed to
    survive.

    A detached HEAD reports the same sentinel on both reads and therefore refuses nothing, which
    case 21d3 of tests/test_release_gate.sh requires in the other direction. Its residual is stated
    rather than implied closed: two DIFFERENT detached states at one commit are indistinguishable
    here, as are two branches switched to and back inside the window, which is the change-and-change-
    back residual in limit 5 wearing a different hat.
    """
    proc = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"], capture_output=True)
    commit = proc.stdout.decode("utf-8", "replace").strip() if proc.returncode == 0 else "<unborn>"
    proc = subprocess.run(["git", "-C", str(root), "symbolic-ref", "-q", "HEAD"],
                          capture_output=True)
    ref = proc.stdout.decode("utf-8", "replace").strip() if proc.returncode == 0 else "<detached>"
    return {"commit": commit, "ref": ref or "<detached>"}


def fingerprint(root, extra_specs=(), extra_rels=()):
    """What the gate read, in a form it can hold against itself when the run ends. (v1.58; scope
    widened from the discovery set to every input class in v1.59.)

    THE TREE AT THE VERDICT MUST BE THE TREE THAT WAS READ, AND UNTIL v1.58 NOTHING SAID SO.
    Discovery and the declaration phase run first, the suites run after, and the whole pass takes
    about twenty minutes on this repository. An external reviewer watched this gate start on a clean
    branch, watched the branch change and a discovered check be edited underneath it, and watched it
    return PASS after ~900s still reporting zero changed declarations. The maintainer's own drafting
    agent was the thing editing the tree; the defect is that the gate cannot TELL, not that anyone
    misbehaved. Twenty minutes is a wide window for a maintainer working alongside a run, and a gate
    whose PASS cannot name the tree it judged certifies nothing.

    THE OBVIOUS REPAIR IS THE WRONG ONE. Running against an immutable snapshot would mean
    snapshotting tracked content, and since v1.54 this gate reads the WORKING tree -- tracked union
    untracked-not-ignored -- precisely because a check authored in the change being gated is
    untracked at the moment the gate runs. A snapshot of tracked content would silently undo v1.54
    and reopen the defect that version closed, which is the worst available outcome here.

    So: fingerprint what the gate actually reads, before and after, and REFUSE on any difference.
    The opening read is every INPUT_CLASS above, tracked union untracked-not-ignored, hashed by
    content so an edit that leaves the size alone is still seen. The ignore rules stay honoured on
    both sides: the suites and the tools legitimately write inside the tree, and a fingerprint over
    ignored artifacts would make the gate refuse itself.

    THE CLOSING READ IS WIDER THAN THE OPENING ONE, AND THAT IS THE v1.60 REPAIR (DRAFT; binds nothing until that version's own owner push). It takes
    `extra_specs` and `extra_rels` from the READS ledger -- every pathspec the run actually
    enumerated and every path it actually read -- so the covered set is a RUNTIME FACT rather than
    a claim about this file's source text. From v1.59 the set was derived from INPUT_CLASSES and a
    grep in case 21j held the phases to it; a phase spelling its pathspec any other way walked
    past that grep, and the guarantee was false while the check certifying it was green. See Reads
    above for why a stricter grep was refused. A phase added tomorrow is covered because it cannot
    obtain a file without the ledger seeing it, not because a list was kept up to date.

    Until v1.59 the set was the DISCOVERY set alone, which is narrower than what the gate reads, and
    v1.58's own case 21e demonstrated the residual with README.md rather than closing it. That case
    is now a control.

    What is checked out rides with the content, as commit AND ref, so a branch change is caught even
    when every file happens to match. See git_identity above: from v1.58 to v1.59 that promise was
    made by this docstring and kept only for commit movement.

    On drift the verdict is a REFUSAL naming what moved. Not a PASS, and not a silent re-run: a
    re-run would hide that the tree is moving under the maintainer, and that is the thing worth
    knowing. The residual is limit 5 and is not hidden here: a file that changes and changes back
    inside the window is byte-identical at both ends, and a file in no input class -- a `.yml`, a
    `.txt`, a licence, a template asset that only a discovered CHECK reads -- is not fingerprinted.
    """
    enumerated = set()
    for patterns in list(INPUT_CLASSES.values()) + [list(g) for g in extra_specs]:
        enumerated |= set(_git_ls(root, patterns, others=False))
        enumerated |= set(_git_ls(root, patterns, others=True))
    digests = {}
    for rel in sorted(enumerated):
        try:
            digests[rel] = hashlib.sha256((root / rel).read_bytes()).hexdigest()
        except OSError as exc:
            refuse(
                "{} is an input to this gate and could not be read to fingerprint the tree ({}); "
                "a tree the gate cannot describe is not one it can return a verdict "
                "about".format(rel, exc)
            )
    # A path the run READ but that no pathspec enumerates any more is hashed leniently rather than
    # refused: if it is gone, its absence is drift and fingerprint_drift names it as disappeared,
    # which is the more useful report of the two.
    for rel in sorted(set(extra_rels) - enumerated):
        try:
            digests[rel] = hashlib.sha256((root / rel).read_bytes()).hexdigest()
        except OSError:
            continue
    return {"identity": git_identity(root), "files": digests}


def fingerprint_drift(before, after):
    """Everything that moved between the two reads, named. An empty list means the tree held."""
    drift = []
    old_id, new_id = before["identity"], after["identity"]
    if old_id["commit"] != new_id["commit"]:
        drift.append("HEAD moved from {} to {}".format(old_id["commit"][:12], new_id["commit"][:12]))
    if old_id["ref"] != new_id["ref"]:
        drift.append("the checked-out ref changed from {} to {}".format(old_id["ref"],
                                                                        new_id["ref"]))
    old, new = before["files"], after["files"]
    for rel in sorted(set(old) - set(new)):
        drift.append("{} disappeared".format(rel))
    for rel in sorted(set(new) - set(old)):
        drift.append("{} appeared".format(rel))
    for rel in sorted(set(new) & set(old)):
        if old[rel] != new[rel]:
            drift.append("{} changed content".format(rel))
    return drift


def discover(root):
    patterns = INPUT_CLASSES["checks"]
    tracked = git_tracked(root, patterns)
    untracked = [r for r in git_untracked(root, patterns) if r not in set(tracked)]
    rels = sorted(set(tracked) | set(untracked))
    if not rels:
        refuse(
            "the discovery set is empty: no {} file in any {} directory, tracked or untracked. An "
            "empty set is not a clean one".format(
                " or ".join(CHECK_SUFFIXES), " or ".join(d + "/" for d in CHECK_DIRS)
            )
        )
    untracked_set = set(untracked)
    checks = [Check(rel, read_text(root, rel), rel not in untracked_set) for rel in rels]

    by_dir = {}
    for c in checks:
        parts = c.rel.split("/")
        for d in CHECK_DIRS:
            if d in parts[:-1]:
                by_dir.setdefault(d, []).append(c)
                break
    for d in CHECK_DIRS:
        if not by_dir.get(d):
            refuse("no check was discovered in any {}/ directory, tracked or untracked; a "
                   "discovery scope that yields nothing is a blind gate, not a clean "
                   "tree".format(d))

    runnable = set(c.rel for c in checks if c.runs)
    for c in checks:
        if c.runs:
            continue
        if not c.instrument_reason:
            refuse("{} declares km-gate-instrument with no reason".format(c.rel))
        if c.instrument_canary not in runnable:
            refuse(
                "{} names {} as its canaries, and that file is not a check this pass will run; an "
                "instrument may be skipped only when something that covers it runs".format(
                    c.rel, c.instrument_canary
                )
            )
    return checks


# --- phase: unrepaired-tree declarations --------------------------------------------------------


def drafted_version(root):
    path = root / "STANDARD.md"
    if not path.exists():
        return None
    m = H1_VERSION_RE.search(read_text(root, "STANDARD.md"))
    return m.group(1) if m else None


def resolve_base(root):
    """The revision a change is measured against. Explicit env first, then the usual remotes."""
    # The explicit value is tried first, then the usual remotes. The fallback matters in CI: a first
    # push to a new branch reports an all-zero "before" revision, and falling back is better than
    # reporting a coverage gap on every branch's first push.
    env = os.environ.get("KM_GATE_BASE")
    candidates = ([env] if env else []) + ["origin/main", "main"]
    for rev in candidates:
        if not rev:
            continue
        proc = subprocess.run(
            ["git", "-C", str(root), "rev-parse", "--verify", "--quiet", rev + "^{commit}"],
            capture_output=True,
        )
        if proc.returncode == 0:
            return rev
    return None


def changed_against(root, base):
    proc = subprocess.run(
        ["git", "-C", str(root), "diff", "--name-only", "-z", base, "--"], capture_output=True
    )
    if proc.returncode != 0:
        return None
    out = proc.stdout.decode("utf-8", "surrogateescape")
    return set(p for p in out.split("\0") if p)


def exists_at(root, base, rel):
    proc = subprocess.run(
        ["git", "-C", str(root), "cat-file", "-e", "{}:{}".format(base, rel)], capture_output=True
    )
    return proc.returncode == 0


def declaration_line_added(root, base, rel):
    """Did this change add or rewrite the file's own km-unrepaired-tree line?"""
    proc = subprocess.run(
        ["git", "-C", str(root), "diff", "-U0", base, "--", rel], capture_output=True
    )
    if proc.returncode != 0:
        return None
    text = proc.stdout.decode("utf-8", "replace")
    for line in text.split("\n"):
        if line.startswith("+") and not line.startswith("+++") and DECL_RE.search(line):
            return True
    return False


def check_declarations(root, checks, self_rel, report):
    failures = []
    counts = {"v": 0, "none": 0, "unrecorded": 0}

    declared = list(checks)
    if self_rel is not None:
        declared = declared + [Check(self_rel, read_text(root, self_rel))]

    for c in declared:
        if c.declaration is None:
            failures.append(
                "{}: no km-unrepaired-tree declaration. A check that adds or changes what the gate "
                "enforces records what it found when it was run against the unrepaired tree; a "
                "missing declaration fails the gate.".format(c.rel)
            )
            continue
        if not c.declaration_result:
            failures.append(
                "{}: km-unrepaired-tree declares '{}' and states no result. The result text is the "
                "declaration; the token alone is not.".format(c.rel, c.declaration)
            )
            continue
        counts["none" if c.declaration == "none" else
               "unrecorded" if c.declaration == "unrecorded" else "v"] += 1

    base = resolve_base(root)
    drafted = drafted_version(root)
    if base is None:
        report.gap(
            "no base revision was resolvable, so the currency of each declaration against the "
            "version being drafted was not checked"
        )
    elif drafted is None:
        report.gap(
            "the drafted version could not be read from STANDARD.md, so declaration currency was "
            "not checked"
        )
    else:
        changed = changed_against(root, base)
        if changed is None:
            report.gap("git diff against {} failed, so declaration currency was not "
                       "checked".format(base))
        else:
            # An untracked check is never named by `git diff --name-only <base>`, so before v1.54 it
            # escaped this phase entirely: the one file class the ADDED sub-rule exists for was the
            # one class it could not reach. It has no blob at the base, so exists_at answers False
            # and it lands in the ADDED arm with no further branching.
            changed = changed | set(c.rel for c in declared if not c.tracked)
            n_added = 0
            n_changed = 0
            for c in declared:
                if c.rel not in changed or c.declaration is None:
                    continue
                if not exists_at(root, base, c.rel):
                    n_added += 1
                    if c.declaration == "unrecorded":
                        failures.append(
                            "{}: added by this change and declares 'unrecorded'. A check born in "
                            "this change has no history to plead; declare {} and record what it "
                            "found against the unrepaired tree, or 'none' with a reason.".format(
                                c.rel, drafted
                            )
                        )
                    elif c.declaration not in (drafted, "none"):
                        failures.append(
                            "{}: added by this change while its km-unrepaired-tree declaration "
                            "names '{}' and the version being drafted is {}.".format(
                                c.rel, c.declaration, drafted
                            )
                        )
                    continue
                n_changed += 1
                touched = declaration_line_added(root, base, c.rel)
                if touched is None:
                    report.gap(
                        "the diff of {} against {} could not be read, so its declaration was not "
                        "checked for re-statement".format(c.rel, base)
                    )
                elif not touched:
                    failures.append(
                        "{}: changed against {} without its km-unrepaired-tree line being among "
                        "the added lines. A check that is edited re-states its declaration, so an "
                        "edit cannot quietly outrun what the declaration claims.".format(
                            c.rel, base
                        )
                    )
            report.note(
                "declaration currency checked against {}: {} check file(s) added, {} changed, of "
                "{} declared".format(base, n_added, n_changed, len(declared))
            )
    return failures, counts, len(declared)


# --- phase: static checks -----------------------------------------------------------------------


def check_shell_syntax(root, extra=()):
    """Tracked shell files, plus any discovered check that is one.

    `extra` carries the untracked discovered checks (v1.54). Without them an unparseable check
    authored in this change would be reported only by whatever its interpreter did when the gate
    tried to run it, and a syntax error deserves to be named as a syntax error before anything is
    executed.
    """
    rels = sorted(set(git_tracked(root, INPUT_CLASSES["shell"]))
                  | set(r for r in extra if r.endswith(".sh")))
    if not rels:
        refuse("no shell file was found; the shell syntax check scanned nothing")
    failures = []
    for rel in rels:
        read_text(root, rel)  # refuses on an unreadable or undecodable file
        proc = subprocess.run(["bash", "-n", str(root / rel)], capture_output=True)
        if proc.returncode != 0:
            failures.append(
                "{}: shell syntax error\n    {}".format(
                    rel, proc.stderr.decode("utf-8", "replace").strip().replace("\n", "\n    ")
                )
            )
    return failures, len(rels)


def check_python_syntax(root, extra=()):
    """Tracked Python files, plus any discovered check that is one. See check_shell_syntax."""
    rels = sorted(set(git_tracked(root, INPUT_CLASSES["python"]))
                  | set(r for r in extra if r.endswith(".py")))
    if not rels:
        refuse("no Python file was found; the Python syntax check scanned nothing")
    failures = []
    for rel in rels:
        src = read_text(root, rel)
        try:
            compile(src, rel, "exec")
        except SyntaxError as exc:
            failures.append("{}: Python syntax error at line {}: {}".format(rel, exc.lineno,
                                                                           exc.msg))
    return failures, len(rels)


def check_json(root):
    rels = git_tracked(root, INPUT_CLASSES["json"])
    if not rels:
        refuse("no tracked JSON or JSON-LD file was found; the parse check scanned nothing")
    failures = []
    for rel in rels:
        src = read_text(root, rel)
        try:
            json.loads(src)
        except ValueError as exc:
            failures.append("{}: does not parse as JSON: {}".format(rel, exc))
    return failures, len(rels)


def strip_fenced(text):
    """Blank out fenced code blocks, keeping line numbers intact so a report can cite a line."""
    out = []
    fenced = False
    for line in text.split("\n"):
        if FENCE_RE.match(line):
            fenced = not fenced
            out.append("")
            continue
        out.append("" if fenced else line)
    return "\n".join(out)


def check_links(root):
    rels = git_tracked(root, INPUT_CLASSES["markdown"])
    if not rels:
        refuse("no tracked markdown file was found; the relative-link check scanned nothing")
    failures = []
    exempt = []
    resolved = 0
    scanned = 0
    for rel in rels:
        text = read_text(root, rel)
        body = strip_fenced(text)
        m = LINK_EXEMPT_RE.search("\n".join(body.split("\n")[:EXEMPT_SCAN_LINES]))
        if m:
            reason = m.group(1).strip()
            if reason.endswith("-->"):
                reason = reason[:-3].strip()
            if not reason:
                refuse("{} declares km-gate-link-exempt with no reason".format(rel))
            exempt.append((rel, reason))
            continue
        scanned += 1
        targets = [(t, "inline") for t in INLINE_LINK_RE.findall(body)]
        targets += [(t, "definition") for t in REF_DEF_RE.findall(body)]
        for target, form in targets:
            if NON_RELATIVE_RE.match(target):
                continue
            path_part = target.split("#", 1)[0].replace("%20", " ")
            if not path_part:
                continue
            resolved += 1
            if path_part.startswith("/"):
                candidate = root / path_part.lstrip("/")
            else:
                candidate = (root / rel).parent / path_part
            if not os.path.exists(str(candidate)):
                failures.append(
                    "{}: {} link target '{}' resolves to nothing".format(rel, form, target)
                )
    return failures, resolved, scanned, len(rels), exempt


# --- phase: run the discovered checks -----------------------------------------------------------


def run_check(root, rel):
    """Returns (status, output). Raises Refusal when the check could not be executed at all."""
    if rel.endswith(".py"):
        argv = [sys.executable, str(root / rel)]
    else:
        argv = ["bash", str(root / rel)]
    try:
        proc = subprocess.run(argv, capture_output=True, cwd=str(root))
    except OSError as exc:
        refuse("{} could not be executed ({}); an unrunnable check is not a passing one".format(
            rel, exc))
    if proc.returncode == 127:
        refuse(
            "{} exited 127, so its interpreter or a command it needs was not found. That is the "
            "gate being unable to run a check, not the check reporting a verdict.".format(rel)
        )
    out = (proc.stdout + proc.stderr).decode("utf-8", "replace")
    return proc.returncode, out


# --- report -------------------------------------------------------------------------------------


class Report(object):
    def __init__(self):
        self.gaps = []
        self.notes = []

    def gap(self, text):
        self.gaps.append(text)

    def note(self, text):
        self.notes.append(text)


def main():
    parser = argparse.ArgumentParser(
        description="Run the whole release gate and return one verdict."
    )
    parser.add_argument("--root", default=None,
                        help="repository root to gate; defaults to the repository this file is in")
    parser.add_argument("--no-suites", action="store_true",
                        help="run discovery, declarations and the static checks only. The verdict "
                             "line is labelled STATIC ONLY and a coverage gap is reported, so this "
                             "mode cannot be recorded as a release verdict")
    parser.add_argument("--limits", action="store_true",
                        help="print the limits this gate states about its own verdict and exit 0 "
                             "without gating anything. This is what a CI definition invokes instead "
                             "of copying the limits into a comment that will drift")
    args = parser.parse_args()

    if args.limits:
        print("km-release-gate states {} limits about its own verdict. A green gate means the "
              "mechanical".format(len(LIMITS)))
        print("checks ran. It does not mean the following are covered.")
        print("")
        print_limits(indent="  ")
        return 0

    here = Path(__file__).resolve()
    root = Path(args.root).resolve() if args.root else here.parent.parent
    report = Report()

    try:
        self_rel = None
        try:
            candidate = here.relative_to(root).as_posix()
            if (root / candidate).exists():
                self_rel = candidate
        except ValueError:
            self_rel = None

        # Taken BEFORE discovery, so a file that appears between the fingerprint and the walk is
        # drift rather than something the gate quietly absorbed.
        before = fingerprint(root)

        checks = discover(root)
        runners = [c for c in checks if c.runs]
        instruments = [c for c in checks if not c.runs]

        failures = []

        decl_failures, decl_counts, decl_total = check_declarations(root, checks, self_rel, report)
        failures += decl_failures

        untracked_rels = [c.rel for c in checks if not c.tracked]

        shell_failures, shell_n = check_shell_syntax(root, untracked_rels)
        failures += shell_failures
        py_failures, py_n = check_python_syntax(root, untracked_rels)
        failures += py_failures
        json_failures, json_n = check_json(root)
        failures += json_failures
        link_failures, links_n, md_scanned, md_n, link_exempt = check_links(root)
        failures += link_failures

        ran = 0
        slowest = []
        started_suites = time.time()
        if args.no_suites:
            report.gap("--no-suites was passed, so no discovered suite or validator was executed")
        else:
            for c in runners:
                started = time.time()
                status, out = run_check(root, c.rel)
                elapsed = time.time() - started
                ran += 1
                slowest.append((elapsed, c.rel))
                mark = "" if c.tracked else " (untracked)"
                if status == 0:
                    print("  ok    {}{}  ({:.0f}s)".format(c.rel, mark, elapsed))
                else:
                    print("  FAIL  {}{} (exit {}, {:.0f}s)".format(c.rel, mark, status, elapsed))
                    for line in out.rstrip("\n").split("\n")[-25:]:
                        print("        {}".format(line))
                    failures.append("{}: exited {}".format(c.rel, status))

        for c in instruments:
            print("  skip  {} (instrument; canaries {})".format(c.rel, c.instrument_canary))
            print("        {}".format(c.instrument_reason))
        for rel, reason in link_exempt:
            print("  skip  {} (link scan)".format(rel))
            print("        {}".format(reason))

        # The tree at the verdict must be the tree that was discovered. Compared here, before
        # either verdict branch, because a FAIL over a tree nobody has is no more useful than a
        # PASS over one: both describe a state that was never whole. See fingerprint() above.
        # THE COVERED SET IS WHAT THIS RUN READ. (v1.60 draft; binds nothing until that version's own owner push.) The closing
        # read re-enumerates every
        # pathspec the run asked for and re-hashes every path it opened, so an input class no list
        # names is still compared; the before side is the opening baseline extended by the ledger's
        # earliest observation of anything the baseline did not hold, and the baseline wins on
        # overlap because it is the earlier of the two reads.
        before_files = dict(READS.first)
        before_files.update(before["files"])
        drift = fingerprint_drift(
            {"identity": before["identity"], "files": before_files},
            fingerprint(root, extra_specs=READS.specs, extra_rels=READS.first),
        )
        if drift:
            refuse(
                "the tree changed while the gate ran, so this verdict would be about no tree that "
                "exists: {}. Re-run the gate on a tree nobody is editing. It refuses rather than "
                "passing, and rather than re-running itself, because a tree moving underneath a "
                "twenty-minute pass is the thing worth knowing.".format("; ".join(drift))
            )

        coverage = (
            "{} check(s) discovered under {}, {} run and {} skipped as instruments covered by "
            "their canaries; {} unrepaired-tree declaration(s) read ({} naming a version, {} "
            "none-with-reason, {} unrecorded); {} shell file(s) syntax-checked; {} Python file(s) "
            "syntax-checked; {} JSON/JSON-LD file(s) parsed; {} relative link(s) resolved across "
            "{} of {} markdown file(s), {} exempt by declaration; {} discovered check(s) "
            "untracked".format(
                len(checks), " and ".join(d + "/" for d in CHECK_DIRS), ran, len(instruments),
                decl_total, decl_counts["v"], decl_counts["none"], decl_counts["unrecorded"],
                shell_n, py_n, json_n, links_n, md_scanned, md_n, len(link_exempt),
                len(untracked_rels),
            )
        )

        if slowest:
            slowest.sort(reverse=True)
            report.note(
                "the discovered checks took {:.0f}s in total; the slowest were {}".format(
                    time.time() - started_suites,
                    ", ".join("{} at {:.0f}s".format(r, e) for e, r in slowest[:3]),
                )
            )

        for note in report.notes:
            print("  note: {}".format(note))
        for gap in report.gaps:
            print("  COVERAGE GAP: {}".format(gap))

        if failures:
            print("")
            print("FAIL release-gate: {} finding(s)".format(len(failures)))
            for f in failures:
                print("  - {}".format(f))
            print("  coverage: {}".format(coverage))
            print("  {} limits apply to this verdict too; run --limits to read them.".format(
                len(LIMITS)))
            return 1

        # A run that executed no check must not be recordable as a release verdict. The label is
        # part of the verdict line rather than a note beside it, so a pass copied into a record
        # carries the qualification with it and cannot be grepped for as an ordinary pass.
        label = "PASS release-gate (STATIC ONLY, NOT A RELEASE VERDICT)" if args.no_suites \
            else "PASS release-gate"
        print("")
        print("{}: {}".format(label, coverage))
        print("  {} limits, because a pass here is read as more than it is:".format(len(LIMITS)))
        print_limits()
        return 0

    except Refusal as exc:
        print("")
        print("REFUSED release-gate: {}".format(exc))
        print("  A refusal is not a pass. The gate could not evaluate the tree.")
        return 2


if __name__ == "__main__":
    sys.exit(main())
