---
type: reference
title: RFC-004 — Feeding the harness, merging hubs, and what multi-tenancy would have to settle first
description: Design document for three gaps named by a deployment owner. Part I designs the harness projection — the hub definition becomes the home of record for the facts its agent-instruction files restate, projected into bounded marked regions and checked for drift, never generated whole. Part II designs hub merge as absorb-and-tombstone under a re-run interview, with two lighter cases routed away from it. Part III finds multi-tenancy premature and states what must be settled, by whom, before any design is possible. No normative change rides this RFC.
tags: [rfc, agent-instructions, projection, hub-merge, multi-tenancy, drift, coverage]
timestamp: 2026-08-19
---

# RFC-004 — Feeding the harness, merging hubs, and multi-tenancy

> **Status: DRAFT — design document only.** As with RFC-003, **no normative edits ride this RFC**:
> no `STANDARD.md` change, no version-history row, no schema, template, script, or skill change.
> Everything below is design awaiting a later, separately authorized normative change and owner
> push; nothing binds any deployment.
>
> **Authority and path:** a deployment owner named three gaps in the knowledge design (2026-08-18)
> and has not yet been asked to decide anything about them. The supervisor tier dispatched the
> maintainer to design rather than implement, and to say honestly which of the three is not ready.
> **No design statement in this RFC is owner-ruled.** The gaps are the owner's; every mechanism
> below is the maintainer's, drafted so it can be argued with.

## Provenance discipline

The evidence hierarchy applies to the standard's own design statements, as in RFC-002 and RFC-003.
Every statement below carries one tag. The vocabulary differs from RFC-003's because the authority
does: there is no owner ruling here to carry.

| Tag | Meaning |
|---|---|
| **[OWNER-NAMED]** | The gap itself, as the owner stated it. Fixed. Nothing about its solution is fixed by it. |
| **[EVIDENCED]** | A maintainer design call resting on a defect verified first-hand in a deployment, cited where it is made. |
| **[DIRECTIONAL]** | A maintainer design call beyond the evidence. Drafted concretely so it can be tested and revised by operational evidence or the owner's word. |

## Verdicts

| Part | Gap | Verdict |
|---|---|---|
| I | The knowledge system should feed the harness | **Designed**, in a narrowed form. The broad form is not what the evidence supports, and building it would repeat a demonstrated failure. |
| II | Hub merging | **Designed.** Every primitive already exists in the standard; none of them has been combined, and two of the three cases people call "merge" should be routed away from the mechanism entirely. |
| III | Multi-tenancy | **Premature.** The word carries three readings whose designs diverge at the first line. §III states what must be settled and by whom. |

---

# Part I — The harness projection

> **Status addendum, 2026-08-20 (added after the fact; the design below is unchanged).** The owner
> decision this Part said it needed first — *which file is the home of record* — was answered:
> `km-deployment.md` is the home of record, `CLAUDE.md` and `AGENTS.md` carry a projected copy in
> bounded marked regions, and drift is reported and never repaired. Part I was taken to a drafted
> standard version on that ruling: **v1.32, drafted and unpublished**, on branch
> `v1.32-harness-projection`. Three design calls below were **narrowed** on contact with the drafted
> check, and the version records each: `hub-owner` is not projected (it is an inline substitution
> occurring nine times per file, not a bounded block); the declared-skill-set list of §5 was not
> taken, because comparing the two installed runtime trees to each other covers the same evidence
> without adding a hand-maintained manifest; and "unclaimed class" is a coverage number rather than
> an advisory, because a low projection count is the healthy state. Parts II and III are untouched
> by that version and remain design only.

## The gap as named

> A KM deployment ought to define the guardrails and skills the agents work inside, rather than the
> agents' instructions being maintained separately from the knowledge that should be shaping them.
> **[OWNER-NAMED]**

## Two defects, one shape

The gap is real, and the evidence for it is sharper than the framing. Two failures were verified
first-hand in one deployment; they are the same defect seen from opposite sides.

