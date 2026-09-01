# Campaign Ledger & Catalogue Format — `/km-vault-upgrade`

The machine-readable formats the vault-upgrade campaign reads and writes, defined once. This
contract is an instance of the standard's import-package contract (`STANDARD.md` → "Import package
contract"): one canonical machine-readable file, JSON so validation needs no external parser
dependency, match hints over duplicate records, and a mechanical validator that gates intake, not
truth.

`tests/test_vault_upgrade_ledger_format.sh` parses its assertions from the machine-readable block
below. **One-definition rule: the block defines; prose elaborates, never redefines.** An edit to
the block reddens the test.

## The machine-readable block

```km-vault-upgrade-contract
ledger-required-row-keys: source_path content_hash disposition proposal_ref batch_id decided_on
disposition-enum: extracted pointer-only rejected out-of-scope deferred
status-enum: planned proposed approved applied rejected
content-hash-format: sha256:<64 lowercase hex>, computed over the file's raw bytes
catalogue-required-columns: domain file date date-source class route
```

## The campaign ledger

One canonical JSON file at the estate Supervisor: `_KM_Supervisor/campaign-ledger.json` once
adopted. It is the campaign's idempotency receipt: which sources have been adjudicated, how, and
under which proposal. It holds **match hints, not duplicate records** — a row points at the source
and the proposal; it never restates extracted content.

### Shape, by example

```json
{
  "manifest": {
    "contract": "km-vault-upgrade/ledger-format",
    "source_system": "sources/systems/vault-example.md",
    "campaign": "vault-example-2026-08",
    "generated_by": "km-vault-upgrade",
    "created_on": "2026-09-02"
  },
  "rows": [
    {
      "source_path": "accounts/orion/2026-04-07-account-report.md",
      "content_hash": "sha256:9b74c9897bac770ffc029102a200c5de1ce02b0400a83f26304e04a0d829c202",
      "disposition": "extracted",
      "proposal_ref": "hub-a/changes/2026-09-02_vault_accounts-b1_proposal.md",
      "batch_id": "B1",
      "decided_on": "2026-09-02"
    },
    {
      "source_path": "Business/2026 Q1 Financial Report.xlsx",
      "content_hash": "sha256:5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03",
      "disposition": "pointer-only",
      "proposal_ref": "hub-a/changes/2026-09-02_vault_accounts-b1_proposal.md",
      "batch_id": "B1",
      "decided_on": "2026-09-02"
    },
    {
      "source_path": "events/conference-notes-04.md",
      "content_hash": "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "disposition": "deferred",
      "proposal_ref": null,
      "batch_id": "B5",
      "decided_on": "2026-09-04",
      "flagged_on": "2026-09-20"
    }
  ]
}
```

### Row rules

- **Every row carries all six required keys** (`ledger-required-row-keys` above). `proposal_ref`
  is the repo-relative path of the proposal that adjudicated the source for `extracted`,
  `pointer-only`, and `rejected` rows; it is `null` for `out-of-scope` and `deferred` rows, which
  no proposal carries.
- **`disposition` takes exactly one value from the enum:**
  - `extracted` — knowledge facts were routed into one or more proposals;
  - `pointer-only` — a record; the hub holds a `file://` pointer, never a copy (Rule 6);
  - `rejected` — proposed and rejected by the owner; the `corrections/` rule, not this row,
    carries the lesson;
  - `out-of-scope` — matched no receiving hub's scope; the tuple sits in `_unrouted/`;
  - `deferred` — an owner ruling postponed it (no CQ needs it yet).
- **One row per `source_path`.** A duplicate path is a contract violation: two adjudications of
  one source is either a re-run that should have updated the row, or a conflict the owner never
  saw. Re-adjudication **updates** the existing row (new hash, new disposition, new
  `proposal_ref`, new `decided_on`) and removes any `flagged_on`.
- **`content_hash`** follows `content-hash-format`: `sha256:` plus 64 lowercase hex digits,
  SHA-256 over the file's **raw bytes** — no whitespace, line-ending, or frontmatter
  normalization. The vault is the system of record; any byte change is a change the owner should
  see. A normalizing hash would silently decide on the owner's behalf which differences matter.
  Compute: `shasum -a 256 <file>`.
- **`batch_id`** correlates the row with the campaign-state table in the catalogue header
  (below). Every `batch_id` in the ledger names a batch that table carries.
