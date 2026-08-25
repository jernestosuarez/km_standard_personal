#!/bin/bash
# km-unrepaired-tree: v1.55 | re-stated for the exemption-anchoring and limits-mechanism repair. The seven assertions added here (13c, 13d, 13e, 20, 20b, 20c, 20d) were run against the unrepaired gate and the unrepaired workflow at 13dec55 before either was touched: 13c and 13d each reported "expected exit 1, got 0", the quoted token having exempted a document carrying a genuinely broken link; 20 reported "--limits printed 0 of 0 defined limits (exit 2)", the flag not existing; 20b and 20c failed with it. Two passed there, and only one of them legitimately: 13e, because a real declaration at the start of a line is honoured by both readers, and 20d, which passed for the wrong reason until its assertion was scoped to the comment block above runs-on. The v1.46 declaration this replaces still holds: run against deliberately broken trees before the gate was trusted: a suite made to fail, a suite whose interpreter is absent, an emptied discovery set, a stripped declaration, a broken relative link, unparseable JSON, a shell syntax error and a Python syntax error. Every one of those trees was gated and every one produced FAIL or REFUSED, never PASS.
#
# Canaries for the release gate (tools/km-release-gate.py), added in v1.46.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves the gate fails when a discovered suite fails, refuses when a discovered suite cannot be
# executed, refuses when the discovery set is empty, fails when a required unrepaired-tree
# declaration is missing or empty, and fails on each static check it runs. It proves the gate does
# NOT fire on a tree in which everything passes, and that its passing line states its coverage. It
# proves the declaration mechanism in both directions: a check this change ADDS may not plead
# `unrecorded`, and a check this change CHANGES must have its declaration line among the lines the
# change added, with the repaired form of each required to pass.
#
# It does NOT prove that an adversarial pass by a second actor took place, because no runner can.
# It does NOT prove that any unrepaired-tree declaration is TRUE; it proves one was made and, where
# a base revision resolves, that it was re-stated when its check was edited. That gap is the point
# of limit 2 in the gate's own header and is stated rather than papered over.
#
# It does NOT prove an organisation's tree is leakage-free. Nothing here can: the denylist lives
# outside this repository by design. What runs here is the leakage INSTRUMENT's canaries.
#
# BOTH DIRECTIONS. A gate reports by failing, so a green run against the real repository proves
# nothing on its own. Every case below builds a fixture repository, breaks exactly one thing, and
# requires the stated verdict; case 1 and case 14 give it trees that are whole and require PASS.
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$ROOT/tools/km-release-gate.py"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

DECL='# km-unrepaired-tree: v9.9 | fixture check written for this canary run; run first against the fixture tree with the violation present, where it failed.'

note() { printf '%s\n' "$*"; }

# run_gate <fixture-dir> [extra-args...] -> prints combined output, returns the gate's status.
# The status is read UNPIPED, because a pipeline reports the tail of the pipe and would mask it.
run_gate() {
  local d="$1"; shift
  local out status
  out=$(cd "$d" && KM_GATE_BASE="${KM_GATE_BASE:-}" python3 "$GATE" --root "$d" "$@" 2>&1)
  status=$?
  printf '%s' "$out"
  return $status
}

# expect <name> <fixture> <expected-status> <needle>
expect() {
  local name="$1" d="$2" want="$3" needle="$4"; shift 4
  local out status
  out=$(run_gate "$d" "$@")
  status=$?
  if [ "$status" -ne "$want" ]; then
    note "FAIL: $name: expected exit $want, got $status"
    printf '%s\n' "$out" | sed 's/^/       /'
    fail=1
    return
  fi
  if ! printf '%s\n' "$out" | grep -Fq "$needle"; then
    note "FAIL: $name: exit $want as expected, but the output never said: $needle"
    printf '%s\n' "$out" | sed 's/^/       /'
    fail=1
    return
  fi
  note "PASS: $name"
}

