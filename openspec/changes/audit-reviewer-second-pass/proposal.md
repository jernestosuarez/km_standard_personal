## Why

Three findings from an external reviewer's **second** pass over this repository. Each was confirmed
here before it was implemented, each was reproduced as a failing case on this branch, off `main` at
`510cf03` (published v1.57), and all were **committed red** (`fbf8002`) before any repair was written.

**Finding 1 [P1] — `tools/km-release-gate.py` can return PASS over a tree that changed while it ran.**

Discovery and the declaration checks run first, the suites run after, and **nothing establishes that
the tree at the verdict is the tree that was discovered.** The file was grepped for
`fingerprint|snapshot|tree_id|rev-parse HEAD|stable`: **zero hits.** No such machinery existed.

The reviewer observed it live: the gate began on clean `main`, the branch changed at 14:16,
`tests/test_restricted_lint.sh` was modified at ~14:18, and the gate returned PASS after ~900 seconds
still reporting zero changed declarations.

**Their timeline is exactly right, and the cause was this maintainer.** The reflog shows
`14:16 checkout: moving from main to v1.57-hub-scan-two-defects` and `14:29 commit: v1.57 (canaries)`:
our own v1.57 drafting agent was mutating the tree while their gate ran, and the reviewer could not
have known that. It does not weaken the finding — it is how the finding was discovered — and **the
defect is that the gate cannot tell, not that anyone misbehaved.** A gate whose PASS cannot name the
tree it judged certifies nothing, and a ~20-minute run is a wide window for a maintainer editing
alongside it.

*Reproduced, three ways, on the unrepaired gate:* a fixture whose discovered suite edits another
discovered check → `PASS release-gate`, exit 0; one whose suite creates a new check-shaped file →
`PASS`, exit 0, over a check never discovered, never held to the declaration rule and never executed;
one whose suite moves `HEAD` with no file content differing → `PASS`, exit 0.

**Finding 2 [P2] — `tests/test_skill_frontmatter.sh` retains a false pass.**

The continuation arm skips **every** indented line unconditionally — no state, no knowledge of which
key it continues, no check that any key precedes it — and the 10-40 word budget is then measured
against `sed -n 's/^description: *//p' | head -1`, the **first physical line alone**.

*Reproduced.* A fixture whose `description:` first line is **13 words**, followed by indented
continuation lines: the check measures 13 words (inside budget) and returns exit 0 with zero violation
lines, while Ruby's YAML parser on the same host folds the continuations and reads **97 words**. A
second fixture, an indented line placed before any key so that it continues nothing at all, is also
accepted.

**Finding 3 [P3] — "the limits, defined once" is overstated.**

The comment beside the gate's limit tuple ended *"Adding a fifth limit is an edit to this tuple and to
nothing else."* That is false: the header block enumerated all four limits in prose under numbered
headings, and `tests/test_release_gate.sh` case 15 hardcoded four `grep -Fq` assertions against those
header strings. A fifth limit was an edit to **three** places.

**Checked against v1.55's own tree (`aeec51a`) rather than taken on the reviewer's word:** the
sentence, the four numbered header entries and the four assertions all stood there together, so the
claim was **false on the day it was written** and is corrected under the v1.47 rule, not dated under
v1.56's. Two further symptoms of the same separate maintenance were found here: the header pointed
twice at `GATE_LIMITS`, which nothing defined (the tuple is `LIMITS`), and it claimed the count *"is
not restated in prose anywhere"* while the tuple's comment 185 lines below said *"the same four
limits"*. The header's own entries had drifted into file order 1, 3, 2, 4.

## What Changes

- **`tools/km-release-gate.py` — tree stability.** `fingerprint()` hashes the discovery set by
  content — the same pathspecs, tracked and untracked alike, factored into `check_patterns()` so no
  second copy exists — with `HEAD` alongside. Taken before discovery, compared before either verdict
  branch, and any difference is a **REFUSAL (exit 2)** naming what moved. **Deliberately not a
  snapshot:** the gate has read the working tree since v1.54 so a check authored in the change being
  gated is visible, and snapshotting tracked content would silently undo that and reopen the defect
  v1.54 closed.
- **`tools/km-release-gate.py` — one definition.** Each limit becomes a `Limit(statement, summary,
  argument)` carrying its own argument beside the words every surface prints; the header's numbered
  prose block is deleted and replaced by a pointer; `GATE_LIMITS` is corrected to `LIMITS`; no prose
  count of the limits remains anywhere. **A fifth limit is added, and adding it was an edit to
  `LIMITS` and to nothing else** — which is the proof, and it also made true, with no edit, the
  identical claim `.github/workflows/release-gate.yml` had carried since v1.55.
- **`tests/test_skill_frontmatter.sh`.** The block is walked with state: a continuation is folded
  into the key it continues; an indented line no key precedes is a violation; `name` and
  `description` are judged on their folded values. **No YAML library is taken as a dependency** —
  PyYAML is absent on the authoring host, Ruby's is present, neither is guaranteed in a deployment's
  environment, and v1.51 already published about a tool that assumed its author's toolchain. The
  inert `"\t"*` pattern (a literal backslash-t inside double quotes, matching no tab-indented line
  ever) is corrected to `[[:space:]]*`.
- **`tests/test_release_gate.sh`.** Case 15's four hardcoded assertions are replaced by three
  **derived** ones naming no limit (15a no prose count, 15b no second enumeration, 15c every named
  constant defined); 15d/15e prove that anchoring did not narrow them into silence; cases 21a-21d
  detect the drift classes and 21e/21f pin the residual and the stable-tree verdict.
- **`tests/test_km_publish_portability.sh` and `tools/km-publish.sh`.** Sweep result, repaired: the
  renderer's bare version derives from the pin instead of being typed a second time; case 7c counts
  the version literals and requires the derivation to hold.
- **`template/hub-scan.sh`, `components/km-cockpit/km-cockpit.py`.** Sweep result, **registered and
  not repaired**: both read `routing-keywords` as a first physical line. Comment only; no behaviour
  changes.
- **`STANDARD.md`.** Three normative additions, the draft lead, and the v1.58 ledger row.

**BREAKING** for nothing a hub asserts. The behavioural change a maintainer meets is stated rather
than absorbed: the gate now refuses occasionally, when the tree moves under a long run, and the
answer is to re-run on a settled tree — never to re-run until it passes.

## Impact

- Affected specs: `release-verification-scope`, `verification-instrument-integrity`,
  `compound-value-validation`
- Affected code: `tools/km-release-gate.py`, `tools/km-publish.sh`,
  `tests/test_release_gate.sh`, `tests/test_skill_frontmatter.sh`,
  `tests/test_km_publish_portability.sh`, `template/hub-scan.sh`,
  `components/km-cockpit/km-cockpit.py`, `STANDARD.md`
- **Not in scope, deliberately.** The folded-value class was found again in the two shipped readers
  of `routing-keywords` and is registered rather than repaired: `fm_field()` serves every field the
  session-start scan reads and is inherited by every hub, so it needs its own canaries and its own
  unrepaired-tree runs rather than a change riding inside a repair to a different instrument.
