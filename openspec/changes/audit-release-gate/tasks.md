# Tasks

Executed 2026-08-24 on branch `v1.46-release-gate`, off `main` at `cf375b2` (published v1.45). Tasks
are ordered by dependency: establish the ground truth before designing the runner, prove the runner's
declaration phase against the tree before the retrofit, retrofit, canary, then run against
deliberately broken trees, then record.

Requirement references point at `specs/release-verification/spec.md` (RV).

## 1. Establish the ground truth before designing anything

- [x] 1.1 Confirm the finding first-hand rather than from the report: no `.github/workflows`, no
      `Makefile`, no `justfile`, no repository-level runner on `main` at `cf375b2`. (RV: one command
      runs the whole gate)
- [x] 1.2 Enumerate what exists: seventeen suites under `tests/`, three validators under `scripts/`.
- [x] 1.3 Run every one of them by hand and record exit status and duration, so the runner is written
      against what the repository does rather than what it is assumed to do.
- [x] 1.4 Record the two that refuse when run bare and why: `tests/test_canonical_leakage.sh` exits 2
      with a usage line because it takes a denylist pattern, and
      `scripts/validate_organization_profile.py` requires a profile path and `--canonical-version`.
      (RV: anything discovered but not run is reported with its reason)
- [x] 1.5 Read each check's own header for a recorded run against an unrepaired tree, so the
      retrofit records evidence rather than a reconstruction.
- [x] 1.6 Probe the relative-link check against the tracked tree before writing it: 91 links across
      91 files, none broken, and the reference-definition form present zero times, so including that
      form costs nothing and closes a form gap.
- [x] 1.7 Record the process defect found while doing this: editing a check while a bash suite was
      mid-run corrupted the running script and produced a false syntax error. Suites and edits are
      not interleaved for the rest of this change.

## 2. Build the runner

- [x] 2.1 Discover the run set from the tracked tree rather than from a list in the runner. (RV: what
      runs is derived by discovery)
- [x] 2.2 Broaden the scope to any `tests/` or `scripts/` directory rather than the root pair, after
      finding a live suite, a parity instrument and an installer under `agents/km-hub-builder/` that
      no release ever ran. (RV: what runs is derived by discovery)
- [x] 2.3 Run every suite and validator, then a shell syntax check, a Python syntax check, a JSON and
      JSON-LD parse check and a relative-link check over the tracked tree. Run cheap phases first and
      every phase to completion, so one failure does not hide the rest. (RV: one command runs the
      whole gate)
- [x] 2.4 Fail closed on an unreadable or undecodable file, a check that cannot be executed, an
      empty discovery set, a discovery directory yielding nothing, and an unlistable tree, with a
      refusal status distinct from a failure and a line saying a refusal is not a pass. (RV: the
      gate refuses rather than passes)
- [x] 2.5 State coverage on a passing run: checks discovered, run and skipped, declarations by kind,
      and the file count of every static phase. (RV: a passing run states its own coverage)
- [x] 2.6 Report the run's own total and its three slowest checks, so the duration claimed in the
      workflow can be checked against a run rather than believed.
- [x] 2.7 Hold the gate to its own declaration rule, locating itself through `__file__` rather than
      by name. (RV: the gate is held to its own declaration rule)

## 3. Prove the declaration phase against the tree before repairing it

- [x] 3.1 **Run the gate against the unrepaired tree.** It fails, naming all twenty existing checks
      as carrying no `km-unrepaired-tree` declaration. Recorded before the retrofit, because
      afterwards the run is no longer available. (RV: a version that adds or changes a check
      declares its run against the unrepaired tree)
- [x] 3.2 Design the declaration as one machine-read line: a version, `none`, or `unrecorded`, a
      separator, and a required result text.
- [x] 3.3 Discover, by attempting the retrofit, that the naive currency rule is wrong: adding the
      declaration line changes every check, so requiring the drafted version of every changed check
      would demand twenty fresh runs for twenty comment lines. Split the rule at the seam where
      adding and changing genuinely differ. (RV: added and changed sub-rules)
- [x] 3.4 Refuse `unrecorded` on a check the change adds; require the declaration line to be among
      the change's added lines on a check the change edits; report a coverage gap when no base
      resolves. (RV: a version that adds or changes a check declares its run)

## 4. Retrofit the declarations, and change nothing any check tests

