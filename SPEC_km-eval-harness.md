---
type: reference
title: Spec — KM Eval Harness (retirement evidence + settled-fact regression)
description: Buildable specification for a lightweight eval harness that generates a question→answer set from a hub's settled facts and decision notes, then measures which records are exercised and which the hub can still answer. Supplies evidence for the standard's existing lifecycle-retirement discipline. Non-normative proposal; adoption routes through the standard-maintainer.
tags: [spec, evaluation, retirement, value-measurement, provenance]
timestamp: 2026-08-05
---

# Spec — KM Eval Harness

> **Status: proposal spec, non-normative.** Companion to
> [DESIGN-RATIONALE_akcp-component-mining.md](DESIGN-RATIONALE_akcp-component-mining.md) (pattern 3).
> Folding it into STANDARD.md as a required step is a standard-maintainer decision.

## Purpose

Give the standard's **lifecycle-retirement** discipline the evidence it currently lacks. Retirement today
is a judgment call — nothing shows *which* records are never used or can no longer be answered. This harness
produces that signal, and as a by-product regression-tests that an agent answering from a hub gets its
settled facts right.

**It measures the hub; it never edits it.** Output is evidence for a human retirement decision, not an
action.

## Non-goals

- Not an autonomous pruner — it proposes candidates; retirement stays a human/owner decision via the
  normal workflow.
- Not a benchmark of the LLM — it tests whether *the hub's content* is retrievable and correct, holding the
  model fixed.
- Not a new store — it reads existing hub files and writes one report; no database, no runtime service.

## Inputs

- A hub's **settled facts** (reconciliation topic files) and **decision notes** (`decisions/`), plus any
  entity notes marked authoritative.
- Each input already carries provenance (the source-traceability rule) and `lifecycle`.

## Mechanism

Three stages, each a small script (bash + the estate's existing agent tooling; no new runtime).

1. **Generate** — for each settled fact / decision note with `lifecycle: active`, derive one or more
   `question → expected-answer` pairs, tagged with the source note's id. Store as a plain
   `eval/<hub>.questions.jsonl` (or markdown table). Regenerated when notes change; never hand-authored
   answers — they are extracted from the note, so the note remains the source of truth.

2. **Run** — pose each question to an agent restricted to *reading the hub* (no outside knowledge). Record,
   per question: answered / not-answered / wrong, and which note id(s) the answer drew on.

3. **Report** — emit `eval/<hub>.report.md` with three lists:
   - **Regression failures** — questions the hub should answer from a settled fact but got wrong or could
     not answer. A correctness signal (possible stale or contradictory content).
   - **Never-exercised records** — active notes that no generated question ever needed. Retirement
     candidates by disuse.
   - **Unanswerable-now records** — notes whose question the hub can no longer answer (source moved,
     context lost). Retirement or reconstruction candidates.

## Integration with existing mechanics

- **Retirement:** the report's "never-exercised" and "unanswerable-now" lists are the evidence input to the
  standard's retirement decision — they do not retire anything themselves.
- **Scan:** the harness runs on demand (e.g. per hub, quarterly), not on every session. The scan may
  surface *staleness of the last report*, not run the eval inline (keep it out of the hot path).
- **Provenance:** because every question is tagged with its source note id, the report is itself traceable —
  each finding names the record it came from.
- **Indexes:** report files carry `lifecycle: active` and are generator-owned; never hand-edited.

## The measurement it provides (why it matters)

A curated knowledge estate can run indefinitely on the belief that it is useful. Retirement gives the
standard a way to remove what has aged; this harness gives retirement a way to *know what has aged* rather
than guess. Records that no question needs, and questions the hub can no longer answer, are the concrete
prune signal — the difference between an examined hub and an unexamined one.

## Open questions for the standard-maintainer

1. **Question generation** — agent-derived per note, or a small fixed template per note type
   (decision / risk / settled fact)? Template is cheaper and more stable; agent-derived covers more phrasing.
2. **Cadence** — per-hub quarterly, or triggered by a size/age threshold?
3. **Answer grading** — exact-match on extracted facts (cheap, brittle) vs agent-judged equivalence
   (robust, costs tokens). Recommend exact-match for facts with values/dates, agent-judged for prose.
4. **Scope** — settled facts + decisions only (recommended first cut), or all entity notes?

## First cut (smallest buildable version)

Settled facts + `decisions/` only · template-generated questions · exact-match grading on the note's stated
value · one report per hub, run on demand. Everything else is a later increment.

*2026-08-05. Proposal spec; non-normative companion to STANDARD.md.*
