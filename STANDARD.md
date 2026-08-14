---
type: brief
title: Knowledge Management Standard: Hub Framework (v1.21 DRAFT — awaiting owner push)
description: Reproducible, organization-agnostic standard for standing up a governed, agent-readable knowledge hub for any initiative, project, or team, with an optional cross-hub Supervisor tier for routing cross-cutting sources, and an optional Agent Tier for named, discoverable agent instances.
tags: [standard, knowledge-management, governance, okf, agents]
resource: template/
timestamp: 2026-08-06
---

# Knowledge Management Standard: Hub Framework (v1.21 DRAFT — awaiting owner push)

**DRAFT — awaiting owner push.** v1.20 (the owner queue) and v1.21 (the `[ RESTRICTED ]`
narrowing) are drafted but unpublished; the last published version is **v1.19**, and every
deployment pin continues to resolve against v1.19 until the owner pushes.

**Status:** Active standard. Framework-agnostic, works with Claude, GPT, Gemini, or any other LLM agent, and equally well with no agent at all (plain human use).

**One exception, deliberately:** the optional **MCP surface** (see *Query surface (MCP)*) is
agent-only by construction. It adds nothing for a human reader and requires none of them to exist.
The hub itself, every file, every rule, every check, remains plain markdown that works with no
agent at all. The MCP server is an **additive consumption path**, never a dependency: delete it and
the hub is unchanged.

---

## Purpose

Every significant initiative, a product launch, a research project, a partnership, an internal
platform build, generates a sustained flow of intelligence: meeting notes, proposals, architecture
decisions, risk assessments, vendor briefings, and strategic memos. Without a disciplined structure,
this intelligence fragments across email threads, chat history, slide decks, and personal notes, and
degrades the moment a team member rotates out or a new collaborator (human or AI) is onboarded.

This standard defines a **knowledge hub framework**: a small, opinionated set of conventions for
organizing a project's knowledge as plain markdown files, with enough structure that both humans and
AI agents can reliably read, trust, and extend it. It can be stood up for a new initiative in under
two hours, by any team, in any organization, with no proprietary tooling.

**What it gives you:**

- A single, auditable source of truth for an initiative, decision-grade, not just archival
- Full agent-readiness: any AI agent can consume the hub without a lengthy onboarding conversation,
  because structured metadata is embedded in every file (Open Knowledge Format, OKF)
- Governance controls that prevent silent corruption: no file is changed without a traceable proposal,
  approval, and integrity check
- Portability: the hub is plain markdown, no proprietary tooling, no vendor lock-in, reproducible on
  any filesystem, syncable with any cloud storage or version control system

**Why plain, local, governed markdown:** A knowledge hub that is vendor-neutral, storage-agnostic,
integrity-verified, and agent-agnostic keeps an organization in control of its own institutional
knowledge. This framework deliberately avoids cloud-hosted wikis with proprietary export formats,
note-taking platforms that lock content behind an API, and any system where the source of truth lives
outside the organization's own storage. It works equally well for a solo founder, a five-person
nonprofit, or a large enterprise team, the governance model scales down as easily as it scales up.

---

## System Architecture

The framework has two independent, complementary layers, plus two optional layers for more advanced
use cases.

### Layer 1: Format (OKF)

Every hub document carries a YAML frontmatter block conforming to the Open Knowledge Format (OKF):
an open, vendor-neutral convention that formalizes the "LLM-wiki pattern", a directory of markdown
files with structured metadata that any agent or tool can parse without reading the full document
body.

OKF contributes: **queryability by type and tag, embedded provenance, interoperability across agent
systems and tools.**

### Layer 2: Governance

A lightweight governance layer sits on top of the format. It enforces five rules that prevent the hub
from drifting into an uncontrolled, unreliable state:

1. **Inbox-first**, all incoming files land in `_inbox/` before anything else
2. **Proposal/approval**, no hub document is edited without a traceable change record
3. **Git-backed integrity**, every hub is a git repository; uncommitted or untracked changes to a
   monitored file are flagged automatically
4. **OKF frontmatter on every doc**, enforced at scan time, not just at authoring time
5. **Source traceability**, every fact in a hub document traces to a named origin; a fact whose
   origin cannot be named is flagged at intake, never blended into settled prose

Governance contributes: **auditability, change control, integrity, and accountability.**

Integrity checking is git-backed rather than a hand-maintained hash file: git already does
content-addressed, incremental change detection natively, and every applied change becomes a real
commit, a full audit trail for free, instead of a single current-state snapshot.

Neither layer is sufficient alone. OKF without governance produces well-formatted documents that
anyone can corrupt silently. Governance without OKF produces a controlled but agent-opaque archive.
Together they produce a hub that is simultaneously human-readable, machine-readable, auditable, and
sovereign to the organization that owns it.

### Layer 3: Reconciliation (optional, single-hub)

As a hub accumulates sources, facts begin to contradict each other. The optional reconciliation layer
maintains a separate, human-adjudicated ledger of **settled facts** that supersede any contradicting
source, without ever modifying the source documents themselves. See **Reconciliation Layer** below.

### Layer 4: Supervisor (optional, cross-hub)

Layers 1–3 govern a **single hub**. When an organization runs several hubs *and* draws on
**cross-cutting sources**, an all-hands meeting, a leadership briefing, a document that touches
several initiatives at once, an optional fourth layer routes facts to the correct hub and records how
hubs relate to each other. The Supervisor never bypasses Layers 1–2: it *dispatches* proposals into
each target hub's own governance. It is defined in full under **Supervisor Tier, Cross-Hub
Orchestration** below, including its estate extensions: the shared-entity registry (semantic layer),
the escalation protocol, and the evidence standard. It is only needed once two or more hubs share a
source or an entity. A single-hub deployment
can ignore it entirely.

### Enterprise organization profile extension (v1.14)

Every new hub begins from the canonical KM Standard. Canonical `km-init` creates an
organization-neutral hub, records the canonical version, full Git revision, and source in
`km-deployment.md`, runs the canonical scan, and creates the initial scaffold commit. It does not
infer or apply organization policy.

An optional `OrganizationProfile` supplies declared organization additions and transformations after
canonical initialization. The generic contract is
[`contracts/organization-profile.schema.json`](contracts/organization-profile.schema.json), and the
dependency-free validator is
[`scripts/validate_organization_profile.py`](scripts/validate_organization_profile.py). The
Enterprise Knowledge Layer owns each profile's identity, revision, approval record, effective date,
enterprise namespace, contract revision, policy references, and module eligibility decisions.

The Supervisor orchestrates deployment but does not own enterprise truth. It resolves one approved
profile from the configured Enterprise Knowledge Layer, pins both the canonical and profile
revisions, validates compatibility and authority, and applies only declared operations. The hub then
records the profile and enterprise binding in `km-deployment.md`.

Deployment has two auditable commits:

1. canonical `km-init` creates and verifies the organization-neutral scaffold;
2. the Supervisor applies and verifies the approved organization profile separately.

A profile may add files only at declared extension paths and may enable a module only with an
eligibility record. It may not replace the canonical initializer, carry a canonical template copy,
weaken canonical governance or scan controls, replace generic agent instructions, copy enterprise
records into the hub, or enable a module without an eligibility decision.

Validation fails closed. An unavailable, unapproved, incompatible, malformed, or overreaching
profile is not applied. A failed customization leaves the verified canonical commit intact, does not
produce an organization-ready claim, and does not register the hub as organization-bound.

Claude and Codex adapters expose the same governed capability. Their syntax may differ, but profile
contract, source revisions, authority, scope, validation results, and stopping points must remain
semantically identical.

---

## Hub Directory Structure

The canonical layout below is fixed. Adapt folder names only for initiative-specific subfolders inside
`working-docs/` and `sources/`. Everything else is standard.

```
<initiative-name>/
│
├── CLAUDE.md                        ← Agent instructions (Claude Code convention)
├── AGENTS.md                        ← Agent instructions (Codex / AGENTS.md convention)
├── README.md                        ← Hub overview, contents, governance rules (human-readable)
├── hub-scan.sh                      ← Session-start integrity + governance scan script (git-backed)
├── km-deployment.md                 ← Canonical and optional organization profile provenance
├── context.jsonld                   ← Root JSON-LD context — resolves frontmatter to a shared vocabulary
│
├── 00_about.md                      ← Hub initiator profile (role, organisation, goals, agent notes)
├── 01_project-brief.md              ← What the initiative is, why it exists, status
├── 02_<context-doc>.md              ← Context, scope, or technical architecture
├── 03_roadmap-milestones.md         ← Rollup: plan, phase gates, budget — links to milestones/
├── 04_stakeholders.md               ← Rollup: reporting lines, narrative — links to stakeholders/
├── 05_partnerships-pipeline.md      ← Rollup: partnership narrative, pipeline — links to partners/
├── 06_risks-decisions.md            ← Rollup: blockers, narrative — links to risks/ and decisions/
├── 07_glossary.md                   ← Canonical terms and acronyms
├── [08–10_<additional>.md]          ← Optional: additional initiative-specific docs
│
├── decisions/                       ← One entity note per decision (type: Decision)
├── risks/                           ← One entity note per risk (type: Risk)
├── stakeholders/                    ← One entity note per person (type: Stakeholder → schema:Person)
├── milestones/                      ← One entity note per milestone (type: Milestone → schema:Event)
├── partners/                        ← One entity note per partner (type: Partner → schema:Organization)
├── relationships/                   ← Optional: one note per relationship assertion
│                                      (type: RelationshipAssertion) — see § Relationship layer
├── corrections/                     ← One note per correction (type: Correction) — the standing
│                                      rules produced when someone said "no, that's wrong"
│
├── _inbox/                          ← Drop zone — ALL incoming files land here first
│   └── README.md                    ← Governance reminder (no exceptions)
│
├── changes/                         ← Pending proposals and approvals
│   ├── PROPOSAL_TEMPLATE.md
│   └── APPROVAL_TEMPLATE.md
│
├── sources/
│   ├── transcript-index.md          ← Inbound provenance index (meetings, memos, documents)
│   ├── dates-register.md            ← Date gate control point — no source ingested without a date
│   ├── publication-log.md           ← Outbound provenance index (artifacts sent, audience, commit)
│   ├── decks/                       ← Source decks + digests
│   ├── docs/                        ← Source documents + digests
│   └── [initiative-specific]/       ← Additional source subfolders as needed
│
├── archive/                         ← Retired narrative docs. Kept for the audit trail,
│                                      excluded from generated artifacts.
├── working-docs/                    ← Team output files (memos, briefings, strategy notes)
│   └── [topic-subfolders]/
│
├── shareable/                       ← Sanitised versions safe for external sharing
│   └── [initiative]_Overview.md
│
└── assets/
    └── architecture/                ← Diagrams and visual materials
```

**Monitored files** (subject to integrity checking and OKF frontmatter enforcement):

```
0[0-9]_*.md   10_*.md   CLAUDE.md   AGENTS.md   README.md   km-deployment.md   context.jsonld
sources/transcript-index.md   sources/publication-log.md
{decisions,risks,stakeholders,milestones,partners}/*.md, excluding TEMPLATE.md
reconciliation/*.md topic files, excluding reconciliation/README.md
```

`reconciliation/README.md` is instructional and is not a settled-fact topic file. Reconciliation topic
files in the root of `reconciliation/`, excluding `README.md`, become monitored once present.

---

## OKF Frontmatter Standard

Every monitored hub document must open with a YAML frontmatter block. `type` is the only required
field; all others are strongly expected. Missing frontmatter is flagged as an error by `hub-scan.sh`.

### Block structure

```yaml
---
type: <type>
title: <human-readable title>
description: <one-sentence description of what this document contains>
tags: [<tag1>, <tag2>, ...]
resource: <path to primary source, or a source-system URI>
timestamp: <YYYY-MM-DD of last approved update>
---
```

### Standard type taxonomy

| Type | Use for |
|---|---|
| `brief` | Project overview / charter, what the initiative is and why it exists |
| `architecture` | Technical architecture, stack, component map, scope/context |
| `roadmap` | Plan, milestones, dates, owners, budget |
| `stakeholders` | People, roles, reporting lines |
| `partnerships` | External partners, pipeline, client relationships |
| `decisions` | Risks, blockers, open decisions awaiting leadership |
| `glossary` | Canonical terms and acronyms |
| `concept` | Strategic vision, product definitions, thematic frameworks |
| `status` | Build/execution status (e.g. sprint reports, delivery snapshots) |
| `index` | Source provenance indexes |
| `config` | Agent instructions, hub configuration (CLAUDE.md, AGENTS.md, README.md) |

Extend the taxonomy for your organization if needed, the fixed part is that every hub document
declares its `type` so agents can filter and query reliably.

### Tagging conventions

Tags are free-form but should be drawn from a consistent vocabulary per initiative. Recommended
practice: define 5–10 canonical tags in your `07_glossary.md` under a "Tag vocabulary" section, and use
only those tags in frontmatter. This allows agents to filter docs by topic reliably.

### `resource` field convention

Point to the document's primary source:
- A path within the hub: `sources/docs/partner_brief_digest.md`
- An external source-system URI: `<system>://<record-id>`
- A source-system search reference: `<system>://search`

---

## Ontology & Entity Layer

