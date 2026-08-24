# Tasks

Executed 2026-08-24 on branch `v1.45-rfc-reference-integrity`, off `main` at `c3e4ffe` (published
v1.44). Tasks are ordered by dependency: reproduce before repairing, build the check and prove it
against the unrepaired tree before landing the document, land, prove the other direction, sweep, then
record.

Requirement references point at `specs/rfc-reference-integrity/spec.md` (RRI).

## 1. Reproduce before acting

- [x] 1.1 Enumerate every RFC identifier in every tracked file and classify each as resolving or
      dangling against the contents of `rfcs/`. (RRI: published text names only documents a reader
      can open)
- [x] 1.2 Record the nine dangling references with their files and lines: `STANDARD.md` 3962 and
      4213, `rfcs/RFC-006-editions.md` 11, 27, 172 and 341, `rfcs/RFC-007-reader-tier.md` 11, 25 and
      332. A reproduction that is not recorded is a claim.
- [x] 1.3 Confirm the document exists only on `rfc-005-routines` at `086da08`, and that the branch's
      single commit adds the file and nothing else, so a file-level landing is available and a merge
      is not required.
- [x] 1.4 Confirm the written form is a code-formatted path rather than a Markdown link, which is why
      a hyperlink walk reported the tree clean. (RRI: the check reads the written forms a hyperlink
      walk misses)
- [x] 1.5 Read the drafting report's flag and the acknowledgement that followed it, so the version row
      records what actually happened rather than a reconstruction of it.

## 2. Read the document before landing it

- [x] 2.1 Read `rfcs/RFC-005-routines.md` in full and confirm it is coherent: six parts, verdicts
      table, provenance tags on every design statement, and its own list of what it must not do.
- [x] 2.2 Confirm it is design only: it claims no version, adds no version-history row, and names no
      normative change, in its banner and in its closing summary. (RRI: a design document may land on
      the published branch ahead of its implementation)
- [x] 2.3 Confirm it is leakage-safe: no organization or unit name, no person, no client or
      initiative, no email, no URL, no local path. Every deployment-shaped detail is genericised, and
      the document names what was too specific to generalise. The leakage guard itself is the steward
      tier's to run.
- [x] 2.4 Confirm the banner has gone stale relative to what has published since: RFC-004 Parts I and
      II by v1.32 and v1.35, RFC-006 by v1.39, RFC-007 by v1.41. (RRI: a landing design document
      states its true status on the day it lands)

## 3. Build the check and prove it against the unrepaired tree

- [x] 3.1 Derive the existing set from the `rfcs/` directory, one identifier per filename, holding no
      list of identifiers in the check. (RRI: the existing document set is derived from the directory)
- [x] 3.2 Match the bare identifier, the code-formatted path with no filename, and the path naming a
      file, and judge a path on whether its file exists rather than on the number inside it. (RRI:
      the check reads the written forms a hyperlink walk misses)
- [x] 3.3 Fail closed on an absent or unlistable directory, a directory yielding no document, a scan
      that parsed nothing, an undecodable file, an exemption with no reason, and a scope in which
      everything is exempt. (RRI: the check refuses rather than passes on input it could not evaluate)
- [x] 3.4 State coverage on a passing run: references found, distinct identifiers, files scanned,
      path forms resolved, files exempt with reasons, documents present. (RRI: a passing run states
      its own coverage)
- [x] 3.5 **Run the check against the tree before the document lands.** Confirm it exits 1 and names
      all nine references at their exact lines. (RRI: the run against the pre-repair published tree)

## 4. Land the document

- [x] 4.1 Take `rfcs/RFC-005-routines.md` from `rfc-005-routines` at `086da08` and confirm it is
      byte-identical to the branch copy before any edit.
- [x] 4.2 Correct the status banner: state the landing, its terms, and which siblings have since been
      implemented while this one has not. Change nothing else in the document. (RRI: a landing design
      document states its true status)
- [x] 4.3 Confirm no normative text changed as a consequence: no section, schema, template, skill,
      scan, component or contract is touched. (RRI: a design document may land ahead of its
      implementation)
- [x] 4.4 Re-run the check and confirm the tree now passes with its coverage stated.

## 5. Prove both directions

