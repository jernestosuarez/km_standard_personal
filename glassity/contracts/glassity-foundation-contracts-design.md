---
type: design
title: Glassity foundation contracts — authority matrix and tenant provisioning
description: Approved design for the first app-facing contract slice: record authority, tenant binding, erasure-map instantiation, provisioning receipt, and inbound envelopes.
tags: [glassity, contracts, authority, provisioning, schema, design]
resource: glassity/contracts/
timestamp: 2026-08-28
lifecycle: active
---

# Glassity foundation contracts — authority matrix and tenant provisioning

## Status

Approved by the accountable owner on 2026-08-28 for specification authoring. This document designs the first contract slice only. It does not implement an application, provisioner, adapter, worker, database, repository broker, deletion service, or runtime control. It does not approve production persistence, runtime, release, residual risk, or the legally conditional values in AD-005.

The approved adaptation design requires four app-facing contracts. This slice covers the foundational pair: the authority matrix and tenant hub/provisioning. The cockpit-web and worker contracts remain separate later slices because they depend on the boundaries fixed here.

## Purpose

The contracts give every app builder and agent one machine-testable answer to two questions:

1. Which system is authoritative for each data class, and what representation may cross into the governed Git hub?
2. How is one tenant hub created, bound, and fed without bypassing canonical initialization, tenant isolation, the record boundary, or core `km-intake`?

The repository remains a specification package. Markdown states behavior; JSON Schema Draft 2020-12 fixes structure; synthetic fixtures and a read-only validator prove positive and negative directions. Application models such as Pydantic are deliberately excluded because they would make this repository an app implementation.

## Scope

### In scope

- a normative authority-matrix contract and schema;
- a tenant deployment-binding contract and schema;
- a per-tenant erasure-map schema instantiated by every deployment binding;
- a provisioning-receipt contract and schema;
- an inbound-envelope contract and schema for upload pointers and domain events;
- synthetic valid and invalid fixtures;
- schema validation, cross-document semantic validation, stable failure codes, and mutation canaries; and
- runnable overlay-local specification tests plus the unchanged authoritative release gate.

### Out of scope

- provisioning a real repository or executing `km-init`;
- proving actual Git ancestry or commit signatures;
- dereferencing an object pointer;
- scanning, extracting, classifying, or deleting content;
- implementing tenant IAM/RLS, Git credentials, workers, cockpit behavior, queues, or model calls;
- a filled operator profile or any real tenant binding, policy, content, identifier, credential, or endpoint; and
- runtime conformance evidence under VER-001 through VER-016.

## Package layout

The package implementation uses overlay paths plus one explicitly governed
workflow exception:

```text
glassity/contracts/
├── README.md
├── requirements-test.txt
├── validate_contracts.py
├── authority-matrix/
│   ├── CONTRACT.md
│   ├── authority-matrix.schema.json
│   └── fixtures/
│       ├── valid/
│       └── invalid/
├── tenant-provisioning/
│   ├── CONTRACT.md
│   ├── deployment-binding.schema.json
│   ├── erasure-map.schema.json
│   ├── provisioning-receipt.schema.json
│   ├── inbound-envelope.schema.json
│   └── fixtures/
│       ├── valid/
│       └── invalid/
└── spec_tests/
    └── test_contracts.py

.github/workflows/glassity-contracts.yml
```

All fixtures are visibly synthetic. No filled operator profile ships. Tests run explicitly with:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

The dedicated `.github/workflows/glassity-contracts.yml` workflow installs the
pinned dependency and runs the overlay-local suite. That workflow is the sole
approved protected-path exception. The unchanged core workflow
`.github/workflows/release-gate.yml` runs the unchanged authoritative
`python3 tools/km-release-gate.py` separately, and both lanes must pass.

Full Draft 2020-12 validation uses the declared **development/test-only** dependency `jsonschema==4.25.1`, pinned in `glassity/contracts/requirements-test.txt` and installed with `python3 -m pip install -r glassity/contracts/requirements-test.txt`. `validate_contracts.py` imports `jsonschema.Draft202012Validator`, calls `check_schema` for every shipped schema, and validates every instance with that engine before semantic checks. It does not vendor a validator and does not claim or implement an unstated schema subset. A missing/incompatible dependency fails closed as `DEPENDENCY_MISSING`; it never falls back to shape-only validation. This dependency belongs to specification verification, not the Glassity application runtime.

