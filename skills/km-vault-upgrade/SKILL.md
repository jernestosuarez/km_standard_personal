---
name: km-vault-upgrade
description: Use when onboarding an Obsidian-structured vault into a KM estate as a governed campaign. /km-vault-upgrade <vault-path> catalogues, interviews, batches extraction through existing flows, and keeps re-runs idempotent.
---

# Skill: km-vault-upgrade — Governed Vault Onboarding Campaign

You have been invoked as `/km-vault-upgrade <vault-path>`. A **source vault** (an
Obsidian-structured directory of notes, exports, and records) is to be onboarded into the KM
estate as a **campaign**: a resumable sequence of dozens-sized, competency-question-ordered
batches, each ending in owner-approved proposals — never a one-shot import.

You operate at the **Supervisor tier**. Run this from the workspace root (the folder that contains
`_KM_Supervisor/` and the hubs). The formats you read and write — the campaign ledger, the
catalogue, the campaign-state table — are defined once, in
[`ledger-format.md`](ledger-format.md); this skill never redefines them. The behavioral contract
is the capability spec
([`vault-upgrade-campaign/spec.md`](../../openspec/changes/add-km-vault-upgrade-skill/specs/vault-upgrade-campaign/spec.md)),
cited per step below.

**Governing principles (do not violate):**

- **The skill never writes entity folders directly.** Every content mutation arrives as a
  proposal in the receiving hub's `changes/`, applied by that hub's own approval flow. The only
  files this skill writes outside `changes/` are the catalogue (Supervisor `_inbox/`), the
  ledger (once adopted), QUEUE and `_unrouted/` rows, and declared-lifetime staging in
  `_scratch/`.
- **The owner decides; rulings are carried forward, never re-derived.** Exclusions, routes,
  quarantines, source-of-record selections, and interview answers are owner decisions. A later
  run repeats none of them and reverses none of them silently.
- **No bypass.** You orchestrate `/km-gather`, `/km-intake`, and `/km-supervise` — you never
  duplicate their steps, copy records into hubs, or modify the source vault. The vault stays
  put and read-only; hubs hold claims and `file://` pointers.

**Precedence.** Where this skill and a live estate plan for the same vault conflict,
**the plan's owner rulings win** until the owner supersedes them. This skill generalizes such
plans; it does not overrule them.

**Arrival is not a decision.** Never pause per file. The campaign holds on the owner in exactly
three places: the **date gate** (mtime-only sources), the **boundary interview** per domain, and
**per-domain proposal approval**. Everything else runs to completion unasked.

---

## Step 0 — Load estate state and active corrections (every session)

Read, in full, before anything else:

- `_KM_Supervisor/hub-registry.md` — the routing map. If `_KM_Supervisor/` does not exist, stop
  and tell the owner to stand up the Supervisor first (offer `/km-init` and the supervisor
  threshold); a campaign has no home without it.
- The campaign catalogue and ledger, if they exist — this is how a cold-start session resumes:
  the catalogue's `## Campaign state` table plus the ledger say exactly which batches are
  planned, proposed, approved, applied, or rejected. Never rebuild campaign state from memory or
  chat history.
- **Every receiving hub's active `corrections/` rules** (`lifecycle: active`). Rejections teach
  the campaign (Step 6); a session that extracts before reading the rules repeats the mistake
  the owner already corrected. State which rules are in force in your first report.
- Any live estate plan for this vault (Precedence, above): its owner rulings bind this run.

## Step 1 — Registration (Episode I; idempotent)

*Spec: "The source vault SHALL be registered as a SourceSystem before any extraction."*

Check `_KM_Supervisor/sources/systems/` for an existing SourceSystem note for this vault.

