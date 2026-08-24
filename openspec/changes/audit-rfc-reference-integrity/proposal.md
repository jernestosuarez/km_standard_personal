## Why

Published `main` at `c3e4ffe` cites `rfcs/RFC-005` in `STANDARD.md` twice, and `rfcs/` on `main`
carries RFC-001, 002, 003, 004, 006 and 007. RFC-005 exists only on the unmerged local branch
`rfc-005-routines` at `086da08`, so the published standard names a design document a reader cannot
open, and RFC-006 and RFC-007 both rest on it: nine dangling identifiers across three files.

This is the maintainer's own error and is recorded as one. v1.39 published carrying those references
while the drafting agent's report explicitly flagged that RFC-005 sat unmerged; the flag was
acknowledged and not acted on. The reference then escaped every check the repository ships because it
is written as a code-formatted path rather than a Markdown link, so nothing that walks hyperlinks ever
saw it. This is audit finding **F-04**.

## What Changes

- The RFC-005 design document lands on `main` from `rfc-005-routines` at `086da08`, **as design only**.
  It binds nothing, claims no version, adds no version-history row, and changes no normative text. This
  is the route RFC-004 took to `main` ahead of the version implementing it.
- Its status banner is corrected to state its true status on the day it lands: still design only and
  still unimplemented, while the two siblings it is named beside have since been implemented, RFC-006
  by v1.39 and RFC-007 by v1.41. The design itself is not rewritten.
- A new check, `scripts/validate_rfc_references.py`, extracts RFC identifiers from prose,
  version-ledger rows and RFC dependency sections rather than from Markdown hyperlinks alone, and
  fails when an identifier names a document that does not exist in `rfcs/`.
- The check derives the existing RFC set from the `rfcs/` directory rather than from a list held in
  the check, so it keeps working as RFCs are added and needs no edit when they are.
- It catches the code-formatted forms the existing hyperlink walk misses: a bare `RFC-005`, a
  backticked path `rfcs/RFC-005`, and a path naming a file that is not there.
- It fails closed rather than passing when it cannot read `rfcs/`, when the directory yields no RFC,
  when no file was scanned, when nothing parsed, or when a scanned file cannot be decoded.
- It states its coverage on a passing run: identifiers found, files scanned, and RFCs present.
- `tests/test_rfc_reference_integrity.sh` proves both directions and runs the check against `main` as
  it stood before this change, where it names the real RFC-005 references.
- A generalised rule is stated in `STANDARD.md` beside the instrument rules it is a sibling of: a
  reference in published text is a promise the reader can open the thing named.
- The v1.45 version row cites F-04, names the maintainer error plainly, and records the new check.
- Not **BREAKING**. No deployment surface changes, no hub changes, no schema changes.

## Capabilities

### New Capabilities

- `rfc-reference-integrity`: what a reference to a design document obliges of the text that makes it,
  how the set of existing documents is derived, which written forms a reference check must catch, when
  it must refuse rather than pass, what it must state on a passing run, and on what terms a design
  document lands on the published branch ahead of the version implementing it.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: `rfcs/RFC-005-routines.md`, which lands and gains a corrected status banner;
  `scripts/validate_rfc_references.py`, the new check; `tests/test_rfc_reference_integrity.sh`, its
  canaries; and the Standard Maintainer section and version ledger of `STANDARD.md`.
- **Affected deployments**: none. No shipped skill, template, scan, component or contract changes, so
  no hub inherits anything from this version and no deployment has an adoption act to perform.
- **Not in scope**: implementing RFC-005. The document lands as design and the routines remain
  unimplemented; a version that implements them is a separate change with its own authority.
- **Not in scope**: the stale status banners of RFC-006 and RFC-007, which name themselves as design
  only although v1.39 and v1.41 implement them. That is audit finding F-09 and is a separate change;
  correcting them here would widen a reference-integrity repair into an RFC lifecycle repair.
- **Not in scope**: validating that a resolvable reference is a reference to the right document. The
  check proves the document is openable, never that the citing text characterises it correctly.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
