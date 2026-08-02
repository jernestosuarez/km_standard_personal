# Reconciliation — {{PROJECT_NAME}} Knowledge Hub

This folder is the **adjudicated fact ledger** for this hub. It tracks facts that have appeared in
contradictory form across source documents and records the hub owner's decision on which version
is ground truth.

---

## How it works

- **Topic files** (e.g. `timeline.md`, `partnerships.md`) hold SETTLED facts. These are
  integrity-monitored via git — committed alongside other hub docs as part of the proposal/approval
  apply step. Changed only via the proposal/approval workflow.
- **`_disputes/`** holds active contradictions awaiting resolution. Each dispute file names who it is
  blocked on; that is not always the hub owner. Transient, not monitored.

Topic files are created as needed, when disputes arise. Do not pre-fill them with facts that have
not been contested — the ledger reflects adjudicated disputes, not a parallel copy of hub content.

---

## Topic file format

```markdown
---
type: reconciliation
title: Settled Facts — <Topic>
topic: <topic-slug>
lifecycle: active
last-reviewed: YYYY-MM-DD
---

# Settled Facts — <Topic>

These values supersede any contradicting source document.

| ID | Claim | Settled Value | Status | Sources (agree) | Sources (contradict) | Date settled |
|---|---|---|---|---|---|---|
| <T>-001 | <what fact> | <the truth> | SETTLED | <source A> | <source B> | YYYY-MM-DD |
```

**Status values:** `SETTLED` · `DISPUTED` · `SUPERSEDED` · `CONDITIONAL`

---

## Dispute file template

When a new source contradicts a SETTLED fact, the agent creates a dispute file here:

```markdown
# Dispute — <Topic> Contradiction

**ID:** <TOPIC>-D<n>
**Detected:** YYYY-MM-DD
**Incoming source:** <digest filename>
**Fact in dispute:** <one-line description>

## Conflict

| | Value | Source |
|---|---|---|
| **Reconciliation says** | <settled value> | <original sources> |
| **Incoming source says** | <new value> | <new digest filename> |

## Resolution options

- **A — Accept incoming:** update topic file to new value (requires proposal/approval)
- **B — Reject incoming:** mark claim in digest as OVERRIDDEN by reconciliation
- **C — Conditional:** both true in context — add conditional note to topic file

## Status

**UNRESOLVED**
**Blocked on:** Hub Owner | <the counterpart the hub is waiting on>
**Created by:** Agent (ingestion of <source filename>)
```

**`Blocked on:` is read by `hub-scan.sh`, so fill it in.** Put `Hub Owner` only when the owner can
actually settle it. When the hub is waiting on a counterpart to reply, name the counterpart: the
dispute is real and open, but there is no owner action in it, and reporting one every day is how
the dispute list stops being read. A dispute with no `Blocked on:` line is reported as unstated,
never as an owner action.

---

## Dispute resolution

**Option A — Accept incoming (settled value is wrong/outdated):**
1. Create a proposal updating the topic file: mark old row `SUPERSEDED`, add new `SETTLED` row
2. Normal approval → apply → commit
3. Delete the dispute file

**Option B — Reject incoming (settled value holds):**
1. Annotate the source digest: mark the contradicting claim as `OVERRIDDEN BY RECONCILIATION: <ID>`
2. Delete the dispute file. No change to topic file needed.

**Option C — Context-dependent:**
1. Create a proposal updating the topic file: change status to `CONDITIONAL`, add context note
2. Normal approval → apply → commit
3. Delete the dispute file

## Resolving a dispute — capture the reasoning first

Before deleting a dispute file, capture the adjudication as a `corrections/` note
(`trigger: dispute`) and commit it. The topic file records **which fact won**; the
correction records **why**, and the rule that stops the contradiction recurring.
Deleting a dispute without it discards the reasoning and guarantees the same source is
re-ingested, re-flagged, and re-adjudicated from scratch.
See STANDARD.md §"Resolving a dispute" and §"The correction loop".
