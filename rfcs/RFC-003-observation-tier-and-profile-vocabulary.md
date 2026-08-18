---
type: reference
title: RFC-003 — The observation tier and profile-declared entity types: two extension points
description: Design document for two governed extension points. Part I defines the tier below Rule 2 — a two-store model separating machine-written observations from governed assertions, and the promotion contract between them, deliberately not the engine. Part II defines profile-declared entity types — a validated vocabulary extension point in the organization-profile contract. The promotion contract is designed first because it constrains the extension design. No normative change rides this RFC.
tags: [rfc, observation-tier, promotion-contract, extension-point, ontology, organization-profile, rule-2]
timestamp: 2026-08-18
---

# RFC-003 — The observation tier and profile-declared entity types

> **Status: DRAFT — design document only.** Unlike RFC-001 and RFC-002, **no normative edits ride
> this RFC**: no `STANDARD.md` change, no version-history row, no schema, template, or script
> change. Everything below is design awaiting a later, separately authorized normative change and
> owner push; nothing binds any deployment.
>
> **Authority and path:** a standard change request entered at the middle stage of the promotion
> path the standard defines (hub experience → supervisor observation → standard RFC). The
> supervisor verified its claims against the trunk at v1.26 and recommended one RFC, two parts,
> promotion contract designed first; the deployment owner answered **"carry"** (2026-08-18),
> accepting that routing. The request's own constraints, restated below and tagged
> **[OWNER-RULED]**, were part of what was carried.
>
> **Ordering note:** the originating request numbered the vocabulary extension first and the
> observation tier second. This RFC presents them in **design order**: the promotion contract is
> the harder design and constrains the shape of the extension point, so it is designed and
> presented first — the request's own sequencing argument, accepted in the ruling.

## Provenance discipline

The standard's evidence hierarchy applies to its own design rulings, as in RFC-002. Every design
statement below carries one tag:

| Tag | Meaning |
|---|---|
| **[OWNER-RULED]** | Carried by the owner's ruling: the request's stated model and constraints, and the supervisor routing the owner accepted. Fixed as drafted. |
| **[DIRECTIONAL]** | A maintainer design call made in drafting, beyond what the request specified. Drafted concretely so it can be tested and revised by operational evidence or the owner's word. |

---

## Motivation

The standard's write model has exactly one tier: every write to a hub is an **assertion** — a
claim about what is true — and every assertion needs a human (Rule 2). For governed knowledge
this is correct and this RFC does not touch it. But it leaves a class of material with no lawful
home: **evidence of what happened**, produced continuously by machines. A hub receiving such
material has only two behaviours, and both fail:

- **Queue it for approval.** The approval path is sized for a small number of curated notes;
  continuous volume exceeds any human's review capacity, and the queue becomes a place where
  things are not read.
- **Keep it outside the hub.** Then the hub holds no trace of what happened, and the knowledge
  the automated work produced is unavailable to anything that reads the hub.

The underlying defect is that two different things are being asked of one store. Evidence of what
happened is high-volume, machine-written, and not authoritative. Claims about what is true are
small, curated, governed, and authoritative. Git is the right substrate for the second and the
wrong substrate for the first — the standard already says as much at the org-core station
(*"version at the tempo of decisions, not of data"*, v1.23 draft) — and today the standard only
names the second.

The evidence is operational and close to home. Deployments that run unattended routines
(scouting passes, evaluation runs, hygiene sweeps) accumulate logs and evaluation shelves that
live outside hub governance precisely because no tier exists for them. And the standard's own
tree now carries the pattern: the KM Cockpit component
([`components/km-cockpit/`](../components/km-cockpit/)) keeps append-only, line-delimited JSONL
ledgers in a manifest-declared state directory — machine-written, high-volume, non-authoritative,
deliberately outside git. The gap is visible in the standard's own shipped component.

