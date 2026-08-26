#!/bin/bash
# km-unrepaired-tree: v1.61 | re-stated for three repairs that edit this file: the observation-ledger cases, the CI limit-copy case, and the cited-digest cases. CASES 21k, 21k2, 21k3 (the ledger). Run against the unrepaired gate at 164ecfb (published v1.60) before any repair was written. 21k RED, 'expected exit 2, got 0': its fixture links README.md to notes.txt and its mutator is the reviewer's own, rm notes.txt, byte for byte from reproduce-link-target-disappears.sh (sha256 a242059f37520507c793afd32e7bb99750332ff5efab38cbcc88741671b35f97, pins 164ecfb36fd7a644365ee9dff41a540130e15e82 by refusing at exit 2 on any other HEAD rather than by re-cloning, so it can test the v1.60 tree and no other). 21k2 RED, 'expected exit 2, got 1', the reverse: a target absent when the link phase asks and created afterwards. 21k3 passed on the unrepaired gate and legitimately, pinning the shape a probe on every relative link must keep accepting. Repaired: 21k names 'notes.txt existed when this run asked and is now absent', 21k2 names 'late.txt did not exist when this run asked and now does', 21k3 passes. 21h STILL PASSES and that is the boundary this pair draws: its notes.txt is linked from nothing, so no phase asks about it; 21k's notes.txt is linked from README.md, so the link phase asks. Same name, same class, opposite verdicts, and the difference is exactly whether the run asked. CASES 20c, 20c2, 20c3 (the limit copy). v1.60's own sweep found that 20c certified an ABSENCE by measuring a PRESENCE and called it the sharpest instance of its class, then registered it. The reviewer's script (reproduce-ci-limit-copy-false-pass.sh, sha256 fa35fad9e335b93e51e44d96e10256ededf44a97427f5bd2c76029886f174c00, pins 164ecfb36fd7a644365ee9dff41a540130e15e82 internally and re-clones it whatever source root it is handed, so it can test the v1.60 tree and no other) was run here UNMODIFIED against that tree and printed 'PASS: 20c. the CI workflow obtains the limits from the gate rather than copying them', 'release-gate canaries passed', suite_exit=0 and REPRODUCED, over a workflow carrying five verbatim limit statements. 20c is narrowed here to the pointer it actually measures; 20c2 measures the absence against the gate's own --limits output; 20c3 is the negative direction and carries the reviewer's injection byte for byte. 20c2 passed on the unrepaired workflow and could not have done otherwise, because the defect was in the CASE and not in the workflow, so 20c3 is what shows the detector works: it fires on the injected copy and 20c2 stays silent on the real file. The repair was verified against the reviewer's fixture by a DE-PINNED variant of their script -- modified in exactly one line, the pinned checkout replaced by a checkout of the source root's own HEAD plus its working-tree diff -- which reported suite_exit=1 and 'NOT REPRODUCED: the release-gate canaries rejected the duplicated limits'. That variant is a modified script and is declared as one. CASES 22, 22b, 22c, 22d, 22e (the cited digest). 22 RED, 'expected exit 1, got 0', and 22d RED for the same reason on a 65-character digest, which is the shape v1.59 actually published. 22b and 22c passed on the unrepaired gate and both legitimately, pinning 'pins <rev>' and 'unpinned' as the two shapes the rule must accept. 22e is the prose direction and it was written because the rule FAILED IT when first run against this repository: the gate's own declaration contains the phrase 'by sha256 and says nothing', and the first form of the rule read 'a' out of 'and' and reported a digest of length 1. That false FAIL is the case's red run, recorded rather than repaired away quietly, and the 16-character floor that answers it is held by 22e so it is a rule rather than a pattern lengthened until the tree went green. All five pass repaired. AND THE RULE: A VERIFICATION DECLARATION IS A RECORD OF WHAT WAS RUN, AND A SCRIPT THAT PINS A REVISION CANNOT TESTIFY ABOUT ANY OTHER REVISION. This file's own v1.60 declaration broke it and is corrected below rather than merely inherited. WHAT WAS NOT DONE, STATED HERE RATHER THAN LEFT TO BE FOUND (v1.61 draft; binds nothing until that version's own owner push). The runs recorded above happened and their outputs are recorded, but they were NOT COMMITTED AS A RED COMMIT, and this version cites none where v1.58 (fbf8002), v1.59 (998b859) and v1.60 (1294b5d) each cite one. Canaries and repairs were authored in one working tree across the same three instrument files -- tools/km-release-gate.py, tests/test_release_gate.sh and tests/test_skill_frontmatter.sh -- so no revision exists at which these cases stand red alone. A retroactive red commit was refused rather than overlooked, because manufacturing one in the version whose own subject is a true statement in a working report becoming a false statement in a published artifact would be the defect this version is about. The evidence is reproducible from git instead, and was reproduced that way here: with the unrepaired gate taken from `git show 164ecfb:tools/km-release-gate.py` and the canaries of tests/test_release_gate.sh run against it, 21k failed 'expected exit 2, got 0', 21k2 failed 'expected exit 2, got 1', 22 and 22d failed 'expected exit 1, got 0', and 21k3 passed, which is the red state this declaration reports. The v1.60 declaration this replaces still holds except where corrected: v1.60 | re-stated for the phase-derivation repair. Case 21j was rewritten from a grep over the gate's source text into a behavioural pair, and the rewritten 21j was run against the unrepaired gate at 73f89e8 (published v1.59) before the repair was written. It was RED: 'expected exit 2, got 0'. Its fixture is the external reviewer's own, lifted from reproduce-phase-derivation-false-pass.sh (sha256 2610ce370cf3869d02cd9a7cca33663d01cdf13f07e23ecf8753f7dac3be88ed, pins 73f89e80774f7401eebb106572c14824a9e60d15 internally and re-clones it whatever source root it is handed, so it tested the v1.59 tree on every run it ever made) rather than written from a description of it: a real verdict phase, check_text, that reads tracked *.txt files through a TUPLE pathspec, git_tracked(root, ("*.txt",)). That script itself was run here unmodified against a detached clone at 73f89e8, on an environment identical to theirs (macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6), and printed 'PASS: 21h. a file in no input class is NOT caught (KNOWN GAP)', 'PASS: 21j. every phase takes its pathspecs from the structure the fingerprint iterates', 'suite_exit=0' and REPRODUCED. The v1.59 form of 21j grepped for git_(tracked|untracked)\(root, \[ and required no match, so it certified a SPELLING where its own title claimed a PROPERTY, and a tuple walked past it; 21h then accepted notes.txt mutating mid-run while notes.txt WAS a gate input, so the gap pin was certifying the wrong thing too. One of the two new assertions passed on the unrepaired gate and legitimately, because its job is to pin a boundary rather than to detect a defect: 21j2, which requires the same added phase over a stable tree to keep passing. Against the repaired gate 21j exits 2 naming notes.txt, 21j2 still passes, and 21h still passes on the UNMODIFIED gate. THE NEXT CLAUSE OF THIS SENTENCE WAS FALSE WHEN v1.60 PUBLISHED IT AND IS STRUCK IN v1.61 (a DRAFT that binds nothing until that version's own owner push): it read 'and the reviewer's script prints NOT REPRODUCED'. That script pins 73f89e8 and re-clones it, so it tested v1.59 on every run; re-measured on 2026-08-26 against the published v1.60 tree it printed 'PASS: 21j. every phase takes its pathspecs from the structure the fingerprint iterates', 'suite_exit=0' and REPRODUCED.  The v1.59 declaration this replaces still holds: v1.59 | re-stated for the fingerprint-scope repair and the branch-identity repair. The nine new or rewritten assertions were run against the unrepaired gate at be6e4bf (published v1.58) before either repair was written, and seven were red. 21d and 21d1: a fixture whose discovered suite switches to a NEW BRANCH AT THE SAME COMMIT reported 'expected exit 2, got 0', its mutator being the external reviewer's own two commands, git branch km-other then git switch -q km-other, lifted from their reproduce-same-commit-branch-switch.sh (sha256 37426e967fbd0c56893568c096eab6762651cbe8fae80f5329d3d39900a06ccc, pins no revision but reads the gate from the fixed path /private/tmp/km-v158-builder-recheck/repo, so it tested whatever tree stood at that path) rather than written from a description of it. That script itself was run here unmodified against a be6e4bf snapshot, on an environment identical to theirs (macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6), and printed 'exit=0 / branch=km-other / REPRODUCED: v1.58 passed after switching branch identity at the same commit'; against the repaired gate the same script prints 'REFUSED release-gate: ... the checked-out ref changed from refs/heads/main to refs/heads/km-other' at exit 2. RE-VERIFIED IN v1.61 (a draft that binds nothing until that version's own owner push) rather than inherited: this script is PATH-pinned, not revision-pinned, and the path it read the gate from no longer exists, so it was re-run with THAT ONE LINE re-pointed at this working tree and nothing else changed, printing exactly that refusal at exit=2 with branch=km-other. A path-pinned script can testify about whichever tree stands at that path; a revision-pinned one re-clones its commit and can testify about nothing else. because git rev-parse HEAD returns one value for two branches standing at one commit, so the branch switch this case's own title has promised since v1.58 was invisible; the fixture that stood here before moved HEAD with an empty commit, which is commit movement and a different thing. 21e, 21g, 21g2 and 21g3, one per input class the gate reads and does not discover -- a tracked markdown file the link phase had resolved, a tracked JSON file the parse phase had read, and a shell and a Python file outside tests/ and scripts/ that the syntax phases had read -- each reported 'expected exit 2, got 0': every one changed after its own phase had run and the gate still returned PASS over the result. 21e is the reviewer's own README.md demonstration, inverted from the assertion of a gap that v1.58 shipped into a control over it. 21j reported the four literal pathspec lists standing in the phases, which is the mechanism by which the covered set could be narrower than the phases at all. Four assertions passed on the unrepaired tree and all four legitimately, because their job is to pin a boundary rather than to detect a defect: 21d2, which requires commit movement to keep being caught; 21d3, which requires a detached HEAD not to refuse; 21h, which requires a file in NO input class not to be caught; and 21f, a stable tree passing twice with the same verdict. The v1.58 declaration this replaces still holds in full: re-stated for the tree-stability repair and the limits-definition repair. The seven new assertions were run against the unrepaired gate at 510cf03 before either repair was written, and all seven were red. 21a and 21c: a fixture whose discovered suite edits another discovered check, and one whose suite creates a new check-shaped file, each reported 'expected exit 2, got 0' -- the gate returned PASS over a tree it had not read, and in the second case over a check it had never discovered, never held to the declaration rule and never executed. 21b, the same class asserted on its own fixture, reported 'expected exit 2, got 1'. 21d: a fixture whose suite moves HEAD with no file content differing reported 'expected exit 2, got 0', which is the half no content hash alone can see and is the reviewer's own observed case. 15a reported the gate typing 'the same four limits' in prose 185 lines below its own claim that the count 'is not restated in prose anywhere'; 15b reported four numbered limit headings in the header block, standing in file order 1, 3, 2, 4; 15c reported GATE_LIMITS, named twice by the header as the home of the single definition and defined nowhere, the definition being LIMITS. Two of the nine new assertions passed on the unrepaired tree and both legitimately, because their job is to pin a boundary rather than to detect a defect: 21e, which requires that a change OUTSIDE the discovery set is not caught, and 21f, which requires a stable tree to pass twice with the same verdict. The v1.55 declaration this replaces still holds: re-stated for the exemption-anchoring and limits-mechanism repair. The seven assertions added here (13c, 13d, 13e, 20, 20b, 20c, 20d) were run against the unrepaired gate and the unrepaired workflow at 13dec55 before either was touched: 13c and 13d each reported "expected exit 1, got 0", the quoted token having exempted a document carrying a genuinely broken link; 20 reported "--limits printed 0 of 0 defined limits (exit 2)", the flag not existing; 20b and 20c failed with it. Two passed there, and only one of them legitimately: 13e, because a real declaration at the start of a line is honoured by both readers, and 20d, which passed for the wrong reason until its assertion was scoped to the comment block above runs-on. The v1.46 declaration this replaces still holds: run against deliberately broken trees before the gate was trusted: a suite made to fail, a suite whose interpreter is absent, an emptied discovery set, a stripped declaration, a broken relative link, unparseable JSON, a shell syntax error and a Python syntax error. Every one of those trees was gated and every one produced FAIL or REFUSED, never PASS.
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
  out=$(cd "$d" && KM_GATE_BASE="${KM_GATE_BASE:-}" python3 "${GATE_BIN:-$GATE}" --root "$d" "$@" 2>&1)
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
  # Two files in NO check directory, one per remaining input class, so the fingerprint cases below
  # can disturb a shell file and a Python file the gate reads without disturbing a discovered check.
  # (Added in v1.59.)
  mkdir -p "$d/tools"
  printf '#!/bin/bash\necho "fixture helper"\n' > "$d/tools/helper.sh"
  printf 'print("fixture helper")\n' > "$d/tools/helper.py"
  # A file in no input class at all, so the residual can be pinned as a gap rather than described.
  printf 'fixture notes\n' > "$d/notes.txt"
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
# 15. THE LIMITS ARE DEFINED IN ONE PLACE, AND THE FILE MAKES NO CLAIM ABOUT THEM IT MAINTAINS BY
#     HAND. (Rewritten in v1.58.)
#
#     Until v1.58 this case named four limits by their exact header wording in four hardcoded
#     `grep -Fq` calls. That made the case itself the third maintained definition of the set: the
#     tuple defined it, a numbered prose block in the gate's header argued each one again, and these
#     assertions pinned that block's wording. The tuple's own comment nevertheless said "Adding a
#     fifth limit is an edit to this tuple and to nothing else", which was false when it was written
#     at v1.55 -- both other places already existed on that tree, so it is corrected under the v1.47
#     rule rather than dated under v1.56's.
#
#     The repair reduced the count of definitions to one rather than describing the drift, and the
#     three assertions below are what keeps it at one. Each is DERIVED: none of them names a limit.
# ================================================================================================

