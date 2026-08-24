# Capability: ledger-date-integrity

What a version-history row's date column asserts, how the commit that published a version is resolved
from the repository rather than from a table held in a check, which timezone the comparison is made
in, how a drafted version differs from an unresolvable one, when the check refuses rather than
returns a verdict, what a passing run states, and on what terms a false date in published text is
corrected in the ledger while the pushed commit and tag carrying it are left alone.

## ADDED Requirements

### Requirement: A version-history row's date is the date its publish commit was made

The date column of a version-history row SHALL state the day the version was published, and that day
SHALL be derived from the commit that published it rather than from any other source. A date carried
into the row from a staging brief, from a prior field of the same row, or from a maintainer's
recollection is a claim about the tree that the tree does not support, and a version SHALL NOT
publish carrying one.

#### Scenario: A publishing session runs past midnight

- **WHEN** a version is drafted on one day and pushed after midnight on the next
- **THEN** the row's date column states the day of the publish commit and not the day of the draft
- **AND** the stamp in the row's description states the same day as the date column

#### Scenario: The staging brief carries a date

- **WHEN** a brief prepared before the push names a publication date
- **THEN** that date is treated as an expectation and the row is stamped from the publish commit
- **AND** the brief's date is never copied into the row unexamined

#### Scenario: The ritual is applied to half the row

- **WHEN** a publishing commit updates the row's stamp and leaves the date column at the draft date
- **THEN** the row contradicts itself and the version is not correctly published
- **AND** both fields are derived from the same commit so they cannot disagree

### Requirement: The publish commit is resolved from the repository and never from a table in the check

The check SHALL resolve each version to its publish commit by reading the repository: an annotated
tag bearing the version identifier where one exists, and a search of commit subjects where one does
not. It SHALL NOT carry a hardcoded mapping of versions to commits or to dates, so that tagging a
version, or publishing a new one, changes the check's answer with no edit to the check. The method
that resolved each version SHALL be reported.

#### Scenario: A version carries an annotated tag

- **WHEN** a tag bearing the version identifier resolves to a commit
- **THEN** that commit is the publish commit and the resolution method is reported as the tag

#### Scenario: A version predates tagging

- **WHEN** no tag bears the version identifier and a commit subject opens with it
- **THEN** that commit is the publish commit and the resolution method is reported as the subject search

#### Scenario: A maintainer looks in the check for the list of publication dates

- **WHEN** the check is read for the mapping it uses
- **THEN** no such list exists in it
- **AND** the tags and the commit subjects are named as the sources the mapping is derived from

#### Scenario: Two commits carry the same version subject on different branches

- **WHEN** a subject search returns more than one candidate and they do not agree on a date
- **THEN** the version is reported as unresolved and ambiguous rather than resolved to either one

### Requirement: The comparison is made in the repository's own recorded timezone

The check SHALL compare the row's date column against the author date of the publish commit as
recorded in that commit's own UTC offset, not normalised to UTC and not shifted into the reader's
locale. A publication is an act performed by a person on a day, and the offset the commit records is
the offset that person was in.

#### Scenario: A publish commit falls shortly after local midnight

- **WHEN** a publish commit is authored at `00:24:40 +0200`
- **THEN** its publication day is the local day, and a row naming the previous day disagrees with it
- **AND** normalising to UTC would report that row as correct, which is the wrong class

#### Scenario: The check runs on a machine in another timezone

- **WHEN** the check runs where the local offset differs from the commit's recorded offset
- **THEN** the verdict is unchanged, because the commit's own offset is what is read

### Requirement: A drafted version is an exclusion and an unresolvable version is a coverage gap

The check SHALL distinguish three outcomes for a row and SHALL NOT collapse them. A version the
ledger declares still drafted SHALL be excluded, because a version awaiting its owner push has no
publish commit by construction and reporting it as a gap would be a permanent false gap. A version
with no resolvable publish commit SHALL be reported as a stated coverage gap on every run, named,
and never folded into the verdict in either direction. Every other version SHALL be compared.

#### Scenario: The ledger declares a version drafted and unpublished

- **WHEN** a row's description opens with an explicit draft declaration
- **THEN** the version is excluded by name and is neither compared nor counted as a gap

#### Scenario: A version predates both tagging and a resolvable subject

- **WHEN** no tag and no commit subject resolves a version
- **THEN** the version is named in a coverage gap the passing run prints
- **AND** the gap is reported whether the run passes or fails

#### Scenario: A version published inside another version's train

- **WHEN** a version was pushed inside the publishing commit of a later version and has no commit of its own
- **THEN** it is reported as unresolved rather than silently attributed to the later version's commit

