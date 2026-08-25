# Capability: compound-value-validation

How a check reads a value the format defines as one thing, and what it may claim about the result.

## ADDED Requirements

### Requirement: A character class borrowed from the host language is not the format's

A reader SHALL derive the character set of a format position from the **format**, never from the host
language's convenience class for it.

A dependency-free reader that models a document format is written in some other language, and that
language's character classes carry their own definitions. Where the modelled format is **stricter**
than the host language's class, the reader SHALL NOT use the host class as if it were the format's.

Specifically: a class the host calls "whitespace" generally **contains the tab**, and a format may
forbid the tab in the position the class is being used for. Using such a class to recognise that
position accepts, silently and by construction, documents the reference parser refuses — the false
pass this capability already forbids.

For every construct where the format is stricter than the host, the change SHALL **probe the actual
boundary against the reference parser**, one case at a time, and SHALL record the answers beside the
rule. The record SHALL include the shapes the parser **accepts** as well as the shapes it rejects,
because a rule tightened past the parser produces false failures and is discovered by a deployment
rather than by the author.

Where the reader's rule is deliberately **stricter** than the format, the change SHALL declare the
divergence, SHALL name what it refuses that the parser would accept, and SHALL state which way the
resulting error can fall. A stricter rule may produce a false failure and SHALL NOT be able to
produce a false pass; that asymmetry is the argument for permitting it, and it SHALL be stated rather
than assumed.

#### Scenario: A reader recognises a position with a host character class

- **WHEN** a reader models a format position using a character class supplied by the host language
- **AND** the format forbids a character that class contains in that position
- **THEN** the reader is rejecting nothing in that case and accepting documents the parser refuses
- **AND** the repair derives the rule from the parser, with the probed boundary recorded beside it

#### Scenario: The reader is stricter than the parser

- **WHEN** a reader's rule refuses a shape the reference parser accepts
- **THEN** the divergence is declared, with the shape named
- **AND** the error direction is stated, and is a false failure rather than a false pass
