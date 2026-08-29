# Glassity Foundation Contract Corrections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the approved foundation-contract package by separating its CI lane from the core gate and closing the identified authority, mutation, resolver, date, chronology, and proof-claim gaps.

**Architecture:** The core release gate remains byte-unchanged and the Glassity suite moves to an explicitly invoked `spec_tests` directory with its own dependency-pinned GitHub workflow. The semantic validator pins the complete authority row and performs only checks that static contract documents can prove; trusted producer authorization, Git ancestry, and resolver authorization remain runtime conformance work.

**Tech Stack:** Python 3.9, `unittest`, JSON Schema Draft 2020-12, `jsonschema==4.25.1`, GitHub Actions, JSON synthetic fixtures

---

## File structure and ownership

- `.github/workflows/glassity-contracts.yml`: new, independent Glassity verification lane; the sole approved protected-path exception.
- `glassity/contracts/spec_tests/test_contracts.py`: moved contract tests plus new workflow, authority, policy, canary, date, chronology, and schema-claim tests.
- `glassity/contracts/tests/test_contracts.py`: removed after the move; this path must no longer exist.
- `glassity/contracts/validate_contracts.py`: complete authority pin, schema-claim check, semantic policy checks, and actual calendar/chronology validation.
- `glassity/contracts/authority-matrix/fixtures/invalid/cases.json`: exact Git-remapping mutation descriptors.
- `glassity/contracts/tenant-provisioning/inbound-envelope.schema.json`: closed opaque resolver-reference grammar.
- `glassity/contracts/tenant-provisioning/fixtures/valid/*.json`: authority-approved classification references.
- `glassity/contracts/tenant-provisioning/fixtures/valid/deployment-binding.json`: classification and retention policy bindings.
- `glassity/contracts/tenant-provisioning/fixtures/valid/provisioning-receipt.json`: recomputed binding digest.
- `glassity/contracts/{README.md,VERIFICATION.md,glassity-foundation-contracts-design.md,glassity-foundation-contracts-implementation-plan.md,glassity-foundation-contracts-corrective-design.md}`: corrected commands, proof limits, exception, and implementation disposition.

### Task 1: Isolate the Glassity verification lane

**Files:**
- Move: `glassity/contracts/tests/test_contracts.py` → `glassity/contracts/spec_tests/test_contracts.py`
- Create: `.github/workflows/glassity-contracts.yml`
- Test: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Move the existing test module without changing its behavior**

Use `apply_patch` to add the existing file unchanged at `spec_tests/test_contracts.py` and remove `tests/test_contracts.py`. Keep:

```python
ROOT = Path(__file__).resolve().parents[3]
CONTRACTS = ROOT / "glassity" / "contracts"
VALIDATOR = CONTRACTS / "validate_contracts.py"
```

The parent depth remains correct because both `tests/` and `spec_tests/` are direct children of `glassity/contracts/`.

- [ ] **Step 2: Run the relocated suite to prove the move preserved behavior**

Run:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: all existing tests pass; the output contains no import or path errors.

- [ ] **Step 3: Add a failing workflow-contract test**

Append this class to `glassity/contracts/spec_tests/test_contracts.py`:

```python
class WorkflowContractTests(unittest.TestCase):
    def test_glassity_workflow_pins_runtime_dependency_and_explicit_suite(self):
        workflow = (ROOT / ".github" / "workflows" / "glassity-contracts.yml").read_text(
            encoding="utf-8"
        )
        required_fragments = (
            "actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683",
            "actions/setup-python@5fda3b95a4ea91299a34e894583c3862153e4b97",
            "python-version: '3.9'",
            "python -m pip install --disable-pip-version-check -r glassity/contracts/requirements-test.txt",
            "python glassity/contracts/validate_contracts.py --self-check",
            "python -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v",
        )
        for fragment in required_fragments:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, workflow)

    def test_legacy_discovery_path_is_absent(self):
        self.assertFalse((CONTRACTS / "tests" / "test_contracts.py").exists())
```

- [ ] **Step 4: Run the workflow test and verify RED**

Run:

```bash
python3 -m unittest glassity.contracts.spec_tests.test_contracts.WorkflowContractTests -v
```

Expected: `test_glassity_workflow_pins_runtime_dependency_and_explicit_suite` errors with `FileNotFoundError` for `.github/workflows/glassity-contracts.yml`; the legacy-path test passes.

