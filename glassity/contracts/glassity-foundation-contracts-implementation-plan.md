# Glassity Foundation Contracts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the machine-testable authority-matrix and tenant-provisioning specification package approved in `glassity-foundation-contracts-design.md`, without adding application or runtime implementation.

**Architecture:** All package work stays under `glassity/contracts/`, with the
sole approved protected-path exception
`.github/workflows/glassity-contracts.yml`. JSON Schema Draft 2020-12 fixes
artifact shape, a pinned dev-only `jsonschema` engine performs full schema
validation, and one read-only Python validator performs cross-document
comparisons and digest/key recomputation. Synthetic baseline fixtures plus
data-driven single-mutation cases prove both acceptance and named failure
reasons; the dedicated overlay workflow and unchanged core workflow/gate remain
separate required lanes.

**Tech Stack:** Python 3.9, `unittest`, `jsonschema==4.25.1`, `referencing` as jsonschema's installed dependency, JSON Schema Draft 2020-12, JSON, Markdown, Git.

---

## Execution boundary and fixed decisions

- Start from synchronized commit `29c8307d0b98d2859f34d140414b160883339c06`.
- Modify only `glassity/contracts/`, except for the approved new workflow
  `.github/workflows/glassity-contracts.yml`. Any other changed path is a refusal.
- Do not implement provisioning, Git operations, object dereference, classification, scanning, deletion, IAM/RLS, queues, workers, cockpit behavior, or model calls.
- Use `jsonschema.Draft202012Validator`; do not replace it with a hand-written schema subset.
- The binding digest is SHA-256 of the exact UTF-8 bytes of the binding JSON file.
- The embedded erasure-map digest is SHA-256 of deterministic JSON bytes produced by `json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")`; no Unicode normalization is applied.
- The extract digest is SHA-256 of the exact decoded JSON string encoded as UTF-8 without Unicode normalization.
- The envelope idempotency derivation and UUIDv4 pattern are copied exactly from the approved design.
- Every task stages named paths only. Never use a blanket Git add.

## Final file map

| File | Responsibility |
|---|---|
| `glassity/contracts/README.md` | Package purpose, dependency installation, commands, and proof limits. |
| `glassity/contracts/requirements-test.txt` | Exact dev/test schema-validator dependency. |
| `glassity/contracts/validate_contracts.py` | Read-only CLI, schema engine, stable issues, semantic checks, and recomputations. |
| `glassity/contracts/authority-matrix/CONTRACT.md` | Normative record-authority behavior. |
| `glassity/contracts/authority-matrix/authority-matrix.schema.json` | Closed authority-matrix shape. |
| `glassity/contracts/authority-matrix/fixtures/valid/authority-matrix.json` | Complete synthetic authority baseline. |
| `glassity/contracts/authority-matrix/fixtures/invalid/cases.json` | Named authority mutations and expected codes. |
| `glassity/contracts/tenant-provisioning/CONTRACT.md` | Normative binding, receipt, envelope, and ancestry-limit behavior. |
| `glassity/contracts/tenant-provisioning/deployment-binding.schema.json` | Closed tenant binding and AD-005 lifecycle shape. |
| `glassity/contracts/tenant-provisioning/erasure-map.schema.json` | Closed instantiated per-tenant erasure map. |
| `glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json` | Closed declared two-commit receipt. |
| `glassity/contracts/tenant-provisioning/inbound-envelope.schema.json` | Closed upload/domain-event envelope variants. |
| `glassity/contracts/tenant-provisioning/fixtures/valid/*.json` | Synthetic binding, receipt, and envelope baselines. |
| `glassity/contracts/tenant-provisioning/fixtures/invalid/cases.json` | Named provisioning/envelope mutations and expected codes. |
| `glassity/contracts/spec_tests/test_contracts.py` | Dependency, schema, semantic, recomputation, and mutation canaries. |
| `glassity/contracts/VERIFICATION.md` | Commands, scope, and explicit proof limits; it does not claim a run occurred. |
| `.github/workflows/glassity-contracts.yml` | Pinned dedicated Glassity verification lane; sole protected-path exception. |

## Public validator interface

