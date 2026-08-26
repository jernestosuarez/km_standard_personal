## Why

Four findings from an external reviewer's **fifth** pass over this repository, off `main` at
`164ecfb` (published v1.60). Each was verified here by reading the code rather than the report, and
each was reproduced as a failing case before any repair was written.

Three arrived as runnable reproduction scripts with stated SHA-256 digests. All three digests were
verified (`a242059f…`, `9415c372…`, `fa35fad9…`), all three were run here **unmodified against the
unrepaired tree**, and all three reproduced on the first attempt. The reference environment is
identical on both sides — macOS 26.5.2 arm64, bash 3.2.57, git 2.50.1, python 3.9.6, ruby 2.6.10p210
with Psych 3.1.0 and libyaml 0.2.1.

**All three scripts pin `164ecfb` internally, and this is stated first because it is the subject of
finding 4.** `reproduce-link-target-disappears.sh` reads the gate from the source root it is handed
but **refuses at exit 2 unless that root's `HEAD` is `164ecfb`**. `reproduce-indented-comment-
continuation.sh` and `reproduce-ci-limit-copy-false-pass.sh` **re-clone `164ecfb`** whatever source
root they are handed. None of the three can demonstrate a repair, and no claim in this change says
that any of them does.

**Finding 1 [P1] — link targets bypassed the read ledger.**

`check_links()` in `tools/km-release-gate.py` validated a target with `os.path.exists(str(candidate))`
and never recorded it in `READS`. *Reproduced with the reviewer's own script, unmodified:*
`PASS release-gate: … 2 relative link(s) resolved across 2 of 2 markdown file(s) …`, `gate_exit=0`,
over a final tree whose `notes.txt` — a target the link phase had resolved — had been deleted by a
discovered check after that phase ran.

**This is not the residual limit 5 states.** That residual is material only a *discovered check*
reads. Here the gate's own link phase read the target's existence and used the answer in its verdict.
Reporting it as the residual would have repeated exactly the mis-drawn boundary of the previous two
versions.

**Finding 2 [P2] — a whole-line comment was folded into the value it followed. This was ours.**

`tests/test_skill_frontmatter.sh` treated an indented `# comment` as an ordinary continuation and
then accepted a following continuation that Psych rejects. *Reproduced with the reviewer's own
script, unmodified:* `PASS: 23 skill file(s) …`, `ALL SKILL FRONTMATTER CHECKS PASSED`,
`checker_exit=0` against `ruby_yaml_exit=1` with `Psych::SyntaxError: did not find expected key while
parsing a block mapping at line 2 column 1`.

**v1.60's own report registered this**, reasoning that modelling it needed modelling what Psych does
to a continuation after a comment, and that this would be "a repair riding inside a repair".

**Finding 3 [P2] — case 20c measured a presence while claiming an absence. This was also ours.**

Case 20c certified that *the CI workflow does not carry a hand copy of the limits* by checking that
the workflow **invokes** `--limits`. *Reproduced with the reviewer's own script, unmodified:* a
workflow carrying both the invocation and five verbatim limit statements produced
`PASS: 20c. the CI workflow obtains the limits from the gate rather than copying them`,
`release-gate canaries passed`, `suite_exit=0`.

**v1.60's own sweep found this and called it "the sharpest" instance of its class**, then registered
it.

**Finding 4 [P3] — a claim known to be false was published.**

The `km-unrepaired-tree` declaration at the head of `tests/test_skill_frontmatter.sh` stated that the
reviewer's script *"prints NOT REPRODUCED with `checker_exit=1`"* on the repaired tree. The same
sentence stood in `tests/test_release_gate.sh`. **Both were false.** Those scripts pin `73f89e8` and
re-clone it, so they tested v1.59 on every run they ever made. *Re-measured on 2026-08-26 against the
published v1.60 tree:* `reproduce-tab-indentation-false-pass.sh` printed
`REPRODUCED: the v1.59 checker passed tab-indented frontmatter that Ruby YAML rejects` at exit 0, and
`reproduce-phase-derivation-false-pass.sh` printed `PASS: 21j …`, `suite_exit=0`, `REPRODUCED`.

**It was known.** The v1.60 drafting report said in plain words that the script "cannot show the
repair, because it hard-pins `73f89e8` internally". The true sentence stayed in the working report;
the false one went into the artifact.

**The reviewer's ruling, accepted here: disclosure does not satisfy a no-open-defect criterion.**
Registering a defect is honest and it is not a repair. Findings 2 and 3 are closed in this change,
and the full registered-not-repaired backlog is audited in `design.md`.

## What Changes

- **`tools/km-release-gate.py`.** The `Reads` ledger records **answers**, not only bytes: a new
  `probes` map holds every path whose presence the run asked about and the answer given, `path_exists`
  becomes the one accessor that asks, and the closing comparison re-asks every recorded question in
  **both directions**. Limit 5 is re-stated as the property rather than as a proxy for it. The
  coverage line names the number of presences recorded. Three call sites move to the accessor.
- **`tools/km-release-gate.py`, declaration phase.** `citation_failures` refuses a declaration that
  cites a script by `sha256` without stating what that script pins, and refuses a digest that is not
  64 hex characters.
- **`tests/test_release_gate.sh`.** Cases 21k/21k2/21k3 (the ledger, both directions plus the clean
  direction); 20c narrowed to the pointer it measures, with 20c2 measuring the absence against the
  gate's own `--limits` output and 20c3 proving the detector fires; cases 22/22b/22c/22d/22e for the
  citation rule, including the prose direction that the first form of the rule failed.
- **`tests/test_skill_frontmatter.sh`.** A whole-line comment ends a plain scalar that has already
  started; it ends neither a block sequence nor a key whose value has not begun, and a blank line
  ends nothing. Four detection canaries and five clean canaries, every shape measured against Psych.
- **`.github/workflows/release-gate.yml`.** The comment claiming that case 20 prevents the copy from
  returning is corrected to name what each of the three cases actually asserts.
- **Both declarations corrected.** The false clauses are **struck in place and attributed**, never
  deleted, and each cited script now states what it pins. A 65-character digest published by v1.59 is
  corrected.
- **`STANDARD.md`.** Four new obligations, the lead, and the version-history row.

## Impact

- Affected specs: `release-verification-scope`, `verification-instrument-integrity`,
  `compound-value-validation`.
- Affected code: `tools/km-release-gate.py`, `tests/test_release_gate.sh`,
  `tests/test_skill_frontmatter.sh`, `.github/workflows/release-gate.yml`, `STANDARD.md`.
- No hub is edited, nothing is redeployed, and nothing here binds until this version's own owner push.