**First, the instruction files are not a superset of the template, and are not close to one.**
**[EVIDENCED]** A retrofit wave across seven hubs found each hub carrying between four and eight
sections for which the shipped template has no counterpart at all: a date-gate procedure, a source
traceability section, a corrections-are-binding section, a lifecycle section, four separately
attributed estate-wide bindings, and — in one hub — seventy lines of owner-authored audience
routing found nowhere else in the standard, the deployment, or that hub. A directive written on the
assumption that the template was the superset would have deleted owner-authored text, and was
refused by the receiving agents for exactly that reason.

**This is the upper bound on any design here, and it is a hard one.** Any mechanism that generates
an agent-instruction file whole is wrong in the way that directive was wrong. The instruction file
is where a deployment's local judgement accumulates, and most of what accumulates there has no
source anywhere else.

**Second, where a fact does appear in two places, the two copies drift, and they drift within
days.** **[EVIDENCED]** The initiation interview substitutes the same elicited facts — the
admission rule, the exclusions, the hard exclusions, the routing keywords, the sensitivity posture
— into *both* the hub definition in `km-deployment.md` *and* the agent-instruction files, at
initiation, once. Nothing keeps them equal afterwards. In one hub the admission rule was widened by
a recorded owner ruling, and the widening was written into the instruction file and not into the
hub definition, so the estate's own registry-reading surfaces attribute sources by an admission rule
the owner has already superseded. In a second hub the divergence runs the other way: the hub
definition carries four out-of-scope clauses, each naming the fact's true home hub, that the
instruction file does not have. Both files were produced by one interview, one day, from one set of
answers.

**The standard already names this defect and confines the naming to one place.** The Agent Tier says
it of agent definitions:

> Two copies of a rule agree on day one and drift silently afterward; a single home of record does
> not. If a definition needs to say what "in scope" means for its hub, that sentence belongs in
> `CLAUDE.md`; the definition links to it rather than repeating it.

The agent-instruction file is the largest violation of that rule in the standard's own template, and
the rule points the wrong way for it: `CLAUDE.md` is named as the home of record for what "in scope"
means, while `km-deployment.md` is where the interview records it, where the quarantine gate checks
it, and where every registry-reading surface reads it. The standard has two homes of record for one
fact class and has not noticed.

## What the mechanism is

**The projection contract, turned inward.** **[DIRECTIONAL]**

The standard already defines a projection contract for surfaces that consume hub content — four
gates, applied to reading sites, briefs, conversational agents, and the query surface. The
agent-instruction files are a consuming surface of hub knowledge that was never named as one. Name
them, and most of the machinery already exists.

### 1 · A closed set of projected fact classes

The hub definition in `km-deployment.md` becomes the **home of record** for the facts the
instruction files restate. The set is closed, small, and exactly the interview's own output:

| Fact class | What it governs in the harness |
|---|---|
| `purpose` | What the hub is |
| `scope-in` | The admission rule |
| `scope-out` | The exclusion statement |
| `hard-exclusions` | What is refused even on a routing-keyword match |
| `routing-keywords` | What reaches the hub at all |
| `hub-owner` | Who is asked when a fact is borderline |
| `audiences` | Each audience mapped to its surface |
| `sensitivity-posture` | Expected restricted classes and planned outbound surfaces |
| `owner-cadence` | Cadence and answer surface |

Closed on purpose. A fact class is added by a governed change to this list, never by a hub deciding
locally that one more thing should be projected, because an open list makes the coverage claim in §4
unmeasurable.

### 2 · Bounded, marked, projected regions

A projected fact appears in the instruction file inside a marked region naming its class:

```markdown
<!-- km:project scope-in -->
Admit a source when: <text projected from km-deployment.md>
<!-- km:end -->
```

