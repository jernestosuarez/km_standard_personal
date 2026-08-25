## Why

Two defects in `template/hub-scan.sh`, the session-start scan every hub inherits. Both were found in
operation by a reference deployment, and both are **harvested** rather than invented here: the designs
were written by the tier that found them, which then refused its own ledger items because the only
artifact that could close them is the canonical scan, which that tier may not edit. A design handed
over is still a claim, so each was verified here and each was reproduced as a failing case on this
branch, off `main` at `2005772` (published v1.56), before either repair was written.

**Defect 1 — the `[ RESTRICTED ]` check blocks a numbered curated document's own name.**

In the pass-1 `awk`, the frontmatter branch treats a `sensitivity: restricted` marker by emitting an
`I` record, which blocks the note's NAME on every outbound surface. For a **numbered curated
document** — a root-level `0[0-9]_*.md` or `10_*.md`, the fixed layout of §"Hub Directory Structure"
and the numbered half of the monitored-files glob — that is wrong. A numbered document's name is the
hub's public structure, not a disclosive record identifier.

*Reproduced on the unrepaired tree.* A `changes/` directive restricting the content of
`03_risks-decisions.md` produced:

```
  ! RESTRICTED IDENTIFIER '03_risks-decisions' on outbound surface: changes/2026-08-24_XX_restrict-claim_directive.md
```

exit 1. So a directive that restricts a document's content cannot name the document it is
restricting, the hub's scan fails at every session start, and the real integrity errors are buried
underneath a finding about the governance act itself. The same tree raised **no** finding at all over
a verbatim quotation of that document's body and exited 0, which is the other half of the same
defect: the frontmatter marker was blocking the name and protecting none of the text.

**Defect 2 — the `[ CORRECTIONS ]` counter reads `lifecycle:` as if it meant `binds`.**

```
_nactive=$(grep -rl '^lifecycle: active' "$_estate_corr"/*.md 2>/dev/null | wc -l | tr -d ' ')
```

`lifecycle:` records whether a DOCUMENT is current; it does not make a note a binding rule. `rule:`
is what does, and the v1.19 section that introduced this block **already specified the count as the
active notes whose `rule:` is in force**, so the implementation never matched its own published
specification. The registry's own `README.md` — a reference document, current, carrying no rule — is
counted as a rule that binds, and every scaffold document ever added to the directory reproduces it.

*Reproduced.* Against a live registry the shipped predicate returns **90**, the corrected predicate
**89**, and `README.md` is the sole difference; three independent instruments in that deployment
already agree on 89. On the synthetic fixture, over two real rules plus a `README.md` and a generated
`index.md` carrying no `rule:`, the block printed `(4 active)` and claimed *every lifecycle: active
note's rule: is in force in this hub*.

## What Changes

- **`template/hub-scan.sh`, `[ RESTRICTED ]` pass 1.** On a numbered curated document at the hub
  root, a frontmatter `sensitivity: restricted` marker sets the classification arm instead of
  emitting the `I` record: content blocked verbatim, name nameable — the treatment
  `accessClass: restricted|record` has had since v1.22, under the crossing law the comment beside it
  already cites. Root-scoped: a numbered name in a subdirectory is unaffected. The body-marker path
  is unchanged.
- **`template/hub-scan.sh`, `[ CORRECTIONS ]`.** The count becomes a three-armed predicate — not
  scaffold, carries a `rule:`, is `lifecycle: active` — written as a loop rather than a pipeline,
  because hub and estate paths contain spaces and an `xargs` formulation returns 0 on such a path
  without saying so. The printed line is rewritten to state that predicate.
- **`tests/test_restricted_lint.sh`.** Four cases (1d–1g) and three fixtures. 1d and 1e detect the
  defect and fail on the unrepaired tree; 1f and 1g pin the boundary the narrowing must not cross and
  the path it does not touch, and pass on both trees by design.
- **`tests/test_corrections_binding.sh`.** Scaffold, generated-index and superseded fixtures; the
  count assertion and a new assertion that the printed line states the predicate actually counted.
- **`STANDARD.md`.** Two normative subsections, the draft lead, and the v1.57 ledger row.

**BREAKING** for nothing a hub asserts. The behavioural change a deployment meets on adoption is
stated rather than absorbed: on a numbered curated document restricted in frontmatter, its name stops
being an error on outbound surfaces and its verbatim body text starts being one, so a proposal
quoting such a line is now a finding where it was not; and an estate whose corrections registry holds
scaffold documents will see its `[ CORRECTIONS ]` count fall. Both are the check doing what the
standard says.

## Impact

- Affected specs: `hub-session-scan`
- Affected code: `template/hub-scan.sh`, `tests/test_restricted_lint.sh`,
  `tests/test_corrections_binding.sh`, `STANDARD.md`
- **Not in scope, deliberately.** The ledger item this answers names two acts; only the first is
  here. Re-deploying the repaired scan across divergent installed copies is writing into hubs, which
  is each hub's own act under its own governance. No hub is edited or dispatched by this version.
