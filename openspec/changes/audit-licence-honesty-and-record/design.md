# Design

## Context

A fork is the moment every document in a tree stops having an author within reach. Three things in
this repository fail that test in three different ways, and none of them is a bug in code.

```
README.md:111        This standard is free to adopt, adapt, fork, and redistribute for any
                     organization's internal or external knowledge management needs. No
                     attribution required.
                     ls LICENSE COPYING LICENCE LICENSE.md  ->  no such file
                     assets/badges/license.svg  ->  "free to adopt"
                     README.md:16  alt="license: free to adopt"
                     STANDARD.md (closing line)  ->  "free to adopt, adapt, and redistribute"

openspec/           37 files, 9 change packages, untracked
                    every proposal names an external QA report of 2026-08-22 as its source
                    that report  ->  excluded by an ignore rule that was never committed

template/README.md:73  Full governance reference: AI KM Hub Standard (available from the hub
                       owner).
                       grep -r "AI KM Hub Standard"  ->  no such document anywhere in the tree
```

The first is the one with consequences outside the repository, and it is also the one where the
maintainer's correct move is to do less rather than more. The owner wants free adoption. The defect
is that wanting it does not grant it. So the repair states both halves and chooses nothing.

## Goals / Non-Goals

**Goals:**

- Quote each false statement as it stood and repair it minimally.
- Preserve the owner's stated intent word for word while withdrawing the implication that it is in
  force.
- Put the honest statement where a reader meets the claim, on all four surfaces that carried it.
- Record that the licence decision is outstanding and the owner's, in the place the standard already
  speaks about licensing.
- Commit the remediation record, after checking every newly tracked file against the deployment's
  leakage denylist rather than assuming untracked material is clean.
- Decide what to do about the external report on the evidence the scan produces, and record the
  decision where a reader will meet the absence.
- Name the governing document in the hub template by a route a fork's reader can walk.

**Non-Goals:**

- Selecting a licence. See Decision 1.
- Adding a `LICENSE` or `COPYING` file of any kind, including an empty or placeholder one.
- Writing anything that reads as legal advice.
- Adding a check. See Decision 3.
- Editing the external report so that it passes a scan. See Decision 5.
- Exempting, narrowing or otherwise weakening the canonical leakage guard. See Decision 5.
- Refreshing or re-verifying the nine committed change packages. They are a record of what was
  proposed, and a record edited to agree with the present is no longer a record. One of them poses
  the tracking decision as open; it is left posing it, and the resolution is recorded in the ignore
  rule and the version row instead.

## Decision 1: state both halves and choose nothing

The owner's instruction is to soften the claim and he has not chosen a licence. Three repairs were
available and only one of them is honest.

| Option | Why not |
|---|---|
| Add a permissive licence matching the intent | The maintainer would be choosing the grant, the warranty position and the patent position on the owner's behalf. It is his decision and a legal one. |
| Delete the reuse paragraph | It would withdraw the owner's stated intent, which he holds. Silence about a licence is what the tree already had, and it is what produced the finding. |
| State the intent, state that no licence is declared, state what applies until one is | Both halves are true, and a reader learns in one sentence what may and may not be relied on. |

The third is taken. The first sentence of the repaired section carries the operative fact, because a
reader who reads one sentence should read the one that governs. The intent follows it, named as
intent, so nothing the owner wants is lost.

The badge changes from `license: free to adopt` to `license: pending`, and the README `alt` text
matches. A badge is read in a fifth of a second and it was the shortest false statement in the tree.
`pending` is honest in both directions: it says no licence is in force, and it says a decision is
expected rather than refused.

## Decision 2: four surfaces, because the claim was on four

The claim did not live in one place. `README.md`'s licence section, the README `alt` text and the
badge image are three, and they are the three a fork's landing page shows. The fourth is
`STANDARD.md`'s closing line, which repeated it in the document that is actually normative, and the
clause inside "The boundary asserts no license" that said the standard is "a license-neutral
description of a boundary that anyone may adopt for free". Repairing the README and leaving those two
would have left the standard itself making the claim the README had just withdrawn.

