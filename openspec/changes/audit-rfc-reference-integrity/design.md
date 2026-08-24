# Design

## Context

Published `main` at `c3e4ffe` carries nine references to a design document that is not on the branch:

```
STANDARD.md:3962                 - It does not implement the Reader (`rfcs/RFC-007`) or the
                                   routines (`rfcs/RFC-005`); it references them.
STANDARD.md:4213                 the v1.39 ledger row, "Neither the Reader (RFC-007) nor the
                                   routines (RFC-005) is implemented here; both are referenced."
rfcs/RFC-006-editions.md:11,27,172,341
rfcs/RFC-007-reader-tier.md:11,25,332
```

`rfcs/` on `main` holds RFC-001, 002, 003, 004, 006 and 007. RFC-005 exists only on the local,
unmerged branch `rfc-005-routines` at `086da08`, whose single commit adds `rfcs/RFC-005-routines.md`
and nothing else. The branch is otherwise far behind `main`, so it is not a merge candidate; the file
is.

Two things about how this reached publication matter more than the missing file.

**It was flagged and not acted on.** v1.39 published carrying two of the references while the
drafting agent's report stated that RFC-005 sat unmerged. The flag was acknowledged. Nothing followed
it. A repair that produced only a landed file would leave the actual failure untouched, which is why
this change is a check and a rule and not only a `git checkout`.

**Nothing mechanical could have caught it.** The reference is written as `` `rfcs/RFC-005` ``: a
code-formatted path, inside no Markdown link. Every walk over hyperlinks in this repository and in
the external audit passed over it and reported no broken links. A check that reads one form of a
reference reports a clean tree for the form it does not read, and a clean tree is what a working
check also looks like. This is the absence-shaped-pass class the standard already names, met in a new
place.

## Goals / Non-Goals

**Goals:**

- Land RFC-005 on the branch as design only, so every published reference resolves.
- State its true status on the day it lands, without rewriting the design.
- Add a check that reads the forms a hyperlink walk misses, derives the existing set from the
  directory, fails closed, and states its coverage.
- Prove both directions, and prove the check against the published tree that carried the defect.
- Sweep every other RFC cross-reference for the same class and record the result, including a
  finding of none.
- State the rule where its siblings are stated, and name the maintainer error plainly.

**Non-Goals:**

- Implementing RFC-005. See Decision 1.
- Repairing the stale status banners of RFC-006 and RFC-007. See Decision 6.
- A general Markdown link checker for the whole repository. See Decision 5.
- Judging whether a resolvable reference describes its target correctly. See Risks.

## Decisions

### Decision 1: land the document rather than remove the references

The audit offered both: merge and disposition RFC-005, or remove its normative dependencies. Landing
is the right one and removal is not, for three reasons.

The references are **true**. v1.39's text says the editions boundary does not implement the routines
and references them; that is an accurate statement about a real design document, and deleting it
would make the published record less complete rather than more honest. RFC-006 and RFC-007 name
RFC-005 in their provenance sections because their own design rests on it; removing those would edit
dated design records to agree with the present, which the repository already refuses to do elsewhere
(`rfcs/` is out of scope for the published-not-draft check for exactly that reason).

Landing is also the **established route**. RFC-004 reached `main` as a design document before v1.32
and v1.35 implemented parts of it. Nothing new is being invented here; a route that already exists is
being used for the document that should have taken it.

And removal would leave the estate's own record worse: the design exists, it was commissioned, and
the only artifact recording it would sit on a branch nobody opens.

### Decision 2: the document lands as design only, and landing is not adopting

Nothing normative rides it. No version-history row for the routines, no section in `STANDARD.md`, no
schema, no skill, no template. The document's own banner says it binds nothing, and the v1.45 row
says the same, because presence on the published branch is otherwise readable as adoption. A later
session finding the file there must not conclude the routines are part of the standard.

The cost of this decision is stated: the published branch now carries a design document for a
mechanism the standard does not have. That is already true of RFC-002, RFC-003 and parts of RFC-004,
so it is the normal state of `rfcs/` rather than a new condition.

### Decision 3: correct the banner, and only the banner

The banner read "As with RFC-003 and RFC-004, no normative edits ride this RFC". The claim about
RFC-005 itself is still true. The comparison is what went stale: RFC-004 Parts I and II were
implemented by v1.32 and v1.35, and the two RFCs written after RFC-005 that name it as an equal
(RFC-006, RFC-007) were implemented by v1.39 and v1.41, while RFC-005 was not.

So a dated status note is added stating what landed, when, on what terms, and which siblings have
since been implemented. The comparison clause is dropped from the first sentence, since it now points
at documents whose status differs from this one's.

Nothing else in the document changes. Its verdicts, its provenance tags, its arguments and its
`timestamp: 2026-08-22` frontmatter all stand: the document is a dated record of what was designed on
that day, and a status note is the only kind of edit that does not falsify it.

### Decision 4: the existing set is derived from the directory, never held in the check

A list of known identifiers written into the check would be correct on the day it was written and
would be a hand-maintained memory of directory state afterwards. This repository has already
diagnosed that artifact class twice: RFC-004 Part I found a hub manifest missing a row for a governed
file that the git-backed integrity check could never catch, and v1.32 refused a declared-skill-set
list for the same reason, comparing the installed trees instead.

So the set comes from `rfcs/` itself, one identifier per filename. Adding, renaming or removing a
document changes the check's answer with no edit to the check, and the canaries prove that by flipping
the verdict on byte-identical fixture text with only the directory changing, in both directions.