OKF frontmatter, as defined above, is descriptive metadata, it doesn't resolve to anything, and isn't
connected to any shared vocabulary. This section closes that gap using the pattern defined by
[Vault-LD](https://github.com/The-Knowledge-Graph-Guys/vault-ld), an open spec that treats a directory
of markdown notes as an RDF graph: each note's YAML frontmatter, read through one shared JSON-LD
context, becomes that note's triples.

### The context.jsonld lift

Every hub ships a root `context.jsonld` that aliases the existing `type` field to `@type` and declares
a `@vocab` for hub-specific terms. This is Vault-LD's "Lifting an OKF Bundle" pattern (its Appendix B):
adding this one file makes every existing hub doc and entity note already-valid linked data, with **zero
changes to existing content**. See [`template/context.jsonld`](template/context.jsonld) for the
reference file, it's populated with the five entity classes below and is ready to copy as-is, adapting
only `@base`/`@vocab` per hub.

### Five entity types, and why they're split this way

Per ["Your Ontology, Your IP"](https://www.knowledge-graph-guys.com/blog/your-ontology-your-ip): an
ontology becomes real intellectual property when it's built as *open-standard common ground* plus
*proprietary extension*, the extension is what only this organization knows, and that's the actual
value. This standard's five entity types are grounded accordingly:

| Type | Grounds in | Why |
|---|---|---|
| `Stakeholder` | `schema:Person` | People are common ground, no organization needs its own definition of what a person is |
| `Partner` | `schema:Organization` | Same reasoning, organizations are a solved, open-standard concept |
| `Milestone` | `schema:Event` | A dated, owned thing happening, schema.org already models this well |
| `Decision` | *(none, proprietary)* | How and why *this* organization decides things has no open-standard equivalent; it's this hub's own vocabulary |
| `Risk` | *(none, proprietary)* | Same, risk framing is organization-specific |
| `RelationshipAssertion` | `rdf:` reification + `prov:` | Optional sixth type. *How people relate* is partly common ground (`org:reportsTo`, `org:memberOf`) and partly proprietary (how your organization evidences collaboration), see § Relationship layer |
| `Correction` | *(none, proprietary)* | Seventh type. How *this* organization learns from being wrong has no open-standard equivalent, and the rules it produces are the organization's own tribal knowledge, which is exactly the part worth keeping. See § The correction loop |

Extend `context.jsonld` with more proprietary terms freely as an initiative needs them, that extension
*is* the ontology's IP, per the reasoning above. Do not invent proprietary replacements for `Stakeholder`
or `Partner`; grounding those in schema.org is what keeps the hub interoperable and avoids the vendor
lock-in that a fully bespoke schema would create.

### One instance, one file

Vault-LD's triples live in frontmatter only, a table row inside a document body is not captured at all
(its SPEC §5.3 is explicit about this). So each individual decision, risk, stakeholder, milestone, or
partner is its **own markdown note**, living in the matching subfolder (`decisions/`, `risks/`,
`stakeholders/`, `milestones/`, `partners/`), not a row in a table. See
[`template/decisions/TEMPLATE.md`](template/decisions/TEMPLATE.md) and its four siblings for the exact
frontmatter shape of each type. Fields that reference another entity (`owner`, `decidedBy`) are
wiki-links to a stakeholder note by name, that's what makes them real graph edges, not just strings.

The numbered docs (`03`–`06`) don't disappear, they become **narrative rollups**: phase gates, budget,
reporting lines, and blocker prose stay there, but anything that was "one row = one fact" becomes a
short linked list pointing at entity notes. A human reading `06_risks-decisions.md` top to bottom still
gets the full picture; an agent or query tool gets individually addressable, typed facts.

### The correction loop (seventh type)

The moment someone says *"no, that's not how we count that"* is the single richest signal a hub ever
receives. It is the point at which knowledge that lives only in someone's head, how this
organization actually does things, becomes visible. It is also, in most systems, thrown away.

A `Correction` note captures it. The trigger is cheap to detect because governance already
instruments every one of these moments:

| Trigger | The moment |
|---|---|
| `rejected-proposal` | A reviewer rejected a change. **Why** they rejected it is the knowledge. |
| `dispute` | A source contradicted a settled fact and the owner adjudicated. |
| `owner-correction` | The owner corrected an agent in conversation, outside the proposal flow. |
| `agent-error` | An agent got something wrong and the mistake was diagnosed. |

#### `rule:` is the whole point

The note records what was got wrong, but the durable field is `rule:`, the standing instruction the
mistake produces.

> **Correct the behaviour that led to the answer, not the answer.**

Fixing an output resolves one instance. A rule resolves the class, and survives after the incident is
forgotten and the people who remember it have moved on. If a correction produces no rule, it is
probably an ordinary edit, not a `Correction`.

#### Rules bind, so they must also retire

Agents read `corrections/` at session start and treat every `lifecycle: active` rule as binding. That
makes a stale rule **worse than no rule**: it silently constrains work for reasons that no longer
apply, and it is invisible precisely because it is obeyed.

Every `Correction` therefore carries `lifecycle: active | superseded | retired`. Retiring a rule is a
normal, expected act, not an admission of error, the conditions that produced it change. Retired
notes are kept for the audit trail and excluded from agent reads and generated artifacts. A
`corrections/` folder that only ever grows is a defect.

#### Where corrections do not belong

A `Correction` records a rule about **how the organization works**. It does not restate the fact that
was fixed, that lives in the entity note or hub doc, corrected in place through the normal flow. Nor
does it replace reconciliation: reconciliation adjudicates **which fact is true**; a correction
captures **what to do differently next time**. A dispute may well produce both.

#### Promotion: a rule learned in one hub must be able to reach the others (added in v1.9)

**Applies to any workspace running more than one hub.** A single-hub deployment can ignore this
section; the problem it solves does not exist there.

A hub agent that gets something wrong writes the rule into **its own** `corrections/`. That is
correct, and it is also where the knowledge stops. The scoping decision, *is this rule local or
general?*, is made **by one agent, inside one hub, at the moment of the incident, with no visibility
of any other hub.** The agent cannot know that a sibling hub hit the same wall last week, and nothing
re-reads the decision afterwards.

The observed failure is not theoretical. In one workspace, two rules were written at estate level,
*read the source before characterising it* and *resolve names against the registry before writing
them*, by an agent that had just made both mistakes. **Both already existed, in a hub, written weeks
earlier.** The estate re-learned by failing what it already knew.

**Propagation is usually already solved**: where estate-level corrections bind every tier, a rule
that reaches the estate reaches everyone. What is missing is **detection**. Three mechanisms close it:

**1 · The promotion duty.** When a hub agent writes a correction, it asks: *would this bind a hub
that has never heard of this initiative?* If plausibly yes, it raises a promotion escalation rather
than deciding alone. Being told "stays local" is a cheap and normal outcome; **not asking is the
failure mode.** This mirrors the ontology-proposal duty, and for the same reason: the agent best
placed to notice is the one least placed to judge scope.

**2 · A periodic sweep**, part of whatever recurring hygiene pass the workspace runs. Read every
hub's `corrections/` and look for three signals:

- **the same principle in two or more hubs**, however differently worded, the strongest signal, and
  the one that catches duplicate discovery;
- **a rule whose text names no initiative-specific noun**, a rule that never mentions its own hub is
  probably general;
- **a local rule that now duplicates an estate rule**, retire it, or keep it demoted as the incident
  record.

**3 · The ladder, written down.** The destinations usually exist; what is missing is any statement
that they form a progression, so the next agent re-derives it:

| Destination | Holds |
|---|---|
| Hub `corrections/` | A rule meaningful only inside that initiative |
| Estate/supervisor `corrections/` | A rule binding every hub in the workspace |
| The evidence standard | A rule about what to believe and in what order |
| This standard, upstream | A rule that would bind an organization that has never heard of yours, genericised, with a leakage check |

**Four cautions, each earned:**

- **Over-promotion is the real risk.** A rule promoted too eagerly makes every hub carry one hub's
  context. Use the test the ontology already uses: *does it survive deleting the proper nouns?*
- **Promote the rule; keep the incident.** The local note stays as the record of what happened,
  evidence is never rewritten. Only the rule travels.
- **Never auto-promote.** The sweep proposes candidates; a human decides. Matching rules by
  similarity will find connections that are not there, and a wrongly promoted rule binds everyone.
- **Promotion is a retirement moment.** A corrections folder that only ever grows is a defect
  (see "Rules bind — so they must also retire"); this is the natural point to prune.

**Sequence matters.** Introducing the duty and the sweep on top of an unexamined backlog starts the
mechanism already behind. Reconcile the existing corrections once, then turn on the standing
machinery.

### Relationship layer (optional sixth type)

The five entity types above describe *things*. They do not describe **how people relate**, who
reports to whom, who collaborates with whom on what, and on what evidence. Frontmatter fields like
`owner` and `decidedBy` carry a few edges, but they cannot express an edge that needs its own
provenance, confidence, or scope.

`RelationshipAssertion` closes that gap. It is **optional**, adopt it only when routing, org context,
or collaboration history genuinely matters to the initiative.

#### Why assertions are separate from people

A person note (`Stakeholder`) states directory facts: name, role, organisation. An assertion states a
**claim about a relationship**, which needs its own provenance because it may be inferred, dated, or
wrong. Keeping them separate means correcting an edge never disturbs a person record, and a reader can
always see *why* the graph believes an edge exists.

This is RDF reification: `subject` / `predicate` / `object`, plus provenance.

#### The assertion model

| Field | Purpose |
|---|---|
| `subject`, `object` | Wiki-links to `stakeholders/` notes, real graph edges |
| `predicate` | One of the vocabulary below |
| `scope` | Topics or initiatives the edge holds within (an edge is rarely unconditional) |
| `confidence` | `high` / `medium` / `low`, **epistemic**: how good the evidence is |
| `assertion_method` | `directory`, `directory-chain`, `communication-evidence`, `meeting-evidence`, `stated` |
| `evidence` | Resolvable references, a source path, page ID, or export + date |
| `observed_at` | When the claim was observed; edges age |

#### Predicate vocabulary

**Common ground**, ground these in W3C Org; do not invent replacements:

| Predicate | Grounds in | Direction |
|---|---|---|
| `reportsTo` | `org:reportsTo` | directional; inverse `supervises` |
| `memberOfUnit` | `org:memberOf` | directional |
| `hasSkipLevelManager` | *(extension)* | directional |

**Proprietary extension**, how *your* organization evidences collaboration. Extend freely; that
extension is the IP:

| Predicate | Direction |
|---|---|
| `collaboratesOn` | symmetric, scope-bound |
| `coordinatesWith` | symmetric |
| `frequentCollaboratorWith` | symmetric |
| `coLeadsInitiativeWith` | symmetric |
| `providesStrategicInputTo` | directional |
| `providesTechnicalOversightTo` | directional |
| `delegatesTechnicalLeadTo` | directional |
| `hasExecutiveSponsor` | directional |
| `hasGovernanceSponsor` | directional |

#### Four rules, and they are not optional

1. **Separate directory facts from inference.** A `directory` assertion and a
   `communication-evidence` assertion are different epistemic objects. Never blur them.
2. **`confidence` is evidence quality, never importance, strength, or performance.** A `high`
   confidence edge is well-evidenced, not a close relationship.
3. **This layer is never evaluative.** `frequentCollaboratorWith` means *repeated evidenced
   contexts*, not a ranking, not a performance signal. A relationship graph is trivially
   weaponisable as an ad-hoc org chart or a productivity metric. Do not permit that reading, and say
   so in the layer's own index.
4. **Evidence must be resolvable by a later reader.** An identifier only the original author can
   resolve is not provenance. If the trail cannot be reconstructed, record it as owner-attested and
   lower the confidence.

#### Sensitivity

A relationship layer describes people. Classify it restricted by default, keep it out of `shareable/`,
and remember that "who works with whom" is inferable personnel data even when every individual edge is
innocuous. Since v1.16 the boundary is checked, not just stated: mark a note with a line beginning
`sensitivity: restricted` and the `[ RESTRICTED ]` check in `hub-scan.sh` fails the scan if that
marker, the name of a note marked restricted in frontmatter, or the verbatim text of a body-marked
restricted section reaches `shareable/`, a change notice, or a generated index. A note restricted
only in one body section stays nameable on those surfaces; its section text does not travel
(narrowed in v1.21, see "Validating the graph", below).

#### One assertion, one file

Same Vault-LD constraint as every other entity: **only frontmatter becomes triples.** A YAML block in
a document body is not captured. Each assertion is its own note in `relationships/`. See
[`template/relationships/TEMPLATE.md`](template/relationships/TEMPLATE.md).

External people (clients, partners, government counterparts) are `Stakeholder` notes with
`involvement: external`, the same class, grounded in `schema:Person`. An organization may choose to
hold them in a separate folder or namespace; that is a local overlay decision, not a schema change,
and it must not fork the `Stakeholder` type.

### Why this matters beyond IP: pull queries and reliable generation

Individually addressable, typed entity notes are what make two things possible that prose tables don't:
someone else's agent can **query** the hub for a precise fact ("open decisions owned by X") instead of
re-reading an entire document, and **generating an artifact** (see "Artifact Generation (Push)" below)
becomes querying facts and wrapping them in narrative, instead of freehand re-synthesis every time,
which is slower and risks restating the same fact slightly differently across different artifacts.

**Design principle: the git commit is the publish boundary.** Any query or generation surface built on
top of entity notes must only ever reflect the last git commit, never an open proposal, an inbox draft,
or an unresolved dispute. Because every hub is already a git repository (Rule 3), "committed" and "safe
to expose" are the same thing by construction, with no separate access-control layer to build or
maintain.

---

## Governance Layer: Five Rules

### Rule 1: Everything goes to `_inbox/` first

**No file bypasses the inbox.** Partner decks, team memos, architecture images, transcripts, digests,
all land in `_inbox/` before anything else. The agent (or the human maintaining the hub) classifies the
file and routes it through the appropriate process.

Routing logic:
- **Source/input files** (decks, docs, external transcripts) → agent creates digest in `_inbox/`,
  proposes updates to hub docs, moves original to `sources/` after approval
- **Team output files** (memos, briefings, strategy notes) → proposed move to `working-docs/<topic>/`
- **Visual assets** → proposed move to `assets/architecture/`

The `_inbox/README.md` should contain only: "Drop all files here. Nothing bypasses the inbox."

#### The date gate

**No source leaves `_inbox/` without a resolved date.** A source with no date cannot be placed in a
timeline, cannot be ordered against other sources, and silently corrupts any later reconstruction of
how an initiative actually unfolded. Undated material is the most common way a hub's history becomes
unrecoverable, and the loss is invisible until someone asks "when did this start?"

`sources/dates-register.md` is the single control point. Every source gets a row before it is ingested:

| Status | Meaning | Ingestion |
|---|---|---|
| `MISSING` | No date yet | **Blocked.** Ask the hub owner. |
| `CONFIRMED` | Date from the document, or supplied by the hub owner | Allowed |
| `ESTIMATED` | Inferred, with the basis stated | Needs owner confirmation to become `CONFIRMED` |
| `UNKNOWN — reconstruction pending` | Owner has seen it and accepts the date is currently unrecoverable | Allowed; gap tracked for later recovery |
| `N/A — reference artifact` | A rate card, template, standard, or similar reference whose date is irrelevant to the timeline | Allowed; creates no reconstruction item and **never** appears in a timeline |

Rules:

1. **Look in the document first**, issue date, sent date, meeting date, version, "as of" line. Record
   the value *and how it was derived*.
2. **Never guess or backfill.** An inferred date is `ESTIMATED` with its basis stated, and stays that
   way until the owner confirms it.
3. **Flag missing dates prominently.** Silence about a missing date is how it becomes permanent.
4. **When a pending date is recovered**, update the register and any affected docs through the normal
   proposal/approval flow.
5. **A document date is not an event** (added in v1.4). A document's date is a property of a file,
   when it was written. *Sent*, *submitted*, *received*, *agreed* are events between parties, each
   needing its own evidence. Never infer an event from a document date; with only the document date,
   record only the document date. This is the date-gate discipline applied one level up: guessing an
   event instead of a date. (The tell in the incident that produced this rule: the hub was still
   *revising* a proposal it claimed was already with the client.)

The `N/A — reference artifact` status exists because a strict gate otherwise blocks material that has
no meaningful date at all. Reference artifacts are marked by the owner and excluded from timelines,
they are not evidence of when anything happened.

### Rule 2: All hub doc edits go through proposal/approval

No monitored hub document is edited directly, not by a human, not by an agent. Every change follows
this flow:

```
1. PROPOSE  →  create changes/<YYYY-MM-DD>_<initials>_<slug>_proposal.md
2. APPROVE  →  reviewer creates changes/<YYYY-MM-DD>_<slug>_approval.md
3. APPLY    →  agent applies changes, moves inbox files, deletes both change files
4. LOG      →  agent logs the action in sources/transcript-index.md
5. COMMIT   →  agent stages the changed paths by name and commits
               (git add <path> ... && git commit -m "apply: <slug>"; see Rule 3)
```

**Exception:** explicit real-time confirmation from the hub owner in chat constitutes approval.
Governance infrastructure files (`hub-scan.sh`) may be updated by the agent at the hub owner's direct
instruction.

#### The exception must produce the same artifact as the formal path

This exception is the **most-used path in practice**, most work happens in conversation, not through
proposal files. That makes it the largest source of corrections in the system, and the easiest place
to lose them: a proposal leaves a file behind, a conversation leaves nothing.

**When a hub owner's real-time confirmation *corrects* the agent**, not merely approves a proposed
change, but tells it that something it did, assumed, or wrote is wrong, the agent writes a
`corrections/` note (`trigger: owner-correction`) and commits it **with** the change.

Distinguish the two, and do not inflate the count:

| Owner says | Artifact |
|---|---|
| "Yes, apply that" | Approval. No correction, nothing was wrong. |
| "No — take names from the directory, the transcript mis-hears them" | **Correction.** A durable rule about how the organization works. |
| "Use level 5, not level 6" | Correction *if* it generalises; a one-off decision if it does not. Record the decision, not a rule. |

The test is the same as everywhere else in this section: **can you state a rule?** If yes, the
correction is real and the rule outlives the conversation. If no, it was a decision, log it as one.

Without this, an agent corrected in chat fixes the instance, the session ends, and the correction is
gone. The next agent, or the same agent next week, repeats the mistake, and the hub owner corrects
it again. That loop is invisible precisely because each individual correction feels cheap.

Approval file outcomes:
- `APPROVED` → apply all changes
- `APPROVED WITH CONDITIONS` → **capture each excluded item's reason as a `corrections/` note**
  (`trigger: rejected-proposal`), then apply only non-excluded items, respecting remarks. A condition
  is a correction: someone said "not that part, and here's why."
- `REJECTED` → **capture the reviewer's reason as a `corrections/` note** (`trigger:
  rejected-proposal`) and commit it, **then** delete both files and log the rejection

#### Never delete the reason

The proposal and approval files are deleted once applied, that is deliberate; `changes/` is a
workspace, not an archive, and git holds the history. But the reviewer's **reason** must survive that
deletion.

A rejection is the clearest signal a hub ever gets: a human, at the moment of correction, saying *"no,
that's wrong."* Recording only *that* a rejection happened, and discarding *why*, throws away the
most valuable thing in the exchange and guarantees the same proposal returns. The `corrections/` note
is written and committed **before** the files are deleted, so the reason outlives the workspace.

See § The correction loop.

### Rule 3: Git-backed integrity check at every session start

Every hub is a git repository. Before any hub work begins, `hub-scan.sh` is run. It runs `git status`
against all monitored files. Any uncommitted or untracked monitored file means a change was made
outside the proposal/approval workflow, surface to the hub owner before proceeding.

This catches: manual edits by contributors who bypassed the workflow, accidental overwrites, sync
conflicts from cloud storage, and agent errors.

#### The curated handover is surfaced first and read before any state reconstruction (added in v1.17)

A hub keeps a single curated home of record for session-to-session state, `HANDOVER.md`: what the
hub is, its open items, the pre-send review points, and what the last session did. It is written
deliberately, at the end of a session, for the next reader. The raw git log and an uncommitted diff
are *not* that record: they are the unadjudicated material the handover was distilled from, and a
resuming session that reconstructs state from them instead of reading the handover skips exactly the
curated content that does not survive in commit subjects, an enumerated open-decision list, a named
pre-send review point.

Reconstructing state from raw history when a curated handover exists is an **evidence-hierarchy
inversion**, the same shape as the estate rule *check the hubs and the layer before the transcripts*:
the settled, adjudicated record outranks the raw stream it was built from, and is consulted first.
The defect that produced this rule was systemic rather than a lapse of attention: nothing at the
enforced session-start entry point surfaced the handover, and the only pointer to it was a
*conditional* advisory ("continuing prior work? read the handover first") that read as optional and
so was skipped by a session that did not classify itself as continuing prior work.

Two obligations close it, and both belong at the session-start entry point Rule 3 already defines:

1. **The scan surfaces it, first.** `hub-scan.sh` prints a `[ HANDOVER ]` block ahead of every other
   section, pointing the agent at `HANDOVER.md` unconditionally ("read it first, before any state
   reconstruction, no exceptions") and echoing its title. A **missing** `HANDOVER.md` is a required
   scaffold file that is gone, so it is reported as an **error** (exit 1), the same rank as missing
   frontmatter, not an advisory; the fix is to regenerate it via the handover skill.
2. **The instruction is unconditional.** The agent-instruction files (`CLAUDE.md`, `AGENTS.md`) name
   reading `HANDOVER.md` as the first read-first step with no precondition, not a conditional aside.
   An advisory that the reader must first decide applies to them is an advisory that the reader who
   most needs it will decide does not.

#### The curated handover is written before a state-changing session ends (added in v1.18)

The read side above is only half of a loop. It guarantees the *next* session reads the curated
handover; it does nothing to guarantee the handover it reads is current. A session that lands real
work and then ends without refreshing `HANDOVER.md` hands the next reader a confident, well-surfaced
record of a state that no longer exists, which is worse than a missing handover, because the read
side vouches for it.

The write side closes the loop at the one point the system can act on: session end. The handover is a
judgment-layer artifact, only the model can author it, and only a stop-gate can both refuse to end a
session and hand the model an instruction, so the obligation is enforced there. When a session has
landed commits that changed hub state but none of them touched `HANDOVER.md`, the gate blocks once
and instructs the model to refresh the current-state section via the handover skill and commit it,
before stopping.

Three properties make this a guardrail rather than a nuisance, and each is a rule, not a tuning
choice:

1. **Substantive work means committed work.** Uncommitted or untracked files are Rule 3's
   `[INTEGRITY]` concern, already surfaced at the next session start; counting them here would fire
   the gate on stray scratch. The gate judges from the same baseline the integrity check trusts,
   HEAD at session start against HEAD now.
2. **It fires at most once per session.** A stop-gate that re-blocks on the very turn that answers it
   is a loop; the model must always be able to say "nothing meaningful changed, no refresh needed" in
   one line and stop. The gate arms a one-shot marker per session and honours the runtime's own
   already-blocking signal, so it never re-enters itself.
3. **It is best-effort, and says so.** No true "session end" signal exists: the stop-gate fires at
   every turn boundary, so this guarantees *one* refresh per working session, not that the handover
   is the session's final word, and a session cleared rather than ended never triggers it at all. The
   read side and the periodic hygiene pass remain the backstop. This is a guardrail against the
   common failure, ending a working session with a stale handover, not a proof that the handover is
   perfect.

In the reference implementation this is `handover-hooks.sh` at the hub root, wired in
`template/.claude/settings.json` as a `SessionStart` baseline and a `Stop` check, with the script path
resolved portably through the runtime's project-directory variable so `km-init` installs it unmodified
into any hub location. The gate resolves the hub root from its own location and reads only committed
history, so it never depends on where the hub lives. It is a Claude Code mechanism; a surface with no
equivalent stop lifecycle enforces the same obligation through this standard and the read-side
surfacing alone. There is deliberately **no** session-end regeneration of any generated artifact: a
hub's only candidate, its generated entity indexes, are *monitored* files that must be committed
through the governed flow, and regenerating them out-of-band at session end would manufacture exactly
the uncommitted-monitored-file state Rule 3 exists to catch. `build-indexes.sh` already runs at apply
time, when an entity note actually changes; there is no deterministic hub artifact that wants a
detached rebuild, so none is invented.

#### The estate corrections registry is surfaced and bound at session start (added in v1.19)

A hub's agent-instruction files already bind the estate tier by reference: the evidence standard, the
identity home of record, and the escalation protocol are each named as governing this hub. The
estate's own `corrections/` registry was not among them. `PROTOCOL.md` asserts that a supervisor-tier
correction binds every tier, but nothing at the hub's enforced session-start entry point surfaced or
read it, so that binding was transitive assertion only, present in the supervisor's prose and absent
from the hub's session start. This is the same defect v1.17 found for the handover: a rule stated to
be binding, with no operational surface that makes it so, is skipped by exactly the session that most
needs it.

The fix mirrors v1.17, and both obligations sit at the session-start entry point Rule 3 already
defines. Both are conditional on the hub actually being part of an estate, so a single-hub deployment
is unaffected:

1. **The scan surfaces it.** In a multi-hub estate — the workspace root also holds `_KM_Supervisor/`
   — `hub-scan.sh` prints a `[ CORRECTIONS ]` block immediately after `[ HANDOVER ]`, pointing the
   agent at `../_KM_Supervisor/corrections/` and counting the `lifecycle: active` notes there whose
   `rule:` is in force in this hub. A standalone hub has no estate directory and the block prints
   nothing.
2. **The instruction is explicit.** `CLAUDE.md` and `AGENTS.md` declare, in the estate-binding
   section, that `../_KM_Supervisor/corrections/` binds this hub: read at session start alongside the
   hub's own `corrections/`, every `lifecycle: active` note's `rule:` in force, a supervisor-tier
   correction binding by reference and never copied down.

The registry is inherited by reference, not copied. A supervisor-tier rule lives in one place and
binds every hub from there; duplicating it into each hub would fork it and reintroduce exactly the
duplicate-discovery problem the promotion ladder (§"Promotion: a rule learned in one hub must be able
to reach the others") exists to close. The `[ CORRECTIONS ]` line is a pointer to that single home of
record, the same relationship the `[ HANDOVER ]` line has to `HANDOVER.md`.

#### Stage explicitly: what a commit contains is chosen, not swept up (added in v1.10)

This is a property of the **sync model**, not of any one version control system. The standard claims
portability in its own opening: the hub is *syncable with any cloud storage or version control
system*. Synced storage carries a property the version control system cannot see: **a deletion is not
durable until the sync agent has agreed to it.** The governance workflow deletes files on purpose (an
applied proposal, its approval, a resolved dispute). A sync agent that has not caught up, or that
resolves a conflict the other way, puts them back. A blanket "stage everything" then re-commits the
restored files as though they were live work, and a proposal applied last week returns as pending,
with a fresh commit vouching for it.

The same blanket command sweeps in artifacts belonging to no one: office lock files, OS metadata,
editor scratch, partial downloads.

**The rule, stated without reference to any one tool:** every commit stages an enumerated set of
paths the committer can name and account for. Never stage by "all changes", by wildcard, or by
"everything not ignored". In git that is `git add <path> [<path> ...]` rather than `git add -A`; in
another system it is whatever the equivalent explicit selection is. Before committing, check whether
anything under `changes/` is **reappearing** rather than being newly created. If it is, delete it
again and leave it out of the commit.

**One exception, deliberately narrow:** the initial scaffold commit of a new hub, where nothing has
been deleted yet and the tree holds only what the template put there.

**Ignore what is not yours.** The hub `.gitignore` covers OS metadata, editor scratch, and office
lock files, which shrinks the problem to the case that matters (resurrected governance files). No
ignore rule can catch that case, because those paths are legitimately tracked.

#### A read of synced storage can report absence that is only lag (added in v1.11)

The staging rule above is one half of a single fact about synced storage. That half says a
**deletion** is not durable at the moment you observe it. The other half says a **read** is not
complete at the moment you observe it, and it has sharper teeth, because acting on it writes rather
than commits.

Storage with on-demand files (OneDrive Files-On-Demand, iCloud "optimise storage", Dropbox smart
sync) keeps the directory entry at full size while the bytes live remotely. The first read triggers a
download that the reading process does not wait for, so the read returns empty and the file
materialises a moment later. Listing the file and the version control system both report thousands of
bytes; reading its first line returns nothing. Nothing is corrupt and nothing is missing. The file is
simply not here yet.

**1. An absence reported by a tool is a claim about a read, not a fact about a file.** It is evidence
of the same rank as any other tool output and it is checked the same way: read it a second time, or
compare the read against the size the directory entry and the version control system report. Do that
before calling "no frontmatter", "empty section" or "no body" a defect.

**2. Never write into a file that reported empty until you have proven it is empty.** A repair
applied to a placeholder destroys the real content the moment the download lands, and the commit that
did it is titled as a fix. That mistake is cheap to make and expensive to undo, which is why the rule
is stated as a prohibition rather than as advice.

**3. A check distinguishes a file it could not read from a file that genuinely lacks the field.**
Those are different findings with different fixes, and reporting them under one label makes storage
lag look like a content defect. In one estate on 2026-07-31 the collapsed label produced eleven false
"missing frontmatter" errors across six hubs in a single run, and every one of the eleven files had
valid frontmatter. Report an unreadable file under its own name and as an **advisory rather than an
error**, because the condition belongs to the storage and not to the hub. Then state that the content
checks did not cover it, so a passing scan is not read as a wider claim than it is.

**Do not retry, and do not sleep, to make the condition go away.** A scan that waits for the tree to
materialise reports a state that was not true when it started, hides that the workspace is not fully
local, and makes its own runtime nondeterministic. Reporting honestly costs one re-run.

**Anything that derives content from a read checks readability first.** A generator that rebuilds an
index, digest or summary from notes it could not read produces a wrong artifact with full confidence
and then overwrites the right one. Such a tool builds nothing if any input is unreadable. A stale
derived file is harmless; a confidently wrong one is not.

In the reference implementation this is a `[ READABILITY ]` gate in `hub-scan.sh` that runs before
every content check and withholds unreadable files from all of them, an abort in `build-indexes.sh`,
and a guards file in `km-publish.sh` that fails the build when it reads as empty while the directory
entry says otherwise.

#### A commit message claims only what was verified (added in v1.10)

A commit message is read later as evidence that something happened. It is the cheapest artifact in
the system to write and one of the most expensive to disbelieve: once a single message is found to
have overstated its change, every other message becomes a claim to check rather than a record to
trust, and the git history stops being the integrity baseline Rule 3 depends on.

Never commit on the strength of a step that was not verified to have completed. Chained steps hide
failure: `;` runs the next step whatever the previous one's exit status, and `&&` protects only
against a step that reports its own failure, so a command that writes nothing yet exits 0 passes
straight through. Check the exit status, then assert the intended result **in the artifact itself**
before staging: if the message says an annex was merged, read the file back and confirm the annex is
in it; if it says a correction was captured, confirm the note exists with its `rule:` field set.

**A commit message states what was verified after the fact, never what was intended.** If the
verification was not run, the message says what was written, not what was merged, applied, or fixed.

This binds a human committer as much as an agent. Agents fail it more often only because they chain
more steps between one verification and the next.

### Rule 4: OKF frontmatter on every monitored doc

All monitored hub documents must carry valid OKF frontmatter with `type:` set. `hub-scan.sh` checks
this at every session start. A new hub document proposed without frontmatter will be flagged.

A document the scan could not read is **not** a document without frontmatter, and the scan reports it
separately (see Rule 3, *A read of synced storage can report absence that is only lag*). Never add
frontmatter to a file on the strength of a read that came back empty.

When applying an approved proposal that adds or modifies a hub doc, verify frontmatter is present and
`timestamp` is updated to the date of application.

### Rule 5: Every fact traces to a named origin

Added in v1.4. The test: when someone asks **"where did you get this information from?"**, the answer
is a pointer, not a memory. Acceptable origins, in order of preference:

1. **An ingested document in the hub's `sources/`**, preferred, because the hub then holds the
   evidence itself and the pointer cannot rot
2. A document-store path (site + path)
3. An email (sender + subject + date)
4. A chat or channel thread
5. A meeting record or transcript
6. An external-retrieval run file (see the External Retrieval layer, where adopted)

Mechanically, Rule 5 rides rails the hub already has, the `resource:` frontmatter field,
`sources/transcript-index.md`, digest origin lines, and per-fact origins in ingestion proposals. What
it forbids is the gap between those rails: a fact appearing in settled hub prose that none of them
can account for. A fact whose origin cannot be named may enter only if it is **flagged as unsourced
at intake** (and carried as a hypothesis, not settled fact), never silently blended in. When two
sources could both account for a fact, record the one the fact was actually taken from.

#### Provenance has an order: record it, because it decides re-checkability (added in v1.5)

The list above is ranked for a reason: **not every named origin is equally recoverable.**

- **First-order**, the hub holds the artifact itself (option 1), or a **resolvable, durable handle**
  a later reader can open unaided: a document URL + version, a message permalink, a stable message
  identifier. The evidence, or a live route to it, is in the hub's hands.
- **Second-order**, the hub holds only an **attestation** of the source: a note, a digest, or an
  agent's package saying *"the email said X"*, where the link back is descriptive prose (sender +
  subject + date), not a handle. The attestation proves the source was seen; it is **not** the
  source, and the prose descriptor rots, mailboxes clear, files move and are renamed, people leave.

Both are valid provenance. What is **not** optional is recording **which order** a fact rests on: a
second-order fact carries a visible marker (and a capped confidence), so the hub always knows which
facts it can re-open and which rest on trust. This is the entity layer's rule, *"an identifier only
the original author can resolve is not provenance"*, generalised from relationship evidence to every
fact. Two mechanisms move a fact up the order:

1. **Prefer a resolvable locator over a prose descriptor.** When a source is captured through an
   intermediary, an agent, a note-taker, a summary, require the most durable handle the source
   system offers (a URL, a permalink, a stable id), not just a human description. A descriptor is the
   fallback, recorded as second-order; it is never the default.
2. **Promote load-bearing facts to first-order.** When a second-order fact carries real weight, pull
   the artifact itself into `sources/` so the hub holds it. Do not hoard everything, hold the
   evidence for the facts that matter, and leave the rest as honestly-marked second-order.

---

## File Templates

Reference implementations of every file described below are provided in [`template/`](template/),
copy that directory verbatim to stand up a new hub, and fill in the placeholders.

### Agent Instruction Files

Hubs may include one or both agent instruction files, depending on the tools used by the team:

- `CLAUDE.md` for Claude Code
- `AGENTS.md` for Codex and other AGENTS.md-compatible agents

Both files carry the same governance contract. Keep their substantive instructions aligned whenever
both are present in a hub. See [`template/CLAUDE.md`](template/CLAUDE.md) and
[`template/AGENTS.md`](template/AGENTS.md) for the full reference text.

### `_inbox/README.md`: Inbox Governance Notice

```markdown
# Inbox — Drop Files Here

**All** incoming files land here first — no exceptions.

- Partner decks, external PDFs, vendor docs, transcripts → agent creates digest here, proposes hub updates
- Team output files (memos, briefings) → agent proposes move to `working-docs/`
- Architecture images → agent proposes move to `assets/architecture/`

Nothing is filed directly to its destination. Everything goes through `_inbox/` first.

Ask the agent to process files here. It will follow the proposal/approval workflow before making
any changes to hub documents.
```

### `changes/PROPOSAL_TEMPLATE.md`

```markdown
# Change Proposal — <Slug>

**Date:** YYYY-MM-DD
**Author:** <Name> (<initials>)
**Slug:** <kebab-case-slug>
**Scope:** <which files are affected>

---

## Summary

<One paragraph: what is being changed and why.>

---

## Changes

### 1 · `<filename>` — <type of change>

<Exact content to add, replace, or remove. Be precise — the agent applies this verbatim.>

---

## Post-apply steps (agent)

1. Move `_inbox/<file>` to `sources/<subfolder>/` (if applicable)
2. Log in `sources/transcript-index.md`
3. Delete this proposal and its approval file
4. Commit the change, staging each touched path by name
   (`git add <path> ... && git commit -m "apply: <slug>"`)
5. Run `hub-scan.sh` to confirm clean state
```

### `changes/APPROVAL_TEMPLATE.md`

```markdown
# Change Approval — <Slug>

**Date:** YYYY-MM-DD
**Reviewer:** <Name>
**Proposal:** `<YYYY-MM-DD>_<initials>_<slug>_proposal.md`
**Decision:** APPROVED / APPROVED WITH CONDITIONS / REJECTED

---

## Remarks

<If APPROVED WITH CONDITIONS: list excluded items or modifications.>

## Reason — REQUIRED if REJECTED or APPROVED WITH CONDITIONS

<Why. Specific. One reason per excluded item.>

## Rule this produces — REQUIRED if REJECTED or APPROVED WITH CONDITIONS

<The standing instruction that stops this recurring, written as an instruction to a future
contributor or agent. Correct the behaviour, not the answer. "no rule — one-off" is a valid answer.>
```

The agent captures **Reason** and **Rule** as a `corrections/` note and commits it *before* deleting
this file. See §"Never delete the reason" and §"The correction loop".

### Query surface (MCP): optional, agent-only

The Ontology Layer promises that *someone else's agent can query the hub for a precise fact*. Until
now that promise was unbuilt: "query" meant "read the markdown." `template/mcp/server.py` is a
reference implementation that makes it real.

**This is the one agent-only component in the standard, and it is opt-in.** The hub works fully
without it. Delete the folder and nothing else changes. It exists because handing an external agent a
directory and hoping is not an interface.

#### Four tools, not forty

| Tool | Purpose |
|---|---|
| `hub_scope()` | Competency questions + **what the hub does not cover**. Call it first. |
| `list_entities(type, status, owner)` | Active entity notes, filtered |
| `get_entity(id)` | One note |
| `query_facts(question)` | Keyword search across hub content, returning **locations to cite** |

Metadata (`00_about.md`, the glossary, folder indexes) is exposed as **resources**, not tools.

**Resist growing this surface.** One tool per entity type, `list_decisions`, `list_risks`,
`list_stakeholders`, is the obvious next step and the wrong one: tool-selection accuracy degrades as
the count rises, and the surface becomes unusable long before it becomes complete. Four intent tools
that compose beat forty that enumerate.

`query_facts` deliberately **does not synthesise**. It returns where the facts are so the caller can
read and cite them. An answer engine that hides its sources is the opposite of what a governed hub is
for.

#### The publish boundary is the whole design

The server reads **only the last git commit** (`git show HEAD:<path>`), never the working tree. An
uncommitted edit, an open proposal, an inbox draft, an unresolved dispute: all invisible.

This is not a nicety. Without it, the MCP surface would quietly become the hole in Rule 2: work that
never passed review would leak to external consumers, and the governance everything else enforces
would be decorative. It also excludes `archive/`, retired and superseded notes, and the hub's own
machinery (`.claude/`, skills, templates), a query surface that answers questions about its own
tooling is noise burying the fact someone asked for.

**Committed = safe to expose.** The server must never be the thing that weakens that.

### Progressive disclosure: the folder index

One-instance-one-file is right for the graph and wrong for reading. A mature hub is fifty decision
notes, and an agent asked "which decisions are open, and who owns them?" would have to open all
fifty, paying the full cost of the entity layer while getting none of its efficiency.

Each entity folder therefore carries a generated `index.md`: title, status, owner, link. One small
file to answer the common question; open individual notes only for what the answer actually needs.

**Indexes are generated, never hand-written.** `build-indexes.sh` rewrites them; the apply step runs
it whenever an entity note changes. A hand-edited index drifts from the notes it claims to
summarise, and **an index nobody trusts is worse than no index**, it gets read as truth long after
it stops being true.

Indexes list **active** notes only. Retired and superseded facts stay on disk and in git, and stay
out of the reader's way.

**A generated index carries `lifecycle: active`, emitted by the generator (added in v1.15).** The
index is a hub-produced document, so the currency rule (§"Currency of generated documents") applies
to it like any other, but its lifecycle can never be a hand-authored claim: the file is overwritten
on every regeneration and its own header forbids hand edits. `build-indexes.sh` therefore emits the
field itself, and `active` is true by construction, because the index lists active notes only and
is regenerated in place rather than superseded. Before this, `[ CURRENCY ]` flagged every generated
index and no permitted act could clear the flag: the only correct fix to a generated file is to
regenerate it, and regeneration reproduced the gap. A check that flags output the machinery cannot
satisfy becomes a permanent explained remainder, and a permanently flagged file teaches every
reader to skip the flag.

### Superseding: an accepted record is replaced, never rewritten

`lifecycle: superseded` records *that* a record was replaced. `supersedes:` records **by what**,
and that link is the whole value. Without it the chain breaks at the cheapest possible link, and the
question a decision record exists to answer, *"why did we change our mind?"*, becomes
unanswerable.

The rule, borrowed from the ADR and unchanged for a decade because it works:

> **An accepted decision is superseded, not edited.** Write a new note, point it at the old one, mark
> the old one `superseded`. Both stay.

Editing an accepted decision destroys the only record that the earlier reasoning ever existed, and
that reasoning is precisely what stops it being re-litigated next year.

`supersedes` is an optional field on `Decision`, `Risk` and `Milestone` (`Correction` already had
it). `[ LINKS ]` validates the pointer automatically, it scans every frontmatter wiki-link, so a
typo in the chain is caught, not silently dropped.

**Deliberately not enforced by `hub-scan.sh`.** Git already holds the archaeology, and a check that
tried to detect "this accepted decision was edited rather than superseded" would cost more than it
returns. Document the rule; do not build the police.

### Lifecycle: retiring what no longer earns its place

Hubs only ever grow. Nothing in a governance model creates pressure to remove anything, so a hub
accumulates until the signal is buried in facts that were true once. **A hub that has never retired
anything is not well-maintained, it is unexamined.**

Every hub doc and entity note carries `lifecycle`:

| Value | Meaning | Appears in generated artifacts? |
|---|---|---|
| `active` | Current. The default. | Yes |
| `superseded` | Replaced by a newer fact, which should link back via `supersedes` | No |
| `retired` | No longer applies. The conditions that made it true changed. | No |

**Retired notes are kept, never deleted.** They stay on disk and in git, the audit trail is the
point, and "why did we believe that in March?" is a question worth being able to answer. They are
excluded from `km-brief` output and from index generation, so they stop competing for attention
without being erased. Narrative docs that retire wholesale move to `archive/`.

**Retirement is a normal act, not an admission of failure.** A fact whose conditions expired was not
wrong; it aged. Treating retirement as an error is exactly what produces hubs nobody prunes.

**This applies with particular force to `corrections/`.** Agents treat every `active` rule as
binding, so a stale rule is **worse than no rule**: it silently constrains work for reasons that no
longer hold, and it is invisible *because* it is obeyed. Review rules at the hub's cadence.

### Currency of generated documents (added in v1.6, scope corrected in v1.12)

The lifecycle machinery above governs hub docs and entity notes. `working-docs/` was exempt, and
that exemption is where currency fails in practice: generated documents (drafts, briefs, response
sections, rendered artifacts) accumulate in **generations**, nothing marks the old generation dead,
and a reader, or a query agent, cannot tell current from stale. The failure mode that motivates
this section: an agent confidently answering from a superseded draft, because every file looked
equally alive.

**Scope: this section governs documents the hub *generates*, never its sources.** An ingested
source file (a partner deck, a contract PDF, a transcript) is **evidence**: kept unmodified as
permanent reference, indexed in the provenance registers, and never marked superseded by newer
information, when a newer source contradicts it, reconciliation adjudicates the *fact* and both
sources remain. If a literal replacement of the same artifact arrives, it is filed as a new source
with its lineage recorded in the digest; the original is never touched. The test: did the file
arrive from outside to inform the hub (evidence, immutable), or did the hub produce it (current
until superseded)?

**Apply that test, and not a folder name (corrected in v1.12).** This section was first written
about `working-docs/`, and both its title and its backfill instruction said so. That is a different
question, "where do drafts live", and it answers the currency question wrongly: a hub can have an
empty `working-docs/` and dozens of unmarked generated documents in its entity folders, its
reconciliation ledger and its numbered hub docs, and a scope keyed to the folder reports it clean.
**Every document the hub produced is in scope wherever it sits**, which is the numbered hub docs,
entity notes, reconciliation topic files, the provenance registers, and `working-docs/` walked
recursively. Out of scope, each for a reason rather than by omission: ingested sources (evidence),
`_inbox/` (arriving, not yet asserted), `changes/` (governance transients carrying their own
proposal lifecycle), `archive/` (already withdrawn from the live set), and published copies in
`shareable/` (currency carried by the publication log).

**Scaffold is not a generated document.** A folder's `README.md`, `TEMPLATE.md` or
`hub-manifest.md` describes the folder rather than asserting anything about the initiative, and has
exactly one generation by construction, so "is this the current one" does not apply to it. A folder
index is also where rule 1 below records the status of the non-markdown artifacts beside it, which
makes it the carrier of other files' currency rather than a bearer of its own. This is the same
definition of "a document" that every other check in `hub-scan.sh` uses, and it is stated here so
the two cannot drift apart: two rules disagreeing about what counts as a document is how the same
backlog gets counted twice and marked never.

**Nor is the machinery the hub runs on.** `CLAUDE.md`, `AGENTS.md`, `HANDOVER.md` and
`sources.config.md` are configuration and agent instructions, not knowledge the hub produced. They
have exactly one generation by construction, git is their history, and they are replaced rather
than superseded, so the currency question has no answer to give about them. This is the
content-versus-infrastructure line drawn in v1.7, applied to currency. It is an exemption from this
section only: those files remain fully subject to frontmatter, freshness, link and shape checking.
A hub scaffolded from `template/` must scan clean against this section on its first run, and a
standard whose own template violates its own rule teaches every reader to ignore the rule.

Five rules close the gap:

1. **Every generated document carries `lifecycle:` and `timestamp:`.** A working document without
   `lifecycle:` is **draft-grade by definition**, and any agent serving it must say so. Non-markdown
   artifacts (docx, pptx, pdf) cannot carry frontmatter: their status is a one-line entry in their
   folder's index or README. No entry = draft-grade.

2. **Supersession is explicit, bidirectional, and immediate.** The moment a document replaces
   another, the new one carries `supersedes: <path>` and the old one is changed to
   `lifecycle: superseded` plus `superseded-by: <path>`, in the same act as creating the
   replacement, never later. A replacement without the back-marker is the exact defect this section
   exists to prevent.

3. **Marking beats moving.** The lifecycle marker is the authoritative act; **file location is
   not**, agents and checks decide currency from frontmatter, never from which folder a file sits
   in or its modification date. Physically relocating a superseded file to `archive/` is optional
   housekeeping, permitted only when the owner confirms the file has **not** been shared through
   cloud-storage sharing links (OneDrive/SharePoint, Google Drive, Dropbox and similar). Sharing
   links are item-bound and usually survive same-library moves, but sync tooling can replay a local
   move as delete-and-recreate, which silently breaks every link. Treat any shared or
   possibly-shared file as immovable: a marked file in place harms nothing; a broken link to an
   external recipient does.

4. **Naming.** Point-in-time documents (briefs, memos, proposals, run records) are named
   `YYYY-MM-DD_<initials>_<slug>.md`; living documents (content masters, trackers) keep stable,
   undated names, history is version control's job, currency is frontmatter's job. **Status never
   goes in a filename**: no `_final`, `_v2`, `_latest`, that is how two "finals" happen, and a
   rename is also a move (rule 3 applies).

5. **One current document per purpose.** For any given purpose, exactly one document is
   `lifecycle: active` at a time. Two actives claiming the same purpose is a defect: an agent that
   finds one **reports the collision instead of picking a winner**, and the owner resolves it via
   supersession markers. Serving agents present `active` documents only; superseded and archived
   content is history, offered only when history is explicitly asked for.

Enforcement is advisory-first: `hub-scan.sh` `[ CURRENCY ]` names every generated document lacking
`lifecycle:` (added in v1.12), and a `superseded` document with no `superseded-by:` pointer is an
error. Backfill of an existing hub is a one-time sweep, marking only, no file moves, with each
supersession evidenced, not guessed.

**The currency check is an advisory and stays one**, even in a hub whose backlog runs to dozens of
files. An error nobody can clear today is a permanently failing gate, a permanently failing gate
gets switched off, and it takes the structural checks with it when it goes. It raises one advisory
for the whole check rather than one per file, because a backlog is a single prompt with many
instances and one-per-file would drown every other count in the scan, but it names every file:
a count with no paths cannot be acted on, and this rule went five weeks unenforced precisely
because nothing named anything.

### Trust signals: freshness and confidence

A hub answers *what* a fact is. A **trustworthy** hub also answers **whether you can rely on it**.
Those are different questions, and the second one has to live **in the data**, not in a skill, a
heuristic, or an agent's judgement. A third party's agent reading an entity note gets no benefit from
a check that only runs when someone invokes a particular skill.

Three fields, three distinct claims. Conflating them is the common failure:

| Field | The claim | **Not** |
|---|---|---|
| `timestamp` | This file was last **edited** on this date | That anyone still vouches for it |
| `last-reviewed` | Someone **confirmed the content is still true** on this date | The last edit, a file can be edited without being re-verified, and re-verified without being edited |
| `confidence` | `high`/`medium`/`low`, **quality of the evidence** behind the claim | Importance, priority, urgency, or how strongly anyone feels about it |

**`confidence` is epistemic, never evaluative.** A `low`-confidence fact is thinly evidenced, not
unimportant. The moment `confidence` starts meaning "how much this matters", the field is dead, it
becomes a mood ring and no one can use it to reason.

**A fact adjudicated through reconciliation is settled, not estimated**, it carries no `confidence`.
Confidence describes claims nobody has ruled on yet. A settled fact that still advertises a
confidence level is telling the reader the adjudication did not happen.

Set the staleness threshold in `07_glossary.md` (default **90 days**) and in `hub-scan.sh`
(`STALE_DAYS`). **They must agree**, a documented rule that differs from the enforced rule is worse
than having neither, because readers trust the document and the machine trusts the script.

### Validating the graph: links and shape

> An ontology is knowledge, not enforcement. A rule only binds when something deterministic checks
> it, respects the answer, and can show the check happened.

Governance (Rules 1–4) was enforced by `hub-scan.sh` from the start. The **entity layer was not**:
`context.jsonld` declared a vocabulary and nothing verified anything conformed to it. Two checks
close that, and both are deliberately dumb, no LLM, no network, no dependencies:

**Wiki-links resolve by NOTE NAME, not display name.** `[[jordan-avery]]`, not
`[[Jordan Avery]]`, the target is the file stem. One form only: allowing both would mean two ways
to write the same edge, which is how a graph quietly forks. Entity templates state the note-name form
explicitly.

**`[ LINKS ]`**, wiki-links in frontmatter (`owner`, `decidedBy`, `subject`, `correctedBy`) are
**load-bearing graph edges**, not decoration. A typo produces a dangling edge that fails *silently*:
the note still renders, the scan still passes, and the fact is simply unreachable. The check parses
every frontmatter `[[link]]`, resolves it against an index of note names, and names the file and the
target when it fails. Unfilled template placeholders (`[[<name>]]`) are skipped.

**`[ SHAPE ]`**, per-type required fields, driven by the entity templates. A `Decision` without
`decidedBy` is not a decision; it is a sentence. The check is a flat table of type → required fields
and must be kept in sync with the `TEMPLATE.md` files.

**`[ RESTRICTED ]`**, the sensitivity boundary, mechanically checked (added in v1.16; narrowed in
v1.21). A note, or a section inside one, is marked restricted by a line beginning
`sensitivity: restricted`, in frontmatter or in the body. The marker states a boundary rule:
restricted content is never surfaced outside its bound, and until v1.16 nothing enforced that rule
anywhere. The check scans the hub's outbound surfaces: `shareable/` (leaves the team by
definition), the free text of `changes/` proposals and approvals excluding the two templates
(notices travel to reviewers and other tiers), and the generated entity indexes (the hub's summary
surface). **Where the marker sits decides what is restricted** (narrowed in v1.21): a marker in
*frontmatter* restricts the whole note, its name included; a marker in the *body* restricts the
section it opens, that section's verbatim text, not the note's name. Three findings, all errors:
the marker itself on a surface means restricted content was copied there wholesale; the name of a
frontmatter-restricted note on a surface, as a wiki-link or a bare word, discloses the existence
and identity of a record that is restricted in its entirety; and a verbatim line of a
body-restricted section on a surface means the bounded text itself travelled. Before the
narrowing, one restricted section anywhere in a file made the file's name an error on every
outbound surface, which made such files structurally un-nameable as proposal targets: the governed
route to changing the file was blocked by the check that was meant to protect it. The narrowing is
a stated trade, and the limits are the check's own: a body-marked note's existence and name become
disclosable, and verbatim-line matching does not catch paraphrase or very short lines, so **a note
whose name or existence is itself sensitive must carry the marker in frontmatter**, where the name
block still covers it. `build-indexes.sh` excludes restricted-marked notes, either form, from the
indexes it writes, so an index hit is cleared by regenerating, never by hand-editing. A surface
file the check could not read is reported and never counted as clean, and an unreadable note is
reported as an identifier-coverage gap: the check does not pass by failing to read its evidence.
This is an error, not an advisory, deliberately: unlike git history, an outbound file can be fixed
before it ships, so the gate is clearable and stays on. Expect occasional false positives from a
restricted note whose name is a common word; that is the fail-closed trade, and the remedy is
renaming the note or adjudicating the hit, never weakening the check.

**Deliberately not SHACL.** Full shape-constraint machinery is rung-3 formalism, and the standard's
rule is: don't climb higher than you need. A required-field check catches the defects that actually
occur, missing owner, dangling link, at a fraction of the cost, and it stays readable by anyone who
can read bash. Adopt SHACL only when multi-hop constraint reasoning becomes a **funded** requirement.

### Exit status: errors gate, advisories do not

`hub-scan.sh` **exits 1 when the hub is broken and 0 when it merely needs attention.** A check that
cannot fail is not a check: nothing can gate on it, no pre-commit hook can use it, and a scheduled
scan looks identical whether the hub is clean or structurally broken.

| Class | Exit | What it means |
|---|---|---|
| **Error** | **1** | Structurally broken: dangling wiki-link, missing required field, missing frontmatter, uncommitted monitored file, unparseable date, restricted content on an outbound surface, not a git repo. **Defects.** |
| **Advisory** | **0** | Intact, needs a human: pending inbox, open proposal, active dispute, stale note. **Prompts.** |

The split is the whole point. **A gate that fires on prompts gets switched off, and takes the real
checks with it.** A stale note means someone should look; it does not mean the hub is wrong. An
inbox with files in it is the system working as designed.

The scan always prints the **full** report before exiting. It does not fail fast: the picture is the
product, the exit code is just how a machine reads it.

### `hub-scan.sh`: Integrity & Governance Scan

The full, copy-ready script is at [`template/hub-scan.sh`](template/hub-scan.sh). It checks, in one
pass: pending inbox files, pending proposals/approvals, git-backed integrity (uncommitted/untracked
monitored files), OKF frontmatter on every monitored file, the restricted-content boundary on
outbound surfaces, and (if configured) open reconciliation disputes. There is no separate baseline file to maintain, the hub's own git history is the baseline.

---

## Standing Up a New Hub: Checklist

Complete these steps in order. Estimated time: 90 minutes for a new hub with no pre-existing content.

### Step 1: Name the questions the hub must answer

**Before any directory exists.** Write down 3–5 questions this hub must answer that cannot be
answered today, each tied to **a decision it serves or a cost it avoids**.

> Good: *"Which commitments are at risk this quarter, and who owns each?"* — drives the steering call.
> Not a question: *"Have everything about the project in one place."* That is a wish, not a question.

**If you cannot produce them, stop. Do not build the hub.** The problem is not missing structure,
it is undefined value, and no amount of governance fixes that. A hub with no competency questions
will pass every integrity check in this standard and answer nothing anyone needed.

This is deliberately the first step. **Every other control here measures correctness; this is the
only one that measures worth**, and it only bites before the directory exists. Once a hub is built
and populated, sunk cost argues for keeping it whatever it does.

The questions go in `01_project-brief.md` → **Competency questions**, and are re-checked at every
`/km-start`.

**Topic coverage is not an answer (added in v1.10).** A document existing on a topic does not mean
the question about that topic is answered. Before marking a question answerable, confirm that **the
specific fact or decision the question asks for is recorded**, in a place a reader can be pointed to,
not that the subject is covered somewhere in the hub. *"We hold three notes on that supplier"* does
not answer *"which supplier commitments are at risk this quarter, and who owns each?"* Mark the row
answerable only with the location of the answer, and re-check it at every session start: an answer
can be overtaken by events while the documents that once carried it stay in place. A hub with broad
coverage and no recorded answers passes every integrity check in this standard and still fails the
only test that measures worth.

*Exception: an archive-of-record hub, where the owner explicitly accepts it answers no live
question. Record that decision in `00_about.md`. Never invent questions to clear the gate, a
fabricated competency question is worse than none, because it makes a useless hub look justified.*

### Step 2: Create the directory structure and initialize git

```bash
HUB="/path/to/<initiative-name>"
mkdir -p "$HUB"/{_inbox,changes,sources/{decks,docs},working-docs,shareable,"assets/architecture"}
cd "$HUB" && git init
```

Or simply copy [`template/`](template/) to `$HUB` (it includes a `.gitignore`) and rename/fill in
placeholders. Git is a hard requirement of this standard's integrity model, every hub is a repo.

### Step 3: Create stub hub docs (`01`–`07` minimum)

For each doc:
1. Create the file with a title (`# 01 — Project Brief`)
2. Add OKF frontmatter (copy from the taxonomy above, adapt `type`, `title`, `description`, `tags`)
3. Add a one-line placeholder body: `Content to be populated.`

### Step 4: Create governance files

Copy verbatim from [`template/`](template/):
- `CLAUDE.md` and/or `AGENTS.md`, adapt: initiative name, scope guard, out-of-scope threads, hub owner name
- `README.md`, adapt: initiative name, contents table (list your actual hub docs)
- `_inbox/README.md`, copy verbatim, no changes
- `changes/PROPOSAL_TEMPLATE.md`, copy verbatim
- `changes/APPROVAL_TEMPLATE.md`, copy verbatim
- `hub-scan.sh`, copy verbatim, no changes needed (self-locating)
- `sources/transcript-index.md`, create with OKF frontmatter and a blank provenance table

### Step 5: Initial commit

```bash
cd "$HUB" && git add -A && git commit -m "init: hub scaffold"
```

This is the baseline every future `hub-scan.sh` integrity check diffs against, there is no separate
manifest file to compute.

The scaffold commit is the **one** place a blanket add is safe (nothing has been deleted yet, and the
tree holds only template files). Every commit after it stages paths explicitly: see Rule 3, *Stage
explicitly*.

### Step 6: Run the first scan

```bash
bash "$HUB/hub-scan.sh"
```

Expected clean output:
```
[ INBOX ]       OK — empty
[ PROPOSALS ]   OK — no pending proposals
[ INTEGRITY ]   OK — all monitored files committed, no drift
[ FRONTMATTER ] OK — all monitored files have valid OKF frontmatter
```

Resolve any issues before proceeding.

### Step 7: Schedule a periodic scan (optional but recommended)

Set up a scheduled task (cron, a CI job, or your agent tool's own scheduler) to run `hub-scan.sh`
daily and deliver output as a notification. This catches drift before the day's work begins.

### Step 8: Connect any external source systems (if applicable)

If the initiative draws on an external knowledge system (a meeting-transcription tool, a CRM, a ticket
tracker), record the connection details and any relevant record IDs in `sources.config.md` and
`sources/transcript-index.md`.

---

## Operating the Hub

### Session-start routine (every session)

```
1. bash hub-scan.sh
2. Inbox files?  → report to hub owner; wait for instruction
3. Proposals with approvals?  → apply, delete, log, commit
4. Uncommitted/untracked change flagged?  → surface to hub owner; do not proceed until resolved
5. Frontmatter missing?  → flag; do not apply changes until resolved
6. All clear?  → proceed with main task
```

### Processing an incoming file

```
1. File appears in _inbox/
2. Agent classifies: source | team output | visual asset
3. Agent creates digest (for source files): <name>_digest.md in _inbox/
4. Agent creates proposal in changes/ covering:
   - Hub doc updates (which sections, what new content)
   - File moves (where the original and digest go after approval)
   - Transcript-index entry
5. Hub owner reviews proposal; creates approval file
6. Agent applies: edits hub docs, moves files, deletes proposal+approval, logs, commits
```

### Applying a change proposal

```
1. Confirm matching approval file exists in changes/
2. Read proposal — understand every change before applying
3. Apply each change exactly as specified
4. Verify OKF frontmatter on any modified hub doc; update timestamp
5. Move any inbox files to their destinations
6. Delete proposal file and approval file
7. Log in sources/transcript-index.md change log
8. Commit the change, staging each touched path by name
   (git add <path> ... && git commit -m "apply: <slug>")
9. Run hub-scan.sh — confirm clean state before closing session
```

---

## Artifact Generation (Push)

Push, generating an artifact and sending it to someone, is already controlled by the proposal/
approval/commit workflow above. This section defines the generation mechanism that sits on top of it,
using the entity notes from the Ontology & Entity Layer.

### Generating a draft

A hub's `km-brief` skill (see [`template/.claude/skills/km-brief/SKILL.md`](template/.claude/skills/km-brief/SKILL.md))
queries entity notes, filtered and ranked by the stated audience, and drafts a memo, briefing, or
status report into `working-docs/<topic>/`. Every fact stated in the draft carries a wiki-link back to
its source entity note: never restate a fact without a traceable link. Drafting requires no proposal or
approval, `working-docs/` is already free-form team output.

Because entity notes and hub docs are only ever read as of the last git commit (the design principle
from the Ontology & Entity Layer above), a draft is always reproducible: the same commit will always
regenerate the same facts.

### Sending externally

Promoting a draft to `shareable/`, or otherwise sending it outside the team, is a normal proposal/
approval/commit cycle, no new mechanism. The one addition: once applied and committed, add a row to
`sources/publication-log.md` (date sent, artifact, audience, the commit it was generated from, sent by).
git's commit log proves *what* changed; the publication log proves *who received what*. This is the
outbound mirror of `sources/transcript-index.md`, which already tracks inbound provenance.

The log records **every outward handoff, internal recipients included** (marked as internal), not
only external or client issues, an internal share can travel onward, and "who received what" has to
answer for that path too.

### Rendering an issuable artifact (publish): added in v1.3

Some outputs leave the hub as *rendered documents* (typically PDF). The principle: **the hub that
holds the record produces the artifact that carries it outward**, a hub that knows the canonical
facts but cannot issue the document is one handoff away from the record and the artifact
disagreeing. Three consequences:

1. **The editable source is the master; the rendered file is an output.** Per-document layout,
   by convention:

   ```
   working-docs/…/<slug>/
     <NAME>.html      ← source of truth (self-contained: content + CSS)
     <NAME>.guards    ← build assertions (required where a correction motivated the source)
     build.sh         ← thin wrapper calling the shared renderer
     README.md        ← what this document is, what the guards protect, who issues it
     <NAME>.pdf       ← build output, regenerated — never hand-edited
   ```

2. **Corrections are encoded as build guards.** The `.guards` sidecar holds one rule per line,
   applied to the rendered PDF's extracted text, `FORBID <regex>` (fail if present),
   `REQUIRE <regex>` (fail if absent), `PAGES <n>` (warn on drift), `#` comments. A rebuild that
   would reintroduce a corrected defect fails instead of shipping. Weakening or deleting a guard is
   a hub change requiring the owner, each guard traces to a correction.

3. **Content and rendering are separate layers.** Drafting and content changes follow the
   proposal/approval workflow above; this mechanism only turns committed content into an issuable
   artifact, and external issue is logged in `sources/publication-log.md` as described. Where a
   rendered document duplicates facts held in a numbered hub doc, the hub doc is the record and the
   source must not drift from it.

**Owner-edited artifacts invert mastership** (added in v1.4). "Source is master" holds only while
the source is the sole writer. The moment the hub owner hand-edits a rendered artifact, that edited
file becomes the baseline: never regenerate over it; make further changes surgically inside it,
matching the owner's formatting; retain the generator/source for provenance only, and record the
inversion in the document's `README.md`. A rebuild that overwrites an owner edit silently discards
human judgment.

**Artifacts stay in the hub** (added in v1.4). Hub artifacts are created and kept only under the hub
tree (`working-docs/` for team outputs, `shareable/` for sanitised external copies). A copy outside
the hub is outside governance, not in git, not integrity-scanned, editable and sendable without the
hub knowing. When a tool or skill's default output path points elsewhere, the hub's location rules
override the default; copies outside the hub only on explicit owner request.

**One renderer, shared.** A single script (`tools/km-publish.sh`, HTML → PDF via WeasyPrint,
self-bootstrapping into a local venv, guard-aware) serves every hub: in a multi-hub workspace it
lives once at the Supervisor tier; a standalone hub keeps it in its own `tools/`. Office-suite
"export to PDF" is a preview path, never an issue path, it drops page breaks and background fills.
The **`/km-publish` skill** (see
[`template/.claude/skills/km-publish/SKILL.md`](template/.claude/skills/km-publish/SKILL.md))
operates this layer: build, scaffold (`new <slug>`), list.

---

## Roles

| Role | Responsibilities |
|---|---|
| **Hub Owner** (typically initiative lead) | **Owns the hub as a product, not just an approval queue.** Holds the competency questions and the coverage boundary; names the users; sets and keeps the review cadence; decides what gets **retired**; reconciles against systems of record; holds decision rights over contested terms. Also: approves or rejects proposals, resolves integrity alerts, confirms scope, sets policy. |
| **Contributor** (any team member) | Creates proposals for their changes; reviews and comments but does not apply directly; follows inbox-first rule |
| **Agent** (any AI assistant, or none) | Runs session-start checklist; reads binding rules in `corrections/`; processes inbox; drafts proposals; applies approved changes; commits. Captures a `corrections/` note whenever it is corrected. This row describes the abstract role, the responsibilities hold whether or not any agent is involved at all. Where the optional **Agent Tier** (below) is in use, a session fulfilling this role runs *as* a named agent instance (`km-<slug>`) with a declared scope; the "or none" property is unaffected, a hub with no named agent, or no agent at all, still works. |

**Critical constraint:** the agent never applies changes to hub docs without either an approved
proposal file or explicit real-time confirmation from the hub owner in chat. This is not a suggestion,
it is the control that makes the system auditable. This constraint holds equally if the hub is
maintained by hand, with no AI agent involved at all.

### Standard Maintainer: changing the standard is a separate role

| Role | Responsibilities |
|---|---|
| **Standard Maintainer** | Evolves the standard itself, this document, the templates, the skills, and any organisation-specific overlay. Versions it, runs the promotion and leakage checks, and **hands the change over for adoption**. Does *not* apply the change to hubs. |

**Authority is separate from evidence.** A correction, near miss, or successful workaround can show
that the standard should improve, but it does not authorize the change. The Standard Maintainer acts
only on a direct instruction from the deployment owner, an approved Supervisor promotion handover,
or an owner-requested repair of a demonstrated defect in the standard or its inherited tooling.

Before editing, classify the lesson:

| Class | Destination |
|---|---|
| **Canonical** | A reusable mechanism for organizations generally; change and version this standard. |
| **Overlay-only** | Policy, vocabulary, structure, people, or systems specific to one organization; change only that organization's overlay. |
| **Hub-local** | Project knowledge or a local operating choice; return it to the hub and do not edit it. |
| **Enterprise knowledge** | Shared facts, ontology, provenance decisions, or enterprise meaning; return it to the deployment's enterprise knowledge steward. |
| **Mixed** | Split the reusable mechanism from the deployment-specific policy or knowledge and place each in its proper scope. |

The optional reference implementation in [`agents/km-hub-builder/`](agents/km-hub-builder/SKILL.md)
ships this role as one governed contract with thin Claude and Codex adapters. Installed runtime files
are deployments of the repository sources, not independent agent definitions. Runtime tool formats
may differ, but authority, classification, write boundaries, verification, attribution, and the
Supervisor stopping point remain the same. The package includes a non-writing drift check and must
refuse to replace an unmanaged agent definition without explicit authorization.

**The separation is the point.** Whoever changes the standard must not also be the one who edits every
hub to match it. When those collapse into one actor, the estate silently reshapes itself around the
new text and stops being independent evidence that the standard works, the standard is then
confirmed by a copy of itself, which is the same defect as a document that agrees with itself N times
counting as N sources. Keeping the roles apart means adoption is a decision each hub owner makes,
recorded in that hub's own history, and a standard that is hard to adopt shows up as friction instead
of disappearing into a mass edit.

**Adoption flow.** A standard change propagates in three hops, each writing only in its own scope:

1. **Standard Maintainer** changes the standard, versions it, and writes a **handover note** into the
   Supervisor's inbox: what changed, which hubs are affected, and what each must do. Then stops.
2. **Supervisor** processes the note inbox-first, decides scope with the estate owner, and dispatches
   proposals into each affected hub's `changes/`.
3. **Each hub** applies under its own governance, approval, commit, audit trail in the hub's history.

In a single-hub deployment the flow collapses to steps 1 and 3, with the hub owner in the middle. The
handover note is the only artifact the Standard Maintainer writes outside the standard itself.

---

## Customisation Guide

### Fixed (do not change per initiative)

| Element | Why fixed |
|---|---|
| `hub-scan.sh` script | Shared standard; updates propagate to all hubs |
| Proposal/approval filename conventions | `hub-scan.sh` slug-matching depends on these |
| OKF frontmatter field names (`type`, `title`, etc.) | Interoperability depends on consistency |
| Standard type taxonomy | Cross-hub consistency; enables multi-hub agent queries |
| Governance rules (five rules) | The control model; partial compliance breaks auditability |
| `Stakeholder`/`Partner`/`Milestone` grounding in schema.org | Interoperability and avoiding vendor lock-in, don't invent proprietary replacements for solved, open-standard concepts |
| One-instance-one-file convention for entity notes | Vault-LD's triples-live-in-frontmatter-only constraint; a table row is invisible to any query surface |

### Adapt per initiative

| Element | What to change |
|---|---|
| `00_about.md` sections | Fill in goals, role context, and agent working notes for this hub |
| `CLAUDE.md` / `AGENTS.md` scope guard | List the initiative's specific in-scope and out-of-scope threads |
| Hub doc numbers and names | Add `08`–`10` for initiative-specific themes; rename `02` as needed |
| OKF `tags` vocabulary | Define 5–10 canonical tags relevant to the initiative |
| `README.md` contents table | List actual hub docs; add initiative-specific rows |
| `working-docs/` subfolders | Match to the initiative's output types (e.g. `memos/`, `partner-briefs/`) |
| `sources/` subfolders | Match to source material types |
| `context.jsonld` `@base`/`@vocab` and proprietary terms | Adapt the base IRI per hub; extend with new proprietary properties as the initiative needs them, this extension is the ontology's actual IP (see "Ontology & Entity Layer") |

### What not to add

Do not add:
- Proprietary tooling dependencies (the hub must run on any filesystem)
- Cloud sync that bypasses the integrity layer (regular file-sync services are fine; direct API writes
  that skip the local files are not)
- Agent auto-apply without approval (the proposal/approval workflow is non-negotiable)
- Hub docs that skip OKF frontmatter (hub-scan.sh will flag them immediately)

---

## Reconciliation Layer

### Why this exists

As a hub accumulates sources, transcripts, partner decks, implementation plans, meeting notes, facts
begin to contradict each other. A timeline shifts. A partner's role description changes. A technical
decision is reversed and then partially reversed again. Without a mechanism to adjudicate these
contradictions, the hub becomes unreliable: agents and humans alike read conflicting information and
cannot determine which version is current.

The reconciliation layer solves this without modifying source documents. It maintains a separate,
human-adjudicated ledger of **settled facts**, the ground truth that supersedes any contradicting
source. When new ingestion contradicts a settled fact, the conflict is surfaced immediately for the
hub owner to resolve.

### Directory structure

```
reconciliation/
├── README.md                   ← How to use this folder; dispute resolution process
├── _disputes/                  ← Active contradictions awaiting resolution (NOT integrity-monitored)
│   └── YYYY-MM-DD_<topic>_dispute.md
├── timeline.md                 ← Settled facts: dates, milestones, deadlines
├── architecture.md             ← Settled facts: stack, components, decisions
├── partnerships.md             ← Settled facts: partner roles, commitments, status
└── [other topics as needed]    ← One file per topic domain
```

**Topic files** (e.g. `timeline.md`, `architecture.md`) are **integrity-monitored**, they're added to
the `monitored_files` glob in `hub-scan.sh` and subject to the same git-backed checking as hub docs.
They represent adjudicated ground truth and must not change outside the proposal/approval workflow.

**Dispute files** (`_disputes/`) are **not monitored**, they are transient records of active
conflicts, created by the agent and deleted once the hub owner resolves the dispute.

### Topic file format

Every topic file carries OKF frontmatter (`type: reconciliation`) and contains a settled-facts table:

```markdown
---
type: reconciliation
title: Settled Facts — <Topic>
topic: <topic-slug>
lifecycle: active
last-reviewed: YYYY-MM-DD
---

# Settled Facts — <Topic>

These values supersede any contradicting source document. When a new source contradicts a SETTLED
fact below, a dispute file is created in `_disputes/` and flagged in the ingestion proposal.

| ID | Claim | Settled Value | Status | Sources (agree) | Sources (contradict) | Date settled |
|---|---|---|---|---|---|---|
| <T>-001 | <what fact> | <the truth> | SETTLED | <source A, B> | <source C> | YYYY-MM-DD |
```

**Status values:**

| Status | Meaning |
|---|---|
| `SETTLED` | Adjudicated. This value is ground truth until explicitly superseded. |
| `DISPUTED` | Contradiction detected; awaiting resolution. A matching dispute file exists in `_disputes/` and names who it is blocked on, which is not always the hub owner. |
| `SUPERSEDED` | Previously settled value, explicitly replaced by a later decision. Kept for audit trail. |
| `CONDITIONAL` | Fact is context-dependent (e.g. true for one region/team, not another). |

### Dispute file format

The agent creates a dispute file whenever a new source digest contradicts a `SETTLED` fact:

```markdown
# Dispute — <Topic> Contradiction

**ID:** <TOPIC>-D<n>
**Detected:** YYYY-MM-DD
**Incoming source:** <digest filename in _inbox/>
**Fact in dispute:** <one-line description>

## Conflict

| | Value | Source |
|---|---|---|
| **Reconciliation says** | <settled value> | <source(s) that established it> |
| **Incoming source says** | <contradicting value> | <new digest filename> |

## Resolution options

- **A — Accept incoming:** update `reconciliation/<topic>.md` fact to new value (requires proposal/approval)
- **B — Reject incoming:** note in the digest that this claim is OVERRIDDEN by reconciliation
- **C — Conditional:** both are true in different contexts — add conditional note to topic file

## Status

**UNRESOLVED**
**Blocked on:** Hub Owner | <the counterpart the hub is waiting on>
**Created by:** Agent (ingestion of <source filename>)
```

**An open dispute is not automatically an owner action item (added in v1.12).** `Blocked on:`
replaces the old `Assigned to: Hub Owner`, which was hardcoded and therefore said nothing. Some
disputes cannot be adjudicated by the owner at all: the hub is waiting on a counterpart to reply,
and the owner chasing them is not the next step. `hub-scan.sh` reads this field rather than
inferring an owner action from the filename, and reports a dispute with no `Blocked on:` line as
unstated rather than assuming the owner. Reporting work as someone's to do when it is not is not a
harmless over-report: a list that is wrong every day stops being read, and the genuine owner
decisions in it go with it.

### Agent behaviour during ingestion

When processing a new file (step 3 of the intake workflow), after creating the digest:

1. **Scan reconciliation topic files**, identify all `SETTLED` facts relevant to the source material
2. **Extract key claims** from the digest, dates, roles, technical decisions, commitments
3. **Compare** extracted claims against settled facts
4. **If no contradiction:** proceed with normal proposal; note "Reconciliation check: no conflicts"
5. **If contradiction found:**
   - Create `reconciliation/_disputes/YYYY-MM-DD_<topic>_dispute.md`
   - Add `⚠ RECONCILIATION REQUIRED` section to the ingestion proposal listing all disputes
   - Do not propose updating reconciliation topic files automatically, that requires explicit hub owner decision

### Resolving a dispute

**Every option below ends by deleting the dispute file. Before it is deleted, capture the
adjudication as a `corrections/` note (`trigger: dispute`).** The topic file records *which fact
won*; the correction records *why*, and the rule that stops the contradiction recurring. Without
this, reconciliation keeps the verdict and discards the reasoning, which is the same defect as
deleting a reviewer's rejection reason. See §"Never delete the reason".

**Option A, Accept the incoming source (settled value is wrong/outdated):**
1. Hub owner creates a proposal updating `reconciliation/<topic>.md`: change status to `SUPERSEDED`, add new `SETTLED` row
2. Normal approval → apply → commit
3. **Capture the adjudication as a `corrections/` note (`trigger: dispute`) and commit it**
4. Delete the dispute file
5. Update the digest in `sources/` if it has already been moved there

**Option B, Reject the incoming source (settled value holds):**
1. Hub owner or agent annotates the digest: mark the contradicting claim as `OVERRIDDEN BY RECONCILIATION: <ID>`
2. **Capture the adjudication as a `corrections/` note (`trigger: dispute`) and commit it**
3. Delete the dispute file
4. No change to reconciliation topic file needed

> Option B is where the loss is worst: nothing changes in the topic file, so **the only durable
> record that the question was ever asked and answered is the correction note.** Delete the dispute
> without it and the same source will be re-ingested, re-flagged, and re-adjudicated from scratch.

**Option C, Context-dependent:**
1. Hub owner creates a proposal updating the topic file: change status to `CONDITIONAL`, add context note
2. Normal approval → apply → commit
3. **Capture the adjudication as a `corrections/` note (`trigger: dispute`) and commit it**, a
   context-dependent verdict is the most valuable kind: the rule is *when* each value applies
4. Delete the dispute file

### `hub-scan.sh`: Reconciliation check

Add this section to `hub-scan.sh` (after `[ FRONTMATTER ]`):

```bash
echo "[ RECONCILIATION ]"
if [ -d "$HUB/reconciliation/_disputes" ]; then
  disputes=$(find "$HUB/reconciliation/_disputes" -maxdepth 1 -name "*_dispute.md" | sort)
  if [ -z "$disputes" ]; then
    echo "  OK — no active disputes"
  else
    echo "  ! Active disputes:"
    while IFS= read -r f; do
      # Read who the dispute is blocked on. Never infer an owner action from the filename.
      blocked=$(sed -n 's/^\*\*Blocked on:\*\*[[:space:]]*//p' "$f" 2>/dev/null | head -1)
      case "$blocked" in
        "")          echo "    - $(basename "$f") (blocked-on not stated or file unreadable)" ;;
        "Hub Owner") echo "    - $(basename "$f") (blocked on: Hub Owner, decision required)" ;;
        *)           echo "    - $(basename "$f") (blocked on: $blocked, no hub-owner action)" ;;
      esac
    done <<< "$disputes"
  fi
else
  echo "  OK — reconciliation not configured"
fi
echo ""
```

### Initialising reconciliation for an existing hub

When adding reconciliation to a hub that already has content:

1. Create the `reconciliation/` directory structure
2. Identify the 3–5 fact domains most likely to have contradictions (typically: timeline, architecture, partnerships/roles)
3. For each domain, create a topic file, start it empty (no settled facts yet)
4. As you process disputes from existing or new ingestion, populate the settled-facts tables
5. Add topic files to the `monitored_files` glob in `hub-scan.sh` once they contain at least one settled fact
6. Update `hub-scan.sh` with the reconciliation check

Do not pre-populate reconciliation with facts that have not yet been contested, the ledger should
reflect adjudicated disputes, not a parallel copy of hub doc content.

### What reconciliation does not replace

- **Hub docs** remain the narrative source of truth (what is known and why it matters)
- **Source documents** remain unchanged (audit trail of what was originally said)
- **Reconciliation** is a narrow ledger of specific facts that have been in dispute and adjudicated

The three layers are complementary: sources → hub docs (narrative) → reconciliation (adjudicated facts).
A contradiction in a source does not automatically change a hub doc, it goes through reconciliation
first, and only hub doc updates that survive that process are proposed.

---

## Supervisor Tier: Cross-Hub Orchestration

### Why this exists

The hub model is **closed-world**: each hub is a self-contained source of truth, and any per-hub
"gather" process runs *inside* one hub, it loads that hub's docs and proposes updates to that hub.
This is correct when a source clearly belongs to one initiative.

It breaks down for **cross-cutting sources**. A single week of meetings can emit facts about three
different initiatives and an internal platform decision, all at once. Run a per-hub gather from inside
one hub and it has no map of the *other* hubs: it will pull foreign facts into the wrong hub, miss
facts that belong elsewhere, and silently duplicate a fact that legitimately touches several hubs.
Duplication is the worst outcome, it is precisely what the reconciliation layer then has to clean up.

The Supervisor solves three problems that only exist *between* hubs:

1. **Routing**, which hub is the **home** (single owner of record) for each fact
2. **Referencing**, when a fact matters to several hubs, how the others point to it **without copying**
3. **The no-home case**, facts about real initiatives that are not yet initiated as hubs

### Core principle: single home of record

**Every fact has exactly one home hub.** That hub owns the fact as a first-class entry. Any other hub
that cares about the fact carries a **typed reference** to it, a short pointer, never a copy. This is
the rule that prevents cross-hub drift: there is only ever one place to update a fact, and everyone
else points at it.

A *surfacing* hub (e.g. an executive-summary hub that exists to raise leadership-relevant items from
across initiatives) is the canonical example: a leadership-relevant fact from one initiative is
**owned** by that initiative's hub and **referenced** (`informs`) by the surfacing hub, not re-stated
in both.

### Directory structure

The Supervisor is a single meta-hub at the **root of the multi-hub workspace**, a sibling to the hubs:

```
_KM_Supervisor/
├── _inbox/               ← Drop zone — ALL inbound supervisor-tier files land here first (v1.4)
├── hub-registry.md       ← Map of every initiative folder: hub|repo status, owner, routing keywords
├── relationships.md      ← Canonical typed graph of edges between hubs (and docs/facts across hubs)
├── routing-log.md        ← Append-only log of every routing pass
└── _unrouted/            ← Backlog: facts with no home hub yet (transient, owner-reviewed)
```

These files carry OKF frontmatter (`type: index`). The Supervisor is operated by the **workspace
owner** (the person who owns the hub-of-hubs). The Supervisor never edits hub docs directly, it only
writes proposals into each target hub's `changes/`, where that hub's Layer-2 governance takes over.

**Inbox-first applies to the Supervisor too** (added in v1.4). The Supervisor routes rather than
ingests, but it still *receives* files, cross-hub source packages, import packages from
unconnected systems, bundles feeding a shared layer, and material misdelivered to the wrong tier.
All of it lands in `_inbox/` first, and a supervisor session classifies: an import package goes to
the import validator, a cross-hub source enters a routing pass, a misdelivered single-hub file is
forwarded to that hub's own `_inbox/`. Nothing lands loose in the Supervisor root, and the
Supervisor's scan flags a pending inbox at session start, a file in the inbox is unprocessed
material, not yet evidence of anything.

### `hub-registry.md`: the routing map

One row per initiative folder. Routing keywords are harvested from each hub's `CLAUDE.md` scope guard
and `07_glossary.md` tag vocabulary. Two status values:

| Status | Meaning | Can receive dispatched proposals? |
|---|---|---|
| `hub` | An initiated hub with full governance (`changes/`, manifest, scan) | Yes |
| `repo` | A plain folder for a real initiative, not yet a hub | No, facts park in `_unrouted/` |

### `relationships.md`: the edge graph

The single place to see how hubs relate. Each edge is **proposed by the Supervisor and confirmed by
the owner**. Referencing hubs also carry a short inline pointer stub next to the relevant doc; this
file is the authoritative index of those stubs.

Edge vocabulary (keep it small):

| Type | Meaning |
|---|---|
| `depends-on` | A cannot proceed or be correct without B |
| `informs` | A surfaces or contextualises B without owning it (surfacing hubs use this) |
| `supersedes` | A replaces a decision previously owned by B |
| `shared-stakeholder` | A and B share a person whose actions affect both |
| `shared-partner` | A and B share an external partner or client |
| `parent-of` | A is the umbrella initiative; B is a sub-initiative |

### The four routing outcomes

Every fact that survives extraction lands in exactly one of these:

| Outcome | Condition | Action |
|---|---|---|
| **Home** | Exactly one hub matches | Dispatch a gather-style proposal into that hub's `changes/` |
| **Reference** | A second/third hub also cares, but does not own | Dispatch a lightweight reference-stub proposal + record the edge |
| **Backlog** | Matches a `repo` (real initiative, no hub) | Park in `_unrouted/`; offer to stand up a hub if the theme recurs |
| **Out of scope** | Matches no initiative, or is not workspace business | Drop; note in the run log |

### The supervise workflow

A cross-hub routing pass runs as a **stepped, owner-in-the-loop process**: the Supervisor proposes the
routing for every fact, but the owner confirms or overrides home/reference/backlog assignments and
every relationship edge before anything is dispatched.

```
1. Load registry + relationships (offer to refresh the registry)
2. Pick the cross-cutting source(s) and scope (e.g. meetings, date range)
3. Extract facts as (claim, source, locator, evidence) tuples — same discipline as a per-hub gather
4. Classify each fact against registry keywords → candidate home(s) + confidence
5. Build the routing table (home / reference / backlog / out-of-scope)
6. STEPPED Q&A — confirm with the owner:
     • clean single-home facts → bulk-confirm
     • multi-home facts → owner picks the home; others become references
     • new recurring themes with no hub → initiate / backlog / ignore
     • each candidate edge → confirm / reject / change type
7. Per target hub: run the reconciliation pre-check against that hub's settled facts
8. Dispatch — write proposals into each home hub's changes/, reference stubs into referencing
   hubs, confirmed edges into relationships.md, backlog items into _unrouted/
9. Log the run in routing-log.md and report a summary
```

A dry-run mode should perform steps 1–6 and show the routing table **without writing any
proposals**, used to validate routing accuracy before wiring dispatch.

### How the Supervisor respects per-hub governance

The Supervisor has **no authority to change a hub doc**. Everything it produces for a hub is a
proposal in that hub's `changes/`, subject to the hub owner's approval, the reconciliation check, and
the resulting commit, exactly as if a human had written the proposal. Routing is a *pre-filter* that
decides which hub a proposal is written into; it does not weaken any Layer-2 control.

### Standing up the Supervisor: checklist

Only needed once a workspace runs two or more hubs that share a source.

1. Create `_KM_Supervisor/` at the workspace root with `_unrouted/`.
2. Build `hub-registry.md`: scan sibling folders, classify each as `hub` or `repo`, capture owner and
   routing keywords from each hub's `CLAUDE.md` scope guard + `07_glossary.md` tags.
3. Create `relationships.md` (empty edge table) and `routing-log.md` (empty run list), both with OKF
   frontmatter.
4. Run a dry-run routing pass on a recent batch of the cross-cutting source and review the routing
   table before any live dispatch.

### What the Supervisor does not do

- It does not hold copies of facts that have been routed home (single home of record).
- It does not run a second governance system, dispatched proposals use each hub's existing Layer-2 flow.
- It does not auto-create hubs or auto-confirm edges, both require an explicit owner decision.
- It does not replace the per-hub gather process; it *invokes the same extraction discipline* across
  hubs and routes the results. Inside a single hub, the ordinary gather process remains the right tool.

---

### Estate extensions: shared entities, escalation, evidence (v1.1)

Routing sources is the Supervisor's first job. Three more emerge as soon as hubs start referring to
the same real-world entities. All three follow from one observation: **truth in a multi-hub estate is
federated by fact class**, each class of fact has exactly one home of record, and the homes differ.

| Fact class | Home of record |
|---|---|
| Identity of shared entities, people, external counterparts, client organizations, products/services, organizational units | **Supervisor** (`semantic-layer/`) |
| Ontology, classes, predicates, qualifiers; the evidence standard | **Supervisor** |
| Which hub owns which scope | **Supervisor** (`hub-registry.md`) |
| Engagement facts, who is doing what in an initiative; milestones, decisions, risks | **the owning hub** |
| Hub-local process corrections | **the owning hub** (`corrections/`) |

The Supervisor is therefore the **master index, never a master copy**. It does not hold a duplicate of
hub knowledge; a duplicate that agrees on day one is the worst kind, because nothing flags it until
the copies have drifted. Hubs hold typed references to Supervisor entities; the Supervisor holds no
copy of hub engagement facts.

#### The semantic layer: shared entity registry

`_KM_Supervisor/semantic-layer/` holds one file per shared entity, in namespaces (`people/`,
`external/`, `clients/`, `products/`, plus `units.md` as a registry), a relationship assertion ledger
with per-assertion provenance and confidence, and the ontology. Rules that keep it sound:

- **Hubs never mint identity.** A hub that encounters a new person/org/product escalates; the entity
  is created (or matched to an existing one) at Supervisor level, and the hub references it.
- **Department/domain packages never ship their own copies of shared entities.** A domain contributes
  classes and scoped role bindings against existing entities, never person or product cards of its
  own. (Every department-shaped source will try; it is the natural way to write a self-contained
  package.)
- **Aliases resolve inward.** Transcription variants and informal names are recorded as aliases so
  references resolve; canonical forms are used in all output.
- **Assertions carry qualifiers.** An unqualified edge overstates: it reads as sole, final, and total.
  Provide `exclusive`, `terminal`, `enforced`, `provisional`, `disputed`, absent means unknown, not
  false. When an assertion is falsified, mark it `disputed` or retract in place; never delete. A
  retained dispute is what makes the eventual answer findable; a clean absence reads as completeness.

#### Escalation protocol

Local hub work escalates to the Supervisor when, and only when, it touches an estate-wide fact
class:

1. creating, changing, or merging the identity of any shared entity;
2. any ontology change (new class, predicate, or qualifier);
3. a contradiction between hubs, or between a hub source and a Supervisor-held fact;
4. a deviation from the evidence standard;
5. a source spanning multiple hubs (the routing case above);
6. anything the estate marks sensitive/restricted.

The mechanism is **files, not calls**: the hub agent writes an escalation note into
`_KM_Supervisor/escalations/` (the inbox pattern, pointed upward). The Supervisor processes it, the
owner decides, the decision is logged, and, where a Supervisor-level fact changed, **sync notices**
are dispatched as proposals into each affected hub's own `changes/`, applied under that hub's own
governance. The Supervisor never edits a hub directly (the no-bypass rule, unchanged).

**The Supervisor decides nothing on its own authority.** It is a protocol plus a registry: it enforces
*which* decisions escalate and records what the owner decided. All decision authority remains with the
estate owner.

#### Evidence standard

Multi-hub estates accumulate conflicting sources, and resolving conflicts by source *type* fails
predictably. The Supervisor holds a ranked trust order, binding on every hub:

| Rank | Source class | Note |
|---|---|---|
| 1 | Subject-confirmed, the person a claim is about, asked directly | required for claims about someone's authority |
| 2 | Owner-statement, from direct knowledge | not the owner recalling what a system says, that is rank 4 in disguise |
| 3 | Two genuinely independent sources | a person plus the system that person reads is one source counted twice |
| 4 | A system of record (directory, catalogue, register) | records what was entered, not what is true, expect wrong, stale, inconsistently scoped, and legacy values |
| 5 | Documents whose evidence references do not resolve | structure may land as hypothesis; authority claims may not |

Application rules that repay their cost: never construct identifiers (e-mail addresses) from names; a
person's own record outranks their manager's list of reports; never turn a hedged phrase into a hard
edge; a document agreeing with itself N times is one source, not N.

#### The correction loop runs at the estate tier too

Hubs capture binding rules in `corrections/` when the record is corrected. The same loop runs one
tier up: when the owner corrects the *agent*, or an agent error or near-miss is diagnosed whose
lesson crosses hub boundaries, a testing habit, a checker blind spot, a trusted-but-stale artifact,
the rule is captured in the Supervisor's own `corrections/` registry **before work continues**, and
binds every session at every tier through the same pointer chain that binds the evidence standard.
The scope test: a rule meaningful only inside one hub stays in that hub; a rule about any hub, or
about the agent's own working method, goes to the estate registry; fact-trust rules go to the
evidence standard. The capture test: *can you state a rule?* If not, it was a one-off, log it where
it happened. A lesson that exists only in a conversation transcript is a defect of the session that
produced it: the scan validates note shape, and silent learning fails review. An estate that corrects
its records but not its operator repeats the operator's errors with well-governed data.

#### Supervisor governance: proportional, not ceremonial

The Supervisor tier is itself **git-backed** (rule 3 applies to it as to any hub). But it does not use
the proposal/approval ceremony: it is the estate's working memory and changes far too often. Its
change rule is *owner authorization in session + a git commit stating the reason*. Hubs get ceremony
because they are shared, curated artifacts; the Supervisor gets **auditability without bureaucracy**.
A Supervisor that cannot show the history of its own registry is the least governed part of the estate
at exactly the point of highest trust.

#### The owner queue: one decision surface, tiered defaults, back-pressure, batched clearing (added in v1.20)

> **DRAFT — awaiting owner push.** Drafted 2026-08-14; not yet part of any published version.

Everything above governs what the estate **captures**: routing, identity, evidence, escalation.
None of it governs what the owner can **consume**. An estate that runs unattended routines,
sweeps, evaluation passes, hygiene runs, produces decisions faster than one human absorbs them,
and each producer surfaces its asks on its own surface: a daily brief here, a state file there,
ask files, escalation notes, pending proposals in every hub, live chat. This section was adopted
after an estate reached roughly forty open items spread across eight such surfaces, nothing
ranked, capped, or expiring, with a material evidence gap presenting identically to a routine
watch-list verdict, and the owner reporting they could no longer tell what was pending or what
needed them. The layers above design for capture and integrity; this one designs for **owner
throughput**. No decision authority moves anywhere: the queue changes where decisions surface and
how they age, never who makes them.

**One surface.** `QUEUE.md`, at the Supervisor tier, is the owner's **only** decision surface.
Every proposal batch, escalation, ask, and owner action registers there as one self-explanatory
row, what it is, where it came from, why it is being asked, in a one-word-answerable form, and
**nothing counts as "surfaced to the owner" without a queue row**. The rows live in a
machine-parseable block (explicit begin/end markers; one delimited row per item: id, tier, date
raised, default date, the ask) so the session-start scan can render and count them. The scan
prints the queue **first**, and a session opens with at most five ranked rows; everything else
waits below the fold.

**Three tiers.**

| Tier | Holds | Default behaviour |
|---|---|---|
| **A** | Money, identity, strategy, client- or external-facing artifacts, deletions, actions only the owner can take | Never defaults. Waits for the owner's word; surfaced live |
| **B** | Recoverable and in scope: routine content proposals, pilot verdicts from evaluation routines | **Auto-applies its recommendation after a veto window (default: 7 days) unless the owner vetoes.** An external deadline may shorten the window, never lengthen it |
| **C** | FYI | Never asks anything; folded into the queue's FYI section |

Tier B flips the middle band from approve-to-act to **veto-to-stop**. A row past its default date
is applied through the normal proposal/approval mechanics, with the approval file citing the
elapsed veto window as its authority, so the audit trail records that the default ran, not that a
review happened. A vetoed row is withdrawn in place, never deleted. **Anything touching identity,
money, restricted content, deletions, or client-facing surfaces is never tier B**, whatever its
origin: the time default exists for recoverable calls, and none of those are recoverable.

**Back-pressure.** When open A + B rows exceed a cap (default: 10), every routine enters
**decision-halt**: it keeps running and logging findings, but mints no new decision items, no
adoption nominations, and no owner-facing asks, verdicts default to the watch list and findings
queue in the routine's own logs, until the count drops below the cap. Decision production is
throttled by decision consumption; the queue can shrink, never spiral. **The check runs at the
start of a routine, not at publication.** A constraint that can invalidate a run's output must be
evaluated before the run does the work: checked only at the moment of publication it turns a
cheap no-op into an expensive retraction, and one estate's routine demonstrated exactly that by
drafting, committing, and then reverting a proposal in a hub's history because it read the queue
last. **Escalation classes are exempt.** Identity, restricted content, and cross-hub
contradictions are the classes the estate exists to catch; suppressing them under back-pressure
would trade the owner's attention for the estate's integrity. They always register, as tier A,
where the queue ranks them first.

**Batched clearing.** A clearing skill (reference name `/km-clear`) sweeps the queue in an owner
Q&A: small batches of three or four questions per round, tier A first ranked by age and impact,
each question zero-context self-explanatory with the recommended option marked and first, one
decision per question, and a free-text answer always outranking the offered options, because an
answer that corrects the question or says "already decided" is the real decision. Two rules carry
the mechanism's value:

- **Reconcile before asking.** Before any row older than the current session is surfaced, check
  the decision log, the estate's derived registers, and the row's home hub for a ruling that
  already answers or supersedes it. A row the record answers is closed with its source cited;
  **the owner is never re-asked a decided thing.** Re-asking is the precise failure the queue
  exists to end: spending the owner's attention on something the estate already knew.
- **Answers execute in the same session.** Every answer becomes a committed artifact, a proposal,
  a directive, an identity record, an archived escalation, before the run reports done; the queue
  is then reranked and the sitting agenda refreshed. A cleared decision that produces no artifact
  is not cleared, it is deferred with extra steps.

Sessions offer a clearing run **in one line** whenever the scan shows the queue warrants it
(several tier-A rows open, a tier-B default imminent, or decision-halt), instead of surfacing
items one by one.

**The weekly sitting.** Decisions batch into one short weekly owner sitting (on the order of
thirty minutes), agenda kept at the bottom of the queue file, top of queue first. Drip is
reserved for tier-A items that genuinely cannot wait, an external deadline inside the week.
Standing review items get a **protected agenda slot**, so recurring walkthroughs stop losing to
the urgent drip.

**Routine output is machine-facing.** Briefs, state files, and logs are demoted to the
machine/agent record: their ask sections point at the queue rows registered that run, never at a
parallel ask list, and **the owner is never expected to read a routine's output to find a
decision**. Each brief carries a read flag; a session triages every unread brief, verifying that
each owner-facing item in it has a queue row, registering any that lack one, then marking it
read. The brief remains the backstop for days no session runs, never a second surface.

**Hub inboxes are queue inventory.** A file pending in any hub's `_inbox/` is decision work the
owner cannot see from the estate tier. The Supervisor scan counts every hub's pending inbox
entries, and each affected hub registers as a queue row, tier B, cleared by directing that hub's
own intake under a committed directive, unless a pending file is itself decision-shaped, in which
case it surfaces as tier A.

**The owner's desk.** The owner's personal follow-ups, reports owed, calls promised, chases, are
not estate decisions and never occupy decision rows. They live in the queue's own "owner's desk"
section as dated nudges, and nowhere else.

A single-hub deployment does not need this section, but the mechanism is not inherently
estate-sized: the moment any deployment's routine output can out-produce its one human decider,
the queue file, the tiers, and the back-pressure rule adopt without the rest of the Supervisor
tier.

#### Import package contract: packages from unconnected systems

Sources sometimes arrive as packages an external agent generated against a system the estate has no
direct connection to (a directory, an org chart, a ticketing system) rather than as documents dropped
in `_inbox/`. Left uncontracted, these packages routinely underdetermine their own evidence: no
retrieval date, no record of the literal query run, external people flattened into internal-looking
records, one confidence label per record instead of per fact, opinions mixed with facts, evidence
references that resolve to nothing outside the generating session. A **generic import package
contract** makes these defects mechanically detectable at intake:

- **One canonical machine file.** Exactly one machine-readable file is authoritative per package
  (JSON, so validation needs no external parser dependency). Additional formats (TTL/JSON-LD/CSV) may
  accompany it but are non-authoritative, parallel formats have been known to disagree with each
  other.
- **A self-describing manifest.** Declares the source system, the extraction method (from a fixed
  enum mapped to the evidence hierarchy's ranks above), the retrieval date, the literal queries run,
  whether evidence references are durable or session-local, what was and was not covered, and
  who/what generated the package.
- **Per-field, not per-record, provenance.** Every fact field is either a value with its own method
  and optional reference, or an explicit "not found", never a bare scalar and never silent absence.
- **Organization affiliation is mandatory on every person claim.** A person not employed by the
  estate owner's own organization is typed distinctly and never folded into an internal listing.
- **Reporting evidence declares its direction.** A subject's own stated chain is distinct from names
  harvested off someone else's reports listing; the second is weaker evidence and is flagged as such,
  not presented as the first.
- **Opinions are quarantined.** Routing or role recommendations live in a separate, clearly-labelled
  section of the package, never inside a fact claim.
- **Known entities are referenced, not restated.** A claim about an entity the estate's registry
  plausibly already holds carries a match hint instead of a full duplicate record.
- **A mechanical validator gates intake, not truth.** Passing validation means the package is honest
  about what it claims and on what basis; it is still adjudicated against the evidence hierarchy
  above, and an owner decision is still required before anything is written to the registry.
  Compliance is never ingestion.

The concrete schema, enum values, validator script, and requester-facing prompt that instantiate this
contract are organization-specific and live at the estate tier, alongside the evidence hierarchy's own
named failure catalog.

---

## Agent Tier: Named Agents, Declared Scope (v1.7)

### Why this exists

The other layers govern content (Layer 2), format (OKF), and, where a workspace runs several hubs,
routing and shared identity (Supervisor Tier, above). None of them names *who is acting*. The Roles
table treats "Agent" as an abstract role: "any AI assistant, or none." That is correct as far as it
goes, but it leaves nothing for an application to query if it needs to know what agents exist, what
each may touch, or which one made a given change.

This layer adds that addressability without adding a second governance system. An agent definition is
a thin identity card, a name, a scope, a capability list, that **points at** the hub's own
`CLAUDE.md` / `AGENTS.md` for behaviour. It does not carry rules of its own.

### Two classes

| Class | Definition lives at | Scope |
|---|---|---|
| **Hub agent** | `.claude/agents/km-<slug>.md`, inside the hub | That hub only |
| **Supervisor agent** | `.claude/agents/km-supervisor.md`, at the Supervisor tier | The estate tier, ontology, shared identity, routing, escalations |

Every hub carries exactly one agent definition. A workspace's Supervisor tier, if it has one, carries
exactly one (name fixed: `km-supervisor`). A single-hub deployment still mints a hub agent, its scope
is simply the hub itself; this layer does not require a Supervisor tier to exist.

### Naming convention

`km-<slug>`, where `slug` is the hub's directory name: lowercased, every run of non-alphanumeric
characters collapsed to a single hyphen, leading/trailing hyphens stripped. Example: a directory named
`Q3 Product_Launch` yields `km-q3-product-launch`.

Names are stable identifiers, they appear in the generated registry (below), in commit attribution,
and in whatever an application builds on top of the estate. Renaming a hub directory does not silently
rename its agent; carrying that renaming through is a deliberate decision, not a side effect of `mv`.

### Thin definitions: the layer's central discipline

An agent definition contains **only**: `name`, `description`, `km_tier` (`hub` | `supervisor`),
`km_scope` (path), `scope_enforcement`, `skills`, plus a short body whose one job is to point at the
hub's `CLAUDE.md` for everything else. It restates no governance rule, no evidence rule, no scope
guard, no ontology. Target length: on the order of 15 lines.

This is the rule the framework already applies to shared entities in a multi-hub estate, "department
packages never ship their own copies of shared entities" (Supervisor Tier, above), applied to agent
configuration itself. Two copies of a rule agree on day one and drift silently afterward; a single
home of record does not. If a definition needs to say what "in scope" means for its hub, that sentence
belongs in `CLAUDE.md`; the definition links to it rather than repeating it. A definition that grows
past roughly 25 lines has almost certainly copied something that belongs elsewhere.

### Scope is a declared convention, not an enforced control

Every agent definition carries `scope_enforcement: convention`, and states this plainly: the scope
path is a norm the agent is instructed to respect, not a boundary that prevents, blocks, or restricts
it from acting outside that path. Nothing at the filesystem or permission layer stops a session opened
in one hub's scope from writing into another hub's files. Documentation describing this layer must
not claim otherwise, an unenforced boundary described as enforced is a false assurance, and a false
assurance is worse than an acknowledged gap, because it is trusted.

### Attribution: the compensating control

Because the boundary cannot be prevented, it is instead made **observable**. Every commit an agent
makes carries a trailer:

```
KM-Agent: <agent-name>
```

`hub-scan.sh` reports an advisory, never an error, since a foreign-agent commit may be a legitimate,
owner-directed override, for any commit whose `KM-Agent` trailer names an agent other than the hub's
own, and for any commit carrying no trailer at all. One trailer line and one check turn a norm nobody
can observe being broken into one that is auditable.

#### `Dispatched-By:` may only be written by the agent that was dispatched (added in v1.12)

Where a workspace dispatches an agent to act in a hub, the resulting commit carries a second trailer,
`Dispatched-By: <dispatching-agent>`, asserting **that the named dispatch happened and that the
dispatched agent authored this commit**. Only that agent may write it. Writing it on a commit one
authored oneself, to record that the work was authorised, is not a shortcut: it is a false entry in
the record that exists to show who actually acted.

The check is mechanical and it is the point of the trailer: a commit carrying `Dispatched-By:` whose
`KM-Agent:` is **not** the hub's own agent means an author outside the hub claimed a dispatched agent
acted. `hub-scan.sh` flags it. Three properties of this check are deliberate and should survive any
reimplementation:

- **It reads a window of history, not `HEAD` alone.** A false trailer is a durable defect in the
  record rather than a transient state; check only the tip and the next commit buries it permanently.
- **Nothing is grandfathered.** Unlike the `KM-Agent` advisory, which exempts commits predating a
  hub's agent definition, this trailer did not exist before the convention did, so carrying one is
  itself proof the commit is in scope.
- **It is an advisory, not an error, and that is not a judgement about severity.** History is not
  rewritten to clear it, so an error would be a gate that can never go green again. The remedy is a
  `corrections/` note naming the commit.

Unlike a foreign `KM-Agent` trailer, a false `Dispatched-By:` has no legitimate reading. This matters
because the trailer is the compensating control for a tier with no mechanical enforcement: everything
else in this section is observable-after-the-fact by design, and a false trailer does not merely
evade the record, it corrupts it. The reasoning that produces one is always available and always
sounds fine, the change is small, the outcome was approved, the proper route is slower for a one-file
edit. **The false trailer is the tell**, and it is easier to notice than the boundary crossing it
accompanies, which is why this is checked rather than merely stated.

### The Supervisor agent never writes into a hub

Where a workspace runs a Supervisor tier, the Supervisor agent effects a hub-level change only by
writing a proposal into that hub's own `changes/`, never by editing a hub document directly, including
when acting on an owner-directed override. The change lands in the owning hub's own git history under
its own approval flow; the human-in-the-loop control is structural, not something a session has to
remember to apply.

#### What "a hub's files" means: content, not machinery

The rule governs **hub content**: the facts a hub asserts and the artifacts it produces. It does not
govern the **machinery a hub runs on**, which the Supervisor may write directly under owner
authorization.

| **Hub content**, proposals only, always | **Infrastructure**, Supervisor may write directly |
|---|---|
| Numbered docs and narrative rollups | Agent definitions |
| Entity notes, decisions, risks, stakeholders, milestones, partners | The hub scan script and other governance scripts |
| Reconciliation, corrections, glossary | Workspace-wide skills rollouts |
| Working documents, shareable artifacts, sources | Scaffolding and template files |

**The test: would a hub owner be surprised to find it changed without their approval?** A fact about
their initiative, always propose. A scan check every hub in the workspace is receiving, no; that is
a rollout, and routing it through one approval cycle per hub buys nothing but delay while the
workspace sits half-migrated.

**Why the Supervisor is entitled to this and a hub agent is not.** Infrastructure is the one thing
that must stay *uniform* across hubs to function at all, a registry is only a roster if every hub is
in it; an attribution advisory is only a control if it runs everywhere. Uniformity is exactly what a
per-hub approval flow cannot guarantee. The Supervisor tier exists to hold what no single hub owns.

**Two binding conditions.** Owner authorization for the rollout, the Supervisor never
self-authorizes an infrastructure change, and the commit lands in the hub's own history carrying the
Supervisor's agent trailer, so a reader of that hub sees who changed its machinery and when. **Direct
write is never silent write.**

**When in doubt, propose.** The cost of a needless proposal is one approval. The cost of a wrongly
direct edit is a hub owner discovering their content changed without them.

### Ontology proposals are a duty, not a permission

The Supervisor Tier already holds that hubs never mint shared identity, a hub encountering an
unrecognised person, organization, product, or unit escalates rather than minting locally. This layer
adds a duty on top of that permission: a hub agent that notices a fact class plausibly deserving
estate-wide treatment is expected to write the escalation, not merely allowed to.

### The registry is generated, never hand-maintained

Where a Supervisor tier exists, `agent-registry.md` is built from the agent definition files
themselves, one row per agent: name, tier, scope path, enforcement level, skills. It is never
hand-edited: a hand-maintained file describing system state is a memory of that state, and a memory
rots the moment the state changes underneath it. Regenerate it whenever a definition is added or
changed; the estate scan reports the registry as stale if a definition has since drifted from it.

### Minting: when a hub is created

Standing up a hub mints its agent definition as part of the same act (see Step 4, "Standing Up a New
Hub," above): derive the slug, write `.claude/agents/km-<slug>.md` from the template, and, if a
Supervisor tier exists, regenerate its agent registry. A single-hub deployment still mints an agent;
its scope is simply the hub itself.

### What this layer does not do

- It does not add a second approval mechanism, Layer 2 (`changes/` proposal/approval) is unchanged.
- It does not make scope technically exclusive, see "Scope is a declared convention," above.
- It does not require a Supervisor tier, a standalone hub mints and runs its own agent unassisted.
- It does not replace the abstract "Agent" role in the Roles table, an unnamed, ad-hoc human-or-AI
  session remains a valid way to operate a hub. This layer serves workspaces that need an addressable
  instance an application can discover; it is not a requirement that every hub have one.

## Version history (added in v1.10)

The version ledger. **A published version number is never reused.** Before publishing, read this
table *and* `git log`, take the next unused number, and add the row in the same commit that changes
the text. This is not bookkeeping: two sessions each publishing "v1.8" leaves two different standards
answering to one name, and every hub that pinned that version now points at an ambiguity. That
happened once (see the v1.9 row) and the ledger exists so it does not happen twice.

| Version | Date | What it introduced |
|---|---|---|
| v1.0 | 2026-07-02 | Base standard: OKF frontmatter, five governance rules, hub structure, `hub-scan.sh`, reconciliation layer. |
| v1.1 | 2026-07-18 | Estate extensions for the Supervisor tier: shared entities, escalation, evidence standard. |
| v1.2 | 2026-07-18 | Generic import package contract for systems the estate cannot connect to. |
| v1.3 | 2026-07-20 | Publish mechanism: issuable artifacts with correction guards. |
| v1.4 | 2026-07-21 | Rule 5 (source traceability), owner-baseline inversion, artifact containment, a document date is not an event, inbox-first at the Supervisor tier. |
| v1.5 | 2026-07-22 | Provenance has an order: first-order held versus second-order attested. |
| v1.6 | 2026-07-28 | Currency of working documents, scoped to generated documents and never to sources. |
| v1.7 | 2026-07-30 | Agent Tier: named agents, declared scope, thin definitions, attribution trailer; hub content versus infrastructure. |
| v1.8 | 2026-07-30 | Standard Maintainer role and the adoption flow. |
| v1.9 | 2026-07-31 | Correction promotion: a rule learned in one hub must be able to reach the others. **Published first as a second "v1.8" by a concurrent session and renumbered**; the ledger and the reuse rule above are the response. |
| v1.10 | 2026-07-31 | Explicit staging and verified commit claims (Rule 3); topic coverage is not an answer (competency questions). |
| v1.11 | 2026-07-31 | A read of synced storage can report absence that is only lag (Rule 3): unreadable is separated from missing, reported as an advisory with its coverage stated, and never repaired by writing. |
| v1.12 | 2026-08-01 | Three checks the standard had promised or implied and nothing performed: `[ CURRENCY ]` for generated documents lacking `lifecycle:`, with the scope corrected from a folder name to the "did the hub produce it" test and scaffold defined out of it; disputes report who they are blocked on (`Blocked on:` replaces a hardcoded `Assigned to: Hub Owner`) instead of asserting an owner action; and a `Dispatched-By:` trailer whose `KM-Agent:` is not the hub's own agent is flagged as a false dispatch claim. |
| v1.13 | 2026-08-01 | Portable Standard Maintainer: authority is separated from evidence; lessons are classified as canonical, overlay-only, hub-local, enterprise knowledge, or mixed; one governed `km-hub-builder` contract ships with thin Claude and Codex adapters, safe installation, and runtime-parity checks. |
| v1.14 | 2026-08-01 | Canonical-first hub initialization with a portable OrganizationProfile contract, pinned deployment provenance, separate Supervisor customization, fail-closed validation, and Claude/Codex semantic parity. |
| v1.15 | 2026-08-02 | Generated entity indexes carry `lifecycle: active`, emitted by `build-indexes.sh`. The currency rule already covered them as hub-produced documents, but the generator omitted the field, so `[ CURRENCY ]` flagged every index in every hub with entity notes and no permitted act could clear it, because the files are regenerated and their headers forbid hand edits. Observed identically by three hub agents in one estate on 2026-08-02. |
| v1.16 | 2026-08-03 | The sensitivity boundary becomes a checked rule: `[ RESTRICTED ]` in `hub-scan.sh` fails, as an error, when a `sensitivity: restricted` marker or the name of a restricted-marked note appears in `shareable/`, in change-notice free text, or in a generated entity index; `build-indexes.sh` excludes restricted notes so an index hit clears by regeneration; `tests/test_restricted_lint.sh` carries the negative fixture proving the check fires. Derived from a security review in one estate that found the restricted rule stated in prose and enforced at no boundary. |
| v1.17 | 2026-08-05 | Session-start handover surfacing (Rule 3): `hub-scan.sh` prints a `[ HANDOVER ]` block ahead of every other section pointing the agent at `HANDOVER.md` unconditionally and echoing its title, and reports a missing `HANDOVER.md` as an error (the same rank as missing frontmatter); the `CLAUDE.md`/`AGENTS.md` pointer is promoted from a conditional advisory to an unconditional first read-first step. Reconstructing session state from the raw git log or a diff when a curated handover exists is an evidence-hierarchy inversion, the same shape as *check the hubs and the layer before the transcripts*. Derived from a supervisor-tier incident where a resumed session rebuilt state from git history and an uncommitted diff, missing named pre-send review points and an enumerated open-decision list, because the enforced entry point surfaced nothing and the only pointer was a conditional advisory. |
| v1.18 | 2026-08-06 | Handover write side (Rule 3), the mirror of v1.17: a `Stop` gate (`handover-hooks.sh`, wired in `template/.claude/settings.json` against a `SessionStart` baseline) blocks once when a session landed commits that changed hub state but did not touch `HANDOVER.md`, instructing the model to refresh the current-state section via `/km-handover` and commit before stopping. Best-effort by construction, Stop fires per turn, not at a true session end, and `/clear` never fires it, so it guarantees one refresh per working session, not the final word; the read side and the hygiene pass remain the backstop. Substantive work is committed work (uncommitted files stay the `[INTEGRITY]` check's concern); the gate fires at most once per session and honours the runtime's already-blocking signal so it never re-enters itself. No session-end regeneration hook: a hub's only deterministic candidate, its generated entity indexes, are monitored files committed through the governed flow, so a detached rebuild would manufacture the uncommitted-monitored state Rule 3 catches. The hook path is portable through the runtime project-directory variable, so `km-init` installs it unmodified per hub. Ported from the proven supervisor-tier write-side hook. |
| v1.19 | 2026-08-06 | The estate corrections registry is surfaced and bound at hub session start (Rule 3), closing for the corrections registry the gap v1.17 closed for the handover. A hub's agent-instruction files bound the evidence standard, the identity home of record, and the escalation protocol by reference, but not the estate `corrections/` registry, so `PROTOCOL.md`'s assertion that a supervisor-tier correction binds every tier had no operational surface at the hub's session-start entry point. `hub-scan.sh` now prints a `[ CORRECTIONS ]` block immediately after `[ HANDOVER ]`, conditional on the workspace root holding `_KM_Supervisor/`, pointing the agent at `../_KM_Supervisor/corrections/` and counting the `lifecycle: active` notes in force; a standalone hub prints nothing. `CLAUDE.md` and `AGENTS.md` declare the registry binding in the estate-binding section, inherited by reference and never copied down. The same change ports the estate-binding section into `AGENTS.md`, which previously carried none, so the binding is present on the non-Claude surface too. Single-hub deployments are unaffected. |
| v1.20 | 2026-08-14 | **DRAFT — awaiting owner push.** The owner queue (Supervisor tier): one machine-parseable decision surface (`QUEUE.md`) that every proposal, escalation, and ask must register on to count as surfaced to the owner; three tiers (A never defaults; B auto-applies its recommendation after a veto window, with identity, money, restricted content, deletions, and client-facing surfaces never tier B; C never asks); routine decision-halt above a queue cap, checked at the **start** of a run and with escalation classes exempt; a batched Q&A clearing skill (`/km-clear`) bound by reconcile-before-ask; one weekly owner sitting with a protected walkthrough slot; routine briefs demoted to machine-facing with a session-triage read flag; hub inboxes counted as queue inventory. Adopted after an estate reached roughly 40 open items across 8 owner-facing surfaces, with routine decision production outrunning one owner's consumption and re-asks spending owner attention on already-decided items. |
| v1.21 | 2026-08-14 | **DRAFT — awaiting owner push.** The `[ RESTRICTED ]` name block is narrowed to what the marker actually restricts. Since v1.16, a `sensitivity: restricted` line anywhere in a note made the note's NAME an error on every outbound surface, so a file with one restricted section could never be named as a proposal target: the governed route to changing such a file was blocked by the check meant to protect it. Now a marker in frontmatter still restricts the whole note, name included; a marker in the body restricts the section it opens, whose verbatim text (lines of at least 16 characters, up to the next heading at the same or a higher level) is blocked on outbound surfaces while the note's name and path stay nameable. Stated trade-offs: a body-marked note's existence and name become disclosable, and verbatim-line matching does not catch paraphrase or very short lines, so a note whose name or existence is itself sensitive must be marked in frontmatter. `build-indexes.sh` continues to exclude both forms from generated indexes. `tests/test_restricted_lint.sh` proves both sides of the narrowing and that the frontmatter name block still fires. Derived from an estate incident (owner-adjudicated "fix", 2026-08-14) in which a hub file with one restricted section became structurally un-nameable in `changes/` proposals. |

---

## Appendix: Quick Reference Card

```
NEW FILE ARRIVES
  └─ Drop in _inbox/
       └─ Agent classifies + digests
            └─ Agent checks reconciliation/ for conflicts
                 ├─ No conflict → normal proposal
                 └─ Conflict → dispute file created + ⚠ flagged in proposal
                      └─ Hub owner resolves → delete dispute → update reconciliation if needed
            └─ Proposal created → Hub owner approves → Agent applies

HUB DOC NEEDS UPDATING
  └─ Author creates proposal in changes/
       └─ Hub owner creates approval
            └─ Agent applies → logs → commits

SESSION STARTS
  └─ bash hub-scan.sh
       ├─ [INBOX]            files? → report to owner
       ├─ [PROPOSALS]        ready? → apply
       ├─ [INTEGRITY]        uncommitted/untracked? → stop, investigate
       ├─ [READABILITY]      unreadable? → advisory, not a defect; re-run when sync settles
       ├─ [FRONTMATTER]      missing? → flag, fix before next change
       ├─ [CURRENCY]         generated doc with no lifecycle:? → mark it, advisory
       ├─ [RECONCILIATION]   disputes? → act on the one blocked on the hub owner
       └─ [AGENT]            false Dispatched-By:? → capture as a corrections/ note

DAILY / PERIODIC (automated)
  └─ hub-scan.sh → notification → owner reviews

CROSS-CUTTING SOURCE ARRIVES (touches many hubs)  [Supervisor tier]
  └─ supervise routing pass
       └─ extract facts → classify against hub-registry.md
            └─ STEPPED Q&A with owner:
                 ├─ one hub matches      → HOME    → proposal into that hub's changes/
                 ├─ several match         → REFERENCE → stub + edge in relationships.md
                 ├─ matches a repo        → BACKLOG  → _unrouted/ (offer to init a hub)
                 └─ matches nothing       → OUT OF SCOPE → drop, log
            └─ dispatch proposals → each hub's normal approval flow applies
            └─ log run in routing-log.md
```

---

*This standard is organization-agnostic and free to adopt, adapt, and redistribute for any team,
company, or individual's knowledge management needs.*
