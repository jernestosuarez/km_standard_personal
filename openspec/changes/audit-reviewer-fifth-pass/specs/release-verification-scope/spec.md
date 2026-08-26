# Capability: release-verification-scope

Which tree a release gate's verdict is about, and what it must establish about that tree before it
returns one.

## MODIFIED Requirements

### Requirement: A gate's verdict is about the tree it read, and a read is any answer it took from that tree

A release gate SHALL establish that the tree it returns a verdict about is the tree it **read**, and
SHALL NOT assume it. Discovery runs at the start of a pass and the verdict is returned at the end; on
a repository of any size those are separated by minutes, during which the tree is editable.

The gate SHALL take a **fingerprint** before discovery and again before the verdict, and SHALL
compare the two. On any difference it SHALL **REFUSE**, naming what moved, and SHALL NOT pass and
SHALL NOT silently re-run.

**What the gate "read" SHALL be defined as every answer it took from the tree, not as a set of files
it opened.** A verdict is made of questions asked and answers used. A phase that opens no file but
asks whether a path exists, and puts the answer into the verdict, has read that path as surely as one
that hashes it; a ledger that records only content holds nothing about it, and the material behind
that answer may change after the phase has run while the verdict still rests on the old answer.

The property SHALL therefore be stated as: **every answer this run took from the tree is taken again
at the verdict, and must be the same answer.** Content is answered by its bytes. A path's presence is
answered by yes or no, and **both directions of a presence answer SHALL be treated as drift** — a
path that existed when it was asked about and is now absent, and a path that was absent when it was
asked about and now exists — because a failing verdict about a tree that no longer exists is no more
useful than a passing one, and the comparison SHALL therefore run before either verdict branch.

Every kind of question the gate can ask of the tree SHALL have **one place to ask it**, and that
accessor SHALL record the answer. A phase added later is then inside the covered set by construction
rather than by a list kept in step. The change that introduces such an accessor SHALL **sweep the
class**: it SHALL identify every other question the instrument asks of its subject whose answer feeds
the verdict — including questions that open no file, such as executability, directory presence, or
the result of an ignore query — and SHALL either route each through a recording accessor or state, in
the instrument itself, why it is outside.

A presence answer SHALL NOT be widened into a content hash. The run asked whether the path exists;
holding it to more than it asked reports drift the verdict never relied on, and an instrument that
refuses over what it did not read is the instrument that gets switched off.

The fingerprint SHALL continue to cover tracked files **and** untracked files the ignore rules do not
exclude, SHALL be taken over file **content** rather than names or sizes, and SHALL exclude ignored
paths, because the checks and tools legitimately write inside the tree they run in. It SHALL include
**what is checked out, as the commit and the symbolic reference standing at it**, and a detached
`HEAD` SHALL remain a stable state rather than a refusal.

A statically declared set of input classes MAY remain as the **opening baseline**, so that a file is
pinned from the start of the run; it SHALL NOT be presented as the guarantee.

The residual SHALL be stated as what it is: a path the run **never asked about**, an answer that
changes and changes back inside the window, a phase that bypasses every accessor, and any question
the instrument asks about something **other than the working tree** — a base revision, for example —
which SHALL be named rather than implied closed. A case SHALL pin that residual as a gap rather than
as a control, and SHALL be readable together with the cases that hold the covered side, so that the
boundary is held from both directions.

#### Scenario: A link target the gate resolved is deleted after the link phase runs

- **WHEN** a discovered check deletes a relative-link target that the gate's link phase had resolved
- **THEN** the gate refuses, naming the path as having existed when the run asked and being absent now

#### Scenario: A path the gate found absent is created after the phase that asked

- **WHEN** a path the gate asked about and found absent is created before the verdict
- **THEN** the gate refuses rather than returning the failing verdict it was about to return

#### Scenario: A path no phase ever asked about changes mid-run

- **WHEN** a file that no phase of the gate reads or asks about is changed while the gate runs
- **THEN** the gate still passes, and that residual is pinned by a case as a known gap
