# Design

## Context

The version-history table of `STANDARD.md` is the only record this repository keeps of when a version
was published. Two of its forty-seven rows state a day on which nothing happened.

```
STANDARD.md:4358   | v1.40 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). ...
                   publish commit 9c14f85   2026-08-23 13:32:21 +0200
                   draft commit   64015a6   2026-08-23 13:15:23 +0200
                   overlay re-pin           2026-08-23 13:37:57 +0200

STANDARD.md:4351   | v1.33 | 2026-08-20 | Drafted and published 2026-08-21 (owner push). ...
                   publish commit 16109ea   2026-08-21 00:24:40 +0200
                   draft commit   f67cd70   2026-08-20 18:11:50 +0200
```

The two rows are wrong in different halves, and the difference is the whole diagnosis.

**v1.40 carried a brief's date into both fields.** The staging brief was written on 2026-08-22, the
session ran past midnight, and the date was copied into the column and into the stamp without being
re-derived. All three v1.40 events are on 2026-08-23.

**v1.33 derived the stamp and not the column.** The publishing commit `16109ea` shows it happening:

```
-| v1.33 | 2026-08-20 | **Drafted 2026-08-20, unpublished** (awaiting owner push). ...
+| v1.33 | 2026-08-20 | Drafted and published 2026-08-21 (owner push). ...
```

Step 2 of the publish ritual says the row is stamped with the push date. It was, in the prose, and
the date column was left holding the draft date. So the row has contradicted itself in published text
since 2026-08-21, and its own commit subject and tag both read 2026-08-21, which means the
information needed to catch it was sitting in three places in the same repository.

Three things about how this survived matter more than the two dates.

**The same class was caught once, by a person, by accident of diligence.** At v1.45 the drafting
agent checked three independent pieces of evidence against each other and found the date wrong before
it published. At v1.40 nobody checked. A control that depends on whether the drafting agent happened
to be careful is not a control.

**A sweep specifically looking for this class did not find v1.33.** The sweep run in preparation for
this change compared each publish commit's *subject* date against that same commit's
*timestamp*. For v1.33 both read 2026-08-21, so it reported clean. The real comparison is the ledger
row against the publish commit, which is a different pair, and the sweep never made it. It was also
truncated at 16 of the 22 publish commits, but the truncation is the lesser fault: untruncated, that
comparison still could not have found v1.33. This is the structural limit the v1.30 row states, met
in a new place: an instrument that fires reliably on the class it models proves nothing about whether
it models the right class.

**Nothing mechanical existed.** Seventeen suites and three validators ship in this repository and not
one of them opens the version-history table's date column.

## Goals / Non-Goals

**Goals:**

- Correct both rows in the ledger, changing nothing else in either row.
- Leave the v1.40 publish commit subject and the `v1.40` tag exactly as they are, and record why.
- Add a check that derives the version-to-commit mapping from the repository, compares in the
  commit's own timezone, names both dates on a disagreement, refuses on unevaluable input, and states
  its coverage.
- Separate a drafted version (an exclusion) from an unresolvable one (a coverage gap) so neither is
  mistaken for a verdict.
- Prove both directions, including a run against `main` at `a2756e2` before the correction.
- Amend the publish ritual so the date is derived at publish time, in the standard and in the
  drafting contract.
- Record the sweep of all 47 rows in the version row, so the next maintainer inherits the measurement.

**Non-Goals:**

- Rewriting the v1.40 commit or tag. See Decision 1.
- Validating the stamp prose inside a row's description. See Decision 5.
- Reconstructing publication dates for the versions that predate tagging. See Decision 4.
- A general date-consistency check over the repository's other timestamps. See Risks.

## Decisions

### Decision 1: the ledger is corrected and the pushed commit and tag are left alone

The v1.40 publish commit subject reads `... (owner push 2026-08-22)` and the annotated tag `v1.40`
carries the same. Both are wrong and neither is rewritten.

Rewriting is available and is refused. `git commit --amend` on a pushed commit rewrites every
descendant, which here is thirteen published versions and twelve annotated tags; retagging replaces
an object that any clone or fork already holds. The repository is about to be forked. The remedy
would trade a documented discrepancy that a reader can understand for a divergence between clones
that a reader cannot, and the second is strictly worse. History is a record of what was done,
including what was done wrongly; the ledger is the record of account, and it is the one that gets
corrected.

