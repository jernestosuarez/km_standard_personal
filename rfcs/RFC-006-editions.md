---
type: reference
title: "RFC-006: Editions, the run/evolve boundary, and a line a licensing policy could later attach to"
description: Design document for a gap named by a deployment owner. The estate is built as tiers, each a focused context, and the standard has no notion of how those tiers package into editions or where a clean boundary between consuming the standard and evolving it would fall. This RFC names one structural line, the run/evolve boundary, maps every component to one side of it, and defines two editions as profiles over the same standard: a Consumer/Run edition that consumes a pinned version and cannot author, and a Builder/Full edition that can invent tooling and evolve or fork the standard. The boundary is license-agnostic by hard requirement: the standard asserts no license, and the line is drawn cleanly enough that an owner MAY later attach a commercial policy to it without the standard encoding any such policy. The Consumer edition is the concrete, bounded form of RFC-004 Part III reading (c). No normative change rides this RFC.
tags: [rfc, editions, run-evolve-boundary, consumer-edition, builder-edition, license-agnostic, packaging, leakage, reader-harvest]
timestamp: 2026-08-22
---

# RFC-006: Editions and the run/evolve boundary

> **Status: DRAFT, design document only.** As with RFC-003, RFC-004 and RFC-005, **no normative edits
> ride this RFC**: no `STANDARD.md` change, no version-history row, no schema, template, script, or
> skill change. Everything below is design awaiting a later, separately authorized normative change
> and owner push; nothing binds any deployment.
>
> **Authority and path:** a deployment owner named one gap in this session. The estate is built as
> tiers, each a focused context, and the standard does not define how those tiers package into
> editions, nor a clean boundary an owner could later apply a licensing or commercial policy to. The
> owner wants two editions and a named boundary, and requires that the boundary be license-agnostic:
> the standard stays free to adopt and asserts no license. The supervisor tier dispatched the
> maintainer to design rather than implement. **The gap is the owner's; every mechanism below is the
> maintainer's, drafted so it can be argued with.** No design statement here is owner-ruled, and
> nothing here asserts, encodes, or implies any license, price, or commercial term.

## Provenance discipline

The evidence hierarchy applies to the standard's own design statements, as in RFC-004 and RFC-005.
Every statement below carries one tag.

| Tag | Meaning |
|---|---|
| **[OWNER-NAMED]** | The gap or idea as the owner stated it. Fixed. Nothing about its solution is fixed by it. |
| **[EVIDENCED]** | A maintainer design call resting on the reference deployment's actual tier structure, cited where it is made. |
| **[DIRECTIONAL]** | A maintainer design call beyond the evidence. Drafted concretely so it can be tested and revised by operational evidence or the owner's word. |

**On the reference deployment.** The tier layout the boundary is read from was invented and operated
in one running estate, the standard's **reference deployment**, which is authoritative for the
invention and behind the standard on purpose. Its tiers are real directories carrying real behaviour;
the boundary below rests on that structure, and every proper noun, path, and unit code is genericised
throughout. A tier named in the reference deployment becomes at most one instance of a tier **class**,
never a name the standard ships.

## Verdicts

| Part | Question | Verdict |
|---|---|---|
| I | The run/evolve boundary | **Designed.** A single structural line, already latent in the estate's tier layout, is named. Every component maps to one side; §I gives the per-component table. |
| II | Two editions as profiles | **Designed.** Consumer/Run and Builder/Full, each a profile over the **same** standard version, no fork of the standard and no new normative surface. |
| III | The boundary is license-agnostic | **Designed as a boundary only, by hard requirement.** The standard asserts no license. A commercial policy is a later, optional overlay the owner MAY attach at the line; applying it or not applying it changes nothing structural, and the standard encodes none of it. |
| IV | The Consumer edition is RFC-004 Part III reading (c) | **Confirmed and made concrete.** The product decision gives reading (c) its bounded form: many independent deployments, one maintainer serving all. [EVIDENCED by RFC-004 Part III.] |
| V | Packaging and leakage | **Designed.** A Consumer-edition runtime ships only the generic run-set, leakage-clean, carrying none of a builder's estate specifics and none of the evolve-set. The canonical leakage guard is what makes a clean consumer runtime possible. |
| VI | Prerequisite: the Reader is not in the standard today | **Stated as a hard dependency, not designed here.** The Consumer edition cannot be complete until the Reader is harvested and genericised. That is a separate effort (a Reader-harvest RFC and version); RFC-006 designs the editions boundary, not the Reader. |