**The generator writes only inside markers, and has no opinion about anything else.** This inverts
the default that made the retrofit directive dangerous: the template is not the superset, the
*marker* is the contract, and every unmarked line is owner-authored by definition. A hub carrying
eight sections the template never heard of is fully conformant, because the mechanism was never
told those sections exist and never looks at them.

**The generator refuses rather than guessing.** It refuses a file whose markers do not balance, a
region naming a class not in the closed set, a region whose declared source does not resolve, and a
file it could not read in full. This extends to a generator the rule the standard already applies to
a reader — anything that derives content from a read checks readability first, and builds nothing if
any input is unreadable, because a stale derived file is harmless and a confidently wrong one is
not — and it is the harder half here, since the target of this generator is a file humans author.
**[DIRECTIONAL]**

### 3 · Drift is reported, never repaired

**The projector never overwrites a divergent region on its own initiative.** **[EVIDENCED]** Either
side may hold the newer truth, and the verified case proves it: the owner's widening of the
admission rule was authored in the instruction file, so a projector that silently made the
instruction file match the hub definition would have reverted a recorded owner ruling and reported
success. Drift is a finding. The owner names which side is right, the hub definition is amended
through the hub's own governance, and only then does the projection re-run.

This is the same division the record boundary already draws for the gateway: detection automates,
resolution authority stays with the owner.

### 4 · The check states its own coverage, and this is the part that answers the manifest blind spot

A new session-start block, `[ PROJECTION ]`, with three findings and a coverage line. **[DIRECTIONAL]**

| Finding | Meaning | Class |
|---|---|---|
| **drift** | A region's text differs from its declared source | error |
| **dangling** | A region names a class or an anchor that does not resolve | error |
| **unclaimed class** | A declared fact class has no region carrying it in the instruction file | advisory |

The coverage line names, always: how many fact classes are declared, how many regions were found,
how many were compared, and how many declared classes are unprojected. It never prints "OK" without
those numbers.

**Why this shape, and what it can still not see.** The standard's stated limit on canaries is that
proving a check fires in both directions proves it fires on the class it *models*, never that it
models the right class, and the demonstrated case is a hub's hand-maintained manifest missing a row
for a governed file: the git-backed integrity check could never have caught it, because a file
absent from the manifest is invisible to a working-tree/history comparison rather than flagged by
it. The pass is the absence of a comparison that was never made.

A naive projection check has exactly that shape. It compares each region against its source and
passes; a fact that lives *only* in the instruction file, in no region and in no declared source, is
invisible to it. That is precisely the owner ruling in the verified case. A check built that way
would go green on the very defect that motivates this Part.

Three properties narrow it, and the residue is named rather than hidden:

1. **The blind spot is converted into a count.** "Declared classes with no region" is the unprojected
   set, reported every run as a number and a list. The check cannot see text it was never told
   about, but it can and does say *how much it was told about and how much of that it found*, which
   turns "the check never looked here" from a silence into a reported quantity.
2. **The evidence base is made able to represent the defect.** The integrity check could not catch
   the missing manifest row because it consults git, and git cannot represent "a row that should
   exist". Here the closed fact-class list is the evidence base, and it can represent absence
   directly: a class with no region is a statable condition, so the check is not structurally blind
   to it.
3. **The residue is stated in the same change, as an obligation on the standard rather than on the
   instrument.** The check proves that every *declared* fact class has one home and that the two
   copies agree. It cannot prove the declared list is complete — that the right nine classes were
   chosen. That is a judgement, fixed at the interview and reviewed at the hub's cadence, and it is
   the same limit the standard already states for routing keywords: the gate proves the field was
   filled, never that the keywords are the right ones. **A limit stated is not a limit closed, and
   this one is not closed.** **[DIRECTIONAL]**

### 5 · Skills: declared, never generated

The gap's second half — *the deployment should define the skills the agents work inside* — divides
into a ready piece and an unready one. **[DIRECTIONAL]**

