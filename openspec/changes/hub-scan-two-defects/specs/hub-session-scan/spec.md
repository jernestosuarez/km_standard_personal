# Capability: hub-session-scan

What the session-start scan every hub inherits may block on an outbound surface, and what it may
count as a rule that binds.

## ADDED Requirements

### Requirement: A numbered curated document's name is structure, and a frontmatter restriction on it restricts content

A **numbered curated document** SHALL be defined as a file at the hub root whose name matches
`0[0-9]_*.md` or `10_*.md`, which is the fixed layout the standard declares and the numbered half of
its monitored-files glob. No file outside the hub root SHALL be treated as a numbered curated
document, whatever its name.

Where a numbered curated document carries a `sensitivity: restricted` marker in its **frontmatter**,
the outbound check SHALL block that document's **content** verbatim on every outbound surface and
SHALL NOT block its **name**. This is the treatment a note classed `restricted` or `record` already
receives, and it follows from the crossing law that existence crosses while contents do not: the name
of a numbered document is the hub's public structure, not a disclosive record identifier, and a
directive that restricts such a document's content must be able to name the document it is
restricting.

Where the marker sits in the **body** of a numbered curated document, the check SHALL be unchanged:
the marked section's verbatim text is blocked and the document's name stays nameable, exactly as for
any other note.

A note whose name or existence is itself sensitive SHALL continue to be blocked by name wherever it
sits outside the numbered curated set, and the narrowing SHALL NOT be widened to any numbered name in
a subdirectory, since relaxing a boundary check converts a false positive into a false negative.

The change SHALL ship a case that fails on the unrepaired tree for each direction it repairs, and a
case that asserts the boundary it must not cross; the second SHALL be recorded as a boundary case
rather than presented as a detector, because it passes on both trees by construction.

#### Scenario: A directive names the numbered document whose content it restricts

- **WHEN** a change notice names a root-level numbered document that carries a frontmatter
  `sensitivity: restricted` marker
- **THEN** the scan raises no restricted-identifier finding for that name
- **AND** the scan does not fail on account of the name

#### Scenario: The same document's body text reaches an outbound surface

- **WHEN** a change notice carries a verbatim line of that document's body
- **THEN** the scan raises a restricted-section-text finding naming that document
- **AND** the scan exits with its error status

#### Scenario: A numbered name in a subdirectory is not curated structure

- **WHEN** a note held in a subdirectory carries a numbered-looking name and a frontmatter
  `sensitivity: restricted` marker, and its name appears on an outbound surface
- **THEN** the scan raises a restricted-identifier finding for that name
- **AND** the scan exits with its error status

#### Scenario: A disclosive record note is unaffected

- **WHEN** an entity note carrying a frontmatter `sensitivity: restricted` marker is named on an
  outbound surface
- **THEN** the scan raises a restricted-identifier finding for that name

### Requirement: The estate corrections count is a count of rules in force, and the printed line states the predicate

The session-start scan's estate-corrections block SHALL count a note as a rule in force only when all
of three conditions hold: the file is not scaffold, it carries a `rule:` field, and it is
`lifecycle: active`. `lifecycle:` records whether a document is current and SHALL NOT by itself be
read as making a note a binding rule.

Scaffold SHALL be the set the standard already defines — a folder's `README.md`, `TEMPLATE.md` and
`hub-manifest.md` — together with a generated `index.md`, which carries `lifecycle: active` by
construction and therefore reads as current while asserting nothing. The check SHALL NOT carry a
filename list for any artifact the standard does not define, since a name list beside a check is a
hand-maintained memory of one deployment's directory.

The line the block prints SHALL state the predicate it ran and SHALL NOT state a wider one. A check
whose printed claim outruns its predicate is a defect of the same rank as a wrong count.

A count that is wrong SHALL be repaired in the predicate and SHALL NOT be repaired by editing the
documents it counts, because removing a field from a scaffold document makes a broken counter agree
by accident and the next scaffold document added reproduces the defect.

Where a derived artifact of the registry could satisfy the predicate without being a note, that
residual SHALL be stated as a limit of the check rather than answered by widening the name list.

#### Scenario: A registry holds scaffold beside its rules

- **WHEN** the registry holds two notes carrying a `rule:` and `lifecycle: active`, a `README.md`
  carrying `lifecycle: active` and no `rule:`, and a generated `index.md` carrying `lifecycle: active`
  and no `rule:`
- **THEN** the block reports two rules in force
- **AND** the line it prints names the predicate it ran

#### Scenario: A rule that is no longer current

- **WHEN** a note carries a `rule:` and a `lifecycle:` of `retired` or `superseded`
- **THEN** it is not counted

#### Scenario: A single-hub deployment

- **WHEN** the workspace root holds no estate corrections directory
- **THEN** the block prints nothing
