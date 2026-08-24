# Tasks

Executed 2026-08-24 on branch `v1.47-ledger-date-integrity`, off `main` at `a2756e2` (published
v1.46). Tasks are ordered by dependency: sweep before correcting, build the check and run it against
the unrepaired tree before the correction is in the working tree, correct, prove the other direction,
then close the cause and record.

Requirement references point at `specs/ledger-date-integrity/spec.md` (LDI).

## 1. Sweep before acting

- [x] 1.1 Parse every version-history row in `STANDARD.md` and resolve each version to its publish
      commit from the repository. 47 rows read. (LDI: the publish commit is resolved from the
      repository)
- [x] 1.2 Record the resolution: 26 compared, of which 22 by annotated tag and 4 by commit subject
      (v1.16 through v1.19); 1 excluded as drafted (v1.23); 20 unresolved (v1.0 through v1.15,
      v1.20, v1.21, v1.24, v1.25).
- [x] 1.3 Record the two disagreements with their evidence: v1.40 claiming 2026-08-22 against publish
      commit `9c14f85` authored `2026-08-23 13:32:21 +0200`, and v1.33 claiming 2026-08-20 against
      publish commit `16109ea` authored `2026-08-21 00:24:40 +0200`. A sweep that is not recorded is
      a claim.
- [x] 1.4 Corroborate v1.40 against two further events: the draft commit `64015a6` at
      `2026-08-23 13:15:23 +0200` and the overlay re-pin at `2026-08-23 13:37:57 +0200`. All three
      events are on the same day and none of them is 2026-08-22.
- [x] 1.5 Read the diff of `16109ea` and confirm the mechanism for v1.33: the publishing commit
      rewrote the stamp to 2026-08-21 and left the date column at the draft date. The row has
      contradicted itself in published text ever since. (LDI: the ritual is applied to half the row)
- [x] 1.6 Confirm v1.33's commit subject and tag already read 2026-08-21, so only its date column is
      wrong and it needs no discrepancy note. (LDI: the pushed history already carries the correct
      date)
- [x] 1.7 **Report the premise failure rather than improvising.** The brief stated v1.40 was the only
      mismatch. It was not. Work stopped, the second finding was reported with its evidence, and the
      scope decision was taken by the owner before anything was written.
- [x] 1.8 Record how the earlier sweep missed v1.33: it compared each publish commit's subject date
      against that same commit's timestamp, a pair that agrees by construction. The comparison that
      finds this class is the ledger row against the commit, which is a different pair.

## 2. Build the check and run it against the unrepaired tree

- [x] 2.1 Derive the version-to-commit mapping from the repository: annotated tag first, commit
      subject search second, with the method reported per version and no table of versions, commits
      or dates held in the check. (LDI: the publish commit is resolved from the repository and never
      from a table in the check)
- [x] 2.2 Exclude a draft subject from resolving as a publication, and refuse to resolve an ambiguous
      subject search rather than picking one of its candidates. (LDI: two commits carry the same
      version subject on different branches)
- [x] 2.3 Read the author date in the commit's own recorded offset. Confirm that UTC would report
      v1.33's false row as correct, which is why the offset is not normalised. (LDI: the comparison
      is made in the repository's own recorded timezone)
- [x] 2.4 Keep the three outcomes apart: excluded (drafted), unresolved (coverage gap), compared.
      (LDI: a drafted version is an exclusion and an unresolvable version is a coverage gap)
- [x] 2.5 Fail closed on an unreadable ledger, a missing version-history heading, an empty table, an
      unparsable row, a date column that is not a date, an unusable git, and an empty resolution set.
      (LDI: the check refuses rather than passes on input it could not evaluate)
- [x] 2.6 State coverage on a passing run: rows read, compared, resolved by tag, resolved by subject,
      excluded, unresolved, with the excluded and unresolved versions named. (LDI: a passing run
      states its own coverage)
- [x] 2.7 **Run the check against the tree before the correction.** Confirm it exits 1 and names both
      rows with all four dates. Confirm the working-tree ledger is byte-identical to `a2756e2`, so
      the run is against published `main` and not a likeness of it.
- [x] 2.8 Record that run in the check's own `km-unrepaired-tree:` declaration, naming v1.47 and the
      real result, before the correction entered the working tree.

## 3. Correct the record

- [x] 3.1 v1.40: date column and stamp to 2026-08-23. (LDI: a version-history row's date is the date
      its publish commit was made)
- [x] 3.2 v1.33: date column to 2026-08-21. Its stamp is already correct and is untouched.
- [x] 3.3 Confirm by word-level diff that exactly three date tokens changed and no other word in
      either row did.
- [x] 3.4 Re-run the check and confirm the tree passes with its coverage stated.

## 4. Leave the pushed history alone, and say so

- [x] 4.1 Do not amend the v1.40 publish commit `9c14f85` and do not retag `v1.40`. Both carry
      `owner push 2026-08-22` and both stay. (LDI: a false date is corrected in the ledger and not
      erased from pushed history)