**Ready:** the hub definition declares the **skill set the hub is expected to carry**, and the scan
reports the difference between declared and installed. This is a completeness check whose evidence
base can represent the defect (a declared skill with no installed file, an installed skill in no
declaration), which is what the manifest blind spot says was missing. It costs one list per hub and
it would have caught, mechanically, a defect this deployment found by survey: mirror skill
directories left un-backfilled across five hubs while their primary directories were fixed.

**Not ready, and deliberately excluded:** *generating* skill bodies from hub knowledge. A skill is a
procedure, not a fact; its correctness is behavioural and no check the standard ships can evaluate
it. Generating procedures from knowledge is a different and much larger design, and this RFC does
not open it.

## What this must NOT do

1. **It must not generate an agent-instruction file whole, nor treat the template as its superset.**
   Verified: seven hubs, four to eight uncounterparted sections each, including owner-authored text
   that exists nowhere else.
2. **It must not project rules — only facts about this hub.** The estate-wide bindings (evidence
   standard, currency, reporting, voice, corrections registry) are inherited **by reference**, and
   the standard already forbids copying them down, because a copied rule forks. The projection
   carries scope, audiences, owner, keywords and posture; it never carries an obligation.
3. **It must not repair drift silently.** §3.
4. **It must not claim to enforce anything.** Agent scope is convention, stated plainly as such by
   the Agent Tier, and a projection into an instruction file changes nothing about that. Describing
   this mechanism as a control over agent behaviour would be a false assurance, which the standard
   holds to be worse than an acknowledged gap.
5. **It must not become an open extension point.** An unclosed fact-class list makes §4's coverage
   claim meaningless, which converts the one honest thing about the design into decoration.

## What it costs a deployment to adopt

- **Per hub, once:** wrap the projected facts in markers — between five and nine bounded regions —
  and reconcile any divergence found while doing it. In the verified deployment that is one
  substantive reconciliation in one hub and a small number of textual differences elsewhere.
- **Per deployment, once:** one generator, one scan block, both shipped by the standard.
- **A deployment that declines pays nothing and stays green**, because the block reports "no
  projected regions declared" together with its counts, which is a coverage statement rather than a
  pass. This matters: a check that turns every existing hub red on the day it ships is a gate that
  gets switched off, and it takes the structural checks with it when it goes.
- **Ongoing:** nothing, unless a projected fact changes, in which case the cost is one edit instead
  of the current two-edits-or-silent-drift.

## The owner decision this needs first

**Which file is the home of record for the hub-definition facts?** The mechanism is the same either
way; the direction of projection is not, and it cannot be inferred.

The maintainer's recommendation is **the hub definition in `km-deployment.md`**, because that is
what the interview produces, what the quarantine gate checks, what the registry and every
registry-reading surface consume, and it is one file per hub where the instruction files are two
mirrors that must already be kept aligned by hand. But the evidence cuts the other way in practice:
when the owner widened an admission rule, he wrote it in the instruction file, because that is the
file he reads. A design that fights where the owner actually writes will lose, quietly, and the
first symptom will be drift again. This is his call, not an inference to be made for him.

---

# Part II — Hub merge

## The gap as named

> There is no mechanism for combining two hubs when an engagement turns out to be one thing rather
> than two, or when a hub was stood up too early. Today the only paths are leaving both or
> hand-moving content, and neither preserves provenance properly. **[OWNER-NAMED]**

This is designable now. Every primitive it needs already exists in the standard; none of them has
been combined, and no section names the act.

## Three cases wear one word, and only one of them is a merge

The most valuable thing the design does is refuse two of the three. **[DIRECTIONAL]**

| Case | What it actually is | Route |
|---|---|---|
| **Two hubs overlap** — they share sources, entities, or facts | A routing question | **Not a merge.** Typed references and the single-home-of-record rule already solve this, and `relationships.md` records the edge. Merging on overlap destroys two working admission rules to fix a problem references already fix. |
| **A hub was stood up too early** — little content, no answered competency questions | The value gate, answered late | **Withdrawal**, not merge. §"Withdrawal" below. Cheap, and it should stay cheap. |
| **The engagement turned out to be one thing** — both hubs have real content, history, and settled facts | A merge | §"Absorb and tombstone" below. |

