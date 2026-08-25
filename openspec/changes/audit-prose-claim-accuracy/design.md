# Design: prose claims, and which of them an instrument can hold

## The shape of the problem

Every finding in this change is a sentence. None of them is a defect in a check, a script or a
template, and none would have been caught by running anything, because a document has no exit status.
That is the class this repository already named at v1.48, and the reason it keeps producing findings
is that the class has two halves and only one of them has a mechanism.

The half with a mechanism: a claim that **enumerates a set an instrument can list**. A rule count, a
file list, an RFC disposition, a version identifier. v1.48 ruled that these are derived and checked,
and three instruments already do it (`validate_template_rule_summary.py`, `validate_rfc_lifecycle.py`,
`validate_rfc_references.py`).

The half without one: a claim that **describes**, **judges** or **counts something in passing**. The
licence prose, the Section 4 summary, "the gate's two stated limits", "147 markdown files". No
instrument reaches these, and the honest answer for most of them is that none should, because an
instrument built over a judgement models whether the sentence was edited.

This change closes what is cheaply closable in the first half, states the discriminator for the
second, and refuses two checks it could have written.

## Decision 1: the licence precision goes in the live section, not the dated ones

The claim "unmodified" appears in three places: the header lead's copy of the v1.53 description, the
v1.53 version row, and this repository's openspec record of that change. The v1.53 **row already
states it precisely**: it says the Appendix boilerplate was completed as the Appendix itself directs
and no other byte was touched, and it names the digest. The imprecise wording is in the lead's
summary of the row and in nothing that a reader consults to learn what the licence is.

So the precision lands where a present-tense reader actually meets the claim, which is
§"The boundary asserts no license" in `STANDARD.md`. That section is live doctrine, is where the
standard speaks about licensing by its own statement, and is not a dated record.

The lead's copy is left alone for two reasons and the second is the stronger. First, the publish
ritual's step 1 preserves the descriptions of published versions word for word, and editing one while
publishing another is precisely what that step forbids. Second, the lead carries the current version
and its two predecessors, so flipping the header to v1.56 rolls v1.53 out of the lead entirely. The
sentence leaves the document by the mechanism that already exists rather than by an edit to a
published description.

**Rejected:** correcting the phrase in the lead and the row. It would rewrite a published description
for imprecision rather than for falsehood, and the row is not imprecise.

## Decision 2: the README states the condition and stops there

Section 4 of Apache-2.0 conditions the act of distributing. The README stated the four duties as
though they were duties of adoption. Two repairs were available.

The one taken: name the trigger, list the notices as §4 lists them, say plainly that internal use and
private modification trigger none of them, and name `LICENSE` §4 as governing. Six lines, no advice.

**Rejected:** explaining §4's clauses (a) to (d), the derivative-works test, or what counts as
distribution. The page already says nothing here is legal advice and that `LICENSE` governs where the
two differ, and a landing page that starts interpreting a licence acquires a second thing that can go
wrong. The finding was that a condition was missing, not that a summary was too short.

## Decision 3: three counts, three treatments, and the discriminator

This is the load-bearing decision in the package, because getting it backwards falsifies a record.

The question is asked about the thing the statement names, at the moment of writing: **was it wrong
then?**

| Claim | Wrong when written? | Treatment |
|---|---|---|
| "all eleven content-returning entry points" (v1.40 row, and the suite) | Yes. The surface declared seven then and declares seven now. Eleven was the driver's call count. | **Corrected**, and the correction names itself and says what eleven counted. |
| "the gate's two stated limits" (the maintainer contract since v1.46, and the v1.53 row) | Yes. The gate printed three at the v1.46 publish commit and three at the v1.53 publish commit. | **Corrected** in the row; the contract stops stating a count at all. |
| "147 markdown files and 41 code files" (v1.53 row) | No. It was the measurement the decision rested on. The tree held 150 at that version's publish commit and holds 158 now, and the code figure has not moved. | **Dated, not refreshed.** "when the decision was taken" is added; the number is untouched. |