# mkfixture <dir>: a whole tree with one suite, one validator, a standard, a README, a JSON file.
mkfixture() {
  local d="$1"
  mkdir -p "$d/tests" "$d/scripts"
  printf '#!/bin/bash\n%s\necho "alpha suite passed"\nexit 0\n' "$DECL" > "$d/tests/test_alpha.sh"
  printf '#!/usr/bin/env python3\n%s\nprint("alpha validator passed")\n' "$DECL" \
    > "$d/scripts/validate_alpha.py"
  printf '# Fixture Standard (v9.9)\n\nSee [the readme](README.md).\n' > "$d/STANDARD.md"
  printf '# Fixture readme\n\nSee [the standard](STANDARD.md).\n' > "$d/README.md"
  printf '{"fixture": true}\n' > "$d/data.json"
  git -C "$d" init -q 2>/dev/null
  git -C "$d" config user.email fixture@example.invalid
  git -C "$d" config user.name Fixture
  git -C "$d" add -A >/dev/null
  git -C "$d" commit -qm "fixture" >/dev/null
  git -C "$d" rev-parse HEAD
}

# ================================================================================================
# 1. The negative direction: a whole tree PASSES, and the passing line states its coverage.
#    A gate that fired here would prove as little as one that never fires.
# ================================================================================================
c="$work/clean"; base=$(mkfixture "$c")
KM_GATE_BASE="$base" expect "1. a whole tree passes" "$c" 0 "PASS release-gate:"
KM_GATE_BASE="$base" expect "1b. the passing line states its coverage" "$c" 0 \
  "2 check(s) discovered under tests/ and scripts/, 2 run"
KM_GATE_BASE="$base" expect "1c. the passing output states the leakage limit" "$c" 0 \
  "does not run an organisation leakage scan and cannot"
KM_GATE_BASE="$base" expect "1c2. the passing output states the second-actor limit" "$c" 0 \
  "No runner supplies a second actor"
KM_GATE_BASE="$base" expect "1c3. the passing output states the exit-status limit" "$c" 0 \
  "cannot see inside it"
KM_GATE_BASE="$base" expect "1d. the passing line counts what the static phases looked at" "$c" 0 \
  "relative link(s) resolved across"

# ================================================================================================
# 2. A discovered suite FAILS -> the gate fails and names it.
# ================================================================================================
c="$work/suitefail"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\necho "alpha suite broke"\nexit 1\n' "$DECL" > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "2. a failing suite fails the gate" "$c" 1 "tests/test_alpha.sh: exited 1"

# ================================================================================================
# 3. A discovered VALIDATOR fails -> the gate fails. Both categories are run, not the suites alone.
# ================================================================================================
c="$work/valfail"; base=$(mkfixture "$c")
printf '#!/usr/bin/env python3\n%s\nimport sys\nsys.exit(3)\n' "$DECL" \
  > "$c/scripts/validate_alpha.py"
KM_GATE_BASE="$base" expect "3. a failing validator fails the gate" "$c" 1 \
  "scripts/validate_alpha.py: exited 3"

# ================================================================================================
# 4. A discovered suite CANNOT EXECUTE -> REFUSED. An unrunnable check is not a passing one, and
#    the gate must not fold "I could not run it" into a verdict about the tree.
# ================================================================================================
c="$work/unrunnable"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\nkm-no-such-interpreter-xyz\n' "$DECL" > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "4. a suite that cannot execute refuses" "$c" 2 \
  "exited 127"
KM_GATE_BASE="$base" expect "4b. the refusal says it is not a pass" "$c" 2 \
  "A refusal is not a pass"

# ================================================================================================
# 5. An EMPTY discovery set -> REFUSED. An empty set is not a clean one.
# ================================================================================================
c="$work/empty"; mkdir -p "$c"
git -C "$c" init -q 2>/dev/null
git -C "$c" config user.email fixture@example.invalid
git -C "$c" config user.name Fixture
printf '# Fixture Standard (v9.9)\n' > "$c/STANDARD.md"
git -C "$c" add -A >/dev/null && git -C "$c" commit -qm empty >/dev/null
expect "5. an empty discovery set refuses" "$c" 2 "the discovery set is empty"

