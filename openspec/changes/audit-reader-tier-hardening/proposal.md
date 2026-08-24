## Why

The external audit of 2026-08-22 found that the drafted Reader tier accepts an open scope hidden
inside a list. The defect was reproduced first-hand: a reader declaring `scope: *, hub-alpha` is
accepted and reported as a `closed scope of 2 hub(s)`, because the scanner validates the scope as one
whole value rather than token by token. A scoped reader is the mechanism that confines a consumer to
its own compartment, so a scope that silently widens defeats the control it exists to provide.

This must be repaired now because the Reader tier is drafted and unpublished. Repairing it in place
costs one branch edit, and publishing it first would convert a cheap fix into a corrective release
against a control that consumers rely on.

## What Changes

- Reader scope validation moves from whole-value comparison to independent validation of every
  declared token, rejecting open tokens (`*`, `all`) in any position, empty entries, malformed hub
  identifiers, and duplicates.
- The scanner fails closed on a scope declaration it cannot evaluate, consistent with its existing
  posture, rather than reporting a pass it cannot justify.
- Bypass canaries are added so the repaired class is proved in both directions and cannot regress
  silently. The existing suite proved only an exact `*` and an exact `all`, which is why the defect
  shipped.
- The standard presents one version identity: document frontmatter and heading agree.
- The Reader distribution's claim that its two instruction mirrors are kept equal is either made true
  or narrowed to the guarantee that actually holds.
- Generated reader output cannot surface as untracked files, while the shipped convention document
  stays tracked.
- No **BREAKING** change. The Reader tier has never been published, so no deployment depends on the
  behaviour being corrected.

## Capabilities

### New Capabilities

- `reader-scope-enforcement`: how a reader's declared scope is parsed, validated, and reported, and
  what the scanner does when it cannot evaluate a declaration.
- `reader-distribution-metadata`: the identity and distribution guarantees of the shipped Reader
  material, covering version identity, mirror equivalence claims, and generated output.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so nothing
existing is being changed at requirement level. Both capabilities above are introduced as `ADDED`.

## Impact

- **Affected material**: the Reader scanner and its test suite, the Reader distribution documents, the
  repository ignore rules, and the standard's own version identity fields.
- **Affected release**: the unpublished Reader tier version. It does not publish until every scenario
  in both delta specs passes and the bypass canaries are proved against the unrepaired scanner.
- **Deployments**: none. No hub content changes, no per-hub obligation, and no existing deployment
  inherits the corrected behaviour because the tier has not shipped.
- **Not in scope**: the audit's findings against published material (the unenforced projection gates,
  the missing RFC, the diverging skill copies) and the absent release gate. Those remain tracked in
  `audit-remediation-2026-08-22` and are addressed by their own changes. See `design.md`.
- **Owner boundary unchanged**: this change drafts and verifies. Publication remains the owner's
  decision, and no licence, tag, merge, or push is performed under it.
