## Why

`routing-keywords` in `km-deployment.md` is a comma-separated list, and the gate `template/hub-scan.sh`
put on it in v1.28 tests the whole value. A value of `", ,"` is neither empty nor placeholder-bearing,
so it falls through every arm of the `case` and the hub scans green while carrying no keyword at all.
A supervisor registry and a decision surface then attribute nothing to that hub, which is exactly the
failure the v1.28 check was added to prevent. Reproduced on the tree at `cac984e`: exit 0,
`OK: canonical standard binding is complete`, `=== OK — clean ===`.

This is defect D6, and it is the second confirmed instance of one class. The first was the Reader
scope check, where `scope: *, hub-alpha` was accepted as a closed scope because only the whole value
was tested, repaired in v1.41. One instance is an incident. Two earn a rule, and the Reader hardening
deferred that rule (its task A3.3) so it would ride with the second instance rather than be written
from one.

## What Changes

- The `routing-keywords` gate in `template/hub-scan.sh` validates the value **token by token**: it
  splits on the comma, trims each token, and requires at least one non-empty, well-formed keyword.
  A value whose tokens are all empty or whitespace is an error and names the offending entries.
- The two existing arms keep working unchanged. An empty value is still reported as empty, and a value
  carrying `{{` anywhere is still reported as an unsubstituted placeholder.
- The block's stated limit is preserved verbatim in substance: this proves the field was filled in,
  never that the keywords are the right ones. The check does **not** judge keyword quality.
- A generalised rule is stated in `STANDARD.md`, in the same section that already states the two
  instrument rules it is a sibling of: **a check that reads a compound value validates its parts,
  never the whole alone.** Both demonstrations are carried with it, because the standard's practice
  is to carry the evidence that earned a rule.
- The cost is stated with the rule: per-token validation is stricter than whole-value validation and
  can reject a sloppy but well-intentioned declaration that the old check would have waved through.
- The sweep of the shipped checks is recorded where the rule is stated, so the next maintainer knows
  what was covered rather than repeating it blind. The sweep was re-verified against the current tree
  for this change rather than carried forward on the strength of the earlier session's finding.
- Four canaries are added beside the existing `routing-keywords` cases, proving both directions, and
  they are run against the unrepaired scan to confirm they fail there.
- Not **BREAKING** for a hub whose `routing-keywords` carries a real keyword. A hub carrying an
  all-empty-token value goes red, which is the defect becoming visible rather than a new obligation.

## Capabilities

### New Capabilities

- `compound-value-validation`: what a check must do when the value it reads is a list rather than a
  scalar, which conclusions a whole-value test is entitled to draw, what the per-token gate on
  `routing-keywords` must accept and refuse, and what the rule costs.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: the `[ DEPLOYMENT ]` block of `template/hub-scan.sh`, where the gate is
  repaired; the Standard Maintainer section of `STANDARD.md`, where the sibling instrument rules
  already live and where the generalised rule and the sweep record are grafted; and
  `tests/test_hub_deployment_binding.sh`, which already holds the `[ DEPLOYMENT ]`
  `routing-keywords` cases and gains four more.
- **Affected deployments**: every hub, because `hub-scan.sh` is inherited. A hub whose keyword field
  carries at least one real keyword is unchanged. A hub whose field is delimiters and whitespace goes
  from green to red, and the fix is the one act that was always required: record the keywords the
  purpose interview produced.
- **Not in scope**: judging whether the recorded keywords are the right keywords. That is the limit
  v1.28 stated and it is unchanged, restated rather than closed.
- **Not in scope**: applying per-token validation to fields that are single-valued by construction.
  The rule binds compound values, and widening it to scalars would produce a check that splits a
  value that has no parts.
- **Not in scope**: the projection comparison in `[ PROJECTION ]`, which compares two representations
  of one text for identity. Identity over a whole value is the right test there, and splitting it
  into tokens would weaken it.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
