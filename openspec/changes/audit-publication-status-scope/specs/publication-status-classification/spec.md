# Capability: publication-status-classification

Where a version's publication status is declared, what counts as a declaration and what counts as a
quotation of one, why the rule is anchored to the opening of a row's description cell rather than
applied to the whole of it, why one classifier serves every instrument that reads publication status,
what such an instrument refuses rather than answers, and what it states about its own coverage.

## ADDED Requirements

### Requirement: Publication status is declared at the opening of a row's description

A version-history row SHALL be read as unpublished when, and only when, its description cell opens
with a draft declaration. The declaration MAY be preceded by whitespace and by emphasis markers, and
by nothing else. A draft declaration appearing later in the same cell SHALL carry no status, because
a description that reproduces a declaration is quoting one.

#### Scenario: A row opens with the declaration

- **WHEN** a description cell opens with `**DRAFT, awaiting owner push.**` or with
  `**DRAFT — awaiting owner push.**`
- **THEN** the version is classified unpublished
- **AND** presentation markers around the token do not change the answer

#### Scenario: A published row quotes a declaration mid-description

- **WHEN** a description cell opens with a published stamp and reproduces another row's draft
  declaration verbatim further along, as evidence for a statement it is making
- **THEN** the version is classified published
- **AND** the quotation is read as quoted text rather than as a status claim

#### Scenario: A row opens with a published stamp

- **WHEN** a description cell opens with `Drafted and published <date> (owner push).` or with
  `Drafted <date>; published <date> with <version>.`
- **THEN** the version is classified published

#### Scenario: The token appears in an unrecognised opening form

- **WHEN** a description cell opens with something that is neither whitespace, an emphasis marker nor
  the declaration token
- **THEN** the version is classified published
- **AND** that strict direction is stated, because an instrument reading this classification must
  behave safely on it rather than silently withdraw coverage

### Requirement: The classification reads the description cell and never the whole row

An instrument SHALL split a version-history row into its version, its date and its description before
classifying it, and SHALL apply the classification to the description alone. A rule anchored to the
opening of a string that begins with the date column can never match, and a rule applied to the whole
row reads a token wherever it sits.

#### Scenario: The date column precedes the description

- **WHEN** a row is `| v9.9 | 2026-01-01 | **DRAFT, awaiting owner push.** ... |`
- **THEN** the classification is applied to the text after the date column
- **AND** the date column is not consulted for status

#### Scenario: A row cannot be split into three cells

- **WHEN** a line names a version but carries no description cell
- **THEN** the instrument that requires a description refuses or reports the row as unreadable rather
  than classifying it

### Requirement: One classifier serves every instrument that reads publication status

Publication status SHALL be derived by a single shared classifier rather than by a pattern copied
into each instrument. Two instruments reading the same table SHALL NOT be able to disagree about a
row, and a change to the rule SHALL take effect in every instrument without an edit to any of them.

#### Scenario: A second instrument is added

- **WHEN** a new check needs to know whether a version is published
- **THEN** it imports the shared classifier and holds no pattern of its own

#### Scenario: The rule is refined

- **WHEN** the definition of a draft declaration changes
- **THEN** one file changes and every instrument's answer changes with it

#### Scenario: A maintainer looks for the rule

- **WHEN** either instrument is read for its definition of an unpublished row
- **THEN** the definition is not there, and the shared classifier is named as where it lives

### Requirement: The shared classifier is covered by canaries and declared to the release gate

The shared classifier SHALL be proved in both directions by its own canaries: at least one case per
real opener form, at least one case for a published row quoting a declaration, and at least one case
for a genuinely drafted row. Because it is a module rather than a runnable check, it SHALL declare
itself to the release gate and name those canaries, and the gate SHALL refuse unless the named
canaries run in the same pass.

#### Scenario: The classifier is discovered by the gate

- **WHEN** the release gate discovers the shared classifier under a scripts directory
- **THEN** the classifier declares that it is an instrument, states why it cannot self-run, and names
  its canaries
- **AND** the gate refuses if those canaries are not themselves a check that runs in the same pass

#### Scenario: A module would otherwise pass by doing nothing

- **WHEN** a module with no entry point is executed by a runner that reads exit status
- **THEN** it would exit zero whatever it contained, which is a check that cannot fail
- **AND** declaring it an instrument is what stops that exit status being read as evidence

### Requirement: Both instruments are proved against a tree where the quotation was live

The repair SHALL be proved against real material and not against synthetic likenesses alone. Each
instrument SHALL be run against the repository as it stood at the commit whose row carried a quoted
declaration, and SHALL classify that version as the tree's own opener declares.

#### Scenario: The draft tree still classifies the drafted version as unpublished

- **WHEN** each instrument runs against the tree at the v1.50 draft commit, whose row opens with a
  draft declaration and quotes another one further along
- **THEN** v1.50 is classified unpublished, by its opener
- **AND** the repair has not blinded the instruments in the other direction

#### Scenario: The same row with a published opener flips both verdicts

- **WHEN** the same tree is taken with only the row's opener flipped to the published stamp
- **THEN** before the repair both instruments classify the version unpublished and both exit zero
- **AND** after the repair both classify it published

### Requirement: A status classification is never allowed to withdraw coverage in silence

An instrument reading this classification SHALL make the consequence of an unpublished verdict
visible in its own output, so that a version excluded from judgement is named rather than merely
absent from it. An excluded version that nobody can see is indistinguishable from a version that was
examined and found clean.

#### Scenario: A version is excluded from date comparison

- **WHEN** a version is classified unpublished by the date-integrity check
- **THEN** the passing run names it in the excluded list with the reason it was excluded

#### Scenario: A version is exempted from marking judgement

- **WHEN** a version is classified unpublished by the published-not-draft check
- **THEN** the passing run states how many versions were classified and how the count splits between
  published and unpublished

### Requirement: The classification models one class and states its limit

This capability SHALL be read as modelling one class: whether a row declares itself still in draft at
the point a declaration is made. It SHALL NOT be read as evidence that the version-history table is
honest, that a row describes what the version did, or that a version absent from the table would be
noticed.

#### Scenario: The table claims a publication that never happened

- **WHEN** a row opens with a published stamp for a version the owner never pushed
- **THEN** every instrument reading this classification agrees with the row
- **AND** the limit is stated rather than left to be inferred, because a check cannot audit its own
  oracle

#### Scenario: Both directions are proved

- **WHEN** the classifier is shown to fire on a declaration and not to fire on a quotation
- **THEN** it is proved to fire on the class it models
- **AND** that is never proof that it models the right class
