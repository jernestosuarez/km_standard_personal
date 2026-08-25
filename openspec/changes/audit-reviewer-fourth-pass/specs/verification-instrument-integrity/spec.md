# Capability: verification-instrument-integrity

What a verification instrument may claim, and what must be true of a repair to one.

## ADDED Requirements

### Requirement: A control that certifies a property of code SHALL NOT enforce a spelling

A control whose stated claim is a **property of running code** SHALL NOT establish that claim by
matching the **source text** that expresses it. A pattern over source text is an approximation of the
property, and a consumer of the property written in any unmatched form satisfies the code while
escaping the pattern, leaving the control green over a false claim.

Where such a control is found, the repair SHALL be to **remove the need for the static analysis**
rather than to widen the pattern. A wider pattern is the same defect with more characters, and the
next author reaches for a helper, a variable or a different call form.

The preferred structural repair is to make the property a **runtime fact**: where every consumer must
obtain the governed thing through an accessor, the accessor SHALL **record what it handed out**, and
the guarantee SHALL be derived from that recording. The covered set is then what was actually used
rather than what a list predicted would be used, a consumer added later is inside it by construction,
and the case that proved the guarantee becomes a **real new consumer** that must be covered with no
edit to the case.

Where the structural repair is not available in the version that finds the defect, the change SHALL
implement the best available control, SHALL state precisely which part of the claim remains enforced
by pattern-matching, and SHALL NOT present a narrowed pattern as a guarantee.

Every change of this kind SHALL state the **residual that remains enforced by nothing**, in the
instrument's own stated limits rather than in a commit message, because a narrower residual is not an
absent one.

#### Scenario: A control greps source text to certify a code property

- **WHEN** a control's stated claim is a property of running code and its mechanism is a pattern over
  source text
- **THEN** the claim is recorded as an approximation of the property
- **AND** the repair makes the property structural rather than widening the pattern
- **AND** where it cannot be made structural, what remains pattern-enforced is named

#### Scenario: A consumer added later must be covered without editing the control

- **WHEN** a new consumer of the governed thing is added
- **THEN** it is inside the covered set with no edit to any list and no edit to the control
- **AND** the control's canary is itself a real added consumer rather than a source-text assertion

### Requirement: A dead matcher made live is a new rule and SHALL be re-derived

A matcher discovered to have never fired SHALL be re-derived rather than respelled.

Where a repair discovers that a matcher has never fired — because it was written in a form the engine
does not honour — the change SHALL treat the rule as **unproven rather than merely unenforced**.
Connecting an inert matcher is authoring its rule for the first time.

The change SHALL re-derive what the matcher should match from the thing being modelled, SHALL prove
the re-derived rule in both directions, and SHALL NOT repair the matcher's spelling while keeping its
intent on trust.

A check that depends on a matching construct the host engine may or may not honour SHALL **probe that
construct against the live engine** before returning any verdict, against an input it must match and
an input it must not, and SHALL **refuse** rather than return a verdict when the probe shows it
inert. An inert matcher and a clean tree are indistinguishable in the output.

#### Scenario: A matcher is found to have been inert

- **WHEN** a repair finds that a matching construct never matched anything
- **THEN** the rule it expressed is treated as untested
- **AND** the rule is re-derived from the modelled thing and proved in both directions before the
  matcher is connected

#### Scenario: A check depends on a construct the engine may ignore

- **WHEN** a check's verdict depends on a matching construct
- **THEN** the check probes the construct against the engine that will run it
- **AND** returns a refusal, not a verdict, when the probe shows the construct inert
