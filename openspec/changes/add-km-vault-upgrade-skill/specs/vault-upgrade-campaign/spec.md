# Capability: vault-upgrade-campaign

Governed onboarding of an Obsidian-structured source vault into a KM estate: catalogue, boundary
interviews, CQ-ordered batched extraction through the existing intake flows, an idempotency ledger,
and an evidenced close. Requirements derive from the origin gap plan's Episodes I–V.

## ADDED Requirements

### Requirement: The skill SHALL never write entity folders directly

Every content mutation SHALL arrive as a proposal in the receiving hub's `changes/`, applied by
that hub's own approval flow. The skill orchestrates `/km-gather`, `/km-intake`, and
`/km-supervise`; it SHALL NOT bypass proposals, copy records into hubs, or modify the source vault.

#### Scenario: A batch produces hub content

- **WHEN** a batch's extraction completes for a domain
- **THEN** the result is one proposal per domain in the receiving hub's `changes/`, and no file
  outside `changes/`, the Supervisor's own ledger/catalogue, or `_scratch/` is written

### Requirement: The source vault SHALL be registered as a SourceSystem before any extraction

Registration SHALL be idempotent: an unregistered vault gets the SourceSystem note
(`systemKind: vault-export`, `uriScheme: file://…`, `connector: manual`,
`refreshPolicy: on-demand`), subscription lines in each receiving hub's `sources.config.md`, and a
dates-register present in every receiving hub — each an owner-authorized commit with the reason
stated. A registered vault's existing note is reused.

#### Scenario: The vault is not yet registered

- **WHEN** `/km-vault-upgrade <vault-path>` runs against an unregistered vault
- **THEN** the skill executes the registration shape above before any cataloguing, and each write
  is an owner-authorized commit

#### Scenario: The vault is already registered

- **WHEN** the skill finds an existing SourceSystem note for the vault
- **THEN** registration is skipped and the existing note is reused unchanged

### Requirement: The catalogue SHALL be generated mechanically, and owner rulings SHALL be carried forward verbatim

