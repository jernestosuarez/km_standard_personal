---
type: config
title: Knowledge Management Standard — Package Overview
description: Organization-agnostic knowledge hub framework — governance model, reference template, and optional agent skills, ready to adopt by any team or company.
tags: [standard, knowledge-management, governance, okf]
timestamp: 2026-07-02
---

<p align="center"><img src="assets/km-banner.png" alt="KM Standard — governed, agent-readable knowledge in plain files" width="100%"/></p>

<p align="center"><em>The open standard for governed knowledge hubs — built for organizations and their agents.</em></p>

<p align="center">
  <img src="assets/badges/version.svg" alt="standard v1.49"/>
  <img src="assets/badges/rfcs.svg" alt="RFCs: 2 adopted"/>
  <img src="assets/badges/license.svg" alt="license: pending"/>
  <img src="assets/badges/format.svg" alt="format: markdown + git"/>
  <img src="assets/badges/agents.svg" alt="agents: MCP-ready"/>
</p>

<p align="center">
  <a href="STANDARD.md"><img src="assets/badges/nav-standard.svg" alt="The Standard"/></a>&nbsp;
  <a href="template/"><img src="assets/badges/nav-template.svg" alt="Template"/></a>&nbsp;
  <a href="rfcs/"><img src="assets/badges/nav-rfcs.svg" alt="RFCs"/></a>&nbsp;
  <a href="skills/"><img src="assets/badges/nav-skills.svg" alt="Skills"/></a>&nbsp;
  <a href="#quick-start--one-hub"><img src="assets/badges/nav-quickstart.svg" alt="Quick start"/></a>
</p>

# Knowledge Management Standard

**Current version: v1.49** (2026-08-24, the repository's licence claim is made honest, and the
record behind nine remediation packages is committed, closing audit finding F-07; this page claimed a
reuse grant while the tree holds no `LICENSE`, `COPYING` or equivalent file, so default copyright
applied and the advertised grant was not the effective one, and the same claim stood on the licence
badge, on this page's `alt` text, and twice in `STANDARD.md`, in its closing line and in one clause
of the editions section; **no licence is chosen here, and that is the shape of the repair rather than
a gap in it**, because adding one would be a maintainer choosing the grant, the warranty position and
the patent position on the owner's behalf, and deleting the reuse paragraph would withdraw an intent
the owner holds; free adoption is preserved word for word and named as intent, what is withdrawn is
only the implication that intent alone is operative, the badge now reads `license: pending`, and the
open decision is recorded in [`STANDARD.md`](STANDARD.md) → *The boundary asserts no license*; the
remediation record behind nine change packages is committed under `openspec/`, thirty-seven files,
while the external QA report they name as their source is deliberately kept out, because a
fail-closed leakage guard refuses a document that is not leaking when a word it denylists as an
entity name is used in that document in its ordinary English sense, and editing the evidence or
widening the guard were both refused, so the report stays out, the ignore rule is committed with its
reason, and every citation names an external report of that date rather than a path a reader would
try to open; `template/README.md` pointed at a governance document that exists under no such name and
at a person a fork's reader does not have, and now names `STANDARD.md` and routes the reader through
the hub's own `km-deployment.md`; **no check is added, and the argument is recorded rather than left
as an omission**, because the one instrument that would catch F-07 cannot land while no licence
exists, a check on grant-shaped wording would model word choice rather than truth, and the
RFC-reference check does not reach a document named by title; v1.48 is the preceding published
version and v1.23 remains an
unpublished draft awaiting its own push). The full
ledger of released versions, and the rule that a published version number is never reused, is in
[`STANDARD.md`](STANDARD.md) → *Version history*.
Pin the version you adopted; adopting a later one is a decision, not a background update.

A reproducible, organization-agnostic framework for standing up a governed, agent-readable knowledge
hub for any initiative — a project, a team, a product line, a nonprofit, a research group. It is not
tied to any specific company, industry, or AI vendor.

## What's in this package

