# Tasks: audit-reviewer-fourth-pass (v1.60 draft)

Branch `v1.60-input-derivation-and-tab-indentation`, off `main` at `73f89e8` (published v1.59).
**Nothing here binds until this version's own owner push.**

## 1. Verify each finding before implementing it

- [x] 1.1 **Both reviewer scripts verified by digest and run unmodified** on detached clones at
      `73f89e8`. `reproduce-phase-derivation-false-pass.sh` (`2610ce37…`): `suite_exit=0`,
      `REPRODUCED`. `reproduce-tab-indentation-false-pass.sh` (`526b32d2…`): `checker_exit=0`,
      `ruby_yaml_exit=1`, `REPRODUCED`. Reference environment identical on both sides.
- [x] 1.2 **Finding 1 confirmed by reading.** Case 21j's mechanism is
      `grep -nE 'git_(tracked|untracked)\(root, \[' "$GATE"`, which no tuple call form matches.
- [x] 1.3 **Finding 2 confirmed by reading and by probing.** The reader captured indentation with
      `[[:space:]]*`; eleven boundary shapes were probed one at a time against Psych 3.1.0 and the
      answers recorded, including the three the parser **accepts**.

## 2. Commit the canaries red

- [x] 2.1 Rewrite 21j from a grep into a behavioural pair carrying the reviewer's own phase; RED,
      `expected exit 2, got 0`. 21j2 passed legitimately as a boundary pin.
- [x] 2.2 Add nine frontmatter cases; **six red**. Two clean canaries passed legitimately. The
      tab-indented comment passed **for the wrong reason** (folded into `name`, tripping the slug
      rule), recorded rather than counted as detection.
- [x] 2.3 Re-state both `km-unrepaired-tree:` declarations before the repair was in the tree.
- [x] 2.4 Commit red: `1294b5d`.

## 3. Repair

- [x] 3.1 `Reads` ledger; `git_tracked`, `git_untracked` and `read_text` record; `_git_ls` is the
      raw non-recording enumerator the fingerprint uses.
- [x] 3.2 The closing fingerprint takes `extra_specs` and `extra_rels` from the ledger; the before
      side is the opening baseline extended by earliest observation, baseline winning on overlap.
- [x] 3.3 Limit 5 re-drawn to *what this run never read*, with the accessor-bypass residual and the
      refused audit-hook alternative stated in it.
- [x] 3.4 Indentation region derived once; a tab in it is a rejection naming the tab; the
      continuation arm takes the value that derivation produced.
- [x] 3.5 Live-shell probe for the tab matcher, refusing rather than returning a verdict, with two
      canaries proving it separates the inert form from the live one.

## 4. Sweeps

- [x] 4.1 *A control enforces a spelling where it claims to enforce a property*: **three** further
      instances (20c, 15b, 15c), registered with their error directions. Case 20 examined and left
      alone; 15a and 20d are prose-about-prose and not this class.
- [x] 4.2 *A character-class assumption imported from shell into a format that forbids it*: **one**
      further instance, in the same reader, repaired here. Every other `[[:space:]]` in the
      repository checked against Psych and found to sit in separation-space position.

## 5. Verify

- [x] 5.1 Unrepaired-vs-repaired recorded for every changed check.
- [x] 5.2 Positive direction: space-indented continuations accepted; the v1.59 sequence control
      holds; a stable-tree gate run PASSes twice with the same verdict.
- [x] 5.3 The two earlier reviewer fixtures (`37426e96…`, `cf6fcbc3…`) re-run; both still fire.
- [x] 5.4 Full release gate as one command, exit 0, `0 discovered check(s) untracked`.
- [x] 5.5 `openspec validate audit-reviewer-fourth-pass --strict`.
- [x] 5.6 `git diff --check`; leakage denylist over every added line.
