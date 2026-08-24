# Design

## Context

The repository is about to be forked. A fork is the moment every document in a tree stops having an
author within reach: whatever a page says is what a reader gets, and there is no session, no estate
and no maintainer to correct it. Three audit findings describe pages in exactly that state.

```
template/README.md:64   Run `bash hub-scan.sh` at the start of every session. It checks all
                        four rules in one pass.
                        STANDARD.md:690,741,805,1015,1027,1073  → six `### Rule N:` headings

template/README.md:78   **Find a fact:** open the relevant numbered doc, or ask the agent to
                        search across hub docs
                        template/06_risks-decisions.md:15  → "Individual risks and decisions are
                        tracked as entity notes in `risks/` and `decisions/` — this doc is the
                        narrative rollup and reading order."

STANDARD.md:138         A lightweight governance layer sits on top of the format. It enforces
                        six rules ...
                        template/hub-scan.sh  → 17 blocks, none of them Rule 5
                        DESIGN-RATIONALE_akcp-component-mining.md:65  → "a source-traceability
                        rule enforced by *discipline* ... Nothing records *lineage* (where each
                        fact came from) as a checkable artifact."

docs/architecture/README.md:11   These documents describe the architecture the KM Standard
                                 implements as of **v1.22** ...
README.md:72                     | `docs/architecture/` | Architecture documentation: the layer
                                 model, ... Descriptive, not normative. |
```

This is the fourth appearance of one class. v1.42 repaired published sections telling readers a
binding obligation bound nothing. v1.45 repaired published text naming a document no reader could
open. v1.47 repaired published rows naming days on which nothing happened. Each of those was caught
by a reader looking at one page. So is this. The class is not "the maintainer was careless"; it is
that **a document ages independently of the system it describes, and nothing in a markdown repository
notices.**

Two of the three sit on the surfaces a fork meets first. `template/README.md` is copied verbatim into
every hub the standard creates, so its four-rule page is not one wrong page but one wrong page per
hub, forever, growing with adoption. The root README is the first file a fork opens.

## Goals / Non-Goals

**Goals:**

- Reproduce each false statement first-hand, quote it, and repair it minimally.
- Verify the two claims the brief refuses to take on the audit's word: the template's fact-finding
  model, and both halves of the Rule 5 enforcement finding.
- Add a check where one is possible and honest, and say plainly where one is not.
- Run that check against the unrepaired tree before the repair enters the working tree, and record
  the run in the declaration the gate reads.
- Label the architecture set rather than refresh it, and put the reasoning in the version row.
- Preserve every claim in the three documents that is actually true.

**Non-Goals:**

- Refreshing the architecture documents. See Decision 3.
- Building a Rule 5 provenance instrument. See Decision 2.
- A general prose-truth checker over the repository. See Risks.
- Repairing `template/README.md`'s stale reference to "AI KM Hub Standard". See Decision 6.

## Decisions

### Decision 1: The template's rule summary is checked, and the count phrase is checked with it

The audit recommends "a version/conformance test for its rule count and terminology." Half of that is
mechanically checkable and half is not. The **rule set** is: the standard declares its rules in
`### Rule N:` headings, and the template's landing page declares its summary in a numbered list under
a governance heading. Two enumerations, one derived from the other. **Terminology** is not: whether an
entry describes its rule well is a judgement, and a check that scored it would be modelling the wrong
class.

The check therefore does two things and refuses to do a third.

1. **Enumeration.** Derive the rule numbers from the standard's own headings; read the numbered
   entries under the template's governance-rule summary; require one entry per rule. On the
   unrepaired tree this fails naming rules 5 and 6.
2. **Count phrases.** Any count written immediately before the word "rules" on the landing page must
   equal the number of rules derived. This is the arm that catches the sentence the finding actually
   quotes, and it is deliberately separate: a page can carry six list entries and still tell its
   reader the scan checks four, which is the same defect surviving its own repair.
3. **Not description quality.** Stated as a limit rather than attempted.

**The rule set is derived and never held here.** There is no rule count, rule list or rule name in the
check's source. A seventh rule added to the standard fails the unchanged landing page with no edit to
the instrument, which is the property that keeps this from becoming a second hand-maintained memory of
the first.