---

# The gap as named

> The KM estate is built as tiers, each a focused context, a directory-as-contract: a **Reader** that
> consumes read-only, a **Supervisor** that routes, runs routines, owns the queue and cockpit, and
> operates hubs, a **Machinery** tier that invents and battle-tests tooling, and a
> **Standard-Steward** tier that evolves the reusable standard. The standard does not define how these
> package into editions, nor a clean boundary an owner could later apply a licensing or commercial
> policy to. The owner wants two editions and a named boundary, and the standard must stay
> license-agnostic. **[OWNER-NAMED]**

The gap is real, and the structure it points at already exists. The reference deployment runs exactly
these tiers as separated contexts, each a directory whose own governing file states what that context
may and may not do. [EVIDENCED] What the standard has never done is name the **line between them** as
a first-class concept, or say which side of that line a given component belongs on. Without the line,
"two editions" is a packaging wish with nothing structural to package against; with it, an edition is
just a declared subset of components on one side of a boundary that already runs.

The one thing this RFC must not do while closing the gap is the thing the owner named as a hard
requirement: it must draw the boundary **without** the standard asserting, encoding, or implying any
license. The boundary is the deliverable. Whatever an owner later chooses to do with that boundary
commercially is a separate act the standard neither performs nor knows about. §III is where that
separation is made load-bearing.

---

# Part I: The run/evolve boundary

## One structural line, read from the tiers that already exist

The estate's tiers divide cleanly into two intents, and the division is not the maintainer's
invention. It is the seam the reference deployment already operates across. [EVIDENCED] Two of the
tiers **consume and operate** a fixed standard; two of them **invent and author** the instruments and
the standard itself. That is the line.

- **Run-set** = the tiers and components that **consume a published standard and operate a live
  estate**: the Reader, the Supervisor (including the queue, the cockpit, and the routines it runs),
  the hubs, and the **pinned canonical standard** the whole set conforms to. The run-set reads the
  standard as authoritative and does not author it.
- **Evolve-set** = the tiers that **invent instruments and author the standard**: the Machinery tier,
  which invents and battle-tests tooling, and the Standard-Steward tier, which authors, evolves, and
  may fork the standard. The evolve-set writes what the run-set later consumes.

The seam is exactly the estate's own two-flow model. [EVIDENCED] The reference deployment already
distinguishes **consumption** (standard to hubs, the standard authoritative, the hubs conform) from
**invention and harvest** (estate to standard, the estate authoritative, the standard brought up to
it at agreed intervals). The run-set is the consumption flow made concrete; the evolve-set is the
invention flow made concrete. RFC-006 does not create this line. It names it, so that an edition can
be defined as a subset on one side of it.

## Every component maps to exactly one side

The boundary is only useful if it is total: no component may straddle it. The mapping below is the
core of Part I. [DIRECTIONAL] on the mapping's use for editions; [EVIDENCED] on the tier roles, which
are read from the reference deployment's own tier contracts.

| Component | What it does | Set | In Consumer / Run edition | In Builder / Full edition |
|---|---|---|---|---|
| **Reader** | Read-only consumption of hub knowledge (query, brief, present); authors nothing | Run-set | Yes, once harvested (see §VI) | Yes |
| **Supervisor** | Routes, runs routines, owns the owner queue and the cockpit, operates hubs | Run-set | Yes | Yes |
| **The cockpit** (`components/km-cockpit`) | The owner's decision and answer surface, operated by the Supervisor | Run-set | Yes | Yes |
| **Hubs** | Hold governed knowledge, admit and reconcile under their own governance | Run-set | Yes | Yes |
| **The pinned canonical standard** | The conformance target the run-set reads as authoritative | Run-set | Yes, pinned to a published version, consumed read-only | Yes, and MAY be evolved or forked |
| **Machinery** | Invents and battle-tests tooling before it is harvested | Evolve-set | No | Yes |
| **Standard-Steward** | Authors, evolves, and may fork the reusable standard; runs the leakage guard | Evolve-set | No | Yes |

