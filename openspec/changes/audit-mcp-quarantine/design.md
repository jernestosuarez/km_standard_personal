# Design

## Context

The optional query surface was written around v1.22. The four-gate access contract arrived later, and
the surface was never brought forward. Its documentation still describes the protections it had at the
time it was written.

Measured against the published tree before this change was drafted:

**Corrected 2026-08-22, during implementation.** The matrix first written here was wrong twice, and
the implementation measured it rather than trusting it. It claimed the query path did not enforce
lifecycle (it does), and it enumerated three content-returning paths when the surface registers
**seven**. Both errors ran in the same direction as the audit's summary, which is the reason a
specification is measured against the code and not against a report.

Measured against the published tree, `main` at `bd6d6ce`:

| Entry point | Committed at `HEAD` | Lifecycle-active | Access clearance | Manifest membership |
|---|---|---|---|---|
| `list_entities()` | Enforced | Enforced | **Not implemented** | **Not implemented** |
| `get_entity(id)` | Enforced | **Not enforced** | **Not implemented** | **Not implemented** |
| `query_facts()` | Enforced | Enforced | **Not implemented** | **Not implemented** |
| `hub_scope()` | Enforced | Not applicable, returns document sections | **Not implemented** | **Not implemented** |
| `hub://about` | Enforced | Not applicable, returns document text | **Not implemented** | **Not implemented** |
| `hub://glossary` | Enforced | Not applicable, returns document text | **Not implemented** | **Not implemented** |
| `hub://index/{folder}` | Enforced | Not applicable, returns document text | **Not implemented** | **Not implemented** |

The sharpest defect is the asymmetry on lifecycle: two retrieval paths exclude retired and superseded
notes and the direct-identifier path does not, while the documentation states the exclusion
unconditionally. Access clearance and manifest membership are implemented on no path at all.

The four entry points beyond the first three were absent from the first matrix. A refusal that covers
only the paths someone remembered to enumerate is not a refusal, so the quarantine covers all seven and
the implementation asserts that by structure rather than by list.

A search of the implementation for sensitivity, access, clearance, manifest, or projection logic
returns nothing. The content test is a denylist: material outside a small set of excluded directories
is treated as content, so an entity carrying a restricted marking in an ordinary location is exposed by
construction.

The documentation states that retired and superseded notes are never returned. That is true of the
listing path and false of the direct-identifier path.

## Decision 1: quarantine before repair

**Chosen**: stop the surface serving, then repair it as a separate change.

**Rejected**: hold the surface unchanged until the gates are implemented. That leaves a published,
documented, apparently-protected surface in the field for the length of the repair, and the false
guarantee is the part causing harm. An operator who reads that retired notes are never returned will
place material behind a control that does not exist on one path.

The standard's own doctrine settles this: an acknowledged gap is safer than a false assurance. A
quarantine is the acknowledgement.

## Decision 2: refuse, rather than degrade

A quarantined surface returns nothing. It does not fall back to the listing path because that path
happens to enforce lifecycle, and it does not serve a reduced result set.

Partial service would require an operator to reason about which of four gates applies on which of
three paths in order to know what they are trusting. That reasoning is exactly what failed here, and a
surface that answers at all invites reliance.

## Decision 3: state the exposure specifically

The version record names which gate each path applied and which content classes each path could
return. A deployment that enabled the surface needs to assess what it actually ran, and a general
statement that the surface was unsafe does not support that assessment.

This is deliberately more disclosure than a defect notice usually carries. The surface answered
questions for callers, so its failure mode is disclosure, and understating it would repeat the
original error in a smaller way.

## Decision 4: the premise is the finding

The root cause is the premise that commitment equals clearance, stated in the surface's own
documentation as "committed is safe to expose". Commitment records a fact. It decides nothing about who
may read it. This is written as a requirement rather than left as commentary, because the same premise
would reproduce the defect in any future surface built on it.

## Decision 5: claims are traceable to enforcement

The distribution-claims capability requires that each claimed protection be traceable to the code
performing it, so a claim that outlives its enforcement is detectable. This is the generalisable half
of the finding, and it applies beyond this surface. It is scoped to this surface here rather than
raised to a repository-wide control, and the wider application is noted below.

## Deliberately excluded from this change

| Item | Why excluded | Where tracked |
|---|---|---|
| Implementing the four gates | The repair is larger than the quarantine and must be separately published, with its own negative tests | `audit-mcp-projection-gates` |
| Lifting the quarantine | Conditioned on the repair being proved, per the last requirement in `mcp-surface-state` | `audit-mcp-projection-gates` |
| Raising the claims-match-enforcement rule to a repository-wide control | The same class appears in at least two other findings, including an overstated enforcement claim in the standard's own text. Raising it belongs with the release gate rather than with one surface's quarantine | Umbrella wave C, and wave D item D2 |
| The Reader scope bypass, the missing design document, the diverging skill copies, the absent release gate, licensing, documentation drift | Separate surfaces and separate approval boundaries | `audit-reader-tier-hardening`, and umbrella waves B, C, D |

## Risks

- **A quarantine can be read as a repair.** Mitigated by the requirement that the quarantine lifts only
  against a proved contract, and by keeping the repair in its own change with its own completion state.
- **Disclosure of the exposure is itself information.** The record names paths and content classes
  rather than any specific content, and the surface reads only committed state, so the record does not
  widen what a reader can learn.
- **Verifying the dependency finding may change its shape.** The installation finding is unverified at
  the time of writing, and its verification is the first task rather than an assumption carried into
  the specification.
