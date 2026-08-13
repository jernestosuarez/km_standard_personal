---
type: reference
title: Design Rationale — Components Mined from Semantica
description: Patterns worth lifting into this standard from Semantica (semantica-agi/semantica, graph-native accountable-AI infrastructure), each mapped to a live gap and passed through the value-gate. Two pass, one passes conditionally, two are rejected with reasons. Non-normative companion; adoption routes through the standard-maintainer.
tags: [rationale, temporal, provenance, decisions, reconciliation, evaluation]
timestamp: 2026-08-13
---

# Design Rationale — Components Mined from Semantica

> **Status: companion rationale, not normative.** Does not change [STANDARD.md](STANDARD.md); adoption
> of any pattern is a standard-maintainer decision. Source examined:
> `semantica-agi/semantica` (MIT, Python; examined 2026-08-13 at 6,155★, ~14 months old, actively
> maintained). The *software* is not a candidate for the standard — same framing rule as
> [DESIGN-RATIONALE_akcp-component-mining.md](DESIGN-RATIONALE_akcp-component-mining.md): lift ideas as
> lightweight additions (a frontmatter convention, a generator step), never import a runtime. Each
> candidate passes the value-gate: *does it answer a question the estate has today?*

## Why this source

Semantica is the closest software embodiment yet of this standard's own design — closer than AKCP and
far more mature: **decisions as first-class, permanently recorded objects** with causal chains and
precedent search; **provenance on every fact** (W3C PROV-O); **conflict detection across sources**
before facts enter the graph; **bi-temporal fact tracking**. A graph-native product converging on the
same primitives is corroboration; where it goes further, its extensions mark candidate gaps here.

## Patterns that PASS the value-gate

### 1 · Bi-temporal validity — separate "when true" from "when recorded" — **priority**
- **Semantica:** every fact carries *valid time* (when it holds in the world) and *recorded time*
  (when the system learned it); point-in-time queries follow.
- **Standard today:** all temporal fields are **record-side** — `date settled`, `last-reviewed`,
  `timestamp`. Nothing states how long a settled value is expected to *remain* true.
- **The live gap this answers:** the first eval-harness pilot demonstrated it — settled facts graded
  internally consistent while the estate elsewhere recorded developments contradicting them. The
  harness's scope statement ("internal consistency, not a check against the world") names the hole;
  nothing currently closes it.
- **Lift:** one optional frontmatter field on settled-fact rows and decision notes —
  **`valid-until:`** (a date) **or `review-by:`** (equivalent semantics: the claim owner's statement of
  when this value should be re-examined). Mechanically checkable: the scan (or the eval harness's
  report stage) lists rows whose validity window has lapsed — **staleness candidates by declaration,
  not by guess**. This also supplies a second, independent evidence stream to the retirement
  discipline, alongside the harness's unanswerable-now list.
- **Cost:** one field + one advisory-class check. No runtime, no graph.
- **Value-gate: PASS — strongest of the set; the gap is documented, dated, and currently open.**

### 2 · Decision causal edges — make the decision chain traversable
- **Semantica:** `trace_decision_chain()` (full causal ancestry), `find_similar_decisions()`
  (precedent), `analyze_decision_impact()` (downstream effects) — decisions linked to decisions.
- **Standard today:** decision notes link *what they replace* (`supersedes:` — the vertical chain) but
  not *what informed them or what they enabled* (the causal graph). "Which earlier decision does this
  rest on?" is answered by memory or grep.
- **Lift:** optional frontmatter edges on decision notes — **`informed-by: ["[[note]]"]`** and its
  generated inverse — using the existing wikilink idiom. Index generation already walks frontmatter;
  the chain becomes listable without any new machinery. Precedent search stays what it is today
  (query agents over `decisions/`), now with edges to follow.
- **Value-gate: PASS, modest** — the question recurs whenever a new decision must cite its governing
  prior; cost is near zero because it reuses two existing mechanisms (frontmatter, wikilinks).

## Conditional

### 3 · PROV-O as the vocabulary for the provenance manifest (refines AKCP pattern 4, not a new item)
- **Semantica:** exports provenance as **W3C PROV-O** for regulatory submission.
- **Standard today:** source-traceability is prose discipline; the machine-readable
  **provenance manifest** proposed in the AKCP rationale (pattern 4) remains unbuilt.
- **Lift:** *when* pattern 4 is built, shape its fact→source map on PROV-O terms
  (`wasDerivedFrom`, entity/activity/agent) instead of inventing a schema — same effort, standard
  vocabulary, free interoperability with any tool that speaks it.
- **Value-gate: conditional PASS** — bites only when pattern 4 is funded; recorded here so the
  manifest, if built, is built once.

## Rejected — with reasons

- **Automated conflict *resolution*** (credibility-weighted / most-recent / voting). The detection
  half is already this standard's reconciliation check; the resolution half is **deliberately
  rejected**: resolution authority here is the owner applying the evidence trust order, not an
  algorithm. Semantica's strategies are a machine restatement of a trust hierarchy — this standard
  keeps the hierarchy and keeps the human. Recorded as a **divergence to preserve**, not a gap.
- **Graph export / traversal layer** (triples, SPARQL over the entity layer). The estate's wikilinks,
  generated indexes and JSON-LD context already answer every traversal question currently asked, via
  grep. Fails the value-gate today; the standard's own restraint line applies — don't climb higher
  than you need. Revisit only if a real query the current mechanics cannot answer appears.

## Priority

Pattern 1 (`valid-until:`/`review-by:`) first — it closes a documented, dated, still-open gap from the
first eval-harness pilot and gives retirement its second evidence stream. Pattern 2 rides along at
near-zero cost. Pattern 3 waits on AKCP pattern 4.

*2026-08-13. Mining rationale; companion to STANDARD.md, non-normative. Related:
DESIGN-RATIONALE_akcp-component-mining.md (framing rule, pattern 4), SPEC_km-eval-harness.md
(the internal-consistency scope statement pattern 1 addresses).*
