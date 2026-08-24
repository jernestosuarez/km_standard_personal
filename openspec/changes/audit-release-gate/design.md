# Design

## Context

Published `main` at `cf375b2` has no `.github/workflows`, no `Makefile`, no `justfile`, and no
repository-level runner. Seventeen suites live under `tests/`, three validators under `scripts/`, and
two more checks plus an installer under `agents/km-hub-builder/`. Every one of them is invoked by
hand. Version tags for v1.0 to v1.39 did not exist until the day before this change. That is audit
finding **F-06**, and the report is right about all of it.

It is also the least interesting part. The failures this repository actually recorded were not caused
by a check that did not run. They were caused by **the same actor authoring the change and verifying
it**, three times:

1. **A Reader scope bypass passed a green suite and a leakage scan and was recommended for
   publication.** `scope: *, hub-alpha` read as a closed scope because the gate tested the whole
   value. The suite that vouched for it proved an exact `*` and an exact `all` and never a list
   containing one. Everything ran. Everything passed. The isolation claim was gone.
2. **A version published citing a design document that was not in the repository**, after the
   drafting agent's own report flagged exactly that. The flag was read, acknowledged, and not acted
   on, and the dangling reference stood through five more versions.
3. **Three published versions told readers their binding sections carried no obligation.** The
   publish ritual as practised flipped the header, the ledger row, the README and the badge, and
   never cleared draft markings from section bodies or from the files those versions shipped.

Case 1 is a check that modelled the wrong shape. Case 2 is a human signal that changed nothing. Case
3 is a step that lived only in a maintainer's habits. A runner reaches the third directly, makes the
first cheaper to catch, and reaches the second not at all.

So this change has to do two things that pull against each other: build the runner, and refuse to let
the runner's green line stand for the part it cannot see. The second is why Part C is written into
the standard rather than filed as a limitation in a report nobody re-reads.

## Goals / Non-Goals

**Goals:**

- One command, one verdict, one coverage line, running everything the repository ships.
- Derive what to run by discovery, so a check added later is inside the gate with no edit anywhere.
- Fail closed on every input the gate could not evaluate, and never fold a refusal into a verdict.
- Run it in CI on push and pull request, pinned, with the expected duration stated.
- Convert the unrepaired-tree run from a habit into a machine-read declaration, and prove the
  declaration mechanism in both directions.
- State both limits in the standard, as properties of the arrangement rather than as work deferred.
- Run the gate against a deliberately broken tree, which is the obligation it imposes on others.

**Non-Goals:**

- Running the organisation leakage scan in CI. See Decision 6.
- Verifying that an adversarial pass happened. See Decision 5.
- Branch protection, required status checks, signed tags, review records. See Risks.
- A test framework, parallelism, or selective re-runs. See Decision 7.
- Changing what any existing check tests. See Decision 3.

## Decisions

### Decision 1: discovery by directory name, not a list, and not only at the root

The gate runs every tracked `*.sh` and `*.py` in any directory named `tests/` or `scripts/`, at the
root or nested. Two directory names are a scope declaration; the checks are never enumerated.

A list of check names beside a runner would be correct on the day it was written and a
hand-maintained memory of directory state afterwards. This repository has diagnosed that artifact
class three times already: a hub manifest missing a row for a governed file that the git-backed
integrity check could never catch, a declared-skill-set list refused by v1.32 in favour of comparing
the installed trees, and the RFC identifier set that v1.45 derived from the directory rather than
holding. The reasoning applies to a runner more sharply than to any of them, because the cost of a
missing entry here is that a check silently stops being part of the release.

**Nesting is deliberate and it found something.** Scoped to the root only, the gate would have run
twenty checks and reported a clean tree. `agents/km-hub-builder/` carries a live suite, a runtime
parity instrument and an installer, and nothing in this repository ever ran them as part of a
release. A gate that looked only where checks are usually kept would report a clean tree for the
place it never looked, which is the structural gap v1.30 names, met in a new place and created by
this change rather than merely inherited.

### Decision 2: nothing discovered is dropped, and a skip must name what covers it

Two discovered files cannot self-run: `tests/test_canonical_leakage.sh` takes a required denylist
pattern and exits 2 with a usage line when run bare, and `scripts/validate_organization_profile.py`
takes a required profile path. Nesting adds two more, the runtime parity instrument and the
installer. Three obvious handlings are all wrong: letting them fail the gate makes it permanently
red, letting exit 2 count as a pass makes the gate lie, and hardcoding their names reintroduces the
list Decision 1 refuses.

