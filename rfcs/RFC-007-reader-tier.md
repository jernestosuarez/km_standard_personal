---
type: reference
title: "RFC-007: The Reader tier, the scoped reader, and the honest isolation boundary"
description: Design document for the gap RFC-006 named as the hard prerequisite for the Consumer edition. The standard has no Reader tier. It ships one read-only consumption skill and no Reader identity, marker, contract, or scoping mechanism. This RFC designs the Reader tier generically as a read-only consumption context that produces outputs from the estate and authors none of it, names its marker and contract, states honestly which reader skills already ship versus which are missing, and designs the scoped reader locked to a declared subset of hubs as the reusable per-compartment or per-tenant consumption face. It states plainly that a scoped reader's isolation is convention unless the hosting enforces it, and refuses to claim enforced tenant isolation the standard cannot deliver. No normative change rides this RFC.
tags: [rfc, reader-tier, scoped-reader, consumption, read-only, isolation, convention, consumer-edition, compartments, reader-harvest]
timestamp: 2026-08-22
---

# RFC-007: The Reader tier and the scoped reader

> **Status: DRAFT, design document only.** As with RFC-003, RFC-004, RFC-005 and RFC-006, **no
> normative edits ride this RFC**: no `STANDARD.md` change, no version-history row, no schema,
> template, script, or skill change. Everything below is design awaiting a later, separately
> authorized normative change and owner push; nothing binds any deployment.
>
> **Authority and path:** a deployment owner named this gap. RFC-006 named the Reader as the hard
> prerequisite for a shippable Consumer edition, and found it present in the reference deployment and
> absent from the standard. The owner's statement is that "the reader should be there." The supervisor
> tier dispatched the maintainer to design the Reader tier and its scoping mechanism, not to harvest or
> implement them. **The gap is the owner's; every mechanism below is the maintainer's, drafted so it
> can be argued with.** No design statement here is owner-ruled.

## Provenance discipline

The evidence hierarchy applies to the standard's own design statements, as in RFC-004, RFC-005 and
RFC-006. Every statement below carries one tag.

| Tag | Meaning |
|---|---|
| **[OWNER-NAMED]** | The gap or idea as the owner stated it. Fixed. Nothing about its solution is fixed by it. |
| **[EVIDENCED]** | A maintainer design call resting on the reference deployment's actual Reader tier, cited where it is made. |
| **[DIRECTIONAL]** | A maintainer design call beyond the evidence. Drafted concretely so it can be tested and revised by operational evidence or the owner's word. |

**On the reference deployment.** The Reader tier the design is read from was invented and operated in
one running estate, the standard's **reference deployment**, which is authoritative for the invention
and behind the standard on purpose. It runs two Reader contexts as real directories carrying real
behaviour: a full reading tier over the whole estate, and a scoped reader locked to a single hub. The
design below rests on that structure, and every proper noun, path, unit code, client, and person is
genericised throughout. A tier named in the reference deployment becomes at most one instance of a tier
**class**, never a name the standard ships.

## Verdicts

| Part | Question | Verdict |
|---|---|---|
| I | The Reader tier, generically | **Designed.** A read-only consumption context with a stated contract, a marker identity, and a set of reader skills. Its shape is read from the reference deployment's own reading tier. |
| II | Which reader skills already ship | **One ships, the rest are missing.** `km-brief` is a read-only consumption skill and ships today. There is no standalone query or gather-for-answer skill, no Reader contract, and no Reader marker. §II gives the honest inventory so the harvest scope is not overstated. |
| III | The scoped reader | **Designed.** A reader locked to a declared subset of hubs is the reusable per-compartment or per-tenant consumption face. The scope is a declaration; its enforcement is a hosting decision, not a standard control. |
| IV | The isolation boundary | **Stated honestly, not overclaimed.** A scoped reader's isolation is convention unless the hosting enforces it with separate installs, storage, or credentials. The standard's contribution is the honest description of where the boundary is and is not. It claims no enforced isolation. |
| V | Relation to the editions | **Confirmed.** The Reader is the missing run-set component RFC-006 named. Harvesting it, under §I–IV, is what makes the Consumer edition shippable. This RFC designs the tier; the harvest is its own effort. |