- [x] 4.2 Record in the v1.47 row that the commit subject and the tag retain the original date, that
      the ledger is the corrected record of account, and why erasing the discrepancy would be the
      worse remedy.
- [x] 4.3 State the asymmetry: v1.33 gets no discrepancy note because its subject and tag already
      read 2026-08-21. A reader must not have to guess why one version has a note and the other does
      not. (LDI: the pushed history already carries the correct date)

## 5. Prove both directions

- [x] 5.1 Firing case: one real date altered by one day in a fixture ledger, requiring the version,
      both dates and the resolution method to be named, and requiring exactly one disagreement.
- [x] 5.2 Non-firing case: the same fixture with every date correct, required NOT to fire. A check
      that fires on everything proves as little as one that fires on nothing.
- [x] 5.3 Offset case, asserted as a pair: v1.33 against 2026-08-20 must fire and against 2026-08-21
      must pass, so the commit's own offset is pinned and a later change to UTC would fail the suite.
- [x] 5.4 Derivation case: an untagged version (v1.16) must resolve through its commit subject, with
      the method reported and the tag count reported as zero.
- [x] 5.5 Exclusion case: a drafted row is excluded by name and is NOT reported as a coverage gap.
- [x] 5.6 Gap case: an unresolvable version is named in a coverage gap while the run still passes on
      the rows it could judge, so the gap is folded into the verdict in neither direction.
- [x] 5.7 Seven refusal cases, each asserting the refusal status and a line saying what could not be
      evaluated.
- [x] 5.8 **The evidence case:** run the check against the version-history table of published `main`
      at `a2756e2`, taken from git rather than reconstructed, and assert both rows by name with all
      four dates and a count of exactly two, so a blanket match cannot pass as a finding.
- [x] 5.9 Run the whole suite against the uncorrected repository first: every case passed except the
      real-repository case, which failed naming both rows. That failure is the suite-level negative
      direction and it was recorded before the correction was applied.
- [x] 5.10 Name the branch no fixture reaches: a git that is present, runnable and failing for a
      reason other than the root not being a repository. Defence in depth, not a proved behaviour.

## 6. Close the cause

- [x] 6.1 Amend step 2 of *Publishing a version*: the date column and the stamp are both derived from
      the publishing commit, in that commit's own offset, in the same act. (LDI: a version-history
      row's date is the date its publish commit was made)
- [x] 6.2 State all four pieces of evidence in the ritual: v1.40, v1.33, the v1.45 near miss, and the
      sweep that went looking for this class and compared a pair that agrees by construction.
- [x] 6.3 Add the non-rewriting rule to the ritual as its own paragraph, so it governs the next
      correction and not only this one.
- [x] 6.4 Update `agents/km-hub-builder/SKILL.md` to say the same to the drafting agent, in the
      section that already governs version selection.
- [x] 6.5 Confirm the two runtime adapters reference `SKILL.md` by path and carry no copy of its
      body, so no mirror needs the same edit. `agents/km-hub-builder/tests/test-agent-package.sh`
      re-run green.
- [x] 6.6 Mark both amendments for v1.47 while drafted, per the ritual v1.42 amended.

## 7. Record

- [x] 7.1 Write the v1.47 row: the defect measured on both rows, the correction, the deliberate
      non-rewriting with the asymmetry stated, the check and how it resolves, the offset decision,
      the three outcomes, the full 47-row sweep, both directions, the cause closed, and the limit.
- [x] 7.2 Flip the header, the frontmatter title and the lead to v1.47 drafted-unpublished,
      preserving the published v1.46, v1.45 and v1.44 descriptions word for word.
- [x] 7.3 State the limit plainly: the check reads the date column and not the stamp prose, and that
      is exactly the half of the v1.33 row that was correct.
- [x] 7.4 Leave `README.md` and the version badge on v1.46, as the ritual requires while a version is
      drafted.

## 8. Verification

- [x] 8.1 `openspec validate audit-ledger-date-integrity --strict` passes.
- [x] 8.2 `tests/test_ledger_dates.sh` passes after the correction, and failed its real-repository
      case before it.
- [x] 8.3 `python3 scripts/validate_ledger_dates.py` passes with its coverage and gap stated.
- [x] 8.4 `python3 scripts/validate_published_not_draft.py` passes, classifying v1.47 as unpublished
      beside v1.23.
- [x] 8.5 `python3 tools/km-release-gate.py` passes, per step 5 of the ritual.
- [x] 8.6 `git diff --check` and `git diff --cached --check` clean.
- [ ] 8.7 Leakage guard: not run here. It lives in the deployment's overlay and is the overlay owner's to run.
- [x] 8.8 Stage by explicit path. Preserve the pre-existing `.gitignore` modification and leave
      `openspec/` untracked.
- [x] 8.9 Did not push, did not tag, did not amend or rewrite any commit or tag, and left `main`
      untouched. Publication is the owner's decision.