- [ ] **Step 5: Add the dedicated workflow**

Create `.github/workflows/glassity-contracts.yml` with exactly this behavior:

```yaml
name: glassity-contracts

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  contracts:
    runs-on: ubuntu-24.04
    timeout-minutes: 10

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - uses: actions/setup-python@5fda3b95a4ea91299a34e894583c3862153e4b97 # v7.0.0
        with:
          python-version: '3.9'
          cache: pip
          cache-dependency-path: glassity/contracts/requirements-test.txt

      - name: Install the pinned contract-test dependency
        run: python -m pip install --disable-pip-version-check -r glassity/contracts/requirements-test.txt

      - name: Check the Draft 2020-12 runtime
        run: python glassity/contracts/validate_contracts.py --self-check

      - name: Run the Glassity contract suite
        run: python -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

- [ ] **Step 6: Run the workflow test and relocated suite GREEN**

Run:

```bash
python3 -m unittest glassity.contracts.spec_tests.test_contracts.WorkflowContractTests -v
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: both commands exit zero.

- [ ] **Step 7: Prove the core gate no longer discovers the overlay suite**

Run:

```bash
python3 tools/km-release-gate.py
```

Expected: exit zero; no discovered-check or declaration line names `glassity/contracts/spec_tests/test_contracts.py`.

- [ ] **Step 8: Commit the isolated lane**

```bash
git add .github/workflows/glassity-contracts.yml glassity/contracts/spec_tests/test_contracts.py glassity/contracts/tests/test_contracts.py
git commit -m "ci: isolate Glassity contract verification"
```

### Task 2: Pin every authority-row field and every forbidden Git assignment

**Files:**
- Modify: `glassity/contracts/validate_contracts.py:54-70,292-328`
- Modify: `glassity/contracts/authority-matrix/fixtures/invalid/cases.json`
- Test: `glassity/contracts/spec_tests/test_contracts.py:444-530`

- [ ] **Step 1: Add failing complete-row and Git-remapping tests**

Add these tests to `AuthorityMatrixTests`:

```python
    def test_every_canonical_authority_field_is_pinned(self):
        validator, matrix = self.load_matrix()
        raw_upload = next(
            row for row in matrix["rows"] if row["data_class"] == "raw_upload"
        )
        mutations = {
            "system_of_record": "tenant_hub",
            "hub_representations": ["governed_claim"],
            "allowed_producers": ["worker"],
            "envelope_types": ["domain_event"],
            "classification_policy_refs": ["urn:glassity:synthetic:policy:other"],
            "retention_policy_ref": "urn:glassity:synthetic:policy:other",
            "forbidden_locations": ["audit_store"],
        }

        for field, value in mutations.items():
            with self.subTest(field=field):
                mutated = deepcopy(matrix)
                row = next(
                    item for item in mutated["rows"]
                    if item["data_class"] == "raw_upload"
                )
                row[field] = value
                issues = validator.validate_authority_matrix(mutated)
                self.assertEqual(
                    [issue.code for issue in issues],
                    ["AUTHORITY_SYSTEM_MISMATCH"],
                )

    def test_non_git_record_classes_cannot_be_remapped_to_tenant_hub(self):
        validator, matrix = self.load_matrix()
        for data_class in ("raw_upload", "app_object", "app_event", "pending_answer"):
            with self.subTest(data_class=data_class):
                mutated = deepcopy(matrix)
                row = next(
                    item for item in mutated["rows"]
                    if item["data_class"] == data_class
                )
                row["system_of_record"] = "tenant_hub"
                issues = validator.validate_authority_matrix(mutated)
                self.assertEqual(
                    [issue.code for issue in issues],
                    ["AUTHORITY_SYSTEM_MISMATCH"],
                )
```

- [ ] **Step 2: Run the new tests and verify RED**

Run:

```bash
python3 -m unittest \
  glassity.contracts.spec_tests.test_contracts.AuthorityMatrixTests.test_every_canonical_authority_field_is_pinned \
  glassity.contracts.spec_tests.test_contracts.AuthorityMatrixTests.test_non_git_record_classes_cannot_be_remapped_to_tenant_hub -v
```

Expected: failures for fields other than `system_of_record` and `hub_representations`; the remapping loop itself may already pass and is retained as an explicit boundary canary.

- [ ] **Step 3: Replace the partial authority tuple with a complete closed mapping**