---

# The gap as named

> The standard has no Reader tier. RFC-006 named it as the hard prerequisite for the Consumer edition,
> and it exists only as an estate invention. The reader should be there. **[OWNER-NAMED]**

The gap is real, and RFC-006 already located it precisely. [EVIDENCED by RFC-006 Part VI.] The
canonical `STANDARD.md` uses the word "reader" only in its ordinary sense, a later person or agent
reading a document, and defines no Reader tier, no Reader agent, and no Reader component. The run-set's
consumption face, the tier that answers "what do we know about X" and "what did we decide and why"
without touching the record, is present in the reference deployment and absent from the standard.
RFC-006 designed the editions boundary and deferred the Reader to a separate effort. This RFC is the
design half of that separate effort. It designs the Reader tier and its scoping mechanism; it does not
harvest them, and it changes nothing.

---

# Part I: The Reader tier, generically

## What a Reader is: a read-only consumption context

A Reader is a context whose whole purpose is to **produce outputs from the estate without authoring
the estate.** [EVIDENCED] The reference deployment states this as the reason the tier exists at all:
reading the estate and building the estate are different sessions with different contracts, decided by
which context was opened rather than by anything anyone remembered. The Reader answers questions and
produces briefs, drafts, analyses, comparisons, and summaries drawn from committed knowledge. It is
the consumption flow made into a session type.

The Reader's contract, genericised from the reference deployment's own reading tier: [EVIDENCED on the
contract's clauses, which are read from the reference tier; DIRECTIONAL on stating them as a standard
tier class]

1. **It produces outputs; it does not change the estate.** It writes its results into its own
   `outputs/` area, or wherever the owner directs, and never into a hub, the semantic layer, or the
   registry. A stray write into a governed tree becomes an uncommitted change that the next build
   session's scan reports as an integrity error, which is a cost the reference deployment paid and
   named.
2. **The consumption acts are out of scope, listed rather than implied.** No proposals, no directives,
   no dispatching hub agents, no queue rows, no corrections notes, no commits, no running any hub or
   estate scan, no refreshing a handover, no regenerating an index. A Reader that starts doing these
   has stopped being a Reader.
3. **Reading anything is in scope.** History is often the fastest answer to "when did we decide this
   and what did it replace", so the whole readable tree, including version history, is the Reader's to
   consult.
4. **A defect found is noted in one line and left.** A stale fact, a broken link, a contradiction: the
   Reader states it and carries on answering the question it was asked. It does not investigate, design
   a fix, or open the machinery. A read session that turns into repair work has failed at the only
   thing it was for. This is the reading-side twin of the estate's build-tier discipline, and it is the
   clause that keeps the read/build split from eroding one convenience at a time.

## What still binds a Reader: the reading subset of the standard

A Reader is not exempt from the standard; it is bound by the subset of it that governs reading rather
than writing. [EVIDENCED] The reference deployment states this subset explicitly rather than pointing
at the full corrections digest, on the grounds that most estate rules govern acts a Reader cannot
perform. Genericised, the reading subset is:

- **The evidence hierarchy binds.** Curated hub documents and the semantic layer outrank raw
  transcripts; a hub-produced artifact is never evidence for itself; the first-order source is read
  before its contents are characterised, because a summary compresses away the distinction being asked
  about.
- **The home of record is consulted first.** Hubs and the semantic layer frame a topic before any
  transcript does. An answer is never built primarily from a raw source when a hub already frames it.
- **Every claim carries its provenance where it appears**, not in a source list at the end. A claim
  whose origin cannot be stated is reported as such rather than asserted.
- **Restricted content is never surfaced** in anything that leaves the session, and a digest inherits
  the most restrictive marking of what it summarises. A marking that lives only in prose still marks
  the content, even though no instrument sees it.
