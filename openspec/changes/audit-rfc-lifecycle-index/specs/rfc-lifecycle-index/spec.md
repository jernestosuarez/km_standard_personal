# Capability: rfc-lifecycle-index

What a design record must state about its own disposition, where the disposition of the whole set is
recorded, how a status correction differs from a rewrite of a dated record, how a count of the set is
kept true without a hand maintaining it, and when a check over the record must refuse rather than
return a verdict.

## ADDED Requirements

### Requirement: The design record has an index and the index covers every document in it

A repository publishing design documents SHALL carry an index recording, for every document present,
its identifier, its title, its status, its decision date where one exists, the version or versions
that implemented it, its relationships to other documents in the set, and the narrowing where a
design was implemented in narrowed form. The index SHALL cover every document present in the
directory, and SHALL name no document that is absent from it.

#### Scenario: A reader arrives at the design directory

- **WHEN** a reader with no access to the authoring sessions opens the design directory
- **THEN** the index states which proposals are implemented, which are drafted and unpublished, and
  which bind nothing
- **AND** the reader learns that from one document rather than from seven banners

#### Scenario: A new design document is added without an index row

- **WHEN** a document is placed in the directory and the index gains no row for it
- **THEN** the check names that document as uncovered
- **AND** the release does not pass with an index that describes a subset of the tree

#### Scenario: The index names a document that is not in the tree

- **WHEN** an index row names an identifier with no file behind it
- **THEN** the check names the row, because an index that promises a document a reader cannot open
  is the same defect as text that names one

#### Scenario: A design was implemented in narrowed form

- **WHEN** a version implemented part of a design and recorded that it did not take some of it
- **THEN** the index row names the narrowing rather than recording the design as adopted whole

### Requirement: The document set and the implementation facts are derived, never held in the check

The check SHALL derive the set of existing design documents by listing the directory, and SHALL
derive what has been implemented by reading the standard's own version-history table. It SHALL NOT
hold a list of identifiers, a list of versions, or a mapping between them.

#### Scenario: A document is added to the directory

- **WHEN** a new design document is placed in the directory
- **THEN** the check's answer changes with no edit to the check

#### Scenario: A ledger row claims an implementation

- **WHEN** a version-history row states that the version implemented a named design document
- **THEN** the check reads that claim from the table rather than from anything written beside it

#### Scenario: The ledger states an adoption in words the pattern does not match

- **WHEN** a version-history row records an adoption without an implementation verb bound to the
  reference
- **THEN** the derived set is a lower bound and the check says so on its passing line
- **AND** the limit is stated rather than closed by widening the pattern until unrelated rows match

### Requirement: A status the version ledger contradicts is a defect the check reports

The check SHALL report, for every design document the version ledger records as implemented, any case
where the document's own status banner does not name the implementing version, and any case where the
index records that document as unimplemented. A status that contradicts the publication record is a
false statement in published text.

#### Scenario: A banner still declares that no normative edits ride the document

- **WHEN** the ledger records a version as implementing a document whose banner names no version
- **THEN** the check names the document, the implementing version, and the stale wording it found

#### Scenario: The index disagrees with the ledger

- **WHEN** the index records a document as draft while a ledger row states that a version implemented
  it
- **THEN** the check names both the row and the version

#### Scenario: The index names a version the ledger does not record

- **WHEN** an index row names an implementing version that appears in no version-history row
- **THEN** the check names it, because an implementation by a version that does not exist is not a
  fact about the tree

#### Scenario: A document is unimplemented and says so

- **WHEN** no ledger row claims an implementation of a document and its banner declares it design only
- **THEN** the check does not fire, because a check that fires on everything proves as little as one
  that fires on nothing

### Requirement: A stale status is corrected by adding a record and never by rewriting the design

A status banner that has gone false SHALL be corrected by a dated note stating what has published
since the document was drafted. The correction SHALL be confined to status. The design body, its
verdicts, its provenance tags, its open questions and its arguments SHALL NOT be rewritten to agree
with the present, and a dated addendum inside the document SHALL be left as the statement of its own
day.

#### Scenario: A banner is corrected after implementation

- **WHEN** a version implements a design whose banner says nothing normative rides it
- **THEN** a dated note is added naming the version and, where the implementation narrowed the
  design, the narrowing
- **AND** the original banner text stands as the dated statement it was

#### Scenario: The design body is edited to match the implementation

- **WHEN** a maintainer proposes rewriting a design so it reads as the version that implemented it
- **THEN** the change is refused, because a dated record edited to agree with the present is no
  longer a record

#### Scenario: A dated addendum inside the document has gone stale in the present tense

- **WHEN** an addendum carrying its own date describes a version as unpublished and that version has
  since published