So the v1.47 row states three things a reader comparing the ledger against `git log` needs: that the
commit subject and the tag retain the original 2026-08-22, that the ledger is the corrected record,
and that the discrepancy was left deliberately rather than missed.

**And it states the asymmetry.** v1.33's subject and tag already read 2026-08-21, so v1.33 gets no
discrepancy note. Saying only "v1.40 has a note" invites a reader to wonder whether v1.33's absence
of one is an oversight. The row says which of the two carries a discrepancy and which does not.

### Decision 2: the mapping is derived from tags first, then commit subjects, and the method is reported

A table of versions and dates written into the check would be exactly the artifact this change
exists to remove: a date held in a document instead of derived from the tree. The repository has
diagnosed that class three times already (the hub manifest in RFC-004 Part I, the declared-skill-set
list refused by v1.32, the RFC identifier list refused by v1.45), and repeating it inside a check
about derived dates would be self-refuting.

Two sources, in order.

**An annotated tag** is the strongest evidence: it names the version, it points at one commit, and
the repository began tagging at v1.22. Tags reach v1.22 and v1.26 through v1.46.

**A commit subject search** covers versions published before tagging began. The pattern requires the
subject to *open* with the version identifier followed by a colon, which resolves v1.16 through v1.19
and correctly refuses `draft v1.21: ...` and `fix: carry the v1.17 release date ...`. A draft subject
is excluded explicitly, so `v1.45 (draft): ...` never resolves as a publication.

The method is printed per version, because "resolved" is not one fact. A tag is an act someone
performed deliberately; a subject match is an inference from prose. A maintainer reading a
disagreement needs to know which one they are being shown before deciding whether the ledger or the
commit is wrong.

**Ambiguity refuses to resolve rather than picking.** `v1.18: hub handover write side ...` appears
twice, on two branches, as `19d1459` and `edac97f`. Where a subject search returns candidates that
disagree about the date, the version is reported unresolved and ambiguous. Where they agree, it
resolves, because the fact being read is the date and the candidates supply one answer.

### Decision 3: the comparison is made in the commit's own recorded offset

`git log --date=short` renders the author date in the offset the commit itself records. That is
deliberate here and it is the decision the whole check turns on.

v1.33's publish commit is `2026-08-21 00:24:40 +0200`. Normalised to UTC it is `2026-08-20 22:24:40`,
and a check comparing UTC dates would have reported the false row `| v1.33 | 2026-08-20 |` as
correct. The class being modelled is "a person published on a day and the ledger names a different
day", and the day a person published on is the day in the offset they were in. Reading UTC would have
produced an instrument that agreed with the defect in exactly the case that is hardest to see.

The same reasoning rejects the reader's local timezone: the verdict must not depend on where the
check is run. The commit's own offset is the only source that is both meaningful and stable.

### Decision 4: three outcomes, kept apart

A row resolves to one of three states, and folding any two of them together produces a wrong
instrument.

**Excluded.** The ledger declares the version still drafted. v1.23 has been in that state since
2026-08-16. A drafted version has no publish commit because it has not been published, so treating it
as unresolvable would print a coverage gap that can never close, and a permanent false gap trains a
reader to stop reading gaps. The declaration is read from the row itself using the same convention
`validate_published_not_draft.py` already uses, so there is one home of record for publication status
and not two.

**Unresolved.** No tag and no subject resolves the version. Twenty rows are in this state: v1.0
through v1.15, which predate both tagging and the `vX.Y:` subject convention, and v1.20, v1.21, v1.24
and v1.25, which were published inside a later version's train and have no commit of their own. This
is a **structural** gap. No test reaches it, no repair closes it, and it is reported on every run,
including a passing one, precisely because it is the part of the ledger the check does not cover.
Attributing v1.20 to v1.22's commit because they published together would be the check inventing the
evidence it was written to demand.

**Compared.** Everything else. Twenty-six rows.

### Decision 5: the date column is checked and the stamp prose is not

The check reads `| vX.Y | YYYY-MM-DD |` and stops there. The stamp inside the description is a
sentence a maintainer wrote, in several forms across the ledger's history ("Drafted and published
2026-08-17 (owner push, with v1.25 and v1.26)", "Drafted 2026-08-14; published 2026-08-16 with
v1.22"), and a check parsing those would be a prose validator with a false-positive surface far
larger than the class it covers.