Three properties of the mapping matter and are stated rather than left implicit:

1. **The pinned standard is in the run-set on the consume side, not the author side.** A run-set
   holds the standard the way a hub holds it: pinned to a published version, read as authoritative,
   never authored. The same artifact appears in both editions, but only the Builder edition carries
   the authority (via the Standard-Steward) to change it. The artifact does not move across the line;
   the **authority to author it** is what the evolve-set adds.
2. **Operating a hub is run-set; inventing the instrument a hub uses is evolve-set.** The Supervisor
   running a routine is consumption. The Machinery tier building a new routine is invention. A
   deployment can do the first forever without ever doing the second, which is precisely what makes a
   Consumer edition coherent.
3. **The cockpit is a run-set component even though it is a reusable standard component.** It ships
   with the standard, but a deployment **operates** it (Supervisor) rather than **authors** it. Its
   presence in the standard's `components/` tree is a consumption artifact; changing the cockpit
   component itself is Standard-Steward work and therefore evolve-set. This is the same
   consume-versus-author distinction as the pinned standard, applied to a shipped component.

---

# Part II: Two editions, each a profile over the same standard

## An edition is a declared subset, not a fork

Both editions run the **same** published standard version. [DIRECTIONAL] An edition is not a variant
of the standard, not a branch, and not a second normative surface. It is a **profile**: a declared
statement of which side or sides of the run/evolve boundary a deployment installs and is authorized
to act on. This keeps the whole design inside the standard's existing profile-and-overlay machinery
rather than inventing a new axis of versioning.

- **Consumer / Run edition** = the **run-set**, pinned to a published standard version. It consumes
  releases and operates a live estate: it reads, routes, runs routines, operates hubs, and presents
  through the cockpit. It **cannot author**: it carries neither the Machinery tier nor the
  Standard-Steward tier, and it holds the standard pinned and read-only. A Consumer deployment that
  wants a standard change requests it upstream; it does not make it locally, because it has no
  evolve-set to make it in.
- **Builder / Full edition** = the run-set **plus** the evolve-set. It does everything a Consumer
  edition does, and additionally can invent tooling (Machinery) and evolve or fork the standard
  (Standard-Steward). A Builder deployment that forks the standard **becomes its own steward** of that
  fork, with all the harvest and leakage-guard discipline that role carries. The Builder edition is
  the edition the reference deployment itself runs.

## The editions are strictly nested, and this is deliberate

The Builder edition is the Consumer edition plus the evolve-set, with no component removed and none
altered. [DIRECTIONAL] The nesting is the property that makes the boundary safe to draw:

- **Nothing a Consumer edition does changes when the evolve-set is added.** A hub operates the same,
  a routine runs the same, the cockpit presents the same. Adding the evolve-set adds authority to
  invent and author; it does not reach back and change consumption behaviour.
- **No deployment is forced into an edition.** A deployment declares which edition it runs; the
  standard defines the two shapes and binds neither on. This is the same no-cost-to-decline discipline
  RFC-004 required of the projection block and RFC-005 required of routines: a deployment that
  declares nothing about editions runs exactly as it does today.
- **Existing hubs change nothing.** Editions are a packaging concept above the hub. A hub does not
  know which edition it runs inside, and no hub file changes because an edition is declared. An
  edition is a statement about the estate's installed component set, not about any hub's contents.

---

# Part III: The boundary is license-agnostic, and this is the hard requirement

## The standard asserts no license, and RFC-006 encodes none