The precedent for correcting is v1.47, which ruled that a false date in a published row is corrected
in the ledger while the pushed commit subject and annotated tag that carry it are left exactly as
they are, because the ledger is the corrected record of account and `git log` is the record of what
was done, including what was done wrongly. A false count is the same object as a false date.

The precedent for not refreshing is v1.45 and v1.50, which ruled that a dated record is never
rewritten to agree with the present. Refreshing 147 to 158 would assert that the licensing decision
was taken on the shape of a tree that did not exist yet.

**The third option, which is the one this change contributes:** where a true dated statement invites a
present-tense reading it cannot keep, neither refresh it nor delete it. **Date it.** The measurement
survives, the false reading dies, and a dated measurement cannot go stale by definition. That is the
generalisation written into §"Standard Maintainer" and it is the requirement this change adds.

**Rejected:** leaving 147 with no qualifier and explaining it only in the v1.56 row. A reader of the
v1.53 row does not read the v1.56 row, and a correction nobody arrives at is a correction that has
not been made.

## Decision 4: for the limits, the repair is to stop counting

The count could have been changed from two to four in both places. It was not, because it would drift
on the next limit exactly as it drifted on the last two, and the v1.55 repair to the CI definition
already established the right answer: the limits live in one definition inside the gate, are printed
by the passing verdict, and are printed alone by a flag. Every other surface points at that
definition and states no number.

So the maintainer contract keeps the **substance** of the two limits that bear on it and states no
count, and it says why in one sentence, so a later maintainer does not helpfully restore the number.

## Decision 5: which check to add, and which two to refuse

**Added: `tests/test_readme_inventory.sh`.** The README's `template/` row enumerates two sets and both
are directories. The entity-note folders are derivable as the directories under `template/` carrying a
`TEMPLATE.md`, which is the tree's own definition of one, so a tenth entity type changes the check's
answer with no edit. The per-hub skills are derivable as the slugs installed in both runtime trees.
The comparison runs in both directions, so an omission and an invention each fail. It fails on the
unrepaired tree naming `km-publish`, which is a real result rather than a check that agrees with
whatever the repaired tree already did.

**Added: case 7 of `tests/test_mcp_quarantine.sh`.** The suite reported eleven entry points because
its summary line printed the size of its own call list. The repair makes the line derive both figures
and name the entry points; the case then holds the reported figure against the set the surface
declares by decorator. Against the unrepaired tree the case fails, 11 against 7.

**Refused: a check that the version identifier agrees across the surfaces the publish ritual flips.**
Five surfaces state it, nothing compares them, and it is cheaply derivable. It is refused because
those surfaces are **designed** to disagree: while a version is drafted the standard's H1 carries the
drafted number and the README and the badge still carry the last published one, which is exactly the
state this branch is in. A check would have to model the ritual's two states, and the classifier that
knows which state a version is in already exists at `scripts/publication_status.py`. Building a fifth
reader of the ledger inside a change about prose accuracy is how an instrument comes to model the
wrong class. It is recorded as a named gap whose honest home is an extension of that classifier.

**Refused: a general check on back-quoted repository paths.** v1.45 built one for RFC identifiers,
including the code-formatted form, and generalising it to any back-quoted path is the obvious next
step and the wrong one. This tree quotes hub paths (`_inbox/`, `sources/dates-register.md`), template
paths that resolve only inside a deployed hub, and paths that are deliberately examples. An instrument
that could not tell those from a reference to a file in this repository would report a tree full of
defects that are not there, and the remedy would be a hand-maintained exclusion list, which is the
artifact class the whole sweep is about.

## What this change does not claim

- It does not make the licence claims checkable. Nothing in this tree reads a licence, which v1.53
  already recorded as a limit, and this change adds a sentence about precision rather than an
  instrument.
- It does not prove the swept surfaces are now correct. A sweep is a point-in-time reading by one
  actor, and the four findings and the findings of none are both recorded so the next reading starts
  from a stated baseline rather than from nothing.
- It does not close the class. The half of it that is judgement is reached by no check, and the
  requirement added here says so in its own words.