The cost is stated rather than hidden, and it is real: it is exactly the half of the v1.33 row that
was *correct*, and had the error been the other way round the check would have missed it. The
mitigation is not mechanical. The ritual now says both fields are derived from the same commit in the
same act, so they cannot disagree without someone editing one of them alone, and the limit is written
into the check's own docstring and into the version row.

### Decision 6: the evidence run uses a real worktree at the pre-correction commit

The check reads a ledger and asks git about tags and subjects, so a fixture that only supplies text
would not exercise resolution. The canaries therefore point the check's `--ledger` at
`git show a2756e2:STANDARD.md` while git resolution runs against the real repository. That is the
actual published table, byte for byte, judged against the actual tags, and it is required to name
v1.40 and v1.33 and to print all four dates.

The positive and negative canaries take the same route for the same reason: a fixture ledger holding
real version identifiers with correct dates must pass, and the same fixture with one date altered by
one day must fail and name that version. Both run against the real tag set, so a canary cannot pass
because the resolution step quietly returned nothing.

### Decision 7: the check exempts files that must quote a wrong date

The canaries construct ledger rows carrying deliberately false dates, and this design document quotes
them. Neither is scanned, because the check reads one file, `STANDARD.md`, by default. Unlike the
published-not-draft and RFC-reference checks, this one has no repository-wide scan and therefore
needs no exemption convention. That is a smaller surface, and it is stated so that a later maintainer
widening the scope knows an exemption mechanism has to arrive with the widening.

## Risks / Trade-offs

- **The check models the date column and no other date in the repository.** The frontmatter
  `timestamp:`, the README badge, the architecture docs and the RFC banners all carry dates that
  nothing compares against anything. Out of scope rather than solved.
- **A resolved commit is assumed to be the right commit.** If a subject search matched a commit that
  happens to open with a version identifier and is not the publication, the check would compare
  against the wrong evidence and could report a false disagreement or conceal a real one. The
  tag-first order and the ambiguity refusal narrow this; they do not eliminate it. The method is
  printed so the maintainer can see which evidence they are being shown.
- **A version published and never given a row is invisible.** The check reads rows. A missing row is
  not a row, and no canary reaches that class. It is the same structural gap v1.30 names.
- **Twenty rows are permanently uncovered.** The gap is stated on every run, which makes it visible
  and does not make it smaller. A reader who takes a passing line as covering the whole ledger has
  misread it, which is why the numbers are on the passing line rather than in a document.
- **The correction is a repair of published text.** Two published rows change, which the publish
  ritual otherwise forbids ("the descriptions of versions already published are preserved word for
  word"). The distinction is that a false statement is not a description, and it is the same
  distinction v1.42 and v1.45 already drew. Nothing else in either row changes, and the v1.47 row
  records the before and the after so the correction is itself auditable.

## Migration Plan

1. Branch off published `main` at `a2756e2`, preserving the pre-existing `.gitignore` modification.
2. Sweep all 47 rows against the repository and record the result before writing anything.
3. Build the check; run it against the tree before the correction and record what it names.
4. Correct the v1.40 date column and stamp, and the v1.33 date column. Change nothing else.
5. Re-run the check and confirm it passes with its coverage stated.
6. Add the canaries; prove both directions, the refusals, and the evidence run at `a2756e2`.
7. Amend the publish ritual in `STANDARD.md` and the drafting contract in
   `agents/km-hub-builder/SKILL.md`.
8. Write the v1.47 row, flip the header and lead to v1.47 drafted-unpublished, preserving the
   published v1.46, v1.45 and v1.44 descriptions word for word.
9. Verify with `openspec validate --strict`, the new canaries, `python3 tools/km-release-gate.py`,
   and `git diff --check`.
10. Adoption: none. No shipped surface changes, so no hub has an act to perform.

## Open Questions

- Should the ledger carry the publish commit identifier in its own column, so the row states its
  evidence rather than requiring a check to go and find it? The argument for is that resolution by
  subject search would stop being necessary. The argument against is that it puts a derived value
  back into the document, which is the artifact class this change is removing, and it would not have
  helped: a maintainer who copied a wrong date from a brief would have copied a wrong commit too.
- Should the twenty unresolved versions be given tags retrospectively, from the commits that can be
  identified by hand? That would close most of the gap and would also manufacture publication
  evidence after the fact, which is the act this change refuses in Decision 4. Not answered here.
- Should the same instrument generalise to every date the standard publishes, including the
  frontmatter timestamp and the README badge? The shape is identical. Whether each of those has a
  derivable source of truth in the tree is the question that decides it.