Naming these is what stops a heavy mechanism being run on a light case, and stops a light hand-move
being run on a heavy one. It is also the honest application of the standard's own adoption rule: an
adoption pass that has never once returned "this should not become a hub" is not being run honestly,
and the same holds here — a merge process that never returns "these two should stay two" is a
rubber stamp.

## Withdrawal: the early-hub case

A hub with no answered competency questions never earned its existence, so the act is the value gate
arriving late rather than a structural merge. **[DIRECTIONAL]**

1. Its content re-homes as **ordinary intake** into the receiving hub: inbox, date gate,
   reconciliation pre-check, proposal, approval, commit. At this volume the standard governance flow
   is the right size and no new mechanism is needed.
2. The receiving hub's routing keywords absorb the withdrawn hub's, or sources that were reaching
   the withdrawn hub stop reaching anything. This is the one step a hand-move reliably forgets.
3. The directory is tombstoned exactly as in §"Absorb and tombstone" step 4. **Never deleted.**
4. No re-interview of the receiving hub, unless its admission rule actually changes.

## Absorb and tombstone: the real merge

Five properties. **[DIRECTIONAL]** throughout, except where the standard's existing doctrine
determines the answer, which is noted.

### 1 · Direction is declared, and a third hub is never created

One hub is the **survivor**; the other is **absorbed**. Merging two hubs into a newly created third
orphans both histories and is forbidden: it converts an act that preserves provenance into one that
discards it wholesale, which is the failure the owner named.

The survivor is chosen on **whose competency questions survive**, not on size, age, or content
volume — the questions are the only thing in the standard that measures a hub's worth, and a merge
is precisely the moment worth is being re-decided. The owner decides; both hub definitions record
the direction and the authority.

### 2 · The interview runs again, on the survivor

A merge changes what the hub *is*, so it changes the hub definition, so the initiation interview
runs again and re-stamps `initiation-interview`. This follows from the standard's existing rule that
a hub's definition is produced and never assumed, applied to the one event that most changes it.

The union of the two hubs' answers is the **pre-fill**, presented with its source, and never the
answer — the standard's pre-fill rule applies unchanged, and it applies hardest here:

- **The union of two admission rules is almost never the right admission rule.** If it were, the two
  hubs would not have needed merging. A merged hub whose scope guard is the literal concatenation of
  the two originals is the tell that the merge was structural bookkeeping and not a decision.
- **Routing keywords must be the union**, or sources stop arriving. This is the mechanical half and
  it is the half hand-merges lose.
- **The sensitivity posture is the stricter of the two, and is elicited, not computed.** Two hubs
  merging usually had two audiences.

Because it is an initiation act producing a hub definition, merge is specified as a **mode of the
initiation skill**, not a separate skill. This is v1.28's own reasoning for the adoption mode: two
entry conditions producing one hub definition would otherwise drift into two definitions of a hub.

### 3 · Content crosses at the granularity its provenance already has

This is where a hand-move destroys provenance, and where re-inboxing every file would make the
mechanism unusable. The split is by what the artifact already carries. **[DIRECTIONAL]**