- [x] 5.1 Firing case per written form: a bare identifier in prose, a code-formatted path, a
      version-ledger row, and a path naming an absent file. (RRI: the check reads the written forms)
- [x] 5.2 Non-firing case: a tree in which every reference resolves, in all three forms. A check that
      fires on everything proves as little as one that fires on nothing. (RRI: the negative direction)
- [x] 5.3 Derivation case, run twice on byte-identical text: landing the file flips the verdict from
      dangling to resolved, and removing it flips it back. (RRI: the existing set is derived from the
      directory)
- [x] 5.4 Six refusal cases, each asserting the refusal status and a refusal line that says what could
      not be evaluated. (RRI: the check refuses rather than passes)
- [x] 5.5 Boundary case: text carrying `rfcs/`, `xRFC-101` and a bare `RFC` yields no reference and
      therefore **refuses**, proving the boundary holds and that an unmatched surface does not pass.
- [x] 5.6 The evidence case: run the whole check against published `main` at `c3e4ffe` through
      `git archive`, assert the count of references named rather than a bare non-zero exit, and assert
      that only RFC-005 is reported so the failure is selective. (RRI: the run against the pre-repair
      published tree)
- [x] 5.7 Report an unresolvable pre-repair commit as a coverage gap rather than folding it into a
      pass. (RRI: the pre-repair commit is unavailable in a clone)
- [x] 5.8 Neuter the matcher deliberately and confirm the suite fails, so a check that has stopped
      firing is known to be detected. Ten cases failed; the matcher was restored and the suite
      re-run green.
- [x] 5.9 Record the one refusal branch no fixture reaches, rather than counting it among the proved
      ones.

## 6. Sweep every other RFC cross-reference

- [x] 6.1 Enumerate every RFC identifier in `STANDARD.md` and record which documents it names.
- [x] 6.2 Enumerate every RFC identifier inside the RFCs themselves, which is where a dependency
      section names another design document.
- [x] 6.3 Enumerate the remaining references across the repository: the README, the architecture
      docs, the initiation skill and the merge canaries.
- [x] 6.4 Confirm every path-form reference resolves to a file that exists, not merely to an
      identifier that exists.
- [x] 6.5 Record the finding, including that it is a finding of none beyond RFC-005.

## 7. Record

- [x] 7.1 Graft the rule into the Standard Maintainer section beside the instrument rules it is a
      sibling of. Do not create a new top-level section to avoid understanding the structure.
- [x] 7.2 Name the maintainer error plainly: the version published with the reference while its own
      drafting report flagged the document as unmerged, and the flag was acknowledged and not acted
      on. (RRI: a drafting report flags an unlanded dependency)
- [x] 7.3 State that landing a design document is not adopting it, and that a stale banner is
      corrected in status only.
- [x] 7.4 State the limit: the check models openability and reaches neither mischaracterisation nor
      the citation nobody wrote.
- [x] 7.5 Mark the new material for v1.45 while it is drafted, per the ritual v1.42 amended.
- [x] 7.6 Write the v1.45 version row: cite F-04, name the error, record the check and the sweep.
- [x] 7.7 Flip the header and the lead to v1.45 drafted-unpublished, preserving the published v1.44,
      v1.43 and v1.42 descriptions word for word.

## 8. Verification

- [x] 8.1 `openspec validate audit-rfc-reference-integrity --strict` passes.
- [x] 8.2 `tests/test_rfc_reference_integrity.sh` passes, and fails against a neutered matcher.
- [x] 8.3 Full suite green, including `tests/test_hub_scan_canaries.sh` and `tests/test_hub_merge.sh`.
- [x] 8.4 `python3 scripts/validate_published_not_draft.py` passes, per step 4 of the ritual,
      classifying v1.45 as unpublished beside v1.23.
- [x] 8.5 `python3 scripts/validate_rfc_references.py` passes against the repaired tree.
- [x] 8.6 `git diff --check` clean.
- [ ] 8.7 Leakage guard: not run here. It is the steward tier's to run.
- [x] 8.8 Stage by explicit path. Preserve the pre-existing `.gitignore` modification.
- [x] 8.9 Did not push, did not tag, did not merge, and left `main` and `rfc-005-routines` untouched.
      Publication is the owner's decision.
