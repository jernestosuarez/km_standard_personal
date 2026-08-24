## Why

This repository is about to be forked and handed to an external party. A fork carries its documents
to readers who cannot ask anyone what a page really meant, so a page that describes a capability the
system does not have travels as fact.

Three audit findings are one class, and it is the class this remediation has already repaired three
times: **a document asserting something the system does not do.** v1.42 found published sections
telling readers a binding obligation bound nothing. v1.45 found published text naming a design
document no reader could open. v1.47 found published rows naming days on which nothing happened.
These three are the same shape in three more places, and two of them sit on the surfaces a fork and a
new hub meet first.

- **F-08.** `template/README.md` line 64 says `hub-scan.sh` "checks all four rules in one pass." The
  standard defines six. The same page tells a reader to find a fact by opening a numbered document,
  while the standard's model is one entity note per instance with the numbered documents as narrative
  rollups, a model the template's own `06_risks-decisions.md` already states. This page is copied
  into every new hub, so its blast radius grows with adoption.
- **F-11.** `STANDARD.md` says the governance layer "enforces six rules." No instrument validates
  Rule 5. The repository's own `DESIGN-RATIONALE_akcp-component-mining.md` records source
  traceability as "a source-traceability rule enforced by *discipline*" with "Nothing records
  *lineage* (where each fact came from) as a checkable artifact."
- **F-12.** `docs/architecture/README.md` describes the architecture "as of **v1.22**" while the root
  README lists the set in the present tense with no version qualifier at all. Nine surfaces have been
  added or materially changed since v1.22.

## What Changes

- `template/README.md`'s governance summary carries all six rules the standard defines, and the
  sentence about the scan states which rules it actually checks rather than a count that is wrong.
- `template/README.md`'s fact-finding line names the entity notes as the home of an individual fact
  and the numbered documents as the narrative rollups, matching the model the same template's own
  numbered documents already declare. The supporting-structure table gains the entity-note folders
  the template ships and the table omitted.
- `STANDARD.md` "Layer 2: Governance" narrows its enforcement claim: it states six rules, checks four
  of them mechanically at session start, checks the outbound half of the sixth, and holds Rule 5 as
  procedure with no instrument behind it. The obligation of Rule 5 is unchanged; only the claim about
  how it is enforced is narrowed.
- `STANDARD.md` "Standard Maintainer" gains the generalised rule the class earns after four repairs:
  a document is held to what the system does.
- The architecture set is **labelled as a historical v1.22 snapshot everywhere it is linked** rather
  than refreshed. `docs/architecture/README.md` says so in its own banner and its frontmatter
  description; the root README's row says so where a reader meets the link. See the design for why
  the label is the honest repair here and the refresh is not.
- A new check, `scripts/validate_template_rule_summary.py`, derives the standard's rule set from
  `STANDARD.md`'s own `### Rule N:` headings and requires the hub template's landing page to
  enumerate every one of them and to state no rule count that disagrees with it.
- `tests/test_template_rule_summary.sh` proves both directions and runs the check against the
  unrepaired tree at `62c4e51`, where it names the two missing rules and the false count.
- The v1.48 version row records all three false statements as they stood, the fork as the reason the
  class was taken now, and the F-12 decision with its reasoning.
- **F-11 and F-12 get no check.** Both are prose judgements whose evidence a check cannot represent.
  Stated in the design rather than answered with an instrument that models the wrong class.
- Not **BREAKING**. No obligation is added or withdrawn, no schema changes, and the only shipped
  surface that changes is the hub template's landing page, whose repair is text.

## Capabilities

### New Capabilities

- `documentation-truth`: what an inherited or published document may assert about the system that
  ships it, how the hub template's rule summary is held to the standard's own rule set, on what terms
  an enforcement claim distinguishes a mechanical control from a procedural one, and how a document
  set that has stopped describing the current system is labelled rather than silently presented as
  current.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: `template/README.md`; the Layer 2 and Standard Maintainer sections, the
  v1.48 row, the header, the frontmatter and the lead of `STANDARD.md`; the architecture row of
  `README.md`; the banner and frontmatter description of `docs/architecture/README.md`; the new
  `scripts/validate_template_rule_summary.py` and its canaries `tests/test_template_rule_summary.sh`.
- **Affected deployments**: one shipped surface changes, `template/README.md`. A hub that already
  installed it carries the four-rule page until it refreshes it, which is an adoption act under that
  hub's own governance. No hub turns red: the new check runs in this repository against the template,
  and no hub runs it.
- **Not in scope**: refreshing the architecture documents to the current version. See the design.
- **Not in scope**: building a Rule 5 provenance instrument. Narrowing the claim is the repair;
  inventing the instrument is a far larger change with its own authority.
- **Not in scope**: `template/README.md`'s line naming the governance reference as "AI KM Hub
  Standard (available from the hub owner)". It is reported and left, because it is a different class
  from the two the finding names and repairing it silently would widen a truth repair into a rewrite.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
