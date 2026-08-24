## Why

The repository has no CI, no single test entry point, and until yesterday no version tags. Verified
first-hand on `main` at `cf375b2`: no `.github/workflows`, no `Makefile`, no `justfile`, seventeen
suites under `tests/` and three validators under `scripts/`, every one of them run by hand and
chosen from memory. This is audit finding **F-06**.

The cause matters more than the missing file. **Verification has been performed by the same actor
that authored the change, and it has failed twice in one week**: a Reader scope bypass passed a green
suite and a leakage scan and was recommended for publication, and a version published citing a
design document that was not in the repository after a drafting agent flagged exactly that. A third
failure was found during the remediation itself: three published versions told readers their binding
sections carried no obligation, because the publish ritual never cleared draft markings from section
bodies. One command cannot fix an actor problem. It can stop the part of it that is mechanical, and
it can require a declaration for the part that is not.

## What Changes

- `tools/km-release-gate.py` is added: one command that runs the whole gate and returns one verdict
  with a stated coverage line. It runs every suite and every validator it discovers, a shell syntax
  check over tracked shell files, a JSON and JSON-LD parse check, a Python syntax check, and a
  relative-link check over tracked markdown.
- What runs is **discovered**, never listed: every tracked `*.sh` and `*.py` in any `tests/` or
  `scripts/` directory, at the root or nested, is a check, so a suite added tomorrow is picked up
  with no edit to the runner. Scoping beyond the root found a live suite under
  `agents/km-hub-builder/` that no release had ever run.
- Nothing discovered is dropped silently. A check that cannot self-run because it takes required
  arguments declares `km-gate-instrument: <canaries> | <reason>`, is reported as skipped with its
  reason, and is refused unless the canaries it names run in the same pass.
- The gate fails closed. An unreadable or undecodable file, a discovered check that cannot be
  executed, an empty discovery set, or a discovery directory that yields nothing is a refusal, and a
  refusal is not a pass.
- `.github/workflows/release-gate.yml` runs the command on push and pull request, on a pinned runner
  image with a pinned action, with the expected duration stated.
- **The declaration.** Every discovered check carries `km-unrepaired-tree: <version|none|unrecorded>
  | <result>`, recording what happened when it was run against the tree it was written to catch. A
  missing or empty declaration fails the gate. A check this change **adds** may not plead
  `unrecorded`; a check this change **changes** must have its declaration line among the lines the
  change added. Twenty-three existing checks are retrofitted with the declaration their own headers
  already evidence, and the nine with nothing recorded say `unrecorded` with a reason rather than
  inventing a run.
- **The limits of the gate are stated in the standard**, in the runner's header and in the workflow,
  rather than left for a green line to imply away: CI cannot run the organisation leakage scan, and
  no script can supply a second actor. A third was found by running the gate against a deliberately
  broken tree and is stated with them: the gate reads a check's exit status and cannot see inside a
  check that swallows its own failure.
- `tests/test_release_gate.sh` proves the gate in both directions across forty-four assertions, and the gate
  is run against deliberately broken trees, which is the obligation it is about to impose on
  everyone else.
- The publish ritual in `STANDARD.md` gains the gate as a required step beside the draft-marking
  clearing v1.42 added, and `agents/km-hub-builder/SKILL.md` is amended to match.
- Not **BREAKING**. No shipped skill, template, scan, component or contract behaviour changes, so no
  hub inherits anything it must act on.

## Capabilities

### New Capabilities

- `release-verification`: what one release gate must run and how it decides what to run, when it
  must refuse rather than return a verdict, what a passing run must state, what a version must
  declare about running a new check against the unrepaired tree, and which things the gate cannot do
  and must therefore say out loud.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: `tools/km-release-gate.py`, the runner; `tests/test_release_gate.sh`, its
  canaries; `.github/workflows/release-gate.yml`, the CI job; the twenty-three existing checks under
  `tests/`, `scripts/` and `agents/km-hub-builder/`, each gaining one or two declaration comment
  lines and no change to what it tests; the Standard Maintainer section and the publish ritual of `STANDARD.md`; the version
  ledger; and `agents/km-hub-builder/SKILL.md`.
- **Affected deployments**: none. The gate governs this repository's own release, not a hub's, so no
  deployment has an adoption act to perform.
- **Not in scope**: branch protection, required status checks, signed tags and review records on the
  hosting platform. Those are settings on a service rather than material in a repository, they are
  the owner's to set, and a change that claimed them would be claiming a control it cannot ship.
- **Not in scope**: running the organisation leakage scan in CI. See the stated limit; this is a
  property of where the denylist lives by design and is not a defect awaiting a fix.
- **Not in scope**: supplying the second actor. The gate requires the declaration and cannot verify
  the adversarial pass behind it.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