So a check declares itself: `km-gate-instrument: <canary-path> | <reason>`. The gate reports it as
skipped, prints the reason, and **refuses unless the named canary is itself a check that runs in the
same pass**. That pairing is the whole point. Without it, "instrument" is a way to delete a check
from the gate by writing one comment line, and the reason a maintainer would reach for it is
precisely that the check had started failing.

The reason is mandatory, refused when absent, and printed on the passing run. That is the same
convention `validate_published_not_draft.py` and `validate_rfc_references.py` already use for
self-exemption. One convention rather than three.

### Decision 3: retrofit the declaration onto the existing checks and change nothing they test

Every discovered check must carry `km-unrepaired-tree:`, so the gate cannot pass the current tree
until all of them do. The retrofit adds one comment line per file, two where the file is also an
instrument, and touches nothing else.

The declarations are taken from what each file's own header already evidences, not from a
reconstruction. Most have a real run to record: the leakage instrument's own repair from a
demonstrated false pass on a tree of eighty-nine matching lines, the publish guards' shimmed-grep
refusal cases, the reader scope cases that passed against the unrepaired scanner, the quarantine's
unquarantined-copy case, the parity check against `10d7950`, the published-not-draft check against
`40f3829` naming fifteen real markings, the reference check against `c3e4ffe` naming nine.

The rest predate the requirement with nothing recorded. They say `unrecorded` with a reason.
Inventing a plausible run for them would be the exact dishonesty this change exists to make harder,
and it would be undetectable, which is the argument for writing the debt down instead. The gate
counts them separately on the passing line so the number is visible and can go down.

### Decision 4: currency in two sub-rules, because adding and changing are different acts

The naive rule is "a check that differs from the base must declare the version being drafted". It is
wrong, and the retrofit proved it wrong within the hour: adding the declaration line changes every
check, so the naive rule would demand twenty fresh unrepaired-tree runs for twenty comment lines. It
is wrong in the ordinary case too, where a typo fix in a suite would demand a run against a tree that
no longer has a defect to find.

The rule is therefore split at the seam where the two acts genuinely differ.

**Added.** A check absent at the base names the version being drafted, or `none` with a reason, and
may not say `unrecorded`. This is fully enforceable and it is where the entire yield sits: a check
born in this change has no history to plead, and running it against the unrepaired tree is the only
thing that distinguishes it from a check that agrees with the repaired tree.

**Changed.** A check present at the base and differing from it must have its own declaration line
among the lines the change added. This forces a deliberate re-statement rather than a fresh run. It
is weaker on purpose, and its weakness is stated: a maintainer can re-state without re-running. What
it buys is that an edit cannot quietly outrun what the declaration claims, which is the failure mode
of any declaration written once and never looked at again.

Both need a base revision. When none resolves, both are a **coverage gap** on the passing line and
neither is folded into the verdict, per the rule v1.30 states for partial reads. The base is taken
from the environment first and falls back to the usual branch, because a first push to a new branch
reports an all-zero revision and a gate that reported a coverage gap on every branch's first push
would check currency almost never.

### Decision 5: require the declaration, and say plainly that it is not the second actor

The minimum viable independence is an adversarial pass by someone other than the change's author,
against the specific class being repaired. No runner verifies that. The temptation is to build
something that looks as though it does, and it must be refused, because a control that gives false
confidence is the failure this change exists to close rather than a narrower version of it.

What is checkable is the declaration. This is the move the standard already makes for exemptions: an
exemption with no stated reason is refused, not because the reason can be validated, but because a
maintainer who must write one has to have thought of one, and a later reader has something to hold
them to. The gate says so in its own passing output: a green result means the mechanical checks ran,
not that anyone other than the author looked.

The evidence for making this the mandatory step rather than advice is quantitative, and it is the
strongest finding of the remediation. Running a new check against the unrepaired tree has caught
something real **four** times in this sequence: the Reader scope bypass, the MCP quarantine, the
skill parity check, and the RFC reference check. It is the highest-yield step in the loop, and it is
the one most easily skipped, because by the time the check is written the defect is usually already
repaired in the working tree and running against the old state feels like ceremony.

