# Tasks

Executed 2026-08-23 on branch `v1.44-compound-value-validation`, off `main` at `cac984e` (published
v1.43). Tasks are ordered by dependency: reproduce before repairing, write the canaries before the
repair so they can be run against the unrepaired scan, repair, prove, re-verify the sweep, then
record.

Requirement references point at `specs/compound-value-validation/spec.md` (CVV).

## 1. Reproduce before acting

- [x] 1.1 Build a fixture hub from `template/` on the unrepaired tree with
      `routing-keywords: ", ,"`, commit it, and run its scan. (CVV: a declared keyword list is
      validated token by token)
- [x] 1.2 Record the output: the `[ DEPLOYMENT ]` block, the final verdict line, and the exit status.
      A reproduction that is not recorded is a claim.
- [x] 1.3 Confirm the value falls through every arm rather than being caught and downgraded, by
      reading the `case` and by the absence of any keyword line in the block.
- [x] 1.4 Confirm the `{{` arm does catch a placeholder in a non-leading position, so the finding is
      the empty-entry half of the class and not both halves.
- [x] 1.5 Confirm the consuming side drops empty tokens silently, so the green scan and the empty
      attribution are one story rather than two.

## 2. Write the canaries before the repair

- [x] 2.1 Add the firing case for an all-empty-token value, beside the existing `routing-keywords`
      cases. (CVV: the value is a delimiter and whitespace only)
- [x] 2.2 Add the firing case for a lone delimiter that leaves no real keyword. (CVV: the value has a
      leading or trailing delimiter and nothing else)
- [x] 2.3 Add the non-firing case for a legitimate multi-keyword value, asserting the deployment
      block's own OK line and exit 0. (CVV: the value is a legitimate multi-keyword list)
- [x] 2.4 Add the non-firing case for a legitimate single keyword with no delimiter. (CVV: the value
      is a single legitimate keyword)
- [x] 2.5 **Run all four against the unrepaired scan.** Confirm the two firing cases fail there. A
      canary that passes against the defect proves nothing. (CVV: the canaries run against the
      unrepaired scan)
- [x] 2.6 Record which of the four pass against the unrepaired scan and why that is the expected
      result for a non-firing case.

## 3. Repair the gate

- [x] 3.1 Split `routing-keywords` on the comma by hand, so an empty entry survives as a token rather
      than being absorbed into its neighbour or dropped off the end. (CVV: a check that reads a
      compound value validates its parts)
- [x] 3.2 Trim each token and require at least one carrying an alphanumeric character. Name the empty
      entries when there are any.
- [x] 3.3 Keep the empty arm and its exact message, which a v1.28 canary asserts.
- [x] 3.4 Keep the placeholder arm as a substring test, correct for a compound value already.
- [x] 3.5 Keep the whole gate behind the interview-date check. (CVV: the keyword gate stays behind the
      interview gate)
- [x] 3.6 Preserve the block's stated limit in substance: this proves the field was filled in, never
      that the keywords are the right ones. Do not widen the check into judging quality. (CVV: the
      keyword gate proves the field was filled in)

## 4. Prove both directions

- [x] 4.1 The two firing cases now fire and the scan exits 1. (CVV: the negative direction is proved)
- [x] 4.2 The two non-firing cases stay green. (CVV: the positive direction is proved)
- [x] 4.3 The v1.28 empty and placeholder canaries still pass, unmodified.
- [x] 4.4 The uninterviewed canary still shows the keyword error withheld.
- [x] 4.5 Confirm the four new cases fail against the unrepaired scan and pass against the repaired
      one, so the pair of runs is the evidence and neither run alone is.

## 5. Re-verify the sweep

- [x] 5.1 Enumerate every check the repository ships, not only the ones named in the finding.
- [x] 5.2 For each, identify the values it validates and classify each as compound or scalar.
- [x] 5.3 For each compound value, confirm the check validates per part or record it as a third
      instance. Do not carry the prior session's conclusion forward unchecked. (CVV: the class is
      swept across the shipped checks)
- [x] 5.4 Record the identity-comparison case explicitly, so a later reader does not mistake it for a
      missed instance.
- [x] 5.5 Record the conclusion with its scope and the revision it was run against.

## 6. Record

- [x] 6.1 Graft the generalised rule into the section that already states its two siblings. Do not
      create a new top-level section to avoid understanding the structure.
- [x] 6.2 Carry both demonstrations with the rule. (CVV: the rule is stated with the demonstrations
      that earned it)
- [x] 6.3 State the cost: per-token validation is stricter and can reject a sloppy but well-intentioned
      declaration.
- [x] 6.4 Record the sweep beside the rule.
- [x] 6.5 Mark the new material for v1.44 while it is drafted, per the ritual v1.42 amended.
- [x] 6.6 Write the v1.44 version row: cite D6, name the generalised rule, name both demonstrations.
- [x] 6.7 Flip the header and the lead to v1.44 drafted-unpublished, preserving the published v1.43,
      v1.42 and v1.41 descriptions word for word.

## 7. Verification

- [x] 7.1 `openspec validate audit-compound-value-validation --strict` passes.
- [x] 7.2 The deployment binding suite passes with the four new cases.
- [x] 7.3 Full suite green, including `tests/test_hub_scan_canaries.sh`.
- [x] 7.4 `python3 scripts/validate_published_not_draft.py` passes, per step 4 of the ritual.
- [x] 7.5 `git diff --check` clean.
- [ ] 7.6 Leakage guard: not run here. It is the steward tier's to run.
- [x] 7.7 Stage by explicit path. Preserve the pre-existing `.gitignore` modification.
- [x] 7.8 Did not push, did not tag, did not merge. Publication is the owner's decision.
