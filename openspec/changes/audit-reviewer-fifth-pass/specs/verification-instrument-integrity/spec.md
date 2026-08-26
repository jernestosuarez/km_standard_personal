# Capability: verification-instrument-integrity

What a verification instrument may claim, what must be true of a repair to one, and what a record of
verification may assert.

## ADDED Requirements

### Requirement: A control whose claim is an absence SHALL measure an absence

Where a control's stated claim is that something is **not present**, the control SHALL establish that
absence directly. It SHALL NOT establish it by testing for the presence of something else — a
pointer, an invocation, a reference — because the presence of a pointer is compatible with the
presence of the thing the claim denies.

Where a claim conflates a presence and an absence, it SHALL be **split**: the presence asserted by a
test for the presence, and the absence asserted by comparing the derived surface against the
definition it derives from, so that the comparison cannot go stale when the definition changes.

The change SHALL state what the absence comparison measures and what it does not, and SHALL name the
error direction. Where a legitimate paraphrase of the definition exists on the derived surface, that
SHALL be stated rather than excluded by pattern.

A control that reports by absence SHALL ship with a case that **injects the thing it denies** and
requires the control to fire, because a control that reports by absence proves nothing about itself.

Any threshold introduced to separate the measured class from surrounding material SHALL be held by
its own case. A threshold added until the tree goes green, with no case requiring the behaviour it
permits, is a pattern lengthened to reach green and is refused by this standard's existing rule.

#### Scenario: A derived surface carries both the pointer and a hand copy

- **WHEN** a surface both invokes the authoritative source and restates its content verbatim
- **THEN** the control reports the restatement, and the case asserting the pointer does not claim the
  absence

### Requirement: Registering a defect is honest and is not a repair

A maintainer who finds a defect while repairing another SHALL take one of three actions, and SHALL
record which.

**Repair it**, which is the default whenever the repair is reachable in the change already open.

**Refer it**, which is legitimate only where the finding is a **policy question** about what the
artifacts may contain rather than a defect in how an instrument reads its input. A referral SHALL be
discharged by putting the question to the owner, and SHALL NOT be discharged by recording it in the
artifact.

**Defer it**, which is legitimate only where all four hold together: the defect is **bounded and
measured** rather than estimated; its **error direction** is stated and is a false failure rather
than a false pass; repairing it inside the current change would genuinely entangle two repairs; and
it is deferred **to a named version**. Where the difficulty that justifies the deferral has not been
measured, the measurement SHALL be taken before the deferral is written down.

**Disclosure is not closure.** A criterion that forbids open defects of a given severity SHALL NOT be
treated as satisfied by disclosing one.

Every item ever registered rather than repaired SHALL be enumerable with its **age**, its **class**
and the **version by which it is answered**. An entry carrying none of those is a defect with prose
beside it.

#### Scenario: A defect is found during an unrelated repair and deferred

- **WHEN** a maintainer defers a defect found while repairing another
- **THEN** the deferral records a measurement rather than an estimate of difficulty, an error
  direction, and the version by which the defect is answered

### Requirement: A verification declaration is a record of what was run

A declaration recording what an instrument found against an unrepaired tree SHALL be a record of what
was **actually run**, and SHALL NOT assert a result that was not obtained.

**A script that pins a revision cannot testify about any other revision.** Where a reproduction script
hard-pins a revision, or re-clones one, it tests that revision whatever root it is handed; where it
pins a **path**, it tests whatever tree stands at that path and ceases to be reproducible once the
path is gone; where it gates the root it is given, it testifies about that root. Which of the three a
script is decides what its output may be cited for.

Where a declaration cites a script by digest, the citation SHALL state **what that script pins**, or
SHALL state that it pins nothing. A digest that is not a well-formed digest is not a citation. This
converts an unverifiable property into a checkable one, as this standard already does for an
exemption with no stated reason; the instrument can see that the pin was stated and SHALL NOT be read
as seeing that the declaration is true.

Before publishing, the claims in an artifact SHALL be verified against the working report that
produced them, and **where the two disagree the artifact is wrong**. A claim that survives in a
working note is read once; a claim in a shipped file is read by every deployment that installs it.

Where a repair cannot be demonstrated by the script that reproduced the defect, the declaration SHALL
say so and SHALL name the means by which the repair **was** verified — an integrated case carrying the
fixture byte for byte, a differential measurement against the reference implementation, or a
de-pinned variant **declared as a modified script** with the modification named.

A published claim found to be false SHALL be corrected **in place and visibly**: the clause struck,
the version that struck it named, and what was measured instead recorded. A false claim deleted
silently leaves a reader of an already-installed copy no way to know their copy carried it.

#### Scenario: A declaration cites a reproduction script by digest

- **WHEN** a check's declaration cites a script by `sha256`
- **THEN** the citation states what that script pins, or states that it is unpinned, and the gate
  fails the tree otherwise

#### Scenario: A published declaration is found to be false

- **WHEN** a claim in a shipped artifact is found to have been false when published
- **THEN** the clause is struck in place with the correcting version named, and what was actually run
  is recorded beside it
