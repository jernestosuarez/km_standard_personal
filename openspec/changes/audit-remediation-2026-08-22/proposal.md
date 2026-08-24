---
type: change
title: Audit remediation, closing the version-evolution drift found by external QA
description: Remediation plan for the 14 findings of the 2026-08-22 external repository audit. Four waves, ordered by exposure. Wave A unblocks the unpublished Reader tier, Wave B issues corrective releases for published v1.39, Wave C builds the release gate that would have caught all of it, Wave D clears documentation drift. Each wave is independently approvable.
tags: [standard, audit, remediation, release-gate, projection, reader, plan]
resource: ../../../STANDARD.md
timestamp: 2026-08-22
lifecycle: active
---

# Change: audit-remediation-2026-08-22

**Nothing here is executed.** Every wave is separately approvable, by letter. The maintainer proposes;
publication of any resulting version remains the owner's push.

## Problem statement

An external QA audit of the repository (baseline: `v1.40-reader-tier` at `a29cc15`, published `main`
at `bd6d6ce` / v1.39) returned a conditional fail with 14 findings. Its central conclusion is worth
restating exactly, because it determines the shape of this plan: the problem is **not** widespread
code breakage. Automated tests passed, the tree was clean, and object integrity was sound. The problem
is **governance drift between versions, and between duplicated distribution surfaces**.

That distinction matters. Every finding below describes a surface that was correct when written and
was never brought forward when the rules around it changed.

### What the maintainer verified independently

The audit is an external document. Its principal claims were reproduced first-hand before this plan
was written, rather than accepted on trust:

| Finding | Verification result |
|---|---|
| F-01 MCP bypasses the projection gates | **Confirmed.** `get_entity()` returns raw entity text after a committed-state check alone: no lifecycle, access class, sensitivity, or manifest gate |
| F-03 Reader scope bypass | **Confirmed and reproduced.** `scope: *, hub-alpha` is accepted and reported as `closed scope of 2 hub(s)`. A trailing comma (`scope: hub-alpha,`) additionally parses as a hub literally named `hub-alpha,` |
| F-04 RFC-005 missing | **Confirmed.** Published `main` carries RFC-001, 002, 003, 004 and 006. `STANDARD.md` on `main` references RFC-005 twice. RFC-005 exists only on an unmerged local branch |
| F-05 `km-brief` copies diverge | **Confirmed.** Root copy is 109 lines, template mirror is 128 |
| F-07 No tracked licence | **Confirmed.** No `LICENSE`, `COPYING`, or equivalent exists |
| F-14 Draft metadata inconsistent | **Confirmed.** Frontmatter reads v1.39 while the heading reads v1.40 draft |

Not independently verified at the time of writing: F-02, F-06, F-08, F-09, F-10, F-11, F-12, F-13.
Each carries a verification step as its first task, so no remediation begins from an unchecked claim.

### Two failures this plan must own

**The Reader scope bypass passed the maintainer's own release verification.** The v1.40 branch was
checked for leakage and its test suite was run and reported green, and a push was recommended on that
basis. The suite proved the scanner rejects an exact `*` and an exact `all`, and nothing tested a
wildcard hidden inside a list. This is the precise limit the standard already states in its own v1.30
row: proving a check fires in both directions proves it fires on the class it **models**, never that
it models the right class. The doctrine was already written down, and it was not applied to the check
being shipped.

**The dangling RFC-005 reference was introduced by a publish decision.** v1.39 was published carrying
normative references to an RFC that had never been merged, while the drafting agent's report
explicitly flagged that RFC-005 and RFC-006 existed only on unmerged branches. The warning was
acknowledged and not acted on.

Both failures share one cause, which is also F-06: **there is no release gate**. Verification before
publication was manual, per-version, and performed by the same actor that authored the change.

### The finding classes

The 14 findings sort into four groups by exposure, and this is the ordering principle of the plan:

1. **Defects in unpublished material** (F-03, F-14). Cheap to fix, because nothing has shipped. They
   block the Reader tier's publication.
2. **Defects in published material** (F-01, F-04, F-05, and F-02). These are live in a deployment
   today and need corrective releases. F-01 is the most serious: a consuming surface that ignores the
   access and lifecycle rules can return retired, superseded, or restricted content.
3. **Absent release infrastructure** (F-06, F-07, F-09). The class that allowed the other three to
   accumulate.
4. **Documentation drift** (F-08, F-10, F-11, F-12, F-13). Lower severity, with one exception: F-08
   ships an outdated governance model into every newly created hub, so its blast radius grows with
   adoption.

