# Tasks

Nothing here has been executed. Tasks are ordered by dependency: verify what is true, enumerate the
exposure, quarantine, correct the claims, then prove the quarantine holds.

Requirement references point at `specs/mcp-surface-state/spec.md` (MSS) and
`specs/mcp-distribution-claims/spec.md` (MDC).

## 1. Verify before acting

- [x] 1.1 Confirm the gate matrix in `design.md` against the published tree: which of the four gates
      each content-returning path applies today. The listing path enforces lifecycle, the
      direct-identifier path does not, and access clearance and manifest membership appear nowhere.
- [x] 1.2 Confirm no sensitivity, clearance, or manifest logic exists anywhere in the implementation.
- [x] 1.3 Confirm the content test is a denylist, so an entity carrying a restricted marking in an
      ordinary location is exposed by construction.
- [x] 1.4 Verify the installation finding, which is unverified: the installed dependency major version,
      the interface the implementation imports, and the interpreter floor the resolved dependency
      actually requires. Do not carry the audit's claim into the repair unchecked. (MDC: instructions
      resolve to a runnable configuration)
- [x] 1.5 Record the documentation sentence that states retired and superseded notes are never
      returned, and the path on which it is false. This is the specific false guarantee. (MDC:
      documentation states only guarantees the implementation keeps)

## 2. Enumerate the exposure

- [x] 2.1 For each content-returning path, list the content classes it could return: retired,
      superseded, restricted, sensitive, and entities absent from the projection manifest. (MSS: the
      quarantine names the exposure it closes)
- [x] 2.2 Write the enumeration in terms of paths and classes, naming no specific content.
- [x] 2.3 Confirm the surface reads committed state only, so the enumeration bounds what was reachable.

## 3. Quarantine the surface

- [x] 3.1 Place the surface in a declared quarantined state in which every content-returning path
      refuses. (MSS: a surface that cannot enforce its contract refuses to serve)
- [x] 3.2 Refuse on the listing path as well, rather than degrading to it because it enforces
      lifecycle. See `design.md`, Decision 2. (MSS)
- [x] 3.3 Make the refusal state its reason, so a caller learns why rather than reading an empty
      result. (MSS)
- [x] 3.4 Report the quarantined state when the surface is started, rather than starting silently.
      (MSS: the quarantine is discoverable before it is relied on)
- [x] 3.5 Confirm the refusal cannot be bypassed by any other entry point on the surface, including any
      path not listed in the gate matrix.

## 4. Correct the claims

- [x] 4.1 Remove or qualify the unconditional lifecycle guarantee, naming the path on which it does not
      hold. (MDC)
- [x] 4.2 Name the gates the implementation performs nowhere as not enforced, rather than omitting
      them. (MDC)
- [x] 4.3 Correct the premise that committed state is safe to expose. Committed records a fact and
      decides nothing about who may read it. (MSS: commitment is not clearance)
- [x] 4.4 State the quarantine in the surface's own documentation, with its reason, where an operator
      meets it before enabling anything. (MSS)
- [x] 4.5 Correct the installation instructions per the finding of 1.4: pin a compatible configuration
      with its true interpreter floor, or state the migration the implementation needs. (MDC)

## 5. Prove the quarantine

- [x] 5.1 Add a test that each content-returning path refuses while quarantined and returns no content.
      (MSS)
- [x] 5.2 Add the negative direction: run the same tests against the unquarantined surface and confirm
      they fail there, so the tests are known to detect a serving surface. Restore, confirm green.
- [x] 5.3 Add a test that starting the surface reports the quarantined state.
- [x] 5.4 Fail closed on empty fixture extraction, so an empty result cannot read as a refusal.
- [x] 5.5 Confirm no test asserts a gate this change does not implement. The quarantine is not the
      repair, and a test that passes because nothing is served must not be read as a gate being proved.

## 6. Record and hand over

- [x] 6.1 Draft the version row naming the exposure by path and class, per task 2, so a deployment can
      assess what it ran. (MSS)
- [x] 6.2 State plainly that this change quarantines and does not repair, and name the change that
      lifts the quarantine.
- [x] 6.3 State the adoption consequence: a deployment that had the surface enabled loses it, which is
      the intended outcome.

## 7. Verification and handover

- [x] 7.1 Full suite green.
- [x] 7.2 Leakage guard clean against a freshly regenerated denylist. Run by the steward tier
      2026-08-22 over the full branch diff and commit messages against a regenerated 760-entry
      denylist: zero hits, whole-word, case-insensitive and case-sensitive. The drafting agent
      correctly declined to tick this, since the guard is the steward's to run.
- [x] 7.3 `git diff --check` clean.
- [x] 7.4 Adversarial pass against the quarantine specifically: attempt to obtain content by every
      entry point, not the suite alone.
- [x] 7.5 `openspec validate audit-mcp-quarantine --strict` passes.
- [x] 7.6 Draft the publish commit. **Do not publish.** Publication is the owner's decision, and no
      merge, tag, or push rides on this change.
