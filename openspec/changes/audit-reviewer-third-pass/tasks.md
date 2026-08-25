# Tasks: audit-reviewer-third-pass (v1.59)

Branch `v1.59-fingerprint-scope-and-frontmatter`, off `main` at `be6e4bf` (published v1.58).

## 1. Verify each finding before implementing it

- [x] 1.1 **Finding 1 confirmed by reading, not by report.** `fingerprint()` iterated
      `check_patterns()` alone and its docstring said so. Measured on `be6e4bf`: the gate's own
      passing line reports 112 links across 172 markdown files, 5 JSON/JSON-LD files, 31 shell and 11
      Python files, none of them fingerprinted.
- [x] 1.2 **Finding 2 confirmed directly.** `git rev-parse HEAD` on `main` and on a fresh branch at
      `be6e4bf` returned the identical value; `git symbolic-ref HEAD` distinguished them.
- [x] 1.3 **Finding 3 confirmed directly.** A block with a valid `name`, a valid description and two
      top-level `- item` lines: `check_tree` exit 0, Ruby `Psych` rejected at line 2 column 1.
- [x] 1.4 **Both reviewer reproduction scripts verified by digest and run unmodified** against a
      `be6e4bf` snapshot. `reproduce-same-commit-branch-switch.sh`
      (`37426e96…`): `exit=0`, `branch=km-other`, `REPRODUCED`.
      `reproduce-invalid-yaml-sequence.sh` (`cf6fcbc3…`): `checker_exit=0`, `ruby_yaml_exit=1`,
      `REPRODUCED`. Reference environment identical on both sides: macOS 26.5.2 arm64, bash 3.2.57,
      git 2.50.1, python 3.9.6, ruby 2.6.10p210 / Psych 3.1.0 / libyaml 0.2.1.
- [x] 1.5 **Nothing in the three findings failed verification.** All three stand as stated.

## 2. Reproduce all three as failing cases, committed red (`998b859`)

- [x] 2.1 `tests/test_release_gate.sh` 21d/21d1: the reviewer's same-commit branch switch. Red:
      `expected exit 2, got 0`.
- [x] 2.2 21e/21g/21g2/21g3: one input class each — markdown, JSON, shell outside the check dirs,
      Python outside the check dirs. All four red: `expected exit 2, got 0`. 21e is v1.58's own gap
      assertion inverted into a control.
- [x] 2.3 21j: no phase may name a pathspec literal. Red on four literals.
- [x] 2.4 `tests/test_skill_frontmatter.sh`: the reviewer's fixture byte for byte. Red:
      `canary NOT caught: sequence entry at the top level of a mapping block`.
- [x] 2.5 **Positive-direction cases, green on both trees by design and labelled as pins:** 21d2
      (commit movement still caught), 21d3 (a detached `HEAD` does not refuse), 21h (a file in no
      input class is not caught), 21f/21f2 (a stable tree passes twice with the same verdict), and a
      sequence indented under its own key still accepted.

## 3. Repair

- [x] 3.1 `INPUT_CLASSES` added; every phase draws its pathspecs from it; `fingerprint()` iterates it,
      tracked ∪ untracked-not-ignored, content-hashed, ignore rules honoured.
- [x] 3.2 `git_head()` → `git_identity()`: commit and symbolic reference. `<detached>` and `<unborn>`
      are stable sentinels, never refusals. Drift names the reference change separately.
- [x] 3.3 Limit 5 restated: the residual is what only a discovered check reads, plus
      change-and-change-back, plus two detached states at one commit.
- [x] 3.4 Frontmatter continuation decided by indentation against `cur_indent`; a sequence entry at
      the mapping's indentation is named as continuing nothing. **No YAML library taken as a
      dependency.**
- [x] 3.5 The frontmatter reader names the plain-scalar subset it models and what falls outside it;
      the passing line states the count and roots read and no longer claims "every shipped skill
      file".

## 4. Sweeps, both recorded

- [x] 4.1 **"A control's scope is narrower than the thing it certifies."** One instance found and
      claim-repaired: `tests/test_skill_frontmatter.sh` claimed every shipped skill file while
      reading three of four locations (`agents/km-hub-builder/SKILL.md` is the fourth; its
      `description` is 42 words, so the scope is registered, not widened). One instance found and
      registered: `scripts/validate_published_not_draft.py` names three exclusions in prose while
      `SCAN_ROOTS` excludes `openspec/`, `.github/`, `assets/` and `leakage/` as well.
- [x] 4.2 **"An inherited arm carried through a repair without being re-derived."** Every repair v1.58
      made was read. **One further instance, and it is finding 1 itself:** `check_patterns()` was
      factored out of discovery and handed to `fingerprint()` with discovery's scope carried over
      rather than re-derived. The other v1.58 repairs carried no untested arm: the publisher's pin
      replaced a literal with a derivation, the limits repair deleted a prose block, and the
      `routing-keywords` instances were registered rather than edited.

## 5. Declarations and verification

- [x] 5.1 `km-unrepaired-tree:` re-stated on all three changed checks, each recording the actual
      unrepaired run and citing the reviewer's script where the run used it.
- [x] 5.2 Both reviewer scripts re-run against the repaired tree: `REFUSED … the checked-out ref
      changed from refs/heads/main to refs/heads/km-other` at exit 2, and `checker_exit=1` naming
      `! SEQUENCE ENTRY IS NOT MORE-INDENTED THAN ANY KEY` on the reviewer's own line.
- [x] 5.3 Full release gate run as one command, exit 0, `0 discovered check(s) untracked`.
- [x] 5.4 `openspec validate audit-reviewer-third-pass --strict`.

## 6. Draft markings

- [x] 6.1 Every section this version adds is marked as v1.59 drafted and unpublished, in `STANDARD.md`
      and in each shipped file it touches. The publishing commit clears them.
