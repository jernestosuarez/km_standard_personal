# Design

## Context

`km-deployment.md` declares `routing-keywords` as a comma-separated, lowercase list, harvested by the
supervisor's hub registry and by the decision surface's per-hub attribution. v1.28 gated it, because
until then an empty value scanned green while every surface reading the field attributed nothing. The
gate as shipped, in the `[ DEPLOYMENT ]` block of `template/hub-scan.sh`:

```sh
routing_keywords=$(fm_field "$deployment_file" "routing-keywords")
case "$routing_keywords" in
  "")        # empty -> error
  *'{{'*)    # unsubstituted placeholder -> error
esac
```

Both arms test the whole value. The `{{` arm survives that, because it is a substring test and a
placeholder anywhere in the list still contains `{{`. The empty arm does not. `""` is the only value
the empty arm recognises, so a list made entirely of delimiters and whitespace passes it, matches no
other arm, and falls out of the `case` with no error raised.

Reproduced on `main` at `cac984e`, on a fixture hub built from `template/` with
`routing-keywords: ", ,"`:

```
[ DEPLOYMENT ]
  OK: canonical standard binding is complete; no organization profile applied
=== OK — clean ===
EXIT=0
```

So the half of the class the check catches is the placeholder half, by accident of the test being a
substring match, and the half it misses is the empty-entry half, which is the half v1.28 was written
for.

The consuming side confirms the consequence rather than mitigating it. `components/km-cockpit/km-cockpit.py`
reads the field as `[k.strip().lower() for k in cells[3].split(",") if k.strip()]`. The `if k.strip()`
filter drops every empty token silently, so `", ,"` resolves to an empty keyword list and the hub is
attributed nothing, with no error anywhere. The consumer is right to be forgiving; the gate was
supposed to be the strict one.

### The first instance

v1.41 repaired the same shape in `template/reader/reader-scan.sh`. A scoped reader declares
`scope: hub-alpha, hub-beta`, and the check tested the whole value for the open tokens `*` and `all`.
`scope: *` was rejected and `scope: *, hub-alpha` was accepted, so an open scope hidden among
well-formed neighbours passed as a closed list. The repair splits on the delimiter by hand, so an
empty entry survives as a token rather than being absorbed into its neighbour, and judges each token
on its own. That implementation is the reference for this one, deliberately: two checks in one
standard splitting one delimiter two different ways is a second defect waiting.

## Goals / Non-Goals

**Goals:**

- Repair D6 by validating `routing-keywords` per token, keeping both existing arms working.
- Keep the block's stated limit honest and unwidened: it proves the field was filled in.
- State the generalised rule where its two siblings are stated, with both demonstrations and the cost.
- Record the sweep's scope and conclusion, re-verified against the current tree.
- Prove both directions, and prove the new canaries fail against the unrepaired scan.

**Non-Goals:**

- Judging keyword quality: length, vocabulary, count, overlap with another hub's keywords. A check
  that judged quality would need a notion of a good keyword, and the standard has none.
- A shared tokeniser extracted from `reader-scan.sh` and `hub-scan.sh`. See Decision 4.
- Per-token validation of single-valued fields. See Decision 5.
- Changing what `km-cockpit.py` does with an empty token. See Decision 6.

## Decisions

### Decision 1: at least one well-formed token, not every token well-formed

`routing-keywords` and reader `scope` are compound values with different logics, and copying the
Reader's strictness across would be the wrong repair.

A reader scope is a **closed list**: the property "closed" is a property of every member, so one open
member destroys it and every token must pass. Keywords are a **non-empty set**: the property the
surfaces need is that the hub can be attributed something, and one usable keyword delivers it.

So the gate here is: split, trim, and require **at least one** non-empty token. A stray empty entry
beside real keywords is reported by naming the entry, because a stray delimiter is a typo worth
seeing, but it does not by itself make the hub unattributable and the standard has no ground to
quarantine a hub over it. A value with no non-empty token at all is the error, because that is the
state in which every consuming surface attributes nothing.

Rejected: requiring every token to be non-empty as an error. It converts `alpha, beta,`, a trailing
comma beside two real keywords, into a red hub, which is the strictness cost this rule carries
turning into a quarantine over punctuation.

Rejected also: silently ignoring empty entries, which is what the consumer does. The gate exists to
be the place the sloppiness is visible.

### Decision 2: what "well-formed" means, and how little it means

A token is well-formed when, after trimming leading and trailing whitespace, it contains at least one
alphanumeric character. That is the whole test.

It is deliberately close to the floor. The field is documented as lowercase, and the consumer
lower-cases what it reads, so a check demanding lowercase would reject a value the consumer handles
correctly and would be enforcing presentation rather than function. A token of pure punctuation is
different: no surface can attribute anything to `-`, and it is indistinguishable from a delimiter
artifact.

This is where the limit is restated rather than closed. `alpha, alpha, alpha` passes. `zzz` passes.
The check proves the field was filled in with something a surface could match on. It does not, and
this version does not make it, prove the keywords are the right ones.

### Decision 3: the empty arm stays, and the token gate sits behind it

Three arms in order: empty, placeholder, then the token walk.

