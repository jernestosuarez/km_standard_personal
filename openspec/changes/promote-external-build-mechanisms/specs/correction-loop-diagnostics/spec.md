# Capability: correction-loop-diagnostics

What a diagnosis contains before anyone acts on it.

## ADDED Requirements

### Requirement: A diagnosis SHALL be a record with four sections

A diagnostic record SHALL contain: environment and validity, separating invalid setup evidence from
findings; the measurement, each failing case run in isolation and in the failing context with one
variable changed per comparison; the hypothesis, with stated confidence, scope no broader than the
route that established it, and its falsifying evidence named; and the smallest next boundary, with
no fix riding inside the diagnosis.

#### Scenario: A harness failure is observed during setup

- **WHEN** an observation is produced by the harness failing to start rather than by the subject
  under diagnosis
- **THEN** it is recorded as invalid setup evidence and excluded from the measurement

#### Scenario: A comparison varies more than one variable

- **WHEN** the two sides of a comparison differ in more than the variable named
- **THEN** the comparison measures the confound and its result is evidence for neither reading

#### Scenario: A fix is proposed inside a diagnosis

- **WHEN** a diagnosis concludes
- **THEN** it names the smallest next boundary and changes nothing, because a repaired tree ends
  the evidentiary value of the record's own measurements

### Requirement: A shared failure value SHALL NOT be read as a shared cause

When several failures report the same number, that number SHALL be read as evidence of a shared
harness deadline and nothing more; the isolation-versus-context matrix decides whether a shared
cause exists, and a case that passes alone and fails in context SHALL NOT be absorbed into "flaky".

#### Scenario: Three unrelated failures report the same timeout value

- **WHEN** several failing cases stop at one identical limit value
- **THEN** the record treats the value as a property of the harness and requires the matrix before
  any common-cause hypothesis

#### Scenario: A case passes in isolation and fails in context

- **WHEN** the matrix shows a case green alone and red in its containing run
- **THEN** the record states an unidentified trigger living in that context, and does not retire
  the question as flakiness

### Requirement: The form's enforcement status SHALL be stated

A statement of the form's enforcement SHALL claim shape conformance only: section presence is
mechanically checkable by a deployment that adopts a fixed heading set, while the quality of a
hypothesis, the validity of a matrix and the honesty of a confidence statement are reached by no
check, and this standard ships no instrument that reads diagnostic records.

#### Scenario: A deployment claims diagnostic quality is enforced

- **WHEN** a section-presence check passes over a diagnostic record
- **THEN** the pass is described as shape conformance only, never as enforcement of diagnostic
  quality
