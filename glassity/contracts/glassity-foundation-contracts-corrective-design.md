---
title: Glassity Foundation Contracts Corrective Design
status: approved-for-implementation
date: 2026-08-29
base_commit: 9226ef91608736dd4447b943f7ce5ed83d95f933
supersedes_in_part: glassity-foundation-contracts-design.md
---

# Glassity foundation contracts corrective design

## 1. Purpose

This design corrects verification-boundary and conformance gaps found after the
foundation-contract implementation reached commit `9226ef9`. It does not change
the approved architecture decisions or authorize application, provisioning, or
runtime implementation.

The correction has four goals:

1. make the Glassity contract suite a genuinely independent verification lane;
2. pin the complete authority-matrix row rather than only part of it;
3. add the mutation canaries required by the approved specification; and
4. narrow claims about resolvers, dates, identities, and Git ancestry to what the
   validator can actually prove.

## 2. Finding that triggers this correction

The implemented tests live at `glassity/contracts/tests/test_contracts.py`.
Because the core release gate discovers nested `tests/` and `scripts/`
directories, `tools/km-release-gate.py` executes the Glassity suite. That
contradicts the documented two-lane model and makes the core lane depend on the
Glassity test-only dependency.

The repository workflow `.github/workflows/release-gate.yml` runs only the core
gate and does not install `glassity/contracts/requirements-test.txt`. A passing
run would therefore depend on mutable runner state rather than a declared,
pinned dependency.

The implementation also omits several named negative directions and validates
only part of each authority row. Those gaps do not invalidate the architecture,
but they prevent the package from satisfying its own approved acceptance
criteria.

## 3. Selected verification architecture

### 3.1 Two independent lanes

The selected approach is a dedicated Glassity contract lane.

The core authoritative lane remains unchanged:

```text
python3 tools/km-release-gate.py
```

The Glassity specification lane becomes:

```text
python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v
```

The test module moves from:

```text
glassity/contracts/tests/test_contracts.py
```

to:

```text
glassity/contracts/spec_tests/test_contracts.py
```

The directory deliberately avoids the names `tests` and `scripts`, so the core
gate does not discover it. The Glassity command is explicit and remains the
authority for the overlay package.

### 3.2 Dedicated workflow and governed exception

A new workflow is added at:

```text
.github/workflows/glassity-contracts.yml
```

This is a narrow, explicit exception to the protected-core boundary. The
exception permits only this new workflow file. It does not authorize changes to
`.github/workflows/release-gate.yml`, `tools/km-release-gate.py`, or any other
protected baseline path.

The workflow:

1. uses the repository's existing pinned checkout action;
2. uses `actions/setup-python` v7.0.0 pinned to commit
   `5fda3b95a4ea91299a34e894583c3862153e4b97`;
3. selects Python 3.9, the minimum supported repository runtime;
4. installs `glassity/contracts/requirements-test.txt` with pip;
5. runs the contract validator self-check; and
6. runs the explicit `spec_tests` discovery command.

The setup-python pin is traceable to the official action commit:
<https://github.com/actions/setup-python/commit/5fda3b95a4ea91299a34e894583c3862153e4b97>.

The two workflows remain separate. A green Glassity workflow does not replace a
green core release gate, and a green core release gate does not imply Glassity
contract conformance.

### 3.3 Rejected alternatives

The following alternatives remain rejected:

- **Leave the suite under `tests/` and install its dependency in the core
  workflow.** This silently turns the overlay into a core-gate dependency and
  modifies two protected paths.
- **Merge both commands into one authoritative gate.** This erases the approved
  separation between core and edition-specific verification.
- **Keep the Glassity lane manual.** This makes declared dependency installation
  and repeatable verification optional.

## 4. Complete authority-row enforcement

The validator's canonical authority definition expands from partial fields to
the complete closed row:

- `system_of_record`;
- `hub_representations`;
- `allowed_producers`;
- `envelope_types`;
- `classification_policy_refs`;
- `retention_policy_ref`; and
- `forbidden_locations`.

Scalar values must match exactly. Array fields are compared as exact sets: no
missing and no additional values. Reordering alone is not a mismatch.

Any difference uses the existing `AUTHORITY_SYSTEM_MISMATCH` reason code. The
documentation is tightened to define that code as a mismatch in the closed
authority definition, not merely the `system_of_record` scalar.

