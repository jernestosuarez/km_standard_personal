---
name: km-supervise
description: Use when a source, decision or fact touches more than one hub. /km-supervise routes it from the supervisor tier into each affected hub's own proposal flow.
---

# Skill: km-supervise — Route a Cross-Cutting Source Across Hubs

You have been invoked as `/km-supervise`. A **cross-cutting source** (meeting transcripts, an
all-staff call, leadership 1:1s) touches many initiatives at once. Your job is to extract its facts,
decide **which hub owns each fact**, record **how hubs relate**, and dispatch proposals into the
correct hubs — **without ever editing a hub doc directly**.

You operate the **Supervisor tier** defined in `STANDARD.md` (Supervisor Tier — Cross-Hub
Orchestration). Run this from the workspace root (the folder that contains `_KM_Supervisor/` and the
hubs).

**Governing principles (do not violate):**
- **Single home of record.** Every fact has exactly one home hub. Other hubs get a *typed reference*, never a copy.
- **Owner decides routing.** You *propose* every routing and every relationship; the owner confirms or overrides. Never auto-assign a contested fact, auto-create a hub, or auto-confirm an edge.
- **No bypass.** You write proposals into each hub's `changes/`. That hub's own approval / reconciliation / commit flow then applies, unchanged.

**Modes:**
- `/km-supervise` — full run, ending in dispatched proposals.
- `/km-supervise --dry-run` — steps 1–6 only; show the routing table, write nothing.

---

## Step 1 — Load the Supervisor state