The implementation exposes these functions for tests and the CLI:

```text
Issue(code: str, path: str, message: str) — immutable validation issue
EnvelopeValidation(issues: list[Issue], intake_hold_required: bool) — envelope result
canonical_json_bytes(value: object) -> bytes
sha256_hex(value: bytes) -> str
expected_idempotency_key(envelope: dict) -> str
load_json(path: Path) -> tuple[Optional[object], list[Issue]]
load_schemas(root: Path) -> tuple[dict[str, dict], object, list[Issue]]
validate_schema(kind: str, value: object, schemas: dict, registry: object) -> list[Issue]
validate_authority_matrix(value: dict) -> list[Issue]
validate_binding(value: dict) -> list[Issue]
validate_receipt(value: dict, binding_bytes: bytes, binding: dict) -> list[Issue]
validate_envelope(value: dict, authority: dict, binding: dict) -> EnvelopeValidation
validate_bundle(authority_path: Path, binding_path: Path, receipt_path: Path,
                envelope_paths: list[Path]) -> list[Issue]
```

The implementation imports `Optional` from `typing`; it must remain valid Python 3.9 syntax.

The CLI forms are:

```text
python3 glassity/contracts/validate_contracts.py --self-check
python3 glassity/contracts/validate_contracts.py bundle \
  --authority <authority.json> \
  --binding <binding.json> \
  --receipt <receipt.json> \
  --envelope <first-envelope.json> \
  --envelope <second-envelope.json>
```

Issues print as `CODE<TAB>JSON_POINTER<TAB>message`, once per code in the contract-defined order. Exit `0` means no issues; exit `1` means invalid input or missing dependency; exit `2` is reserved for CLI usage errors.

### Task 1: Pin the schema engine and establish the fail-closed CLI

**Files:**
- Create: `glassity/contracts/requirements-test.txt`
- Create: `glassity/contracts/README.md`
- Create: `glassity/contracts/validate_contracts.py`
- Create: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Write the dependency and CLI tests first**

Create the test module with the loader and these tests:

```python
import importlib.util
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTRACTS = ROOT / "glassity" / "contracts"
VALIDATOR = CONTRACTS / "validate_contracts.py"


def load_validator():
    spec = importlib.util.spec_from_file_location("glassity_contract_validator", VALIDATOR)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class DependencyAndCliTests(unittest.TestCase):
    def test_self_check_uses_draft_2020_12(self):
        result = subprocess.run(
            [sys.executable, str(VALIDATOR), "--self-check"],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "VALID Draft202012Validator jsonschema==4.25.1")

    def test_missing_dependency_fails_closed(self):
        result = subprocess.run(
            [sys.executable, "-S", str(VALIDATOR), "--self-check"],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("DEPENDENCY_MISSING", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
```

- [ ] **Step 2: Run the focused tests and verify red**

Run:

```bash
python3 -m unittest glassity/contracts/spec_tests/test_contracts.py -v
```

Expected: both tests fail because `validate_contracts.py` does not exist.

- [ ] **Step 3: Add the pinned dependency and minimal validator**

`requirements-test.txt` contains exactly:

```text
jsonschema==4.25.1
```

Start `validate_contracts.py` with:

```python
#!/usr/bin/env python3
import argparse
from dataclasses import dataclass
from importlib import metadata
from pathlib import Path
import sys


REASON_ORDER = (
    "JSON_INVALID", "DEPENDENCY_MISSING", "SCHEMA_INVALID",
    "AUTHORITY_SET_INCOMPLETE", "AUTHORITY_SET_UNKNOWN", "AUTHORITY_SYSTEM_MISMATCH",
    "TENANT_MISMATCH", "DEPLOYMENT_MISMATCH", "ERASURE_MAP_INCOMPLETE",
    "PROVISIONING_ORDER_INVALID", "PROVISIONING_DIGEST_MISMATCH", "POINTER_REQUIRED",
    "RAW_CONTENT_FORBIDDEN", "ENVELOPE_ID_INVALID", "UNSAFE_DESTINATION",
    "EXTRACT_ENCODING_FORBIDDEN", "EXTRACT_TOO_LARGE", "EXTRACT_LENGTH_MISMATCH",
    "EXTRACT_DIGEST_MISMATCH", "IDEMPOTENCY_KEY_MISMATCH", "PROVENANCE_DATE_REQUIRED",
    "PROVENANCE_DATE_INVALID", "PROVENANCE_UNKNOWN_REASON_REQUIRED",
)


@dataclass(frozen=True)
class Issue:
    code: str
    path: str
    message: str


def schema_runtime():
    try:
        from jsonschema import Draft202012Validator
        from referencing import Registry, Resource
    except ImportError:
        return None
    if metadata.version("jsonschema") != "4.25.1":
        return None
    return Draft202012Validator, Registry, Resource


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-check", action="store_true")
    args = parser.parse_args(argv)
    runtime = schema_runtime()
    if runtime is None:
        print("DEPENDENCY_MISSING\t/\tjsonschema==4.25.1 is required", file=sys.stderr)
        return 1
    if args.self_check:
        print("VALID Draft202012Validator jsonschema==4.25.1")
        return 0
    parser.error("bundle command is required")


if __name__ == "__main__":
    raise SystemExit(main())
```

The initial `README.md` states that this is a specification validator, lists the dependency install command, and says it never mutates a hub or proves runtime behavior.

- [ ] **Step 4: Run the focused tests and verify green**

Run the same unittest command. Expected: `Ran 2 tests` and `OK`.

- [ ] **Step 5: Commit the scaffold**

```bash
git add -- glassity/contracts/requirements-test.txt glassity/contracts/README.md \
  glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: pin schema validation runtime"
```

### Task 2: Implement the closed authority matrix

**Files:**
- Create: `glassity/contracts/authority-matrix/CONTRACT.md`
- Create: `glassity/contracts/authority-matrix/authority-matrix.schema.json`
- Create: `glassity/contracts/authority-matrix/fixtures/valid/authority-matrix.json`
- Create: `glassity/contracts/authority-matrix/fixtures/invalid/cases.json`
- Modify: `glassity/contracts/validate_contracts.py`
- Modify: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add red tests for schema checking and the exact authority set**

Add tests that load the valid matrix, call `load_schemas(CONTRACTS)`, `validate_schema("authority", matrix, schemas, registry)`, and `validate_authority_matrix(matrix)`. Assert no issues. Then remove `raw_upload`, append an `unknown_class`, and change `pending_answer.system_of_record` to `tenant_hub`; assert exactly `AUTHORITY_SET_INCOMPLETE`, `AUTHORITY_SET_UNKNOWN`, and `AUTHORITY_SYSTEM_MISMATCH` respectively.

The required semantic constants are:

```python
AUTHORITY = {
    "raw_upload": ("object_storage", {"pointer"}),
    "app_object": ("application_database", {"pointer", "digest", "claim", "decision"}),
    "app_event": ("event_store", {"pointer", "digest", "claim", "decision"}),
    "digest": ("tenant_hub", {"governed_digest"}),
    "claim": ("tenant_hub", {"governed_claim"}),
    "decision": ("tenant_hub", {"governed_decision"}),
    "classified_extract": ("tenant_hub", {"classified_text_extract"}),
    "pointer": ("tenant_hub", {"resolvable_pointer"}),
    "owner_queue": ("tenant_hub", {"governed_queue_record"}),
    "execution_record": ("tenant_hub", {"governed_execution_record"}),
    "pending_answer": ("pending_answer_store", {"none_until_pull"}),
    "audit_event": ("audit_store", {"non_content_evidence_pointer"}),
}
```

- [ ] **Step 2: Run the new authority tests and verify red**

Expected: failure because the schema, fixture, loader, and semantic validator are absent.

- [ ] **Step 3: Create the authority schema and baseline fixture**

The schema is Draft 2020-12, `additionalProperties: false` at every object, and requires:

```json
{
  "schema_version": "1.0",
  "matrix_id": "urn:glassity:synthetic:authority-matrix:v1",
  "revision": "1",
  "rows": [
    {
      "data_class": "raw_upload",
      "system_of_record": "object_storage",
      "hub_representations": ["pointer"],
      "allowed_producers": ["inbound_adapter"],
      "envelope_types": ["upload_pointer"],
      "classification_policy_refs": ["urn:glassity:synthetic:policy:classification"],
      "retention_policy_ref": "urn:glassity:synthetic:policy:retention",
      "forbidden_locations": ["tenant_hub", "pending_answer_store"]
    }
  ]
}
```

Repeat the row using the exact `AUTHORITY` mapping for all twelve classes. Use only these producer values: `inbound_adapter`, `core_intake`, `cockpit`, `worker`, `audit_service`; and envelope values: `upload_pointer`, `domain_event`, `none`. Arrays are unique and non-empty except where the contract explicitly permits `none`.

- [ ] **Step 4: Add schema registry and authority semantics**

Implement `load_json`, `load_schemas`, and `validate_schema` using `Draft202012Validator.check_schema` and a `referencing.Registry`. Implement `validate_authority_matrix` by indexing rows, comparing exact key sets, system-of-record values, and permitted representations. Return sorted unique `Issue` objects using `REASON_ORDER`; never rely on schema-engine error order.

- [ ] **Step 5: Add the authority contract and invalid-case descriptors**

`CONTRACT.md` copies the exact authority table and states amendment-only extension. `cases.json` contains descriptors with `case_id`, `artifact`, `operation`, `path`, optional `value`, and `expected_reason` for missing, extra, duplicate, and remapped rows.

- [ ] **Step 6: Run authority tests and verify green**

Expected: all dependency and authority tests pass.

- [ ] **Step 7: Commit the authority contract**

```bash
git add -- glassity/contracts/authority-matrix glassity/contracts/validate_contracts.py \
  glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: define record authority matrix"
```

### Task 3: Implement the erasure map and deployment binding

**Files:**
- Create: `glassity/contracts/tenant-provisioning/CONTRACT.md`
- Create: `glassity/contracts/tenant-provisioning/erasure-map.schema.json`
- Create: `glassity/contracts/tenant-provisioning/deployment-binding.schema.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/deployment-binding.json`
- Modify: `glassity/contracts/validate_contracts.py`
- Modify: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add red binding and erasure-map tests**

Test a valid `active` binding with `legal_hold: null`, then a `frozen` copy with a scoped hold. Mutate lifecycle to `paused`, remove one erasure category, remove the embedded erasure map, and set a blanket hold without a scope digest. Assert `SCHEMA_INVALID`, `ERASURE_MAP_INCOMPLETE`, `ERASURE_MAP_INCOMPLETE`, and `SCHEMA_INVALID` respectively.

- [ ] **Step 2: Run the binding tests and verify red**

Expected: missing schemas and fixture.

- [ ] **Step 3: Create the erasure-map schema**

Require one entry for each semantic category:

```python
ERASURE_CATEGORIES = {
    "iam_session", "worker_transient", "pending_answer_queue", "app_database_event",
    "derived_projection_index", "s3_object_version", "github_repository",
    "backup_recovery", "scan_event_finding", "audit_log", "anthropic_control_plane",
    "export_staging", "tenant_secret",
}
```

Each closed entry requires `category`, `data_classes`, `owning_system`, `selectors`, `locations`, `freeze_control`, `deletion_mechanism`, `deletion_start_bound`, `provider_backup_expiry`, `verification_query`, `restore_deletion_ledger`, `non_content_evidence`, and `legal_hold_behavior`. The map requires `schema_version`, `map_id`, `revision`, `tenant_id`, `deployment_id`, and `entries`.

- [ ] **Step 4: Create the deployment-binding schema and fixture**

Require `schema_version`, `binding_id`, `binding_revision`, `tenant_id`, `deployment_id`, `canonical_commit`, `overlay_revision`, `operator_profile_ref`, `tenant_policy_refs`, `approval_record`, `repository`, `operational_region`, `lifecycle`, `legal_hold`, `erasure_map`, `created_at`, `effective_at`, and `lifecycle_evidence_ref`.

Use the exact lifecycle enum:

```json
["active", "frozen", "deletion_executing", "completion_pending", "complete"]
```

