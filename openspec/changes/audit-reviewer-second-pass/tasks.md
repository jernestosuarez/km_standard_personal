# Tasks: audit-reviewer-second-pass (v1.58)

Branch `v1.58-gate-stability-and-frontmatter`, off `main` at `510cf03` (published v1.57).

## 1. Verify each finding before implementing it

- [x] 1.1 **Finding 1's grep reproduced.** `tools/km-release-gate.py` grepped for
      `fingerprint|snapshot|tree_id|rev-parse HEAD|stable`: zero hits, exit 1. No such machinery.
- [x] 1.2 **The reviewer's timeline checked against the reflog.** `14:16 checkout: moving from main
      to v1.57-hub-scan-two-defects` and `14:29 commit: v1.57 (canaries)`. The cause was this
      maintainer's own v1.57 drafting agent. Recorded in the version row plainly: the defect is that
      the gate cannot tell, not that anyone misbehaved.
- [x] 1.3 **Finding 2 reproduced with a fixture of this session's own making**, not the reviewer's:
      first line 13 words, folded value 97 by Ruby's YAML, `check_tree` exit 0, zero violations.
- [x] 1.4 **Finding 3 checked against v1.55's own tree (`aeec51a`)**, not taken on the reviewer's
      word: the sentence, the four numbered header entries and the four `grep -Fq` assertions all
      stood there together. False on the day written, so the v1.47 rule applies, not v1.56's.
- [x] 1.5 **Two further symptoms of finding 3's class found here**: the header named `GATE_LIMITS`,
      which nothing defined, and claimed the count "is not restated in prose anywhere" while the
      tuple's comment 185 lines below said "the same four limits".
- [x] 1.6 **One detail of finding 3 does not survive as stated, and is recorded.** No test would have
      failed on a fifth limit: case 15 asserted presence of four strings, not the set's size. The
      third place was coupled to the header's wording, not its count. `design.md` §7.

## 2. Reproduce all three as failing cases, committed red (`fbf8002`)

- [x] 2.1 `tests/test_skill_frontmatter.sh`: two violation canaries (folded value over budget;
      indented line continuing no key) — both "canary NOT caught" on the unrepaired tree.
- [x] 2.2 `tests/test_skill_frontmatter.sh`: one **positive-direction** case (a two-line description
      inside the budget) — passes on both trees by design, and is labelled as a pin, not a detector.
- [x] 2.3 `tests/test_release_gate.sh` 21a-21d: content drift, a check appearing, and `HEAD` moving —
      all red, three at "expected exit 2, got 0".
- [x] 2.4 `tests/test_release_gate.sh` 21e/21f: the residual and the stable-tree verdict — pass on
      both trees, recorded as boundary pins.
- [x] 2.5 `tests/test_release_gate.sh` 15a/15b/15c: three derived assertions replacing four hardcoded
      ones — all red on the unrepaired gate.
- [x] 2.6 **A fixture-reuse defect in the canaries themselves, found and fixed:** 21a and 21b shared
      a fixture, and a mutator leaves its mutation behind, so the second run was answered for a
      different reason (exit 1, not 2). Each assertion now gets its own fixture.

## 3. Finding 1 — tree stability, fail-closed

- [x] 3.1 `check_patterns()` factored out, so the fingerprint covers exactly what discovery covers
      and no second copy of the pathspec list exists.
- [x] 3.2 `fingerprint()` content-hashes that set, tracked and untracked alike, and carries `HEAD`.
- [x] 3.3 `git_head()` returns a stable sentinel on an unborn branch rather than refusing: an unborn
      branch is a real state, and comparability is what matters.
- [x] 3.4 Taken **before** discovery; compared **before either verdict branch**, so a FAIL over a
      tree nobody has is refused as readily as a PASS.
- [x] 3.5 `fingerprint_drift()` names what moved: appeared, disappeared, changed content, `HEAD`.
- [x] 3.6 **Not a snapshot**, and the reason is written into the function's own docstring so the next
      maintainer meets the trap rather than rediscovering it. `design.md` §1.
- [x] 3.7 Residual stated in the check's own words **and** as limit 5, and pinned by case 21e as a
      gap rather than a control.
- [x] 3.8 The refusal documented in the exit-status block at the top of the file.

## 4. Finding 3 — one definition, and the fifth limit as its proof

- [x] 4.1 `Limit(statement, summary, argument)` namedtuple; each limit carries its own argument.
- [x] 4.2 The header's numbered prose block deleted, replaced by a four-line pointer.
- [x] 4.3 `GATE_LIMITS` corrected to `LIMITS` in both places that named it.
- [x] 4.4 No prose count of the limits remains; every count is `len(LIMITS)`.
- [x] 4.5 **The fifth limit added — an edit to `LIMITS` and to nothing else.** The proof is the act.
- [x] 4.6 Verified: this also made true, with no edit, the identical claim
      `.github/workflows/release-gate.yml` had carried since v1.55.
- [x] 4.7 Case 20's count marker updated to the definition's new opening (`^    Limit($`).
- [x] 4.8 **15a/15c anchored** after they reported this change's own repair as the defect: quoted
      spans and the dated `km-unrepaired-tree` line are blanked, in place, so line numbers stay true.
- [x] 4.9 **15d/15e added**, running both anchored greps against a copy of the gate carrying the
      v1.55 wording as a live claim, and requiring both to fire — because a rule narrowed until the
      tree goes green is indistinguishable from one that has stopped matching.

## 5. Finding 2 — the logical value

- [x] 5.1 The block walked with state: a continuation folds into the key it continues.
- [x] 5.2 An indented line no key precedes is a **violation**, not a skip.
- [x] 5.3 `name` and `description` judged on their folded values; duplicate counting derived from
      the parsed key openings rather than from a whole-file grep.
- [x] 5.4 **No parser dependency taken.** PyYAML absent on this host, Ruby's present, neither
      guaranteed in a deployment's environment. Ruby was used to establish ground truth for the
      reproduction only, and ships in nothing. `design.md` §5.
- [x] 5.5 The inert `"\t"*` pattern (a literal backslash-t) corrected to `[[:space:]]*` — v1.29's
      rule met in this repository's own suite. Probed before asserting.
- [x] 5.6 **Runtime measured, and the implementation changed because of it:** `printf | sed` per
      line ran 196s against the original's 82s, back to back on the same cold tree. Rewritten with
      `[[ =~ ]]` and `BASH_REMATCH` it spawns no subprocess per line. **Measured warm, which is the
      only comparable pair: 1.6s repaired against 1.5s original.** The cost is a tenth of a second,
      and it is stated that way rather than as the speed-up the cold figures would have implied.
- [x] 5.7 Coverage stated in the check: it models plain-scalar folding, not the whole of YAML.

## 6. Sweeps — both run, both recorded, including what was excluded and why

- [x] 6.1 **Finding 2's class swept** across every shipped check, tool and surface.
- [x] 6.2 `.km-tier`'s `tier` and `scope:` examined and **excluded with reason**: the standard defines
      that marker as line-oriented, not YAML, so those values are single-valued by construction.
- [x] 6.3 Frontmatter openers (`head -1` against `---`) excluded: physical-line tests by definition.
- [x] 6.4 **Class found twice more, on `routing-keywords`** — `fm_field()` in `template/hub-scan.sh`
      and the cockpit's reader. Reproduced: five declared, YAML reads five, `fm_field` reads
      `alpha, beta,`, cockpit reads two. The v1.44 per-token repair is handed a truncated value.
- [x] 6.5 **Registered, not repaired**, in both readers' source and in `STANDARD.md`, with the reason:
      `fm_field()` serves every field the scan reads and is inherited by every hub, so it needs its
      own canaries and unrepaired-tree runs rather than a change riding inside an unrelated repair.
- [x] 6.6 **Finding 3's class swept** across every single-definition claim in shipped code.
- [x] 6.7 `scripts/publication_status.py` verified genuinely single (both validators import it).
- [x] 6.8 `tests/test_readme_inventory.sh` and the cockpit's desk-id claim examined; neither is the
      class, and the reasoning is recorded rather than the conclusion alone.
- [x] 6.9 **One real instance found and repaired:** `tools/km-publish.sh`'s pin claimed one place and
      held two literals. Bare version now derives from the pin; case 7c added, red at "2 version
      literal(s)" on the unrepaired tool.

## 7. Declarations, gate, and draft markings

- [x] 7.1 `km-unrepaired-tree:` re-stated on every changed check: `tests/test_release_gate.sh`,
      `tests/test_skill_frontmatter.sh`, `tests/test_km_publish_portability.sh`, and the gate itself.
- [x] 7.2 Each declaration records what the check found on the **unrepaired** tree, written before the
      repair was in the working tree.
- [x] 7.3 **Release gate: PASS, exit 0**, 34 checks discovered, 29 run, no coverage gaps, and
      **`0 discovered check(s) untracked`**.
- [x] 7.4 The fingerprint held across the real ~20-minute run: no false refusal on a settled tree.
- [x] 7.5 **Draft markings written per section and in shipped files** — not a blanket lead sentence —
      in `STANDARD.md`'s three additions, in the gate's header and `LIMITS` comment, in the fifth
      limit's own argument text, in both frontmatter-check comment blocks, in `tools/km-publish.sh`'s
      pin comment, in the two registered-gap notes, and in each new test case's comment.
- [x] 7.6 `openspec validate audit-reviewer-second-pass --strict` passes.

## 8. Deliberately not done

- [x] 8.1 **No watcher process.** It would close the change-and-change-back residual and is a
      different instrument with a different failure mode. Named so a later maintainer does not read
      "tree stability is solved" off limit 5.
- [x] 8.2 **`fm_field()` not repaired here.** §6.5.
- [x] 8.3 **Nothing redeployed, no hub edited or dispatched.** The canonical change is the whole of it.
- [x] 8.4 **Not published.** Draft only: no merge, no tag, no push. Every addition is marked and
      binds nothing until the owner's push.
