# Tasks

Executed on branch `v1.54-gate-discovery-scope`, off `main` at `eb57f0f` (published v1.53). Ordered by
dependency: reproduce before repairing, measure the unrepaired tree before the repair is in the
working tree, repair, prove the other direction, then record.

Requirement references point at `specs/release-verification-scope/spec.md` (RVS).

## 1. Verify the premise before repairing anything

- [x] 1.1 Read the gate's actual discovery call rather than the brief's paraphrase. Confirm
      `discover()` obtains its file list from `git_tracked()` and that `git_tracked()` runs
      `git ls-files`, which lists the index.
- [x] 1.2 Read the contract's actual ordering. Confirm `agents/km-hub-builder/SKILL.md` places the
      release gate ahead of the numbered pre-commit list whose third item is explicit staging, so the
      gate is specified to run while a new check is untracked.
- [x] 1.3 Establish the baseline on the clean tree. `33 check(s) discovered under tests/ and
      scripts/`, `PASS release-gate`, exit 0, `30 shell file(s) syntax-checked`.
- [x] 1.4 Reproduce the finding. `tests/test_zz_probe.sh` was written into the working tree,
      untracked, holding `this is not valid shell ((((`. `bash -n` rejects it with
      `syntax error near unexpected token '('`. `git status --short` shows `?? tests/test_zz_probe.sh`.
      The gate reported `33 check(s) discovered`, `PASS release-gate`, exit 0, `30 shell file(s)
      syntax-checked`. The file was neither run nor named anywhere in the output.
      (RVS: an untracked check-shaped file cannot be parsed)
- [x] 1.5 The count did not move: 33 and 33, PASS and PASS, exit 0 and exit 0. That is what makes
      this a blindness rather than a misjudgement. Confirmed on the full run and again under
      `--no-suites`, which isolates discovery from execution.
- [x] 1.6 Establish why the gate's own canaries never caught it. Cases 7, 9, 10 and 17 each `git add`
      the fixture file they introduce before gating it. The v1.48 workaround is written into the
      fixtures of the suite that exists to break this gate, so the untracked path was never
      exercised. That is the finding underneath the finding.
- [x] 1.7 Remove the probe and confirm the working tree is clean again before any repair is written.

## 2. Decide the shape of the repair, and argue it

- [x] 2.1 Evaluate the reviewer's option 1, rejecting untracked check-shaped files. Record why it is
      rejected: it never runs the new check, so the maintainer must stage to obtain a verdict, which
      is the v1.48 workaround promoted from a note to a rule.
- [x] 2.2 Evaluate the reviewer's option 2, requiring a clean or fully staged tree. Record why it is
      rejected: it reddens ordinary editing, it forces the published ritual to be rewritten from
      gate-then-stage to stage-then-gate for every change, and it puts the pre-commit review step
      after the gate rather than before it.
- [x] 2.3 Adopt the union shape: discover tracked and untracked-not-ignored check-shaped files under
      the same roots, run both, report which is which.
      (RVS: a release gate is a verdict about the working tree)
- [x] 2.4 State the trade accepted rather than presenting the choice as free: the verdict is now about
      the working tree, so a scratch file shaped like a check will be discovered, required to carry a
      declaration, and executed. Record the two smaller trades with it.
- [x] 2.5 Fix the boundary of the union. Discovery only; the JSON and relative-link phases stay
      index-scoped so a half-written markdown file does not redden the gate.
      (RVS: a phase deliberately remains index-scoped)
- [x] 2.6 Decide the ignored-path line and write it down as a residual gap rather than a property.
      (RVS: a check-shaped file is ignored)

## 3. Write the canary before the repair, and run it against the unrepaired gate

- [x] 3.1 Add cases 19 and 19b: a whole fixture tree plus one untracked check-shaped file carrying a
      shell syntax error, requiring a non-passing verdict that names the file, and requiring it to be
      named as a syntax error rather than merely as a failed run.
- [x] 3.2 Add cases 19c and 19d: the same fixture with the untracked file removed, requiring PASS and
      requiring the coverage line to state the untracked count as zero rather than omitting it. This
      is the other direction; a case that failed here would be failing on everything.
      (RVS: the tree holds no untracked check-shaped file; every discovered check is tracked)
- [x] 3.3 Add cases 19e and 19f: an untracked check that parses but carries no declaration, and one
      that pleads the unrecorded token, each required to fail.
      (RVS: an untracked check carries no declaration; an untracked check pleads that nothing was
      recorded)