# A CLAIM IS READ WHERE A CLAIM IS MADE, AND A QUOTATION IS NEVER A CLAIM. 15a and 15c below read
# the gate's own prose for statements it maintains by hand, and a repair to that class necessarily
# QUOTES the wording it removed -- the version row, the header's own record of what was wrong, the
# `km-unrepaired-tree` declaration. An unanchored search reads those quotations as the defect and
# reports a file that has just been repaired, which is the class STANDARD.md states under "A status
# is read where a status is declared, and quoted everywhere else" (v1.52) and again under "A
# directive token is read where a directive is declared" (v1.55). Written unanchored first, both
# cases did exactly that, on this change's own repair.
#
# Two anchors, and both are rules rather than conveniences. Text inside double quotes or backticks
# is a quotation and is blanked. The `km-unrepaired-tree` line is a DATED RECORD of what a past
# tree did, which this standard's own rule forbids rewriting to agree with the present, so it is
# blanked too -- in place, so the line numbers a failure reports stay true.
gate_claims() { sed 's/^# km-unrepaired-tree:.*$//' "$1" | sed 's/"[^"]*"/""/g; s/`[^`]*`/``/g'; }

# 15a. No surface states a count of the limits in prose. The gate's own header has claimed since
#      v1.55 that the count is not restated in prose anywhere, and 185 lines below it the tuple's
#      comment stated it. A number typed beside the set it counts is the artifact class STANDARD.md
#      records as the one that rots, and this file carried the claim and the counter-example at once.
prose_counts=$(gate_claims "$GATE" | grep -nEi '(one|two|three|four|five|six|seven|eight|nine|ten|[0-9]+)[ -]+limits?\b' || true)
if [ -z "$prose_counts" ]; then
  note "PASS: 15a. the gate states no count of its own limits in prose; every surface derives it"
