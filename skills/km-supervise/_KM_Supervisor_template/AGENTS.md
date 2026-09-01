---
type: config
title: Agent Instructions — Supervisor Tier
description: Instructions for agents working at the estate tier. Routing scope, governance rules, and the skills this tier resolves.
tags: [governance, config, supervisor]
timestamp: {{INIT_DATE}}
---

# Working instructions — Supervisor tier

This directory is the **estate tier**, not a hub and not a software project. It holds estate-level
state — the hub registry, the owner's queue, cross-hub relationships, routing history — and it
governs how material reaches the hubs beside it. Read [`README.md`](README.md) for what the tier
holds at minimum and the named condition under which each further capability is adopted.

**The hubs are siblings at `../`.** An estate session runs here, in this directory, and reaches a
hub as `../<hub>/`.

## Scope guard

This tier has a **routing scope, not an admission rule**. A hub admits sources; this tier decides
*which hub* a fact belongs to and records how the hubs relate. It never holds hub knowledge
itself.

- **In scope:** the hub registry and routing keywords; cross-hub relationships; the estate queue;
  routing decisions and their log; the unrouted backlog; source systems shared across hubs;
  estate-wide corrections; campaign state for bulk ingestion.
- **Out of scope:** any hub's own knowledge. Entity notes, rollups, claims and decisions belong in
  the hub that owns them. If a fact has one home hub, it lives there and this tier holds at most a
  pointer.
- **Hard exclusion — refuse even when it would be convenient:** never write into a hub's governed
  tree directly. Everything this tier sends to a hub arrives as a proposal in that hub's
  `changes/`, applied by the hub's own flow.

## Change rule

This tier uses **no proposal/approval ceremony**. Its change rule is **owner authorization in
session plus a git commit stating the reason**. That applies to every file here, including the
adoption of a new capability from the README's growth-conditions table and the adoption of new
estate state such as a campaign ledger.

Stage exact paths. Blanket staging in a populated tree is prohibited.

## Skills this tier resolves

Estate-tier skills (`km-init`, `km-supervise`, `km-vault-upgrade`) resolve from
`.claude/skills/<slug>` here — and `.agents/skills/<slug>` where this estate runs an AGENTS.md
surface — as **symlinks into a standard checkout, never copied trees**. See
[`README.md`](README.md) → "Estate-tier skills" for why the links live here rather than at the
workspace root above, and for the two control points that keep them honest.

Per-hub skills are a different class: each hub receives its own copies from the standard's
`template/` at initiation.

## Working notes

- Prefer reading [`hub-registry.md`](hub-registry.md) before answering any question about which
  hub owns what; it is the routing map's home of record.
- A surfaced item is a queue row: if something needs the owner, it goes in
  [`QUEUE.md`](QUEUE.md) rather than staying in a session.
- This directory is git-backed. Commit as you go, with the reason in the message.