The empty arm is kept rather than folded into the token walk, even though a walk over `""` would also
report no usable token. Two reasons. The message differs, and `routing-keywords is empty` names the
defect an operator actually has more precisely than a report about tokens. And v1.28's canary asserts
that exact string; a repair that silently rewrites the message another test asserts is a repair that
takes a working canary with it.

The placeholder arm stays second and stays a substring test. It is already correct for a compound
value, because a placeholder in any position contains `{{`, and moving it into the token walk would
change nothing except the number of moving parts.

The token walk is last, so a value that is neither empty nor placeholder-bearing is the only value it
sees, which is precisely the value that used to fall through.

The whole gate stays behind the interview-date check, unchanged: a hub that was never interviewed has
one defect, not two, and both are fixed by the same act.

### Decision 4: the same splitting technique, not a shared function

The token walk is written with the same hand-rolled split `reader-scan.sh` uses, peeling to the next
delimiter, trimming, judging and repeating, rather than with `IFS=,` word splitting, which absorbs
an empty entry into its neighbour and drops a trailing one. An empty entry that disappears during splitting is
the defect this change exists to fix, reappearing inside the fix.

The two are not factored into one shared helper. `hub-scan.sh` is a single file every hub installs and
runs standalone; `reader-scan.sh` is a single file every Reader installs and runs standalone. Neither
sources the other and neither should, because a shared library between them is a second file a
deployment has to install correctly for its scan to work at all. The cost is stated: one technique now
lives in two places, and a defect found in one is looked for in the other by hand. The sweep record is
what makes that "by hand" a defined act rather than a hope.

### Decision 5: the rule binds compound values, and says which values those are

Stated without a boundary, "validate the parts" would ask a check to split `deployment-state`, whose
value has no parts, and the next maintainer would reasonably ignore the rule rather than apply it
absurdly. So the rule names its own trigger: a value the standard defines as a **list**, a **set**, or
a **delimited sequence**. A scalar is validated as a whole because it is a whole, and that is not an
exception to the rule.

The rule also names what it is not. An identity comparison between two representations of one value,
which is what `[ PROJECTION ]` does when it compares a projected fact against its home of record, is
correctly a whole-value test. Splitting it into tokens would let two texts differ in ways the
comparison then tolerated. Compound-value validation and whole-value comparison are different acts and
the rule is careful not to swallow the second.

### Decision 6: the consumer is not changed

`km-cockpit.py` keeps dropping empty tokens. A consumer that hard-failed on a malformed field would
take the decision surface down over a typo in one hub's binding, and the surface is the estate's
answering path. The gate is where the strictness belongs, because a scan is run by someone who can
act on the result. This is the same division the standard already uses between the scan and the
surfaces it protects.

## Risks / Trade-offs

- **Per-token validation is stricter and can reject a sloppy but well-intentioned declaration.** This
  is the cost of the rule and it is stated with the rule rather than discovered by a deployment. The
  mitigation is Decision 1's threshold: only a value with no usable token at all is an error.
- **The rule is stated from two instances of one shape, both found in this repository.** Two is enough
  to distinguish a pattern from an incident and it is not enough to prove the shape is general. The
  rule carries its demonstrations so a reader can judge the evidence rather than the assertion.
- **Proving both directions proves the check fires on the class it models, never that it models the
  right class.** The class here is "no usable keyword". A field filled with plausible-looking keywords
  that no source will ever match is reached by no canary, because the check is working exactly as
  written. That is the limit v1.28 stated and v1.30 generalised, and it stands.
- **The sweep is a point-in-time finding.** It covered the checks this repository ships at
  `cac984e`. A check added later is not covered by it, which is why the rule is stated as an
  obligation on new checks and not only as a record of a repair.
- **Two files now carry the same splitting technique.** Accepted, per Decision 4.
- **Hubs already deployed do not inherit the repair by upgrading the standard.** An installed
  `hub-scan.sh` is refreshed as an adoption act under the hub's own governance, as every previous
  scan repair was.

## Migration Plan

1. Reproduce D6 on the unrepaired tree and record the output.
2. Add the four canaries beside the existing `routing-keywords` cases and confirm they fail against
   the unrepaired scan.
3. Repair the gate in `template/hub-scan.sh`.
4. Confirm the canaries pass and the v1.28 cases still pass.
5. Graft the generalised rule and the sweep record into the Standard Maintainer section of
   `STANDARD.md`, marked for v1.44 while drafted.
6. Verify: the deployment binding suite, the full suite, `scripts/validate_published_not_draft.py`,
   `git diff --check`.
7. Adoption: a deployment refreshes its installed `hub-scan.sh` under its own governance. A hub that
   goes red on the refreshed scan records the keywords its purpose interview produced.

## Open Questions

- Should the field be validated at the point it is written, by `/km-init`, as well as at scan time?
  The interview produces the value and could refuse a bad one at the source, which would stop the
  defect reaching a binding at all. That is a change to the initiation skill and is not answered here.
- Should the standard eventually declare, per field, whether it is scalar or compound, so a checker
  can be read against a declaration rather than against a comment? That would make the rule
  mechanically checkable and it is a change to the frontmatter contract, well beyond this repair.
