---
type: reference
title: "RFC-005: Routines, what they are, what sources they read, and the one the standard needs for itself"
description: Design document for a gap named by a deployment owner. The standard governs routine OUTPUT (the queue tiers, the back-pressure cap, machine-facing briefs) but never defines the routines themselves, what a routine is, when it runs, and above all what sources it reads. This RFC designs the definition half, generically, with user-configurable sources declared per routine, a disconnected-by-default posture where an unwired routine is a clean no-op, four genericised routine shapes, and one routine the standard specifically needs, a per-hub version-conformance watch against the pinned version. No normative change rides this RFC.
tags: [rfc, routines, sources, configuration, conformance, drift, disconnected-by-default]
timestamp: 2026-08-22
---

# RFC-005: Routines, their sources, and the conformance watch

> **Status: DRAFT, design document only.** **No normative edits ride this RFC**: no `STANDARD.md`
> change, no version-history row, no schema, template, script, or skill change. Everything below is
> design awaiting a later, separately authorized normative change and owner push; nothing binds any
> deployment.
>
> **Status corrected on landing (2026-08-24, v1.45).** This document was drafted on 2026-08-22 and
> then sat on an unmerged branch while published text already cited it, which is audit finding F-04.
> It lands on the published branch **as design only**, by the route RFC-004 took ahead of the
> version that implemented it: nothing here binds, no version is claimed, and its presence on the
> branch is not adoption. The banner above originally read "as with RFC-003 and RFC-004", and that
> comparison has since gone stale: RFC-004 Parts I and II were implemented by v1.32 and v1.35,
> RFC-006 by v1.39, and RFC-007 by v1.41, while **the routines designed below remain
> unimplemented.** The design itself is unchanged from the day it was drafted.
>
> **Authority and path:** a deployment owner named one gap in this session, the standard governs
> what routines produce but never defines the routines themselves or the sources they read, and
> requires that routines be defined generically with user-configurable sources and a
> disconnected-by-default posture. The supervisor tier dispatched the maintainer to design rather
> than implement. **The gap is the owner's; every mechanism below is the maintainer's, drafted so it
> can be argued with.** No design statement here is owner-ruled.

## Provenance discipline

The evidence hierarchy applies to the standard's own design statements, as in RFC-004. Every
statement below carries one tag.

| Tag | Meaning |
|---|---|
| **[OWNER-NAMED]** | The gap itself, as the owner stated it. Fixed. Nothing about its solution is fixed by it. |
| **[EVIDENCED]** | A maintainer design call resting on something verified first-hand in the reference deployment, cited where it is made. |
| **[DIRECTIONAL]** | A maintainer design call beyond the evidence. Drafted concretely so it can be tested and revised by operational evidence or the owner's word. |

**On the reference deployment.** The routines designed below were invented and battle-tested in one
running estate, the standard's **reference deployment**, which is authoritative for the invention
and behind the standard on purpose. Its detail is deployment-shaped (a specific transcription source,
a single owner identity, local estate paths) and is genericised throughout this RFC: every proper
noun is stripped, and every source named in the reference deployment becomes at most **one example
of a source class**, never a default the standard ships wired.

## Verdicts

| Part | Gap | Verdict |
|---|---|---|
| I | The standard defines routine output but never a routine | **Designed.** The output half already exists and is cited; this RFC supplies the definition half as a small closed shape. |
| II | The four routine shapes | **Designed**, genericised from four the reference deployment consolidated to. Each is described by function, not by any deployment's sources. |
| III | Sources are hardcoded, and must be user-configurable | **Designed.** Sources move into the existing organization-profile config contract, declared per routine. The reference deployment's transcription source becomes one example. |
| IV | Disconnected by default | **Designed.** A routine with no declared source is a clean no-op, not an error, on the same latent-until-opt-in, fail-closed discipline the standard already uses. |
| V | A version-conformance watch the standard needs for itself | **Designed, and strongly motivated.** [DIRECTIONAL] on the mechanism, [EVIDENCED] on the need: the reference deployment's own component drifted far behind the pinned version before anything counted it. |
| VI | Obligation-watch elevation; cadenced cross-hub reconciliation | **Stated, not answered.** Two open design questions, framed for a later decision. |