- **Identity is resolved, never constructed.** A person's name is resolved against the semantic layer
  before it is written, and a contact detail is never built from a name.
- **Voice binds anything the owner would send or sign**, and estate separation binds absolutely: a
  Reader never references an unrelated estate.

## The marker and identity

A Reader must be recognisable as a Reader by inspection, not by memory. [EVIDENCED on the marker's
existence in the reference deployment; DIRECTIONAL on its exact shape as a standard artifact] The
reference deployment marks its reading tier with a tier marker file and a local agent-configuration
directory, so that opening the directory is what selects the contract. Generically, a Reader context
declares its identity through:

- **A tier marker** at the context root, naming the context as a Reader and naming what it may read.
  The marker is the machine-and-human-readable statement that this is a consumption context, the twin
  of the deployment manifest a hub carries.
- **A governing context file** stating the Reader contract in full, the way a hub's `CLAUDE.md` states
  the hub's. This file, not a remembered rule, is what binds the session.
- **An `outputs/` area** for results, and an optional notes area for the one-line defects the Reader is
  permitted to record and hand back.

The marker is a **declaration of identity**, and §IV is explicit that a declaration is not an enforced
control. What the marker buys is that the contract is selected structurally by which context was
opened, which is the property the reference deployment says is the whole point of a separate tier.

## The reader skills a Reader uses

A Reader is a consumption context, so its skills are the consumption skills: the ones that read
committed knowledge and produce an output, carrying none of the ones that author, propose, route, or
operate. §II gives the honest inventory of which of these the standard ships today and which are
missing, because the harvest scope depends on that count being accurate rather than optimistic.

---

# Part II: Which reader skills already ship, and which are missing

The most useful thing this Part does is refuse to overstate what the standard already has. [DIRECTIONAL
on the classification; EVIDENCED on the skill inventory, read from the canonical `skills/` tree] The
standard ships nine skills. Classified by whether a Reader could use it without violating the read-only
contract:

| Skill | What it does | Reader-usable? |
|---|---|---|
| `km-brief` | Drafts a memo, briefing, or status report for a named audience by **querying committed entity notes** | **Yes. This is a read-only consumption skill and it ships today.** |
| `km-gather` | Researches from external or configured sources and **drafts a proposal** citing evidence for every change | **No. It authors a proposal**, which is a write-path act a Reader may not perform. Its research half is reader-shaped; its output is not. |
| `km-start` | Runs the structural scan plus the corrections, staleness, and competency-question audits | **No. Running a scan is an out-of-scope operating act.** |
| `km-init` | Stands up or adopts a hub, runs the interview, mints the agent, registers the hub | No. Authoring and registration. |
| `km-intake` | Applies or rejects proposals, turns inbox files into proposals | No. Authoring. |
| `km-propose` | Drafts a proposal from a discussion, decision, or correction | No. Authoring. |
| `km-publish` | Renders a committed document outward as a PDF through the shared renderer | Borderline. It reads committed source and emits an artifact, but it is an issuing act with its own guards and publication log; treat it as an operating skill, not a Reader skill, until a harvest decides otherwise. |
| `km-handover` | Rewrites the current-state section of the handover file | No. Authoring a governed file. |
| `km-supervise` | Routes a cross-hub source or decision into each hub's proposal flow | No. Routing and authoring. |

**The honest inventory, stated for the harvest:**

- **Ships and is a Reader skill:** `km-brief`, and only `km-brief`. It is the one skill that reads
  committed knowledge and produces an output without touching the record.
