# Capability: documentation-truth

What an inherited or published document may assert about the system that ships it, how the hub
template's landing page is held to the standard's own rule set, on what terms an enforcement claim
distinguishes a mechanical control from a procedural one, and how a document set that has stopped
describing the current system is labelled rather than presented as current.

## ADDED Requirements

### Requirement: A shipped document asserts only what the system it ships with does

A document this repository ships SHALL NOT assert a capability, a count, or an operating model that
the repository does not implement at the version that ships it. Where a document is copied into a
deployment on installation, the assertion travels into every deployment that installs it, so a false
one is a defect in each of them and not only in this repository. Where such an assertion is found, it
SHALL be repaired to what the system does, and the claim that was true SHALL be preserved rather than
rewritten alongside it.

#### Scenario: An inherited landing page names a count the standard has outgrown

- **WHEN** the hub template's landing page states a number of governance rules
- **THEN** that number is the number the standard defines
- **AND** the page is repaired rather than left for each deployment to discover

#### Scenario: The repository is forked

- **WHEN** the tree is handed to a reader with no access to the session or the estate that wrote it
- **THEN** every document the fork carries is read as a statement about the system
- **AND** a document that describes a capability the system does not have is a defect the reader meets first

#### Scenario: A true claim sits beside a false one

- **WHEN** a paragraph carrying a false assertion also carries claims that hold
- **THEN** only the false assertion is changed and the surrounding claims are preserved word for word

### Requirement: The hub template's rule summary enumerates every rule the standard defines

The hub template's landing page SHALL enumerate one summary entry per governance rule the standard
defines, and the set it enumerates SHALL be derived from the standard rather than maintained
independently of it. A landing page carrying fewer entries than the standard has rules teaches a new
hub a governance model the standard has replaced.

#### Scenario: The standard defines six rules and the page lists four

- **WHEN** the landing page's summary lists rules 1 through 4 and the standard defines rules 1 through 6
- **THEN** the check fails and names the rules the page does not carry

#### Scenario: The standard gains a rule

- **WHEN** a later version adds a seventh rule to the standard
- **THEN** the check fails against the unchanged landing page with no edit to the check itself

#### Scenario: The page enumerates every rule

- **WHEN** the landing page carries one entry per rule the standard defines
- **THEN** the check passes and states how many rules it derived and how many entries it matched

### Requirement: A rule count written in the template's prose agrees with the standard

A count written immediately before the word "rules" on the hub template's landing page SHALL equal
the number of rules the standard defines. A sentence naming a count is the form the
defect took, and it survives independently of the list above: a page can carry six list entries and
still tell its reader the scan checks four.

#### Scenario: The page says the scan checks all four rules

- **WHEN** the page contains the phrase "all four rules" and the standard defines six
- **THEN** the check fails, names the phrase, the count it asserts and the count the standard defines

#### Scenario: A count is written as a numeral

- **WHEN** the page writes a digit before the word "rules" rather than a spelled-out number
- **THEN** the count is read and judged the same way

#### Scenario: The page states no count at all

- **WHEN** the page names the rules it means rather than counting them
- **THEN** no count is judged, and the run reports that none was found rather than passing silently

### Requirement: The rule set is derived from the standard and never held in the check

The check SHALL derive the set of governance rules from the standard's own rule headings, and SHALL
NOT carry a rule count, a rule list, or a rule name in its own source. A list kept beside a check is a
hand-maintained memory of the document it checks, which is the artifact class this standard already
records as the one that rots.

#### Scenario: A maintainer reads the check for the rule set it uses

- **WHEN** the check is read for the list it compares against
- **THEN** no such list exists in it
- **AND** the standard's rule headings are named as the source the set is derived from

#### Scenario: A rule is renumbered in the standard

- **WHEN** the standard's rule headings change
- **THEN** the check's answer changes with them and no edit to the check is required

### Requirement: The check refuses rather than passes on input it could not evaluate

The check SHALL exit without a verdict when the standard or the landing page cannot be read or
decoded, when the standard yields no rule heading, when the landing page carries no governance-rule
summary section, or when that section yields no numbered entry. An unread page is not a conformant
one, and a summary section that parsed to nothing looks exactly like a page whose entries all match.

#### Scenario: The landing page cannot be read

- **WHEN** the landing page is absent or cannot be decoded
- **THEN** the check refuses and names what it could not evaluate

#### Scenario: The standard yields no rule heading

