---
title: Glassity foundation contract verification scope
description: Required commands, evidence boundaries, and proof limits for the foundation contract package.
tags: [glassity, contracts, verification]
---

# Glassity foundation contract verification scope

This record specifies the evidence required to accept the foundation contract package. It does not record a test outcome and contains no mutable result field.

## Schema syntax checks

Each command must run directly and exit zero:

```bash
python3 -m json.tool glassity/contracts/authority-matrix/authority-matrix.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/deployment-binding.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/erasure-map.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/provisioning-receipt.schema.json >/dev/null
python3 -m json.tool glassity/contracts/tenant-provisioning/inbound-envelope.schema.json >/dev/null
```

These checks prove JSON syntax only. Full Draft 2020-12 schema and instance validation is exercised by the overlay suite with the pinned development/test dependency.

## Required independent acceptance lanes

Run the overlay suite directly:

```bash
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

The dedicated `.github/workflows/glassity-contracts.yml` workflow installs the
pinned dependency, performs the validator self-check, and runs this exact
suite. It is the sole approved protected-path exception for this slice.

Run the authoritative core release gate separately, directly, and without a pipe:

```bash
python3 tools/km-release-gate.py
```

Both commands must exit zero. The overlay suite exercises the Glassity contract package; the core release gate proves only the checks it reports. A duration without the command's exit status is not gate evidence. A socket-denied release-gate run is environmental and must be rerun with the same command under the required localhost permission; it is not a pass.

The core workflow `.github/workflows/release-gate.yml` and core gate
`tools/km-release-gate.py` remain unchanged. The core gate must not discover the
Glassity `spec_tests` module.

## Protected-core boundary

Compare the completed slice with the approved specification base and inspect the working tree:

```bash
git diff --name-only 08d5302 HEAD
git diff --name-only 52469eb HEAD
git status --short
```

The first comparison preserves the complete governance history: it includes the
approved implementation plan at
`docs/superpowers/plans/2026-08-29-glassity-foundation-contract-corrections.md`.
Commit `52469eb` is therefore the approved pre-implementation baseline. From
that baseline, every changed path must remain under `glassity/contracts/`,
except for the sole approved workflow exception
`.github/workflows/glassity-contracts.yml`. The overlay checks are not added to
protected `tools/km-release-gate.py`; the two acceptance lanes remain separately
required.

## Proof limits

The schemas, fixtures, semantic validator, and declared provisioning receipt do not prove:

- runtime tenant isolation or route/database enforcement;
- actual Git object existence, ancestry, tree contents, commit attribution, or signatures;
- malware or content scanning, scanner availability, quarantine behavior, or archive limits;
- authorization to dereference a source pointer at runtime;
- authorization of the opaque resolver target or response at runtime;
- a trusted mapping from `actor_service_id` to an allowed producer role;
- deletion execution, provider expiry, backup-ledger replay, or erasure completion; or
- worker identity, credential lifetime, egress controls, termination behavior, or other worker runtime behavior.

Those properties require the later runtime and Git conformance evidence defined by the approved architecture decisions. A successful contract run must not be presented as evidence that any of them occurred.