| Path | What it is |
|---|---|
| [`STANDARD.md`](STANDARD.md) | The full standard — architecture, governance rules, frontmatter spec, ontology layer, checklists. Read this first. |
| [`template/`](template/) | A ready-to-copy reference hub: stub docs, `context.jsonld`, `km-deployment.md`, entity-note folders (`decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/`, `corrections/`, plus the optional `relationships/`, `claims/`, and `sources/systems/`), governance files, and the per-hub agent skills (`km-intake`, `km-propose`, `km-gather`, `km-start`, `km-handover`, `km-brief`) already wired up for Claude Code and AGENTS.md-compatible tools. |
| [`rfcs/`](rfcs/RFC-001-sor-gateway.md) | Design RFCs. RFC-001 — the record boundary / systems-of-record gateway (published as v1.22, 2026-08-16): motivation, migration, implementation notes, and open questions for Rule 6, `accessClass`, `SourceSystem`, `Claim`, bitemporal validity, and inbound connectors. RFC-002 — stations, compartments, and the resolution plane (drafted as v1.23, awaiting owner push), with per-ruling provenance tags. |
| [`contracts/organization-profile.schema.json`](contracts/organization-profile.schema.json) | Portable JSON contract for an approved Enterprise Knowledge Layer organization profile. |
| [`scripts/validate_organization_profile.py`](scripts/validate_organization_profile.py) | Dependency-free validator for profile shape, compatibility, safe paths, and module eligibility. |
| [`skills/km-init/`](skills/km-init/SKILL.md) | Workspace-level skill: runs the purpose interview and either stands up a brand-new hub from `template/` or adopts a directory that already exists, writing only what it lacks. |
| [`skills/km-supervise/`](skills/km-supervise/SKILL.md) | Optional workspace-level skill: routes a source that touches multiple hubs (the "Supervisor tier"). Includes a starter `_KM_Supervisor_template/`. |
| [`skills/km-brief/`](skills/km-brief/SKILL.md) | Per-hub skill: generates an audience-tailored memo/briefing/status report by querying entity notes instead of freehand-reading hub docs. |
| [`components/km-cockpit/`](components/km-cockpit/README.md) | Optional side component (published as v1.24, 2026-08-17): the KM Cockpit — the owner decision surface. Renders the owner queue as full-context decision cards on localhost; configured entirely by a deployment manifest; never published beside a reading site. Normative contract in [`SPEC.md`](components/km-cockpit/SPEC.md). |
| [`agents/km-hub-builder/`](agents/km-hub-builder/SKILL.md) | Optional Standard Maintainer package: one governed contract, distributable Claude and Codex adapters, safe installation, and runtime-parity checks. It changes standards and hands adoption to the Supervisor; it never edits hubs. |
| [`docs/architecture/`](docs/architecture/README.md) | **A historical v1.22 snapshot, not the current architecture.** The layer model, the canonical-first hub deployment protocol, the OrganizationProfile contract, and authority boundaries, as they stood at v1.22. Descriptive, not normative, and not maintained forward: the cockpit, the projection contract, the supervisor threshold, hub merge, editions, the Reader tier, the MCP quarantine and the release gate all postdate it and are described in [`STANDARD.md`](STANDARD.md) instead. |

## Quick start — one hub

1. Read [`STANDARD.md`](STANDARD.md), sections "Purpose" through "Governance Layer."
2. Copy [`template/`](template/) to your new hub's location, e.g. `cp -R template/ ~/projects/my-initiative`.
3. Replace every `{{PLACEHOLDER}}` in the copied files (see the placeholder map in
   [`skills/km-init/SKILL.md`](skills/km-init/SKILL.md)) — or, if you're using an AI agent that
   supports custom skills, install `skills/km-init/SKILL.md` and invoke it to do this
   interactively.
4. `git init`, make the initial commit, and run `hub-scan.sh` (Steps 1 and 4–5 in `STANDARD.md`).
   That scaffold commit is the one place a blanket `git add -A` is safe; after it, stage the paths you
   touched (see *Rule 3 → Stage explicitly*), which matters most when the hub lives in synced storage.
5. Start working: drop files in `_inbox/`, propose changes in `changes/`, run `hub-scan.sh` at the
   start of every session. Track individual decisions/risks/stakeholders/milestones/partners as entity
   notes (`decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/`), not as table rows in
   the numbered docs — see "Ontology & Entity Layer" in `STANDARD.md`. Use `/km-brief` to generate a
   memo or briefing from those entity notes for a given audience.

`km-init` always creates a canonical-only hub and records its canonical version, revision, and source
in `km-deployment.md`. Organization binding is a separate Supervisor action. The Supervisor resolves
and validates an approved OrganizationProfile from the configured Enterprise Knowledge Layer, then
records the organization customization in a second commit.

No AI agent is required to use this standard — it works as a plain governance discipline for a
human-maintained markdown folder. The optional skills exist to automate the mechanical parts (digesting
sources, drafting proposals, running the scan) for teams using an AI coding/knowledge assistant.

## Quick start — more than one hub

The moment a workspace runs more than one hub, the standard advises creating the Supervisor
tier (v1.26) — starting from the **minimum tier**: a hub registry, an estate queue,
an inbox, and its own git history, with every further capability adopted against a named
condition. See "The supervisor threshold" and "Supervisor Tier — Cross-Hub Orchestration" in
`STANDARD.md`, and [`skills/km-supervise/`](skills/km-supervise/SKILL.md) for the routing
skill (adopted when a source first spans two hubs).

## License / reuse

**No licence has been declared for this repository, so default copyright applies and no reuse grant
is in force.** Free adoption is the owner's stated intent: this standard is meant to be adopted,
adapted, forked, and redistributed for any organization's internal or external knowledge management
needs, with no attribution required. Intent is not a licence, so until one is declared a reader may
rely on that intent as a statement of direction and never as permission. Choosing a licence, or
choosing not to, is an open decision and it belongs to the repository owner. Nothing on this page is
legal advice. The open decision is recorded in [`STANDARD.md`](STANDARD.md) → *The boundary asserts
no license*.
