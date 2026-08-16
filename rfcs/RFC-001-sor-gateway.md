---
type: reference
title: RFC-001 — The record boundary: a systems-of-record gateway for governed hubs
description: Names the boundary the inbox, date gate, and reconciliation were always enforcing — records stay in systems of record; hubs hold claims about records — and gives it a schema: Rule 6, accessClass, SourceSystem, Claim, bitemporal validity, and an inbound connector model. Drafted as v1.22; normative edits ride the same branch.
tags: [rfc, record-boundary, sor-gateway, governance, ontology]
timestamp: 2026-08-16
---

# RFC-001 — The record boundary: a systems-of-record gateway

> **Status: DRAFT.** Owner-authorized 2026-08-16; drafted as **v1.22 (DRAFT — awaiting owner
> push)** on branch `feature/sor-gateway`, stacked on the unpublished v1.20/v1.21 drafts. The
> normative edits summarized in §"Normative changes" land in the same branch; nothing binds any
> deployment until the owner publishes. Open questions in §"Open questions" are deliberately
> unresolved and await the owner's ruling.

---

## Motivation

A hub is not a data store. The moment it starts holding copies of operational records — CRM rows,
ledger entries, personnel files, contact databases — it becomes a shadow system: unowned,
unrefreshed, invisible to the access controls of the system the records actually live in, and
growing staler by the day while looking exactly as authoritative as the day it was copied. Every
governance control in this standard measures whether the hub is *consistent*; none of them, until
now, said what the hub may *hold*.

The evidence is operational, not theoretical: an engagement organizing a partner organization's
complete internal knowledge export (~12,000 files, including investor-contact databases, financial
records, and sales materials) into a governed hub. At that scale the question "does this file
enter the hub?" stops being answerable file-by-file and demands a rule. The rules that emerged —
stated below as the four crossing laws — were discovered by applying the standard's existing
mechanisms honestly, not designed in advance. See §"The lesson" for what actually happened.

**The central insight: the standard already contains the gateway, operated manually.** The inbox
(Rule 1), the date gate, and the reconciliation layer *are* the boundary between systems of record
and the hub: material lands in `_inbox/`, is dated, digested, classified, and adjudicated before
anything becomes settled hub prose. This RFC names the boundary those mechanisms were always
enforcing, and gives it a schema — so that automating any part of it later cannot quietly automate
away the part that must stay human. The governing principle throughout:

> **Detection, extraction, and freshness automate; classification and resolution authority stay
> with the owner.**

This is the same division reconciliation already draws (the agent detects contradictions; the
owner adjudicates them), applied one layer down.

---

## The layered architecture

```
L4  Consumers          humans · agents · factories · briefs/publications
L3  Domain hubs        per-project / per-domain governed hubs
L2  Supervisor         routing · ontology stewardship · cross-hub reconciliation · SoR registry
L1  SoR Gateway        connectors · classification · claim extraction · freshness · access mediation
L0  Systems of record  ERP · CRM · HRIS · finance · DMS · ticketing · transcription · IdP
```

L3 and L2 exist in the standard today (hubs; the Supervisor tier). L0 exists in every
organization whether or not anyone names it. **L1 is what this RFC names**: today it is the inbox
+ date gate + reconciliation operated by hand, and that manual form remains the reference
implementation. A hub built from a snapshot is the batch degenerate case of the gateway — a
`vault-export` source with `refreshPolicy: none`, honestly declared. Nothing in this RFC requires
a connector, a server, or any automation to exist.

This stack does not renumber the standard's existing internal layers (Format, Governance,
Reconciliation, Supervisor); those describe what is inside a hub and above it. This stack
describes where the hub sits between the systems that master records and the consumers that read
knowledge.

---

## Normative changes (summary — the edits are the authority)

All edits land in this branch; section names refer to `STANDARD.md`.