## Contract 1: authority matrix

The authority matrix is a versioned closed set. A new data class or changed authority mapping requires a governed contract amendment; an unknown row does not pass as an extension.

The matrix contains exactly these required classes and systems of record:

| Data class | System of record | Permitted hub representation |
|---|---|---|
| `raw_upload` | `object_storage` | content-addressed pointer only |
| `app_object` | `application_database` | pointer, digest, claim, or decision |
| `app_event` | `event_store` | pointer, digest, claim, or decision |
| `digest` | `tenant_hub` | governed digest |
| `claim` | `tenant_hub` | governed claim |
| `decision` | `tenant_hub` | governed decision |
| `classified_extract` | `tenant_hub` | bounded classified UTF-8 text extract |
| `pointer` | `tenant_hub` | resolvable, non-secret source pointer |
| `owner_queue` | `tenant_hub` | governed queue record |
| `execution_record` | `tenant_hub` | governed execution record |
| `pending_answer` | `pending_answer_store` | no hub representation until `pull` consumes it |
| `audit_event` | `audit_store` | non-content evidence pointer only, if governed knowledge needs it |

Each row also carries allowed producer roles, permitted inbound-envelope type,
required classification/policy references, retention-policy reference, and
explicitly forbidden locations. `raw_upload`, `app_object`, `app_event`, and
`pending_answer` can never name the tenant hub as their system of record. The
validator rejects missing rows, duplicate rows, extra rows, or any altered field
in a closed authority row. `AUTHORITY_SYSTEM_MISMATCH` names any such complete-row
difference; it is not limited to the `system_of_record` scalar.

## Contract 2: tenant deployment binding

Every provisioned tenant has one binding. The binding contains:

- contract version and binding revision;
- tenant ID and deployment ID;
- canonical commit pin and Glassity overlay revision;
- operator-profile reference, never an embedded filled profile;
- tenant policy references and approval record;
- repository identity and approved ref set, without a credential or clone URL carrying a secret;
- selected operational region;
- lifecycle state;
- orthogonal scoped-legal-hold marker;
- the instantiated per-tenant erasure map; and
- creation/effective timestamps and lifecycle evidence reference.

The `lifecycle` field reuses the AD-005 state vocabulary exactly:

```text
active | frozen | deletion_executing | completion_pending | complete
```

A legal hold is not a sixth lifecycle state. The separate `legal_hold` value is either `null` or a closed object whose status is `scoped` and which names the governed decision reference, non-content scope digest, legal-basis reference, and review date. It is structurally orthogonal and may coexist with any lifecycle value; the governed offboarding procedure determines whether a particular combination is reachable and cannot use the marker to weaken the underlying state. This avoids inventing a parallel state machine.

The binding embeds an `erasure_map` instance conforming to `erasure-map.schema.json`; a mere path to future work is invalid. Every entry includes the AD-005 fields for data class, owning system, tenant/source/lineage selectors, primary and derived locations, freeze control, deletion mechanism, start bound, provider/backup expiry, verification query, restoration/deletion-ledger behavior, non-content evidence, and legal-hold behavior. The required store categories from AD-005 form a closed minimum set. A missing store category is `ERASURE_MAP_INCOMPLETE`, not a warning.

## Contract 3: provisioning receipt

The receipt records the declared two-commit sequence:

1. core `km-init` created the complete canonical hub at `canonical_initialization_commit`;
2. the Glassity provisioner applied the deployment binding and approved overlay at `overlay_commit`; and
3. `overlay_parent_commit` equals `canonical_initialization_commit`.

The receipt includes the tenant and deployment IDs, exact canonical pin,
overlay revision, binding digest, erasure-map digest, actor/service identity,
timestamps, and `proof_level: declared_parent_relationship`. The
`actor_service_id` is evidence of the claimed service identity, not a trusted
assertion that the service is authorized for an allowed producer role; that
mapping requires runtime conformance evidence.

The semantic validator recomputes referenced document digests and requires the declared parent equality. It does **not** prove that either commit exists, that the commit contains the claimed tree, or that the parent relationship is true in Git. Actual ancestry, tree content, commit attribution, and signatures are later Git conformance work. The normative contract and every rendered receipt description must state this limit; the receipt is never described as ancestry proof.

