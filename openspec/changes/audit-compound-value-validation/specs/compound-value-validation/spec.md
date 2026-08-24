# Capability: compound-value-validation

What a check must do when the value it reads is a list rather than a scalar: which conclusions a
whole-value test is entitled to draw, what the per-token gate on a declared keyword list must accept
and refuse, what the rule costs, and what the sweep of the shipped checks covered.

## ADDED Requirements

### Requirement: A check that reads a compound value validates its parts and never the whole alone

A check that reads a value the standard defines as a list, a set, or a delimited sequence SHALL split
that value on its delimiter and validate each resulting part. A verdict about such a value SHALL NOT
be reached by testing the undivided value alone, because a value can satisfy every whole-value test
while containing no part that satisfies the rule the check exists to enforce.

#### Scenario: A compound value carries a bad part beside well-formed neighbours

- **WHEN** a check reads a delimited value in which one part violates the rule the check enforces and
  the other parts do not
- **THEN** the check reports the violation
- **AND** it names the offending part rather than the whole value

#### Scenario: Every part of a compound value is empty

- **WHEN** a delimited value consists only of delimiters and whitespace, so no part carries content
- **THEN** the check reports the value as carrying no usable entry
- **AND** the verdict is not affected by the value being neither absent nor empty as a whole

#### Scenario: The value the check reads is a scalar

- **WHEN** a check reads a value the standard defines as single-valued
- **THEN** the value is validated as a whole
- **AND** this is not treated as an exception to the rule, because a scalar has no parts to split

#### Scenario: Two representations of one value are compared for identity

- **WHEN** a check compares a projected copy of a value against its home of record
- **THEN** the comparison is made over the whole value
- **AND** the rule does not require it to be split, because identity is not compound validation

### Requirement: The rule is stated with the demonstrations that earned it and with its cost

The standard SHALL state the compound-value rule alongside the instrument rules it is a sibling of,
and SHALL carry both demonstrations that earned it: a scope declaration accepted as closed because an
open token sat among well-formed neighbours, and a keyword list accepted as filled in because a value
of delimiters and whitespace was neither absent nor placeholder-bearing. The statement SHALL record
the cost, which is that per-token validation is stricter than whole-value validation and can reject a
sloppy but well-intentioned declaration.

#### Scenario: A reader asks why the rule exists

- **WHEN** a reader reaches the compound-value rule in the standard
- **THEN** both demonstrations are stated with the defect each one produced
- **AND** the rule is placed with the other rules governing the checks the standard ships

#### Scenario: A maintainer weighs adopting the rule

- **WHEN** a maintainer reads the rule before applying it to a new check
- **THEN** the cost of per-token validation is stated
- **AND** the statement does not present the rule as free

### Requirement: A declared keyword list is validated token by token

A check on a comma-separated keyword list a hub declares SHALL split the value on the comma, trim each
token, and require at least one token carrying an alphanumeric character. A value whose tokens all
trim to nothing SHALL be reported as an error naming the empty entries. An empty value and a value
carrying an unsubstituted placeholder SHALL continue to be reported as they were.

#### Scenario: The value is a delimiter and whitespace only

- **WHEN** the declared keyword list is a value such as `, ,` in which no token carries content
- **THEN** the check reports that the value carries no usable keyword
- **AND** the scan does not report the hub as clean

#### Scenario: The value has a leading or trailing delimiter and nothing else

- **WHEN** the declared keyword list is a lone delimiter, leaving no real keyword on either side
- **THEN** the check reports that the value carries no usable keyword

#### Scenario: The value is a legitimate multi-keyword list

- **WHEN** the declared keyword list carries several non-empty keywords separated by commas
- **THEN** the check does not fire
- **AND** the deployment block reports its binding as complete

#### Scenario: The value is a single legitimate keyword

- **WHEN** the declared keyword list carries exactly one non-empty keyword and no delimiter
- **THEN** the check does not fire

#### Scenario: The value is empty

- **WHEN** the declared keyword list is empty
- **THEN** the check reports it as empty in the terms it already used

#### Scenario: The value carries an unsubstituted placeholder

- **WHEN** the declared keyword list carries an unsubstituted initialisation placeholder in any
  position
- **THEN** the check reports the unsubstituted value

### Requirement: The keyword gate proves the field was filled in and not that the keywords are right

The keyword gate SHALL state that it proves only that the field carries something a surface could
match on. It SHALL NOT judge keyword quality, count, vocabulary, or fitness for the hub's subject, and
the standard SHALL keep that limit stated rather than let per-token validation be read as a stronger
claim than it is.

#### Scenario: The declared keywords are well formed and unfit

- **WHEN** the declared keyword list carries tokens that are well formed and that no real source will
  ever match
- **THEN** the check passes
- **AND** the standard states that this outcome is within the gate's declared limit

#### Scenario: A maintainer proposes widening the gate to judge quality

- **WHEN** a change would have the gate rank or reject keywords on their content
- **THEN** the limit is a deliberate boundary of this capability and widening it is a separate change

### Requirement: The keyword gate stays behind the interview gate and reports one defect per act

The keyword gate SHALL be evaluated only when the hub's initiation interview date is itself valid. A
hub that was never interviewed SHALL be reported as uninterviewed and SHALL NOT additionally be
reported for its keyword field, because both are fixed by the same act.

#### Scenario: The hub carries no interview date

- **WHEN** the deployment binding carries no valid initiation interview date
- **THEN** the hub is reported as not initiated
- **AND** no keyword error is reported beside it

#### Scenario: The hub is interviewed and the keyword field is bad

- **WHEN** the interview date is valid and the keyword list carries no usable token
- **THEN** the keyword error is reported

### Requirement: The class is swept across the shipped checks and the sweep is recorded

The standard SHALL record which of the checks it ships were examined for this class, what the sweep
concluded, and against which revision it was run, so that the finding is available to the next
maintainer rather than repeated blind. A recorded sweep SHALL be re-verified against the tree before
it is carried into a later change as fact.

#### Scenario: A maintainer asks whether the class was swept

- **WHEN** a maintainer reads the rule
- **THEN** the sweep's scope and conclusion are recorded with it
- **AND** the record states that everything outside the two repaired instances either validates per
  part already or reads a single-valued field

#### Scenario: A prior session's sweep is reused

- **WHEN** a change relies on a sweep conclusion an earlier session recorded
- **THEN** the conclusion is re-verified against the current tree before it is recorded as fact

#### Scenario: A new check reads a compound value

- **WHEN** a check is added after the sweep and reads a list, a set, or a delimited sequence
- **THEN** the rule binds it, because the sweep is a point-in-time finding and the rule is an
  obligation

### Requirement: The repaired keyword gate is proved in both directions and against the unrepaired scan

The repair SHALL ship canaries proving the gate fires on an all-empty-token value and on a lone
delimiter, and proving it does not fire on a legitimate multi-keyword value or a legitimate single
keyword. Those canaries SHALL be run against the unrepaired scan and SHALL be shown to fail there, so
that a canary passing against both the defect and the repair is not recorded as evidence.

#### Scenario: The negative direction is proved

- **WHEN** the canaries run against a hub whose keyword list carries no usable token
- **THEN** the scan reports the error and exits non-zero

#### Scenario: The positive direction is proved

- **WHEN** the canaries run against a hub whose keyword list is legitimate
- **THEN** the scan does not report a keyword error and the hub scans green

#### Scenario: The canaries run against the unrepaired scan

- **WHEN** the new canaries are run against the scan as it stood before the repair
- **THEN** the firing cases fail there
- **AND** a canary that passes against both the unrepaired and the repaired scan is not recorded as
  proof
