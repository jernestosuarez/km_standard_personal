---
type: config
title: Initiator Profile — {{PROJECT_NAME}} Knowledge Hub
description: Context about the person and unit that created this hub — role, goals, and working notes for agents.
tags: [config, initiator, context]
resource: ./
lifecycle: active   # the current generation of this document (STANDARD.md, Currency of generated documents)
timestamp: {{INIT_DATE}}
last-reviewed: {{INIT_DATE}}   # last time someone confirmed this is still true (NOT the last edit — that's `timestamp`)
---

# Initiator Profile — {{PROJECT_NAME}}

**Name:** {{HUB_OWNER}}
**Role:** {{INITIATOR_ROLE}}
**Organisation:** {{ORG_NAME}}
**Unit / Team:** {{UNIT_NAME}}
**Hub created:** {{INIT_DATE}}

---

## Why this hub was created

{{INITIATOR_GOALS}}

---

## Role & unit context

{{INITIATOR_CONTEXT}}

---

## Notes for agents

{{INITIATOR_AGENT_NOTES}}

---

## Users of this hub

Who actually consumes this hub. Not "the team" — name them, and say what each comes here for.
A hub with no named users is a hub with no one to disappoint, which is why nobody notices it rotting.

| User | What they come here for |
|---|---|
| {{HUB_OWNER}} | Owner |
| | |

---

## Review cadence

**Cadence:** <e.g. monthly / quarterly>
**Last full review:** {{INIT_DATE}}

At each review, the owner checks: are the **competency questions** (`01_project-brief.md`) still the
right ones, and can the hub answer them? What should be **retired**? `hub-scan.sh` reports
`[ FRESHNESS ]` against the threshold in `07_glossary.md`.

---

## Reconciling against systems of record

`hub-scan.sh` verifies **internal** consistency only. It cannot tell you the hub disagrees with the
system that actually owns a fact — the CRM, the finance system, the signed contract. Nothing in this
standard can. That check is human, and it needs a date.

| System of record | What it owns | Reconcile every | Last reconciled |
|---|---|---|---|
| | | | |
