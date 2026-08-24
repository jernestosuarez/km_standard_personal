# Capability: publisher-portability

What an executable tool the standard ships must do about interpreter discovery, dependency pinning,
the state it generates inside a governed tree, the external binaries it calls, and the platform claims
it makes about itself.

## ADDED Requirements

### Requirement: A shipped tool discovers its interpreter portably and honours an explicit override

A tool that bootstraps its own runtime SHALL NOT locate an interpreter by a single hardcoded
filesystem path belonging to one package manager on one platform. It SHALL consult an explicit
operator-supplied override before any search, SHALL search the operator's `PATH` before any
conventional install prefix, and SHALL accept a candidate only after verifying that it meets the
stated minimum version and can create a virtual environment.

#### Scenario: An operator names their own interpreter

- **WHEN** the override environment variable names a usable interpreter
- **THEN** the tool uses that interpreter and consults no search path
- **AND** the resolved interpreter is reported, so the operator can see which one was taken

#### Scenario: The override names an interpreter that cannot work

- **WHEN** the override names a path that is absent, is not executable, or is below the minimum version
- **THEN** the tool refuses and names the override, the value it was given and why it was rejected
- **AND** the tool does NOT silently fall back to a search, because an override quietly ignored makes
  the operator's account of what happened false

#### Scenario: A usable interpreter is first on PATH

- **WHEN** no override is set and a supported interpreter is on `PATH`
- **THEN** the tool finds it without reference to any package manager's prefix

#### Scenario: The host is not the author's host

- **WHEN** the tool runs on a platform where the author's package-manager prefix does not exist
- **THEN** discovery proceeds through `PATH` and the remaining conventional prefixes rather than
  failing at the first missing directory

### Requirement: The minimum interpreter version is derived from the dependency, not assumed

The tool SHALL state a minimum interpreter version, and that version SHALL be the one the pinned
dependency itself declares, read from the dependency's own metadata. An interpreter below the minimum
SHALL be rejected during discovery rather than accepted and left to fail at install time.

#### Scenario: An interpreter below the floor is present

- **WHEN** the only interpreter available is older than the pinned dependency supports
- **THEN** discovery rejects it and the refusal names the minimum version required

#### Scenario: An interpreter cannot build a virtual environment

- **WHEN** a candidate meets the version floor but cannot import the modules needed to create a
  virtual environment
- **THEN** it is not accepted, because failing later reports the wrong cause

### Requirement: A refusal names the platform, the requirement, and the route out

When a tool cannot bootstrap, the message SHALL name the platform it is running on, the requirement
that was not met, what it searched, and the override that lets an operator answer directly. Install
guidance SHALL be selected for the platform actually detected. Platform-specific knowledge that is
true SHALL be preserved as a note for that platform rather than presented as the whole diagnosis or
deleted.

#### Scenario: Bootstrap fails on a platform the author never used

- **WHEN** no usable interpreter is found
- **THEN** the message names the operating system and architecture reported by the host
- **AND** it does not prescribe a package manager that does not exist on that platform

#### Scenario: A platform carries a non-obvious constraint

- **WHEN** the platform has a known constraint that explains a failure an operator would otherwise
  misdiagnose
- **THEN** the constraint is stated in that platform's branch of the message
- **AND** it is not shown to operators of other platforms, for whom it is noise

### Requirement: A bootstrapped dependency is pinned, and the pin is visible with its reason

A tool that installs a dependency at run time SHALL install a pinned version, SHALL hold that pin in
one named place, and SHALL record beside it why the pin exists. An existing environment whose
installed version does not match the pin SHALL be rebuilt rather than used.

#### Scenario: The same script is run months apart

- **WHEN** the tool bootstraps on two different days
- **THEN** it installs the same dependency version on both

#### Scenario: An environment predates the current pin

- **WHEN** an environment exists carrying a version other than the pin
- **THEN** the tool rebuilds it rather than rendering with an unpinned version it did not choose

#### Scenario: A maintainer changes the pin

