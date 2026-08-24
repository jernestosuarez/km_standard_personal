# Design

## Context

Audit finding **F-07** of 2026-08-22 said that `README.md` advertised a reuse grant the repository
could not give. v1.49 answered the honesty half and deliberately left the substance half open: it
withdrew the operative claim, preserved free adoption as the owner's stated intent, recorded that no
`LICENSE`, `COPYING` or equivalent existed and that default copyright therefore applied, and stated
that choosing a licence belonged to the deployment owner. Its tasks record the maintainer declining
to select one, on the ground that selecting a licence chooses the grant, the warranty position and
the patent position on the owner's behalf, and that this is his decision and a legal one.

That decision has now been taken by him. He accepted the recommendation of Apache-2.0 and confirmed,
asked directly, that he is the author and the copyright holder. This change implements it.

The situation this design has to hold steady is that **the word "licence" names two different objects
in this repository**, and they have been carefully kept apart since v1.39. One is the repository, a
tree of files with a copyright holder. The other is the standard, a body of doctrine that says the
run/evolve boundary carries no licence, price or commercial term for any deployment. Putting a
`LICENSE` file in the tree changes the first and must not touch the second. Every decision below is
downstream of that.

## Goals / Non-Goals

**Goals**

- Put the complete Apache License 2.0 in the tree, unmodified, with the owner named as copyright
  holder, and put the grant into force.
- State on the landing page what an adopter may rely on, in the licence's own terms.
- Withdraw the no-attribution claim, which Apache-2.0 makes false.
- Record the decision, its reasoning and its authority where the standard already speaks about
  licensing, without weakening by one word the doctrine that section exists to protect.

**Non-Goals**

- Choosing the licence. That was done by the owner and is implemented here, not decided here.
- Asserting anything about how a deployment licenses its own knowledge, hubs or estate.
- Changing the editions boundary, the component mapping, or anything a Consumer edition does.
- Adding a check. See Decision 4.
- Giving legal advice. Nothing in this package is any, and nobody who wrote it is qualified to.

## Decision 1: Apache-2.0, and the reason is the patent grant

The recommendation the owner accepted rests on four reasons, in descending weight.

1. **The express patent grant, Section 3.** This is the deciding one. This repository publishes a
   **specification** that other organizations implement. An implementer of a specification needs
   certainty that the specifier will not later assert a patent over the thing they were invited to
   build, and Section 3 gives it: an irrevocable grant from each contributor over their own
   contributions, paired with a defensive termination clause that ends the grant for an adopter who
   brings patent litigation over the work. MIT is silent on patents and CC0 explicitly declines to
   grant them. For a licence over prose that is meant to be implemented, silence is the wrong answer.
2. **Institutional legal review treats it as routine.** The likely adopters are large institutions,
   and adoption dies in legal review. Apache-2.0 is on the standing approved list of essentially
   every organization that keeps one. A licence that triggers a bespoke review is a licence that is
   not adopted.
3. **It does not obstruct the editions boundary.** v1.39 published a boundary drawn cleanly enough
   that an owner **MAY** later attach a commercial policy at the line, for example treating the
   evolve-set as owned or paid, without the standard encoding any such policy. Permissively licensing
   the repository that carries the run-set leaves that option exactly where v1.39 left it: a policy,
   if one is ever written, binds only the parties who accept it and lives in the owner's own terms.
4. **One licence over the whole repository.** The alternative, a documentation licence over the prose
   and a code licence over the code, was considered and rejected on the tree's actual shape: 147
   markdown files and 41 code files, with `template/`, `skills/` and the scaffolds being
   specification and implementation at once. A split would put the boundary through files rather than
   between them, and every maintainer afterwards would have to decide which side a new file fell on.
   Apache-2.0 is drafted to cover both ("Work" is source or object form, documentation included).

## Decision 2: three paragraphs, because the distinction is the thing at risk

This is the load-bearing decision in the package.

§"The boundary asserts no license" opens with a hard requirement: the standard asserts no license,
price or commercial term. v1.49 added a note under it recording that the repository had declared no
licence, and took care to say that the note "records the state of one repository and places no rule
on any deployment, which would be the license assertion this section forbids." That care was cheap
when the recorded state was *no licence*, because a note saying nothing had been granted could hardly
be read as granting anything.