The authority suite gains descriptors that assign each of these classes to the
tenant Git hub and must reject each one:

- raw upload;
- app object;
- app event; and
- pending answer.

The valid deployment binding includes the authority-approved classification
policy reference. An envelope's classification policy references must be
present in both:

1. the deployment binding's `tenant_policy_refs`; and
2. the matched authority row's `classification_policy_refs`.

Changing the binding fixture requires recomputing the binding digest declared by
the provisioning receipt. The validator continues to recompute rather than
trust declared digests.

### 4.1 Producer identity boundary

The matrix pins the allowed producer-role declarations. The envelope's
`actor_service_id` is evidence of the claimed service identity; it is not a
trusted role assertion.

No client-declared `actor_role` field is added. Mapping an authenticated workload
identity to an authorized producer role belongs to runtime conformance at the
inbound adapter and worker boundary. The specification must not claim that a
standalone JSON document can prove that authorization.

## 5. Required mutation canaries

### 5.1 Envelope identifiers

The schema retains the canonical UUID-v4 lowercase form and closed length. The
suite adds distinct mutations for:

- uppercase or mixed-case UUID;
- a UUID version other than v4;
- an overlong identifier;
- a valid UUID with a prefix;
- a valid UUID with a suffix; and
- a value containing non-canonical or control characters.

Every case must fail with `ENVELOPE_ID_INVALID`.

### 5.2 Destinations

The safe destination remains exactly `_inbox/<envelope-id>.json`, recomputed
from the validated identifier. The suite adds mutations for:

- a `sources/` destination;
- an absolute path;
- parent-relative traversal;
- percent-encoded traversal; and
- an alternate backslash separator.

Every case must fail with `UNSAFE_DESTINATION`.

### 5.3 Receipt ancestry claim

The provisioning-receipt schema description is itself governed metadata. It
must state that the receipt validates the declared expected parent relationship
but does not prove actual Git ancestry.

Schema loading validates that statement. A test mutates the schema metadata to
claim that the receipt proves Git ancestry and requires `SCHEMA_INVALID`. Actual
commit ancestry remains an implementation-conformance check.

### 5.4 Existing reasons remain exact

All existing invalid descriptors continue to assert their named reason code.
The new canaries do not weaken a precise failure into a generic non-zero test.

## 6. Resolver-reference constraint

The pointer resolver is constrained to an opaque, non-credential-bearing
reference grammar:

```text
^[A-Za-z][A-Za-z0-9+.-]*:[A-Za-z0-9][A-Za-z0-9:._/-]*$
```

The value may not contain whitespace, control characters, `://`, `?`, `#`, `@`,
or `=`. This excludes HTTP URLs, query-bearing signed URLs, user-info syntax,
fragments, and common embedded credential forms while allowing existing URN-like
fixtures.

The suite includes HTTP, presigned/query, user-info, query, and fragment
mutations. Each fails with the existing pointer policy reason.

This is a syntactic safety boundary. It cannot prove that the external resolver
named by an opaque reference is correctly authorized or free of secrets. Runtime
resolver authorization and response handling remain conformance work.

## 7. Calendar and chronology checks

Regex shape alone is not accepted as date validation.

- Legal-hold `review_date` must be a real Gregorian calendar date in
  `YYYY-MM-DD` form.
- Binding `created_at` and `effective_at`, and receipt `initialized_at` and
  `overlay_applied_at`, must be real UTC timestamps in exact
  `YYYY-MM-DDTHH:MM:SSZ` form.
- A binding requires `created_at <= effective_at`.
- A receipt requires `initialized_at <= overlay_applied_at`.

Invalid dates and timestamps fail `SCHEMA_INVALID`. A valid receipt whose event
order is reversed fails `PROVISIONING_ORDER_INVALID`. No new reason code is
introduced.

## 8. Documentation corrections

The implementation updates these records so that commands, paths, and claims
match the corrected behavior:

- `glassity/contracts/README.md`;
- `glassity/contracts/VERIFICATION.md`;
- `glassity/contracts/glassity-foundation-contracts-design.md`; and
- `glassity/contracts/glassity-foundation-contracts-implementation-plan.md`.

The original records remain historical evidence. Their verification sections
are amended to point to this corrective design and the dedicated workflow.