---

# The gap as named

> The standard governs routine output, the queue tiers, the back-pressure cap, the machine-facing
> briefs, but never defines the routines themselves: what a routine is, when it runs, and above all
> **what sources it reads.** The reference deployment's routines hardcode a specific source. Define
> routines generically, with **user-configurable sources** (each deployment chooses which sources a
> routine touches, because sources vary with each deployment's MCP connectivity), and make any
> deployment-specific file a routine reads **configuration, not canonical text**, a disconnected-by-
> default mode. **[OWNER-NAMED]**

The gap is real and the asymmetry is exact. The standard already governs the **consumption** side of
a routine, what it may surface to the owner and how, in fine detail: the owner queue as the single
decision surface, the three tiers with the tier-B veto window, the back-pressure cap that halts
decision production before it outruns the one human, and the rule that a routine's brief is
machine-facing and never the owner's reading surface (all in *The owner queue* and *The owner
interaction contract*, v1.20 through v1.24). What the standard never says is what stands upstream of
that output: what a routine **is**, what triggers it, what phases it runs, and which sources it
reads to produce anything at all. A routine is, today, an unspecified process that happens to feed a
well-specified queue.

That silence is why the reference deployment's routines each hardcode their own source. Nothing told
them not to.

---

# Part I: What a routine is, generically

## The definition half is the missing half

A routine, generically, is four things: **[DIRECTIONAL]**

1. a **trigger**, a schedule or an event that starts it;
2. an ordered set of **phases**, the work it does, run in sequence so a single process is a single
   writer;
3. a set of **declared sources**, what it reads, and nothing it was not told to read;
4. an **output**, which the standard already governs completely.

The standard owns item 4 and only item 4. This RFC adds items 1 through 3, and the load-bearing one
is item 3: a routine is defined by its sources, and a routine whose sources are hardcoded is a
routine the standard has not actually defined, only observed.

**The single-writer property is not new and is carried in, not invented.** [EVIDENCED] The reference
deployment's routines-review (2026-08-03) found five scheduled runs firing inside a fifty-minute
window, two of them writing the same repository, and recorded two concrete collisions where
concurrent writers produced an out-of-order shared file and a routine nearly reporting an
already-completed sibling as not having run. Its consolidated architecture closed this by making the
morning routine one process running its phases in order, so the tier has exactly one writer in the
window. The generic lesson, phases run in a declared order within one process, is the ordered-phases
half of the definition above, and it rests on that verified race, not on taste.

## What this Part does not touch

The output contract is cited, never restated. A routine's asks register as queue rows, obey the
tiers, respect the back-pressure cap, and its brief is the machine/agent backstop, exactly as the
standard already binds. This RFC adds no new output behaviour and must not: the failure the queue
sections were adopted to end (routines each surfacing asks on their own parallel surface until the
owner could not tell what was pending) is precisely the failure a new output channel would reopen.

---

# Part II: The four routine shapes

Genericised from the four the reference deployment consolidated to, after its review audited ten
routines, found nine gaps and six clashes, and proposed collapsing to four. [EVIDENCED] Each is
described **by function**, and every source named in the reference version is dropped to Part III as
a configurable example. **[DIRECTIONAL]** on the shapes; the count and their boundaries are the
maintainer's reading of the evidence, not the owner's word.