## Contract 4: inbound envelope

One closed envelope schema uses a discriminator with two variants: `upload_pointer` and `domain_event`. Common fields are:

- contract namespace/version and a canonical lowercase UUIDv4 envelope ID;
- tenant and deployment IDs;
- envelope type;
- source-system, object, and immutable version identity;
- actor/service identity and creation time;
- mandatory content-addressed pointer;
- provenance date block;
- classification and policy references;
- declared idempotency key; and
- destination derived as `_inbox/<envelope-id>.json`.

The adapter validates the active deployment binding, authority row, tenant equality, pointer, provenance, idempotency key, and destination before it writes one envelope into `_inbox/`. Nothing in this contract writes directly to `sources/`, promotes governed state, or substitutes for core `km-intake`.

### Content-addressed pointer

The pointer is mandatory for both variants and contains:

- source system;
- source object ID;
- immutable source version ID;
- lowercase SHA-256 of the raw source bytes;
- non-secret resolver reference; and
- storage region or owning-system reference needed for authorization.

The pointer is the only route to the raw object. Its opaque resolver-reference
syntax excludes embedded URL, query, user-info, and common credential forms.
Presigned URLs, bearer tokens, credentials, embedded bytes, binary fields, and
unrestricted HTTP URLs are forbidden. Syntax does not prove that the external
resolver is authorized or secret-free. Dereferencing remains a runtime action
requiring fresh tenant/object authorization under SEC-002 and SEC-015.

### Classified extract

An upload envelope may contain no extract or one classified extract. The extract is governed content, not the raw object, and has this closed shape:

- `content_type: text/plain; charset=utf-8`;
- `content_transfer_encoding: identity`;
- `classification` from the approved vocabulary;
- `text`;
- declared `utf8_byte_length`; and
- declared lowercase SHA-256.

The authoritative size bound is **65,536 UTF-8 bytes per envelope**. The validator encodes the exact decoded JSON string as UTF-8 without Unicode normalization, recomputes its byte length and SHA-256, and compares both declared values. A mismatch produces `EXTRACT_LENGTH_MISMATCH` or `EXTRACT_DIGEST_MISMATCH`; it never trusts the declarations. More than 65,536 bytes produces `EXTRACT_TOO_LARGE`.

The closed object shape rejects binary/blob/data fields and any base64 transfer-encoding declaration. The semantic validator also rejects recognizable `data:*;base64,` payloads. It cannot prove that arbitrary ordinary-looking text was not manually encoded; that limitation is explicit and is not converted into a stronger claim.

### Domain event

A domain-event envelope carries a source pointer and bounded governed assertion material, never the operational event record. Its closed assertion object may carry a digest, claim candidate, decision reference, and classification/policy references. It cannot carry an unrestricted event payload, database row, binary field, or raw record body.

## Deterministic idempotency

The namespace for v1 is:

```text
glassity.inbound-envelope.v1
```

The validator recomputes:

```text
sha256(
  utf8(namespace + NUL + tenant_id + NUL + envelope_type + NUL
       + source_system + NUL + source_object_id + NUL + source_version_id)
)
```

Every tuple field is non-empty and NUL-free. The declared key must be 64 lowercase hexadecimal characters and exactly match the recomputation; otherwise validation returns `IDEMPOTENCY_KEY_MISMATCH`. Actor, arrival time, retry count, classification, and extract text are deliberately excluded, so redelivery of the same immutable source version deduplicates despite transport or actor changes. A changed source must carry a new immutable version ID; a governed correction does not masquerade as redelivery.

The uniqueness scope is the tenant's full retained intake history. At-least-once adapter delivery may repeat an identical envelope, but intake produces at most one governed effect for the tuple. A future derivation change requires a new contract namespace and governed amendment.

## Provenance date gate

`provenance.date_status` is mandatory and uses one of two closed forms:

- `resolved`: requires an ISO `source_date` and `date_kind` of `document`, `event`, or `version`;
- `unknown`: requires a non-empty reason and contains no invented source date.

A missing date block or status is `PROVENANCE_DATE_REQUIRED`. An incomplete resolved form is `PROVENANCE_DATE_INVALID`; an unknown form without its reason is `PROVENANCE_UNKNOWN_REASON_REQUIRED`.