Read, in full:
- `_KM_Supervisor/hub-registry.md` — the routing map (hubs, repos, owners, routing keywords)
- `_KM_Supervisor/relationships.md` — existing edges (so you don't re-propose known ones)

If `_KM_Supervisor/` does not exist, stop and tell the owner to stand up the Supervisor first
(see "The supervisor threshold" in `STANDARD.md` — advised the moment there is more than one
hub) — offer to mint the minimum tier from `_KM_Supervisor_template/`.

If the tier exists but is the **minimum tier** (no `relationships.md`, `routing-log.md`, or
`_unrouted/`), this run is exactly the named condition for adopting the routing capability — a
source now belongs to two or more hubs. Say so, and offer to create the three routing files
from the template (with OKF frontmatter) before proceeding; the first run should be `--dry-run`.

Ask once: **"Refresh the registry before we start? (re-scan hub scope guards + glossary tags)"**
- **Yes** → re-derive routing keywords for each hub from its `CLAUDE.md` scope guard and
  `07_glossary.md` tag vocabulary; update `hub-registry.md`; show a one-line diff; proceed.
- **No** → proceed with the registry as-is.

---

## Step 2 — Choose the cross-cutting source and scope

Ask the owner in one message:
1. **Which source** — e.g. a meeting-transcript tool, a folder of notes, pasted text.
2. **Scope** — date range, meeting list, or query (e.g. "meetings 2026-06-22 → 2026-06-26").
3. **Optional hub focus** — restrict routing to a subset of hubs, or default to all hubs in the registry.

---

## Step 3 — Extract facts (same discipline as `/km-gather`)

Read or search the selected source. Tag every fact as a tuple:

```
(claim, source_name, locator, evidence)
```

- **locator** — most specific reference available: page ID, timestamp, file path + line, date, heading.
- **evidence** — direct quote or close paraphrase, max 2 sentences.

**Hard rule:** a fact with no locator + evidence is not routed. Collect it and report it at Step 9 as
"could not be sourced." If a source item has no usable content (e.g. an empty transcript), note it as
"deferred — no content" and move on.

---

## Step 4 — Classify each fact against the registry

For each extracted fact, match its content against every hub's **routing keywords** and scope guard:

- Record **candidate home hub(s)** with a confidence read (high / medium / low) and the matched keyword(s).
- Honour each hub's **hard exclusions** — a keyword match inside an excluded thread is not a match.
- A fact may match: one hub (clean), several hubs (multi-home), a `repo` initiative (backlog), or
  nothing in the registry (out of scope).

---

## Step 5 — Build the routing table

Assemble a single table — one row per fact:

| # | Fact (short) | Locator | Candidate home | Other hubs interested | Proposed outcome |
|---|---|---|---|---|---|

Proposed outcome is one of: **HOME** (one hub) · **REFERENCE** (home + referencing hubs) ·
**BACKLOG** (repo, no hub) · **OUT OF SCOPE**. Also draft a short list of **candidate edges** for
`relationships.md` (e.g. `Hub_A depends-on Hub_B — shared vendor decision`).

If `--dry-run`: present the table and the candidate edges, state "dry run — nothing written," and stop.

---

## Step 6 — Stepped Q&A with the owner (the heart of this skill)

Walk the owner through the decisions **in this order**, batching the easy ones and asking one focused
question per contested item. Do not dispatch anything until this step is complete.

**6a — Bulk-confirm the clean facts.**
List every **HOME** fact whose candidate hub is unambiguous (single high-confidence match). Ask once:
> "These N facts each map cleanly to one hub. Confirm all, or call out any to revisit?"

**6b — Resolve multi-home facts, one at a time.**
For each fact matching more than one hub, ask a single question:
> "Fact: ‹claim›. It matches ‹Hub A› and ‹Hub B›.
> Which hub **owns** it (home)? The other(s) will get a reference, not a copy."
Record the chosen home; mark the rest as references.

**6c — Decide the no-home themes.**
Group BACKLOG facts by theme. For each recurring theme, ask:
> "Theme ‹X› (‹n› facts) has no hub. Options: **initiate a hub** (`/km-init`) · **park in backlog**
> (`_unrouted/`) · **ignore**. Which?"
Do **not** run `/km-init` here — only record the decision. If "initiate," note it as a follow-up.

**6d — Confirm relationship edges.**
For each candidate edge, ask:
> "Edge: ‹Hub A› **‹type›** ‹Hub B› — basis: ‹evidence›. Confirm / reject / change type?"
Reject freely — "no relationship" is a valid and common answer.

**6e — Flag reconciliation-relevant changes.**
If any HOME fact contradicts something you already know is settled in the target hub, note it now so
Step 7 can handle it; do not try to resolve it yourself.

Use a structured choice prompt for 6b–6d where it helps; keep each question to one decision. Capture
the owner's answers verbatim — they drive Steps 7–8.

---

## Step 7 — Reconciliation pre-check per target hub

For each hub that will receive a HOME proposal:
- Read that hub's `reconciliation/*.md` settled facts (excluding `README.md`).
- If a routed fact contradicts a `SETTLED` fact: **do not** put the change in the proposal body.
  Instead add a `⚠ RECONCILIATION CONFLICT` block at the top of that hub's proposal naming the
  settled fact ID. Hub-owner decision required there before it can apply.

This mirrors `/km-gather` Step 6 — the Supervisor never overrides a hub's settled facts.

---

## Step 8 — Dispatch (full mode only)

For each decision confirmed in Step 6:

**HOME →** write `‹hub›/changes/YYYY-MM-DD_supervisor_‹slug›_proposal.md` in the same format
`/km-gather` produces (Hub docs affected · Sources searched · per-change Source/Evidence/Change blocks,
plus any `⚠ RECONCILIATION CONFLICT` block from Step 7).

**REFERENCE →** write a lightweight proposal into the referencing hub that adds a **pointer stub**, not
the fact itself, e.g.:
> `See ‹home-hub›/06_risks-decisions.md#‹anchor› — owned there. Relationship: ‹type›.`

**EDGE →** append each confirmed edge to `_KM_Supervisor/relationships.md` under "## Edges"
(From · Type · To · Basis/source · Confirmed = YYYY-MM-DD). This is a Supervisor-owned file, so the
owner's Step-6 confirmation is the authority to write it.

**BACKLOG →** write the fact (with locator + evidence) into `_KM_Supervisor/_unrouted/‹theme›.md`.
If the owner chose "initiate," add a clearly-marked follow-up note at the top of that file.

Do **not** apply or approve any hub proposal — dispatch only. Each hub owner approves via their own flow.

---

## Step 9 — Log the run and report

Append an entry to `_KM_Supervisor/routing-log.md` under "## Runs":
- Date, mode (full / dry-run), source + scope
- Counts: facts extracted · routed home (per hub) · references · backlog · out of scope · could-not-source
- Confirmed edges
- Backlog themes and any "initiate hub" follow-ups
- Open reconciliation conflicts raised in target hubs

Then report to the owner, in this order:
- Source(s) and scope
- Routing table outcome (counts as above)
- Proposals dispatched: list each `‹hub›/changes/‹file›` (or "dry run — none")
- Edges recorded
- Backlog items + suggested new hubs
- Reminder: each dispatched proposal still needs approval **in its own hub** (create a matching
  approval file there or confirm in chat) before it applies.