The second gap is narrower. The entity vocabulary is canonical
([`template/context.jsonld`](../template/context.jsonld)), and the organization-profile contract
([`contracts/organization-profile.schema.json`](../contracts/organization-profile.schema.json))
configures **behaviour** but cannot configure **vocabulary**: it has no key for entity types and
is `additionalProperties: false`. A deployment whose domain needs a type outside the built-in set
must either misuse an existing type (the vocabulary stops meaning what it says), change the
canonical standard (every deployment's domain accretes into the trunk), or fork the template (a
second standard nobody governs — the outcome `canonical_compatibility` exists to prevent). The
built-in set is not the problem; the absence of a governed way to extend it is.

The two parts are one coherent surface: **how a deployment extends the standard without changing
the trunk** — Part I for volume, Part II for vocabulary. And Part I load-bears for Part II: see
§"Why the promotion contract constrains the extension design".

---

# Part I — The observation tier below Rule 2

## 1 · Two stores, one boundary [OWNER-RULED]

The tier is defined as a **two-store model and the contract between them, deliberately not the
engine**:

| Store | Holds | Written by | Approval | Substrate |
|---|---|---|---|---|
| **Observations** | Evidence of what happened. High-volume, machine-written, **explicitly not authoritative** | Machines, continuously | **None** | **Outside the git-backed hub** |
| **Assertions** | Claims about what is true. The governed notes that exist today | Humans and agents under Rule 2 | Proposal/approval, **unchanged** | Git |

Rule 2 is untouched: observations are not assertions, so the approval requirement for governed
knowledge does not weaken. This adds a tier **below** it.

Two properties are hard requirements of the whole design, not implementation choices
[OWNER-RULED]:

1. **An observation must never be readable as an assertion by any downstream surface** — scans,
   indexes, the MCP query surface, projections, or any consumer of hub content (§6).
2. **Promotion is a recorded event with its own provenance**, never a copy that loses where it
   came from (§7).

Like `Claim`, the tier is **optional per hub** [OWNER-RULED]: available, never required, and a
hub with no machine-written inflow loses nothing by ignoring it (§8).

## 2 · The observation store is a system of record the hub produces [DIRECTIONAL]

The design key that makes the tier cohere with the standard instead of beside it: **the
observation store is a system of record, and the hub relates to it under Rule 6 exactly as it
relates to any other SoR.** Observations are records — high-volume operational evidence, mastered
where they are produced. The hub holds claims about them. The four crossing laws apply unchanged:

- **Claims cross; observations don't.** A promoted conclusion enters the hub; the raw stream
  stays in the store.
- **Aggregates cross; individual observations don't** — the common promotion case: a figure
  computed across many observation records.
- **Existence crosses; contents don't.** The hub (and its scan) may say the store exists, how big
  it is, and how it is addressed — without reading it.
- **An unavoidable copy is the classified extract with lineage** — the load-bearing-evidence case
  in §5.

Two consequences follow for free. First, the store is describable by the machinery the standard
already has: a hub adopting the tier records it as a **`SourceSystem` note** (`systemKind:
other`, or a future `observation-store` enum value), with `uriScheme`, `connector`,
`defaultAccessClass`, and `refreshPolicy` carrying the store's terms — no parallel registry is
invented, and in a multi-hub estate the note follows the same federated placement as any other
SourceSystem. Second, **promotion is a Rule 6 crossing**, so it inherits the governing principle
already stated there: *detection, extraction, and freshness automate; classification and
resolution authority stay with the owner.* Machines may nominate; only the governed flow promotes.

## 3 · What an observation is [DIRECTIONAL]

The contract specifies **properties, never a storage format** — mandating a format would be
specifying the engine. An observation record must be:

- **addressable** — a stable reference (an id, or a durable position in an append-only store)
  that a promotion can cite and a later reader can resolve while the store's retention holds;
- **timestamped** — when it was recorded;
- **producer-attributed** — which activity or component wrote it;
- **append-only** — observations are recorded, never edited in place; a wrong observation is
  contradicted by a later one, not rewritten (the retract-in-place doctrine, one tier down).