| Shape | Function | Declared sources (class, not instance) | Output, governed already |
|---|---|---|---|
| **A · Integrity and ingestion sweep** | On a working-day cadence, run the estate's integrity scan across every hub, then harvest new material from the deployment's inbound sources, extract facts, route them, and draft proposals into each home hub. Never apply; the owner decides. Fold a per-hub change digest into one brief. | The integrity scanner (ships with the standard); zero or more **inbound content sources** declared by the deployment | Proposals in each hub's `changes/`; one machine-facing brief; queue rows for anything owner-facing |
| **B · External discovery routed into hubs** | On a cadence, scan declared external sources for material relevant to the hubs' competency questions, score it, and produce a **draft proposal in the owning hub** for anything above a threshold, so a discovery lands where it can be adjudicated rather than in a log nobody routes. | Zero or more **external discovery sources** (search endpoints, registries, feeds) declared by the deployment | Draft proposals in hubs; verdicts registered as tier-B queue rows within the cap |
| **C · Owner-ask generation** | On a cadence, harvest every unresolved decision the estate is holding, unresolved identities, standing questions, items blocked on a counterpart, expiring windows, into **one batched, answer-inline file** the owner clears in a single sitting, rather than the estate scattering asks across surfaces. | The estate's own registers (queue, decision log, hubs); zero or more **outbound ask channels** declared by the deployment | One owner-ask file; every ask also a queue row |
| **D · Periodic hygiene and self-maintenance** | On a slower cadence, check currency and obligations, verify the estate's own derived surfaces, **maintain the routines themselves** (drift between a routine's declared scope and the estate's actual shape, orphaned routine definitions), and honour a declared leave mode by holding non-urgent asks rather than stacking them into unread output. | The estate's scanners and registers; the routine definitions themselves; a declared **owner-absence signal** (optional) | A hygiene section in the brief; correction-promotion candidates; queue rows |

Two properties of this set matter more than the four rows.

**The shapes are functions, not schedules.** [DIRECTIONAL] The reference deployment runs A each
working morning, B midday, C weekly, D weekly, and that cadence is a good default but it is a
**deployment choice**, declared in config (Part III), not a constant the standard fixes. A
deployment with different rhythms declares different triggers against the same four functions.

**Owner-ask generation is a shape, not an afterthought.** [EVIDENCED] The review found that no
routine generated the estate-facing ask file, that the pattern worked only when a human hand-
assembled it, and that the open-question backlog regrew on its own between assemblies, with one
attribution question asked in three consecutive sweeps. The standard already states the principle
that owner asks are a block, not a scatter, in the interaction contract; shape C is that principle
given a routine to run it.

---

# Part III: Configurable sources via the existing config contract

## The contract already exists; sources are what it is missing

The standard already ships `contracts/organization-profile.schema.json` and a validator, the place a
deployment declares what is true of it that the canonical text must not hardcode. Sources are
exactly such a fact: they vary with each deployment's connectivity (which MCP tools it has, which
file inputs exist, which external endpoints it may reach) and they are the textbook case of
something that belongs in configuration and not in the standard's body. **[DIRECTIONAL]**

## A routines configuration block

Design: a **routines section in the organization profile** (or a parallel routines profile validated
by the same instrument, an open sub-choice below), where a deployment declares, per routine:

```yaml
# illustrative shape, inside the organization profile, not a schema change proposed here
routines:
  integrity-and-ingestion-sweep:      # a Part II shape, by function
    trigger: { schedule: "weekdays 09:00" }
    sources:
      - kind: mcp
        tool: <deployment's inbound-content MCP tool name>   # e.g. a transcription workspace
      - kind: file
        path: <a deployment inbox path>
  external-discovery:
    trigger: { schedule: "weekdays 13:00" }
    sources: []                        # declared empty: a clean no-op, see Part IV
```

The rules on that block: **[DIRECTIONAL]**

- **A source is declared by class and instance.** `kind` names what the standard understands
  (`mcp`, `file`, `endpoint`); the instance (`tool`, `path`, `url`) is the deployment's own and never
  appears in canonical text.
