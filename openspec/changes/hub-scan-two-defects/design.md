# Design: hub-scan-two-defects (v1.57)

Branch `v1.57-hub-scan-two-defects`, off `main` at `2005772` (published v1.56).

This is a **harvest**. Both designs arrived from the tier that found the defects in operation. A
design handed over is still a claim, so this document records what survived verification, what did
not, and the judgements that were left open for the drafting agent to make.

---

## 1. What exactly is "a numbered curated document"?

**Answer: a root-level `0[0-9]_*.md` or `10_*.md`, and nothing else.**

The handed-over design said "a root-level `NN_*.md`" and asked for it to be confirmed against the
standard's own definition of hub structure rather than invented as a pattern. It was, and the
standard's definition is narrower than `NN_*.md` in two ways that both matter.

*The digits.* §"Hub Directory Structure" fixes the layout `00_about.md` through `07_glossary.md` with
`[08–10_<additional>.md]` optional, and the monitored-files glob directly beneath it reads
`0[0-9]_*.md   10_*.md`. That is the standard's own enumeration of the numbered curated set, and it
stops at 10. `NN_*.md` would admit `42_scratch.md`, which the standard has never called structure.
The narrower form was taken because **this narrowing relaxes a security check**, and where the
evidence supports two boundaries the narrower one is the correct default.

*The location.* The same glob scopes the numbered documents to the hub root. Nothing in the standard
treats a numbered file in a subdirectory as curated structure: entity notes are named for their
subject, working documents are named `YYYY-MM-DD_<initials>_<slug>.md`, and a numbered name inside a
folder is an ordinary note that happens to sort. So the case pattern anchors on `"$HUB"/`, and
`tests/test_restricted_lint.sh` case 1f asserts that a frontmatter-restricted
`working-docs/03_engagement-note.md` still has its name blocked.

*Why case 1f passes on the unrepaired tree, and why that is not a defect in the case.* It cannot
detect this version's defect, because the behaviour it asserts is the behaviour before the change.
Its job is different: **narrowing a security check is how a false positive becomes a false negative**,
and the only mechanical guard against the narrowing spreading is a case that fails the moment it does.
It is recorded as a boundary case rather than offered as a detector, which is the distinction v1.30
already draws between a canary and an over-match case.

*A note on the implementation.* `curated` is passed into `awk` with `-v` and tested as `curated+0`
rather than as a bare truth test, so the arm does not depend on whether a given `awk` treats a
command-line assignment of `"0"` as a numeric strnum or as a string. The value is computed by a shell
`case` with a leading `(` on the pattern, which is what keeps it parseable inside `$( )` on the
bash 3.2 that ships as `/bin/bash` on macOS — the same reason the line above it already carries one.

## 2. Does the body-marker path need the same narrowing?

**No, and this is stated explicitly rather than left unexamined.**

A marker in the body opens a span and emits `C` records only — one per verbatim line of the section
it opens. It has emitted no `I` record since v1.21, which is exactly the narrowing v1.21 made and for
exactly this reason: a note restricted only in one body section must stay nameable, or the governed
route to changing it is blocked by the check meant to protect it. So a numbered curated document
marked in the body **is already nameable**, and there is nothing for this version to narrow.

Applying the narrowing there would not be a no-op; it would be a widening. Setting `classed=1` from a
body marker would block the whole body rather than the marked section, which is more than the marker
asks for and less than the author declared.

Both directions are asserted anyway, in case 1g, so this paragraph is evidence rather than a claim:
a body-marked `05_partnerships-pipeline.md` is nameable on a surface, and a verbatim line of its
marked section on the same surface is an error.

## 3. What the frontmatter narrowing actually changes, which is more than the brief said

Worth recording because it is the trade a deployment meets. Before this change, the frontmatter
branch emitted `I` and **did not** set `classed`, so a note restricted in frontmatter had its name
blocked and **none of its text blocked at all**. After it, on a numbered curated document, the text is
blocked and the name is not. The exchange is therefore not "name for nothing"; it is
**name-protection for content-protection**, which is what the marker was asking for in the first
place and what crossing law 3 says the answer should be.

Two consequences follow, and neither is hidden:

- A `changes/` proposal that quotes a verbatim line (16 characters or more) of a restricted numbered
  document is now an error where it was not. That is the check doing its job.