In `validate_contracts.py`, define:

```python
AUTHORITY = {
    "raw_upload": ("object_storage", {"pointer"}, {"inbound_adapter"}, {"upload_pointer"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"tenant_hub", "pending_answer_store"}),
    "app_object": ("application_database", {"pointer", "digest", "claim", "decision"}, {"cockpit", "worker"}, {"domain_event"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"tenant_hub"}),
    "app_event": ("event_store", {"pointer", "digest", "claim", "decision"}, {"cockpit", "worker"}, {"domain_event"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"tenant_hub"}),
    "digest": ("tenant_hub", {"governed_digest"}, {"core_intake", "worker"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "claim": ("tenant_hub", {"governed_claim"}, {"core_intake", "worker"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "decision": ("tenant_hub", {"governed_decision"}, {"core_intake", "cockpit"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "classified_extract": ("tenant_hub", {"classified_text_extract"}, {"core_intake"}, {"upload_pointer"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "pointer": ("tenant_hub", {"resolvable_pointer"}, {"core_intake"}, {"upload_pointer"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"pending_answer_store"}),
    "owner_queue": ("tenant_hub", {"governed_queue_record"}, {"cockpit", "worker"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "execution_record": ("tenant_hub", {"governed_execution_record"}, {"worker"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage"}),
    "pending_answer": ("pending_answer_store", {"none_until_pull"}, {"worker"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"tenant_hub", "object_storage"}),
    "audit_event": ("audit_store", {"non_content_evidence_pointer"}, {"audit_service"}, {"none"}, {"urn:glassity:synthetic:policy:classification"}, "urn:glassity:synthetic:policy:retention", {"object_storage", "pending_answer_store"}),
}
```

In `validate_authority_matrix`, compare the row to the tuple in this exact field order:

```python
        expected = AUTHORITY[row["data_class"]]
        actual_row = (
            row.get("system_of_record"),
            set(row.get("hub_representations", [])),
            set(row.get("allowed_producers", [])),
            set(row.get("envelope_types", [])),
            set(row.get("classification_policy_refs", [])),
            row.get("retention_policy_ref"),
            set(row.get("forbidden_locations", [])),
        )
        if actual_row != expected:
            issues.append(
                Issue(
                    "AUTHORITY_SYSTEM_MISMATCH",
                    f"/rows/{index}",
                    f"closed authority definition changed for {row['data_class']}",
                )
            )
```

- [ ] **Step 4: Add exact mutation descriptors for the four prohibited Git mappings**

In `authority-matrix/fixtures/invalid/cases.json`, retain the existing pending-answer case and add:

```json
{
  "case_id": "raw-upload-remapped-to-git",
  "artifact": "authority-matrix.json",
  "operation": "replace",
  "path": "/rows/0/system_of_record",
  "value": "tenant_hub",
  "expected_reason": "AUTHORITY_SYSTEM_MISMATCH"
},
{
  "case_id": "app-object-remapped-to-git",
  "artifact": "authority-matrix.json",
  "operation": "replace",
  "path": "/rows/1/system_of_record",
  "value": "tenant_hub",
  "expected_reason": "AUTHORITY_SYSTEM_MISMATCH"
},
{
  "case_id": "app-event-remapped-to-git",
  "artifact": "authority-matrix.json",
  "operation": "replace",
  "path": "/rows/2/system_of_record",
  "value": "tenant_hub",
  "expected_reason": "AUTHORITY_SYSTEM_MISMATCH"
}
```

Rename the existing `authority-row-remapped` case to `pending-answer-remapped-to-git` without changing its `/rows/10/system_of_record` mutation.

- [ ] **Step 5: Run authority and descriptor suites GREEN**

Run:

```bash
python3 -m unittest \
  glassity.contracts.spec_tests.test_contracts.AuthorityMatrixTests \
  glassity.contracts.spec_tests.test_contracts.InvalidFixtureDescriptorTests -v
```

Expected: all authority and descriptor tests pass; each descriptor produces only `AUTHORITY_SYSTEM_MISMATCH`.

- [ ] **Step 6: Commit the full authority pin**

```bash
git add glassity/contracts/validate_contracts.py glassity/contracts/authority-matrix/fixtures/invalid/cases.json glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: pin complete authority rows"
```

### Task 3: Cross-check classification policies against binding and authority