else
  note "FAIL: 15a. the gate types a count of its own limits in prose"
  printf '%s\n' "$prose_counts" | sed 's/^/       /'
  fail=1
fi

# 15b. The header does not enumerate the limits a second time. A numbered prose block that argues
#      each limit is a second definition however carefully it is kept: on the unrepaired tree its
#      four entries stood in file order 1, 3, 2, 4, which is what separate maintenance looks like.
header_enum=$(grep -nE '^# [0-9]+\. [A-Z]' "$GATE" || true)
if [ -z "$header_enum" ]; then
  note "PASS: 15b. the header argues no numbered limit of its own; the definition carries its argument"
else
  note "FAIL: 15b. the header enumerates limits a second time, beside the definition"
  printf '%s\n' "$header_enum" | sed 's/^/       /'
  fail=1
fi

# 15c. Every constant the leading comment block names is a constant the file defines. The header
#      pointed twice at `GATE_LIMITS` while the definition was named `LIMITS`, so the one sentence
#      telling a reader where the single definition lives named nothing at all. This is the same
#      class as a reference whose target is not in the tree (STANDARD.md, v1.45), one scope down.
undefined_in() { # <gate-file> -> the constant names its header claims and its body never defines
  gate_claims "$1" | awk 'NR==1{next} /^[[:space:]]*(#|$)/{print; next} {exit}' \
    | grep -oE '\b[A-Z][A-Z0-9]*(_[A-Z0-9]+)+\b' | sort -u | while read -r n; do
        grep -qE "^${n}[[:space:]]*=" "$1" || echo "$n"
      done
}
undefined_consts=$(undefined_in "$GATE")
if [ -z "$undefined_consts" ]; then
  note "PASS: 15c. every constant the gate's header names is defined in the gate"
else
  note "FAIL: 15c. the gate's header names a constant the gate does not define"
  printf '%s\n' "$undefined_consts" | sed 's/^/       /'
  fail=1
fi

# 15d/15e. THE ANCHORING ABOVE IS A NARROWING, AND A NARROWING PROVES NOTHING BY GOING GREEN.
#      "A rule narrowed until the tree goes green passes, and so does a rule that has stopped
#      matching entirely" -- STANDARD.md, v1.52 -- and the only case that separates the two is a
#      record genuinely in one state while quoting the other. So both anchored greps are run
#      against a copy of the gate carrying the v1.55 wording as a LIVE claim rather than as a
#      quotation, and both must fire on it. Without these, 15a and 15c could have been anchored
#      into silence by this very change and nothing would have said so.
probe="$work/gate_probe.py"
awk 'NR==2{print; print "# These are the same four limits the header block above argues for."
           print "# Read GATE_LIMITS below, which is the one definition every surface prints from."
           next} {print}' "$GATE" > "$probe"
