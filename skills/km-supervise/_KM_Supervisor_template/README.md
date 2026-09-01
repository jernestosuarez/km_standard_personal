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

## Estate-tier skills: linked here, never copied, never at the workspace root

The estate-tier skills (`km-init`, `km-supervise`, `km-vault-upgrade`) have one canonical copy
each, in the standard checkout's `skills/` tree. They resolve **inside this directory**, through
`.claude/skills/<slug>` entries — and `.agents/skills/<slug>` where the estate uses an AGENTS.md
surface — that are **symlinks to those canonical directories, never copied trees**.

**Why here and not the workspace root above.** This tier is the estate's governed unit: a git
repository, with a change rule, holding the estate's state, and carrying its own
`CLAUDE.md`/`AGENTS.md` — structurally the same shape as a hub, which is where every other skill
in this standard lives beside its scope guard. The workspace root above is an ordinary folder,
not a repository: a `.claude/` placed there is untracked by anything, reached by no scan, and
orphaned from any scope guard. An estate session therefore runs **in this directory**, with the
hubs as siblings at `../`.

A copy rather than a link is the drift class the standard has already measured (the one skill
copy without a parity check was the one that drifted), and no check reaches a copy inside a
deployed estate; a link keeps every session on the checkout's governed text, and updating a
skill becomes `git pull` in the checkout.

Two control points, and only these:
- **Minting a new instance** — create the links when this tier is minted, one per estate-tier
  skill the estate uses, in both runtime trees the estate runs.
- **Health-check** — each skill's own first step verifies its link on every run: a missing entry
  is offered for creation (owner authorization plus a commit stating the reason), a copy found
  in its place is reported as drift risk and offered for replacement, and a link found at the
  superseded workspace-root location is offered for relocation here — never left silently.

**Bind only what exists.** A hub next to this tier carries estate-binding references only to the
files and directories actually present here; a dangling binding is worse than none. When a
capability above is adopted, extend each hub's estate-binding section through that hub's own
governance.

This tier is git-backed (initialize a repository here at minting). It uses no proposal/approval
ceremony: its change rule is owner authorization in session plus a git commit stating the
reason.