- **WHEN** no rule heading can be found in the standard
- **THEN** the check refuses rather than concluding that a page carrying no entries is complete

#### Scenario: The summary section yields no entry

- **WHEN** the governance-rule summary section exists and contains no numbered entry
- **THEN** the check refuses rather than passing over an empty comparison

### Requirement: A passing run states its own coverage

The passing line SHALL state how many rules were derived from the standard, how many summary entries
were found on the landing page, how many were matched, and how many count phrases were judged. A
recorded pass that does not state those numbers is void rather than clean, because a pass over a set
that silently shrank reads identically to a pass over a set that held.

#### Scenario: The check passes

- **WHEN** every rule is enumerated and every count agrees
- **THEN** the passing line states rules derived, entries found, entries matched and counts judged

#### Scenario: The summary section is renamed and the entries are no longer found

- **WHEN** a later edit moves the entries out of the section the check reads
- **THEN** the coverage numbers change or the check refuses, and the shrinkage is visible rather than folded into a pass

### Requirement: An enforcement claim distinguishes a mechanical control from a procedural one

Where this standard states that a rule is enforced, it SHALL state what enforces it, and SHALL NOT
describe a rule held by procedure as enforced by an instrument. A rule with no instrument behind it
remains fully binding; what is narrowed is the claim about how compliance is established, never the
obligation. Describing a procedural control as mechanical is the false assurance this standard
already holds to be worse than an acknowledged gap, and it takes the same posture here that it takes
toward agent scope and toward a scoped reader's isolation.

#### Scenario: Six rules are stated and four are checked at session start

- **WHEN** the governance layer is described
- **THEN** the rules the session-start scan checks are named
- **AND** the rules held by procedure are named as procedural rather than counted into the enforced set

#### Scenario: A rule is enforced in one half and not the other

- **WHEN** an instrument covers part of a rule and not the rest
- **THEN** the covered part is named and the uncovered part is stated rather than absorbed into the claim

#### Scenario: A reader concludes the procedural rule is optional

- **WHEN** the narrowed claim is read
- **THEN** it states that the rule binds exactly as the others do and that only the enforcement claim changed

#### Scenario: A field-presence check is offered as provenance validation

- **WHEN** an entity-shape check requires a provenance field to be present on an optional note type
- **THEN** that is stated as field presence on those types and never as validation that a fact in prose traces to a named origin

### Requirement: A document set that no longer describes the current system is labelled wherever it is linked

Where a descriptive document set has stopped tracking the system it describes, it SHALL be labelled
as a snapshot of the version it does describe, and the label SHALL appear wherever the set is linked
rather than only inside the set. A snapshot honestly labelled is true; a snapshot presented as current
is not, and a disclaimer that lives only behind the link is not read by the reader who follows the
link from somewhere else.

#### Scenario: An index carries a version qualifier and its inbound link does not

- **WHEN** the set's own index names the version it describes and the page linking to it does not
- **THEN** the linking page carries the label too, at the point the reader meets the link

#### Scenario: The set is labelled rather than refreshed

- **WHEN** refreshing the set would be a substantial authoring job riding on a documentation-truth change
- **THEN** the set is labelled as a historical snapshot and the reason is recorded in the version row
- **AND** the label names what has changed since, so a reader can tell what the snapshot does not cover

#### Scenario: A reader needs the current description

- **WHEN** the labelled set is opened
- **THEN** it names the normative document that does describe the current system

### Requirement: The check models the template's rule summary and nothing else

This capability SHALL be read as modelling one mechanically checkable class and no other: a hub
template landing page whose governance-rule summary or rule count disagrees with the standard's own
rule set. It SHALL NOT be read as evidence that the page's rule descriptions are accurate, that the
page's other statements are true, that an enforcement claim anywhere is correctly narrowed, or that a
descriptive document set is current. Proving both directions proves the check fires on the class it
models, never that it models the right class.

#### Scenario: An entry names the right rule number and describes it wrongly

- **WHEN** the summary carries one entry per rule and one entry's description is false
- **THEN** this check does not detect it, and the limit is stated rather than left to be inferred

#### Scenario: An enforcement claim elsewhere overstates what an instrument does

- **WHEN** a document claims a control that no instrument supplies
- **THEN** no check in this change detects it, because the evidence a check can read cannot represent the claim

#### Scenario: A snapshot label goes stale in turn

- **WHEN** the labelled architecture set falls further behind
- **THEN** the label remains true, because it names a version rather than a currency, and no check is claimed over it
