# Tasks

Executed 2026-08-24 on branch `v1.48-documentation-truth`, off `main` at `62c4e51` (published v1.47).
Tasks are ordered by dependency: verify before repairing, build the check and run it against the
unrepaired tree before any repair enters the working tree, repair, prove the other direction, then
record.

Requirement references point at `specs/documentation-truth/spec.md` (DT).

## 1. Verify before repairing

- [x] 1.1 Reproduce F-08's first claim: read `template/README.md` and record the summary list and the
      sentence at line 64 verbatim. (DT: the hub template's rule summary enumerates every rule)
- [x] 1.2 Count the standard's rules from its own `### Rule N:` headings rather than from the audit's
      word. Record the six heading lines.
- [x] 1.3 **Verify F-08's second claim first-hand.** Read `template/README.md`'s fact-finding line,
      `template/06_risks-decisions.md`, and `STANDARD.md` §"One instance, one file", and record
      whether the page's model contradicts the standard's.
- [x] 1.4 Record the wider half of 1.3 found by looking: the supporting-structure table omits every
      entity-note folder the template ships. List the folders that exist in `template/`.
- [x] 1.5 **Verify F-11's first half.** Record `STANDARD.md`'s enforcement sentence and the place two
      thousand lines later where the standard already states the narrower, true claim.
- [x] 1.6 **Verify F-11's second half.** Enumerate `template/hub-scan.sh`'s blocks and map each of
      the six rules to the block that checks it or to nothing. Record that Rule 5 maps to nothing and
      that `[ FRONTMATTER ]` reads `type:` alone.
- [x] 1.7 Record the nuance the audit does not mention: `[ SHAPE ]` requires `evidencedBy` on `Claim`
      and `assertion_method` on `RelationshipAssertion`, which is field presence on two optional
      types and is not Rule 5 validation. (DT: a field-presence check is offered as provenance
      validation)
- [x] 1.8 Read `DESIGN-RATIONALE_akcp-component-mining.md` and quote its own admission rather than
      citing the audit's summary of it.
- [x] 1.9 **Verify F-12.** Record `docs/architecture/README.md`'s scope sentence, record exactly how
      `README.md` links the set, and check the ledger for what has been added or materially changed
      since v1.22.
- [x] 1.10 Sweep the tree for rule-count phrases, so the check's scope is a decision rather than an
      assumption. Record every hit and classify each as home of record, dated record, or defect.

## 2. Build the check and run it against the unrepaired tree

- [x] 2.1 Derive the rule set from the standard's own `### Rule N:` headings, holding no rule count,
      list or name in the check's source. (DT: the rule set is derived from the standard and never
      held in the check)
- [x] 2.2 Read the numbered entries under the landing page's governance-rule summary and require one
      per derived rule, naming any rule with no entry. (DT: the hub template's rule summary
      enumerates every rule the standard defines)