| # | Change | Where |
|---|---|---|
| 1 | **Rule 6 — The record boundary**: records stay in systems of record; hubs hold claims about records with resolvable pointers. The four crossing laws. The inbox/date-gate/reconciliation named as the manual gateway. | Governance Layer (now "Six Rules"); Layer-2 summary bullet; Customisation Guide fixed table |
| 2 | **`accessClass`** — optional OKF frontmatter field, `public \| internal \| restricted \| record`, default `internal` when absent. Propagation (derived-from-restricted inherits restricted) and declassification ("aggregation declassifies; extraction does not"). Outbound enforcement made classification-aware in `[ RESTRICTED ]`: a restricted-class note's **body text** is blocked verbatim on outbound surfaces while its **name stays nameable** (existence crosses — law 3); the existing `sensitivity: restricted` frontmatter marker remains the mechanism for names/existence that are themselves sensitive. Commented optional field added to every entity `TEMPLATE.md`. | Rule 6 §`accessClass`; `template/hub-scan.sh`; `template/build-indexes.sh` (restricted-class notes excluded from generated indexes); `tests/test_restricted_lint.sh` (fixtures both sides) |
| 3 | **`SourceSystem`** — optional eighth entity type, one note per connected system of record, home `template/sources/systems/TEMPLATE.md`. Fields: `systemKind`, `uriScheme`, `connector`, `defaultAccessClass`, `refreshPolicy`, `owner`, `last-reviewed`, `lifecycle`. Grounded in `dcat:DataService` (`dcat` prefix added to `context.jsonld`) — data-catalog vocabulary is solved common ground, per the standard's own IP doctrine. Cross-referenced both ways with `sources/dates-register.md` (register = per-source date gate; SourceSystem = per-system contract) and with `sources.config.md` (gather runtime config). | Ontology & Entity Layer §"Source systems"; hub structure diagram; monitored-files list; `hub-scan.sh` `[ SHAPE ]` + monitoring |
| 4 | **`Claim`** — optional ninth entity type, `template/claims/TEMPLATE.md`: a settled fact promoted to a first-class note when it needs an independent lifecycle, an evidence chain, a validity window, or a stable cross-hub identity. `evidencedBy` reuses the `prov:wasDerivedFrom` mapping; `assertion_method` reuses the relationship layer's vocabulary plus `derived`. **Reconciliation remains the adjudication process; promotion is never mandatory** — small hubs keep their tables. Proprietary grounding, like `Decision`/`Risk`. | Ontology & Entity Layer §"Claims"; `claims/` in entity dirs (`hub-scan.sh`, `build-indexes.sh`) |
| 5 | **Bitemporal validity** — optional cross-cutting fields `validFrom` / `validUntil` (when the fact holds in the world) and `recordedAt` (when the hub learned it), mapped to `schema:validFrom` / `schema:validThrough` / `prov:generatedAtTime`, all `xsd:date`. Adopts the priority candidate from `DESIGN-RATIONALE_semantica-component-mining.md` (pattern 1) in normative-draft form; field names follow the entity layer's idiom rather than the rationale's `valid-until:` sketch. Lifecycle handles supersession; validity handles **scheduled truth**. | §"Scheduled truth"; `context.jsonld` |
| 6 | **Source connectors (inbound)** — optional section mirroring the outbound "Query surface (MCP)" section. v1 (declarative): each SourceSystem note *is* the manifest. v2 (live): a connector declares readable scope, class ceiling, cadence, uri scheme; read-only by default; everything lands via `_inbox/` or as claims with lineage; raw records never cross. | §"Source connectors (SoR gateway)" |
| 7 | **Housekeeping** — version to v1.22 DRAFT (banner, H1, ledger row); README package overview (this `rfcs/` folder, new template files); Supervisor-tier pointer note for the SoR-registry/charter question; monitored-files list brought into agreement with `hub-scan.sh`'s actual entity set (it had silently omitted `relationships/` and `corrections/` — a pre-existing doc/scan mismatch repaired while editing that block). | Throughout |

