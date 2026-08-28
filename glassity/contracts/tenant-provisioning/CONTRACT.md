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

Digest declarations are also recomputed rather than trusted. `binding_sha256` is the lowercase SHA-256 of the deployment-binding file's exact bytes, including its serialized whitespace and final newline. `erasure_map_sha256` is the lowercase SHA-256 of the embedded erasure-map object serialized as compact JSON with keys sorted lexicographically, UTF-8 output, no ASCII escaping, separators `,` and `:`, and no Unicode normalization. A mismatch is `PROVISIONING_DIGEST_MISMATCH`. These digest checks bind a receipt to the supplied artifacts; they do not prove Git ancestry or commit contents.

## Inbound envelope

The inbound envelope is a closed, synthetic specification boundary with two variants: `upload_pointer` and `domain_event`. Both variants carry the same tenant and deployment identities as the active deployment binding, a canonical lowercase UUIDv4 envelope ID, actor and creation evidence, provenance, classification-policy references, an idempotency key, and a mandatory content-addressed `source` pointer. The pointer contains only `system`, `object_id`, immutable `version_id`, lowercase raw-content SHA-256, a non-secret `resolver_ref`, and `owning_region_or_system`. HTTP(S) resolver URLs, credentials, presigned URLs, bearer tokens, raw bytes, blobs, binary fields, data fields, and unrestricted payload fields are forbidden. The pointer is the only route to raw source content; this contract never dereferences it.

An upload may include one classified extract. It is exactly identity-encoded `text/plain; charset=utf-8`, carries its classification and policy reference, and is limited to 65,536 bytes after encoding the decoded JSON string as UTF-8 without Unicode normalization. The validator recomputes both `utf8_byte_length` and SHA-256 from those exact bytes. A recognizable `data:*;base64,` URI is rejected case-insensitively. Closed fields and the transfer-encoding rule exclude declared binary/base64 payloads, but the validator cannot prove that ordinary-looking text was not manually encoded; it makes no stronger claim. A domain event carries only its pointer and the closed `domain_assertion` fields; it never carries the operational event record.

The v1 idempotency key is the lowercase SHA-256 of the UTF-8 encoding of `glassity.inbound-envelope.v1`, tenant ID, envelope type, source system, source object ID, and source version ID joined in that order by NUL bytes. Every tuple field is non-empty and NUL-free, and the validator recomputes rather than trusts the declared key. The uniqueness scope is the tenant's retained intake history.

`provenance.date_status` is mandatory. `resolved` requires a real ISO calendar `source_date` and a `date_kind` of `document`, `event`, or `version`. `unknown` requires a non-empty reason, is structurally valid, and sets `intake_hold_required`; it never invents a date or permits promotion. The destination is recomputed as `_inbox/<envelope-id>.json`. Any other path is unsafe, and nothing in this contract writes directly to `sources/` or promotes governed state. Authority, tenant, deployment, and every classification-policy reference are checked against the authority matrix and binding before the envelope is accepted.

The envelope ID is exactly 36 characters and matches canonical lowercase UUIDv4 pattern `^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`; any other form is `ENVELOPE_ID_INVALID`. Only after that check does the validator derive the destination. A declared destination unequal to the exact `_inbox/<envelope-id>.json` derivation is `UNSAFE_DESTINATION`. The schema and recomputation reject absolute paths, parent traversal, alternate separators, prefixes, suffixes, control characters, percent-encoded traversal, and destinations such as `sources/` by construction and defense in depth.

The authority matrix, binding, embedded erasure map, receipt, and envelope must carry the same tenant and deployment identities wherever those identities apply. The binding must be `active` to accept an envelope. Cross-document values are compared server-side by the validator; no artifact can establish a different tenant or deployment merely by being internally schema-valid.

This contract defines specification artifacts only. It does not provision a tenant, operate a repository, execute deletion, dereference a source, promote governed state, or prove runtime isolation or erasure conformance.

## Stable validation reasons

The validator emits tab-separated `REASON_CODE`, JSON Pointer, and contextual message fields. Codes are ordered deterministically and emitted at most once each. Messages may change to add context; codes are stable contract values, and changing one requires a governed amendment.

The initial package-wide reason set is:

```text
JSON_INVALID
DEPENDENCY_MISSING
SCHEMA_INVALID
AUTHORITY_SET_INCOMPLETE
AUTHORITY_SET_UNKNOWN
AUTHORITY_SYSTEM_MISMATCH
TENANT_MISMATCH
DEPLOYMENT_MISMATCH
ERASURE_MAP_INCOMPLETE
PROVISIONING_ORDER_INVALID
PROVISIONING_DIGEST_MISMATCH
POINTER_REQUIRED
RAW_CONTENT_FORBIDDEN
ENVELOPE_ID_INVALID
UNSAFE_DESTINATION
EXTRACT_ENCODING_FORBIDDEN
EXTRACT_TOO_LARGE
EXTRACT_LENGTH_MISMATCH
EXTRACT_DIGEST_MISMATCH
IDEMPOTENCY_KEY_MISMATCH
PROVENANCE_DATE_REQUIRED
PROVENANCE_DATE_INVALID
PROVENANCE_UNKNOWN_REASON_REQUIRED
```

Parse failures take precedence as `JSON_INVALID`. Named schema paths are mapped to their specific contract code before the `SCHEMA_INVALID` fallback. Semantic relationship and recomputation checks then add their named codes. A single-mutation canary must fail for exactly its declared reason; multi-defect input may produce several ordered reasons but never partial success.

## Security and governance traceability

- Authority and tenant comparisons bind SEC-002 and VER-002/012.
- `_inbox/` confinement and path canaries bind SEC-003 and VER-003.
- Pointer minimization and raw-content exclusion bind SEC-006/015 and VER-005/012.
- Receipt attribution fields prepare SEC-005/013 and VER-004/010 without claiming conformance.
- Idempotency recomputation binds SEC-014 and VER-011.
- The extract bound contributes to SEC-016, but does not replace AD-003 upload-volume limits or content scanning.
- Lifecycle and erasure-map completeness bind SEC-019 and VER-016, but schema validity does not prove that deletion occurred.

These bindings show which approved controls shaped the contracts. They are not runtime conformance evidence for any SEC or VER item.
