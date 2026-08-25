# Tasks

Executed on branch `v1.55-reviewer-p2-findings`, off `main` at `13dec55` (published v1.54). Ordered by
dependency: reproduce every finding before repairing anything, sweep the class each finding implies,
then repair, then prove the other direction, then record.

Requirement references point at `specs/verification-instrument-integrity/spec.md` (VII).

## 1. Reproduce all four findings on the unrepaired tree

- [x] 1.1 Finding 1. Delete the closing `---` from all three shipped copies of
      `skills/km-brief/SKILL.md` and run `tests/test_skill_frontmatter.sh`. Record the verdict and the
      exit status.
      (VII: the closing delimiter is absent)
- [x] 1.2 Finding 2. Give `README.md` a broken relative link and a fenced block quoting
      `km-gate-link-exempt:`. Call `check_links()` directly and record failures, files scanned, files
      exempt and links resolved. Then remove the fence alone and record the same figures, so the
      quotation's effect is measured rather than inferred.
      (VII: the token appears inside a fenced code block)
- [x] 1.3 Finding 3. Add a branch to `install-agent.sh` that prints both `Installed ...` lines and
      exits 0 without copying when `--replace-existing` is passed. Run
      `agents/km-hub-builder/tests/test-agent-package.sh` and record the verdict and exit status.
      (VII: the operation returns success without acting)
- [x] 1.4 Finding 4. Confirm the workflow's word `Pinned` against what GitHub guarantees, and count
      the limits the workflow documents against the limits the gate prints. **Measured: the workflow
      header enumerates 2 under "Both limits are stated in STANDARD.md"; the gate prints 4.**
- [x] 1.5 Restore the tree to clean after each reproduction and confirm with `git status --short`
      before the next one.

## 2. Sweep the class each finding implies

- [x] 2.1 Finding 1's class. Probe five further frontmatter malformations against the unrepaired
      check: a `...` terminator, a duplicated `name:`, a duplicated `description:`, an extra key, and
      an empty block. Record which pass and which are already caught.
- [x] 2.2 Finding 2's class. Enumerate every machine-read directive token in the repository and
      record, for each, the position its instrument reads it from. Demonstrate rather than assert:
      insert a quotation into the first 60 lines of `STANDARD.md` and record what
      `scripts/validate_published_not_draft.py` does with it.
- [x] 2.3 Finding 3's class. Sweep all 23 shell suites for cases that assert an exit status where an
      effect is meant. Separate the class proper from its weaker sibling, where a verdict's status is
      asserted without its reason.
- [x] 2.4 Decide the boundary of this change: repair the class in the files the findings name, and
      register the rest with reasons rather than widening without bound.

## 3. Repair finding 1

- [x] 3.1 Require a closing `---` on its own line, and refuse a block whose required key appears more
      than once. Report each as its own violation line.
      (VII: the closing delimiter is absent; the block is closed with a different marker; a key
      appears twice inside the block)
- [x] 3.2 Add a canary for each new rule, and confirm the existing canaries still fire.
- [x] 3.3 Record the extra-key case in the check's header as a registered gap with its reason.
- [x] 3.4 Re-state the `km-unrepaired-tree` declaration on `tests/test_skill_frontmatter.sh` naming
      v1.55 with the result measured in tasks 1.1 and 2.1.

## 4. Repair finding 2

- [x] 4.1 Add one shared anchoring rule: the token begins its line after optional whitespace and at
      most one comment marker, and is not honoured inside a fenced block.
      (VII: the token appears mid-sentence in prose; the token is declared at the start of a line)
- [x] 4.2 Apply it in `tools/km-release-gate.py` for `km-gate-link-exempt:`, and give that reader the
      60-line leading window its two siblings already have.
- [x] 4.3 Apply it in `scripts/validate_published_not_draft.py` and `scripts/validate_rfc_references.py`.
- [x] 4.4 Confirm every exemption currently declared in this repository still resolves, by name and
      reason, on each instrument's passing run.
      (VII: a declared exemption carries no reason)
- [x] 4.5 Add the canaries: a fenced quotation, a mid-sentence quotation, and a real declaration, in
      the suites of all three instruments.
- [x] 4.6 Re-state the `km-unrepaired-tree` declaration on every check file touched, naming v1.55.

## 5. Repair finding 3

- [x] 5.1 Assert the effect of the pre-install check, the install, the post-install check and the
      parity run, and require each expected refusal to name its reason.
