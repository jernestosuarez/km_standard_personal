---
type: architecture
title: Architecture Documentation Index
description: Index of the documents describing the layered architecture the KM Standard implements, from the canonical mechanism to the knowledge hubs.
tags: [architecture, standard, enterprise, deployment]
timestamp: 2026-08-02
---

# Architecture Documentation

These documents describe the architecture the KM Standard implements as of v1.14. They are
organization-neutral: they describe the mechanism generically, and any organization adopting the
standard can read them without translation. They are descriptive, not normative. Where they
disagree with [`STANDARD.md`](../../STANDARD.md), `STANDARD.md` wins.

| Document | Covers |
|---|---|
| [`01-overview.md`](01-overview.md) | The layered architecture and the authority flow between layers. |
| [`02-hub-deployment.md`](02-hub-deployment.md) | The canonical-first, profile-second deployment protocol, its two commits, and its fail-closed behavior. |
| [`03-organization-profile.md`](03-organization-profile.md) | The OrganizationProfile contract: required fields, immutability, forbidden operations, and resolution rules. |
| [`04-authority-boundaries.md`](04-authority-boundaries.md) | Who approves, who implements, who orchestrates, who executes, and how each is recorded. |

Normative sources:

- [`STANDARD.md`](../../STANDARD.md), in particular the enterprise organization profile extension
  (v1.14), the Roles section, and the Agent Tier.
- [`contracts/organization-profile.schema.json`](../../contracts/organization-profile.schema.json)
- [`scripts/validate_organization_profile.py`](../../scripts/validate_organization_profile.py)
- [`template/km-deployment.md`](../../template/km-deployment.md)
- [`skills/km-init/SKILL.md`](../../skills/km-init/SKILL.md)
- [`tests/test_hub_deployment_binding.sh`](../../tests/test_hub_deployment_binding.sh)