# 5b. A discovery scope where one of the two directories yields nothing is equally blind.
c="$work/halfempty"; base=$(mkfixture "$c")
git -C "$c" rm -q "scripts/validate_alpha.py" >/dev/null
KM_GATE_BASE="$base" expect "5b. a discovery directory yielding nothing refuses" "$c" 2 \
  "no check was discovered in any scripts/ directory, tracked or untracked"

# 5c. Not a repository at all. An unlistable tree is not an empty one.
c="$work/norepo"; mkdir -p "$c/tests"
expect "5c. a tree that is not a repository refuses" "$c" 2 "git ls-files failed"

# ================================================================================================
# 6. A MISSING declaration fails the gate. This is the mechanism Part C is about.
# ================================================================================================
c="$work/nodecl"; base=$(mkfixture "$c")
printf '#!/bin/bash\necho ok\n' > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "6. a missing unrepaired-tree declaration fails the gate" "$c" 1 \
  "no km-unrepaired-tree declaration"

# 6b. A declaration whose result text is empty is a token, not a declaration.
c="$work/emptydecl"; base=$(mkfixture "$c")
printf '#!/bin/bash\n# km-unrepaired-tree: v9.9 | \necho ok\n' > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "6b. a declaration with no result text fails the gate" "$c" 1 \
  "states no result"

# 6c. The other direction, on the very file case 6 stripped: restore it byte for byte and the gate
#     passes. A gate that failed here would be failing on everything, which proves nothing.
c="$work/nodecl"
git -C "$c" checkout -- tests/test_alpha.sh
KM_GATE_BASE="$base" expect "6c. the stripped declaration restored, the gate passes" "$c" 0 \
  "PASS release-gate:"

# ================================================================================================
# 7. CURRENCY, sub-rule ADDED: a check this change adds may not plead `unrecorded`.
# ================================================================================================
c="$work/added"; base=$(mkfixture "$c")
printf '#!/bin/bash\n# km-unrepaired-tree: unrecorded | nothing was run.\necho ok\n' \
  > "$c/tests/test_beta.sh"
git -C "$c" add tests/test_beta.sh >/dev/null
KM_GATE_BASE="$base" expect "7. an added check pleading 'unrecorded' fails the gate" "$c" 1 \
  "added by this change and declares 'unrecorded'"

# 7b. The repaired form: the same added check naming the drafted version passes.
printf '#!/bin/bash\n%s\necho ok\n' "$DECL" > "$c/tests/test_beta.sh"
KM_GATE_BASE="$base" expect "7b. the added check naming the drafted version passes" "$c" 0 \
  "PASS release-gate:"

# 7c. An added check naming some OTHER version is not current either.
printf '#!/bin/bash\n# km-unrepaired-tree: v1.1 | run long ago against something else.\necho ok\n' \
  > "$c/tests/test_beta.sh"
KM_GATE_BASE="$base" expect "7c. an added check naming a stale version fails the gate" "$c" 1 \
  "the version being drafted is v9.9"

# ================================================================================================
# 8. CURRENCY, sub-rule CHANGED: editing a check without re-stating its declaration fails.
# ================================================================================================
c="$work/changed"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\necho "alpha suite passed"\necho "and something new"\n' "$DECL" \
  > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "8. a changed check with an untouched declaration fails the gate" "$c" 1 \
  "without its km-unrepaired-tree line being among"

# 8b. The repaired form: re-state the declaration and the same edit passes.
printf '#!/bin/bash\n# km-unrepaired-tree: v9.9 | re-stated for this edit; re-run against the fixture tree carrying the violation, where it failed.\necho "alpha suite passed"\necho "and something new"\n' \
  > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "8b. the declaration re-stated, the same edit passes" "$c" 0 \
  "PASS release-gate:"

# 8c. No base resolvable at all -> a COVERAGE GAP, never folded into the verdict. The branch is
#     renamed away from the names the gate falls back to, so nothing resolves on any host.
c="$work/nobase"; base=$(mkfixture "$c")
git -C "$c" branch -M km-fixture-trunk
KM_GATE_BASE="km-no-such-revision-xyz" expect "8c. an unresolvable base is a coverage gap, not a verdict" \
  "$c" 0 "COVERAGE GAP: no base revision was resolvable"