if [ -n "$(gate_claims "$probe" | grep -Ei '(one|two|three|four|five|six|seven|eight|nine|ten|[0-9]+)[ -]+limits?\b' || true)" ]; then
  note "PASS: 15d. the anchored count check still fires on an unquoted prose count"
else
  note "FAIL: 15d. the anchored count check has been narrowed into silence"
  fail=1
fi
if [ -n "$(undefined_in "$probe")" ]; then
  note "PASS: 15e. the anchored constant check still fires on an unquoted undefined constant"
else
  note "FAIL: 15e. the anchored constant check has been narrowed into silence"
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
# Counted from the definition's own opening marker. v1.58 gave each limit a `Limit(` constructor so
# that its statement, the lines every surface prints, and its full argument sit together; this is
# the one place the canaries touch that shape, and it is a count of the definition rather than a
# copy of it.
defined=$(grep -c '^    Limit($' "$GATE")
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

# THE CLAIM IS ABSENCE OF A COPY, SO THE MEASUREMENT MUST BE ABSENCE OF A COPY.
# (v1.61 draft; binds nothing until that version's own owner push.)
#
# Until v1.61 case 20c certified "the CI workflow obtains the limits from the gate rather than
# copying them" by confirming that the string `km-release-gate.py --limits` appears in the file. An
# invocation is not an absence: a workflow that invokes the flag AND carries a complete hand copy
# below it satisfied that test, and an external reviewer demonstrated exactly that by inserting five
# verbatim limit statements under the comment block and watching 20c pass. v1.60's own sweep found
# this and called it the sharpest instance of "a control enforces a spelling where it claims to
# enforce a property", then registered it rather than repairing it. Disclosure is not closure.
#
# So the claim is split in two, and each half is measured by what it says.
#   20c  asserts the POINTER: the workflow invokes --limits. That is a presence, a grep answers it
#        honestly, and the title now says only that.
#   20c2 asserts the ABSENCE: no line of the gate's own limit definition -- neither a `statement`
#        nor a `summary` line -- is restated verbatim anywhere in the workflow. The comparison is
#        against the gate's LIMITS, taken from the gate itself, so it cannot go stale when a limit
#        is added, reworded or removed. There is no pattern here to lengthen.
#
# WHAT THIS MEASURES AND WHAT IT DOES NOT, stated rather than left to be found. A verbatim copy is
# caught. A PARAPHRASE is not, and the workflow legitimately carries one: "a green run means the
# mechanical checks ran. It does not mean the push is free of organisation leakage, and it does not
# mean anyone other than the author looked." That sentence is a summary written for a reader who
# will not open the log, and it is not a restatement of the definition. The property enforced here
# is that the DEFINITION's own words appear once, in the definition. Its error direction is a false
# PASS on a paraphrase that drifts, never a false FAIL, and the pointer 20c holds is what keeps the
# authoritative text one command away from the log.
workflow_limit_copies() { # <workflow-file>: prints each line of the gate's limit definition that
                          # the workflow restates verbatim. Empty output means no copy.
  python3 - "$GATE" "$1" <<'COPYCHECK'
import subprocess, sys
gate, workflow = sys.argv[1], sys.argv[2]
# The limit text is taken from the GATE'S OWN --limits output rather than by parsing its source:
# that is the surface CI reads, so what is compared here is what a copier would have copied.
out = subprocess.run([sys.executable, gate, "--limits"], capture_output=True)
if out.returncode != 0:
    print("REFUSED: the gate would not print its limits, so no comparison was made")
    sys.exit(2)
lines = []
for raw in out.stdout.decode("utf-8", "replace").split("\n"):
    text = raw.strip()
    # Drop the numbering the renderer adds, keeping the statement and summary text itself. A
    # fragment shorter than 30 characters is not evidence of a copy.
    head = text.split(". ", 1)
    if len(head) == 2 and head[0].isdigit():
        text = head[1]
    if len(text) >= 30:
        lines.append(text)
if not lines:
    print("REFUSED: --limits printed no comparable text")
    sys.exit(2)
body = open(workflow).read()
for text in lines:
    if text in body:
        print(text)
COPYCHECK
}

if [ -f "$WORKFLOW" ]; then
  if grep -Fq -- "km-release-gate.py --limits" "$WORKFLOW"; then
    note "PASS: 20c. the CI workflow invokes --limits, so the log carries the gate's own limit text"
  else
    note "FAIL: 20c. the CI workflow does not invoke --limits, so the log carries no limit text"
    fail=1
  fi

  copies=$(workflow_limit_copies "$WORKFLOW"); copies_status=$?
  if [ "$copies_status" -ne 0 ]; then
    note "FAIL: 20c2. the copy comparison could not be made, so it proved nothing"
    printf '%s\n' "$copies" | sed 's/^/       /'
    fail=1
  elif [ -z "$copies" ]; then
    note "PASS: 20c2. the CI workflow restates no line of the gate's limit definition verbatim"
  else
    note "FAIL: 20c2. the CI workflow carries a hand copy of the gate's limits; these lines of the"
    note "       definition are restated in it verbatim:"
    printf '%s\n' "$copies" | sed 's/^/       /'
    fail=1
  fi

  # THE OTHER DIRECTION, AND IT IS THE ONE THAT MATTERS HERE. 20c2 reports by ABSENCE, so on its own
  # it passes whether it works or not. The injection below is the external reviewer's own, byte for
  # byte from reproduce-ci-limit-copy-false-pass.sh: five verbatim limit statements appended to the
  # comment block above `name:`. The detector must find them.
  copy_fixture="$work/workflow_with_copy.yml"
  python3 - "$WORKFLOW" "$copy_fixture" <<'INJECT'
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text()
marker = "# than the author looked.\n"
assert marker in text, "20c3 anchor (the closing line of the comment block) is not in the workflow"
copy = """#
# COPIED LIMITS (deliberately stale-prone duplicate):
# 1. This gate does not run an organisation leakage scan and cannot.
# 2. No runner supplies a second actor.
# 3. This gate reads a check's exit status and cannot see inside it.
# 4. Discovery reads the working tree but honours the ignore rules.
# 5. A stable fingerprint is not a stable tree.
"""
Path(sys.argv[2]).write_text(text.replace(marker, marker + copy, 1))
INJECT
  if [ -f "$copy_fixture" ]; then
    injected=$(workflow_limit_copies "$copy_fixture")
    if [ -n "$injected" ]; then
      note "PASS: 20c3. the copy detector fires on a workflow carrying a verbatim hand copy"
    else
      note "FAIL: 20c3. a workflow carrying five verbatim limit statements was reported as clean"
      fail=1
    fi
  else
    note "FAIL: 20c3. the copy fixture could not be built; its anchor in the workflow has moved"
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