`legal_hold` is `null` or a closed object requiring `status: scoped`, `decision_ref`, `scope_digest`, `legal_basis_ref`, and ISO `review_date`. Reference the erasure schema by its absolute `$id` and register both schemas before instance validation.

- [ ] **Step 5: Implement binding semantics**

`validate_binding` checks exact erasure categories, tenant/deployment equality between binding and map, duplicate categories, and that the scoped marker never weakens lifecycle. Do not reject a scoped hold solely because of the lifecycle value; orthogonality is structural.

- [ ] **Step 6: Run binding tests and verify green**

Expected: valid active/frozen cases pass and each single mutation returns its named reason.

- [ ] **Step 7: Commit binding and erasure contracts**

```bash
git add -- glassity/contracts/tenant-provisioning/CONTRACT.md \
  glassity/contracts/tenant-provisioning/erasure-map.schema.json \
  glassity/contracts/tenant-provisioning/deployment-binding.schema.json \
  glassity/contracts/tenant-provisioning/fixtures/valid/deployment-binding.json \
  glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: define tenant binding and erasure map"
```

### Task 4: Implement the declared provisioning receipt

**Files:**
- Create: `glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/provisioning-receipt.json`
- Modify: `glassity/contracts/tenant-provisioning/CONTRACT.md`
- Modify: `glassity/contracts/validate_contracts.py`
- Modify: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add red receipt recomputation tests**

Load binding bytes and its embedded erasure map. Assert the valid receipt passes. Change `overlay_parent_commit`, `binding_sha256`, `erasure_map_sha256`, and `proof_level`; assert `PROVISIONING_ORDER_INVALID`, `PROVISIONING_DIGEST_MISMATCH`, `PROVISIONING_DIGEST_MISMATCH`, and `SCHEMA_INVALID`.

- [ ] **Step 2: Run receipt tests and verify red**

Expected: missing schema, fixture, and validator function.

- [ ] **Step 3: Create the receipt schema and synthetic fixture**

Require `schema_version`, `receipt_id`, `tenant_id`, `deployment_id`, `canonical_pin`, `canonical_initialization_commit`, `overlay_revision`, `overlay_parent_commit`, `overlay_commit`, `binding_sha256`, `erasure_map_sha256`, `actor_service_id`, `initialized_at`, `overlay_applied_at`, and `proof_level`. Commit fields are lowercase 40-hex SHA-1 identifiers because the pinned repository currently uses SHA-1 object format. `proof_level` is the constant `declared_parent_relationship`.

- [ ] **Step 4: Implement exact digest and order checks**

Add:

```python
import hashlib
import json


def canonical_json_bytes(value):
    return json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")


def sha256_hex(value):
    return hashlib.sha256(value).hexdigest()
```

`validate_receipt` compares tenant/deployment/canonical values, requires `overlay_parent_commit == canonical_initialization_commit`, compares `binding_sha256` with exact binding-file bytes, and compares `erasure_map_sha256` with `canonical_json_bytes(binding["erasure_map"])`.

- [ ] **Step 5: State the proof limit in every receipt surface**

Add a receipt section to `CONTRACT.md`: the declaration is not evidence that commits exist or are ancestors. The validator never shells out to Git. The schema's title/description and README use “declared parent relationship,” never “ancestry proof.”

- [ ] **Step 6: Run receipt tests and verify green**

Expected: all receipt mutations return their exact reason.

- [ ] **Step 7: Commit the receipt contract**

```bash
git add -- glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json \
  glassity/contracts/tenant-provisioning/fixtures/valid/provisioning-receipt.json \
  glassity/contracts/tenant-provisioning/CONTRACT.md \
  glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: define provisioning receipt"
```

### Task 5: Implement upload and domain-event envelopes

**Files:**
- Create: `glassity/contracts/tenant-provisioning/inbound-envelope.schema.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/upload-pointer.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/upload-pointer-with-extract.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/domain-event.json`
- Create: `glassity/contracts/tenant-provisioning/fixtures/valid/unknown-date.json`
- Modify: `glassity/contracts/tenant-provisioning/CONTRACT.md`
- Modify: `glassity/contracts/validate_contracts.py`
- Modify: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add red tests for the four valid variants**

