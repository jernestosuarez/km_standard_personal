# Design: an instrument that reads its own input carelessly is an instrument that passes by absence

## Context

The four findings look unrelated. They are the same shape seen from four angles: an instrument whose
verdict is produced by something other than the property it claims to judge.

- The frontmatter check judges a **block** and never confirms the block has an end, so it judges
  whatever text follows the opening delimiter.
- The link check judges a **document** unless the document opts out, and it recognises an opt-out
  anywhere in the raw bytes, so a document that merely mentions the opt-out is not judged.
- The installer test judges an **effect** and reads an **exit status**, so an installer that stopped
  installing still passes.
- The workflow describes a **runner** and a **set of limits** by copying prose, so its description is
  true only for as long as nobody edits the original.

Three of the four are the absence-shaped pass this repository's own gate header says it has already
been bitten by. The fourth is documentation that has drifted from what it documents.

## Goals

1. A malformed frontmatter block MUST NOT be readable as a conforming one.
2. A quotation of a directive token MUST NOT act as that directive, in any instrument in this
   repository that reads one.
3. A test of a mutating operation MUST fail when the mutation does not happen, whatever the operation
   returns.
4. The CI workflow's statements about its environment and its limits MUST be true, and the ones that
   can drift MUST be generated rather than copied.

## Finding 1: what else the frontmatter check misses

The reviewer named the missing closing delimiter. The question the finding implies is what else a
block can be malformed by that the same reading also misses. Five candidates were probed against the
unrepaired check by mutating all three shipped copies of `skills/km-brief` and running the suite.

| Malformation | Unrepaired result | Disposition |
|---|---|---|
| Closing `---` deleted | exit 0, 0 violations | Repaired: a terminator is required |
| Closing delimiter written as YAML's `...` end marker | exit 0, 0 violations | Repaired by the same rule |
| A second, contradictory `name:` key in the block | exit 0, 0 violations | Repaired: duplicate keys refused |
| A second, contradictory `description:` key | exit 0, 0 violations | Repaired by the same rule |
| An extra key beyond the two the contract allows | exit 0, 0 violations | Registered, not repaired |
| Empty block (`---` immediately followed by `---`) | exit 1, 6 violations | Already caught |

The duplicate-key cases belong with the delimiter case because they share its cause: the check reads
the first match of a `sed` expression and never asks whether the block is well formed. A file whose
second `name:` disagrees with its first installs a slug the listing and the invocation do not share,
and the check reports it as conforming.

The extra-key case is registered rather than repaired. `allowed-tools` and similar keys are real
fields in real runtimes, and refusing them is a policy decision about what this standard's skill
files may carry, not a defect in how this check reads its input. Widening the check to enforce it
would settle that policy silently. It is recorded in the check's own header so the next maintainer
finds the question rather than rediscovering it.

## Finding 2: where a declaration is made

`km-gate-link-exempt:` is read with `re.search` over the raw file. Two things are wrong with that and
only one of them is the reviewer's case:

1. The read happens before `strip_fenced`, so a fenced example is a declaration.
2. The read is unanchored, so a mid-sentence mention anywhere in a 4749-line document is a
   declaration.

v1.52 repaired this class in `scripts/validate_published_not_draft.py` by anchoring the read to where
the declaration is made. The anchor it chose was a leading window: `lines[:EXEMPT_SCAN_LINES]`, 60
lines. That is better than unanchored and it is not sufficient, which the sweep demonstrated on the
one file where it matters most. `STANDARD.md`'s first 60 lines are its version lead, and a version
lead is exactly the prose that quotes tokens. One inserted sentence exempted the home of record from
its own publication check.

So the anchor is made of two independent conditions, applied identically in all three readers:

- **Line-anchored.** The token must be the first thing on its line, after optional whitespace and at
  most one comment marker (`#`, `//`, `<!--`, `*`, `-`). A declaration is a line; a mention is part of
  a sentence.
- **Outside a fence.** Fenced blocks are blanked before the search. A fenced block is quotation by
  definition.

Both are needed. Line-anchoring alone lets a fenced example that starts at column zero through, which
is how examples are normally written. Fence-stripping alone lets the `STANDARD.md` sentence through,
which was not fenced.

The gate's link exemption additionally takes the 60-line leading window, so the three instruments now
share one rule rather than three. Every exemption currently declared in this repository is at the
start of its line, in a header comment or docstring, within the first 60 lines, outside any fence, and
resolves unchanged.

### What was swept

Every machine-read directive token in the repository:

