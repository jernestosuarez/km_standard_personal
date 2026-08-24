# KM Standard OpenSpec Review and Dev-Builder Handoff

**Reviewed:** 2026-08-22  
**Change package:** `audit-remediation-2026-08-22`  
**OpenSpec CLI:** 1.4.1  
**Disposition:** Not implementation-ready; restructure the OpenSpec artifacts before executing remediation tasks.

## Objective

Convert the existing audit-remediation plan into valid, independently approvable OpenSpec change packages without implementing the underlying repository fixes yet.

The existing `proposal.md` and `tasks.md` are useful source material. Preserve their verification-first approach, owner decision boundaries, and prohibition on publishing without approval.

## Confirmed validation result

The following command currently fails:

```sh
openspec validate audit-remediation-2026-08-22 --strict
```

Confirmed failures:

1. The change has no requirement deltas under `specs/<capability>/spec.md`.
2. The proposal lacks OpenSpec's required exact `## Why` section.
3. It also does not use the required `## What Changes` and `## Capabilities` structure.
4. There are no requirements with `#### Scenario:` acceptance cases.
5. `openspec show audit-remediation-2026-08-22 --json --deltas-only` cannot produce a parsed delta contract.

The task parser does recognize the checklist: OpenSpec currently reports 70 tasks and zero completed.

## Structural issue to resolve

The proposal states that four waves are independently approvable and separately publishable, but all four are held in one OpenSpec change. OpenSpec completes and archives a change package as one unit, so the package cannot honestly represent independent wave approval or release state.

The mismatch is clearest in the MCP work:

- B2 quarantines the MCP surface as one corrective release.
- B4 implements the projection gates as a later release.

Those actions must not share one OpenSpec completion state.

## Required restructuring

Create separately valid OpenSpec changes for independently approvable or publishable outcomes. The minimum recommended split is:

1. `audit-reader-tier-hardening`
   - Reader token parsing and bypass canaries.
   - Reader metadata, mirror claim, and output-ignore correction.
   - Compound-value control sweep.

2. `audit-mcp-quarantine`
   - Verify SDK/API compatibility.
   - Enumerate current exposure paths.
   - Disable or clearly quarantine the surface.
   - Correct unsupported dependency and enforcement claims.

3. `audit-mcp-projection-gates`
   - Reuse the canonical projection/access policy.
   - Apply all four gates to every content-returning path.
   - Include direct-identifier and negative-access scenarios.
   - Lift quarantine only when the contract is proven.

4. `audit-governance-artifact-integrity`
   - Restore or disposition RFC-005.
   - Add RFC reference-integrity checks.
   - Establish canonical `km-brief` instructions and governed mirror parity.

5. `audit-release-governance`
   - One repository audit command.
   - CI and publication gate.
   - Version tagging ritual.
   - RFC lifecycle index and generated badge.

6. `audit-documentation-conformance`
   - Hub-template governance model.
   - Mechanical-versus-procedural control language.
   - Architecture snapshot status.
   - Publisher portability.
   - Project-prefixed Cockpit specification filename.

Licensing must remain an explicit owner-decision item. Do not select a licence or change the effective reuse grant while restructuring these documents. If licensing becomes approved work, give it its own change package or a clearly gated capability within release governance.

If the owner prefers exactly four wave packages, that is acceptable only if independently published steps—especially MCP quarantine and MCP repair—are still represented by separate changes.

## Required proposal structure

Every resulting `proposal.md` must use OpenSpec's exact structure:

```markdown
## Why

## What Changes

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact
```

Do not merely rename the existing headings. Condense each proposal to the outcome governed by that change. Move implementation choices and cross-cutting architectural decisions into `design.md`.

The current repository has no base capability specifications under `openspec/specs/`. Therefore:

- use a new capability and `## ADDED Requirements` when formalizing behavior not already represented in OpenSpec; or
- bootstrap an existing capability under `openspec/specs/` before describing it as modified.

Do not declare a capability modified when there is no corresponding base capability specification.

## Required delta-spec format

Each capability needs a file at:

```text
openspec/changes/<change-id>/specs/<capability>/spec.md
```

Use exact delta headers and testable requirements:

