---
type: index
title: Dates & Provenance Register
description: Control point for the date gate — no source is ingested without a resolved date.
tags: [provenance, dates, governance, sources]
resource: transcript-index.md
lifecycle: active   # the current generation of this document (STANDARD.md, Currency of generated documents)
timestamp: {{INIT_DATE}}
---

# Dates & Provenance Register

Enforces the **date gate** (STANDARD.md → Governance Layer → Rule 1): no source leaves `_inbox/`
without a resolved date. Every source gets a row here *before* it is ingested.

**Maintained by:** agents during intake. **Approved by:** the hub owner.

## Status values

- `MISSING` — no date yet; **blocks ingestion**. Ask the hub owner.
- `CONFIRMED` — date from the document or supplied by the hub owner. Ingestion allowed.
- `ESTIMATED` — inferred, with the basis stated; needs owner confirmation to become `CONFIRMED`.
- `UNKNOWN — reconstruction pending` — owner accepts the date is currently unrecoverable; ingestion
  allowed, gap tracked for later recovery.
- `N/A — reference artifact` — rate card, template, standard or similar reference whose date is
  irrelevant to the timeline; owner-marked. No reconstruction item; excluded from timelines.

## Procedure (run at every intake, before the move/apply step)

1. Add or refresh a row for every `_inbox/` source.
2. Fill any date found in the document — and note how it was derived.
3. For `MISSING` rows, present this register to the hub owner and request the dates.
4. Gate the move on Status ∈ {`CONFIRMED`, `UNKNOWN — reconstruction pending`, `N/A — reference artifact`}.
5. Record recovered dates here and propagate to hub docs via proposal/approval.

**Never guess or backfill a date.**

---

## Register

| # | Source | Date field | Value | Status | Basis / who confirmed |
|---|---|---|---|---|---|
| | | | | | |

---

_Last updated: {{INIT_DATE}}_
