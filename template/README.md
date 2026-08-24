---
type: config
title: {{PROJECT_NAME}} Knowledge Hub
description: {{DESCRIPTION}}
tags: [governance, index]
timestamp: {{INIT_DATE}}
---

# {{PROJECT_NAME}} — Knowledge Hub

**Description:** {{DESCRIPTION}}  
**Hub owner:** {{HUB_OWNER}}  
**Initialised:** {{INIT_DATE}}  
**Scope:** {{SCOPE_IN}} | Excludes: {{SCOPE_OUT}}

---

## What this hub is

This directory is a governed knowledge hub for **{{PROJECT_NAME}}**. It is the single source of
truth for decisions, partners, architecture, and risks related to this initiative.

All content is:
- **Versioned** via a proposal/approval workflow — no file changes without a trace
- **Integrity-checked** via git — every hub is a git repository; `hub-scan.sh` checks for uncommitted/untracked drift
- **Agent-readable** via OKF v0.1 frontmatter on every document

---

## Hub contents

| File | Type | What it covers |
|---|---|---|
| [00_about.md](00_about.md) | config | Hub initiator profile — role, organisation, goals, and agent working notes |
| [01_project-brief.md](01_project-brief.md) | brief | What the initiative is, why it exists, current status |
| [02_context-scope.md](02_context-scope.md) | architecture | Context, scope boundaries, key constraints |
| [03_roadmap-milestones.md](03_roadmap-milestones.md) | roadmap | Plan, milestones, dates, owners, budget |
| [04_stakeholders.md](04_stakeholders.md) | stakeholders | People, roles, reporting lines |
| [05_partnerships-pipeline.md](05_partnerships-pipeline.md) | partnerships | External partners and pipeline |
| [06_risks-decisions.md](06_risks-decisions.md) | decisions | Risks, blockers, open decisions, decisions made |
| [07_glossary.md](07_glossary.md) | glossary | Canonical terms and acronyms |

Supporting structure:

| Path | Purpose |
|---|---|
| `decisions/`, `risks/`, `stakeholders/`, `milestones/`, `partners/` | One note per instance. Each individual decision, risk, person, milestone and partner lives in its own note here; the numbered docs above are the narrative rollups over them |
| `corrections/` | One note per correction: the standing rule a mistake produced |
| `relationships/`, `claims/` | Optional entity notes: relationship assertions, and settled facts promoted to their own lifecycle |
| `_inbox/` | Drop zone — all incoming files land here first |
| `changes/` | Pending proposals and approvals |
| `reconciliation/` | Adjudicated fact ledger |
| `sources/` | Source files, digests, provenance index |
| `working-docs/` | Team output files (memos, briefings) |
| `shareable/` | Sanitised docs safe for external sharing |
| `assets/architecture/` | Diagrams and visual materials |

---

## Governance rules (summary)

1. **Inbox-first** — all incoming files go to `_inbox/` before anything else, no exceptions
2. **Proposal/approval** — no hub doc is edited without a traceable proposal and approval
3. **Git-backed integrity** — every hub is a git repository; `hub-scan.sh` checks for uncommitted/untracked drift in monitored files via `git status`, and `git log` is the audit trail
4. **OKF frontmatter** — every monitored doc carries valid `type:` frontmatter
5. **Source traceability**, every fact traces to a named origin; a fact whose origin cannot be named is flagged at intake and never blended into settled prose
6. **The record boundary**, records stay in the systems that master them; this hub holds claims about records, with resolvable pointers, never shadow copies of operational data

Run `bash hub-scan.sh` at the start of every session. It checks rules 1 to 4 in one pass, and the
outbound half of rule 6 through its restricted-content block. Rule 5 is procedural: no check
validates it, and it binds exactly as the others do.

Full governance reference: AI KM Hub Standard (available from the hub owner).

---

## How to work with this hub

**Process a new file:** drop it in `_inbox/`, then run `/km-intake` (or ask the agent to process it)

**Propose a change:** create a proposal using `changes/PROPOSAL_TEMPLATE.md`, or run `/km-propose`

**Check hub health:** `bash hub-scan.sh`

**Find a fact:** open its entity note. One note per decision, risk, stakeholder, milestone and
partner lives in `decisions/`, `risks/`, `stakeholders/`, `milestones/` and `partners/`; the numbered
docs are the narrative rollups over those notes and never the home of an individual fact. Or ask the
agent to search across the hub.
