# Capability: compound-value-validation

How a check reads a value that spans more than one line, and what it may claim about the format it
approximates.

## ADDED Requirements

### Requirement: A continuation is decided by indentation, never by a leading marker

A reader that folds a multi-line value SHALL decide whether a line continues a key by comparing that
line's indentation with the indentation of the key it would continue. It SHALL NOT treat a leading
marker — a sequence dash or any other token — as sufficient on its own.

A sequence entry standing at the indentation of the mapping SHALL be reported as continuing nothing,
because a block mapping followed by a root sequence is not a document the format defines: a parser
rejects it outright, and a check that folds such a line into the preceding value certifies a document
no runtime can load.

Accepting input a parser refuses is a false pass rather than an approximation, and SHALL be repaired
rather than bounded. Reading less of a valid document than a parser does is an approximation, and is
governed by the requirement below.

#### Scenario: A sequence entry stands at the indentation of the mapping

- **WHEN** a block carries valid keys and a sequence entry that is not more-indented than any key
- **THEN** the check reports that entry as continuing nothing
- **AND** the check does not fold it into the value of the preceding key

#### Scenario: A sequence is indented under the key it belongs to

- **WHEN** a block carries a key whose value is a sequence indented beneath it
- **THEN** the check accepts the block
- **AND** a case asserts this acceptance, so that the tightening cannot be narrowed into rejecting
  legitimate input

### Requirement: A dependency-free reader states the subset it models

Where a check parses a structured format without taking a parser as a dependency, it SHALL name the
**subset it models** — the delimiters, key shapes, value forms and folding rule it understands — and
SHALL name what falls outside that subset, so that a passing line is not read as a claim that the
excluded constructs were evaluated.

The passing line SHALL state that a file it accepts conforms to **this standard's** contract as
modelled, and SHALL NOT state or imply that the file is thereby valid in the underlying format.

Declining the dependency SHALL remain available where the parser is not guaranteed in the environment
the check ships into; naming the subset is what makes that decline honest rather than what replaces
it.

#### Scenario: A reader without a parser dependency returns a passing verdict

- **WHEN** a dependency-free reader passes a file
- **THEN** its passing line states the subset it read the file as
- **AND** the constructs outside that subset are named where the reader is documented
- **AND** the passing line does not claim validity in the underlying format
