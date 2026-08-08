---
type: reference
title: Design Rationale — Components Mined from AKCP
description: Four patterns worth lifting into this standard from the Agent Knowledge Compiler and Control Plane (AKCP), each mapped to current estate mechanics and passed through the value-gate. Non-normative companion; folding any pattern into STANDARD.md routes through the standard-maintainer.
tags: [rationale, governance, compilation, policy, provenance, evaluation]
timestamp: 2026-08-05
---

# Design Rationale — Components Mined from AKCP

> **Status: companion rationale, not normative.** Does not change [STANDARD.md](STANDARD.md). It records
> four patterns worth considering; adopting any of them into the standard proper is a standard-maintainer
> decision. Source examined: `vfcarida/Agent-Knowledge-Compiler-and-Control-Plane` (MIT, TypeScript,
> examined 2026-08-05 at 8★, one month old, single author — the *software* is far too early to depend on;
> only its *patterns* are mined here).

## Framing rule

Lift ideas as **lightweight additions** — a bash step, a declarative frontmatter convention — never the
compiler-and-control-plane software, which would import a Node/TypeScript runtime and a maintenance surface
this standard deliberately avoids. Each candidate is passed through the value-gate: *does it answer a
question the estate has today?* Patterns that fail it are recorded as rejected, not deferred.

## The four patterns

### 1 · Compile-to-Context-Packs — "compile once, don't rediscover per query"
- **AKCP:** compiles knowledge once into an intermediate representation, then emits agent-ready Context
  Packs rather than re-reading raw sources on every query.
- **Estate today:** `km-brief` and agents read hub docs and entity notes live, each time.
- **Improvement:** extend the index generator to emit a compiled, provenance-tagged **context pack** per
  hub that agents and `km-brief` consume instead of re-reading raw markdown. Reduces re-read cost and
  operationalises the standard's own instinct to keep the structured, decision-bearing content authoritative.
- **Value-gate:** PASS — re-read cost is real and grows with the estate.

### 2 · Declarative Policy Cards — machine-checkable governance
- **AKCP:** governance as declarative files (allowed agents/tools, side-effect rules `read = audit /
  write = deny`, approval requirements, PII), mapped to NIST AI RMF and OWASP LLM.
- **Estate today:** the equivalent rules live as *prose* — the working-instructions file, the change
  workflow, `corrections/`, the sensitivity clause. Binding, but an agent must read and remember them.
- **Improvement:** express the standing rules as a small **declarative policy file per hub** that the scan
  checks — who may edit what, what needs a proposal, what escalates, sensitivity handling. Makes the
  binding rules enforceable by tooling rather than advisory.
- **Value-gate:** PASS — the estate already has these rules; this makes them checkable.
- **Caveat:** AKCP's own policy engine is the part that does not work — its README admits
  *"rules[].condition is accepted by the schema but not yet evaluated."* Lift the pattern, not the
  implementation, and keep it a **check**, never an autonomous enforcer. The human-gated change workflow
  stays the authority.

### 3 · Eval harness from knowledge — the measurement retirement currently lacks
- **AKCP:** compiles knowledge into eval datasets.
- **Estate today:** the standard added lifecycle **retirement** ("retiring what no longer earns its place",
  and the prune point in the corrections lifecycle). But retirement is a **judgment call with no evidence
  behind it** — nothing tells you *which* records are never used or can no longer be answered.
- **Improvement:** a generator that turns settled facts and decision notes into a
  question→expected-answer set, used two ways: (a) regression — an agent answering from the hub gets
  settled facts right; (b) **retirement evidence** — records never exercised by any question, or that the
  hub can no longer answer, become prune candidates. This supplies the missing measurement *under* the
  existing retirement discipline rather than adding a parallel one.
- **Value-gate:** PASS, strongest of the four — it gives an existing standard mechanism (retirement) the
  evidence it currently does without.
- **Full specification:** [SPEC_km-eval-harness.md](SPEC_km-eval-harness.md).

### 4 · Provenance build manifest — make traceability tooling-verifiable
- **AKCP:** emits build manifests carrying provenance as a compilation output.
- **Estate today:** a source-traceability rule enforced by *discipline*, plus an integrity manifest
  (SHA-256 — *has it changed*). Nothing records *lineage* (where each fact came from) as a checkable artifact.
- **Improvement:** generate a **provenance manifest** alongside the integrity manifest — a machine-readable
  fact→source map — so unsourced claims are caught mechanically at scan time instead of by reviewer habit.
- **Value-gate:** PASS — unsourced facts are already treated as a defect; this detects them.

## Rejected — already covered

- **Intermediate-representation / schema normalisation** — AKCP's headline ("solved five incompatible schema
  shapes") is already solved here by OKF frontmatter and the entity-note templates.
- **Two-phase commit before side-effects** — already present as proposal/approval and the escalation
  protocol; AKCP's version is thinner.
- **Capability mapping** — partially covered by the agent registry; a minor formalisation at most.

## Priority

Item 3 (eval harness) first — smallest build, and it supplies evidence to a mechanism the standard already
has but currently runs on judgment alone. See the spec.

## Addendum — independent convergence (2026-08-08)

AWS's **Context Ontology Accelerator** (`aws/context-ontology-accelerator`, official `aws` org, examined
2026-08-08) independently implements the same governance shape this standard and AKCP arrived at: AI
proposes metadata, **nothing becomes authoritative without human review**, and steward edits sit in an
explicit priority hierarchy — `STEWARD_EDITED` > `DETERMINISTIC` (from constraints) > `AI_GENERATED` —
where higher priority always survives regeneration, and *editing and approving are two distinct actions*.
That is three independent arrivals at human-gated, provenance-tiered knowledge governance (this standard,
AKCP, COA), the third from a major cloud vendor's official org. Recorded as corroborating evidence that
the standard's core design is the emerging industry pattern — not as grounds for any rule change, which
still requires operational evidence per the maintainer's discipline.

*2026-08-05. Adversarial/mining rationale; companion to STANDARD.md, non-normative.*