For each fixture, validate schema and semantics against the valid authority matrix and binding. Assert `result.issues == []`. For `unknown-date.json`, additionally assert `result.intake_hold_required is True` without treating the artifact as invalid.

- [ ] **Step 2: Add red recomputation and path tests**

Mutate one field at a time and assert:

```text
uppercase/non-v4 envelope_id       -> ENVELOPE_ID_INVALID
destination mismatch               -> UNSAFE_DESTINATION
missing pointer                    -> POINTER_REQUIRED
embedded raw_content               -> RAW_CONTENT_FORBIDDEN
extract content_transfer_encoding  -> EXTRACT_ENCODING_FORBIDDEN
65,537 UTF-8 bytes                 -> EXTRACT_TOO_LARGE
false utf8_byte_length             -> EXTRACT_LENGTH_MISMATCH
one-byte text change, old digest   -> EXTRACT_DIGEST_MISMATCH
one tuple field, old key           -> IDEMPOTENCY_KEY_MISMATCH
missing provenance                 -> PROVENANCE_DATE_REQUIRED
invalid resolved date              -> PROVENANCE_DATE_INVALID
unknown without reason             -> PROVENANCE_UNKNOWN_REASON_REQUIRED
```

- [ ] **Step 3: Run envelope tests and verify red**

Expected: missing schema, fixtures, and functions.

- [ ] **Step 4: Create the closed discriminator schema**

Use `$defs` for common fields, pointer, provenance, extract, and domain assertion; `oneOf` selects `upload_pointer` or `domain_event`. `envelope_id` has `minLength: 36`, `maxLength: 36`, and the approved lowercase UUIDv4 pattern. The destination pattern is `_inbox/<same-safe-UUID-shape>.json`; semantic validation proves equality with the ID.

The pointer requires `source_system`, `source_object_id`, `source_version_id`, `content_sha256`, `resolver_ref`, and `owning_region_or_system`. Reject HTTP(S) resolver values and any credential-bearing fields through a closed schema.

The optional extract requires `content_type: text/plain; charset=utf-8`, `content_transfer_encoding: identity`, `classification`, `classification_policy_ref`, `text`, `utf8_byte_length`, and `sha256`. The domain assertion is closed and permits only `digest`, `claim_candidate`, `decision_ref`, `classification`, and `classification_policy_refs`.

- [ ] **Step 5: Implement the approved recomputations**

Add exact functions:

```python
IDEMPOTENCY_NAMESPACE = "glassity.inbound-envelope.v1"
UUID4 = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
)


def expected_idempotency_key(envelope):
    fields = (
        IDEMPOTENCY_NAMESPACE,
        envelope["tenant_id"],
        envelope["envelope_type"],
        envelope["source"]["system"],
        envelope["source"]["object_id"],
        envelope["source"]["version_id"],
    )
    if any(not value or "\0" in value for value in fields):
        raise ValueError("idempotency tuple fields must be non-empty and NUL-free")
    return sha256_hex("\0".join(fields).encode("utf-8"))


def expected_destination(envelope_id):
    if not UUID4.fullmatch(envelope_id):
        raise ValueError("invalid canonical UUIDv4")
    return f"_inbox/{envelope_id}.json"


def extract_measurements(extract):
    raw = extract["text"].encode("utf-8")
    return len(raw), sha256_hex(raw)
```

Add this result type beside `Issue`:

```python
@dataclass(frozen=True)
class EnvelopeValidation:
    issues: list[Issue]
    intake_hold_required: bool
```

`validate_envelope` compares all declarations, rejects `data:*;base64,` case-insensitively, checks tenant/deployment equality, confirms the classification policy reference appears in the binding, and returns `EnvelopeValidation(ordered_issues, provenance["date_status"] == "unknown")`. `validate_bundle` appends `result.issues` and does not treat the hold flag as a validation failure.

- [ ] **Step 6: Run envelope tests and verify green**

Expected: four valid variants pass; every isolated mutation returns exactly the expected code.

- [ ] **Step 7: Commit the envelope contract**