# ================================================================================================
# 21. THE VERDICT IS ABOUT THE TREE THE GATE DISCOVERED. (Added in v1.58.)
#
#     Discovery and the declaration phase run first; the suites run after; the run takes about
#     twenty minutes on the real repository. Nothing established that the tree at the verdict was
#     the tree that was discovered, so a PASS could not name what it had judged. An external
#     reviewer observed it live: the gate began on a clean branch, the branch changed underneath it,
#     a discovered check was edited, and the gate returned PASS after ~900s still reporting zero
#     changed declarations. The maintainer's own drafting agent was the thing editing the tree. The
#     defect is that the gate cannot tell, not that anyone misbehaved -- twenty minutes is a wide
#     window for a maintainer working alongside a run, and a gate whose PASS cannot name the tree it
#     judged certifies nothing.
#
#     THE REPAIR IS NOT A SNAPSHOT, DELIBERATELY. Since v1.54 the gate reads the WORKING tree,
#     tracked union untracked-not-ignored, because a check authored in the change being gated is
#     untracked at exactly the moment the gate runs. Running against a snapshot of tracked content
#     would silently undo v1.54 and reopen the defect that version closed. So the gate fingerprints
#     what it read -- the same set discovery reads, by path and content, plus HEAD -- before and
#     after, and REFUSES on any difference. A refusal is not a pass and is not a silent re-run.
#
#     Each mutator below sorts after the check it disturbs, so the disturbance lands after that
#     check has run and the case is about the fingerprint rather than about execution order.
# ================================================================================================

# mkdrift <dir> <mutator-body>: a whole fixture plus a discovered suite that disturbs the tree.
mkdrift() {
  local d="$1" body="$2"
  mkfixture "$d" >/dev/null
  { printf '#!/bin/bash\n%s\n' "$DECL"; printf '%s\n' "$body"; printf 'exit 0\n'; } \
    > "$d/tests/test_zz_mutator.sh"
  git -C "$d" add -A >/dev/null
  git -C "$d" commit -qm "mutator" >/dev/null
  git -C "$d" rev-parse HEAD
}

# 21a/21b. A discovered check is EDITED while the gate runs. Each assertion gets its OWN fixture:
#      a mutator leaves its mutation behind, so a second run over the same tree is a different tree
#      and would be answered for a different reason. (Found by writing it the other way first.)
c="$work/drift_content"
base=$(mkdrift "$c" 'printf "\n# edited while the gate was running\n" >> tests/test_alpha.sh')
KM_GATE_BASE="$base" expect "21a. a discovered check edited mid-run is refused, not passed" "$c" 2 \
  "tests/test_alpha.sh"
c="$work/drift_content2"
base=$(mkdrift "$c" 'printf "\n# edited while the gate was running\n" >> tests/test_alpha.sh')
KM_GATE_BASE="$base" expect "21b. the refusal says the tree changed while the gate ran" "$c" 2 \
  "the tree changed while the gate ran"

# 21c. A NEW check-shaped file appears while the gate runs. It was never discovered, never held to
#      the declaration rule and never executed, and a verdict that covered it would be a lie.
c="$work/drift_added"
base=$(mkdrift "$c" 'printf "#!/bin/bash\nexit 0\n" > tests/test_zz_late.sh')
KM_GATE_BASE="$base" expect "21c. a check appearing mid-run is refused, not silently uncovered" "$c" 2 \
  "tests/test_zz_late.sh"

