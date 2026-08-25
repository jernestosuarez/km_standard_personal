## Why

Two findings from an external reviewer's **fourth** pass over this repository. Each was verified here
by reading the code rather than the report, each was reproduced as a failing case on this branch, off
`main` at `73f89e8` (published v1.59), and both were **committed red** (`1294b5d`) before either
repair was written. Both arrived as runnable reproduction scripts with stated SHA-256 digests; both
digests were verified (`2610ce37…`, `526b32d2…`), both scripts were run unmodified on detached clones
at the tag, and both reproduced on the first attempt. The reference environment is identical on both
sides — macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6, ruby 2.6.10p210 with Psych 3.1.0
and libyaml 0.2.1 — which is why they ran without adaptation and why every parser measurement below
is quoted with the parser named.

**Finding 1 [P2] — case 21j enforces a syntax, not the guarantee it certifies.**

Case 21j of `tests/test_release_gate.sh` is the control for *every verdict phase takes its pathspecs
from `INPUT_CLASSES`*, so that a phase reading a new file class cannot fall outside the stability
fingerprint. It enforced that by grepping `tools/km-release-gate.py` for the literal
`git_tracked(root, [` and requiring no match.

A phase written any other way walks straight past it. *Reproduced with the reviewer's own script,
unmodified:* a real `.txt`-reading verdict phase using `git_tracked(root, ("*.txt",))` — a **tuple**
instead of a list — produced `PASS: 21h. a file in no input class is NOT caught (KNOWN GAP)`,
`PASS: 21j. every phase takes its pathspecs from the structure the fingerprint iterates`,
`suite_exit=0`, `REPRODUCED`. Case 21j certified a guarantee that was false; case 21h then accepted
`notes.txt` mutating mid-run at a moment when `notes.txt` **was** a gate input, so the pin on what
lies outside the covered set was certifying the wrong thing as well.

**This is this repository's own published doctrine met in its own suite.** v1.29/v1.30 state that a
check proved in both directions fires on the class it models, never that it models the right class.
Case 21j was proved in both directions and still modelled a call's spelling.

**Finding 2 [P2] — `[[:space:]]` is read as indentation, and that class contains the tab.**

YAML forbids tabs in indentation. `tests/test_skill_frontmatter.sh` captured a line's indentation
with `[[:space:]]*`, so a tab-indented continuation was folded into the preceding key and the block
accepted. *Reproduced with the reviewer's own script, unmodified:* `PASS: 23 skill file(s) …`,
`ALL SKILL FRONTMATTER CHECKS PASSED`, `checker_exit=0` against `ruby_yaml_exit=1` with
`Psych::SyntaxError: found a tab character that violate indentation while scanning a plain scalar at
line 3 column 14`, `REPRODUCED`.

**This is inside the declared contract by v1.59's own words.** The paragraph v1.59 itself added
classifies accepting a parser-rejected document as a false pass. The version that drew the line is
the version that crossed it.

**And note how it got here, because it is the sharper lesson.** v1.58 found the original tab arm
written `"\t"*` inside double quotes — a literal backslash-t, **inert since the day it was written**
— and repaired it by switching to `[[:space:]]`, which made the arm live for the first time and
wrong in the same motion. Making a dead arm live without asking whether it *should* match is how an
inert arm became a false pass.

## What Changes

- **`tools/km-release-gate.py` — the covered set becomes a runtime fact.** A `Reads` ledger records
  every pathspec enumerated and every path opened; `git_tracked`, `git_untracked` and `read_text`
  register into it. The closing fingerprint re-enumerates those pathspecs and re-hashes those paths,
  so it covers **what the run actually read**. `INPUT_CLASSES` remains as the **opening baseline** —
  a file is pinned from t=0 rather than from the moment its phase reaches it — and is no longer the
  guarantee. A phase added later is covered by construction, with no list to keep in step and no
  source-text claim to check.
- **`tools/km-release-gate.py` — limit 5 re-drawn.** The residual is what **this run never read**,
  not what a table failed to name. What remains enforced by nothing at all — a phase bypassing all
  three accessors — is stated in the limit rather than in a commit message, together with the reason
  a process-wide audit hook was weighed and refused.
- **`tests/test_release_gate.sh` — case 21j stops being a grep.** It becomes a **real added phase**:
  the reviewer's own `check_text`, tuple pathspec and all, injected into a copy of the real gate with
  its anchors asserted, which must be covered with no edit to the case. **21j2** requires the same
  added phase over a stable tree to keep passing. **21h** keeps its gap on the *unmodified* gate, and
  the pair now states the boundary exactly.
- **`tests/test_skill_frontmatter.sh` — indentation is spaces.** A tab anywhere in a line's
  indentation region — its leading whitespace, plus the `-` indicator and the whitespace after it on
  a sequence entry — is a rejection naming the tab. Eleven boundary shapes were probed against Psych
  and recorded beside the rule, the accepted ones as well as the rejected. The reader is **stricter
  than libyaml in one named place** and says so. The continuation arm now takes the value the single
  indentation derivation already produced instead of re-deriving the region with its own
  `[[:space:]]` match. **The tab matcher is probed against the live shell before it is trusted**, and
  the suite REFUSES rather than returning a verdict if the matcher proves inert.
- **`STANDARD.md`.** Three normative additions, the draft header and lead, and the v1.60 ledger row.

**BREAKING** for nothing a hub asserts. The behavioural change a maintainer meets is that the
frontmatter check now rejects tab-indented frontmatter, including the space-then-tab form libyaml
accepts, and the answer is to indent with spaces.

## Impact

- Affected specs: `verification-instrument-integrity`, `release-verification-scope`,
  `compound-value-validation`
- Affected code: `tools/km-release-gate.py`, `tests/test_release_gate.sh`,
  `tests/test_skill_frontmatter.sh`, `STANDARD.md`
- **Registered, not repaired (spelling-for-property sweep).** Three further instances, each with its
  error direction stated: case **20c** certifies *the CI workflow obtains the limits from the gate
  rather than copying them* by confirming the string `km-release-gate.py --limits` appears, which a
  workflow could satisfy while also carrying a copy; case **15b** certifies *the header argues no
  numbered limit of its own* by matching `^# [0-9]+\. [A-Z]`; case **15c** certifies *every constant
  the header names is defined* by requiring `^NAME=`. Case **20**'s source-text count of `Limit(` was
  examined and left alone because any miscount produces a false failure, never a false pass.
  Repairing all four structurally is a change to four unrelated controls riding inside a repair to a
  fifth.
- **Registered, not repaired (frontmatter reader).** A *space*-indented `# comment` inside a block is
  a comment to Psych and is folded into the preceding value by this reader, which can move a
  description's word count in either direction. No shipped file does it, and modelling it correctly
  requires modelling what Psych does to a continuation that follows a comment.
