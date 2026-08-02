---
type: architecture
title: The OrganizationProfile Contract
description: The portable contract for organization customization, its required fields, immutability rules, forbidden operations, and resolution semantics.
tags: [architecture, organization-profile, contract, validation]
timestamp: 2026-08-02
---

# The OrganizationProfile Contract

An OrganizationProfile is the only vehicle by which organization policy reaches a hub. It is a JSON
document owned by the Enterprise Knowledge Layer, validated against
[`contracts/organization-profile.schema.json`](../../contracts/organization-profile.schema.json) by
the dependency-free validator
[`scripts/validate_organization_profile.py`](../../scripts/validate_organization_profile.py).

## Required fields

Every field below is required. The schema allows no additional properties, at the top level or in
any nested object.

| Field | Meaning |
|---|---|
| `schema_version` | Contract version. Fixed at `1.0`. |
| `profile_id` | Stable identifier of the profile. |
| `profile_revision` | Identifier of this exact revision of the profile. |
| `organization` | The organization's `id` and `name`. |
| `approval` | The institutional approval: `record_id` and `approved_at` date. |
| `canonical_compatibility` | The canonical version range the profile supports: `minimum` inclusive, `maximum_exclusive` exclusive. |
| `enterprise_binding` | The enterprise `namespace` and `contract_revision` the profile binds to. |
| `policy_references` | Unique references to the governing policy instructions. |
| `supervisor_binding` | The one supported provider operation: `resolve_organization_profile`. |
| `operations` | The declared customization operations. May be empty. |
| `forbidden_operations` | Exactly the six canonical prohibitions, listed below. |
| `effective_date` | The date from which the profile may be applied. |
| `lifecycle` | One of `active`, `superseded`, `retired`. Only `active` profiles are applied. |

## Immutability

A profile revision is immutable. Changing anything in a profile produces a new `profile_revision`;
the old revision is superseded, not edited. This is what makes the binding recorded in a hub's
`km-deployment.md` durable evidence: `organization-profile-id` plus
`organization-profile-revision` names exactly one artifact, forever.

## Resolution semantics

The Supervisor resolves a profile through the provider interface at an exact `profile_id` and
`profile_revision`. There is no default profile, no newest-revision fallback, and no partial match.
If the requested revision cannot be resolved, deployment stops. This prevents a deployment from
silently drifting onto a revision nobody approved for it.

## Canonical compatibility

The profile declares the canonical version range it was approved against. The validator checks
`minimum <= canonical version < maximum_exclusive` for the exact canonical version in use. An
incompatible canonical version rejects the profile before customization. Adopting a newer canonical
version therefore requires a profile revision approved for that range, which is a decision, not a
background update.

## Operations

A profile may declare two kinds of operations, and nothing else.

| Kind | Constraints |
|---|---|
| `add` | Writes one file. The `target` must be a safe relative path under `.km/organization/`, unique within the profile. The `source` must be a safe relative path. The content is pinned by `sha256`; a hash mismatch rejects the profile. |
| `module` | Enables one module. Requires a lowercase `module_id`, a safe relative `source` pinned by `sha256`, and an `eligibility_record` naming the eligibility decision. |

Path safety is checked mechanically: no absolute paths and no `..` segments, in either target or
source. Add operations can only extend the hub under `.km/organization/`; they can never overwrite
canonical files.

## The six forbidden operations

Every profile must carry exactly these six prohibitions. The list is fixed by the contract and
checked by the validator; a profile that omits, alters, or extends it is invalid.

1. `replace_canonical_initializer`. A profile never replaces canonical `km-init`.
2. `copy_canonical_template`. A profile never carries its own copy of the canonical template.
3. `weaken_canonical_governance`. A profile never relaxes canonical governance or scan controls.
4. `replace_generic_agent_instructions`. A profile never replaces the generic agent instructions.
5. `copy_enterprise_records`. A profile never copies enterprise records into a hub.
6. `enable_module_without_eligibility`. A module is enabled only with an eligibility record.

## Module eligibility

Module eligibility is an Enterprise Knowledge Layer decision, recorded per module in the
`eligibility_record` field of the module operation. The Supervisor applies a module only when the
record is present. It does not judge eligibility itself, and a module without a record is an
overreaching operation that rejects the profile.
