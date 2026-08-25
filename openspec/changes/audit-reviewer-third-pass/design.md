# Design: audit-reviewer-third-pass (v1.59)

Branch `v1.59-fingerprint-scope-and-frontmatter`, off `main` at `be6e4bf` (published v1.58).

Three findings. Two decisions in them were genuinely open and are argued here rather than recorded as
conclusions, and one question about the process itself is answered at the end because it is the thing
this pass is really about.

## 1. Symbolic ref, or narrow the claim? Both were honest; one was chosen

The reviewer's ruling framed this better than the brief did: *"a same-commit branch switch is
acceptable if branch identity is explicitly outside the contract and the claim that branch changes are
caught is removed. It is not acceptable while the implementation and canary claim branch identity is
protected."* **The defect is the contradiction, not the coverage.** Two coherent worlds existed and
the tree was in neither: the docstring promised branch detection, case 21d's title promised branch
detection, and the implementation detected commit movement while the case's fixture exercised commit
movement. Three surfaces, two of them describing a capability that was not there and the third
quietly agreeing with the implementation.

**Recording the symbolic reference was chosen.** The argument is not that it is cheaper — both repairs
are small — but that the promise is the right one to keep. A branch is what the maintainer is about to
commit to. Switching branch mid-run changes what the verdict is *about* even when every byte holds
still, and a reader who is told "the gate noticed the branch change" has been told something they can
act on, where a reader told "branch identity is outside the contract" learns only that the instrument
declines a question they still have. The narrowing route was also the one with a hidden cost: it would
have had to name *what else* covers a branch switch, and nothing does.

**What the widening had to not break, and was proved not to break.** A detached `HEAD` is a real and
stable state — it is what a CI checkout frequently presents — and an identity that refused whenever it
could not resolve a branch would refuse every such run. `git symbolic-ref -q HEAD` fails there, so the
sentinel `<detached>` is recorded and compares equal to itself. Case 21d3 requires the ordinary
verdict on a detached tree, and it passed on the *unrepaired* tree too, which is exactly what a
boundary pin should do.

**The residual, stated.** Two different detached states at one commit are indistinguishable, and so is
a branch switched away and back inside the window. That is the change-and-change-back residual in
another costume, and it is stated with it rather than separately.

## 2. Deriving the covered set, rather than widening the list

Finding 1 could have been closed by adding four globs to `fingerprint()`. That repair would have been
correct today and would have re-created the exact mechanism that produced the defect: a set of
pathspecs maintained beside the phases that read them, agreeing by hand until the day a phase is added.
`check_patterns()` was itself the v1.58 attempt at this — factored out so there would be *one* copy of
the discovery list — and the factoring is what carried discovery's scope into a new consumer that
needed a different scope. **The fix for a hand-maintained set is not a second hand-maintained set.**

So `INPUT_CLASSES` is the single structure, every phase draws from it, and `fingerprint()` iterates
it. Case 21j asserts the mechanism rather than the outcome: no phase may name a pathspec literal. Four
behavioural cases prove four classes are covered *today*; 21j is what makes a fifth class covered
*tomorrow*, by the edit that adds it.

**Why not the whole tree, restated because the reviewer's ruling touches it.** They wrote: *"Either
fingerprint all inputs contributing to the verdict or narrow the verdict's stated scope accordingly."*
All inputs is what v1.59 does. It is not the whole tree, and the difference is deliberate: ignored
paths stay out because the suites and tools write inside the tree they run in, and a fingerprint over
their artifacts converges on a gate that refuses every run — the failure mode that gets a gate switched
off and takes the real checks with it. What remains outside is what a *discovered check* reads and the
gate does not: `.yml`, `.txt`, the licence, template assets. That is pinned by case 21h as a gap.

## 3. Tighten the reader, or bound the claim? Both, and they are not substitutes

The reviewer offered a third option on finding 3: *"if the project intentionally accepts a
dependency-free subset broader than YAML, the check should describe that subset rather than call the
result conforming YAML."* It is a real alternative and it was weighed.