**Scope is the hub template's landing page alone, and that is a declaration rather than an oversight.**
A sweep of the tree for count phrases finds `STANDARD.md` (the home of record the check derives
from), the v1.0 ledger row and `rfcs/RFC-001` (both dated records of what was true when written, and
falsifying them would be the defect this change repairs, inverted), and the architecture set (correct
at six). Widening the count arm across the tree would fire on the historical records, and the only
way to keep it quiet would be an exemption list, which is the artifact class the derivation above
exists to avoid.

### Decision 2: F-11 is repaired by narrowing the claim, and no check is added

The finding's recommendation offers two routes: narrow the claim, or introduce a minimal checkable
provenance record. The second is a far larger change: it needs a lineage artifact, a format for it, a
generator, a gate, an adoption path for every existing hub, and an answer to what happens to a hub
whose settled prose predates the artifact. It also needs its own authority. Narrowing the claim is the
repair this version is for.

**Both halves were verified first-hand rather than taken from the report.**

- `STANDARD.md:138` reads "It enforces six rules". Its own §"Validating the graph" already says
  "Governance (Rules 1–4) was enforced by `hub-scan.sh` from the start", so the standard contradicts
  itself two thousand lines apart, and the narrower statement is the true one.
- `template/hub-scan.sh` ships seventeen blocks. Rules 1, 2, 3 and 4 each have one
  (`[ INBOX ]`, `[ PROPOSALS ]`, `[ INTEGRITY ]`, `[ FRONTMATTER ]`). Rule 6's outbound half has one
  (`[ RESTRICTED ]`). **Rule 5 has none.**
- `[ FRONTMATTER ]` checks for `type:` and for nothing else, so the `resource:` field Rule 5 names as
  one of its rails is not validated anywhere.
- One nuance the audit does not mention and this design records rather than smoothing over:
  `[ SHAPE ]` does require `evidencedBy` on a `Claim` note and `assertion_method` on a
  `RelationshipAssertion`. That is **field presence on two optional entity types**, not validation
  that a fact in settled prose traces to a named origin, which is what Rule 5 obliges. Reporting it as
  partial Rule 5 enforcement would be the same overstatement in a smaller size, so the narrowed text
  names it for what it is.
- `DESIGN-RATIONALE_akcp-component-mining.md:65-66` says it in the repository's own words:
  "a source-traceability rule enforced by *discipline*, plus an integrity manifest (SHA-256 — *has it
  changed*). Nothing records *lineage* (where each fact came from) as a checkable artifact."

**Why no check.** The claim is prose about what other instruments do. A check that read the
enforcement sentence and compared it against a list of scan blocks would need that list, which is the
hand-maintained memory again; and it would model *whether the sentence was edited*, not whether it is
true. The honest statement is that this half of the change is verified by reading and is covered by
no instrument, and that is written into the version row rather than implied by a green gate.

**The obligation does not move.** Rule 5 binds exactly as it did. What is withdrawn is the claim that
an instrument establishes compliance with it.

### Decision 3: F-12 is labelled as a v1.22 snapshot, not refreshed

Both routes the finding offers are honest. The label is chosen, for three reasons.

**Refreshing is a substantial authoring job and it would ride unreviewed.** Nine surfaces have been
added or materially changed since v1.22: the cockpit, the projection contract, the three surfaces and
the owner queue, the supervisor threshold and minimum tier, hub merge, editions, the Reader tier, the
MCP quarantine and the release gate. Bringing six architecture pages up to those is new descriptive
prose about the current system, written inside a change whose whole discipline is *quote the false
statement, repair it minimally, change nothing else*. It would be the largest and least reviewed part
of a documentation-truth version, which is the shape of change this remediation exists to stop.

**A snapshot honestly labelled is true.** The pages are not wrong about v1.22. They are wrong only in
being presented as the current architecture, and that presentation is what this change repairs. The
document set keeps its value as the record of what the architecture was at the record-boundary
release, which is a real thing to hold and would be destroyed by rewriting it in place, exactly as
v1.45 refused to rewrite a dated design record to agree with the present.