# 8d. An unresolvable explicit base FALLS BACK to the usual branch rather than giving up. A first
#     push to a new branch reports an all-zero revision, and a gate that reported a coverage gap on
#     every branch's first push would check currency almost never.
c="$work/fallback"; base=$(mkfixture "$c")
git -C "$c" branch -M main
KM_GATE_BASE="0000000000000000000000000000000000000000" \
  expect "8d. an unresolvable explicit base falls back to the usual branch" "$c" 0 \
  "declaration currency checked against main"

# ================================================================================================
# 9. The INSTRUMENT exemption: skipped with its reason, and refused unless something covers it.
# ================================================================================================
c="$work/instrument"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\n# km-gate-instrument: tests/test_alpha.sh | takes a required argument and exits 2 when run bare.\n[ $# -eq 1 ] || exit 2\n' \
  "$DECL" > "$c/tests/test_gamma.sh"
git -C "$c" add tests/test_gamma.sh >/dev/null
KM_GATE_BASE="$base" expect "9. an instrument is skipped with its reason and its canaries named" "$c" 0 \
  "skip  tests/test_gamma.sh (instrument; canaries tests/test_alpha.sh)"
KM_GATE_BASE="$base" expect "9b. the coverage line counts the skip rather than hiding it" "$c" 0 \
  "1 skipped as instruments covered by their canaries"

# 9c. An instrument naming canaries that will not run is a check deleted by one comment line.
printf '#!/bin/bash\n%s\n# km-gate-instrument: tests/test_nowhere.sh | takes a required argument.\nexit 2\n' \
  "$DECL" > "$c/tests/test_gamma.sh"
KM_GATE_BASE="$base" expect "9c. an instrument whose canaries do not run refuses" "$c" 2 \
  "is not a check this pass will run"

# 9d. An instrument declaration with no reason refuses. No exclusion is silent.
printf '#!/bin/bash\n%s\n# km-gate-instrument: tests/test_alpha.sh | \nexit 2\n' \
  "$DECL" > "$c/tests/test_gamma.sh"
KM_GATE_BASE="$base" expect "9d. an instrument exemption with no reason refuses" "$c" 2 \
  "declares km-gate-instrument with no reason"

# ================================================================================================
# 10. The static checks, one broken thing each.
# ================================================================================================
c="$work/shellsyntax"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\nif [ 1 -eq 1 ]; then\n' "$DECL" > "$c/broken.sh"
git -C "$c" add broken.sh >/dev/null
KM_GATE_BASE="$base" expect "10. a shell syntax error fails the gate" "$c" 1 \
  "broken.sh: shell syntax error"

c="$work/pysyntax"; base=$(mkfixture "$c")
printf '#!/usr/bin/env python3\n%s\ndef broken(\n' "$DECL" > "$c/broken.py"
git -C "$c" add broken.py >/dev/null
KM_GATE_BASE="$base" expect "10b. a Python syntax error fails the gate" "$c" 1 \
  "broken.py: Python syntax error"

c="$work/badjson"; base=$(mkfixture "$c")
printf '{"unterminated": \n' > "$c/data.json"
KM_GATE_BASE="$base" expect "10c. unparseable JSON fails the gate" "$c" 1 \
  "data.json: does not parse as JSON"

c="$work/badjsonld"; base=$(mkfixture "$c")
printf 'not json at all\n' > "$c/graph.jsonld"
git -C "$c" add graph.jsonld >/dev/null
KM_GATE_BASE="$base" expect "10d. unparseable JSON-LD fails the gate" "$c" 1 \
  "graph.jsonld: does not parse as JSON"

c="$work/badlink"; base=$(mkfixture "$c")
printf '# Fixture readme\n\nSee [the missing thing](docs/absent.md).\n' > "$c/README.md"
KM_GATE_BASE="$base" expect "10e. a relative link resolving to nothing fails the gate" "$c" 1 \
  "link target 'docs/absent.md' resolves to nothing"