### Requirement: The check refuses rather than passes on input it could not evaluate

The check SHALL exit without a verdict about dates when the ledger cannot be read, when the
version-history table cannot be located, when the table yields no row, when a row cannot be parsed
into a version and a date, when git cannot be executed or fails, or when no version at all resolved
to a publish commit. An unread table is not a clean one, and a resolution set that came back empty
looks exactly like a repository in which every date agrees.

#### Scenario: The version-history table cannot be located

- **WHEN** the ledger carries no version-history heading
- **THEN** the check refuses and names what it could not evaluate

#### Scenario: A row is malformed

- **WHEN** a row names a version and its second column is not a date
- **THEN** the check refuses rather than skipping the row into a pass

#### Scenario: Nothing resolved

- **WHEN** no version in the table resolves to a publish commit by tag or by subject
- **THEN** the check refuses, because a verdict drawn from an empty resolution set is drawn from nothing

#### Scenario: Git is unusable

- **WHEN** git cannot be executed or returns an error
- **THEN** the check refuses rather than treating every version as unresolved and passing

### Requirement: A disagreement is reported naming both dates

Where a row's date column and its publish commit's author date differ, the check SHALL fail and
SHALL name the version, the date the ledger claims, the date the commit records, the commit
identifier, and the method that resolved it. A verdict that says only that something disagrees
leaves the maintainer to redo the measurement.

#### Scenario: A row disagrees with its publish commit

- **WHEN** a row claims 2026-08-22 and its publish commit is authored on 2026-08-23
- **THEN** the check fails and prints the version, both dates, the commit and the resolution method

#### Scenario: Every row agrees

- **WHEN** every compared row's date column matches its publish commit's author date
- **THEN** the check passes and reports no disagreement

### Requirement: A passing run states its own coverage

The passing line SHALL state how many rows were read, how many versions were resolved by tag, how
many by subject search, how many were excluded as drafted, and how many were unresolved, naming the
unresolved ones. A recorded pass that does not state those numbers is void rather than clean,
because a pass over a set that shrank silently is indistinguishable from a pass over a set that held.

#### Scenario: The check passes

- **WHEN** every compared row agrees with its publish commit
- **THEN** the passing line states rows read, resolved by tag, resolved by subject, excluded and unresolved
- **AND** the unresolved versions are named rather than counted only

#### Scenario: The resolution set shrinks between runs

- **WHEN** a tag is deleted and a version falls back to being unresolvable
- **THEN** the coverage numbers on the passing line change and the shrinkage is visible in the output

### Requirement: A false date in published text is corrected in the ledger and not erased from pushed history

A pushed commit or annotated tag carrying a date the ledger now corrects SHALL NOT be rewritten, and
the correction SHALL be made in the ledger. Rewriting pushed public history to remove a
discrepancy is a worse remedy than documenting it, particularly where the repository may be cloned or
forked. The ledger SHALL be named as the corrected record of account, the discrepancy SHALL be
recorded in the version row that carries the correction, and the reason for leaving it SHALL be
stated so that a reader comparing the two finds an explanation rather than a contradiction.

#### Scenario: The commit subject and the tag carry the wrong date

- **WHEN** the ledger's date is corrected and the pushed subject and tag still carry the original
- **THEN** neither the commit nor the tag is rewritten
- **AND** the version row states that they retain the original date and that the ledger is the record of account

#### Scenario: The pushed history already carries the correct date

- **WHEN** only the ledger's date column was wrong and the subject and tag are right
- **THEN** no discrepancy note is written for that version
- **AND** the version row says so explicitly rather than leaving the asymmetry unexplained

#### Scenario: A maintainer proposes to rewrite the tag

- **WHEN** rewriting is considered as the tidier remedy
- **THEN** it is refused, because every clone and fork already carries the original object

### Requirement: The check models the date column and nothing else

This capability SHALL be read as modelling one class and no other: a date column that disagrees with
the commit that published the version. It SHALL NOT be read as evidence that a stamp inside a row's
prose is correct, that a row
describes what the version actually did, that the resolved commit is the right commit, or that a
version missing from the ledger would be noticed. Proving both directions proves the check fires on
the class it models, never that it models the right class.

#### Scenario: A stamp inside the row's prose is wrong while the date column is right

- **WHEN** a row's description names a different day from its own date column
- **THEN** this check does not detect it, and the limit is stated rather than left to be inferred

#### Scenario: A version was published and no row was ever added

- **WHEN** a publish commit exists for a version the ledger does not list
- **THEN** this check does not detect it, because it reads rows and a missing row is not a row