- [x] 4.1 Add one declaration line to each of the twenty checks under `tests/` and `scripts/`, taken
      from that file's own recorded evidence.
- [x] 4.2 Add three more under `agents/km-hub-builder/` once the scope was broadened, including one
      `none` for the installer, which has no violation class to run against an unrepaired tree.
- [x] 4.3 Say `unrecorded` with a reason for the checks whose headers record no such run, rather than
      inventing a plausible one. Nine of twenty-five. Confirm the gate counts them separately on the
      passing line so the debt is visible.
- [x] 4.4 Declare the four instruments with the canaries that cover them, and confirm the gate
      refuses when a named canary would not run. (RV: anything discovered but not run is reported
      with its reason and is covered)
- [x] 4.5 Confirm no check's behaviour changed: the additions are comment lines, and the full suite
      is green afterwards.

## 5. Prove the gate in both directions

- [x] 5.1 A failing suite and a failing validator each fail the gate and are named. (RV: one command
      runs the whole gate)
- [x] 5.2 A check that cannot execute, an empty discovery set, a directory yielding nothing, a tree
      that is not a repository, an undecodable tracked file, an instrument whose canaries would not
      run, an instrument exemption with no reason, and a link exemption with no reason all refuse.
      (RV: the gate refuses rather than passes)
- [x] 5.3 A missing declaration, an empty declaration, an added check pleading `unrecorded`, an added
      check naming a stale version, and a changed check with an untouched declaration all fail. (RV:
      a version that adds or changes a check declares its run)
- [x] 5.4 Each static phase fires on one broken thing: a shell syntax error, a Python syntax error,
      unparseable JSON, unparseable JSON-LD, and a relative link resolving to nothing.
- [x] 5.5 **The negative direction.** Whole trees pass, at the start of the run and again at the end
      after every other case has broken something, so a fixture that leaked state cannot hide. The
      link check is proved not to over-fire on resolving, anchored, remote or fenced-code links.
      (RV: the negative direction)
- [x] 5.6 The repaired form of every declaration case is required to pass, so no case is a one-way
      assertion.
- [x] 5.7 Prove the base fallback in both directions: an unresolvable base with no branch to fall
      back to is a coverage gap, and an unresolvable explicit base with a branch present falls back
      and checks currency.
- [x] 5.8 Assert that the gate states all three limits in its own header, since none of them is a
      property of the tree. (RV: the gate states the things it cannot do)
- [x] 5.9 Forty-four assertions in `tests/test_release_gate.sh`, each breaking exactly one thing.
- [x] 5.10 A run that executed no check is labelled STATIC ONLY on the verdict line itself and
      reports a coverage gap, so it cannot be grepped for or recorded as an ordinary pass.

## 6. Run the gate against deliberately broken trees, which is the rule it imposes

- [x] 6.1 **The gate found a defect in itself on its first full run against the real repository.** It
      REFUSED, because `tests/test_release_gate.sh` writes instrument declarations into the fixtures
      it builds and a whole-file search read one of those fixture lines as the canary file's own
      claim.
- [x] 6.2 Fix the class rather than exempting the one file: declarations are read from the leading
      comment block only. Canary both directions, so a body carrying the syntax passes and a body
      carrying the syntax with no header declaration still fails. (RV: the gate is proved in both
      directions)
- [x] 6.3 Break the real repository, one way at a time, restoring after each: a real suite made to
      fail, a real suite whose command does not exist, and a real check with its declaration
      stripped. Each produced FAIL or REFUSED and never PASS.
- [x] 6.4 Untrack every check in a copy of the real repository and confirm the gate REFUSES on an
      empty discovery set rather than passing on a tree with nothing to run.
- [x] 6.5 Record the artifact of the copy-based runs honestly: in a copy made without git history,
      `tests/test_skill_distribution_parity.sh` fails because the commit its evidence case anchors
      on is absent. That is a property of the copy, not of the gate, and the real-repository breaks
      are the evidence relied on.
- [x] 6.6 **Record the third limit the exercise found, which is why it is done rather than reasoned
      about.** Given a real suite carrying a command that does not exist, the gate PASSED: the suite
      does not run under a fail-fast shell option, swallowed the 127, and exited 0 on its own
      accounting. The gate reads a check's exit status and cannot see inside it. State it beside the
      other two limits, and pin it with a case asserting it as an acknowledged gap. (RV: a check
      fails internally and returns success)
