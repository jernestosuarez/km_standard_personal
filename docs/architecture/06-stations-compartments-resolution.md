---
type: architecture
title: Stations, Compartments, and the Resolution Plane (DRAFT)
description: The v1.23 draft architecture — hub species as station × exposure, compartments for hub-to-hub access, the resolution plane for record-class data, the three planes, tombstone redaction, crossing-law scale-invariance, and the Supervisor charter sketch. Not yet binding.
tags: [architecture, draft, stations, compartments, resolution-plane, supervisor]
timestamp: 2026-08-16
---

# Stations, Compartments, and the Resolution Plane

> **DRAFT — v1.23, awaiting owner push. Nothing on this page binds any deployment.** The template
> mechanics it describes are physically present in the published tree (optional and
> absent-by-default, so no hub that declares nothing is affected), but the obligations bind only
> when v1.23 publishes. Normative draft text: `STANDARD.md` (sections marked v1.23); rationale and
> per-ruling provenance tags (owner-ruled / delegated / directional):
> [`rfcs/RFC-002-stations-compartments-resolution.md`](../../rfcs/RFC-002-stations-compartments-resolution.md).

## The resolution plane

Record-class data is never stored in the hub's git. The hub holds the pointer; the gateway
resolves it at query time through a connector — clearance-checked, audit-logged, nothing
persisted. The access *event* may be recorded as a claim; the accessed *data* may not. The reason
is structural: git is permanent, and personal data carries a right to erasure that a versioned
file cannot honor. The classes therefore divide by storage plane — `restricted` content may live
in git under its class; `record` referents are resolved, never stored.

## The three planes

| Plane | Substrate | Holds |
|---|---|---|
| Knowledge | git | Everything Rule 6 lets cross |
| Resolution | gateway/MCP runtime | Nothing at rest — record-class referents resolved per query |
| Scratch | `_scratch/`, git-ignored, wipeable | Temporarily materialized records for batch work, with a stated lifetime |

Storage stays git at every station; what differs near the systems of record is the runtime. The
scratch plane names work that must touch records in bulk — an export extracted, processed,
deleted. Because git never held it, erasure is honored by construction.

## Station × exposure: two independent axes

Declared in `km-deployment.md`: `station` (org-core | domain | engagement | publication) governs
**intake**; `exposure` (never-public | compartment | counterparty | public) governs **output**.
Defaults when absent: `domain` / `compartment`. The crossing laws become station-transition rules
— from SoR into org-core, knowledge crosses at full fidelity (records still resolve-only); from
org-core into domain hubs, aggregates cross; onto publication surfaces, only public claims cross.

> **Build at the station, publish at the exposure.**

The design error the axes repair: deriving a hub's intake rules from its exposure hollows the hub
out to match its most public consumer. Fill it to its station; let the boundary produce the
projections. Alongside this rides the tempo rule: org-core hubs snapshot aggregates at governance
cadence — *the hub records what the organization knew and decided upon, not everything it
measured.*

## Compartments, not levels

Hub-to-hub access is compartmented and audience-relative, not a linear scale: two hubs can be
equally "restricted" about the same subject in opposite directions — one holds positions its
counterparty must never see; the other is written *for* that counterparty. Each hub declares an
owner, an audience, and a boundary; cross-compartment flow is default-deny, Supervisor-mediated.

Three mechanisms, three jobs, non-collapsible: `station`/`exposure` govern a hub's **edges**; the
**compartment** governs **membership between hubs**; `accessClass` governs **zones inside a hub**.

## Scale-invariance and the two exceptions to permanence

- **Existence crosses; contents don't — at every altitude.** Each layer relates to the layer
  below as hubs relate to systems of record: the Supervisor holds claims *about* hubs, never hub
  contents. A tier holding only existence-grade claims is not worth breaching for contents that
  were never there.
- **Redaction with tombstones** is the single lawful exception to supersede-never-rewrite: an
  owner-only history-redaction procedure for erasure obligations that reach committed knowledge,
  leaving a tombstone note (the fact and date of removal preserved, the content gone), logged as a
  correction, exceptional by definition — routine redaction is a Rule 6 failure upstream.

## Supervisor charter sketch

Four functions, sketched (the charter rewrite remains future work): the **promotion path** (hub
experience → supervisor observation → standard RFC — the ontology's own evolution mechanism);
**cross-hub claim reconciliation** (one claim, one home of record; the sweep detects divergence,
the owning hub resolves); the **federated SoR registry** (in multi-hub estates `SourceSystem`
notes live at the Supervisor, with per-hub subscriptions to a uriScheme plus filter — connector
classification policy must be uniform across hubs; per-hub placement remains the single-hub
home); and **compartment policy** (the gateway sets classification defaults, the compartment
owner adjudicates exceptions, the Supervisor holds the policy table and escalation path).