It is not cheap now. A note saying "this is licensed Apache-2.0", sitting three paragraphs under a
sentence saying "the standard asserts no license", is exactly the shape a careless reader collapses.
The failure mode is concrete and it is not hypothetical: an adopter concludes that adopting this
standard obliges them to license their own hub, their own knowledge, or their own estate under
Apache-2.0. Nothing of the sort is true, and a single ambiguous sentence in the governing document is
enough to make an institution's counsel say no.

So the note is written in three paragraphs that hold the two objects apart on the page rather than
relying on a reader to hold them apart in their head:

1. **The repository's licence.** What it is, where the text is, that the owner selected it and
   confirmed authorship, and why Apache-2.0.
2. **The separation, stated plainly.** Two different things are called a licence here; the repository
   carries one; the standard asserts none, on any deployment; these are separate facts about separate
   objects. It names what does not change: no line of the boundary, no row of the component mapping,
   nothing a Consumer deployment does, and nothing about how an adopter licenses their own material.
   It closes by conceding the test rather than asserting immunity from it: if this note ever began to
   read as an assertion, the note would go and the doctrine would stay.
3. **The state before this one, kept as the record of it.** The v1.49 substance is preserved in the
   past tense rather than deleted, so a reader who arrives from the v1.49 row or from a fork of an
   older revision finds the transition explained instead of a contradiction to resolve.

Everything above the note is left word for word. The hard requirement, the "MAY later attach a
policy" clause, the "policy binds only the parties who accept it" clause, and §"What this section
does not do", whose first bullet still reads *"It asserts, encodes, or implies no license, price, or
commercial term"*, are all still true and all untouched. That bullet is the check on this decision:
if the edit had made it false, the edit was wrong.

`README.md` carries the same separation, in one short paragraph, because the landing page is where
most readers meet the question and a pointer into a 4700-line document is not an answer.

## Decision 3: no delta spec, and `openspec validate --strict` will fail

This package has `proposal.md`, `design.md` and `tasks.md`, and no `specs/` directory.

The question a delta spec answers is "what new requirement does this change place on the system?"
The answer is none. Declaring a licence for one repository places no obligation on any deployment,
any hub, any agent or any conforming implementation. It changes what a reader of *this tree* may do
with *this tree*, which is a fact about an artifact rather than a rule in a standard.

The alternative is worse than a failing validator, and it is worse in a specific way. To write a
delta here, one would have to express the change as a requirement, and the only requirement in the
neighbourhood is licence-shaped. Adding a licence-shaped requirement to this standard's normative
surface is precisely what §"The boundary asserts no license" forbids and what §"What this section
does not do" promises no later version will do. Feeding the validator a fiction would therefore
break the doctrine this very change is written to protect.

`openspec validate audit-licence-declared --strict` will fail with `Change must have at least one
delta. No deltas found.` That is recorded as the expected and honest outcome. `openspec/` is read by
no check in this repository: `tools/km-release-gate.py` is the verification that governs publication
here, and both `validate_published_not_draft.py` and `validate_rfc_references.py` carry `openspec` in
`SKIP_DIRS`. Precedents: `audit-licence-honesty-and-record` (Decision 4) and
`audit-spec-filename-convention`.

## Decision 4: no check, and it is the same argument v1.49 made from the other side

v1.49 considered a `LICENSE`-file check and recorded that it could not land, because it would have
been red on the repaired tree from the moment it landed. That obstacle is gone. The check would now
be green. It is still not worth adding, and the reason is worth writing down because it is the more
general one.

A `LICENSE`-existence check proves that a file exists. It cannot read the file, cannot know which
licence it contains, and cannot compare that against the four other places this repository now makes
a licence claim: the badge, the README `alt` text, the README section body, and the note in
`STANDARD.md`. The whole of the F-07 class was **claims disagreeing with the operative document**,
and a check that watches only the operative document's existence models the least interesting part of
it. A stronger check, one that extracted a licence identifier from `LICENSE` and required the same
string on the badge and in the README, is conceivable. It is not built here, because the identifier
lives in an SVG's text node and in two prose sentences, so the check would be a set of hand-written
extraction patterns over surfaces whose wording is meant to change, which is a check that fails for
reasons other than the defect it models.

