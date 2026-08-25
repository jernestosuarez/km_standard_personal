## Why

The external review of 2026-08-25 returned a conditional fail. Its release blocker was repaired as
v1.54 and its four P2 findings as v1.55. Two findings remained, and both are the same class: a claim
made in prose that no instrument reads. Each was reproduced on this branch, off `main` at `aeec51a`
(published v1.55), before anything was repaired, because several of the reviewer's figures had moved
since they were measured and one of them named a file that never carried the claim.

**6. The licence prose, while the licence itself is sound.** Reproduced independently: with the
Appendix boilerplate's `Copyright [yyyy] [name of copyright owner]` restored on the single line that
differs, `LICENSE` hashes to
`cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, the published digest of the
canonical Apache-2.0 text. Sections 1 to 9 carry no edit; one Appendix line is instantiated exactly
as the Appendix directs. Two things around it are wrong.

- *"Unmodified" is imprecise.* `STANDARD.md` §"The boundary asserts no license" said `LICENSE`
  "carries the complete licence text" and the header lead said "the complete unmodified licence text
  with his copyright line". Neither tells a reader that one line is instantiated, or how to check it.
  A reader who expects a byte-identical copy and meets an unexplained difference has met it in the
  one file where an unexplained difference costs the most.
- *The README overstates the duties.* It read: "What the licence asks in return: **keep the copyright
  notice, the licence text, and the `NOTICE` attribution, and mark the files you changed** (§4).
  Attribution is a condition of the grant." Section 4 conditions **distribution**. As written the
  page told a reader who uses the standard internally, or who modifies it and passes it to nobody,
  that they owe notice-preservation duties they do not owe.

**7. Factual drift, in three claims that are three different repairs.**

- *The markdown-file count.* Claimed 147 markdown files and 41 code files. Measured: **158** tracked
  markdown files now, **150** in the tree the v1.53 publish commit `eb57f0f` shipped, **147** on
  `main` when that change's design was written, and **41** code files at all three points. The
  reviewer attributed the claim to `README.md` as well; that did not survive verification, because
  `README.md` states no file count.
- *The MCP entry points.* The v1.40 row and `tests/test_mcp_quarantine.sh` both said **eleven**
  content-returning entry points. Measured: `template/mcp/server.py` declares **seven**, four
  `@mcp.tool()` and three `@mcp.resource()`. Eleven was the size of the suite's own driver call list,
  `get_entity` being driven five times with five identifiers.
- *The gate's stated limits.* `agents/km-hub-builder/SKILL.md` has ordered every report to read the
  gate's **two** stated limits since v1.46, and the v1.53 row obeyed it. Measured: the gate printed
  **three** at `a2756e2` (the v1.46 publish commit) and at `eb57f0f` (the v1.53 publish commit), and
  prints **four** now. The contract was wrong from the version that introduced the gate.

**The question underneath both findings.** All of it is prose no instrument reads, the same class as
the six surfaces asserting Apache-2.0 with nothing checking any of them. So the change also owes a
sweep of what else this repository asserts in prose and nothing verifies.

## What Changes

- **The licence prose becomes precise, and the duties get their condition.** The live section states
  which part of `LICENSE` is canonical, which line differs, why the Appendix directs it, and the
  digest anyone can reproduce. `README.md` names redistribution as the trigger for §4, lists the
  notices as §4 lists them, says that internal use and private modification trigger none of them, and
  points at `LICENSE` as governing. No advice is added.
- **Three counts, three treatments, and the discriminator is written down.** A count is **corrected**
  when it was false on the day it was written, and **left standing** when it was true then and has
  been overtaken since. The eleven entry points and the two limits were false on the day and are
  corrected, under the v1.47 rule that a false published row is corrected in the ledger while the
  pushed objects are left alone. The 147 was a dated measurement supporting a dated decision, so it
  is **dated rather than refreshed**: the words "when the decision was taken" are added and the
  number is not touched.
- **The repair for the limits is to stop counting.** The maintainer contract states no number and
  orders the set to be taken from the gate; §"Publishing a version" step 5 does the same;
  §"A gate runs before publication" no longer says "those four"; and the gate's header no longer
  claims a CI copy that v1.55 deleted.
- **One check is added, and it answers the class.** `tests/test_readme_inventory.sh` derives what the
  template ships, its entity-note folders from the directories carrying a `TEMPLATE.md` and its
  per-hub skills from both runtime trees, and requires the landing page's two enumerations to equal
  the derivation in both directions. `tests/test_mcp_quarantine.sh` gains case 7, which holds the
  entry-point figure the suite reports against the set the surface declares by decorator.
- **The sweep is recorded, findings and findings of none alike**, in the version row, so the next
  sweep does not start blind.
- **One requirement is genuinely added**, and it is the discriminator above plus the rule that a
  count of a growing set is derived or dropped rather than refreshed. That is the delta.

## Impact

- Affected specs: `documentation-truth` (one requirement added).
- Affected code: `tests/test_readme_inventory.sh` (new), `tests/test_mcp_quarantine.sh`,
  `tools/km-release-gate.py` (comment only), `.github/workflows/release-gate.yml` (comment only).
- Affected contracts: `STANDARD.md` §"The boundary asserts no license", §"Standard Maintainer",
  §"A gate runs before publication, and it declares what it cannot do", §"Publishing a version";
  `agents/km-hub-builder/SKILL.md`; `README.md`.
- Affected deployments: none. No template file, skill, scan or hub-facing surface changes behaviour,
  and no hub turns red. The one behavioural change is a new maintainer-side check on this
  repository's own landing page.
- Not affected: the licence, the grant, and everything the standard asserts about deployments. The
  repair to the licence prose changes no term and no permission.