`STANDARD.md`'s "The boundary asserts no license" section is also the natural home of the record that
the decision is outstanding. It is where the standard already speaks about licensing, it already
hard-requires that the standard assert no licence, and a note recording the state of this one
repository sits inside that requirement rather than against it: recording a repository's own state
places no term on any deployment. The note says so in its own words, so a later reader does not have
to work out whether the section has started asserting the thing it forbids.

## Decision 3: no check, and this is the argued half

The standard's own instruction is that a version adding or editing a check must prove it in both
directions and record what it found against the unrepaired tree. That obligation makes adding a
check expensive on purpose, and it makes adding the wrong check worse than adding none.

Three candidate checks were considered.

1. **Require a `LICENSE` file when the README claims a grant.** This is a real, mechanical class, and
   it is the one instrument that would have caught F-07. It cannot be added here: the owner has not
   chosen a licence, so the check would fail on the repaired tree from the moment it landed. A check
   that is red by construction is a check that gets switched off, and it takes the real checks with
   it. It becomes available the day a licence is declared, and it is named here for that day.
2. **Forbid grant-shaped wording anywhere in the tree.** This models word choice, not truth. The
   repaired README still contains "free to adopt, adapt, fork, and redistribute", correctly, as a
   statement of intent. A pattern check would fire on the honest sentence and pass on a dishonest one
   written in other words.
3. **Resolve prose references to named documents.** This is Part C's class, and it is worth stating
   precisely what already covers it. `scripts/validate_rfc_references.py` does **not** cover it. That
   check derives its known set from the filenames in `rfcs/` and matches three written forms of an
   RFC identifier: a bare `RFC-NNN`, a code-formatted `rfcs/RFC-NNN`, and a path naming a file. "AI
   KM Hub Standard" is none of those, so the check was green over line 73 for as long as the line
   existed, and it is green over it now. The general class, a document named in prose by a title
   rather than by a path, has no derivable known set: there is no directory to read the titles out
   of, so any check over it would carry a hand-maintained list of acceptable names, which is the
   artifact class this repository has already recorded as the one that rots.

So no check. A licence claim and a document reference are prose judgements, and the evidence that
would settle either is not in the tree. This is the same posture v1.48 took toward F-11 and F-12, and
it is stated in the version row rather than implied away by a green gate.

## Decision 4: no delta spec, and `openspec validate --strict` will fail

This package has `proposal.md`, `design.md` and `tasks.md`, and no `specs/` directory. That is
deliberate, and the consequence is stated rather than worked around.

The question a delta spec answers is "what new requirement does this change place on the system?"
Here the answer is none.

- Part A repairs a false statement in published text. The requirement that published text says only
  what the system does was added in v1.48 and is already in `STANDARD.md`'s Standard Maintainer
  section: *a document is held to what the system does, and a shipped document most of all.* Part A
  is an instance of it, in the same way that a bug fix is an instance of the tests that already
  exist.
- Part B commits a record so that the references to it resolve. The requirement that a reference is a
  promise the reader can open the thing named was added in v1.45 and has an instrument behind it.
  Part B is an instance of that one.
- Part C is a second instance of the v1.48 rule, and one that the v1.48 agent explicitly deferred to
  this version rather than folding in silently.

Writing a delta spec would therefore mean either restating a published requirement as though it were
new, which puts one obligation in two places and guarantees they will diverge, or inventing a
licence-shaped requirement, which is exactly the assertion `STANDARD.md`'s editions section forbids
and would be far worse than a failing validator.

`openspec validate audit-licence-honesty-and-record --strict` will fail for want of deltas. That
failure is the honest outcome. The tool models a change as something that alters requirements, this
change alters no requirement, and the correct response to a tool that cannot express "purely
corrective" is to record what it said, not to feed it a fiction. The release gate,
`tools/km-release-gate.py`, is the verification that governs publication in this repository, and it
does not read `openspec/`.

## Decision 5: a fail-closed guard refused a document that is not leaking

This is the finding of the change, and it was produced by doing the verification rather than by
reasoning about it.

