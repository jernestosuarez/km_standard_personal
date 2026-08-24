# Design

## Context

The Reader tier is drafted and unpublished. The audit of 2026-08-22 found one control defect in it
(the scope bypass) and three metadata inconsistencies. Because nothing has shipped, this change
repairs the drafted material in place rather than issuing a correction against a published version.

The defect was reproduced before this change was written. The scanner reported
`OK - scoped reader; closed scope of 2 hub(s): *, hub-alpha`, and a trailing delimiter produced a hub
named `hub-alpha,`. Both observations are the basis of the scenarios in
`specs/reader-scope-enforcement/spec.md`.

## Decision 1: validate tokens, rather than tighten the whole-value test

**Chosen**: split the declared scope and validate each token independently.

**Rejected**: extend the existing whole-value comparison with more patterns to catch `*, ` and similar
forms. That approach keeps the defect's shape and only narrows one instance of it. Each new evasion
would need another pattern, and the check would go on asserting a property it tests only by example.

Token-level validation states the actual rule, which is that every member of a closed list must itself
be a closed member.

## Decision 2: refuse rather than pass on an unevaluable declaration

The scanner already refuses on a context it cannot read. The scope path is brought to the same posture
so the instrument has one behaviour throughout. This follows the standard's existing rule that a check
reporting by absence must distinguish *absent* from *could not be evaluated*, and must not report the
second as the first.

## Decision 3: the coverage statement stays honest about isolation

The repaired scanner validates a declaration. It does not, and cannot, establish that a reader is
prevented from reading outside its declared scope, because that is a hosting property. The coverage
requirement in the delta spec exists to stop a future reader of the output inferring an enforcement
that was never performed. This is the same posture the Reader tier already takes on isolation, and the
repair must not quietly strengthen the claim while strengthening the check.

## Decision 4: the generalised defect class is tracked, not formalised here

The defect's class is *validating a compound value by its whole rather than by its parts*. The
standard's practice is to generalise a repaired defect into a rule rather than patch one instrument,
so this change includes a task to sweep other shipped checks that read a delimited value, and to report
what was swept including a finding of none.

The generalised rule is deliberately **not** formalised as a capability in this change. Doing so would
widen a Reader repair into a change about every instrument the standard ships, and the sweep's result
is not yet known. If the sweep finds the class elsewhere, the rule earns its own change under release
verification. If it finds nothing, the sweep is recorded and the rule is stated where the standard
states its other instrument rules.

## Decision 5: repair in place, and the sequencing that follows

This change edits the unpublished Reader branch. It does not merge, tag, publish, or push. The
sequencing constraint that matters across the remediation set is that **a branch carrying an unfinished
wave is never merged forward to satisfy a later one**. Each remediation change owns its own branch off
the published head at the time it starts, and reaches the published head only through its own owner
push.

The Reader tier does not publish until every scenario in both delta specs passes and the bypass
canaries have been proved against the unrepaired scanner.

## Deliberately excluded from this change

These audit findings are **not** addressed here. They remain tracked in the umbrella plan at
`openspec/changes/audit-remediation-2026-08-22/`, and each is intended to become its own change with
its own approval and publication state:

| Finding | Why excluded | Where tracked |
|---|---|---|
| Unenforced projection gates on the optional query surface | Concerns published material and needs its own corrective release. It is also the audit's most serious finding and must not be delayed behind a Reader repair | Umbrella wave B, items B2 and B4 |
| Missing design document referenced by published text | Independent of the Reader, and repairable at lower cost on its own | Umbrella wave B, item B1 |
| Diverging copies of a distributed skill | Independent surface, its own parity control | Umbrella wave B, item B3 |
| Absent release gate, tags, and continuous verification | The cause of the class rather than an instance of it, and larger than this change | Umbrella wave C |
| Licensing | An owner decision and a legal one. No licence is selected, and the effective reuse grant is not altered by this change | Umbrella wave C, item C3 |
| Documentation drift in the hub template, architecture set, publisher, and specification filename | Lower exposure, batched separately | Umbrella wave D |

The two surfaces where quarantining the query surface and repairing it must not share one completion
state is the reason the umbrella plan is being split at all: a single package completes and archives as
a unit, which cannot represent two separately published steps.

## Risks

- **A canary suite can prove the wrong class.** This is exactly how the original defect shipped: the
  suite tested an exact `*` and an exact `all` and never a list. The mitigation in the delta spec is
  the requirement that the bypass scenarios are executed against the unrepaired scanner and must fail
  there.
- **Token validation can be too strict.** A hub identifier form that rejects a legitimate name would
  break a conformant reader. The positive scenarios exist to hold that line, and the identifier form is
  taken from the standard's existing hub naming rather than invented here.
- **Repairing the declaration can read as repairing isolation.** Addressed by Decision 3.
