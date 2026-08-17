---
type: architecture
title: KM Cockpit — normative contract
description: The binding contract for the owner decision surface — data model, card contract, proposal lifecycle states, request channel, and invariants. Binds any implementation, not only the reference file.
tags: [cockpit, component, contract, owner-queue, interaction]
resource: km-cockpit.py
timestamp: 2026-08-17
---

# KM Cockpit — normative contract

This contract governs the owner decision surface. `km-cockpit.py` is the reference
implementation; a reimplementation on any stack must satisfy every numbered section. Each rule
here was ruled operationally in a live deployment — none is speculative. The surrounding
standard text is STANDARD.md → Supervisor Tier → "The owner queue" and "The owner interaction
contract".

## 1. A surface, not a pen

The cockpit renders the owner queue and captures answers. It **never executes anything and never
writes estate state**: no edit to `QUEUE.md`, no hub write, no identity mint, ever. Every answer
becomes committed estate artifacts only through a supervisor (or single-hub agent) session,
under the same governance as a chat answer — proposal/approval/directive instruments, hub agents
applying, identity minted only on the owner's word. Chat, the batched clearing skill, and the
cockpit are **equal answer channels**; the cockpit is additive, never a dependency.

## 2. Unpublished by default

Decision surfaces are **unpublished by default**. The queue carries budget, identity, and
commercial context; nothing that governs the knowledge layer's publication covers it, so the
decision layer gets its own rule:

- the server binds localhost only, and the bind address is not a configuration knob;
- the cockpit is never deployed or published beside a reading site, docs portal, or any
  audience surface;
- shared or remote access is an **explicit owner decision** carrying clearance and an audit
  trail — never a default, never a side effect of deploying something else.

## 3. Data model

**Source of truth: the queue file, read-only.** Everything renders from `QUEUE.md` on every
request — no cache, no database, no drift. Rendered tables carry the full card content; the
machine block (`<!-- QUEUE:BEGIN … QUEUE:END -->`, one delimited row per item: id, tier, raised,
default, ask) supplies dates. Wrapped lines are joined before parsing; tier-C bullets keep their
bold labels.

**Canonical row schema** for tier A and B rendered rows: `Id | Since | Defaults | Decision |
Options`. Tier A carries `-` in Defaults; Decision opens with one bold recognition sentence,
then at most two sentences of context; Options are exact quoted verbs, recommendation first. A
tier-B row names its specific default action first and `veto` second — generic "apply" only when
no precise verb exists, and a real row option always wins over a synthetic one. The parser stays
tolerant of legacy shapes so a schema migration can ship parser-first.

**Owner-side state: append-only JSONL** in the configured state directory: answers,
answers-processed, executions, questions, questions-processed, question-replies, plus a
notification-dedup file. Card state is computed per request: open → **answered** (controls
hidden, the recorded verb shown) → **executed** (execution note with its commits/links shown).
`recommended` is captured with every answer for the follow-rate metric, and must always reflect
what the served card actually showed.

**Rotation semantics: a record is consumed exactly once.** `pull` and `questions` print pending
records and move them to the processed file in one call. **Pull consumes for the whole estate:**
whoever pulls owns immediate surfacing and execution of every record returned — never only the
records relevant to their own task — and must later record `exec` per id. Tests never invoke
`pull` against the live store; they verify by reading fixture files and remove only their own
throwaway records.

## 4. The card contract

Every tier-A/B card renders, mandatorily: links to every referenced file, zero-context
what-it-is, the options with the **recommendation first**, tier badge, age, and hub chips. A
card below this bar is repaired before it is answerable; "not sure what this is" is a context
failure of the surface, never an owner answer — the row returns to open, repaired.

**The decision-brief gate.** A tier-A/B card is answerable only against a passing decision
brief (`queue-briefs/<row-id>.md`: complete frontmatter, ten sections, the mandatory sections
non-empty, at least one sourced fact naming source, ISO date, and hub — provenance is semantic:
bullets or tables both valid). A gated or incomplete record renders in a separate compact
"Preparing for you" group — visible and auditable, **no answer controls**, the precise gate
reason in the expanded details only, the actionable tiers never deformed by it. The Ask channel
stays open on gated cards. The server enforces the same gate on POST, not only in rendering.

