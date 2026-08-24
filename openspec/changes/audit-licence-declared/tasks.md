# Tasks

Executed 2026-08-24 on branch `v1.53-licence-declared`, off `main` at `d810e5b` (published v1.52).
Ordered by dependency: verify the premise, build the licence, repair every surface that carries a
licence claim, record, then verify. `main` is untouched and nothing is pushed.

This change adds no requirement and carries no delta spec, so there are no requirement references to
point at. The reasoning is in `design.md`, Decision 3.

## 1. Verify the premise before acting on it

- [x] 1.1 Confirm the absence rather than take it from the brief: listed `LICENSE`, `LICENSE.md`,
      `LICENSE.txt`, `LICENCE`, `COPYING`, `COPYING.md`, `NOTICE` and `NOTICE.txt` at the repository
      root. None existed.
- [x] 1.2 Read §"The boundary asserts no license" in full before touching it, including the hard
      requirement at its head, the "MAY later attach a policy" clause, and §"What this section does
      not do", whose first bullet is the check on the edit.
- [x] 1.3 Sweep the tree for every surface carrying a licence claim rather than work from the list
      supplied. Found five: the README badge `alt`, the README §"License / reuse", the badge image,
      the note in §"The boundary asserts no license", and **`STANDARD.md`'s closing line**, which was
      not on the list and which v1.49 had repaired for exactly this reason. It said *"no licence has
      been declared for this repository, so default copyright applies until one is"* and would have
      been left contradicting the `LICENSE` file two thousand lines above it.
- [x] 1.4 Establish the copyright year from evidence: the repository's first commit is `c763d53`,
      author date 2026-08-02. The year is 2026.
- [x] 1.5 Establish that the tree vendors no third-party material needing attribution in `NOTICE`.
      No vendored dependency, no bundled source, no third-party copyright notice anywhere outside
      test fixtures that create a `LICENSE.md` inside a throwaway virtualenv.
- [x] 1.6 Check whether the owner's name already appears in the repository in some other form, since
      the brief asked for a discrepancy to be reported rather than silently resolved. **It does not
      appear at all.** The canonical tree names no person, which is the leakage discipline working.
      There is therefore no competing form to reconcile, and `Carlos Correia` is a first occurrence.
- [x] 1.7 Confirm the no-attribution claim's provenance rather than date it by guess:
      `git log -S"attribution required" -- README.md` resolves its first appearance to the
      repository's initial commit `c763d53`.

## 2. Build the licence

- [x] 2.1 Obtain the canonical Apache License 2.0 plain text and **verify it before using it**:
      SHA-256 `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, the published hash
      of the canonical text, over 202 lines. Verified before any edit, so the hash covers the text
      that was placed rather than the text that was left.
- [x] 2.2 Fill the one field the Appendix itself directs a licensor to fill:
      `Copyright [yyyy] [name of copyright owner]` becomes `Copyright 2026 Carlos Correia`. Asserted
      by construction that it is the only occurrence, and changed nothing else. The body of the
      licence, Sections 1 to 9 and END OF TERMS AND CONDITIONS, is byte-identical to the verified
      text.
- [x] 2.3 Write `NOTICE`: the work, the copyright line, a pointer to `LICENSE` and to the canonical
      URL, and a statement of what Section 4(d) asks of a redistributor. No further attributions,
      per 1.5.
- [x] 2.4 The Apache licence text is verbatim and is exempt from every house style rule. It is not
      paraphrased, abridged, reflowed or reformatted.

## 3. Repair the landing page

- [x] 3.1 §"License / reuse": lead with the operative fact, that the repository is licensed
      Apache-2.0 and the grant is in force.
- [x] 3.2 State what an adopter may rely on in the licence's own section numbers rather than in a
      paraphrase a reader has to trust: use and redistribution (§2, §4), the express patent grant and
      its defensive termination (§3), and one licence over the whole repository.
- [x] 3.3 State what the licence asks in return in the same place, so the grant and its conditions
      are not on separate screens.
- [x] 3.4 **Remove the "no attribution required" claim and say that it is withdrawn as false**, with
      the reason. Deleting it silently would leave a reader who remembers it unable to tell whether
      the page changed or they misread it.
- [x] 3.5 Carry the repository-versus-standard separation on the landing page too, in one paragraph.
      A pointer into a 4700-line document is not an answer to the question most readers will have.
- [x] 3.6 Name `LICENSE` as governing where the summary and the licence differ, and state that
      nothing on the page is legal advice.
- [x] 3.7 Badge: `pending` becomes `Apache-2.0`. Geometry and palette taken from the badges already
      in `assets/badges/` rather than invented: the label box, the fill `#8A6D1F`, the height, the
      font stack and the baseline are unchanged, and only the value box width and the overall width
      move to fit the longer string, sized against the comparable `agents` badge. The README `alt`
      text matches the image.