## 9. Expected implementation file set

The correction may change only:

- files under `glassity/contracts/` needed for schemas, fixtures, validator,
  tests, and documentation; and
- the approved exception `.github/workflows/glassity-contracts.yml`.

The old `glassity/contracts/tests/test_contracts.py` is removed only after its
contents and coverage have moved to `spec_tests/`.

No other protected baseline path may change.

## 10. Acceptance criteria

Implementation is acceptable only when all of the following are evidenced:

1. `python3 glassity/contracts/validate_contracts.py --self-check` exits zero.
2. The explicit `spec_tests` unittest command exits zero with all positive,
   negative, recomputation, and mutation cases passing.
3. A clean direct `python3 tools/km-release-gate.py` exits zero and does not
   discover or require a declaration for the Glassity `spec_tests` module.
4. The dedicated workflow performs the same dependency installation and
   Glassity commands used locally.
5. Mutating each complete authority-row field produces
   `AUTHORITY_SYSTEM_MISMATCH`.
6. Raw-upload, app-object, app-event, and pending-answer Git assignments are each
   rejected by an exact reason assertion.
7. Every identifier, destination, ancestry-claim, resolver, calendar, and
   chronology mutation named in this design fails for its exact expected reason.
8. The validator recomputes every declared digest and idempotency value covered
   by the approved specification.
9. `git diff --check` is clean.
10. The final diff contains no changed protected-core path other than the single
    approved workflow exception.
11. Both lane exit statuses are recorded explicitly; elapsed time alone is not
    gate evidence.
12. Supervisor review is a hard stop before push or implementation acceptance.

## 11. Non-goals

This correction does not implement:

- application or provisioning runtime behavior;
- trusted workload-identity-to-producer-role authorization;
- actual Git ancestry verification;
- external resolver authorization;
- production persistence, tenant isolation, or release; or
- any change to the five approved architecture decisions.

## 12. Disposition

This corrective design is approved for implementation as the bounded completion
of the foundation contract package. Approval authorizes implementation of the
listed corrections and the single workflow exception only. It does not approve
runtime behavior, production persistence, or release. Supervisor review remains
the hard stop before push or implementation acceptance.

## 13. Implementation evidence

The corrective implementation was exercised directly on 2026-08-29. Exit
status, rather than elapsed time, is the acceptance evidence:

| Check | Observed result |
|---|---|
| `python3 -m pip install --disable-pip-version-check -r glassity/contracts/requirements-test.txt` | exit `0`; pinned `jsonschema==4.25.1` satisfied |
| `python3 glassity/contracts/validate_contracts.py --self-check` | exit `0`; `Draft202012Validator` and `jsonschema==4.25.1` reported |
| `python3 -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v` | exit `0`; 70 tests run, 0 failures, 0 errors |
| Five required `python3 -m json.tool` schema commands | each exit `0` |
| `git diff --check` | exit `0` |
| `python3 tools/km-release-gate.py` in the restricted sandbox | exit `1`; only `tests/test_km_cockpit.sh` failed because localhost bind was denied with `PermissionError: [Errno 1] Operation not permitted` |
| Identical direct, unpiped `python3 tools/km-release-gate.py` rerun with localhost permission | exit `0`; 35 checks discovered, 30 run, 5 skipped as declared instruments |

The successful core gate did not discover
`glassity/contracts/spec_tests/test_contracts.py`. Its discovery remained under
the core `tests/` and `scripts/` paths, confirming the two-lane boundary.

The scope result has two explicit views:

1. `08d5302..HEAD` contains the approved governance plan at
   `docs/superpowers/plans/2026-08-29-glassity-foundation-contract-corrections.md`,
   the sole workflow exception `.github/workflows/glassity-contracts.yml`, and
   paths under `glassity/contracts/`.
2. `52469eb..HEAD`, the approved implementation delta, contains only
   `.github/workflows/glassity-contracts.yml` and paths under
   `glassity/contracts/`; no other protected-core path changed.

This evidence accepts the bounded corrective implementation for Supervisor
review. It does not prove runtime resolver authorization, a trusted
`actor_service_id`-to-producer-role mapping, actual Git ancestry, production
persistence, tenant isolation, or release. Supervisor review remains the hard
stop before push or implementation acceptance.