```bash
git add -- glassity/contracts/tenant-provisioning/inbound-envelope.schema.json \
  glassity/contracts/tenant-provisioning/fixtures/valid \
  glassity/contracts/tenant-provisioning/CONTRACT.md \
  glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: define inbound envelope boundary"
```

### Task 6: Add data-driven invalid fixtures and the complete bundle CLI

**Files:**
- Create: `glassity/contracts/tenant-provisioning/fixtures/invalid/cases.json`
- Modify: `glassity/contracts/authority-matrix/fixtures/invalid/cases.json`
- Modify: `glassity/contracts/validate_contracts.py`
- Modify: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add a red data-driven mutation test**

Implement test-side JSON Pointer mutation operations `remove`, `replace`, `add`, and `append_copy`. For each descriptor, deep-copy the named valid baseline, apply exactly one mutation, validate the relevant artifact or bundle, and assert the returned code list equals `[expected_reason]`.

The tenant invalid descriptor set contains at least one case for every code from `TENANT_MISMATCH` through `PROVENANCE_UNKNOWN_REASON_REQUIRED`; authority descriptors cover the three authority codes; dependency and malformed-JSON tests cover the first two codes. Add an unmapped additional-property case for `SCHEMA_INVALID`.

- [ ] **Step 2: Run the data-driven tests and verify red**

Expected: failures for missing mutation loader, bundle CLI, and any reason without a descriptor.

- [ ] **Step 3: Implement deterministic mutation loading and reason ordering**

Tests reject a descriptor with an unknown operation, duplicate `case_id`, missing `expected_reason`, or a reason outside `REASON_ORDER`. Production validation deduplicates issues by code and sorts them with `REASON_ORDER`; JSON pointer paths remain diagnostic and never decide ordering.

- [ ] **Step 4: Complete `validate_bundle` and the CLI parser**

The CLI requires one authority, binding, and receipt path plus at least one envelope. It loads exact binding bytes before JSON decoding, performs schema checks first, then semantic checks, prints all ordered issues to stderr, and prints one line on success:

```text
VALID foundation-contracts: <tenant_id> <deployment_id> <N> envelope(s)
```

Invalid input produces no success line and no traceback.

- [ ] **Step 5: Add CLI subprocess canaries**

Run the valid bundle and assert exit `0`. Run one tenant-mismatched bundle and assert exit `1`, `TENANT_MISMATCH` on stderr, no traceback, and no `VALID` line. Run without required arguments and assert exit `2` with argparse usage.

- [ ] **Step 6: Run the entire overlay suite**

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: all tests pass, every `REASON_ORDER` code is reached by at least one canary, and the test prints its exact test count.

- [ ] **Step 7: Commit complete fixture coverage and CLI**

```bash
git add -- glassity/contracts/authority-matrix/fixtures/invalid/cases.json \
  glassity/contracts/tenant-provisioning/fixtures/invalid/cases.json \
  glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: prove named invalid directions"
```

### Task 7: Finish normative docs and run final acceptance

**Files:**
- Modify: `glassity/contracts/README.md`
- Modify: `glassity/contracts/authority-matrix/CONTRACT.md`
- Modify: `glassity/contracts/tenant-provisioning/CONTRACT.md`
- Create: `glassity/contracts/VERIFICATION.md`

- [ ] **Step 1: Complete the package README**

Document installation, both CLI forms, fixture layout, stable reason format, and the two independent acceptance commands. State that `requirements-test.txt` is dev/test-only and that missing `jsonschema==4.25.1` is a refusal rather than a fallback.

- [ ] **Step 2: Complete both normative contracts**

The authority contract includes the twelve-row closed table, amendment rule, and record-boundary prohibitions. The provisioning contract includes lifecycle/hold orthogonality, embedded erasure map, declared-only receipt, exact digest rules, UUIDv4 destination derivation, 65,536-byte extract rule, base64 limitation, idempotency tuple, date gate, tenant confinement, and stable reason contract.

- [ ] **Step 3: Create the verification-scope record**

