---
title: Glassity tenant provisioning contract
description: Normative tenant binding, erasure-map, receipt, and inbound-envelope boundary.
tags: [glassity, contracts, provisioning]
---

# Glassity tenant provisioning contract

## Deployment binding

Every tenant deployment has one versioned binding. It pins the canonical Standard commit and approved Glassity overlay, refers to rather than embeds the operator profile and tenant policies, identifies the repository and approved refs without a credential-bearing URL, fixes the operational region, and records lifecycle evidence.

The lifecycle vocabulary is exactly `active`, `frozen`, `deletion_executing`, `completion_pending`, and `complete`. A legal hold is a separate scoped marker, not a lifecycle state. It may coexist with any lifecycle value and never restores or weakens access prohibited by that lifecycle.

## Per-tenant erasure map

Every binding embeds a complete erasure map. The required categories are `iam_session`, `worker_transient`, `pending_answer_queue`, `app_database_event`, `derived_projection_index`, `s3_object_version`, `github_repository`, `backup_recovery`, `scan_event_finding`, `audit_log`, `anthropic_control_plane`, `export_staging`, and `tenant_secret`.

Each entry identifies its data classes, owning system, tenant/source/lineage selectors, primary or derived locations, freeze control, deletion mechanism and start bound, provider or backup expiry, verification query, restore-time deletion-ledger behavior, non-content evidence, and scoped legal-hold behavior. Missing, duplicate, or unknown categories make the map incomplete. The embedded map must carry the binding's tenant and deployment identities.

## Provisioning receipt

The provisioning receipt records the declared two-commit sequence: core `km-init` creates the complete canonical hub, then the Glassity provisioner applies the deployment binding and approved overlay. Its `overlay_parent_commit` must equal its `canonical_initialization_commit`; its tenant, deployment, canonical pin, and overlay revision must match the binding; and its binding and embedded erasure-map digests are recomputed rather than trusted.

This is a **declared parent relationship**, not evidence that either commit exists or that one commit is an ancestor of the other. The validator never shells out to Git and does not inspect repository objects, trees, attribution, or signatures. Actual Git ancestry and commit contents remain later conformance work.

## Inbound envelope

The inbound envelope is a closed, synthetic specification boundary with two variants: `upload_pointer` and `domain_event`. Both variants carry the same tenant and deployment identities as the active deployment binding, a canonical lowercase UUIDv4 envelope ID, actor and creation evidence, provenance, classification-policy references, an idempotency key, and a mandatory content-addressed `source` pointer. The pointer contains only `system`, `object_id`, immutable `version_id`, lowercase raw-content SHA-256, a non-secret `resolver_ref`, and `owning_region_or_system`. HTTP(S) resolver URLs, credentials, presigned URLs, bearer tokens, raw bytes, blobs, binary fields, data fields, and unrestricted payload fields are forbidden. The pointer is the only route to raw source content; this contract never dereferences it.

An upload may include one classified extract. It is exactly identity-encoded `text/plain; charset=utf-8`, carries its classification and policy reference, and is limited to 65,536 bytes after encoding the decoded JSON string as UTF-8 without Unicode normalization. The validator recomputes both `utf8_byte_length` and SHA-256 from those exact bytes. A recognizable `data:*;base64,` URI is rejected case-insensitively. Closed fields and the transfer-encoding rule exclude declared binary/base64 payloads, but the validator cannot prove that ordinary-looking text was not manually encoded; it makes no stronger claim. A domain event carries only its pointer and the closed `domain_assertion` fields; it never carries the operational event record.

The v1 idempotency key is the lowercase SHA-256 of the UTF-8 encoding of `glassity.inbound-envelope.v1`, tenant ID, envelope type, source system, source object ID, and source version ID joined in that order by NUL bytes. Every tuple field is non-empty and NUL-free, and the validator recomputes rather than trusts the declared key. The uniqueness scope is the tenant's retained intake history.

`provenance.date_status` is mandatory. `resolved` requires a real ISO calendar `source_date` and a `date_kind` of `document`, `event`, or `version`. `unknown` requires a non-empty reason, is structurally valid, and sets `intake_hold_required`; it never invents a date or permits promotion. The destination is recomputed as `_inbox/<envelope-id>.json`. Any other path is unsafe, and nothing in this contract writes directly to `sources/` or promotes governed state. Authority, tenant, deployment, and every classification-policy reference are checked against the authority matrix and binding before the envelope is accepted.

This contract defines specification artifacts only. It does not provision a tenant, operate a repository, execute deletion, dereference a source, promote governed state, or prove runtime isolation or erasure conformance.