| Artifact class | How it crosses |
|---|---|
| **Entity notes** (decisions, risks, stakeholders, milestones, partners, relationships, claims, corrections) | **Re-homed, not re-digested.** They are already governed artifacts carrying their own frontmatter and provenance. The merge adds a `movedFrom:` lineage field naming the absorbed hub and the original path, and changes nothing else. One proposal per folder class, not per note. |
| **Sources and their digests** | Moved with their `sources/dates-register.md` rows and `transcript-index.md` entries **carried over verbatim**. A source's recorded date is evidence and is never re-derived by the merge; re-deriving it is how a merge silently re-dates a hub's whole history. |
| **Reconciliation topic files** | **Merged row by row, through reconciliation itself.** See §4. |
| **Narrative rollups (`00`–`07`)** | **Never concatenated.** Two `01_project-brief.md` files cannot both be `lifecycle: active`, and the currency rule already says what happens: one current document per purpose, and an agent finding two reports the collision rather than picking a winner. The survivor's numbered docs are amended by ordinary proposals; the absorbed hub's move to the survivor's `archive/`, marked `superseded` with `superseded-by:` pointing at the counterpart. |
| **`working-docs/`, `shareable/`** | Moved with lifecycle markers intact; `publication-log.md` rows carry over, because who received what is not re-derivable. |
| **The absorbed hub's `corrections/`** | Crosses in full. A correction is a rule about how the organization works, and it survives the hub that learned it — this is the promotion ladder pointing sideways rather than up. Duplicates of a rule the survivor already holds are retired with a pointer, not deleted. |

For volume, the merge uses the bulk-corpus intake shape the standard already records as guidance —
catalogue, boundary interview, domain split, per-domain extract — one proposal per domain rather
than one per file. Governance is not weakened: every proposal is still approved, applied, logged and
committed under the survivor's own flow.

### 4 · Reconciliation is where the merge actually happens

Two hubs that were secretly one engagement hold contradicting settled facts. That is not a side
effect of merging; **it is the merge**, and the reconciliation layer is the mechanism the standard
already ships for it. **[DIRECTIONAL]**

Each absorbed settled row is checked against the survivor's ledger. Agreement is recorded; a
contradiction opens a dispute file, adjudicated by the owner through the ordinary three options, and
every adjudication captures a `corrections/` note before the dispute file is deleted, because the
verdict without the reasoning is the loss the standard already names.

**A merge that raises zero disputes should be suspected of having skipped the check**, not
celebrated. Two hubs describing one engagement with no contradiction between them is possible and
uncommon; it is worth stating out loud, because a clean run is exactly what an unrun check also
looks like.

### 5 · The absorbed hub is tombstoned, never deleted

Determined by existing doctrine rather than invented here: an accepted record is superseded, not
rewritten; retired notes are kept; a falsified assertion is retracted in place. Applied to a whole
hub:

- The **directory stays** and its **git history stays**. Every external pointer into it still
  resolves, which is the provenance property the owner said hand-moving fails to preserve.
- It gains a **`MERGED-INTO.md` tombstone**: the survivor, the date, the owner's authority, the
  survivor's applying commits, and a plain statement that nothing in this directory is current.
- Its **admission rule becomes a refusal** — "this hub is merged into X; admit nothing" — so a
  routing pass or an agent that still reaches it is told, rather than quietly filing into a dead
  hub.
- Its **agent definition is retired** and the agent registry regenerated.
- Its **registry row stays, with a new status.** The registry today has `hub` and `repo`; merge adds
  **`merged`**, with a `merged-into` column. The row must stay, because a hub-shaped directory
  absent from the registry is quarantined by the estate scan, and a tombstoned hub should report a
  tombstone, not a quarantine. **This is the one schema change Part II requires.**
- Its **scan is expected not to go green**, and this is correct rather than a defect to fix: the
  directory is no longer a live hub and a green scan would assert that it is.

### 6 · Estate references are re-pointed by the estate, and re-pointing keeps its history

Relationship edges naming the absorbed hub, semantic-layer references, open queue rows, escalations,
unrouted backlog entries, and any decision-surface hub map are rewritten by the Supervisor, because
cross-hub state is estate state and no hub owns it. Per the retract-in-place rule, an edge is
**re-pointed with its history kept**, never deleted.

Merge is therefore **Supervisor-mediated under owner authority** and is not available to a hub
agent: it is cross-hub by construction, which is escalation-class work.

## What this must NOT do

1. **It must not delete the absorbed hub or rewrite its history.** The one lawful history redaction
   the standard contemplates exists for erasure obligations, and a merge is not one.
