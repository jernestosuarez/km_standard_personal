---
type: reference
title: RFC-002 — Stations, compartments, and the resolution plane
description: Companion to RFC-001. Folds the owner's follow-on rulings into the record boundary — the resolution plane for record-class data, the three planes of an org-core hub, station × exposure as independent axes, compartments for hub-level access, scale-invariance of the crossing laws, tombstoned redaction, decision-tempo versioning, and a Supervisor charter sketch. Drafted as v1.23; each ruling carries its provenance tag.
tags: [rfc, record-boundary, stations, compartments, resolution-plane, supervisor]
timestamp: 2026-08-16
---

# RFC-002 — Stations, compartments, and the resolution plane

> **Status: DRAFT.** Companion to [RFC-001](RFC-001-sor-gateway.md); owner design session of
> 2026-08-16, relayed the same day; drafted as **v1.23 (DRAFT — awaiting owner push)** on branch
> `feature/sor-gateway`, stacked on the v1.22 draft. RFC-001's open questions are updated in place
> with resolved-by pointers — the questions stand as asked; what answers them is marked.

## Provenance discipline

The standard's own evidence hierarchy applies to its rulings. Every item below carries one tag,
so the owner's later testing can revisit each cleanly:

| Tag | Meaning |
|---|---|
| **[OWNER-RULED]** | Explicit owner statement. Binding as drafted. |
| **[DELEGATED]** | Owner asked for the advisor's recommendation and received it ("I count on your advice"). Binding as drafted, on delegated authority. |
| **[DIRECTIONAL]** | Owner approved the direction for testing ("let's go in this direction, I'll test it"). Drafted normatively; expected to be revised by operational evidence. |

Everything remains unpublished draft until the owner pushes; the tags rank the rulings *within*
that shared draft status.

---

## 1 · The resolution plane [OWNER-RULED]

**Record-class data is never stored in the hub's git.** The hub holds the pointer; the gateway
resolves it at query time through a connector (typically MCP): clearance-checked, audit-logged,
nothing persisted. The access **event** may be recorded as a claim; the accessed **data** may not.

The rationale the owner endorsed: git is permanent and erasure obligations are not optional.
Personal data carries a right to erasure that a versioned file cannot honor — every commit that
ever contained it would have to be rewritten, which Rule 3's integrity model exists to forbid. So
the classes divide by *storage plane*: `restricted` content may live in git under its class;
`record` referents live only in their system of record and are **resolved, never stored**.

This strengthens Rule 6 from implication ("must never be reproduced in hub content") to explicit
normative text, and it gives RFC-001's query-time-gating gap **one name instead of two**:
RFC-001's implementation note 4 (should `accessClass` gate the MCP query surface?) and open
question 3 are both *the resolution plane* — the hub's own query surface serves knowledge-plane
content as before; anything record-class is answered by resolution through the gateway,
clearance-checked at the moment of the query. Normative text: Rule 6 → "The resolution plane".

## 2 · The three planes of an org-core hub [DELEGATED]

Storage stays git at every station; what differs near the systems of record is the **runtime**:

| Plane | Substrate | Holds |
|---|---|---|
| **Knowledge plane** | git | Claims, aggregates, existence — everything Rule 6 lets cross |
| **Resolution plane** | gateway/MCP runtime (item 1) | Nothing at rest: record-class referents resolved per query |
| **Scratch plane** | a declared, git-ignored, wipeable workspace | Temporarily materialized records for batch processing, with a stated lifetime |

The scratch plane existed operationally in RFC-001's evidence engagement — a vault export
extracted, processed, and deleted — and had no name in the standard, which meant no rule bound
it. It now has both: `_scratch/` at the hub root, git-ignored by the template's own `.gitignore`,
so it honors erasure **by construction** (what git never held, git never has to forget). It is
the *materialized* batch degenerate case of the gateway: same crossing laws on the way out of it,
plus a wipe at the end. Normative text: Rule 6 → "Three planes"; `_scratch/` added to
`template/.gitignore`.

