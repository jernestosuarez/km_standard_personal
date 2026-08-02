---
type: decisions
title: Risks, Blockers & Open Decisions — {{PROJECT_NAME}}
description: Rollup and narrative for active blockers, risks, and decisions for {{PROJECT_NAME}}. Individual risks and decisions are tracked as entity notes in risks/ and decisions/.
tags: [risks, decisions, blockers]
resource: sources/transcript-index.md
lifecycle: active   # the current generation of this document (STANDARD.md, Currency of generated documents)
timestamp: {{INIT_DATE}}
last-reviewed: {{INIT_DATE}}   # last time someone confirmed this is still true (NOT the last edit — that's `timestamp`)
---

# 06 · Risks, Blockers & Open Decisions — {{PROJECT_NAME}}

**As of:** {{INIT_DATE}}

Individual risks and decisions are tracked as entity notes in `risks/` and `decisions/` — this doc is
the narrative rollup and reading order. Blockers stay here as prose; they aren't yet a formalized type.

---

## Active blockers

> _List items that are currently stopping progress. Use 🔴 for high urgency, 🟡 for medium._

### 🔴 [Blocker name] (HIGH)

_Describe the blocker: what is blocked, who needs to act, and what the consequence of delay is._

- **Decision needed:** _[What specific decision or action would unblock this?]_
- **Owner:** _[Who must act?]_

---

## Standing risks

> _One line per open risk, linking to its entity note in `risks/`. Add a note there for detail._

- [[risk-slug]] — one-line summary

---

## Decisions

> _One line per decision, linking to its entity note in `decisions/`. Never remove a link — this is the
> decision log; superseded decisions stay listed with a note, they don't get deleted._

- [[decision-slug]] — one-line summary

---

> _Replace placeholder links above with real risk and decision entity notes as they're created via
> `/km-intake` or `/km-propose`._
