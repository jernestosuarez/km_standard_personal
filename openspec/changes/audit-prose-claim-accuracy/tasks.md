# Tasks: audit-prose-claim-accuracy (v1.56)

Branch `v1.56-prose-claim-accuracy`, off `main` at `aeec51a` (published v1.55).

## 1. Reproduce every finding before repairing anything

- [x] 1.1 **The licence file, verified independently rather than taken from the report.** Restore the
      Appendix placeholder on the one line that differs and hash the result:
      `sed 's/^   Copyright 2026 <owner>$/   Copyright [yyyy] [name of copyright owner]/' LICENSE |
      shasum -a 256` returns
      `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, the published digest of the
      canonical Apache-2.0 text and the digest the v1.53 row already cites. Sections 1 to 9 carry no
      edit; exactly one line differs, and the Appendix is what directs it.
- [x] 1.2 **Locate every "unmodified" claim.** Three: `STANDARD.md` line 69 (the header lead's copy of
      the v1.53 description), the v1.53 version row, and
      `openspec/changes/audit-licence-declared/{proposal,design}.md`. The row is already precise: it
      says the Appendix boilerplate was completed as the Appendix directs and no other byte was
      touched. The imprecision is in the lead's summary.
- [x] 1.3 **The README's Section 4 sentence, quoted as it stood:** "What the licence asks in return:
      **keep the copyright notice, the licence text, and the `NOTICE` attribution, and mark the files
      you changed** (§4). Attribution is a condition of the grant." No condition named. Section 4
      conditions distribution.
- [x] 1.4 **The markdown-file count.** `git ls-files '*.md' | wc -l` → **158**. At `eb57f0f`, the
      v1.53 publish commit, `git ls-tree -r --name-only eb57f0f | grep -c '\.md$'` → **150**. The
      claim is **147**, which that change's own tasks file records as the count on `main` before the
      package's own files landed. Code files, `.py` and `.sh`: **41** at `eb57f0f` and **41** now.
      **The reviewer's attribution to `README.md` does not survive verification**: `README.md` states
      no file count, and never has.
- [x] 1.5 **The MCP entry points.** `grep -cE '^@mcp\.(tool|resource)' template/mcp/server.py` → **7**
      (four tools, three resources). `bash tests/test_mcp_quarantine.sh` prints
      `PASS: all 11 entry points refused`. Eleven is the size of the driver's call list;
      `get_entity` is driven five times with five identifiers.
- [x] 1.6 **The gate's stated limits.** `python3 tools/km-release-gate.py --limits` →
      `km-release-gate states 4 limits`. At `a2756e2` (v1.46 publish) the gate printed **three**; at
      `eb57f0f` (v1.53 publish) it printed **three**. So the v1.53 row's "two stated limits" was
      false on the day, and `agents/km-hub-builder/SKILL.md` has said two since v1.46, which is where
      the row got it. The v1.54 row correctly says three, so the ledger already disagreed with itself.

## 2. The sweep: what else is asserted in prose and verified by nothing

- [x] 2.1 Read for counts, version identifiers and file references: `README.md` (package table,
      licence section, badge alt text), `STANDARD.md` (live sections and the ledger), `template/`
      (landing page, skills, scan), `components/km-cockpit/`, `agents/km-hub-builder/` and its
      adapters, `docs/architecture/`, `rfcs/`, `.github/workflows/`, `tools/`, and every check under
      `tests/` and `scripts/`.
- [x] 2.2 **Finding: the README enumerates six per-hub skills where the template installs seven.**
      `template/.claude/skills/` and `template/.agents/skills/` each hold `km-brief`, `km-gather`,
      `km-handover`, `km-intake`, `km-propose`, `km-publish`, `km-start`. The row omits `km-publish`.
- [x] 2.3 **Finding: the gate's header claims a copy that no longer exists.** It says the first two
      limits are stated "here, in the standard, and in the CI workflow"; v1.55 deleted the CI copy
      and replaced it with a `--limits` step.
- [x] 2.4 **Finding: the CI definition describes discovery as it was before v1.54.** Its opening
      comment says the gate "discovers every tracked check", and since v1.54 discovery reads the
      working tree, tracked and untracked together.
- [x] 2.5 **Finding: the README counts the design set by hand beside a badge that derives it.**
      "Design RFCs, seven of them" stands next to an RFC badge that
      `scripts/validate_rfc_lifecycle.py` renders from the index and asserts against the committed
      surface. Seven is correct today and is a hand-kept memory of a growing directory.
- [x] 2.6 **Findings of none, recorded so the next sweep does not re-derive them.** The entity-note
      folder enumeration in the same README row is exactly the nine directories under `template/`
      carrying a `TEMPLATE.md`. `tests/test_hub_scan_canaries.sh` carries cases 14a to 14m as
      `STANDARD.md` says. The shipped template projects three of the ten declared fact classes, as
      the standard says. There are 23 shell suites, as v1.55's dated records say, and this change
      makes 24 without restating theirs. `docs/architecture/` writes "at least nine surfaces", which
      is the lower-bound form this class wants and is the model.
- [x] 2.7 **Two checks considered and refused, with reasons, in `design.md` decision 5:** a
      version-identifier agreement check across the five surfaces the publish ritual flips (those
      surfaces are designed to disagree while a version is drafted), and a general back-quoted
      repository-path reference check (the tree quotes hub paths, template paths and examples, and
      the instrument would need a hand-maintained exclusion list).

## 3. Run the added and edited checks against the unrepaired tree, before the repair

- [x] 3.1 `tests/test_readme_inventory.sh` written and run on `main` at `aeec51a`. **Case 2 FAILED**:
      "the README's per-hub skill enumeration omits km-publish, which the template ships". Case 3
      (entity-note folders) **passed there legitimately** and is recorded as passing rather than
      reworded until it fails. Cases 4, 5 and 6 passed, being the refusal and the two negative
      directions.
- [x] 3.2 `tests/test_mcp_quarantine.sh` case 7 written and run before the summary line was repaired.
      **FAILED**: "the suite reports 11 entry point(s) while the surface declares 7". Negative
      direction driven separately by appending an eighth decorated entry point the driver does not
      call: the case fails naming `probe_entry` as declared and unreported. `template/mcp/server.py`
      restored and confirmed byte-identical afterwards.
- [x] 3.3 Both declarations written into the files that carry them, naming **v1.56** and the real
      result. `tests/test_mcp_quarantine.sh` re-states its v1.40 declaration in full beside the new
      one, because the v1.40 run still holds.

## 4. Repair finding 6

- [x] 4.1 `STANDARD.md` §"The boundary asserts no license" gains a paragraph stating what
      "unmodified" means about `LICENSE`: the terms carry no edit, one Appendix line is instantiated
      as the Appendix directs, and the digest reproduces on restoring the placeholder.
- [x] 4.2 The same section's sentence about `README.md` now says the page states that the Section 4
      conditions attach to redistribution.
- [x] 4.3 The header lead's imprecise copy is **not** edited: it is a published description that step
      1 of the publish ritual preserves word for word, and flipping the header to v1.56 rolls the
      v1.53 description out of the lead by the mechanism that already exists.
- [x] 4.4 `README.md`'s licence section names redistribution as the trigger, lists the notices as §4
      lists them, states that internal use and private modification trigger none of them, keeps the
      withdrawal of the no-attribution claim scoped to redistribution, and names `LICENSE` §4 as
      governing. No advice added.

## 5. Repair finding 7, three ways

- [x] 5.1 **Corrected, false on the day:** the v1.40 row now reads "all seven content-returning entry
      points, the four tools and the three resources, refuse and return no content across eleven
      driver invocations", with a note stating what the row said, what eleven counted, and that it is
      corrected under the v1.47 rule with the pushed objects left alone.
- [x] 5.2 **Corrected, false on the day:** the v1.53 row states no count of the gate's limits, carries
      a note recording that it said two while the gate printed three on the day and why, and its own
      two additional limits are renumbered so the ordinals agree.
- [x] 5.3 **Dated, not refreshed:** the v1.53 row's "147 markdown files and 41 code files" gains
      "when the decision was taken" and a note stating all three measured figures and the reason a
      refresh would falsify the record.
- [x] 5.4 **Stop counting:** `agents/km-hub-builder/SKILL.md` states no number, orders the set to be
      taken from the gate, keeps the two limits that bear on it as substance, and says why the number
      is gone so a later maintainer does not restore it.
- [x] 5.5 `STANDARD.md` §"Publishing a version" step 5 takes the same treatment, and
      §"A gate runs before publication" no longer reads "beyond those four".
- [x] 5.6 `tools/km-release-gate.py`'s header no longer claims the CI workflow carries a copy of the
      limits, and points at `GATE_LIMITS` and `--limits` as the one definition.
- [x] 5.7 `.github/workflows/release-gate.yml`'s opening comment describes discovery as reading the
      working tree, tracked and untracked together, and names the coverage line as the figure to read.
      The comment block above `runs-on:` is untouched, so case 20d of `tests/test_release_gate.sh`
      still holds.
- [x] 5.8 `README.md` drops "seven of them" from the RFC row and lets the derived badge carry the
      number.

## 6. Write the rule down

- [x] 6.1 `STANDARD.md` §"Standard Maintainer" gains the subsection stating both halves: a count of a
      growing set is derived or dropped, and a dated record is corrected only where it was wrong when
      written, with dating as the third option for a true statement that invites a false present-tense
      reading. Marked as drafted and unpublished.
- [x] 6.2 The delta lands against the existing `documentation-truth` capability, because a requirement
      is genuinely added. `openspec validate audit-prose-claim-accuracy --strict` passes.

## 7. Verify

- [x] 7.1 `bash tests/test_readme_inventory.sh` passes on the repaired tree, reporting the derived
      counts on its passing line.
- [x] 7.2 `bash tests/test_mcp_quarantine.sh` passes, case 7 reporting seven entry points named.
- [x] 7.3 `python3 tools/km-release-gate.py` exits 0 with `0 discovered check(s) untracked`.
- [x] 7.4 The canonical leakage instrument run over the whole tree and, separately, over the outgoing
      range, which is what the pre-push hook reads.
- [x] 7.5 `git diff --check` clean; explicit paths staged; `KM-Agent: km-hub-builder` trailer only.
- [x] 7.6 Not pushed. The version row opens with its draft declaration and the material it adds is
      marked drafted and unpublished until the owner's push.