It was rejected **as a substitute** and adopted **as an addition**, on one distinction that turns out
to be the general rule and is now written into the spec: reading *less* of a valid document than a
parser does is an approximation, and it is legitimate as long as it is named. **Accepting a document a
parser refuses is a false pass**, and no amount of describing the subset makes it one. A block mapping
followed by a root sequence is not a scalar-resolution nicety; it is a document Psych 3.1.0 rejects at
`line 2 column 1`, that no runtime can load, and that no legitimate skill file needs. Describing a
subset that includes it would be describing a subset in which the check certifies unloadable files.

So the reader is tightened *and* the claim is bounded. The subset is now named — `---` delimiters,
column-zero keys, plain scalars folded across more-indented continuations, whole-line comments, blanks
— and what is outside it is named too: flow collections, block scalars, anchors, aliases, tags,
multiple documents, quoted and complex keys, nested mappings, and the format's scalar resolution. The
passing line says the file conforms to *this standard's* contract as modelled, not that it is valid
YAML. The next reviewer is then testing the instrument against its stated contract rather than against
the whole of a format it never claimed.

**The dependency stays refused.** v1.51 exists because a shipped tool assumed its author's toolchain.
PyYAML is absent on this host; Psych is present here and is not guaranteed anywhere a deployment runs
this. Naming the subset is what makes declining the dependency honest — it is not a replacement for
it.

## 4. Is the gate's stability property specified tightly enough to be finished?

The brief asked whether each round is narrowing an under-specified claim. The reviewer supplied the
specification, so this is written against theirs rather than one invented here. Their acceptance
criterion, verbatim, in four parts:

1. **No reproducible P1 or P2 false pass/failure within the gate or checker's declared contract.**
2. **Earlier repaired findings rerun successfully against the immutable candidate tag.**
3. **Full gate passing on that same tag.**
4. **P3 documentation issues either corrected or accurately bounded without contradicting executable
   behavior.**

**What v1.59 satisfies.** Bullet 1, for every class reachable from the contract as it now stands: the
two P2 reproductions are theirs, run unmodified, red before and refused/failed after; the P1 class is
covered by four behavioural cases plus the derivation case, and the boundary cases (detached `HEAD`,
stable tree twice, sequence indented under its key, commit movement) prove the repairs did not become
instruments that fire on everything. Bullet 4 is satisfied twice over: the branch-identity claim now
matches executable behaviour on all three surfaces, and the frontmatter claim is both corrected (the
scanned roots and count replace "every shipped skill file") and bounded (the subset is named). Bullet
3 is satisfied on this branch: the full gate passes at exit 0 with `0 discovered check(s) untracked`.

**What remains outside, and this is the honest part.** Bullet 2 and the *"immutable candidate tag"* in
bullets 2 and 3 are not things this change can satisfy: a tag is created at publication, by the owner,
and no drafting session can produce the artefact those bullets are about. They are satisfied by the
owner's publish step and by the reviewer's next pass, not here. Their third-pass evidence records that
no earlier repair had regressed on the v1.58 tag, which is the corresponding fact for the previous
round.

**So: is the property finished?** The *stability* property is now specified as tightly as a
before/after mechanism can be, and its boundary is a mechanism boundary rather than an oversight. The
full property is: *every input contributing to the verdict is identical at the start and at the end of
the pass, and what is checked out is the same thing at both ends.* v1.59 implements exactly that. Two
things sit outside it, both by construction and both stated: a change undone inside the window is
invisible to any pair of reads, and material read only by a discovered check is not an input to the
gate. **The reviewer has ruled the first acceptable when stated and has explicitly not required a
watcher or an immutable execution mechanism**, so it is stated and no watcher is built.

The remaining question — the one the next round should be about — is the second: whether "input to the
gate" is the right boundary, or whether the right boundary is "input to anything the gate runs". That
is a larger instrument (it would need each check to declare what it reads), it has a real cost, and it
is named here so the next pass is about the residual rather than rediscovering the shape.

**On the pattern of three passes each finding a defect in the last pass's repair.** Two of the three
findings this round trace to an instruction rather than to a drafter: v1.58's brief specified the
fingerprint as covering what discovery covers, and the drafter built and honestly registered exactly
that. That is not a repair cycle failing to converge; it is a specification being written one round at
a time. The counter-measure adopted here is the derivation, not more prose: `INPUT_CLASSES` and case
21j mean the next phase is covered without anyone specifying it. Where that move is unavailable — and
it is unavailable for change-and-change-back — the residual is stated with the reason it is not
closed, which is what the reviewer's criterion asks for.
