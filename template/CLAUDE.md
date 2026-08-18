---
type: config
title: Agent Instructions — {{PROJECT_NAME}} Knowledge Hub
description: Instructions for Claude agents working in this hub. Governance rules and workflows.
tags: [governance, config]
timestamp: {{INIT_DATE}}
---

> **Read [HANDOVER.md](HANDOVER.md) first — no exceptions.** It is the curated home of record for
> session-to-session state: current state, open items, and what was done last session. Read it
> **before** reconstructing any state from the git log or a diff; raw history is not a substitute for
> the curated handover. `hub-scan.sh` surfaces it as its first `[ HANDOVER ]` line.

# Working instructions — {{PROJECT_NAME}} Knowledge Hub

This directory is a **knowledge hub**, not a software project. The goal is to maintain a
governed, auditable source of truth for {{PROJECT_NAME}}.

## Scope guard

Cover **{{PROJECT_NAME}} only**. The guard is an admission rule, not a description:

- **Admit** a source when: {{SCOPE_IN}}
- **Exclude:** {{SCOPE_OUT}}
- **Hard exclusions — refuse even when a routing keyword matches:** {{HARD_EXCLUSIONS}}

Keyword matching is how a source reaches this hub in the first place, so the hard exclusions are
what actually stop one. If a fact is borderline, ask {{HUB_OWNER}}.

## Whose perspective

Produce work as **{{UNIT_NAME}}** — {{ORG_NAME}}. Register: institutional, authoritative, concise.

For fuller context on the hub initiator's role, goals, and working preferences, read `00_about.md`.

## Where the data lives

- **Initiator profile:** `00_about.md` — role, goals, and agent working notes for this hub
- **Source material:** files dropped in `_inbox/` and processed through the intake workflow
- **Curated hub:** the numbered markdown files in this directory (00–07+)
- **Transcripts / meeting notes:** drop in `_inbox/` for processing; reference in `sources/transcript-index.md`

## How to handle new sources (intake workflow)

1. Find new files in `_inbox/` (`hub-scan.sh` [INBOX] section flags them)
2. **Classify** the file:
   - **Source/input** (partner decks, external docs, transcripts, research) → steps 3–8 below
   - **Team output** (memos, briefings authored by the team) → propose move to `working-docs/<topic>/`; no digest
   - **Visual asset** (diagrams, images) → propose move to `assets/architecture/`; no digest
3. **Digest** — extract full content; for image-based PPTX extract embedded slide images, read visually, clean up temp files; note "what's new vs hub"
4. **Move** original to `sources/<subfolder>/`
5. **Write digest** as `<name>_digest.md` next to the original
6. **Run reconciliation check** (see below)
7. **Create proposal** in `changes/`
8. **Log** in `sources/transcript-index.md`

## Reconciliation check (during ingestion)

After creating a digest for a new source file (step 5):
1. Scan `reconciliation/*.md` topic files, excluding `README.md`, for SETTLED facts relevant to the source material
2. Extract key claims from the digest — dates, decisions, roles, technical choices, commitments
3. Compare extracted claims against settled facts
4. **No contradiction:** add "Reconciliation check: no conflicts" to the ingestion proposal
5. **Contradiction found:**
   - Create `reconciliation/_disputes/YYYY-MM-DD_<topic>_dispute.md` using the dispute template in `reconciliation/README.md`
   - Add `⚠ RECONCILIATION REQUIRED` section to the proposal listing all disputes
   - Do NOT auto-update reconciliation topic files — only hub owner decisions change settled facts
6. After {{HUB_OWNER}} resolves a dispute: **capture the adjudication as a `corrections/` note (`trigger: dispute`) and commit it** — the topic file records which fact won, the correction records why and the rule that stops it recurring — **then** delete the dispute file; update the topic file if needed (via proposal/approval)

## OKF frontmatter (all hub docs)

Every monitored hub doc must carry valid OKF v0.1 frontmatter (`type`, `title`, `description`, `tags`,
`resource`, `timestamp`). Verify frontmatter is present and `timestamp` is updated when applying
any proposal. `hub-scan.sh` validates frontmatter at every session start.

