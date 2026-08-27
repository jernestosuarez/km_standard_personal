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

**Arity decides the schema, and an unreadable Defaults cell fails loudly** (added in
v1.64). Five cells IS a canonical row
and its third cell IS the Defaults cell whatever it holds — one shared definition of a valid
Defaults value (`-`, `never`, `MM-DD`, `YYYY-MM-DD`) serves the parser and `queue-check`, so the
board and the session-start check cannot disagree about what a row means. A Defaults value
outside that set is a defect IN THAT CELL and renders as a red PARSE ERROR card with no answer
controls, plus an error out of `queue-check`; it never falls through to a legacy reading that
shifts every field left and makes the Defaults cell the card's title, because a wrong render
answers the reader's question and stops them looking. Two companions, same rule: a row id
written with markdown emphasis still parses (a dropped row is an open decision vanishing from
the board), and a machine-block row whose rendered row failed to parse surfaces as a loud
placeholder card, never a silent drop.

**The lane axis** (added in v1.64). The machine block MAY carry a 6th field, `lane` — `knowledge | machinery | standard |
hand` — appended last so every positional parser is untouched. Tier is the CLOCK (what happens
on silence); lane is the CONTEXT (what the owner needs in their head to answer). The decisions
board groups by lane with tier sections inside, `?lane=` scopes the page and always states what
it scoped out, and the Overview carries the per-lane split of the open rows exactly once. The
surface never infers a lane: absent, empty or unrecognised reads as `knowledge`, because the
assignment belongs to the registering agent, by contract and not by guess. `hand`-lane rows and
the owner's desk are the same KIND of material and are joined at the SECTION, never the card:
registered rows keep their briefs, options and answer channel on the board's hand lane; desk
bullets keep Mark done on the desk; one act never gets two sets of controls.

**A row the queue itself marks ANSWERED is answered, whatever the stores say** (added in
v1.64). A deployment's pickup
machinery MAY write a durable marker onto the row — leading the Decision cell as
`**ANSWERED "<verb>", execution owed by the Supervisor.**`, or appended to the machine-block
row as an `answered:<verb>` field. The queue file is the record; the answer stores are rotating
logs. The parser splits the marker off the decision text — the marker is the row's STATE, never
its identity, and a card must never be TITLED by it — and the state computation folds it in as
an answer source, so a row whose store record aged out or was written by another deployment
still reads answered. **Two states only:** a row is ANSWERED from the moment the answer exists —
including after a pull consumed it, and including while the row is still on the board — until a
genuine execution record marks it EXECUTED; it is never answerable again in between, because
re-rendered answer controls under the owner's own answer are the recurring display lie this
rule closes. A genuine reopen is re-registered under a new id.

**Quotes make a verb an option; bold is presentation** (ruled 2026-08-19, v1.31). The accepted
forms, tried in order, are `**"verb"**`, `"verb"`, and the legacy prose `**Verb** (context)`.
The specification is the fixed reference and the implementation moves to meet it: a queue written
exactly as this section and the shipped template describe it must parse, and the two bold forms
stay accepted so no queue written against an earlier parser breaks. The template ships one worked
tier-A row and one worked tier-B row, inside a fenced block — **a fenced row is documentation and
is never parsed as a queue row**, so an example can be copied without appearing on the owner's
surface as a decision.

**A row this contract cannot read is REPORTED, never silently emptied.** When a tier-A/B row
yields no options, the card renders through the gated path of §4 — in "Preparing for you", with
no answer controls and the reason stated — and the row is reported by `hub-scan.sh`'s `[ QUEUE ]`
block (single-hub deployments) and by `km-cockpit.py queue-check` (a supervisor tier, where
hub-scan does not run), both with three outcomes: readable / unreadable row / could not be
evaluated. Two rules follow, and both were bought with an incident. First, an **empty action bar
is a false pass**: title, tier badge, hub chips, age and the tier-A badge all render, so the card
looks complete, the owner goes to answer, and there is nothing to press and nothing anywhere
saying why. Second, the tier-B synthetic `apply`/`veto` pair fires **only when the row declares
no options at all**; a row that declared options the surface could not read is gated instead,
because answering it against a synthesised pair records an answer the row never offered and
credits the recommendation-follow-rate with a hit against an option the owner was never shown.