- **Missing, and needed for a real Reader tier:**
  1. **A standalone query or answer skill.** The Reader's most common act, "what do we know about X",
     "what did we decide and why", is not a memo for a named audience and so is not `km-brief`. The
     reference deployment answers it as an ordinary session act with no skill behind it. A generic
     Reader would benefit from a dedicated query skill that reads the home of record first, carries
     provenance per claim, and respects restricted markings, but **no such skill ships**. [EVIDENCED on
     the absence; DIRECTIONAL on the recommendation]
  2. **A reader-safe gather.** `km-gather`'s research half (search sources, compare against hub state)
     is reader-shaped, but its output half authors a proposal. A Reader that needs to gather for an
     answer rather than for a change has no skill that stops at the answer. Whether this is a mode of
     `km-gather` or a separate skill is a harvest decision, not decided here.
  3. **The Reader contract and marker themselves.** These are not skills but tier scaffolding, and the
     standard ships none of it: no Reader context template, no tier marker, no governing-file template
     stating the read-only contract and the reading subset.

So the harvest is not "package the one skill that exists." It is "harvest one existing skill, design
and add at least one missing query skill, and add the Reader tier scaffolding that no skill provides."
Naming this now keeps a later session from reading "the Reader mostly ships" off the presence of
`km-brief`.

---

# Part III: The scoped reader, the reusable part

## A reader locked to a declared subset of hubs

The valuable, reusable mechanism is not the full-estate Reader; it is the **scoped reader**: a
delegated reader restricted to a declared subset of hubs and nothing else. [EVIDENCED] The reference
deployment runs one: a reader that may read exactly one named hub, has no access to any other knowledge
area, and answers "out of scope for this reader and stop" to any question that reaches past its
boundary. This is the shape a consumer or a tenant sees when it is given a view of only its own
compartment.

Generically, a scoped reader is a Reader (all of Part I binds it unchanged) plus a **scope
declaration**: [DIRECTIONAL]

- **The scope is a named, closed list of hubs** the reader may read, declared in the reader's tier
  marker. Closed on purpose, the same discipline RFC-004 applied to its fact-class list: an open scope
  makes the boundary claim unstatable.
- **Everything outside the scope is refused, not filtered.** A question needing material outside the
  declared hubs is answered "this is out of scope for this reader" and stopped, rather than answered
  partially from whatever happens to be visible. The reference deployment states this as a firm
  contract precisely because the surrounding material may or may not be physically present.
- **The scoped reader ignores the scoped hub's own build files.** A hub carries its own agent
  instructions, scan, and hooks for the people who maintain it; a scoped reader is a reader, not that
  hub's agent, and its contract is the reader's context file, not the hub's. This keeps a delegated
  reader from being captured by the instructions of the thing it was sent to read.

## Where it connects: compartments and the Consumer edition

The scoped reader is the consumption-side counterpart of two mechanisms the standard has already
designed, and stating the connection is most of its value. [DIRECTIONAL]

- **RFC-002 compartments (stations and exposure).** RFC-002 designed the compartment as hub-level
  access: each hub declares an owner, an audience (who it is for), and a boundary (who it must never
  reach), with cross-compartment flow default-deny and Supervisor-mediated. A scoped reader is **how a
  compartment is consumed**: the declared hub subset of a scoped reader is the read-side projection of
  a compartment's membership. The compartment model says which hubs an audience may see; the scoped
  reader is the context that lets that audience see those hubs and only those. The two are the same
  boundary named from opposite sides, one governing membership between hubs and the other governing a
  reader's view across them. RFC-002's audience and boundary values are hub-local content and never
  reach the canonical repository; a scoped reader's declared hub list is the same kind of local
  declaration and lives with the reader, not in the standard.
- **RFC-006 the Consumer edition and per-tenant access.** RFC-006 defined the Consumer edition as the
  run-set pinned to a published version, and named the Reader as its missing consumption face. The
  scoped reader is **how a single Consumer deployment presents a per-tenant or per-audience view**: one
  estate, several scoped readers, each locked to the hubs one consumer is entitled to see. This is the
  bounded, honest form of "per-tenant access" that does not reopen RFC-004 reading (b): it is one
  operator's estate showing different consumers different compartments through scoped readers, not
  several mutually invisible operators, which remains blocked exactly where RFC-004 left it. The scoped
  reader gives per-audience consumption its concrete shape without asserting the multi-operator
  isolation the standard cannot deliver.

