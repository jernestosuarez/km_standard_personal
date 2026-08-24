# Tasks

Unchecked throughout: nothing in this plan has been executed. Each wave is separately approvable.
Every task that repairs a finding begins by reproducing it, and every shipped check carries a
both-directions canary before its version is drafted.

## A. Unblock the unpublished Reader tier (v1.41)

Branch: `v1.41-reader-tier`, which is drafted and unpublished (renumbered from
`v1.40-reader-tier` once v1.40 published as the MCP quarantine). Repairs land in place, so no corrective
release is required.

### A1. Scope token parser (F-03, reproduced)
- [ ] A1.1 Record the reproduction in the branch as a failing canary first: `scope: *, hub-alpha`
      currently reports `OK - scoped reader; closed scope of 2 hub(s)`, and `scope: hub-alpha,` parses
      a hub named `hub-alpha,`. Both must fail before the fix, and pass after.
- [ ] A1.2 Rewrite the scope validation in `template/reader/reader-scan.sh` to split the declared value
      on its delimiter and validate **each token independently**. Reject: a token equal to `*` or `all`
      in any position, an empty token (leading, trailing, or doubled delimiter), a token that is not a
      well-formed hub identifier, and a duplicate token.
- [ ] A1.3 Refuse rather than pass on a scope line the parser cannot evaluate, consistent with the
      script's existing fail-closed posture, and keep the coverage line honest about what was checked.
- [ ] A1.4 Extend `tests/test_reader_scaffold.sh` with bypass canaries: mixed wildcard in first,
      middle and last position; `all` inside a list; empty entries; a duplicate; a malformed
      identifier; and the positive case proving a legitimate multi-hub scope still passes.
- [ ] A1.5 Verify the negative direction: run the new canaries against the pre-fix scanner, confirm
      they fail, restore the fix, confirm green.
- [ ] A1.6 Confirm `template/reader/README.md` and the `STANDARD.md` Reader section describe the
      closed-scope rule as the parser now enforces it, with no gap between claim and behaviour.

### A2. Draft metadata (F-14, reproduced)
- [ ] A2.1 Reconcile `STANDARD.md` frontmatter `title` with the document heading so one version
      identity is presented (was v1.39 against a v1.40 draft; now v1.41 in both).
- [ ] A2.2 Reader instruction mirrors: either make `template/reader/CLAUDE.md` and
      `template/reader/AGENTS.md` genuinely equivalent, or correct the README's equality claim to state
      the per-runtime differences that are actually permitted. Do not leave the claim broader than the
      guarantee.
- [ ] A2.3 Tighten the `outputs/` ignore so the shipped convention document is tracked while generated
      reader output cannot surface as untracked files.

### A3. Generalise the defect class (F-03)
- [x] A3.1 Sweep every shipped check that reads a delimited or compound value for the same
      whole-value-instead-of-per-token shape. Report what was swept and what was found, including a
      finding of none. **Swept 2026-08-23** on `v1.41-reader-tier`: `template/reader/reader-scan.sh`
      (the originating defect, repaired), `template/hub-scan.sh` (routing-keywords, the station and
      exposure enums, the `km:` projection markers and their class list, the queue table rows, the
      `sensitivity`/`accessClass` markers, the wikilink targets), `template/build-indexes.sh`,
      `template/handover-hooks.sh`, `tools/km-publish.sh`, `template/mcp/server.py`,
      `agents/km-hub-builder/scripts/check-runtime-parity.sh`,
      `scripts/validate_organization_profile.py`, `components/km-cockpit/km-cockpit.py`. **One further
      instance found**, registered as D6 below. Everything else either validates per token already or
      reads a single-valued field.
- [x] A3.2 Where the class is found, repair it in the same wave or register it with its reason.
      Registered as D6 rather than repaired here, per `audit-reader-tier-hardening/design.md`
      Decision 4: the Reader repair is not widened into a change about the hub scan.
- [ ] A3.3 State the generalised rule where the standard states its other instrument rules, so the next
      check written against a list validates its parts. **Deferred by design** (Decision 4): the rule
      earns its own change now that the sweep has found a second instance. Tracked with D6.

### A4. Publication of v1.41
- [ ] A4.1 Full suite green, leakage guard clean, bypass canaries passing.
- [ ] A4.2 Adversarial pass specifically against the repaired class before recommending publication,
      rather than relying on the suite alone.
- [ ] A4.3 Draft the publish commit; publication remains the owner's decision.

## B. Corrective releases for published v1.39

### B1. Resolve RFC-005 (F-04, reproduced)
- [ ] B1.1 Confirm the current state: `main` carries RFC-001, 002, 003, 004, 006; `STANDARD.md` on
      `main` references RFC-005 twice; RFC-005 exists on an unmerged local branch only.
