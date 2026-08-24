## Why

The version-history table of `STANDARD.md` is this repository's only publication record, and two of
its rows state a date that never happened.

`| v1.40 | 2026-08-22 |` and its stamp "Drafted and published 2026-08-22 (owner push)" are both
false. Every v1.40 event was on 2026-08-23: the draft commit `64015a6` at `13:15:23 +0200`, the
publish commit `9c14f85` at `13:32:21 +0200`, and the overlay re-pin that adopted it at
`13:37:57 +0200`. The staging brief carried the previous day's date, the work ran past
midnight, and nobody re-derived the date from the tree.

`| v1.33 | 2026-08-20 |` is false in the same column for the opposite reason. Its publish commit
`16109ea` is `2026-08-21 00:24:40 +0200`, its own stamp already says "published 2026-08-21", and its
commit subject and tag both read 2026-08-21. The publishing commit derived the stamp correctly and
left the date column at the draft date, so the ritual was applied to half the row and the row now
contradicts itself in published text.

A false date in a version-history row is a false statement in published text, which is the class
v1.42 and v1.45 already repaired in two other forms. Nothing in this repository has ever compared a
row's date against the commit that published it.

## What Changes

- The v1.40 row's date column and stamp are corrected to 2026-08-23. Every other word in the row is
  unchanged.
- The v1.33 row's date column is corrected to 2026-08-21. Its stamp is already correct and is left
  as it is, and every other word in the row is unchanged.
- **The v1.40 publish commit subject and the annotated tag `v1.40` are deliberately not rewritten.**
  Both carry `owner push 2026-08-22` and both are pushed public history. The v1.47 row records that
  the discrepancy is intended, names the ledger as the corrected record of account, and says why
  erasing it would be a worse remedy than documenting it. v1.33 needs no such note, because its
  subject and tag already read 2026-08-21, and the v1.47 row says that too rather than leaving a
  reader to wonder why one version got a note and the other did not.
- A new check, `scripts/validate_ledger_dates.py`, compares every version-history row's date column
  against the author date of the commit that published that version.
- The mapping from version to publish commit is derived from the repository, never held in the check:
  an annotated tag where one exists, a search of commit subjects where one does not, and the method
  that resolved each version is reported.
- A version the ledger records as still drafted is an explicit exclusion rather than a gap, because a
  drafted version has no publish commit by construction.
- A version with no resolvable publish commit is a stated coverage gap, reported on every run and
  never folded into the verdict. The ledger reaches back to v1.0 and tags only reach v1.22, so the
  gap is structural.
- The check refuses rather than passes on an unreadable ledger, a missing or empty table, an
  unparsable row, an unusable git, or an empty resolution set.
- `tests/test_ledger_dates.sh` proves both directions and runs the check against `main` at `a2756e2`
  before the correction, where it names v1.40 and v1.33 with all four dates.
- The publish ritual in `STANDARD.md` and the drafting contract in `agents/km-hub-builder/SKILL.md`
  are amended: the publication date is derived from the publishing commit at publish time and is
  never carried in from a brief or copied from a prior field.
- The v1.47 version row states the defect, the correction, the deliberate non-rewriting, the new
  check, and the full sweep of all 47 rows, so the next maintainer inherits the measurement.
- Not **BREAKING**. No deployment surface changes, no hub changes, no schema changes.

## Capabilities

### New Capabilities

- `ledger-date-integrity`: what a version-history row's date column asserts, how the commit that
  published a version is resolved from the repository, which timezone the comparison is made in, how
  a drafted version and an unresolvable version differ, when the check refuses rather than returns a
  verdict, what a passing run states, and on what terms a false date in published text is corrected
  in the ledger while the pushed commit and tag that carry it are left alone.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: the v1.40 and v1.33 rows, the publish ritual and the Standard Maintainer
  section of `STANDARD.md`; `agents/km-hub-builder/SKILL.md`; the new check
  `scripts/validate_ledger_dates.py`; and its canaries `tests/test_ledger_dates.sh`.
- **Affected deployments**: none. No shipped skill, template, scan, component or contract changes, so
  no hub inherits anything from this version and no deployment has an adoption act to perform.
- **Not in scope**: rewriting the v1.40 publish commit or its tag. See the design.
- **Not in scope**: the stamp prose of any row other than v1.40's. A stamp is a sentence a maintainer
  wrote and the check reads the date column, so widening the check to parse stamps would make it a
  prose validator with a much larger false-positive surface.
- **Not in scope**: the twenty versions with no resolvable publish commit. They are reported as a
  coverage gap and are not reconstructed here, because reconstructing a publication act from a tree
  that never recorded one is the same failure as carrying a date in from a brief.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