### Decision 6: CI cannot run the organisation leakage scan, and that is stated, not deferred

The scan needs a denylist generated from a real organisation's own entity names. In a canonical,
publishable standard that denylist lives outside the repository **by design**, because carrying it
here would itself be the leakage the guard exists to prevent. This is not an oversight to be closed
by a secret, a submodule or a fetch step; every one of those puts the vocabulary somewhere the
canonical repository can reach, which is the condition being avoided.

So the gate runs the instrument's canaries and proves the **instrument** works. It can never prove
that a given push is clean. The fail-closed pre-push hook on a deployment's own clone is the only
thing that scans an actual push, and it is local and untracked by necessity rather than by neglect.

Writing this into the standard as a limit, rather than into a backlog as a gap, is the actual
decision. The alternative is that a future maintainer reads a green badge on a canonical repository,
concludes leakage is covered, and stops running the local hook, which would turn a stated limit into
an unstated one.

### Decision 7: no test framework, no parallelism, no selective re-run

The gate is a few hundred lines of dependency-free Python 3 running subprocesses in order. It could
run suites in parallel and finish in a third of the time. It does not, for two reasons: interleaved
output from twenty subprocesses is materially harder to read at the moment it matters, which is when
something failed; and several suites build fixture repositories in temporary directories and run git
inside them, so parallel execution is a correctness question that would need its own proof. Ten
minutes of wall clock in CI is cheap. A gate whose failure output is hard to read is not.

It runs every phase rather than stopping at the first failure, so one broken thing does not hide the
rest, and it runs the cheap static phases before the ten minutes of suites so a syntax error is
reported in seconds. It also prints its own total and its three slowest checks, so the duration
stated in the workflow can be checked against the run rather than believed.

### Decision 8: declarations are read from the header block, and this was found by the gate

The gate's first full run against the real repository **refused**, because `tests/test_release_gate.sh`
writes instrument declarations into the fixtures it builds and a whole-file search read one of those
fixture lines as the canary file's own claim. Two repairs were available: exempt the one file, which
is what the existing self-exemption convention would suggest, or scope the search.

Scoping is correct and the exemption is not. The class is general: any canary for any of these
markers will contain the markers, and an exemption list would grow one entry per canary while a
whole-file search stays wrong for every file that has not been noticed yet. A declaration is header
material, every check in this repository already puts its header material at the top, and reading it
from the leading run of shebang, blank and comment lines makes a fixture line structurally incapable
of being mistaken for a declaration. Both directions are canaried: a body carrying the syntax passes,
and a body carrying the syntax with no header declaration still fails.

That the gate found this in itself, on its first real run, is the argument for the change in
miniature.

### Decision 9: a third limit, found by breaking the tree rather than by reasoning

The proof obligation was to run the gate against a deliberately broken tree. Doing it produced a
result no amount of design would have: a real suite was given a command that does not exist, and the
gate **passed**. The suite is not run under a fail-fast shell option, so it swallowed the 127 and
exited 0 on its own accounting, and the gate reported exactly what the check reported.

This is not repairable inside a runner. A gate reads a check's exit status; seeing inside the check
is what the canary rule already does, one instrument at a time. So the two rules are siblings rather
than substitutes: canaries prove a check still fires, a gate proves every check was run, and neither
covers the other.

It is therefore stated as a third limit beside the other two, and pinned by a case that asserts the
behaviour as an acknowledged gap. The alternative, leaving it unwritten, means a later maintainer
either rediscovers it in an incident or closes it accidentally and silently changes what a passing
gate means.

The refusal on exit 127 catches only the narrower case where the process itself ends on the missing
command, which the corrected break confirmed: made genuinely unexecutable, the same suite produced a
refusal.

### Decision 10: the gate holds itself to the rule it imposes

The runner carries its own `km-unrepaired-tree` declaration, located through `__file__` rather than
by name, and its canaries assert that both limits are stated in its header. A rule its author exempts
himself from is precisely the shape of the three failures in Context, and shipping one here would be
the fourth.

## Risks / Trade-offs

- **The gate checks that a declaration was made, never that it is true.** A maintainer can write a
  declaration for a run that did not happen, and nothing detects it. This is limit 2 restated at the
  level of the mechanism, and it is why the declaration is described as converting an unverifiable
  property into a checkable one rather than into a verified one.
