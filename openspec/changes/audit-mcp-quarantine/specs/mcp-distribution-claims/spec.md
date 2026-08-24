# Capability: mcp-distribution-claims

The correspondence between what the optional query surface promises in its documentation and what its
implementation performs, including whether its installation instructions resolve to a configuration it
can run under.

## ADDED Requirements

### Requirement: Documentation states only guarantees the implementation keeps

The surface's documentation SHALL state only those protections its implementation actually performs,
and SHALL name an absent protection as absent. A guarantee that holds on one retrieval path SHALL NOT
be written as though it holds on all of them.

#### Scenario: A guarantee holds on one path and not another

- **WHEN** a lifecycle guarantee is enforced on the listing path and not on the direct-identifier path
- **THEN** the documentation does not state the guarantee unconditionally
- **AND** it names the path on which the guarantee does not hold

#### Scenario: A required gate is not implemented at all

- **WHEN** the standard requires a gate that the implementation performs nowhere
- **THEN** the documentation names that gate as not enforced
- **AND** it does not omit the gate silently

#### Scenario: Documentation and implementation agree

- **WHEN** every protection named in the documentation is performed on every path it claims
- **THEN** the distribution is conformant

### Requirement: A stated protection is traceable to the code that performs it

Each protection the documentation claims SHALL be traceable to the implementation that performs it, so
that a claim surviving the removal of its enforcement is detectable. A claim with no corresponding
enforcement SHALL be treated as a defect rather than as documentation drift.

#### Scenario: Enforcement is removed and the claim remains

- **WHEN** the code performing a claimed protection is removed or bypassed
- **THEN** the surviving documentation claim is reported as a defect

### Requirement: Installation instructions resolve to a runnable configuration

The surface's installation instructions SHALL resolve to a dependency and interpreter configuration
under which the shipped implementation runs. An unpinned instruction that resolves to an interface the
implementation does not use SHALL be corrected or replaced with a stated migration.

#### Scenario: The unpinned instruction resolves to an incompatible interface

- **WHEN** the documented installation command resolves to a dependency version whose interface the
  implementation does not use
- **THEN** the instructions are corrected to a compatible pinned configuration, or the required
  migration is stated

#### Scenario: The stated interpreter floor is lower than the dependency requires

- **WHEN** the documentation states an interpreter version below what the resolved dependency requires
- **THEN** the stated floor is corrected to the version actually required

#### Scenario: A clean environment follows the instructions

- **WHEN** the documented instructions are followed in a clean environment
- **THEN** the surface starts, or it reports its quarantined state, rather than failing on an import
