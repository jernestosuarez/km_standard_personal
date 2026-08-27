---
type: config
title: KM Cockpit — deployment
description: How to deploy the KM Cockpit side component; the normative contract lives in SPEC.md.
tags: [cockpit, component, deployment, owner-queue]
resource: km-cockpit.py
timestamp: 2026-08-17
---

# KM Cockpit — the owner decision surface (side component)

The cockpit renders the owner queue (`QUEUE.md`) as full-context decision cards, captures the
owner's answers into an append-only local store, and shows what the estate did with each answer.
It is a **side component** of the KM Standard: it ships in its own directory, deploys in its own
step, and no hub or supervisor mechanism depends on it. Delete it and the estate is unchanged —
chat and the batched clearing skill remain equally valid answer channels.

**What it never does:** execute anything, write estate state, mutate `QUEUE.md`, or mint
identity. It is a surface, not a pen. The full normative contract — data model, card contract,
proposal lifecycle states, request channel, invariants — is [`SPEC.md`](SPEC.md), and it binds
any reimplementation, not just this reference file.

## Deployment (its own step, never part of a hub or site deploy)

1. Copy this directory to the deployment location:
   - **multi-hub estate:** inside the supervisor tier, e.g. `_KM_Supervisor/cockpit/`;
   - **single hub (no supervisor tier yet):** inside the hub, e.g. `<hub>/cockpit/`, with a
     hub-local `QUEUE.md` at the hub root (template:
     `skills/km-supervise/_KM_Supervisor_template/QUEUE.md` — the same file the supervisor tier
     uses; the data contract is identical at both scales).
2. `cp km-cockpit.example.json km-cockpit.json` and fill in the manifest: estate root, queue
   path, hub-registry path (omit for single-hub), port, organization name, state directory.
   The manifest is the component's **only** deployment-specific input; the per-hub attribution
   map derives from the governed hub registry, never from edits to the code.
3. `python3 km-cockpit.py serve` (Python 3 stdlib only — no venv, no dependencies). Session-side
   CLI: `pull` · `questions` · `reply <id> "text"` · `exec <id> "note" [status]` · `dismissed` ·
   `desk` · `queue-check [<path>]` · `selftest`.
   `queue-check` reports any tier-A/B row that fails to parse or whose declared options the
   surface cannot read, and is what a supervisor tier runs at session start (a single-hub
   deployment gets the same check from `hub-scan.sh`'s `[ QUEUE ]` block). Three exit codes: `0`
   readable, `1` a row cannot be read, `2` refused — no path, or the queue could not be read. It
   never writes. `pull` writes each consumed answer's trace to `answer-pickup-log.md` beside
   the queue file BEFORE truncating the pending store, so no ordering can lose a record
   (SPEC.md §3, v1.64); `dismissed` and `desk` are read-only listings and consume
   nothing.
4. Verify by fetching: `/`, `/decisions`, `/activity`, `/hubs`, `/api/state`. A served-surface
   change is done when the owner can see it — after any change, restart the server and fetch the
   page before reporting done.

**When the second hub arrives** and the minimum supervisor tier is minted (STANDARD.md →
Supervisor Tier → "The minimum tier"), move the estate queue there and re-point the manifest's
`queue_path` (and add `hub_registry_path`). One config change; no rebuild, no data migration —
the queue file, briefs directory, and answer store keep working as they are.

## Security posture (normative — SPEC.md §Unpublished by default)

- Binds `127.0.0.1` only; the bind address is deliberately **not** configurable.
- Never published beside a reading site, docs portal, or any audience surface. The decision
  layer carries budget, identity, and commercial context — often more sensitive than the
  knowledge it decides about. Decision surfaces are **unpublished by default**; any shared or
  remote access is an explicit owner decision carrying clearance and an audit trail.
- Every file-serving route confines its path to the estate root. Never widen this.

## Running two cockpits on one machine

Two estates (or a hub-local cockpit and an estate cockpit) need **distinct `port` and
`state_dir` values** — the answer stores must never collide.

## Notifications

Desktop notifications use macOS `osascript` and are best-effort: on other platforms the notify
loop is a silent no-op and nothing else degrades.