- [x] 2.3 Judge every count written immediately before the word "rules" on the landing page against
      the derived count, reading spelled-out numbers and numerals alike. (DT: a rule count written in
      the template's prose agrees with the standard)
- [x] 2.4 Fail closed on an unreadable standard or landing page, on a standard yielding no rule
      heading, on a landing page with no summary section, and on a summary section yielding no entry.
      (DT: the check refuses rather than passes on input it could not evaluate)
- [x] 2.5 State coverage on a passing run: rules derived, entries found, entries matched, count
      phrases judged. (DT: a passing run states its own coverage)
- [x] 2.6 **Run the check against the tree before any repair.** Confirm it exits 1, names rules 5 and
      6 as missing, and names the "all four rules" phrase with both counts.
- [x] 2.7 Confirm the working-tree `template/README.md` is byte-identical to `62c4e51`, so the run in
      2.6 is against published `main` and not a likeness of it.
- [x] 2.8 Record that run in the check's own `km-unrepaired-tree:` declaration, naming v1.48 and the
      real result, before any repair enters the working tree.

## 3. Repair F-08

- [x] 3.1 Extend the governance summary to all six rules, wording each from the standard's own Layer
      2 list, and leave the four existing entries' text as it stands.
- [x] 3.2 Replace the scan sentence with one that names the rules the scan actually checks and the
      rule it does not, so the page does not trade one false count for another. (DT: an enforcement
      claim distinguishes a mechanical control from a procedural one)
- [x] 3.3 Repair the fact-finding line to name the entity notes as the home of an individual fact and
      the numbered documents as the narrative rollups.
- [x] 3.4 Add the entity-note folders to the supporting-structure table. Leave the numbered-document
      table untouched, because it is true.
- [x] 3.5 Confirm by diff that nothing else in the document changed.

## 4. Repair F-11

- [x] 4.1 Narrow the Layer 2 enforcement sentence so it states the rules rather than claiming an
      instrument behind all of them.
- [x] 4.2 Add the paragraph that names which rules the session-start scan checks, which half of Rule
      6 is checked, and that Rule 5 has no instrument, in the same honesty posture the standard takes
      toward agent scope and the scoped reader.
- [x] 4.3 State in that paragraph that Rule 5 binds exactly as the others do and that only the
      enforcement claim is narrowed. (DT: a reader concludes the procedural rule is optional)
- [x] 4.4 Name the `[ SHAPE ]` field-presence cases for what they are rather than as partial Rule 5
      enforcement.
- [x] 4.5 Leave the six-rule list, the Rule 5 section and every other claim in the section word for
      word.

## 5. Repair F-12

- [x] 5.1 Replace the architecture index's scope sentence with a snapshot banner: the version it
      describes, that it is not maintained forward, what has changed since that it does not cover,
      and that `STANDARD.md` is the current normative description. (DT: a document set that no longer
      describes the current system is labelled wherever it is linked)
- [x] 5.2 Correct the index's frontmatter description, which asserts the same thing in the field an
      agent reads.
- [x] 5.3 Label the link in `README.md` where the reader meets it, since a disclaimer behind the link
      is not read by the reader who follows the link.
- [x] 5.4 Leave the document table, the version bridge and the normative-sources list untouched.
- [x] 5.5 Record the decision and its reasoning in the version row, and state that a refresh would
      have ridden unreviewed on a documentation-truth change.

## 6. Graft the rule

- [x] 6.1 Add the generalised rule to the Standard Maintainer section beside its siblings, naming the
      four appearances of the class. (DT: a shipped document asserts only what the system does)
- [x] 6.2 Mark it for v1.48 while drafted, per the ritual v1.42 amended.

## 7. Prove both directions

- [x] 7.1 Real-tree case: the repaired repository passes and the passing line states its coverage.
- [x] 7.2 Firing case, enumeration: a fixture landing page missing a rule fires and names it.
- [x] 7.3 Firing case, count: a fixture landing page carrying every entry and a wrong count phrase
      fires, so the two arms are proved independent of each other.
- [x] 7.4 Non-firing case: a fixture that enumerates every rule and states a correct count does not
      fire. A check that fires on everything proves as little as one that fires on nothing.
- [x] 7.5 Derivation case: a fixture standard with a seventh rule flips the same landing page from
      passing to failing, which is what proves the set is derived rather than held.
- [x] 7.6 Numeral case: a count written as a digit is read and judged like a spelled-out one.
- [x] 7.7 No-count case: a page naming its rules without counting them passes, and the coverage line
      reports that no count was judged rather than passing silently.
- [x] 7.8 Refusal cases, each asserting the refusal status and a line saying what could not be
      evaluated: unreadable standard, unreadable landing page, standard with no rule heading, landing
      page with no summary section, summary section with no entry.
- [x] 7.9 **The evidence case:** run the check against `template/README.md` and `STANDARD.md` as they
      stood at `62c4e51`, read out of git rather than reconstructed, and assert rules 5 and 6 by name
      and the count phrase with both numbers.
- [x] 7.10 Run the whole suite against the unrepaired repository first and record which cases fail
      there, so the suite is known to detect the defect rather than to agree with the repaired tree.

## 8. Record

- [x] 8.1 Write the v1.48 row: each false statement quoted as it stood, each repair, the two claims
      verified first-hand, the F-12 decision with its reasoning, the check with both directions and
      its unrepaired-tree run, and the plain statement that F-11 and F-12 are covered by no
      instrument.
- [x] 8.2 Name the fork in the row as the reason the class was taken now.
- [x] 8.3 Flip the frontmatter title, the H1 and the lead to v1.48 drafted-unpublished, preserving
      the published v1.47, v1.46 and v1.45 descriptions word for word.
- [x] 8.4 Derive the row's date from this session's own publishing work rather than from any date
      supplied to it, and confirm it against the commit after committing.
- [x] 8.5 Leave `README.md`'s version line and the version badge on v1.47, as the ritual requires
      while a version is drafted.
- [x] 8.6 State the limits: the check models the template's rule summary and nothing else, and
      neither F-11 nor F-12 is reached by any instrument.

## 9. Verification

- [x] 9.1 `openspec validate audit-documentation-truth --strict` passes.
- [x] 9.2 `tests/test_template_rule_summary.sh` passes after the repair, and its evidence case failed
      before it.
- [x] 9.3 `python3 scripts/validate_template_rule_summary.py` passes with its coverage stated.
- [x] 9.4 `python3 scripts/validate_published_not_draft.py` passes, classifying v1.48 as unpublished
      beside v1.23.
- [x] 9.5 `python3 tools/km-release-gate.py` passes, per step 5 of the ritual: 28 checks
      discovered, 24 run, 4 skipped as instruments covered by their canaries, 29 unrepaired-tree
      declarations read, 2 check files reported as added against `origin/main`. Run twice: the
      first run discovered 26 checks because the gate walks the **tracked** tree and the two new
      files were still untracked, so it was rerun after staging. A gate that has not seen a check
      has not run it, whatever its verdict says.
- [x] 9.6 `git diff --check` and `git diff --cached --check` clean.
- [x] 9.7 Leakage: every added line and every new file was scanned against the deployment overlay's
      generated denylist (762 entries, generated 2026-08-23), whole-word, case-insensitive for the
      750 CI entries and case-sensitive for the 10 CS entries. No match. This is not the pre-push
      hook, which is the only thing that scans an actual push, and the denylist is a generated
      artifact that may be stale against the semantic layer as of today.
- [x] 9.8 Stage by explicit path. Preserve the pre-existing `.gitignore` modification and leave
      `openspec/` untracked.
- [x] 9.9 Did not push, did not tag, did not amend any pushed commit, and left `main` untouched.
      Publication is the owner's decision.