The material under `openspec/` had never been scanned. The canonical leakage instrument enumerates
**tracked** files, and these were untracked, so they sat outside every previous scan's scope by
construction, which is why the scan was run before staging rather than after. Scanned file by file
against the deployment's generated denylist with the pre-push hook's own matching semantics,
whole-word, case-insensitive for the 750 case-insensitive entries and case-sensitive for the 10
case-sensitive ones:

- the 40 files under `openspec/` produce **zero hits on both halves**. The record carries nothing;
- the external QA report produces **one case-insensitive hit**. A single word in one heading is a
  denylisted entity name in the deployment's semantic layer and an ordinary English verb in the
  sentence where it appears.

The guard is not wrong. It cannot distinguish the two senses of a word, and it is whole-word and
fail-closed precisely because no human reads several hundred denylist entries against a diff. A
control that refuses a document that is not leaking is the expected cost of a control that never
lets one through quietly.

Four resolutions were available. Three were refused.

| Option | Why not |
|---|---|
| Edit the report so the scan passes | It is external evidence. Altering a document to satisfy a control that examines it inverts what the control is for. |
| Exempt the term, or narrow the guard | The exemption is permanent and it protects every later document that uses that name in its real sense. A guard weakened once for convenience is a guard nobody trusts. |
| Drop the report and leave the citations naming it | This recreates the dangling-reference class that v1.45 published a check to close. |
| **Keep the report out, commit the record, and repair the citations** | Costs least and hides nothing. The record is published, the report stays in the deployment's own files, and no reference names a path a reader would try to open. |

The fourth is taken. Three things follow from it.

**The ignore rule is committed this time, with its reason.** The rule was never in the committed
`.gitignore`, verified by reading the file at `main` (`ec51128`), which has twelve lines and no such
rule. It had lived as an uncommitted working-tree modification carried across sessions, which means
the exclusion depended on one machine's working tree and would not have survived a clone. A decision
this deliberate should not be invisible, so the rule is committed with a comment stating what the
document is, where it is held, and why editing it or weakening the guard were both refused. A reader
who wonders why the audit is absent finds the answer in the rule rather than nowhere.

**The citations are repaired rather than left.** Every reference in this package now describes an
external QA report of 2026-08-22 held in the deployment's records. None writes a filename or a path.
The nine existing packages already described the audit that way and named no path, which was checked
rather than assumed, so nothing in them needed changing on that count.

**The report never enters history at all.** Removing a file in a later commit does not help here: the
pre-push hook scans the diff of every outgoing commit, so a blob committed once and deleted twice is
still transmitted and still refused. The two commits of this change were therefore rebuilt from
`main` rather than corrected forward, which was available because neither had been pushed.

## Risks / Trade-offs

- **The repaired README is less inviting.** A fork's reader now learns that no grant is in force.
  That is the point: the previous text was inviting and wrong, and a reader who acted on it had no
  way to know. The mitigation is that the intent is stated plainly and the decision is named as open,
  so a reader who wants the grant knows there is someone to ask and what to ask for.
- **`license: pending` will go stale if no decision is made.** It is honest for as long as no licence
  exists, which is unbounded, and it is not honest as a permanent state of affairs. Nothing in the
  tree can fix that; only the owner can.
- **A fork gets the reasoning without the assessment that prompted it.** Nine packages describe an
  external report the reader cannot open, because it is held in the deployment's own records. That is
  a real loss and it is preferred to the alternatives in Decision 5. The packages carry their own
  findings in their own words, so the reasoning survives the absence.
- **The exclusion depends on a term that may leave the denylist.** The denylist is generated from the
  deployment's semantic layer; if that entity is ever removed, the report becomes committable and the
  ignore rule becomes a rule with a reason that no longer holds. The comment states the reason so
  that a later maintainer can tell.

## Migration Plan

None. No deployment action is required. A hub that has already installed `template/README.md` keeps
its old governance-reference line until it refreshes the file, which is an adoption act under that
hub's own governance.

## Open Questions

- The licence itself. Open, and the owner's.
- Whether the `LICENSE`-file check named in Decision 3 should be added on the day a licence is
  declared. Recommended, and out of scope here.