## Plan

Four waves. Each is independently approvable and separately publishable. Wave A must complete before
the Reader tier publishes. Waves B, C and D may be reordered on the owner's word, and the recommended
order is as written.

### Wave A, unblock the unpublished Reader tier

The Reader tier (v1.40) is drafted and unpublished, so its defects are repaired in place on its own
branch and no corrective release is needed. Two fixes.

**A1, the scope token parser (F-03).** The current check validates the scope as a single whole value.
It is rewritten to parse and validate **each token independently**, rejecting `*`, `all`, empty
entries, malformed identifiers and duplicate declarations. The reason this is a real control and not
a cosmetic one: a scoped reader is the mechanism by which a consumer or tenant is confined to its own
compartment, so a scope that silently widens is the failure mode the whole mechanism exists to
prevent.

**A2, draft metadata (F-14).** Frontmatter and heading agree on one version identity; the Reader
README's claim that the two instruction mirrors are kept equal is either made true or corrected to
what is actually guaranteed; the outputs-directory ignore rule is tightened so generated material
cannot surface as untracked files.

**A3, generalise the lesson.** F-03's defect class is *validating a compound value by its whole rather
than by its parts*. Every other shipped check that reads a delimited list is swept for the same shape.
This follows the standard's own established practice of generalising a repaired defect into a rule
rather than patching one instrument.

### Wave B, corrective releases for published v1.39

Ordered by exposure, cheapest first where exposure is equal.

**B1, resolve RFC-005 (F-04).** The design document exists and is complete on an unmerged branch. It
is merged to `main` as a design record, which is how RFC-004 reached `main` ahead of the version that
implemented it. This closes the dangling normative reference at the lowest possible cost and restores
the design lineage that RFC-006 and RFC-007 both depend on. A link check that reads code-formatted RFC
identifiers, and not only Markdown hyperlinks, is added so the class cannot recur silently.

**B2, quarantine the MCP surface (F-01, F-02).** The optional MCP surface does not enforce the four
projection gates the standard requires of every consuming surface, and its own README claims that it
does. Until the gates are implemented, the surface is **marked disabled and its claims corrected**.
This is deliberately the first action rather than the full repair, on the standard's own doctrine that
an acknowledged gap is safer than a false assurance. The README's dependency instructions are corrected
in the same pass, since an unpinned install now selects an SDK major version whose API the server does
not use (F-02, to be verified first).

**B3, reconcile the distributed `km-brief` (F-05).** The root copy lacks the lifecycle protections its
template mirrors carry, so the copy advertised as distributable is the less safe one, and it can
surface retired or superseded knowledge. One canonical source is established, mirrors are derived from
it, and the parity test is extended from frontmatter to the governed instruction body, permitting only
documented per-runtime substitutions. This finding is **not new**: the v1.27 row recorded the drift and
deliberately deferred it. The deferral is now closed.

**B4, implement the MCP projection gates (F-01).** The full repair, as its own version: all four gates
(committed at `HEAD`, lifecycle-active, within access clearance, present in the projection manifest)
applied on every path including direct-identifier retrieval, sharing one policy implementation with the
other consuming surfaces rather than reimplementing it. Negative tests are mandatory: retired,
superseded, restricted, sensitive and unmanifested entities must each be proved unreachable, by
identifier lookup as well as by query.

### Wave C, the release gate

**C1, one audit command, run in CI (F-06).** A single versioned command that runs every suite, the
leakage guard, the syntax and link checks, and the profile validation. It becomes a required gate for
publication. Annotated version tags are created for released versions so a release is identifiable
without reading the ledger. This wave is what converts the two failures owned above from recurring
accidents into caught ones.

**C2, an RFC index (F-09).** `rfcs/README.md` recording every proposal's status, decision date,
implementing version, supersession and partial-adoption state, with the repository badge generated
from it rather than maintained by hand. Several RFC status banners are stale, because parts of them
have since been implemented while the banner still declares that no normative change rides on it.

**C3, licensing (F-07).** The README advertises adoption, adaptation, forking and redistribution
without attribution, and no licence file exists, so default copyright applies and the advertised grant
is not the effective one. **This is an owner decision and a legal one, and the maintainer does not
select a licence.** Two paths are prepared and neither is taken without instruction: adopt a standard
licence at the repository root, or soften the README's reuse claim to match the actual grant until
counsel formalises it. This item interacts directly with the editions boundary published in v1.39,
which was deliberately drawn to be license-agnostic so that a policy could later be attached at that
line without structural change.

