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
tree in which the thing checked no longer looks the way it looked when it was checked.

**The covered set SHALL be a runtime fact rather than a claim about the gate's source text.** A
previous form of this requirement said the covered set SHALL be derived from a single structure that
every phase takes its pathspecs from, and required a case to enforce that derivation. The structure
was right; the enforcement was a pattern over source text, and a phase spelling its pathspec in any
unmatched form escaped it while the case reported the guarantee as held. So: every phase SHALL obtain
its files through accessors that **record what they hand out**, the closing fingerprint SHALL cover
every pathspec actually enumerated and every path actually opened during the run, and a phase added
later SHALL therefore be inside the covered set **by construction**. A statically declared set of
input classes MAY remain as the **opening baseline**, so that a file is pinned from the start of the
run rather than from the moment its phase reaches it; it SHALL NOT be presented as the guarantee.

The case that establishes this SHALL be a **real added phase** reading a class no declared table
names, which must be covered with no edit to any list and no edit to the case itself.

The fingerprint SHALL cover tracked files **and untracked files the ignore rules do not exclude**, and
SHALL be taken over file **content** rather than over names or sizes alone. It SHALL continue to
exclude ignored paths, because the checks and tools legitimately write inside the tree they run in and
a fingerprint over their artifacts converges on a gate that refuses every run.

The fingerprint SHALL additionally include **what is checked out, as the commit and the symbolic
reference standing at it**. A revision identifier alone does not identify a branch: two branches at
one commit return the same value, so a same-commit branch switch changes what is being gated while
every file and every hash holds still. A detached `HEAD` SHALL remain a stable state rather than
becoming a refusal on every run.

On any difference the gate SHALL **REFUSE**, naming what moved, and SHALL NOT pass and SHALL NOT
silently re-run.

The residual SHALL be stated as what it is: a file the run **never read** can still change unseen, as
can a file that changes and changes back inside the window. A case SHALL pin that residual as a gap
rather than as a control, and SHALL be read together with the added-phase case above, so that the
boundary — what was read is covered, what was not is not — is held from both sides. **A phase that
obtained a file without going through the recording accessors is outside the ledger and is detected by
nothing**; that SHALL be stated in the gate's own limits.

#### Scenario: A phase reading a class no declared table names is added

- **WHEN** a new verdict phase reads a file class that no statically declared input table names
- **THEN** the files it read are covered by the closing fingerprint
- **AND** a mid-run change to one of them is refused, with no edit to any list or to the case

#### Scenario: A file the run never read changes mid-run

- **WHEN** a file that no phase of the gate reads is changed while the gate runs
- **THEN** the gate still passes, and that residual is pinned by a case as a known gap
