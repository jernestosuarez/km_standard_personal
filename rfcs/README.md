---
type: reference
title: RFC index, the disposition of every design proposal in this repository
description: The home of record for what each RFC in this repository is, what has become of it, which published version implemented it, where a design was implemented in narrowed form, and how the RFC badge is kept true. Read this before reading any individual RFC.
tags: [rfc, index, disposition, governance, lifecycle]
timestamp: 2026-08-24
---

# RFC index

An RFC in this repository is a **dated design record**. It states what was designed, on what
authority, with what evidence, on the day it was written. It is never rewritten to agree with what
happened afterwards, so an RFC read on its own tells you what somebody proposed, not what the
standard now does.

**This page is where you learn what became of each proposal.** It is the home of record for
disposition. `STANDARD.md` → *Version history* is the home of record for what published. The two
answer different questions and this page cites the second for every claim it makes.

## Status vocabulary

Four terms, and they are not interchangeable.

| Status | Meaning |
|---|---|
| `ADOPTED` | Implemented by a published version, in full or with the narrowings this page's Notes name. |
| `PARTIALLY ADOPTED` | Some parts implemented by published versions and others not. The row names which. |
| `DRAFT` | Normative edits were written for a version that has **not** published. Text exists and binds nothing. |
| `DESIGN ONLY` | No normative edits ride the document at all. It binds nothing and no version claims it. |

`DRAFT` and `DESIGN ONLY` look the same from a distance and are not the same thing. RFC-002 has
normative text drafted and waiting on an owner push; RFC-003 and RFC-005 have none. Collapsing the
two would erase the fact that v1.23 exists.

## The index

| RFC | Title | Status | Implemented by | Decided | Relationships | Notes |
|---|---|---|---|---|---|---|
| [RFC-001](RFC-001-sor-gateway.md) | The record boundary: a systems-of-record gateway for governed hubs | ADOPTED | v1.22 | 2026-08-16 | RFC-002 is its companion and answers three of its open questions | Rule 6, `accessClass`, `SourceSystem`, `Claim`, bitemporal validity and the inbound connector model published together on the owner's ruling of 2026-08-16. Open questions 1 and 3 are resolved by RFC-002 and question 2 partially, so those resolutions ride v1.23 and do not bind yet. |
| [RFC-002](RFC-002-stations-compartments-resolution.md) | Stations, compartments, and the resolution plane | DRAFT | v1.23 (drafted, never published) | | Companion to RFC-001; RFC-007's scoped reader is the read side of its compartment | **v1.23 has never published.** There is no `v1.23` tag, its version-history row opens `**DRAFT — awaiting owner push**`, the lead of `STANDARD.md` states it remains drafted and unpublished, and the merge that published v1.22 records that v1.23 rides as draft. Its `DRAFT` banner is correct and is not a stale status. Sections of `STANDARD.md` carrying `(added in v1.23)` bind nothing until its own push, and v1.35 records one merge guard that cannot bind until it does. |
| [RFC-003](RFC-003-observation-tier-and-profile-vocabulary.md) | The observation tier and profile-declared entity types | DESIGN ONLY | | | None | Two extension points, designed and not taken up. No version-history row names it, no `STANDARD.md` section implements it, and the observation tier and the profile-declared entity vocabulary are both absent from the standard. Routed to design by the deployment owner's ruling of 2026-08-18. |
| [RFC-004](RFC-004-harness-projection-hub-merge-multi-tenancy.md) | Feeding the harness, merging hubs, and what multi-tenancy would have to settle first | PARTIALLY ADOPTED | v1.32, v1.35 | 2026-08-20 (Part I), 2026-08-22 (Part II) | Part III reading (c) is given its concrete form by RFC-006 | **Part I, the harness projection: adopted by v1.32, narrowed in three ways the version itself records**: `hub-owner` is not projected (it is an inline substitution occurring nine times per file, not a bounded block); the declared-skill-set list of §5 was **not taken**, because comparing the two installed runtime trees to each other covers the same evidence without a hand-maintained manifest; and "unclaimed class" became a coverage number rather than an advisory, because a low projection count is the healthy state. **Part II, hub merge: adopted by v1.35**, with one guard that cannot bind yet, since a merge across differing compartment declarations is refused in vocabulary drafted at v1.23. **Part III, multi-tenancy: not adopted.** Its own verdict is *premature*. Reading (c) later took concrete, bounded form as the Consumer edition in v1.39; readings (a) and (b) are untouched and remain where this RFC left them. The Part I status addendum inside the document is dated 2026-08-20 and describes v1.32's state on that day; it is deliberately not refreshed. |
| [RFC-005](RFC-005-routines.md) | Routines, their sources, and the conformance watch | DESIGN ONLY | | | Referenced by RFC-006 and by the editions section as something neither implements | Designed 2026-08-22 and unimplemented. It landed on the published branch under v1.45 **as design only**, to repair published text that cited a document no reader could open; landing is not adopting. Its banner was corrected on that landing and states its true status. |
| [RFC-006](RFC-006-editions.md) | Editions, the run/evolve boundary, and a line a licensing policy could later attach to | ADOPTED | v1.39 | 2026-08-22 | Names RFC-007 as the hard prerequisite for the Consumer edition; is the concrete form of RFC-004 Part III reading (c) | Adopted as boundary doctrine. **No schema, check or mechanism was added**, because the RFC states none is strictly required by the boundary itself, and the optional edition-declaration field it discusses was deliberately deferred. Tier separation is stated as convention and never as an enforced control. The Consumer edition's Reader was a known, tracked gap at v1.39 and was closed by v1.41. |
| [RFC-007](RFC-007-reader-tier.md) | The Reader tier, the scoped reader, and the honest isolation boundary | ADOPTED | v1.41 | 2026-08-23 | Completes the Consumer edition RFC-006 defined; the scoped reader is the read side of an RFC-002 compartment | Adopted with the isolation claim kept honest: a scoped reader's isolation is **convention** unless the hosting enforces it, and the standard refuses to describe it as an enforced tenant boundary. **Reader skills were narrowed**: `km-brief` is named as the Reader skill that already ships, and a dedicated query skill and a reader-safe gather are deferred to a later harvest rather than authored. Drafted as v1.40 and renumbered when v1.40 published as something else; a published version identifier is never reused. |
| [RFC-008](RFC-008-proposal-template-staging.md) | The proposal template's staging discipline, and two hub-local practices seeking a canonical home | ADOPTED | v1.64 | 2026-08-27 | Implements a restatement of Rule 3 (*Stage explicitly*, v1.10) at the template's point of use; its no-home ruling rests on v1.63's manifest retirement | **Adopted by v1.64** (published 2026-08-27, owner push), implemented as designed, with its three conclusions carried in full: the blanket-add prohibition is grafted into the shipped proposal template beside the staging step it governs (Rule 3 stays the home of record); the manifest-recompute step gets **no canonical home**, because v1.63 retired its subject, and a deployed hub drops the step when it refreshes its template; and `tests/test_proposal_template_staging.sh` replaces a token-absence acceptance criterion with a presence-measuring check, run red against the unrepaired tree first. |