- **The transcription source is one example, never the default.** [EVIDENCED] The reference
  deployment's sweep hardcodes a transcription-workspace MCP as its inbound source. In this design
  that source is one legal value of one `kind` under one routine, illustrative in a comment, shipped
  wired to nothing. A deployment with no transcription connectivity declares a different source or
  none, and the standard is unchanged.
- **The schedule is configuration too.** The cadence in Part II is a default a deployment overrides
  here, so a routine's trigger stops being a constant baked into a skill.
- **The validator gains coverage, not the body.** Whatever validates the profile validates the
  routines block, and, per the standard's own rule that a check reporting by absence is proven in
  both directions, that validation ships with a case proving it rejects a malformed source
  declaration and a case proving it passes a clean one, stating the mode it ran. This RFC does not
  write that check; it names it as the surface a later authorized change must touch.

---

# Part IV: Disconnected by default

## An unwired routine is a no-op, not an error

The standard ships the four routine **definitions** and the **config schema** for their sources, and
wires **no source at all**. A routine with an empty `sources` list is a **clean no-op**: it runs,
finds nothing declared to read, does nothing, and reports that it did nothing, without erroring.
**[DIRECTIONAL]** This is the owner's disconnected mode, and it is not a new discipline, it is a
discipline the standard already applies in two places, cited here so the design inherits rather than
invents:

1. **Opt-in per surface, from the projection contract (v1.24).** The projection contract's fourth
   gate is that a surface receives a projection only if it is listed in that surface's own manifest,
   projection is opt-in per surface, never everything everywhere. A routine reading only its
   declared sources is the same posture: nothing is read that a deployment did not name.
2. **Latent until adoption, from the adoption model.** The standard's whole adoption flow is that a
   canonical mechanism ships and binds nothing until a hub adopts it under its own governance; the
   owner queue section states the same for itself, that a single-hub deployment does not need it and
   the mechanism adopts only when a deployment's output can out-produce its one decider. Routines
   ship latent in exactly this sense: present in the standard, active in a deployment only when that
   deployment declares a source.

## Fail-closed is the pairing that makes disconnected safe

A no-op on **no** source is correct; a silent no-op on a source that was **declared but could not be
read** is the failure mode the standard forbids everywhere else. **[DIRECTIONAL]** The two must be
distinguished, on the standard's established rule that anything deriving from a read checks
readability first and that a check fails closed on any input it could not evaluate:

- **No source declared** → clean no-op, reported as *disconnected*, green.
- **Source declared, resolves, empty** → ran, nothing new, green.
- **Source declared, does not resolve or cannot be read** → **fail closed**, reported as a coverage
  gap, never folded into a green verdict.

The distinction is the whole safety of disconnected mode: without it, a deployment whose MCP tool
silently stopped answering would look identical to a deployment that deliberately wired nothing, and
the standard has a name for that, an unread tree is not a clean one.

---

# Part V: The version-conformance watch the standard needs for itself

## The need is evidenced, and it is the standard's own blind spot

The standard's entire propagation model is that hubs **pin a version** and catch up through
governed retrofit waves, deployment pins resolve the version they pinned until the Supervisor
re-pins. That model has a hole it does not currently report: **nothing tells the estate which hubs
have fallen behind the pinned version, and by how much.** [EVIDENCED] This is not hypothetical. The
reference deployment's own reusable component drifted roughly two thousand lines behind the pinned
standard before anyone counted the gap, which is the same class of failure RFC-004 Part I diagnosed
for a hand-maintained manifest, a pass that is the absence of a comparison nobody made. A model
built on pinning with no drift report is a model that discovers its own arrears by accident.

## What the routine reports

A routine, on a cadence, that reports **per-hub conformance drift against the pinned standard
version**. **[DIRECTIONAL]** Its shape follows the standard's own rules for a check whose pass is an
absence:

- **For each hub: the version it pins, the current published version, and the distance between
  them.** A hub pinning the current version is conformant; a hub several versions behind is reported
  with the count, not a silent OK.
- **It reports drift; it never closes it.** Consistent with the standard's report-never-repair
  discipline (the harness projection, v1.32) and its separation-of-roles rule that whoever changes
  the standard is not who edits hubs to match it. This routine counts arrears; retrofit remains a
  governed adoption act each hub owner makes.
- **It states its own coverage.** How many hubs were read, how many pins resolved, how many could
  not be evaluated, so a hub whose pin cannot be read is a reported coverage gap and never a hub
  assumed current.

## The reference-deployment exemption, written into the design

[DIRECTIONAL] This routine, run naively, would report the **reference deployment** as the estate
most in arrears, because it is: the reference deployment leads the standard, invents ahead of it, and
is behind the last release **on purpose**. A conformance watch that flagged that as a defect would
do exactly what this whole tier exists to prevent, drag the lab back to the last release. The design
therefore names the exemption in the routine itself: a deployment (or a component within one)
declared as the **reference deployment** for a mechanism is reported as *ahead / reference*, not as
*behind / non-conformant*, and its drift is expected rather than actioned. The exemption is a
declared status, not an inference, so a deployment cannot quietly exempt itself from real arrears by
claiming to be the lab.

---

# Part VI: Two open design questions, stated not answered

Both are real, both are within reach, and neither is the maintainer's to settle by inference.

**(a) Elevate an obligation and deadline watch to a first-class routine.** [DIRECTIONAL] Today the
watching of dated obligations, retention windows, review-due dates, and the standard's **own tier-B
seven-day veto-window expiry**, is scattered: some of it is a buried check inside periodic hygiene
(shape D), some of it is not watched by any routine at all. [EVIDENCED] The reference deployment's
review found dated obligations (a fourteen-day destruction window, a two-day resurrection watch)
depending on someone remembering, and its own tier-B rule creates deadlines the standard produces
but no routine surfaces as they approach. The question: should obligation-and-deadline watching be
its own routine shape, ranked and cadenced, rather than one line inside hygiene? The argument for is
that a deadline the estate itself created (the veto-window expiry) and then does not watch is the
sharpest possible version of the drift this RFC is about. The argument against is a fifth shape where
four were the point. **Stated, not answered.**

**(b) Should cross-hub reconciliation and divergence detection run on a cadence?** [DIRECTIONAL]
The standard ships reconciliation as an **event-driven** mechanism, run when content crosses or when
a contradiction is raised. Nothing runs it on a **schedule** to detect divergence that accrues
quietly between events, two hubs' settled facts drifting apart with no crossing to trigger the
check. The question: does cross-hub reconciliation belong in a routine's cadence (plausibly shape D
or a dedicated shape), or is event-triggering sufficient and a cadenced pass just cost? The evidence
does not settle it, and the cost (reconciliation is the expensive layer) argues for caution.
**Stated, not answered.**

---

# What this RFC must NOT do

1. **It must not add a new owner-facing output channel.** A routine's output is the queue and the
   machine-facing brief the standard already governs; the whole reason the queue sections exist is
   that routines each grew their own ask surface. A routine defined here surfaces through the
   existing contract or not at all.
2. **It must not ship any source wired.** Disconnected by default is the design, not a deployment's
   later choice to disconnect. The transcription source, and every source, is an example in a
   comment, never a default in the schema.
3. **It must not let an unread source pass as a no-op.** The disconnected/failed distinction in
   Part IV is load-bearing; collapsing it would reintroduce the silent-failure class the standard
   forbids.
4. **It must not action the reference deployment's drift as non-conformance.** Part V's exemption is
   part of the design, not an operational courtesy, and it is a declared status rather than an
   inference so it cannot be abused.
