# Capability: answer-surface-disclosure

What a consuming answer surface may reveal about material it will not answer from.

## ADDED Requirements

### Requirement: A consuming answer surface SHALL render restricted, ineligible and absent as one state

A consuming answer surface SHALL render a topic restricted beyond its declared clearance, a topic
whose evidence is ineligible to ground an answer, and a topic on which the corpus holds nothing as
indistinguishable: one no-answer state, byte-identical, disclosing neither sources nor the reason
for the silence. A differentiated refusal is an oracle: it confirms existence to a reader not
entitled to it, and enumeration maps the estate's restricted holdings from refusal patterns alone.

This requirement is a reconciliation with crossing law 3, not a replacement of it. Law 3 continues
to govern traffic between governed parties — registries, catalogues, proposals, change notices,
hub-to-hub references — where a steward is entitled to existence. An owner-adjudicated artifact
authored for `shareable/` is neither surface class: it is a human act under the proposal flow.
Because the reconciliation narrows the reach of published doctrine, it binds only on the owner's
explicit word at publication, stated in the drafted text.

#### Scenario: A restricted-only topic and an absent topic are queried

- **WHEN** the same serving surface receives a query naming a topic held only in restricted
  material and a query naming a topic the corpus has never held
- **THEN** the two responses are byte-identical

#### Scenario: A test asserts a differentiated refusal

- **WHEN** a test asserts that the surface distinguishes a restricted refusal from a genuine miss
- **THEN** that test fails against a conforming surface

#### Scenario: A stewardship surface names a restricted record

- **WHEN** a registry, catalogue entry or change notice names the existence of a record whose
  contents are restricted
- **THEN** law 3 governs and the name crosses, exactly as before this requirement

### Requirement: The rule SHALL state its own enforcement status

The requirement SHALL be described as convention until an implementation exists, because no shipped
instrument evaluates a serving surface while the query surface is quarantined, and any implementation
that would lift the quarantine SHALL ship the byte-identity case with it.

#### Scenario: An implementation seeks to lift the quarantine

- **WHEN** a query surface implementation claims every excluded content class is unreachable by
  identifier lookup and by query
- **THEN** its evidence includes the byte-identity case, because unreachable must render as the
  same bytes as absence
