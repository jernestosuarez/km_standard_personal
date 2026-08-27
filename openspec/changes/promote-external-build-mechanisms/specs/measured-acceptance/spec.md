# Capability: measured-acceptance

How a decision made on a measurement is protected from the measurement.

## ADDED Requirements

### Requirement: The acceptance threshold and the stop predicate SHALL be fixed before the measurement runs

A decision made on a measurement SHALL have its threshold and its stop predicate stated in the
design that authorises the measurement, committed before the measurement runs — accept or reject an
implementation, keep or remove an optimisation, adopt or roll back alike. A threshold argued
after the numbers are in is the measurement judging itself.

#### Scenario: A measurement is proposed without a threshold

- **WHEN** a design authorises a measurement whose result will decide acceptance and states no
  threshold or stop predicate
- **THEN** the measurement is not run until the design states them, in a commit that precedes the
  measurement commit

#### Scenario: A stop condition is met mid-run

- **WHEN** an observation named by the stop predicate occurs during the measurement
- **THEN** the run halts and rolls back rather than continuing to a number

### Requirement: The mechanical half SHALL be commit ordering, and its limits SHALL be stated

A check for this rule SHALL answer exactly two questions from history: that the commit carrying the
threshold is an ancestor of the commit recording the measurement, and that the threshold is
contained in it. It SHALL NOT be described as proving that no unrecorded run preceded the design, that the run honoured
its stop predicate, or that the threshold is well chosen.

#### Scenario: A deployment automates the obligation

- **WHEN** a deployment builds a check for this rule
- **THEN** the check answers ancestry and containment and nothing more, and its passing line claims
  no wider property
