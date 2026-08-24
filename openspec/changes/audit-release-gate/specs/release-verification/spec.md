# Capability: release-verification

What one release gate must run and how it decides what to run, when it must refuse rather than
return a verdict, what a passing run must state, what a version must declare about running a new
check against the unrepaired tree, and which things the gate cannot do and must therefore say out
loud.

## ADDED Requirements

### Requirement: One command runs the whole gate and returns one verdict

The repository SHALL carry a single entry point that runs the whole release gate and returns one
pass or fail. It SHALL run every suite under the test directory, every validator under the script
directory, a syntax check over tracked shell files, a parse check over tracked JSON and JSON-LD
files, a syntax check over tracked Python files, and a relative-link check over tracked markdown. A
verification performed by choosing checks from memory SHALL NOT be recorded as the gate having run.

#### Scenario: A maintainer verifies a change before publication

- **WHEN** a version is prepared for publication
- **THEN** one command runs every check the repository ships and returns one verdict
- **AND** no check is selected by the maintainer's recollection of which ones matter

#### Scenario: A discovered suite fails

- **WHEN** any suite the gate discovered exits non-zero
- **THEN** the gate fails and names the suite and its exit status

#### Scenario: A discovered validator fails

- **WHEN** any validator the gate discovered exits non-zero
- **THEN** the gate fails and names it, because validators and suites are both in the run set

#### Scenario: A static check finds a defect

- **WHEN** a tracked shell file has a syntax error, a tracked Python file has a syntax error, a
  tracked JSON or JSON-LD file does not parse, or a relative link in tracked markdown resolves to
  nothing
- **THEN** the gate fails and names the file and the finding

#### Scenario: The whole tree is sound

- **WHEN** every discovered check passes and every static phase finds nothing
- **THEN** the gate passes and states its coverage
- **AND** a gate that failed here would prove as little as one that never fails

### Requirement: What runs is derived by discovery and never held as a list in the runner

The gate SHALL derive the set of checks it runs by discovering the tracked files in its declared
scope, taking each check from a file actually present. It SHALL NOT carry a list of check names, so
that adding, renaming or removing a check changes what the gate runs with no edit to the gate.

#### Scenario: A new check is added to the repository

- **WHEN** a new suite is added under the test directory and tracked
- **THEN** the gate runs it with no change to the gate itself

#### Scenario: A check is renamed or removed

- **WHEN** a check file is renamed or deleted
- **THEN** the gate's run set changes accordingly and no stale name is attempted

#### Scenario: A maintainer looks in the runner for the list of checks

- **WHEN** the runner is read for an enumeration of what it runs
- **THEN** no such enumeration exists
- **AND** the directories it discovers from are named as the scope the set is derived from

### Requirement: Anything discovered but not run is reported with its reason and is covered

A check the gate discovers but does not execute SHALL declare itself, SHALL state a reason, and
SHALL name a canary suite that runs in the same pass. The gate SHALL report it as skipped, print its
reason, and SHALL refuse when the reason is absent or when the named canary is not in the run set. A
discovered check SHALL NOT be silently dropped.

#### Scenario: An instrument takes a required argument

- **WHEN** a discovered check is an instrument that takes a required argument and exits with a usage
  status when run bare
- **THEN** the gate skips it, prints its reason, and names the canaries that exercise it
- **AND** the skip is counted on the coverage line rather than hidden

#### Scenario: The named canary would not run

- **WHEN** a check declares itself an instrument and names a canary file that the gate will not run
- **THEN** the gate refuses, because otherwise a check is deleted from the gate by one comment line

#### Scenario: The declaration states no reason

- **WHEN** a check declares itself an instrument and gives no reason
- **THEN** the gate refuses, so no exclusion is silent

#### Scenario: A file is excluded from the link scan

- **WHEN** a markdown file declares itself exempt from the relative-link check with a stated reason
- **THEN** the gate honours the exemption and prints the reason on the passing run
- **AND** an exemption with no reason is refused

### Requirement: The gate refuses rather than passes on anything it could not evaluate

The gate SHALL exit with a distinct refusal status, and SHALL NOT return a verdict about the tree,
when a file in scope cannot be read or decoded, when a discovered check cannot be executed at all,
when the discovery set is empty, when a declared discovery directory yields no check, or when the
tracked file set cannot be listed. A refusal SHALL state what could not be evaluated and SHALL say
that it is not a pass.