## Session-start checklist

At the start of every session involving this hub, before doing any other work:

1. **Run `bash hub-scan.sh`** — covers inbox, proposals, git-backed integrity, OKF frontmatter, and reconciliation disputes in one pass.
2. **Handle any issues reported by section:**
   - `[HANDOVER]` → **read `HANDOVER.md` first, before any state reconstruction from the git log or a diff**; a missing `HANDOVER.md` is an error, regenerate it via `/km-handover` before continuing
   - `[INBOX]` files found → report to {{HUB_OWNER}}; wait for instruction before processing
   - `[PROPOSALS]` ready to apply → apply, delete both files, log, commit
   - `[INTEGRITY]` uncommitted/untracked change → stop; surface to {{HUB_OWNER}} before doing anything else
   - `[FRONTMATTER]` missing → flag; fix before applying any other change
   - `[CURRENCY]` generated doc with no `lifecycle:` → mark it; advisory, never blocks a change
   - `[RESTRICTED]` restricted marker, frontmatter-restricted note name, or restricted section text on an outbound surface → error; remove it, or regenerate the index, before anything ships
   - `[RECONCILIATION]` disputes → each names who it is blocked on; surface to {{HUB_OWNER}} the ones blocked on the owner, report the rest as open, not as owner actions
   - `[AGENT]` false `Dispatched-By:` → a commit outside this hub claimed a dispatched agent acted; capture it as a `corrections/` note, do not rewrite history
3. **Read `corrections/`** — every note with `lifecycle: active` carries a `rule:` that is
   **binding** on this session. These are standing instructions produced when someone corrected the
   record; they encode how this organization actually works. Treat a `rule:` as you would an
   instruction in this file. Ignore `superseded` and `retired` notes.
4. All sections OK → proceed with the session's main task.

**When you get something wrong and it is diagnosed** — by the owner, by a scan, or by yourself —
write a `corrections/` note (`trigger: agent-error`) capturing the rule that prevents a repeat. This
is the one trigger with no external prompt: nobody files a proposal against an agent's mistake, so if
you do not record it, nothing does. An agent that silently fixes its own error teaches the hub
nothing.

## Session-end handover

If this session changed hub state, **refresh `HANDOVER.md` before you stop** — run `/km-handover` to
rewrite section 5 (current state, open items, next steps) with what actually changed, then commit it.
The next session reads that handover first and trusts it; leaving it stale hands the next agent a
confident record of a state that no longer exists. A `Stop` gate (`handover-hooks.sh`) enforces this:
it blocks once when a session landed commits but did not touch `HANDOVER.md`. If nothing meaningful
changed, say so in one line and stop — it will not fire again this session.

## Change review workflow

Hub docs are edited only after an approved proposal **or** explicit real-time confirmation
from {{HUB_OWNER}} in chat.

**The chat path is not the cheap path.** It is the one most used, so it is where corrections are most
often lost. If {{HUB_OWNER}} *corrects* you in chat — tells you something you did, assumed, or wrote
is wrong — write a `corrections/` note (`trigger: owner-correction`) and commit it **with** the
change. Approving a proposed change is not a correction; being told you were wrong is. The test:
**can you state a rule?** If yes, capture it. If no, it was a one-off decision — log it as one.