2. **It must not concatenate narrative documents.** Two actives for one purpose is a collision to
   report, and the owner supersedes one.
3. **It must not auto-resolve contradictions.** Detection automates; adjudication is the owner's.
4. **It must not skip the interview** on the strength of already knowing what both hubs are. The
   union is a pre-fill, never an answer.
5. **It must not advertise reversibility.** Unmerging is not a mechanism and this design does not
   pretend otherwise. Once content has crossed into the survivor's governance and been adjudicated,
   the two hubs are not recoverable as two by running anything backwards; what is recoverable is
   every individual artifact, from git, which is a different and lesser promise. **The reversible
   act is the decision not to merge yet**, and the design should say so where an operator will read
   it, because a mechanism that implies reversibility invites being run on a hunch.
6. **It must not run across a compartment boundary.** See the open limit below.

## What it costs a deployment to adopt

Almost nothing until it is used. One new status value and one column in the hub registry; one mode
on the initiation skill; one section in the standard. Hubs gain nothing and change nothing. A
deployment that never merges pays the registry schema change and no more.

The cost lands entirely on the merge itself, and it is real: an interview, a domain-split intake, and
a reconciliation pass whose size is the number of contradictions between the two ledgers. That is
the correct place for the cost to land.

## The open limit, stated rather than papered over

**A merge across differing compartment declarations is refused by this design, and the guard has
nothing to bind to today.** **[DIRECTIONAL]** Merging a hub declared never-public into one declared
counterparty-facing declassifies everything in it as a side effect of a structural act. That is a
disclosure decision and must be answered as one, before and separately.

The vocabulary that would express the guard — `station`, `exposure`, and the compartment model — is
drafted and unpublished, so the rule as written above binds nothing until that version is pushed.
This is a real limit on Part II, not a reason to defer it: the other five properties stand on
published doctrine, and the guard becomes checkable the day the vocabulary does.

---

# Part III — Multi-tenancy: premature, and what has to be settled first

## The gap as named

> What a deployment serving several organisations needs that a single-organisation one does not.
> **[OWNER-NAMED]**

## Why no design is offered

The word carries at least three readings. They are all legitimate, they are all plausibly what was
meant, and **their designs diverge at the first line rather than at the edges.** Choosing one by
inference and drafting it would produce a document that reads as ready while the question underneath
it is untouched — which is the specific failure this RFC was asked to avoid.

| Reading | What it means | State |
|---|---|---|
| **(a) Several client organisations as *subjects*** | One owner, one operating entity, hubs *about* different organisations | **Already the case in at least one deployment, and already designed.** The compartment model answers it: each hub declares owner, audience and boundary, and cross-compartment flow is default-deny and Supervisor-mediated. It is drafted and unpublished. Nothing new is needed; a push is. |
| **(b) Several owner organisations as *operators*** | Separate owners, separate decision authority, mutually invisible estates, one operator serving all | **Genuinely new work, and the standard has no primitive for most of it.** See below. |
| **(c) Several independent deployments of the standard** | Many organisations each running their own estate, one maintainer serving all | **Mostly exists**: the organization-profile contract, the overlay pin, the adoption flow. What is missing is plural — the canonical repository assumes one overlay per deployment, and multi-overlay conformance has never been exercised. A bounded gap, not a layer. |

## What reading (b) would require, and why it cannot be designed yet

Reading (b) is the only one that is a new layer, and four things block it. Each is a decision, not a
design problem, and none of them is the maintainer's to make.

1. **Authority is unmodelled, and singular.** Every rule in the standard says *the owner* — one
   person, unnamed, unqualified, holding all decision rights. The queue has one owner surface, the
   evidence standard has one rank-2 "owner statement", escalation resolves to one decider. Making
   that plural is not a schema change; it changes the meaning of roughly a dozen existing
   obligations. **Who settles it:** the deployment owner, on what tenancy means for decision rights,
   before any schema is drafted.