`unknown` is structurally valid because uncertainty is a real source condition, but it forces core intake's date-resolution hold. The source remains in `_inbox/`, intake creates the pending date-resolution item, and nothing is promoted. The adapter never invents a date to obtain a green schema result.

## Path and tenant confinement

The schema constrains `envelope_id` to the canonical lowercase UUIDv4 form, exactly 36 characters and matching `^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`. Any other case, UUID version, separator, prefix, suffix, or length is `ENVELOPE_ID_INVALID`. The destination is not free text: the validator derives `_inbox/<envelope-id>.json` from the already-valid ID and requires the declared destination to equal that value. `UNSAFE_DESTINATION` therefore guards derivation mismatch and defense in depth rather than carrying the entire hostile-ID boundary. Absolute paths, parent segments, empty segments, platform separators, percent-encoded traversal, control characters, symlink targets, alternate Git remotes, and any destination outside `_inbox/` remain invalid.

The authority matrix, deployment binding, erasure map, receipt, and envelope must carry the same tenant and deployment identities where applicable. The validator performs cross-document comparison; matching schema shapes alone are insufficient. A mismatch is always `TENANT_MISMATCH` or `DEPLOYMENT_MISMATCH` and never falls back to a client-supplied value.

## Validation interface and failure behavior

`validate_contracts.py` is a read-only specification validator. It parses JSON, validates each artifact against its Draft 2020-12 schema, then performs the approved cross-document and recomputation rules. It never provisions, mutates, moves, classifies, dereferences, commits, or deletes anything.

Validation exits zero only when all requested artifacts and relationships pass. It exits nonzero on malformed/unreadable input, schema error, unknown fields, missing counterpart, relationship mismatch, digest mismatch, or an internal validation failure. It emits no traceback for invalid input and never returns partial success.

Each failure has a stable reason code. The initial required set is:

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

Messages may add context; fixtures assert the reason code. Changing a code is a contract change.

Reason selection is deterministic. Parse failure is `JSON_INVALID`. The validator maps schema failures at named contract paths to their specific code above before using the `SCHEMA_INVALID` fallback; for example, an absent pointer is `POINTER_REQUIRED`, an absent erasure map is `ERASURE_MAP_INCOMPLETE`, and an absent date block is `PROVENANCE_DATE_REQUIRED`. Semantic relationship and recomputation checks then add their named codes. Codes are emitted once each in the contract-defined order, independent of the JSON Schema engine's error order. Each single-mutation invalid fixture must produce exactly its expected code; multi-defect input may produce several ordered codes but can never return partial success.

## Data flow

```text
approved operator-profile reference
              │
              ▼
complete canonical km-init commit
              │
              ▼
Glassity overlay + deployment binding + erasure map commit
              │
              ▼
declared-only provisioning receipt

source system ──► authority + active binding check
              ──► pointer/provenance/idempotency validation
              ──► _inbox/<envelope-id>.json
              ──► core km-intake
              ──► governed proposal/record after the date gate
```

Any failure before `_inbox/` produces no hub write. Arrival in `_inbox/` is the request to run intake, not an owner decision. Only the resulting proposal waits for owner authority where the Standard requires it.

## Verification design

### Positive fixtures

- the complete authority matrix;
- an active binding with a complete synthetic erasure map and no hold;
- a frozen binding with a scoped hold, proving the fields are orthogonal;
- a declared two-commit receipt with matching recomputed document digests;
- an upload-pointer envelope without an extract;
- an upload-pointer envelope with a short classified extract;
- a domain-event envelope with a resolved event date; and
- an envelope with `date_status: unknown` that validates structurally and is marked for intake hold.

### Negative fixtures and mutation canaries

Every invalid fixture names its expected reason code. At minimum the suite mutates a valid baseline to prove rejection of:

- missing, duplicate, extra, or remapped authority rows;
- raw uploads, app records, or pending answers assigned to Git;
- a missing store in the instantiated erasure map;
- a lifecycle value outside AD-005 or a blanket legal hold;
- tenant or deployment mismatch between any two artifacts;
- an overlay parent declaration unequal to the canonical initialization commit;
- a receipt description that claims actual Git ancestry proof;
- a changed binding or erasure-map digest;
- a missing pointer or embedded raw/blob/binary/data field;
- a mixed-case, non-v4, overlong, prefixed, suffixed, or otherwise non-canonical envelope ID;
- direct `sources/`, absolute, parent-relative, encoded-traversal, or alternate-separator destinations;
- an extract over 65,536 UTF-8 bytes;
- binary/base64 encoding declarations and recognizable base64 data URIs;
- a one-byte extract mutation with the old digest;
- a false extract byte length;
- a one-field idempotency-tuple mutation with the old key;
- a declared idempotency key that was not recomputed;
- a missing provenance date block;
- a resolved date with invalid shape; and
- an unknown date without a reason.