Every file SHALL get a row — domain, file, date, date-source (named vs mtime), knowledge-vs-record
class, route (candidate hub by registry keywords, or `excluded` with the ruling's date) — written
to the Supervisor `_inbox/`,
read-only with respect to the vault. Prior owner rulings (exclusions, routes, quarantines) SHALL
be carried forward verbatim, never re-derived. A subtree the owner ruled excluded SHALL never be
proposed from by any later phase.

#### Scenario: Cataloguing a registered vault

- **WHEN** cataloguing runs
- **THEN** every file has a mechanical row and the owner's remaining work is rulings, not
  enumeration

#### Scenario: A prior catalogue exists

- **WHEN** cataloguing runs against a vault with an existing catalogue
- **THEN** the prior catalogue's owner rulings appear verbatim in the new catalogue's rulings
  section

#### Scenario: An excluded subtree

- **WHEN** any later phase plans a batch
- **THEN** no file under an owner-excluded subtree is included

### Requirement: A domain SHALL NOT be extracted before its boundary interview

One boundary interview per domain, in the owner's words, SHALL precede that domain's first batch.
A bulk-export subtree SHALL be quarantined as its own campaign with per-subtree triage, never
batch-intaked blindly.

#### Scenario: A batch would draw from an uninterviewed domain

- **WHEN** batch planning selects files from a domain with no recorded interview
- **THEN** the batch is blocked and the interview surfaces as a `QUEUE.md` row

#### Scenario: A bulk-export subtree is encountered

- **WHEN** the catalogue identifies a bulk-export subtree
- **THEN** it is quarantined as its own campaign and excluded from ordinary batch planning

### Requirement: Batches SHALL be CQ-ordered and produce one proposal per domain

Each batch SHALL declare which hub competency questions it serves, stay at dozens of files, and
produce one proposal per domain in the receiving hub's `changes/` — not one per file.

#### Scenario: Campaign planning

- **WHEN** batches are planned
- **THEN** each batch names the CQs it serves and its size stays at dozens of files

### Requirement: Extraction SHALL route per-fact tuples through the standard intake pipeline

Each extracted fact SHALL be a tuple (claim, source, locator, evidence); a fact without locator
and evidence SHALL NOT be routed. Records SHALL yield `file://` pointers only. Each source's date
SHALL resolve through the date gate before extraction. A mixed cross-cutting source SHALL route
via `/km-supervise` with `--dry-run` first; out-of-scope facts SHALL land in `_unrouted/` or be
logged out-of-scope, never dropped silently. A conflict with a SETTLED fact SHALL open a dispute
file and the batch SHALL proceed without that fact until adjudication.

#### Scenario: A fact has no locator or evidence

- **WHEN** extraction yields a fact without a locator and evidence excerpt
- **THEN** the fact is not routed, and it is reported in the batch report as unsourced

#### Scenario: A mixed source yields an out-of-scope fact

- **WHEN** a fact from a cross-cutting source matches no receiving hub's scope
- **THEN** it is written as a tuple to `_unrouted/` and counted in the batch report

### Requirement: Minted entities SHALL close their edges within the proposing batch

Every wikilink target of a minted entity SHALL exist or be minted in the same proposal, so
`[ LINKS ]` passes on apply.

#### Scenario: A Decision references a Stakeholder that does not exist

- **WHEN** a batch mints a Decision whose `decidedBy` names an unminted Stakeholder
- **THEN** the Stakeholder note is minted in the same proposal

### Requirement: Every extract SHALL carry an access class from interview or SourceSystem default

Each extract SHALL inherit the SourceSystem `defaultAccessClass` unless the domain's boundary
interview restricts it; restricted material SHALL never reach indexes or `shareable/`.

#### Scenario: An interview restricts a domain

- **WHEN** a boundary interview declares a domain's material restricted
- **THEN** every extract from that domain is stamped with the restricted class regardless of the
  SourceSystem default

### Requirement: A rejected proposal SHALL produce a corrections rule before deletion

A rejected proposal SHALL yield a `corrections/` note capturing the durable `rule:` before the
proposal is deleted, and every subsequent batch session SHALL read active corrections first.

#### Scenario: The owner rejects a batch proposal

- **WHEN** a proposal is rejected
- **THEN** a `corrections/` note with a durable `rule:` exists before the proposal file is removed

#### Scenario: A later batch session starts

- **WHEN** any subsequent batch session begins
- **THEN** active correction rules are read before extraction and obeyed

### Requirement: Campaign state SHALL be resumable and re-runs SHALL be idempotent

Batches SHALL be tracked as planned / proposed / approved / applied / rejected in the campaign
state table. Every apply SHALL stage exact paths, carry the `KM-Agent:` trailer, and be followed
by `build-indexes.sh` and a green `hub-scan.sh`. On re-run, a source whose ledger row matches by
content hash SHALL be skipped; a changed source SHALL be flagged for the owner. Ledger adoption at
an estate SHALL be a governed act: owner authorization plus a commit stating the reason.

#### Scenario: A session resumes a half-done campaign

- **WHEN** a cold-start session reads the catalogue's campaign-state table and the ledger
- **THEN** it can state which batches are planned, proposed, approved, applied, or rejected, and
  proceed without re-proposing adjudicated work

#### Scenario: A re-run meets an already-adjudicated source

- **WHEN** a re-run finds a ledger row whose `content_hash` matches the source's current hash
- **THEN** the source is skipped

#### Scenario: A re-run meets a changed source

- **WHEN** a re-run finds a ledger row whose `content_hash` differs from the source's current hash
- **THEN** the source is flagged for the owner and is not silently re-proposed

### Requirement: Duplicate subtrees SHALL be reconciled, never silently deduped

The owner SHALL choose one copy as source of record; differences SHALL reconcile file by file
through the dispute mechanism.

#### Scenario: Two copies of a subtree differ

- **WHEN** the catalogue finds a duplicated subtree with differing content
- **THEN** the owner selects the source-of-record copy and each differing file is reconciled
  individually, and no copy is dropped without that selection

### Requirement: The campaign SHALL close with evidence

When all planned batches are applied, each hub's competency questions SHALL be re-checked and
flipped N → Y only with a pointable fact; `/km-handover` SHALL run per receiving hub; ingestion
rows SHALL clear from `QUEUE.md`; and the incumbent plan SHALL be retired
(`lifecycle: retired`) pointing at the closing commit.

#### Scenario: All planned batches are applied

- **WHEN** the close step runs
- **THEN** every CQ flip cites a pointable fact, handover runs per hub, the queue holds no
  ingestion rows, and the superseded plan is marked retired with the closing commit referenced
