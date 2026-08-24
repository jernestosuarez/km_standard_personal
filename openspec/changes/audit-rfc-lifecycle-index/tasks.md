# Tasks

Executed 2026-08-24 on branch `v1.50-rfc-lifecycle-index`, off `main` at `d0482ec` (published v1.49).
Tasks are ordered by dependency: verify every audit claim before repairing anything, build the check
and run it against the unrepaired tree before any repair enters the working tree, repair, prove the
other direction, then record.

Requirement references point at `specs/rfc-lifecycle-index/spec.md` (RLI).

## 1. Verify every claim before repairing

- [x] 1.1 List `rfcs/` and record the set actually present rather than the audit's count.
- [x] 1.2 Read `assets/badges/rfcs.svg` and record its rendered text verbatim; record `README.md`
      line 15's `alt` string.
- [x] 1.3 Confirm there is no `rfcs/README.md` and record what a reader following the nav badge to
      `rfcs/` currently gets.
- [x] 1.4 Record `README.md` line 70 verbatim and note which RFCs it names.
- [x] 1.5 Read each of the seven status banners and record what each declares.
- [x] 1.6 **Test the audit's RFC-002 claim rather than acting on it.** Check for a `v1.23` tag, read
      the v1.23 ledger row, read the lead of `STANDARD.md`, and read the merge commit that published
      v1.22. Record whether `DRAFT` is true. (RLI: a status that is already true is left word for word)
- [x] 1.7 **Test the audit's RFC-005 claim.** Establish when RFC-005 landed and whether its banner
      was corrected then. Record the finding.
- [x] 1.8 Derive the implementation facts for every RFC from the version-history table, quoting the
      clause in each row that states them, and record RFC-007 as a defect the audit does not list.
- [x] 1.9 Record the two ledger rows whose adoption wording an implementation-verb pattern cannot
      match (v1.22 for RFC-001, v1.32 for RFC-004 Part I), so the derivation's lower bound is a
      measured fact rather than a caveat. (RLI: the derived set is a lower bound)
- [x] 1.10 Record the narrowings each implementing version reported, quoting the version row.
- [x] 1.11 Record RFC-004's dated Part I addendum and the decision not to edit it. (RLI: a dated
      addendum is left as the statement of its own day)

## 2. Build the check and run it against the unrepaired tree

- [x] 2.1 Derive the RFC set from `rfcs/`, ignoring any non-RFC file, holding no identifier list.
      (RLI: the document set is derived, never held in the check)
- [x] 2.2 Derive implementation claims from the version-history table by matching an implementation
      verb bound to an RFC reference, and state the lower bound on the passing line. (RLI: the
      implementation facts are derived)
- [x] 2.3 Parse the index table into rows with a fixed status vocabulary, and compare its coverage
      with the directory in both directions. (RLI: the index covers every document)
- [x] 2.4 Judge each banner the ledger contradicts by whether it names the implementing version.
      (RLI: a status the ledger contradicts is reported)
- [x] 2.5 Render the badge from the index and require the committed badge and the README `alt` to be
      equal to it. (RLI: the count is generated and never maintained by hand)
- [x] 2.6 Add the `--write-badge` mode to the same file, so the generator and the validator cannot
      drift apart.
- [x] 2.7 Judge the badge against the ledger-derived count when no index exists, so the arm still
      speaks in the evidence run. (RLI: there is no index to derive the count from)
- [x] 2.8 Fail closed on an unreadable standard, an absent version-history table, an empty table, a
      missing or unlistable `rfcs/`, an empty RFC set, an unparsable index, an unknown status term, a
      missing badge, a badge with no message, and an unreadable README or one that does not reference
      the badge. (RLI: the check refuses rather than passes)
- [x] 2.9 Fail rather than refuse on an absent index, and name every uncovered RFC. (RLI: the index
      is absent)
- [x] 2.10 State coverage on a passing run. (RLI: a passing run states its own coverage)
- [x] 2.11 **Run the check against `main` as it stands, before any repair.** Confirm it exits 1,
      names seven uncovered RFCs, names RFC-004, RFC-006 and RFC-007 with v1.35, v1.39 and v1.41, and
      names the badge with `2 adopted` and the ledger-supported count.
- [x] 2.12 Record that run in the check's own `km-unrepaired-tree:` declaration, naming v1.50 and the
      real result, before any repair enters the working tree.

## 3. Build the index

- [x] 3.1 Write `rfcs/README.md` with the four-term status vocabulary defined in the document itself
      and one row per RFC. (RLI: the design record has an index)
- [x] 3.2 Record decision dates where one exists and leave the cell empty where none does, rather
      than inventing one from a file timestamp.
- [x] 3.3 Record RFC-004 as `PARTIALLY ADOPTED` with the version for each part and the parts not
      implemented.
- [x] 3.4 Record the narrowings, quoted from the implementing versions. (RLI: a design was
      implemented in narrowed form)
- [x] 3.5 Record relationships between RFCs, and state plainly that no RFC supersedes another, rather
      than leaving a supersession column that says nothing.
- [x] 3.6 State in the index how the badge is kept true and which command regenerates it.
- [x] 3.7 Record RFC-002's `DRAFT` with the reason and the evidence, so a reader does not read it as
      the stale status the audit took it for.

## 4. Correct the three false banners

- [x] 4.1 RFC-004: add a dated status note naming v1.32 for Part I and v1.35 for Part II, the three
      narrowings Part I took, the state of Part III, and that the Part I addendum below is dated.
