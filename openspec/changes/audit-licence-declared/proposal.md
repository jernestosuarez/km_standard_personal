## Why

The licence decision has been open since audit finding **F-07**. v1.49 closed the dishonesty and
left the decision where it belonged. It withdrew an advertised grant that no file in the tree
supported, recorded that no `LICENSE`, `COPYING` or equivalent existed, that default copyright
therefore applied, and that choosing a licence was the deployment owner's decision rather than a
maintainer's. Its own version row said so in as many words, and its tasks record the maintainer
refusing to select one.

The owner has now made the decision. Asked what licence to adopt, he accepted the recommendation of
**Apache-2.0**. Asked directly, he confirmed that **he is the author and the copyright holder**. Both
answers are his, given in the session that produced this change. This package implements a decision
and makes none.

Two things follow from that, and only one of them was asked for.

- **The grant goes into force.** A reader of this repository stops holding a statement of direction
  and starts holding a licence.
- **One sentence on the landing page becomes false.** `README.md` has promised free adoption *"with
  no attribution required"* since the repository's first commit. v1.49 preserved it deliberately, as
  the owner's intent, because under default copyright it granted nothing either way. Under
  Apache-2.0 it contradicts Section 4, which makes preserving the copyright notice, the licence text
  and the `NOTICE` attribution a condition of the grant. Leaving it would recreate F-07 in the act of
  closing it: a landing page saying one thing and the operative document saying another.

## What Changes

- **`LICENSE`** at the repository root: the complete Apache License 2.0, unmodified. The text was
  verified against the published SHA-256 of the canonical plain-text licence (`cfc7749b...`) before
  the copyright field was filled, and the only edit is the Appendix boilerplate field the Appendix
  itself directs a licensor to fill: `Copyright 2026 Carlos Correia`.
- **`NOTICE`** at the root: the attribution notice Section 4(d) refers to. Minimal. The tree vendors
  no third-party material, so it carries no further attributions.
- **`README.md` §"License / reuse"** is replaced. It leads with the operative fact, states in the
  licence's own section numbers what an adopter may rely on and what the licence asks in return,
  names `LICENSE` as governing where the summary and the licence differ, and **withdraws the
  no-attribution claim as false**. The badge `alt` text is matched to the image.
- **`assets/badges/license.svg`** reads `Apache-2.0` in place of `pending`, geometry and palette
  taken from the badges already in `assets/badges/`.
- **`STANDARD.md` §"The boundary asserts no license"**: the v1.49 note is replaced by three
  paragraphs. The repository's licence. The separation, stated plainly. The pre-v1.53 state kept as
  the record of what this replaced. See the design, Decision 2, for why the separation is the
  load-bearing part.
- **`STANDARD.md`'s closing line**, repaired at v1.49 to say that no licence had been declared, is
  repaired again for the same reason it was repaired then, and now carries both halves in one
  sentence.
- **The v1.53 version row**, the frontmatter title, the H1 and the lead, flipped to v1.53
  drafted-and-unpublished with the published v1.52, v1.51 and v1.50 descriptions preserved word for
  word.
- **No check is added.** See the design, Decision 4.
- Not **BREAKING**. No obligation is added or withdrawn, no schema changes, and no shipped surface
  changes: `LICENSE` and `NOTICE` are repository-root files that no hub installs.

## Capabilities

### New Capabilities

None. See the design, Decision 3. Declaring a licence for one repository is not a rule this standard
imposes on anybody, and writing a delta spec here would mean the standard had begun asserting the
licensing term §"The boundary asserts no license" forbids.

### Modified Capabilities

None.

## Impact

- **Affected material**: `LICENSE` and `NOTICE`, both new; the licence section and the badge `alt` of
  `README.md`; `assets/badges/license.svg`; and in `STANDARD.md` the note in §"The boundary asserts
  no license", the closing line, the frontmatter title, the H1, the lead and the v1.53 row.
- **Affected deployments**: none. No shipped surface changes, no hub file changes, no check changes,
  and nothing a hub or an estate does is different. A deployment that adopts v1.53 gains a licence
  over the standard repository it pinned and gains no obligation of its own.
- **Not in scope**: asserting any licence, price or commercial term on any deployment. That would be
  the thing the editions section forbids, and the boundary, the component mapping and the two
  editions are identical to what v1.39 published.
- **Not in scope**: `rfcs/RFC-006-editions.md`, whose v1.49 status note names the pre-v1.53 licence
  state. It is a dated design record, `rfcs/` is out of the publication-status check's declared
  scope for that reason, and the note reads as of v1.49 rather than as of now. Named here so the
  next maintainer finds it recorded rather than missed. See the design, Open Questions.
- **Not in scope**: touching the leakage guard. See the design, Decision 5.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision,
  and this one cannot be pushed at all until the denylist question in Decision 5 is settled by the
  deployment that owns the denylist.