This is the owner's hard requirement and the governing constraint on the entire RFC. The standard
**stays free to adopt and asserts no license.** RFC-006 defines only the **boundary**. It draws that
boundary cleanly enough that the owner **MAY** later attach a licensing or commercial policy at the
line, for example treating the evolve-set as owned or paid, **without the standard itself encoding any
such policy.** [OWNER-NAMED] on the requirement; [DIRECTIONAL] on how the design honours it.

Stated as plainly as it can be stated, so no later session mistakes the one for the other:

- **The boundary is the deliverable of this RFC.** A named structural line, a total component
  mapping, and two editions defined as subsets across it. That is all RFC-006 produces, and all it is
  authorized to produce.
- **The license principle is a later, optional overlay the owner applies, and is not part of the
  standard.** Whether a commercial policy is ever attached, and what it says, is an owner act that
  happens **outside** the standard, in the owner's own overlay or business terms, at a time of the
  owner's choosing. The standard neither performs that act nor references it.

## Applying or not applying a policy changes nothing structural

The design test for "clean enough to attach a policy to" is this: the boundary must be drawn so that
attaching a commercial policy, or never attaching one, produces **no structural difference** in the
standard or in any deployment that does not opt into the policy. [DIRECTIONAL] The line sits in the
same place, the component mapping is identical, the two editions are defined identically, and a
Consumer deployment behaves identically, whether or not any policy exists. A policy, if the owner ever
writes one, binds only the parties who accept it and lives only in the owner's overlay; the canonical
standard remains a license-neutral description of a boundary that anyone may adopt for free.

This is the whole reason the boundary and the policy are kept as two separate things. A standard that
encoded even a hint of a commercial term (a "paid tier", a "licensed component", a price-shaped
field) would stop being free to adopt, and would drag every conforming reimplementation into a
commercial posture it never agreed to. The boundary carries no such term. It carries only the
structural fact of two sides, which is equally true and equally useful to an adopter who will never
attach a policy at all.

---

# Part IV: The Consumer edition is RFC-004 Part III reading (c), made concrete

RFC-004 Part III found "multi-tenancy" premature because the word carried three readings whose designs
diverged at the first line, and it declined to design any of them by inference. [EVIDENCED by RFC-004
Part III.] Reading **(c)** was: *several independent deployments of the standard, many organisations
each running their own estate, one maintainer serving all.* RFC-004 judged (c) "mostly exists" as
machinery (the organization-profile contract, the overlay pin, the adoption flow) with one bounded gap
(the canonical repository assumes one overlay per deployment, and multi-overlay conformance has never
been exercised), and called it "a bounded gap, not a layer."

**The Consumer / Run edition is the product decision that gives reading (c) its concrete, bounded
form.** [DIRECTIONAL] Where RFC-004 said (c) was a bounded gap awaiting a decision to name it, RFC-006
names it: the bounded form of "many independent deployments, one maintainer serving all" is precisely
a fleet of Consumer-edition run-sets, each pinned to a published version, each consuming releases from
one upstream steward, none of them carrying an evolve-set. The one maintainer serving all is a Builder
edition (or the canonical steward) authoring the standard the fleet consumes.

This resolves reading (c) without reopening readings (a) or (b), which remain exactly as RFC-004 left
them:

- Reading (a), several client organisations as **subjects** of one estate, is the compartment model,
  drafted and unpublished, and is orthogonal to editions: a single Consumer edition can already hold
  hubs about many subject organisations.
- Reading (b), several owner organisations as **operators**, mutually invisible estates, remains the
  genuinely new work RFC-004 blocked on four unanswered decisions. Editions do not touch it. A
  Consumer edition serves one operator; multi-operator authority, isolation-as-a-claim, a shared
  evidence standard, and per-tenant erasure are untouched by this RFC and stay blocked where RFC-004
  left them.

So RFC-006's contribution to the multi-tenancy question is narrow and honest: it closes reading (c),
the one RFC-004 already judged bounded and close, and leaves (a) and (b) exactly where they were.

---

# Part V: Packaging and leakage

## A Consumer runtime ships only the generic run-set, leakage-clean

