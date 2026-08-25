# Capability: documentation-truth

How a repository states a count of something it holds, and on what terms a dated record is corrected
rather than rewritten to agree with the present.

## ADDED Requirements

### Requirement: A count of a growing set is derived or dropped, and a dated record is corrected only where it was wrong when written

A surface stating how many of something a repository holds SHALL derive the figure from the home of
record, or SHALL state no figure and name where the figure is read. Where a count genuinely helps and
cannot be derived, it SHALL be written as a lower bound or carry the date it was measured, since
neither form can be falsified by growth. A number refreshed in place is the same defect one week
younger.

A dated record SHALL be corrected where its statement was false on the day it was written, and SHALL
NOT be rewritten where it was true then and has been overtaken since. The discriminator is a
measurement of the thing the statement names, taken as at the moment of writing, and that measurement
SHALL be recorded beside the repair. A correction SHALL name itself as a correction and SHALL state
what the record previously said, so a reader meets a correction rather than a contradiction; where
the record has already been pushed, the pushed objects SHALL be left as they are.

Where a statement was true when written and invites a present-tense reading it cannot keep, it SHALL
be dated rather than refreshed or deleted.

This requirement reaches a claim about a set an instrument can list. It reaches no judgement, no
description's accuracy, and no claim about whether a document that should have been cited was cited,
and where a claim is a judgement the surface SHALL narrow it and state that no check covers it.

#### Scenario: A landing page enumerates the skills a template installs

- **WHEN** a landing page names the per-hub skills a shipped template installs
- **THEN** that enumeration is compared against the template's own runtime trees by a check
- **AND** a member the template installs and the page omits fails that check
- **AND** a member the page names and the template does not install fails it too

#### Scenario: A published record states a count that was wrong on the day it was written

- **WHEN** a version row states a number of entry points that the surface never had
- **THEN** the row is corrected in the ledger and the correction names itself
- **AND** the row states what the original number actually counted
- **AND** the pushed commit and tag carrying the original wording are left unchanged

#### Scenario: A published record states a measurement that was true when taken and has since grown

- **WHEN** a version row cites a file count as the evidence a decision rested on
- **AND** the tree has grown since that decision
- **THEN** the number is not refreshed, because refreshing it would assert the decision was taken on
  a tree that did not exist
- **AND** the number is not deleted, because it is the evidence the decision rested on
- **AND** the statement is dated, so it says which day it is about

#### Scenario: A contract instructs a report to state a fixed number of an instrument's limits

- **WHEN** a maintainer contract tells every report to read a named count of limits from an instrument
- **AND** the instrument holds those limits in one definition and prints them
- **THEN** the contract states no count and orders the set to be taken from the instrument
- **AND** any substance the contract needs is stated as substance rather than as an enumeration
