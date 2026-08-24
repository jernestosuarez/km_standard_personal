#!/usr/bin/env python3
# km-release-gate: the one command that runs the whole gate and returns one verdict.
#
# km-unrepaired-tree: v1.46 | run against a deliberately broken tree (a suite made to fail, a suite made unexecutable, an emptied discovery set, a stripped declaration) and confirmed to refuse or fail in each; see tests/test_release_gate.sh.
#
# Standard: STANDARD.md §"Publishing a version" step 5, and §"Standard Maintainer" under
# "A gate runs before publication, and it declares what it cannot do".
#
#   python3 tools/km-release-gate.py [--root PATH] [--no-suites]
#
# Exit: 0  PASS     everything discovered ran and every phase passed; the coverage line says what
#                     was looked at
#       1  FAIL     a suite, a validator, a syntax check, a parse, a link, or a required
#                     unrepaired-tree declaration failed
#       2  REFUSED  the gate could not evaluate: no repository, an empty discovery set, an
#                     unreadable or undecodable file, a discovered check that could not be executed,
#                     or an exemption the gate could not honour
#
# Neither 1 nor 2 is a pass. The distinction says whether the tree is bad or the gate was blind, and
# a gate that reported "blind" as "clean" would be the absence-shaped pass this repository has
# already been bitten by three times.
#
# ------------------------------------------------------------------------------------------------
# WHAT THIS GATE CANNOT DO. The first two limits are stated here, in the standard, and in the CI
# workflow, because a green line from this command is read as "safe to publish" and neither of them
# is covered by it. The third was found by running this gate against a deliberately broken tree, and
# it is recorded in the same place rather than in a report nobody re-reads.
#
# 1. IT CANNOT RUN THE ORGANISATION LEAKAGE SCAN. That scan needs a denylist generated from a real
#    organisation's own entity names, and that denylist lives outside this repository BY DESIGN:
#    carrying it here would itself be the leakage the guard exists to prevent. So this gate runs the
#    leakage instrument's canaries and proves the INSTRUMENT works. It can never prove that a given
#    push is clean. The fail-closed pre-push hook on a deployment's own clone is the only thing that
#    scans an actual push, and it is local and untracked. This is a stated limit of the gate, not a
#    defect awaiting a fix.
#
# 3. IT READS A CHECK'S EXIT STATUS AND CANNOT SEE INSIDE IT. This was found by running the gate
#    against a deliberately broken tree rather than reasoned about: a real suite was given a command
#    that does not exist, and the gate PASSED, because the suite is not run under `set -e`, swallowed
#    the 127, and exited 0 on its own accounting. The gate reported exactly what the check reported.
#    Nothing here reaches a check that fails internally and returns success, and no runner that
#    treats a check as a black box can. That is what the canary rule the standard already carries is
#    for, and it is why this limit is stated beside the other two rather than filed as a defect. The
#    refusal on 127 below catches only the case where the PROCESS itself ends on the missing command.
#
# 2. IT CANNOT SUPPLY A SECOND ACTOR. The minimum viable independence is an adversarial pass, by
#    someone other than the change's author, against the specific class being repaired. No runner
#    verifies that it happened, and this one does not pretend to. What it CAN do is require the
#    declaration: every check under the discovery scope carries a machine-read
#    `km-unrepaired-tree:` line recording what happened when it was run against the tree it was
#    written to catch, and a missing or malformed line fails the gate. That converts an unverifiable
#    process property into a checkable one, which is the move this standard already makes for
#    exemptions, where an exemption with no stated reason is refused. The gate checks that a
#    declaration was MADE. It cannot check that it is TRUE.
#
# ------------------------------------------------------------------------------------------------
# DISCOVERY, AND WHY IT IS NOT A LIST.
#
# Every tracked `*.sh` and `*.py` file in any directory named `tests/` or `scripts/`, at the root or
# nested anywhere in the tree, is a discovered check. The two directory names are a scope
# declaration; the checks themselves are never enumerated here, so a suite added tomorrow is picked
# up with no edit to this file. A list held beside a runner is a hand-maintained memory of directory
# state, which is the artifact class this standard records as the one that rots.
#
# The scope is deliberately not limited to the root `tests/` and `scripts/`. A suite sitting in a
# component's own `tests/` directory is a suite, and a gate that looked only at the root would report
# a clean tree for the place it never looked, which is the failure class this repository already
# names.
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
LINK_EXEMPT_RE = re.compile(r"km-gate-link-exempt:[ \t]*(.*)")
# The H1 carries "(v1.46)" when published and "(v1.46 draft)" while drafted. The version being
# drafted is the same number either way, so both forms are read.
H1_VERSION_RE = re.compile(r"^# .*\((v[0-9]+\.[0-9]+)(?: draft)?\)\s*$", re.M)

