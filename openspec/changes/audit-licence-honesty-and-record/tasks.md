# Tasks

Executed 2026-08-24 on branch `v1.49-licence-honesty-and-record`, off `main` at `ec51128` (published
v1.48). Tasks are ordered by dependency: verify before repairing, scan before committing the record,
repair, then record. `main` is untouched and nothing is pushed.

This change adds no requirement and carries no delta spec, so there are no requirement references to
point at. The reasoning is in `design.md`, Decision 4.

## 1. Verify before repairing

- [x] 1.1 Reproduce F-07's first claim: read `README.md` and record the reuse sentence verbatim.
      Line 111: *"This standard is free to adopt, adapt, fork, and redistribute for any
      organization's internal or external knowledge management needs. No attribution required."*
- [x] 1.2 Verify the absence rather than take it from the finding: listed `LICENSE`, `LICENSE.md`,
      `LICENCE`, `COPYING` and `COPYING.md` at the repository root. None exists.
- [x] 1.3 Read `assets/badges/license.svg` and record its text: `license` / `free to adopt`. Record
      the README `alt` at line 16: `alt="license: free to adopt"`.
- [x] 1.4 Sweep the tree for the same claim rather than assume the finding named every instance.
      Two further surfaces found in `STANDARD.md`: the closing line (*"free to adopt, adapt, and
      redistribute for any team, company, or individual's knowledge management needs"*) and one
      clause of §"The boundary asserts no license" (*"a license-neutral description of a boundary
      that anyone may adopt for free"*). Both are in the normative document.
- [x] 1.5 Reproduce Part C's claim: `template/README.md` line 73 reads *"Full governance reference:
      AI KM Hub Standard (available from the hub owner)."* A tree-wide search for "AI KM Hub
      Standard" finds it only in that line, in the v1.48 version row that reported it, and in the
      v1.48 design that deferred it. No document carries the name.
- [x] 1.6 Inventory the untracked record before committing it: 37 files under `openspec/` in 9 change
      packages, 332,202 bytes; with this change's own package, 40 files and 366,215 bytes.
- [x] 1.7 Verify the `.gitignore` premise rather than act on a line number supplied to this change.
      The rule excluding the external report is present only in the working tree; `.gitignore` at
      `main` (`ec51128`) has twelve lines and no such rule, so the exclusion depended on one
      machine's working tree and would not have survived a clone.
- [x] 1.8 Check how the nine existing packages actually cite the audit, rather than assume they name
      a path. They describe it as "the external audit of 2026-08-22" and similar; no package writes
      a filename, and a tree-wide search for a Markdown link to it finds none. Nothing in them needs
      repairing on that count.

## 2. Scan before committing, and let the scan decide

- [x] 2.1 Establish that the material had never been scanned: the canonical instrument enumerates
      **tracked** files, and these were untracked, so they were outside every previous scan's scope
      by construction. Scan before staging rather than after.
- [x] 2.2 Split the deployment's generated denylist as the pre-push hook does: 750 case-insensitive
      entries, 10 case-sensitive, 762 lines generated 2026-08-23.
- [x] 2.3 Scan each file with the hook's own matching semantics (`grep -inwF` and `grep -nwF`).
      **`openspec/` is clean: zero hits on both halves across all 40 files.** The external QA report
      produces **one case-insensitive hit**: a word in one heading that is a denylisted entity name
      in the deployment's semantic layer and an ordinary English verb in the sentence it appears in.
- [x] 2.4 Inspect the hit rather than act on the count, and report it rather than clear it.
- [x] 2.5 Refuse to edit the report. It is external evidence, and altering a document to satisfy a
      control that examines it inverts what the control is for.
- [x] 2.6 Refuse to exempt the term or narrow the guard. The exemption would be permanent and would
      cover every later document using that name in its real sense.
- [x] 2.7 Refuse to drop the report while leaving citations that name it, which would recreate the
      dangling-reference class v1.45 published a check to close.
- [x] 2.8 Take the fourth option: keep the report out, commit the record, repair the citations, and
      commit the ignore rule with its reason. See `design.md` Decision 5.
- [x] 2.9 Do not name the denylisted term anywhere in this repository, including in commit messages,
      the version row and the ignore comment, so that recording the finding does not create the
      occurrence the finding is about.

## 3. Commit the record without the report

- [x] 3.1 Restore the ignore rule and **commit it**, with a comment stating what the document is,
      where it is held, that the leakage guard denylists a term it uses in an ordinary English sense,
      and that editing the report and weakening the guard were both refused. The absence is now
      explained where a reader meets it.
- [x] 3.2 Repair every reference in this package so none names a filename or a path. Each now
      describes an external QA report of 2026-08-22 held in the deployment's records.
- [x] 3.3 Leave the nine existing packages alone. They record what was proposed when they were
      written, and `audit-remediation-2026-08-22/proposal.md` poses the tracking decision as open. A
      record edited to agree with the present is no longer a record; the resolution is carried by the
      ignore rule and the version row instead.
- [x] 3.4 Rebuild both commits from `main` rather than correcting forward. The pre-push hook scans
      the diff of every outgoing commit, so a blob committed once and deleted later is still
      transmitted and still refused. Neither commit had been pushed, so the rebuild was available.
- [x] 3.5 Stage by explicit path: the nine existing packages (37 files) and `.gitignore` in the record
      commit, this change's own package and the four repaired files in the drafting commit.
- [x] 3.6 `git diff --cached --check` reports three trailing-whitespace warnings on the record commit,
      all of them Markdown hard line breaks in the OpenSpec review document as received. Left as
      received: the review is part of the record, and reformatting a record is editing it. Recorded
      in the commit message rather than silently accepted.

## 4. Repair the licence claim

- [x] 4.1 `README.md` §"License / reuse": lead with the operative fact, that no licence has been
      declared, that default copyright applies and that no reuse grant is in force.
- [x] 4.2 Preserve the owner's stated intent in full and name it as intent, so nothing he holds is
      withdrawn.
- [x] 4.3 State what a reader may rely on and what they may not, in the same sentence.
- [x] 4.4 State that the decision is open and belongs to the repository owner, and point at the place
      in the standard where it is recorded.
- [x] 4.5 State that nothing on the page is legal advice, and write nothing that reads as any.
- [x] 4.6 Badge: `free to adopt` becomes `pending`, with the geometry and the palette taken from the
      badges already in `assets/badges/` rather than invented. The `alt` text in `README.md` matches
      the image.
- [x] 4.7 **Select no licence and add no `LICENSE`, `COPYING` or placeholder file.** Verified after
      the repair by listing the root again.

## 5. Repair the same claim in the standard

- [x] 5.1 §"The boundary asserts no license": drop the four words that made the same unsupported
      grant, and leave the license-neutrality claim, which is true, exactly as it stands.
- [x] 5.2 Add the note recording this repository's own licence state, that the decision is open, and
      that it belongs to the deployment owner.
- [x] 5.3 State in the note that it records the state of one repository and places no term on any
      deployment, so a reader does not have to work out whether the section has begun asserting the
      thing it forbids.
- [x] 5.4 Mark the note for v1.49 while drafted, per the ritual v1.42 added.
- [x] 5.5 Repair the closing line of `STANDARD.md`, which carried the claim a fourth time.
- [x] 5.6 Leave §"What this section does not do" word for word. Its licence bullet is still true.

## 6. Repair the governance reference

- [x] 6.1 Name `STANDARD.md` and the document's full title, so the reference resolves to something
      that exists.
- [x] 6.2 Route a fork's reader to the repository it came from through the hub's own
      `km-deployment.md` and the three fields that record the version, revision and source, rather
      than through a person.
- [x] 6.3 Change nothing else on the page. Verified by diff.

## 7. No check, argued

- [x] 7.1 Consider a `LICENSE`-file check and record why it cannot land here: it would be red on the
      repaired tree from the moment it landed, because no licence exists. Named for the day one does.
- [x] 7.2 Consider a grant-wording check and record why it models the wrong thing: it would fire on
      the repaired README, which correctly still contains the grant words as a statement of intent.
- [x] 7.3 **Check whether `scripts/validate_rfc_references.py` already covers Part C's class**, by
      reading its source rather than assuming. It does not: it derives its known set from the
      filenames in `rfcs/` and matches a bare `RFC-NNN`, a code-formatted `rfcs/RFC-NNN`, and a path
      naming a file. "AI KM Hub Standard" is none of those. It was green over line 73 for as long as
      the line existed.
- [x] 7.4 Record why the general class is not checkable here: a document named in prose by title has
      no directory to derive a known set from, so any check would carry a hand-maintained list.
- [x] 7.5 Add no check, and therefore write no `km-unrepaired-tree:` declaration. No check file is
      added or edited by this change, which the gate confirms by reporting 0 added and 0 changed.

## 8. Record

- [x] 8.1 Write the v1.49 row: F-07, the licence sentence quoted as it stood, the three other
      surfaces that carried it, the options and why the third was taken, the plain statement that the
      owner has not chosen a licence and that the decision remains open and the owner's, the record
      commit with its file and byte counts, the leakage finding stated as a finding rather than a
      footnote (the term's two senses, why it is denylisted, the four resolutions and why three were
      refused), the committed ignore rule and its reason, the Part C repair, the no-check argument,
      and the delta-spec decision.
- [x] 8.2 Flip the frontmatter title, the H1 and the lead to v1.49 drafted-unpublished, preserving
      the published v1.48, v1.47 and v1.46 descriptions word for word.
- [x] 8.3 Leave `README.md`'s version line and `assets/badges/version.svg` on v1.48, as the ritual
      requires while a version is drafted. The licence badge is not a status surface and is repaired.
- [x] 8.4 Derive the row's date from this session's own commits rather than from any date supplied to
      it, and confirm it against the commit after committing. Record commit `72b61ba` is
      `2026-08-24 18:26:50 +0200`; the drafting commit is confirmed in 9.11 below.
- [x] 8.5 State the limits: no instrument reaches either prose repair; `license: pending` cannot be
      kept honest by anything in the tree; the green gate proves neither leakage-freedom nor a second
      actor; and the exclusion of the report rests on a denylist entry that could later be removed,
      at which point the ignore rule's reason no longer holds.

## 9. Verification

- [x] 9.1 `openspec validate audit-licence-honesty-and-record --strict` **fails**, with
      `[ERROR] file: Change must have at least one delta. No deltas found.` This is the expected and
      honest outcome, argued in `design.md` Decision 4, and it is recorded rather than answered by
      inventing a requirement. No other check in this repository reads `openspec/`.
- [x] 9.2 `python3 scripts/validate_published_not_draft.py` passes: 50 versions classified (48
      published, 2 unpublished, being v1.23 and v1.49), 120 files scanned, 2 exempt.
- [x] 9.3 `python3 scripts/validate_rfc_references.py` passes: 196 references across 127 files
      scanned, resolving to 7 identifiers, 2 files exempt.
- [x] 9.4 **Both of those were checked for a coverage change, not merely for a verdict.** Neither
      grew. Both declare `openspec` in `SKIP_DIRS` and neither lists it in `SCAN_ROOTS`, and the
      counts are identical when the same two checks are run in a worktree at `ec51128`: 127 files and
      120 files there, 127 and 120 here. The premise that tracking `openspec/` would widen them does
      not hold, and it is recorded as it was found.
- [x] 9.5 What did grow is the release gate's own tree walk: 91 markdown files and 93 relative links
      at `ec51128`, 131 markdown files and 95 relative links in the final tree. All 131 of 131 were
      read and every link resolves **with the external report absent**, which is the arrangement that
      had to be re-checked: an earlier run resolved 115 links with the report present, and 20 of
      those were the report's own. Nothing else pointed at it, so nothing dangles now that it is
      gone.
- [x] 9.6 `python3 scripts/validate_ledger_dates.py` passes, excluding v1.49 as drafted beside v1.23,
      with its structural 20-version coverage gap unchanged.
- [x] 9.7 `python3 tools/km-release-gate.py` exits 0. Numbers in the version report.
- [x] 9.8 `git diff --check` and `git diff --cached --check` clean on the second commit.
- [x] 9.9 Leakage, re-run over the final staged tree with the canonical instrument itself: **zero
      hits on both halves.** Case-insensitive, whole-word, boundary syntax verified, 195 tracked
      files scanned, no match; case-sensitive, whole-word, boundary syntax verified, 195 tracked
      files scanned, no match. The one hit that decided this change is no longer in the tree to find,
      and `git status` shows the report correctly ignored rather than untracked.
- [x] 9.10 Stage by explicit path. `main` untouched, nothing pushed, no tag, no licence chosen, no
      `LICENSE` file added.
- [x] 9.11 Confirm the drafting commit's own author date, in its own recorded offset, against the
      date in the v1.49 row and the frontmatter `timestamp`. Reported in the version report.
