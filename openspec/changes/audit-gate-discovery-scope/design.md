# Design: the release gate discovers the tree it is being asked to judge

## Context

The gate's own header states its discovery doctrine:

> Every tracked `*.sh` and `*.py` file in any directory named `tests/` or `scripts/`, at the root or
> nested anywhere in the tree, is a discovered check.

The word doing the damage is `tracked`. It was chosen for a good reason and the reason is still good:
`git ls-files` gives a stable, ignore-aware, repository-relative listing, and it is what every other
phase of the gate uses. The mistake is that the gate's purpose and its listing disagree about which
tree is under judgement. The gate is run to decide whether the working tree may be committed and
published. `git ls-files` describes the index. Between those two trees sits exactly one file class,
and it is the class the maintainer just wrote.

The interaction with the contract is what turns a narrow mismatch into a blind spot with a schedule.
`agents/km-hub-builder/SKILL.md` orders the gate before staging. So the gate is guaranteed to run at
the one moment a newly authored check is invisible to it. This is not an unlucky ordering; it is the
documented one.

## Goals

1. An untracked check-shaped file under a discovery root MUST NOT be able to produce a passing
   verdict.
2. The maintainer MUST be able to get a real verdict on a check they just wrote, at the moment the
   contract says to run the gate, without staging it first.
3. Ordinary editing MUST NOT be reddened. A dirty working tree is the normal state of work.
4. Whatever the gate looked at MUST be visible in the coverage line, including where it came from.

## Options considered

### Option 1: reject untracked check-shaped files

The reviewer's first named shape. Discovery keeps listing tracked files; a separate pass lists
untracked check-shaped files under the discovery roots and fails the gate, naming them.

It closes goal 1 and goal 3 cleanly, and it is the smallest diff. It fails goal 2, and the way it
fails it is the reason it was rejected. The gate would refuse to give a verdict precisely when the
maintainer has done the thing the standard most wants done, which is write a new check. The only way
forward is to stage the file and run again. That is the v1.48 workaround promoted from a note in a
report to a rule in an instrument. It also spends a fail on a file it has decided not to look at,
which reads as "I can see something and I will not evaluate it" - a strange thing for an instrument
whose whole doctrine is that nothing discovered is silently dropped.

### Option 2: require a clean or fully staged tree

The reviewer's second named shape. The gate verifies the tree is clean or fully staged before
returning any verdict.

It closes goal 1 by construction and it is the strongest guarantee available: the thing gated is
exactly the thing that would be committed. It fails goal 3 outright. Every unrelated edit in progress
would refuse the gate, so the gate becomes a thing run once at the end rather than a thing run while
working, and an instrument that is expensive to run is an instrument that is run less. It also fails
goal 2 in a second-order way: it forces the contract to be rewritten from "gate then stage" to "stage
then gate" for every change rather than for the check case, which is a large change to the published
ritual in exchange for a defect that lives in one file class. And a gate that demands a clean tree
cannot be run before the commit it is meant to authorise without staging everything first, which
makes the pre-commit review step in the same contract land after the gate rather than before it.

### Option 3, chosen: discover the union, run both, report which is which

Discovery becomes tracked ∪ (untracked and not ignored), under the same roots and the same suffixes.
Both are read, held to the declaration rules, syntax-checked and executed. The coverage line states
how many of the discovered checks were untracked and each one is named on the run.

It closes goal 1: the measured probe is discovered, its syntax error is named, and the gate fails.
It closes goal 2: the maintainer gets a genuine verdict on a check written moments ago, with no
staging, at the point the contract already specifies. It closes goal 3, because the union is scoped
to check-shaped files under `tests/` and `scripts/` and touches nothing else. It closes goal 4 by
adding the provenance to the line that already exists for that purpose.

## The trade this accepts, stated plainly

**The gate's verdict is now about the working tree rather than about the committed tree.** That is a
real cost and it should be named rather than presented as a free win.

Concretely, a scratch file a maintainer drops at `tests/test_scratch.sh` while debugging will be
discovered, will be required to carry an unrepaired-tree declaration naming the drafted version, and
will be executed. The gate will fail on it. Someone will find that annoying, and they will be right
to, and the answer is that a file named like a check, shaped like a check and sitting where checks
live is a check until it is deleted or moved. The repository has no other convention for what a check
is; the two directory names *are* the scope declaration, and the gate's header already says so.

The argument for accepting the cost is that the alternative failure is worse and asymmetric. Being
made to explain a scratch file costs one minute. A green gate over a check nobody ran costs a
publication, and it has already cost one: the gate ran, printed a number, and the number was wrong by
exactly the file that mattered.

Two smaller trades come with it:

- **The gate can now execute code that is not in the repository.** Anything sitting untracked in a
  discovery root gets run. This is not a new exposure in practice, because the untracked file is one
  the maintainer put there in a tree they already control and are about to commit from, and the gate
  already executes 33 tracked scripts on the same host. But it is a real widening of what `python3
  tools/km-release-gate.py` will run, and a fork should know it before pulling this version.
- **`--no-suites` does not avoid it.** Static-only runs still discover and syntax-check the untracked
  files. That is deliberate: the static phases are the ones that catch an unparseable check, and they
  are the cheap half.

## Residual gaps, asserted as gaps

1. **Ignored paths remain invisible.** `git ls-files --others --exclude-standard` honours
   `.gitignore`, so a check-shaped file under an ignored path is not discovered. This is the correct
   line and it is drawn on purpose: an ignored file is not a file the repository ships, and a gate
   that ran the contents of a vendored dependency's `tests/` directory would be unusable. It does mean
   that adding a path to `.gitignore` removes it from the gate, silently, which is a way to delete a
   check by editing a different file. Nothing here closes that, and it is written down instead.
2. **The JSON and relative-link phases stay tracked-only.** Widening those to the working tree would
   redden the gate on any half-written markdown file, which is goal 3. So an untracked JSON file that
   does not parse is still not seen. The union is scoped to the class the finding is about.
3. **The three limits the gate already states are unchanged.** No leakage scan, no second actor, and
   no visibility inside a check that swallows its own failure. This change makes the gate see a check
   it was blind to; it does not make the gate see inside any check.
4. **Proving both directions proves the gate fires on this class, never that the class is the right
   one.** The same limit the standard already records for every check it ships applies to case 19.

## Implementation notes

- `git_untracked(root, patterns)` mirrors `git_tracked` exactly, adding `--others
  --exclude-standard`, with the same NUL separation so a filename carrying a space survives, and the
  same refusal on a non-zero exit, because an unlistable tree is not an empty one.
- `Check` gains a `tracked` boolean. It is carried, not inferred later, because the currency phase and
  the report both need it and recomputing it twice is how two rules that agree today stop agreeing.
- In `check_declarations`, the set returned by `changed_against` is unioned with the untracked
  discovered rels before the ADDED/CHANGED split. `exists_at` already answers `False` for a path with
  no blob at the base, so an untracked check lands in the ADDED arm with no further branching.
- The refusal messages in `discover` drop the word `tracked`, because they would otherwise describe a
  scope the function no longer has. The corresponding needle in `tests/test_release_gate.sh` case 5b
  moves with them, in the same change, which is the whole-surface rule.
- The coverage line gains its provenance clause at the **end** rather than inside the existing
  discovered clause, so that the assertions cases 1b and 9b already make about that line keep holding.
  A repair that silently rewrote the string every canary greps for would be changing what the suite
  measures while claiming to add to it.