The pairing this requires is fail-closed on the derivation step. An unreadable or absent directory
must refuse, because deriving an empty set from a directory nobody could read and then reporting
every reference in the tree as dangling would be a verdict drawn from an unread input, which is the
mirror of the defect being repaired.

### Decision 5: three forms, and the path form is judged more strictly than the identifier

The check matches a bare identifier, a code-formatted path with no filename, and a path naming a
file. It does not attempt to be a general Markdown link checker: the class this change models is a
reference to a design document, and a check that tried to resolve every link in the repository would
be a different instrument with a different failure surface, adopted for a different reason.

The path form is held to the stricter test. `rfcs/RFC-004-renamed-away.md` carries an identifier that
exists, and if the identifier were the whole test, a rename inside `rfcs/` would leave every link to
the old filename passing on the strength of the number in it. So a path ending in a filename must
name a file that is present, and the identifier inside it is judged separately by the identifier
pass. The two tests are complementary and the reference is counted once.

The match boundary is deliberate and is canaried: `xRFC-101` is not a reference, and `RFC-0051` does
not read as `RFC-005`. A boundary that silently matched nothing would look exactly like a tree that
cites nothing, which is why the fixture carrying only near-misses is required to **refuse** rather
than to pass.

### Decision 6: RFC-006 and RFC-007 keep their stale banners here

Both declare themselves design only although v1.39 and v1.41 implement them. That is real and it is
audit finding F-09, whose remedy is an RFC index carrying status, decision date, implementing version
and supersession for every document, with the badge generated from it. Correcting two banners here
would do a third of that job, leave the index unbuilt, and widen a reference-integrity repair into an
RFC lifecycle repair. The finding is named in this change's Impact so the next session does not have
to rediscover it.

### Decision 7: the check exempts files that must name absent identifiers

The instrument's docstring names identifiers to define what it matches, and its canaries name
identifiers that do not exist on purpose. Both would otherwise report themselves as violations. The
mechanism is the one `validate_published_not_draft.py` already uses: a `rfc-reference-exempt:`
declaration carrying a reason, refused when the reason is missing, and printed on the passing run so
no exclusion is silent. One convention rather than two.

## Risks / Trade-offs

- **The check models openability and nothing else.** A reference that resolves to the wrong document,
  or to a superseded one, passes. So does a version that should have cited a document and did not.
  The last of those is the structural gap v1.30 describes: the check is working exactly as written
  and the evidence it consults cannot represent a citation nobody wrote. No canary reaches it.
- **A design document on the published branch can be read as adopted.** Mitigated by the banner, the
  ledger row and the rule, all of which say landing is not adopting. Not eliminated: the mitigation
  is prose, and prose is read by whoever reads it.
- **The scan boundary is a judgement.** `rfcs/` is in scope here and out of scope for the
  published-not-draft check, and the two boundaries are opposite for good reasons that a reader has
  to hold at once. Each check states its own scope in its docstring and on its passing line.
- **One refusal branch is unreachable from a fixture.** The check refuses when no file was scanned,
  and while `rfcs/` is itself a scan root a tree that satisfies the derivation step always carries a
  scannable file. The guard is kept as defence in depth, and the test header says it is not proved
  rather than counting it among the proved refusals.
- **A repository-level check is not inherited by any deployment.** This instrument protects the
  standard's own text. A hub citing a document it does not carry is reached by nothing here, and that
  is out of scope rather than solved.

## Migration Plan

1. Branch off published `main` at `c3e4ffe`, preserving the pre-existing `.gitignore` modification.
2. Reproduce: run the new check against the tree before the RFC lands and record the nine references
   it names, with their files and lines.
3. Land `rfcs/RFC-005-routines.md` from `rfc-005-routines` at `086da08`, byte-identical, then correct
   its status banner and nothing else.
4. Add the check and its canaries; run the canaries against the pre-repair tree through `git archive`
   so the evidence case is the real tree and not a likeness of it.
5. Neuter the matcher deliberately and confirm the suite fails, so a check that has stopped firing is
   known to be detected.
6. Sweep every RFC cross-reference in the repository and record the result, including a finding of
   none.
7. Graft the rule into the Standard Maintainer section, marked for v1.45 while drafted; write the
   v1.45 row; flip the header and lead to v1.45 drafted-unpublished, preserving the published v1.44,
   v1.43 and v1.42 descriptions word for word.
8. Verify: `openspec validate --strict`, the new canaries, the full suite,
   `scripts/validate_published_not_draft.py`, `git diff --check`.
9. Adoption: none. No shipped surface changes, so no hub has an act to perform.

## Open Questions

- Should the check run as part of the publish ritual's own numbered steps, beside
  `validate_published_not_draft.py`? The argument for is that this defect was created at publish
  time and the ritual is where publish-time obligations live. The argument against is that the ritual
  governs status claims and this is a reference claim, and that the check runs in the suite every
  change already runs. Left as it stands, and named here so the next maintainer can settle it.
- Should the repository carry an RFC index (status, decision date, implementing version,
  supersession), with the badge generated from it? That is audit finding F-09 and would make "which
  documents exist and what became of them" answerable in one place rather than by reading seven
  banners. Not answered here.
- Should the same instrument be generalised to any cross-document identifier the standard mints, for
  example defect identifiers such as D6 and audit findings such as F-04, which are cited in published
  text with no register behind them? The shape is identical. Whether those identifiers have a home of
  record to derive a set from is the question that decides it.
