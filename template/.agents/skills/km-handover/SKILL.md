---
name: km-handover
description: Use at the end of a working session, or when the handover is stale. /km-handover rewrites the current-state and open-items section of HANDOVER.md for the next agent.
---

# Skill: km-handover — Update Session Handover

You have been invoked as `/km-handover`. Update section 5 of `HANDOVER.md` so the next
agent can resume this hub's work without re-deriving context.

---

## Step 1 — Collect session summary

Ask the user in one message for:
- **What was done:** what changed in the hub this session (files edited, proposals applied, sources ingested)
- **Open items:** anything unfinished, pending approval, or blocked
- **Next steps:** what the next agent should prioritise first

If the user includes this information directly in the `/km-handover` invocation, use it as-is
without asking again.

---

## Step 2 — Read current HANDOVER.md

Read `HANDOVER.md` from the hub root. Locate section 5:
- **Start:** the line `## 5. Current state & open items`
- **End:** the line immediately before `## 6.` (or end of file if section 6 is absent)

---

## Step 3 — Replace section 5

Overwrite the content between the section 5 heading and the section 6 heading with a dated
entry. Keep the heading `## 5. Current state & open items` and the blockquote note intact.
Replace only the body:

```
## 5. Current state & open items

> _Updated by the agent at the end of each session via `/km-handover`. Replace this block entirely — do not append._

**As of YYYY-MM-DD:**

- [Summary of what was done this session]
- [Proposals applied / created / deleted]
- [Sources ingested / reconciliation actions]

**Open items:**
- [Anything unfinished or blocked — include owner if known]
- [Proposals awaiting approval]

**Next steps for the next agent:**
1. Run `bash hub-scan.sh`
2. [First priority]
3. [Second priority if any]
```

Do not modify any other section of HANDOVER.md.

---

## Step 4 — Report

Confirm: `HANDOVER.md updated — section 5 reflects work as of [date].`