The negative direction is the reason, not merely a nonzero exit. A canary that produces the wrong reason fails.

### Required commands

The later implementation is accepted only after both commands run directly and report exit status zero:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
python3 tools/km-release-gate.py
```

The first proves the overlay contracts. The second proves only what the core release gate says it proves; neither substitutes for later runtime/Git conformance.

## Security and governance traceability

- Authority and tenant comparisons bind SEC-002 and VER-002/012.
- `_inbox/` confinement and path canaries bind SEC-003 and VER-003.
- Pointer minimization and raw-content exclusion bind SEC-006/015 and VER-005/012.
- Idempotency recomputation binds SEC-014 and VER-011.
- Binding lifecycle and erasure-map completeness bind SEC-019 and VER-016.
- Receipt attribution fields prepare SEC-005/013 and VER-004/010 without claiming conformance.
- The extract limit contributes to SEC-016; it does not replace AD-003 upload limits or malware scanning.

All examples remain synthetic. No customer or prospect content, derived excerpt, organization profile, credential, endpoint, or personal name enters this package.

## Alternatives rejected

### Markdown-only contracts

Rejected because prose alone cannot exercise required fields, recomputations, path confinement, or negative fixtures and would fail the approved specification-check requirement.

### Application models in this repository

Rejected because Pydantic or app-domain classes would select a runtime implementation and turn a specification package into app code. The app may later generate or hand-write its own models against the schemas.

### One contract bundle for all four app surfaces

Rejected because cockpit and worker behavior are independent subsystems with different threat boundaries. Bundling them would make review and failure isolation harder and would delay the foundational authority and provisioning interfaces.

### Authority matrix only

Rejected because it would state where data belongs without proving the first operational boundary that uses it. Pairing it with provisioning and inbound envelopes produces one coherent, testable slice while still excluding runtime code.

## Acceptance criteria for the specification implementation

The future implementation plan must demonstrate all of the following before this slice can be accepted:

1. Every planned artifact exists under `glassity/contracts/`; protected core
   files remain unchanged except for the sole approved new workflow
   `.github/workflows/glassity-contracts.yml`.
2. All schemas are Draft 2020-12, closed by default, checked and exercised with the pinned dev-only `jsonschema==4.25.1` `Draft202012Validator`, and covered by synthetic positive and negative fixtures; no subset or fallback is claimed.
3. The validator recomputes—not trusts—the inbound idempotency key, extract UTF-8 byte length, extract digest, binding digest, and erasure-map digest.
4. The authority matrix enforces the exact record boundary.
5. Every deployment binding instantiates the complete per-tenant erasure map and reuses the AD-005 lifecycle vocabulary with an orthogonal scoped hold.
6. The provisioning receipt declares the required commit order and visibly disclaims actual Git proof.
7. Envelope IDs are canonical lowercase UUIDv4 values, and `_inbox/<envelope-id>.json` is recomputed rather than trusted.
8. Upload extracts are optional, classified, identity-encoded UTF-8 text and no larger than 65,536 bytes; the raw object is available only through its mandatory pointer.
9. Idempotency scope and derivation are deterministic and mutation-tested.
10. Provenance always carries a resolved or explicitly unknown date state; unknown dates force the intake hold.
11. All invalid fixtures assert a stable reason code, and mutation canaries prove the validator can fail for that reason.
12. The overlay contract suite and authoritative release gate each run directly and exit zero.
13. The evidence report states that schemas and receipts do not prove runtime
    tenant isolation, actual Git ancestry, content scanning, resolver or
    producer-role authorization, dereference authorization, or deletion
    conformance.

## Next step after approval of this written specification

The foundation-contract implementation and its approved corrective design are
now implemented on the review branch. Supervisor review remains the hard stop
before push or implementation acceptance. Cockpit-web and worker contracts
remain separate design/specification cycles.