- [x] 4.2 RFC-006: add a dated status note naming v1.39 and the two components it deferred.
- [x] 4.3 RFC-007: add a dated status note naming v1.41 and the narrowing it recorded.
- [x] 4.4 Confirm by diff that no design body, verdict, provenance tag, open question or argument
      changed in any of the three. (RLI: a stale status is corrected by adding a record)
- [x] 4.5 Leave RFC-001, RFC-002, RFC-003 and RFC-005 untouched, and record why in the version row.

## 5. Generate the badge and repair the README

- [x] 5.1 Regenerate `assets/badges/rfcs.svg` from the index with `--write-badge`.
- [x] 5.2 Set the README `alt` text from the same derivation.
- [x] 5.3 Repair `README.md`'s RFC row to route the reader to the index rather than to describe two
      of seven RFCs in prose.

## 6. Graft the rule

- [x] 6.1 Add the generalised rule to the Standard Maintainer section beside its siblings from v1.45,
      v1.46 and v1.48.
- [x] 6.2 Mark it for v1.50 while drafted, per the ritual v1.42 amended.

## 7. Prove both directions

- [x] 7.1 Real-tree case: the repaired repository passes and the passing line states its coverage.
- [x] 7.2 Firing case, coverage: a fixture index missing one row fires and names the RFC.
- [x] 7.3 Firing case, phantom row: a fixture index naming an RFC with no file fires and names it.
- [x] 7.4 Firing case, ledger contradiction: a fixture index recording an implemented RFC as design
      only fires and names the version.
- [x] 7.5 Firing case, phantom version: a fixture index naming an implementing version absent from
      the ledger fires.
- [x] 7.6 Firing case, stale banner: a fixture RFC implemented by a ledger row whose banner names no
      version fires and names both.
- [x] 7.7 Firing case, badge: a fixture badge carrying a count the index does not support fires and
      names both values.
- [x] 7.8 Firing case, `alt` only: a correct badge image with a stale `alt` fires, so the two are
      proved independent.
- [x] 7.9 Firing case, no index: a fixture tree with no index fails, names every RFC, and names the
      badge against the ledger-derived count.
- [x] 7.10 Non-firing case: a fixture satisfying every arm does not fire.
- [x] 7.11 Derivation case: adding an RFC file to a fixture directory flips an unchanged index from
      passing to failing, which is what proves the set is derived rather than held.
- [x] 7.12 Derivation case, ledger: adding an implementing row to a fixture ledger flips an unchanged
      index and banner from passing to failing.
- [x] 7.13 Refusal cases, each asserting exit 2 and a line saying what could not be evaluated:
      unreadable standard, no version-history table, empty table, missing `rfcs/`, empty RFC set,
      unparsable index, unknown status term, missing badge, badge with no message, README not
      referencing the badge.
- [x] 7.14 Round-trip case: `--write-badge` output satisfies the validating arm, so the generator and
      the validator are proved to be one derivation.
- [x] 7.15 **The evidence case:** run the check against the tree at `main` as it stands, read out of
      git rather than reconstructed, asserting the uncovered count, the three banner findings by name
      and version, and the badge finding with both values.
- [x] 7.16 Run the whole suite against the unrepaired tree first and record which cases fail there.

## 8. Record

- [x] 8.1 Write the v1.50 row: F-09 cited, every false statement quoted as it stood, the true
      disposition of all seven RFCs, the three audit claims that did not survive verification, the
      check with both directions and its unrepaired-tree run, and how the badge is kept true.
- [x] 8.2 Name the fork in the row as the reason the class was taken now.
- [x] 8.3 Flip the frontmatter title, the H1 and the lead to v1.50 drafted-unpublished, preserving the
      published v1.49, v1.48 and v1.47 descriptions word for word.
- [x] 8.4 Derive the row's date from this session's own commit rather than from any date supplied to
      it, and confirm it against the commit after committing.
- [x] 8.5 Leave `README.md`'s version line and the version badge on v1.49, as the ritual requires
      while a version is drafted.
- [x] 8.6 State the limits: the ledger derivation is a lower bound, a Notes cell describing a
      narrowing wrongly is reached by no arm, and both directions prove the class modelled and not
      that the right class was modelled.

## 9. Verification

- [x] 9.1 `openspec validate audit-rfc-lifecycle-index --strict` passes.
- [x] 9.2 `tests/test_rfc_lifecycle_index.sh` passes after the repair, and its evidence case failed
      before it.
- [x] 9.3 `python3 scripts/validate_rfc_lifecycle.py` passes with its coverage stated.
- [x] 9.4 `python3 scripts/validate_published_not_draft.py` passes, classifying v1.50 as unpublished
      beside v1.23.
- [x] 9.5 `python3 scripts/validate_rfc_references.py` passes with `rfcs/README.md` in scope.
- [x] 9.6 `python3 tools/km-release-gate.py` exits 0, run after staging so the new files are tracked
      and therefore discovered.
- [x] 9.7 `git diff --check` and `git diff --cached --check` clean.
- [x] 9.8 Leakage: the canonical instrument run over the final tree, both halves, with file counts
      reported.
- [x] 9.9 Stage by explicit path. `KM-STANDARD-AUDIT-2026-08-22.md` stays ignored and out of the
      commit, and `.gitignore` is not touched.
- [x] 9.10 Did not push, did not tag, did not amend any pushed commit, and left `main` untouched.