A Consumer-edition runtime must ship the **generic** run-set and nothing else. [DIRECTIONAL] It
carries:

- the run-set components: the Reader (once harvested, §VI), the Supervisor, the cockpit, the hub
  scaffolding, and the pinned canonical standard;
- **none of the evolve-set**: no Machinery tier, no Standard-Steward tier, no leakage tooling as an
  authoring instrument, no RFC or version-drafting surface;
- **none of a builder's estate specifics**: no builder's hub contents, no builder's overlay, no
  builder's proper nouns, unit codes, people, paths, clients, or examples.

The second and third points are the same discipline the estate already binds as strict separation:
one estate's specifics never travel into an artifact meant to be adopted by another. A Consumer
runtime is, by construction, an artifact meant to be adopted by an organisation that has never heard
of the builder that produced it, which is the canonical standard's own genericity test applied to a
shipped runtime rather than to a shipped clause.

## The canonical leakage guard is what makes a clean consumer runtime possible

This is the load-bearing dependency of Part V, and it is already met. [EVIDENCED] The canonical
standard is held publishable by a leakage guard that treats the canonical repository as publishable
and checks added lines against a denylist of one organisation's names, unit codes, people,
initiatives, clients, paths, and system names. That guard is exactly the instrument a clean Consumer
runtime needs: it is the mechanism that already proves the generic run-set carries none of a builder's
specifics. A Consumer runtime is packaged from leakage-clean canonical material, so the property "no
builder specifics reached the consumer" is not a new promise this RFC has to invent an instrument for;
it is the property the leakage guard already enforces on the canonical repository, applied at the
packaging step.

Two things follow, and both are stated so a packaging effort does not have to rediscover them:

1. **The leakage guard is an evolve-set instrument, and a Consumer edition does not ship it as an
   authoring tool.** The guard's job is to keep the canonical clean at authoring time; that is
   Standard-Steward work. A Consumer edition benefits from the guard having run upstream, but does not
   carry the guard as a live authoring instrument, because it does not author. Whether a packaging
   step re-runs the guard as a **verification gate** on the runtime it emits is a packaging-design
   choice for the Reader-harvest effort, not decided here.
2. **A clean consumer runtime is possible only for material the guard covers.** The guard covers the
   canonical standard. It does not cover a builder's hub knowledge, which is why the run-set a Consumer
   edition ships is the **generic** run-set (scaffolding and the pinned standard), never a builder's
   populated hubs. The consumer arrives with empty, governed hubs and its own initiation interview,
   not with someone else's knowledge.

---

# Part VI: The prerequisite, stated plainly

## The Reader is not in the standard today

The Consumer edition's read-only consumption tier, the Reader, **is not in the canonical standard.**
[EVIDENCED] It is an estate invention, living in the reference deployment as `_KM_Reader` and
`_KM_Reader_Factory`, and it has never been harvested. The canonical `STANDARD.md` uses the word
"reader" only in its ordinary sense (a later person or agent reading a document); it defines no Reader
tier, no Reader agent, and no Reader component. The run-set's consumption face is therefore, today,
present in the reference deployment and absent from the standard.

## This is a hard dependency for a separate effort

The Consumer edition **cannot be complete until the Reader is harvested and genericised into the
standard.** [DIRECTIONAL on the sequencing; EVIDENCED on the absence.] RFC-006 designs the editions
boundary; it does not design the Reader. The Reader harvest is its own effort with its own gate:

- it is a per-feature, proof-gated harvest of a settled estate invention, exactly the harvest
  discipline the standard-steward tier already operates;
- it needs its own RFC and its own drafted-and-unpublished version, on the reference-deployment
  exemption, so the lab is not dragged back to the last release while the Reader is genericised;
- it must strip the reference deployment's Reader specifics (the factory's local paths, the estate's
  proper nouns, any wired sources) to a generic Reader class, under the same leakage guard Part V
  relies on.