## Supersession

**No RFC in this repository supersedes another.** The column is absent rather than empty, because a
column of dashes reads as a fact that was checked and there is nothing here to check. The set is
cumulative: RFC-002 answers questions RFC-001 left open, RFC-006 names RFC-007 as its prerequisite,
and RFC-007 closes the gap RFC-006 declared. None of them withdraws or replaces an earlier design.
Should one ever do so, it is recorded in the Relationships column of both rows and in the superseded
document's own status banner, and neither document is deleted.

## How the badge is kept true

The `rfcs` badge on the repository's landing page is **generated from the table above** and never
maintained by hand. A hand-maintained count is what produced the false `2 adopted` this page was
created to repair.

```bash
python3 scripts/validate_rfc_lifecycle.py --write-badge
```

The same file validates it. Run with no arguments it asserts that `assets/badges/rfcs.svg` and the
`alt` text beside it in `README.md` are exactly what it would render from this table, so a badge
edited by hand, an `alt` left behind, or a status changed here without regenerating the badge each
fail the release gate. The count is not maintained; it is regenerated.

That check also holds this page to the tree and to the ledger: every RFC in this directory must have
a row here, every row must name a document that exists, no row may record as unimplemented an RFC the
version ledger says a version implemented, and every version named in the *Implemented by* column
must be a real version-history row.

## The limit of that check, stated

The ledger has never used one phrase for adoption, so the check derives implementation from rows that
bind an implementation verb to an RFC reference, and that set is a **lower bound**. The v1.22 row
records RFC-001's adoption as "Full rationale ... in `rfcs/RFC-001-sor-gateway.md`" and the v1.32 row
records RFC-004 Part I as "designed in `rfcs/RFC-004`". Neither is in the derived set, and both are
carried in this table under a maintainer's judgement. Widening the pattern until it caught them would
also catch the v1.45 row, which names an RFC while recounting a repair and implements nothing.

Nothing checks whether a Notes cell above describes a narrowing correctly. That is a judgement, and
the standard's own rule is to say so rather than to build an instrument that models whether the
sentence was edited.