- [x] 5.2 Assert that the refused collision left the unmanaged file byte-identical.
      (VII: the operation refuses and must leave the tree alone)
- [x] 5.3 Assert that `--replace-existing` replaced the file: the managed marker present, the
      unmanaged content gone, and the result identical to a clean install.
      (VII: the operation acts as specified)
- [x] 5.4 Re-run the task 1.3 mutation against the repaired suite and require it to fail, naming the
      file.
- [x] 5.5 Re-state the `km-unrepaired-tree` declaration on
      `agents/km-hub-builder/tests/test-agent-package.sh` naming v1.55.

## 6. Repair finding 4

- [x] 6.1 Move the gate's four limits into one module-level definition, printed by the passing block
      and summarised by the failing block.
- [x] 6.2 Add `--limits`, printing that definition and exiting 0 without gating anything.
- [x] 6.3 Correct the workflow's runner comment to what the platform guarantees.
      (VII: the workflow describes its runner image)
- [x] 6.4 Replace the workflow's two copied limit paragraphs with a step that runs `--limits`.
      (VII: a limit is added to the tool)
- [x] 6.5 Add the suite cases that pin the mechanism: `--limits` prints every defined limit, and the
      workflow invokes it.
      (VII: the mechanism is pinned by a check)

## 7. Prove both directions

- [x] 7.1 Run each repaired check against its own reproduction from section 1 and require it to fail,
      naming the defect.
- [x] 7.2 Run each repaired check against the clean repository and require it to pass, with the same
      counts the unrepaired check reported where the tree is genuinely unchanged.
- [x] 7.3 Run `python3 tools/km-release-gate.py` to exit 0, and confirm the coverage line reports
      `0 discovered check(s) untracked`.

## 8. Record

- [x] 8.1 Amend `STANDARD.md` §"A gate runs before publication, and it declares what it cannot do"
      with the directive-anchoring rule and the effect-not-status rule.
- [x] 8.2 Amend `STANDARD.md` §"Skill files declare their trigger" with the terminated-block rule.
- [x] 8.3 Flip the header, the frontmatter title and the lead of `STANDARD.md` to v1.55 drafted and
      unpublished, preserving the published v1.54, v1.53 and v1.52 descriptions verbatim.
- [x] 8.4 Write the v1.55 version row: the external review as the source, each defect quoted as it
      stood and as repaired, and the two generalisations.
- [x] 8.5 `openspec validate audit-reviewer-p2-findings --strict` passes.
- [x] 8.6 Run the canonical leakage instrument over the final tree, both halves, and over the outgoing
      range separately.
- [x] 8.7 Commit with explicit paths and the `KM-Agent: km-hub-builder` trailer. Do not push.

## 9. Measured results, in one place

| Finding | Unrepaired tree at `13dec55` | Repaired |
|---|---|---|
| 1 skill frontmatter | closing `---` deleted from 3 shipped copies: `ALL SKILL FRONTMATTER CHECKS PASSED`, exit 0 | exit 1, naming the swallowed prose line by line |
| 1 sweep | `...` terminator, duplicate `name:`, duplicate `description:`, extra key: all exit 0, 0 violation lines. Empty block: exit 1, 6 violation lines | first three now exit 1 with a named violation; extra key registered, still exit 0 |
| 2 link exemption | fenced quotation: 0 failures, `153 of 154` scanned, 1 exempt, 88 links; without it 1 failure, 113 links | fenced and mid-sentence quotations both exit 1 naming the link; real declaration still honoured |
| 2 sweep, published-not-draft | one sentence at line 13 of `STANDARD.md`: `122 file(s) scanned, 5 exempt`, 3 markings of a true 9, exit 0 | `123 file(s) scanned, 4 exempt`, 9 markings, exit 0, `STANDARD.md` scanned |
| 2 sweep, rfc references | same sentence: 171 references across 130 files, 5 path references, exit 0 | 257 across 131, 15 path references, exit 0 |
| 3 installer | installer returning success without writing: `agent package tests passed`, exit 0 | exit 1 at case 6 naming the file; a truncating refusal exits 1 at case 5 |
| 4 workflow | `Pinned rather than ubuntu-latest`; 2 limits documented, 4 printed | label described as mutable; limits printed by `--limits` from one definition |

Gate on the final tree: `PASS release-gate`, exit 0, `33 check(s) discovered ... 0 discovered
check(s) untracked`, `0 check file(s) added, 8 changed, of 34 declared`.