| Token | Read from | Verdict |
|---|---|---|
| `km-gate-link-exempt:` | raw whole file | Defect, repaired |
| `published-not-draft-exempt:` | first 60 lines, raw | Defect, demonstrated on `STANDARD.md`, repaired |
| `rfc-reference-exempt:` | first 60 lines, raw | Same reader, same shape, repaired |
| `km-unrepaired-tree:` | `header_of()`, the leading comment block | Already anchored |
| `km-gate-instrument:` | `header_of()`, the leading comment block | Already anchored |

The last two were anchored to the leading comment block in v1.53's gate work, for this exact reason:
the gate's header records that it found its own canaries declaring on behalf of the fixtures they
write. They are left alone. The line-anchor is applied to them as well, because a comment block that
documents the syntax is the one place a quotation is most likely, and the cost is nothing.

## Finding 3: exit status versus effect

`agents/km-hub-builder/tests/test-agent-package.sh` is the only suite in this repository that
exercises a **mutating** tool. Every other suite exercises a checker, a scanner or a validator, whose
product **is** its verdict, so asserting the status is asserting the effect. That is why the sweep
this finding demands returns one file and not twenty-three.

The sweep covered all 23 shell suites. The result:

- **The class, in full: one file, four cases.** In `test-agent-package.sh`, the pre-install `--check`,
  the post-install `--check`, the parity run, the unmanaged-collision refusal and the
  `--replace-existing` run were all asserted by exit status alone. Two of them have an effect nobody
  looked at: the refusal must leave the unmanaged file untouched, and the replacement must replace
  it. All are repaired here.
- **A weaker sibling, registered rather than repaired.** Several validator suites assert a refusal or
  a failure status without also asserting which reason produced it, so a case could pass on the right
  status for the wrong cause. `tests/test_km_publish_guards.sh` cases 3, 5b, 6a, 6c, 8b and 12c are
  the clearest examples. This is a different defect from the one under repair: those cases judge a
  verdict, and the verdict is the tool's whole output, so nothing is unobserved. Repairing them means
  adding a message needle to six assertions across a suite this change does not otherwise touch, and
  the-thing-under-review-is-the-thing-corrected says that belongs in its own change. Registered here
  with its reason.

## Finding 4: a copy that has already drifted

The workflow's header carries two of the gate's four limits. Correcting the copy makes it true today
and leaves the mechanism that made it false. The mechanism available without over-building is the one
the gate already has: it prints the limits itself, from one definition, on every run.

So the limits become a module-level `LIMITS` tuple in `tools/km-release-gate.py`, printed by the
passing block, summarised by the failing block, and exposed by a new `--limits` flag. The workflow
stops restating them and runs the flag as its first step, so the CI log carries the current limits
without any file having to be edited when a limit is added. `tests/test_release_gate.sh` asserts that
the flag prints every defined limit and that the workflow invokes it, so the pointer cannot rot into
another copy.

The pinning claim is corrected rather than mechanised, because it is not a copy of anything. GitHub
redeploys version-labelled images weekly. `ubuntu-24.04` selects a major version, not an image. The
comment now says that, and says what the label does buy: the gate's verdict does not move to a new
Ubuntu release without an edit here, which is a smaller and true claim.

## Options considered and rejected

**Parse the frontmatter with a YAML library.** Rejected. It adds a dependency to a suite that runs
under `bash` alone on a hosted runner, and it would move the check from "the two fields a runtime
reads are present and well formed" to "this is valid YAML", which is a different and larger contract.

**Require the link exemption inside an HTML comment.** Rejected. It breaks the existing fixture and
every future declaration for the sake of a distinction line-anchoring already draws, and markdown
files in this repository do not otherwise use HTML comments for machine-read material.

**Generate the workflow header from the gate.** Rejected as over-building. A generated YAML comment
needs a generator, a check that the generator ran, and a way to fail when it did not. Running the
flag costs one step and produces the same guarantee in the place a reader actually looks, which is
the log.

## Residual gaps, asserted as gaps

1. The frontmatter check still does not enforce that the block carries **only** the two allowed keys.
   Registered above.
2. The line anchor admits a declaration written at the start of a line inside a block quote deeper
   than one marker, and rejects one indented under a list item. Both are deliberate: the rule is a
   line, not a parse tree.
3. `tests/test_km_publish_guards.sh` and its siblings still assert some statuses without asserting
   the reason. Registered above.
4. The `--limits` mechanism keeps the CI log current. It cannot make anyone read it, and it does not
   stop a future editor from writing a fresh copy of the limits into the workflow header. The suite
   case asserts the flag is invoked; it does not assert that no copy exists.