1. **Propose** — create `changes/<YYYY-MM-DD>_<initials>_<slug>_proposal.md` using `PROPOSAL_TEMPLATE.md`
2. **Approve** — {{HUB_OWNER}} or reviewer creates `changes/<YYYY-MM-DD>_<slug>_approval.md`
3. **Apply** — agent applies changes, deletes both files, logs in `sources/transcript-index.md`, runs `bash build-indexes.sh` if any entity note changed, commits by staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`)

**Agent rules:**
- **Stage explicitly. Never `git add -A`.** In synced storage a deleted proposal or approval can be restored by the sync agent, and a blanket add re-commits it as if it were live. Stage the paths you touched. If anything under `changes/` is reappearing rather than being newly created, delete it again and leave it out of the commit.
- **Claim only what you verified.** Check that each step actually completed (a chain joined by `;`, or by `&&` after a step that fails silently, proves nothing), then read the result back out of the file before staging. The commit message says what was verified after the fact; if you did not verify, say what was written, not what was merged.
- Proposal without matching approval → surface to {{HUB_OWNER}}; do not apply
- **Owner correction in chat** (no proposal) → write a `corrections/` note (`trigger: owner-correction`) capturing the rule, and commit it with the change
- Proposal + `APPROVED` → apply all; delete both; log; commit
- Proposal + `APPROVED WITH CONDITIONS` → apply only non-excluded items; delete both; log; commit
- Proposal + `REJECTED` → **capture the approval's Reason and Rule as a `corrections/` note (`trigger: rejected-proposal`) and commit it**; then delete both; log rejection; no hub changes
- Proposal + `APPROVED WITH CONDITIONS` → capture each excluded item's reason as a `corrections/` note before applying the rest
- **Never delete a reviewer's reason.** `changes/` is a workspace; the reason must outlive it.

## Generating artifacts (push)

Use `/km-brief` to draft a memo, briefing, or status report from this hub's entity notes
(`decisions/`, `risks/`, `milestones/`, `stakeholders/`, `partners/`) instead of freehand-reading the
numbered docs. Drafting into `working-docs/` needs no approval. Promoting a draft to `shareable/` (or
otherwise sending it externally) follows the normal change review workflow above; once applied and
committed, add a row to `sources/publication-log.md` (date sent, artifact, audience, commit, sent by).

## Default outputs

Lead with action items and open decisions, grouped by owner. Flag blockers explicitly with the owner's name.

## Sensitivity

Treat client and partner information as restricted. Do not surface personnel or HR matters in
summaries unless directly asked.

## Entity indexes

`index.md` in each entity folder is **generated**. Never hand-edit one — run `bash build-indexes.sh` and commit the result. A hand-edited index drifts from the notes it claims to summarise, and an index nobody trusts is worse than none: it will be read as truth long after it stops being true.

## Estate binding (multi-hub deployments only)

If this hub is part of a multi-hub estate — a workspace whose root contains `_KM_Supervisor/` — the
estate tier binds this hub. Delete this section in a single-hub deployment. **Bind only what
exists** (v1.26): a supervisor tier starts minimal and grows against named conditions, so keep
each bullet below only if its target file or directory is actually present at the tier — a
dangling binding is worse than none — and extend this section through this hub's own governance
when the tier adopts a capability.

- **`../_KM_Supervisor/hub-registry.md` and `../_KM_Supervisor/QUEUE.md`** (the minimum tier)
  bind this hub's registration and the owner's decisions: this hub appears as a registry row,
  and anything needing the estate owner's word registers on the estate queue — nothing counts
  as surfaced to the owner without a queue row.
- **`../_KM_Supervisor/EVIDENCE.md`** governs trust between conflicting sources
  (subject-confirmed > owner-statement > independent sources > systems of record > unresolved
  references). Never construct identifiers from names; never turn a hedge into an edge; retract in
  place, never delete.
- **Identity home of record: `../_KM_Supervisor/semantic-layer/`.** This hub holds engagement facts
  and *references* shared entities (people, external counterparts, clients, products, units); it never
  mints them. New entity, identity change, ontology change, cross-hub contradiction, or restricted
  content → escalate per **`../_KM_Supervisor/PROTOCOL.md`** (write a note to
  `../_KM_Supervisor/escalations/`). The estate owner decides at supervisor level; sync notices return
  through this hub's own `changes/`.
- **`../_KM_Supervisor/corrections/` binds this hub.** Read it at session start alongside this hub's
  own `corrections/`: every `lifecycle: active` note there carries a `rule:` in force here. A
  supervisor-tier correction binds every hub by reference and is never copied down; `hub-scan.sh`
  surfaces it as a `[ CORRECTIONS ]` line.