**Owner-side state: append-only JSONL** in the configured state directory: answers,
answers-processed, executions, questions, questions-processed, question-replies, a dismissal
store (v1.64), plus a notification-dedup file. Card state is computed per request: open → **answered** (controls
hidden, the recorded verb shown) → **executed** (execution note with its commits/links shown).
`recommended` is captured with every answer for the follow-rate metric, and must always reflect
what the served card actually showed.

**An execution record's `status` separates work done from work merely captured** (added v1.34).
An execution record carries an optional `status`. **Absent** is a genuine execution — the work
was done — and every record written before this field existed stays a real execution, unchanged,
because the absence of a status can only mean executed, never unknown. **`status: "recorded"`** is
a bookkeeping capture: an unattended answer pickup wrote the owner's answer down, but the work is
still owed. Only genuine executions count as done; a `recorded` capture renders in the same
owner-visible state as a queued answer — answered, awaiting Supervisor execution — and a later
`recorded` for an id that once executed reopens it, discipline over the mere presence of a record.
Any record admitting it is not executed while carrying no status is a ledger lie: a record that
is not a genuine execution states so, or the count it feeds is wrong. This rule is owed to the
reference deployment: its cockpit counted a bookkeeping note as work done and showed
answered-but-undone rows as executed, then it invented the status split and was proven on it, and
this section is brought up to that implementation. The reference deployment leads and the
specification follows it here; every other implementation moves to meet this section.

**The owner's desk: a hand lane derived from the queue, never written** (added v1.36). The queue
carries the deployment owner's **personal follow-ups** — what the owner is waiting on and what the
owner owes someone — as bullets under a `## Owner's desk` heading. This is a **hand lane**: distinct
from decision tiers A/B/C, nothing on it defaults, nothing expires, and nothing on it ever occupies a
decision row. The cockpit renders the desk in **its own section, after Hubs**, and derives it from the
queue on every request. Four obligations bind any implementation:

- **Derive, never edit.** The desk on screen is parsed live from the queue file; the cockpit never
  writes the queue, exactly as §1 requires of every surface. One bullet is one item, at the queue's
  own granularity, never a split invented from prose punctuation.
- **The id is derived: `desk-<slug>`.** A bullet has no id of its own, so the id is `desk-` plus a
  slug of the bullet's leading **bold phrase** (falling back to its first words when there is no bold
  lead). A derived id survives edits to the rest of the bullet, so a ticked item does not re-surface
  when its date or owed detail changes. The stated limit: **renaming the bold lead mints a new id**,
  which returns a previously ticked item to the desk — a deliberate re-nudge over a silent drop.
- **The control is a tick, not a dismiss.** Hiding a live commitment without resolving it is the
  failure to avoid. Marking an item done appends an owner-store record
  (`{"id": "desk-<slug>", "answer": "done", "done": true, "item": "<text>"}`) to the append-only
  answers store; the tick rides the **ordinary answers channel**, so a normal `pull` consumes it like
  any answer and the supervisor prunes the nudge from the queue in its own session. Undo is a further
  appended record; the append-only store's last record wins. A ticked item moves off the active list
  into a done disclosure that opens onto the items themselves, each with Undo.
- **Owner-supplied desk text may not size a layout** (§8). Desk item text arrives from the queue and
  renders in a bounded track; its grids are registered in `OWNER_TEXT_GRIDS`.
- **A desk tick never counts as a decision** (added v1.37). Because the tick rides the answers
  channel, the decision accounting must exclude `desk-<slug>` ids from every set it feeds (pending,
  queued, executed, recorded), or a cleared personal follow-up reads as a decision awaiting Supervisor
  execution. The desk section derived above is the only place desk ids ever surface; they are the
  owner's hand lane and count as neither a decision nor an execution anywhere else.

This rule is owed to the reference deployment: its cockpit parsed the decision tiers only, so desk
nudges added to the queue were invisible on the owner's surface, then it added the desk section and
this contract is brought up to that implementation. That deployment then found that a cleared
follow-up still read as a decision awaiting execution (the tick rode the answers channel straight
into the decision accounting), and excluded desk ids from every decision and execution set; this
section is brought up to that fix too. The reference deployment leads and the specification follows
it here; every other implementation moves to meet this section.

**The KM Standard status card: read-only visibility on the tracked standard checkout** (added
v1.38). The Home surface may carry a status card for the KM Standard itself, showing the version the
deployment is pinned to and the checkout's push state. Its data source is not the queue but a
separate local read of the standard checkout the deployment tracks, configured by
`standard_repo_path` in the manifest; when that key is absent the card does not render, so a
deployment that keeps no local checkout shows nothing rather than a guess. Four obligations bind any
implementation:

- **Display only, never a pen.** The card renders state and grows no controls, exactly as §1
  requires of every surface. A standard change that needs the owner's word is a governed tier-A/B
  decision, never a button on this card.
- **The published version is resolved from the publish branch's committed history** (amended in
  v1.64). The card reports the version of the newest commit on
  the configured publish branch (`standard_publish_branch`, default `main`) whose committed
  `STANDARD.md` H1 carries no draft qualifier, walking past drafted H1s — because a working-tree
  H1 mid-draft reads "(vX.Y draft)", and reporting a drafted number as the pinned version is a
  wrong answer with full confidence. The card names the branch and the resolving commit; when no
  publishable commit can be resolved it says so rather than showing an empty or invented
  version. (The v1.38 rule this amends: the version identifier in the working tree's H1 title.)
  Draft RFCs (status banner reads DRAFT) render inline as title, status and path — never as
  file links, per the confinement bullet below.
- **Push state is local git only, never a network call.** The card compares the local branch to its
  configured upstream and reports one of: in sync, N commits not yet pushed (with the unpushed
  subjects available), or origin carries commits not yet pulled. It reads local git alone, states
  that the origin comparison is as of the last fetch, and never contacts the network, so the render
  never depends on connectivity. A missing checkout or a failing git reports itself instead of
  fabricating state.
- **The card never links the checkout.** The standard checkout lives outside the estate root, and
  every file-serving route confines resolved paths to that root (§4); this card widens no boundary
  and emits no file link into the checkout.

This card is owed to the reference deployment, whose owner asked to see the standard's own version
and push state on the cockpit; this section is brought up to that implementation. The reference
deployment leads and the specification follows it here, so a conformance pass never drags the lab
back to the last release; every other implementation moves to meet this section.

**Rotation semantics: a record is consumed exactly once, and the trace is written before the
consumption is final** (step-order clause added in v1.64). `pull` and `questions` print pending records and move them to the
processed file in one call. **Pull consumes for the whole estate:** whoever pulls owns immediate
surfacing and execution of every record returned — never only the records relevant to their own
task — and must later record `exec` per id. Tests never invoke `pull` against the live store;
they verify by reading fixture files and remove only their own throwaway records.

Because consumption is irreversible, `pull`'s step order is the guarantee: read the pending
answers; append them to the processed store; append one `consumed, processing` line per record
to the **pickup log** (`answer-pickup-log.md` beside the queue file); and TRUNCATE the pending
store LAST. A failure at any earlier step leaves the answers pending, so the next pull retries
them — there is no ordering that loses a record. The log line is the consume path's own
obligation, never the caller's, because a caller can forget it or die before meeting it; the
consumer then resolves each line to its outcome. The activity page renders the log as the
"picked up without you asking" panel: the owner's own input, consumed while nobody was
watching, must be visible, because the pull rotated it out of the store and the log is its
only trace. (Writing the log is a session-side CLI act under the pulling session's own
authority; the serving surface itself still writes nothing.)

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

**The neutral preparing badge** (added v1.33). A gated or incomplete record renders a neutral
"Preparing" badge in its glance and **never its actionable tier badge**, so a single glance can
never carry an actionable signal — the red "needs you" summons for the owner's word — and "being
prepared, nothing for you to do yet" at the same instant. The tier is named only in the badge's
title tooltip, never as a badge the owner reads as a call to act. This rule is owed to the
reference deployment: its cockpit rendered the contradiction on one card, then rendered the fix,
and this section is brought up to that implementation. The reference deployment leads and the
specification follows it here; every other implementation moves to meet this section.

**The options gate** (added v1.31) uses the same path for the same reason: a tier-A/B row whose
declared options cannot be read is not answerable, so it renders in "Preparing for you" with the
reason stated, rather than as a complete-looking card with an empty action bar. The two gates are
one rule seen twice — a card the owner cannot act on says so, in the group for records that are
not ready, and never by falling quietly silent in the place the control belongs. Since v1.64
the two gates state their OWN conditions: an options-gated row wears a neutral "Gated" badge with the repair named ("Options
unreadable — repair the row's options cell"), where a brief-gated one wears "Preparing" —
because what the owner can do about the two differs, and two states that mean different things
must not render identically. Neither ever wears the actionable tier badge (the v1.33 rule,
unchanged).

**Answered and executed rows swap their tier badge for their state badge** (added in
v1.64). The tier badge is the CLOCK —
what happens if the owner says nothing — and on an answered or executed row that clock has
stopped, because the owner already spoke. A tier-A row the owner has answered must not keep its
red "Needs you" beside its own tick: it wears "Answered" (and an executed row still on the
board wears "Executed" — execution recorded, reconciliation pending), with the registered tier
kept in the tooltip as context. The badge metadata the client poll swaps in is serialised from
the server's own constants, never restated in the script, because two copies of a label drift
and a client disagreeing with the server about what a state is called is the same defect one
layer down; the poll announces the change on a page left open, because a surface that changes
while nobody is looking must announce the change.

**Dismissal of informational items** (added in v1.64). Tier-C FYI cards and the "Preparing for you"/"Gated" notices carry a
Dismiss control; persistence is the default (nothing expires, times out, or hides itself on a
seen-heuristic), and dismissal is owner-side VIEW STATE only — an append to the dismissed
store, exactly like an answer; the queue file is never touched and the item stays in the
record. A tier-A/B decision card is never dismissible (it leaves the board by being answered)
and a supervisor action is never dismissible (it is work owed; it leaves when done). Undo sits
on the card the instant it is dismissed, and each informational section carries an
"N dismissed" disclosure that restores any of them — never a count that dead-ends. Ids are
validated live against the queue on every request, never against a hardcoded list.

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

**A proposal file still present has not been applied, whatever the execution note says** (added
in v1.64). A hub's agent
DELETES the proposal file when it applies it, so a proposal still sitting in `changes/` whose
governing row carries an execution record is downgraded from state 4 to `Directive issued —
waiting on this hub's own agent to apply it (<id>)`. The exec note is a CLAIM by the recording
session; the file's presence is the FACT, and the fact wins — in the reference deployment three
proposals once read "executed" on the strength of notes recording "directives committed" while
the hub agents had never been dispatched and the files sat untouched.

Hub attention badges and estate-level signals derive from these same states: a hub whose only
pending item is answered-awaiting-execution says so, never a generic contradiction. **Open owner
decisions and pending supervisor work are never conflated in any count.** The test for every
attention signal: clicking it shows, within one step, what is pending and from whom — the owner,
the supervisor, or a hub agent. A count with no list is a display defect of the same class as an
unregistered ask.

## 5.5 One home per item, and the activity split (added in v1.64)

**An item is rendered in exactly ONE place — where it is ACTED on. Every other surface refers to
it by a count with a link, never by repeating it.** The rule was ruled in the reference
deployment after one evening's features left the same items repeated across pages ("it starts
being a bit cluttered with info repeated in different pages"), and it binds every future
addition. The two main pages have distinct jobs: the Overview answers *what needs me, and is
anything wrong* (counts, exceptions, status — no answerable item that exists elsewhere);
`/decisions` answers *let me work through them*. Concretely: tier-C items live on the decisions
board, inside their lanes, where Dismiss belongs beside the item — the Overview's watchlist is
a pointer; the desk lives on its own page — the Overview's desk tile is a pointer; agent
activity lives on the Activity page — the Overview carries a count and a link; the governed
totals (tier A, tier B) stay in the stat grid because the halt and the defaults act on them,
each number stated once, and every tile that stands for items is a link to the page that
renders them. Two standing constraints: a count may never point at a page that does not show
the thing, and a de-duplication pass changes rendering only, never a written record.

**The activity page splits by ACTOR**: what the owner decided ("Your decisions"), what agents
did on their own dispatches ("Agents"), and what ran unattended ("Picked up without you
asking") — one feed mixing all three hides the entries that matter, a refusal or an answer
consumed while nobody watched. The Agents section reads curated frontmatter from an
`agent-reports/` directory beside the queue file (`agent`, `row`, `outcome` ∈ applied | refused
| stopped | reported, `commits`, `hubs`, `timestamp`): git records what an agent CHANGED, and a
refusal changes nothing, so its report file is the only record it has. Refusals and stops
render in their own group ABOVE routine applies, never interleaved, and claim the display cap
first. An outcome outside the four governed values, or a file the parser cannot read, is listed
unreadable BY NAME — a typo becomes visible instead of silently miscounting. The directory is a
convention a deployment's dispatch machinery fills; the surface ships the reading contract
only, and a deployment with no such machinery sees the section say so. A bookkeeping-recorded
execution entry renders truthfully as "Answered — awaiting execution", never as executed.

**The single-hub initiated read is date-shape checked.** In single-hub mode the surface reads
`initiation-interview:` from the hub's deployment binding as the hub scan's own gate reads it —
requiring the ISO date shape — so an unsubstituted placeholder cannot render a hub as initiated
while the scan quarantines the same hub. Two instruments reading one fact must not disagree
about it.

## 6. The supervisor-actions request channel

Work owed by the supervisor renders as **"Waiting on KM Supervisor"** with the label "Work owed
by the KM Supervisor. No owner action is required unless you choose to redirect it." — never as
an implied owner task list. Per action: **Ask for update / Run next / Hold / View evidence**.
All three controls record **requests** through the existing questions pipeline under the stable
ref `supervisor-action:<action-id>` with a message type (`question` | `run-next` | `hold`),
validated live against the queue's SUPERVISOR-ACTIONS block (never a hardcoded id list), and
confirmed with "Request recorded — awaiting KM Supervisor acknowledgement." No control edits the
queue. The pulling session acknowledges each request in the same session it pulls (a pull is not
an acknowledgement); a Hold binds the supervisor's scheduling until the owner releases it or the
supervisor replies with a reasoned alternative the owner can see. Row states: Open / Request
sent / Supervisor replied / Overdue. An item whose next step is an owner choice never lives only
in this register — it is registered as a governed tier-A/B decision.

**Run next replaced Prioritize** (amended in v1.64), on the reference deployment owner's own challenge: a relative
nudge was never a usable instruction, and the distinction it rested on — an owner ANSWER versus
a request on Supervisor work — was semantic, not structural, since both are one recorded word
the cockpit never executes. The retired `prioritize` type is REFUSED with an explanatory 400
rather than silently re-filed, so a click on a stale page is never recorded under a word the
owner no longer has. What genuinely differs about these rows is the DEPENDENCY, so each card
shows its due state (overdue / due today / ahead / no due date — rendered as a defect, because
"when a session picks it up" is not a plan, compared exactly as the session-start scan compares
it) and, where the action's own prose names something it waits on, that clause QUOTED verbatim —
never parsed into a structured field the estate never wrote, and never front-trimmed, because
trimming can lop a negation and turn a quote into a claim. **Run next over a stated dependency
is recorded, never refused**: the clause travels into the pulled record and the confirmation, so
both sides see what is being overridden and the Supervisor either runs it or comes back with
why not.

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
- **No owner-supplied value may size a layout** (ruled 2026-08-19, v1.31). An option label, an
  answer, a note, a desk item: everything arriving from the queue or the answer store is
  unbounded text the surface does not control, and it renders inside a box whose size the layout
  decides — a bounded grid track, a wrapping label, a truncation applied at the point of render.
  The instance was a grid track with an `auto` maximum sized by option labels the length of
  sentences, which took the row and collapsed the title beside it to one word per line: a card
  technically correct and unreadable. Two obligations follow: any grid track that carries
  owner-supplied text has a **bounded maximum** (never `auto` or `max-content`), and any new
  surface rendering owner text is **registered in `OWNER_TEXT_GRIDS` in the same change**, since
  the check can only verify the tracks it has been told about. Its coverage line states how many
  it checked; it cannot discover an unregistered one, and that gap is closed by this rule, not by
  the instrument.
- **A control the owner cannot press is a defect, not an empty state.** Wherever this surface
  cannot render an answer control, it says so on the card and reports the row (§3); it never
  emits an empty action bar, and it never substitutes an option the row did not declare.
- After any code change: restart the server, then verify by fetching the changed behavior. Run
  `python3 km-cockpit.py selftest` — it carries the negative direction for both rules above (an
  unbounded owner-text track and an unreadable row must each be caught, and neither check may
  fire on legitimate input).

## 9. Roadmap note — derived-first queues (recorded, not built)

A later revision may **derive** queue content that the estate's files already know — open
contradictions, pending proposals, commitments past target, hub freshness — leaving only
conversational questions in the hand-maintained queue file, since hand-maintained state drifts.
Evidence so far: one estate, one day — medium confidence. The shipped contract is
queue-file-first, exactly as proven in deployment; derived-first is a roadmap direction, not
part of this contract.