**Links resolve relative to the file that carries them** — queue rows from the queue file's
directory, briefs from `queue-briefs/`, any viewed document from its own directory — with
`#fragment` pass-through. Every file-serving route confines resolved paths to the estate root;
this boundary never widens. A genuinely missing target is a real 404.

## 5. Truthful lifecycle states — attention signals resolve to a visible item

Every pending hub proposal is **listed by name** with exactly one of five states, matched
through the queue row **and** its canonical decision brief (live or archived — a pulled row
leaves the queue, so the brief is the surviving link source):

1. `Awaiting owner decision <id>` — links to the decision card;
2. `Answered "<verb>" — awaiting Supervisor execution (<id>)` — always the recorded verb: a
   veto renders truthfully, never as "approved";
3. `Queued for Supervisor execution (<id>)`;
4. `Execution recorded — proposal reconciliation pending (<id>)`;
5. `Needs decision routing` — no governing decision found.

Hub attention badges and estate-level signals derive from these same states: a hub whose only
pending item is answered-awaiting-execution says so, never a generic contradiction. **Open owner
decisions and pending supervisor work are never conflated in any count.** The test for every
attention signal: clicking it shows, within one step, what is pending and from whom — the owner,
the supervisor, or a hub agent. A count with no list is a display defect of the same class as an
unregistered ask.

## 6. The supervisor-actions request channel

Work owed by the supervisor renders as **"Waiting on KM Supervisor"** with the label "Work owed
by the KM Supervisor. No owner action is required unless you choose to redirect it." — never as
an implied owner task list. Per action: **Ask for update / Prioritize / Hold / View evidence**.
All three controls record **requests** through the existing questions pipeline under the stable
ref `supervisor-action:<action-id>` with a message type (`question` | `prioritize` | `hold`),
validated live against the queue's SUPERVISOR-ACTIONS block (never a hardcoded id list), and
confirmed with "Request recorded — awaiting KM Supervisor acknowledgement." No control edits the
queue. The pulling session acknowledges each request in the same session it pulls (a pull is not
an acknowledgement); a Hold binds the supervisor's scheduling until the owner releases it or the
supervisor replies with a reasoned alternative the owner can see. Row states: Open / Request
sent / Supervisor replied / Overdue. An item whose next step is an owner choice never lives only
in this register — it is registered as a governed tier-A/B decision.

## 7. Session integration

The estate's session-start scan restarts the server if it is down, then `pull`s answers (each
processed exactly like a chat answer, then executed and `exec`-recorded) and `questions` (each
`reply`'d into its card). Sequencing: pull → **update the queue immediately** (answered rows
leave the open tables) → then execute; a stale open card the owner can re-answer is the failure
this ordering prevents. Answers execute through proper channel authority — an approval or
directive committed in the target hub citing the cockpit answer with its timestamp; a hub agent
refusing a shortcut is the system working.

## 8. Invariants (the review checklist for every change)

- Stdlib only; one file; binds 127.0.0.1 only; never in any publication deploy.
- The queue file is read-only to the cockpit; owner state is append-only JSONL; no database.
- Estate-root confinement on every file-serving endpoint.
- Never executes, never writes estate files, never mints identity; identity / restricted /
  deletions / client-facing classes can never be auto-decided.
- Every card meets the card contract (§4); `exec` notes carry the commits — the activity feed
  is the owner's audit trail.
- All deployment specifics live in the manifest (§Deployment, README.md); the hub attribution
  map derives from the governed hub registry; no organization string is ever hardcoded.
- After any code change: restart the server, then verify by fetching the changed behavior.

## 9. Roadmap note — derived-first queues (recorded, not built)

A later revision may **derive** queue content that the estate's files already know — open
contradictions, pending proposals, commitments past target, hub freshness — leaving only
conversational questions in the hand-maintained queue file, since hand-maintained state drifts.
Evidence so far: one estate, one day — medium confidence. The shipped contract is
queue-file-first, exactly as proven in deployment; derived-first is a roadmap direction, not
part of this contract.