**Files:**
- Modify: `glassity/contracts/validate_contracts.py:549-608`
- Modify: `glassity/contracts/tenant-provisioning/fixtures/valid/deployment-binding.json`
- Modify: `glassity/contracts/tenant-provisioning/fixtures/valid/{upload-pointer.json,upload-pointer-with-extract.json,unknown-date.json,domain-event.json,provisioning-receipt.json}`
- Test: `glassity/contracts/spec_tests/test_contracts.py:1035-1135`

- [ ] **Step 1: Add a failing authority-policy test**

Add to `InboundEnvelopeTests`:

```python
    def test_envelope_policy_must_match_binding_and_source_authority(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        mutated = deepcopy(envelope)
        policy_ref = "urn:glassity:synthetic:policy:binding-only"
        mutated["classification_policy_ref"] = policy_ref
        mutated_binding = deepcopy(binding)
        mutated_binding["tenant_policy_refs"].append(policy_ref)

        result = validator.validate_envelope(mutated, authority, mutated_binding)

        self.assertEqual([issue.code for issue in result.issues], ["SCHEMA_INVALID"])
```

- [ ] **Step 2: Run it and verify RED**

Run:

```bash
python3 -m unittest glassity.contracts.spec_tests.test_contracts.InboundEnvelopeTests.test_envelope_policy_must_match_binding_and_source_authority -v
```

Expected: FAIL because the current validator accepts any reference present in the binding.

- [ ] **Step 3: Select matched authority rows once and enforce the intersection**

Replace the `authorized_source = any(...)` expression with:

```python
    matched_authority_rows = [
        row
        for row in authority_rows
        if isinstance(row, dict)
        and row.get("system_of_record") == value["source"].get("system")
        and value.get("envelope_type") in row.get("envelope_types", [])
        and (
            value.get("envelope_type") != "upload_pointer"
            or row.get("data_class") == "raw_upload"
        )
    ]
    if not matched_authority_rows:
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/source/system",
                "source system is not authoritative for this envelope type",
            )
        )
```

After collecting `declared_policy_refs`, compute and enforce both allowed sets:

```python
    authority_policy_refs = set().union(
        *(
            set(row.get("classification_policy_refs", []))
            for row in matched_authority_rows
        )
    ) if matched_authority_rows else set()
    if any(
        policy_ref not in bound_policy_refs
        or policy_ref not in authority_policy_refs
        for policy_ref in declared_policy_refs
    ):
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/classification_policy_ref",
                "classification policy is not approved by both binding and authority",
            )
        )
```

- [ ] **Step 4: Align all valid synthetic policy references**

Set `deployment-binding.json` to:

```json
"tenant_policy_refs": ["urn:glassity:synthetic:policy:classification", "urn:glassity:synthetic:policy:retention"]
```

In `upload-pointer.json`, `upload-pointer-with-extract.json`, `unknown-date.json`, and `domain-event.json`, replace every classification-policy value `policies/synthetic-retention-v1` with:

```text
urn:glassity:synthetic:policy:classification
```

This includes `extract.classification_policy_ref` and every item in `domain_assertion.classification_policy_refs`.

Set the receipt's `binding_sha256` to the digest of the byte-preserving one-line binding edit:

```text
eb14f8e769bacf11e27fc6eef1d62daf942f0c097545b0de16719ab77e2481f4
```

- [ ] **Step 5: Run policy, digest, and bundle tests GREEN**

Run:

```bash
python3 -m unittest \
  glassity.contracts.spec_tests.test_contracts.InboundEnvelopeTests \
  glassity.contracts.spec_tests.test_contracts.BundleCliTests -v
```

Expected: all tests pass; the valid bundle continues to exit zero and receipt digest recomputation succeeds.

- [ ] **Step 6: Commit the policy cross-check**

```bash
git add glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py glassity/contracts/tenant-provisioning/fixtures/valid
git commit -m "contracts: bind envelope policies to authority"
```

### Task 4: Complete identifier, destination, and resolver canaries

**Files:**
- Modify: `glassity/contracts/tenant-provisioning/inbound-envelope.schema.json:84-101`
- Test: `glassity/contracts/spec_tests/test_contracts.py:1008-1066`

- [ ] **Step 1: Expand identifier and destination tests**

Replace the current identifier and destination tests with:

```python
    def test_noncanonical_envelope_ids_have_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        canonical = envelope["envelope_id"]
        invalid_ids = (
            canonical.upper(),
            "123e4567-e89b-12d3-a456-426614174000",
            canonical + "0",
            "prefix-" + canonical,
            canonical + "-suffix",
            canonical[:-1] + "\n",
        )

        for envelope_id in invalid_ids:
            with self.subTest(envelope_id=repr(envelope_id)):
                mutated = deepcopy(envelope)
                mutated["envelope_id"] = envelope_id
                self.assert_envelope_reason(mutated, "ENVELOPE_ID_INVALID")

    def test_unsafe_destinations_have_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        invalid_destinations = (
            "sources/synthetic.json",
            "/_inbox/123e4567-e89b-42d3-a456-426614174000.json",
            "../_inbox/123e4567-e89b-42d3-a456-426614174000.json",
            "_inbox/%2e%2e/123e4567-e89b-42d3-a456-426614174000.json",
            "_inbox\\123e4567-e89b-42d3-a456-426614174000.json",
        )

        for destination in invalid_destinations:
            with self.subTest(destination=destination):
                mutated = deepcopy(envelope)
                mutated["destination"] = destination
                self.assert_envelope_reason(mutated, "UNSAFE_DESTINATION")
```

- [ ] **Step 2: Expand the resolver schema test and verify RED**

Replace `test_pointer_rejects_http_resolvers_and_credential_fields` with:

```python
    def test_pointer_rejects_nonopaque_or_credential_bearing_resolvers(self):
        validator, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)
        invalid_refs = (
            "https://example.invalid/object",
            "s3:object?X-Amz-Signature=synthetic",
            "urn:user@example.invalid:object",
            "urn:object?token=synthetic",
            "urn:object#fragment",
            "urn:object=synthetic",
            "urn:a://example.invalid/object",
        )

        self.assertEqual(schema_issues, [])
        for resolver_ref in invalid_refs:
            with self.subTest(resolver_ref=resolver_ref):
                mutated = deepcopy(envelope)
                mutated["source"]["resolver_ref"] = resolver_ref
                issues = validator.validate_schema(
                    "inbound-envelope", mutated, schemas, registry
                )
                self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])

        credential_field = deepcopy(envelope)
        credential_field["source"]["bearer_token"] = "synthetic-secret"
        issues = validator.validate_schema(
            "inbound-envelope", credential_field, schemas, registry
        )
        self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])
```

Run:

```bash
python3 -m unittest glassity.contracts.spec_tests.test_contracts.InboundEnvelopeTests.test_pointer_rejects_nonopaque_or_credential_bearing_resolvers -v
```

Expected: FAIL for at least the query-, user-info-, fragment-, equals-, or embedded-`://` mutations.

- [ ] **Step 3: Constrain `resolver_ref` in the JSON Schema**

Replace its current `minLength`/HTTP-only constraint with:

```json
"resolver_ref": {
  "type": "string",
  "pattern": "^[A-Za-z][A-Za-z0-9+.-]*:[A-Za-z0-9][A-Za-z0-9:._/-]*$",
  "not": {"pattern": "://"}
}
```

The positive URN fixtures remain valid. The grammar excludes whitespace, controls, `?`, `#`, `@`, and `=` by construction.

- [ ] **Step 4: Run all envelope tests GREEN**

Run:

```bash
python3 -m unittest glassity.contracts.spec_tests.test_contracts.InboundEnvelopeTests -v
```

Expected: all identifier, destination, resolver, and existing envelope tests pass with exact reason codes.

- [ ] **Step 5: Commit envelope boundary hardening**

```bash
git add glassity/contracts/tenant-provisioning/inbound-envelope.schema.json glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: harden envelope references and paths"
```

### Task 5: Validate schema proof wording and real chronology

**Files:**
- Modify: `glassity/contracts/validate_contracts.py:1-15,173-207,331-423`
- Test: `glassity/contracts/spec_tests/test_contracts.py`

- [ ] **Step 1: Add failing schema-claim, date, and chronology tests**

Add these tests to the existing binding and receipt test classes:

```python
    def test_binding_rejects_impossible_dates_and_reversed_effect(self):
        validator, binding = self.load_binding()
        impossible_hold = deepcopy(binding)
        impossible_hold["legal_hold"] = {
            "status": "scoped",
            "decision_ref": "decisions/synthetic-legal-hold-v1",
            "scope_digest": "a" * 64,
            "legal_basis_ref": "legal/synthetic-basis-v1",
            "review_date": "2026-02-30",
        }
        reversed_effect = deepcopy(binding)
        reversed_effect["effective_at"] = "2026-08-28T09:59:59Z"

        for mutated in (impossible_hold, reversed_effect):
            with self.subTest(mutated=mutated):
                issues = validator.validate_binding(mutated)
                self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])

    def test_receipt_rejects_impossible_timestamp_and_reversed_events(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        impossible = deepcopy(receipt)
        impossible["initialized_at"] = "2026-02-30T10:01:00Z"
        reversed_events = deepcopy(receipt)
        reversed_events["overlay_applied_at"] = "2026-08-28T10:00:59Z"

        self.assertEqual(
            [issue.code for issue in validator.validate_receipt(
                impossible, binding_bytes, binding
            )],
            ["SCHEMA_INVALID"],
        )
        self.assertEqual(
            [issue.code for issue in validator.validate_receipt(
                reversed_events, binding_bytes, binding
            )],
            ["PROVISIONING_ORDER_INVALID"],
        )

    def test_receipt_schema_must_disclaim_git_ancestry_proof(self):
        validator = load_validator()
        schema_path = (
            CONTRACTS
            / "tenant-provisioning"
            / "provisioning-receipt.schema.json"
        )
        mutated = json.loads(schema_path.read_text(encoding="utf-8"))
        mutated["description"] = "Proves actual Git ancestry."
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "provisioning-receipt.schema.json"
            target.write_text(json.dumps(mutated), encoding="utf-8")
            _, _, issues = validator.load_schemas(root)

        self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])
```

Place `test_binding_rejects_impossible_dates_and_reversed_effect` in `DeploymentBindingTests`, which already defines `load_binding`. Place both receipt tests in `ProvisioningReceiptTests`, which already defines `load_receipt_bundle`.

- [ ] **Step 2: Run the three tests and verify RED**

Run their fully qualified unittest names with `-v`.

Expected: the impossible and reversed calendar tests currently return no issues, and the mutated proof description currently loads without `SCHEMA_INVALID`.

- [ ] **Step 3: Add strict calendar parsing helpers**

Change the import to:

```python
from datetime import date, datetime
```

Add:

```python
UTC_SECONDS = re.compile(
    r"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
)
RECEIPT_PROOF_DESCRIPTION = (
    "Declares provisioning inputs and an expected parent relationship; "
    "it does not prove Git ancestry."
)


def parse_utc_seconds(value: object) -> datetime:
    if not isinstance(value, str) or not UTC_SECONDS.fullmatch(value):
        raise ValueError("timestamp must use exact UTC-second form")
    return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")


def parse_calendar_date(value: object) -> date:
    if not isinstance(value, str) or not re.fullmatch(
        r"[0-9]{4}-[0-9]{2}-[0-9]{2}", value
    ):
        raise ValueError("date must use exact calendar form")
    return date.fromisoformat(value)
```

- [ ] **Step 4: Enforce the receipt schema disclaimer while loading**

Inside `load_schemas`, after deriving `kind`, add:

```python
        if (
            kind == "provisioning-receipt"
            and schema.get("description") != RECEIPT_PROOF_DESCRIPTION
        ):
            issues.append(
                Issue(
                    "SCHEMA_INVALID",
                    "/description",
                    f"{path}: receipt schema must disclaim actual Git ancestry proof",
                )
            )
```

Continue loading the schema so all syntax checks still run; `_ordered_unique` supplies the one stable reason.

- [ ] **Step 5: Add binding and receipt chronology semantics**

At the end of `validate_binding`, before ordering issues, add:

```python
    try:
        created_at = parse_utc_seconds(value.get("created_at"))
        effective_at = parse_utc_seconds(value.get("effective_at"))
        legal_hold = value.get("legal_hold")
        if isinstance(legal_hold, dict):
            parse_calendar_date(legal_hold.get("review_date"))
        if created_at > effective_at:
            raise ValueError("binding cannot become effective before creation")
    except ValueError:
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/",
                "binding dates must be real and chronologically ordered",
            )
        )
```

At the start of `validate_receipt`, add:

```python
    try:
        initialized_at = parse_utc_seconds(value.get("initialized_at"))
        overlay_applied_at = parse_utc_seconds(value.get("overlay_applied_at"))
    except ValueError:
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/",
                "receipt timestamps must be real UTC-second values",
            )
        )
        initialized_at = None
        overlay_applied_at = None
```