Until that harvest lands, a Consumer edition can be **defined** (this RFC does that) but not fully
**shipped**, because one of its run-set components does not yet exist in generic form. Naming this
dependency here is the honest half of the design: the boundary and the two editions are designable now
and are designed above; the Consumer edition's completeness waits on a named, separate piece of work.

---

# What this must NOT do

1. **It must not assert or encode any license, price, or commercial term.** The standard stays
   license-neutral. RFC-006 draws a boundary only, and §III makes the separation between the boundary
   and any future policy load-bearing. A version that later implements this must carry no
   price-shaped, license-shaped, or "paid tier" field anywhere in the canonical surface.
2. **It must not force any deployment into an edition.** An edition is a declared subset a deployment
   opts into. A deployment that declares nothing runs exactly as it does today, on the same
   no-cost-to-decline discipline RFC-004 and RFC-005 required.
3. **It must not change what any existing hub does.** Editions are a packaging concept above the hub.
   No hub file changes because an edition is declared, and a hub does not know which edition it runs
   inside.
4. **It must not fork the standard to make two editions.** Both editions run the same published
   version. An edition is a profile over one standard, not a variant of it; a second normative surface
   would reintroduce the drift the single-home-of-record rule exists to prevent.
5. **It must not ship a builder's specifics in a consumer runtime.** The Consumer runtime carries the
   generic run-set only, leakage-clean, with empty governed hubs. A populated hub, an overlay, or any
   proper noun crossing into a consumer artifact is a leakage failure, not a convenience.
6. **It must not treat the Consumer edition as complete before the Reader is harvested.** §VI names
   the dependency; a later session must not read "editions designed" as "Consumer edition shippable".
7. **It must not claim the boundary is an enforced control.** Tier separation in the estate is
   convention stated as such, the same posture the standard already takes toward agent scope.
   Describing the run/evolve line as a technical control over what a deployment can do would be the
   false assurance the standard holds to be worse than an acknowledged gap.

---

# What it would cost a deployment to adopt

- **Per deployment, once:** an edition declaration in the profile, naming which edition the deployment
  runs (Consumer/Run or Builder/Full). A deployment that declares nothing runs as today.
- **Per deployment, once (Builder editions):** nothing new. The reference deployment already runs the
  full component set; declaring itself a Builder edition is a statement of what it already is.
- **The standard, once:** the run/evolve boundary and the two edition shapes written into a section,
  the component-to-side mapping recorded, and the license-neutrality of the boundary stated as an
  invariant. No new instrument is strictly required by the boundary itself; the leakage guard Part V
  relies on already exists.
- **Blocked until a separate effort:** a fully shippable Consumer runtime, which waits on the Reader
  harvest (§VI). The editions boundary does not wait on it; the Consumer edition's completeness does.

---

# Summary of what would change, if this were later authorized

Nothing in this RFC changes anything today. If it were separately authorized:

| Surface | Change |
|---|---|
| `STANDARD.md` | A new section naming the run/evolve boundary, the run-set and evolve-set, the component-to-side mapping, the two editions as profiles over one version, and the invariant that the boundary asserts no license |
| The organization-profile contract | An optional edition declaration: which edition a deployment runs; absent means unchanged behaviour |
| Packaging guidance | How a Consumer runtime is assembled from the generic, leakage-clean run-set, carrying no evolve-set and no builder specifics |
| A separate Reader-harvest RFC and version | The Reader genericised into the standard, on the reference-deployment exemption, under the leakage guard (a hard prerequisite for a shippable Consumer edition; **not** this RFC) |

No version number is claimed, no version-history row is added, and no deployment pin moves. **No
license, price, or commercial term is asserted, encoded, or implied anywhere in this RFC or in any
change it contemplates; the boundary is the deliverable, and any commercial policy is a later,
optional overlay the owner applies outside the standard.** Adoption, if any part is later authorized,
follows the standard's three-hop flow: the maintainer changes the standard and writes one handover,
the Supervisor decides scope with the owner, and each hub or deployment adopts under its own
governance. The reference deployment, already a Builder edition, adopts by declaring what it already
is, not by being dragged back to the last release.