- **`decided_on`** is the `YYYY-MM-DD` date of the owner decision the row records (approval,
  rejection, or ruling) — not the date the row was written.
- **An empty ledger (zero rows) is valid.** A fresh campaign has adjudicated nothing.

### FLAG semantics on hash change

On re-run, each catalogued source is hashed and looked up by `source_path`:

- **Hash matches the row** → the source is skipped. Adjudicated is adjudicated.
- **Hash differs** → the run stamps `flagged_on: YYYY-MM-DD` on the row and reports the source to
  the owner as **FLAG**. The row's hash, disposition, and proposal ref remain the adjudicated
  record until the owner rules; nothing is re-proposed silently. A flagged row is resolved by
  owner re-adjudication (row updated, `flagged_on` removed) or an explicit owner ruling to keep
  the prior disposition (`flagged_on` removed, `decided_on` updated).
- **No row** → the source is new to the campaign and enters batch planning normally.

A ledger consisting entirely of flagged rows is valid: it describes a vault that changed wholesale
under a completed campaign, awaiting owner rulings.

### Adoption is a governed act

The ledger is **new estate state**. The skill instructs its adoption under the Supervisor tier's
generic change rule — owner authorization in session plus a git commit stating the reason — and
never creates it silently. The supervisor template's growth-conditions table does not yet name
this capability; that row lands with the follow-up that ships the estate-side runtime validator.

Everything else the campaign materializes — batch staging, extraction intermediates, dry-run
routing tables — lives in `_scratch/` (git-ignored, wipeable, stated lifetime, per the
scratch-plane doctrine). Only the ledger, the catalogue, and the proposals touch governed trees.

## The catalogue

One markdown file per campaign at the Supervisor `_inbox/`
(`vault-catalogue-YYYY-MM-DD.md`), regenerated per catalogue run — not appended. Regeneration is
safe because rulings are carried forward verbatim (below) and the file is mechanical everywhere
else; an append-per-run catalogue would fork the file into competing snapshots a resuming session
would have to reconcile. A pre-existing hand-built catalogue that satisfies this structure is a
valid instance of this contract retroactively; its rulings enter the carry-forward set unchanged.

### Required structure, in order

1. **OKF frontmatter** (`type: report`, `lifecycle: draft` until the campaign closes).
2. **`## Owner rulings applied`** — every owner ruling (exclusions, routes, quarantines), carried
   **verbatim** from any prior catalogue and extended by new rulings, each dated. Rulings are
   decisions; re-deriving one is how a re-catalogue silently reverses it.
3. **`## Campaign state`** — the batch table, updated per session. This is the resumability
   surface: a cold-start session reads this table plus the ledger and knows exactly where the
   campaign stands. Columns:

   | Batch | Domain | CQs served | Status | Decided on |
   |---|---|---|---|---|
   | B1 | Business | CQ1, CQ3 | applied | 2026-09-02 |
   | B2 | Meetings | CQ1, CQ3 | proposed | — |
   | B3 | Work + root actives | CQ2, CQ4 | planned | — |

   - **Batch** is the `batch_id` ledger rows carry; the correlation is by that identifier.
   - **Status** takes exactly one value from `status-enum`: `planned` (declared, not yet
     extracted) → `proposed` (proposal dispatched to the hub's `changes/`) → `approved` (owner
     approved, not yet applied) → `applied` (applied, scans green, ledger rows written) — or
     `rejected` (owner rejected; a `corrections/` rule exists; the batch may be re-planned under
     a new batch id).
   - **Decided on** is the date of the owner decision that produced the current status; `—` while
     `planned` or awaiting decision.
4. **Domain summary table** — one row per domain: route, file count, knowledge candidates,
   records.
5. **Per-file catalogue table** — the mechanical rows. Required columns per
   `catalogue-required-columns`: **domain, file, date, date-source, class, route.** Additional
   columns (size, notes) are permitted. Values:
   - `date` — `YYYY-MM-DD`; `date-source` — `named` (parsed from the filename, authoritative
     candidate) or `mtime` (filesystem, must pass the date gate at intake).
   - `class` — `knowledge?` (extraction candidate) or `record` (stays in the vault; pointer only
     if referenced).
   - `route` — candidate hub by registry keywords, a quarantine marker for bulk-export subtrees,
     or `excluded` with the ruling's date.

A reader with this contract alone can produce a valid ledger row and a valid catalogue row; that
is the bar the format test holds it to.
