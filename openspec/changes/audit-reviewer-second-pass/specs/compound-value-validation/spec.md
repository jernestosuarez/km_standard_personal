# Capability: compound-value-validation

What a check must read before it judges a value the format it is written in defines as one thing.

## ADDED Requirements

### Requirement: A check judges the logical value, never its first physical line

Where a format folds a value across continuation lines, a check reading that value SHALL reconstruct
the whole logical value before judging it, and SHALL NOT judge the first physical line alone. A plain
scalar in a frontmatter block is the case that occurs: every more-indented line following the key
belongs to the value, and a check that reads the key's own line and stops is measuring a fragment.

This requirement composes with per-part validation in one direction only. Splitting a value into its
parts SHALL be performed on the reconstructed logical value; splitting a truncated value validates the
parts of a fragment perfectly and proves nothing about the value the format defines.

A reader reconstructing such a value SHALL be **state-aware**. It SHALL record which key a
continuation continues and fold the continuation into that key. An indented line that **no key
precedes** SHALL be reported as a violation rather than skipped, because a line that continues nothing
is not a continuation, and skipping every indented line unconditionally is what allows a swallowed
document body to read as a conforming block.

A check SHALL NOT acquire a new parser dependency in order to meet this requirement where the
reconstruction can be performed by the tooling the check already requires. A parser present on the
maintainer's machine is not necessarily present in the environment a deployment runs the check in,
and this standard already records a version repairing a shipped tool that assumed its author's
toolchain. Where the reconstruction is performed without a parser, its coverage SHALL be stated: it
models the folding the standard's own files use, not the whole of the format.

Any matching construct used to recognise a continuation SHALL be verified against the tool that will
actually run it, since a construct the tool does not honour matches nothing, and nothing is what a
conforming input also looks like.

The tightening SHALL ship with a case asserting that a legitimate multi-line value **within** the
rule's bounds is still accepted, because a reader tightened until it rejects valid input is the same
defect wearing the opposite sign.

#### Scenario: A folded value outside the budget is reported

- **WHEN** a value's first physical line satisfies a length rule and its folded value does not
- **THEN** the check reports the value as violating the rule
- **AND** the count it reports is the count of the folded value

#### Scenario: An indented line that continues no key is reported

- **WHEN** an indented line appears in the block before any key has been opened
- **THEN** the check reports it as a violation
- **AND** it is not skipped as a continuation

#### Scenario: A legitimate multi-line value within the rule is accepted

- **WHEN** a value spans two lines and its folded value satisfies every rule
- **THEN** the check reports no violation
- **AND** it does so both before and after the tightening

#### Scenario: The reconstruction adds no parser dependency

- **WHEN** the check runs in an environment carrying no library parser for the format
- **THEN** the check still reconstructs and judges the logical value
- **AND** its stated coverage names the subset of the format it models