- **Registered** → skip; reuse the existing note unchanged. Say so.
- **Unregistered** → execute the registration shape, each write an **owner-authorized commit with
  the reason stated**:
  1. SourceSystem note at the Supervisor (`systemKind: vault-export`, `uriScheme: file://…`,
     `connector: manual`, `refreshPolicy: on-demand`, and the owner's `defaultAccessClass`).
     A live vault is knowingly registered as `vault-export`; note it in the file.
  2. A subscription entry in each receiving hub's `sources.config.md` naming the SourceSystem
     and the owner's path filter for that hub.
  3. A `sources/dates-register.md` present in **every** receiving hub — create from the template
     where missing, and never reset one that is live.

Registration precedes cataloguing; every extract inherits this note's provenance and access
class.

## Step 2 — Catalogue, mechanically (Episode I)

*Spec: "The catalogue SHALL be generated mechanically, and owner rulings SHALL be carried forward
verbatim."*

Generate the catalogue per the contract in [`ledger-format.md`](ledger-format.md) — one file per
campaign at the Supervisor `_inbox/`, **read-only with respect to the vault**:

- **Every file gets a row**: domain, path, date, date-source (`named` when a valid ISO date
  parses from the filename; `mtime` otherwise), knowledge-vs-record class, candidate hub route
  by registry keywords, exclusion flag. This is mechanical work; the owner's time is for
  rulings, not enumeration.
- **Carry prior rulings forward verbatim.** If a prior catalogue exists, its `## Owner rulings
  applied` section crosses into the new catalogue unchanged, then extends with any new rulings,
  each dated. A subtree the owner ruled excluded is **never proposed from** by any later step —
  re-inclusion requires a fresh owner ruling.
- **Date gate posture, recorded per row, held at intake**: `named` dates are accepted
  mechanically; `mtime` rows are confirmed with the owner at intake as `ESTIMATED` and
  registered in the receiving hub's `sources/dates-register.md`. Never silently backfill a date.
- **Quarantine bulk-export subtrees** (a platform export dominated by row stubs, a duplicated
  tree, anything whose file count dwarfs its knowledge density) as **their own campaigns** with
  per-subtree triage — never batch-intaked blindly. Mark them in the catalogue and surface each
  as a `QUEUE.md` row.

Present the domain summary to the owner for rulings. Cataloguing writes no proposal and asks no
per-file question.

## Step 3 — Boundary interview, one per domain (Episode II)

*Spec: "A domain SHALL NOT be extracted before its boundary interview."*

No batch draws from a domain without a recorded interview. **A batch that would is blocked, and
the missing interview surfaces as a `QUEUE.md` row** — the block is a fact in the queue, not a
silent stall.

Run each interview as one focused round — scope, sensitivity, depth — in the owner's words:

1. **Scope** — what in this domain is knowledge to extract, what is records (pointer-only), what
   is out entirely?
2. **Access class** — does this domain restrict below the SourceSystem `defaultAccessClass`?
   Client-identifying or commercial-terms material defaults to `restricted`; the owner's word
   here stamps every extract from the domain (Step 5).
3. **Extraction depth** — e.g. decisions and commitments only, or also stakeholder edges?
4. **Open rulings the domain carries** — duplicate copies, cadence, deferrals: any question a
   prior plan left unresolved for this domain is answered here, by the owner, and recorded.

**Look before asking**: pre-fill every answer you can defend from the catalogue, the registry,
and any prior plan, present each pre-fill with its source, and spend the owner's attention on
what the record cannot answer. A pre-fill is a proposal, not an answer — only the owner's
confirmation is recorded, into the catalogue's rulings section.

## Step 4 — Batch planning, CQ-ordered (Episode II)

*Spec: "Batches SHALL be CQ-ordered and produce one proposal per domain."*

Plan batches into the catalogue's `## Campaign state` table (contract in
[`ledger-format.md`](ledger-format.md)):

- **Each batch declares which hub competency questions it serves.** Order batches so every batch
  moves a named N toward Y; a batch serving no CQ is deferred, not run.
- **Batch size stays at dozens of files.** If a single batch proposal exceeds review capacity
  (~50 proposed changes), the next batch halves — review capacity, not file count, governs.
- **One proposal per domain per batch**, in the receiving hub's `changes/` — never one per file.
- Batches from interviewed domains only (Step 3); ledger-skipped sources excluded (Step 8).

## Step 5 — Extraction under governance (Episode III)

*Spec: "Extraction SHALL route per-fact tuples through the standard intake pipeline"; "Minted
entities SHALL close their edges within the proposing batch"; "Every extract SHALL carry an
access class."*