- **A green gate will be read as more than it is.** Both limits are stated in three places, the
  runner's header, the standard, and the workflow, because a badge is read where the standard is not.
  The mitigation is prose, and prose is read by whoever reads it.
- **The `unrecorded` token is a hole with a fence around it.** Several checks use it today. Nothing
  stops another, except that an added check may not, and that the count is printed on every passing
  run.
- **Broadening discovery to nested directories will catch things nobody meant as checks.** The
  installer under the agent package is the first, and it is handled by declaring it an instrument
  covered by the package tests. A repository that later adds a `scripts/` directory of unrelated
  utilities will feel this. The alternative, scoping to the root, silently drops a real suite, and a
  false positive that must be declared is better than a false negative that is silent.
- **Pinning the runner image means it goes stale.** `ubuntu-24.04` will be superseded and eventually
  removed. That is a maintenance cost accepted so the gate's verdict changes when this repository
  changes and not when a hosted image does.
- **CI is not the whole control the audit asked for.** The finding also names branch protection,
  required status checks and signed tags. Those are settings on a hosting service, not material in a
  repository. They are the owner's to set, and a change that claimed them would be claiming a control
  it cannot ship. They are named in the proposal's Impact so the next session does not rediscover
  them.
- **The relative-link check skips fenced code blocks.** A genuine link inside a code fence is not
  checked. Fenced content is example text that often names paths which deliberately do not exist, and
  firing on it would make the check unusable in a repository whose documents are largely about file
  layouts. The choice is stated and canaried in both directions.
- **The gate reads a check's exit status and cannot see inside it.** See Decision 9. A check that
  fails internally and returns success passes the gate. This is stated, canaried as a gap, and not
  claimed as covered.
- **One refusal branch is reachable only through the environment.** The gate refuses when a
  discovered check exits with the status meaning its interpreter or a command it needed was absent.
  The canary produces that by calling a command that does not exist, which is the real shape, but a
  genuinely missing interpreter is not reproducible in a fixture and is not claimed as proved.
- **The gate is a repository-level control and no deployment inherits it.** A hub with unrun checks
  is reached by nothing here. That is out of scope rather than solved.

## Migration Plan

1. Branch off published `main` at `cf375b2`, preserving the pre-existing `.gitignore` modification by
   stashing and restoring it rather than discarding it.
2. Establish the ground truth first: run every suite by hand, record which self-run and which refuse,
   and record durations, so the runner is written against what the repository does rather than what
   it is assumed to do.
3. Write the runner. Prove the discovery, declaration and static phases against the real tree before
   any retrofit, where the declaration phase must fail on every existing check.
4. Retrofit the declarations from each file's own recorded evidence, `unrecorded` where there is
   none.
5. Write the canaries, one broken thing per case, with the repaired form of each required to pass.
6. Run the gate against deliberately broken versions of the real repository, not only fixtures.
7. Add the workflow, pinned by image and by action SHA, stating the expected duration and both
   limits.
8. Graft the rule into the Standard Maintainer section beside the instrument rules it is a sibling
   of, add step 5 to the publish ritual, amend the agent contract, write the v1.46 row, and flip the
   header and lead to v1.46 drafted-unpublished, preserving the published v1.45, v1.44 and v1.43
   descriptions word for word.
9. Verify: `openspec validate --strict`, the new canaries, the full gate, both existing validators,
   `git diff --check`.
10. Adoption: none. No shipped surface changes, so no hub has an act to perform.

## Open Questions

- Should the `unrecorded` count on the passing line become a ceiling that may only go down? It would
  turn the stated debt into a ratchet. The argument against is that a check legitimately added for a
  class never observed says `none`, not `unrecorded`, so the ceiling would measure a set that should
  already be closed, and a ratchet nobody can satisfy gets disabled.
- Should the gate refuse when an instrument's only cover is a canary that itself says `unrecorded`?
  That chain is honest and weak. Whether it is worth mechanising is not settled here.
- Should the two limits be emitted as machine-readable output, so a consuming surface can show them
  beside a badge? The shape is the same as the coverage line. Whether anything would consume it is
  the question that decides it.
- Should the standard require an annotated tag per published version, given that the absence of tags
  for v1.0 to v1.39 is part of the same finding? Tagging is an owner push act and sits on the far
  side of the boundary this role stops at.