INLINE_LINK_RE = re.compile(r"\[[^\]]*\]\(\s*<?([^)<>\s]+)>?(?:\s+[\"'][^)]*[\"'])?\s*\)")
REF_DEF_RE = re.compile(r"^[^\S\n]{0,3}\[[^\]]+\]:[^\S\n]*(\S+)[^\S\n]*$", re.M)
FENCE_RE = re.compile(r"^\s*(```|~~~)")
NON_RELATIVE_RE = re.compile(r"^(https?:|mailto:|ftp:|tel:|data:|#)", re.I)


class Refusal(Exception):
    """The gate could not evaluate something. Never folded into a verdict."""


def refuse(message):
    raise Refusal(message)


def git_tracked(root, patterns):
    """Tracked paths under root matching the given pathspecs, NUL-separated so a filename
    carrying a space is not split into two names that both fail to exist."""
    cmd = ["git", "-C", str(root), "ls-files", "-z", "--"] + list(patterns)
    try:
        proc = subprocess.run(cmd, capture_output=True)
    except OSError as exc:
        refuse("git could not be executed: {}".format(exc))
    if proc.returncode != 0:
        refuse(
            "git ls-files failed in {} ({}); an unlisted repository is not an empty one".format(
                root, proc.stderr.decode("utf-8", "replace").strip()
            )
        )
    out = proc.stdout.decode("utf-8", "surrogateescape")
    return sorted(p for p in out.split("\0") if p)


def read_text(root, rel):
    path = root / rel
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
    def __init__(self, rel, text):
        text = header_of(text)
        self.rel = rel
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


def discover(root):
    patterns = []
    for d in CHECK_DIRS:
        for suffix in CHECK_SUFFIXES:
            patterns.append("{}/*{}".format(d, suffix))
            patterns.append("*/{}/*{}".format(d, suffix))
    rels = git_tracked(root, patterns)
    if not rels:
        refuse(
            "the discovery set is empty: no tracked {} file in any {} directory. An empty set is "
            "not a clean one".format(
                " or ".join(CHECK_SUFFIXES), " or ".join(d + "/" for d in CHECK_DIRS)
            )
        )
    checks = [Check(rel, read_text(root, rel)) for rel in rels]

    by_dir = {}
    for c in checks:
        parts = c.rel.split("/")
        for d in CHECK_DIRS:
            if d in parts[:-1]:
                by_dir.setdefault(d, []).append(c)
                break
    for d in CHECK_DIRS:
        if not by_dir.get(d):
            refuse("no tracked check was discovered in any {}/ directory; a discovery scope that "
                   "yields nothing is a blind gate, not a clean tree".format(d))

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


def check_shell_syntax(root):
    rels = git_tracked(root, ["*.sh"])
    if not rels:
        refuse("no tracked shell file was found; the shell syntax check scanned nothing")
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


