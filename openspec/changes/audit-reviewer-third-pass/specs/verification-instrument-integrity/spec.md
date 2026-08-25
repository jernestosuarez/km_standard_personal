# Capability: verification-instrument-integrity

What a verification instrument may claim, and what must be true of a repair to one.

## ADDED Requirements

### Requirement: A control's claim names only the set it read

A check's passing line SHALL claim only what the check actually read. Where the set it reads is
narrower than the population its wording implies, the wording SHALL be corrected to name the roots and
the count actually scanned, or the set SHALL be widened; it SHALL NOT be left claiming the population.

Where widening the set would change what the instrument enforces rather than what it reads — because
admitting the additional material would require a policy decision about what that material may carry —
the scope SHALL be **registered with its measurement and its reason** rather than widened inside the
repair, and the claim SHALL be corrected in the same change. Settling a policy question as a side
effect of a repair to a reader settles it silently.

#### Scenario: A check claims a population wider than its scan

- **WHEN** a check's passing line names a population and its scan reads a proper subset of that
  population
- **THEN** the claim is corrected to state the scanned roots and the scanned count
- **AND** where the scope is not widened, the reason is recorded with the measurement that supports it

### Requirement: A case that asserts a gap is inverted when the gap closes

A change that closes a residual SHALL invert the case pinning it into a control, rather than delete
it: the same fixture, the same input, the opposite expectation. Deleting it removes the record that the gap existed and closed;
leaving it asserting the gap makes the repair read as a regression.

While inverting such a case, the change SHALL check that no canary reading the instrument's own prose
reports the repair itself as the defect, because a repair to a claim necessarily quotes the wording it
removed.

#### Scenario: A residual pinned as a gap is later closed

- **WHEN** a change closes a residual that an existing case asserts as a known gap
- **THEN** that case is inverted into a control asserting the closure
- **AND** any prose-reading canary is checked against the repair's own quotations before the change is
  committed

### Requirement: A repair re-derives the construct it touches, not only the line that failed

Where a defect is found in one arm of a matching construct, every arm of that construct SHALL be
re-derived in the same change. An arm that has never been exercised is indistinguishable from one that
works, and the repair is the moment its cost is lowest. A repair that corrects the failing line and
carries the remaining arms forward unexamined SHALL be recorded as such if a later version finds one
of them wrong, so the lesson attaches to the method rather than to the pattern.

A change that repairs an instrument SHALL sweep for this class across the repairs the preceding change
made, and SHALL record the result including a finding of none.

#### Scenario: One arm of a multi-arm pattern is found defective

- **WHEN** a change repairs one arm of a matching construct
- **THEN** the remaining arms are re-derived and exercised in the same change
- **AND** the sweep for arms carried through the preceding change's repairs is recorded, including a
  finding of none
