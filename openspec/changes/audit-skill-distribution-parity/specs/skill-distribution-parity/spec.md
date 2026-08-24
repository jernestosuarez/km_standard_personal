# Capability: skill-distribution-parity

What it means for a skill shipped in more than one location to be the same skill in each: which copy
is canonical, what may legitimately differ between copies, and what the gate on that duplication must
compare, must state, and must refuse.

## ADDED Requirements

### Requirement: A skill shipped in more than one location carries the same governed body in every copy

A skill shipped in more than one location SHALL carry the same governed instruction body in every
copy. Copies MAY differ only by substitutions the standard documents as per-runtime, and every other
difference SHALL be treated as drift rather than as a local variant.

#### Scenario: A governance instruction is present in one copy and absent in another

- **WHEN** one copy of a skill carries an instruction the other copies do not
- **THEN** the difference is reported as drift
- **AND** the slug and the differing copies are named

#### Scenario: Copies differ only by a documented per-runtime substitution

- **WHEN** the only difference between two copies is a substitution the standard documents as
  per-runtime
- **THEN** the copies are in parity
- **AND** no drift is reported

#### Scenario: Every copy carries the same body

- **WHEN** the governed body of every copy of a slug is equal after documented substitution
- **THEN** the slug is in parity

### Requirement: One copy is canonical and the advertised copy is never the weaker one

One location SHALL be named as the canonical copy of each shipped skill, and it SHALL be the location
the repository advertises as distributable. The copy advertised as distributable SHALL NOT carry a
weaker instruction body than any mirror of it, and a divergence SHALL be resolved by raising the
weaker copy rather than by removing the instruction from the stronger one.

#### Scenario: The advertised copy lacks a protection a mirror carries

- **WHEN** the advertised copy omits an instruction that constrains what a skill may surface, and a
  mirror carries it
- **THEN** the advertised copy is brought up to the mirror
- **AND** the mirror is not reduced to match the advertised copy

#### Scenario: A reader asks which copy is authoritative

- **WHEN** a skill exists in a canonical location and in runtime mirrors
- **THEN** the standard names the canonical location
- **AND** it names the mirrors as mirrors of that copy

### Requirement: The parity check compares the governed body and not the frontmatter alone

A parity check over duplicated skills SHALL compare the governed instruction body of each copy. A
check that compares frontmatter alone SHALL NOT be recorded as establishing parity, because two
copies can carry identical frontmatter and materially different instructions.

#### Scenario: Frontmatter matches and the bodies differ

- **WHEN** two copies of a slug carry byte-identical frontmatter and different instruction bodies
- **THEN** the parity check reports drift
- **AND** the verdict is not affected by the frontmatter agreeing

#### Scenario: A per-runtime substitution appears in the body

- **WHEN** a documented per-runtime substitution appears inside the instruction body rather than in
  the frontmatter
- **THEN** the check normalises it before comparing
- **AND** it reports no drift for that difference alone

### Requirement: Permitted differences are documented before they are permitted

Every difference the parity check tolerates SHALL be documented in the standard as a per-runtime
substitution before the check tolerates it. An undocumented difference SHALL be reported as drift,
and the tolerance list SHALL NOT widen on its own to accommodate a difference found in the tree.

#### Scenario: An undocumented difference is found

- **WHEN** the copies differ in a way the standard does not document as per-runtime
- **THEN** the difference is reported as drift
- **AND** it is not absorbed into the tolerance list

#### Scenario: A new per-runtime difference becomes necessary

- **WHEN** a legitimate new per-runtime difference is introduced
- **THEN** the standard documents the substitution in the same change that introduces it

### Requirement: The parity check fails closed when it cannot read a copy

The parity check SHALL refuse, without returning a parity verdict, when it cannot read or cannot
parse a copy it was asked to compare, when a mirror exists with no canonical copy behind it, or when
it found no skill to compare at all. An unreadable copy SHALL NOT be reported as a copy in parity and
SHALL NOT be silently skipped.

#### Scenario: A copy cannot be read

- **WHEN** a copy the check must compare cannot be read or decoded
- **THEN** the check refuses and names the copy
- **AND** it returns no parity verdict for the run

#### Scenario: A copy has no parseable frontmatter boundary

- **WHEN** a copy carries no frontmatter terminator, so its governed body cannot be delimited
- **THEN** the check refuses and names the copy

#### Scenario: A mirror has no canonical copy

- **WHEN** a slug is present in a runtime mirror tree and absent from the canonical location
- **THEN** the check refuses and names the slug

#### Scenario: Nothing was found to compare

- **WHEN** the check finds no skill in the canonical location
- **THEN** it refuses rather than reporting that every copy is in parity

### Requirement: The parity check states its coverage on a passing run

A passing run of the parity check SHALL state how many slugs it found, how many copy pairs it
compared, and how many documented substitutions it applied. A recorded pass that does not state its
coverage SHALL be treated as void rather than as clean.

#### Scenario: The check passes

- **WHEN** the check completes with no drift
- **THEN** its passing line names the slugs found, the pairs compared, and the substitutions applied

#### Scenario: The check compares nothing yet reports success

- **WHEN** a run reports success while having compared zero pairs
- **THEN** that result is treated as void rather than as parity

### Requirement: The parity check is proved against the divergence it was written for

The parity check SHALL be proved to fire on a synthetic divergence, proved not to fire on a
documented per-runtime substitution, and proved against the unrepaired tree in which the real
divergence exists, where it SHALL name that divergence. A check proved only against synthetic input
SHALL state that limit.

#### Scenario: A synthetic divergence is introduced

- **WHEN** a line is added to one copy and not the others
- **THEN** the check reports drift and names the slug

#### Scenario: The documented substitution is exercised

- **WHEN** the tree contains a slug whose copies differ only by the documented per-runtime
  substitution
- **THEN** the check does not report drift for that slug

#### Scenario: The check runs against the unrepaired tree

- **WHEN** the check is run against the tree as it stood before the repair
- **THEN** it reports drift on the real divergence
- **AND** it names the slug and the copies that differ
