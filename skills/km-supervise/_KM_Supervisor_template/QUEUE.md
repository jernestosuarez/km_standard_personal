---
type: index
title: Owner Queue
description: The owner's single decision surface — every proposal batch, escalation, and ask registers here as one self-explanatory row; nothing counts as surfaced without one.
tags: [supervisor, owner-queue, index]
timestamp: {{INIT_DATE}}
---

# Owner Queue

The single decision surface (STANDARD.md → Supervisor Tier → "The owner queue"). One row per
open item, canonical schema `Id | Since | Defaults | Decision | Options`: Decision opens with
one bold recognition sentence, Options are exact quoted verbs with the recommendation first.
Tier A never defaults; tier B names its specific default action first and `veto` second, and
auto-applies on the default date unless vetoed; tier C asks nothing. Each tier-A/B row carries a
decision brief at `queue-briefs/<id>.md` before it is answerable. In a single-hub deployment
this same file lives at the hub root; the format is identical at both scales.

**Options are exact quoted verbs**, recommendation first. Bold is optional presentation and is
never what makes a verb an option; the quotes are. A row whose Options cell cannot be read is
**reported** — by `hub-scan.sh` and by `km-cockpit.py queue-check` — and its card renders with no
answer controls and the reason stated, because a card that looks complete with nothing to press
is worse than a card that says it is not ready.

**Worked examples.** These are inside a fenced block, so they are documentation: a decision
surface parses queue rows, never fenced ones, and these will not render as decisions. Copy the
shape into the tables below.

```
| a4 | 08-19 | - | **Approve the pilot budget.** The vendor holds the quote until Friday and the amount is above the delegated limit. | "approve", "approve at half", "decline" |
| b7 | 08-19 | 08-26 | **Publish the revised onboarding note.** Two hubs asked for it; the change is reversible and touches no client-facing surface. | "publish it", "veto" |
```

Their machine-block lines, which supply the dates:

```
a4 | a | 2026-08-19 | - | approve the pilot budget?
b7 | b | 2026-08-19 | 2026-08-26 | publish the revised onboarding note?
```

## Tier A — needs the owner's word

| Id | Since | Defaults | Decision | Options |
|---|---|---|---|---|
| | | | | |

## Tier B — applies its recommendation unless vetoed

| Id | Since | Defaults | Decision | Options |
|---|---|---|---|---|
| | | | | |

## Tier C — FYI

- *(none)*

## Owner's desk

Personal follow-ups and chases — dated nudges, never decision rows.

- *(none)*

<!-- QUEUE:BEGIN
id | tier | raised | default | ask
QUEUE:END -->

<!-- SUPERVISOR-ACTIONS:BEGIN
id | since | due | action | evidence
SUPERVISOR-ACTIONS:END -->
