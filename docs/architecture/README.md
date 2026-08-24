---
type: architecture
title: Architecture Documentation Index
description: Historical v1.22 snapshot of the layered architecture, from systems of record through the canonical mechanism to the knowledge hubs and their consumers. Not maintained forward; STANDARD.md describes the current system.
tags: [architecture, standard, enterprise, deployment, record-boundary]
timestamp: 2026-08-16
---

# Architecture Documentation

> **A HISTORICAL SNAPSHOT OF v1.22, NOT THE CURRENT ARCHITECTURE** (labelled in v1.48). This set
> describes the standard as it stood at **v1.22** (published 2026-08-16), with **v1.23 riding as
> draft** and marked as such
> wherever it appears. **It is not maintained forward.** The standard has added or materially changed
> at least nine surfaces since: the KM Cockpit and the owner queue's decision surface, the projection
> contract's four gates, the three-surface model, the supervisor threshold and the minimum tier, hub
> merge, the editions and run/evolve boundary, the Reader tier and the scoped reader, the quarantine
> of the MCP query surface, and the release gate. **None of those is described here.** Read this set
> as the record of what the architecture was at the record-boundary release, and read
> [`STANDARD.md`](../../STANDARD.md) for what it is now.

These documents are organization-neutral: they describe the mechanism generically, and any
organization adopting the standard can read them without translation. They are descriptive, not
normative. Where they disagree with [`STANDARD.md`](../../STANDARD.md), `STANDARD.md` wins.

| Document | Covers |
|---|---|
| [`01-overview.md`](01-overview.md) | The layered architecture, the vertical L0–L4 stack, the entity types, and the authority flow between layers. |
| [`02-hub-deployment.md`](02-hub-deployment.md) | The canonical-first, profile-second deployment protocol, its two commits, and its fail-closed behavior. |
| [`03-organization-profile.md`](03-organization-profile.md) | The OrganizationProfile contract: required fields, immutability, forbidden operations, and resolution rules. |
| [`04-authority-boundaries.md`](04-authority-boundaries.md) | Who approves, who implements, who orchestrates, who executes, and how each is recorded. |
| [`05-the-record-boundary.md`](05-the-record-boundary.md) | The record boundary (v1.22): the four crossing laws, `accessClass`, the `SourceSystem` and `Claim` types, bitemporal validity, and inbound connectors. |
| [`06-stations-compartments-resolution.md`](06-stations-compartments-resolution.md) | **DRAFT (v1.23, not yet binding):** stations × exposure, compartments, the resolution plane, the three planes, tombstone redaction, and the Supervisor charter sketch. |

## Version bridge

These pages were first written at the v1.15 init (2026-08-02). What the standard added between
that and the version these pages now describe, one line each from the version ledger:

| Version | Introduced |
|---|---|
| v1.16 | The sensitivity boundary became a checked rule: `[ RESTRICTED ]` in `hub-scan.sh`; restricted notes excluded from generated indexes. |
| v1.17 | Session-start handover surfacing: `[ HANDOVER ]` prints first; a missing `HANDOVER.md` is an error. |
| v1.18 | Handover write side: a Stop gate forces a `HANDOVER.md` refresh before a state-changing session ends. |
| v1.19 | The estate corrections registry is surfaced and bound at hub session start (`[ CORRECTIONS ]`). |
| v1.20 | The owner queue: one machine-parseable decision surface, three tiers, decision-halt back-pressure, batched clearing. (Drafted 2026-08-14; published 2026-08-16 with v1.22.) |
| v1.21 | `[ RESTRICTED ]` name block narrowed to frontmatter-restricted notes; body-marked sections block their text, not the note's name. (Drafted 2026-08-14; published 2026-08-16 with v1.22.) |
| v1.22 | The record boundary — see [`05-the-record-boundary.md`](05-the-record-boundary.md). |
| v1.23 | **DRAFT** — stations, compartments, and the resolution plane; see [`06-stations-compartments-resolution.md`](06-stations-compartments-resolution.md). |

Normative sources:

- [`STANDARD.md`](../../STANDARD.md), in particular the Governance Layer (six rules), the
  Ontology & Entity Layer, the enterprise organization profile extension (v1.14), the Roles
  section, the Agent Tier, and the version history ledger.
- [`rfcs/RFC-001-sor-gateway.md`](../../rfcs/RFC-001-sor-gateway.md) (adopted, v1.22) and
  [`rfcs/RFC-002-stations-compartments-resolution.md`](../../rfcs/RFC-002-stations-compartments-resolution.md)
  (draft, v1.23).
- [`contracts/organization-profile.schema.json`](../../contracts/organization-profile.schema.json)
- [`scripts/validate_organization_profile.py`](../../scripts/validate_organization_profile.py)
- [`template/km-deployment.md`](../../template/km-deployment.md)
- [`template/hub-scan.sh`](../../template/hub-scan.sh)
- [`skills/km-init/SKILL.md`](../../skills/km-init/SKILL.md)
- [`tests/test_hub_deployment_binding.sh`](../../tests/test_hub_deployment_binding.sh) and
  [`tests/test_restricted_lint.sh`](../../tests/test_restricted_lint.sh)
