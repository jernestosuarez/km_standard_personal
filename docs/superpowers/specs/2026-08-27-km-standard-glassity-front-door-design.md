# KM Standard Glassity Front Door Design

**Status:** Approved in conversation on 2026-08-27  
**Repository:** `cjgama/km_standard_glassity`  
**Baseline:** KM Standard v1.64 at `9d43e193d044e2bdd6084480b80195b7e8ba9adf`

## Objective

Present the repository as **KM Standard - Glassity Edition** with a concise, credible, and navigable GitHub front door. The redesign must explain the product before its release history, serve adopters and maintainers with equal priority, and preserve every normative Standard, governance, template, skill, component, and test obligation.

This is a presentation and documentation slice. It does not introduce a Glassity release number. The edition initially states only that it is based on KM Standard v1.64.

## Audience and primary journeys

The README serves two audiences equally:

1. **Adopters** evaluating the framework or creating and operating a governed knowledge hub.
2. **Maintainers** reviewing, testing, and evolving the Standard under its governance model.

The first screen gives each audience a named path. Neither path is visually or structurally subordinate to the other.

## Identity and positioning

The display name is **KM Standard - Glassity Edition**.

The primary definition is:

> A governed knowledge-hub framework for people and AI assistants, built in plain Markdown and Git.

The supporting description is:

> KM Standard helps teams turn scattered project material into decision-grade, auditable knowledge without depending on a proprietary knowledge platform.

The baseline statement is:

> **Glassity Edition - based on KM Standard v1.64**

The GitHub repository description is:

> Glassity's edition of an open, vendor-neutral standard for governed knowledge hubs built for people and AI assistants in Markdown and Git.

The repository remains private during this redesign.

## First-screen design

The first rendered screen contains, in this order:

1. A versionless Glassity Edition banner.
2. The display name and primary definition.
3. Four trust signals: upstream baseline, release gate, Apache-2.0, and Markdown + Git.
4. The one-line baseline statement.
5. Two accessible text entry points: **Adopt the Standard** and **Evolve the Standard**.

The current image navigation buttons are removed. Navigation uses ordinary linked text so labels remain selectable, accessible, and understandable when images do not load.

The 287-word v1.64 narrative is removed from the README opening. Its authoritative record remains in `STANDARD.md`. `CHANGELOG.md` records a concise inherited-baseline summary and links to the normative version ledger.

## README information architecture

The redesigned `README.md` uses this sequence:

1. Identity, positioning, trust signals, and baseline.
2. Equal adopter and maintainer entry points.
3. **Why this exists:** the scattered-knowledge problem and the outcome the framework is designed to produce.
4. **What you get:** governed changes, portable plain files, shared human/agent readability, a reusable scaffold, and mechanical validation.
5. **How it works:** a compact Mermaid diagram showing sources, governed hub, readers/agents, and the optional Supervisor tier.
6. **Adopt the Standard:** a short quick start linked to `docs/adopting.md`.
7. **Evolve the Standard:** the maintainer path linked to `docs/maintaining.md`.
8. **Repository map:** a compact list of the principal packages, linked to `docs/README.md` for detail.
9. **Baseline and version policy:** Glassity Edition is based on upstream v1.64 and has no independent release number until it diverges.
10. **License and attribution:** a short Apache-2.0 operational summary linked to `docs/license-and-reuse.md`, `LICENSE`, and `NOTICE`.

The README should be scannable without hiding necessary qualifications. Detailed governance, release, architecture, and legal records remain linked rather than duplicated.

## Documentation additions

The slice adds these reader-facing files:

- `CHANGELOG.md`: records the inherited v1.64 baseline and reserves future entries for Glassity-specific changes.
- `docs/README.md`: maps current, historical, adopter, maintainer, architecture, RFC, and design material.
- `docs/adopting.md`: explains evaluation, initialization, operation, and the transition from one hub to a Supervisor tier.
- `docs/maintaining.md`: explains authority, the release gate, RFCs, OpenSpec change records, and the rule that cached results never produce the authoritative verdict.
- `docs/license-and-reuse.md`: carries the detailed Apache-2.0 explanation currently occupying the README.

The historical v1.22 architecture files remain in place in this slice. `docs/README.md` and the root README label them as historical and route readers to `STANDARD.md` for current authority. Moving or rewriting those files is a later governed slice because existing references may depend on their paths.

## Visual system

The banner retains the existing dark navy, teal, coral, and gold palette. Its message changes from the v1.22 record-boundary release to the edition-level identity:

- No version number appears in the static banner.
- The main title is `KM Standard` with `Glassity Edition` as the edition mark.
- The supporting line is `Governed knowledge hubs in plain Markdown and Git.`
- The illustration represents sources flowing through a governed hub to people and AI assistants.
- The record-boundary slogan and Supervisor-specific emphasis move out of the hero.

Both `assets/km-banner.svg` and `assets/km-banner.png` are updated together. The PNG remains the README image. The SVG remains the editable source. Alt text names the product and its purpose, not its version.

The badge row is limited to four items. The release-gate badge links to the actual GitHub Actions workflow. Static artwork never carries mutable release data.

## GitHub metadata

After the repository content is accepted, configure these topics:

- `knowledge-management`
- `knowledge-base`
- `governance`
- `markdown`
- `git`
- `ai-agents`
- `knowledge-graph`
- `open-standard`

The homepage remains unset until a maintained documentation site exists. Discussions remain disabled during this slice.

## Scope boundaries

This slice may change only:

- `README.md`
- `CHANGELOG.md`
- `docs/README.md`
- `docs/adopting.md`
- `docs/maintaining.md`
- `docs/license-and-reuse.md`
- `docs/superpowers/specs/2026-08-27-km-standard-glassity-front-door-design.md`
- `docs/superpowers/plans/2026-08-27-km-standard-glassity-front-door-implementation-plan.md`
- `assets/km-banner.svg`
- `assets/km-banner.png`
- GitHub repository description and topics

It must not change:

- `STANDARD.md`
- `template/`
- `skills/`
- `components/`
- `agents/`
- `contracts/`
- `rfcs/`
- `scripts/`
- `tests/`
- `tools/`
- `.github/workflows/release-gate.yml`
- license terms or attribution
- any governance, publication, or release-gate behavior

## Verification and acceptance criteria

The implementation is accepted only when all of the following are true:

1. The first README screen identifies Glassity Edition and explains the product before version history.
2. The README gives adopters and maintainers equally prominent entry paths.
3. The baseline is stated consistently as upstream KM Standard v1.64, with no invented Glassity version.
4. Neither banner asset contains `v1.22`, `v1.64`, or another mutable version number.
5. The README contains no long-form v1.64 release narrative.
6. Every relative link added or retained in the README resolves.
7. `tools/km-release-gate.py` runs directly and exits 0 after the content changes.
8. `git diff --check` exits 0.
9. The final diff touches only the approved presentation, documentation, plan, and design files.
10. The original canonical checkout and repository remain unchanged.

The release gate result must be reported with its exit status. A duration without an exit status is not evidence of a passing gate.

## Publication sequence

1. Implement and verify on `codex/glassity-front-door`.
2. Review the complete diff against the scope boundary.
3. Run the direct, uncached release gate and record its exit status.
4. Commit and push the feature branch.
5. Review and merge through the repository's normal governed workflow.
6. Update GitHub description and topics only when the repository content carrying the new identity is accepted.
