# Capability: verification-instrument-integrity

What a verification instrument must do so that its verdict is produced by the property it claims to
judge: how it reads a delimited block, how it recognises a directive addressed to it, what it asserts
about an operation that changes a tree, and how a runner's published description of itself is kept
true.

## ADDED Requirements

### Requirement: A delimited block is read only when its delimiters are both present

A check that validates a delimited block SHALL confirm the closing delimiter as well as the opening
one, and SHALL treat an unterminated block as a violation rather than reading to end of file. A
reader that stops at end of file cannot distinguish a block from a document, so every key in the body
becomes a key in the block and a malformed file is reported as conforming.

Within a block so delimited, a key that appears more than once SHALL be a violation. A reader that
takes the first match of a key silently discards a contradicting value, and the value it discards is
the one a differently written reader would have used.

#### Scenario: The closing delimiter is absent

- **WHEN** a file opens a frontmatter block and no closing delimiter follows
- **THEN** the check reports the file as violating
- **AND** it exits non-zero
- **AND** it does not report the file as carrying conforming frontmatter

#### Scenario: The block is closed with a different marker

- **WHEN** a file opens a frontmatter block and closes it with a marker other than the one the
  contract names
- **THEN** the check reports the file as violating

#### Scenario: A key appears twice inside the block

- **WHEN** a frontmatter block declares the same key twice with different values
- **THEN** the check reports the file as violating
- **AND** it names the duplicated key

#### Scenario: The block is well formed

- **WHEN** every shipped file opens its block, closes it, and declares each required key exactly once
- **THEN** the check passes
- **AND** the verdict is identical to the verdict the same tree produced before this requirement

### Requirement: A directive token is read only where a directive is declared

An instrument that changes its own behaviour on finding a token in a scanned file SHALL read that
token only from a position where a declaration can be made, and SHALL NOT honour a token that appears
as quoted text. At minimum the token SHALL begin its line, after optional whitespace and at most one
comment marker, and SHALL NOT be honoured inside a fenced code block.

This SHALL apply to every such token an instrument reads, not only to the token whose defect was
reported. A quotation-triggered directive repaired in one instrument and left standing in another is
the same defect with a different file name.

#### Scenario: The token appears inside a fenced code block

- **WHEN** a scanned file contains a fenced code block whose content includes an exemption token
- **THEN** the instrument does not exempt that file
- **AND** the file is scanned
- **AND** any violation it carries is reported

#### Scenario: The token appears mid-sentence in prose

- **WHEN** a scanned file mentions an exemption token inside a sentence, in backticks or otherwise,
  rather than at the start of a line
- **THEN** the instrument does not exempt that file

#### Scenario: The token is declared at the start of a line

- **WHEN** a scanned file carries an exemption token at the start of a line, outside any fenced
  block, with a non-empty reason
- **THEN** the instrument exempts that file
- **AND** it names the file and the reason on its passing run

#### Scenario: A declared exemption carries no reason

- **WHEN** a scanned file declares an exemption token at the start of a line with an empty reason
- **THEN** the instrument refuses
- **AND** it does not return a passing verdict

### Requirement: A test of an operation that changes a tree asserts the change

A test whose subject is an operation that creates, replaces or refuses to replace a file SHALL assert
the state of that file after the operation, and SHALL NOT accept the operation's exit status as
evidence that the operation occurred. An operation that returns success without acting is
indistinguishable, to a status-only assertion, from one that acted.

A test whose subject is a refusal SHALL assert that the refusal left the tree unchanged, and SHALL
assert that the refusal named its own reason, so that a refusal produced by an unrelated error is not
recorded as the refusal under test.

#### Scenario: The operation returns success without acting

- **WHEN** an installer is altered to print its success message and exit zero without writing
  anything
- **THEN** the test fails
- **AND** it names the file whose expected content is absent

#### Scenario: The operation refuses and must leave the tree alone

- **WHEN** an installer refuses to overwrite an unmanaged file
- **THEN** the test asserts the file's content is unchanged
- **AND** the test asserts the refusal message named the unmanaged file

#### Scenario: The operation acts as specified

- **WHEN** the installer replaces the unmanaged file under its replacement flag
- **THEN** the test asserts the file now carries the managed marker
- **AND** the test asserts the file no longer carries the content it replaced

### Requirement: A runner's published description of itself is true and is not a copy

A continuous integration definition SHALL describe its runner image in terms of what the platform
actually guarantees, and SHALL NOT call a mutable version label a pin. A version label that the
platform redeploys on a schedule selects a version, not an image.

Where such a definition would otherwise restate a set of statements that lives in the tool it runs,
it SHALL obtain them from that tool at run time rather than copying them. A tool that publishes a set
of limits SHALL expose those limits from a single definition, used by its own passing output and by
any command that prints them, so that adding a limit changes one place.

#### Scenario: The workflow describes its runner image

- **WHEN** the workflow selects a version-labelled hosted runner image
- **THEN** its comment states that the image behind the label is redeployed by the platform
- **AND** it does not describe the label as a pin

#### Scenario: A limit is added to the tool

- **WHEN** a limit is added to the tool's single definition
- **THEN** the command that prints the limits prints it
- **AND** the tool's passing output prints it
- **AND** no continuous integration file has to be edited for the printed set to be current

#### Scenario: The mechanism is pinned by a check

- **WHEN** the repository's own suite runs
- **THEN** it asserts the limits command prints every limit the tool defines
- **AND** it asserts the continuous integration definition invokes that command