## 3 · Hub species: station × exposure [DIRECTIONAL]

Two independent axes, declared in the deployment manifest (`km-deployment.md`, the hub's species
card):

- `station: org-core | domain | engagement | publication` — governs **intake**: what may flow in.
- `exposure: never-public | compartment | counterparty | public` — governs **output**: who may
  consume.

Defaults when absent — `station: domain`, `exposure: compartment` — so no existing hub changes
and no scan that passed before fails now (`[ DEPLOYMENT ]` validates the enums only when the
fields are present).

The crossing laws become **station-transition rules**, parameterized by (from-station,
to-station): from a system of record into org-core, knowledge crosses at full fidelity (records
still resolve-only, per item 1); from org-core into domain hubs, aggregates cross; onto
publication surfaces, only public claims cross.

> **Build at the station, publish at the exposure.**

The design error this repairs, stated generically: **deriving a hub's intake rules from its
exposure hollows the hub out to match its most public consumer.** A hub filled only with what its
widest audience may see cannot answer its owner's own questions. Fill it to its station; let the
boundary produce the projections.

The decision-tempo rule rides this axis (item 7, [DELEGATED]): org-core hubs snapshot aggregates
at governance cadence — weekly, monthly, at decision points — while telemetry stays in the
systems of record and their dashboards. *The hub records what the organization knew and decided
upon, not everything it measured.* This guards SoR-adjacent stations against git-as-telemetry
noise. Normative text: Rule 6 → "Station and exposure"; manifest fields in
`template/km-deployment.md`; enum validation in `hub-scan.sh` `[ DEPLOYMENT ]`.

## 4 · Compartments, not levels [DIRECTIONAL] — resolves RFC-001 open question 1

Hub-to-hub access is not a linear scale; it is **compartmented and audience-relative**. The
genericized evidence: an estate ran two hubs about the same partnership — one advisory hub whose
*boundary* includes the counterparty (it holds negotiation positions), and one organizational hub
whose *audience* **is** the counterparty. Same "restricted" level; opposite directions. No
ordering of levels can express that; a compartment model expresses it in two fields.

Mechanism: each hub declares an **owner**, an **audience** (who it is for), and a **boundary**
(who it must never reach), in the deployment manifest beside station and exposure.
Cross-compartment flow is **default-deny, Supervisor-mediated**: a hub's agent following another
hub's pointer crosses a compartment edge only through the Supervisor's policy table (item 8d).

Three mechanisms, three jobs, deliberately non-collapsible:

| Mechanism | Governs | Question it answers |
|---|---|---|
| `station` / `exposure` | A hub's **edges** | What flows in; who consumes out |
| **Compartment** (audience/boundary) | **Membership between hubs** | May this hub's content reach that hub's audience? |
| `accessClass` | **Zones inside a hub** | What may be done with this note's content? |

Audience and boundary values are free-form party names and therefore **hub-local content** — they
live in each hub's own manifest and never in this canonical repository. No mechanical validation
is imposed on them in this draft; the declaration and the default-deny rule are the normative
core. Normative text: Rule 6 → "Station and exposure" (the three-mechanisms table); commented
manifest fields.

## 5 · Scale-invariance of the crossing laws [DIRECTIONAL]

Each layer relates to the layer below exactly as hubs relate to systems of record. The Supervisor
holds claims **about** hubs — existence, ownership, topics, claim identities — never hub
contents; a person's supervisor-level card records **which** compartments they appear in, never
what they did there.

> **Existence crosses; contents don't — at every altitude.**

This is also the structural answer to the supervisor-as-highest-value-target problem: a tier that
holds only existence-grade claims about the tiers below is not worth breaching for their
contents, because the contents were never there. Normative text: Supervisor Tier, beside "master
index, never a master copy".

## 6 · Redaction with tombstones [DELEGATED]

The single lawful exception to *supersede, never rewrite*: an **owner-only history-redaction
procedure** for erasure obligations that reach committed knowledge (not just records — item 1
already keeps records out of git). The redaction:

- leaves a **tombstone note** recording the fact and date of redaction — the *fact that something
  was removed* is preserved; the content is gone;
- is logged as a `corrections/` note (the reasoning survives, as everywhere);
- must be **exceptional and documented** — a redaction that is routine is a hub holding material
  it should never have held, which is a Rule 6 failure upstream, not a redaction policy.

Placed beside the supersede-never-rewrite doctrine as its explicit boundary condition, so the two
rules are read together and neither silently swallows the other. Normative text: §"Superseding".

## 7 · Version at the tempo of decisions [DELEGATED]

Folded into item 3's normative text (the station axis is where it bites); recorded here as its
own ruling for provenance. Org-core hubs snapshot aggregates at governance cadence; telemetry
stays in systems of record. The hub records what the organization knew and decided upon, not
everything it measured.

## 8 · Supervisor charter sketch [DIRECTIONAL] — partially resolves RFC-001 open question 2

Four functions, sketched here as charter material; the charter rewrite itself remains future
work:

- **(a) The promotion path.** Hub experience → supervisor observation → standard RFC, named as
  the ontology's evolution mechanism: schema changes are corrections at the meta level, and this
  very branch — an engagement's crossing decisions becoming Rule 6 — is an instance of the path
  it names.
- **(b) Cross-hub claim reconciliation.** A claim has one identity and one home of record; other
  hubs reference it. The Supervisor's sweep detects divergence between a referenced claim and its
  references and routes a dispute to the owning hub. Detection automated, resolution human — the
  unchanged principle at a new altitude.
- **(c) Federated SoR registry** — refines RFC-001's per-hub `SourceSystem` placement.
  Connectors are estate-level infrastructure: one mail connector serves many hubs, and its
  classification policy must be uniform, or the same record crosses at two different ceilings
  depending on which hub asked. In multi-hub estates, `SourceSystem` notes therefore live at the
  **Supervisor**, and each hub carries a **subscription** — it subscribes to a `uriScheme` with a
  filter. **Per-hub placement remains valid for single-hub deployments**, where there is no
  second hub for the policy to diverge across. Normative text: entity layer §"Source systems"
  and the Supervisor pointer paragraph.
- **(d) Compartment policy.** The gateway sets classification defaults; the compartment owner
  adjudicates exceptions; the Supervisor holds the policy table and the escalation path — the
  mirror of reconciliation, at the compartment edge.

## RFC-001 open questions — disposition

| RFC-001 question | Disposition |
|---|---|
| 1 · Hub-level access classes | **Resolved [DIRECTIONAL]** by item 4: compartments, not levels — owner/audience/boundary, default-deny, Supervisor-mediated. |
| 2 · Supervisor charter expansion | **Partially resolved [DIRECTIONAL]** by item 8's four-function sketch; the charter rewrite stays future work. |
| 3 · Query-time enforcement | **Subsumed [OWNER-RULED]** by item 1: the gap has one name — the resolution plane. Record-class access is clearance-checked resolution through the gateway; the knowledge-plane MCP surface is unchanged. |

## What remains open for the owner

1. **Operational testing of every [DIRECTIONAL] item** — station/exposure enums and transition
   rules, the compartment declaration shape, the federated-registry subscription mechanism, and
   the scale-invariance wording — the owner stated they will test; the tags mark exactly what
   that testing may revise.
2. **The Supervisor charter rewrite** itself (item 8 is a sketch, not the charter).
3. **The redaction procedure's mechanics** — the tombstone note's exact shape and any tooling —
   are documented as convention only; no script performs or verifies a redaction in this draft.
4. **Resolution-plane implementation** — the clearance check, the audit log, and the
   access-event-as-claim shape are specified behaviors with no reference implementation yet
   (RFC-001 implementation note 2 remains the connector's home).

*2026-08-16. Companion to STANDARD.md v1.23 (DRAFT) and to RFC-001-sor-gateway.md.*