# ================================================================================================
# 11. The link check does NOT over-fire. A check that matches everything proves as little as one
#     that matches nothing.
# ================================================================================================
c="$work/goodlinks"; base=$(mkfixture "$c")
printf '# Fixture readme\n\n[std](STANDARD.md) [anchored](STANDARD.md#heading) [remote](https://example.invalid/x)\n[spaced](data.json) and a fenced example that names nothing real:\n\n```\n[broken](does/not/exist.md)\n```\n' \
  > "$c/README.md"
KM_GATE_BASE="$base" expect "11. resolving, anchored, remote and fenced links do not fire" "$c" 0 \
  "PASS release-gate:"

# ================================================================================================
# 12. An UNDECODABLE tracked file refuses. A file skipped into a verdict is a verdict about a file
#     nobody read.
# ================================================================================================
c="$work/undecodable"; base=$(mkfixture "$c")
printf 'valid start \377\376 invalid\n' > "$c/notes.md"
git -C "$c" add notes.md >/dev/null
KM_GATE_BASE="$base" expect "12. an undecodable tracked file refuses" "$c" 2 \
  "could not be decoded as UTF-8"

# ================================================================================================
# 13. The link exemption needs a reason, and the reason is printed.
# ================================================================================================
c="$work/linkexempt"; base=$(mkfixture "$c")
printf '# Fixture readme\n\nkm-gate-link-exempt: this fixture names paths that are deliberately absent.\n\n[gone](docs/absent.md)\n' \
  > "$c/README.md"
KM_GATE_BASE="$base" expect "13. a link exemption with a reason is honoured and printed" "$c" 0 \
  "this fixture names paths that are deliberately absent"

printf '# Fixture readme\n\nkm-gate-link-exempt:\n\n[gone](docs/absent.md)\n' > "$c/README.md"
KM_GATE_BASE="$base" expect "13b. a link exemption with no reason refuses" "$c" 2 \
  "declares km-gate-link-exempt with no reason"

# 13c-13e (v1.55). An exemption is DECLARED, never QUOTED. Until v1.55 the gate searched the raw
# markdown for the token before stripping fenced blocks and with no anchor at all, so a document
# that merely showed the syntax removed itself from the scan. Measured on the real repository at
# 13dec55: README.md with a broken link and a fenced example reported 0 link failures and
# "153 of 154 markdown files scanned, 1 exempt"; without the fenced example the same tree reported
# the broken link and 25 more resolved links. Each case below carries a genuinely broken link, so a
# gate that honours the quotation passes and a gate that does not fails and names the link.
printf '# Fixture readme\n\nA document opts out like this:\n\n```text\nkm-gate-link-exempt: only an example of the syntax\n```\n\n[gone](docs/absent.md)\n' \
  > "$c/README.md"
KM_GATE_BASE="$base" expect "13c. a FENCED quotation of the token does not exempt the document" "$c" 1 \
  "link target 'docs/absent.md' resolves to nothing"

printf '# Fixture readme\n\nA file opts out by writing `km-gate-link-exempt: <reason>` near its top.\n\n[gone](docs/absent.md)\n' \
  > "$c/README.md"
KM_GATE_BASE="$base" expect "13d. a MID-SENTENCE quotation of the token does not exempt the document" "$c" 1 \
  "link target 'docs/absent.md' resolves to nothing"

printf '# Fixture readme\n\n<!-- km-gate-link-exempt: declared at the start of a line, in a comment -->\n\n[gone](docs/absent.md)\n' \
  > "$c/README.md"
KM_GATE_BASE="$base" expect "13e. a real declaration at the start of a line is still honoured" "$c" 0 \
  "declared at the start of a line, in a comment"

# ================================================================================================
# 14. The whole-tree pass once more, after every case above has broken something, so a fixture
#     that leaked state into the clean tree cannot hide.
# ================================================================================================
c="$work/clean2"; base=$(mkfixture "$c")
KM_GATE_BASE="$base" expect "14. a whole tree still passes at the end of the run" "$c" 0 \
  "PASS release-gate:"