#### Scenario: A discovered check cannot be executed

- **WHEN** a discovered check cannot be started, or exits with the status that means its interpreter
  or a command it needs was not found
- **THEN** the gate refuses and names it
- **AND** an unrunnable check is not folded into a verdict about the tree

#### Scenario: The discovery set is empty

- **WHEN** no check is discovered anywhere in the declared scope
- **THEN** the gate refuses, because an empty set is not a clean one

#### Scenario: One discovery directory yields nothing

- **WHEN** one of the declared discovery directories yields no check while another yields some
- **THEN** the gate refuses, because a scope that has stopped matching looks exactly like a scope
  with nothing in it

#### Scenario: A tracked file cannot be read or decoded

- **WHEN** a file the gate must read is absent from the working tree, unreadable, or not decodable
- **THEN** the gate refuses and names the file rather than skipping it into a passing verdict

#### Scenario: The tree is not a listable repository

- **WHEN** the tracked file set cannot be listed
- **THEN** the gate refuses, because an unlisted repository is not an empty one

### Requirement: A passing run states its own coverage

A passing run SHALL state how many checks were discovered, how many ran, how many were skipped as
instruments, how many declarations were read and of which kinds, and how many files each static
phase examined. It SHALL name every file that exempted itself and the reason each gave. A recorded
pass that does not state those numbers is void rather than clean.

#### Scenario: The gate passes

- **WHEN** every phase passes
- **THEN** the passing line reports checks discovered, run and skipped, declarations read by kind,
  and the file counts of every static phase

#### Scenario: A phase could not be covered

- **WHEN** part of the gate could not be exercised, such as a currency check with no base revision
  to resolve against
- **THEN** it is reported as a coverage gap and is never folded into the verdict

#### Scenario: A reader asks what a recorded pass covered

- **WHEN** a maintainer reads a recorded pass
- **THEN** the numbers say what was looked at rather than only that nothing was found

### Requirement: A version that adds or changes a check declares its run against the unrepaired tree

Every check in the gate's discovery scope SHALL carry a machine-read declaration recording the
result of running it against the unrepaired tree: the version under which that run happened and what
it found, or an explicit token stating that no such tree existed or that none was recorded, with a
reason in either case. A missing declaration, or a declaration whose result text is empty, SHALL
fail the gate.

Where a base revision is resolvable, a check the change **adds** SHALL declare the version being
drafted, or that no unrepaired tree existed, and SHALL NOT plead that none was recorded. A check the
change **changes** SHALL have its own declaration line among the lines the change added. Where no
base revision is resolvable, both SHALL be reported as a coverage gap rather than folded into the
verdict.

#### Scenario: A check carries no declaration

- **WHEN** a discovered check has no unrepaired-tree declaration
- **THEN** the gate fails and names it

#### Scenario: A declaration is a token with no result

- **WHEN** a declaration names a version and states no result
- **THEN** the gate fails, because the result text is the declaration and the token alone is not

#### Scenario: A change adds a check and records nothing

- **WHEN** a check absent at the base revision declares that no run was recorded
- **THEN** the gate fails, because a check born in this change has no history to plead

#### Scenario: A change adds a check and declares the run

- **WHEN** a check absent at the base revision declares the version being drafted and what the run
  against the unrepaired tree found
- **THEN** the gate passes that check

#### Scenario: A change edits a check without touching its declaration

- **WHEN** a check that exists at the base revision differs from it and its declaration line is
  unchanged
- **THEN** the gate fails, so an edit cannot quietly outrun what the declaration claims

#### Scenario: A change edits a check and re-states its declaration

- **WHEN** the same edit also re-states the declaration line
- **THEN** the gate passes that check

#### Scenario: No base revision resolves

- **WHEN** the gate runs where no base revision can be resolved
- **THEN** currency is reported as a coverage gap and the verdict is drawn from the rest

#### Scenario: A declaration is made and is untrue

- **WHEN** a maintainer records a declaration for a run that did not happen
- **THEN** the gate cannot detect it, and this limit is stated rather than left for a green line to
  imply away

### Requirement: The gate runs in continuous integration on push and on pull request

The repository SHALL carry a continuous integration workflow that runs the gate on push and on pull
request. The workflow SHALL pin its runner image and its actions, SHALL state the expected duration
of a run, and SHALL state the gate's two limits so a green badge is not read as more than it is.

