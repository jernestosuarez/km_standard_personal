## Why

Three findings from an external reviewer's **third** pass over this repository. Each was verified
here before it was implemented, each was reproduced as a failing case on this branch, off `main` at
`be6e4bf` (published v1.58), and all were **committed red** (`998b859`) before any repair was
written. Two of the three arrived as runnable reproduction scripts with stated SHA-256 digests; both
digests were verified, both scripts were run here unmodified, and both reproduced on the first
attempt. The reference environment is identical on both sides — macOS 26.5.2 arm64, bash 3.2.57, git
2.50.1, python 3.9.6, ruby 2.6.10p210 with Psych 3.1.0 and libyaml 0.2.1 — which is why they ran
without adaptation and why every parser measurement below is quoted with the parser named.

**Finding 1 [P1] — the gate's stability fingerprint covers its discovery candidates, not its inputs.**

`fingerprint()` hashed exactly the set discovery reads, `*.sh` and `*.py` under `tests/` and
`scripts/`, by the same pathspecs; its own docstring said so. The gate reads far more: measured on
`be6e4bf` it resolved **112 relative links across 172 markdown files**, parsed **5** JSON/JSON-LD
files, and syntax-checked **31** shell and **11** Python files. None of those were fingerprinted, so a
broken link, an unparseable JSON file or a syntax error introduced *after* its own phase had run
survived into the final working tree with a PASS over it. **v1.58's case 21e shipped asserting this as
a KNOWN GAP** and demonstrating it with `README.md`.

**The specification was the narrow part, not the implementation.** The brief that produced v1.58 said
the fingerprint must cover the same set discovery covers; the drafter built exactly that and
registered the residual honestly. The instruction was wrong: a gate's inputs are wider than its
discovery candidates. The record says so.

*Reproduced, four ways, on the unrepaired gate:* a tracked markdown file the link phase had already
resolved, edited mid-run → `PASS`, exit 0; the same for a tracked JSON file the parse phase had read,
for a shell file and for a Python file outside `tests/` and `scripts/` that the syntax phases had
read. A fifth reproduction is structural: four literal pathspec lists stood in the phases, which is
the mechanism by which the covered set could be narrower than the phases at all.

**Finding 2 [P2] — a same-commit branch switch is undetected, and the claim says otherwise.**

`git_head()` ran `git rev-parse HEAD` and nothing else. Two branches at one commit return the same
value. The `fingerprint()` docstring claimed *"HEAD rides with it so a branch change is caught even
when every file happens to match"*, which is **false as written**: it catches commit movement. Case
21d's own title promised a branch change while its fixture moved `HEAD` with an **empty commit**.

*Reproduced* with the reviewer's own script, unmodified, against a `be6e4bf` snapshot: mutator `git
branch km-other` then `git switch -q km-other`, commit unchanged before and after, result `exit=0`,
`branch=km-other`, `REPRODUCED`.

**Finding 3 [P2] — the frontmatter approximation accepts invalid YAML.**

The continuation arm was `[[:space:]]* | "- "*`. A **top-level** `- …` line was accepted as continuing
the preceding key. YAML requires a sequence to be more-indented than the key it belongs to; a block
mapping followed by a root sequence is structurally invalid.

*Reproduced* with the reviewer's own script, unmodified: a valid `name`, a conforming description and
one root-level `- top-level sequence content makes this YAML document invalid` gave `checker_exit=0`
against `ruby_yaml_exit=1` with `Psych::SyntaxError: did not find expected key while parsing a block
mapping at line 2 column 1`. **The arm predates v1.58 and the v1.58 repair carried it forward without
examining it**, which is the finding worth more than the instance.

## What Changes

- **`tools/km-release-gate.py` — the covered set is derived from the phases.** `INPUT_CLASSES` holds
  every pathspec any phase reads — checks, shell, python, json, markdown — and every phase takes its
  pathspecs from it; none names a literal. `fingerprint()` iterates that structure, tracked ∪
  untracked-not-ignored, content-hashed. v1.54's working-tree semantics are unchanged and ignored
  artifacts stay excluded, because the suites write inside the tree and a fingerprint over everything
  is a gate that refuses itself.
- **`tools/km-release-gate.py` — identity is a commit AND a ref.** `git_head()` becomes
  `git_identity()`, recording `rev-parse HEAD` and `symbolic-ref -q HEAD`. A detached `HEAD` reports a
  stable sentinel and refuses nothing. The drift report names the ref change separately from the
  commit change.
- **`tools/km-release-gate.py` — limit 5 restated.** The residual is narrower and is described as what
  it now is: what only a discovered check reads, and change-and-change-back, are outside.
- **`tests/test_release_gate.sh`.** Case **21e is inverted** from an assertion of the gap into a
  control over it; 21g/21g2/21g3 hold one input class each; **21h is the new gap pin**, a file in no
  input class; **21d is rewritten** to the reviewer's own same-commit branch switch with 21d2 keeping
  commit movement and **21d3 requiring a detached `HEAD` not to refuse**; **21j** requires every phase
  to take its pathspecs from `INPUT_CLASSES`.
- **`tests/test_skill_frontmatter.sh`.** A continuation is decided by comparing a line's indentation
  with the key it would continue; a sequence entry that is not more-indented than any key is named as
  continuing nothing. **No YAML library is taken as a dependency.** The reviewer's fixture is carried
  byte for byte, and a positive-direction case requires a sequence indented under its own key to keep
  passing. The reader now **names the plain-scalar subset it models** and states that a file it
  accepts is conforming to this standard's contract and is not certified as valid YAML. The passing
  line states the count and the roots actually read instead of claiming "every shipped skill file".
- **`STANDARD.md`.** Five normative additions, the draft lead, and the v1.59 ledger row.

**BREAKING** for nothing a hub asserts. The behavioural change a maintainer meets is that the gate now
refuses on a wider class of mid-run drift — a markdown or JSON edit, or a branch switch — and the
answer is to re-run on a settled tree, never to re-run until it passes.

## Impact

- Affected specs: `release-verification-scope`, `verification-instrument-integrity`,
  `compound-value-validation`
- Affected code: `tools/km-release-gate.py`, `tests/test_release_gate.sh`,
  `tests/test_skill_frontmatter.sh`, `STANDARD.md`
- **Registered, not repaired.** The scope sweep found `scripts/validate_published_not_draft.py`
  naming `rfcs/`, `outputs/` and `work/` in its *what is out of scope* prose while `SCAN_ROOTS`
  silently excludes `openspec/`, `.github/`, `assets/` and `leakage/` as well. That is a
  documentation gap in an instrument this change does not otherwise touch, and correcting it here
  would be a repair riding inside a repair to something else.
- **Registered, not widened.** `agents/km-hub-builder/SKILL.md` carries the two frontmatter fields and
  is outside the frontmatter check's scan. Its `description` is 42 words, so admitting it would redden
  the tree; whether an agent contract is bound by a residency budget written for runtime skill files
  is a policy decision, not a defect in how the check reads its input.