- [x] 3.8 Leave `README.md`'s version line and `assets/badges/version.svg` on v1.52, as the ritual
      requires while a version is drafted. The licence badge is not a publication-status surface and
      is repaired now, exactly as v1.49 repaired it.

## 4. Record it in the standard, without collapsing the distinction

- [x] 4.1 Replace the v1.49 note with three paragraphs, per `design.md` Decision 2: the repository's
      licence; the separation stated plainly; the pre-v1.53 state kept as the record of it.
- [x] 4.2 In the second paragraph, name the two objects explicitly, say that the repository carries a
      licence and the standard asserts none on any deployment, and say that these are separate facts
      about separate objects. Name what does not change: no line of the boundary, no row of the
      component mapping, nothing a Consumer deployment does, and nothing about how an adopter
      licenses their own hubs, knowledge or deployment.
- [x] 4.3 Concede the test rather than assert immunity from it: if the note ever began to read as an
      assertion of licence on a deployment, the note goes and the doctrine stays.
- [x] 4.4 Keep the pre-v1.53 state in the past tense rather than deleting it, so a reader arriving
      from the v1.49 row or from an older fork finds the transition explained.
- [x] 4.5 Mark the note for v1.53 while drafted, per the ritual v1.42 added, and carry the clause
      saying it binds nothing until its own owner push.
- [x] 4.6 **Change no word above the note.** Verified by diff: the hard requirement, the "MAY later
      attach a policy" clause, the "binds only the parties who accept it" clause and the whole of
      §"What this section does not do" are untouched, and its first bullet, *"It asserts, encodes, or
      implies no license, price, or commercial term"*, is still true of the section.
- [x] 4.7 Repair `STANDARD.md`'s closing line, found at 1.3, so that it carries both halves in one
      sentence.
- [x] 4.8 Leave `rfcs/RFC-006-editions.md` alone and record the reason and the counter-argument in
      `design.md` Open Questions, rather than editing a dated design record or dropping the finding.

## 5. Version record

- [x] 5.1 Write the v1.53 row: the decision open since F-07 and made honest at v1.49; that the owner
      made it and confirmed authorship and copyright; the licence and the four reasons in descending
      weight, with the patent grant named as the deciding one; what was built and how the licence
      text was verified; the withdrawal of the no-attribution claim as part of the change rather than
      a consequence of it; the distinction, stated so nothing collapses it; the no-delta and no-check
      arguments; the push obstacle; and the verification with its limits.
- [x] 5.2 Open the description cell with `**DRAFT, awaiting owner push.**`, which is the anchored form
      `scripts/publication_status.py` reads, and confirm both instruments classify v1.53 as
      unpublished rather than assuming they do.
- [x] 5.3 Flip the frontmatter title, the H1 and the lead to v1.53 drafted-and-unpublished,
      **preserving the published v1.52, v1.51 and v1.50 descriptions word for word** and demoting
      v1.52 to "The current published version is", per the v1.52 draft's own precedent.
- [x] 5.4 Take no date from the brief. The date column, the frontmatter `timestamp` and the lead are
      derived from this session's own drafting commit and confirmed against it after committing; see
      9.7.
- [x] 5.5 Reuse no published version number: the ledger runs to v1.52 and `git log --all` shows no
      v1.53 anywhere.

## 6. No check, argued

- [x] 6.1 Reconsider the `LICENSE`-file check v1.49 named for the day one exists. That day is today
      and the check is still not added: it would prove that a file exists and could not read which
      licence it contains or compare it against the four other surfaces that now claim one, which is
      the whole of the F-07 class. `design.md` Decision 4.