- The live case the harvest came from may therefore still fail its scan — on a **different and
  correct** finding — if the directive that restricts the claim also quotes it. That is an estate
  action under that hub's own governance, not something this version can or should reach.

## 4. The corrections predicate, and one departure from the handed-over design

The predicate is `not scaffold` **and** `carries a rule:` **and** `lifecycle: active`. `rule:` is the
discriminator this standard already names: §"`rule:` is the whole point" says a correction that
produces no rule is probably an ordinary edit and not a `Correction`. The v1.19 section that
introduced the block already specified the count as the active notes *whose `rule:` is in force*, so
this is the implementation being brought up to its own published specification rather than a new rule.

The loop is a loop and not a pipeline for the reason the handed-over design gives, and it is the right
reason: hub and estate paths contain spaces, and an `xargs` formulation silently returns 0 on such a
path. The `[ -f "$_f" ] || continue` guard is added on top of it, so that an empty directory — where
the glob does not expand — is counted as zero rather than as one non-existent file.

**The departure.** The handed-over design's scaffold arm read
`README.md|index.md|template.md|DIGEST*.md`. Three things about that did not survive verification.

- `template.md` is the wrong case. The standard's scaffold set is `README.md`, **`TEMPLATE.md`** and
  `hub-manifest.md` (§"Currency of generated documents"), and the scan already implements exactly
  that set in `skip_doc`. A second, differently-cased scaffold list inside the same script is the
  drift the standard explicitly warns against there: *"this is the same definition of a document that
  every other check in `hub-scan.sh` uses, and it is stated here so the two cannot drift apart."* The
  arm now uses the standard's own set, plus `index.md`.
- `index.md` is kept, and it is the one addition that earns its place independently: `build-indexes.sh`
  has emitted `lifecycle: active` into every generated index since v1.15, by construction, so a
  generated index is the second shape that reads as current while asserting nothing. The pass-1 walk
  of `[ RESTRICTED ]` already skips `*/index.md` for a related reason.
- `DIGEST*.md` was **dropped**, and this is a judgement rather than an oversight. The standard defines
  no such artifact anywhere, so writing the pattern here would put a filename convention belonging to
  one deployment's directory into a canonical check — the hand-maintained memory of directory state
  that this standard already records as the artifact class that rots. It was also verified to be
  inert: all four `DIGEST*.md` files in the measured registry carry **zero** `^rule:` lines, so the
  `rule:` arm already excludes them and the name arm would never have fired.

**The residual is registered rather than closed**, in the check's own comment and in the standard's
text: a *derived* digest of the registry that rendered `rule:` and `lifecycle: active` at column zero
would be counted, because nothing in the evidence distinguishes it from a note. The repair for that
case belongs in the generator that writes it, or in naming the artifact under the scaffold set.

## 5. The printed line

The check's own comment and its output line were rewritten together. A line reading *every
lifecycle: active note's rule: is in force in this hub* describes a predicate the block does not run,
and a check whose printed claim outruns its predicate is the defect one layer above the count. The
line now names the three arms, and `tests/test_corrections_binding.sh` asserts the line as well as the
number, so the two cannot drift apart silently.

`(N active)` became `(N active rule(s))` for the same reason: the number is a count of rules in force,
not of current documents, and the unit belongs in the line that carries it.

## 6. What was explicitly not done

- **`lifecycle: active` was not removed from the registry's `README.md`.** That edits the data until a
  broken counter accidentally agrees, and the next scaffold file added reproduces the defect. It is
  also estate content, outside this tier's write boundary.
- **No hub was edited, dispatched to, or re-deployed into.** The ledger item this answers names two
  acts and only the canonical narrowing is here.
- **No `type: Correction` predicate was adopted**, though it was considered as a more principled
  discriminator than `rule:`. The measured registry carries both `type: correction` and
  `type: Correction` in the same directory, so a `type:` predicate would be case-fragile against real
  data, and `rule:` is the discriminator the standard already names.

## 7. Sweeps

Recorded in full, including the findings of none, in `tasks.md` §5 and in the v1.57 ledger row. Each
class returned exactly one instance and it is the one repaired. One near-neighbour is registered
rather than repaired: the cockpit renders a hub's registry membership in a column it also calls
`lifecycle`, which is a naming collision over a different property and not a false predicate.