**The label has to travel to the link.** `docs/architecture/README.md` already carries "as of
**v1.22**", and that is the disclaimer the finding says prevents a direct contradiction. It is not
enough on its own: it reads as a version stamp on a current description, and the root README's row
carries no qualifier whatsoever. So the repair is in two places, and the requirement is written as
*wherever it is linked*, because the reader who needs the label is the one arriving from the root
README and the reader who needs it most is a fork.

**What the label says.** That the set describes v1.22 and the v1.23 draft, that it is not maintained
forward, what has changed since that it does not cover, and that `STANDARD.md` is the current
normative description. Naming what is missing is the part that makes it usable rather than merely
defensible.

**No check.** Whether a descriptive document set still describes the system is exactly the judgement
no evidence in the tree represents. A check comparing the set's stated version against the current
version would fire permanently and by construction, and a permanently failing gate gets switched off
and takes the real checks with it, which this standard already records.

### Decision 4: The fact-finding claim was verified before it was repaired

The brief refuses to let the audit's second F-08 claim be taken on trust, and the verification changes
the shape of the repair.

The claim holds. `template/README.md:78` says "open the relevant numbered doc", the template's own
`06_risks-decisions.md` says the opposite in its own body and frontmatter, and `STANDARD.md`
§"One instance, one file" is explicit that the numbered docs "become **narrative rollups**".

It also holds **wider than the finding states**, and the wider part is the more damaging half. The
landing page's supporting-structure table lists seven paths and omits every entity-note folder the
template ships: `decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/`, `corrections/`,
`relationships/` and `claims/`, all of which are physically present in `template/` with their
`TEMPLATE.md` files. So the page does not merely point a reader at the wrong place; it never mentions
the right one. Repairing the one line and leaving the table would leave the page still teaching the
older model, which is the defect and not a smaller version of it.

The repair is therefore the line plus the table rows, and no more. The numbered-document table is
untouched, because it is true.

### Decision 5: The unrepaired-tree run is the check's own, and the other two repairs say they have none

`km-unrepaired-tree:` is required of every check in the gate's scope. The new check names v1.48 and
carries the real result of a run made against the working tree before any repair entered it, which is
`main` at `62c4e51` for the file in question. The canary suite carries the same run as its evidence
case, reading the landing page out of git rather than rebuilding a likeness of it.

The declaration is not stretched to cover F-11 or F-12. The gate can see that a declaration was made
and never that it is true, and writing one for a run that did not happen is the failure the
declaration exists to prevent.

### Decision 6: One further stale statement is reported and left

`template/README.md:66` reads "Full governance reference: AI KM Hub Standard (available from the hub
owner)." No document of that name exists in this repository; the standard is
`Knowledge Management Standard: Hub Framework`, and a fork's reader has no hub owner to ask. It is
plausibly the same class.

It is left, and reported instead. The finding names two claims, both were verified, and both are
repaired. Repairing a third on the maintainer's own initiative inside a change whose discipline is
minimality is how a truth repair becomes a rewrite, and the honest route is to name it for the next
version rather than fold it in silently.

## Risks / Trade-offs

- **The count arm is a prose pattern, and prose patterns over-fire.** Mitigated by scoping it to one
  file, by deriving the expected count rather than hardcoding it, and by proving a non-firing case.
  The residual risk is a future landing page writing a count in a form the pattern does not read,
  which the check reports as *no count found* on the coverage line rather than as a pass.
- **Two of the three repairs are covered by no instrument.** Stated rather than mitigated. F-11 and
  F-12 are held by this document, the version row and a reader.
- **The snapshot label can itself go stale.** It cannot, in the sense that matters: it names a
  version, not a currency. What can go stale is the list of what has changed since, and that list is
  written as of v1.48 and dated by the row that carries it.
- **A hub that already installed the four-rule page keeps it.** Re-pinning rewrites no installed file.
  Refreshing is an adoption act under each hub's own governance, and the version row says so.

## Migration Plan

None required. No obligation is added or withdrawn, no schema changes, and no check runs in a hub. A
deployment refreshes `template/README.md` when it next installs from the template.

## Open Questions

None. The one deferred item, Decision 6, is named rather than left open.
