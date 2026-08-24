## Why

The optional query surface shipped in the hub template does not enforce the access contract the
standard requires of every consuming surface, and its own documentation states a guarantee it does not
keep. Both were reproduced first-hand against the published tree.

The standard requires a consuming surface to expose an entity only when it is committed at `HEAD`,
lifecycle-active, within the caller's access clearance, and present in a projection manifest. The
surface applies the first gate everywhere, the second on one path only, and the third and fourth
nowhere at all. `get_entity()` returns raw entity text after a committed-state check alone, so a
direct identifier lookup returns retired and superseded content that the listing path correctly
withholds. No sensitivity, clearance, or manifest logic exists anywhere in the implementation.

The surface's documentation asserts that retired and superseded notes are never returned. That
sentence is false on the direct-identifier path, which is the worst form of this defect: an operator
reading the documentation has been told a control exists, and will place material behind it.

The premise underneath is that commitment equals clearance. Committing a fact records it. It does not
decide who may read it.

This change quarantines the surface. It does not repair it, because an operator relying on a false
guarantee today is the urgent problem, and the repair is larger than the removal of the claim.

## What Changes

- The query surface is placed in a declared quarantined state in which it refuses to serve, rather
  than serving under a contract it cannot enforce.
- The quarantine is discoverable by an operator before installation, and by anyone who starts the
  surface.
- The documentation's enforcement claims are corrected to state only the guarantees the code
  implements, with the unenforced gates named as absent rather than omitted.
- The dependency instructions are corrected so they resolve to a configuration the surface can
  actually run under, after the installed interface version is verified.
- **BREAKING** for any deployment that had this optional surface enabled. That is the intended
  outcome: the surface stops answering rather than answering unsafely.

## Capabilities

### New Capabilities

- `mcp-surface-state`: whether the optional query surface serves or refuses, how that state is
  declared, and what it does when it cannot enforce its contract.
- `mcp-distribution-claims`: the correspondence between what the surface's documentation promises and
  what its implementation performs, including its installation instructions.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so both
capabilities are introduced as `ADDED`.

## Impact

- **Affected material**: the optional query surface shipped in the hub template and its documentation.
- **Affected deployments**: any deployment that enabled the surface. It stops serving on adoption. A
  deployment that never enabled it is unaffected, and no hub content changes in either case.
- **Exposure to be stated, not estimated**: the version record names which content classes were
  reachable by which path, so a deployment can assess what it actually ran rather than guess.
- **Not in scope**: implementing the four gates. That is a separate change,
  `audit-mcp-projection-gates`, and it lifts the quarantine when its contract is proved. The two must
  not share a completion state, because they are two published steps.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
