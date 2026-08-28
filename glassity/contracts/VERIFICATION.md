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
python3 -m unittest discover -s glassity/contracts/tests -p 'test_*.py' -v
```

Run the authoritative core release gate separately, directly, and without a pipe:

```bash
python3 tools/km-release-gate.py
```

Both commands must exit zero. The overlay suite exercises the Glassity contract package; the core release gate proves only the checks it reports. A duration without the command's exit status is not gate evidence. A socket-denied release-gate run is environmental and must be rerun with the same command under the required localhost permission; it is not a pass.

## Protected-core boundary

Compare the completed slice with the approved specification base and inspect the working tree:

```bash
git diff --name-only 29c8307d0b98d2859f34d140414b160883339c06 HEAD
git status --short
```

Every changed path in this slice must remain under `glassity/contracts/`. The overlay checks are not added to protected `tools/km-release-gate.py`; the two acceptance lanes remain separately required.

## Proof limits

The schemas, fixtures, semantic validator, and declared provisioning receipt do not prove:

- runtime tenant isolation or route/database enforcement;
- actual Git object existence, ancestry, tree contents, commit attribution, or signatures;
- malware or content scanning, scanner availability, quarantine behavior, or archive limits;
- authorization to dereference a source pointer at runtime;
- deletion execution, provider expiry, backup-ledger replay, or erasure completion; or
- worker identity, credential lifetime, egress controls, termination behavior, or other worker runtime behavior.

Those properties require the later runtime and Git conformance evidence defined by the approved architecture decisions. A successful contract run must not be presented as evidence that any of them occurred.
