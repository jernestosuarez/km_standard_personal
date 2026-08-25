# Capability: release-verification-scope

Which tree a release gate's verdict is about, and what it must establish about that tree before it
returns one.

## MODIFIED Requirements

### Requirement: A gate's verdict is about the tree it discovered, established rather than assumed

A release gate SHALL establish that the tree it returns a verdict about is the tree it **read**, and
SHALL NOT assume it. Discovery runs at the start of a pass and the verdict is returned at the end; on
a repository of any size those are separated by minutes, during which the tree is editable by the
maintainer the gate is run for.

The gate SHALL take a **fingerprint** of what it reads before discovery and again before the verdict,
and SHALL compare the two.

The fingerprint SHALL cover **every input class the gate reads**, not only the checks it discovers.
Discovery answers *what will be run* and is one input class among several; a gate that also parses
data files, resolves references or syntax-checks sources reads those files too, and an input that is
not fingerprinted may change after the phase that read it has finished, leaving the verdict covering a
tree in which the thing checked no longer looks the way it looked when it was checked. This
requirement previously said "the same set discovery covers"; that was the narrow part, and it is
widened here.

The covered set SHALL be **derived from the phases that consume it** rather than listed beside them. A
single structure SHALL hold every input class's pathspecs, every phase SHALL take its pathspecs from
that structure, no phase SHALL name a pathspec literal of its own, and the fingerprint SHALL iterate
that structure. A case SHALL require the derivation, so that a phase added later which reads a new
class cannot fall outside the fingerprint silently.

The fingerprint SHALL cover tracked files **and untracked files the ignore rules do not exclude**, and
SHALL be taken over file **content** rather than over names or sizes alone. It SHALL continue to
exclude ignored paths, because the checks and tools legitimately write inside the tree they run in and
a fingerprint over their artifacts converges on a gate that refuses every run.

The fingerprint SHALL additionally include **what is checked out, as the commit and the symbolic
reference standing at it**. A revision identifier alone does not identify a branch: two branches at
one commit return the same value, so a same-commit branch switch changes what is being gated while
every file and every hash holds still. Where a gate promises that a branch change is caught, it SHALL
record the symbolic reference; where it does not so promise, the claim, the case that proves it and
the version record SHALL narrow together. A detached `HEAD` SHALL report a stable value and SHALL NOT
become a refusal on every run.

Where the two fingerprints differ, the gate SHALL **refuse**, under its own refusal status, and the
refusal SHALL name what changed. It SHALL NOT return a pass, and it SHALL NOT re-run itself silently.
A refusal on this ground SHALL take precedence over a failing verdict as well as over a passing one.

The gate SHALL NOT implement this by running against an immutable snapshot of tracked content. A gate
that discovers the working tree does so in order to see a check authored in the change being gated,
which is untracked at the moment the gate runs; snapshotting tracked content would withdraw that
coverage while appearing to add a guarantee.

The residual SHALL be stated rather than implied closed, in the gate's own stated limits and in the
check's own words: a before/after comparison cannot detect a change that is undone within the window,
because both ends are identical by construction; two different detached states at one commit are
indistinguishable for the same reason; and material in no input class — read by a discovered check but
not by the gate — is not fingerprinted. A case SHALL pin what remains outside as a gap rather than as
a control.

#### Scenario: A discovered check is edited while the gate runs

- **WHEN** a discovered check's content changes between the start of a pass and its verdict
- **THEN** the gate refuses under its refusal status
- **AND** the refusal names the check that changed

#### Scenario: A check-shaped file appears while the gate runs

- **WHEN** a file that discovery would have discovered appears after discovery has run
- **THEN** the gate refuses rather than returning a verdict that silently excludes it
- **AND** the refusal names the file that appeared

#### Scenario: An input the gate read but did not discover changes while the gate runs

- **WHEN** a file in any input class the gate reads — a markdown file whose links were resolved, a
  JSON file that was parsed, a shell or Python file that was syntax-checked — changes after the phase
  that read it has run
- **THEN** the gate refuses and names that file
- **AND** the refusal is reached whether or not the file lies under a check directory

#### Scenario: A phase names a pathspec of its own

- **WHEN** any phase of the gate obtains its file set from a pathspec literal rather than from the
  single input-class structure the fingerprint iterates
- **THEN** a case fails, because the covered set is no longer derived from the phases that consume it

#### Scenario: The branch changes while the commit does not

- **WHEN** the checked-out branch changes during a pass and the commit is identical before and after
- **THEN** the gate refuses and names the reference change
- **AND** the refusal is reached by the symbolic reference rather than by the commit or by any content
  comparison

#### Scenario: A detached HEAD is gated

- **WHEN** the gate runs on a tree whose `HEAD` is detached and nothing changes during the pass
- **THEN** the gate returns its ordinary verdict
- **AND** no refusal is raised on the ground of what is checked out

#### Scenario: A stable tree still passes, and passes the same way twice

- **WHEN** the gate runs twice over a tree that nothing is editing
- **THEN** both runs return the same passing verdict
- **AND** the stability check introduces no run-to-run variation

#### Scenario: A file in no input class changes during a pass

- **WHEN** a file that only a discovered check reads, and that no phase of the gate reads, changes
  during a pass
- **THEN** the gate returns its ordinary verdict, because that file is not fingerprinted
- **AND** this is recorded as a stated limit and pinned by a case as a gap rather than as a control