5. **It must not fix the number of routines as canonical.** Four is the reference deployment's
   consolidation and a good default; the standard defines routine **shapes and the config that binds
   them**, and a deployment declares which it runs. Freezing exactly four would hardcode one estate's
   architecture into the standard, the very mistake this RFC exists to undo.
6. **It must not claim a routine enforces anything.** A routine reads, scans, drafts, and reports;
   application stays a governed owner decision. Describing a routine as a control would be the false
   assurance the standard holds to be worse than an acknowledged gap.

# What it would cost a deployment to adopt

- **Per deployment, once:** a routines block in the profile declaring, per routine it runs, its
  trigger and its sources. A deployment that declares nothing runs nothing and stays green, the same
  no-cost-to-decline property RFC-004 required of the projection block.
- **Per deployment, once:** the four routine definitions and the config schema ship with the
  standard; the validator gains a routines case with both its directions proved.
- **Ongoing:** nothing, unless a source changes, in which case the cost is one config edit, not a
  skill rewrite, which is the point of moving sources into config.
- **The reference deployment specifically:** it re-expresses its four hardcoded-source routines as
  four config declarations, and declares itself the reference deployment for the conformance watch
  so it is reported as ahead rather than behind.

# What the reference deployment carried that was too specific to generalise

Named honestly, per the harvest discipline, so a later session does not mistake deployment shape for
standard:

- **The specific inbound source (a transcription-workspace MCP and its tool names).** Genericised to
  a `kind: mcp` source example. It is one deployment's connectivity, not a standard concept, and it
  is the exact thing Part III exists to push into config.
- **The single-owner identity and the estate's absolute paths.** Not generalised at all; they are
  overlay and deployment configuration, and they appear nowhere in this design except as the reason
  sources must be configurable.
- **The exact cadence grid (09:00 / 13:00 / Monday / Friday, with jitter and specific clock times).**
  Kept only as an illustrative default; the real content is that cadence is a declared trigger, not a
  constant. The specific clock arithmetic is a deployment's scheduling detail with no canonical
  meaning.
- **The specific enterprise-knowledge and erasure-store checks (shape D in the reference
  deployment).** These fold into hygiene as *check the estate's own derived surfaces and dated
  obligations* generically; the particular surfaces (a named semantic-layer verifier, a named
  erasure-store mirror path with `rsync --delete`) are one estate's instruments and belong to that
  deployment, not to the standard. The generic obligation is Part VI(a); the specific scripts are not
  harvested.
- **The scouting query banks, scoring rubric, and rotation.** Shape B is genericised to *scan
  declared external sources, score, route above a threshold*. The particular query banks and the
  external endpoints (a code-hosting API, a news aggregator) are deployment connectivity, declared as
  `kind: endpoint` sources, never canonical.

---

# Summary of what would change, if this were later authorized

Nothing in this RFC changes anything today. If it were separately authorized:

| Surface | Change |
|---|---|
| `STANDARD.md` | A new section defining what a routine is (trigger, phases, declared sources, governed output), the four routine shapes by function, the disconnected-by-default and fail-closed posture, and the version-conformance watch with its reference-deployment exemption |
| `contracts/organization-profile.schema.json` (or a parallel routines profile) | A routines block: per routine, a trigger and a list of sources declared by `kind` and instance |
| The profile validator | A routines-block case, both directions proved, stating the mode it ran |
| Routine definitions / skills | Four generic routine definitions shipped wired to no source, sources read from config, single-process phase order preserved |
| A conformance-watch check | A per-hub pin-vs-published drift report that states its own coverage, reports and never repairs, and honours a declared reference-deployment status |

No version number is claimed, no version-history row is added, and no deployment pin moves. Adoption,
if any part is later authorized, follows the standard's three-hop flow: the maintainer changes the
standard and writes one handover, the Supervisor decides scope with the owner, and each hub adopts
under its own governance. The reference deployment adopts by re-expressing its routines as config,
not by being dragged back to the last release, and the design says so in Part V so the next
conformance pass cannot.