# 21d. THE CHECKED-OUT BRANCH CHANGES AND THE COMMIT DOES NOT. (Rewritten in v1.59.) This case's
#      title has promised since v1.58 that a branch change is caught, and its fixture proved
#      something else: it moved HEAD with an EMPTY COMMIT, which is commit movement and is caught by
#      `git rev-parse HEAD` alone. Two branches standing at the same commit return the same value
#      from that command, so a same-commit branch switch -- which is exactly what the reviewer
#      observed at 14:16 -- was invisible, and the gate's own docstring said otherwise. The fixture
#      below switches branch WITHOUT moving the commit, which is the thing the title claims.
#
#      THE MUTATOR IS THE REVIEWER'S OWN, BYTE FOR BYTE: `git branch km-other` then
#      `git switch -q km-other`, lifted from their reproduce-same-commit-branch-switch.sh rather
#      than written from a description of it, so what is asserted here is the act they performed.
#      `git switch` needs git 2.23 or later. The reference environment for every measurement this
#      version records is macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6, and ruby
#      2.6.10p210 with Psych 3.1.0 and libyaml 0.2.1 -- the reviewer's environment and this
#      maintainer's, which is why their scripts ran here unmodified and reproduced on the first run.
c="$work/drift_branch"
base=$(mkdrift "$c" 'git branch km-other
git switch -q km-other')
KM_GATE_BASE="$base" expect "21d. a same-commit branch switch mid-run is refused" "$c" 2 \
  "km-other"
# Its own fixture, for the reason 21a/21b already carry: a mutator leaves its mutation behind, so a
# second run over the same tree starts on the branch the first run created and drifts nowhere.
c="$work/drift_branch2"
base=$(mkdrift "$c" 'git branch km-other
git switch -q km-other')
KM_GATE_BASE="$base" expect "21d1. the refusal names the ref, not only the commit" "$c" 2 \
  "the checked-out ref changed"

# 21d2. COMMIT MOVEMENT, still. Widening the identity must not cost the half that already worked,
#       so the empty-commit fixture 21d used to carry is kept here on its own name.
c="$work/drift_head"
base=$(mkdrift "$c" 'git commit -q --allow-empty -m "moved underneath the gate"')
KM_GATE_BASE="$base" expect "21d2. HEAD moving mid-run is refused even when no file differs" "$c" 2 \
  "HEAD moved"

# 21d3. THE OTHER DIRECTION, AND IT IS NOT OPTIONAL. Recording the symbolic ref must not make a
#       detached HEAD refuse on every run: a detached HEAD is a real and stable state, and a gate
#       that refused it would be unusable in exactly the CI checkouts that run it.
c="$work/detached"; base=$(mkfixture "$c")
git -C "$c" checkout -q --detach
KM_GATE_BASE="$base" expect "21d3. a detached HEAD is a stable state, not a refusal" "$c" 0 \
  "PASS release-gate:"

# ================================================================================================
# 21e-21h. THE FINGERPRINT COVERS WHAT THE GATE READS, NOT WHAT DISCOVERY FINDS. (Added in v1.59.)
#
#      Until v1.59 the fingerprint hashed exactly the set discovery reads -- `*.sh` and `*.py` under
#      tests/ and scripts/ -- and 21e ASSERTED that as a known gap. But the gate reads far more than
#      the checks it discovers: it resolves relative links across every tracked markdown file,
#      parses every tracked JSON and JSON-LD file, and syntax-checks every tracked shell and Python
#      file wherever it lives. None of those were fingerprinted, so a broken link, an unparseable
#      JSON file or a syntax error introduced AFTER its phase had run survived into the final
#      working tree with a PASS over it. The control's scope was narrower than the thing it
#      certified, which is the class this repository keeps finding.
#
#      The four cases below are one per input class the gate reads, and 21e is the reviewer's own
#      demonstration inverted from an assertion of the gap into a control over it.
# ================================================================================================
c="$work/drift_markdown"
base=$(mkdrift "$c" 'printf "\nedited while the gate was running\n" >> README.md')
KM_GATE_BASE="$base" expect "21e. a markdown file the link phase read, changed mid-run, is refused" \
  "$c" 2 "README.md"
c="$work/drift_json"
base=$(mkdrift "$c" 'printf "{\"fixture\": false}\n" > data.json')
KM_GATE_BASE="$base" expect "21g. a JSON file the parse phase read, changed mid-run, is refused" \
  "$c" 2 "data.json"
c="$work/drift_shell"
base=$(mkdrift "$c" 'printf "\n# edited while the gate was running\n" >> tools/helper.sh')
KM_GATE_BASE="$base" expect "21g2. a shell file outside the check dirs, changed mid-run, is refused" \
  "$c" 2 "tools/helper.sh"
c="$work/drift_python"
base=$(mkdrift "$c" 'printf "\n# edited while the gate was running\n" >> tools/helper.py')
KM_GATE_BASE="$base" expect "21g3. a Python file outside the check dirs, changed mid-run, is refused" \
  "$c" 2 "tools/helper.py"

# 21h. THE RESIDUAL, PINNED AS A GAP AND NOT AS A CONTROL, AND RE-DRAWN IN v1.60. The fingerprint
#      covers what THIS RUN READ. A file NO phase of the gate reads -- a `.txt`, a `.yml`, a
#      licence, a template asset -- is opened by the discovered checks and not by the gate, and can
#      still change mid-run without being seen. So can a file that changes and changes back.
#
#      READ THIS CASE WITH 21j BELOW; SEPARATELY EITHER ONE MISLEADS. Under v1.59 this case passed
#      while a real `.txt`-reading phase stood in the gate, so `notes.txt` WAS an input to it and
#      the pin was certifying the wrong thing. The pair now says the true thing exactly: 21h
#      requires that a class the UNMODIFIED gate never reads is not covered, and 21j requires that
#      the same class IS covered the moment a phase actually reads it. The boundary is what was
#      read, and both sides of it are held.
#
#      A later change that widens the fingerprint again fails here loudly instead of quietly
#      redefining what a PASS covers.
c="$work/drift_outside"
base=$(mkdrift "$c" 'printf "edited while the gate was running\n" >> notes.txt')
KM_GATE_BASE="$base" expect "21h. a file in no input class is NOT caught (KNOWN GAP)" "$c" 0 \
  "PASS release-gate:"
note "     ^ this is the acknowledged residual, not a control. The fingerprint covers what the GATE"
note "       reads; what only a discovered check reads, and a file that changes and changes back,"
note "       are not seen."

# ================================================================================================
# 21j/21j2. THE COVERED SET IS A RUNTIME FACT, NOT A SOURCE-TEXT CLAIM.
#      (Rewritten in v1.60.)
#
#      Four behavioural cases above prove four classes are covered today. They cannot prove that a
#      phase added TOMORROW is covered, and that is what this pair is for.
#
#      v1.59 answered it by grepping the gate for `git_tracked(root, [` and requiring no match --
#      a check that enforced a SPELLING where it claimed to enforce a PROPERTY. It was proved in
#      both directions and it still modelled the wrong class, which is this repository's own
#      published doctrine (v1.29/v1.30) met in its own suite. An external reviewer walked past it
#      by writing a real `.txt`-reading phase with a TUPLE pathspec -- git_tracked(root,
#      ("*.txt",)) -- and 21j certified the guarantee while the guarantee was false; 21h then
#      accepted `notes.txt` mutating mid-run, at which point `notes.txt` WAS a gate input and the
#      "outside the inputs" pin was certifying the wrong thing too.
#
#      A stricter grep is the same defect with a longer pattern, and the next reviewer writes a
#      helper or a variable. So the guarantee is made structural instead: every phase obtains its
#      files through accessors that RECORD what they hand out, and the closing fingerprint covers
#      what was actually read. The canary is therefore a REAL NEW PHASE -- the reviewer's own, byte
#      for byte, tuple pathspec and all, injected into a copy of the real gate -- which must be
#      covered with no edit to any list and no edit to this case.
# ================================================================================================
# The reviewer's phase is lifted from reproduce-phase-derivation-false-pass.sh (sha256
# 2610ce370cf3869d02cd9a7cca33663d01cdf13f07e23ecf8753f7dac3be88ed) rather than written from a
# description of it. The anchors are asserted, so if the gate is refactored underneath this canary
# it fails loudly instead of quietly building an unmodified gate and passing over it.
mkgate_new_phase() { # <out.py>
  python3 - "$GATE" "$1" <<'INJECT'
import sys
src = open(sys.argv[1]).read()
phase = ('def check_text(root):\n'
         '    """A newly added verdict phase that reads tracked text files."""\n'
         '    for rel in git_tracked(root, ("*.txt",)):\n'
         '        read_text(root, rel)\n'
         '\n\n')
marker = "# --- phase: run the discovered checks"
assert marker in src, "21j anchor 1 (the phase marker) is not in the gate"
src = src.replace(marker, phase + marker, 1)
call = "        failures += link_failures\n"
assert call in src, "21j anchor 2 (the link phase call site) is not in the gate"
src = src.replace(call, call + "        check_text(root)\n", 1)
open(sys.argv[2], "w").write(src)
INJECT
}
probe_gate="$work/gate_new_phase.py"
if mkgate_new_phase "$probe_gate"; then
  c="$work/drift_new_phase"
  base=$(mkdrift "$c" 'printf "edited while the gate was running\n" >> notes.txt')
  GATE_BIN="$probe_gate" KM_GATE_BASE="$base" \
    expect "21j. a phase added later, reading a class no list names, is covered by construction" \
    "$c" 2 "notes.txt"
  # And it must not fire on everything: the same added phase over a tree that holds still passes.
  c="$work/stable_new_phase"; base=$(mkfixture "$c")
  GATE_BIN="$probe_gate" KM_GATE_BASE="$base" \
    expect "21j2. the same added phase over a stable tree still passes" "$c" 0 \
    "PASS release-gate:"
else
  note "FAIL: 21j. the probe gate could not be built; its anchors in the gate have moved"
  fail=1
fi

# ================================================================================================
# 21k-21k3. A QUESTION ASKED OF THE TREE IS A READ, EVEN WHEN NOTHING IS OPENED.
#           (Added in v1.61 draft; binds nothing until that version's own owner push.)
#
#      The ledger recorded CONTENT: what git_tracked and git_untracked enumerated, and what
#      read_text opened. The link phase opens nothing. It asks `does this path exist?`, uses the
#      answer in the verdict, and until v1.61 recorded nothing, so a discovered check could delete a
#      link target after the link phase had run and the gate returned PASS over a final tree
#      carrying a broken link. An external reviewer demonstrated it with a `.txt` target, which made
#      it look like the acknowledged residual of limit 5. It is not: the residual is material only a
#      DISCOVERED CHECK reads. Here the GATE read the target -- its existence -- and put the answer
#      in its own verdict.
#
#      So the ledger records ANSWERS, not only bytes, and `path_exists` is the accessor that asks.
#      The property the closing comparison now holds is one sentence: every answer this run took
#      from the tree is taken again at the verdict and must be the same answer. Both directions of
#      an existence answer can change, so both are cases here.
#
#      21h IS THE BOUNDARY AND IT STILL HOLDS. Its `notes.txt` is linked from nothing, so no phase
#      ever asks about it and it stays outside. The `notes.txt` below IS linked from README.md, so
#      the link phase asks. Same file name, same class, opposite verdicts, and the difference is
#      exactly whether the run asked.
# ================================================================================================

# mklinkdrift <dir> <readme-link-target> <mutator-body>: mkdrift, with README.md carrying one
# relative link to the named target, so the link phase asks about that path before the suites run.
mklinkdrift() {
  local d="$1" target="$2" body="$3"
  mkfixture "$d" >/dev/null
  printf '# Fixture readme\n\nSee [the standard](STANDARD.md).\nSee [the target](%s).\n' "$target" \
    > "$d/README.md"
  { printf '#!/bin/bash\n%s\n' "$DECL"; printf '%s\n' "$body"; printf 'exit 0\n'; } \
    > "$d/tests/test_zz_mutator.sh"
  git -C "$d" add -A >/dev/null
  git -C "$d" commit -qm "mutator" >/dev/null
  git -C "$d" rev-parse HEAD
}

# 21k. THE REVIEWER'S OWN CASE, and the mutator is theirs byte for byte: `rm notes.txt`, lifted from
#      reproduce-link-target-disappears.sh rather than written from a description of it.
c="$work/drift_link_gone"
base=$(mklinkdrift "$c" 'notes.txt' 'rm notes.txt')
KM_GATE_BASE="$base" \
  expect "21k. a link target the link phase resolved, deleted mid-run, is refused" "$c" 2 \
  "notes.txt"

# 21k2. THE REVERSE, which is the half a deletion-shaped repair would miss. The link phase asks
#       about a target that is ABSENT, records that answer and fails the tree for it; the mutator
#       then creates the file. The recorded answer no longer holds, so the verdict is a REFUSAL and
#       not the FAIL it was about to be -- a FAIL over a tree that no longer exists is no more
#       useful than a PASS over one, which is why the drift comparison runs before either branch.
c="$work/drift_link_appeared"
base=$(mklinkdrift "$c" 'late.txt' 'printf "created while the gate was running\n" > late.txt')
KM_GATE_BASE="$base" \
  expect "21k2. a link target that was absent when asked and then appears is refused" "$c" 2 \
  "late.txt"

# 21k3. The other direction, and it is not optional: a probe recorded on every relative link in the
#       repository must not make a tree that holds still refuse. This fixture asks the same question
#       and nothing answers it differently.
c="$work/stable_link"; base=$(mkfixture "$c")
printf '# Fixture readme\n\nSee [the standard](STANDARD.md).\nSee [the target](notes.txt).\n' \
  > "$c/README.md"
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "link" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" expect "21k3. a link target that holds still does not refuse" "$c" 0 \
  "PASS release-gate:"

# ================================================================================================
# 22. A DECLARATION THAT CITES A SCRIPT BY DIGEST STATES WHAT THAT SCRIPT PINS.
#     (Added in v1.61 draft; binds nothing until that version's own owner push.)
#
#      v1.60 published this sentence in the header of tests/test_skill_frontmatter.sh: "the
#      reviewer's script prints NOT REPRODUCED with checker_exit=1". It was false when it was
#      written. That script sets EXPECTED_SHA=73f89e8 and re-clones that commit whatever source root
#      it is handed, so it tests v1.59 on every run and prints REPRODUCED on every run. The same
#      false claim was published in this file's own v1.60 declaration. Both were known: the drafting
#      report said in plain words that the script "cannot show the repair, because it hard-pins
#      73f89e8 internally", and the true sentence stayed in the working report while the false one
#      went into the artifact.
#
#      A VERIFICATION DECLARATION IS A RECORD OF WHAT WAS RUN, AND A SCRIPT THAT PINS A REVISION
#      CANNOT TESTIFY ABOUT ANY OTHER REVISION. No check can read a declaration and know whether its
#      prose is true -- that is limit 2, and it is not being repealed here. What a check CAN do is
#      require the fact that makes the prose checkable BY A READER: when a declaration cites a
#      script by `sha256 <digest>`, the citation must be followed by what that script pins. This is
#      the move this repository already makes for exemptions, where a `km-gate-link-exempt` token
#      with no stated reason is refused rather than honoured.
#
#      The syntax is `sha256 <64 hex>, pins <what>` or `sha256 <64 hex>, unpinned`. A digest that is
#      not 64 hex characters fails here too, which is how the malformed 65-character digest v1.59
#      published for reproduce-invalid-yaml-sequence.sh was found.
# ================================================================================================
c="$work/decl_digest_bare"; base=$(mkfixture "$c")
cat > "$c/tests/test_beta.sh" <<'BARE'
#!/bin/bash
# km-unrepaired-tree: v9.9 | run using their script (reproduce-thing.sh, sha256 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef) and it printed REPRODUCED.
exit 0
BARE
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "bare digest" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" \
  expect "22. a declaration citing a digest without saying what it pins fails the gate" "$c" 1 \
  "does not say what that script pins"

# 22b. THE OTHER DIRECTION. A declaration that states the pin must pass, or the rule is a rule
#      against citing evidence at all.
c="$work/decl_digest_pinned"; base=$(mkfixture "$c")
cat > "$c/tests/test_beta.sh" <<'PINNED'
#!/bin/bash
# km-unrepaired-tree: v9.9 | run using their script (reproduce-thing.sh, sha256 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef, pins the fixture commit and therefore tested only that tree) and it printed REPRODUCED.
exit 0
PINNED
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "pinned digest" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" \
  expect "22b. a declaration that states what its cited script pins passes" "$c" 0 \
  "PASS release-gate:"

# 22c. AND `unpinned` IS THE OTHER TRUE ANSWER. A script that takes the tree it is handed can
#      testify about the tree it was handed, and saying so must not be harder than saying nothing.
c="$work/decl_digest_unpinned"; base=$(mkfixture "$c")
cat > "$c/tests/test_beta.sh" <<'UNPINNED'
#!/bin/bash
# km-unrepaired-tree: v9.9 | run using their script (reproduce-thing.sh, sha256 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef, unpinned: it gates the root it is given) and it printed REPRODUCED.
exit 0
UNPINNED
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "unpinned digest" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" \
  expect "22c. a declaration that says its cited script is unpinned passes" "$c" 0 \
  "PASS release-gate:"

# 22d. A MALFORMED DIGEST IS NOT A CITATION. 65 hex characters is what v1.59 published; it names no
#      file, and the rule must not accept it merely because the prose after it reads well.
c="$work/decl_digest_malformed"; base=$(mkfixture "$c")
cat > "$c/tests/test_beta.sh" <<'MALFORMED'
#!/bin/bash
# km-unrepaired-tree: v9.9 | run using their script (reproduce-thing.sh, sha256 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefa, pins the fixture commit) and it printed REPRODUCED.
exit 0
MALFORMED
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "malformed digest" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" \
  expect "22d. a declaration citing a digest that is not 64 hex characters fails the gate" "$c" 1 \
  "is not a 64-character sha256"

# 22e. AND PROSE IS NOT A CITATION. Found by running the rule against this repository rather than
#      by reasoning about it: the gate's own declaration says "cites a script by sha256 and says
#      nothing about what it pins", and the first form of the rule read `a` out of "and" and
#      reported a digest of length 1. A declaration is prose that contains the word, so the word
#      cannot be the trigger. Without this case the 16-character floor is a patch applied until the
#      tree went green, which is the thing this repository publishes a rule against.
c="$work/decl_digest_prose"; base=$(mkfixture "$c")
cat > "$c/tests/test_beta.sh" <<'PROSE'
#!/bin/bash
# km-unrepaired-tree: v9.9 | no script was used. This check cites nothing by sha256 and says nothing about any pin, because there is nothing to cite; the run was made by hand against the fixture tree.
exit 0
PROSE
git -C "$c" add -A >/dev/null; git -C "$c" commit -qm "prose" >/dev/null
base=$(git -C "$c" rev-parse HEAD)
KM_GATE_BASE="$base" \
  expect "22e. prose mentioning sha256 without a digest is not read as a citation" "$c" 0 \
  "PASS release-gate:"

# 21f. The stable tree must still pass, and the fingerprint must not make it flaky. Case 1 already
#      requires PASS on a whole tree; this runs the same fixture twice and requires the same verdict
#      both times, because a stability check that is itself unstable is worse than none.
c="$work/stable"; base=$(mkfixture "$c")
KM_GATE_BASE="$base" expect "21f. a stable tree passes" "$c" 0 "PASS release-gate:"
KM_GATE_BASE="$base" expect "21f2. a stable tree passes again, with the same verdict" "$c" 0 \
  "PASS release-gate:"

if [ "$fail" -eq 0 ]; then
  note ""
  note "release-gate canaries passed"
  exit 0
else
  note ""
  note "release-gate canaries FAILED"
  exit 1
fi
