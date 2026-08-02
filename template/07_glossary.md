---
type: glossary
title: Glossary — {{PROJECT_NAME}}
description: Canonical terms, acronyms, and tag vocabulary for {{PROJECT_NAME}}.
tags: [glossary, terms]
resource: sources/transcript-index.md
lifecycle: active   # the current generation of this document (STANDARD.md, Currency of generated documents)
timestamp: {{INIT_DATE}}
last-reviewed: {{INIT_DATE}}   # last time someone confirmed this is still true (NOT the last edit — that's `timestamp`)
---

# 07 · Glossary — {{PROJECT_NAME}}

**As of:** {{INIT_DATE}}

> _Define every term or acronym used across the hub. When in doubt, add it here.
> Agents and contributors use this as the canonical reference._

---

## Terms and acronyms

| Term | Definition |
|---|---|
| Hub | This knowledge directory and its governed content |
| OKF | Open Knowledge Format v0.1 — YAML frontmatter standard for markdown files |
| Proposal | A `changes/*_proposal.md` file describing proposed hub doc edits |
| Approval | A `changes/*_approval.md` file authorising a proposal to be applied |
| Settled fact | A claim adjudicated as ground truth in `reconciliation/*.md` topic files, excluding `README.md` |
| Dispute | An active contradiction between a settled fact and an incoming source |
| `context.jsonld` | The hub's root JSON-LD context — resolves frontmatter fields to a shared vocabulary so hub docs and entity notes are valid linked data |
| Entity note | A single markdown file with typed frontmatter representing one instance of a Decision, Risk, Stakeholder, Milestone, or Partner — lives in the matching subfolder, not as a table row |
| Decision / Risk / Stakeholder / Milestone / Partner | The five entity types this standard formalizes; `Stakeholder`/`Partner`/`Milestone` ground in schema.org, `Decision`/`Risk` are proprietary extensions under this hub's `@vocab` |

> _Add initiative-specific terms below._

| | |
|---|---|
| | |

---

## Tag vocabulary

> _Define the canonical tags used in OKF frontmatter across this hub.
> All hub docs should use only tags from this list._

| Tag | Used for |
|---|---|
| `brief` | Project overview documents |
| `roadmap` | Plans and milestones |
| `decisions` | Risk and decision logs |
| `partnerships` | Partner and client entries |
| `stakeholders` | People and roles |
| `glossary` | This document |
| `governance` | Hub governance files (CLAUDE.md, AGENTS.md, README.md) |
| `decision` | Entity notes in `decisions/` |
| `risk` | Entity notes in `risks/` |
| `stakeholder` | Entity notes in `stakeholders/` |
| `milestone` | Entity notes in `milestones/` |
| `partner` | Entity notes in `partners/` |

> _Add initiative-specific tags below._

| | |
|---|---|
| | |

## Trust signals

| Field | Means | Not |
|---|---|---|
| `timestamp` | When the file was last **edited** | Whether anyone still vouches for it |
| `last-reviewed` | When someone last **confirmed the content is still true** | The last edit |
| `confidence` | **Quality of the evidence** behind a claim | Importance, priority, or how strongly anyone feels |

**Staleness threshold: 90 days.** `hub-scan.sh` reports `[ FRESHNESS ]` against it. Change it here
*and* in `hub-scan.sh` (`STALE_DAYS`) — they must agree, or the documented rule and the enforced rule
diverge, which is worse than having neither.

A fact adjudicated through reconciliation is **settled**, not estimated — it carries no `confidence`.
Confidence is for claims nobody has ruled on yet.
