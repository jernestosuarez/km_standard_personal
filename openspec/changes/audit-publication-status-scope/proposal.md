## Why

Two checks read publication status out of the version-history table of `STANDARD.md`, and both of
them ask the wrong question of a row. `scripts/validate_published_not_draft.py` and
`scripts/validate_ledger_dates.py` each carry the same pattern, byte for byte:

```python
DRAFT_ROW = re.compile(r"\*\*DRAFT\b|\bDRAFT\s*[—–-]\s*awaiting owner push")
```

and each applies it with `search`, over the whole of the row. The docstring of
`validate_published_not_draft.py` says something narrower and correct: a row is unpublished when its
description "opens with an explicit draft declaration". The prose describes the class; the code
matches the token anywhere.

**The consequence was measured during the v1.50 publish, and it is reproduced here.** The v1.50 row
argued that RFC-002's `DRAFT` banner was true, and it evidenced that by reproducing the v1.23 row's
own declaration verbatim inside its description. Once the row's opener was flipped from the draft
declaration to `Drafted and published 2026-08-24 (owner push).`, the quotation was still sitting in
the middle of the description, and both instruments went on reading v1.50 as unpublished:

- `validate_ledger_dates.py` reported `2 excluded as drafted, v1.23, v1.50` and therefore never
  compared v1.50's date column against its publish commit;
- `validate_published_not_draft.py` reported `49 published, 2 unpublished` and therefore exempted
  every draft marking naming v1.50 from judgement, which is the arm that catches a publish commit
  that failed to clear its own markings.

Both returned PASS. Two checks, both green, both blind, over an incomplete publication, because the
document quoted a phrase. The published v1.50 row on `main` today paraphrases that quotation away,
so the current tree passes: the defect was worked around at publication time rather than repaired,
and the workaround is not available to a fork.

The class matters beyond the incident. Quoting a defect verbatim is what this repository's
remediation prose does constantly, in version rows, in check docstrings and in canary fixtures. A
status classifier that reads a token wherever it appears is disarmed by house practice, silently, and
a forker inherits the disarming with the checks.

## What Changes

- **The rule becomes anchored.** A version-history row is unpublished when its **description cell**
  opens with a draft declaration: optional leading whitespace, an optional emphasis marker, then the
  literal token `DRAFT`. A draft declaration appearing anywhere else in the description is quoted
  text and carries no status.
- **The rule gets one home.** `scripts/publication_status.py` is added as the single classifier both
  instruments import: it locates a version-history row, splits it into version, date and description,
  and answers whether the description opens with a draft declaration. Neither instrument keeps a
  pattern of its own. The two copies that exist today are already identical and already drifting
  toward a second anchoring rule each, which is the artifact class this standard records as the one
  that rots.
- **`validate_published_not_draft.py` starts reading the description cell.** It previously passed
  everything after the version cell, including the date column, to the pattern, so an anchored rule
  applied to that string would never have matched anything. Row splitting moves into the shared
  classifier so both instruments cut the row the same way.
- **Both instruments re-state their `km-unrepaired-tree` declarations** with what the repaired code
  found against the unrepaired tree, as the v1.46 gate requires of a check a change edits.
- **`tests/test_publication_status_scope.sh`** proves the shared classifier directly, in both
  directions, over the real opener forms and over a published row that quotes a declaration.
- **`tests/test_published_not_draft.sh` and `tests/test_ledger_dates.sh`** each gain a pair of cases
  proving the end-to-end verdict flips for the published-row-quoting-a-token case and does not flip
  for a genuinely drafted row, plus a case run against the tree at the v1.50 draft commit `1444b15`.
- **`STANDARD.md`** gains the v1.52 row and one obligation under §"Standard Maintainer", beside its
  v1.29, v1.30 and v1.44 siblings: a status token is read where a status is declared, not wherever it
  appears.
- Not **BREAKING**. No deployment surface changes, no hub changes, no schema changes.

## Capabilities

### New Capabilities

- `publication-status-classification`: where a version's publication status is declared, what counts
  as a declaration and what counts as a quotation of one, why the rule is anchored to the opening of
  the description cell, why one classifier serves every instrument that reads publication status,
  what such an instrument must refuse, and what it must state about its own coverage.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: `scripts/publication_status.py` (new), `scripts/validate_published_not_draft.py`,
  `scripts/validate_ledger_dates.py`, `tests/test_publication_status_scope.sh` (new),
  `tests/test_published_not_draft.sh`, `tests/test_ledger_dates.sh`, and `STANDARD.md`.
- **Affected deployments**: none. No shipped skill, template, scan, component or contract changes, so
  no hub inherits anything from this version and no deployment has an adoption act to perform.
- **Not in scope**: whether the version-history table is honest. It is the only publication record
  the repository has, and neither instrument can audit its own oracle. This change moves the question
  a check asks of a row; it does not give the check a second source.
- **Not in scope**: the stamp inside a row's prose. `validate_ledger_dates.py` deliberately reads the
  date column alone, and that limit is unchanged here.
- **Not in scope**: retro-fitting the paraphrase in the published v1.50 row. The row published as it
  stands, a dated record is not rewritten to agree with the present, and the v1.52 row records what
  the paraphrase was working around.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