---

# Part IV: The honest isolation boundary

## A scoped reader's isolation is convention unless the hosting enforces it

This is the load-bearing honesty of the whole RFC, and it is stated plainly so no later session
mistakes a convenience for a control. [OWNER-NAMED as the standard's repeated posture; DIRECTIONAL on
applying it to the scoped reader] The standard says, deliberately and repeatedly, that agent scope is
convention and not an enforced control, and that a false assurance is worse than an acknowledged gap.
A scoped reader is subject to exactly that limit:

- **The scope declaration is a convention.** A reader's tier marker naming three hubs does not, by
  itself, prevent the reader from reading a fourth if the fourth is present and readable. The
  declaration binds behaviour the way every agent contract in the standard binds behaviour: by being
  the contract the context reads, not by being a wall the filesystem enforces.
- **Isolation becomes real only when the hosting makes it real.** [EVIDENCED] The reference
  deployment's scoped reader achieves genuine isolation not through its prose but through **what is
  physically present**: the other knowledge areas are simply not in the shared workspace, and git write
  commands are denied by the local configuration. That is a hosting-and-credentials fact, not a
  standard-prose fact. Real isolation between a scoped reader and the hubs it may not see comes from
  separate installations, separate storage, or separate credentials, which are decisions the hosting
  makes and the standard does not perform.
- **The standard's contribution is the honest description of where the boundary is and is not.**
  [DIRECTIONAL] The standard can define the scoped-reader contract, the closed scope declaration, and
  the refuse-out-of-scope behaviour, and it can state exactly which part of that is convention (all of
  it, absent hosting enforcement) and which part is real (only what the hosting enforces). That honest
  description is the deliverable. It is worth shipping precisely because it stops a deployment from
  reading "scoped reader" as "isolated tenant" when nothing underneath it enforces isolation.

## What this refuses to claim

The design refuses to describe a scoped reader as an enforced tenant boundary. A scoped reader whose
only isolation is its own prose is a reader that will read whatever is put in front of it; presenting
that as tenant isolation to a third party would be the false assurance the standard holds to be worse
than an acknowledged gap, and it is the same refusal RFC-004 Part III made about multi-tenant
isolation-as-a-claim. The standard describes the boundary honestly and points at the hosting for
enforcement; it does not pretend the prose is the enforcement.

---

# Part V: Relation to the editions

The Reader is the run-set component RFC-006 named as absent, and this RFC is the design that lets it be
harvested. [EVIDENCED by RFC-006 Part VI] RFC-006 mapped the Reader to the run-set on the consume side,
marked it "Yes, once harvested," and stated that the Consumer edition cannot be complete until the
Reader is harvested and genericised. This RFC supplies the design that harvest will implement:

- **Part I** gives the Reader tier a generic contract, marker, and reading subset, so the harvest has a
  target shape rather than a copy of the reference deployment's specifics.
- **Part II** states honestly that only `km-brief` ships and names the missing query skill and the
  missing tier scaffolding, so the harvest is scoped to real work and not mistaken for repackaging.
- **Parts III and IV** give the Consumer edition its per-tenant consumption face, the scoped reader,
  and bound it to the honest isolation limit, so the Consumer edition does not ship an isolation claim
  the standard cannot honour.

Harvesting the Reader under this design is what turns RFC-006's "Consumer edition defined" into
"Consumer edition shippable." [DIRECTIONAL] The harvest itself is a per-feature, proof-gated lift of a
settled estate invention, on the reference-deployment exemption so the lab is not dragged back to the
last release, under the leakage guard RFC-006 Part V relies on. That harvest is its own effort with its
own drafted-and-unpublished version. This RFC binds none of it; it is the design the harvest argues
with.

---

# What this must NOT do