# ================================================================================================
# 16. Declarations are read from the file's LEADING COMMENT BLOCK and nowhere else.
#
#     This is not a hypothetical. On the gate's first full run against the real repository it
#     REFUSED, because this very file writes instrument declarations into the fixtures it builds and
#     a whole-file search read one of them as this file's own. The class is fixed rather than the
#     one file exempted, and it is proved in both directions here.
# ================================================================================================
c="$work/headerscope"; base=$(mkfixture "$c")
{
  printf '#!/bin/bash\n%s\n' "$DECL"
  printf '# a fixture this check writes, whose CONTENT carries the declaration syntax:\n'
  printf 'cat <<EOF_FIXTURE > /dev/null\n'
  printf '# km-gate-instrument: tests/test_nowhere.sh | a fixture line, not this file own claim.\n'
  printf '# km-unrepaired-tree: unrecorded | a fixture line, not this file own claim.\n'
  printf 'EOF_FIXTURE\n'
  printf 'exit 0\n'
} > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "16. declaration syntax in a file body is not read as its own" "$c" 0 \
  "PASS release-gate:"

# 16b. The other direction: with the header declaration gone, one buried in the body does NOT save
#      it. A scope that accepted the body would make case 16 pass for the wrong reason.
{
  printf '#!/bin/bash\n'
  printf 'cat <<EOF_FIXTURE > /dev/null\n'
  printf '%s\n' "$DECL"
  printf 'EOF_FIXTURE\n'
  printf 'exit 0\n'
} > "$c/tests/test_alpha.sh"
KM_GATE_BASE="$base" expect "16b. a declaration buried in the body does not satisfy the rule" "$c" 1 \
  "no km-unrepaired-tree declaration"

# ================================================================================================
# 17. THE ACKNOWLEDGED GAP, asserted as a gap and not as a control.
#
#     The gate reads a check's EXIT STATUS. A check that fails internally and still returns 0 passes,
#     and no runner that treats a check as a black box can do otherwise. This was found by running
#     the gate against a deliberately broken tree: a real suite was given a command that does not
#     exist, the suite swallowed the 127 because it does not run under `set -e`, it exited 0 on its
#     own accounting, and the gate PASSED. The case below pins that behaviour so it is a documented
#     limit rather than a surprise, and so a future change that closes it fails here loudly instead
#     of quietly redefining what a pass means.
# ================================================================================================
c="$work/swallowed"; base=$(mkfixture "$c")
printf '#!/bin/bash\n%s\nkm-no-such-command-deliberate-break\nexit 0\n' "$DECL" \
  > "$c/tests/test_beta.sh"
git -C "$c" add tests/test_beta.sh >/dev/null
KM_GATE_BASE="$base" expect "17. a check that swallows its own failure still passes (KNOWN GAP)" \
  "$c" 0 "PASS release-gate:"
note "     ^ this is the acknowledged gap, not a control. The canary rule the standard already"
note "       carries is what reaches inside a check; the gate reaches only its exit status."

# ================================================================================================
# 18. A run that executed no check cannot be recorded as a release verdict.
# ================================================================================================
c="$work/staticonly"; base=$(mkfixture "$c")
KM_GATE_BASE="$base" expect "18. --no-suites is labelled STATIC ONLY on the verdict line itself" \
  "$c" 0 "PASS release-gate (STATIC ONLY, NOT A RELEASE VERDICT):" --no-suites
KM_GATE_BASE="$base" expect "18b. --no-suites reports the unexecuted checks as a coverage gap" \
  "$c" 0 "COVERAGE GAP: --no-suites was passed" --no-suites
out=$(run_gate "$c" --no-suites)
if printf '%s\n' "$out" | grep -Fq "PASS release-gate:"; then
  note "FAIL: 18c. a static-only run still prints a line that reads as an ordinary pass"
  fail=1
else
  note "PASS: 18c. a static-only run prints no line that reads as an ordinary pass"
fi

