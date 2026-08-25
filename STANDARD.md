---
type: brief
title: Knowledge Management Standard: Hub Framework (v1.58 draft)
description: Reproducible, organization-agnostic standard for standing up a governed, agent-readable knowledge hub for any initiative, project, or team, with an optional cross-hub Supervisor tier for routing cross-cutting sources, an optional Agent Tier for named, discoverable agent instances, an optional record-boundary layer for governed use of systems of record, and an editions boundary that names where consuming the standard ends and evolving it begins.
tags: [standard, knowledge-management, governance, okf, agents]
resource: template/
timestamp: 2026-08-25
---

# Knowledge Management Standard: Hub Framework (v1.58 draft)

**v1.58 is DRAFTED and UNPUBLISHED** (2026-08-25): three findings from an external reviewer's second
pass, each reproduced as a failing case on this branch, off `main` at `510cf03` (published v1.57), and
committed red before any repair was written. **The release gate could PASS over a tree that changed
while it ran.** Discovery runs first, the suites run after, and the pass takes about twenty minutes;
nothing established that the tree at the verdict was the tree that was discovered. The reviewer watched
it happen — the gate began on clean `main`, the branch changed, a discovered check was edited, and the
gate returned PASS after ~900s still reporting zero changed declarations — and **the thing editing the
tree was this maintainer's own drafting agent**, which is why the defect is that the gate cannot tell
and not that anyone misbehaved. The repair is deliberately **not** a snapshot: the gate has read the
working tree since v1.54 so that a check authored in the change being gated is visible, and
snapshotting tracked content would silently undo that. It fingerprints what it actually reads, plus
`HEAD`, before and after, and **refuses** on any difference, naming what moved. The residual is stated
and pinned as a gap rather than implied closed: a file that changes and changes back inside the window
is identical at both ends, and anything outside the discovery set is not covered. **The frontmatter
check measured the first physical line of a value that spans lines.** Every indented line was skipped
as a continuation unconditionally — no state, no record of which key it continued, no requirement that
any key precede it — and the residency budget was then measured against the first line alone: a
description whose first line is 13 words and whose folded YAML value is 97 passed at exit 0. The block
is now walked with state, **taking no YAML library as a dependency**, because a parser on the
maintainer's machine is not one in the shipped environment. **And "the limits, defined once" was
false when it was written.** The gate's limit set was maintained in three places — the data, a numbered
prose block arguing each one again, and hardcoded assertions pinning that block's wording — while a
comment beside the data claimed adding one was an edit to the data and to nothing else. It is corrected
under the v1.47 rule, not dated under v1.56's, because it was false at v1.55 and not overtaken since.
The repair reduces the count of definitions to one rather than describing the drift, **and this
version's own fifth limit is the proof**: adding it was an edit to one structure. **Both sweeps
returned instances and both are recorded**, one repaired and one registered with its reason: the
folded-value class was found again in the two shipped readers of `routing-keywords`, where the
per-token repair of v1.44 is handed a value already truncated to its first line, and the
single-definition class was found in the renderer's version pin, which claimed one place and held two.

The preceding published version is **v1.57** (2026-08-25, owner push: two defects in the session-start scan every hub
inherits, both found in operation by a deployment and both harvested rather than invented here. Each
was reproduced as a failing case on this branch, off `main` at `2005772` (published v1.56), and
committed red before either repair was written. **The restricted check blocked a numbered curated
document's own name.** A root-level `0[0-9]_*.md` carrying a frontmatter `sensitivity: restricted`
marker had its NAME blocked on every outbound surface, so a directive restricting that document's
content could not name the document it was restricting: the hub's scan failed at every session start
and buried its real integrity errors underneath. A numbered document's name is the hub's public
structure, not a disclosive record identifier, so the marker now restricts the CONTENT and leaves the
name nameable — which is the treatment `accessClass: restricted|record` has had since v1.22 under the
crossing law the comment beside it already cited, *existence crosses; contents don't*. This is v1.21's
own reasoning reaching a case it should always have covered, not a new rule, and the narrowing is
**root-scoped**: a numbered name in a subdirectory is an ordinary note and stays blocked, because
narrowing a security check is how a false positive becomes a false negative. The body-marker path was
examined and is deliberately unchanged: a body marker already emits section text and never the name.
**The corrections counter read `lifecycle:` as if it meant `binds`.** `lifecycle:` records whether a
DOCUMENT is current; `rule:` is what makes a note a binding rule, and the v1.19 section that
introduced the block already specified the count as the active notes *whose `rule:` is in force*, so
the implementation never matched its own published specification. The registry's own `README.md` — a
reference document, current, carrying no rule — was counted as a rule that binds, and every scaffold
document ever added reproduced it. Measured against a live registry of 90: the current predicate
returns **90**, the repaired predicate **89**, and `README.md` is the sole difference; three
independent instruments in that deployment already agreed on 89. The predicate now has three arms —
not scaffold, carries a `rule:`, is `lifecycle: active` — and the printed line states them, because a
check whose printed claim outruns its predicate is the class this repository has spent twelve versions
repairing. **Both sweeps returned exactly one instance each, the two repaired**, and both findings of
none are recorded rather than left silent. Nothing in this version is redeployed anywhere: the
canonical narrowing is the whole of it, and installing it into a hub is that hub's own act).

The version before that is **v1.56** (2026-08-25, owner push: claims made in prose that no instrument reads.
**The source is the same external review that produced v1.54 and v1.55**, and these are the last of
its findings. Each was reproduced here before it was repaired, and several had moved since the
reviewer measured them, which is why the measurements below are this version's own. **The licence
file is sound and the prose around it was not.** Restore the Appendix placeholder on one line and
`LICENSE` hashes to `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, the
published digest of the canonical Apache-2.0 text, so the terms carry no edit and exactly one line
differs: the Appendix boilerplate instantiated with the copyright line, which is the act the
Appendix exists to be used for. Saying the file is *unmodified* and stopping there invites a reader
to expect a byte-identical copy and to meet an unexplained difference in the one file where an
unexplained difference costs the most, so *The boundary asserts no license* now states which part is
canonical and how anyone can check it. **`README.md` stated the Section 4 duties without their
condition**, so a reader using the standard internally, or modifying it and passing it to nobody,
was told they owed notice-preservation duties they do not owe; the duties attach to
**redistribution**, the page says so, and `LICENSE` governs. **Three drifted counts, and they are
three different repairs, which is the finding rather than an accident of tidying.** A count is
corrected when it was false on the day it was written, and left standing when it was true then and
has been overtaken since, and this version had one of each and one that was neither. *Eleven entry
points:* the MCP quarantine suite reported eleven and the v1.40 row published it, while the surface
declares **seven** by decorator, four tools and three resources; eleven was the size of the driver's
own call list, `get_entity` being driven five times. False on the day, so the row is corrected under
the v1.47 rule and the suite now derives the figure from the decorators. *Two stated limits:* the
maintainer contract has told every report to read the gate's **two** limits since the version that
introduced the gate, while the gate printed **three** from that same version and **four** since
v1.54, and the v1.53 row obeyed the contract and published the wrong number. False on the day in
both places, so both are corrected and the contract now states no count at all. *147 markdown
files:* the v1.53 row's evidence for licensing the repository as one thing. Measured **158** on
`aeec51a`, the tree this version was measured against, and 162 once this change's own package
lands; that version's own publish commit shipped 150, and `main` held 147 when the design was
written, the code figure being 41 throughout. That number is a dated measurement
supporting a dated decision, so refreshing it would falsify it and only its missing date is
repaired. **The sweep the question demands.** Every count, version identifier and file reference
this repository asserts in prose was read for the same class. It found one wrong enumeration, the
`README.md` row naming six per-hub skills the template installs where it installs seven, and
`km-publish` was the one it omitted; one stale pointer inside the gate to a copy of its limits that
v1.55 had already deleted; one stale description of discovery in the CI definition, which still
called it a walk over tracked checks after v1.54 made it read the working tree; and one hardcoded
count of the design set sitting beside a badge that derives the same number. **One check is added
and it is the answer to the class, not to the instance:** `tests/test_readme_inventory.sh` derives
what the template ships, its entity-note folders from the directories carrying a `TEMPLATE.md` and
its per-hub skills from both runtime trees, and requires the landing page's two enumerations to
equal the derivation in both directions, so the inventory stops being a hand-kept memory of a
directory. It fails on the unrepaired tree naming `km-publish`. **What was deliberately not built is
recorded with the reason**, because a check that models the wrong class closes a sweep and proves
nothing: no instrument compares the version identifier across the five surfaces the publish ritual
flips, and none is added here, since those surfaces are designed to disagree while a version is
drafted and a check would have to model the ritual's two states inside a repair to prose accuracy).

**v1.23** (stations, compartments, and the resolution plane) **remains drafted
and unpublished**: its sections are marked with their version and bind nothing until its own push.
Deployment pins resolve the version they pinned until their Supervisor re-pins.

**Status:** Active standard. Framework-agnostic, works with Claude, GPT, Gemini, or any other LLM agent, and equally well with no agent at all (plain human use).

**One exception, deliberately:** the optional **MCP surface** (see *Query surface (MCP)*) is
agent-only by construction. It adds nothing for a human reader and requires none of them to exist.
The hub itself, every file, every rule, every check, remains plain markdown that works with no
agent at all. The MCP server is an **additive consumption path**, never a dependency: delete it and
the hub is unchanged. **It is quarantined at v1.40 and serves nothing** (see *Query surface (MCP)*).

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

A lightweight governance layer sits on top of the format. It states six rules that prevent the hub
from drifting into an uncontrolled, unreliable state, and it enforces four of them mechanically:

1. **Inbox-first**, all incoming files land in `_inbox/` before anything else
2. **Proposal/approval**, no hub document is edited without a traceable change record
3. **Git-backed integrity**, every hub is a git repository; uncommitted or untracked changes to a
   monitored file are flagged automatically
4. **OKF frontmatter on every doc**, enforced at scan time, not just at authoring time
5. **Source traceability**, every fact in a hub document traces to a named origin; a fact whose
   origin cannot be named is flagged at intake, never blended into settled prose
6. **The record boundary**, records stay in the systems that master them; hubs hold claims about
   records, with resolvable pointers, never shadow copies of operational data

**Which of the six an instrument establishes, and which a person does (narrowed in v1.48).** Rules 1
to 4 are checked at every session start by `hub-scan.sh`, in its `[ INBOX ]`, `[ PROPOSALS ]`,
`[ INTEGRITY ]` and
`[ FRONTMATTER ]` blocks. Rule 6's **outbound** half is checked by `[ RESTRICTED ]`, which blocks
restricted and record-class content from the surfaces a hub publishes to; the crossing laws that
govern what may come **in** from a system of record are operated by the inbox, the date gate and
reconciliation, which are procedures rather than checks. **Rule 5 has no instrument at all.** Nothing
in this standard validates that a fact in settled hub prose traces to a named origin: `[ FRONTMATTER ]`
reads `type:` and never `resource:`, and no lineage artifact is generated or compared. `[ SHAPE ]`
does require `evidencedBy` on a `Claim` note and `assertion_method` on a `RelationshipAssertion`, and
that is field presence on two optional entity types, never a verdict about whether a fact in prose
has an origin or whether the origin named is real. The repository's own component-mining rationale
records the same thing in its own words: a source-traceability rule enforced by discipline, with
nothing recording lineage as a checkable artifact.

**This narrows a claim and withdraws no obligation.** Rule 5 binds exactly as the other five do; what
is withdrawn is the statement that an instrument establishes compliance with it. The standard takes
the same posture here that it takes toward agent scope and toward a scoped reader's isolation: a
control described as mechanical when it is procedural is a false assurance, and a false assurance is
worse than an acknowledged gap, because it is trusted. A deployment that wants Rule 5 mechanised
builds the provenance artifact and the check that reads it, which is a change of a different size
from this sentence, with its own authority.

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
the escalation protocol, and the evidence standard. **The threshold is the hub count, not
overlap: the moment a workspace runs more than one hub, this standard advises creating the
Supervisor tier** (v1.26; an owner ruling replacing the earlier "share a source or an entity"
trigger) — estate-level state has nowhere correct to live inside a hub, and the tier starts as
the small **minimum tier** defined below, never the full apparatus. A single-hub deployment can
ignore it entirely.

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
├── claims/                          ← Optional: one note per promoted claim (type: Claim)
│                                      — see § Claims (ninth type)
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
│   ├── systems/                     ← Optional: one note per connected system of record
│   │                                  (type: SourceSystem) — see § Source systems (eighth type)
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
{decisions,risks,stakeholders,milestones,partners,relationships,corrections,claims}/*.md, excluding TEMPLATE.md
sources/systems/*.md, excluding TEMPLATE.md
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
| `SourceSystem` | `dcat:DataService` | Optional eighth type. A connected system of record is a solved, open-standard concept — W3C DCAT already models data services; don't invent a proprietary replacement. See § Source systems |
| `Claim` | *(none, proprietary)* | Optional ninth type. What *this* organization holds to be true, on what evidence, for what period — that adjudication is the hub's own vocabulary, like `Decision` and `Risk`. See § Claims |

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

### Source systems: the record boundary's registry (optional eighth type)

Rule 6 says records stay in systems of record. A hub honouring it needs one small thing the
directory layout did not have: a place where *which systems, on what terms* is written down. A
`SourceSystem` note is that place — one note per connected system of record, in `sources/systems/`,
carrying the system-level contract: what kind of system it is, how its records are addressed, how
the hub connects, the classification ceiling of what it may emit, and how often it is re-read. It
is **optional**, like `RelationshipAssertion`: adopt it when the hub actually draws on systems of
record; a hub fed only by dropped documents loses nothing by ignoring it.

| Field | Purpose |
|---|---|
| `systemKind` | `erp` \| `crm` \| `hris` \| `finance` \| `dms` \| `ticketing` \| `transcription` \| `idp` \| `vault-export` \| `other` |
| `uriScheme` | How pointers into this system are written, e.g. `gdrive://`, `notion://`, `transcript://` — the resolvable-pointer half of Rule 6 |
| `connector` | `manual` \| `mcp:<server-name>` \| `api` — how material crosses. `manual` is the common case and fully valid: the inbox is the connector |
| `defaultAccessClass` | The class stamped on anything extracted from this system, unless the owner rules otherwise |
| `refreshPolicy` | `on-demand` \| `daily` \| `weekly` \| `none` — how freshness is maintained. `none` declares a snapshot honestly |
| `owner` | Wiki-link to the stakeholder who owns the relationship with this system |

Grounding: `dcat:DataService` (W3C DCAT, declared in `context.jsonld`) — the same reasoning as
`Stakeholder` and `Partner`: data-catalog vocabulary is solved common ground, and a proprietary
replacement would buy nothing but lock-in. See
[`template/sources/systems/TEMPLATE.md`](template/sources/systems/TEMPLATE.md).

The note lives under `sources/` deliberately: it is provenance infrastructure, the system-level
sibling of the provenance registers already there. The division of labour with
`sources/dates-register.md` matters and is stated in both places: the **register** remains the
date gate's control point, one row per *source*; the **SourceSystem note** carries the
*system-level* contract those sources arrive under. `sources.config.md` remains the gather tool's
runtime configuration; where this type is adopted, a configured external source points at its
SourceSystem note rather than restating its terms. See also §"Source connectors (SoR gateway)":
in the connector model, each SourceSystem note *is* the connector's declarative manifest.

**Placement in a multi-hub estate (refined in v1.23).** Connectors are estate-level
infrastructure: one mail connector serves many hubs, and its classification policy must be
uniform, or the same record crosses at two different ceilings depending on which hub asked. In a
multi-hub estate, `SourceSystem` notes therefore live at the **Supervisor**, and each hub carries
a **subscription** — it subscribes to a `uriScheme` with a filter. Per-hub placement under
`sources/systems/` remains valid, and is the default, for a **single-hub deployment**, where
there is no second hub for the policy to diverge across.

### Claims: a settled fact with its own lifecycle (optional ninth type)

The reconciliation layer settles facts into topic-file rows, and for most hubs a row is enough. A
row stops being enough when a fact needs what a row cannot carry: its own lifecycle (it will be
superseded independently of its topic), an evidence chain (several resolvable pointers, not a
source-list cell), a validity window, or a stable identity another hub can reference. A `Claim`
note — one statement per file, in `claims/` — promotes such a row to a first-class entity.

Fields: the statement itself is the `title`; `owner`; `evidencedBy` (a list of resolvable
pointers — Rule 5's provenance order applies, and the mapping reuses `prov:wasDerivedFrom`);
`assertion_method` (the relationship layer's vocabulary — `directory`, `communication-evidence`,
`meeting-evidence`, `stated` — plus `derived`, for a claim computed from records: an aggregate
that crossed under law 2); `confidence` (omitted once adjudicated, as everywhere else);
`accessClass`; the bitemporal fields (§"Scheduled truth"); `supersedes`; `lifecycle`. See
[`template/claims/TEMPLATE.md`](template/claims/TEMPLATE.md).

**Reconciliation remains the adjudication process; promotion is never mandatory.** A settled row
MAY become a Claim note when it earns the overhead — it never must, and a small hub loses nothing
by keeping its tables. When a row is promoted, it points at the note instead of restating it:
single home of record, as everywhere. Grounding: proprietary, like `Decision` and `Risk` — what
this organization holds true, on what evidence, is its own vocabulary.

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

## Governance Layer: Six Rules

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

**The count is of rules in force, and `lifecycle:` does not decide that (corrected in v1.57).** The
sentence above has specified the count since v1.19 as the `lifecycle: active` notes *whose `rule:`
is in force*, and the predicate that shipped read `lifecycle: active` alone, so **the implementation
never matched its own published specification**. `lifecycle:` records whether a **document** is
current; `rule:` is what makes a note a binding rule, and this standard already says so in §"`rule:`
is the whole point": a correction that produces no rule is probably an ordinary edit and not a
`Correction` at all. So the registry's own `README.md` — a reference document, current, carrying no
rule — was counted as a rule that binds, and **every scaffold document ever added to the directory
reproduced it**, the count drifting by one more each time. Measured on a live registry: the shipped
predicate returned **90**, the corrected one **89**, and `README.md` was the sole difference, with
three independent instruments in that deployment already agreeing on 89.

The predicate has three arms and all must hold: the file is **not scaffold**, it carries a **`rule:`**,
and it is **`lifecycle: active`**. Scaffold is this standard's own set — `README.md`, `TEMPLATE.md`,
`hub-manifest.md` (§"Currency of generated documents") — plus a generated `index.md`, which carries
`lifecycle: active` by construction since v1.15 and is therefore the second shape that reads as
current while asserting nothing. **The printed line states that predicate rather than a wider claim**,
because a check whose printed claim outruns what it counts is the defect one layer up from the count
itself. **The remedy is never to take `lifecycle: active` off the scaffold document**: that edits the
data until a broken counter accidentally agrees, and the next scaffold file added reproduces the
defect.

*The limit, stated rather than hidden.* A **derived** artifact of the registry — a generated digest of
its rules — that rendered `rule:` and `lifecycle: active` at column zero would be counted, because
nothing in the evidence distinguishes it from a note. No filename pattern for such an artifact is
written into the check: this standard defines none, and a name list beside a check is the
hand-maintained memory of one deployment's directory that this standard already records as the
artifact class that rots. The repair for that case belongs in the generator, or in naming the artifact
under the scaffold set above.

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

### Rule 6: The record boundary (added in v1.22)

**Records stay in systems of record. Hubs hold claims about records.**

A hub is not a data store. The moment it starts holding copies of operational records — CRM rows,
ledger entries, personnel files, contact databases — it becomes a shadow system: unowned,
unrefreshed, and invisible to the access controls of the system the records actually live in.
Every hub therefore distinguishes **systems of record** (the ERP, CRM, HRIS, finance system,
document store, ticketing system, transcription service, identity provider — wherever a record is
mastered) from **knowledge** (what the hub asserts about the world). Records stay in the system
that owns them; the hub holds **claims about records**, each with a resolvable pointer back
(Rule 5's provenance order applies to the pointer).

Four crossing laws govern what may pass from a system of record into a hub:

1. **Claims cross; records don't.** *"The contract commits us to X — at `<uri>`"* is hub
   knowledge. The contract itself stays in the document store.
2. **Aggregates cross; line items don't.** A total computed across a ledger is knowledge; the
   ledger's rows are records.
3. **Existence crosses; contents don't.** That a database exists — its size, owner, and location —
   is knowledge; its rows are records. A hub can answer *"what do we hold, and where?"* without
   holding any of it.
4. **When a copy is unavoidable — pointer rot, survivability (sources get revoked; people leave) —
   copy only the classified extract, with lineage:** source pointer, extraction date, access
   class. A hub must survive losing its system of record, but only at the fidelity its access
   class permits.

**This rule names a boundary the standard already enforced by hand.** The inbox (Rule 1), the date
gate, and the reconciliation layer *are* the gateway between systems of record and the hub,
operated manually: material lands in `_inbox/`, is dated, digested, classified, and adjudicated
before anything becomes settled hub prose. Rule 6 states what those mechanisms were always
protecting, and gives it a schema — the optional `accessClass` field below, the `SourceSystem` and
`Claim` entity types (Ontology & Entity Layer), and the optional connector section (§"Source
connectors (SoR gateway)"). The governing principle for any automation built at this boundary,
the same division reconciliation already draws: **detection, extraction, and freshness automate;
classification and resolution authority stay with the owner.**

#### `accessClass`: the classification a claim carries (optional)

Any hub document or entity note may carry an optional frontmatter field:

```yaml
accessClass: public | internal | restricted | record
```

- **Default when absent: `internal`.** A hub with no interest in classification never writes the
  field, and nothing changes.
- **`record`** marks catalogue entries and pointers whose referent must never be reproduced in hub
  content: the note may say what the record is, where it lives, and how big it is (law 3); it may
  never quote it.
- **Propagation:** anything derived from `restricted` material inherits `restricted` unless
  declassified.
- **Declassification: "Aggregation declassifies; extraction does not."** A total computed across a
  thousand rows may drop a class; a single row never does — whoever does the extracting.
- **Outbound enforcement:** nothing `restricted` or `record` reaches `shareable/` or a published
  artifact. Mechanically, the `[ RESTRICTED ]` check is classification-aware: the body text of a
  note classed `restricted` or `record` is blocked verbatim on outbound surfaces, while the note's
  **name stays nameable** — existence crosses (law 3); contents do not. Verbatim matching enforces
  the declassification rule by construction: an aggregate is not a verbatim line of any restricted
  note, so it passes; an extracted line is, so it does not. Restricted-class notes are also
  excluded from generated entity indexes. The existing `sensitivity: restricted` marker is
  complementary, not competing: a note whose **name or existence** is itself sensitive carries the
  marker in frontmatter, which blocks the name as well, exactly as since v1.16.

#### The resolution plane: record-class data is resolved, never stored (added in v1.23)

**Record-class data is never stored in the hub's git.** The hub holds the pointer; the gateway
resolves it at query time through a connector (typically MCP): clearance-checked, audit-logged,
nothing persisted. The access **event** may be recorded as a claim; the accessed **data** may not.

The reason is structural, not stylistic: git is permanent, and erasure obligations are not
optional. Personal data carries a right to erasure that a versioned file cannot honor — every
commit that ever contained it would have to be rewritten, which Rule 3's integrity model exists
to forbid. So the classes divide by **storage plane**: `restricted` content may live in git under
its class; `record` referents live only in their system of record and are resolved, never stored.
This is the one place `accessClass` is more than a handling label — it decides *where the bytes
are allowed to exist*.

#### Three planes: knowledge, resolution, scratch (added in v1.23)

Storage stays git at every station; what differs near the systems of record is the **runtime**:

| Plane | Substrate | Holds |
|---|---|---|
| **Knowledge** | git | Claims, aggregates, existence — everything Rule 6 lets cross |
| **Resolution** | gateway/MCP runtime | Nothing at rest: record-class referents resolved per query |
| **Scratch** | `_scratch/`, git-ignored, wipeable | Temporarily materialized records for batch processing, with a stated lifetime |

The scratch plane is the named home for work that must touch records in bulk — an export
extracted, processed, and deleted. It is declared (`_scratch/` at the hub root, ignored by the
template's own `.gitignore`), its lifetime is stated before materialization, and it is wiped when
the batch completes. Because git never held it, erasure is honored **by construction**. It is the
*materialized* batch degenerate case of the gateway: the same crossing laws govern what leaves it
for the knowledge plane, plus a wipe at the end. Anything worth keeping crosses as a claim,
aggregate, or classified extract with lineage — never by promoting scratch contents into git
wholesale.

#### Station and exposure: what flows in, who consumes out (added in v1.23)

Two independent axes, declared in the hub's deployment manifest (`km-deployment.md`):

- `station: org-core | domain | engagement | publication` — governs **intake**: what may flow in.
- `exposure: never-public | compartment | counterparty | public` — governs **output**: who may
  consume. Defaults when absent: `station: domain`, `exposure: compartment`.

The crossing laws are **station-transition rules**, parameterized by (from-station, to-station):
from a system of record into org-core, knowledge crosses at full fidelity (records still
resolve-only); from org-core into domain hubs, aggregates cross; onto publication surfaces, only
public claims cross.

> **Build at the station, publish at the exposure.**

The design error the two axes exist to prevent: **deriving a hub's intake rules from its exposure
hollows the hub out to match its most public consumer** — a hub filled only with what its widest
audience may see cannot answer its owner's own questions. Fill it to its station; let the
boundary produce the projections.

Two rules ride these axes:

- **Version at the tempo of decisions, not of data.** Org-core hubs snapshot aggregates at
  governance cadence — weekly, monthly, at decision points; telemetry stays in the systems of
  record and their dashboards. The hub records what the organization knew and decided upon, not
  everything it measured.
- **Hub-to-hub access is compartmented, not leveled.** Two hubs can be equally "restricted" about
  the same subject in opposite directions — one holds positions its counterparty must never see;
  the other is written *for* that counterparty. No ordering of levels expresses that. Each hub
  therefore declares an **owner**, an **audience** (who it is for), and a **boundary** (who it
  must never reach), beside station and exposure in the manifest; cross-compartment flow is
  **default-deny, Supervisor-mediated**. Three mechanisms, three jobs, deliberately
  non-collapsible: `station`/`exposure` govern a hub's **edges**; the **compartment** governs
  **membership between hubs**; `accessClass` governs **zones inside a hub**.

Full rationale, transition table, and provenance tags:
[`rfcs/RFC-002-stations-compartments-resolution.md`](rfcs/RFC-002-stations-compartments-resolution.md).

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

> **QUARANTINED at v1.40. This surface serves nothing.**
>
> It predates the four-gate projection contract below and does not enforce it. `get_entity(id)`
> applied the committed-state gate alone, so an identifier lookup returned retired and superseded
> notes in full that `list_entities()` correctly withheld; access clearance and projection-manifest
> membership are implemented on no path at all; and the content test is a denylist, so a note
> carrying a restricted marking in an ordinary directory was content by construction. Every
> content-returning entry point, the four tools and the three resources alike, now refuses and states
> why, and starting the surface reports the quarantine rather than starting silently.
>
> **This is a quarantine and not a repair.** The gates are implemented and proved by a separate
> change, and the quarantine lifts only when every required gate is enforced on every
> content-returning path and each excluded content class is proved unreachable by identifier lookup
> and by query. It is not lifted by a repair of one path while another stays unguarded. A deployment
> that had the surface enabled loses it, which is the intended outcome: it stops answering rather
> than answering under a contract it cannot keep. No hub content changes, and a deployment that never
> enabled it is unaffected.
>
> The rest of this section describes the surface's design, which stands. Read it as the shape the
> repair restores, not as a description of anything currently serving.

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
would be decorative. On the listing and query paths it also excludes `archive/`, retired and
superseded notes, and the hub's own machinery (`.claude/`, skills, templates), a query surface that
answers questions about its own tooling is noise burying the fact someone asked for. **It did not
exclude them on `get_entity(id)`, and this text used to say it did**, without naming a path. The
per-path qualification is the correction: a guarantee that holds on one retrieval path is never
written as though it holds on all of them.

**Committed is not cleared (corrected at v1.40).** This section previously read "committed = safe to
expose", and that premise is withdrawn. Committing a fact records it, and it passed review to get
there; it decides nothing about who may read it. Committed state is gate 1 of four, and a surface
that treats it as sufficient is the defect this quarantine closes. The publish boundary itself
stands, and the server must never be the thing that weakens it.

### Source connectors (SoR gateway): optional, inbound (added in v1.22)

The query surface above is the hub's optional **outbound** interface: external agents consume
committed hub facts through four tools. This section is its **inbound mirror** — the record
boundary (Rule 6) expressed as an interface. The symmetry is deliberate: outbound, the git commit
is the publish boundary; inbound, the access class is the crossing boundary. Both are additive
consumption paths, never dependencies.

**v1 — declarative.** Each `SourceSystem` note (Ontology & Entity Layer, eighth type) *is* the
connector manifest: system kind, uri scheme, connector route, class ceiling, refresh cadence. A
hub whose connectors are all `manual` is already fully described — the inbox is the connector, and
**a hub built from a snapshot is the batch degenerate case of the gateway**: a `vault-export`
source with `refreshPolicy: none`, honestly declared.

**v2 — live.** A connector — typically an MCP server — declares its readable scope, the
access-class ceiling of what it emits, its cadence, and its uri scheme, matching its SourceSystem
note. Gateway rules, whatever the transport:

- **Read-only by default.** A connector that can write to a system of record is a different tool
  with a different risk model, and is out of scope here.
- **Everything lands via `_inbox/`, or as claims with lineage** — source pointer, extraction date,
  access class. A connector is a faster inbox, never a bypass: the date gate, digesting, and
  reconciliation apply unchanged.
- **Raw records never cross.** A connector emits claims, aggregates, existence, and classified
  extracts under the four crossing laws — at or below its declared ceiling; the contents of a
  `record`-class referent never cross at all. For those referents the connector is also the
  **resolution plane** (Rule 6): it answers queries against the record at query time —
  clearance-checked, audit-logged, nothing persisted.
- **Detection, extraction, and freshness automate; classification and resolution authority stay
  with the owner.**

Like the MCP query surface, delete every connector and the hub is unchanged — the manual gateway,
inbox + date gate + reconciliation, is the reference implementation.

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

**The one lawful exception: redaction with tombstones (added in v1.23).** An erasure obligation
can reach committed *knowledge*, not just records (the resolution plane already keeps records out
of git). For that case, and only that case, an **owner-only history-redaction procedure** exists:
the content is removed from history, and a **tombstone note** is left recording the fact and date
of the redaction — the *fact that something was removed* is preserved; the content is gone. The
redaction is logged as a `corrections/` note, so the reasoning survives, and it must be
**exceptional and documented**: a hub redacting routinely is a hub that held material Rule 6
should have kept out — fix the intake, not the history. This is the supersede-never-rewrite
doctrine's explicit boundary condition, stated here so neither rule silently swallows the other.

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

#### The staleness rule: show the gap, never correct it silently (added in v1.24)

The date gate forbids guessing a date. This is its generalization to **states overtaken by
time**: a commitment whose target date has passed but still reads "planned", a periodic figure
with no successor after its period, a status the calendar has contradicted. None of these is
wrong in the record — the record was true when written — but any surface that republishes it
as-is is asserting something time has falsified, and the tempting defaults (guess the outcome,
mark it done, drop the item) all destroy trust the moment anyone checks.

**When a recorded state is contradicted by the passage of time, publish the contradiction and
name who can resolve it.** The reference forms: *"target passed, status unconfirmed"*, and *"no
later figure exists in this knowledge base."* The honest gap is also the better artifact: to an
external reader it is evidence the system reports what it knows rather than what looks
finished. Derived from a deployment that published six overtaken commitments exactly this way,
on pages a counterparty read.

### Scheduled truth: bitemporal validity (optional, added in v1.22)

`lifecycle` handles supersession — a fact replaced by a later one. It does not handle **scheduled
truth**: a fact that is true *for a period*, known in advance. A constraint that holds between two
dates (a change freeze), an exemption that expires and resurfaces, a decision overtaken by a dated
event — none of these is superseded by anything; they lapse on schedule, and no record-side
timestamp says so.

Three optional frontmatter fields, on any hub document or entity note:

| Field | The claim |
|---|---|
| `validFrom` | The fact holds in the world from this date |
| `validUntil` | …and stops holding on this date. A lapsed window is a staleness candidate **by declaration, not by guess** |
| `recordedAt` | When the hub learned it — which neither `timestamp` (last edit) nor `last-reviewed` (last re-verification) states |

World-time and record-time are different axes, and conflating them is how a hub grades itself
internally consistent while the world has moved on. This adopts the priority candidate from
[`DESIGN-RATIONALE_semantica-component-mining.md`](DESIGN-RATIONALE_semantica-component-mining.md)
(pattern 1) in normative form; the field names follow the entity layer's existing idiom rather
than the rationale's `valid-until:` sketch. Mappings in `context.jsonld`: `schema:validFrom`,
`schema:validThrough`, `prov:generatedAtTime`, all `xsd:date`. No check gates on these fields yet;
the lapsed-window advisory is specified in
[`rfcs/RFC-001-sor-gateway.md`](rfcs/RFC-001-sor-gateway.md) but deliberately unbuilt until hubs
write the fields.

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

**A numbered curated document's name is structure, not a disclosive identifier (narrowed in
v1.57).** A **numbered curated document** is a root-level `0[0-9]_*.md` or `10_*.md` — the fixed
layout of §"Hub Directory Structure" and the numbered half of the monitored-files glob, and nothing
else. On such a document a frontmatter `sensitivity: restricted` marker restricts the **content**
and leaves the **name** nameable: every body line of it is blocked verbatim on outbound surfaces,
exactly as for a note classed `restricted` or `record`, and the note's name is not. This is not a
new rule. It is crossing law 3 — *existence crosses; contents don't* — applied to a case it should
always have covered, and the comment beside the classification arm of the check has stated that
principle since v1.22.

*What earned it, and it is the same shape as the defect v1.21 repaired.* A deployment restricted an
adverse commercial claim inside a numbered rollup by marking the document in frontmatter. The check
then made the document's own name an error on every outbound surface, so the **directive that
restricted the content could not name the document it was restricting**, and the hub's scan failed at
every session start with its real integrity errors buried underneath a finding about the governance
act itself. v1.21 found the same shape and narrowed the body-marker path with the same reasoning: a
check that blocks the governed route to changing a file is protecting nothing.

*The narrowing is root-scoped, and that is the load-bearing half.* A numbered name in a
**subdirectory** is an ordinary note; the standard treats no such file as curated structure, and the
narrowing does not reach it. **Narrowing a security check is how a false positive becomes a false
negative**, so the boundary is drawn at the standard's own definition of hub structure rather than at
a filename pattern, and a case asserting that a subdirectory note's name is still blocked ships with
the change and passes on the unrepaired tree too, because its job is to pin the boundary rather than
to detect the defect.

*The body-marker path is unchanged, and it was examined rather than assumed.* A marker in a body
already restricts the section it opens and emits no name record at all (v1.21), so a numbered curated
document marked in the body was already nameable and needs no narrowing; applying one there would
only widen what is blocked. Both directions of that path are asserted in the same suite so the
statement is evidence rather than a claim.

*The trade, stated rather than absorbed.* Before this, a frontmatter marker on such a document blocked
its name and blocked **none** of its text. After it, the text is blocked and the name is not, so a
proposal quoting a verbatim line of a restricted numbered document is now an error where it was not.
That is the check doing what the marker asks, and it is the reason the repair is a change of what is
protected rather than a relaxation of it.

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
outbound surfaces, the harness projection against the hub definition (v1.32), and (if configured) open reconciliation disputes. There is no separate baseline file to maintain, the hub's own git history is the baseline.

**Every block is proved in both directions (added in v1.30).** Almost all of them report a defect
by finding something, so a clean hub and a check that has stopped firing produce the same output: a
line beginning "OK". `tests/test_hub_scan_canaries.sh` builds a clean hub from the template, proves
it green, and then injects one known violation per block, requiring both the naming line and the
exit class, for `[ INBOX ]`, `[ PROPOSALS ]`, `[ INTEGRITY ]`, `[ READABILITY ]`, `[ FRONTMATTER ]`,
`[ FRESHNESS ]`, `[ LINKS ]`, `[ SHAPE ]`, `[ CURRENCY ]`, `[ RECONCILIATION ]` and the `[ AGENT ]`
false-dispatch walk. Three cases assert the other side of the same blocks, that a resolving edge, an
unfilled template placeholder and a genuine dispatch are *not* reported, because a check that fires
on everything proves as little as one that fires on nothing. `[ QUEUE ]` (v1.31) and `[ PROJECTION ]`
(v1.32) were added under the same obligation and carry their cases with them. This matters more here than in any
single instrument: the scan is inherited by every hub, so a block that has silently stopped firing
turns an entire estate green at once, with no symptom anywhere to notice.

The same version makes `[ FRONTMATTER ]` and `[ LINKS ]` state their coverage on the passing line,
the count of documents whose frontmatter was read and the count of edges actually resolved against
the size of the note index. Both previously passed with a sentence that reads identically over forty
inputs and over none, which is the coverage half of the rule below applied to the standard's own
template: a check reporting "OK" without saying what it looked at is a word, not evidence. A hub
whose `[ LINKS ]` line reports zero edges is being told something true and useful, that the entity
layer it is relying on has nothing in it yet.

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

#### The purpose interview: the definition is produced, never assumed (added in v1.25)

The value gate above asks whether the hub is worth building; the **purpose interview** asks
what it actually is, and hub initiation is one of the interaction contract's lifecycle gates —
it may not proceed silently. `/km-init` runs the interview as batched structured Q&A and its
answers become the **hub definition**, three artifacts:

1. the **scope guard** — purpose, one line in / one line out, in the agent-instruction files, and
   from v1.32 written there inside `km:project` marked regions rather than as a bare substitution,
   so the copy stays comparable with the definition it came from;
2. the **hub manifest** — the definition recorded in `km-deployment.md` (purpose, scope guard,
   audiences mapped to the three surfaces, the elicited knowledge-vs-records boundary, evidence
   expectations, routing keywords, owner cadence), stamped with the interview date as
   `initiation-interview`;
3. the **registry row** — where a supervisor tier exists, the hub's entry in the hub registry.

Two of the interview's questions exist because assuming them fails operationally. **Audiences
map to surfaces:** each audience is named to the surface it gets (audience / owner /
practitioner), so the owner surface is planned rather than discovered missing. **The
knowledge-vs-records boundary is elicited, not assumed:** the access vocabulary (Rule 6,
`accessClass`) exists in the standard, but which of the owner's material is knowledge to curate
and which is records to point at is a conversation — walked source by source — that no default
answers correctly.

**One interview, two files, and only one of them is the home of record (v1.32).** The interview
writes the same elicited facts into the hub manifest and into the agent-instruction files, and
nothing kept the two copies equal afterwards — see *The harness projection* under the Agent Tier.
`km-deployment.md` is the home of record; the instruction files carry bounded marked copies, and
`hub-scan.sh` reports divergence without repairing it.

**The quarantine gate:** a hub whose deployment binding records no `initiation-interview` date
never scans green — `hub-scan.sh` reports it as an error — and in a multi-hub estate a
hub-shaped directory absent from the hub registry is quarantined by the estate's own scan. An
uninterviewed hub is not a lesser hub; it is not yet a hub.

**The manifest's routing keywords are gated too (added in v1.28).** `routing-keywords` is part of
the manifest the interview produces, and it is what a supervisor's registry and a decision surface
read to attribute a source or a decision to this hub. Until v1.28 nothing checked it, so a hub
could carry an interview date, an empty keywords field and a green scan at the same time, while
every surface reading the field silently attributed nothing to it — a check that exists in one
place and not the other is how a declared mechanism stops working without anyone being told.
`hub-scan.sh` now reports an empty or unsubstituted value as an error, and reports it only once the
interview date itself is valid, because a hub that was never interviewed has one defect and not
two. **Stated limit:** the check proves the field was filled in, never that the keywords are the
right ones.

#### A gate needs a route back: initiating a directory that already exists (added in v1.28)

The quarantine gate is right, and as first shipped it was a trap. `/km-init` creates a hub by
copying the template to a path where none exists, so it cannot interview a directory it did not
create. From the moment the gate shipped, every hub predating it and every existing project folder
a deployment adopts the standard onto has been non-conformant, permanently, with no act defined
anywhere that would make it conformant again. The standard's own text made the trap visible
without closing it: a pre-existing hub found beside a new one was registered as a `repo` with its
interview "owed", and `repo` is a demotion (it receives no dispatched proposals), not a route.

> **A control that makes existing artifacts non-conformant ships with the act that makes them
> conformant.**

That act is an **adoption mode** of the initiation skill: the interview runs against a directory
that already exists, and writes only what is missing. Four properties make it an adoption rather
than an amnesty:

1. **The interview is run, never waived.** The mode exists so the interview can reach a hub that
   already exists, not so the gate can be cleared without one. Stamping an `initiation-interview`
   date onto an uninterviewed hub forges exactly the evidence the gate asks for, and that is worse
   than the red scan it replaces, because a red scan is honest.
2. **It writes only what is absent.** Existing content is never overwritten, and the deployment
   provenance the hub already carries is preserved as it stands: a hub records the revision it was
   built from, and re-pinning it to a later one is a separate governed act with its own authority.
   The mode adds the hub definition, the scope guard, and (where a supervisor tier exists) the
   registry row; it scaffolds only files that are genuinely missing, and lists what it added.
3. **It clears every gate the directory tripped, or it stops.** A hub-shaped directory can be
   quarantined twice over: by its own scan, for a missing interview record, and, where a
   supervisor tier exists, by the estate's scan, for absence from the hub registry. One interview
   answers both, and clearing one while leaving the other leaves the hub non-conformant with a
   check nobody happened to be looking at.
4. **The value gate still applies, and it is harder to hold here.** Step 1's questions are
   designed to bite *before* a directory exists; afterwards, sunk cost argues for initiating
   whatever is already there. Adoption is therefore also the moment to decide that a directory
   should **not** become a hub, and an adoption pass that has never once returned that answer is
   not being run honestly.

Demonstrated by a deployment that upgraded onto eleven pre-existing hub directories: all eleven
initiation records had to be written by hand at the supervisor tier because the initializer had no
path to produce them, and the workspace scan reported clean throughout, since every hub was
running an inherited copy of the scan that predated the gate. Eleven hubs needing a route back is
what a missing route looks like at the first deployment that meets it.

#### Look before asking: the interview pre-fills what the record already answers (added in v1.28)

Before the first question is put, read what already exists: the directory itself (its documents,
its agent-instruction files, its deployment binding, its sources) and, where a supervisor tier is
present, the workspace registries. **Pre-fill every answer defensible from that evidence and
present each one with its source**, for the owner to confirm or correct, then state plainly which
answers could not be pre-filled, because those are the real questions. This is the interaction
contract's reconcile-before-asking rule applied to initiation, and it is what makes an interview of
this length survivable: asking the owner of a directory holding two years of content to describe
it from zero is how an interview gets abandoned, and an abandoned interview leaves an uninitiated
hub. It matters most in the adoption mode above, where the evidence is richest and the owner's job
is to ratify what the content already demonstrates rather than to reconstruct it.

**A pre-fill is a proposal, not an answer.** Only the owner's confirmation is recorded, and an
unconfirmed pre-fill is never written into the hub definition as though it had been given. The
mechanism's whole value is that it spends the owner's attention on what the record cannot answer;
a pre-fill that becomes the answer by default spends none of it and fabricates the definition
instead.

#### Three more questions the interview asks (added in v1.28)

v1.25 named two questions that fail when they are assumed. Three more join them, each for the same
reason: the standard already ships the mechanism, and nothing was eliciting the input it needs.

**Scope is stated as an admission rule, with its hard exclusions named.** "What this hub is about"
is a description; an agent holding an inbound source needs a rule it can apply to that source. The
in-scope answer therefore states the condition under which a source is **admitted**, and the
out-of-scope answer names the **hard exclusions**: what this hub refuses *even when a routing
keyword matches*. Keyword matching is how a source reaches a hub in the first place, so an
exclusion never stated against a matching keyword never fires, and a guard whose "out" is a subject
area rather than a refusal is barely stronger than no guard at all.

**The sensitivity posture is elicited, not discovered.** Are restricted classes expected in this
hub, and which outbound surfaces are planned for it? A yes makes the outbound lint set part of
initiation instead of a retrofit and, where the hub species axes are in use, declares them at the
start. The standard has carried the outbound restricted check since v1.16 and the access vocabulary
since v1.22, and the conversation that configures either of them was asked for nowhere — the same
defect v1.25 named for the knowledge-versus-records boundary, found a second time in a second
place. Discovering a restricted class after an outbound surface exists is the expensive order: the
material has already travelled, and the check that would have stopped it is installed afterwards.

**What should move home to this hub?** Where the workspace holds material with no home — the
supervisor's unrouted backlog, a parked register, a routing gap recorded and left open — the
interview asks which of it belongs here, and initiation moves it. A hub stood up inside a live
workspace usually exists *because* something had nowhere to go, so material left parked after its
home is created outlives the backlog's own reason for existing, and a register that is never
drained stops being read. The question applies only where such a register exists: a first hub, or
a deployment that has not adopted the routing capability, has nothing to sweep.

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
[ INTEGRITY ]   OK — committed monitored state is clean
[ FRONTMATTER ] OK — 16 monitored document(s) carry OKF frontmatter
[ LINKS ]       OK — 0 frontmatter wiki-link(s) resolve against 21 indexed note name(s)
```

Resolve any issues before proceeding.

### Step 7: Schedule a periodic scan (optional but recommended)

Set up a scheduled task (cron, a CI job, or your agent tool's own scheduler) to run `hub-scan.sh`
daily and deliver output as a notification. This catches drift before the day's work begins.

### Step 8: Connect any external source systems (if applicable)

If the initiative draws on an external knowledge system (a meeting-transcription tool, a CRM, a ticket
tracker), record the connection details and any relevant record IDs in `sources.config.md` and
`sources/transcript-index.md`. Where the record boundary layer is adopted (Rule 6), also create one
`SourceSystem` note per connected system in `sources/systems/` — the system-level contract: kind,
uri scheme, connector route, class ceiling, refresh cadence.

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

### The projection contract: four gates on every consuming surface (added in v1.24)

Every surface that consumes hub content — a static reading site, a conversational agent, a push
brief, the MCP query surface — passes the same four gates before a page or fact travels. This
generalizes the entity layer's design principle ("the git commit is the publish boundary") into
the stated contract of every projection:

1. **Committed at git HEAD**, never the working tree — drafts, open proposals, inbox material,
   and unresolved disputes stay invisible with no extra rule to write;
2. **Lifecycle-active** — retired and superseded notes do not project;
3. **Within the surface's access clearance** — the note's `accessClass` is at or below the
   ceiling declared for that surface (Rule 6);
4. **Listed in that surface's manifest** — projection is opt-in per surface, never "everything
   not excluded".

One requirement of the projection step itself: **generated markdown is normalized for its
renderer.** Source conventions and renderer conventions differ (a list beginning directly after
a paragraph, two-space versus four-space nesting), and projecting one into the other without
normalization silently flattens structure — intros merge with their bullets, sub-bullets become
siblings — while the source looks correct throughout.

Decision surfaces are not audience surfaces and never ride a projection: they are unpublished
by default (see "The decision surface" under the Supervisor Tier).

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
   `REQUIRE <regex>` (fail if absent), the whole-word forms `FORBID-WORD` and `REQUIRE-WORD`
   (added in v1.30), `PAGES <n>` (warn on drift), `#` comments. A rebuild that would reintroduce a
   corrected defect fails instead of shipping. Weakening or deleting a guard is a hub change
   requiring the owner, each guard traces to a correction.

   **A guard that could not be evaluated refuses; it never passes (added in v1.30).** A `FORBID`
   rule reports a defect by matching, so its pass is an absence, and the general rule below
   (§"Standard Maintainer") applies to it with unusual force: every guard exists *because* a
   correction motivated it, so a build reporting "guards passed" on a rule that never ran reissues
   the exact defect the document was corrected to remove. The runner therefore distinguishes three
   outcomes rather than two, present, absent, and *could not answer*, and refuses on the third with
   its own exit status. Refusal conditions: a pattern the matching tool will not compile; a
   boundary construct the tool proves inert when probed against a fixture with a known answer; text
   extraction that produced nothing; a guards file that reads as empty while its directory entry
   reports bytes; a file asserting no rules at all; and an unrecognised verb, which would otherwise
   leave an author's rule unevaluated inside a passing build. The whole-word verbs exist so the
   refusal has a route back: they use the matching tool's own whole-word flag rather than a regex
   construct, and a guards file travels between hosts, so the portable form is the documented one.
   Both directions are proved in `tests/test_km_publish_guards.sh`, including against a deliberately
   inert matching engine.

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
guard-aware, bootstrapping itself at a pinned version into an environment outside every governed
tree) serves every hub: in a multi-hub workspace it
lives once at the Supervisor tier; a standalone hub keeps it in its own `tools/`. Office-suite
"export to PDF" is a preview path, never an issue path, it drops page breaks and background fills.
The **`/km-publish` skill** (see
[`template/.claude/skills/km-publish/SKILL.md`](template/.claude/skills/km-publish/SKILL.md))
operates this layer: build, scaffold (`new <slug>`), list.

**The renderer's environment contract (added in v1.51).** Five obligations, each earned by a defect
in the script this standard has shipped since v1.3. **The interpreter is discovered, never
hardcoded**: an explicit environment variable first, then `PATH`, then the conventional install
prefixes, and an override that cannot work is refused by name rather than searched past, because an
override quietly ignored leaves the operator with a false account of which interpreter ran. **The
bootstrapped dependency is pinned**, at one named version with the reason beside it, and an
environment carrying another version is rebuilt rather than used, so an environment predating the
pin cannot survive as a silent third version. **Generated runtime state lives outside every governed
tree**, because a tool that writes into the tree it renders from makes the hub fail its own
integrity check, and the remedy an operator reaches for is committing that state into a governed
hub; the ignore rule and the scan exemption are kept as well, for the tree that already has one.
**An external binary is checked by name before the work that needs it**, and the check separates
what the build cannot proceed without from what only decorates it. **A refusal about the environment
carries its own exit status**, distinct from a guard failure, because exit 1 is a claim about the
document and a host with no interpreter is not that.

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

**A check that reports by absence is proven in both directions (added in v1.29).** Leakage scans,
denylist checks, restricted-content lints and grep-based integrity checks all report a problem by
*matching*, so a pass is an *absence*, and an absence is the same output as a broken pattern, a
mistyped path, an unread input, or a syntax the tool silently ignores. In the same change that
writes or edits such an instrument, inject a known violation and require the instrument to catch it,
then confirm it passes on genuinely clean input, and ship both directions as a test rather than as
something run once by hand: a check that has not been shown to fail has not been shown to work.
Fail closed on every input the instrument could not read, an empty scan set included, because an
unread tree is not a clean one, and state the mode actually run in the passing line so a recorded
"passed" says what was checked. Regex boundary syntax is the case that demonstrated this: `\b` is
honoured by some tools and ignored by others *on the same host*, so any matching construct is
verified against the tool that will actually run it and never inferred from the platform. An ignored
boundary matches nothing, and nothing is exactly what a clean tree looks like.

**The rule binds every check the standard ships, not only the maintainer's own (added in v1.30).**
It was written from a maintainer instrument and it is a property of the *shape*, so it reaches the
session-start scan, the publish guards, and any future check whose pass is an absence. Two
consequences follow, and the second is a limit rather than an obligation.

*First, the negative direction is the only one that detects a check which has stopped firing.* A
disabled check still passes its clean fixture, still prints its OK line, and still reports nothing
on a healthy hub; when one block of a reference scan was deliberately neutered while this version
was being written, its positive case and both of its "does not over-match" cases went on passing,
and only the injected violation caught it. A suite carrying only positive cases would have vouched
for a check that had ceased to exist.

*Second, and stated because it is easy to over-read a green canary suite: proving both directions
proves a check fires on the violation class it MODELS, never that it models the right class.* A
check whose gap is structural is reached by no canary at all, because it is working exactly as
written and the evidence it consults simply cannot represent the defect. The demonstrated case: a
hub's hand-maintained manifest was missing a row for a governed file, and the git-backed integrity
check could never have caught it, since a file absent from the manifest is invisible to a working
tree/history comparison rather than flagged by it. Canaries close *"the check stopped firing"*.
*"The check never looked here"* is answered by making each check state its own coverage, which is
why a passing line names what was scanned and a partial read is reported as a coverage gap rather
than folded into the verdict.

**A check that reads a compound value validates its parts, never the whole alone (added in v1.44).**
When the value a check reads is defined by the standard as a list, a set, or a delimited sequence,
the check splits it on its delimiter and judges each part. A verdict reached by testing the undivided
value is not a verdict about that value, because a compound value can satisfy every whole-value test
while containing no part that satisfies the rule the check exists to enforce. The trigger is named so
the rule cannot be applied absurdly: a value that is single-valued by construction is validated as a
whole because it is a whole, and that is not an exception.

*Two demonstrations, both in the checks this standard ships, and the second is why this is a rule
rather than an incident.* The first is the Reader scope declaration, repaired in v1.41. A scoped
reader names a closed list of hubs, and the check tested the whole value for the open tokens `*` and
`all`, so `scope: *` was rejected and `scope: *, hub-alpha` was accepted as a closed scope. An open
declaration hidden among well-formed neighbours passed, which is the whole of the isolation claim
gone. The second is `routing-keywords` in the deployment binding, repaired in v1.44. The field is a
comma-separated list, and the v1.28 gate tested the whole value for emptiness and for an
unsubstituted placeholder, so `routing-keywords: ", ,"` was neither, fell through every arm, and the
hub scanned green carrying no keyword at all. A supervisor registry and a decision surface then
attributed nothing to that hub, which is precisely the state v1.28 added the gate to prevent. Both
gates were written correctly for a scalar and installed over a list, which is the shape to look for:
the code reads as right, and the granularity is wrong.

*The threshold is a property of the value, not of the rule.* A closed list is closed only if every
member is closed, so one bad member is fatal and every part must pass. A keyword set needs one usable
member for a surface to attribute the hub, so the gate requires at least one and reports a stray
empty entry beside real keywords as an advisory instead of a quarantine. Copying one threshold onto
the other is how a repair for a real defect turns into a hub blocked over a trailing comma.

*The cost, stated because it is real.* Per-token validation is stricter than whole-value validation,
and it can reject a sloppy but well-intentioned declaration that the old check waved through. A
deployment adopting a per-token gate can go red on a value it had been running with, and the honest
answer is that the value was always failing the rule and only the check was not looking. Splitting a
value also costs care: the split must preserve empty entries rather than absorb or drop them, since
an entry that disappears during splitting is the defect reappearing inside its own fix.

*What the rule does not reach.* Comparing two representations of one value for identity, which is
what the harness projection check does when it holds a projected fact against its home of record, is
correctly a whole-value test, and splitting it into parts would let the two sides differ in ways the
comparison then tolerated. Compound-value validation and whole-value comparison are different acts.
The rule also proves nothing about content: a keyword gate that walks every entry still proves only
that the field was filled in with something a surface could match on, never that the keywords are the
right ones, which is v1.28's limit restated rather than closed.

*The mirror image: a value that is one thing across several lines, judged by one line (added in
v1.58, drafted and unpublished — this material binds nothing until its own owner push).* The rule
above splits a compound value into its parts. Its counterpart is that the value handed to that split
must be the **whole logical value**, because a frontmatter format that folds a plain scalar across
continuation lines lets a first physical line satisfy every test while the value a real parser reads
does not. A check that reads `<key>:` and stops at the end of that line is measuring a fragment, and
the two rules compose in one direction only: splitting a truncated value into parts validates the
parts of a fragment perfectly.

*Demonstrated in this standard's own skill-file check and repaired there.* Its budget test read the
first physical line of `description:`, so a description whose first line was 13 words and whose folded
value was 97 was accepted with no finding, while a YAML parser on the same host read the 97. The
reader now walks the block with state — a continuation is folded into the key it continues, and an
indented line that no key precedes is a violation rather than something to skip, since a line that
continues nothing is not a continuation. **No YAML library is taken as a dependency to do it**: the
folding is done in the shell the check already requires, because a parser present on the maintainer's
machine is not necessarily present in the shipped environment, and this standard has already published
a version about a tool that assumed its author's toolchain. The cost is stated: such a reader models
the plain-scalar folding these formats use, not the whole of YAML.

*The sweep this demanded found the class again, in the field the rule above was written about, and it
is registered rather than repaired here.* The session-start scan's general frontmatter-field reader
prints the first matching line and stops, and a decision surface reads the same field with an
expression that cannot cross a newline. Measured on a manifest declaring five routing keywords folded
across two lines: a YAML parser reads all five, the scan's reader reads `alpha, beta,` — two keywords
and a stray empty entry, which it then correctly splits per token, per the rule above — and the
decision surface reads two. Three keywords are invisible to every surface that routes on them, and the
hub scans green. **The per-token repair was right and was handed a truncated value**, which is the
whole finding. It is registered here rather than closed inside a repair to a different instrument,
because that reader is inherited by every hub and serves every field the scan reads: it is a change
with its own blast radius, its own canaries and its own unrepaired-tree runs, and settling it as a
side effect of an unrelated repair is the move this standard already refuses elsewhere.

*The sweep, recorded so it is not repeated blind (added in v1.44).* Every
check this repository ships was read for this class at revision `cac984e`, and re-read for v1.44
rather than carried forward on the earlier session's word: the hub scan block by block, the reader
scan, the publish guards, the leakage instrument, the skill parity check, the published-not-draft
check, the organization profile validator, the index builder, the handover hooks, the agent runtime
parity check, and the cockpit's queue and layout checks. Exactly two instances of the class were
found, and both are the ones named above. Everything else either validates per part already, in
which case it was already doing what the rule now requires, or reads a value that is single-valued by
construction, in which case the rule does not apply to it. The per-part cases are worth naming,
because they are the models: the queue block accepts an options cell only when at least one
well-formed quoted verb is found inside it, the layout check splits a grid declaration into tracks
and judges each track, the profile validator walks every element of every list it is given, the
publish guards evaluate one rule per line of the guards file, and the link check tests each
wiki-link separately rather than the frontmatter as a whole. The sweep is a point-in-time finding
over the checks that existed when it was run. The rule binds every check added after it, which is why
it is written here as an obligation and not only as a record of two repairs.

**A reference is a promise the reader can open the thing named (added in v1.45).** Published text
names no document that is absent from the published tree. Where a version's text rests on a design
document, the document lands first, as design, or the reference comes out before the version
publishes. Deciding which one after the push is not a decision; it is a defect the reader meets
before the maintainer does.

*The demonstration, and it is the maintainer's own error.* Published `main` cited `rfcs/RFC-005`
twice in this document while `rfcs/` carried RFC-001 through RFC-004, RFC-006 and RFC-007. The
routines design existed only on an unmerged branch, so the standard named a document no reader could
open, and RFC-006 and RFC-007 both rested on it: nine dangling references across three files. v1.39
published carrying two of them **while the drafting agent's own report flagged that the document sat
unmerged**, and the flag was acknowledged and not acted on. That is the part worth recording. The
failure was not that nobody noticed. It is that noticing changed nothing, which is exactly the gap a
mechanical check exists to close, and the reason this rule is written as a check rather than as
advice to look harder.

*Why nothing caught it.* The reference is written as a code-formatted path rather than as a Markdown
link, so every walk over hyperlinks passed over it. A check that reads only the form a reference
usually takes reports a clean tree for the form it does not read, and a clean tree is what a working
check also looks like. `scripts/validate_rfc_references.py` therefore extracts identifiers from
running prose, from version-ledger rows, and from the dependency and provenance sections of the
design documents themselves, and it holds a reference written as a path to the stricter test that the
file it names exists, so a rename inside the directory cannot leave a link passing on the strength of
the number in it. The set of documents that exist is **derived from the directory**, and no list of
known identifiers is held in the check, so adding or removing a document changes the answer with no
edit to the instrument: a list kept beside the check would be a hand-maintained memory of directory
state, which is the artifact class this standard already records as the one that rots. The check
refuses rather than passes when it cannot list the directory, when the directory yields no document,
when nothing parsed anywhere, or when a file in scope cannot be decoded, because an unread directory
is not an empty one and a pattern that has stopped matching produces the same silence as a tree that
cites nothing. It states on a passing run how many references it found, across how many files, and
how many documents are present. Both directions are proved in
`tests/test_rfc_reference_integrity.sh`, one case per written form, and the set is run against the
published tree that carried the defect, where it names all nine real references.

*A design document may land ahead of the version that implements it, and landing is not adopting.*
The repair here is to land the document, which is the route RFC-004 took to the published branch
before v1.32 and v1.35 implemented parts of it. A document landing this way binds nothing, claims no
version, adds no version-history row, and changes no normative text, and its own status banner says
so. Where that banner has gone stale against what has published since the document was drafted, the
banner is corrected to state the document's true status on the day it lands and the design is left
alone: this is a status repair of the same kind as the publishing step's clearing of draft markings,
and rewriting a dated design record to agree with the present would falsify it.

*The limit, stated rather than hidden.* This models one class: a reference whose target is not in the
tree. It says nothing about whether a resolvable reference characterises its target correctly,
whether the target is current, or whether a document that should have been cited was cited at all.
The last of those is the structural gap no canary reaches, for the reason v1.30 already gives: the
check is working exactly as written, and the evidence it consults cannot represent a citation nobody
wrote.

**A gate runs before publication, and it declares what it cannot do (added in v1.46).** Every check a
repository ships is run by one command, and that command decides what to run by **discovering** the
checks rather than by holding a list of them. A list beside a runner is a hand-maintained memory of
directory state, and
this standard already records that artifact class as the one that rots. Nothing discovered is dropped
in silence: a check that cannot run itself declares why and names the canaries that cover it, and the
gate refuses unless those canaries run in the same pass, because otherwise a check is deleted from
the gate by one comment line. The gate refuses rather than passes on a file it cannot read, a check
it could not execute, and an empty discovery set, since an unread tree is not a clean one, and it
states its coverage on the passing line so a recorded pass says what was looked at.

*The gate discovers the tree it is being asked to judge, which is the working tree and not the index
(added in v1.54).* A gate is run to decide whether a change may be committed
and published, so the tree it must see is the one the maintainer is about to commit from. Discovery
that lists tracked paths alone sees a different tree, and the difference is exactly one file class:
the check authored in the change being gated. That is not an unlucky edge. The maintainer contract
orders the gate to run **before** explicit staging, so a newly written check is guaranteed to be
untracked at the moment the gate runs, and a gate blind to it returns the count and the verdict a
clean tree returns. Discovery therefore reads tracked and untracked files together; an untracked
discovered check is held to the added-check declaration rule, because it is one; and the coverage line
states how many of the discovered checks were untracked, since a number that merges what a repository
ships with what it does not says less than it appears to. Where a contract fixes when the gate runs
relative to staging, that contract states which tree the gate reads, because the instruction is
correct under only one of the two answers. The trade is stated rather than absorbed: a scratch file
shaped like a check and sitting where checks live is now discovered and run, which is the price of
having no convention for what a check is other than its name and its directory, and it is the cheaper
of the two errors. Discovery still honours the repository's ignore rules, so a check-shaped file under
an ignored path is not seen, and that is recorded as the residual gap it is rather than left for a
reader to discover.

*What earned this, and it is not a missing file.* The repository had seventeen suites and three
validators and no way to run them but by hand. That is the symptom. The cause is that **verification
was performed by the same actor that authored the change**, and it failed three times: a scope bypass
passed a green suite and a leakage scan and was recommended for publication; a version published
citing a design document that was not in the repository, after the drafting agent's own report
flagged exactly that; and three published versions told readers their binding sections carried no
obligation, because the publish ritual never cleared draft markings from the section bodies. One
command cannot repair an actor problem, and a standard that pretended otherwise would be shipping the
false confidence it exists to prevent.

*So the gate requires the declaration, which is the part that reaches the actor.* Every check records
what it found when it was **run against the unrepaired tree**: the version that run happened under
and its result, or an explicit statement that no such tree existed or that none was recorded, with a
reason either way. A missing declaration fails the gate. A check the change **adds** names the
version being drafted and may not plead that nothing was recorded, because a check born in this
change has no history to plead. A check the change **changes** has its declaration line among the
lines the change added, so an edit cannot quietly outrun what the declaration claims. Where the gate
cannot resolve a base to measure against, it reports a coverage gap rather than folding the absence
into its verdict. This is the same move this standard already makes for exemptions, where an
exemption with no stated reason is refused: a property nobody can verify becomes a claim anybody can
check.

*The evidence for making that the mandatory step.* Running a new check against the unrepaired tree
has caught something real **four** times in the sequence of repairs that produced these rules: the
Reader scope bypass, the query-surface quarantine, the skill parity check, and the reference check.
It is the highest-yield step in the loop and it is the one most easily skipped, because by the time a
maintainer writes the check the defect is usually already fixed in the working tree and running it
against the old state feels like ceremony. It is not ceremony. It is the only step that distinguishes
a check that detects the defect from a check that agrees with whatever the repaired tree already did.

*The first limit: a gate cannot run an organisation's leakage scan.* That scan needs a denylist
generated from a real organisation's own entity names, and in a canonical, publishable standard that
denylist lives **outside the repository by design**, because carrying it there would itself be the
leakage the guard exists to prevent. So a shared gate runs the leakage instrument's **canaries** and
proves the instrument works, and it can never prove that a given push is clean. The fail-closed
pre-push hook on a deployment's own clone is the only thing that scans an actual push, and it is
local and untracked by necessity. This is stated as a property of the arrangement rather than as a
defect awaiting a fix, so that a later maintainer does not spend a version discovering why it cannot
be closed.

*The second limit: a script cannot supply a second actor.* The minimum viable independence is an
adversarial pass, by someone other than the change's author, against the specific class being
repaired. No runner verifies that it happened, and a gate must not let its green imply it. What the
gate says instead, in its own passing output, is that the mechanical checks ran and that nobody other
than the author is known to have looked. The declaration is what the gate can require; the second
actor is what it cannot, and the honest thing is to write both sentences down next to each other.

*The third limit, and it was found by running the gate against a deliberately broken tree rather
than by thinking about it.* A gate reads a check's **exit status**, and it cannot see inside the
check. Given a real suite carrying a command that does not exist, this gate passed: the suite was not
running under a fail-fast shell option, it swallowed the missing command, and it exited zero on its
own accounting, so the gate reported exactly what the check reported. No runner that treats a check
as a black box can do better. What reaches inside a check is the canary rule stated above, which is
why these two rules are siblings rather than substitutes: canaries prove a check still fires, and a
gate proves the checks were all run. Neither covers the other. Pin the behaviour with a case that
asserts it as a gap, so that a later change closing it fails loudly rather than quietly redefining
what a pass means.

*A directive token is read where a directive is declared, and a quotation is never a directive
(added in v1.55).* An instrument that changes its own behaviour on finding a token in a file it scans
is reading input, and input can quote. A file that shows the syntax of an exemption, in an example, a
docstring or a sentence, is describing the mechanism rather than invoking it, and an instrument that
cannot tell the two apart is disabled by its own documentation. So a directive token binds only where
it begins its own line, after optional whitespace and at most one comment marker, and never inside a
fenced block. Both conditions are needed: the line anchor alone admits a fenced example written at
column zero, which is how examples are normally written, and fence-stripping alone admits a sentence
that mentions the token in running prose. **This rule is a property of every reader in a repository,
never of the one where the defect was found.** The class was repaired here once already, and the
repair reached one instrument while two others kept reading their exemptions from raw text; the
second finding was the first one again, in a different file. When a quotation-triggered directive is
found anywhere, enumerate every directive token the repository reads, record for each the position
its reader reads it from, and repair or clear all of them in the same change. And anchor to a
position, not to a window alone: a leading window is better than an unanchored search and is not
sufficient, because the leading lines of a home of record are its version lead, and a version lead is
exactly the prose that quotes tokens.

*A test whose subject changes a tree asserts the change, never the exit status (added in v1.55).* An
operation that creates, replaces, or refuses to replace a file has a product that outlives it, and
that product is what the test is about. An exit status is a claim the operation makes about itself,
and an operation altered to return success without acting is indistinguishable, to a status-only
assertion, from one that acted. So assert the file: that it exists, that it carries what the
operation was supposed to write, and that it no longer carries what the operation was supposed to
replace. The rule for a **refusal** is the one most easily forgotten, because a refusal looks like it
has no product: it has two, and both must be asserted. The refusal must name its own reason, or any
error at all satisfies the case, and it must leave the protected file byte-identical, or the refusal
damaged the thing it exists to protect while returning the status the test wanted. This obligation
does not reach a check, a scanner or a validator, whose product **is** its verdict; there the status
is the effect, and the assertion to add is the reason rather than the file.

*A continuous integration definition states what its platform guarantees, and copies nothing the tool
already prints (added in v1.55).* A version-labelled hosted runner image is not a pin when the
platform redeploys the image behind the label on a schedule, and calling it one tells a reader the
environment is fixed when it is not; say what the label actually buys, which is usually that the job
does not move to a new major release on its own. And where such a definition would restate a set of
statements that lives in the tool it runs, it obtains them from the tool at run time instead. A copy
of a list that lives somewhere else drifts, and this one had: the definition documented two of the
gate's limits while the gate printed four, and an external reviewer found the gap rather than the
authoring loop. The tool holds the list once, prints it from that one definition, and exposes a
command that prints it alone, so adding a statement is an edit in one place and every reader of the
log sees the current set.

*A gate's verdict is about the tree it discovered, and it says so or it certifies nothing (added in
v1.58, drafted and unpublished — this section binds nothing until its own owner push).* A gate
discovers its inputs at the start and returns its verdict at the end, and on a repository of any size
those are twenty minutes apart. Nothing in between establishes that the tree at the verdict is the
tree that was discovered, so a maintainer editing alongside the run — which is the normal case, not a
transgression — moves the gate's subject underneath it, and the gate cannot tell. The demonstration
was an external reviewer's: this repository's gate began on a clean branch, the branch changed, a
discovered check was edited, and the gate returned PASS after about 900 seconds still reporting zero
changed declarations. The thing editing the tree was the maintainer's own drafting agent, which is
why the finding is about the instrument and not about anyone's conduct. **A PASS that cannot name the
tree it judged is not a verdict.**

*The obvious repair is the wrong one, and the trap is worth stating because it is the first thing
anyone reaches for.* "Run against an immutable snapshot" means snapshotting **tracked** content, and a
gate that discovers the working tree does so precisely because the check authored in the change being
gated is untracked at the moment the gate runs. Snapshotting tracked content would silently undo that
and reopen the defect it closed. So the gate takes the fail-closed route instead: it **fingerprints
what it actually reads** — the same set discovery reads, tracked and untracked alike, by content, with
the revision identifier alongside so a branch change is caught even when every file happens to match —
before and after, and **refuses** when the two differ, naming what moved. A refusal, not a pass, and
not a silent re-run: a tree moving underneath a long pass is the thing the maintainer needs told.

*This is a refusal condition first and a stated limit second, and both, because they answer different
questions.* Drift is detectable, and what a gate does with a condition it can detect is refuse — the
verdict category it already has for "could not evaluate". But what a PASS now means is narrower than a
reader will assume, and that belongs with the limits, which is where this standard already puts every
sentence of the form *a green line does not mean this*. Two residuals, stated rather than implied
closed: a file that changes **and changes back** inside the window is byte-identical at both ends and
invisible to any before/after comparison, because no evidence of the middle survives — catching that
needs a watcher rather than a pair of reads, which is a different instrument at a different cost; and
the fingerprint covers **only** what discovery covers, so everything else the checks read can move
mid-run unseen. Widening it to the whole tree was considered and refused: the checks and tools
legitimately write inside the tree they run in, and a fingerprint over everything converges on a gate
that refuses every run, which is how a gate gets switched off and takes the real checks with it. Pin
the narrow scope with a case that asserts it as a gap, so a later change that widens it fails loudly
instead of quietly redefining what a pass covers.

*And a limit is worth adding only if adding one is cheap, which is the second half of this version.*
The set of limits a gate states is exactly the kind of set this standard says must have one home:
before v1.58 this repository's gate held its limits as data, argued them again in a numbered prose
block, and pinned that block's wording in a third place with hardcoded assertions, while a comment
beside the data claimed that adding one was an edit to the data and to nothing else. That claim was
false when it was written. The repair is the one this standard prefers wherever it is available:
**reduce the count of maintained definitions rather than describe the drift.** Each limit now carries
its own argument beside the words every surface prints, the prose block is gone, and the assertions
derive instead of enumerating — and the proof that it worked is that this version's own fifth limit
was an edit to one structure. Where such a reduction is not available, state the several places
plainly; what is not available is leaving a claim standing that the file itself contradicts.

*What the gate does not reach beyond the limits it states.* It checks that a declaration was made and
re-stated, never that the run behind it happened. It does not force a fresh unrepaired-tree run for a
typo fix, only a deliberate re-statement, so a maintainer who re-states without re-running is inside
the letter of the rule. And branch protection, required status checks, signed tags and review records
are settings on a hosting service rather than material in a repository; they are the owner's to set,
and a standard that claimed them would be claiming a control it cannot ship. The limits themselves are held in
one definition inside the gate and printed from it, by the passing verdict and by a command that
prints them alone, so that no other file has to carry a copy that will drift.

*Run the gate against a deliberately broken tree before trusting it, which is the rule it imposes on
every other check applied to itself.* Doing that here found the third limit above, and it found a
defect in the gate on its first full run against the real repository. Both are the argument for the
exercise in miniature: a gate is a check that reports by absence like any other, and a gate that has
never been shown to fail has not been shown to work.

**A document is held to what the system does, and a shipped document most of all (added in v1.48).**
A page that describes a capability the system does not have is a defect of the same rank as a check
that passes by absence,
and it is caught by nobody, because a document has no exit status. Four repairs have now landed on
one class: published sections telling readers a binding obligation bound nothing (v1.42), published
text naming a document no reader could open (v1.45), published rows naming days on which nothing
happened (v1.47), and an inherited landing page teaching a governance model the standard had replaced
(v1.48). Three obligations follow.

*A document a deployment installs carries its false statement into every deployment.* The hub template's
landing page is copied verbatim into each new hub, so a wrong rule count there is one wrong page per
hub rather than one wrong page, and the total grows with adoption while the repository's own copy
looks like a single file. Weigh a claim on an inherited surface by the number of installations it
reaches, and repair it before a claim in the reference document alone.

*Where the claim is an enumeration, derive it and check it; where it is a judgement, narrow it and say
no check covers it.* A rule count, a file list or a version identifier can be compared against the
home of record, and the comparison is derived from that home rather than copied beside the check, or
the check becomes the second stale copy. An enforcement claim, a currency claim and a description's
accuracy are judgements no evidence in the tree represents, and an instrument built over them models
whether the sentence was edited rather than whether it is true. Say so in the version row instead of
letting a green gate imply a coverage nobody has.

*A descriptive set that has stopped tracking the system is labelled, not silently refreshed.* Label it
wherever it is linked, because the reader who needs the label arrives from somewhere else, and name
what the snapshot does not cover so the label is usable rather than merely defensible. A dated record
is never rewritten to agree with the present, and the choice between labelling and refreshing is
stated in the version row with its reason, because a refresh riding inside a documentation-truth
change is the largest and least reviewed part of it.

**A design record states its own disposition, and the count of the set is derived (added in v1.50).**
A repository that publishes design documents publishes a second thing with them: the question of
what became of each one. Answer it in an **index** that covers every document in the directory and
records, per document, its status, the version that implemented it, and the narrowing where a design
was implemented in narrowed form. The index is the home of record for disposition, the version
ledger is the home of record for what published, and every claim the index makes cites the second.

*Why the index rather than the banners.* A status banner is written on the day the design is written
and is read on every day after it. It goes stale by sitting still, which no author ever notices,
because a document that has not been touched looks maintained. Seven banners maintained separately
are seven places for the same fact, and the class this standard already names for a copy with no
source applies exactly: it rots. The index gives the copies a source.

*The count is generated, never maintained.* Any surface stating how many designs are adopted is
rendered from the index by the instrument that validates it, and the validating run asserts that the
committed surface and its accessible text are what it would render. A count typed beside an index is
a hand-maintained memory of that index, which is the artifact class under repair, and the accessible
text is judged with the image because a reader who receives only the alternative text is the reader
left holding the false claim.

*A stale status is corrected by adding a record, never by rewriting the design.* This is v1.45's rule
applied a second time, and the discipline is the whole of it: leave the banner's original words
standing as the dated statement they were, add a dated note recording what has published since, name
the narrowing where the implementation narrowed the design, and leave a dated addendum inside the
document alone even when its present tense has gone false, because the current fact belongs in the
note that carries today's date and in the index that carries none. A design body rewritten to read as
the version that implemented it is no longer a record of what was proposed.

*Verify the finding before repairing it, and record what does not survive.* Of six claims made about
this class in one external report, two described defects that were not in the tree and one defect it
never mentioned was real. A remediation taken on trust would have falsified a correct status and left
a false one standing. Where a claim does not survive verification, publish the disproof beside the
repairs rather than dropping it, so the next reader knows the status was examined and not overlooked.

*The limit, stated rather than hidden.* Implementation is derived from ledger rows binding an
implementation verb to a reference, which is a **lower bound**: a version that recorded an adoption in
other words is invisible to it, and widening the pattern until it caught them would catch rows that
name a design while implementing nothing. Whether an index entry describes a narrowing correctly is a
judgement no evidence in the tree represents, and an instrument built over it would model whether the
sentence had been edited.

**An executable the standard ships claims only the hosts it was run on (added in v1.51).** Bootstrap
code is the least exercised code a standard ships, and the reason is structural rather than
negligence: it is written once on the author's machine, it succeeds there, and the environment it
builds persists, so the branch every other host takes is the branch that never runs again on the
machine of the person maintaining it. Five defects accumulated in nine lines behind that, and no
check in the repository could reach any of them. Three obligations follow.

*Give the bootstrap a way to run without doing the work.* A subcommand that resolves the environment,
reports what it resolved, checks the external tools and installs nothing turns an untestable branch
into one a canary can drive. Without it a case has to perform the whole expensive act to reach the
cheap decision inside it, which is why the case never gets written, and an untested branch in a
shipped executable fails at the one moment nobody in the deployment can diagnose it.

*Discover, pin, and stay out of the tree.* Search rather than hardcode, and let an operator name the
answer explicitly. Pin what is installed, because an unpinned install is a different program on a
different day, and this repository has already paid for that class once. Put generated state outside
every tree the tool can run in, because an ignore rule reaches only the trees that adopt it while
moving the directory repairs all of them at once, and keep the ignore rule anyway for the tree that
already has the state sitting in it.

*Claim a platform only where the change was run, and say so in the executable itself.* A portability
repair whose version row says "portable" about a path nobody executed is the same false statement as
the one it repaired, one layer up. Name the exercised host, name the written-and-unverified ones,
name what is out of scope and why, and put those words where the operator meets the failure rather
than only in the ledger, because the reader of a shipped tool is not reading the standard.

**A status is read where a status is declared, and quoted everywhere else (added in v1.52).** A
check that decides a record's status by looking for the words of a declaration is disarmed by any
document that quotes those words, and quoting the text a rule governs is what a remediation record
does constantly: a version row that evidences a claim, a check docstring that defines what it
matches, a canary fixture that carries a violation on purpose. Anchor such a check to the place the
declaration is made, name the tolerances that place allows, and treat the same words anywhere else
as the quotation they are. Where two instruments read the same status, the rule lives
in one of them and neither holds a copy, because a status two checks can disagree about is not a
status.

*The demonstration, and it is this repository's own publication ritual.* Two checks read publication
status out of the version ledger: one applies it to draft markings across the governed surface, and
one excludes a version awaiting its push from date comparison. Both searched the declaration token
anywhere in a row. A version row then evidenced a statement by reproducing another row's declaration
verbatim, and from the moment that row's own opening was flipped to its published stamp, both checks
read the published version as still awaiting its push. One stopped comparing its date. The other
stopped judging any marking that named it, which is the arm that catches a publish commit failing to
clear its own markings, and three real stale markings sat inside that exemption. Both returned a
pass. Two green checks, both blind, over an incomplete publication, and the cause was ordinary house
practice rather than an unusual input.

*Two properties of the repair are the transferable part.* **The failure mode is a silent withdrawal
of coverage, not a wrong answer**, so it presents as a shorter list of things examined, which is the
same output a clean tree produces; a check whose classification can shrink its own scope states how
much it excluded and names what. **And the current tree is no evidence at all.** A rule narrowed until
the tree goes green passes, and so does a rule that has stopped matching entirely. The only case that
separates a repair from either is a record that is genuinely in one state while quoting the
declaration of the other, in both directions, run against the tree where the quotation was live.

**A count of a growing set is derived or dropped, and a record is corrected only where it was wrong
when it was written (added in v1.56).** Two rules, and the second is the one that is easy to get
backwards.

*A number typed beside the set it counts is a hand-maintained memory of that set, which is the
artifact class this standard already records as the one that rots.* So a surface stating how many of
something a repository holds either derives the figure from the home of record, as the design index
and its badge already do, or states no figure and names where the figure is read. A fresh number
written into live prose is the same defect one week younger, and the week is the only thing the
refresh bought. Where a count genuinely helps and cannot be derived, write a **lower bound** or date
it, because neither can be falsified by growth. The demonstrations are this repository's own: an
enumeration of the skills a template installs that named six while the template installed seven; a
maintainer contract that told every report to read the gate's *two* limits while the gate printed
three, and then four; and a design set described in prose as "seven of them" standing beside a badge
that derived the same number from the index.

*And a dated record is corrected when its statement was **false on the day it was written**, and left
standing when it was **true then and overtaken since**.* Those are different acts and they are told
apart by one question, asked about the thing the statement names: was it wrong at the moment of
writing? A false statement in a published record is corrected in the record, which is the rule this
standard already applies to a false date, with the pushed commit and tag that carry the original
wording left exactly as they are; the correction names itself, so a reader meets a correction rather
than a contradiction. A statement that was true and has been overtaken is **never** rewritten to
agree with the present, because rewriting it destroys the record of what was known and decided. Where
such a statement invites a present-tense reading it cannot keep, the repair is neither a refresh nor
a deletion: **date it**, so the sentence says which day it is about. That keeps the measurement, kills
the false reading, and cannot go stale. Deciding which of the two a claim is takes a measurement, not
a memory, and the measurement belongs in the version row beside the repair.

*The limit, stated rather than hidden.* This reaches a claim about a set an instrument can list. It
says nothing about whether a description is accurate, whether a judgement is sound, or whether a
document that should have been cited was cited at all, and an instrument built over those would
model whether a sentence had been edited. Where a claim is a judgement, narrow it and say that no
check covers it, which is the same answer this standard already gives for enforcement and currency
claims.

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
| Governance rules (six rules) | The control model; partial compliance breaks auditability |
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
and `07_glossary.md` tag vocabulary. Status values:

| Status | Meaning | Can receive dispatched proposals? |
|---|---|---|
| `hub` | An initiated hub with full governance (`changes/`, manifest, scan) | Yes |
| `repo` | A plain folder for a real initiative, not yet a hub | No, facts park in `_unrouted/` |
| `merged` | A tombstoned hub absorbed into another; carries a `merged-into` column naming the survivor (added in v1.35) | No, the row is a tombstone; content lives in the survivor |

The `merged-into` column is empty for `hub` and `repo` rows and names the survivor folder for a
`merged` row. A `merged` row **stays in the registry** rather than being deleted: a hub-shaped
directory absent from the registry is quarantined by the estate scan, and a tombstoned hub must
report a tombstone, not a quarantine (see "Hub merge: absorb-and-tombstone" below). A deployment that
never merges carries the extra column empty and is otherwise unaffected.

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

### The supervisor threshold: hub count > 1 (added in v1.26)

**The moment there is more than one hub, the standard advises creating the Supervisor tier.**
This replaces the earlier trigger ("once two or more hubs share a source or an entity"): the
count of hubs is the threshold, not whether they overlap yet. The reason is where estate-level
state lives — the decision queue, the owner's surface, and cross-hub reconciliation belong to
the estate rather than to either hub, and putting them inside a hub conflates the tiers; a
second estate demonstrated this by accumulating estate state with nowhere correct to hold it.

**The part that decides whether the rule is followed: the tier must scale down.** A mature
supervisor is large — protocol, evidence standard, semantic layer, routing, escalations,
sweeps — and a two-hub estate that reads the rule as "build all of that" will ignore it. So the
standard defines a minimum, and everything else is adopted against a named condition.

#### The minimum tier

A directory at the workspace root holding exactly four things:

1. **`hub-registry.md`** — one row per hub: folder, status (`hub`/`repo`, and `merged` with a
   `merged-into` column where a hub has been absorbed, v1.35), owner,
   routing keywords (each hub's row is written by its own `/km-init` interview);
2. **`QUEUE.md`** — the estate's owner queue (the mechanism above, at its smallest);
3. **`_inbox/`** — the drop zone; inbox-first applies to the supervisor from day one;
4. **its own git history** — `git init` at minting; auditability without bureaucracy, as above.

That is all. Every omitted capability has a **named adoption condition** — the conditions table
ships in the minimum tier's own README (template:
[`skills/km-supervise/_KM_Supervisor_template/`](skills/km-supervise/_KM_Supervisor_template/)):

| Omitted capability | Adopt when |
|---|---|
| Routing pass (`relationships.md`, `routing-log.md`, `_unrouted/`) | A source belongs to two or more hubs |
| Semantic layer (shared-entity registry) | Hubs start disagreeing about the same people, organizations, or products |
| Escalation protocol (`escalations/`) | Someone other than the owner operates a hub, or restricted-class content appears |
| Evidence standard (`EVIDENCE.md`) | Two sources conflict and the hubs need one binding trust order |
| Estate corrections registry (`corrections/`) | The owner corrects the agent on a rule that crosses hub boundaries |
| Decision surface (KM Cockpit component) | The owner wants the queue as rendered cards rather than a file |

#### Bind only what exists

A hub scaffolded next to a minimum tier must not carry estate-binding references to an evidence
standard, semantic layer, protocol file, escalations folder, or corrections registry that are
not there — the template's own instruction already says a dangling binding is worse than none.
The rule: **a hub's estate-binding section names only the estate files and directories actually
present at the tier**, and each capability adopted later extends the binding through that hub's
own governance. The scan side already behaves this way (`[ CORRECTIONS ]` prints only when the
estate corrections directory exists); the instruction files must match it.

#### Detection at hub creation

Hub creation is the natural moment the threshold is crossed, so when `/km-init` finds another
hub already in the workspace it runs two checks. First, it **detects a deployed decision
surface** — a cockpit manifest at a deployment location — and asks the owner whether the new
hub joins it: with no tier yet, a yes rides the tier-minting below (the estate queue absorbs
both hubs and the manifest re-points); with a tier already present, the new hub's registry row
is all the cockpit's registry-derived map needs, and the interview states which of the two
paths applied. Second, if there is no supervisor tier, it **recommends minting the minimum
tier then and there, recommendation first** (registry rows for both hubs, the estate queue,
the inbox, `git init`). The owner may decline — the threshold rule is advice the standard
gives, never an act it performs silently.

#### The decision surface crosses the threshold by configuration

Before the tier exists, a deployed cockpit binds to the **hub-local** queue file; when the
minimum tier is minted, the estate queue moves there and the cockpit's manifest re-points its
queue path (and gains the registry path) — the same data contract at both scales, one config
change, no rebuild (see `components/km-cockpit/`). This is why the component is genericised by
configuration: the threshold rule is only followable if crossing it is cheap.

### Standing up the Supervisor: checklist

At the second hub (the threshold above), mint the **minimum tier**:

1. Create `_KM_Supervisor/` at the workspace root: `hub-registry.md`, `QUEUE.md`, `_inbox/`,
   and the README with the conditions table (template:
   `skills/km-supervise/_KM_Supervisor_template/`); `git init` the directory.
2. Build `hub-registry.md`: one row per sibling folder, classified `hub` or `repo`, with owner
   and routing keywords from each hub's interview record (`km-deployment.md`), `CLAUDE.md`
   scope guard, and `07_glossary.md` tags.
3. Re-point any deployed decision surface at the estate queue (one manifest change, above).

Adopt the routing capability when its condition first occurs (a source belongs to two or more
hubs): create `relationships.md` (empty edge table), `routing-log.md` (empty run list) and
`_unrouted/`, all with OKF frontmatter, then run a dry-run routing pass on a recent batch of
the cross-cutting source and review the routing table before any live dispatch.

### What the Supervisor does not do

- It does not hold copies of facts that have been routed home (single home of record).
- It does not run a second governance system, dispatched proposals use each hub's existing Layer-2 flow.
- It does not auto-create hubs or auto-confirm edges, both require an explicit owner decision.
- It does not replace the per-hub gather process; it *invokes the same extraction discipline* across
  hubs and routes the results. Inside a single hub, the ordinary gather process remains the right tool.

---

### Hub merge: absorb-and-tombstone (added in v1.35)

> **Added in v1.35.** This section is designed in
> [`rfcs/RFC-004`](rfcs/RFC-004-harness-projection-hub-merge-multi-tenancy.md) Part II. It answers
> the second of the three gaps a deployment owner named
> (2026-08-18): there was no mechanism for combining two hubs when an engagement turns out to be one
> thing rather than two, or when a hub was stood up too early, and the only paths were leaving both
> or hand-moving content, neither of which preserves provenance. Every primitive it needs already
> exists in the standard; this section is the first to combine them and name the act. The mechanism
> is drafted from design and not yet proven by a run, the same status the adoption mode carried at
> v1.28.

#### Three cases wear one word, and only one is a merge

The first duty of the design is to refuse two of the three cases people call a merge. A merge
process that never returns "these two should stay two" is a rubber stamp, exactly as an adoption
pass that never returns "this should not become a hub" is not being run honestly.

| Case | What it actually is | Route |
|---|---|---|
| **Two hubs overlap** (they share sources, entities, or facts) | A routing question | **Not a merge.** Typed references and the single-home-of-record rule already solve it, and `relationships.md` records the edge. Merging on overlap destroys two working admission rules to fix a problem references already fix. |
| **A hub was stood up too early** (little content, no answered competency questions) | The value gate arriving late | **Withdrawal**, below. Cheap, and it stays cheap. |
| **The engagement turned out to be one thing** (both hubs have real content, history, and settled facts) | A merge | **Absorb-and-tombstone**, below. |

#### Withdrawal: the early-hub case

A hub with no answered competency questions never earned its existence, so the act is the value gate
arriving late rather than a structural merge.

1. Its content re-homes as **ordinary intake** into the receiving hub: inbox, date gate,
   reconciliation pre-check, proposal, approval, commit. At this volume the standard governance flow
   is the right size and no new mechanism is needed.
2. The receiving hub's routing keywords **absorb** the withdrawn hub's, or sources that were reaching
   the withdrawn hub stop reaching anything. This is the one step a hand-move reliably forgets.
3. The directory is **tombstoned** exactly as in absorb-and-tombstone property 5. **Never deleted.**
4. **No re-interview** of the receiving hub, unless its admission rule actually changes.

#### Absorb-and-tombstone: the real merge

Six properties. Directional throughout, except where existing doctrine determines the answer, which
is noted.

**1. Direction is declared, and a third hub is never created.** One hub is the **survivor**; the
other is **absorbed**. Merging two hubs into a newly created third orphans both histories and is
forbidden: it converts an act that preserves provenance into one that discards it wholesale, which is
the failure the owner named. The survivor is chosen on **whose competency questions survive**, never
on size, age, or content volume: the questions are the only measure of a hub's worth in the standard,
and a merge is precisely the moment worth is re-decided. The owner decides; both hub definitions
record the direction and the authority.

**2. The interview runs again, on the survivor.** A merge changes what the hub *is*, so it changes
the hub definition, so the initiation interview runs again and re-stamps `initiation-interview`. This
follows from the existing rule that a hub's definition is produced and never assumed, applied to the
one event that most changes it. The union of the two hubs' answers is the **pre-fill**, presented
with its source, and never the answer (the pre-fill rule of v1.28 applies unchanged, and hardest
here):

- **The union of two admission rules is almost never the right admission rule.** If it were, the two
  hubs would not have needed merging. A merged hub whose scope guard is the literal concatenation of
  the two originals is the tell that the merge was bookkeeping rather than a decision.
- **Routing keywords are the union**, or sources stop arriving. This is the mechanical half, and the
  half hand-merges lose.
- **The sensitivity posture is the stricter of the two, and is elicited, never computed.** Two hubs
  merging usually had two audiences.

Because it is an initiation act producing a hub definition, merge is a **mode of the initiation
skill**, not a separate skill. This is v1.28's own reasoning for the adoption mode: two entry
conditions producing one hub definition would otherwise drift into two definitions of a hub.

**3. Content crosses at the granularity its provenance already has.** A hand-move destroys
provenance, and re-inboxing every file would make the mechanism unusable. The split is by what the
artifact already carries:

| Artifact class | How it crosses |
|---|---|
| **Entity notes** (decisions, risks, stakeholders, milestones, partners, relationships, claims, corrections) | **Re-homed, not re-digested.** They already carry their own frontmatter and provenance. The merge adds a `movedFrom:` lineage field naming the absorbed hub and the original path, and changes nothing else. One proposal per folder class, not per note. |
| **Sources and their digests** | Moved with their `sources/dates-register.md` rows and `transcript-index.md` entries **carried over verbatim**. A source's recorded date is evidence and is never re-derived by the merge; re-deriving it is how a merge silently re-dates a hub's whole history. |
| **Reconciliation topic files** | **Merged row by row, through reconciliation itself** (property 4). |
| **Narrative rollups (`00`-`07`)** | **Never concatenated.** Two `01_project-brief.md` files cannot both be `lifecycle: active`; the currency rule already says one current document per purpose and reports the collision rather than picking a winner. The survivor's numbered docs are amended by ordinary proposals; the absorbed hub's move to the survivor's `archive/`, marked `superseded` with `superseded-by:` pointing at the counterpart. |
| **`working-docs/`, `shareable/`** | Moved with lifecycle markers intact; `publication-log.md` rows carry over, because who received what is not re-derivable. |
| **The absorbed hub's `corrections/`** | Crosses **in full.** A correction is a rule about how the organization works and it survives the hub that learned it: this is the promotion ladder pointing sideways rather than up. A duplicate of a rule the survivor already holds is retired with a pointer, never deleted. |

For volume, the merge uses the bulk-corpus intake shape the standard already records as guidance
(catalogue, boundary interview, domain split, per-domain extract): one proposal per domain rather
than one per file. Governance is not weakened, every proposal is still approved, applied, logged, and
committed under the survivor's own flow.

**4. Reconciliation is where the merge actually happens.** Two hubs that were secretly one engagement
hold contradicting settled facts. That is not a side effect of merging; **it is the merge**, and the
reconciliation layer is the mechanism the standard already ships for it. Each absorbed settled row is
checked against the survivor's ledger. Agreement is recorded; a contradiction opens a **dispute
file**, adjudicated by the owner through the ordinary three options, and **every adjudication captures
a `corrections/` note** before the dispute file is deleted, because the verdict without the reasoning
is a loss the standard already names. **A merge that raises zero disputes should be suspected of
having skipped the check**, never celebrated: two hubs describing one engagement with no
contradiction between them is possible and uncommon, and a clean run is exactly what an unrun check
also looks like.

**5. The absorbed hub is tombstoned, never deleted.** Determined by existing doctrine rather than
invented here: an accepted record is superseded, not rewritten; retired notes are kept; a falsified
assertion is retracted in place. Applied to a whole hub:

- The **directory stays** and its **git history stays.** Every external pointer into it still
  resolves, which is the provenance property hand-moving fails to preserve.
- It gains a **`MERGED-INTO.md` tombstone**: the survivor, the date, the owner's authority, the
  survivor's applying commits, and a plain statement that nothing in the directory is current.
- Its **admission rule becomes a refusal** ("this hub is merged into X; admit nothing"), so a routing
  pass or an agent that still reaches it is told, rather than quietly filing into a dead hub.
- Its **agent definition is retired** and the agent registry regenerated.
- Its **registry row stays, with a new status.** The registry gains `merged` and a `merged-into`
  column, **the one schema change this section requires.** The row must stay, because a hub-shaped
  directory absent from the registry is quarantined by the estate scan, and a tombstoned hub should
  report a **tombstone, not a quarantine.**
- Its **scan is expected not to go green**, and this is correct rather than a defect to fix: the
  directory is no longer a live hub, and a green scan would assert that it is. `hub-scan.sh`'s
  `[ DEPLOYMENT ]` block detects `MERGED-INTO.md` and reports a `TOMBSTONE` finding naming the
  survivor, in place of the interview and keyword checks a live hub runs.

**6. Estate references are re-pointed by the Supervisor, and re-pointing keeps its history.**
Relationship edges naming the absorbed hub, semantic-layer references, open queue rows, escalations,
unrouted backlog entries, and any decision-surface hub map are rewritten by the Supervisor, because
cross-hub state is estate state and no hub owns it. Per the retract-in-place rule, an edge is
**re-pointed with its history kept**, never deleted. Merge is therefore **Supervisor-mediated under
owner authority** and is not available to a hub agent: it is cross-hub by construction, which is
escalation-class work.

#### What this must NOT do

1. **It must not delete the absorbed hub or rewrite its history.** The one lawful history redaction
   the standard contemplates exists for erasure obligations, and a merge is not one.
2. **It must not concatenate narrative documents.** Two actives for one purpose is a collision to
   report, and the owner supersedes one.
3. **It must not auto-resolve contradictions.** Detection automates; adjudication is the owner's.
4. **It must not skip the interview** on the strength of already knowing what both hubs are. The
   union is a pre-fill, never an answer.
5. **It must not advertise reversibility.** Unmerging is not a mechanism, and this design does not
   pretend otherwise. Once content has crossed into the survivor's governance and been adjudicated,
   the two hubs are not recoverable as two by running anything backwards; what is recoverable is
   every individual artifact, from git, which is a different and lesser promise. **The reversible act
   is the decision not to merge yet**, and the design says so where an operator will read it, because
   a mechanism that implies reversibility invites being run on a hunch.
6. **It must not run across a compartment boundary.** See the open limit below.

#### The open limit: a compartment-crossing guard, written but inert

**A merge across differing compartment declarations is refused by this design, and the guard has
nothing to bind to yet.** Merging a hub declared never-public into one declared counterparty-facing
would declassify everything in it as a side effect of a structural act; that is a disclosure decision
and must be answered as one, before and separately. The vocabulary that would express the guard
(`station`, `exposure`, and the compartment model) is drafted and unpublished at v1.23, so **the
guard as written binds nothing until v1.23 publishes.** This is a real limit on this section, not a
reason to defer it: the other five properties stand on published doctrine, and the guard becomes
checkable the day the vocabulary does.

#### The reference deployment leads this mechanism

This section is drafted from design and has not yet been performed by a running deployment. When the
reference deployment first performs a merge it does so as the lab in which the mechanism is proven,
and the standard is brought up to what that deployment learns rather than the deployment being
dragged back to this drafted text. A conformance pass that finds the reference deployment ahead of
this section reports the gap and harvests it; it never reverts the deployment to the last release.

#### What it costs a deployment to adopt

Almost nothing until it is used: one new status value and one column in the hub registry, one mode on
the initiation skill, one section in the standard. Hubs gain nothing and change nothing. A deployment
that never merges pays the registry schema change and no more. The cost lands entirely on the merge
itself, and it is real: an interview, a domain-split intake, and a reconciliation pass whose size is
the number of contradictions between the two ledgers. That is the correct place for the cost to land.

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

**The crossing laws are scale-invariant (added in v1.23, directional).** Each layer relates to
the layer below exactly as hubs relate to systems of record: the Supervisor holds claims
**about** hubs — existence, ownership, topics, claim identities — never hub contents, and a
person's supervisor-level card records **which** compartments they appear in, never what they did
there. *Existence crosses; contents don't — at every altitude.* This is also the structural
answer to the supervisor-as-highest-value-target problem: a tier that holds only existence-grade
claims about the tiers below is not worth breaching for their contents, because the contents were
never there.

*Pointer (v1.22; updated in v1.23):* where hubs adopt the record boundary (Rule 6), the
Supervisor gains the charter material sketched in
[`rfcs/RFC-002-stations-compartments-resolution.md`](rfcs/RFC-002-stations-compartments-resolution.md),
item 8: the **promotion path** (hub experience → supervisor observation → standard RFC — the
ontology's own evolution mechanism); **cross-hub claim reconciliation** (a claim has one identity
and one home of record; the sweep detects divergence, the owning hub resolves — detection
automated, resolution human); the **federated SoR registry** (estate-level `SourceSystem` notes
with per-hub subscriptions — see the placement note in the entity layer); and **compartment
policy** (the gateway sets classification defaults; the compartment owner adjudicates exceptions;
the Supervisor holds the policy table and the escalation path). The charter rewrite itself
remains future work; this paragraph remains a pointer, not the charter.

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

> Drafted 2026-08-14; published 2026-08-16 with v1.22.

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

**A row states its options in a form the surface can read, and a row that does not is reported
(added in v1.31).** The rendered row schema is `Id | Since | Defaults | Decision | Options`, and
the options are **exact quoted verbs, recommendation first** — the quotes are what make a verb an
option; emphasis is presentation. Every deployment checks this at session start, because the
failure is silent by construction: a row whose options cannot be read renders as a complete-looking
card with no control in it, and it is discovered when the owner goes to answer, which in the
demonstrated case was in front of a client. A single-hub deployment gets the check from
`hub-scan.sh`'s `[ QUEUE ]` block; a Supervisor tier, where the hub scan does not run, gets it from
the decision surface's own `queue-check`. Both distinguish *readable* from *cannot be read* from
*could not be evaluated*, and the queue template ships worked rows — inside a fenced block, so an
example is documentation and never a decision on the owner's surface.

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
section as dated nudges, and nowhere else. This is a **hand lane**, distinct from decision tiers
A/B/C: nothing on it defaults and nothing expires. The section is a `## Owner's desk` heading with
one bullet per item; each bullet's id is **derived** as `desk-<slug>` from its leading bold phrase,
so an id survives edits to the rest of the bullet while renaming the lead mints a new id and
re-surfaces the item (a deliberate re-nudge over a silent drop). A decision surface **derives the
desk from the queue and never edits it**; the owner marks an item done through the owner-side answer
store (`{"id": "desk-<slug>", "answer": "done", "done": true}`), which rides the ordinary answers
channel so the supervisor prunes the nudge on its next pull, and the tick is a done record, never a
dismissal of a live commitment. The KM Cockpit component surfaces the desk in its own section after
Hubs; its normative shape is in `components/km-cockpit/SPEC.md` §3, added in v1.36 (dev-0005).

A single-hub deployment does not need this section, but the mechanism is not inherently
estate-sized: the moment any deployment's routine output can out-produce its one human decider,
the queue file, the tiers, and the back-pressure rule adopt without the rest of the Supervisor
tier.

#### The owner interaction contract (added in v1.24)

The queue governs what surfaces to the owner; this contract governs **how**. Every rule here
failed first as prose in a live deployment — missing links, context-free questions, duplicates,
verbosity, absent reminders, a hub initiated with no Q&A — so each is paired with a mechanism,
never restated as advice. It binds every session and every routine of the deployment that
adopts it.

1. **A question exists only as an artifact.** A question to the owner exists only as a
   registered queue row or a structured Q&A card — asking and registering are the same act. A
   question in running prose was not asked: it may not be counted on, waited for, or held
   against the owner. Every row or card carries, mandatorily: **links** to every referenced
   file; **two lines of zero-context legibility** (what it is, where it came from); **why only
   the owner** can answer it; and **options, recommendation first**, one-word answerable. Cards
   come in small batches (three or four per round), tier A first. A free-text answer always
   outranks the offered options — an answer that corrects the question or says "already
   decided" triggers a reconcile, never an argument.
2. **No duplicates, mechanically.** Because every ask is a row, reconcile-before-ask (above)
   runs against a complete register: the decision log, the queue's open and closed rows, and
   the home hub, before any row is written. A question the record answers is closed with its
   source, never re-asked.
3. **Reminders are automatic, immediate, and short.** Every row carries its ask date and age;
   session start renders unanswered asks with ages. A row unanswered across two sessions gets a
   one-line nudge — the row id and its ask line, never a re-explanation (the row already
   explains itself). A tier-A row is never silently waiting: it is nudged, or the owner has
   parked it explicitly.
4. **Estate events force a Q&A (lifecycle gates).** Some events may not proceed silently; each
   fires a structured owner interview: **hub initiation** (a hub-shaped directory not in the
   hub registry is quarantined — never scanned green — until the initiation interview runs;
   see `/km-init`); a **hub merge** (the initiation interview re-runs on the survivor and the
   absorbed hub is tombstoned, its registry row kept with status `merged` so it reports a
   tombstone rather than a quarantine; Supervisor-mediated under owner authority, v1.35;
   see "Hub merge: absorb-and-tombstone"); a **new outbound surface**
   (sensitivity interview and lint coverage before first publish); **standard adoption or
   version change** (nothing publishes without the owner's push); a **new counterpart class**
   (identity and data-protection interview before minting).
5. **Owner-facing output has a fixed, short shape.** Every owner-facing turn ends, in order:
   **NEEDS YOU** (the linked rows or cards, bounded, first — or "nothing needs you"), **DONE**
   (one line per completed thing, links inline), **FYI** (optional, three lines maximum), and
   nothing else. Narration, method, and evidence trails live in logs and commits, not in the
   owner's reading. A periodic hygiene pass reports interaction metrics — asks made, answered,
   re-asked, average nudge age — so degradation shows as a number.
6. **Answer surfaces are equal channels.** Chat, the batched clearing skill, and any deployed
   decision surface (below) are equally valid ways to answer; every channel's answers are
   processed identically — executed to committed artifacts in the same session, then
   acknowledged.

#### The decision surface: three surfaces, and the KM Cockpit component (added in v1.24)

A deployment has **three surfaces, not two**, and naming them is what keeps the middle one from
being forgotten:

| Surface | Who reads it | What it carries |
|---|---|---|
| **Audience** | Each function or counterpart the deployment serves | Generated knowledge shaped per audience, through the projection contract — no machinery |
| **Owner** | The one person decisions wait on | Only the decisions waiting on them: the queue, rendered decidable |
| **Practitioner** | Whoever operates the hub | The hub itself — files, scans, proposals, skills |

The owner surface is the one that decides whether a deployment survives: a knowledge system
produces decisions faster than it produces documents, and if those decisions accumulate
somewhere nobody opens, the system becomes a chore and is abandoned. It is therefore a
**deployment component, not an optional extra**.

The standard ships a reference implementation: the **KM Cockpit**
([`components/km-cockpit/`](components/km-cockpit/)) — a stdlib-only, single-file local web
surface rendering the queue as full-context cards with one-click answers, truthful proposal
lifecycle states, an activity audit trail, and per-hub views. It is a **side component**: own
directory, own deployment step, configured entirely by a deployment manifest (estate root,
queue path, hub-registry path, port, organization name), with the per-hub attribution map
derived from the governed hub registry. Its normative contract is
[`components/km-cockpit/SPEC.md`](components/km-cockpit/SPEC.md), and two of its rules are
rules of this standard, whatever implements the surface:

- **A surface, never a pen.** A decision surface renders the queue and captures answers; it
  never executes anything, never writes estate state, never mints identity. Answers become
  committed artifacts only through a governed session.
- **Decision surfaces are unpublished by default.** The decision layer carries budget,
  identity, and commercial context — routinely more sensitive than the knowledge it decides
  about, and the record boundary that governs knowledge says nothing about it. A decision
  surface binds to localhost and is never published beside a reading site or any audience
  surface; shared or remote access is an explicit owner decision carrying clearance and an
  audit trail.
- **A control the owner cannot press is a defect, not an empty state (added in v1.31).** Where a
  decision surface cannot read what a row declares, it says so on the card, withholds the answer
  controls, and reports the row through the deployment's own session-start check; it never
  renders an empty action bar on an otherwise complete-looking card, and it never substitutes an
  option the row did not declare — an answer recorded against a synthesised option is an answer
  to a question nobody asked. This is the false-pass rule of §"Standard Maintainer" applied to
  the owner's surface: the state that means *this could not be read* must not look identical to
  the state that means *there is nothing to do*.
- **No owner-supplied value may size a layout (added in v1.31).** Option labels, answers, notes
  and row text all arrive from files the surface does not control, so all of them render inside
  a box the layout decides. A grid track sized by an option label the length of a sentence takes
  the row and collapses everything beside it: technically correct, unreadable, and unnoticeable
  in review because it needs real content to appear.

In a single-hub deployment the same component binds to a hub-local queue file — the identical
data contract — so minting the supervisor tier later re-points one manifest path and nothing
else (see "The minimum tier", below).

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
belongs in the hub definition in `km-deployment.md` (corrected in v1.32: this said `CLAUDE.md`, which
left the standard naming two homes of record for one fact class); the definition links to it rather
than repeating it. A definition that grows
past roughly 25 lines has almost certainly copied something that belongs elsewhere.

### The harness projection: the hub definition is the home of record (added in v1.32)

The rule above is stated for agent definitions, and the largest violation of it in this standard was
the template's own agent-instruction files. `CLAUDE.md` and `AGENTS.md` restate the admission rule,
the exclusions and the hard exclusions that `km-deployment.md` already holds. The initiation
interview substitutes one set of elicited answers into both, once, at initiation, and nothing keeps
them equal afterwards.

Two failures were verified in a deployment, and they are one defect seen from opposite sides.

**The instruction file is not a superset of the template, and is not close to one.** A retrofit wave
across seven hubs found each hub carrying between four and eight sections for which the shipped
template has no counterpart at all, including owner-authored routing found nowhere else in the
standard, the deployment, or that hub. A directive written on the assumption that the template was
the superset would have deleted owner-authored text and was refused by the receiving agents for
exactly that reason. **This is the upper bound on the mechanism: nothing here generates an
agent-instruction file whole.**

**Where a fact does appear twice, the two copies drift, and within days.** In one hub the admission
rule was widened by a recorded owner ruling written into the instruction file and not into the hub
definition, so every registry-reading surface went on attributing sources by a rule the owner had
already superseded. In another the divergence ran the other way: the hub definition carried
exclusions naming each fact's true home hub that the instruction file did not have. One interview,
one day, one set of answers, both files.

**The ruling that resolves it:** `km-deployment.md` §"Hub definition" is the **home of record** for
the facts an instruction file restates. `CLAUDE.md` and `AGENTS.md` carry a **projected copy inside
bounded marked regions**. Drift is **reported, never repaired**.

#### A closed set of fact classes

The set is the interview's own output, and it is closed by the standard:

| Class | What it governs in the harness |
|---|---|
| `purpose` | What the hub is |
| `scope-in` | The admission rule |
| `scope-out` | The exclusion statement |
| `hard-exclusions` | What is refused even on a routing-keyword match |
| `audiences` | Each audience mapped to its surface |
| `knowledge-records-boundary` | What is curated as a claim and what stays in a system of record |
| `evidence-expectations` | What this hub trusts, and what needs owner confirmation |
| `owner-cadence` | Cadence and answer surface |
| `sensitivity-posture` | Restricted classes expected, outbound surfaces planned |
| `routing-keywords` | What reaches the hub at all (frontmatter) |

A hub cannot extend the list. An open list makes the coverage statement below unmeasurable, and the
coverage statement is the only honest thing this check has to say about what it did not look at.

**One class the interview elicits is deliberately absent: the hub owner's name.** It appears nine
times per instruction file, inline, inside sentences. Bounding it would mean nine markers per file
around sentence fragments, which is the opposite of a bounded region, so it is substituted at
initiation and is not projected. Stated plainly because it is a gap: a changed hub owner is
reconciled by hand.

#### The marker is the contract, not the template

A projected fact lives inside a marked region naming its class. The markers are HTML comments and
render as nothing:

```markdown
- **Admit** a source when:
  <!-- km:project scope-in — home of record: km-deployment.md § Hub definition -->
  Admit a source when it bears on the delivery of this engagement.
  <!-- km:end -->
```

The home of record marks the same values with `km:fact`. **Every unmarked line in an instruction
file is owner-authored by definition** and is never read, compared, generated or touched. This
inverts the default that made the retrofit directive dangerous: a hub carrying eight sections this
standard never heard of is fully conformant, because the mechanism was never told those sections
exist and never looks at them.

Text is compared as words, not as lines: a region is collapsed to single-spaced text before
comparison, so **reflowing a region is not drift and rewording it is**. A check that reddened on a
rewrap would be red on every hub that ran a formatter once.

#### Drift is reported, never repaired

Nothing in this mechanism writes into an instruction file on its own initiative. **Either side may
hold the newer truth**, and the verified case proves it: a projector that silently made the
instruction file match the hub definition would have reverted a recorded owner ruling and reported
success. The scan reports; the owner names which side is right; the hub definition is amended
through the hub's own governance; the projection follows. This is the division the record boundary
already draws for the gateway — detection automates, resolution authority stays with the owner.

The report therefore **prints both texts**, not just the class name. A drift report that names a
fact without showing the two values sends the owner to open two files before he can make the
decision the design reserves for him.

#### Where the region sits, which decides whether this works at all

There is an honest argument against the ruling, and it is carried into the design rather than
dropped: in the verified case the owner widened the admission rule **in the instruction file**,
because that is the file he reads. A design that fights where its owner actually writes loses
quietly, and the first symptom is drift again.

Three properties answer it, and they matter more than tidiness:

1. **His edit is never destroyed.** Report-never-repair is not a governance nicety here, it is what
   makes writing in the instruction file a safe act rather than a lossy one. The words he typed are
   still there at the next session, and the scan asks a question about them.
2. **The region carries its own pointer, in the file he is editing.** The marker comment names the
   home of record on the line above the text, so the answer to "where does this belong" is visible
   at the point of writing rather than in a standard he is not reading.
3. **It is caught at the next session start, not at an audit.** `[ PROJECTION ]` runs in the
   session-start scan every hub already runs, so the gap between writing in the wrong file and being
   told is one session. There is deliberately **no session-end gate**: a `Stop` hook fires while he
   is still mid-edit, and a mechanism that interrupts an owner halfway through writing a rule is the
   same failure as one that overwrites it.

The related choice is how *tightly* the region is drawn. Drawn around a value alone, the owner's
natural act — adding a bullet beside the fact he is amending — lands outside every region and is
invisible. So the block also reports **unprojected text sitting between projected regions**, by file
and line, as an advisory: it does not judge whether the line is a fact, it names it and says where
its home would be if it is. A region's own label line is excluded, or every conformant hub would
carry three permanent advisories on day one and the signal would be worthless before it was used.

#### `[ PROJECTION ]`: three errors, one advisory, and a coverage statement

| Finding | Meaning | Class |
|---|---|---|
| `DRIFT` | A region's words differ from its source in the home of record | error |
| `DANGLING` | A region names a class outside the closed set, or one whose source does not resolve | error |
| `UNBALANCED MARKERS` | An opener with no terminator, or a terminator with no opener | error |
| `MISPLACED SOURCE` | A `km:fact` region outside the home of record | error |
| `HARNESS MIRROR DIVERGENCE` | The same skill differs between two installed runtime trees | error |
| `UNPROJECTED TEXT` | A non-label line between projected regions, inside none of them | advisory |

The block **refuses rather than passes** when the home of record is missing or unreadable: there is
nothing to compare against, and a run that printed OK would be reporting a comparison it never made.

Every run states its coverage, and it never collapses into the word OK: **how many fact classes the
standard declares, how many regions were found in how many instruction files, how many were
compared, and how many declared classes are not projected in this hub at all.** The shipped template
projects three of ten, and **that is the healthy state, not a backlog**: every projection is a second
copy that must then be kept equal, so a deployment should project the fewest facts its harness
genuinely restates and no more.

#### The harness carries its skills twice

The same discipline reaches the runtime trees. A hub that installs both `.claude/skills/` and
`.agents/skills/` holds two copies of every procedure, and two copies of a procedure drift exactly as
two copies of a fact do — demonstrated by mirror directories left un-backfilled across five hubs
while their primary directories were fixed. The block compares the installed trees slug by slug, and
tolerates exactly **one** designed difference: each tree names its own harness instruction file.
Everything else differing is drift. A deployment installing one tree has one home and is not
compared. This closes, for a deployed hub, the limit stated under *Skill files declare their trigger*
— that a skill living in a hub is bound by the same rules and reached by no automated check — for the
mirror-parity half of it.

The declared-skill-set list proposed in the design was **not** taken. Its motivating evidence is
fully covered by comparing the installed trees to each other, which needs no declaration at all, and
the alternative would have added a hand-maintained manifest — the artifact class that produced the
blind spot this section is otherwise trying to narrow.

#### What this must not do

1. **Never generate an agent-instruction file whole**, and never treat the template as its superset.
2. **Never project rules, only facts about this hub.** Estate-wide bindings are inherited by
   reference; a copied rule forks.
3. **Never repair drift.**
4. **Never claim to enforce anything.** Agent scope is a declared convention, and a projection into
   an instruction file changes nothing about that. Calling this a control over agent behaviour would
   be the false assurance this standard holds to be worse than an acknowledged gap.
5. **Never let the fact-class list become an open extension point.**

#### The limit, stated rather than hidden

Proving both directions proves this check fires on the class it models, never that it models the
right class. **A fact that lives only in an instruction file, in no region and in no source, cannot
be compared with anything** — it is the same shape as a hub manifest missing a row for a governed
file, which the git-backed integrity check could never catch. Three things narrow it and none closes
it: the unprojected set is reported as a number and a list rather than passed over in silence; the
evidence base can represent absence directly, because a declared class with no region is a statable
condition; and text written beside a projected fact is named by file and line. What remains is that
**the declared list cannot be proven complete** — that the right classes were chosen is a judgement,
fixed at the interview and reviewed at the hub's cadence, and it is the same limit this standard
already states for routing keywords: the gate proves the field was filled, never that the keywords
are the right ones. `tests/test_hub_scan_canaries.sh` cases 14a–14m prove the block fires on each
class it models, refuses on evidence it cannot read, and does **not** fire on a rewrapped region, a
region's own label line, the one designed per-runtime skill difference, or a single-runtime
deployment.

### Skill files declare their trigger, not their title (added in v1.27)

A **skill** is a named procedure an agent runtime can discover and invoke (`/km-start`, `/km-intake`,
`/km-gather`). It is not an agent: it carries no scope and no identity, and it is discovered by
metadata rather than by being asked for by name. Every skill file this standard ships therefore
carries YAML frontmatter with exactly two fields:

```yaml
---
name: km-gather
description: Use when hub content needs researching from external or configured sources. /km-gather searches them, compares against current hub state, and drafts a proposal citing evidence for every change.
---
```

`name` is the directory slug and the invocation. `description` states **when to use the skill**,
in trigger terms. It is the only part of the file a runtime holds before invocation, the body loads
only once the skill is selected, so it is also the only thing on which the decision to invoke can be
made. A skill file with no frontmatter falls back to whatever its first heading says, and a heading
is a title: "Skill: km-gather, Research Sources and Propose Hub Updates" names the skill without
ever saying what would make an agent reach for it. Discovery then degrades to the operator
remembering the skill exists, which is exactly the knowledge a new session does not have.

Three properties, each with a cost that makes it a rule rather than a preference:

- **One dense sentence, roughly 15 to 30 words**, naming the trigger conditions and the invocation
  itself. Descriptions are **resident**: they occupy the context window of every session in which the
  skill is installed, used or not. The standing cost scales with the *number* of installed skills,
  not with how often they fire, so verbosity is paid for on every message of every session.
- **Written so it needs no quoting.** Keep a colon followed by a space out of the value: a plain YAML
  scalar cannot contain one, and a description that must be quoted is one naive frontmatter reader
  away from carrying its own quotation marks into the listing.
- **Placed where its residency is earned.** Per-hub skills live in the hub and are resident only in
  sessions opened there; workspace-level skills (hub initialization, cross-hub routing) live at the
  workspace. Placement, not intent, decides who pays.

Compliance is mechanical: `tests/test_skill_frontmatter.sh` fails when any shipped skill file lacks
frontmatter, lacks either field, carries a `name` that is not its directory slug, carries a
description that would not survive a plain-scalar parse, or carries one outside the word budget; it
also fails when the same slug's frontmatter has drifted between the trees it ships in. Since v1.55 it
also fails when the block is **not closed**, when the block is closed by a marker other than `---`,
when a required key is declared **more than once**, or when a line inside the block is not something
a mapping would hold. Those four are one defect: a reader that confirms the opening delimiter and
then stops at end of file cannot tell a block from a document, and a reader that takes the first
match of a key silently discards a contradicting value another reader would have used. The
delimiter rule alone is not enough, and this is the part worth carrying into any check of a
delimited block: every shipped skill file contains `---` horizontal rules in its prose, so deleting
the real terminator merely moves the closing delimiter down the document, and the block swallows the
body while both keys stay present and unique. What makes the swallowed prose visible is requiring
every line inside the block to read as a mapping entry, a continuation, a comment or a blank. **One
gap is registered rather than closed:** the check does not require the block to carry *only* the two
fields, because refusing an extra key is a policy decision about what a skill file may carry rather
than a defect in how the check reads its input, and settling it inside a repair to the reader would
settle it silently. **Since v1.58 (drafted and unpublished; this material binds nothing
until its own owner push) the three value rules are applied to the folded value rather than to its
first physical line.** `description` is a plain YAML scalar, so every more-indented line following it
belongs to it, and a check reading only the first line measured a fragment: a description whose first
line was 13 words and whose folded value was 97 passed the residency budget, and an indented line
placed before any key — continuing nothing at all — was skipped as though it continued something. The
block is now walked with state, and the general rule this earns is stated under §"A check that reads a
compound value validates its parts". Each rule is
proved against a synthetic violation, so a check that has stopped firing is itself caught. **Stated
limit:** the test covers the skills this standard ships. A skill written locally in a deployed hub is
bound by the same rule and reached by no automated check, so it is verified at review. Half of that
limit is closed in a deployed hub by `[ PROJECTION ]` (v1.32), which compares the installed runtime
trees to each other: it catches a skill updated in one tree and not the other, and still says nothing
about whether a locally written description names its trigger. `tests/test_skill_frontmatter.sh`
compares frontmatter and stops there, and `[ PROJECTION ]` compares bodies only inside a deployed hub
and only between the two runtime trees, so the copy this repository advertises is compared with
nothing. That gap is closed by the subsection below (added in v1.43).

#### One canonical copy, and the mirrors are mirrors (added in v1.43)

Every per-hub skill this standard ships exists in three places: `skills/<slug>/SKILL.md`, and a
mirror in each of the two runtime trees the hub template installs. Workspace-level skills, hub
initialization and cross-hub routing, ship in the canonical location alone and have no mirror to
diverge from. Three copies of one procedure drift exactly as three copies of one fact do, and the
copy that drifted here was the one that matters most.

**`skills/<slug>/SKILL.md` is the canonical copy.** It is the location the README advertises as
distributable, the location an adopter and a fork reach first, and the reference the frontmatter
check already compares against. The two runtime trees are **mirrors of it**, and a reader asking
which copy is authoritative is answered here rather than left to infer it from a README table.

Four obligations follow, and the first three are mechanical.

1. **Every copy carries the same governed instruction body.** The governed body is everything after
   the closing frontmatter terminator. Two copies with identical frontmatter and different
   instructions are two different skills wearing one name, so parity is established on the body and
   never on the frontmatter alone.
2. **Exactly one difference is permitted, and it is documented before it is permitted.** Each runtime
   tree names its own harness instruction file, which is the same single substitution `[ PROJECTION ]`
   tolerates inside a deployed hub. A hub and this repository therefore tolerate one list rather than
   two. Any other difference is drift. A tolerance list that widens to fit whatever the tree happens
   to contain converges on tolerating everything, which is a check that cannot fail.
3. **The check refuses rather than passes on anything it cannot evaluate**: a copy it cannot read or
   whose body it cannot delimit, a mirror with no canonical copy behind it, a canonical location
   holding no skill, or any run that would report success having compared nothing. It states its
   coverage on a passing run, in slugs found, pairs compared and substitutions applied, and a
   recorded pass that does not state those is void rather than clean. `tests/test_skill_distribution_parity.sh`
   is the instrument, and it is runnable against any tree so it can be pointed at an unrepaired one.
4. **Direction of repair is decided by reading the content, never by the authority of the location.**
   This one is a judgement and is deliberately not mechanised. When copies diverge, the copy carrying
   the stronger protection is the one the others are raised to, even when that copy is a mirror and
   the weaker one is canonical. Reversing that produces three copies in perfect parity and three
   deployments able to publish a retired fact, which is a gate certifying the wrong thing.

**Why the gate is a companion to the frontmatter check rather than an extension of it.** The two
model different classes and should fail separately: one models discoverability, which a runtime reads
before invocation, and the other models distribution, which is what a deployment installs. The parity
check also owes a coverage line of its own, and it must run against an arbitrary tree, which is how
it is proved against the divergence it was written for rather than against a synthetic likeness. The
cost is stated: two instruments now walk the same three trees, and a change to the distribution
layout touches both.

**The limit, stated rather than hidden.** Parity proves the copies agree. It never proves they are
right, because three copies of an unsafe body are in perfect parity, and that is why obligation 4 is
written as a judgement and not as a rule the check enforces. The tolerated substitution is a real
hole one token wide, by construction: a skill whose bodies genuinely differ only in the harness
instruction-file name cannot be distinguished from one where that difference is drift. And a skill
written locally in a deployed hub is still reached by no check here, which is v1.27's limit
unchanged, narrowed for the mirror half by `[ PROJECTION ]` in the hub's own scan.

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

## Editions and the run/evolve boundary (added in v1.39)

This section implements `rfcs/RFC-006`. It names one structural line already latent in a tiered
deployment, maps every component to one side of it, and defines two editions as profiles over the
**same** standard version. It is boundary doctrine only: it adds no schema, no check, and no
mechanism, and it changes nothing an existing hub or deployment does.

### The run/evolve boundary

A deployment's tiers divide by one intent: some **consume and operate** a fixed standard, and some
**invent and author** the instruments and the standard itself. That division is the boundary.

- **Run-set** = the tiers and components that consume a published standard and operate a live estate:
  the Reader, the Supervisor (including the queue, the cockpit, and the routines it runs), the hubs,
  and the **pinned canonical standard** the whole set conforms to. The run-set reads the standard as
  authoritative and does not author it.
- **Evolve-set** = the tiers that invent instruments and author the standard: the Machinery tier,
  which invents and battle-tests tooling, and the Standard-Steward tier, which authors, evolves, and
  may fork the standard and runs the leakage guard. The evolve-set writes what the run-set consumes.

The line is the same two-flow model a tiered deployment already runs: **consumption** (standard to
hubs, the standard authoritative, the hubs conform) and **invention and harvest** (deployment to
standard, the deployment authoritative, the standard brought up to it at agreed intervals). The
run-set is the consumption flow; the evolve-set is the invention flow.

The mapping is total: every component maps to exactly one side, and none straddles it.

| Component | What it does | Set | In Consumer / Run edition | In Builder / Full edition |
|---|---|---|---|---|
| **Reader** | Read-only consumption of hub knowledge (query, brief, present); authors nothing | Run-set | Yes, once harvested (see *The Reader prerequisite*) | Yes |
| **Supervisor** | Routes, runs routines, owns the owner queue and the cockpit, operates hubs | Run-set | Yes | Yes |
| **The cockpit** (`components/km-cockpit`) | The owner's decision and answer surface, operated by the Supervisor | Run-set | Yes | Yes |
| **Hubs** | Hold governed knowledge, admit and reconcile under their own governance | Run-set | Yes | Yes |
| **The pinned canonical standard** | The conformance target the run-set reads as authoritative | Run-set | Yes, pinned to a published version, consumed read-only | Yes, and MAY be evolved or forked |
| **Machinery** | Invents and battle-tests tooling before it is harvested | Evolve-set | No | Yes |
| **Standard-Steward** | Authors, evolves, and may fork the reusable standard; runs the leakage guard | Evolve-set | No | Yes |

Three properties of the mapping are stated rather than left implicit:

1. **The pinned standard is in the run-set on the consume side, not the author side.** A run-set holds
   the standard the way a hub holds it: pinned to a published version, read as authoritative, never
   authored. The same artifact appears in both editions, and only the Builder edition carries the
   authority (through the Standard-Steward) to change it.
2. **Operating a hub is run-set; inventing the instrument a hub uses is evolve-set.** The Supervisor
   running a routine is consumption. The Machinery tier building a new routine is invention. A
   deployment can do the first forever without ever doing the second, which is what makes a Consumer
   edition coherent.
3. **The cockpit is a run-set component even though it is a reusable standard component.** It ships
   with the standard, but a deployment operates it (Supervisor) rather than authors it. Changing the
   cockpit component itself is Standard-Steward work and therefore evolve-set.

### Two editions, each a profile over one standard

Both editions run the **same** published standard version. An edition is not a variant of the
standard, not a branch, and not a second normative surface. It is a **profile**: a declared statement
of which side or sides of the boundary a deployment installs and is authorized to act on. This keeps
editions inside the standard's existing profile-and-overlay machinery.

- **Consumer / Run edition** = the run-set, pinned to a published standard version. It consumes
  releases and operates a live estate: it reads, routes, runs routines, operates hubs, and presents
  through the cockpit. It **cannot author**: it carries neither the Machinery tier nor the
  Standard-Steward tier, and it holds the standard pinned and read-only. A Consumer deployment that
  wants a standard change requests it upstream, because it has no evolve-set to make it in.
- **Builder / Full edition** = the run-set **plus** the evolve-set. It does everything a Consumer
  edition does, and additionally can invent tooling (Machinery) and evolve or fork the standard
  (Standard-Steward). A Builder deployment that forks the standard becomes its own steward of that
  fork, with the harvest and leakage-guard discipline that role carries.

The editions are strictly nested: the Builder edition is the Consumer edition plus the evolve-set,
with no component removed and none altered. The nesting is what makes the boundary safe to draw:

- **Nothing a Consumer edition does changes when the evolve-set is added.** A hub operates the same, a
  routine runs the same, the cockpit presents the same. Adding the evolve-set adds the authority to
  invent and author; it does not reach back and change consumption behaviour.
- **No deployment is forced into an edition.** A deployment declares which edition it runs; the
  standard defines the two shapes and binds neither on. This is the same no-cost-to-decline discipline
  the standard applies to its other optional layers: a deployment that declares nothing about editions
  runs exactly as it does today.
- **Existing hubs change nothing.** Editions are a packaging concept above the hub. A hub does not
  know which edition it runs inside, and no hub file changes because an edition is declared.

### The boundary asserts no license

This is a hard requirement of this section. The standard **asserts no license, price, or commercial
term.** This section defines only the boundary. It draws that boundary cleanly enough that an owner
**MAY** later attach a licensing or commercial policy at the line, for example treating the evolve-set
as owned or paid, **without the standard itself encoding any such policy, and without any structural
change.** The line sits in the same place, the component mapping is identical, the two editions are
defined identically, and a Consumer deployment behaves identically, whether or not any policy exists.

A policy, if an owner ever writes one, binds only the parties who accept it and lives only in the
owner's own overlay or business terms, outside the canonical standard. The canonical standard remains
a license-neutral description of a boundary, and the licence state of the repository that carries it
is recorded in the note below. This section encodes no
license, and any later version implementing editions carries no price-shaped, license-shaped, or paid-tier
field anywhere in the canonical surface.

**This repository is licensed under the Apache License, Version 2.0, and the fact is recorded here
because this is where the standard speaks about licensing (added in v1.53).** The decision v1.49
recorded as open is now made.
The deployment owner selected Apache-2.0 and confirmed that he is the author and copyright holder.
`LICENSE` at the repository root carries the complete licence text, `NOTICE` carries the attribution
notice required by its Section 4(d), and `README.md` states the grant, what an adopter may rely on,
and that the Section 4 conditions attach to redistribution rather than to use or private
modification. The grant is in force, so a reader of this repository now holds a licence where until
v1.53 they held a statement of direction. Apache-2.0 was selected for one property above the others:
it carries an **express patent grant**, which a specification other organizations implement needs
and which a bare permissive licence does not give.

**What "unmodified" means about that file, stated precisely because it was not (narrowed in v1.56).**
The **terms**
are the canonical text and carry no edit: Sections 1 to 9, the preamble and
the end-of-terms line are byte for byte what the licensor publishes. **One line differs**, and the
Appendix is what directs it: the Appendix boilerplate's `Copyright [yyyy] [name of copyright owner]`
is instantiated with the copyright line, which is the act the Appendix exists to be used for.
Anyone can reproduce that: restore the placeholder on that one line and the file's SHA-256 is
`cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, the published digest of the
canonical text. Saying the file is *unmodified* without that sentence invites a reader to expect a
byte-identical copy and to find a difference the repository did not explain, and an unexplained
difference in a licence file is the one place a reader is entitled to stop trusting the rest.
Nothing in this paragraph changes the grant; it describes the artifact that carries it.

**Two different things are called a licence here, and they are separate facts about separate
objects.** The **repository** carries a licence, which is what the two paragraphs above record. The
**standard** asserts none, on any deployment, which is the hard requirement at the head of this
section and is unchanged in every word. Licensing this repository puts no licence, price, or
commercial term on any hub, estate, or deployment that adopts the standard, and it changes no line of
the boundary, no row of the component mapping, and nothing a Consumer deployment does. What an
adopter's own hubs, knowledge, and deployment are licensed under is the adopter's affair, and this
standard says nothing about it. Recording the state of one repository is therefore not the license
assertion this section forbids; if this note ever began to read as one, the note would go and the
doctrine would stay. Nothing in this note is legal advice.

**The state before this one, kept as the record of it.** Until v1.53 no `LICENSE`, `COPYING` or
equivalent file existed, so default copyright applied to this repository and the intended grant was
not in force: free adoption was the owner's stated intent, and a reader could rely on that intent as
direction and never as permission. Choosing a licence, or choosing not to, was an open decision that
belonged to the deployment owner, and no maintainer of this standard made it on his behalf. It was
made by him, and this note records it rather than deciding it.

### The key doctrine: the authority crosses, the artifact does not

The pinned canonical standard sits in the run-set, on the consume side, in **both** editions. The
same artifact is present whether a deployment consumes or authors. What the Builder edition adds is
the **authority** to author that artifact, carried by the evolve-set (the Standard-Steward). Stated as
one line: **the artifact does not cross the boundary, the authority does.** An edition is therefore a
statement about who may author, not a statement about which standard is installed.

### The Consumer edition is RFC-004 Part III reading (c)

RFC-004 Part III examined "multi-tenancy" and found reading **(c)** to be *several independent
deployments of the standard, many organisations each running their own estate, one maintainer serving
all*, which it judged a bounded gap rather than a layer. The **Consumer / Run edition is the concrete,
bounded form of reading (c)**: a fleet of Consumer-edition run-sets, each pinned to a published
version, each consuming releases from one upstream steward, none carrying an evolve-set, with the one
maintainer serving all being a Builder edition (or the canonical steward) authoring the standard the
fleet consumes. Readings (a) and (b) are untouched and remain where RFC-004 left them.

### The Reader prerequisite: a tracked gap, not a defect

The Consumer edition's read-only consumption tier, the Reader, is **not in the canonical standard
today.** It is a deployment invention that has never been harvested; the canonical `STANDARD.md` uses
the word "reader" only in its ordinary sense and defines no Reader tier, agent, or component. v1.39
defines the editions boundary and the two edition shapes, all of which are complete without the
Reader. The Consumer edition's **run-set is completed** by harvesting and genericising the Reader into
the standard, which is the separate effort designed in `rfcs/RFC-007` (its own version, on the
reference-deployment exemption, under the leakage guard).

Until that harvest lands, a Consumer edition can be **defined** (this section does that) but not fully
**shipped**, because one run-set component does not yet exist in generic form. This is a known,
tracked gap, not a defect: the boundary and the two editions are complete now, and the Consumer
edition's completeness waits on the named Reader harvest.

**Update (v1.41):** that harvest has landed. The Reader tier is now defined
in the standard under *The Reader tier* below, implementing `rfcs/RFC-007`, so the Consumer edition's
run-set exists in generic form and the tracked gap named here is closed. The v1.39 account above is
left as the historical record of the gap.

### What this section does not do

- It asserts, encodes, or implies no license, price, or commercial term. It draws a boundary only.
- It forces no deployment into an edition; a deployment that declares nothing runs as it does today.
- It changes nothing any existing hub does, and it forks the standard into no second normative surface.
- It adds no schema, check, or mechanism. The boundary is documentation doctrine, and RFC-006 states
  that no new instrument is strictly required by the boundary itself. An optional edition declaration
  in the organization profile is a possible later addition, deliberately not made here.
- It claims no enforced control. Tier separation is convention stated as such, the same posture the
  standard takes toward agent scope; describing the run/evolve line as a technical control over what a
  deployment can do would be a false assurance.
- It does not implement the Reader (`rfcs/RFC-007`) or the routines (`rfcs/RFC-005`); it references them.

## Reader tier: read-only consumption (added in v1.41)

This section implements `rfcs/RFC-007`. It defines the **Reader**, the read-only consumption tier the
editions section named as the one run-set component missing from the standard in generic form, and the
**scoped reader**, the reader locked to a declared subset of hubs that is the per-compartment and
per-tenant consumption face of RFC-002 and the Consumer edition (RFC-006). It is a tier a deployment
MAY adopt; a deployment that runs no separate reading context runs exactly as it does today.

### What a Reader is

A Reader is a context whose whole purpose is to **produce outputs from the estate without authoring the
estate.** Reading the estate and building the estate are different sessions with different contracts,
and the Reader makes the consumption flow into a session type decided by which context was opened rather
than by anything anyone remembered. A Reader answers questions and produces briefs, drafts, analyses,
comparisons, and summaries drawn from committed knowledge. It is the consumption face of the run-set.

### The Reader contract

A Reader context is governed by a contract stated in full in its own governing file, not by a remembered
rule. The contract has four clauses:

1. **It produces outputs; it does not change the estate.** It writes results into its own `outputs/`
   area, or wherever the owner directs, and never into a hub, the semantic layer, or the registry. A
   stray write into a governed tree becomes an uncommitted change the next build session's scan reports
   as an integrity error, so the read/build split is protected by keeping writes out of the record
   entirely.
2. **The consumption acts are out of scope, listed rather than implied.** No proposals, no directives,
   no dispatching hub agents, no queue rows, no corrections notes, no commits, no running any hub or
   estate scan, no refreshing a handover, no regenerating an index. A Reader that starts doing these has
   stopped being a Reader.
3. **Reading anything readable is in scope.** History is often the fastest answer to "when did we decide
   this and what did it replace," so the whole readable tree, including version history, is the Reader's
   to consult.
4. **A defect found is noted in one line and left.** A stale fact, a broken link, a contradiction: the
   Reader states it and carries on answering the question it was asked. It does not investigate, design a
   fix, or open the machinery. This is the reading-side twin of the build tier's discipline, and it is
   the clause that keeps the read/build split from eroding one convenience at a time.

### The reading subset of the standard that still binds

A Reader is not exempt from the standard; it is bound by the subset of it that governs reading rather
than writing, and that subset is stated in full rather than by pointing at the whole corrections
registry, because most estate rules govern acts a Reader cannot perform. The reading subset:

- **The evidence hierarchy binds.** Curated hub documents and the semantic layer outrank raw
  transcripts; a hub-produced artifact is never evidence for itself; the first-order source is read
  before its contents are characterised, because a summary compresses away the distinction being asked
  about.
- **The home of record is consulted first.** Hubs and the semantic layer frame a topic before any
  transcript does. An answer is never built primarily from a raw source when a hub already frames it.
- **Every claim carries its provenance where it appears**, not in a source list at the end. A claim
  whose origin cannot be stated is reported as such rather than asserted.
- **Restricted content is never surfaced** in anything that leaves the session, and a digest inherits
  the most restrictive marking of what it summarises. A marking that lives only in prose still marks the
  content, even though no instrument sees it.
- **Identity is resolved, never constructed.** A person's name is resolved against the semantic layer
  before it is written, and a contact detail is never built from a name.
- **Voice binds anything the owner would send or sign**, and estate separation binds absolutely: a
  Reader never references an unrelated estate.

### The marker, the governing file, and the outputs area

A Reader must be recognisable as a Reader by inspection, not by memory. A Reader context declares its
identity through three things, shipped as the reader scaffold under `template/reader/`:

- **A tier marker** at the context root, the file `.km-tier`, whose first line is the word `reader`.
  A scoped reader additionally declares its scope in this file (see below). The marker is the
  machine-and-human-readable statement that this is a consumption context, the twin of the deployment
  manifest a hub carries, and opening the directory is what selects the contract.
- **A governing context file** stating the Reader contract in full, the way a hub's agent-instruction
  file states the hub's. The scaffold ships this as `CLAUDE.md` with an `AGENTS.md` mirror, on the
  standard's framework-agnostic convention; this file, not a remembered rule, is what binds the session.
- **An `outputs/` area** for results, and an optional `correction notes/` area for the one-line defects
  the Reader is permitted to record and hand back.

The marker is a **declaration of identity**, not an enforced control. What it buys is that the contract
is selected structurally by which context was opened, which is the whole point of a separate tier.

### The reader skills a Reader uses

A Reader's skills are the consumption skills: those that read committed knowledge and produce an output,
carrying none that author, propose, route, or operate. Of the skills the standard ships, **`km-brief`
is the Reader skill** and it ships today: it reads committed entity notes and produces a memo, briefing,
or status report without touching the record. It is the one shipped skill a Reader can use without
violating the read-only contract.

A dedicated query or answer skill, for the Reader's most common act ("what do we know about X," "what
did we decide and why"), is **deferred to a later harvest**, and is not added here. The Reader answers
that act through `km-brief` and direct query of the home of record, carrying provenance per claim and
respecting restricted markings by the reading subset above. A reader-safe form of research gathering
(the read half of a gather that stops at an answer rather than authoring a proposal) is likewise
deferred, and whether it is a mode of an existing skill or a new one is a harvest decision, not made
here. Naming these as deferred keeps a later session from reading "the Reader mostly ships" off the
presence of `km-brief`.

### The scoped reader

The reusable, valuable mechanism is the **scoped reader**: a reader restricted to a declared subset of
hubs and nothing else. A scoped reader is a Reader (the whole contract above binds it unchanged) plus a
**scope declaration**:

- **The scope is a named, closed list of hubs** the reader may read, declared in the reader's `.km-tier`
  marker on a `scope:` line as a comma-separated list of hub names. Closed on purpose, the same
  discipline a closed fact-class list applies: an open scope (`*`, `all`, or an empty list) makes the
  boundary claim unstatable and is not a scoped reader.
- **Every member of the list is closed, or the list is not.** The scope is judged token by token and
  never as one whole value. An open token is an open scope wherever it sits, so `*, hub-alpha` is
  rejected exactly as a bare `*` is; and an empty entry, a duplicate, or a token that is not a well
  formed hub identifier (the standard's own hub slug) is rejected rather than absorbed into its
  neighbour. A declaration that cannot be evaluated at all, such as a marker declaring `scope:` twice,
  is refused rather than passed, because a check reporting by absence must never report *could not be
  evaluated* as *nothing found*.
- **Everything outside the scope is refused, not filtered.** A question needing material outside the
  declared hubs is answered "this is out of scope for this reader" and stopped, rather than answered
  partially from whatever happens to be visible. The contract is stated firmly precisely because the
  surrounding material may or may not be physically present.
- **The scoped reader ignores the scoped hub's own build files.** A hub carries its own agent
  instructions, scan, and hooks for the people who maintain it; a scoped reader is a reader, not that
  hub's agent, and its contract is the reader's context file, not the hub's. This keeps a delegated
  reader from being captured by the instructions of the thing it was sent to read.

### Where the scoped reader connects: compartments and the Consumer edition

The scoped reader is the consumption-side counterpart of two mechanisms the standard has already
designed, and stating the connection is most of its value:

- **RFC-002 compartments.** A compartment is hub-level access: each hub declares an owner, an audience,
  and a boundary, with cross-compartment flow default-deny. A scoped reader is **how a compartment is
  consumed**: the declared hub subset of a scoped reader is the read-side projection of a compartment's
  membership. The two are the same boundary named from opposite sides, one governing membership between
  hubs and the other governing a reader's view across them. A scoped reader's declared hub list is a
  local declaration that lives with the reader, not in the canonical standard, exactly as a
  compartment's audience and boundary values are hub-local content.
- **RFC-006 the Consumer edition.** The Consumer edition is the run-set pinned to a published version. A
  scoped reader is **how a single Consumer deployment presents a per-tenant or per-audience view**: one
  estate, several scoped readers, each locked to the hubs one consumer is entitled to see. This is the
  bounded, honest form of per-audience access: one operator's estate showing different consumers
  different compartments through scoped readers, not several mutually invisible operators, which is a
  separate and still-unclaimed layer.

### The honest isolation boundary

This is the load-bearing honesty of the tier, stated plainly so no later session mistakes a convenience
for a control. The standard says, deliberately and repeatedly, that agent scope is convention and not an
enforced control, and that a false assurance is worse than an acknowledged gap. A scoped reader is
subject to exactly that limit:

- **The scope declaration is a convention.** A reader's marker naming three hubs does not, by itself,
  prevent the reader from reading a fourth if the fourth is present and readable. The declaration binds
  behaviour the way every agent contract in the standard binds behaviour: by being the contract the
  context reads, not by being a wall the filesystem enforces.
- **Isolation becomes real only when the hosting makes it real.** Genuine isolation between a scoped
  reader and the hubs it may not see comes from **what is physically present and permitted**: the other
  knowledge areas simply not being in the shared workspace, and write commands denied by the local host
  configuration. The reader scaffold ships a host permission file that denies git write commands as one
  such second-layer control, but that denies writing, not reading; it does not wall off a tree that is
  present. Real read isolation is separate installations, separate storage, or separate credentials,
  which are decisions the hosting makes and the standard does not perform.
- **The standard's contribution is the honest description of where the boundary is and is not.** The
  standard defines the scoped-reader contract, the closed scope declaration, and the refuse-out-of-scope
  behaviour, and states exactly which part of that is convention (all of it, absent hosting enforcement)
  and which part is real (only what the hosting enforces). That honest description is the deliverable,
  and it is worth shipping precisely because it stops a deployment from reading "scoped reader" as
  "isolated tenant" when nothing underneath it enforces isolation.

The standard therefore **refuses to describe a scoped reader as an enforced tenant boundary.** A scoped
reader whose only isolation is its own prose is a reader that will read whatever is put in front of it;
presenting that as tenant isolation to a third party would be the false assurance the standard holds to
be worse than an acknowledged gap. The standard describes the boundary honestly and points at the
hosting for enforcement; it does not pretend the prose is the enforcement.

### Relation to the editions, and what it costs to adopt

The Reader is the run-set component RFC-006 named as absent, and this section is the harvest that lets a
Consumer edition be shipped rather than only defined. What it costs a deployment:

- **To run a Reader, once:** one Reader context with its marker, its governing contract file, and its
  `outputs/` area, plus whichever reader skills it uses. A deployment that declines runs as today.
- **Per scoped reader, once:** a scope declaration naming the closed hub subset, and a hosting decision
  about whether the isolation is real (separate install, storage, or credentials) or convention only.
  The standard states which it is; the deployment chooses.
- **Ongoing:** nothing. A Reader consumes; it adds no maintenance to any hub, and a hub does not know a
  Reader is reading it.

### What this section does not do

- It claims no enforced isolation. A scoped reader's isolation is convention unless the hosting enforces
  it; describing the scope declaration as a technical tenant boundary would be a false assurance.
- It does not let a Reader author the estate. A Reader produces outputs into its own area and never
  writes a hub, the semantic layer, or the registry, and never proposes, dispatches, routes, commits, or
  runs a scan.
- It does not redesign the editions (RFC-006) or the compartments (RFC-002); it references both and
  defines only the Reader tier and the scoped reader that consume them.
- It does not overstate what ships. Only `km-brief` is a Reader skill today; the dedicated query skill
  and reader-safe gather are named as deferred.
- It forces no deployment into running a Reader, and it ships no reference deployment's specifics: the
  scaffold is the generic tier class, carrying no deployment's hubs, proper nouns, paths, or people.

## Version history (added in v1.10)

The version ledger. **A published version number is never reused.** Before publishing, read this
table *and* `git log`, take the next unused number, and add the row in the same commit that changes
the text. This is not bookkeeping: two sessions each publishing "v1.8" leaves two different standards
answering to one name, and every hub that pinned that version now points at an ambiguity. That
happened once (see the v1.9 row) and the ledger exists so it does not happen twice. Adding the row
is one step of the ritual and not the whole of it; see "Publishing a version" below (added in
v1.42).

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
| v1.20 | 2026-08-16 | Drafted 2026-08-14; published 2026-08-16 with v1.22. The owner queue (Supervisor tier): one machine-parseable decision surface (`QUEUE.md`) that every proposal, escalation, and ask must register on to count as surfaced to the owner; three tiers (A never defaults; B auto-applies its recommendation after a veto window, with identity, money, restricted content, deletions, and client-facing surfaces never tier B; C never asks); routine decision-halt above a queue cap, checked at the **start** of a run and with escalation classes exempt; a batched Q&A clearing skill (`/km-clear`) bound by reconcile-before-ask; one weekly owner sitting with a protected walkthrough slot; routine briefs demoted to machine-facing with a session-triage read flag; hub inboxes counted as queue inventory. Adopted after an estate reached roughly 40 open items across 8 owner-facing surfaces, with routine decision production outrunning one owner's consumption and re-asks spending owner attention on already-decided items. |
| v1.21 | 2026-08-16 | Drafted 2026-08-14; published 2026-08-16 with v1.22. The `[ RESTRICTED ]` name block is narrowed to what the marker actually restricts. Since v1.16, a `sensitivity: restricted` line anywhere in a note made the note's NAME an error on every outbound surface, so a file with one restricted section could never be named as a proposal target: the governed route to changing such a file was blocked by the check meant to protect it. Now a marker in frontmatter still restricts the whole note, name included; a marker in the body restricts the section it opens, whose verbatim text (lines of at least 16 characters, up to the next heading at the same or a higher level) is blocked on outbound surfaces while the note's name and path stay nameable. Stated trade-offs: a body-marked note's existence and name become disclosable, and verbatim-line matching does not catch paraphrase or very short lines, so a note whose name or existence is itself sensitive must be marked in frontmatter. `build-indexes.sh` continues to exclude both forms from generated indexes. `tests/test_restricted_lint.sh` proves both sides of the narrowing and that the frontmatter name block still fires. Derived from an estate incident (owner-adjudicated "fix", 2026-08-14) in which a hub file with one restricted section became structurally un-nameable in `changes/` proposals. |
| v1.22 | 2026-08-16 | The record boundary (Rule 6): records stay in systems of record; hubs hold claims about records, with resolvable pointers. Four crossing laws — claims cross, records don't; aggregates cross, line items don't; existence crosses, contents don't; an unavoidable copy is the classified extract with lineage. Optional `accessClass` frontmatter field (`public \| internal \| restricted \| record`, default `internal` when absent), with propagation (derived-from-restricted inherits restricted), the declassification rule ("aggregation declassifies; extraction does not"), and classification-aware `[ RESTRICTED ]` enforcement: a restricted-class note's body text is blocked verbatim on outbound surfaces while its name stays nameable (existence crosses; the `sensitivity: restricted` frontmatter marker remains the mechanism for names that are themselves sensitive), and restricted-class notes are excluded from generated indexes. Two optional entity types: `SourceSystem` (`sources/systems/`, grounded in `dcat:DataService`) — the per-system contract behind the per-source date register — and `Claim` (`claims/`, proprietary) — a settled fact promoted to its own lifecycle and evidence chain, with reconciliation remaining the adjudication process and promotion never mandatory. Optional bitemporal fields `validFrom`/`validUntil`/`recordedAt` (adopting the Semantica mining rationale's priority candidate). An optional inbound connector section mirrors the outbound MCP query surface; the manual inbox + date gate + reconciliation are named as the gateway's reference implementation, and detection/extraction/freshness automate while classification and resolution authority stay with the owner. Full rationale, migration notes, implementation notes, and open questions in `rfcs/RFC-001-sor-gateway.md`. Derived from an engagement organizing a partner organization's complete internal knowledge export (~12,000 files) into a governed hub, where the four crossing laws were discovered operationally rather than designed. |
| v1.23 | 2026-08-16 | **DRAFT — awaiting owner push.** Stations, compartments, and the resolution plane (`rfcs/RFC-002-stations-compartments-resolution.md`; every ruling provenance-tagged owner-ruled / delegated / directional). The resolution plane: record-class data is never stored in hub git — the hub holds the pointer and the gateway resolves it at query time, clearance-checked, audit-logged, nothing persisted; the access event may be recorded as a claim, the data may not (git permanence cannot honor erasure obligations). Three planes: knowledge (git), resolution (gateway runtime), scratch (`_scratch/`, git-ignored, wipeable, stated lifetime — erasure by construction). Hub species as two independent manifest axes in `km-deployment.md`: `station` (org-core \| domain \| engagement \| publication) governs intake, `exposure` (never-public \| compartment \| counterparty \| public) governs output; defaults `domain`/`compartment` when absent, enums validated by `[ DEPLOYMENT ]` only when present; the crossing laws become station-transition rules — build at the station, publish at the exposure — and org-core hubs version at the tempo of decisions, not of data. Hub-to-hub access is compartmented, not leveled: each hub declares owner, audience, and boundary; cross-compartment flow is default-deny, Supervisor-mediated (resolving RFC-001 open question 1). Scale invariance: existence crosses, contents don't — at every altitude; the Supervisor holds claims about hubs, never hub contents. Redaction with tombstones enters as the supersede-never-rewrite doctrine's explicit boundary condition. Federated SoR registry: in multi-hub estates `SourceSystem` notes live at the Supervisor with per-hub subscriptions, single-hub placement unchanged (partially resolving open question 2); query-time gating is subsumed by the resolution plane (open question 3). |
| v1.24 | 2026-08-17 | Drafted and published 2026-08-17 (owner push, with v1.25 and v1.26). The owner-surface train, from an operational build (2026-08-14→17) on a second estate. (1) **Three surfaces named** — audience / owner / practitioner — with the owner surface promoted to a deployment component: decisions accumulating where nobody opens them is how a deployment dies. (2) **The KM Cockpit side component** (`components/km-cockpit/`): the proven owner decision surface shipped exactly as deployed (v3.8 behavior — brief-gated cards, five truthful proposal lifecycle states, supervisor-actions request channel, per-hub views, activity audit trail), genericised by **configuration only** — a deployment manifest (estate root, queue path, hub-registry path, port, organization name, state dir) and a registry-derived hub map; normative contract in its `SPEC.md`, including *surface-never-a-pen* and *decision surfaces are unpublished by default* (localhost-bound, never beside a reading site, shared access an explicit owner decision with clearance and audit). Single-hub mode binds the same component to a hub-local queue file — identical data contract, so the supervisor threshold (v1.26) is a manifest re-point, proven by `tests/test_km_cockpit.sh`'s single-hub round-trip. (3) **The owner interaction contract**: questions exist only as registered artifacts (links, zero-context, why-owner, recommendation-first), mechanical dedup, automatic two-session nudges, lifecycle gates, the fixed NEEDS YOU / DONE / FYI output shape, equal answer channels. (4) **The projection contract**: four gates on every consuming surface (committed at HEAD, lifecycle-active, within clearance, manifest-listed) plus renderer normalization. (5) **The staleness rule**: a recorded state contradicted by time publishes the contradiction and names who can resolve it, never a silent correction. Trade-offs recorded: the queue stays hand-maintained-file-first exactly as deployed — deriving queue content from what the estate's files already know is a roadmap note only (one estate, one day, medium confidence; SPEC.md §9); desktop notifications are macOS best-effort; keyword hub-attribution is approximate until the queue's machine block gains an explicit hubs field. |
| v1.25 | 2026-08-17 | Drafted and published 2026-08-17 (owner push, with v1.24 and v1.26). The `/km-init` purpose interview: a hub's definition is **produced by a structured Q&A, never assumed** — purpose and scope guard (in **and** out), audiences each mapped to one of the three surfaces, the **knowledge-vs-records boundary elicited source by source** (the Rule 6 access vocabulary existed; the conversation that applies it did not), evidence expectations, routing keywords, and owner cadence — the answer-surface question asked recommendation-first with **a deployed cockpit as the recommended default** (owner amendment, 2026-08-17: the owner surface is what decides whether a deployment survives); planning the surface is mandatory, deploying it remains an explicit act. Outputs: the scope guard, the hub manifest (`km-deployment.md` → Hub definition, `initiation-interview` date, `routing-keywords`), and the supervisor registry row where a tier exists. **The quarantine gate is mechanical:** `[ DEPLOYMENT ]` in `hub-scan.sh` errors on a binding with no interview date (date-shape checked, so an unsubstituted placeholder cannot pass), and an uninterviewed hub never scans green; `tests/test_hub_deployment_binding.sh` carries the canary. Delivery guidance in `km-init` Step 8: name what reconciliation finds during onboarding out loud (a selling point, not only a control), and a **directional, run-once** bulk-corpus intake shape (catalogue → boundary interview → domain split → briefed parallel readers → per-domain extract → entity layer) recorded as guidance, deliberately not yet a normative pattern. Trade-off recorded: existing hubs fail the gate until the interview is backfilled at adoption — deliberate, that is the gate working. |
| v1.26 | 2026-08-17 | Drafted and published 2026-08-17 (owner push, with v1.24 and v1.25). The supervisor at the second hub, from the owner's recorded ruling: **hub count > 1 advises creating the Supervisor tier**, replacing the "share a source or an entity" trigger — the count is the threshold, not overlap, because estate-level state (the owner queue, cross-hub decisions) has nowhere correct to live inside a hub. What makes the rule followable: (1) the **minimum tier** — hub registry + estate queue + inbox + own git history, nothing more, with every omitted capability (routing, semantic layer, escalations, evidence standard, estate corrections, decision surface) carrying a **named adoption condition** in a table that ships in the tier's own template README; (2) **bind-only-what-exists** — a hub's estate-binding section names only files actually present at the tier (`km-init` prunes at scaffold time; the scan's `[ CORRECTIONS ]` block already behaved this way), with a new minimum-tier bullet binding the registry and queue; (3) **detection at creation** — `/km-init` finding an existing hub first detects an already-deployed cockpit and asks whether the new hub joins it (no tier yet: the yes rides the tier-minting, estate queue absorbing both hubs and the manifest re-pointing; tier present: the registry row alone suffices, and the interview states which path applied), then **recommends** minting the minimum tier, recommendation-first (owner amendment, 2026-08-17, strengthening the original "offers"); declining is recorded, never overridden; (4) **the decision surface crosses by configuration** — hub-local queue pre-tier, manifest re-point at minting, identical data contract (proven by the v1.24 single-hub round-trip test). `km-supervise` now names its own adoption condition: a minimum tier meeting its first cross-hub source adopts the routing files at that moment. Trade-offs recorded: the threshold is **advice the standard gives, never an act it performs** — the owner may decline; and the minimum tier deliberately omits every capability whose absence is recoverable, betting that a small tier actually minted beats a complete tier ignored. |
| v1.27 | 2026-08-18 | Drafted and published 2026-08-18 (owner push). Skill files declare their trigger, not their title (Agent Tier). Every skill file the standard ships (`skills/`, `template/.claude/skills/`, `template/.agents/skills/`) now carries YAML frontmatter with `name` (the directory slug, which is also the invocation) and `description` written as **when to use it**, in trigger terms, naming the invocation itself. Derived from a measured defect in a deployed estate: 81 of 82 hub-local skill files carried no frontmatter at all, so every runtime listing fell back to the file's first heading — a title ("Skill: km-gather, Research Sources and Propose Hub Updates") states what a skill is called and never what would make an agent reach for it, leaving discovery to whoever already remembers the skill exists. Three enforced properties, each with its cost stated: one dense sentence of roughly 15–30 words, because descriptions are **resident** — they occupy context in every session where the skill is installed, used or not, and the standing cost scales with the number of skills installed rather than with how often they fire; written to need no quoting (no colon-space in the value), since a plain YAML scalar cannot contain one and a quoted scalar is one naive frontmatter reader away from showing its own quote marks in the listing; and placed where residency is earned, per-hub skills in the hub, workspace-level skills (initialization, cross-hub routing) at the workspace. `tests/test_skill_frontmatter.sh` enforces all four field rules plus mirror parity, and proves each rule against a synthetic violation. **Trade-offs recorded:** (1) the fix *adds* a standing token cost where there was none — measured at ~45 tokens per skill, ~319 for a hub's set of seven, against reliable discovery; the one-sentence cap is where that trade was struck, and the 10–40 word test ceiling is the mechanical form of "roughly". (2) The colon-space ban constrains phrasing (some descriptions read slightly stiffer than their quoted form would) in exchange for parsing identically under a real YAML parser and a naive line reader. (3) Descriptions state trigger conditions but do **not** change any runtime's decision to auto-invoke; whether a given skill should fire unprompted stays a per-deployment choice this version deliberately leaves open. (4) The distribution copy `skills/km-brief/SKILL.md` is missing the index-first and lifecycle-filter guidance its template mirrors carry — pre-existing content drift, reported, deliberately **not** repaired here so that this change adds frontmatter and nothing else; the new mirror-parity check covers frontmatter only. (5) Hubs already deployed do not inherit the fix by upgrading the standard: their installed skill copies are backfilled as an adoption act under each hub's own governance. |
| v1.28 | 2026-08-19 | Drafted and published 2026-08-19 (owner push). Initiation for hubs that already exist, and four things the interview must elicit. (1) **A gate needs a route back.** v1.25 made a missing `initiation-interview` date a scan error, but `/km-init` only creates a hub from the template at a path where none exists, so it cannot interview a directory it did not create: every hub predating the gate, and every existing project folder a deployment adopts the standard onto, became permanently non-conformant with no defined act to make it conformant, and the standard's only acknowledgement of the case demoted such a hub to `repo` with its interview "owed". The skill gains an **adoption mode** — the interview runs against a directory that already exists and writes only what is missing — under four properties: the interview is run and never waived (stamping a date onto an uninterviewed hub forges the gate's own evidence, and a red scan is more honest); existing content and recorded canonical provenance are preserved, re-pinning being a separate governed act; both quarantines a directory can trip (its own scan for the missing interview record, the estate scan for absence from the registry) are cleared by the one interview or the pass stops; and the value gate still applies, harder, because after the directory exists sunk cost argues for initiating whatever is there. Demonstrated by a deployment that upgraded onto **eleven pre-existing hub directories** and had to write all eleven initiation records by hand at the supervisor tier, with its workspace scan reporting clean throughout because each hub ran an inherited copy of the scan predating the gate. (2) **Look before asking:** the interview reads the directory and the workspace registries first and pre-fills every answer defensible from evidence, each presented with its source for the owner to confirm or correct, naming plainly what could not be pre-filled — the interaction contract's reconcile-before-asking rule applied to initiation, and what makes an interview of this length survivable — with the guard that a pre-fill is a proposal and never an answer, so an unconfirmed pre-fill is never written into the hub definition. (3) **Scope stated as an admission rule** with its **hard exclusions** named: what the hub refuses even when a routing keyword matches, since keyword matching is how a source reaches a hub and an exclusion never stated against a matching keyword never fires. (4) **The sensitivity posture is elicited**, not discovered: expected restricted classes and planned outbound surfaces, so the outbound lint set is part of initiation rather than a retrofit — the outbound check has shipped since v1.16 and the access vocabulary since v1.22 while nothing asked for the input that configures them, the same defect v1.25 named for the knowledge-versus-records boundary. (5) **What should move home to this hub:** where the workspace holds an unrouted backlog, a parked register or an open routing gap, the interview asks which of it belongs here and initiation moves it; conditional on such a register existing. (6) **`routing-keywords` is gated:** `[ DEPLOYMENT ]` now errors on an empty or unsubstituted value, reported only once the interview date itself is valid so an uninterviewed hub shows one defect and not two; `tests/test_hub_deployment_binding.sh` carries both canaries. **Trade-offs recorded:** (a) the keyword gate turns red any hub interviewed under v1.25 that left the field empty — one field per hub, and the same shape of trade v1.25 itself recorded, which is the gate working rather than a regression; (b) the gate proves the field was filled, never that the keywords are the right ones, and no check can; (c) the interview grows again, to five rounds, and the pre-fill step is the whole of what pays for it, so a deployment that skips the pre-fill inherits the length without the mitigation; (d) the adoption mode is specified as a mode of the initiation skill rather than a separate skill, because two entry conditions producing one hub definition would otherwise drift into two definitions of a hub; (e) the mode is specified and unexecuted at this version — it is drafted from a deployment that performed the same work by hand, so the shape is evidenced and the skill path itself is not yet proven by a run. |
| v1.29 | 2026-08-19 | Drafted and published 2026-08-19 (owner push). A check that reports by absence is proven in both directions (Standard Maintainer). Repairs a demonstrated **false pass in the canonical leakage instrument**: `tests/test_canonical_leakage.sh` invokes `git grep -E`, whose regex engine ignores `\b`, so the natural way to write a whole-word denylist entry (`\bTerm\b`) matched nothing and printed "canonical leakage check passed" against a tree carrying 89 matching lines in one file — a guard reporting success while letting through exactly what it exists to stop — and the instrument could not express the case-insensitive half of a denylist at all. Found while publishing v1.28, by canarying the instrument rather than by trusting its output. **Four repairs.** Word boundaries are requested with `-w`, which git implements above the regex engine and which is therefore portable, in place of a construct the engine may ignore; `-i` makes the case-insensitive half expressible; an explicit boundary construct written into a pattern (`\b`, `\B`, `\<`, `\>`, `[[:<:]]`, `[[:>:]]`) is **probed against the live engine** before the scan and the run is refused when it proves inert, so a pattern that cannot match can never produce a pass; and the instrument fails closed on an unreadable repository or an empty scan set, with the passing line naming the mode actually run and the number of files scanned, so a recorded "passed" states what was checked. `tests/test_canonical_leakage_guard.sh` carries fifteen assertions proving both directions, including that the historic `\b` form can never again exit 0. The generalised rule is stated in §"Standard Maintainer" and bound in the maintainer contract (`agents/km-hub-builder/SKILL.md`). **Trade-offs recorded:** (a) the inert-syntax refusal is deliberately conservative — on a host whose engine does honour a construct the probe permits it, but the documented form stays `-w`, so a maintainer never has to know which host they are on; (b) `-w` bounds the whole match, so a denylist term meant to fire *inside* a longer word is written without it, and the looser substring mode is then a deliberate choice that the passing line names; (c) the scan covers tracked files, which is the publishable set by definition but leaves an untracked working file out of scope; (d) nothing here changes what a hub does, so there is no hub adoption action and the repair reaches a deployment only by re-pinning the canonical standard. **Consequence for records already written:** any leakage result recorded before this version whose pattern used `\b` is void, not clean, and is re-run under `-w` before it is relied on. |
| v1.30 | 2026-08-19 | Drafted and published 2026-08-19 (owner push). The checks a hub and a build run are proved in both directions. v1.29 stated the rule and proved one maintainer instrument; this version applies it to the two instruments a *deployment* actually runs, and records what a canary cannot do. (1) **The publish guard runner** (`tools/km-publish.sh`) had the same shape as the repaired leakage instrument and no negative test: `FORBID` rules are manifest-supplied extended regular expressions matched with `grep -qiE`, so a pattern the engine ignores, an invalid pattern (`grep` exits 2, which a boolean test reads as "absent"), a mistyped verb (warned past), or extraction that produced no text all ended in the same line, "Guards passed". That is the worst false pass in the standard, because every guard exists *because* a correction motivated it, so the passing build reissues the corrected defect. The runner now compiles each pattern with the tool that will run it, **probes any boundary construct against that tool** and refuses when it proves inert, refuses on empty or unreadable extracted text, on a guards file asserting no rules, on an unrecognised verb and on a non-numeric `PAGES` value, distinguishes *present / absent / could-not-answer* rather than two outcomes, and names in its passing line how many rules of which kind ran and how much text was scanned. Whole-word verbs `FORBID-WORD` and `REQUIRE-WORD` are added so the refusal has a portable route back, using the matching tool's own `-w` rather than a regex construct, since a guards file travels between hosts. The guard engine is reachable as `--check-guards`, so it is testable without WeasyPrint or a PDF. (2) **The session-start scan**: eleven blocks of `template/hub-scan.sh` reported by absence with nothing proving they fire, and two of them passed without stating any coverage at all. `tests/test_hub_scan_canaries.sh` builds a clean hub from the template, proves it green, then injects one known violation per block — `[ INBOX ]`, `[ PROPOSALS ]`, `[ INTEGRITY ]`, `[ READABILITY ]`, `[ FRONTMATTER ]`, `[ FRESHNESS ]`, `[ LINKS ]`, `[ SHAPE ]`, `[ CURRENCY ]`, `[ RECONCILIATION ]` and the `[ AGENT ]` false-dispatch walk — asserting the naming line and the exit class, plus three cases proving the blocks do *not* fire on a resolving edge, an unfilled template placeholder or a genuine dispatch. `[ LINKS ]` was taken first: it decides graph-edge integrity for every hub in an estate and its failure mode is a dangling edge that fails silently. The scan is inherited by every hub, so a block that stops firing turns a whole estate green at once. No dead check was found — the eleven all fire — so `template/hub-scan.sh` changes in exactly one respect: `[ FRONTMATTER ]` and `[ LINKS ]` now name their coverage on the passing line (documents read; edges resolved against the size of the note index), because a sentence that reads identically over forty inputs and over none is a word rather than evidence, and a hub whose link check reports zero edges is being told something true. (3) **The rule is generalised in §"Standard Maintainer"** to every check the standard ships, with the demonstration that only the negative direction detects a dead check: one block was deliberately neutered while this version was written and its positive case and both its over-match cases went on passing. **Stated limit, recorded as part of the rule:** proving both directions proves a check fires on the class it *models*, never that it models the right class, and a check whose gap is structural is reached by no canary — demonstrated by a hub manifest missing a row for a governed file, which the git-backed integrity check could never have caught, because a file absent from a hand-maintained manifest is invisible to a working-tree/history comparison rather than flagged by it. **Trade-offs recorded:** (a) refusing an unrecognised guard verb turns red any existing guards file carrying a typo or a locally-invented verb, which is the gate working, and the fix is one line per file; (b) refusing a guards file that asserts no rules means a placeholder sidecar kept "for later" now blocks its build, deliberately, since a build cannot be reported as guarded by a file that guards nothing; (c) `\b` is still *permitted* where the live tool honours it, the same conservative stance as v1.29, so the documented portable form is the `-WORD` verb rather than a ban; (d) the `[ READABILITY ]` canary reproduces the observable (size on disk, read returns nothing) with an unreadable file mode and not an actual cloud on-demand placeholder, which cannot be created in a test, and the proxy additionally trips `[ INTEGRITY ]`, so that case asserts the block's own contract rather than the run's exit class; (e) nothing a hub *asserts* changes and no hub content is touched, so there is no per-hub content adoption; the only inherited file that changes is `template/hub-scan.sh`, and only in its two passing lines, so a deployment inherits (1) by taking the shared renderer and (2) by installing the current template scan, which is the retrofit wave already sequenced. (f) The canary suites live in `tests/`, which a hub does not carry, so a hub running an inherited copy of the scan is covered by them only for as long as that copy has not drifted from the template — the drift, not the canaries, is what a deployment has to manage. |
| v1.31 | 2026-08-19 | Drafted and published 2026-08-19 (owner push). A control the owner cannot press is a defect, not an empty state. Reported from a deployment that adopted the canonical queue row schema, and found in front of a client mid-demonstration. (1) **The specification and the parser disagreed on the options format**, and the specification won. `SPEC.md` §3 says options are exact quoted verbs; the reference parser required them to be **bold** *and* quoted, so a queue written exactly as the specification and the shipped template describe it parsed **zero** options, the action bar rendered empty, and the card still showed its title, tier badge, hub chips, age and `NEEDS YOU` — complete-looking, unanswerable, silent. The parser moves to the specification (quotes make a verb an option; emphasis is presentation) and keeps both bold forms, so nothing written against the old parser breaks, which is the only asymmetry available: moving the specification instead would have broken every queue written to it and every conforming reimplementation. The specification was also the side that had *already* assigned tolerance to the parser. (2) **A row the surface cannot read is REPORTED, never silently emptied** — `hub-scan.sh` gains a conditional `[ QUEUE ]` block for the single-hub shape, `km-cockpit.py` gains `queue-check` for a Supervisor tier where the hub scan does not run, both with three outcomes (readable / cannot be read / could not be evaluated), and the card renders through the existing "Preparing for you" gate with the reason stated, enforced on POST as well as in rendering. The tier-B synthetic `apply`/`veto` pair now fires **only** where a row declares no options at all: it had been *hiding* this defect for a whole tier, and answering a row against options it never declared also credited the recommendation-follow-rate with a hit on an option the owner was never shown. (3) **No owner-supplied value may size a layout** — stated as an invariant rather than patched: an option label the length of a sentence sized a grid track with an `auto` maximum and collapsed the title column beside it, and the same class covers answers, notes and row text. Registered owner-text tracks must have a bounded maximum, a new owner-text surface is registered in the same change, and the check states the coverage it has. (4) `str.capitalize()` lower-cased everything after the first character, so an option naming a person rendered their name in lower case on the surface shown to them. (5) The queue template ships **worked tier-A and tier-B rows** inside a fenced block, and a fenced row is now documentation to every reader of the queue — parser, scan and check alike — so an example can be copied without appearing as a decision. **Both directions proved:** 19 new selftest cases, 6 hub-scan canaries (including the block staying silent where no queue exists, and its verdict cross-checked against `queue-check` on the same fixture), and 6 rendered-surface cases in `tests/test_km_cockpit.sh`. The selftest and the rendered-surface cases were re-run against the pre-fix parser and fail on it, so they are known to detect the defect they were written for; the `[ QUEUE ]` canaries assert naming lines no other block emits, so a removed or dead block fails them by construction, but they were never run against a scan that predates the block and that is a weaker claim, stated as such. **Stated limits:** the layout check verifies the tracks it has been *told* carry owner text and cannot discover an unregistered surface, which is why the registration obligation is in the contract rather than in the instrument; and the scan's `[ QUEUE ]` block and `queue-check` are two implementations of one rule, held together by a cross-check on a shared fixture and by nothing else. **Trade-off recorded:** a queue that curls its quotes now fails the check rather than parsing, which is deliberate — an unrecognised form is reported loudly instead of being absorbed by a more permissive parser that would go on hiding the next one. |
| v1.32 | 2026-08-20 | Drafted and published 2026-08-20 (owner push). The harness projection: the hub definition is the home of record for the facts the instruction files restate. Answers the first of the three gaps a deployment owner named (2026-08-18), designed in `rfcs/RFC-004`, and unblocked by his ruling that `km-deployment.md` is the home and `CLAUDE.md`/`AGENTS.md` carry a projected copy with drift REPORTED and never repaired. **The defect, verified in a deployment:** the initiation interview substitutes one set of elicited answers into both the hub manifest and the two instruction files, once, and nothing keeps them equal — in one hub an owner widened the admission rule in the instruction file only, so every registry-reading surface went on attributing sources by a rule he had already superseded; in another the hub definition carried exclusions the instruction file lacked. The standard was itself confused about which file was the home: §"Thin definitions" said `CLAUDE.md` while the interview, the quarantine gate and every registry-reading surface used `km-deployment.md`. That sentence is **corrected**. **The upper bound, and the reason nothing here generates a file whole:** a retrofit wave across seven hubs found each carrying four to eight sections with no template counterpart at all, including owner-authored text existing nowhere else, so the template is not the superset and a generator that assumed it was would delete the deployment's own judgement. (1) **A closed set of ten fact classes** homed in `km-deployment.md`, marked with `<!-- km:fact -->`; a projected copy lives in an instruction file inside `<!-- km:project <class> -->`, and **every unmarked line is owner-authored by definition** and is never read, compared or touched. The hub owner's name is deliberately NOT projected: it appears nine times per file, inline inside sentences, and bounding it would mean nine markers around sentence fragments. (2) **`[ PROJECTION ]` in `hub-scan.sh`** — `DRIFT`, `DANGLING`, `UNBALANCED MARKERS`, `MISPLACED SOURCE` and `HARNESS MIRROR DIVERGENCE` as errors, `UNPROJECTED TEXT` beside a projected fact as an advisory, and a **coverage line on every run** naming classes declared, regions found, files read, regions compared, and classes not projected. Text is compared as words, so reflowing a region is not drift and rewording it is. The block **refuses** rather than passes when the home of record is missing or unreadable. (3) **Nothing repairs drift**, and the report prints both texts so the owner can decide from the report: the verified case proves either side can hold the newer truth, and a projector that made the instruction file match would have reverted a recorded ruling and reported success. (4) **The counter-argument is carried into the design rather than dropped.** The owner wrote his widening in the instruction file because that is the file he reads, and a design that fights where its owner writes loses quietly. So: his text is never destroyed, the marker names the home of record on the line above it where he is typing, the catch is at the next session start, there is deliberately **no `Stop`-hook gate** (it fires while he is still mid-edit, and interrupting an owner halfway through writing a rule is the same failure as overwriting it), and text written *between* regions — where an owner amending a fact actually writes — is named by file and line as an advisory rather than an error, because a gate that reddens a hub for a legitimate sentence gets switched off and takes `DRIFT` with it. (5) **Skills are compared, not declared.** The two runtime trees a hub installs hold two copies of every procedure and drift as facts do (demonstrated: mirror directories left un-backfilled across five hubs); `[ PROJECTION ]` compares them slug by slug and tolerates exactly one designed difference, each tree naming its own harness instruction file. The declared-skill-set list proposed in the RFC was **not taken**: its evidence is fully covered by comparing the installed trees, and the alternative added a hand-maintained manifest, which is the artifact class that produced the blind spot this version is narrowing. **Both directions proved**, 16 cases (`tests/test_hub_scan_canaries.sh` 14a–14m): each finding fires on the class it models, the block refuses on evidence it cannot read, and it does **not** fire on a rewrapped region, a region's own label line, the one designed per-runtime skill difference, or a single-runtime deployment. The suite was re-run against a deliberately neutered comparison and exactly the two drift cases failed, so it is known to detect a dead block. Two over-match cases were found by the instrument itself on its first run: byte-comparing the shipped skill mirrors reported a legitimate per-runtime difference as divergence, and a naive interleaved-text rule would have reported every region's own label line, giving each conformant hub three permanent advisories on day one. **Stated limits:** a fact living only in an instruction file, in no region and no source, cannot be compared with anything — the same shape as the manifest defect the git-backed integrity check could never catch — so the unprojected set is reported as a number and a list, the evidence base can represent absence directly, and text beside a projected fact is named; what remains is that **the declared list cannot be proven complete**, which is a judgement reviewed at the hub's cadence and the same limit already stated for routing keywords. A changed hub owner is reconciled by hand. **Trade-offs recorded:** (a) the shipped template projects three of ten classes and that is the healthy state, not a backlog — every projection is a second copy, so the coverage line reports what is *not* projected without implying it should be; (b) `UNPROJECTED TEXT` is advisory by choice, which means a fact written beside a region is named but does not gate; (c) the mirror comparison normalises exactly one noun and would report any future legitimate per-runtime difference as drift, which is deliberate — the maintainer normalises it or accepts it, and the check never widens on its own; (d) a hub adopts this by installing the current template scan and wrapping the facts its instruction files already restate, three regions per file, reconciling whatever divergence that surfaces; a deployment that wraps nothing stays green and its coverage line says so. |
| v1.33 | 2026-08-21 | Drafted and published 2026-08-21 (owner push). The neutral preparing badge. Resolves deviation **dev-0007**, harvested from the reference deployment, where the owner's screenshot on 2026-08-19 caught one gated card carrying the red "needs you" tier badge and the "being prepared, nothing for you to do yet" flag at the same glance, a card that both summoned him and told him there was nothing for him yet. A gated or incomplete decision card now renders a neutral grey "Preparing" badge in its glance and never its actionable tier badge, so a single glance can never both summon the owner for a decision and say nothing is ready for him yet; the tier is named only in the badge's title tooltip. The actionable tiers are unchanged, and the dismissal machinery of a separate deviation was deliberately kept out of this harvest. `components/km-cockpit/SPEC.md` §4 carries the clause and names the reference deployment as the source the specification follows here, so a conformance pass never drags the lab back to the last release. A rendered-surface case in `tests/test_km_cockpit.sh` proves both directions: a gated tier-A card's glance carries the neutral "Preparing" badge and not the tier-A label "Needs you", and an ungated tier-A card still renders "Needs you"; the fixture extraction fails closed when it is empty. |
| v1.34 | 2026-08-21 | Drafted and published 2026-08-21 (owner push). A bookkeeping note is not work done. Resolves deviation **dev-0009**, harvested from the reference deployment, where the owner saw executed rows still logged and hubs shown as awaiting execution when the work was done ("very low discipline"): the unattended answer pickup had written execution records that were captures of his answer, not the work being done, and the cockpit counted any execution record as done, so undone rows read as executed and the executed tally was inflated. An execution record now carries an optional `status`. Absent means a genuine execution, so every record written before this field existed stays real and unchanged; `status: "recorded"` means the answer was captured but the work is still owed. `state()` splits the two, so only genuine executions count as executed, and a `recorded` capture folds into the same owner-visible state as a queued answer (answered, awaiting Supervisor execution), with a later `recorded` for an id reopening it, discipline over the mere presence of a record. The "answers executed" tile counts only genuine executions and the "awaiting supervisor execution" surface now includes captured-but-owed ids, so the two counts stay coherent. The `exec` CLI takes an optional status so a pickup can write a capture that never reads as done. The dismissal and desk machinery of a separate deviation was deliberately kept out of this harvest, and this component ships no execution-ledger scan, so the reference deployment's "not-executed-but-no-status is a ledger lie" scan check has no home here and was not built. The same rule is stated in `components/km-cockpit/SPEC.md` §3, which names the reference deployment as the source the specification follows here, so a conformance pass never drags the lab back to the last release. A rendered-surface case in `tests/test_km_cockpit.sh` proves both directions on one live state: a `recorded` capture does not count as executed and does surface as awaiting execution, while a status-absent record still counts as executed; the check fails closed when the state is empty. |
| v1.35 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). Hub merge, implementing `rfcs/RFC-004` Part II. Answers the second of the three gaps a deployment owner named (2026-08-18): there was no mechanism for combining two hubs when an engagement turns out to be one thing rather than two, or when a hub was stood up too early, and the only paths were leaving both or hand-moving content, neither of which preserves provenance. Every primitive already existed in the standard; this version is the first to combine them and name the act. **Three cases wear one word and only one is a merge:** two hubs that overlap are a routing question already solved by typed references and single-home-of-record (not a merge); a hub stood up too early is a **withdrawal** (its content re-homes as ordinary intake, the receiving hub absorbs its routing keywords, the directory is tombstoned, and there is no re-interview unless the admission rule changes); an engagement that was really one thing is the real merge, **absorb-and-tombstone**. Refusing the two lighter cases is the design's first duty: a merge process that never returns "these two should stay two" is a rubber stamp. **Absorb-and-tombstone, six properties.** (1) Direction is declared, the survivor chosen on whose competency questions survive, and a third hub is never created. (2) The initiation interview runs again on the survivor and re-stamps `initiation-interview`; the union of the two hubs' answers is a pre-fill and never the answer (the union of two admission rules is almost never the right one, routing keywords are the union or sources stop arriving, sensitivity is the stricter of the two and is elicited); merge is a **mode of the initiation skill**, not a separate skill, by v1.28's own reasoning. (3) Content crosses at the granularity its provenance already has: entity notes re-homed with a `movedFrom:` field and not re-digested, sources with their `dates-register.md` rows and `transcript-index.md` entries carried over verbatim, reconciliation topics merged row by row, narrative rollups never concatenated (the absorbed hub's move to the survivor's `archive/` marked `superseded`), `corrections/` crossing in full. (4) Reconciliation is where the merge actually happens: each absorbed settled row is checked against the survivor's ledger, a contradiction opens a dispute file adjudicated by the owner, every adjudication captures a `corrections/` note, and a merge that raises zero disputes is suspect rather than clean. (5) The absorbed hub is tombstoned, never deleted: directory and git history stay, a `MERGED-INTO.md` tombstone names the survivor, the admission rule becomes a refusal, the agent is retired, and the **registry row stays with a new `merged` status and a `merged-into` column** so the estate scan reports a tombstone rather than a quarantine; the hub's own scan is expected not to go green, and `[ DEPLOYMENT ]` in `hub-scan.sh` reports a `TOMBSTONE` finding naming the survivor in place of the interview and keyword checks a live hub runs. (6) Estate references are re-pointed by the Supervisor with history kept; merge is Supervisor-mediated under owner authority and not available to a hub agent. **The one schema change** is the registry's `merged` status and `merged-into` column; a deployment that never merges carries the extra column empty. **What this must NOT do:** delete the absorbed hub or rewrite its history, concatenate narrative documents, auto-resolve contradictions, skip the interview, advertise reversibility (the reversible act is the decision not to merge yet), or run across a compartment boundary. **The open limit, stated:** a merge across differing compartment declarations is refused, but the vocabulary that expresses the guard (`station`, `exposure`, the compartment model) is drafted and unpublished at v1.23, so the guard as written binds nothing until v1.23 publishes; the other five properties stand on published doctrine. **Surfaces changed:** a new "Hub merge: absorb-and-tombstone" section under the Supervisor Tier; the hub registry schema (`skills/km-supervise/_KM_Supervisor_template/hub-registry.md` and the two registry tables in `STANDARD.md`); `hub-scan.sh`'s `[ DEPLOYMENT ]` tombstone detection; a merge mode and a withdrawal mode on the initiation skill (`skills/km-init/SKILL.md`). **Both directions proved** (`tests/test_hub_merge.sh`): a tombstoned hub (a `MERGED-INTO.md` present, a valid live binding otherwise) reports `TOMBSTONE` naming the survivor and does not report the `HUB NOT INITIATED` quarantine and does not go green, while the same hub with the tombstone removed scans green and asserts it is a live hub (the defect the detection exists to catch); an ordinary uninterviewed hub-shaped directory with no tombstone reports the quarantine and not a tombstone, so the two classifications are distinguished; the negative direction was confirmed against a scan with tombstone detection removed and then restored; the fixture extraction fails closed when it is empty; and the skill-mode conformance cases prove the initiation skill declares the merge mode reruns the interview with the union as pre-fill and the withdrawal mode does not re-interview. **Stated limits:** the interview-rerun and union-pre-fill behaviours are prose in the initiation skill and are proved only at the level of the skill's declared text, the same status the v1.28 adoption mode carried, so the skill path itself is drafted from design and not yet proven by a run; and the estate-scan quarantine-versus-tombstone classification is registry-membership convention, mechanised here at the per-hub scan through the `MERGED-INTO.md` tombstone. The reference deployment leads this mechanism: when it first performs a merge the standard is brought up to what it learns, and a conformance pass never reverts it to this drafted text. |
| v1.36 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). The owner's desk. Resolves deviation **dev-0005**, harvested from the reference deployment, where the owner asked that his own follow-ups be separated into their own section after Hubs. The queue admits a hand lane of the deployment owner's personal follow-ups (what the owner is waiting on and what the owner owes), written as bullets under an "## Owner's desk" heading; each bullet's id is derived as `desk-<slug>` from its leading bold phrase, so an id survives edits to the rest of the bullet, while renaming the lead mints a new id and re-surfaces the item, a deliberate re-nudge chosen over a silent drop. The desk is a hand lane distinct from decision tiers A, B, and C: nothing on it defaults, nothing expires, and it never occupies a decision row. The cockpit renders the desk in its own section after Hubs, derives it from the queue on every request, and never writes the queue; the owner's only control is Mark done, which appends a record to the owner-side answer store (`{"id": "desk-<slug>", "answer": "done", "done": true}`) and rides the ordinary answers channel, so the Supervisor prunes the nudge on its next pull, and Undo is a further appended record. A ticked item moves to a done disclosure and off the active list. The control is a tick and never a dismiss, because hiding a live commitment without resolving it is the failure to avoid. `components/km-cockpit/SPEC.md` §3 carries the clause and names the reference deployment as the source the specification follows here, so a conformance pass never drags the lab back to the last release; the queue schema in this document gains the owner's-desk hand lane and the `desk-<slug>` id shape. `tests/test_km_cockpit.sh` proves both directions: a desk bullet renders in the desk section and not in tiers A/B/C, a done desk record moves the item to the done disclosure and off the active list, and the desk derives from the queue without the cockpit writing the queue file; the fixtures fail closed when empty. This harvest only adds the desk: the desk-tick execution-fold defect and the dismissal machinery of separate deviations were deliberately kept out of it. |
| v1.37 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). A desk tick is never a decision awaiting execution. Resolves deviation **dev-0013**, harvested from the reference deployment, where the owner (2026-08-20) saw "decisions pending to be executed" listing a personal follow-up he had already marked done as if it were work awaiting the Supervisor. Desk ticks ride the ordinary answers channel (added v1.36), so a `desk-<slug>` done record sits in the owner-side answer store, and `state()` built its decision and execution sets by reading those stores raw by id, so a cleared follow-up landed in the pending, queued, executed, and recorded accounting and read as answered, awaiting Supervisor execution. `state()` now excludes `desk-` ids from every set it feeds: from pending (the answer store), from queued (the pulled-answer store), and from the execution ledger it folds into executed and recorded, which hardens the recorded-to-queued fold against any future desk record as well. Desk rendering is untouched; the desk section (`render_desk`/`desk_ticks`) stays the only place desk ids surface. `components/km-cockpit/SPEC.md` §3 gains the clause (a desk tick never counts as a decision, and the desk lane is the only place desk ids appear) and names the reference deployment as the source the specification follows here, so a conformance pass never drags the lab back to the last release. A rendered-surface case in `tests/test_km_cockpit.sh` proves both directions on one live state: a ticked `desk-<slug>` record appears in none of pending, queued, or executed (a desk id in the recorded set folds into queued, so the queued assertion covers it) yet still renders in the desk done disclosure, while a genuine decision awaiting execution still counts; the check fails closed when the state carries no decision ids. The negative direction was confirmed against the unfixed `state()` and then restored. This harvest changes only the `state()` exclusion; desk rendering and the dismissal machinery of separate deviations were kept out of it. |
| v1.38 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). The KM Standard status card. Resolves deviation **dev-0003**, harvested from the reference deployment, where the owner asked to see the standard's own version and push state on the cockpit. A read-only Home card surfaces the standard checkout the deployment tracks: the version it is pinned to (read from the checkout's `STANDARD.md` title line) and its push state against origin (in sync, N commits not yet pushed with their subjects available, or origin carries commits not yet pulled). The card is display only and grows no controls, exactly as `components/km-cockpit/SPEC.md` §1 requires of every surface, so a standard change that needs the owner is a governed tier-A/B decision and never a button here; it reads local git alone, states that the origin comparison is as of the last fetch, and never contacts the network, so the render never depends on connectivity; a missing or unreadable checkout reports itself rather than fabricating state; and it emits no file link into the checkout, which lives outside the estate root and whose file-serving confinement (§4) this card must not widen. The checkout is configured by `standard_repo_path` in the deployment manifest; when that key is absent the card does not render, so a deployment that keeps no local checkout shows nothing rather than a guess. `components/km-cockpit/SPEC.md` §3 gains the clause and names the reference deployment as the source the specification follows here, so a conformance pass never drags the lab back to the last release. `tests/test_km_cockpit.sh` proves both directions on one live server: an in-sync checkout renders the pinned version and reads as in sync, while an extra local commit flips the same card to commits not yet pushed; the check fails closed when the card does not render. The negative direction was confirmed against a tree without the card and then restored. This harvest only adds the status card; no other deviation's surface was pulled in. |
| v1.39 | 2026-08-22 | Drafted and published 2026-08-22 (owner push). Editions and the run/evolve boundary, implementing `rfcs/RFC-006`. A deployment owner named one gap: the standard defined no clean boundary between consuming the standard and evolving it, and no way for tiers to package into editions. This version names one structural line already latent in a tiered deployment. **The run-set** consumes a published standard and operates a live estate (the Reader, the Supervisor with its queue, cockpit and routines, the hubs, and the pinned canonical standard read as authoritative); **the evolve-set** invents instruments and authors the standard (the Machinery tier and the Standard-Steward tier, which may fork it and runs the leakage guard). Every component maps to exactly one side by a table in the new "Editions and the run/evolve boundary" section; the line is the deployment's own consumption-versus-invention two-flow model made explicit. **Two editions are profiles over one standard version, strictly nested:** a Consumer/Run edition is the run-set, pinned and read-only, that consumes releases and cannot author; a Builder/Full edition adds the evolve-set and the authority to invent tooling and evolve or fork the standard. No component is removed or altered between them, no deployment is forced into an edition, and no existing hub changes, on the same no-cost-to-decline discipline the standard's other optional layers carry. **The key doctrine:** the pinned standard sits in the run-set, on the consume side, in both editions; only the Builder edition adds the authority to author it, so the artifact does not cross the boundary, the authority does. **License-agnostic by hard requirement:** the standard asserts no license, price, or commercial term; the section defines only the boundary, drawn so an owner MAY later attach a licensing policy at the line without any structural change, that policy living outside the canonical standard in the owner's own overlay. The Consumer edition is the concrete, bounded form of RFC-004 Part III reading (c) (many independent deployments, one maintainer serving all). **Boundary doctrine only:** no schema, check, or mechanism is added, because RFC-006 states no new instrument is strictly required by the boundary itself and an optional edition-declaration field is deliberately deferred; tier separation is stated as convention, never as an enforced control. **A known, tracked gap, not a defect:** the Consumer edition's Reader tier is not yet in the canonical standard, so v1.39 defines the editions boundary while the Consumer run-set is completed by the separate Reader harvest designed in `rfcs/RFC-007`. Neither the Reader (RFC-007) nor the routines (RFC-005) is implemented here; both are referenced. |
| v1.40 | 2026-08-23 | Drafted and published 2026-08-23 (owner push). The optional MCP query surface is quarantined and serves nothing. It is not repaired here. **The finding.** The surface (`template/mcp/`) was written before the four-gate projection contract (added v1.24) and was never brought forward to it. Measured first-hand against the published tree at v1.39: the listing path `list_entities()` applied gates 1 and 2 (committed at HEAD, lifecycle-active) and neither 3 nor 4; the direct-identifier path `get_entity(id)` applied gate 1 **alone**, so an identifier lookup returned the complete raw text of retired and superseded notes that the listing path correctly withheld; the query path `query_facts()` applied gates 1 and 2 and neither 3 nor 4; and `hub_scope()` together with the three resources (`hub://about`, `hub://glossary`, `hub://index/{folder}`) applied gate 1 alone. Access-clearance and projection-manifest logic exist **nowhere** in the implementation, on any path. The content test is a **denylist**, excluding only `_inbox/`, `changes/`, `archive/`, `.claude/`, `.agents/`, `mcp/`, `docs/` and a short filename list, so a note carrying a restricted marking in an ordinary directory was content by construction. **The exposure, stated by path and by content class** so a deployment can assess what it actually ran rather than guess, naming no specific content: `get_entity(id)` could return the full frontmatter and body of any committed note in the eight entity directories, including notes that were **retired**, **superseded**, marked **`sensitivity: restricted`**, classed **`accessClass: restricted`**, or **absent from every projection manifest**; `list_entities()` could return the full frontmatter (not the body) of every **active** entity note including the **restricted-marked**, **restricted-class** and **manifest-absent** ones, and could not return retired or superseded notes; `query_facts()` could return the **path, title and match count** (not the body) of every committed markdown file outside the denylist, including **restricted-marked**, **restricted-class** and **manifest-absent** notes, and could not return retired or superseded ones; `hub_scope()` could return three named sections of `01_project-brief.md` verbatim; and the three resources could return the complete text of `00_about.md`, `07_glossary.md` and any entity folder's `index.md`, regardless of lifecycle, class or manifest membership. The surface reads **committed state only** (`git show HEAD:<path>`) and never the working tree, so that enumeration bounds what was reachable: uncommitted edits, open proposals, inbox drafts and unresolved disputes were never exposed. **The premise, corrected.** The section and the surface both read "committed = safe to expose". That is withdrawn. Committing a fact records it and it passed review to get there; it decides nothing about who may read it. Committed state is gate 1 of four, and a surface treating it as sufficient reproduces this defect. **The false guarantee, corrected.** `template/mcp/README.md` stated without qualification that retired and superseded notes are never returned. That was true of the listing and query paths and **false of `get_entity(id)`**, which is the worst form of the defect: an operator was told a control existed on every path and could reasonably have placed material behind it. Documentation now states only the guarantees the implementation keeps, names the path on which a partial guarantee does not hold, and names the two never-implemented gates as not enforced rather than omitting them. **What quarantine means here:** every content-returning entry point refuses and states the quarantine and its reason, so a caller learns why rather than reading an empty result; the refusal covers the four tools **and** the three resources, which the gate matrix framing the finding did not enumerate, because a refusal covering only the paths someone remembered to list is not a refusal; the surface does **not** degrade to the listing path merely because that path enforced lifecycle, since reasoning about which of four gates applies on which of several paths is exactly what failed here; and starting the surface reports the quarantine and exits rather than starting silently, reported **before** the dependency import so a clean environment meets the quarantine and not an `ImportError`. **Installation instructions corrected, after verification rather than on report:** the README said `pip install mcp` and "Python 3.8+". Verified against the package index, `mcp` 2.0.0 removed `mcp.server.fastmcp` outright, which is the interface `server.py` imports, so an unpinned install resolves to a release the surface cannot import and then exits claiming the package is missing when it is installed at the wrong major version; `mcp` 1.29.0 was confirmed to ship `mcp/server/fastmcp/` with `FastMCP` exported. Every published `mcp` release, 1.0.0 onward, declares `Requires-Python >=3.10`, so the stated 3.8 floor was satisfiable by no configuration carrying the dependency. The instructions are now `pip install "mcp>=1.29,<2"` at Python 3.10 or newer, with the move to the 2.x interface named as a migration this file does not contain. **One correction to the finding as first written:** the query path was reported as not enforcing lifecycle. Reproduced against the tree, it does. The record states what was measured, not what was alleged. **Both directions proved** (`tests/test_mcp_quarantine.sh`): all seven content-returning entry points, the four tools and the three resources, refuse and return no content across eleven driver invocations against a synthetic hub committing one note of every named class, *(this row read "all eleven content-returning entry points" until v1.56. Eleven was the number of calls the suite makes, `get_entity` being driven five times with five identifiers; the surface has seven entry points and always had. The count was wrong on the day it was written rather than overtaken since, so it is corrected in the ledger under the v1.47 rule that the ledger is the corrected record of account, and the pushed commit and tag that carry the original wording are left exactly as they are. `tests/test_mcp_quarantine.sh` case 7 now derives the figure from the surface's own decorators so it cannot be restated wrongly again.)* while the same assertions run against an unquarantined copy fail and the content comes back, so a pass is evidence of a refusal and not of an empty tree; the whole suite was also run against the pre-change surface and failed in nine places before being restored; the fixture fails closed when extraction is empty; and the instrument's own first draft carried a case-sensitive pattern that passed against the uncorrected file, found by the negative run and recorded in the test rather than smoothed away. **Explicitly not proved here:** no test asserts any of the four gates. A test passing because nothing is served must never read as a gate being proved, so the two never-implemented gates are asserted as an **acknowledged gap** and not as a control. **This quarantines and does not repair.** The gates are implemented and proved by the separate change `audit-mcp-projection-gates`, which is the only thing that lifts the quarantine, and it is not lifted by a repair of one path while another stays unguarded. **Adoption consequence, BREAKING and intended:** a deployment that had this optional surface enabled loses it. It stops answering rather than answering under a contract it cannot keep. A deployment that never enabled it is unaffected, no hub content changes in either case, and the hub remains fully readable as plain markdown through its own governed channels. An acknowledged gap is safer than a false assurance, and the quarantine is the acknowledgement. |
| v1.41 | 2026-08-23 | Drafted and published 2026-08-23 (owner push). Drafted as v1.40 and renumbered once v1.40 published as the MCP quarantine; a published version identifier is never reused. The Reader tier, the scoped reader, and the honest isolation boundary, implementing `rfcs/RFC-007` and completing the Consumer edition's run-set that v1.39 (RFC-006) named as its one missing component. A deployment owner named the gap: the standard had no read-only consumption tier and defined no Reader identity, marker, contract, or scoping mechanism. This version adds a **Reader tier**: a read-only consumption context that produces outputs from the estate and authors none of it, with a four-clause contract (produces outputs not estate changes; the consumption acts are out of scope and listed; reading anything readable is in scope; a defect is noted in one line and left), the reading subset of the standard that still binds it (evidence hierarchy, home of record first, provenance per claim, restricted never surfaced, identity resolved not constructed, voice, estate separation), and a scaffold under `template/reader/` (a `.km-tier` marker whose first line is `reader`, a governing `CLAUDE.md` with an `AGENTS.md` mirror, an `outputs/` area, an optional `correction notes/` area, and a host permission file that denies git write commands). It defines the **scoped reader**: a reader locked to a named, closed list of hubs declared on a `scope:` line in the marker, that refuses everything outside the list rather than answering partially, and that ignores its target hub's own build files. The scoped reader is stated as the read-side projection of an RFC-002 compartment and the per-tenant consumption face of the RFC-006 Consumer edition, both by reference, neither redesigned. **The honest isolation boundary:** a scoped reader's isolation is convention unless the hosting enforces it with separate installs, storage, or credentials; the shipped git-write denial denies writing not reading, and the standard refuses to describe a scoped reader as an enforced tenant boundary, on the same posture it takes toward agent scope. **Reader skills, minimal:** `km-brief` is named as the Reader skill that already ships; a dedicated query skill and a reader-safe gather are named as deferred to a later harvest, the Reader answering meanwhile through `km-brief` and direct query, so no heavy new skill is authored. A `reader-scan.sh` in the scaffold validates the reader declaration's shape (marker present and first line `reader`, governing file present, `outputs/` present, and any declared scope a non-empty closed list), canaried both directions in `tests/test_reader_scaffold.sh`; it validates the declaration, not isolation, and states that limit in its own coverage line. **The scope is validated token by token, never as one whole value.** The first draft of this scanner compared the declared scope as a single string, so it rejected an exact `*` and an exact `all` and accepted either one hidden in a list: `scope: *, hub-alpha` reported a closed scope of two hubs, and `scope: hub-alpha,` reported a hub whose name carried the delimiter. The suite was green because it proved only the two exact forms and never a list, which is the failure this version records as much as the parser it corrects. Each token is now judged on its own: an open token is rejected wherever it sits and is named, an empty entry from a leading, trailing or repeated delimiter is reported rather than absorbed into its neighbour or dropped off the end, a duplicate is rejected and named, and a token that is not the standard's own hub slug is rejected and named. A declaration the parser cannot evaluate, a marker declaring `scope:` more than once or a scope line carrying bytes outside the printable set, is **refused** rather than passed, on the same posture the scanner already took toward a context it could not read. The bypass canaries were run against the unrepaired scanner and fail there in nineteen places before passing against the repaired one; a canary that passes against both proves nothing. **Stated limits:** the repair strengthens the check and not the boundary, so the coverage line is unchanged and still says isolation was not validated; and proving both directions proves the check fires on the class it models, never that it models the right class, which is precisely what the first suite got wrong. The scaffold's two instruction mirrors are documented as carrying equal contract text differing only by the mirror note `AGENTS.md` opens with, that being the guarantee that actually holds, and the `outputs/` ignore is tightened so generated reader output cannot surface as untracked material while the shipped convention document stays tracked. A sweep of every other shipped check that reads a delimited value found one further instance of the same whole-value shape, in the hub scan's `routing-keywords` completeness test; it is registered with its reason rather than repaired here, so a Reader repair is not widened into a change about the hub scan. No enforced tenant isolation is asserted, encoded, or implied. |
| v1.42 | 2026-08-23 | Drafted and published 2026-08-23 (owner push). Published text is not draft text. **The defect, and it was in published material, including material deployments install.** Every version that added a section marked it `(added in vX.Y, drafted and unpublished)` while drafting, with the accompanying clause that the section binds nothing until its own owner push, and marked the shipped files it touched the same way. The publish ritual then flipped the frontmatter title, the H1, the lead paragraph, the version-history row, `README.md` and the badge, and never the section bodies and never the shipped files, so each marking survived its own publication. **The root cause is the ritual, stated honestly:** the documented ritual had no clearing step, and the maintainer publishing v1.35, v1.39 and v1.40 did not notice that the bodies still said the opposite of the header. **What was found, enumerated against published `main` rather than trusted from an earlier count** (two prior enumerations of the standard alone disagreed, at seven and at six, and both were low): seventeen markings across five files, fifteen of them naming a version outright. In `STANDARD.md`, nine: v1.40 at line 1275, the MCP quarantine blockquote; v1.35 at 2565 (the registry status table), 2653 (the minimum Supervisor tier's registry description), 2730 (the "Hub merge: absorb-and-tombstone" heading), 2732 and 2733 (that section's own blockquote and its binds-nothing clause) and 3179 (the interview-trigger list); v1.39 at 3691 (the "Editions and the run/evolve boundary" heading) and 3697 (its binds-nothing clause). **In the shipped surfaces, eight more, all v1.35, and these matter most because the false claim lands inside a deployment rather than only in the reference document:** `skills/km-init/SKILL.md` at 17 and 18 (the merge and withdrawal entry conditions), 44 (the modes heading) and 46 with its binds-nothing clause, telling an operator that the two modes bind nothing; `skills/km-supervise/_KM_Supervisor_template/hub-registry.md` at 12, the registry template a Supervisor tier installs, marking the `merged` status itself as drafted; `template/hub-scan.sh` at 335, inherited by every hub; and `tests/test_hub_merge.sh` at 2, internal and lower stakes, repaired for consistency. The registry schema is the sharpest case: the `merged` status and the `merged-into` column are a real obligation v1.35 introduced, and a deployment reading its own installed copy would reasonably have skipped it on the strength of the marking. **The repair** clears the draft parenthetical and the binds-nothing clause at each of the seventeen and changes no other word; the version attribution is kept, because `(added in v1.35)` is true and useful and only the draft claim was false. Claims of a different kind are left standing: the initiation skill still says the merge modes are drafted from design and not yet proven by a run, which remains true. The v1.23 markings in the same document are untouched: v1.23 genuinely remains drafted and unpublished. **The mechanical check** is `scripts/validate_published_not_draft.py`, and it covers the governed surface rather than the standard alone. A check scoped to `STANDARD.md` would have reported a clean pass on a tree whose installed skill, registry template and hub scan still carried the false claim, which is a control certifying the wrong class and is the precise failure this version exists to close. One home of record: publication status is read from the version-history table of `STANDARD.md` and from nowhere else, then applied to every scanned file, so it keeps working as versions publish; a row counts as unpublished only when it opens with an explicit draft declaration, and every other row counts as published, which is the strict direction and can never let a stale marking through. **The scope is declared, not implicit:** `STANDARD.md`, `README.md`, `agents/`, `components/`, `contracts/`, `docs/`, `scripts/`, `skills/`, `template/`, `tests/` and `tools/`, over a named suffix list, with `outputs/` and `work/` excluded as the deployment profile requires. `rfcs/` is out of scope and the reason is stated on every run: an RFC is a dated design record of what the status was when a ruling was captured, not a surface a deployment installs, and freezing its prose to current status would falsify the record. A single file may exempt itself with a line stating a reason; an exemption with no reason is refused, and every exempt file is named with its reason on the passing run, so no exclusion is silent. Two files declare one: the check and its canaries, whose docstrings and fixtures quote markings by construction. It reads each file in blocks of consecutive non-blank lines with blockquote and comment markers stripped, because a marking is regularly split across two source lines and a joined `>` or `#` hides the phrase from the pattern, which looks exactly like clean text. Each marking is attributed to the nearest version identifier, within an asymmetric window: a version may precede the phrase at a distance, because that is the shape the real markings take, but one that merely turns up in the next sentence does not capture it. Two kinds of text are excluded rather than judged, and are counted and reported so the exclusion is visible: **template** text, where the nearest identifier is a placeholder such as `vX.Y`, because the ritual has to quote the marking it governs and a quotation is not a status claim; and **unversioned** text, where no identifier is close enough, because a general statement of the convention names no release and cannot be stale. The cost is stated rather than hidden: a bare binds-nothing clause inside a section whose heading is stale is not caught on its own, and is reached through the heading, which is where the version is named. It **fails closed**, refusing without a verdict, when `STANDARD.md` is unreadable or empty, when there is no version-history heading, when the table yields no rows or no published row, when a version is recorded twice, when a scanned file cannot be decoded, when an exemption declares no reason, when everything in scope is exempt, or when any marking is attributed to a version the table does not record. On a passing run it states its coverage in files as well as in markings: how many versions it classified and how they split, how many files it scanned and how many were exempt and why, and how many markings it found and how they divide between judged, template and unversioned. **Both directions proved** (`tests/test_published_not_draft.sh`): a synthetic stale marking for a published version is caught and the version named; a synthetic legitimate marking for an unpublished version does not fire; the same body text flips verdict when only its version-history row flips, which is what proves the published set is derived and not hardcoded, in both directions; **a stale marking in a shipped skill and in a shipped shell script is caught while `STANDARD.md` is clean, which is what proves the widened scope is real and not decorative, and the same two files marked for an unpublished version do not fire**; template and unversioned text is counted and reported rather than silently dropped; a declared exemption is honoured for its own file alone and does not silence its neighbours, and is printed on the pass; seven unevaluable inputs (empty, no version-history heading, no rows, a version recorded twice, a marking naming a version the table does not record, an exemption without a reason, everything in scope exempt) refuse with exit 2 rather than returning a clean verdict; and the check was run against the whole repository as it stood at the published v1.41 commit, where it fails and names all fifteen markings that carry an explicit version, in `STANDARD.md` and in all four shipped files, while leaving the legitimate v1.23 markings alone. The two it does not name there are bare binds-nothing clauses that name no version and are reached through their own stale headings. That last case is the strongest available evidence that the instrument detects the defect it was written for rather than a synthetic likeness of it. **The ritual is amended** in the new "Publishing a version" section under the version ledger and in the `km-hub-builder` contract's own publication step, so clearing the publishing version's markings and running the check are part of publishing rather than something a maintainer remembers. **Stated limits:** a marking in `rfcs/` is out of scope by declaration rather than by oversight, and is cleared by reading; the check cannot audit the version-history table itself, which is the only publication record the repository has; and proving both directions proves the instrument fires on the class it models, never that it models the right class. |
| v1.43 | 2026-08-23 | Drafted and published 2026-08-23 (owner push). One canonical copy, and the mirrors are mirrors. Resolves audit finding **F-05**, and closes the drift v1.27's own version row recorded and knowingly deferred. **The defect, measured against published `main` at `10d7950` rather than trusted from the finding.** Seven skills ship in three locations each: `skills/<slug>/SKILL.md`, which `README.md` presents as the distributable per-hub skill, and a mirror in each of the two runtime trees the hub template installs. Nothing in this repository compared their bodies. `skills/km-brief/SKILL.md` was 109 lines against 128 in both mirrors, missing one contiguous block of 19 lines, 954 bytes, carrying three instructions: read the index first, because each entity folder's `index.md` lists active notes only and navigating by it avoids loading every note; include only `lifecycle: active` and exclude `superseded` and `retired`; and honour `confidence`, saying so when an artifact rests on low-confidence facts rather than laundering them into assertions by omission. **The safety consequence, plainly:** the copy the repository advertised as distributable could surface a retired or superseded fact in a memo and present it as true now. A retired fact was true once, which is why publishing it reads as current rather than as obviously wrong, and the note is kept on disk for the audit trail, which is not the same as being fit to publish. **Why the existing gate did not see it.** The three copies carry byte-identical frontmatter, so `tests/test_skill_frontmatter.sh` (v1.27) reported them in parity while the bodies differed by a governance block; and `[ PROJECTION ]` (v1.32) compares bodies only inside a deployed hub and only between the two runtime trees, which are identical to each other here, so the advertised copy was the one surface compared with nothing. That is why it is the one that drifted. **v1.27 knew.** Its version row records the drift as pre-existing, states that the new mirror-parity check covers frontmatter only, and defers the repair so that v1.27 would add frontmatter and nothing else. The deferral was honest and it is closed here. **The repair, and its direction.** The advertised copy is raised to the mirrors' body; no mirror is reduced to match the root. `skills/<slug>/SKILL.md` is named the canonical copy and the runtime trees are named as mirrors of it, so which copy is authoritative has a written answer. Direction of repair is written as a **judgement about content and never about the authority of the location**, and is deliberately not mechanised: reversing it would have produced three copies in perfect parity and three deployments able to publish a retired fact. **The gate** is `tests/test_skill_distribution_parity.sh`, a companion to the frontmatter check rather than an extension of it, because the two model different classes and should fail separately, because the parity check owes a coverage line of its own, and because it must be runnable against an arbitrary tree in order to be proved against the unrepaired one. It compares the governed instruction body, delimited at the closing frontmatter terminator, leaving frontmatter to v1.27's check so one cause produces one failure. It tolerates **exactly one** documented per-runtime substitution, each runtime tree naming its own harness instruction file, which is the same single substitution `[ PROJECTION ]` already tolerates in a deployed hub, so a hub and this repository tolerate one list rather than two; a difference is documented in the standard first and tolerated second. It **refuses** with no verdict on a copy it cannot read or whose body it cannot delimit, on a mirror with no canonical copy behind it, on a canonical location holding no skill, and on any run that would report success having compared nothing. It states its coverage on a passing run: 9 canonical slugs, 7 multi-location, 14 pairs compared, 8 documented substitutions applied, and the 2 single-location slugs it did not compare, named. **Both directions proved**, 16 cases: drift added to a mirror body and to the canonical body, a governance line removed from the canonical copy (the shape of the real defect), and drift sitting beside a documented substitution so normalisation cannot swallow its neighbour, all fire; a fixture whose copies differ only by the documented substitution does **not** fire, and neither does the real `km-propose`, whose two runtime copies genuinely differ per runtime in the shipped tree, with the case failing loudly if that difference ever disappears so it cannot quietly stop proving anything; and six unevaluable inputs (no frontmatter terminator, an empty copy, an unreadable copy, an orphan mirror slug, an empty canonical location, a tree with no mirrors) refuse rather than returning a clean verdict, with the unreadable case reported as a coverage gap rather than a pass where the uid bypasses the permission bits. **Run against the unrepaired tree** at `10d7950`, read out of git rather than hand-built, the check reports drift, names `km-brief`, and reports 19 differing lines against each of the two mirrors, and does not also return parity there; that is the strongest available evidence it detects the defect it was written for rather than a synthetic likeness of it. **The whole class was swept.** All nine shipped skills were compared, both directions, in every location they ship in. Seven are multi-location and were the ones at risk. `km-brief` was the only governed-body divergence, confirmed by the check against the unrepaired tree and not by inspection alone. `km-propose` differs between the two runtime trees by the documented substitution and by nothing else. The remaining five multi-location slugs are byte-identical across all three copies. `km-init` and `km-supervise` ship in the canonical location only, are workspace-level rather than per-hub, have no mirror to diverge from, and are named on the coverage line so their exclusion is visible rather than silent. No further divergence was found and none was registered. **Stated limits:** parity proves the copies agree and never that they are right, since three copies of an unsafe body are in perfect parity, which is why the direction of repair stays a judgement; the tolerated substitution is a real hole one token wide by construction, and widening it is a documented act; two instruments now walk the same three trees, so a change to the distribution layout touches both; a skill written locally in a deployed hub is still reached by no check here, which is v1.27's limit unchanged; and proving both directions proves the instrument fires on the class it models, never that it models the right class. **Adoption:** hubs already deployed do not inherit the repair by upgrading the standard. An installed `km-brief` copy is backfilled as an adoption act under each hub's own governance, exactly as v1.27's frontmatter fix was. |
| v1.44 | 2026-08-23 | Drafted and published 2026-08-23 (owner push). A check that reads a compound value validates its parts, never the whole alone. Repairs defect **D6** and states the generalised rule the repair earns. **The defect.** `routing-keywords` in `km-deployment.md` is a comma-separated list harvested by the supervisor's hub registry and by the decision surface's per-hub attribution. The gate v1.28 put on it, in the `[ DEPLOYMENT ]` block of `template/hub-scan.sh`, tested the **whole value**: an empty arm matching only `""`, and a substring arm matching `{{`. A value of `", ,"` is neither empty nor placeholder-bearing, so it matched no arm, fell out of the `case` with no error, and the hub scanned green carrying no keyword at all. Reproduced on published `main` at `cac984e` before any repair: exit 0, `OK: canonical standard binding is complete`, `=== OK — clean ===`. The consuming surface confirms the consequence rather than softening it: `km-cockpit.py` reads the field as `[k.strip().lower() for k in cells[3].split(",") if k.strip()]`, so every empty entry is dropped silently and the hub is attributed nothing, with no error raised anywhere. The placeholder arm was already correct for a list, being a substring test, and a placeholder in a non-leading position was confirmed to fire; only the empty-entry half of the class was present. **The repair.** The value is split on the comma by hand, so an empty entry survives as a token rather than being absorbed into its neighbour or dropped off the end, each entry is trimmed, and at least one entry must carry an alphanumeric character. A value whose entries are all empty or punctuation is an error naming the entry count. A stray empty entry beside real keywords is named as an **advisory**, never a quarantine, because one usable keyword is all a surface needs to attribute the hub and a trailing comma is a typo worth seeing rather than grounds to stop a hub scanning; the closed-list logic that makes every member fatal belongs to the reader scope and is deliberately not copied here. The two v1.28 arms are unchanged, including the exact wording a v1.28 canary asserts, and the gate stays behind the interview-date check so an uninterviewed hub still reports one defect and not two. The passing line states its coverage, naming usable entries against total entries, and restates the limit: this proves the field was filled in, never that the keywords are the right ones. **The generalised rule**, stated in the Standard Maintainer section beside *a check that reports by absence is proven in both directions* (v1.29) and *the rule binds every check the standard ships* (v1.30), which are its siblings: when the value a check reads is a list, a set, or a delimited sequence, the check splits it and judges each part, because a compound value can satisfy every whole-value test while containing no part that satisfies the rule. **Two demonstrations, deliberately, because one instance is an incident and two earn a rule.** The first is the Reader scope declaration repaired in v1.41, where the check tested the whole value for the open tokens `*` and `all`, so `scope: *` was rejected and `scope: *, hub-alpha` was accepted as a closed scope. The second is this one. Both gates were written correctly for a scalar and installed over a list, which is the shape to look for: the code reads as right and the granularity is wrong. The rule was deliberately deferred by the v1.41 hardening (its task A3.3) so it would ride with a second instance rather than be written from one. **The cost is stated:** per-token validation is stricter and can reject a sloppy but well-intentioned declaration the old check waved through, and a deployment can go red on a value it had been running with, the honest answer being that the value was always failing the rule and only the check was not looking. **What the rule does not reach:** an identity comparison between two representations of one value, which is what `[ PROJECTION ]` performs, is correctly a whole-value test and splitting it would let the two sides differ in ways the comparison then tolerated. **The sweep is recorded with the rule** so the next maintainer does not repeat it blind: every check the repository ships was read for this class and re-read for this version rather than carried forward on the earlier session's word, covering the hub scan block by block, the reader scan, the publish guards, the leakage instrument, the skill parity check, the published-not-draft check, the organization profile validator, the index builder, the handover hooks, the agent runtime parity check, and the cockpit's queue and layout checks. Exactly two instances were found, both named above; everything else validates per part already or reads a single-valued field. The per-part cases are named as models: the queue block accepts an options cell only when at least one well-formed quoted verb is found inside it, the layout check splits a grid declaration into tracks, the profile validator walks every element of every list, the publish guards evaluate one rule per line, and the link check tests each wiki-link separately. The sweep is a point-in-time finding over the checks that existed at `cac984e`; the rule binds every check added after it. **Both directions proved** (`tests/test_hub_deployment_binding.sh`, beside the existing `routing-keywords` cases, which is where the `[ DEPLOYMENT ]` canaries live): the gate fires on an all-empty-entry value and on a lone delimiter, and does not fire on a legitimate multi-keyword list or on a single legitimate keyword; the advisory threshold is asserted in its own case, so it cannot drift in either direction without a test saying so; each fixture asserts that its mutation actually applied, so no case can pass by scanning a hub that never carried the value under test; and **all of them were run against the unrepaired scan first**, where both firing cases fail and the suite stops at the first, which is what makes them evidence that the gate detects the defect rather than agreeing with whatever the scan already did. **Stated limits:** the gate judges no keyword quality, count, or fitness, so a field of well-formed keywords no source will ever match still passes, and proving both directions proves the check fires on the class it models and never that it models the right class. |
| v1.45 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). Published text names only documents a reader can open. Closes audit finding **F-04**. **The defect, and it is the maintainer's own.** Published `main` at `c3e4ffe` cited `rfcs/RFC-005` twice in `STANDARD.md`, in the editions section's list of what it does not implement and in the v1.39 ledger row, while `rfcs/` carried RFC-001 through RFC-004, RFC-006 and RFC-007. The routines design existed only on the unmerged local branch `rfc-005-routines` at `086da08`, so the published standard named a design document a reader could not open, and RFC-006 and RFC-007 each rested on it: **nine dangling references across three files**, two in the standard and seven in the two RFCs that depend on it. **v1.39 published carrying those references while the drafting agent's report explicitly flagged that RFC-005 sat unmerged, and the flag was acknowledged and not acted on.** That is recorded plainly because it is the whole lesson: the failure was not that nobody noticed, it is that noticing changed nothing, and a standard whose remedy for that is to look harder next time has no remedy. **Why nothing caught it.** The reference is written as a code-formatted path rather than a Markdown link, so every walk over hyperlinks passed over it, and a check that reads one form of a reference reports a clean tree for the form it does not read. **What this version does.** (1) The RFC-005 design document **lands on the published branch as design only**, by the route RFC-004 took ahead of v1.32 and v1.35: it binds nothing, claims no version, adds no version-history row, and changes no normative text, and its presence on the branch is not adoption. Its status banner is corrected to state its true status on the day it lands, that it remains unimplemented while the siblings it was named beside have been implemented since (RFC-004 Parts I and II by v1.32 and v1.35, RFC-006 by v1.39, RFC-007 by v1.41); the design itself is unchanged. (2) A new check, `scripts/validate_rfc_references.py`, extracts RFC identifiers from running prose, from version-ledger rows, and from the dependency and provenance sections of the design documents themselves rather than from Markdown hyperlinks alone, catching the bare identifier, the code-formatted path that got through, and a path naming a file that is not there, which the identifier existing does not excuse. **The existing set is derived from the `rfcs/` directory and no list of identifiers is held in the check**, so it keeps working as documents are added and needs no edit when they are; a list beside the check would be a hand-maintained memory of directory state. It **refuses rather than passes** when it cannot list the directory, when the directory yields no document, when no file was scanned, when nothing parsed anywhere, when a scanned file cannot be decoded, when a self-exemption declares no reason, or when everything in scope is exempt. It **states its coverage** on a passing run: references found, distinct identifiers they resolve to, files scanned, path forms resolved, files exempt with their reasons, and the documents present. (3) The generalised rule is grafted into the Standard Maintainer section beside the instrument rules it is a sibling of. **Both directions proved** (`tests/test_rfc_reference_integrity.sh`): one firing case per written form, a case in which every reference resolves and the check does not fire, a pair of runs proving the set is derived from the directory because landing the file alone flips identical text from dangling to resolved and removing it flips it back, six refusal cases, and a boundary case in which near-misses yield no reference at all. The suite was run against a deliberately neutered matcher and failed in ten places, so it is known to detect a check that has stopped firing. **The strongest case is the last:** the check is run against published `main` at `c3e4ffe`, where it fails and names all nine real RFC-005 references at their exact lines, which is evidence of fit rather than of mechanism. **A sweep of every other RFC cross-reference** in `STANDARD.md` and in the RFCs themselves found **no second instance**: the other six identifiers resolve everywhere they are named, and all fourteen path-form references resolve to files that exist. **Stated limits:** the check models openability alone, so it says nothing about whether a resolvable reference characterises its target correctly, whether the target is current, or whether a document that should have been cited was cited at all, and that last one is reached by no canary because the evidence the check consults cannot represent a citation nobody wrote. **No deployment surface changes.** No skill, template, scan, component, contract or schema is touched, so no hub inherits anything from this version and no deployment has an adoption act to perform. The routines remain unimplemented; implementing them is a separate version with its own authority. |
| v1.46 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). A release gate runs before publication, and it declares what it cannot do. Closes audit finding **F-06**. **The finding, verified first-hand rather than taken from the report.** On published `main` at `cf375b2` there is no `.github/workflows`, no `Makefile`, no `justfile`, and no repository-level runner: seventeen suites under `tests/` and three validators under `scripts/`, every one of them invoked by hand and selected from whatever the session remembered. Version tags for the whole v1.0 to v1.39 range were absent until the day before this version. **The cause is worse than the missing file, and it is what this version is actually about: verification has been performed by the same actor that authored the change, and it has failed three times.** (1) A Reader scope bypass passed a green suite and a leakage scan and was recommended for publication; `scope: *, hub-alpha` read as a closed scope because the check tested the whole value, and the suite that vouched for it proved an exact `*` and never a list containing one. (2) v1.39 published citing a design document that was not in the repository, **after the drafting agent's own report flagged exactly that**; the flag was acknowledged and nothing followed it, and the reference stood through five more versions. (3) Found during the remediation itself: three published versions told readers their binding sections carried no obligation, because the publish ritual flipped the header, the row, the README and the badge and never cleared the draft markings from the section bodies or from the files those versions shipped. One command cannot repair an actor problem. It can end the part of it that is mechanical, and it can make the part that is not into something a reader can check. **What this version adds.** (1) `tools/km-release-gate.py`, a single entry point returning one verdict: it runs every suite and every validator it discovers, a shell syntax check over tracked shell files, a JSON and JSON-LD parse check, a Python syntax check, and a relative-link check over tracked markdown, in that order, cheapest phases first and every phase run so one failure does not hide the rest. **What it runs is discovered, never listed:** every tracked `*.sh` and `*.py` in any `tests/` or `scripts/` directory, at the root or nested anywhere in the tree, is a check, so a suite added tomorrow is picked up with no edit to the runner, and a list held beside a runner would be a hand-maintained memory of directory state, which this standard already records as the artifact class that rots. **Nothing discovered is dropped silently:** a check that cannot self-run because it takes required arguments declares `km-gate-instrument: <canaries> | <reason>`, is reported as skipped with its reason and the canaries that cover it, and is **refused** unless those canaries run in the same pass, so a check cannot be removed from the gate by writing one comment line. Four files declare themselves this way: the leakage instrument, which takes a denylist pattern and exits 2 with a usage line when run bare; the organization profile validator, which takes a profile path; and the agent package's runtime parity instrument and its installer. Every one of them is covered by canaries that do run. **Scoping discovery beyond the root found something:** the agent package carries a live suite that no release had ever run, and a gate that looked only where checks are usually kept would have reported a clean tree for the one place it never looked. It **refuses rather than passes** on a file it cannot read or decode, on a discovered check it could not execute at all, on an empty discovery set, on a declared directory that yields no check, and on a tree it cannot list, because an unread tree is not a clean one and a refusal must never be folded into a verdict. It **states its coverage** on a passing run: checks discovered, run and skipped, declarations read by kind, and the file counts of every static phase. (2) `.github/workflows/release-gate.yml`, running the gate on push and pull request on a pinned runner image with the checkout action pinned by commit SHA, stating its expected duration, measured at 8 to 11 minutes across four full runs on the maintainer's machine and dominated by two suites at roughly 5 and 2 minutes, with the gate printing its own total and its three slowest checks on every run so the figure can be checked rather than believed. (3) **The declaration**, which is the part that answers the actor problem. Every check in the gate's scope carries `km-unrepaired-tree: <version\|none\|unrecorded> | <result>`, recording what it found when it was run against the tree it was written to catch. A missing declaration, or one whose result text is empty, **fails the gate**. Where a base revision resolves, a check this change **adds** must name the version being drafted and may not plead that nothing was recorded, since a check born in this change has no history to plead; a check this change **changes** must have its declaration line among the lines the change added, so an edit cannot quietly outrun what the declaration claims. Where no base resolves, both are reported as a **coverage gap** and neither is folded into the verdict. This is the same move the standard already makes for exemptions, where an exemption with no stated reason is refused: an unverifiable process property is converted into a checkable one. **The evidence for making this the mandatory step** is that running a new check against the unrepaired tree has caught something real **four** times in this remediation sequence: the Reader scope bypass, the MCP quarantine, the skill parity check, and the RFC reference check. It is the highest-yield step in the loop and the one most easily skipped. All twenty-three existing checks are retrofitted with the declaration their own headers already evidence; the nine with nothing recorded say `unrecorded` with a reason rather than inventing a run, and the gate counts and prints them on the passing line so the debt is visible rather than hidden. (4) The publish ritual gains the gate as step 5 beside the draft-marking clearing v1.42 added, and `agents/km-hub-builder/SKILL.md` is amended to match. **Two limits are stated in the standard rather than hidden behind a green line, and both are properties of the gate rather than defects awaiting a fix.** First, **the gate does not run an organisation leakage scan and cannot.** That scan needs a denylist generated from a real organisation's own entity names, and the denylist lives outside this repository **by design**, because carrying it here would itself be the leakage the guard exists to prevent. So the gate runs the instrument's canaries and proves the instrument works, and can never prove that a given push is clean; the fail-closed pre-push hook on a deployment's own clone remains the only thing that scans an actual push, and it is local and untracked. Second, **no script supplies a second actor.** The minimum viable independence is an adversarial pass, by someone other than the change's author, against the specific class being repaired, and no runner verifies that it happened. The gate requires the declaration and states, in its own passing output, that a green result means the mechanical checks ran and not that anyone other than the author looked. **Both directions proved** (`tests/test_release_gate.sh`, forty-four assertions, each breaking exactly one thing): a failing suite and a failing validator fail the gate; a suite whose interpreter is absent, an empty discovery set, a directory yielding no check, a tree that is not a repository, an undecodable tracked file, an instrument whose canaries would not run, and an exemption with no reason all **refuse**; a missing declaration, an empty declaration, an added check pleading `unrecorded`, an added check naming a stale version, and a changed check with an untouched declaration all **fail**; each static phase fires on one broken thing; and against whole trees, at the start of the run and again at the end, the gate **passes** and states its coverage, because a gate that fired on everything would prove as little as one that never fires. The link check is proved not to over-fire on resolving, anchored, remote or fenced-code links, and the repaired form of every declaration case is required to pass, so no case is a one-way assertion. **The gate was run against a deliberately broken tree**, which is the obligation it is about to impose on everyone else: a real suite made to fail (FAIL), a real suite made genuinely unexecutable (REFUSED), the discovery set emptied (REFUSED), and a real declaration stripped (FAIL), each in the actual repository rather than a fixture, and not one of them produced a PASS. **That exercise also found a third limit, which is why it is worth doing rather than reasoning about.** A real suite was given a command that does not exist, and the gate **passed**: the suite does not run under `set -e`, it swallowed the missing command, and it exited 0 on its own accounting, so the gate reported exactly what the check reported. The gate reads a check's exit status and cannot see inside it, and no runner that treats a check as a black box can. What reaches inside a check is the canary rule this section already carries; the gate reaches only its verdict. The behaviour is pinned by a case that asserts it as an acknowledged gap, so a later change that closes it fails loudly rather than quietly redefining what a pass means. **The gate also caught a defect in itself on its first full run against the real repository**, refusing because its own canaries write declaration syntax into the fixtures they build and a whole-file search read a fixture line as the canary's own claim; the class was fixed by reading declarations from the leading comment block alone, rather than by exempting the one file, and both directions are canaried. **The gate holds itself to its own rule** and carries an `km-unrepaired-tree` declaration of its own, because a rule whose author exempts himself from it is the failure this version exists to close. **Stated limits beyond the two above:** the gate checks that a declaration was made and re-stated, never that the run behind it happened; the currency rule does not force a fresh unrepaired-tree run for a typo fix, only a deliberate re-statement; branch protection, required status checks, signed tags and review records are settings on a hosting service rather than material in a repository and are the owner's to set, so this version claims none of them; and proving both directions proves the gate fires on the classes it models, never that it models the right ones. **No deployment surface changes.** No skill, template, scan, component, contract or schema is touched, so no hub inherits anything from this version and no deployment has an adoption act to perform. |
| v1.47 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). A version-history date is derived from the commit that published the version. **The defect, measured.** Two of the ledger's forty-seven rows stated a day on which nothing happened, and they were wrong in different halves, which is the whole diagnosis. `v1.40` claimed `2026-08-22` in its date column and in its stamp while all three of its events were on 2026-08-23: the draft commit `64015a6` at `13:15:23 +0200`, the publish commit `9c14f85` at `13:32:21 +0200`, and the overlay re-pin that adopted it at `13:37:57 +0200`. The staging brief carried the previous day's date, the session ran past midnight, and nobody re-derived the date from the tree. `v1.33` claimed `2026-08-20` while its publish commit `16109ea` is `2026-08-21 00:24:40 +0200` and its own stamp, its commit subject and its tag all read 2026-08-21; the publishing commit's diff shows the stamp being derived and the date column being left at the draft date, so the ritual was applied to half the row and the row has contradicted itself in published text since the moment it published. A version-history row is this repository's only publication record, so a wrong date in it is a false statement in published text, the class v1.42 and v1.45 already repaired in two other forms. **The correction.** The v1.40 date column and stamp become 2026-08-23 and the v1.33 date column becomes 2026-08-21. Three date tokens change and no other word in either row does. **What is deliberately NOT rewritten, and the asymmetry stated.** The v1.40 publish commit subject and the annotated tag `v1.40` both carry `owner push 2026-08-22` and both are left exactly as they are. They are pushed public history: amending the commit would rewrite every descendant, which here is six published versions and six tags, and retagging would replace an object every clone and fork already holds. A reader who finds two clones disagreeing about history has a harder problem than a reader who finds a discrepancy with an explanation beside it, so the discrepancy is documented and not erased. **The ledger is the corrected record of account**; `git log` remains the record of what was done, including what was done wrongly. v1.33 carries no such note and needs none, because its subject and its tag already read 2026-08-21: only its date column was wrong. That asymmetry is stated here rather than left for a reader to read as an oversight. **The check.** `scripts/validate_ledger_dates.py` compares every row's date column against the author date of the commit that published that version. The mapping is derived from the repository and is held nowhere in the check: an annotated tag where one exists, a search of commit subjects where one does not, with a draft subject never resolving as a publication and an ambiguous subject search refusing to resolve rather than picking. The method that resolved each version is reported, because a tag is a deliberate act and a subject match is an inference from prose, and a maintainer reading a disagreement needs to know which they are being shown. **The comparison is made in the commit's own recorded offset**, and that is the decision the instrument turns on: v1.33's publish commit is 2026-08-20 in UTC, so a check reading UTC would have certified the false row as correct in exactly the case hardest to see. **Three outcomes are kept apart.** A version the ledger declares drafted is an **exclusion**, because a version awaiting its owner push has no publish commit by construction and a gap that can never close trains a reader to stop reading gaps. A version with no resolvable publish commit is a **stated coverage gap**, printed on every run including a passing one, named, and folded into the verdict in neither direction. Everything else is **compared**. The check refuses rather than passes on an unreadable ledger, a missing version-history heading, an empty table, an unparsable row, an unusable git, or an empty resolution set. **The sweep, recorded so the next maintainer inherits the measurement rather than repeating it.** All 47 rows: 26 compared (22 resolved by tag, 4 by commit subject), 1 excluded as drafted (v1.23), and 20 unresolved (v1.0 through v1.15, which predate both tagging and the `vX.Y:` subject convention, plus v1.20, v1.21, v1.24 and v1.25, which published inside a later version's commit and have none of their own). That 20-version gap is **structural**: no test reaches it and no repair closes it, and attributing v1.20 to v1.22's commit because they published together would be the check inventing the evidence it was written to demand. **Both directions proved** (`tests/test_ledger_dates.sh`): run against published `main` at `a2756e2` before the correction it fails and names both rows with all four dates, reporting exactly two disagreements so the failure is selective; run after, it passes with its coverage stated; a fixture altering one real date by one day fires and a fixture whose dates all agree does not; a version with no tag is required to resolve through its commit subject with the method reported; the offset is pinned by requiring v1.33 to read 2026-08-21 and not the UTC day; and seven refusal cases each assert the refusal status and a line saying what could not be evaluated. **The cause, closed in the ritual.** Step 2 of *Publishing a version* now derives both the date column and the stamp from the publishing commit in one act, and `agents/km-hub-builder/SKILL.md` says the same to the drafting agent. Four pieces of evidence stand behind it: v1.40, a brief's date carried into both fields; v1.33, the stamp derived and the column left behind; v1.45, caught before publication only because a drafting agent checked three independent pieces of evidence against each other; and the sweep run afterwards to find this very class, which compared each publish commit's subject date against that same commit's timestamp, a pair that agrees by construction, and reported clean over a row that was wrong. That last one is the strongest, because it shows the class surviving an inspection that was specifically looking for it, which is the structural limit the v1.30 row states met in a new place. **The limit, stated rather than deferred.** The check reads the date column and not the stamp prose inside a row, which is written in several forms across the ledger's history and would make the instrument a prose validator with a far larger false-positive surface. That cost is real and it is precisely the half of the v1.33 row that happened to be correct. The ritual answers it and the check does not. Nor does the check know whether a resolved commit is the right commit, whether a row describes what its version did, or whether a version was published and given no row at all. |
| v1.48 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). Three fork-facing documents said something this system does not do. **Why the class was taken now, and taken together.** This repository is about to be forked and handed to an external party. A fork carries its documents as they stand to readers with no access to the session, the estate, or anyone who can correct them, so a page describing a capability the system does not have travels as fact and is unanswerable. The three findings are one class, and it is the class this remediation has already repaired three times: v1.42 found published sections telling readers a binding obligation bound nothing, v1.45 found published text naming a document no reader could open, v1.47 found published rows naming days on which nothing happened. They are repaired in one version because they are one class, not because they are individually small. **F-08, the hub template landing page, and it is the one that multiplies.** `template/README.md` line 64 read, verbatim: *"Run `bash hub-scan.sh` at the start of every session. It checks all four rules in one pass."* The standard has defined six rules since v1.22, verified first-hand from its own six `### Rule N:` headings rather than from the finding, and the page's summary list carried four entries. This page is copied verbatim into every hub `/km-init` creates, so the statement is one wrong page per hub rather than one wrong page, and the count grows with adoption. **The finding's second claim was verified before it was repaired, and it holds wider than stated.** Line 78 read: *"**Find a fact:** open the relevant numbered doc, or ask the agent to search across hub docs"*, while the standard's model is one entity note per instance with the numbered documents as narrative rollups, and the same template's own `06_risks-decisions.md` already says so in its body and its frontmatter: *"Individual risks and decisions are tracked as entity notes in `risks/` and `decisions/`, this doc is the narrative rollup."* Looking rather than reading the finding found the larger half: the page's supporting-structure table listed seven paths and named **none** of the eight entity-note folders the template physically ships (`decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/`, `corrections/`, `relationships/`, `claims/`), so the page did not merely point at the wrong place, it never mentioned the right one, and repairing the line alone would have left the page teaching the older model. **The repair** extends the summary to all six rules in the standard's own words, replaces the scan sentence with one naming which rules the scan actually checks, repairs the fact-finding line, and adds the entity folders to the supporting table. The numbered-document table is untouched, because it is true. **F-11, the overstated enforcement claim, and both halves were verified here rather than taken from the report.** This document read: *"A lightweight governance layer sits on top of the format. It enforces six rules that prevent the hub from drifting into an uncontrolled, unreliable state."* First half: `template/hub-scan.sh` ships seventeen blocks; rules 1 to 4 have one each (`[ INBOX ]`, `[ PROPOSALS ]`, `[ INTEGRITY ]`, `[ FRONTMATTER ]`), rule 6's outbound half has `[ RESTRICTED ]`, and **rule 5 has none**. `[ FRONTMATTER ]` reads `type:` and never `resource:`, which Rule 5 names as one of its own rails. The standard already contradicted itself two thousand lines away, where §"Validating the graph" says *"Governance (Rules 1-4) was enforced by `hub-scan.sh` from the start"*, and that narrower sentence is the true one. Second half: `DESIGN-RATIONALE_akcp-component-mining.md` says it in the repository's own words, *"a source-traceability rule enforced by *discipline*... Nothing records *lineage* (where each fact came from) as a checkable artifact."* **One nuance the finding does not mention is recorded rather than smoothed over:** `[ SHAPE ]` does require `evidencedBy` on a `Claim` note and `assertion_method` on a `RelationshipAssertion`. That is field presence on two optional entity types, never a verdict about whether a fact in settled prose has an origin, and reporting it as partial Rule 5 enforcement would be the same overstatement in a smaller size. **The repair narrows the claim and withdraws no obligation:** the lead sentence now states six rules and enforces four, a new paragraph names which instrument covers which rule and says plainly that Rule 5 has none, and it states that Rule 5 binds exactly as the other five do. **No Rule 5 instrument is invented here**, deliberately: a lineage artifact, its format, its generator, its gate and an adoption path for every existing hub is a change of a different size with its own authority. **F-12, the architecture documents, and the decision is to label.** `docs/architecture/README.md` read: *"These documents describe the architecture the KM Standard implements as of **v1.22**"*, and the root README's row read, with no version qualifier of any kind: *"Architecture documentation: the layer model, the canonical-first hub deployment protocol, the OrganizationProfile contract, and authority boundaries. Descriptive, not normative."* Checked against the ledger, at least nine surfaces have been added or materially changed since v1.22: the cockpit, the projection contract's four gates, the three-surface model and the owner queue, the supervisor threshold and minimum tier, hub merge, editions, the Reader tier and scoped reader, the MCP quarantine, and the release gate. **The set is labelled a historical v1.22 snapshot rather than refreshed, and the reason belongs in this row.** Refreshing six architecture pages to describe nine later surfaces is a substantial authoring job consisting entirely of new prose about the current system, and it would ride unreviewed inside a change whose whole discipline is to quote a false statement and repair it minimally; it would be the largest and least examined part of a documentation-truth version, which is the shape of change this remediation exists to stop. A snapshot honestly labelled is **true**; a snapshot presented as current is not, and the pages are not wrong about v1.22. This is also the posture v1.45 took when it refused to rewrite a dated design record to agree with the present. **The label travels to the link**, because the reader who needs it arrives from somewhere else and a disclaimer behind the link is not read by the reader who follows the link: the architecture index gains a banner naming the version, stating that it is not maintained forward, listing the nine surfaces it does not cover and pointing at `STANDARD.md`; its frontmatter description, which asserted the same thing in the field an agent reads, is corrected; and the root README's row carries the label where the reader meets it. **The check, and it is added only where one is possible and honest.** `scripts/validate_template_rule_summary.py` derives the rule set from this document's own `### Rule N:` headings, holding no rule count, list or name in its own source, so a rule added or renumbered changes its answer with no edit to the instrument. It has two independent arms: one requires a summary entry on the landing page per rule derived, and one requires any count written immediately before the word "rules" on that page to equal the number derived. The arms are separate on purpose, because a maintainer who extends the list and leaves the sentence has repaired the visible half and shipped the other, which is the defect surviving its own repair. **Scope is the landing page alone and that is a declaration:** a tree-wide sweep for count phrases finds this document (the home of record it derives from), the v1.0 ledger row and RFC-001 (dated records correct when written, which "correcting" would falsify), and the architecture set (already at six); widening the arm would fire on the dated records and the only remedy would be an exemption list, which is the artifact class the derivation exists to avoid. It **refuses** rather than passes on an unreadable standard or landing page, a standard yielding no rule heading, a page with no governance-rule summary heading, and a summary yielding no numbered entry. It **states its coverage** on a passing run in rules derived, entries found, entries matched and count phrases judged, and reports a page stating no count as an arm that judged nothing rather than as a pass. **Both directions proved** (`tests/test_template_rule_summary.sh`, ten cases): a missing entry fires and is named; a page carrying every entry with a wrong count phrase fires on the count arm alone, so the arms are proved independent; a page right in both arms does **not** fire, since a check firing on everything proves as little as one firing on nothing; one unchanged landing page passes against a six-rule fixture standard and fails against a seven-rule one, which is what proves the set is derived rather than held; a numeral count is judged like a spelled-out one; an entry numbered for a rule the standard does not define is caught, so the comparison runs both ways; and five unevaluable inputs refuse rather than returning a clean verdict. **Run against the unrepaired tree**, published `main` at `62c4e51`, with both inputs read out of git rather than rebuilt, the check exits 1 and names three real statements: no summary entry for Rule 5, none for Rule 6, and `template/README.md:64` asserting 4 rules where the standard defines 6, with coverage of 6 rules derived, 4 entries found, 4 matched, 1 count phrase judged. The whole suite was run against the unrepaired repository first, where every case passed except the real-tree case, which failed naming all three; that failure is the suite-level negative direction and it was recorded before any repair entered the working tree. **F-11 and F-12 are covered by no check, stated plainly rather than implied away by a green gate.** An enforcement claim is prose about what other instruments do, and a check reading it would need a list of those instruments beside it, which is the hand-maintained memory again, and would model whether the sentence was edited rather than whether it is true. Whether a descriptive set still describes the system is the judgement no evidence in the tree represents, and a check comparing its stated version against the current one would fire permanently and by construction, which is a gate that gets switched off and takes the real checks with it. Both are verified by reading, recorded here, and held by a reader. **The generalised rule** is grafted into the Standard Maintainer section beside its instrument siblings: a document is held to what the system does; a document a deployment installs carries its false statement into every deployment and is weighed by its installations; an enumeration is derived and checked while a judgement is narrowed and declared uncovered; and a descriptive set that has stopped tracking the system is labelled wherever it is linked rather than silently refreshed. **One further stale statement is reported and left:** `template/README.md` line 66 reads *"Full governance reference: AI KM Hub Standard (available from the hub owner)"*, naming a document that does not exist under that name and a person a fork's reader does not have. It is plausibly the same class, it is not one of the two claims the finding names, and repairing it on the maintainer's own initiative inside a change whose discipline is minimality is how a truth repair becomes a rewrite; it is named here for the next version. **Stated limits:** the check models the landing page's rule enumeration and rule count and nothing else, so it says nothing about whether an entry describes its rule correctly, whether anything else on the page is true, whether the narrowed enforcement claim is right, or whether a descriptive set is current; terminology quality is a judgement and is deliberately not scored; the count arm is a prose pattern and a count written in a form it does not read is reported as no count found rather than as a pass; the snapshot label names a version rather than a currency, so it cannot go stale, while the list of what has changed since is written as of v1.48 and dated by this row; and proving both directions proves the check fires on the class it models, never that it models the right class. **One deployment surface changes,** `template/README.md`. A hub that already installed it keeps the four-rule page until it refreshes it, which is an adoption act under that hub's own governance; re-pinning rewrites no installed file. No hub turns red: the new check runs in this repository against the template, and no hub runs it. |
| v1.49 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The repository's licence claim is made honest, and the record behind nine remediation packages is committed. Closes audit finding **F-07**. **The false statement, quoted as it stood.** `README.md` line 111 read, verbatim: *"This standard is free to adopt, adapt, fork, and redistribute for any organization's internal or external knowledge management needs. No attribution required."* The tree holds no `LICENSE`, `COPYING` or equivalent file, verified by listing for each of those names rather than taken from the finding's word, so default copyright applies and the advertised grant is not the effective grant. The same claim stood on three further surfaces: the badge image `assets/badges/license.svg`, which read `license: free to adopt`; the README `alt` text, which repeated it; and this document, twice, in its closing line (*"free to adopt, adapt, and redistribute for any team, company, or individual's knowledge management needs"*) and in one clause of the editions section (*"a license-neutral description of a boundary that anyone may adopt for free"*). Repairing the README alone would have left the normative document making the claim the README had just withdrawn. **The owner has not chosen a licence, and none is chosen here.** This is the shape of the repair rather than a gap in it. Three moves were available: add a permissive licence matching the intent, which would be the maintainer choosing the grant, the warranty position and the patent position on the owner's behalf, and it is his decision and a legal one; delete the reuse paragraph, which would withdraw an intent the owner holds and return the tree to the silence that produced the finding; or state both halves. The third is taken. **Free adoption is preserved word for word and named as intent**, and what is withdrawn is only the implication that intent alone is operative. The repaired section leads with the operative fact, because a reader who reads one sentence should read the one that governs: no licence has been declared, so default copyright applies and no reuse grant is in force; intent may be relied on as direction and never as permission; the decision is open and it belongs to the repository owner. The badge reads `license: pending`, which is honest in both directions, saying that nothing is in force and that a decision is expected rather than refused, and the README `alt` text matches it. Nothing written here is legal advice, and the repaired text says so. **The record of the outstanding decision sits in the editions section**, §"The boundary asserts no license", because that is where this standard already speaks about licensing and already hard-requires that it assert none. A note recording the state of one repository sits inside that requirement rather than against it, and it says so in its own words, so a later reader does not have to work out whether the section has begun asserting the thing it forbids. **The remediation record is committed, in `72b61ba`:** thirty-seven files across nine change packages under `openspec/` (332,202 bytes), 5,573 lines with the ignore rule below. They are the governance record of what was proposed across nine versions, and leaving them untracked leaves that reasoning in a directory a fork does not carry. **The external QA report of 2026-08-22 that those packages name as their source is deliberately not committed, and the reason is the most interesting thing this version found.** That material had never been scanned by anything: the canonical instrument enumerates tracked files and these were untracked, so they sat outside every previous scan's scope by construction. Scanned before staging against the deployment's generated denylist (762 entries, generated 2026-08-23) with the pre-push hook's own matching semantics, whole-word, case-insensitive for the 750 case-insensitive entries and case-sensitive for the 10 case-sensitive ones: **`openspec/` is clean, zero hits on both halves across all forty files, and the report produces one case-insensitive hit.** A single word in one heading is a client entity name in the deployment's semantic layer and an ordinary English verb in the sentence where it stands. **A fail-closed leakage guard can refuse a document that is not leaking, and this is the record of what to do when it does.** The guard is not wrong. It is whole-word and fail-closed precisely because no one reads several hundred denylist entries against a diff by eye, and it cannot tell two senses of a word apart; refusing a document that is not leaking is the expected cost of a control that never lets one through quietly. Four resolutions were available and three were refused. **Editing the report so the scan passes** alters external evidence, and altering a document to satisfy the control that examines it inverts what the control is for. **Exempting the term or narrowing the guard** buys one push and spends a permanent protection, because the exemption then covers every later document that uses that name in its real sense. **Dropping the report while leaving citations that name it** recreates the dangling-reference class v1.45 published a check to close. **Keeping the report out, committing the record, and repairing the citations** costs least and hides nothing, and it is what was done. Three things follow. The ignore rule is **committed this time, with its reason in a comment**, because it had never been in the committed file and the exclusion therefore depended on one machine's working tree and would not have survived a clone; a reader who wonders why the audit is absent now finds the answer in the rule rather than nowhere. Every reference in the new package **describes an external report of that date held in the deployment's records and names no path a reader would try to open**, and the nine existing packages were checked rather than assumed and already did the same, so none of them needed editing. And the two commits of this version were **rebuilt from `main` rather than corrected forward**, because the hook scans the diff of every outgoing commit, so a blob committed once and deleted later is still transmitted and still refused; neither commit had been pushed, so the rebuild was available. The denylisted term is **deliberately not named anywhere in this repository**, including in this row, so that recording the finding does not create the occurrence the finding is about. The nine existing packages are otherwise left exactly as they are, including the one that poses the tracking decision as still open: a record edited to agree with the present is no longer a record, and this row is where the resolution belongs. Every other ignore rule, including `outputs/` and `work/`, is untouched. **One further stale statement is repaired.** `template/README.md` line 73 read: *"Full governance reference: AI KM Hub Standard (available from the hub owner)."* No document exists under that name anywhere in the tree, and "available from the hub owner" names a person a fork's reader does not have. The v1.48 agent found it, declined to fold it into a change whose discipline was minimality, and recorded it for this version. The line now names `STANDARD.md` and points at the hub's own `km-deployment.md` for the version, revision and source of the repository the hub was created from, which is a route a fork's reader can walk. **No check is added, and the argument is recorded rather than left as an omission.** Three candidates were considered. A check requiring a `LICENSE` file wherever the README claims a grant is the one instrument that would have caught F-07, and it cannot be added while no licence exists, because it would be red on the repaired tree from the moment it landed; a check red by construction is a check that gets switched off and takes the real checks with it, so it is named for the day a licence is declared. A check forbidding grant-shaped wording models word choice rather than truth, and would fire on the repaired README, which correctly still contains the words "free to adopt, adapt, fork, and redistribute" as a statement of intent. And `scripts/validate_rfc_references.py` **does not** cover the class Part C repairs, checked rather than assumed: it derives its known set from the filenames in `rfcs/` and matches a bare `RFC-NNN`, a code-formatted `rfcs/RFC-NNN`, and a path naming a file. "AI KM Hub Standard" is none of those, so that check was green over line 73 for as long as the line existed and is green over it now. The general class, a document named in prose by title rather than by path, has no directory to derive a known set from, so any check over it would carry a hand-maintained list of acceptable names, which is the artifact class this repository has already recorded as the one that rots. **The OpenSpec package carries no delta spec**, `openspec/changes/audit-licence-honesty-and-record/`, and `openspec validate --strict` fails for want of deltas. That is the honest outcome and it is recorded rather than worked around: this change adds no requirement. Each repair is an instance of a rule already published here, the v1.48 rule that a document is held to what the system does and the v1.45 rule that a reference is a promise the reader can open the thing named. Writing a delta would mean restating a published requirement as though it were new, which puts one obligation in two places and guarantees they diverge, or inventing a licence-shaped requirement, which is exactly the assertion the editions section forbids. **Stated limits.** Nothing in the tree can keep `license: pending` honest if no decision is ever made; only the owner can. No instrument reaches either prose repair, so both are held by a reader rather than by a check. The green release gate does not mean the push is free of organisation leakage, since the denylist that scan needs is generated outside this repository by design and only the deployment's own pre-push hook scans an actual push, and here that scan has a known hit awaiting the owner's inspection. And no runner supplies a second actor: the change was verified by the agent that wrote it, and an adversarial pass by someone else has not taken place. |
| v1.50 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The design record states what became of every proposal in it. Closes audit finding **F-09**. **Why the class was taken now.** This repository is about to be forked and handed to an external party. A fork carries the design record to readers who cannot ask anyone which proposals are live, which have been implemented and which bind nothing, and today the repository answers that question on three surfaces and gets it wrong on all three. **The false statements, quoted as they stood.** `assets/badges/rfcs.svg` rendered *"2 adopted"* and `README.md` line 15 carried *"RFCs: 2 adopted"* as the image's `alt` text, over a directory holding **seven** RFCs of which the ledger itself records three as implemented. `rfcs/` held seven `RFC-*.md` files and **no index at all**, while the landing page's own navigation badge sends a reader to that directory. `README.md` line 70 described RFC-001 and RFC-002 and stopped, so five of seven were invisible to a reader of the package overview. RFC-004's banner read *"Status: DRAFT — design document only. As with RFC-003, **no normative edits ride this RFC**"* while v1.32 implemented its Part I and v1.35 its Part II; RFC-006's read *"no normative edits ride this RFC"* while v1.39 implemented the editions model; RFC-007's read the same while v1.41 implemented the Reader tier. **The disposition derived first-hand, from this ledger rather than from the report.** RFC-001 `ADOPTED` by v1.22. RFC-002 `DRAFT`: v1.23 has never published. RFC-003 `DESIGN ONLY`, unimplemented and referenced by no version. RFC-004 `PARTIALLY ADOPTED`: Part I by v1.32, Part II by v1.35, Part III unadopted with its own verdict of *premature* standing, its reading (c) later taking concrete form as v1.39's Consumer edition while readings (a) and (b) are untouched. RFC-005 `DESIGN ONLY`, landed on the published branch by v1.45 as design only. RFC-006 `ADOPTED` by v1.39. RFC-007 `ADOPTED` by v1.41. **Three of the report's own statements did not survive verification, and each is published rather than dropped.** Its pairing of the badge with RFC-002 is wrong: **RFC-002's `DRAFT` is true**, evidenced by the absence of a `v1.23` tag, by the draft declaration that opens the v1.23 row of this ledger, by this document's lead, and by the merge commit that published v1.22 recording that v1.23 rides as draft; that banner is left word for word, and a remediation taken on trust would have falsified it. **RFC-005 is neither absent nor stale**, having landed under v1.45 with its banner corrected then. And the report **does not mention RFC-007**, whose banner carried the identical false sentence; it is repaired here. **The repair.** `rfcs/README.md` is added: one row per RFC carrying identifier, title, status in a four-term vocabulary the page defines, the implementing version or versions, the decision date where one exists, relationships, and the narrowing each implementation recorded. `DRAFT` and `DESIGN ONLY` are kept apart deliberately, because normative text written and waiting on a push is not the same state as no text at all. Three banners gain a dated status note and **not one word of any design body, verdict, provenance tag, open question or argument changes**, on v1.45's rule that a dated record corrected to agree with the present is falsified rather than repaired; where an implementation narrowed a design the note names the narrowing, quoted from what the implementing version itself recorded. RFC-004's Part I addendum, dated 2026-08-20 and describing v1.32 as then unpublished, is **deliberately not refreshed**, and the new note says so. **The badge is generated, and that is the answer to how the count is kept true**: `scripts/validate_rfc_lifecycle.py --write-badge` renders it from the index, the same file's validating run asserts that the committed badge and the `alt` text beside it are byte-equal to what it would render, and the release gate runs that validating half, so a hand-edited badge, a stale `alt`, or a status changed without regeneration each fail the gate. It now reads `3 adopted, 1 partial, 3 open`. **The check** derives the RFC set from the directory, the implementation facts from this table, and the count from the index, and holds no list of any of the three. A missing index **fails** while a present but unparsable one **refuses**, because the directory was read in the first case and was not evaluated in the second, and folding them together would have silenced the badge arm in the one run that has to name the false count. **Both directions proved** (`tests/test_rfc_lifecycle_index.sh`, 26 cases): eight firing cases, one per class; a non-firing case; two derivation cases that hold the index still while a file is added to a fixture directory and a row to a fixture ledger, which a check holding its own list would pass twice; twelve refusal cases; a round trip proving the generator and the validator are one derivation; and **the evidence case against published `main` at `d0482ec`, extracted from git rather than rebuilt, where the check names eleven statements**: seven RFCs uncovered by a missing index, the three stale banners with v1.35, v1.39 and v1.41, and the badge reading `2 adopted` while the ledger records three RFCs as implemented. The suite run against the unrepaired tree fails there on the real-tree case, so it is known to detect the defect rather than to agree with the repaired tree. **Stated limits.** The ledger derivation is a **lower bound**: the v1.22 row records RFC-001's adoption as "Full rationale ... in `rfcs/RFC-001-sor-gateway.md`" and the v1.32 row records RFC-004 Part I as "designed in `rfcs/RFC-004`", neither carrying an implementation verb, so neither is in the derived set and both are carried by the index under a maintainer's judgement; widening the pattern until it caught them would also catch the v1.45 row, which names an RFC while recounting a repair and implements nothing. Whether an index entry describes a narrowing correctly is reached by no arm, and an instrument over it would model whether the sentence had been edited. Proving both directions proves the check fires on the classes it models, never that it models the right ones. Nothing a deployment installs changes, so no hub turns red. |
| v1.51 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The one executable this standard ships runs on a host it was not written on, and names the hosts it was. Closes audit finding **F-10**. **Why the class was taken now.** This repository is about to be forked. `tools/km-publish.sh` is one of the few pieces of executable tooling the standard ships, a fork hands it to operators who cannot ask anyone why it failed, and as it stood it ran on exactly one class of machine and told everyone else to run a command that does not exist there. **The defects, quoted as they stood, each verified first-hand against published `main` at `44622d5` rather than taken from the report.** Discovery was one hardcoded glob: `BREWPY="$(ls -1 /opt/homebrew/bin/python3.1* 2>/dev/null | grep -v config | tail -1 || true)"`. `/opt/homebrew` is the Apple Silicon Homebrew prefix; Intel macOS Homebrew installs under `/usr/local`, Linux has no Homebrew prefix at all, and nothing else was consulted, so a usable interpreter first on `PATH` was never seen. The refusal read `ERROR: no Homebrew python3. One-off setup:  brew install python@3.12 pango gdk-pixbuf libffi` and **exited 1**, so a host with no Python and a document that reintroduced a corrected defect returned the same status. The install was unpinned, `"$VENV/bin/pip" install --quiet weasyprint`, which is the shape that quarantined the MCP surface at v1.40 after an unpinned install resolved to a major version whose interface the code did not use. The environment was built inside the repository at `VENV="$TOOLS/.venv"` and was covered by no ignore rule in either tree, `git check-ignore -v tools/.venv` exiting 1 with no output. `template/hub-scan.sh` matched `.venv` **zero** times, so a fixture hub carrying `tools/.venv/` reported `?? tools/.venv/` under `! UNCOMMITTED OR UNTRACKED MONITORED FILES` in its `[ INTEGRITY ]` block, and a hub that rendered one document failed its own session-start scan every session afterwards, where the remedy an operator reaches for is committing a virtual environment into a governed hub. And `pdfinfo` and `pdftotext` were called with no presence check. **The repair.** Discovery is an explicit `KM_PUBLISH_PYTHON` override, then `PATH` newest-first, then the conventional prefixes, and an override that cannot work is refused by name and never searched past. Two questions are asked of a candidate rather than one, the version and the ability to create an environment, because several distributions ship a `python3` that fails at `ensurepip` and reports it as a problem with something else. The floor is **CPython 3.10**, read out of the pinned distribution's own `Requires-Python` metadata rather than assumed; on the authoring host `/usr/bin/python3` is 3.9.6 and is refused while `/opt/homebrew/bin/python3.12` is accepted. The pin is one named variable with the reason beside it, and an environment carrying any other version is rebuilt. Refusals name the platform, the requirement, what was searched and the override, with install guidance selected by platform; the macOS SIP note from the old message is real knowledge and is kept, in the macOS branch where it is worth reading rather than shown to every operator as the whole diagnosis. `pdftotext` is a refusal when the source has a guards sidecar, since guards are applied to extracted text, and `pdfinfo` is a named warning with the page count and any `PAGES` rule reported as unevaluated, because `PAGES` is a warning rule by contract. An environment the build cannot be performed in exits **2**, never 1. **`--preflight` is what makes any of this testable**: before it, reaching the bootstrap required a render, and a render that succeeds leaves an environment behind that stops the branch ever running again on that machine, which is how five defects accumulated in nine lines with no check able to reach them. **The environment leaves the tree, and the decision is stated rather than implied.** It is built under the user's cache directory, keyed by the pinned version, relocatable with `KM_PUBLISH_VENV`. Out-of-tree was chosen over ignoring it in place for one reason, and it is adoption rather than taste: an ignore rule has to reach every tree the tool can run in, including hubs created before this version whose ignore file is a copy of the old one, and a deployment that misses that adoption action fails its own session-start scan, while moving the directory repairs every tree at once. The ignore rules and the scan exemptions are added **as well**, because `KM_PUBLISH_VENV` lets an operator legitimately point the environment back inside a tree and because a hub that already ran the old publisher has one sitting there today that no new tool removes. The pathspec spelling is the one **proved** to exclude against the git that runs the scan rather than the one that reads best: `':(exclude)*/.venv'` and `':(exclude)*/.venv/'` each excluded nothing while producing no error, which is the silent-inertness class the guard runner's boundary probe exists to catch and which looks exactly like a clean tree, and `':(exclude,glob)**/.venv'` with its `/**` partner excludes both a nested and a root-level directory. The `[ LINKS ]` note-index walk and the restricted-surface walk are excluded too, because the pinned renderer's environment carries two `LICENSE.md` files under site-packages and a vendored licence in a hub's note index is a name a hub wiki-link can resolve against. **Platform support, claimed only where it was exercised.** macOS on Apple Silicon: discovery, the pin and an end-to-end render with guards applied to the extracted text, all run in this session. Linux, Intel macOS and every other Unix host: **written and unverified**, portable by construction and not run on any of them, and the tool, the skill and this row each say so rather than implying otherwise. Native Windows: out of scope with its reason, WeasyPrint's native library stack there being a separate problem this change does not take. **Both directions, and three unrepaired-tree runs** (`tests/test_km_publish_portability.sh`, 22 assertions, 0 coverage gaps). Each unrepaired artifact is extracted from `44622d5` rather than rebuilt, and each is paired with the repaired tree on the same input, which is what makes it evidence: the old publisher, driven with `ls` shimmed to return nothing while a usable `python3.12` stands first on `PATH`, exits 1 with the Homebrew message and never looks at `PATH`, where the repaired tool resolves; the old scan, over a fixture hub whose ignore file is also the old one, names the environment directory in its `[ INTEGRITY ]` block, where the repaired scan does not; and the old note-index walk indexes 23 names against the repaired walk's 22 with a vendored licence in place. The non-firing direction is proved for both exclusions: the repaired scan still reports a genuinely untracked monitored document, and still indexes a note added outside the environment, so neither exclusion blinded its block. Two cases are produced by a one-line fixture edit to a copy of the tool, named in the case so a reader can weigh it, one replacing the candidate name list and one emptying the prefix list; everything else is the real `PATH`, the real prefixes, the real git and the real scan. **What remains unproved, stated rather than deferred.** No Linux, Intel macOS or other Unix host was available in this session, so every claim about those platforms is written and unverified, and the install guidance printed on them is unverified with them. Whether the conventional prefix list is right for a distribution nobody here ran is reached by no case. The canaries prove refusal and resolution on the class of environment they model, on one host; they cannot prove a render on a host this session did not have, and a canary is blind to a defect whose shape its fixture cannot represent. Proving both directions proves the suite fires on the classes it models, never that it models the right ones. **Adoption.** A hub takes the new `template/hub-scan.sh` and the new ignore rule with its next standard adoption; until it does, an environment already inside its tree still trips its scan, and the repaired tool no longer puts one there. |
| v1.52 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). A status is read where a status is declared, and quoted everywhere else. **The defect.** `scripts/validate_published_not_draft.py` and `scripts/validate_ledger_dates.py` each held the same pattern, byte for byte, matching an emphasised `DRAFT` or a `DRAFT` followed by `awaiting owner push`, and each applied it with `search` across a whole version-history row, while the first instrument's own docstring said something narrower and correct: a row is unpublished when its description **opens with** a draft declaration. The prose described the class; the code matched the token anywhere. The two copies were identical, neither imported anything from the other, and they did not even search the same slice of the row, which is what a copied rule looks like just before it diverges. **The measured consequence, taken during the v1.50 publish rather than theorised.** The v1.50 row argued that RFC-002's `DRAFT` status was true and evidenced that by reproducing the v1.23 row's own `**DRAFT — awaiting owner push**` verbatim, mid-description. From the moment that row's own opening was flipped to `Drafted and published 2026-08-24 (owner push).`, which is the single edit a publishing commit makes, the quotation went on classifying v1.50 as a version still awaiting its push. `validate_ledger_dates.py` reported `2 excluded as drafted, v1.23, v1.50` and therefore never opened v1.50's date column. `validate_published_not_draft.py` reported `49 published, 2 unpublished` and therefore exempted every draft marking naming v1.50 from judgement, which is the arm that catches a publishing commit failing to clear its own markings; that state, reconstructed here from the tree at `1444b15`, holds **three real stale markings** the exemption hid, in the lead paragraph and twice in the drafted section body. **Both instruments returned PASS. Two green checks, both blind, over an incomplete publication, and the blindness was caused by house practice rather than by an unusual input**: quoting the text a rule governs is what this repository does constantly, in version rows, in check docstrings and in canary fixtures, so the class reaches every fork with the checks. The v1.50 row published only because the quotation was paraphrased out at publication time, which is a repair of the document to fit the instrument; **the current tree therefore passes and proves nothing**, and a pattern narrowed until it went green would pass equally, as would a pattern that had stopped matching entirely. **The repair.** The rule is **anchored**: a row is unpublished when its **description cell opens with** a declaration, tolerating leading whitespace and emphasis markers and nothing else, and a declaration reproduced further along the same cell is a quotation carrying no status. The tolerances are derived from the openers the ledger actually uses, the em dash form v1.23 carries, the comma form the v1.50 and v1.51 drafts carried, the bare form the docstring documented, against the two published forms, `Drafted and published <date> (owner push).` and `Drafted <date>; published <date> with <version>.` An unrecognised opener classifies as published, which is the strict direction in both instruments and is stated as such rather than left to be discovered. **The rule now has one home**, `scripts/publication_status.py`, which both instruments import and neither duplicates; it also splits the row, because the published-not-draft check was passing the date column into the classification and an anchored rule applied to that string could never have matched. Unifying was the decision worth arguing: two files would have held three subtleties each, where the row is cut, what may precede the token and what case it carries, and this standard already records in three places that a rule written twice is two rules that agree today. `validate_ledger_dates.py`'s own docstring already claimed the convention had one home of record; the claim is now implemented rather than asserted. **Both directions, and the negative one is the whole proof.** `tests/test_publication_status_scope.sh` runs the same fixtures through the superseded pattern and requires the two to disagree on exactly the quoting case, so the suite detects the defect rather than agreeing with the repaired tree; `tests/test_published_not_draft.sh` case 11 and `tests/test_ledger_dates.sh` case 10 each prove a published row quoting a declaration and a drafted row quoting the same one, then run the real material at `1444b15` in both states, where v1.50 stays exempt while its own opener declares it and is judged the moment the opener alone is flipped, with a wrong date on that now-compared row caught as well, so the restored coverage is real rather than nominal. **This row quotes a declaration token itself, deliberately.** Doing so before the repair would have made the row unreadable to the instruments once it published; doing so after is the case the repair makes safe, and it leaves the proof standing in the ledger where the next publishing session will run it. **Stated limits.** Neither instrument can audit the version-history table, which is the only publication record the repository has, so a row claiming a publication nobody performed is agreed with as before. The paraphrase in the published v1.50 row is left exactly as it published, because a dated record is not rewritten to agree with the present. And proving both directions proves the classifier fires on the class it models, never that it models the right class; what changed is that the class it models is now the one the ritual writes. Nothing a deployment installs changes, so no hub turns red. |
| v1.53 | 2026-08-24 | Drafted and published 2026-08-24 (owner push). The repository declares a licence, and it is Apache-2.0. This closes the decision audit finding **F-07** opened and v1.49 made honest. **What was open, and who closed it.** v1.49 withdrew an advertised grant that no file in the tree supported, recorded that no `LICENSE`, `COPYING` or equivalent existed, that default copyright therefore applied, and that choosing a licence was the deployment owner's decision and not a maintainer's. It has now been made by him: asked what licence to adopt he accepted the recommendation of **Apache-2.0**, and asked directly he confirmed that **he is the author and the copyright holder**. Both answers are the owner's, given in the session that drafted this version, and this row records a decision rather than making one. **Why Apache-2.0 and not MIT or CC0.** The deciding property is the **express patent grant** of Section 3. This repository publishes a specification that other organizations implement, so an adopter needs patent certainty over the thing they are building to, and the licensor gains the defensive termination clause that ends the grant for an adopter who brings patent litigation over the work. MIT and CC0 give neither side any of that. Three further reasons stand behind it. Institutional legal review approves Apache-2.0 as routine, which matters because the likely adopters are large institutions and a licence that triggers a review is a licence that is not adopted. It does not obstruct the editions boundary published at v1.39: permissively licensing the run-set leaves a later commercial policy on the evolve-set open, which is precisely the freedom that section reserves to the owner and precisely what it declines to encode. And **one licence covers the whole repository** rather than splitting specification from code, because the tree interleaves them at every level: 147 markdown files and 41 code files **when the decision was taken**, with templates, skills and scaffolds being both at once, so any split would put the boundary through files rather than between them. *(The date qualifier is added in v1.56 and the measurement is not touched. Read without one, the number invited a present-tense reading it could never keep: the count was 147 on `main` when the design was written, 150 in the tree this version actually published, and 158 at v1.56, while the code figure is still 41. Refreshing a dated measurement would falsify it; dating it removes the false reading and cannot go stale. Nothing in this repository states the live figure in prose, and nothing needs to: the release gate counts the tree on every run.)* **What was built.** `LICENSE` at the root carries the complete Apache License 2.0, unmodified, verified before the copyright field was filled against the published SHA-256 of the canonical text (`cfc7749b`), with the Appendix boilerplate completed as the Appendix itself directs and no other byte touched. `NOTICE` carries the attribution notice Section 4(d) refers to, minimal, and the tree vendors no third-party material that would need more. `README.md` replaces the pending-licence section written at v1.49 with the grant in force, states in the licence's own section numbers what an adopter may rely on and what the licence asks in return, and names `LICENSE` as governing where the summary and the licence differ. `assets/badges/license.svg` reads `Apache-2.0` in place of `pending`, with the README `alt` text matched to it and the geometry and palette taken from the badges already in `assets/badges/`. **The claim that no attribution is required is withdrawn as false, and the withdrawal is part of this change rather than a consequence of it.** `README.md` had promised free adoption *"with no attribution required"* since the repository's first commit, and v1.49 preserved that sentence deliberately, as the owner's intent, because under default copyright it granted nothing either way. Under Apache-2.0 it is simply untrue: Section 4 makes preserving the copyright notice, the licence text and the `NOTICE` attribution a condition of the grant. A licence that says one thing while the landing page says the opposite is the F-07 class recreated in the act of closing it. **The distinction the section protects, stated so that nothing collapses it.** Two different things are called a licence in this repository. The **repository** now carries one. The **standard** asserts none, on any deployment, which is a hard requirement of *The boundary asserts no license* and is v1.39 doctrine unchanged in every word. Licensing this repository puts no licence, price or commercial term on any hub, estate or deployment that adopts the standard; the boundary, the component mapping and the two editions are identical to what v1.39 published. The section's note is rewritten in three paragraphs that keep the two apart on the page: the repository's licence, then the separation stated plainly as separate facts about separate objects, then the pre-v1.53 state kept as the record of what it replaced rather than deleted. The closing line of this document, repaired at v1.49 to say that no licence had been declared, is repaired again for the same reason it was repaired then, and it now carries both halves in one sentence. **No delta spec, argued.** `openspec/changes/audit-licence-declared/` carries a proposal, a design and tasks and no delta, so `openspec validate --strict` fails with *"Change must have at least one delta. No deltas found."* That is the honest outcome and it is recorded rather than answered by inventing a requirement. Declaring a licence for one repository imposes no rule on any deployment, and writing a delta here would mean the standard had begun asserting the licensing term this very section forbids. `audit-licence-honesty-and-record` and `audit-spec-filename-convention` are the precedents. **No check is added**, and the reason is the same one v1.49 recorded from the other side: a `LICENSE`-file check would now be green from the day it landed and would prove only that a file exists, never that the licence it names is the one the README, the badge and this section describe, which is the whole of the class. Nothing in the tree can keep a licence claim honest, and that is stated as a limit rather than filed as work deferred. **A push obstacle, and the first attempt to resolve it weakened a guard and was reverted.** The deployment's canonical leakage denylist carries the owner's own name, so the copyright line this version requires is matched by the fail-closed pre-push hook and the routine push is refused. The guard was working exactly as designed, and the name was never altered to evade it. **What was tried first is recorded rather than omitted, because it is the most useful sentence in this row for whoever reads it next.** The steward judged that the denylist needed a narrow exclusion for the owner's name and dispatched it without asking the owner; a security review flagged it as weakening the one control that tier's own contract names as never to be relaxed. The owner was then shown the exact change and its blast radius: four entries removed, and because the matcher is whole-word, the bare given name and the bare surname would have been unblocked for everyone rather than for him alone. **He chose to revert it.** The guard is fully intact, all four name forms are back on the denylist, which the generator emits at 760 entries over 762 lines, and the generator carries no owner exclusion; the revert is a commit rather than an erasure, so both the attempt and its reversal stay in history where a later maintainer can read them. **Publication was made instead under a one-time owner-authorised bypass of the hook**, on his reasoning that a single reviewed exception is a smaller hole than a standing one. **What replaced the automatic scan, because a bypass removes it.** The entire outgoing tree was scanned by hand against the full denylist, twice and independently: six case-insensitive whole-word hits and zero case-sensitive, every one of them the copyright notice itself or this change's own record of writing it, in `LICENSE`, `NOTICE`, `README.md` and three lines of the OpenSpec package. A control run with only the owner-name entries removed came back completely clean, which is what makes those six the whole story rather than the six someone happened to notice. **Verification and limits.** `python3 tools/km-release-gate.py` exits 0. The gate's stated limits are read into this row rather than deferred: it runs no organisation leakage scan and cannot, and it supplies no second actor. *(This row said the gate's **two** stated limits. It printed three on the day this version published, the third being that it reads a check's exit status without seeing inside it, which it had printed since v1.46; the row named two because the maintainer contract it was written under said two. The count was false when written rather than overtaken since, so it is corrected here under the v1.47 rule, and the contract that produced it no longer states a count. Corrected in v1.56.)* To those this version adds two of its own: that no instrument in this repository reads a licence, so every prose claim about the grant rests on a maintainer having read Apache-2.0 correctly, and that nothing here is legal advice and none of it was written by anyone qualified to give any. |
| v1.54 | 2026-08-25 | Drafted and published 2026-08-25 (owner push). The release gate discovers the tree it is being asked to judge. **The source is an external review**, the first pass over this repository by anyone outside the loop that authored it; it returned conditional fail with this as its single release blocker and the fork is held until it lands. **The defect.** `tools/km-release-gate.py` obtained its discovery set from `git_tracked()`, which runs `git ls-files` and therefore lists the **index**. `agents/km-hub-builder/SKILL.md` orders the release gate ahead of the numbered pre-commit list whose third item is explicit staging. So the gate was specified to run at the one moment a check authored in the change being gated is untracked, and a listing of the index cannot see it. This is not an unlucky edge; it is the documented ordering. **The measured reproduction, taken by the steward on the tree at `eb57f0f`.** Clean tree: `33 check(s) discovered`, `PASS release-gate`, exit `0`. Then `tests/test_zz_probe.sh` was written into the working tree, untracked, holding `this is not valid shell ((((`, which `bash -n` rejects with a syntax error. The gate reported `33 check(s) discovered`, `PASS release-gate`, exit `0`. The count did not move, `30 shell file(s) syntax-checked` in both runs, and the file was neither run nor named. A gate that cannot see a check cannot have run it, and this one said PASS. **The gap was known and left open, and that is the sharpest part of this row.** On 2026-08-24 the v1.48 drafting agent hit this exact behaviour, wrote that a gate which has not seen a check has not run it whatever its verdict says, worked around it by staging the new check before running the gate, and reported it as a limitation rather than repairing it. It was then reproduced independently by the external reviewer on 2026-08-25. Nothing about it was newly discovered here. **Why the gate's own canaries never caught it.** Every fixture in `tests/test_release_gate.sh` that introduces a new check file stages it with `git add` first: cases 7, 9, 10 and 17 all do. The workaround was written into the fixtures of the suite that exists to break this gate, so the untracked path was never exercised. That is the finding underneath the finding, and it is why the new cases stage nothing. **The shape chosen, of three, and it is the third.** The reviewer named two. Rejecting untracked check-shaped files and failing the gate is the smallest diff and it closes the measured case, but it never runs the new check, so the maintainer must stage to obtain any verdict; that is the v1.48 workaround promoted from a note in a report to a rule in an instrument, and it makes the gate refuse at the moment it is most needed. Requiring a clean or fully staged tree is the strongest guarantee available and it reddens ordinary editing, forces the published ritual to be rewritten from gate-then-stage to stage-then-gate for every change rather than for the check case, and pushes the contract's own pre-commit review step to after the gate rather than before it. **What was built instead is the union**: discovery reads tracked and untracked-not-ignored check-shaped files under the same roots, runs both, syntax-checks a discovered check before executing it, holds an untracked check to the ADDED declaration rule because it is one, names each untracked check on the run and counts them on the coverage line. **The trade accepted, stated rather than absorbed.** The verdict is now about the **working tree** rather than the committed tree, so a scratch file shaped like a check and sitting where checks live will be discovered, will be required to carry an unrepaired-tree declaration naming the drafted version, and will be executed. Someone will find that annoying and they will be right to. The answer is that this repository has no other convention for what a check is: the two directory names **are** the scope declaration, as the gate's own header already said. The asymmetry decides it. Explaining a scratch file costs a minute; a green gate over a check nobody ran costs a publication, and it had already cost the count in this row. Two smaller trades ride with it, that the gate now executes code which is not in the repository, and that `--no-suites` does not avoid the discovery and the syntax phases. **A second hole closed on the way.** An untracked check escaped the declaration phase entirely, because `git diff --name-only <base>` never names an untracked path, so the one file class the ADDED sub-rule exists for was the class it could not reach. The untracked discovered rels are now unioned into the changed set. **Both directions, and the negative one was run first.** Case 19 of `tests/test_release_gate.sh` was written before the repair existed and run against the unrepaired gate, where 8 of its 11 assertions failed and the suite exited 1: the untracked invalid check produced `expected exit 1, got 0`, and the coverage line said nothing about provenance. Two of the three that passed did so legitimately, 19c and the ignored-path gap 19j; 19g passed for the wrong reason, because the untracked check it declares was invisible. Against the repaired gate all 54 assertions of the suite pass and it exits 0. On the real repository the measured case now reports `34 check(s) discovered` and `FAIL release-gate: 2 finding(s)`, naming `tests/test_zz_probe.sh: shell syntax error` and `tests/test_zz_probe.sh: no km-unrepaired-tree declaration`; with the probe removed the same tree reports `33 check(s) discovered` and passes, so the repair did not widen what the gate runs on a tracked tree. **The contract moved with the instrument.** `agents/km-hub-builder/SKILL.md` now states that the gate discovers the working tree, that running it before staging is therefore correct, and that a new check must not be staged to make the gate notice it; it also says that if a future gate is narrowed back to the index the instruction is wrong and must move with it. `openspec/changes/audit-gate-discovery-scope/` carries the proposal, the design, the tasks and a delta under `release-verification-scope`, and `openspec validate --strict` passes. **Stated limits.** The gate's three existing limits are unchanged: it runs no organisation leakage scan and cannot, it supplies no second actor, and it reads a check's exit status without seeing inside it. A fourth is added rather than closed: discovery honours the ignore rules, so a check-shaped file under an ignored path is still not discovered, which means a path added to `.gitignore` leaves the gate by an edit to neither the gate nor the check. Case 19j pins that as a gap and not as a control. The JSON parse and relative-link phases stay index-scoped on purpose, so an unparseable untracked JSON file is still unseen; widening them would redden the gate on any half-written file. And proving both directions proves this instrument fires on the class it models, never that the class is the right one. **Independence, honestly.** This defect was found by a second actor and repaired by the first, so the repair itself has had no adversarial pass; the reviewer's own reproduction is the check on the finding, not on the fix. Nothing a deployment installs changes and no hub turns red. |
| v1.55 | 2026-08-25 | Drafted and published 2026-08-25 (owner push). Four defects found by an external reviewer, and two of them are one defect seen twice. **The source is the external review of 2026-08-25**, the first independent pass over this repository by anyone outside the loop that authored it. It returned conditional fail; its single release blocker landed as v1.54, and these are its four remaining P2 findings. Each was reproduced on the tree at `13dec55` before it was repaired, because three of the same reviewer's earlier findings did not survive verification and one of these might not have. **All four held.** **Finding 1, as it stood.** `tests/test_skill_frontmatter.sh` confirmed that line 1 of a skill file is `---` and then extracted the block with `awk 'NR>1 && /^---$/{exit} NR>1'`, which runs to end of file when no closing delimiter exists. *Measured:* the closing `---` deleted from all three shipped copies of `skills/km-brief/SKILL.md`, the suite printed `PASS: every shipped skill file carries a conforming name/description frontmatter` and `ALL SKILL FRONTMATTER CHECKS PASSED`, exit 0. **The sweep of the same class**, five further malformations probed against the unrepaired check: a `...` terminator, a duplicated `name:`, a duplicated `description:` and an extra key all passed at exit 0 with zero violation lines; an empty block was already caught at exit 1 with six. **What the reviewer did not name, and it matters more.** Requiring merely that *a* closing delimiter exists is not enough, because every shipped skill file carries `---` horizontal rules in its prose: deleting the real terminator moves the closing delimiter down the document and the block swallows sixteen lines of body while both keys stay present and unique. Measured on the half-repaired check: exit 0. **As repaired:** the block must be terminated by `---` on its own line, no required key may be declared twice, and every line inside the block must read as a mapping entry, a continuation, a comment or a blank. Four new canaries; the extra-key case is **registered rather than repaired**, in the check's own header, because refusing `allowed-tools` and its kin is a policy decision about what a skill file may carry rather than a defect in how the check reads its input. **Finding 2, as it stood.** `tools/km-release-gate.py` ran `LINK_EXEMPT_RE.search(text)` over the **raw** markdown, before `strip_fenced` and with no anchor at all. *Measured:* `README.md` given a broken relative link and a fenced `text` block quoting `km-gate-link-exempt:` reported 0 link failures, `153 of 154 markdown files scanned, 1 exempt`, 88 links resolved; the same tree without the fenced example reported 1 failure naming the broken link and 113 links resolved. A quotation removed a document from the scan and 25 links from the count, at exit 0. **The first generalisation, and it is the more useful finding than the instance: this is the class v1.52 repaired, in one instrument, and left standing in another.** v1.52 found a quoted draft-declaration token silencing two publication checks and anchored the read to where the declaration is made. A directive read from raw text is a defect of the **reader**, so every reader of every directive token was in scope from that moment and only one was repaired. **What the sweep found.** Five machine-read tokens exist here. `km-unrepaired-tree:` and `km-gate-instrument:` are read from the leading comment block and were already anchored. `km-gate-link-exempt:` was raw and unanchored. And the anchor v1.52 itself chose, a 60-line leading window read raw, is reachable: *measured*, one sentence inserted at line 13 of `STANDARD.md` reading that a document opts out by writing the token exempted the **home of record** from `scripts/validate_published_not_draft.py`, which reported `122 file(s) scanned, 5 exempt` against a true 123 and 4, saw 3 draft markings instead of 9, and exited 0; the same sentence for `rfc-reference-exempt:` exempted it from `scripts/validate_rfc_references.py`, which reported 171 references across 130 files against a true 257 across 131, and 5 path references against a true 15, at exit 0. **As repaired:** one anchoring rule in all three readers. A token binds only where it begins its own line, after optional whitespace and at most one comment marker, and never inside a fenced block, and the gate's reader takes the 60-line leading window its two siblings already had. Both conditions are needed: line-anchoring alone admits a fenced example written at column zero, and fence-stripping alone admits the `STANDARD.md` sentence, which was not fenced. Every exemption currently declared in this repository still resolves, by name and reason, with the same counts. **Finding 3, as it stood.** `agents/km-hub-builder/tests/test-agent-package.sh` invoked `install-agent.sh --replace-existing` under `set -e` and asserted nothing afterwards. *Measured:* a branch added to the installer that prints both `Installed ...` lines and exits 0 without copying anything left the suite printing `agent package tests passed` at exit 0, with the unmanaged file still holding the word `unmanaged`. **The second generalisation, from the sweep the finding implies.** All 23 shell suites were read for cases asserting an exit status where an effect is meant. **The class lives in exactly one file, and the reason is structural:** it is the only suite whose subject is a **mutating** tool. Every other suite exercises a checker, a scanner or a validator whose product **is** its verdict, so there the status is the effect. Within that one file five cases were status-only, and two of them had an effect nobody looked at: the refusal must leave the unmanaged file byte-identical, and the replacement must replace it. A weaker sibling is **registered rather than repaired**: several validator suites assert a refusal status without asserting which reason produced it, `tests/test_km_publish_guards.sh` cases 3, 5b, 6a, 6c, 8b and 12c most clearly. Those cases observe the tool's whole output and leave nothing unobserved, so they are a different defect, and reaching them would correct something other than the thing under review. **As repaired:** every case asserts the tree afterwards, each expected refusal must name its own reason or any error at all would satisfy it, and the refused file is compared byte for byte against its prior state. Proved in both directions with two mutations: an installer that succeeds without writing now fails at case 6 naming the file, and a refusal branch that truncates the file it protects now fails at case 5. **Finding 4, as it stood.** `.github/workflows/release-gate.yml` called `ubuntu-24.04` `Pinned rather than ubuntu-latest`. GitHub redeploys version-labelled runner images on a weekly cadence, so the image behind the label is mutable and the word is false. The same file documented **two** gate limits under the words `Both limits are stated in STANDARD.md`, while the gate printed **four**, the fourth having been added at v1.54. **As repaired:** the runner comment states what the platform actually does and what the label actually buys, which is that the job does not move to a new Ubuntu major release on its own, and it points at the genuine pin in the same file, the checkout action's commit SHA. The copied limit paragraphs are **gone rather than corrected**, because a copy of a list that lives elsewhere drifts again: the four limits are now one module-level definition in `tools/km-release-gate.py`, printed by the passing verdict, summarised by the failing one, and exposed by a new `--limits` flag that the workflow runs as its first step. Adding a fifth limit is an edit to that tuple and to nothing else. `tests/test_release_gate.sh` cases 20 to 20d pin the mechanism: the flag prints every limit defined, states the count from the same definition, the workflow invokes it, and the comment block above `runs-on:` may not use the word *pinned*. **Proof.** Seven new assertions in `tests/test_release_gate.sh` (13c, 13d, 13e, 20, 20b, 20c, 20d), three in `tests/test_published_not_draft.sh`, three in `tests/test_rfc_reference_integrity.sh`, four new canaries in `tests/test_skill_frontmatter.sh`, and six rewritten cases in the agent package suite, every one run against the unrepaired tree first and recorded in the `km-unrepaired-tree` declaration of the file that carries it. Of the seven gate assertions, five failed against the unrepaired tree, 13e passed legitimately because a real declaration is honoured by both readers, and 20d passed for the wrong reason until its assertion was scoped to the comment block above `runs-on:`, which is recorded rather than quietly fixed. **Limits.** A green gate does not prove a push is free of organisation leakage, because the denylist that scan needs is generated from an organisation's own entity names and is kept outside a publishable canonical repository by design, so only a deployment's own pre-push hook scans an actual push. And a green gate does not mean anyone other than the author looked. This version is the counter-example to that second limit rather than an exception to it: every defect here was found by a second actor, and none of them was found by the gate. |
| v1.56 | 2026-08-25 | Drafted and published 2026-08-25 (owner push). Claims made in prose that no instrument reads. **The source is the external review of 2026-08-25**, whose release blocker landed as v1.54 and whose four P2 findings landed as v1.55; these are its last two, and the sweep they demand. Every measurement below is this version's own, because several of the reviewer's figures had moved and one of them named a file that never carried the claim. **Finding 6, the licence prose, and the licence itself is sound.** Reproduced independently: with the Appendix boilerplate's `Copyright [yyyy] [name of copyright owner]` restored on the one line that differs, `LICENSE` hashes to `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, which is the published digest of the canonical Apache-2.0 text, so Sections 1 to 9 carry no edit and the single difference is the Appendix instantiated exactly as the Appendix directs. Two things about the prose were wrong. *Unmodified is imprecise.* `STANDARD.md` §"The boundary asserts no license" said `LICENSE` "carries the complete licence text" and the header lead said "the complete unmodified licence text with his copyright line", neither of which tells a reader that one line is instantiated or how to check it. **As repaired:** the live section states which part is canonical, which line differs, why the Appendix directs it, and the digest anyone can reproduce, and it says why the imprecision matters, which is that an unexplained difference in a licence file is where a reader is entitled to stop trusting the rest. The v1.53 row already stated it precisely and is untouched; the header lead's copy leaves the document by the ordinary rolling of the lead rather than by an edit to a published description. *The README overstated the duties.* It read "What the licence asks in return: keep the copyright notice, the licence text, and the `NOTICE` attribution, and mark the files you changed (§4). Attribution is a condition of the grant." Section 4 conditions **distribution**, so as written the page told a reader who uses the standard internally, or who modifies it and passes it to nobody, that they owe notice-preservation duties they do not owe. **As repaired:** the condition is named first, the notices are listed as §4 lists them, internal use and private modification are said to trigger none of them, and `LICENSE` §4 is named as governing. No advice was added and none is offered. **Finding 7, factual drift, and it is three different repairs rather than one.** A count is **corrected** when it was false on the day it was written and **left standing** when it was true then and has been overtaken since, and this version had one of each and one that was neither, which is why the three are treated differently and the discriminator is written into §"Standard Maintainer" rather than applied silently. *(1) The markdown-file count.* Claimed 147 markdown files and 41 code files, in the v1.53 row, in the header lead's copy of it and in that change package's design note. **Measured:** 158 tracked markdown files on `aeec51a`, the tree this version was measured against, and 162 once this change's own package lands, which is why no live figure is written in prose and the release gate's coverage line is the place to read it; 150 in the tree the v1.53 publish commit `eb57f0f` actually shipped; 147 on `main` when the design was written, which is where the figure came from; and 41 code files at all three points, so only the markdown half moved. The reviewer attributed the claim to `README.md` as well and **that did not survive verification**: `README.md` states no file count and never did. This is a dated measurement supporting a dated decision, so refreshing it to 158 would falsify the record and dropping it would remove the evidence the decision rested on. **As repaired:** the words "when the decision was taken" are added and the number is not touched, with a note stating all three figures and why the qualifier rather than a refresh. The live tree's figure is stated in prose nowhere, because the gate counts it. *(2) The MCP entry points.* The v1.40 row and `tests/test_mcp_quarantine.sh` both said **eleven** content-returning entry points. **Measured:** `template/mcp/server.py` declares **seven**, four `@mcp.tool()` and three `@mcp.resource()`; eleven was the size of the suite's own driver call list, `get_entity` being driven five times with five identifiers. That was false on the day it was written and has not moved since, so it is corrected under the v1.47 rule that a false published row is corrected in the ledger while the pushed commit and tag that carry the original wording are left exactly as they are. **As repaired:** the row states seven, says what eleven counted, and names itself as corrected; the suite's summary line derives both figures, reporting invocations and entry points separately and naming the entry points; and a new case 7 holds the figure the suite reports against the set the surface declares by decorator, so the number cannot be restated wrongly again. *(3) The gate's stated limits.* `agents/km-hub-builder/SKILL.md` has instructed every report to read the gate's **two** stated limits since v1.46, and the v1.53 row obeyed that instruction and published the same number. **Measured:** the gate printed **three** at `a2756e2`, the v1.46 publish commit, and at `eb57f0f`, the v1.53 publish commit, the third being that it reads a check's exit status without seeing inside it; it prints **four** now, the fourth added at v1.54. So the contract was wrong from the version that introduced it and the row was wrong on the day, in both cases false rather than overtaken, and both are corrected. **As repaired, and the repair is to stop counting:** the contract states no number, orders the set to be taken from the gate rather than from any copy, and keeps the two limits that bear on it as substance; §"Publishing a version" step 5 does the same; §"A gate runs before publication" no longer says "those four"; and the gate's own header no longer claims the CI workflow carries a copy, which v1.55 deleted. The v1.53 row is corrected to name no count and its own two additional limits are renumbered to match. **The sweep, which is the part that outlives the findings.** Every one of these is a claim in prose that no instrument reads, the same class as the six surfaces that assert Apache-2.0 with nothing checking any of them. The whole repository was read for counts, version identifiers and file references asserted in prose, and what was covered is stated so the next sweep does not start blind: the README's package table and licence section, the standard's own live sections and its ledger, the shipped template's landing page and skills, the components, the agent contract and its adapters, `docs/architecture/`, the RFC set, the CI definition, the gate and every check under `tests/` and `scripts/`. **Four findings, beyond the three above.** The README enumerated **six** per-hub skills the template installs where both runtime trees install **seven**, `km-publish` being the omission, which is the only outright wrong enumeration found. The gate's header said its first two limits are stated "here, in the standard, and in the CI workflow" when v1.55 had already deleted the CI copy. The CI definition's opening still described discovery as a walk over **tracked** checks, which v1.54 changed to the working tree. And the README described the design set as "seven of them" beside a badge that derives the same number from the RFC index, which is a hand-kept count of a growing set standing next to its own home of record; the words are dropped and the badge keeps the number. **Findings of none, recorded as such.** The entity-note folder enumeration in the same README row is exactly the nine directories under `template/` that carry a `TEMPLATE.md`. `tests/test_hub_scan_canaries.sh` really does carry cases 14a to 14m as the standard says. The shipped template really does project three of the ten declared fact classes. There really are 23 shell suites, as v1.55's dated records say, and this version makes it 24 without restating theirs. `docs/architecture/` says "at least nine surfaces", which is the lower-bound form this class wants and is named here as the model. **One check is added, and it answers the class rather than the instance.** `tests/test_readme_inventory.sh` derives what the template ships, its entity-note folders from the directories carrying a `TEMPLATE.md` and its per-hub skills from both runtime trees, and requires the landing page's two enumerations to equal the derivation in **both directions**, so a member omitted and a member invented are each a failure and the inventory stops being a hand-kept memory of a directory. **Proof:** run against the unrepaired tree at `aeec51a` it FAILS, naming `km-publish` as a skill the template installs and the README does not carry; the folder case passes there legitimately and is recorded as passing rather than reworded until it fails; cases 5 and 6 drive the negative direction against mutated copies of the README; case 4 requires a refusal rather than a pass when the enumeration cannot be located. `tests/test_mcp_quarantine.sh` case 7 is proved the same way: run against the unrepaired tree it FAILS reporting 11 against 7, and appending an eighth decorated entry point the driver does not call makes it fail naming that entry point. **What was deliberately not built, with the reason, because a check that models the wrong class closes a sweep and proves nothing.** Nothing compares the version identifier across the five surfaces the publish ritual flips, and no check for it is added here: those surfaces are **designed** to disagree while a version is drafted, the standard's H1 carrying the drafted number while the README and the badge still carry the last published one, so a check would have to model the ritual's two states, and building a fifth reader of the ledger inside a repair to prose accuracy is how a check comes to model the wrong thing. It is recorded as a named gap whose honest home is an extension of `scripts/publication_status.py`. No general check on back-quoted repository paths is added either: the tree quotes hub paths, template paths and paths that are examples, and an instrument that could not tell those from a reference to a file in this repository would report a tree full of defects that are not there. **No delta spec, argued.** `openspec/changes/audit-prose-claim-accuracy/` carries a proposal, a design and tasks, and one delta against the existing `documentation-truth` capability, because one requirement is genuinely added: the discriminator between correcting a false record and falsifying a true one, and the rule that a count of a growing set is derived or dropped rather than refreshed. Everything else in this version is corrective, and where a change is purely corrective the precedent for shipping no delta is `audit-licence-honesty-and-record` and `audit-spec-filename-convention`. **Limits.** A green gate does not prove a push is free of organisation leakage, because the denylist that scan needs is generated from an organisation's own entity names and is kept outside a publishable canonical repository by design, so only a deployment's own pre-push hook scans an actual push. A green gate does not mean anyone other than the author looked, and the findings repaired here were again found by a second actor and by none of the checks. To those this version adds one of its own: the check it ships proves that the README's two enumerations equal the directories they describe, never that the row's surrounding prose is true, and no instrument in this repository reads a licence, so every sentence above about what Apache-2.0 grants still rests on a maintainer having read it correctly. |
| v1.57 | 2026-08-25 | Drafted and published 2026-08-25 (owner push). Two defects in `template/hub-scan.sh`, the session-start scan every hub inherits, both found in operation by a reference deployment and both **harvested** rather than invented here: the designs were written by the tier that found them, which then refused its own ledger items because the only artifact that could close them is the canonical scan, which that tier may not edit. Each was reproduced as a failing case on this branch, off `main` at `2005772` (published v1.56), and **committed red before either repair was written**, because a case that passes against the unrepaired tree proves nothing about the repair that follows. **Defect 1, the `[ RESTRICTED ]` check blocked a numbered curated document's own NAME.** In the pass-1 frontmatter branch a `sensitivity: restricted` marker emitted an `I` record, blocking the note's name on every outbound surface. For a root-level `0[0-9]_*.md` or `10_*.md` that is wrong: the name is the hub's public structure, not a disclosive record identifier. *Measured on the unrepaired tree:* a `changes/` directive restricting the content of `03_risks-decisions.md` produced `! RESTRICTED IDENTIFIER '03_risks-decisions' on outbound surface: changes/2026-08-24_XX_restrict-claim_directive.md`, exit 1, so **the directive could not name the document it was restricting** and the hub's scan failed at every session start with its real integrity errors buried underneath; and the same tree raised **no** finding at all over a verbatim quotation of that document's body, exiting 0, which is the other half of the same defect. The marker on such a document now sets the classification arm instead: content blocked verbatim, name nameable — the treatment `accessClass: restricted|record` has had since v1.22, under the crossing law the comment beside it already cited. **This is v1.21's reasoning reaching a case it should always have covered**, not a new rule: v1.21 narrowed the body-marker path because a check that blocks the governed route to changing a file protects nothing, and this is the same shape found a second time. **The narrowing is root-scoped, which is the load-bearing half**: a numbered name in a subdirectory is an ordinary note and stays blocked, because narrowing a security check is how a false positive becomes a false negative, and the case that asserts it passes on the unrepaired tree too — its job is to pin the boundary, not to detect the defect. **The body-marker path is unchanged and was examined rather than left unexamined:** a body marker already emits section text and never a name, so a numbered curated document marked in the body was already nameable, and narrowing there would only widen what is blocked; both its directions are asserted in the same suite. **The trade is stated:** before this, a frontmatter marker on such a document blocked its name and none of its text; after it, the text is blocked and the name is not, so a proposal quoting a verbatim line is now an error where it was not. **Defect 2, the `[ CORRECTIONS ]` counter read `lifecycle:` as if it meant `binds`.** `lifecycle:` records whether a DOCUMENT is current; `rule:` is what makes a note a binding rule, and **the v1.19 section that introduced the block already specified the count as the active notes *whose `rule:` is in force*, so the implementation never matched its own published specification.** The registry's own `README.md` — a reference document, current, carrying no rule — was counted as a rule that binds, and every scaffold document ever added reproduced it. *Measured against a live registry:* the shipped predicate returned **90**, the corrected predicate **89**, `README.md` was the sole difference, and three independent instruments in that deployment already agreed on 89; on the synthetic fixture the block printed `(4 active)` over two real rules, a README and a generated index. The predicate now has three arms, all of which must hold — not scaffold, carries a `rule:`, is `lifecycle: active` — with scaffold taken from this standard's own set (`README.md`, `TEMPLATE.md`, `hub-manifest.md`) plus a generated `index.md`, which carries `lifecycle: active` by construction since v1.15. It is written as a loop and not a pipeline, because hub and estate paths contain spaces and an `xargs` formulation returns 0 on such a path without saying so. **The printed line was rewritten to state that predicate**, since a check whose printed claim outruns what it counts is the defect one layer up from the count. **What was deliberately not done:** the `lifecycle: active` line was not removed from the registry's `README.md`, because that edits the data until a broken counter accidentally agrees and the next scaffold file reproduces the defect; and no `DIGEST*.md` name pattern was written into the check, though the handed-over design proposed one — the standard defines no such artifact, a name list beside a check is the hand-maintained memory of one directory this standard already records as the class that rots, and the four digests present in the measured deployment carry no `^rule:` line, so the arm would have been inert. **That is registered as the stated limit rather than closed:** a derived digest rendering `rule:` and `lifecycle: active` at column zero would be counted, and the repair for it belongs in the generator or in naming the artifact under the scaffold set. **Both sweeps returned exactly one instance each, and both findings of none are recorded rather than left silent.** *Defect 1's class — a check treats a structural name as a disclosive identifier* — was swept across every instrument that matches a name against a boundary: `[ RESTRICTED ]` is the only one in the repository that decides whether a NAME may cross, and `build-indexes.sh` (indexes only entity folders, which hold no numbered documents), the quarantined MCP surface (`Path(path).stem` is an identifier, not a disclosure gate), the cockpit (`path.stem` titles a proposal) and the leakage instrument (an organization name is disclosive wherever it sits, by design) do not carry it. *Defect 2's class — a check reads `lifecycle:` as if it meant `binds`* — was swept across every use of the field in shipped code: `is_current`, `[ CURRENCY ]`, `build-indexes.sh`'s row filter and the MCP surface's projection gate all read it as currency, which is what it means; `validate_organization_profile.py` validates the enum; and `validate_rfc_lifecycle.py` names a disposition derived from the ledger rather than the field. **One near-neighbour is registered rather than repaired:** the cockpit renders a hub's registry membership in a column it also calls `lifecycle`, which is a naming collision over a different property and not a false predicate. **Scope, stated because the ledger item it answers named two acts and only one is here:** this version is the canonical narrowing alone. Re-deploying the repaired scan across divergent installed copies is writing into hubs, which is each hub's own act under its own governance, and no hub is edited or dispatched by this version. |
| v1.58 | 2026-08-25 | **DRAFT — awaiting owner push.** Three findings from an external reviewer's second pass over this repository. Each was reproduced as a failing case on this branch, off `main` at `510cf03` (published v1.57), and **committed red before any repair was written** (`fbf8002`), because a case that passes against the unrepaired tree proves nothing about the repair that follows. **Finding 1 [P1], `tools/km-release-gate.py` could return PASS over a tree that changed while it ran.** Discovery and the declaration checks run first, the suites run after, and nothing established that the tree at the verdict was the tree that was discovered; the file was grepped for `fingerprint|snapshot|tree_id|rev-parse HEAD|stable` and returned **zero hits**, because no such machinery existed. The reviewer observed it live: the gate began on clean `main`, the branch changed at 14:16, `tests/test_restricted_lint.sh` was modified at ~14:18, and the gate returned PASS after ~900s still reporting zero changed declarations. **The cause was this maintainer's own v1.57 drafting agent**, mutating the tree while the reviewer's gate ran — the reflog shows `14:16 checkout` and `14:29 commit: v1.57 (canaries)` — and the reviewer could not have known that. It does not weaken the finding, it is how the finding was discovered, and **the defect is that the gate cannot tell, not that anyone misbehaved**: a ~20-minute run is a wide window for a maintainer editing alongside it, and a gate whose PASS cannot name the tree it judged certifies nothing. **The repair is deliberately not a snapshot.** Since v1.54 the gate reads the working tree, tracked ∪ untracked-not-ignored, so that a check authored in the change being gated is visible; a snapshot of tracked content would silently undo v1.54 and reopen the exact defect that version closed. It fingerprints **what it actually reads** — the same set discovery reads, by the same pathspecs, by content, with `HEAD` alongside so a branch change is caught even when every file matches — before and after, and **REFUSES** (exit 2) on any difference, naming what moved. Not a PASS, and not a silent re-run. *Measured, four fixtures, on the unrepaired gate at `510cf03`:* a suite editing another discovered check → PASS, exit 0; a suite creating a new check-shaped file → PASS, exit 0, over a check never discovered, never held to the declaration rule and never executed; a suite moving `HEAD` with no content differing → PASS, exit 0. The repaired gate refuses all three at exit 2 naming what moved. **The residual is stated rather than implied closed, and pinned as a gap:** a file that changes and changes back inside the window is byte-identical at both ends and invisible to any before/after comparison, and anything outside the discovery set is not fingerprinted at all — case 21e requires a change outside that set to still pass, so a later widening fails loudly. Widening to the whole tree was considered and refused: the checks and tools legitimately write inside the tree, and a fingerprint over everything converges on a gate that refuses every run. **This became BOTH a refusal condition and a fifth stated limit, and the reasoning is recorded because the question was asked:** drift is detectable, and a detectable condition is answered by the verdict category the gate already has for *could not evaluate*; but what a PASS now means is narrower than a reader assumes, and every sentence of the form *a green line does not mean this* belongs with the limits. **Finding 2 [P2], `tests/test_skill_frontmatter.sh` retained a false pass.** The continuation arm skipped **every** indented line unconditionally — no state, no knowledge of which key it continued, no check that any key preceded it — and the 10-40 word budget was then measured against `sed -n 's/^description: *//p' | head -1`, the first physical line alone. *Reproduced:* a fixture whose `description:` first line is **13 words** followed by indented continuation lines was accepted at exit 0 with zero violation lines, while Ruby's YAML parser on the same host read the effective value as **97 words**. A second fixture, an indented line placed before any key so that it continues nothing at all, was also accepted. The block is now walked with state: a continuation is folded into the key it continues, and an indented line no key precedes is a violation. **No YAML library is taken as a dependency**, deliberately — PyYAML is absent on the authoring host, Ruby's is present, and neither is guaranteed in a deployment's environment; this repository has already published v1.51 about a tool that assumed its author's toolchain, so the folding is done in the shell the check already requires, and the limit is stated: it models the plain-scalar folding these files use, not the whole of YAML. **A third defect was found while repairing rather than by probing:** the arm's tab pattern was written `"\t"*` inside double quotes, which is a literal backslash-t, so no tab-indented line had ever matched it — the v1.29 rule about verifying a matching construct against the tool that runs it, met in this repository's own suite. **The positive direction ships with it:** a legitimate two-line description inside the budget must still be accepted, and is, on both trees. **Finding 3 [P3], "the limits, defined once" was overstated.** The comment beside the gate's limit tuple ended *"Adding a fifth limit is an edit to this tuple and to nothing else"*, and the same set was maintained in **three** places: the tuple; a numbered prose block in the header arguing each limit again; and four hardcoded `grep -Fq` assertions in `tests/test_release_gate.sh` case 15 pinning that block's wording. **Verified against v1.55's own tree (`aeec51a`) rather than taken on the reviewer's word**: the sentence, the four numbered header entries and the four assertions all stood there together, so the claim was **false on the day it was written** and is corrected under the v1.47 rule, not dated under v1.56's. Two further symptoms of the same separate maintenance were found here: the header pointed twice at `GATE_LIMITS`, a name nothing defined (the tuple is `LIMITS`), and it claimed the count *"is not restated in prose anywhere"* while the tuple's comment 185 lines below said *"the same four limits"* — the file carried the claim and its counter-example at once. The header's entries had also drifted into file order 1, 3, 2, 4. **The repair reduces the count of maintained definitions rather than describing the drift**, which is the route this standard prefers where it is available: each limit now carries its own argument beside the words every surface prints, the header's prose block is gone, and case 15 is replaced by three **derived** assertions that name no limit — no prose count of the limits, no numbered enumeration beside the definition, and every constant the header names actually defined. **The proof is this version's own work: adding the fifth limit was an edit to `LIMITS` and to nothing else**, and it also made true, with no edit, the identical claim `.github/workflows/release-gate.yml` had been carrying since v1.55. **The anchoring those checks needed is itself proved in both directions.** Written unanchored, cases 15a and 15c reported this change's own repair as the defect, because a repair to this class necessarily *quotes* the wording it removed — the v1.52/v1.55 class, met on the checks written to close it. They now blank quoted spans and the `km-unrepaired-tree` line, which is a dated record this standard forbids rewriting; and because *"a rule narrowed until the tree goes green"* is indistinguishable from one that has stopped matching, cases **15d and 15e** run both anchored greps against a copy of the gate carrying the v1.55 wording as a live claim and require both to fire. **Both sweeps returned instances, and both findings are recorded rather than left silent.** *Finding 2's class — a check reads the first physical line of a value whose logical value spans lines* — was swept across every shipped check, tool and surface. `.km-tier`'s `tier` and `scope:` reads were examined and excluded: the standard defines that marker as line-oriented, not YAML, so those values are single-valued by construction. The frontmatter openers (`head -1` for `---`) are physical-line tests by definition. But the class was found **twice more, on `routing-keywords`, the very field v1.44 was written about**: `fm_field()` in `template/hub-scan.sh` does `print; exit` on the first matching line, and the cockpit's reader uses `[^"\n]*` with `re.M`, which cannot cross a newline. *Measured on a manifest declaring five keywords folded across two lines:* YAML reads all five, `fm_field` reads `alpha, beta,` — two keywords plus a stray empty entry, which the v1.44 gate then correctly splits per token — and the cockpit reads two. **The per-token repair was right and was handed a truncated value.** It is **registered, not repaired here**, in both readers and in this document, because `fm_field` serves every field the scan reads and is inherited by every hub: that is a change with its own blast radius, its own canaries and its own unrepaired-tree runs, and settling it inside a repair to an unrelated instrument is the move this standard already refuses. *Finding 3's class — a comment claims a single definition where several are maintained* — was swept across every such claim in shipped code. `scripts/publication_status.py` was verified genuinely single (both validators import it). One real instance was found and **repaired**: `tools/km-publish.sh` said *"THE PIN. One name, one place ... editing this line is sufficient to change what renders"* above **two** literals, `WEASYPRINT_PIN="weasyprint==69.0"` and `WEASYPRINT_VERSION="69.0"`, the second being what `venv_ready` verifies against and what the environment path is built from; editing the pin alone would install one version and verify against another. It fails closed, which is why nothing caught it. The bare version now derives from the pin, and new case 7c counts the version literals and requires the derivation to hold — red at *"2 version literal(s)"* on the unrepaired tool. **Nothing is redeployed anywhere by this version**, and no hub is edited or dispatched. |


### Publishing a version (added in v1.42)

A version publishes in one commit, and that commit is not finished when the header carries the new
number. Publication is a claim about status, and it is complete only when every surface that states
the version's status states the same one.

1. **The status surfaces flip.** The frontmatter title, the H1, the lead paragraph, `README.md` and
   the version badge carry the new version, and the descriptions of versions already published are
   preserved word for word.
2. **The version-history row is stamped**, and the date is **derived from the publishing commit**
   rather than carried in (amended in v1.47). The row cites the reason the version resolves, and no
   published number is ever reused: read the ledger *and* `git log` before choosing it. The date column and the stamp
   are both read off the commit that publishes the version, in that commit's own recorded offset, in
   the same act, so the two cannot disagree unless someone later edits one of them alone. A date that
   arrives from a staging brief, from the draft date already sitting in the row, or from a
   maintainer's sense of what day it is, is a claim about the tree that the tree does not support,
   and a session that began yesterday and pushes after midnight is exactly the session that supplies
   one. Three demonstrations earned this and a fourth explains why it has to be mechanical. v1.40
   carried a brief's date into the column and into the stamp while its draft commit, its publish
   commit and the overlay re-pin that adopted it were all on the following day. v1.33 derived the
   stamp at publish time and left the column holding the draft date, so the ritual was applied to
   half the row and the row contradicted itself in published text from the moment it published.
   v1.45 was caught before publication, and only because the drafting agent checked three independent
   pieces of evidence against each other rather than trusting the one it was handed. And the sweep
   that went looking for this class afterwards compared each publish commit's subject date against
   that same commit's timestamp, a pair that agrees with itself by construction, so it reported clean
   over a row that was wrong. `scripts/validate_ledger_dates.py` makes the comparison mechanically:
   it resolves each version's publish commit through an annotated tag where one exists and through a
   search of commit subjects where one does not, reads the author date in the commit's own offset,
   reports a version it cannot resolve as a stated coverage gap rather than as a pass or a failure,
   refuses rather than passes on a table it could not read, and runs inside the gate at step 5.
3. **The publishing version's own draft markings are cleared everywhere the version wrote them.**
   While a version is drafted, everything it adds is marked `(added in vX.Y, drafted and
   unpublished)` and carries the clause saying it binds nothing until its own owner push, in the
   standard's own sections **and** in every shipped file the version touched: skills, templates,
   scans, components, agent contracts, tests. Both statements become false at the moment of the
   push, and text telling a reader that a binding obligation carries none is worse than no marking
   at all, because a deployment reading its own copy is entitled to act on it. The shipped files
   matter most: a marking left in a skill or a template installs the false claim into every
   deployment that adopts the version, where the standard's own text is not what the operator
   reads. Clear the draft parenthetical and the clause, keep the version attribution
   `(added in vX.Y)`, and change no other word: this is a status repair and never a rewrite.
   Markings belonging to a version that is still drafted are left exactly as they are.
4. **`scripts/validate_published_not_draft.py` runs and passes.** It reads publication status from
   the version-history table of `STANDARD.md`, which is the single home of record for it, and
   applies that status across the governed surface: the standard, the README, `skills/`,
   `template/`, `components/`, `contracts/`, `agents/`, `docs/`, `scripts/`, `tools/` and `tests/`.
   It keeps working as later versions publish and needs no edit as they do; it exempts a version the
   table declares still drafted; it refuses rather than passes on input it could not evaluate; and
   it states on a passing run how many versions it classified, how many files it scanned, how many
   were exempt and why, and how many markings it judged. `rfcs/` is out of scope, because an RFC is
   a dated design record of what the status was when a ruling was captured rather than a surface a
   deployment installs, and freezing its prose to current status would falsify the record. A file
   may exempt itself with a stated reason, which the passing run prints, so no exclusion is silent.
   Its canaries are `tests/test_published_not_draft.sh`.
5. **The release gate runs and passes (added in v1.46).** `tools/km-release-gate.py` is one command
   returning one verdict. It discovers every check the repository ships rather than being told which
   ones to run, executes
   them, adds a shell syntax check, a JSON and JSON-LD parse check, a Python syntax check and a
   relative-link check over the tracked tree, and states its coverage on the passing line. It
   refuses rather than passes on anything it could not evaluate, and a refusal is not a pass. **It
   also refuses when the tree changed while it ran** (added in v1.58, drafted and unpublished; this
   clause binds nothing until its own owner push): it fingerprints what it read, before and after,
   and a verdict about a tree that no longer exists is withheld rather than issued. A maintainer
   editing alongside a twenty-minute pass is the ordinary case, so this refusal is expected
   occasionally and is answered by re-running on a settled tree, never by re-running until it
   passes. Step 4
   runs inside it, so the gate covers it; step 4 keeps its own number because the ritual should say
   which control clears step 3, and because a maintainer publishing from a tree where the gate
   cannot run needs to know which single check is the one that must not be skipped. **A version that
   adds or changes a check does not clear this step merely by running it.** Every check carries
   `km-unrepaired-tree: <version|none|unrecorded> | <result>`, recording what it found when it was
   run against the tree it was written to catch, and the gate fails on a missing declaration, on one
   whose result text is empty, on a check this change added that pleads nothing was recorded, and on
   a check this change edited whose declaration line it left untouched.

Step 3 is written down because it was omitted for three published versions running. The ritual as
practised covered the header, the row, the README and the badge; the maintainer publishing v1.35,
v1.39 and v1.40 did not notice the bodies or the files those versions shipped; and seventeen false
status claims across five files, fifteen of them naming a version outright, stood in published
material until v1.42 enumerated them. A step that lives only in a
maintainer's memory is a step that will be skipped, which is why step 3 is paired with step 4 and
not left as advice.

Step 4 covers the whole governed surface for the same reason. A check that validated the standard
alone would have passed green on a tree whose shipped skill, registry template and hub scan still
told an operator that a binding registry obligation did not bind. A control that certifies the
document while the installed files carry the defect is a control that gives false confidence, which
is the failure this section exists to close and not a narrower version of it.

Step 5 exists because the four steps above are a list, and a list is run by whoever remembers it.
Three of the failures this standard records were caught by nothing, three different ways: a check
that vouched for the wrong shape, a flag that was read and not acted on, and a step that lived only
in a maintainer's habits. What they share is that the person verifying was the person who wrote the
thing being verified. The gate ends the mechanical half of that, and its declaration requirement
makes the half no gate can reach into something a later reader can hold the maintainer to. Read the
gate's stated limits with it (added in v1.46), taking the set from the gate's own output rather than
from a copy anywhere (narrowed in v1.56). Two of them are worth naming here as substance: a green gate does not mean a push is
leakage-free, and it does not mean anyone other than the author looked. Naming them is not
enumerating them, and this section states no count, because the set grows and every copy of it in
this repository has drifted at least once.

**Correcting a published date, and what is deliberately not rewritten** (added in v1.47). A false date in a
published version-history row is corrected in the ledger, and the pushed commit subject and annotated
tag that carry it are left exactly as they are. Rewriting pushed public history to erase a discrepancy is a
worse remedy than documenting one: amending a published commit rewrites every descendant, retagging
replaces an object that every clone and fork already holds, and a reader who finds two clones
disagreeing about history has a harder problem than a reader who finds a discrepancy with an
explanation beside it. The ledger is the corrected record of account and `git log` is the record of
what was done, including what was done wrongly. The version row carrying the correction states which
pushed objects retain the original date and which already carried the right one, so a reader
comparing the two finds the asymmetry explained rather than a contradiction to resolve.

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

*This standard is organization-agnostic. This repository is licensed under the Apache License,
Version 2.0; the standard it carries still asserts no licence on any deployment. See "The boundary
asserts no license" above.*
