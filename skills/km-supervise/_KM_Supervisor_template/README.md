---
type: config
title: Supervisor Tier — the minimum tier and its growth conditions
description: What this tier holds at minimum, and the named condition under which each omitted capability is adopted.
tags: [supervisor, config, minimum-tier]
timestamp: {{INIT_DATE}}
---

# Supervisor tier

This directory is the estate tier: estate-level state lives here, never inside a hub, because
the decision queue, the owner's surface, and cross-hub reconciliation belong to the estate and
putting them in a hub conflates the tiers.

**The minimum tier is deliberately small** (STANDARD.md → Supervisor Tier → "The minimum
tier"): a hub registry, an estate queue, an inbox, and this directory's own git history. That is
all a two-hub estate needs on day one. Everything else is adopted **against a named condition**,
never pre-built — a tier that demands the full apparatus up front is a tier the rule-follower
ignores.

## Growth conditions — adopt each capability when its condition first occurs

| Capability | Adopt when | Reference |
|---|---|---|
| Routing pass (`relationships.md`, `routing-log.md`, `_unrouted/`) | A source belongs to two or more hubs | STANDARD.md → "The supervise workflow" |
| Semantic layer (shared-entity registry) | Hubs start disagreeing about the same people, organizations, or products | STANDARD.md → "The semantic layer" |
| Escalation protocol (`escalations/`) | Someone other than the owner operates a hub, or restricted-class content appears | STANDARD.md → "Escalation protocol" |
| Evidence standard (`EVIDENCE.md`) | Two sources conflict and the hubs need one binding trust order | STANDARD.md → "Evidence standard" |
| Estate corrections registry (`corrections/`) | The owner corrects the agent on a rule that crosses hub boundaries | STANDARD.md → "The correction loop runs at the estate tier too" |
| Decision surface (KM Cockpit component) | The owner wants the queue as rendered cards rather than a file | `components/km-cockpit/` in the standard |

**Bind only what exists.** A hub next to this tier carries estate-binding references only to the
files and directories actually present here; a dangling binding is worse than none. When a
capability above is adopted, extend each hub's estate-binding section through that hub's own
governance.

This tier is git-backed (initialize a repository here at minting). It uses no proposal/approval
ceremony: its change rule is owner authorization in session plus a git commit stating the
reason.
