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
  <img src="assets/badges/version.svg" alt="standard v1.55"/>
  <img src="assets/badges/rfcs.svg" alt="RFCs: 3 adopted, 1 partial, 3 open"/>
  <img src="assets/badges/license.svg" alt="license: Apache-2.0"/>
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

**Current version: v1.55** (2026-08-25, four defects from the external review, and two of them are
one defect seen twice; the source is the same first independent pass over this repository that
produced v1.54, whose release blocker landed there and whose four remaining P2 findings land here,
each reproduced on the tree at `13dec55` before it was repaired because three of the same reviewer's
earlier findings had not survived verification; **the skill-frontmatter check accepted an
unterminated block**, confirming the opening delimiter and then extracting with an `awk` expression
that runs to end of file, so with the closing delimiter deleted from all three shipped copies of one
skill the suite still printed that every shipped skill file conforms, at exit 0, and four further
malformations passed too; **a fifth was found while repairing and matters more**, because every
shipped skill file carries horizontal rules in its prose, so requiring merely that *a* terminator
exists moves the delimiter down the document and the block swallows the body with both keys present
and unique; **a quoted exemption token disabled link checking for a whole document**, the gate
searching raw markdown before fenced blocks were stripped and with no anchor, so a fenced example of
the syntax removed `README.md` from the scan, took 25 links with it and hid a broken link at exit 0;
**that is the class v1.52 repaired in one instrument and left standing in another**, which is the
more useful finding than either instance, and the sweep it demands found the v1.52 anchor itself
reachable, one ordinary sentence in the first 60 lines of `STANDARD.md` exempting the **home of
record** from its own publication check and from the RFC reference check, both at exit 0; **the
installer's replacement behaviour was asserted and never verified**, an installer altered to print
its success lines and exit 0 without copying anything leaving the agent package suite passing; **and
the CI workflow overstated pinning and understated limits**, calling a version-labelled runner image
a pin when the platform redeploys the image behind the label, and documenting two of the gate's
limits while the gate printed four; **the two generalisations are the point** — a directive token is
a property of every reader in a repository, so all five machine-read tokens were enumerated and all
three raw readers repaired under one anchoring rule, and a test whose subject changes a tree asserts
the change, the sweep of all 23 shell suites finding the class in exactly one file because it is the
only suite whose subject is a mutating tool; nothing a deployment installs changes and no hub turns
red; v1.54 is the preceding
published version and v1.23 remains an
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
| [`template/`](template/) | A ready-to-copy reference hub: stub docs, `context.jsonld`, `km-deployment.md`, entity-note folders (`decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/`, `corrections/`, plus the optional `relationships/`, `claims/`, and `sources/systems/`), governance files, and the per-hub agent skills (`km-intake`, `km-propose`, `km-gather`, `km-start`, `km-handover`, `km-brief`, `km-publish`) already wired up for Claude Code and AGENTS.md-compatible tools. Both enumerations in this row are compared against the template itself by `tests/test_readme_inventory.sh`, so neither is a hand-kept memory of a directory. |
| [`rfcs/`](rfcs/README.md) | Design RFCs, each a dated design record that is never rewritten to agree with what happened afterwards. **Start at [`rfcs/README.md`](rfcs/README.md), the index**, which records for every proposal its status, the published version that implemented it, where a design was implemented in narrowed form, and how the RFC badge above is generated from that table rather than counted by hand. |
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

**This repository is licensed under the Apache License, Version 2.0.** The complete text is in
[`LICENSE`](LICENSE) and the attribution notice is in [`NOTICE`](NOTICE). The grant is in force: it
is a licence rather than a statement of intent, which is what this page could offer while the
decision was open at v1.49. Copyright 2026 Carlos Correia.

What an adopter may rely on, in the licence's own terms rather than this page's:

- **Use, adapt, fork, and redistribute**, for internal or external knowledge management, commercially
  or not, with no fee and no permission to ask for (§2, §4).
- **An express patent grant** from each contributor over their own contributions, irrevocable except
  under the defensive termination clause that ends it for an adopter who brings patent litigation
  over the work (§3). That grant is why this licence was chosen for a specification other
  organizations implement.
- **One licence over the whole repository.** The specification prose and the code are not split,
  because the tree interleaves them: templates, skills, and scaffolds are both at once.

What the licence asks in return, and it asks it **when you redistribute** the work or a derivative of
it, in source or object form: **keep the copyright, patent, trademark and attribution notices, hand
on a copy of the licence, mark the files you changed, and carry the `NOTICE` attribution** (§4).
Those conditions attach to distribution. Using this repository inside your own organization, or
modifying it and not passing it on, triggers none of them. This page previously said that no
attribution was required at all; that is false under Apache-2.0 once anything is redistributed, and
it is withdrawn here. `LICENSE` §4 states the conditions in full and governs.

**The repository now carries a licence. The standard still asserts none.** Those are separate facts
about separate objects. Licensing this repository puts no licence, price, or commercial term on any
hub, estate, or deployment that adopts the standard, and it changes nothing in the editions boundary.
Both facts are recorded in [`STANDARD.md`](STANDARD.md) → *The boundary asserts no license*.

Nothing on this page is legal advice, and where this summary and [`LICENSE`](LICENSE) differ,
[`LICENSE`](LICENSE) governs.