2. **Tenant isolation would be a claim, and the standard cannot honour it.** Agent scope is
   convention, not an enforced control, and the standard says so deliberately and repeatedly, on the
   grounds that a false assurance is worse than an acknowledged gap. A multi-tenant knowledge system
   whose isolation between tenants is convention is a claim nobody should ship to a third party. If
   the isolation claim is to be made, the control is a hosting and credentials decision — separate
   installations, separate storage, separate credentials — and the standard's contribution is the
   **honest description of where the boundary is and is not**, which is a short section rather than
   a layer. **Who settles it:** the owner decides whether the claim is made at all; whoever owns
   hosting decides how, and that answer determines whether the standard has anything to add.

3. **Two tenants cannot share one evidence standard.** The estate holds a single ranked trust order
   binding every hub, and its top rank is subject-confirmation about *this* organization's people.
   Two tenants disagreeing about a shared counterpart have no arbiter, and inventing one at the
   maintainer tier would be the maintainer deciding whose facts win. **Who settles it:** the
   enterprise knowledge steward, on whether a per-tenant evidence standard is even coherent, before
   any of it reaches the canonical standard.

4. **Erasure and retention obligations become per-tenant and may conflict.** The standard's answer to
   erasure today is structural — record-class data never enters git, and knowledge redaction is
   exceptional and tombstoned. Two tenants with different retention regimes over material in one
   shared semantic layer is a case the resolution plane does not cover, because the semantic layer
   *is* git and is shared by construction. **Who settles it:** this is a legal and data-protection
   question first and a design question second, and it must arrive as a constraint rather than be
   invented as one.

## What would make this designable, in order

1. **The owner names which reading he means**, in one line. This is not a design question and no
   amount of design resolves it. Cheapest possible unblock.
2. **If (a): the compartment version is pushed.** Then the gap is closed by an act that is already
   drafted, and designing on top of an unpublished draft is avoided — which matters, because a
   design that binds to a draft tempts the next session to treat the draft as published.
3. **If (c): a bounded piece of work is specified** — plural overlays, per-deployment pin discipline,
   and conformance across them. Designable immediately once named, and small.
4. **If (b): items 1–4 above are answered by the parties named**, and only then does a design become
   possible. Until then, anything written would be a schema with no authority model underneath it.

## The honest statement

Part III is not a gap in the design; it is a question with three answers, and the estate has not been
asked which one. Writing a mechanism now would spend the owner's attention on reviewing a design for
a problem that has not been stated, and would leave behind an artifact that a later session reads as
settled. The useful output here is the question, and it is above.

---

# Summary of what would change, if any of this were later authorized

Nothing in this RFC changes anything today. If Parts I and II were separately authorized:

| Part | Surface | Change |
|---|---|---|
| I | `STANDARD.md` | New section under Agent Tier: the harness projection, the closed fact-class list, the marker contract, the report-never-repair rule, and the coverage limit |
| I | Hub definition (`km-deployment.md`) | Declares the projected fact classes and the expected skill set |
| I | Agent-instruction templates | Marked regions around the projected facts; every other line untouched |
| I | `hub-scan.sh` | A `[ PROJECTION ]` block with three findings and a coverage line; both directions proved, per the standard's own rule |
| I | Initiation skill | Writes markers rather than bare substitutions |
| II | `STANDARD.md` | New section under the Supervisor Tier: the three cases, withdrawal, absorb-and-tombstone, the tombstone contract |
| II | Hub registry schema | `merged` status and a `merged-into` column |
| II | Initiation skill | A merge mode and a withdrawal mode |
| III | — | Nothing. §III is a question, not a change. |

No version number is claimed, no version-history row is added, and no deployment pin moves. Adoption,
if any part is later authorized, follows the standard's three-hop flow: the maintainer changes the
standard and writes one handover, the Supervisor decides scope with the owner, and each hub applies
under its own governance.
