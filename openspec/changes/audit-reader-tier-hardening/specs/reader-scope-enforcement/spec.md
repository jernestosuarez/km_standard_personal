# Capability: reader-scope-enforcement

How a reader's declared scope is parsed, validated and reported. This capability governs the
declaration only. It does not govern isolation, which is a hosting property and is stated as such.

## ADDED Requirements

### Requirement: Every declared scope token is validated independently

The reader scanner SHALL split a declared scope on its delimiter and evaluate each token on its own.
A declaration SHALL be rejected when any single token is an open token, regardless of that token's
position in the list, and regardless of how many other tokens are well formed.

#### Scenario: Wildcard token appears first in a list

- **WHEN** a reader declares `scope: *, hub-alpha`
- **THEN** the scanner rejects the declaration
- **AND** it does not report the scope as closed
- **AND** it names the offending token

#### Scenario: Wildcard token appears last in a list

- **WHEN** a reader declares `scope: hub-alpha, *`
- **THEN** the scanner rejects the declaration

#### Scenario: Reserved open token appears inside a list

- **WHEN** a reader declares `scope: hub-alpha, all, hub-beta`
- **THEN** the scanner rejects the declaration

#### Scenario: A legitimate closed scope is accepted

- **WHEN** a reader declares `scope: hub-alpha, hub-beta`
- **THEN** the scanner accepts the declaration
- **AND** it reports a closed scope of two hubs

### Requirement: Malformed scope entries are rejected

The reader scanner SHALL reject a scope containing an empty entry, a duplicate token, or a token that
is not a well formed hub identifier. An empty entry SHALL NOT be silently absorbed into an adjacent
token, and a delimiter SHALL NOT become part of a hub name.

#### Scenario: Trailing delimiter produces an empty entry

- **WHEN** a reader declares `scope: hub-alpha,`
- **THEN** the scanner rejects the declaration
- **AND** it does not report a hub whose name contains the delimiter

#### Scenario: Repeated delimiter produces an empty entry

- **WHEN** a reader declares `scope: hub-alpha,, hub-beta`
- **THEN** the scanner rejects the declaration

#### Scenario: The same hub is declared twice

- **WHEN** a reader declares `scope: hub-alpha, hub-alpha`
- **THEN** the scanner rejects the declaration
- **AND** it names the duplicated token

#### Scenario: A token is not a well formed hub identifier

- **WHEN** a reader declares a scope token that does not match the hub identifier form
- **THEN** the scanner rejects the declaration
- **AND** it names the offending token

### Requirement: The scanner fails closed on a declaration it cannot evaluate

The reader scanner SHALL refuse, rather than pass, when it cannot evaluate the declaration it was
given. A scope that cannot be parsed SHALL NOT produce a passing result on the grounds that no
violation was observed.

#### Scenario: A scope line is present but cannot be parsed

- **WHEN** a reader declares a scope line the parser cannot evaluate
- **THEN** the scanner refuses
- **AND** it reports that it could not evaluate the declaration, rather than reporting a pass

#### Scenario: The reader context cannot be read

- **WHEN** the scanner is pointed at a context that does not exist or cannot be read
- **THEN** the scanner refuses
- **AND** it does not report a well formed declaration

### Requirement: An absent scope declares a full reader

The reader scanner SHALL treat the absence of a scope declaration as a full reader over the readable
estate, and SHALL report that outcome explicitly rather than silently.

#### Scenario: No scope is declared

- **WHEN** a reader declares no scope
- **THEN** the scanner accepts the declaration
- **AND** it reports a full reader rather than a closed scope

### Requirement: The scanner states the coverage it actually has

The reader scanner SHALL state, on every run, that it validated the reader's declaration and did not
validate isolation. It SHALL NOT report or imply that a reader is prevented from reading outside its
declared scope.

#### Scenario: A scoped reader passes validation

- **WHEN** the scanner accepts a well formed closed scope
- **THEN** its coverage line states that the declaration was validated
- **AND** its coverage line states that isolation was not validated

### Requirement: A repaired control is proved against its unrepaired form

The bypass scenarios in this capability SHALL be executed against the scanner as it behaved before
repair, and SHALL fail there. A canary that passes against both the repaired and the unrepaired
scanner does not establish that it detects the defect.

#### Scenario: Canaries are run against the unrepaired scanner

- **WHEN** the bypass scenarios are executed against the pre-repair scanner
- **THEN** they fail
- **AND** the same scenarios pass against the repaired scanner