- [x] 3.4 Add cases 19g, 19h and 19i: an untracked check declaring the drafted version with a result
      text, required to pass, to be named as untracked on the run and to be counted on the coverage
      line.
      (RVS: an untracked check is discovered and runs; an untracked check names the drafted version)
- [x] 3.5 Add case 19j: an ignored check-shaped file is NOT discovered, pinned as a gap rather than as
      a control so a later change that closes it fails loudly here.
      (RVS: a check-shaped file is ignored)
- [x] 3.6 Run the new cases against the UNREPAIRED gate, before the repair is in the working tree.
      **8 of the 11 new assertions failed and the suite exited 1.** Case 19 reported `expected exit 1,
      got 0` over `PASS release-gate: 2 check(s) discovered`; 19b, 19e, 19f likewise; 19d, 19h and 19i
      reported that the output never carried the provenance text; case 15 failed because the fourth
      limit was not yet stated. Of the three that passed, 19c and 19j passed legitimately, and 19g
      passed for the wrong reason: the untracked check it declares was invisible, so the tree it
      gated was the fixture without it. This is the run the `km-unrepaired-tree` declaration on
      `tests/test_release_gate.sh` cites.

## 4. Repair the instrument

- [x] 4.1 Add `git_untracked(root, patterns)`, mirroring `git_tracked` with
      `--others --exclude-standard`, same NUL separation, same refusal on a non-zero exit.
- [x] 4.2 Union the two listings in `discover()`, and carry a `tracked` boolean on each `Check`.
- [x] 4.3 Union the untracked discovered rels into the changed set in `check_declarations`, so an
      untracked check lands in the ADDED arm.
- [x] 4.4 Extend the shell and Python syntax phases to cover the discovered checks as well as the
      tracked files, so an unparseable check is named before anything executes it.
- [x] 4.5 Add the provenance clause to the END of the coverage line, and mark each untracked check in
      the run output.
      (RVS: discovery reports the provenance of what it discovered)
- [x] 4.6 Drop the word `tracked` from the two refusal messages in `discover()` that no longer describe
      the scope, and move case 5b's needle with them in the same change.
- [x] 4.7 Rewrite the gate's DISCOVERY header block to describe the union, and add the ignored-path
      exclusion to the stated limits.
- [x] 4.8 Re-state the `km-unrepaired-tree` declaration on `tools/km-release-gate.py` naming v1.54 with
      the result measured in task 1.4.
- [x] 4.9 Re-state the `km-unrepaired-tree` declaration on `tests/test_release_gate.sh` naming v1.54
      with the result measured in task 3.5.

## 5. Prove both directions on the real repository

- [x] 5.1 Run `tests/test_release_gate.sh` against the repaired gate. **All 54 assertions pass, exit
      0**, old cases and new.
- [x] 5.2 Re-run the measured reproduction from task 1.4 against the repaired gate. `34 check(s)
      discovered`, `FAIL release-gate: 2 finding(s)`, naming `tests/test_zz_probe.sh: shell syntax
      error` with the interpreter's own message, and `tests/test_zz_probe.sh: no km-unrepaired-tree
      declaration`. The measured case is closed.
- [x] 5.3 Remove the probe and confirm the repository gates clean, exit 0.
- [x] 5.4 The discovered count on the clean tree is `33`, unchanged from the baseline, and the
      coverage line reads `0 discovered check(s) untracked`. The repair did not quietly widen what the
      gate runs on a tracked tree.

## 6. Amend the contract and the standard

- [x] 6.1 Amend `agents/km-hub-builder/SKILL.md` so the ordering instruction states which tree the gate
      reads and that a newly authored check needs no staging to be seen.
      (RVS: a contract that orders the gate relative to staging states which tree the gate reads)
- [x] 6.2 Amend `STANDARD.md` §"A gate runs before publication, and it declares what it cannot do" to
      carry the working-tree rule and the ignored-path gap.

## 7. Record

- [x] 7.1 Flip the header, the frontmatter title and the lead of `STANDARD.md` to v1.54 drafted and
      unpublished, preserving the published v1.53, v1.52 and v1.51 descriptions verbatim.
- [x] 7.2 Write the v1.54 version row: the external review as the source, the measured reproduction
      quoted, the gap named as known since v1.48 and left open, the shape chosen and the trade
      accepted, both directions, and the limits.
- [x] 7.3 `openspec validate audit-gate-discovery-scope --strict` passes.
- [x] 7.4 Run the full gate to exit 0 and the canonical leakage instrument over the final tree, both
      halves, reporting file counts and the hit list.
- [x] 7.5 Commit with explicit paths and the `KM-Agent: km-hub-builder` trailer. Do not push.