### Design decisions worth naming

- **The new rule is Rule 6, not Rule 5.** The governance layer already has five rules (Rule 5,
  source traceability, since v1.4). Nothing is renumbered.
- **`accessClass` does not replace `sensitivity:`.** The marker mechanism (v1.16, narrowed v1.21)
  answers "is this note's name or this section's text disclosable?" — a *surface* question. The
  class answers "what may be done with this content?" — a *derivation* question. A
  frontmatter-marked note's name is blocked; a classed note's name is deliberately **not** blocked,
  because law 3 says existence crosses — a `record`-class catalogue entry exists precisely so the
  hub can name a record without reproducing it. A note whose existence is itself sensitive marks
  `sensitivity: restricted` in frontmatter, exactly as before.
- **Verbatim matching enforces declassification by construction.** An aggregate computed from
  restricted rows is not a verbatim line of any restricted note, so it passes the outbound check; a
  copied line item is, so it fails. The check and the aphorism are the same rule seen twice.
- **SourceSystem stays under `sources/`.** It is provenance infrastructure — the system-level
  sibling of the registers already there. The repo structure supports this: the named provenance
  registers inside `sources/` are already individually monitored, so `sources/systems/*.md` joins
  that pattern (re-included by name in `[ INTEGRITY ]`, walked by the monitored-docs loop).
- **`confidence` is not required on `Claim`.** A claim promoted from a settled row is adjudicated,
  and the standard already rules that settled facts carry no confidence. Required fields are
  `title`, `owner`, `evidencedBy`, `assertion_method`, `recordedAt`.

---

## Migration and back-compat

**No existing hub changes, and no existing hub fails a scan it previously passed.**

- Every new mechanism is optional and absent-by-default: no `accessClass` field means `internal`;
  no `claims/` or `sources/systems/` folder means the checks that would walk them find nothing
  (`find … 2>/dev/null`, same tolerance as `relationships/` today).
- The `[ RESTRICTED ]` extension fires only where a note actually carries
  `accessClass: restricted` or `accessClass: record` — a vocabulary no pre-v1.22 hub uses.
- `sensitivity: restricted` behavior is unchanged on both sides of the v1.21 narrowing; the
  existing fixtures still pass unmodified.
- The bitemporal fields bind nothing mechanically yet (see implementation notes).
- Adoption is per-hub and owner-decided, through the normal three-hop flow (Standard Maintainer →
  Supervisor → each hub's own governance). A hub adopts the record boundary by creating the
  folders it needs and copying the two new templates; nothing retrofits automatically.

---

## Implementation notes — specified here, not implemented

1. **Lapsed-validity advisory.** A `[ VALIDITY ]` (or `[ FRESHNESS ]`-adjacent) advisory listing
   notes whose `validUntil` is past: *staleness candidates by declaration, not by guess*. Advisory,
   never error (same reasoning as `[ CURRENCY ]`: a backlog nobody can clear today is a gate that
   gets switched off). Parse dates with the same dual `date -j -f` / `date -d` fallback
   `[ FRESHNESS ]` uses. Not built now: no hub yet writes the fields, and a check with no possible
   evidence proves nothing.
2. **v2 live connectors.** An MCP server per system of record, declaring readable scope, an
   access-class ceiling on everything it emits, cadence, and uri scheme, matching its SourceSystem
   note. Gateway rules regardless of transport: read-only by default; output lands via `_inbox/`
   or as claims with lineage (source pointer + extraction date + access class); raw records above
   class `record` never cross; the date gate and reconciliation apply unchanged — a connector is a
   faster inbox, never a bypass. Nothing here is built; the declarative v1 (the note itself) is
   deliberately sufficient to adopt the layer.
3. **Class propagation is a stated rule, not yet a checked one.** "Derived from restricted
   inherits restricted" cannot be checked deterministically without derivation metadata; where a
   `Claim` carries `evidencedBy` pointers into a classed source, a future check could compare
   classes. Until then: document the rule; do not build the police.
4. **Query-time gating.** Whether `accessClass` should gate agent tool access on the MCP query
   surface (e.g. `query_facts` refusing to return `restricted` content to an unprivileged caller)
   is open question 3 — it depends on the MCP surface growing a caller-identity concept it does
   not have. Today the reference server (`template/mcp/server.py`) filters retired/superseded
   notes but neither `sensitivity`-marked nor classed content — a pre-existing property, now
   named; `claims/` was added to its entity dirs so Claim notes are queryable like any other
   entity.
5. **Supervisor SoR registry.** An estate view aggregating the hubs' `SourceSystem` notes (which
   systems feed which hubs, at what ceilings) — generated, never hand-maintained, like the agent
   registry. Pointer added to the Supervisor tier; the charter expansion is open question 2.
