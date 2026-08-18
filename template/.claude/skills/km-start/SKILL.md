---
name: km-start
description: Use at the start of any session in this knowledge hub, or to check its health. /km-start runs the structural scan plus the corrections, staleness and competency-question audits.
---

# Skill: km-start — Session Opening Audit

You have been invoked as `/km-start`. Run this at the beginning of every session involving
this hub. It checks structural health, flags stale or time-sensitive content, and — after
confirmation — can draft a proposal to clean up clearly expired items.

---

## Step 1 — Structural check

Run `bash hub-scan.sh` from the hub root.

- **Any section reports an issue** → surface it to the hub owner and stop. Do not proceed
  to content scanning until structural issues are resolved.
- **All sections OK** → proceed to Step 2.

---

## Step 1.5 — Corrections in force

Read `corrections/`. Report the count of `lifecycle: active` notes and list their `rule:` lines.

These are binding standing instructions, not history. An agent that has not read them will repeat a
mistake the hub already paid for. Flag any note whose `date:` is older than the hub's review cadence
(`07_glossary.md`) as a **retirement candidate** — a rule that no longer applies but still binds is
worse than no rule.

## Step 1.6 — Competency questions

Read the **Competency questions** table in `01_project-brief.md`.

Report, for each: is it still the right question, and can the hub answer it *now*?

- Flag any row whose **Last verified** is older than the review cadence in `00_about.md`.
- Flag any row still marked **answerable today = N** since the last session — that is the hub
  failing at the only thing it was built for.
- If the questions no longer reflect what the owner needs, say so. Questions changing is normal;
  questions being quietly ignored is not.
- **Topic coverage is not an answer.** Before reporting a row as **Y**, confirm the specific fact or
  decision the question asks for is actually recorded, and name where. Documents existing on the
  subject are not an answer, and a **Y** you cannot point at is an **N**.

This is the only check that measures whether the hub is **worth** anything. Every other section of
the scan measures whether it is *correct*. A hub can be perfectly correct and useless.

## Step 2 — Read HANDOVER.md

Read `HANDOVER.md`. Locate the date in section 5 ("Current state & open items").

- If section 5 was last updated **more than 3 days ago**, note: *"HANDOVER.md section 5 last
  updated [date] — run `/km-handover` at the end of this session."*
- If HANDOVER.md does not exist, note that too.

---

## Step 3 — Scan hub docs for time-sensitive content

Read all numbered hub docs present (`01_*.md` through `10_*.md`) and `HANDOVER.md`.

Scan for the following signals:

**Expired / likely stale:**
- Dates that have now passed, appearing near words like: *expires, deadline, quote, credits,
  by [month], before [date], target date*
- Items in `06_risks-decisions.md` marked as time-boxed to a date that has passed

**Unresolved pending:**
- Language like: *pending, TBD, to be confirmed, awaiting, not yet, no date set, to schedule*
- Blockers with no resolution or owner update

**Status that may have changed:**
- Items marked *on hold, paused, deferred* — these may have been resolved or escalated
- Partnership entries with no recent activity signal

For each signal found, record: file, approximate line or section, the flagged text, and which
bucket it falls into.

---

## Step 4 — Session briefing

Present findings in three buckets. Be specific — file and section for every item.

```
## Session briefing — [date]

### Hub scan
[All OK] OR [list issues]

### HANDOVER.md
[Up to date] OR [Stale — last updated YYYY-MM-DD]

---

### Bucket 1 — Expired / clearly stale
Items where the date has passed or the fact is demonstrably outdated.
No new information needed to act — just removal or archival.

- [file] § [section]: "[flagged text]" — [why it's stale]

### Bucket 2 — Unresolved pending items
Items that were open and may still be open — or may have been resolved externally.

- [file] § [section]: "[flagged text]" — [what's unknown]
  → Suggested action: run `/km-gather` against [source] to check

### Bucket 3 — Status that may have changed
Items on hold, deferred, or with no recent signal.

- [file] § [section]: "[flagged text]" — [what might have changed]
  → Suggested action: run `/km-gather` against [source] to check

---

### Recommended km-gather queries
[List specific queries the user could run against configured sources to resolve Bucket 2 + 3]
```

If no signals are found in any bucket, say so and end here.

---

## Step 5 — Confirm before proposing

For Bucket 1 items only:

Describe what a proposal would contain — each change as a plain-English sentence:
- *"Remove expired HPE GPU quote note from HANDOVER.md section 5"*
- *"Archive the $45K AWS credits deadline note — mark as expired"*

Then ask: **"Shall I create a proposal for these Bucket 1 items?"**

- **Yes** → create `changes/YYYY-MM-DD_agent_km-start_proposal.md` covering only the
  confirmed Bucket 1 items. Use the standard proposal format with Source = "hub-scan
  content audit (km-start)" and Evidence = the flagged text quoted from the hub doc.
- **No** → note the items for the user's reference and end.

Buckets 2 and 3 are never auto-proposed — they require external validation via `/km-gather`
before any hub change.