An observation record **must not carry OKF frontmatter claiming a hub entity type** — that is the
format-level half of hard requirement 1. The reference examples of the class (routine logs,
evaluation shelves, the cockpit component's JSONL ledgers) all satisfy these properties already;
none needed to be designed for it.

## 4 · Where observations live [DIRECTIONAL]

The store's location is **declared in the hub's deployment manifest** (`km-deployment.md`),
following the precedent of every other declared plane. The default is a git-ignored
`_observations/` directory at the hub root — the scratch plane's mechanics with the opposite
lifecycle: `_scratch/` is wipeable with a stated lifetime; `_observations/` is append-only with a
stated **retention**. A deployment may instead declare an external location (a service, a
database, another tree); the manifest declaration, not the path, is what makes the store known.

Because git never holds observations, two properties arrive by construction: erasure is honorable
(what git never held, git never has to forget — the resolution-plane rationale, applied to the
hub's own output), and the publish boundary cannot leak them (§6).

Retention is declared, not defaulted: the manifest states how long observations are kept, and a
promotion whose evidence would outlive the store's retention pulls the cited excerpt into
`sources/` as a first-order hold — Rule 5's existing "promote load-bearing facts to first-order"
mechanism, unchanged.

## 5 · The promotion contract [OWNER-RULED elements; DIRECTIONAL mechanics]

What an observation must carry before it can become an assertion. The five elements are the
request's, carried as ruled; the field mappings are drafting [DIRECTIONAL]. PROV provides the
vocabulary for the first two, and **`Claim` is the result's reference shape**.

| # | Element [OWNER-RULED] | Carried as [DIRECTIONAL] | Grounding |
|---|---|---|---|
| 1 | **Evidence reference** — the observation(s), or the observation set, the assertion rests on | `evidencedBy: [<uri>, …]` on the resulting note — existing field, values in the store's declared `uriScheme` | `prov:wasDerivedFrom` (existing mapping) |
| 2 | **Producing activity** — what produced the evidence and, for an aggregate, the computation performed | `generatedBy:` — new cross-cutting field | `prov:wasGeneratedBy` (new mapping) |
| 3 | **Promotion approver** — who or what approved the promotion | `promotedBy:` — wiki-link to a stakeholder note, or the named authority under which a default ran | `prov:wasAttributedTo` (new mapping) |
| 4 | **Scope** — what the assertion applies to | `scope:` — existing field | `skos:inScheme` (existing mapping) |
| 5 | **Expiry** — where one applies | `validUntil:` (existing, optional); `recordedAt:` stamps when the hub asserted it | `schema:validThrough`, `prov:generatedAtTime` (existing mappings) |

**The result shape is Claim-adjacent** [OWNER-RULED]: a promoted observation typically lands as a
`Claim` note, with `assertion_method: derived` — the vocabulary's existing value for "a claim
computed from records", which is exactly what a promotion is — plus the fields above. No new
entity type is minted for promotion [DIRECTIONAL]: the promotion fields are **cross-cutting**,
like the bitemporal fields, so a promotion may also land as a `Decision`, a `Risk`, or (once Part
II exists) an extension-typed note, carrying the same five elements wherever it lands.

**Promotion rides Rule 2 unchanged** [DIRECTIONAL]. A promotion is proposed into `changes/`,
approved, applied, logged, and committed like any other assertion — the tier adds required
content to the artifact, never a second approval mechanism. Where a deployment runs the owner
queue, a routine may **nominate** a promotion as a queue row under the queue's own tiering; the
tier itself neither requires nor bypasses that machinery.

## 6 · Hard requirement 1: never readable as an assertion [OWNER-RULED; enforcement DIRECTIONAL]

The requirement is enforced **by construction first, prohibition second**:

- **By construction:** observations live outside git, and every conforming consuming surface
  already passes the projection contract's gate 1 — *committed at git HEAD*. An observation is
  never at HEAD, so no conforming surface can serve one, with no new rule to write. This is the
  strongest available enforcement: the boundary holds even for a surface that has never heard of
  this RFC, provided it honors the contract the standard already binds it to.
- **By prohibition, for the machinery that walks the filesystem rather than HEAD:** scans, index
  builders, and the MCP server's entity walk **never enter the observation plane**. The scan may
  print an existence-grade advisory — the store exists, its declared retention, its approximate
  size — and nothing more: *existence crosses; contents don't*, applied to the hub's own store.
- **By format:** an observation carries no hub-typed OKF frontmatter (§3), so even a
  mis-configured walker finds nothing shaped like an entity note.
- **By labeling, at the edge:** any surface that deliberately presents observations (a dashboard,
  a tailing view) presents them **as observations** — non-authoritative, unapproved — never
  interleaved with hub facts. Such surfaces are engines, out of scope here; the labeling duty is
  the one thing the contract says about them.

## 7 · Hard requirement 2: promotion is a recorded event [OWNER-RULED; mechanics DIRECTIONAL]

A promotion that merely copies content into a note loses where it came from — the exact defect
provenance exists to prevent. The contract requires the event to survive in three existing rails,
none new:

1. **The resulting note** carries the five contract elements (§5) — the durable, queryable record;
2. **The provenance index** (`sources/transcript-index.md`) logs the promotion at apply time, as
   the Rule 2 flow already logs every apply — naming the evidence reference and approver;
3. **The apply commit** is the event's timestamp and audit anchor, as everywhere.

A fuller PROV model — the promotion itself as a first-class `prov:Activity` with plan and
association — is deliberately **not** required [DIRECTIONAL]: three rails the standard already
runs beat a fourth it would have to build, and nothing in the three-rail form precludes lifting
to the fuller model later.

## 8 · Optionality and adoption condition [OWNER-RULED; condition wording DIRECTIONAL]

Like `Claim` and `RelationshipAssertion`: available, never mandatory. The adoption condition, in
the style of the supervisor tier's conditions table: **adopt the observation tier when
machine-written material arrives faster than the approval path can read it** — the moment the
queue-it-or-lose-it dilemma first bites. A hub fed only by dropped documents never meets the
condition and never carries the plane.

---

# Part II — Profile-declared entity types

## 9 · Why the promotion contract constrains the extension design [DIRECTIONAL]

Two load-bearing constraints flow from Part I into Part II, and they are the reason for the
design order:

1. **The extension point must not become the pressure valve for volume.** Without an observation
   tier, a deployment drowning in machine-written material would reach for the one extension it
   had — a custom entity type — and mint assertions at machine tempo, hollowing out Rule 2 from
   inside the vocabulary. With Part I in place, Part II can be strictly an
   **assertion-vocabulary** mechanism: an extension type is a governed note type under Rule 2,
   full stop, and volume has somewhere else to land.
2. **The cross-cutting vocabulary is reserved.** The promotion fields (§5), the bitemporal
   fields, `accessClass`, `lifecycle`, and the provenance fields are canonical and cross-cutting
   so that a promoted observation can land as an extension-typed note **without the extension
   redefining any of them**. An extension declares new types, edges, and properties *beside* the
   cross-cutting layer, never beneath it (§13).

## 10 · The declaration [DIRECTIONAL]

A new optional key in the organization-profile contract, `entity_extensions`, requiring a
`schema_version` bump (existing `1.0` profiles remain valid; the key requires `1.1`). Each entry
declares one type:

```json
{
  "entity_extensions": [
    {
      "type_name": "Facility",
      "folder": "facilities",
      "description": "A physical site the organization operates",
      "grounding": "schema:Place",
      "required_fields": ["owner", "status"],
      "edges": {
        "operatedBy": {"grounding": "schema:provider"},
        "locatedWith": {}
      },
      "properties": {
        "capacity": "xsd:integer",
        "commissioned": "xsd:date"
      }
    }
  ]
}
```

- `type_name` — PascalCase; the entity class.
- `folder` — the entity folder, joining the one-instance-one-file convention.
- `grounding` — **explicit, always**: either a compact IRI into a public vocabulary already
  prefixed in `context.jsonld` (`schema:`, `org:`, `prov:`, `dcat:`, `skos:`), or the literal
  `"proprietary"` with a `grounding_rationale`. This makes the standard's IP doctrine a recorded
  decision per type rather than a default omission: map to solved common ground where a suitable
  term exists; mint proprietary terms only where the concept is genuinely the organization's own
  [OWNER-RULED as a constraint; the explicit-field mechanism is drafting].
- `required_fields` — drives `[ SHAPE ]` for the new type, exactly as the flat table drives it
  for canonical types.
- `edges` — properties that are graph edges (wiki-link values, `@type: @id`), each with optional
  public grounding.
- `properties` — datatyped literals (`xsd:` types).

The declaration lives in the **profile**, so it is deployment content by construction: the
canonical repository gains only the mechanism, never any organization's vocabulary — the exact
line the request drew between an extension point and new canonical content [OWNER-RULED].

## 11 · Validation: fail-closed, no shadowing, canonical wins over time [OWNER-RULED constraint; mechanics DIRECTIONAL]

An extension **must not be able to redefine or shadow a canonical type** [OWNER-RULED]. The
validator (`validate_organization_profile.py`, extended) enforces, fail-closed like every other
profile check:

- `type_name` not in the canonical type set, and `folder` not a canonical entity folder;
- no declared term (type, edge, or property name) may **re-map a key already present in the
  canonical `context.jsonld`** — a term name already bound stays bound; an extension needing a
  different meaning picks a different name;
- `grounding` may not target another hub type (aliasing `Facility` to `Decision` is shadowing by
  another route);
- prefixes must be drawn from the context's declared public vocabularies — an extension may not
  introduce new namespace prefixes in this draft (a deliberate floor; lifting it is an open
  question).

**Canonical wins over time.** The canonical type set grows (`SourceSystem` and `Claim` arrived in
v1.22), so a collision can be born after an extension deploys. The rule: collision validation
runs against the canonical version actually pinned at application time, and when a deployment
re-pins to a canonical version that has minted a colliding name, validation fails the profile at
re-pin — the canonical name wins, and the deployment renames its extension type through its own
governance, with supersession recorded. An extension never holds a name against the trunk.

## 12 · Materialization and machinery visibility [DIRECTIONAL]

**Materialization.** At profile application, the declared terms are merged into the hub's root
`context.jsonld` — the file the standard already tells initiatives to extend ("that extension
*is* the ontology's IP"); this mechanism makes the extension declared, validated, and uniform
across the organization's hubs instead of hand-typed per hub. The merge is deterministic and
refuses to overwrite any existing key (the validator has already guaranteed it never needs to).
The entity folder is created with a generated `TEMPLATE.md` carrying the declared required
fields. Both land in the profile-application commit, the second of the two auditable deployment
commits — nothing new in the commit model.

**Visibility.** *Scans and index builders must know an extension exists, otherwise they report a
declared type as an unrecognised folder* [OWNER-RULED]. The deployment manifest
(`km-deployment.md`) records the declared extension set — types, folders, required fields — at
application time, and the machinery reads it there:

- `hub-scan.sh` extends its monitored-files set, `[ FRONTMATTER ]`, `[ LINKS ]`, and `[ SHAPE ]`
  over declared extension folders, with required fields from the declaration;
- `build-indexes.sh` generates each extension folder's `index.md` like any canonical folder;
- the MCP surface's `list_entities(type)` accepts extension types via the same declaration — the
  four-tool surface does not grow.

**The checker is proven, not assumed.** An integrity checker narrower than the graph it checks
misses exactly the violations extensions introduce — a lesson one estate has already paid for.
The implementing change must therefore ship a **canary**: a test fixture declaring a synthetic
extension type with an injected violation (a missing required field, a dangling edge), which the
extended scan must catch. A scan that cannot fail on extension content does not check it.

## 13 · Bound by `canonical_compatibility`, reserving the cross-cutting layer [OWNER-RULED; reservation DIRECTIONAL]

An extension states which trunk versions it holds against **by construction**: `entity_extensions`
lives inside the profile, and the profile already carries `canonical_compatibility` — the range
governs the extension with no new field [OWNER-RULED]. §11's canonical-wins rule is this binding
enforced over time.

The reserved layer (§9): an extension may not redeclare or remap `lifecycle`, `timestamp`,
`last-reviewed`, `confidence`, `accessClass`, `sensitivity`, the bitemporal fields, `supersedes`,
`evidencedBy`, `scope`, `assertion_method`, or the promotion fields of Part I. These are the
standard's cross-cutting spine; they mean the same thing on every note, canonical or extended, or
they mean nothing.

## 14 · What an extension may not do [OWNER-RULED, restated]

No specific entity types enter the canonical vocabulary through this mechanism, ever — the
extension point is the whole design. An extension cannot: redefine or shadow a canonical type or
term (§11); weaken any governance rule (extension notes are monitored, scanned, and governed
identically to canonical notes); introduce a write path (Part I is the only tier below Rule 2,
and it is not a write path into git); or ship entity *instances* (the profile declares types;
notes are hub content under hub governance, as always).

---

## Migration and back-compat

**No existing hub or profile changes, and nothing fails that passed.** Both parts are optional
and absent-by-default: no manifest observation declaration means no observation plane and no scan
line; `schema_version: 1.0` profiles remain valid and declare nothing; a hub that never adopts
either part is byte-for-byte unaffected. Adoption is per-deployment (Part II, through the
enterprise layer's profile governance) and per-hub (Part I, through each hub's own governance),
through the normal three-hop flow.

## Implementation notes — specified here, not implemented

None of the following exists after this RFC; each lands only with the eventual normative change:

1. **Contract and validator:** `entity_extensions` in
   `contracts/organization-profile.schema.json` (`schema_version` 1.1) and the matching
   fail-closed checks in `scripts/validate_organization_profile.py`, with negative fixtures for
   every refusal in §11.
2. **Context terms:** `generatedBy` → `prov:wasGeneratedBy` and `promotedBy` →
   `prov:wasAttributedTo` in `template/context.jsonld`.
3. **Machinery:** manifest-driven extension walk in `template/hub-scan.sh` and
   `template/build-indexes.sh`; the extension canary test (§12); the observation-plane
   existence advisory; MCP `list_entities` extension-type acceptance.
4. **Templates:** manifest fields for the observation declaration (location, retention) in
   `template/km-deployment.md`; `_observations/` in the template `.gitignore`; the generated
   extension `TEMPLATE.md` shape.
5. **`SourceSystem` enum:** whether `observation-store` joins `systemKind` or stays `other`
   (cosmetic; decide at implementation).
6. **STANDARD.md text:** Part I as a new subsection under the governance layer (below Rule 2,
   explicitly not renumbering anything) plus entity-layer and Supervisor pointers; Part II in the
   organization-profile section and the entity layer. Version row and README with the same
   change.

## Deliberately not designed

Deferred by the request's own scope [OWNER-RULED], and honored here: **no ingestion
implementation and no storage choice** — the contract, not the engine, is what keeps the engine
replaceable and the volume out of git; **no requirement that any hub adopt** either part; **no
change to Rule 2 for assertions**. Additionally deferred by the maintainer [DIRECTIONAL]: any
auto-promotion (machines nominate, the governed flow promotes — a promotion applied without the
contract's approver element is a Rule 2 violation, not a feature); any observation query surface;
retention tooling.

## Open questions — for the owner to rule on

1. **Promotion default tier.** Where the owner queue exists, may a routine-nominated promotion
   ever be tier B (auto-apply after a veto window), or is promotion always tier A? The contract
   works either way; the queue's own exclusion list (identity, money, restricted, deletions,
   client-facing) would still bind. Recommendation: start tier A, relax per class with evidence.
2. **New namespace prefixes for extensions.** §11 floors extensions at the context's existing
   public prefixes. A deployment grounding into a domain vocabulary (e.g. a sector ontology)
   would need a declared-prefix mechanism — worth designing only when a real profile asks.
3. **Estate-level observation stores.** The cockpit's ledgers are estate-tier, not hub-tier. Part
   I is drafted hub-first (the request's frame); whether the supervisor tier declares its own
   observation plane under the same contract is left to the estate's operational evidence.

*2026-08-18. Design companion to STANDARD.md v1.26 (published 2026-08-17). Related:
RFC-001-sor-gateway.md (Rule 6, the crossing laws, `SourceSystem`, `Claim`, bitemporal fields);
RFC-002-stations-compartments-resolution.md (planes, tempo-of-decisions, scale invariance).*