- [ ] B1.2 Merge RFC-005 to `main` as a design record, matching how RFC-004 reached `main` ahead of the
      version implementing it. Confirm it is leakage-clean before it lands.
- [ ] B1.3 Add a reference check that extracts RFC identifiers from prose, version-ledger rows and RFC
      dependency sections, and not only from Markdown hyperlinks. The existing link check missed this
      because the reference is written as a code-formatted path.
- [ ] B1.4 Prove the check in both directions against a deliberately dangling identifier.
- [ ] B1.5 Audit every other RFC cross-reference in `STANDARD.md` and in the RFCs for the same class of
      dangling reference.

### B2. Quarantine the MCP surface (F-01 reproduced, F-02 unverified)
- [ ] B2.1 Verify F-02 before acting on it: confirm the installed SDK major version, the API the server
      imports, and the Python version floor actually required.
- [ ] B2.2 Enumerate every path in `template/mcp/server.py` that returns entity content, and record for
      each which of the four gates it applies today. `get_entity()` is confirmed to apply none beyond a
      committed-state check.
- [ ] B2.3 Mark the MCP surface disabled or experimental in a way a deployment cannot miss, and correct
      `template/mcp/README.md` so it no longer claims enforcement the code does not perform.
- [ ] B2.4 Correct the dependency instructions per B2.1: pin a compatible release with its true Python
      floor, or state plainly that the template targets an API that requires migration.
- [ ] B2.5 State the exposure honestly in the version row: which content classes could be returned by
      which path, so a deployment can assess what it ran.
- [ ] B2.6 Draft as its own version; publication is the owner's decision.

### B3. Reconcile the distributed `km-brief` (F-05, reproduced)
- [ ] B3.1 Diff `skills/km-brief/SKILL.md` (109 lines) against `template/.claude/skills/km-brief/SKILL.md`
      (128 lines) and the second template mirror. Record every semantic difference, not only the
      known lifecycle section.
- [ ] B3.2 Establish one canonical source and derive the runtime mirrors from it, so the copy the
      README advertises as distributable is the protected one.
- [ ] B3.3 Extend `tests/test_skill_frontmatter.sh`, or add a companion test, to compare the governed
      instruction body and permit only documented per-runtime substitutions.
- [ ] B3.4 Prove the parity check in both directions by introducing a synthetic divergence.
- [ ] B3.5 Apply the same parity question to every other skill shipped in more than one location, since
      the finding's class is duplication without a parity gate.
- [ ] B3.6 Record in the version row that this closes a drift the v1.27 row knowingly deferred.

### B4. Implement the MCP projection gates (F-01)
- [ ] B4.1 Locate the existing projection and access policy implementation used by the other consuming
      surfaces. Reuse it; do not author a second implementation.
- [ ] B4.2 Apply all four gates on every content-returning path: committed at `HEAD`, lifecycle-active,
      within the consumer's access clearance, and present in the projection manifest.
- [ ] B4.3 Cover direct-identifier retrieval explicitly, which is the path that bypasses the others.
- [ ] B4.4 Negative tests, mandatory and each proved unreachable by identifier lookup as well as by
      query: retired, superseded, restricted, sensitive, and unmanifested entities.
- [ ] B4.5 Lift the quarantine only when B4.4 passes, and state in the version row what changed for a
      deployment that had the surface enabled.

## C. The release gate

### C1. One audit command, enforced (F-06, unverified)
- [ ] C1.1 Verify the finding: confirm the absence of CI workflows, status checks, release tags and a
      repository-level test runner, and confirm the leakage hook is local and untracked.
- [ ] C1.2 Add one versioned command that runs every suite, the leakage guard, syntax and link checks,
      and profile validation, with a single pass or fail result and a stated coverage line.
- [ ] C1.3 Run it in CI on every push and pull request.
- [ ] C1.4 Make it a required gate before a version publishes, and record that requirement where the
      publication ritual is described.
- [ ] C1.5 Create annotated tags for released versions so a release is identifiable without reading the
      ledger, and document the tagging step as part of publication.
- [ ] C1.6 Record honestly that a local pre-push hook protects one machine and cannot protect a remote
      push or another contributor.

### C2. RFC index and badge (F-09, unverified)
- [ ] C2.1 Verify the stale statuses: the badge count, RFC-002's declared status, RFC-004's banner
      against the versions that implemented parts of it, and RFC-006's banner against v1.39.
- [ ] C2.2 Add `rfcs/README.md` recording for every proposal: status, decision date, implementing
      version, supersession, and partial-adoption notes.
- [ ] C2.3 Generate the badge from the index rather than maintaining it by hand.
- [ ] C2.4 Update each RFC's status banner where a later version has implemented part of it, so no
      banner claims that no normative change rides on a design already shipped.