`VERIFICATION.md` lists the exact commands and states, before any run, that schemas and receipts do not prove runtime tenant isolation, actual Git ancestry, scanning, pointer authorization, deletion, or worker behavior. It does not contain “PASS” fields that require editing after the gate.

- [ ] **Step 4: Run formatting and package checks**

```bash
python3 -m json.tool glassity/contracts/authority-matrix/authority-matrix.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/deployment-binding.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/erasure-map.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/inbound-envelope.schema.json >/dev/null
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: every JSON parse exits `0`; overlay suite exits `0` with no failures or errors.

- [ ] **Step 5: Prove protected core stayed unchanged**

```bash
git diff --name-only 29c8307d0b98d2859f34d140414b160883339c06 HEAD
git status --short
```

Expected: every changed path starts with `glassity/contracts/`, except for the
sole approved new workflow `.github/workflows/glassity-contracts.yml`; status
contains only the documentation paths from the current task before staging.

- [ ] **Step 6: Stage only the final documentation and run the authoritative gate**

```bash
git add -- glassity/contracts/README.md \
  glassity/contracts/authority-matrix/CONTRACT.md \
  glassity/contracts/tenant-provisioning/CONTRACT.md \
  glassity/contracts/VERIFICATION.md
python3 tools/km-release-gate.py
```

Expected: direct, unpiped gate exit `0`; report discovered/run/skipped counts and its stated limits. A socket-denied run is environmental and must be rerun with the same command under the required localhost permission; it is not a pass.

- [ ] **Step 7: Commit the completed specification package**

```bash
git commit -m "docs: complete foundation contract package"
```

- [ ] **Step 8: Final evidence audit**

```bash
git status --short --branch
git diff --name-only 29c8307d0b98d2859f34d140414b160883339c06 HEAD
rg -n -i 'T''BD|T''ODO|FIX''ME' glassity/contracts
```

Expected: clean working tree; all changed paths under `glassity/contracts/`
except for `.github/workflows/glassity-contracts.yml`; search exit `1` with no
matches. Report the commits, overlay-suite exit status/test count,
authoritative-gate exit status/counts, and explicitly repeat the runtime/Git
proof limits.

## Spec-coverage index

| Approved requirement | Plan task |
|---|---|
| Full Draft 2020-12 via declared dev dependency, no subset fallback | 1, 2, 7 |
| Closed authority set and amendment-only extension | 2 |
| Binding reuses AD-005 lifecycle and orthogonal scoped hold | 3 |
| Binding instantiates complete erasure map | 3 |
| Receipt declares ordering but does not prove Git ancestry | 4 |
| Binding and erasure-map digests recomputed | 4 |
| UUIDv4 ID and derived `_inbox/` path | 5 |
| Mandatory pointer; no embedded raw file | 5 |
| Optional classified identity-encoded UTF-8 extract, 65,536-byte bound | 5 |
| Extract length and digest recomputed | 5 |
| NUL-separated versioned idempotency tuple recomputed | 5 |
| Resolved/unknown provenance date gate | 5 |
| Tenant/deployment cross-document comparisons | 3–6 |
| Stable reason codes and exact negative direction | 1–6 |
| Separate overlay suite and authoritative gate | 6, 7 |
| Protected core unchanged except for the sole approved workflow | 7 |
| Explicit runtime/Git limitations | 4, 7 |

## Execution handoff

Implement tasks in order. Each task leaves the overlay suite green and creates one focused commit. Do not begin the cockpit-web or worker contract cycles in this plan. Stop for review if a schema field, authority mapping, erasure category, reason code, digest serialization, or security boundary would need to differ from the approved design.

## Corrective implementation disposition

The corrective design is approved for implementation. The dedicated
`.github/workflows/glassity-contracts.yml` lane is the sole workflow exception;
`.github/workflows/release-gate.yml` and `tools/km-release-gate.py` remain
unchanged. `AUTHORITY_SYSTEM_MISMATCH` covers any changed field in a complete
closed authority row. Resolver syntax excludes embedded URL, query, and
user-info credential forms but does not prove runtime resolver authorization.
`actor_service_id` is evidence of a claimed service identity, not a trusted
producer-role assertion. Supervisor review remains the hard stop before push or
implementation acceptance.