### Wave D, documentation drift

**D1, the hub template landing page (F-08).** It teaches four governance rules where the standard now
defines six, and directs readers to find facts in numbered documents where the current model uses
one-instance-per-file entity notes with numbered documents as narrative rollups. Every newly created
hub inherits these instructions, so this is the drift with the largest downstream cost in the wave. A
conformance test on its rule count and terminology prevents recurrence.

**D2, narrow the enforcement claim (F-11).** The standard states that its governance layer enforces all
six rules, while the repository's own design rationale acknowledges that source traceability remains
procedural with no checkable lineage artifact. Either the claim is narrowed to distinguish mechanical
from procedural controls, or a minimal checkable provenance record is introduced. The first is
recommended, on the same honesty doctrine that governs the Reader's isolation boundary.

**D3, architecture documents (F-12).** Frozen around v1.22 and v1.23 while the cockpit, projection
contract, owner surfaces, merge workflow, editions and Reader tier all arrived afterwards. Either
refreshed or labelled a historical snapshot wherever the README links them.

**D4, publisher portability (F-10).** Platform-specific interpreter discovery, an unpinned rendering
dependency, and a generated environment directory with no ignore rule, which can make a governed hub's
tree read as dirty. Supported platforms declared, discovery made portable, dependencies pinned, the
environment ignored, and an end-to-end rendering smoke test added.

**D5, specification filename (F-13).** The component specification uses a generic filename against the
repository's own cache-safety convention. Renamed with its references updated atomically.

## Impact

**Surfaces changed.** `template/reader/` and its tests (Wave A). `rfcs/` and the RFC index (B1, C2).
`template/mcp/` and its README and tests (B2, B4). `skills/km-brief/` and both template mirrors and
the parity test (B3). Repository-level CI configuration and an audit command (C1). Repository root
licence, if and only if the owner directs it (C3). `template/README.md`, `docs/architecture/`,
`tools/km-publish.sh`, `components/km-cockpit/SPEC.md` and the references to it (Wave D).

**Version numbering.** Wave A repairs the unpublished v1.40 in place and publishes it as v1.40. Waves
B, C and D each produce one or more versions above it. Exact numbers are assigned at drafting time and
are deliberately not fixed here, because the waves may be reordered.

**Hub impact.** Wave A and Waves B1 through B4 change no hub content and impose no per-hub obligation.
D1 changes what a **newly created** hub inherits and leaves existing hubs untouched. C1 changes the
maintainer's release process and nothing a deployment runs.

**What is blocked.** The Reader tier does not publish until A1 and A2 complete and the bypass canaries
pass. Nothing else in this plan blocks on anything outside it.

**Reference deployment.** The estate that authors this standard remains its reference deployment. Where
a repair here lands ahead of that deployment, the deployment adopts it under its own governance, and a
conformance pass never reverts the deployment to this text.

## Owner decisions required

1. **Approve waves by letter**, in any subset and any order. Wave A is recommended first because it
   unblocks published work, and B2 is recommended immediately after because it is the only finding
   describing a live exposure path in a published version.
2. **F-01 shape**: quarantine the MCP surface first and repair it in a later version (recommended), or
   hold it unchanged until the full repair is ready.
3. **F-07 licensing**: select a licence, refer it to counsel, or direct the interim softening of the
   README's reuse claim. The maintainer proposes no licence.
4. **Tracking of this document and the audit**: the audit report is currently excluded from version
   control at the owner's request, by an uncommitted ignore rule. This proposal is likewise untracked.
   Both may be committed as governance records, or both may remain local. One decision covers both.

## What this change must not do

1. **It must not repair a finding it has not first reproduced.** Eight findings remain unverified and
   each carries verification as its first task.
2. **It must not claim a control it does not implement.** F-01 and F-11 both exist because a document
   asserted an enforcement that no code performed. A quarantine that says so plainly is the correct
   outcome of B2, and a passing check is not.
3. **It must not widen a repair into a redesign.** Each finding is closed at its own scope. The MCP
   gate implementation reuses the existing policy rather than authoring a second one.
4. **It must not publish anything on the maintainer's judgement alone.** Every version arising from
   this plan is drafted, leakage-guarded, proved in both directions, and published on the owner's
   decision.
5. **It must not treat a green suite as a release gate** until C1 exists. Until then, verification of
   any version arising from this plan explicitly includes an adversarial pass against the specific
   defect class being repaired.
