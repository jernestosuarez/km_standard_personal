## Why

The first independent review of this repository by anyone outside the authoring loop returned a
conditional fail on 2026-08-25. Its release blocker was repaired as v1.54. Four P2 findings remained.
Each was reproduced on this branch, off `main` at `13dec55` (published v1.54), before anything was
repaired. All four hold, and two of them reach further than the reviewer said.

**1. The skill-frontmatter check accepts an unterminated block.**
`tests/test_skill_frontmatter.sh` checks that line 1 is `---` and then extracts the block with
`awk 'NR>1 && /^---$/{exit} NR>1'`, which happily runs to end of file when no closing delimiter
exists. Measured: the closing `---` was deleted from all three shipped copies of `skills/km-brief`,
and the suite printed `PASS: every shipped skill file carries a conforming name/description
frontmatter`, `ALL SKILL FRONTMATTER CHECKS PASSED`, exit `0`. The whole body of the file was read as
frontmatter and nothing complained.

**2. A quoted exemption token disables link checking for a whole document.**
`tools/km-release-gate.py` runs `LINK_EXEMPT_RE.search(text)` on the raw markdown, before
`strip_fenced` and with no anchor. Measured: `README.md` was given a broken link and a fenced `text`
block containing the exemption token as an example. `check_links` reported `0` failures, `153 of 154
markdown files scanned, 1 exempt`, `88 links resolved`. Without the fenced example the same tree
reported `1` failure naming the broken link and `113 links resolved`. A quotation removed a document
from the scan and 25 links from the count.

**This is the class v1.52 repaired**, where a quoted draft-declaration token silenced two publication
checks and the repair anchored the read to where the declaration is made. The class was repaired in
one instrument and left standing in another. The sweep this finding demands then found the anchor
v1.52 chose is itself reachable: `scripts/validate_published_not_draft.py` and
`scripts/validate_rfc_references.py` read their exemption from the first 60 lines, raw. Measured: one
sentence inserted at line 13 of `STANDARD.md` reading ``A document opts out by writing
`published-not-draft-exempt: <reason>` in its first lines.`` exempted `STANDARD.md`, the home of
record, from its own publication check, which printed `exempt: STANDARD.md (<reason>` in its first
lines.)` and exited `0`.

**3. The installer's replacement behaviour is asserted, never verified.**
`agents/km-hub-builder/tests/test-agent-package.sh` runs `install-agent.sh --replace-existing` under
`set -e` and asserts nothing afterwards. Measured: a branch was added to `install-agent.sh` that
prints the two `Installed ...` lines and exits `0` without copying anything when
`--replace-existing` is passed. The suite printed `agent package tests passed` and exited `0`, with
the unmanaged file still holding the word `unmanaged`.

**4. The CI workflow overstates pinning and understates limits.**
`.github/workflows/release-gate.yml` calls `ubuntu-24.04` "Pinned rather than ubuntu-latest". GitHub
redeploys version-labelled runner images on a weekly cadence, so the image behind that label is
mutable and the claim is false. The same file's header documents **two** gate limits under "Both
limits are stated in STANDARD.md"; `tools/km-release-gate.py` prints **four** on every passing run.
The workflow is a hand copy of prose that lives somewhere else, and it has already drifted.

## What Changes

- **A frontmatter block must be terminated to be read.** `tests/test_skill_frontmatter.sh` requires a
  closing `---` on its own line, refuses a block whose keys are duplicated, and gains a canary for
  each. The sweep of the surrounding class is recorded: five malformations were probed against the
  unrepaired check, four passed it, and the fifth was already caught.
- **A directive token is read only where a directive is declared.** One anchoring rule is applied to
  all three exemption readers: the token must begin its line, after optional whitespace and an
  optional comment marker, and must not sit inside a fenced block. The gate's link exemption also
  gains the leading-window anchor its two siblings already had, so the three instruments now read
  their exemptions by the same rule.
- **The installer test asserts outcomes.** Every case in
  `agents/km-hub-builder/tests/test-agent-package.sh` now asserts what happened rather than what was
  returned: the replaced file carries the managed marker and no longer carries the unmanaged content,
  the refused file is byte-identical to what it was before the refusal, and each expected refusal is
  required to name its own reason.
- **The workflow states what is true and stops copying what is not.** `ubuntu-24.04` is described as
  a version label whose image is redeployed on a weekly cadence, not as a pin. The two copied limit
  paragraphs are replaced by a step that runs `python3 tools/km-release-gate.py --limits`, which
  prints the gate's own limits into the CI log from the single definition the gate itself prints
  from. `tests/test_release_gate.sh` pins the mechanism: the flag prints every defined limit, and the
  workflow invokes it.

## Impact

- Affected specs: `verification-instrument-integrity` (new capability).
- Affected code: `tests/test_skill_frontmatter.sh`, `tools/km-release-gate.py`,
  `scripts/validate_published_not_draft.py`, `scripts/validate_rfc_references.py`,
  `agents/km-hub-builder/tests/test-agent-package.sh`, `tests/test_release_gate.sh`,
  `.github/workflows/release-gate.yml`.
- Affected contracts: `STANDARD.md` §"A gate runs before publication, and it declares what it cannot
  do" and §"Skill files declare their trigger".
- Affected deployments: any fork running these checks. Every change is stricter, never looser. A tree
  whose skill frontmatter is terminated, whose exemptions are declared at the start of a line outside
  a fence, and whose installer actually copies files, behaves exactly as before.
- Not affected: the exemption syntax itself is unchanged, and every exemption currently declared in
  this repository still resolves under the new rule.