Extend `order_mismatch` with:

```python
        or (
            initialized_at is not None
            and overlay_applied_at is not None
            and initialized_at > overlay_applied_at
        )
```

- [ ] **Step 6: Run binding, receipt, schema, and full overlay tests GREEN**

Run:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: all tests pass; invalid calendar values produce `SCHEMA_INVALID`, reversed receipt events produce `PROVISIONING_ORDER_INVALID`, and the shipped receipt schema passes its disclaimer check.

- [ ] **Step 7: Commit proof and chronology checks**

```bash
git add glassity/contracts/validate_contracts.py glassity/contracts/spec_tests/test_contracts.py
git commit -m "contracts: verify proof wording and chronology"
```

### Task 6: Correct the governed records and run final acceptance

**Files:**
- Modify: `glassity/contracts/README.md`
- Modify: `glassity/contracts/VERIFICATION.md`
- Modify: `glassity/contracts/glassity-foundation-contracts-design.md`
- Modify: `glassity/contracts/glassity-foundation-contracts-implementation-plan.md`
- Modify: `glassity/contracts/glassity-foundation-contracts-corrective-design.md`

- [ ] **Step 1: Update every command and verification-boundary claim**

Make these exact documentation changes:

```text
old overlay path: glassity/contracts/tests
new overlay path: glassity/contracts/spec_tests
new workflow: .github/workflows/glassity-contracts.yml
sole protected-path exception: the new workflow file
unchanged core workflow: .github/workflows/release-gate.yml
unchanged core gate: tools/km-release-gate.py
```

State that `AUTHORITY_SYSTEM_MISMATCH` covers any changed field in the closed authority row. State that resolver syntax excludes embedded URL/query/user-info credential forms but does not prove runtime resolver authorization. State that `actor_service_id` is evidence, not a trusted producer-role assertion.

- [ ] **Step 2: Record the approved corrective-design status**

Change the corrective design frontmatter from:

```yaml
status: proposed-for-review
```

to:

```yaml
status: approved-for-implementation
```

Add a final implementation-evidence section only after all commands below pass. It must record command, exit status, and scope result; elapsed time may be recorded but never substitutes for the exit status.

- [ ] **Step 3: Run the dependency and overlay lane directly**

Run:

```bash
python3 -m pip install --disable-pip-version-check -r glassity/contracts/requirements-test.txt
python3 glassity/contracts/validate_contracts.py --self-check
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

Expected: all three commands exit zero.

- [ ] **Step 4: Run schema syntax and diff checks**

Run:

```bash
python3 -m json.tool glassity/contracts/authority-matrix/authority-matrix.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/deployment-binding.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/erasure-map.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/inbound-envelope.schema.json >/dev/null
git diff --check
git diff --name-only 08d5302 HEAD
git status --short
```

Expected: JSON commands and `git diff --check` exit zero; every changed path is under `glassity/contracts/` except `.github/workflows/glassity-contracts.yml`; the working tree contains only the intentional documentation edits before their commit.

- [ ] **Step 5: Run the authoritative core gate once, directly and unpiped**

Run:

```bash
python3 tools/km-release-gate.py
```

Expected: exit zero; output does not discover `glassity/contracts/spec_tests/test_contracts.py`. Record the exit status explicitly.

- [ ] **Step 6: Add implementation evidence and commit the records**

In the corrective design evidence section, record the exact overlay test count observed, both lane exit statuses, the self-check exit status, and the protected-path result. Do not prestate a test count in advance.

Then commit:

```bash
git add glassity/contracts/README.md glassity/contracts/VERIFICATION.md glassity/contracts/glassity-foundation-contracts-design.md glassity/contracts/glassity-foundation-contracts-implementation-plan.md glassity/contracts/glassity-foundation-contracts-corrective-design.md
git commit -m "docs: close foundation contract corrections"
```

- [ ] **Step 7: Verify the final branch and stop for Supervisor review**

Run:

```bash
git status --short --branch
git log --oneline 08d5302..HEAD
git diff --name-only 08d5302 HEAD
```

Expected: clean branch; six bounded implementation commits after the design; no changed protected-core path other than `.github/workflows/glassity-contracts.yml`.

Do not push. Supervisor review is the hard stop before push or implementation acceptance.
