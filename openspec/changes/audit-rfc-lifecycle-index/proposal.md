## Why

This repository is about to be forked and handed to an external party. A fork carries the design
record to readers who cannot ask anyone which proposals are live, which have been implemented, and
which bind nothing. Today the repository answers that question three times and gets it wrong twice,
and it offers no single place where the answer is written down at all. This is audit finding
**F-09**, and it is the same class as v1.45, v1.47 and v1.48: a document that misdescribes the
system.

Every claim below was verified against the tree and the version ledger rather than taken from the
audit's list, and the verification changed the finding in three places.

- **The badge is false.** `assets/badges/rfcs.svg` renders `2 adopted` and `README.md` line 15
  carries the same string as the image's `alt` text. `rfcs/` holds seven RFCs. The version ledger
  records three of them as implemented in its own words, and a fourth as adopted in its banner, so
  no reading of "adopted" yields two.
- **There is no index.** `rfcs/` holds seven `RFC-*.md` files and no `README.md`. The README's own
  nav badge links a reader to `rfcs/`, where a directory listing is all that greets them.
- **The README's description names two of seven.** `README.md` line 70 describes RFC-001 and
  RFC-002 and stops, so RFC-003 through RFC-007 are invisible to a reader of the package overview.
- **RFC-004's banner is false.** It reads *"Status: DRAFT — design document only. As with RFC-003,
  no normative edits ride this RFC"* while v1.32 implemented Part I in a narrowed form and v1.35
  implemented Part II.
- **RFC-006's banner is false.** It reads *"no normative edits ride this RFC"* while v1.39
  implemented the editions model, and the v1.39 ledger row says so in the word "implementing".
- **RFC-007's banner is false**, on the same wording, while v1.41 implemented the Reader tier.

Three of the audit's own statements about F-09 do not survive verification, and this change records
each rather than repairing a defect that is not there.

- **RFC-002's `DRAFT` is true, and the audit's pairing of it with the badge is wrong.** v1.23 has
  never published. There is no `v1.23` tag, the ledger row for v1.23 opens `**DRAFT — awaiting owner
  push.**`, the lead of `STANDARD.md` states that v1.23 remains drafted and unpublished, and the
  merge commit that published v1.22 records that v1.23 rides as draft. RFC-002's banner is correct
  and is left word for word.
- **RFC-005 is not absent, and its banner is not stale.** It landed on the published branch under
  v1.45 as design only, and that version already corrected its banner to name the versions that had
  implemented its siblings. The audit was written before that landing.
- **The audit does not mention RFC-007**, whose banner carries the identical false sentence. It is
  repaired here.

## What Changes

- **`rfcs/README.md` is added**: the index, one row per RFC, carrying identifier, title, status,
  decision date where one exists, the version or versions that implemented it, relationships to
  other RFCs, and the narrowing where a design was implemented in narrowed form. It is the document
  a forker reads to learn what the design record says.
- **Three status banners are corrected**, and only their status. RFC-004, RFC-006 and RFC-007 each
  gain a dated status note recording what has published since they were drafted. **No design body,
  verdict, provenance tag or argument is rewritten**, on the v1.45 rule that correcting a dated
  record to agree with the present falsifies it. Where a design was implemented in narrowed form the
  note names the narrowing, quoting what the implementing version itself recorded.
- **RFC-001, RFC-002, RFC-003 and RFC-005 are not edited.** Each states its true disposition already.
- **The badge is generated from the index**, by the same file that validates it, and reads
  `3 adopted, 1 partial, 3 open`. The README `alt` text is generated with it and matches.
- **`README.md`'s RFC description is repaired** to route the reader to the index rather than to
  describe two of seven RFCs in prose that goes stale on the next adoption.
- **A check is added**, `scripts/validate_rfc_lifecycle.py`, with canaries in
  `tests/test_rfc_lifecycle_index.sh`. It derives the RFC set from the directory, the implementation
  facts from the version-history table, and the badge count from the index. It holds no list.
- **The rule is grafted** into the Standard Maintainer section beside its siblings from v1.45,
  v1.46 and v1.48.
- Not **BREAKING**. No obligation on a hub changes, no schema changes, and no file a deployment
  installs is touched.

## Capabilities

### New Capabilities

- `rfc-lifecycle-index`: what a design record must state about its own disposition, where the
  disposition of the whole set is recorded, how a count of it is kept true, and how a status
  correction differs from a rewrite of a dated record.

### Modified Capabilities

None.

## Impact

- **Affected material**: `rfcs/README.md` (new); the status banners of
  `rfcs/RFC-004-harness-projection-hub-merge-multi-tenancy.md`, `rfcs/RFC-006-editions.md` and
  `rfcs/RFC-007-reader-tier.md`; `assets/badges/rfcs.svg`; the badge `alt` text and the RFC row of
  `README.md`; `scripts/validate_rfc_lifecycle.py` (new); `tests/test_rfc_lifecycle_index.sh` (new);
  the Standard Maintainer section, the frontmatter title, the H1, the lead and the v1.50 row of
  `STANDARD.md`.
- **Affected deployments**: none. No shipped template, skill, component or scaffold changes, so no
  hub turns red and no hub has anything to adopt beyond the version pin itself.
- **Not in scope**: editing any RFC's design, verdicts, provenance tags, open questions or
  arguments. Only status is touched, and only where status is false.
- **Not in scope**: publishing v1.23, or changing RFC-002's status in either direction. Its draft
  state is a decision the owner has not made, and this change does not make it for him.
- **Not in scope**: refreshing the dated Part I status addendum inside RFC-004, which describes
  v1.32's state on 2026-08-20 and was true on that day.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's
  decision.