- **THEN** the addendum is left alone and the current fact is carried by the note that carries
  today's date and by the index

#### Scenario: A status that is already true is reviewed

- **WHEN** a document's banner states a status the ledger and the tree confirm
- **THEN** it is left word for word, and the review is recorded rather than turned into an edit

### Requirement: The count of the set is generated from the index and never maintained by hand

Any surface stating how many design documents are adopted SHALL be generated from the index, and the
generator SHALL be the same instrument that validates it. The check SHALL fail when a committed count
surface differs from what it would render from the index, and SHALL judge the accessible text of that
surface as well as the surface itself.

#### Scenario: The index changes and the count surface is not regenerated

- **WHEN** an index row's status changes and the badge is left as it was
- **THEN** the check fails and names both the rendered value and the derived one

#### Scenario: The count surface is edited by hand to a value the index does not support

- **WHEN** a maintainer edits the count directly
- **THEN** the check fails, because the surface is regenerated rather than maintained

#### Scenario: The image is repaired and its accessible text is not

- **WHEN** the badge image carries the derived count and the `alt` text carries the old one
- **THEN** the check fails and names the `alt` text
- **AND** the reader who receives only the accessible text is not left with the false claim

#### Scenario: There is no index to derive the count from

- **WHEN** the check runs against a tree carrying a count surface and no index
- **THEN** it judges the count against the implementations the ledger records and reports that the
  count is wrong as well as underived

### Requirement: The check refuses rather than passes on input it could not evaluate

The check SHALL exit with a distinct refusal status, and SHALL NOT return a verdict about
disposition, when the standard cannot be read or carries no version-history table, when the table
yields no row, when the design directory is missing, unlistable or yields no document, when an index
is present but yields no parsable row, when an index row declares a status outside the declared
vocabulary, when the count surface is missing or yields no value, or when the page carrying the
accessible text cannot be read or does not reference the count surface.

#### Scenario: The design directory is absent

- **WHEN** the check runs against a tree with no design directory
- **THEN** it refuses and says the set could not be derived
- **AND** it does not report an empty set as a clean one

#### Scenario: The index is present and unparsable

- **WHEN** an index file exists and yields no row the check can read
- **THEN** it refuses rather than reporting every document as uncovered

#### Scenario: An index row carries an unknown status

- **WHEN** a row declares a status outside the vocabulary the index defines
- **THEN** the check refuses and names the term, because a vocabulary anything can join is not a
  vocabulary

#### Scenario: The version ledger cannot be read

- **WHEN** the standard is unreadable or carries no version-history table
- **THEN** the check refuses, because the implementation facts have no other home of record

#### Scenario: The index is absent

- **WHEN** no index file exists at all
- **THEN** the check fails rather than refusing, because the directory was read and the finding is
  complete
- **AND** it names every document left uncovered

### Requirement: A passing run states its own coverage

A passing run SHALL state how many documents are present in the directory and name them, how many
index rows were read and how the statuses split, how many implementation claims were read from the
version ledger, how many banners were verified against those claims, and the value it derived for the
count surface. It SHALL state that the ledger-derived set is a lower bound. A recorded pass that does
not state those numbers is void rather than clean.

#### Scenario: The check passes against a repaired tree

- **WHEN** every arm is satisfied
- **THEN** the passing line reports documents present, rows read, the status split, ledger claims
  read, banners verified, and the derived count

#### Scenario: A maintainer reads a recorded pass

- **WHEN** a pass is quoted as evidence
- **THEN** the numbers say what was looked at rather than only that nothing was found

### Requirement: The check is proved in both directions and against the tree the defect was found in

The check SHALL ship canaries that inject each defect it models and require it to be caught, and that
give it a tree where every arm is satisfied and require it not to fire. It SHALL additionally be run
against the published branch as it stands before this change, and SHALL be shown to name the real
stale banners and the wrong count there.

#### Scenario: The positive direction

- **WHEN** a fixture omits an index row, contradicts the ledger, leaves a banner unnamed, or carries a
  count the index does not support
- **THEN** the check reports that case and exits non-zero

#### Scenario: The negative direction

- **WHEN** a fixture satisfies every arm
- **THEN** the check passes and states its coverage

#### Scenario: The run against the unrepaired published branch

- **WHEN** the check runs against the branch as it stands before this change
- **THEN** it fails, names the design documents left uncovered by a missing index, names each banner
  the ledger contradicts with its implementing version, and names the count surface with both the
  value it carries and the value the ledger supports
- **AND** the counts named are asserted rather than left as a bare non-zero exit

#### Scenario: The pre-repair revision is unavailable in a clone

- **WHEN** the revision the evidence case anchors on is not present
- **THEN** the run reports a coverage gap rather than folding the absence into a pass
