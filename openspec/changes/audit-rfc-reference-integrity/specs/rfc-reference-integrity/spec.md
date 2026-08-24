# Capability: rfc-reference-integrity

What a reference to a design document obliges of the text that makes it, how the set of existing
documents is derived, which written forms a reference check must catch, when it must refuse rather
than return a verdict, what it must state on a passing run, and on what terms a design document lands
on the published branch ahead of the version implementing it.

## ADDED Requirements

### Requirement: Published text names only documents a reader can open

Text the standard publishes SHALL NOT name a design document that is absent from the published tree.
A reference is a promise that the named thing can be opened, and a version SHALL NOT publish carrying
a reference whose target has not landed. Where a version's text depends on a design document, the
document lands first, as design, or the reference is removed before the version publishes.

#### Scenario: A version is drafted citing a document that is not on the published branch

- **WHEN** text prepared for publication names a design document that exists only on an unmerged branch
- **THEN** the version does not publish until the document lands or the reference is removed
- **AND** the choice between landing and removing is made before the push, not deferred past it

#### Scenario: A drafting report flags an unlanded dependency

- **WHEN** a report on a version's own drafting states that a document it references is unmerged
- **THEN** the flag is acted on before the push
- **AND** acknowledging the flag without acting on it is recorded as the maintainer error it is

#### Scenario: The reference resolves but the citing text mischaracterises the document

- **WHEN** a reference names a document that exists and describes it wrongly
- **THEN** this capability does not detect it, because openability is what the check models
- **AND** the limit is stated rather than left for a reader to infer from a passing run

### Requirement: The existing document set is derived from the directory and never held in the check

The check SHALL derive the set of existing RFCs by reading the `rfcs/` directory, taking each
identifier from the name of a file actually present. It SHALL NOT carry a hardcoded list of
identifiers, so that adding, renaming or removing an RFC changes the check's answer with no edit to
the check.

#### Scenario: A new RFC is added to the directory

- **WHEN** a new RFC file is placed in `rfcs/` and text elsewhere references its identifier
- **THEN** the check resolves the reference with no change to the check itself

#### Scenario: An RFC referenced everywhere is removed from the directory

- **WHEN** an RFC file is removed from `rfcs/` while references to its identifier remain
- **THEN** every one of those references is reported as dangling

#### Scenario: The identifier set would otherwise be stale

- **WHEN** the check is read by a maintainer looking for the list of known identifiers
- **THEN** no such list exists in the check
- **AND** the directory is named as the single source the set is derived from

### Requirement: The check reads the written forms a hyperlink walk misses

The check SHALL extract RFC identifiers from running prose, from version-ledger rows, and from RFC
dependency and provenance sections, not from Markdown hyperlinks alone. It SHALL recognise a bare
identifier such as `RFC-005`, a code-formatted path such as `rfcs/RFC-005`, and a Markdown link whose
target names an RFC file. Where a reference is written as a path ending in a filename, the check SHALL
additionally require that the named file exists, so a path naming a real identifier under a wrong
filename is reported rather than resolved.

#### Scenario: The reference is a code-formatted path

- **WHEN** text carries `rfcs/RFC-005` inside backticks and no file in `rfcs/` bears that identifier
- **THEN** the check reports the reference with its file and line

#### Scenario: The reference is a bare identifier in running prose

- **WHEN** a sentence names `RFC-005` with no path and no link and no such file exists
- **THEN** the check reports the reference

#### Scenario: The reference sits in a version-ledger row

- **WHEN** a version-history row names an identifier for which no file exists
- **THEN** the check reports it, because a ledger row is published text like any other

#### Scenario: The reference is a Markdown link to a filename that does not exist

- **WHEN** a link target names `rfcs/RFC-004-some-other-name.md` while the identifier RFC-004 exists
  under a different filename
- **THEN** the check reports the path as unresolvable
- **AND** the identifier existing is not accepted as the path resolving

#### Scenario: Every reference resolves

- **WHEN** every identifier named in the scanned surface has a file in `rfcs/`
- **THEN** the check does not fire
- **AND** a check that fired here would prove as little as one that never fires

### Requirement: The check refuses rather than passes on input it could not evaluate

The check SHALL exit with a distinct refusal status, and SHALL NOT return a verdict about references,
when the `rfcs/` directory is missing or unreadable, when that directory yields no RFC at all, when no
file was scanned, when the scan parsed no identifier anywhere, or when a file in scope cannot be
decoded. A refusal SHALL state what could not be evaluated.