- [x] 6.2 Consider the stronger cross-surface check and record why it is not built: the licence
      identifier lives in an SVG text node and in two prose sentences, so the check would be
      hand-written extraction patterns over surfaces whose wording is meant to change.
- [x] 6.3 State the limit rather than defer it: nothing in this tree keeps a licence claim honest.
- [x] 6.4 Add no check and therefore write no `km-unrepaired-tree:` declaration. The gate confirms
      it: 0 check files added, 0 changed, of 34 declared.

## 7. The push obstacle, reported rather than worked around

- [x] 7.1 Establish the premise from the denylist rather than from the brief: the deployment's
      generated denylist carries the owner's name across eight case-insensitive entries, and the
      pre-push hook matches with `grep -inwF`, so the copyright line matches.
- [x] 7.2 Refuse to alter the name to slip past the guard. A copyright notice that does not name the
      copyright holder is not a copyright notice.
- [x] 7.3 Refuse to disable, narrow or bypass the guard from this repository. It is not where that
      decision lives, and weakening a fail-closed control to get one commit out is how it stops being
      fail-closed.
- [x] 7.4 Run the guard anyway and report what it found rather than react to it. See 9.5.
- [x] 7.5 Do not push, do not tag, do not use `--no-verify`, and leave the branch for the steward to
      push once the deployment that owns the denylist has recorded its own narrow exclusion.

## 8. Staging discipline

- [x] 8.1 Stage by explicit path: `LICENSE`, `NOTICE`, `README.md`, `STANDARD.md`,
      `assets/badges/license.svg`, and the three files of this package. No blanket staging.
- [x] 8.2 Confirm `KM-STANDARD-AUDIT-2026-08-22.md` is still ignored and is not in the index.
- [x] 8.3 Attribution trailer `KM-Agent: km-hub-builder`, and no other trailer.

## 9. Verification

- [x] 9.1 `python3 tools/km-release-gate.py` **exits 0**. 33 checks discovered, 28 run, 5 skipped as
      instruments covered by their canaries; 34 unrepaired-tree declarations read; 30 shell, 11
      Python, 5 JSON/JSON-LD; **110 relative links resolved across 150 of 150 markdown files**, up
      from 106 across 147 at `main`, the growth being this package's three files and the four new
      links to `LICENSE` and `NOTICE`, all of which resolve. Run twice: once over the staged tree
      before this file existed, reporting 149 of 149, and once over the committed tree, reporting
      150 of 150. The committed run is the one this line records.
- [x] 9.2 `python3 scripts/validate_published_not_draft.py` passes: 54 versions classified (52
      published, 2 unpublished, being v1.23 and v1.53), 123 files scanned, 4 exempt.
- [x] 9.3 `python3 scripts/validate_ledger_dates.py` passes and excludes v1.53 as drafted beside
      v1.23, with its structural 20-version coverage gap unchanged. The exclusion is the evidence for
      5.2: the anchored classifier read the new row's opener as a declaration.
- [x] 9.4 `openspec validate audit-licence-declared --strict` was run and **fails**, exit 1, with
      `[ERROR] file: Change must have at least one delta. No deltas found.` Expected and honest,
      recorded from the run rather than predicted, argued in `design.md` Decision 3, and
      recorded rather than answered by inventing a requirement. No check in this repository reads
      `openspec/`.
- [x] 9.5 Leakage, run with the canonical instrument over the committed tree, both halves, both with
      the boundary syntax probed against the live engine. **Case-sensitive half: clean, 10 entries,
      221 tracked files scanned, no match. Case-insensitive half: 6 hits, every one of them the
      owner's own name in a copyright line or in this package's record of one**, two in `LICENSE` and
      `NOTICE`, one in `README.md`, one in `proposal.md` and two in this file. Re-run with the eight
      owner-name entries removed and the other 742 kept: **clean over the same 221 files.** So the
      tree carries no leakage other than the copyright notice this version exists to add and the
      package's own account of it, and those hits are the expected ones, reported rather than
      cleared. See 7.2 to 7.4.
- [x] 9.6 `git diff --check` and `git diff --cached --check` clean.
- [x] 9.7 Confirm the drafting commit's own author date, in its own recorded offset, against the date
      in the v1.53 row, the frontmatter `timestamp` and the lead. Reported in the version report.
- [x] 9.8 `main` untouched, nothing pushed, no tag.