The limit is therefore stated rather than filed: **nothing in this tree keeps a licence claim
honest.** Every prose statement in this change about what Apache-2.0 grants rests on a maintainer
having read Apache-2.0 correctly, and no gate reaches that. The release gate's own two limits apply
on top: it runs no organisation leakage scan and cannot, and it supplies no second actor.

## Decision 5: the guard will refuse this push, and it was not worked around

The deployment's canonical leakage denylist contains the owner's own name. It is there for a good
reason: the denylist is generated from the deployment's own entity names, and the owner is an entity
in it. The copyright line this version exists to add therefore matches the fail-closed pre-push hook,
which scans the message and the diff of every outgoing commit and refuses the push on any hit.

Three responses were available and two were refused.

- **Alter the name to slip past the guard.** Refused. A copyright notice that does not name the
  copyright holder is not a copyright notice, and defeating a control by deforming the thing it
  examines is the move v1.49 refused when it declined to edit an external report so that it would
  pass a scan.
- **Disable, narrow or bypass the guard from here.** Refused. This repository is not where that
  decision lives. Weakening a fail-closed control to get one commit out is how a control stops being
  fail-closed, and the guard protects every other push.
- **Build the change correctly and leave it unpushed until the deployment that owns the denylist adds
  a narrow, reasoned exclusion for its own owner's name in its own overlay.** Taken. That work is not
  in this repository and is not in this package.

The leakage run on this change is expected to report hits on the owner's name in `LICENSE`, `NOTICE`
and `README.md`, and those hits are reported as a finding rather than cleared. A hit that the guard
is right to raise and that a human is right to allow is the case a fail-closed guard is supposed to
produce, and the correct handling of it is a decision recorded somewhere, never a pattern quietly
edited.

## Risks / Trade-offs

- **The distinction collapses in a reader's head anyway.** Mitigated by Decision 2 and by the same
  separation on the landing page, and not eliminated. No instrument can detect a reader's
  misreading. If a real adopter ever reports this confusion, the remedy is to move the separation
  earlier in the section, not to withdraw the record.
- **Apache-2.0 is irrevocable for what has already been published.** That is the point of it and it
  is what an adopter relies on, but it means the owner cannot un-grant v1.53 later. He can license
  future versions differently; he cannot claw this one back. Stated because it is the one
  consequence of this change that cannot be corrected in a later version.
- **The copyright year is 2026 and the repository's history begins in 2026.** Verified from the first
  commit's author date rather than assumed. A later year is added by whoever publishes in it.
- **The licence claim rests on prose, and prose rots.** See Decision 4. This is the standing limit.

## Migration Plan

None. No shipped surface changes, no hub installs `LICENSE` or `NOTICE`, no check changes, and no
deployment has to do anything. A deployment that re-pins to v1.53 gains a licence over the standard
repository it pinned and gains no obligation.

## Open Questions

- **`rfcs/RFC-006-editions.md`** carries a status note added at v1.49 that states the pre-v1.53
  licence position in the present tense. It was left alone here, deliberately: `rfcs/` is out of the
  publication-status check's declared scope because an RFC is a dated design record, the note names
  v1.49 and therefore reads as of v1.49, and the v1.45 rule is that a dated record corrected to agree
  with the present is falsified rather than repaired. The counter-argument is that the note's own
  purpose is currency, and that a fork's reader landing there is told the repository has no licence.
  If a dated v1.53 sentence is wanted, it is a one-line addition to that banner and it should be made
  by the version that publishes, so the marking is cleared by the same act that clears the others.
  Recorded here rather than decided, because no check in the tree will surface it later.
- **A second actor.** No adversarial pass by anyone other than the author has been made against the
  specific class this change touches, which is a licence claim disagreeing with the operative
  document across five surfaces. The gate cannot supply one and does not pretend to.