#### Scenario: The RFC directory is absent

- **WHEN** the check runs against a tree carrying no `rfcs/` directory
- **THEN** it refuses and says the existing set could not be derived
- **AND** it does not report every reference as dangling, which would be a verdict drawn from an
  unread directory

#### Scenario: The RFC directory holds no RFC

- **WHEN** `rfcs/` exists and contains no file bearing an identifier
- **THEN** the check refuses rather than treating the empty set as the truth about the tree

#### Scenario: The scan finds no identifier at all

- **WHEN** the scanned surface yields no RFC identifier
- **THEN** the check refuses, because a pattern that has stopped matching and a tree that cites
  nothing produce the same silence

#### Scenario: A file in scope cannot be decoded

- **WHEN** a scanned file cannot be read as text
- **THEN** the check refuses and names the file rather than skipping it into a passing verdict

#### Scenario: A file exempts itself without a reason

- **WHEN** a file declares an exemption from the scan and states no reason for it
- **THEN** the check refuses, so no exclusion is silent

### Requirement: A passing run states its own coverage

A passing run SHALL state how many identifiers it found, how many files it scanned, and how many RFCs
are present in the directory it derived the set from. It SHALL name every file that exempted itself
and the reason each gave. A recorded pass that does not state those numbers is void rather than clean.

#### Scenario: The check passes against a clean tree

- **WHEN** every reference resolves
- **THEN** the passing line reports identifiers found, files scanned, and RFCs present

#### Scenario: A file exempts itself with a reason

- **WHEN** a file declares an exemption with a stated reason
- **THEN** the passing run names the file and prints the reason

#### Scenario: A reader asks what a pass covered

- **WHEN** a maintainer reads a recorded pass
- **THEN** the numbers say what was looked at rather than only that nothing was found

### Requirement: The check is proved in both directions and against the tree the defect was found in

The check SHALL ship canaries that inject a dangling identifier and require it to be caught, and that
give it a tree in which every reference resolves and require it not to fire. It SHALL additionally be
run against the published tree as it stood before this change, and SHALL be shown to name the real
dangling references there. A canary that passes against both the defective and the repaired tree
SHALL NOT be recorded as proof.

#### Scenario: The positive direction

- **WHEN** a fixture names an identifier with no file behind it
- **THEN** the check reports it and exits non-zero

#### Scenario: The negative direction

- **WHEN** a fixture names only identifiers that resolve
- **THEN** the check passes and states its coverage

#### Scenario: The run against the pre-repair published tree

- **WHEN** the check runs against published `main` as it stood before the RFC landed
- **THEN** it fails there and names the real RFC-005 references in the standard and in the two RFCs
  that depend on it
- **AND** the count of references named is asserted rather than left as a bare non-zero exit

#### Scenario: The pre-repair commit is unavailable in a clone

- **WHEN** the commit the evidence case anchors on is not present
- **THEN** the run reports a coverage gap rather than folding the absence into a pass

### Requirement: A design document may land on the published branch ahead of its implementation

A design document landing ahead of its implementation SHALL bind nothing, claim no version, add no
version-history row, and change no normative text. Landing a design document on the published branch
SHALL NOT be read as adopting its design.

#### Scenario: A design document lands to repair a dangling reference

- **WHEN** published text already cites a design document that is not on the branch
- **THEN** the document may land as design only, which is the route an earlier RFC already took
- **AND** no normative text changes as a consequence of it landing

#### Scenario: The landed document is read as adopted

- **WHEN** a later session reads the presence of a design document on the published branch
- **THEN** the document's own status banner states that it binds nothing
- **AND** presence on the branch is not evidence of adoption

### Requirement: A landing design document states its true status on the day it lands

A landing document's status banner SHALL be corrected to state the document's true status where that
banner has gone stale relative to what has published since it was drafted. The correction SHALL be
confined to status and SHALL NOT rewrite the design, its verdicts, its provenance tags, or its
arguments.

#### Scenario: Siblings named in the banner have since been implemented

- **WHEN** a banner names other documents as equally unimplemented and versions have since implemented
  them
- **THEN** the banner records which have been implemented and by which version, and that this one has
  not
- **AND** the design body is left unchanged

#### Scenario: A status correction is mistaken for a design change

- **WHEN** the landing commit is reviewed
- **THEN** the only change to the document beyond its arrival is in its status banner