1. **It must not claim enforced isolation the standard cannot deliver.** A scoped reader's isolation is
   convention unless the hosting enforces it. Describing the scope declaration as a technical tenant
   boundary would be the false assurance the standard holds to be worse than an acknowledged gap. §IV.
2. **It must not let a Reader author the estate.** The read-only contract is the point of the tier. A
   Reader produces outputs into its own area and never writes a hub, the semantic layer, or the
   registry, and never proposes, dispatches, routes, commits, or runs a scan.
3. **It must not design the editions or the compartments.** The editions are RFC-006 and the
   compartments are RFC-002. This RFC references both and designs only the Reader tier and the scoped
   reader that consume them.
4. **It must not overstate what ships.** Only `km-brief` is a Reader skill today. A later session must
   not read "the Reader mostly ships" off its presence; the query skill and the tier scaffolding are
   missing and §II says so.
5. **It must not force any deployment into running a Reader.** A deployment that operates without a
   separate reading context runs exactly as it does today. The Reader is a tier a deployment may adopt,
   the same no-cost-to-decline discipline RFC-004, RFC-005 and RFC-006 required.
6. **It must not ship a builder's specifics in a Reader or scoped reader.** The harvested Reader is the
   generic tier class, leakage-clean, carrying none of the reference deployment's hubs, proper nouns,
   paths, clients, or people. This is the same strict-separation discipline RFC-006 Part V binds on the
   Consumer runtime.
7. **It must not capture a scoped reader with its target hub's instructions.** A scoped reader is a
   reader, not the scoped hub's agent, and its contract is the reader's context file, not the hub's
   build files.

---

# What it would cost a deployment to adopt

- **Per deployment, once (to run a Reader):** one Reader context with its marker, its governing
  contract file, and its `outputs/` area, plus whichever reader skills it uses. A deployment that
  declines runs as today.
- **Per scoped reader, once:** a scope declaration naming the closed hub subset, and a hosting decision
  about whether the isolation is real (separate install, storage, or credentials) or convention only.
  The standard states which it is; the deployment chooses.
- **The standard, once (if the harvest is later authorized):** the Reader tier written into a section,
  the reader-skill classification recorded, at least one query skill added, and the honest isolation
  limit stated as an invariant beside the existing agent-scope-is-convention posture.
- **Ongoing:** nothing. A Reader consumes; it adds no maintenance to any hub, and a hub does not know a
  Reader is reading it.

---

# Summary of what would change, if this were later authorized

Nothing in this RFC changes anything today. If the Reader harvest were separately authorized:

| Surface | Change |
|---|---|
| `STANDARD.md` | A new section defining the Reader tier: the read-only contract, the reading subset that binds it, the marker identity, and the scoped reader with its closed scope declaration and its honest isolation limit |
| `skills/` | `km-brief` confirmed as a Reader skill; at least one new query or answer skill added; a reader-safe gather decided as a mode or a new skill |
| Reader tier scaffolding | A Reader context template: tier marker, governing contract file, `outputs/` area, optional defect-notes area |
| The organization-profile / edition declaration | The Reader named as the run-set's consumption face, so a Consumer edition can declare it (RFC-006) |
| The leakage guard | Applied to the harvested Reader and any scoped-reader scaffolding, so no reference-deployment specifics cross into the generic tier class |

No version number is claimed, no version-history row is added, and no deployment pin moves. **No
enforced tenant isolation is asserted, encoded, or implied anywhere in this RFC or in any change it
contemplates; a scoped reader's isolation is convention unless the hosting enforces it, and the
standard's contribution is the honest description of where that boundary is and is not.** Adoption, if
authorized, follows the standard's three-hop flow and the harvest discipline: the maintainer harvests
and genericises the Reader under the leakage guard on the reference-deployment exemption, writes one
handover, the Supervisor decides scope with the owner, and each deployment adopts under its own
governance. The reference deployment, which already runs both a full reader and a scoped reader, adopts
by declaring what it already is, not by being dragged back to the last release.
