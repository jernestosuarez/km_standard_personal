# Glassity foundation contracts

This directory contains machine-testable specification contracts for the Glassity overlay. The validator checks contract documents and synthetic fixtures; it is not application or provisioning runtime code.

The package contains two normative contract groups:

- `authority-matrix/` fixes the closed v1 record-authority boundary.
- `tenant-provisioning/` fixes the deployment binding, embedded erasure map, declared provisioning receipt, and inbound-envelope boundary.

All examples are synthetic. The package must not contain customer content, derived customer excerpts, filled operator profiles, credentials, private endpoints, or real tenant identifiers.

## Validation dependency

Install the pinned development and test dependency:

```bash
python3 -m pip install -r glassity/contracts/requirements-test.txt
```

`requirements-test.txt` is development/test-only and pins `jsonschema==4.25.1`. The validator uses `jsonschema.Draft202012Validator`, checks every shipped schema, and performs full Draft 2020-12 instance validation before semantic checks. It does not vendor a validator, implement a private subset, or fall back to shape-only checks. A missing or incompatible dependency is a refusal with `DEPENDENCY_MISSING`, not degraded validation.

## Command-line interface

Check that the full JSON Schema Draft 2020-12 validation runtime is available:

```bash
python3 glassity/contracts/validate_contracts.py --self-check
```

Validate one complete contract bundle with one or more inbound envelopes:

```bash
python3 glassity/contracts/validate_contracts.py bundle \
  --authority glassity/contracts/authority-matrix/fixtures/valid/authority-matrix.json \
  --binding glassity/contracts/tenant-provisioning/fixtures/valid/deployment-binding.json \
  --receipt glassity/contracts/tenant-provisioning/fixtures/valid/provisioning-receipt.json \
  --envelope glassity/contracts/tenant-provisioning/fixtures/valid/upload-pointer.json \
  --envelope glassity/contracts/tenant-provisioning/fixtures/valid/domain-event.json
```

Success is reported on standard output and exits zero. Failure is reported on standard error as one tab-separated issue per line:

```text
REASON_CODE<TAB>/json/pointer<TAB>context message
```

Reason codes are stable contract values; messages may add context. Invalid input never produces partial success. See the normative contracts for the initial reason-code set.

## Fixtures

Each contract group has `fixtures/valid/` and `fixtures/invalid/` material. Valid files are complete synthetic instances. Invalid `cases.json` files are data-driven mutation descriptors: each names a valid baseline, one mutation, and the exact `expected_reason`. The test suite must reject a canary for its named reason, not merely return a nonzero status.

## Independent acceptance lanes

The Glassity lane runs in the dedicated
`.github/workflows/glassity-contracts.yml` workflow. It installs the pinned
test dependency, runs the validator self-check, and invokes the suite explicitly:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

The authoritative core lane remains unchanged in
`.github/workflows/release-gate.yml` and runs the unchanged core gate separately:

```bash
python3 tools/km-release-gate.py
```

Both commands are required and neither substitutes for the other. The first
exercises the Glassity overlay schemas, semantic checks, recomputations,
fixtures, and mutation directions. The second is the authoritative core release
gate and proves only the checks it reports. The new Glassity workflow is the
sole approved protected-path exception; the overlay checks are not wired into
protected core.

`AUTHORITY_SYSTEM_MISMATCH` means that any field in a complete closed authority
row differs from the canonical definition, not only that its
`system_of_record` changed. Resolver syntax excludes embedded URL, query, and
user-info credential forms, but it cannot prove runtime resolver authorization.
Likewise, `actor_service_id` is evidence identifying the claimed service; it is
not a trusted assertion that the service holds an allowed producer role.

The validator is read-only. It never mutates a tenant hub. Schemas, fixtures,
and receipts do not prove runtime tenant isolation, actual Git ancestry, content
scanning, source-pointer authorization, trusted producer-role authorization,
deletion conformance, or worker behavior. The required commands and these proof
limits are recorded in `VERIFICATION.md`.