def check_python_syntax(root):
    rels = git_tracked(root, ["*.py"])
    if not rels:
        refuse("no tracked Python file was found; the Python syntax check scanned nothing")
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
    rels = git_tracked(root, ["*.json", "*.jsonld"])
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
    rels = git_tracked(root, ["*.md"])
    if not rels:
        refuse("no tracked markdown file was found; the relative-link check scanned nothing")
    failures = []
    exempt = []
    resolved = 0
    scanned = 0
    for rel in rels:
        text = read_text(root, rel)
        m = LINK_EXEMPT_RE.search(text)
        if m:
            reason = m.group(1).strip()
            if not reason:
                refuse("{} declares km-gate-link-exempt with no reason".format(rel))
            exempt.append((rel, reason))
            continue
        scanned += 1
        body = strip_fenced(text)
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
    args = parser.parse_args()

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

        checks = discover(root)
        runners = [c for c in checks if c.runs]
        instruments = [c for c in checks if not c.runs]

        failures = []

        decl_failures, decl_counts, decl_total = check_declarations(root, checks, self_rel, report)
        failures += decl_failures

        shell_failures, shell_n = check_shell_syntax(root)
        failures += shell_failures
        py_failures, py_n = check_python_syntax(root)
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
                if status == 0:
                    print("  ok    {}  ({:.0f}s)".format(c.rel, elapsed))
                else:
                    print("  FAIL  {} (exit {}, {:.0f}s)".format(c.rel, status, elapsed))
                    for line in out.rstrip("\n").split("\n")[-25:]:
                        print("        {}".format(line))
                    failures.append("{}: exited {}".format(c.rel, status))

        for c in instruments:
            print("  skip  {} (instrument; canaries {})".format(c.rel, c.instrument_canary))
            print("        {}".format(c.instrument_reason))
        for rel, reason in link_exempt:
            print("  skip  {} (link scan)".format(rel))
            print("        {}".format(reason))

        coverage = (
            "{} check(s) discovered under {}, {} run and {} skipped as instruments covered by "
            "their canaries; {} unrepaired-tree declaration(s) read ({} naming a version, {} "
            "none-with-reason, {} unrecorded); {} shell file(s) syntax-checked; {} Python file(s) "
            "syntax-checked; {} JSON/JSON-LD file(s) parsed; {} relative link(s) resolved across "
            "{} of {} markdown file(s), {} exempt by declaration".format(
                len(checks), " and ".join(d + "/" for d in CHECK_DIRS), ran, len(instruments),
                decl_total, decl_counts["v"], decl_counts["none"], decl_counts["unrecorded"],
                shell_n, py_n, json_n, links_n, md_scanned, md_n, len(link_exempt),
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
            print("  limits: no organisation leakage scan; no second actor; and a check that fails")
            print("          internally and returns success is not seen. See the passing text.")
            return 1

        # A run that executed no check must not be recordable as a release verdict. The label is
        # part of the verdict line rather than a note beside it, so a pass copied into a record
        # carries the qualification with it and cannot be grepped for as an ordinary pass.
        label = "PASS release-gate (STATIC ONLY, NOT A RELEASE VERDICT)" if args.no_suites \
            else "PASS release-gate"
        print("")
        print("{}: {}".format(label, coverage))
        print("  limits, because a pass here is read as more than it is:")
        print("    1. This gate does not run an organisation leakage scan and cannot. The denylist is")
        print("       generated from an organisation's own entity names and is kept outside this")
        print("       repository by design. The instrument's canaries prove the instrument; the")
        print("       deployment's own fail-closed pre-push hook is the only thing that scans a push.")
        print("    2. No runner supplies a second actor. The gate requires the unrepaired-tree")
        print("       declaration and cannot verify that an adversarial pass by someone other than")
        print("       the author took place, nor that any declaration it read is true.")
        print("    3. This gate reads a check's exit status and cannot see inside it. A check that")
        print("       fails internally and returns success passes here. Canaries are what reach")
        print("       inside a check; this reaches only its verdict.")
        return 0

    except Refusal as exc:
        print("")
        print("REFUSED release-gate: {}".format(exc))
        print("  A refusal is not a pass. The gate could not evaluate the tree.")
        return 2


if __name__ == "__main__":
    sys.exit(main())