# ================================================================================================
# 19. AN UNTRACKED CHECK-SHAPED FILE IS DISCOVERED, AND CANNOT PRODUCE A PASSING VERDICT.
#
#     The gate discovered checks with `git ls-files`, which lists the INDEX, while the maintainer
#     contract in agents/km-hub-builder/SKILL.md orders the gate to be run BEFORE explicit staging.
#     A check authored in the change being gated is therefore untracked at exactly the moment the
#     gate runs, and the gate could not see it.
#
#     MEASURED ON THE REPOSITORY AT eb57f0f, published v1.53, before the repair:
#       clean tree                     -> 33 check(s) discovered, PASS, exit 0
#       + untracked tests/test_zz_probe.sh holding an unparseable line bash -n rejects
#                                      -> 33 check(s) discovered, PASS, exit 0
#     The count did not move, the file was never named, and 30 shell files were syntax-checked in
#     both runs. The gate returned the verdict a clean tree returns over a check it had not seen.
#
#     WHY THIS SUITE NEVER CAUGHT IT. Every case above that introduces a new check file stages it
#     with `git add` first: cases 7, 9, 10 and 17 all do. The workaround the v1.48 drafting agent
#     used when it hit this gap on 2026-08-24, and reported rather than repaired, is written into
#     the fixtures of the suite that exists to break this gate, so the untracked path was never
#     reached. That is the finding underneath the finding, and it is why these cases stage nothing.
# ================================================================================================
c="$work/untracked"; base=$(mkfixture "$c")
printf 'this is not valid shell ((((\n' > "$c/tests/test_zz_probe.sh"
KM_GATE_BASE="$base" expect "19. an untracked invalid check cannot produce a passing verdict" "$c" 1 \
  "tests/test_zz_probe.sh"
KM_GATE_BASE="$base" expect "19b. it is named as a syntax error rather than merely failing to run" \
  "$c" 1 "tests/test_zz_probe.sh: shell syntax error"

# 19c. The other direction, on the same fixture: remove the untracked file and the tree passes. A
#      case that failed here would be failing on everything, which proves nothing.
rm -f "$c/tests/test_zz_probe.sh"
KM_GATE_BASE="$base" expect "19c. with the untracked file gone, the same tree passes" "$c" 0 \
  "PASS release-gate:"
KM_GATE_BASE="$base" expect "19d. the coverage line states the untracked count as zero, not absent" \
  "$c" 0 "0 discovered check(s) untracked"

# 19e. An untracked check that PARSES is still a check this change adds, so the ADDED declaration
#      rule reaches it. Before the repair it escaped that phase entirely, because
#      `git diff --name-only <base>` never names an untracked path.
printf '#!/bin/bash\necho ok\n' > "$c/tests/test_zz_new.sh"
KM_GATE_BASE="$base" expect "19e. an untracked check with no declaration fails the gate" "$c" 1 \
  "no km-unrepaired-tree declaration"

printf '#!/bin/bash\n# km-unrepaired-tree: unrecorded | nothing was run.\necho ok\n' \
  > "$c/tests/test_zz_new.sh"
KM_GATE_BASE="$base" expect "19f. an untracked check pleading 'unrecorded' fails the gate" "$c" 1 \
  "added by this change and declares 'unrecorded'"

# 19g. The repaired form passes, is RUN, and is reported as untracked, so the provenance of a
#      discovered check is stated rather than merged into one number.
printf '#!/bin/bash\n%s\necho ok\n' "$DECL" > "$c/tests/test_zz_new.sh"
KM_GATE_BASE="$base" expect "19g. an untracked check declaring the drafted version passes" "$c" 0 \
  "PASS release-gate:"
KM_GATE_BASE="$base" expect "19h. the run names it and marks it untracked" "$c" 0 \
  "ok    tests/test_zz_new.sh (untracked)"
KM_GATE_BASE="$base" expect "19i. the coverage line counts the untracked discovered check" "$c" 0 \
  "1 discovered check(s) untracked"

# 19j. AN IGNORED CHECK-SHAPED FILE IS NOT DISCOVERED. This is the residual gap, pinned here as a
#      gap rather than as a control, so a later change that closes it fails loudly here instead of
#      quietly redefining the scope. An ignored file is not a file the repository ships; the cost is
#      that a path added to .gitignore leaves the gate by an edit to a different file.
rm -f "$c/tests/test_zz_new.sh"
printf 'tests/test_zz_ignored.sh\n' > "$c/.gitignore"
git -C "$c" add .gitignore >/dev/null
printf 'this is not valid shell ((((\n' > "$c/tests/test_zz_ignored.sh"
KM_GATE_BASE="$base" expect "19j. an ignored check-shaped file is not discovered (KNOWN GAP)" "$c" 0 \
  "PASS release-gate:"
