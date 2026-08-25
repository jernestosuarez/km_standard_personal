# Capability: release-verification-scope

Which tree a release gate's verdict is about, and what it must establish about that tree before it
returns one.

## ADDED Requirements

### Requirement: A gate's verdict is about the tree it discovered, established rather than assumed

A release gate SHALL establish that the tree it returns a verdict about is the tree it discovered,
and SHALL NOT assume it. Discovery runs at the start of a pass and the verdict is returned at the
end; on a repository of any size those are separated by minutes, during which the tree is editable
by the maintainer the gate is run for.

The gate SHALL take a **fingerprint** of what it reads before discovery and again before the verdict,
and SHALL compare the two. The fingerprint SHALL cover the same set discovery covers, by the same
pathspecs, **including untracked files the ignore rules do not exclude**, and SHALL be taken over file
**content** rather than over names or sizes alone. It SHALL additionally include the repository's
current revision identifier, so that a change of branch is detected even when every file's content
happens to match.

Where the two fingerprints differ, the gate SHALL **refuse**, under its own refusal status, and the
refusal SHALL name what changed. It SHALL NOT return a pass, and it SHALL NOT re-run itself silently:
a tree moving underneath a long pass is a fact the maintainer needs told, and a verdict about a tree
that no longer exists is withheld rather than issued. A refusal on this ground SHALL take precedence
over a failing verdict as well as over a passing one, because a failure measured against a tree
nobody has is no more useful than a pass measured against one.

The gate SHALL NOT implement this by running against an immutable snapshot of tracked content. A gate
that discovers the working tree does so in order to see a check authored in the change being gated,
which is untracked at the moment the gate runs; snapshotting tracked content would withdraw that
coverage while appearing to add a guarantee.

The residual SHALL be stated rather than implied closed, in the gate's own stated limits and in the
check's own words: a before/after comparison cannot detect a change that is undone within the window,
because both ends are identical by construction, and material outside the discovery set is not
fingerprinted at all. A case SHALL pin the narrow scope as a gap rather than as a control, so that a
later change widening it fails loudly instead of quietly redefining what a pass covers.

#### Scenario: A discovered check is edited while the gate runs

- **WHEN** a discovered check's content changes between the start of a pass and its verdict
- **THEN** the gate refuses under its refusal status
- **AND** the refusal names the check that changed
- **AND** no passing verdict is printed

#### Scenario: A check-shaped file appears while the gate runs

- **WHEN** a file that discovery would have discovered appears after discovery has run
- **THEN** the gate refuses rather than returning a verdict that silently excludes it
- **AND** the refusal names the file that appeared

#### Scenario: The revision changes while no file content differs

- **WHEN** the repository's revision identifier changes during a pass and every fingerprinted file's
  content is identical at both ends
- **THEN** the gate refuses and names the revision change
- **AND** the refusal is reached by the revision identifier rather than by any content comparison

#### Scenario: A stable tree still passes, and passes the same way twice

- **WHEN** the gate runs twice over a tree that nothing is editing
- **THEN** both runs return the same passing verdict
- **AND** the stability check introduces no run-to-run variation

#### Scenario: A change outside the discovery set is not detected

- **WHEN** a file outside the discovery set changes during a pass
- **THEN** the gate returns its ordinary verdict, because that file is not fingerprinted
- **AND** this is recorded as a stated limit and pinned by a case as a gap rather than as a control