```markdown
## ADDED Requirements

### Requirement: Reader scope tokens are closed and individually validated

The Reader scanner SHALL validate every declared scope token independently and SHALL fail closed when a token cannot be evaluated.

#### Scenario: Wildcard token appears inside a list
- **WHEN** a Reader scope contains `*, hub-alpha`
- **THEN** the scanner rejects the declaration
- **AND** it does not report the scope as closed
```

Rules for every delta:

1. Use only exact `## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`, or `## RENAMED Requirements` headers.
2. Every requirement must contain at least one heading with exactly four hashes: `#### Scenario:`.
3. Include both allowed and rejected behavior where a control has two directions.
4. State observable behavior, not implementation steps.
5. Keep implementation commands and file-edit sequences in `tasks.md`.
6. When using `MODIFIED`, include the complete resulting requirement rather than a partial patch.

## Suggested capability boundaries

Use these as a starting point, consolidating only where the behavior and approval boundary are genuinely the same:

- `reader-scope-enforcement`
- `reader-distribution-metadata`
- `rfc-reference-integrity`
- `skill-distribution-parity`
- `mcp-surface-state`
- `mcp-projection-enforcement`
- `release-verification`
- `rfc-lifecycle-index`
- `hub-template-conformance`
- `standard-control-claims`
- `architecture-versioning`
- `publisher-portability`
- `spec-cache-safety`

## Design documents required

Add `design.md` where the change makes decisions that affect multiple surfaces or future maintenance. At minimum, document:

1. How MCP reuses one projection policy instead of creating a second policy implementation.
2. How the canonical `km-brief` source produces or validates runtime mirrors.
3. How the repository audit command, CI, tagging, and owner publication decision interact.
4. How remediation branches and versions are sequenced without merging an unfinished wave accidentally.
5. Which findings are deliberately excluded from each change and where they remain tracked.

## Tasks conversion

The current task content is strong and should be distributed into the resulting changes rather than discarded.

For each resulting `tasks.md`:

- retain reproduction before repair;
- retain pre-fix and post-fix canary execution;
- keep owner-only publication and licensing decisions explicit;
- order tasks by dependency;
- reference the corresponding capability requirement where useful;
- make each task small enough to complete and verify in one implementation session;
- keep the cross-cutting leakage and adversarial checks in every applicable change instead of leaving them only in the original umbrella file.

Do not mark any remediation task complete merely because the OpenSpec package was restructured.

## Builder constraints

1. Do not implement the underlying audit fixes during this documentation restructuring unless separately authorized.
2. Do not publish, push, merge, tag, or choose a licence.
3. Preserve unrelated user changes, including the current local audit report and `.gitignore` change.
4. Do not weaken the existing proposal's owner-decision boundaries.
5. Do not convert unverified findings into assertions. Keep their reproduction tasks first.
6. Do not create a second implementation of an existing policy merely to satisfy a delta spec.
7. Use project-prefixed names for specification and build-plan documents.

## Completion criteria

The restructuring is complete only when:

- [ ] Every independently approvable/publishable outcome has its own change state.
- [ ] Every resulting proposal has `Why`, `What Changes`, `Capabilities`, and `Impact` sections.
- [ ] Every declared capability has a matching delta specification.
- [ ] Every requirement has at least one `#### Scenario:` block.
- [ ] Positive and negative control behavior is represented where applicable.
- [ ] Architectural decisions are captured in the relevant `design.md`.
- [ ] The original 70 tasks are accounted for, intentionally consolidated, or explicitly deferred with a reason.
- [ ] Licensing remains blocked on an owner decision.
- [ ] `openspec validate <change-id> --strict` passes for every resulting change.
- [ ] `openspec show <change-id> --json --deltas-only` returns the intended requirements and scenarios.
- [ ] `openspec status --change <change-id>` shows all required artifacts ready.
- [ ] No underlying remediation task has been falsely marked complete.

## Verification commands

Run these for every resulting change:

```sh
openspec instructions proposal --change <change-id>
openspec instructions specs --change <change-id>
openspec instructions tasks --change <change-id>
openspec status --change <change-id>
openspec validate <change-id> --strict
openspec show <change-id> --json --deltas-only
```

Finally, inspect `git diff --check` and report the resulting change-package inventory, capability inventory, task accounting, and strict-validation result. Do not commit or publish without the owner's direction.