note "     ^ this is the acknowledged gap, not a control. Discovery honours the ignore rules, so a"
note "       path added to .gitignore leaves the gate without any edit to the gate or to the check."

# ================================================================================================
# 15. THE STATED LIMITS. None of them is a test of the tree; all four are assertions that the gate
#     says out loud what it cannot do, because a green line is otherwise read as "safe to publish".
# ================================================================================================
if grep -Fq "IT CANNOT RUN THE ORGANISATION LEAKAGE SCAN" "$GATE" &&
   grep -Fq "IT CANNOT SUPPLY A SECOND ACTOR" "$GATE" &&
   grep -Fq "S EXIT STATUS AND CANNOT SEE INSIDE IT" "$GATE" &&
   grep -Fq "IT DOES NOT SEE AN IGNORED FILE" "$GATE"; then
  note "PASS: 15. the gate states all four of its limits in its own header"
else
  note "FAIL: 15. the gate does not state all four of its limits in its own header"
  fail=1
fi

# ================================================================================================
# 20. THE LIMITS ARE DEFINED ONCE AND PRINTED, NOT COPIED. (v1.55.)
#     .github/workflows/release-gate.yml carried a hand copy of the limits, documented TWO of the
#     four, and had already drifted when an external reviewer read it. The copy is gone; the
#     workflow runs --limits instead. These cases pin the mechanism so the pointer cannot rot back
#     into a copy.
# ================================================================================================
WORKFLOW="$ROOT/.github/workflows/release-gate.yml"
limits_out=$(python3 "$GATE" --limits 2>&1); limits_status=$?
defined=$(grep -c '^    ("' "$GATE")
printed=$(printf '%s\n' "$limits_out" | grep -cE '^  [0-9]+\. ')
if [ "$limits_status" -eq 0 ] && [ "$defined" -gt 0 ] && [ "$printed" -eq "$defined" ]; then
  note "PASS: 20. --limits prints every limit the gate defines ($printed of $defined), exit 0"
else
  note "FAIL: 20. --limits printed $printed of $defined defined limits (exit $limits_status)"
  printf '%s\n' "$limits_out" | sed 's/^/       /'
  fail=1
fi

if printf '%s\n' "$limits_out" | grep -Fq "states $defined limits"; then
  note "PASS: 20b. --limits states the count it is about to print, from the same definition"
else
  note "FAIL: 20b. --limits did not state the number of limits it defines"
  fail=1
fi

if [ -f "$WORKFLOW" ]; then
  if grep -Fq -- "km-release-gate.py --limits" "$WORKFLOW"; then
    note "PASS: 20c. the CI workflow obtains the limits from the gate rather than copying them"
  else
    note "FAIL: 20c. the CI workflow does not invoke --limits, so any limits it states are a copy"
    fail=1
  fi
  # Scoped to the comment block immediately above `runs-on:`, because the same file legitimately
  # pins actions/checkout by commit SHA and that IS a pin. A version-labelled runner image is not.
  runner_comment=$(awk '/^[[:space:]]*#/ { buf = buf $0 "\n"; next }
                        /runs-on:/ { printf "%s", buf; exit }
                        { buf = "" }' "$WORKFLOW")
  if printf '%s' "$runner_comment" | grep -qi 'pinned'; then
    note "FAIL: 20d. the CI workflow calls a version-labelled runner image a pin"
    printf '%s\n' "$runner_comment" | sed 's/^/       /'
    fail=1
  elif printf '%s' "$runner_comment" | grep -qi 'redeploy'; then
    note "PASS: 20d. the CI workflow says the platform redeploys the image behind the label"
  else
    note "FAIL: 20d. the CI workflow says nothing true about what its runner label selects"
    fail=1
  fi
else
  note "FAIL: 20. the CI workflow is absent, so 20c and 20d proved nothing"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  note ""
  note "release-gate canaries passed"
  exit 0
else
  note ""
  note "release-gate canaries FAILED"
  exit 1
fi
