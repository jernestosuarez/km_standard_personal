# Capability: release-verification-scope

Which tree a release gate is a verdict about, which files it discovers as checks within that tree,
what it does with a check-shaped file it has not been asked to run before, how it reports where each
discovered check came from, and what it states about the files its scope still excludes.

## ADDED Requirements

### Requirement: A release gate is a verdict about the working tree

A release gate SHALL discover and evaluate the checks present in the working tree at the moment it
runs, and SHALL NOT limit discovery to the repository index. A gate that a contract requires to be
run before staging is a gate that will be run while newly authored files are untracked, and a verdict
derived from the index in that moment is a verdict about a different tree from the one being
committed.

#### Scenario: A newly authored check has not been staged

- **WHEN** a check-shaped file exists under a discovery root and is untracked
- **THEN** the gate discovers it
- **AND** it is evaluated by the same rules as a tracked check
- **AND** the verdict accounts for it

#### Scenario: An untracked check-shaped file cannot be parsed

- **WHEN** an untracked file under a discovery root carries a syntax error its interpreter rejects
- **THEN** the gate returns a failing or refusing verdict
- **AND** it names that file
- **AND** it does not return a passing verdict

#### Scenario: The tree holds no untracked check-shaped file

- **WHEN** every check-shaped file under every discovery root is tracked and every phase passes
- **THEN** the gate passes
- **AND** the verdict is identical to the verdict the same tree produced before this requirement

### Requirement: Discovery reports the provenance of what it discovered

A release gate SHALL state, on its coverage line, how many of the discovered checks were untracked,
and SHALL name each untracked discovered check in its run output. A coverage line exists so that a
recorded pass says what was looked at; a count that merges files the repository ships with files it
does not says less than it appears to.

#### Scenario: An untracked check is discovered and runs

- **WHEN** an untracked check-shaped file under a discovery root is discovered and executed
- **THEN** the run output names it and marks it as untracked
- **AND** the coverage line states how many discovered checks were untracked

#### Scenario: Every discovered check is tracked

- **WHEN** no discovered check is untracked
- **THEN** the coverage line states that count as zero rather than omitting the clause

### Requirement: An untracked discovered check is held to the added-check declaration rule

An untracked discovered check SHALL be held to the rule a release gate applies to a check the current
change ADDS. Such a check SHALL declare the version being drafted, or an explicit statement that no
unrepaired tree existed together with a reason, and SHALL NOT be permitted to plead that nothing was
recorded.

#### Scenario: An untracked check carries no declaration

- **WHEN** an untracked discovered check has no unrepaired-tree declaration in its leading comment
  block
- **THEN** the gate fails and names it

#### Scenario: An untracked check pleads that nothing was recorded

- **WHEN** an untracked discovered check declares the unrecorded token
- **THEN** the gate fails, because a check that does not yet exist in the repository has no history to
  plead

#### Scenario: An untracked check names the drafted version

- **WHEN** an untracked discovered check declares the version currently being drafted with a result
  text
- **THEN** the declaration phase accepts it

### Requirement: The excluded scope is stated rather than implied

A release gate SHALL state which files its discovery still cannot see. Where discovery honours the
repository's ignore rules, the gate SHALL record that an ignored check-shaped file is not discovered,
and SHALL record it as a residual gap rather than as a property that needs no mention.

#### Scenario: A check-shaped file is ignored

- **WHEN** a check-shaped file under a discovery root matches the repository's ignore rules
- **THEN** it is not discovered
- **AND** that exclusion is documented as a gap in the gate's own stated limits

#### Scenario: A phase deliberately remains index-scoped

- **WHEN** a static phase other than check discovery reads tracked paths only
- **THEN** the reason for the narrower scope is recorded alongside it

### Requirement: A contract that orders the gate relative to staging states which tree the gate reads

A maintainer contract SHALL state which tree the release gate discovers wherever that contract
prescribes when the gate is run relative to staging. An instruction to run the gate before staging is
correct only if the gate reads the working tree, and a contract that is silent on the point leaves the
maintainer to infer it from an instrument whose behaviour may change.

#### Scenario: The contract orders the gate before staging

- **WHEN** a contract instructs that the release gate is run before explicit staging
- **THEN** the contract states that the gate discovers checks in the working tree
- **AND** it states that a newly authored check therefore needs no staging to be seen

#### Scenario: The gate's discovery scope changes

- **WHEN** a change alters which tree the gate discovers
- **THEN** the contract's ordering instruction is reviewed and amended in the same change
