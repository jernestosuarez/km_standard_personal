## Why

Audit finding **F-13** (Low to Medium) states, verbatim:

> Generic specification filename violates cache-safety policy. The repository guidance requires
> project-prefixed spec and plan filenames to avoid cross-project cache collisions.
> `components/km-cockpit/SPEC.md` is generic and heavily referenced.
> **Recommendation:** Rename it to a project-specific name such as `KM-COCKPIT-SPEC.md` and update
> references atomically.

The finding rests on a premise about this repository: that it holds a cache-safety convention
requiring project-prefixed names for specification and plan documents. **That premise was checked
before anything was renamed, and it does not hold.** No such convention exists in `STANDARD.md`, in
`README.md`, in the Standard Maintainer contract at `agents/km-hub-builder/SKILL.md`, in the active
deployment profile, in the organization overlay, in any check the repository ships, or anywhere else
in the tracked tree. The words "cache safety", "cache collision" and "project-prefixed" appear in
exactly one place in the repository, and it is not repository guidance.

This is the last outstanding technical item from the audit of 2026-08-22 before the repository is
forked. Three of that audit's findings have already failed verification during this remediation, so
the finding was measured rather than executed. This package records the measurement and the
disposition, so that a fork's reader who finds `SPEC.md` still generically named finds the reason
beside it rather than an open item nobody explained.

## What Changes

**Nothing in the repository changes.** No file is renamed, no reference is edited, no check is added,
and no version is minted. What this package adds is the record of an investigation and its result.

- **The cited convention does not exist here, and it is not invented to satisfy the finding.** The
  only text in the tree expressing the idea is builder constraint 7 of
  `openspec/changes/audit-remediation-2026-08-22/KM-STANDARD-OPENSPEC-REVIEW.md`: *"Use
  project-prefixed names for specification and build-plan documents."* That file is an external
  review of 2026-08-22 addressed to whoever would restructure the OpenSpec packages. It is a received
  artifact committed as a record, it binds one restructuring task, and its constraint is about the
  documents that task would produce. It is not a rule of this repository, it was never adopted as
  one, and no instrument reads it.
- **The reference count is recorded rather than described.** The audit's word is "heavily
  referenced". Measured: **26 occurrences across six tracked files.** Three are resolvable Markdown
  links. Nine sit inside seven dated version-ledger rows that the repository's own doctrine forbids
  rewriting.
- **The rename, performed as recommended, would create the defect this remediation has already
  published a check to close.** Updating "every reference atomically" reaches seven dated ledger
  rows. The repository rules, at v1.45 and again at v1.50, that a dated record corrected to agree
  with the present is falsified rather than repaired. So the recommendation forces a choice between
  falsifying seven ledger rows and leaving nine occurrences naming a file no reader can open, which
  is the F-04 class.
- **The premise is also contradicted by the tree it describes.** `SPEC.md` is the only file in the
  repository carrying that basename. `README.md` occurs 16 times, `SKILL.md` 24 times, and `spec.md`,
  `tasks.md`, `proposal.md` and `design.md` occur 13, 13, 13 and 12 times. The finding singles out
  the one generic specification name that is unique in the tree, while the names that actually repeat
  are the ones OpenSpec requires.
- **No check is added.** See the design, Decision 3.
- Not **BREAKING**. No obligation is added or withdrawn, no schema changes, no shipped surface
  changes, and no deployment inherits anything.

## Capabilities

### New Capabilities

None. This change adds no requirement to the standard, and it carries no delta specification.
`openspec validate audit-spec-filename-convention --strict` therefore fails with *"Change must have
at least one delta"*, exactly as `audit-licence-honesty-and-record` does. That failure is the honest
outcome here. A delta specification would mean writing the cache-safety requirement into the standard
so that a validator has something to read, which would grant the finding's premise the authority the
investigation just established it does not have. See the design, Decision 4.

### Modified Capabilities

None.

## Impact

- **Affected material**: this package only. Three files under
  `openspec/changes/audit-spec-filename-convention/`, tracked as the governance record. No file
  outside that directory is touched.
- **Affected deployments**: none. `components/km-cockpit/SPEC.md` keeps its name and its path, so
  every deployment that pins, reads or cites it is unaffected, and no hub turns red.
- **Not in scope**: renaming `components/km-cockpit/SPEC.md`, editing any reference to it, and
  editing the seven dated ledger rows that name it.
- **Not in scope**: writing a project-prefix rule into `STANDARD.md` or the maintainer contract. The
  finding presupposes such a rule; a remediation that creates it in order to comply with it would be
  a change with no authority behind it.
- **Not in scope**: editing `KM-STANDARD-OPENSPEC-REVIEW.md`. It records what an external reviewer
  asked for on 2026-08-22 and it stays as written.
- **Owner boundary unchanged**: this change records a disposition. Whether the finding is closed on
  this reasoning is the owner's decision, and no version is minted for it.
