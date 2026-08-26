# Capability: compound-value-validation

How a dependency-free reader of a structured format bounds and proves what it accepts.

## ADDED Requirements

### Requirement: A deferral of a format-modelling defect SHALL be priced by measurement

A change that defers a format-modelling defect SHALL price the deferral by measurement against the
reference implementation, and SHALL NOT record an estimate of difficulty in place of one.

Where a reader of a structured format defers a defect on the ground that modelling the behaviour
correctly is expensive, the change SHALL **take the measurement that prices it** before writing the
deferral down. A reader that already probes the reference implementation for one construct has the
instrument in hand for the next, and an estimate of difficulty is not evidence of it.

Where the model is genuinely out of reach, **rejecting the construct with a named reason** is the
honest fallback, and SHALL be declared as a house rule with its error direction stated — a rejection
can produce a false failure and never a false pass. That fallback SHALL NOT be adopted without first
checking, against the reference implementation, that it does not refuse shapes the format accepts and
that a legitimate artifact may use.

A repair that answers **every measured shape** the way the reference implementation does is a
**model** and carries no declared divergence. A repair that diverges in a named place is a **house
rule**. The change SHALL say which of the two it is.

#### Scenario: A comment interrupts a plain scalar

- **WHEN** a whole-line comment follows a plain scalar that has already started
- **THEN** the reader treats the scalar as ended, and a following continuation is reported as
  continuing nothing

#### Scenario: A comment appears where the format does not end a value

- **WHEN** a whole-line comment appears inside a block sequence, or before a key's value has begun
- **THEN** the reader leaves the value open, matching the reference implementation
