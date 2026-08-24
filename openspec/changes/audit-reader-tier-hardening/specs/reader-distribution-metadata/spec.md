# Capability: reader-distribution-metadata

The identity and distribution guarantees of the shipped Reader material: which version the standard
presents, what equivalence its instruction mirrors actually promise, and which reader files are
tracked.

## ADDED Requirements

### Requirement: The standard presents one version identity

The standard document SHALL present the same version in its frontmatter and in its heading. A
consumer reading either field SHALL arrive at the same answer for which version the document is.

#### Scenario: Frontmatter and heading disagree

- **WHEN** the document frontmatter names one version and the heading names another
- **THEN** this is a defect and the document is corrected before publication

#### Scenario: Frontmatter and heading agree

- **WHEN** the document frontmatter and heading name the same version
- **THEN** the document presents one identity and passes

### Requirement: A stated equivalence between mirrors matches the guarantee that holds

The Reader distribution SHALL describe the equivalence that actually holds between the instruction
copies it ships for more than one runtime. It SHALL NOT claim the copies are equal when documented
per-runtime differences exist. Any permitted difference SHALL be named.

#### Scenario: Documentation claims equality that does not hold

- **WHEN** the distribution states that its instruction mirrors are kept equal
- **AND** the mirrors differ other than by a documented per-runtime substitution
- **THEN** this is a defect, and either the mirrors are made equivalent or the claim is narrowed to
  the guarantee that holds

#### Scenario: A documented per-runtime difference is present

- **WHEN** the mirrors differ only where the documentation names a permitted per-runtime difference
- **THEN** the distribution is conformant

### Requirement: Generated reader output is not distributed

The repository SHALL track the Reader's shipped convention document and SHALL NOT track or surface
generated reader output. A reader that has produced output SHALL NOT thereby present that output as
untracked material in the distribution.

#### Scenario: A reader produces output

- **WHEN** a reader writes a generated output file into its output area
- **THEN** the repository ignores it
- **AND** it does not appear as untracked material

#### Scenario: The shipped convention document is present

- **WHEN** the distribution is cloned fresh
- **THEN** the Reader's output-area convention document is present and tracked
- **AND** the shipped scaffold passes its own scan
