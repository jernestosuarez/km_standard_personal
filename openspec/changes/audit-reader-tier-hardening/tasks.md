# Tasks

Executed on branch `v1.41-reader-tier` on 2026-08-23, except 7.2, which is the steward's to run.
Tasks are ordered by dependency: reproduce, then repair, then prove
the repair detects what it was written for, then verify the whole surface.

Requirement references point at `specs/reader-scope-enforcement/spec.md` (RSE) and
`specs/reader-distribution-metadata/spec.md` (RDM).

## 1. Reproduce before repairing

- [x] 1.1 Reproduce the bypass on the current scanner and record the exact output: a scope of
      `*, hub-alpha` reports a closed scope of two hubs. (RSE: tokens validated independently)
- [x] 1.2 Reproduce the delimiter defect: a scope of `hub-alpha,` yields a hub whose name carries the
      delimiter. (RSE: malformed entries rejected)
- [x] 1.3 Commit the reproductions as failing canaries first, so the suite is red before any fix and
      the fix is what turns it green.

## 2. Repair the scope parser

- [x] 2.1 Split the declared scope on its delimiter and validate each token independently. (RSE:
      tokens validated independently)
- [x] 2.2 Reject an open token (`*`, `all`) in any position, naming the offending token. (RSE: tokens
      validated independently)
- [x] 2.3 Reject empty entries from a leading, trailing, or repeated delimiter, and never absorb an
      empty entry into an adjacent token. (RSE: malformed entries rejected)
- [x] 2.4 Reject a duplicate token, naming it. (RSE: malformed entries rejected)
- [x] 2.5 Reject a token that is not a well formed hub identifier, using the standard's existing hub
      naming rather than a new form. (RSE: malformed entries rejected)
- [x] 2.6 Refuse, rather than pass, on a scope line that cannot be evaluated. (RSE: fails closed)
- [x] 2.7 Preserve the absent-scope behaviour: no scope declared means a full reader, reported
      explicitly. (RSE: absent scope declares a full reader)
- [x] 2.8 Keep the coverage line honest: declaration validated, isolation not validated. (RSE: states
      the coverage it actually has)

## 3. Prove the repair in both directions

- [x] 3.1 Add bypass canaries for an open token in first, middle and last position. (RSE)
- [x] 3.2 Add canaries for empty entry, repeated delimiter, duplicate token, and malformed identifier.
      (RSE)
- [x] 3.3 Add the positive canaries: a legitimate multi-hub scope passes, and an absent scope reports a
      full reader. (RSE)
- [x] 3.4 Add the refusal canaries: unparseable scope line, and unreadable reader context. (RSE)
- [x] 3.5 Run every new canary against the **unrepaired** scanner and confirm each fails there, then
      restore the repair and confirm green. A canary that passes against both proves nothing. (RSE: a
      repaired control is proved against its unrepaired form)
- [x] 3.6 Confirm the fixture extraction fails closed when it reads nothing, so an empty result cannot
      read as a pass.

## 4. Align the documents with the repaired behaviour

- [x] 4.1 Confirm the Reader distribution's closed-scope description matches what the parser now
      enforces, with no gap between claim and behaviour.
- [x] 4.2 Confirm the standard's Reader section states the same rule.

## 5. Distribution metadata

- [x] 5.1 Reconcile the standard's frontmatter version with its heading so one identity is presented.
      (RDM: one version identity)
- [x] 5.2 Compare the two Reader instruction mirrors and record every difference. (RDM: stated
      equivalence matches the guarantee)
- [x] 5.3 Either make the mirrors equivalent, or narrow the documentation to the guarantee that holds
      and name each permitted per-runtime difference. Do not leave the claim broader than the
      guarantee. (RDM)
- [x] 5.4 Tighten the output-area ignore so generated reader output cannot surface as untracked
      material while the shipped convention document stays tracked. (RDM: generated output is not
      distributed)
- [x] 5.5 Verify on a fresh clone that the shipped scaffold passes its own scan. (RDM)

## 6. Generalise the defect class

- [x] 6.1 Sweep every shipped check that reads a delimited or compound value for the same
      whole-value-instead-of-per-token shape.
- [x] 6.2 Report what was swept and what was found, including a finding of none. A silent sweep is not
      a result. **Swept:** `template/reader/reader-scan.sh` (the originating defect), `template/hub-scan.sh`
      (routing-keywords, the station/exposure enums, the `km:` projection markers and their class list,
      the queue table rows, the `sensitivity`/`accessClass` markers, the wikilink targets),
      `template/build-indexes.sh`, `template/handover-hooks.sh`, `tools/km-publish.sh`,
      `template/mcp/server.py`, `agents/km-hub-builder/scripts/check-runtime-parity.sh`,
      `scripts/validate_organization_profile.py`, `components/km-cockpit/km-cockpit.py`.
      **Found: one further instance**, the hub scan's `routing-keywords` completeness test, which tests
      the whole value for empty or `{{` so a value of `", ,"` scans green while carrying no keyword.
      Everything else validates per token already or reads a single-valued field.
- [x] 6.3 If the class is found elsewhere, register it with its reason rather than widening this
      change. See `design.md`, Decision 4. Registered as **D6** in
      `openspec/changes/audit-remediation-2026-08-22/tasks.md`, with the measurement and the reason it
      is not repaired here; A3.3's generalised rule is tracked with it.

## 7. Verification and handover

- [x] 7.1 Full suite green.
- [x] 7.2 Leakage guard clean against a freshly regenerated denylist. Run by the steward tier 2026-08-23 over the full branch diff and commit messages (115010 bytes) against a regenerated 760-entry denylist: zero hits, whole-word, case-insensitive and case-sensitive.
- [x] 7.3 `git diff --check` clean.
- [x] 7.4 Adversarial pass against the repaired class specifically, not the suite alone, since a green
      suite has already once been mistaken for a release gate.
- [x] 7.5 `openspec validate audit-reader-tier-hardening --strict` passes.
- [x] 7.6 Draft the publish commit for the Reader tier version. **Do not publish.** Publication is the
      owner's decision, and no merge, tag, push, or licence selection rides on this change. The version
      is drafted as **v1.41** on branch `v1.41-reader-tier`; it was drafted as v1.40 and renumbered
      because v1.40 published as the MCP quarantine and a published identifier is never reused. Nothing
      was pushed, tagged, or merged to `main`.
