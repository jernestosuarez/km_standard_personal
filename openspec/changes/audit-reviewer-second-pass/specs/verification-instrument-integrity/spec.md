# Capability: verification-instrument-integrity

What an instrument may claim about how many places its own definitions are maintained in.

## ADDED Requirements

### Requirement: An instrument claiming a single definition maintains a single definition

An instrument SHALL NOT claim that a set it holds is defined in one place while maintaining that set
in several. Where its source states that adding a member is an edit to one place, that SHALL be true,
or the claim SHALL be replaced by an accurate statement of the several places in fact maintained.

Reducing the count of maintained definitions SHALL be preferred to describing the drift, where that
can be done without rendering the definition unreadable. Where a set is held as data and a second
surface argues each member again in prose, the argument SHALL be carried by the data beside the
member it argues, so that a member and the reasoning for it cannot drift apart.

A check asserting this property SHALL be **derived** and SHALL NOT enumerate the set's members: a
check that names each member is itself a further maintained definition of the set, and is the defect
it was written to detect. No surface of the instrument SHALL state a count of the set in prose; every
count SHALL be computed from the definition.

Where such a claim is found to have been **false at the time it was written**, it SHALL be corrected
in the record rather than dated, which is the treatment this standard already gives a false published
statement; a claim that was true when written and has been overtaken SHALL be dated instead. The two
SHALL be told apart by measurement against the tree the claim was written on, not by recollection.

A check written for this class SHALL be anchored so that a **quotation** of the removed wording is
not read as the claim itself. A repair to this class necessarily quotes what it removed, in the
version record, in the instrument's own account of what was wrong, and in the unrepaired-tree
declaration, and an unanchored check reports a file it has just repaired. Because narrowing a check
until the tree goes green is indistinguishable from a check that has stopped matching, the anchored
form SHALL be proved against a copy of the instrument carrying the removed wording as a live claim,
and SHALL be required to fire on it.

#### Scenario: The instrument states no count of its own set in prose

- **WHEN** the instrument's source is read for its own claims, with quotations and dated records
  excluded
- **THEN** no prose count of the set appears
- **AND** every printed count is computed from the definition

#### Scenario: A second enumeration beside the definition is a finding

- **WHEN** the instrument's header enumerates the set's members alongside the definition
- **THEN** the check reports it, naming the lines
- **AND** the check does so without naming any member

#### Scenario: The name the instrument points at is the name it defines

- **WHEN** the instrument's header names the identifier holding the single definition
- **THEN** that identifier is defined in the instrument
- **AND** a named identifier that is defined nowhere is reported

#### Scenario: The anchored check still fires on a live claim

- **WHEN** the anchored check is run against a copy of the instrument carrying the removed wording
  as a claim rather than as a quotation
- **THEN** the check fires
- **AND** the anchoring is therefore shown not to have silenced it

#### Scenario: Adding a member is an edit to one place

- **WHEN** a new member is added to the set
- **THEN** no other file and no other passage requires an edit for the instrument to remain accurate
- **AND** every surface that prints the set reflects the addition without being changed