### C3. Licensing (F-07, reproduced, owner decision)
- [ ] C3.1 Present the options and their consequences. **Do not select a licence.**
- [ ] C3.2 On the owner's instruction only: add the chosen licence at the repository root and align the
      README and the badge with it.
- [ ] C3.3 If the decision is deferred, soften the README's reuse claim to match the grant that is
      actually in force, and record the deferral with its reason.
- [ ] C3.4 Note the interaction with the editions boundary published in v1.39, which was drawn to be
      license-agnostic precisely so a policy could attach at that line later without structural change.

## D. Documentation drift

### D1. Hub template landing page (F-08, unverified)
- [ ] D1.1 Verify: confirm `template/README.md` states four enforced rules against the standard's
      current six, and confirm the numbered-document guidance against the current entity-note model.
- [ ] D1.2 Rewrite it from the current operating model, since every newly created hub inherits it.
- [ ] D1.3 Add a conformance test on its rule count and core terminology, proved in both directions.
- [ ] D1.4 State whether existing hubs carry the outdated page and whether adoption is expected, or
      whether the change reaches new hubs only.

### D2. Narrow the enforcement claim (F-11, unverified)
- [ ] D2.1 Verify the contradiction between the standard's six-rule enforcement claim and the design
      rationale's acknowledgement that source traceability is procedural.
- [ ] D2.2 Narrow the claim to distinguish mechanical controls from procedural ones, which is the
      recommended path and consistent with the honesty doctrine applied to the Reader's isolation
      boundary, or introduce a minimal checkable provenance record.

### D3. Architecture documents (F-12, unverified)
- [ ] D3.1 Verify the coverage gap against the surfaces added since v1.22 and v1.23.
- [ ] D3.2 Refresh the package, or label it a historical snapshot at every point the README links it.

### D4. Publisher portability (F-10, unverified)
- [ ] D4.1 Verify the platform-specific interpreter discovery, the unpinned rendering dependency, the
      generated environment directory, and the absence of an ignore rule for it.
- [ ] D4.2 Declare supported platforms, make interpreter discovery portable, and pin dependencies.
- [ ] D4.3 Ignore the generated environment, and confirm a governed hub's scan does not read it as a
      dirty tree.
- [ ] D4.4 Add an end-to-end rendering smoke test, since the existing tests exercise guard logic and
      not dependency installation or actual output.

### D5. Specification filename (F-13, unverified)
- [ ] D5.1 Verify the cache-safety convention and confirm the generic filename conflicts with it.
- [ ] D5.2 Rename with every reference updated atomically, and confirm no reference is left dangling.

### D6. `routing-keywords` is validated as a whole value (registered 2026-08-23, from the A3 sweep)

**Reason it is registered rather than repaired here.** It is the same class as F-03, found in a
different instrument on published material. Repairing it inside `audit-reader-tier-hardening` would
widen a Reader repair into a change about the hub scan and would ride the Reader's publication state,
which `design.md` Decision 4 rules out. It is a lower-exposure defect than F-03: it weakens a
completeness check on a manifest field, and it opens no read path.

**What was measured.** `template/hub-scan.sh` reads `routing-keywords` with `fm_field` and tests the
whole value in one `case`: empty, or containing `{{`. The field is a comma-separated list, so a value
of `", ,"` is neither empty nor a placeholder and scans green while carrying no keyword at all. The
`{{` arm is a substring test and does catch a placeholder in any position, so only the empty-entry
half of the class is present. Verified by extracting the field with the scan's own `fm_field` awk and
walking the `case` arms; the value arrives as `, ,` and matches no arm.

- [ ] D6.1 Reproduce against a hub whose `routing-keywords` is a list of empty entries, as a failing
      canary first.
- [ ] D6.2 Validate the field token by token: reject a list whose tokens are all empty, and name the
      empty entry rather than absorbing it.
- [ ] D6.3 Prove both directions against the unrepaired scan, and keep the stated limit that this
      proves the field was filled in and never that the keywords are the right ones.
- [ ] D6.4 With D6 repaired, state the generalised rule (A3.3) where the standard states its other
      instrument rules: a check that reads a delimited value validates each token, and a value it
      cannot tokenise is refused rather than passed.

## Cross-cutting, applies to every wave

- [ ] X.1 Leakage guard clean on every branch before any push, against a freshly regenerated denylist.
- [ ] X.2 Every shipped check proved in both directions, and re-run against the unfixed tree to confirm
      it detects the defect it was written for.
- [ ] X.3 Every version row states its stated limits and trade-offs, including what the repair does not
      cover.
- [ ] X.4 No wave publishes on the maintainer's judgement alone.
- [ ] X.5 Until C1 exists, each version's verification includes an explicit adversarial pass against the
      defect class being repaired, because a green suite has already once been mistaken for a gate.