6. **`km-init` scaffolding.** `km-init` does not create `claims/` or `sources/systems/` — the same
   asymmetry `relationships/` already has (folder optional, template present in `template/`, not in
   the init copy list). A hub adopts by creating the folder; if the owner later wants init-time
   scaffolding, that is a one-line change to the skill.
7. **YAML shape caveat.** `evidencedBy` must be an **inline** list (`[a, b]`), like `evidence:` on
   relationship assertions — the scan's `fm_field` reads single-line values only, and a block list
   would read as missing. The template says so.

---

## Open questions — for the owner to rule on

1. **Hub-level access classes.** Does a *hub* itself carry a clearance (a finance hub vs a project
   hub) that the Supervisor mediates when one hub's agent follows another hub's pointers? Today the
   class lives on notes; a hub-level ceiling would be the natural unit for cross-hub mediation, and
   also the first genuinely new Supervisor authority since the evidence standard.
2. **Supervisor charter expansion.** Ontology stewardship, SoR-registry stewardship, and
   classification authority — policy sets defaults at the gateway (each SourceSystem note's
   `defaultAccessClass`); the owner adjudicates exceptions, the mirror of reconciliation. The
   standard now carries only a pointer note in the Supervisor tier; the charter rewrite is future
   work and should not ride this RFC.
3. **Query-time enforcement.** Whether `accessClass` gates agent tool access at query time on the
   MCP surface (implementation note 4). Depends on the MCP query-surface work; deciding it now
   would be designing ahead of a funded question.

---

## The lesson

The four crossing laws were discovered operationally, not designed. In a real engagement —
describable only as: *an engagement organizing a partner organization's complete internal
knowledge export (~12,000 files, including investor-contact databases, financial records, and
sales materials) into a governed hub* — the boundary emerged one honest decision at a time:

- a contract's **claims** crossed into the hub while the document stayed in its document store
  behind a URI pointer — *claims cross; records don't*;
- funding history crossed as an **aggregate** while the line items didn't — *aggregates cross;
  line items don't*;
- two large contact databases crossed as **existence + size** while their contents were never read
  — *existence crosses; contents don't*;
- and the complete vault export was **catalogued and git-ignored**, with only decision-relevant
  files opened — the unavoidable-copy case, held at the fidelity its access class permits.

At no point did the engagement need a mechanism the standard lacked. The inbox received, the date
gate dated, digests classified, reconciliation adjudicated. What was missing was the *name* of the
rule being enforced — so every crossing decision was re-derived from first principles, by one
person, with no schema to record the terms. The governance layer already contained the gateway;
this RFC names it and gives it a schema.

*2026-08-16. Companion to STANDARD.md v1.22 (DRAFT). Related:
DESIGN-RATIONALE_semantica-component-mining.md (bitemporal candidate, adopted here as change 5);
DESIGN-RATIONALE_akcp-component-mining.md (framing rule for lifting ideas, not runtimes).*