#### Scenario: A change is pushed or proposed

- **WHEN** a commit is pushed or a pull request is opened
- **THEN** the gate runs and its verdict is the job's verdict

#### Scenario: A reader estimates how long a run takes

- **WHEN** the workflow is read
- **THEN** it states the expected duration, because the slowest suites dominate the run

#### Scenario: A reader takes the green badge for a clean push

- **WHEN** the workflow passes
- **THEN** the workflow itself says what that pass does not cover

### Requirement: The gate states the things it cannot do

The gate SHALL state, in the standard and in its own output, that it does not run an organisation
leakage scan and cannot; that no runner supplies the second actor an adversarial pass requires; and
that it reads a check's exit status and cannot see inside a check that fails internally and returns
success. Each SHALL be stated as a limit of the gate rather than as a defect awaiting a fix, and the
gate's green result SHALL NOT be allowed to imply any of them.

#### Scenario: The leakage scan is expected of CI

- **WHEN** a reader asks why the gate does not scan a push for organisation leakage
- **THEN** the answer is that the denylist is generated from an organisation's own entity names and
  is kept outside this repository by design, since carrying it here would itself be the leakage the
  guard exists to prevent
- **AND** the gate proves the instrument through its canaries and never proves a given push clean
- **AND** the deployment's own fail-closed pre-push hook, which is local and untracked, remains the
  only thing that scans an actual push

#### Scenario: The green line is read as independent verification

- **WHEN** the gate passes
- **THEN** the pass says that the mechanical checks ran, not that anyone other than the author looked
- **AND** the minimum viable independence remains an adversarial pass by someone other than the
  change's author against the specific class being repaired

#### Scenario: A check fails internally and returns success

- **WHEN** a discovered check encounters a failure, does not propagate it, and exits zero
- **THEN** the gate passes, because it reads the check's verdict and cannot see inside it
- **AND** the limit is stated and pinned by a case asserting it as a gap, so a later change that
  closes it fails loudly rather than quietly redefining what a pass means
- **AND** what reaches inside a check is the canary obligation, which this capability does not
  replace

#### Scenario: A limit is treated as a backlog item

- **WHEN** either limit is read as a gap to be closed in a later version
- **THEN** the standard states it as a property of the gate, so a later maintainer does not spend the
  effort discovering why it cannot be closed

### Requirement: Running the gate is a step of the publish ritual

The documented publish ritual SHALL require the gate to run and pass before publication, beside the
clearing of the publishing version's own draft markings. The agent contract that ships the
maintainer role SHALL state the same obligation.

#### Scenario: A version is published

- **WHEN** the publishing commit is prepared
- **THEN** the gate has been run and has passed, and the ritual names that as a step rather than as
  advice

#### Scenario: The ritual and the agent contract disagree

- **WHEN** the ritual gains a step
- **THEN** the agent contract that ships the role is amended in the same change

### Requirement: The gate is proved in both directions and against a deliberately broken tree

The gate SHALL ship canaries that break exactly one thing per case and require the stated verdict,
and that give it whole trees and require it to pass. It SHALL additionally be run against a
deliberately broken tree and shown to fail there, which is the obligation it imposes on every other
check. A gate that passes against both a broken and a whole tree SHALL NOT be recorded as proof.

#### Scenario: The positive direction

- **WHEN** a fixture breaks one thing the gate checks
- **THEN** the gate fails or refuses, and names what it found

#### Scenario: The negative direction

- **WHEN** a fixture tree is whole
- **THEN** the gate passes and states its coverage

#### Scenario: The gate is run against a deliberately broken tree

- **WHEN** the gate runs against a tree in which a real check has been made to fail, made
  unexecutable, emptied from discovery, or stripped of its declaration
- **THEN** it fails or refuses in each case
- **AND** a gate that could not pass its own rule does not ship

#### Scenario: The gate itself stops firing

- **WHEN** a phase of the gate is deliberately neutered
- **THEN** the canaries fail, so a gate that has ceased to check something is detected

#### Scenario: The gate is held to its own declaration rule

- **WHEN** the gate is read for the declaration it requires of every check
- **THEN** it carries one of its own, because a rule its author exempts himself from is the failure
  this change exists to close