- **WHEN** the pin is edited in its one named place
- **THEN** what runs changes, with no other edit needed

### Requirement: Generated runtime state does not dirty a governed tree

A tool that generates a runtime environment SHALL place it outside any governed tree by default, and
SHALL allow an operator to relocate it. The in-tree location SHALL additionally be ignored by the
repository's ignore rules and by the ignore rules shipped to deployments, and SHALL be exempted from
every whole-tree walk the shipped scan performs, not only the one that reported the defect.

#### Scenario: A hub renders a document

- **WHEN** an operator runs the publisher inside a governed hub
- **THEN** the hub's integrity scan reports the monitored state as clean afterwards
- **AND** the operator is never presented with committing a virtual environment as the remedy

#### Scenario: A deployment predates this rule

- **WHEN** a hub created before this version already carries an environment directory in its tree
- **THEN** the scan exemption covers it, so the fix does not depend on that hub's ignore file being
  updated

#### Scenario: An operator relocates the environment back into a tree

- **WHEN** the override points the environment inside a governed tree
- **THEN** the ignore rules and the scan exemption still cover it

#### Scenario: The scan walks the tree for a purpose other than integrity

- **WHEN** the shipped scan walks the whole hub for markdown, for its note index or its restricted
  surface, and an environment directory holds markdown of its own
- **THEN** that markdown is excluded from the walk, because a dependency's vendored document is not
  hub content and must not become a name a hub link can resolve against
- **AND** a markdown file outside the environment is still walked, so the exclusion is proved not to
  be a blanket one

#### Scenario: An exclusion pattern is written but does not match

- **WHEN** an exemption is added to a scan
- **THEN** the pattern is verified against the tool that will run it, because a pattern that matches
  nothing and a tree with nothing to match produce identical output

### Requirement: External binaries are checked by name before they are needed

A tool that calls an external binary SHALL check for it before the work that depends on it, and SHALL
report a missing binary by name together with what it is needed for and how to obtain it. A binary
whose absence prevents a required check SHALL be treated as required; a binary whose absence only
degrades reporting SHALL be a named warning and SHALL NOT fail the build.

#### Scenario: The text extractor is missing and the source is guarded

- **WHEN** the source has a guards sidecar and the text-extraction binary is absent
- **THEN** the tool refuses before rendering, names the binary and the package that supplies it
- **AND** the operator does not receive a downstream complaint about empty extracted text

#### Scenario: The page-count binary is missing

- **WHEN** the binary that supplies the page count is absent
- **THEN** the build proceeds and warns, naming the binary
- **AND** a page-count rule that could not be evaluated is reported as unevaluated rather than passed

#### Scenario: The text extractor is missing and the source is unguarded

- **WHEN** no guards sidecar exists for the source
- **THEN** the absence of the text extractor does not block the build, because nothing needed it

### Requirement: A bootstrap is testable without performing the work it bootstraps

A tool SHALL expose a way to run its environment resolution and its binary checks, and report what it
resolved, without installing anything and without producing its output artifact.

#### Scenario: A suite proves discovery

- **WHEN** the suite drives the tool with a controlled environment
- **THEN** override handling, discovery failure and binary checks are each exercised
- **AND** nothing is installed and no artifact is produced on the host running the suite

#### Scenario: The pin is asserted

- **WHEN** the suite reads what the tool reports
- **THEN** the pinned dependency version is among what it states, so a pin silently removed is caught

### Requirement: Platform support is claimed only where it was exercised

Documentation and error text for a shipped tool SHALL name the platforms on which it was actually
exercised, and SHALL label as unverified any platform whose code path exists but was not run. A
platform that cannot work SHALL be named together with the reason.

#### Scenario: A forker reads the platform statement

- **WHEN** a reader with no access to the authoring session asks what this tool runs on
- **THEN** they find which platform was exercised, which is written but unverified, and which is out
  of scope with a reason

#### Scenario: A maintainer is tempted to claim coverage

- **WHEN** a code path for a platform is written carefully but never executed
- **THEN** the text says the path is written and unverified rather than implying it was exercised