- [x] 6.7 Re-run the same break made genuinely unexecutable, where the process itself ends on the
      missing command, and confirm the gate REFUSES.
- [x] 6.8 Confirm the gate passes on the current tree, before and after the duration reporting was
      added, and again at the end of the change.

## 7. CI

- [x] 7.1 `.github/workflows/release-gate.yml` runs the gate on push and pull request. (RV: the gate
      runs in continuous integration)
- [x] 7.2 Pin the runner image and pin the checkout action by commit SHA, so the verdict changes when
      this repository changes and not when a hosted image does.
- [x] 7.3 Fetch full history, because a shallow clone resolves no base and the currency rule would
      become a permanent coverage gap.
- [x] 7.4 Resolve the base from the pull request base or the push's previous revision, and rely on
      the gate's own fallback for a branch's first push, where the reported revision is all zeros.
- [x] 7.5 State the expected duration from measurement rather than estimate: 8 to 11 minutes across
      four full runs, dominated by two suites at roughly 5 and 2 minutes. Set a timeout well above
      it. (RV: a reader estimates how long a run takes)
- [x] 7.6 State both limits in the workflow itself, because a badge is read where the standard is
      not. (RV: a reader takes the green badge for a clean push)

## 8. The two stated limits

- [x] 8.1 State that the gate cannot run an organisation leakage scan, why the denylist is outside
      the repository by design, that the canaries prove the instrument and never a push, and that
      the local fail-closed pre-push hook remains the only thing that scans an actual push. (RV: the
      leakage scan is expected of CI)
- [x] 8.2 State that no script supplies a second actor, that the minimum viable independence is an
      adversarial pass by someone other than the author against the class being repaired, and that
      the gate's green does not imply it. (RV: the green line is read as independent verification)
- [x] 8.3 Write all three as properties of the arrangement rather than as work deferred, in the
      runner's header and in `STANDARD.md`, with the first two repeated in the workflow because a
      badge is read where the standard is not. (RV: a limit is treated as a backlog item)
- [x] 8.4 State the limit of the declaration itself: the gate checks that one was made and
      re-stated, never that the run behind it happened. (RV: a declaration is made and is untrue)

## 9. Record

- [x] 9.1 Graft the rule into the Standard Maintainer section beside the instrument rules it is a
      sibling of, rather than opening a new top-level section.
- [x] 9.2 Name the three verification failures plainly, and name the cause rather than the symptom:
      the actor verifying was the actor who authored.
- [x] 9.3 Record the four-times evidence for the unrepaired-tree run, since it is what makes the
      declaration the mandatory step rather than advice.
- [x] 9.4 Add step 5 to the publish ritual and say why step 4 keeps its own number. (RV: running the
      gate is a step of the publish ritual)
- [x] 9.5 Amend `agents/km-hub-builder/SKILL.md` to match the ritual and to carry both limits into
      every report the role writes. (RV: the ritual and the agent contract disagree)
- [x] 9.6 Mark the new material for v1.46 while it is drafted, per the ritual v1.42 added.
- [x] 9.7 Write the v1.46 version row: cite F-06, name the three failures, record the runner, the
      workflow and the declaration, and state both limits explicitly.
- [x] 9.8 Flip the header and lead to v1.46 drafted-unpublished, preserving the published v1.45,
      v1.44 and v1.43 descriptions word for word.

## 10. Verification

- [x] 10.1 `openspec validate audit-release-gate --strict` passes.
- [x] 10.2 `tests/test_release_gate.sh` passes, forty-four assertions.
- [x] 10.3 `python3 tools/km-release-gate.py` passes on the current tree, and the coverage line
      states what it looked at.
- [x] 10.4 `python3 scripts/validate_published_not_draft.py` passes per step 4 of the ritual,
      classifying v1.46 as unpublished beside v1.23.
- [x] 10.5 `python3 scripts/validate_rfc_references.py` passes.
- [x] 10.6 `git diff --check` clean.
- [ ] 10.7 Leakage guard: not run here. It is the steward tier's to run.
- [x] 10.8 Stage by explicit path. Preserve the pre-existing `.gitignore` modification through the
      branch checkout by stashing and restoring it, never discarding it.
- [x] 10.9 Did not push, did not tag, did not merge, and left `main` untouched. Publication is the
      owner's decision.