Extract each batch through the existing flows — single-hub domains via `/km-gather`, mixed or
cross-cutting sources via `/km-supervise` (**always `--dry-run` first**, then the full run on the
owner's confirmation). Working intermediates live in `_scratch/`, never in governed trees. The
discipline, whichever flow runs:

- **Per-fact tuples.** Every extracted fact is `(claim, source, locator, evidence)`. **A fact
  without locator and evidence is not routed** — collect it and report it as unsourced in the
  batch report. A mixed file may route facts to different hubs; the file is not the unit, the
  fact is.
- **Records are never extracted.** A `record`-class source yields a `file://` pointer only, and
  only when a claim references it.
- **Edge closure, computed per batch.** Before dispatch, walk every minted entity's wikilink
  fields; every target **exists or is minted in the same proposal**, so `[ LINKS ]` passes on
  apply. A decision whose stakeholder is missing mints the stakeholder beside it.
- **Access class stamped at extraction, not retrofit.** Each extract carries the domain
  interview's access class, else the SourceSystem `defaultAccessClass`. Restricted material
  never reaches indexes or `shareable/`.
- **Out-of-scope facts are never dropped.** A fact matching no receiving hub's scope is written
  as a tuple to `_KM_Supervisor/_unrouted/<theme>.md` and counted in the batch report.
- **Contradictions are wins.** A fact contradicting a hub's SETTLED reconciliation row goes into
  a `⚠ RECONCILIATION CONFLICT` block / dispute file, and the batch proceeds without it until
  the owner adjudicates.

Dispatch means proposals in `changes/` — nothing is applied here. Each hub's own approval flow
takes over (Step 7).

## Step 6 — Rejection teaches the campaign (Episode III)

*Spec: "A rejected proposal SHALL produce a corrections rule before deletion."*

When the owner rejects a proposal (in whole or in part):

1. **Capture the durable rule first.** Write a `corrections/` note in the receiving hub with a
   binding `rule:` stating what the campaign must do differently — before the proposal file is
   deleted. The verdict without the reasoning is a loss.
2. Mark the batch `rejected` in the campaign-state table and write its ledger rows with
   disposition `rejected` (Step 7).
3. Every subsequent session obeys the rule from Step 0. The owner never corrects the same
   behavior twice; if they had to, say so in the report — it means a rule was missed or is
   ambiguous, and the rule itself needs the owner's attention.

## Step 7 — Apply under the apply contract, then ledger the batch (Episode IV)

*Spec: "Campaign state SHALL be resumable and re-runs SHALL be idempotent."*

Approval happens in each hub's own flow; this skill never approves or applies a proposal on the
owner's behalf. When a hub applies an approved batch proposal, **the apply contract** holds
(Rule 3):

- the commit stages **exact paths** — never a blanket add in a populated tree;
- the commit carries the **`KM-Agent:` trailer**;
- `build-indexes.sh` runs after apply, and `hub-scan.sh` comes back **green** before the batch
  is called applied. A batch whose scan is not green is not applied, whatever the commit says.

Then record the batch:

1. **Adopt the ledger, once, as a governed act.** The campaign ledger
   (`_KM_Supervisor/campaign-ledger.json`, format in [`ledger-format.md`](ledger-format.md)) is
   new estate state. On first need — not before — ask the owner to authorize its adoption and
   create it in a commit stating the reason, under the Supervisor tier's generic change rule.
   Never create estate state silently.
2. **Write one ledger row per adjudicated source**: path, content hash, disposition
   (`extracted` / `pointer-only` / `rejected` / `out-of-scope` / `deferred`), proposal ref,
   batch id, decision date — exactly as the contract defines. One row per source, ever;
   re-adjudication updates the row.
3. **Update the campaign-state table** in the catalogue header (`planned` → `proposed` →
   `approved` → `applied`, or `rejected`), with the decision date.
4. **Crystallize per batch.** Before the next batch begins, entity notes implied by the newly
   applied extracts (stakeholders, decisions, risks, commitments) are proposed through the
   ordinary flow — CQ answerability accretes per batch instead of piling up at the close.

The catalogue header and the ledger are the whole resumable state: a cold-start session (Step 0)
reads them and continues, mid-campaign, without reconstruction.

## Step 8 — Re-run semantics: skip, FLAG, new (Episode IV)

Re-running `/km-vault-upgrade` against the same vault — including a live vault that changed —
must never double-propose. On every catalogue run after ledger adoption, hash each source
(`sha256` over raw bytes, per the contract) and compare against its ledger row:

- **Hash matches** → the source is **skipped**: adjudicated is adjudicated. Skipped sources are
  counted in the run report, per disposition.
- **Hash differs** → stamp `flagged_on` on the row and report the source as **FLAG** for the
  owner. The prior adjudication stands until the owner rules: re-adjudicate (the row is updated
  and re-enters batch planning) or keep the prior disposition (the flag clears). Nothing is
  re-proposed silently.
- **No row** → the source is new; it enters batch planning normally.

## Step 9 — Duplicate subtrees: reconcile, never silently dedupe (Episode IV)

*Spec: "Duplicate subtrees SHALL be reconciled, never silently deduped."*

When the catalogue finds the same subtree in two places with differing content (two export runs,
a copied folder):

1. **The owner selects one copy as source of record** — an owner ruling, recorded in the
   catalogue's rulings section. Never pick by newest, largest, or hash count.
2. **Differences reconcile file by file** through the dispute mechanism: each differing file is
   a per-diff decision, and a divergent non-record copy can carry the truth. Identical files
   need no decision — byte-identical is not a dispute.
3. The non-record copy is catalogued as excluded (ruling-dated) once reconciliation completes;
   its ledger rows point at the source-of-record's proposals.

## Step 10 — Close with evidence (Episode V)

*Spec: "The campaign SHALL close with evidence."*

"Ingested" is a checked fact, not a feeling. When every planned batch in the campaign-state
table is `applied` (or `rejected` with its rule captured):

1. **Re-check each receiving hub's competency questions** in `01_project-brief.md`. A CQ flips
   N → Y **only with a pointable fact** — an entity note or claim, not a pile of applied
   documents. A CQ that cannot flip stays N, and saying so is part of the close.
2. **`/km-handover` runs per receiving hub.**
3. **Ingestion rows clear from `QUEUE.md`** — including interview and quarantine rows this
   campaign opened.
4. **Retire the superseded plan.** Any hand-written estate plan this campaign generalized is
   marked `lifecycle: retired`, pointing at the closing commit. Retired, never deleted.
5. Mark the catalogue `lifecycle` from `draft` to its closing state, and report the campaign's
   final counts: sources adjudicated per disposition, batches per status, CQs flipped with their
   evidence, corrections minted, flags outstanding.

A quarantined bulk-export subtree that never got its own campaign is not silently forgotten at
close: its QUEUE row survives, naming it as the follow-up campaign it is.
