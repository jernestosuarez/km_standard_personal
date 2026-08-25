## Why

`tools/km-release-gate.py` discovers the checks it runs with `git_tracked()`, which lists **tracked**
paths only:

```python
def discover(root):
    ...
    rels = git_tracked(root, patterns)
```

`agents/km-hub-builder/SKILL.md` tells the maintainer to run that gate **before** staging: its
"Verify and commit" section orders the release gate ahead of the numbered pre-commit list whose third
item is "Stage explicit paths only." So a check authored in the change being gated is untracked at
exactly the moment the gate runs, and a gate that lists tracked paths cannot see it.

**Measured on the tree at `eb57f0f` (published v1.53).**

- Baseline, clean tree: the gate printed `33 check(s) discovered` and `PASS release-gate`, exit `0`.
- `tests/test_zz_probe.sh` was written into the working tree, untracked, containing
  `this is not valid shell ((((`, which `bash -n` rejects with a syntax error.
- The gate printed `PASS release-gate`, `33 check(s) discovered`, exit `0`.

The count did not move. The invalid check was neither run nor named, and the gate returned the
verdict a clean tree returns. A gate that cannot see a check cannot have run it, and this one said
PASS.

**The gap was known and left open.** On 2026-08-24 the v1.48 drafting agent hit this exact behaviour,
wrote *"a gate that has not seen a check has not run it, whatever its verdict says"*, worked around it
by staging the new check before running the gate, and reported it as a limitation rather than
repairing it. The suite `tests/test_release_gate.sh` encodes the same workaround: cases 7, 9, 10 and
17 all `git add` their fixture files before gating, so the suite never exercised the untracked path
and the gap was invisible to the gate's own canaries. An independent external reviewer reproduced it
on 2026-08-25 and named it a release blocker.

This is the absence-shaped pass the gate's own header says the repository has already been bitten by
three times, occurring inside the instrument written to end it. The gate's coverage line, which exists
so that "a recorded pass says what was looked at", states a number that omits the one file the
maintainer most needs looked at.

## What Changes

- **Discovery reads the working tree, not the index.** The discovered set becomes the union of
  tracked and untracked-but-not-ignored check-shaped files under the discovery roots. Both are run.
  The coverage line states how many of the discovered checks were untracked, and each untracked one is
  named on the run, so provenance is reported rather than erased.
- **An untracked discovered check is held to the ADDED currency rule.** It is absent at the base
  revision, so it must declare the version being drafted or `none` with a reason, and may not plead
  `unrecorded`. Until now an untracked new check escaped the declaration phase entirely, because
  `git diff --name-only <base>` never named it.
- **The shell and Python syntax phases scan the discovered checks as well as the tracked files**, so a
  check-shaped file that cannot parse is named as a syntax error before anything tries to execute it.
- **Ignored paths stay outside discovery**, and that is stated as the residual gap rather than left to
  be found.
- **The contract is amended.** `agents/km-hub-builder/SKILL.md` gains one sentence saying the gate
  reads the working tree, so running it before staging is correct and no longer requires staging a new
  check first to make it visible.
- **The suite gains the case permanently.** `tests/test_release_gate.sh` gains case 19, which builds a
  fixture whose only defect is an untracked invalid check and requires the gate to fail and name it,
  then requires the same tree to pass once the file is removed.

## Impact

- Affected specs: `release-verification-scope` (new capability).
- Affected code: `tools/km-release-gate.py`, `tests/test_release_gate.sh`.
- Affected contracts: `agents/km-hub-builder/SKILL.md`, `STANDARD.md` §"A gate runs before
  publication, and it declares what it cannot do".
- Affected deployments: any fork running the gate. The gate becomes stricter, never looser: a tree
  that passed before and holds no untracked check-shaped file passes unchanged.
- Not affected: the JSON parse phase and the relative-link phase remain tracked-only, deliberately, so
  ordinary editing of an unstaged markdown file does not redden the gate.
