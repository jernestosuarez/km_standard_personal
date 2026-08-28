# Glassity foundation contracts

This directory contains machine-testable specification contracts for the Glassity overlay. The validator checks contract documents and synthetic fixtures; it is not application or provisioning runtime code.

Install the pinned development and test dependency:

```bash
python3 -m pip install -r glassity/contracts/requirements-test.txt
```

Check that the full JSON Schema Draft 2020-12 validation runtime is available:

```bash
python3 glassity/contracts/validate_contracts.py --self-check
```

The validator is read-only. It never mutates a tenant hub and does not prove runtime behavior, Git ancestry, tenant isolation, worker controls, or release readiness.
