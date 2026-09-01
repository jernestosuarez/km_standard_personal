# Proposal: add-km-vault-upgrade-skill

**No STANDARD.md version is drafted by this change.** The skill lands under factory governance
(discovered tests, release gate); publication in the version ledger is the owner's separate
decision.

## Why

Onboarding a large Obsidian vault into a KM estate today requires the owner to hand-write a phased
plan and hand-build a catalogue. The incumbent — `~/km/_KM_Supervisor/vault-ingestion-plan.md` with
its 977-line hand-built catalogue — is the only working solution, and it is not reusable: every
future vault, and every re-run against the same live vault, starts from zero. The bulk-corpus shape
the standard already records as guidance (catalogue → boundary interview → domain split → one
proposal per domain) has no skill implementing it.

The gap analysis that motivates this change (origin: `km-vault-upgrade-gap-plan`, 2026-09-01) maps
the `/om-vault-upgrade` import mechanics onto KM governance and names eight gaps neither system
covers:

- **GAP-1** — the catalogue is hand-built; the per-file rows (date, date-source, class, route,
  exclusion) are mechanical work an agent should do, leaving only rulings to the owner.
- **GAP-2** — om classifies files; KM routes facts. Mixed files need per-fact tuples
  (claim, source, locator, evidence) that can feed multiple hubs from one source.
- **GAP-3** — minting an entity requires its wikilink targets to exist or be minted in the same
  proposal; edge closure per batch is computed by no existing flow.
- **GAP-4** — a campaign of dozens-sized batches across sessions needs resumable state:
  which batches are proposed / approved / applied / rejected, ordered by competency questions.
- **GAP-5** — a rejected proposal must teach the campaign: a `corrections/` note with a durable
  `rule:`, read by every subsequent batch session.
- **GAP-6** — no idempotency receipt exists. Re-running against a live vault must skip
  already-adjudicated sources and flag changed ones, which needs a campaign ledger
  (source path + content hash + disposition + proposal ref) — new estate state, adopted as a
  governed act.
- **GAP-7** — duplicated subtrees need source-of-record selection plus per-diff reconciliation,
  never silent dedupe.
- **GAP-8** — every extract inherits the SourceSystem `defaultAccessClass` unless the boundary
  interview restricts it; restricted material must never reach indexes or `shareable/`.

## What Changes

1. **ADDED capability `vault-upgrade-campaign`** — a workspace-level skill,
   `skills/km-vault-upgrade/SKILL.md`, canonical-only like `km-init` and `km-supervise`. It turns
   the incumbent's hand-written plan into a reusable onboarding command: catalogue → boundary
   interviews → CQ-ordered batched extraction through the existing `/km-gather` / `/km-intake` /
   `/km-supervise` flows → idempotency ledger → evidenced close. The skill orchestrates existing
   flows; it never bypasses proposals, never writes entity folders directly, never copies records
   into hubs, and never modifies the source vault.
2. **Campaign ledger + catalogue format contract** — `skills/km-vault-upgrade/ledger-format.md`,
   an instance of the standard's import-package contract: one canonical machine-readable JSON
   ledger, match hints over duplicate records, a mechanical validator gating intake, not truth.
   The incumbent's catalogue becomes the first valid catalogue instance retroactively.
3. **A discovered format test** — `tests/test_vault_upgrade_ledger_format.sh`, proving in both
   directions that the ledger/catalogue contract cannot drift silently, plus literal-conformance
   cases for the skill's load-bearing declarations.
4. **README repository-map prose** — the untested `skills/` row gains vault-onboarding phrasing.

Explicitly **not in scope**: any STANDARD.md normative edit or version bump; publication
(version-ledger row, badge, changelog); execution of the campaign against the real vault (that is
post-merge estate work under the incumbent plan); any behavioral change to `/km-gather`,
`/km-intake`, or `/km-supervise`; template mirrors or per-hub distribution of the new skill; an
estate-side runtime ledger validator (follow-up once the format survives one real campaign).

## Impact

- `skills/km-vault-upgrade/` (new: `SKILL.md`, `ledger-format.md`), `tests/` (one new discovered
  check), `README.md` (one prose row), plus this OpenSpec package.
- No STANDARD.md edit. No template edit. No existing skill, script, or check is modified. The
  supervisor template's growth-conditions table is deliberately not extended; the ledger row lands
  with the follow-up that ships the estate-side validator.
- The new check carries its `km-unrepaired-tree` declaration as `none` with the reason stated: it
  is a new-capability check, not a defect repair, and no version is being drafted.
- Existing suites stay green: `test_skill_frontmatter.sh` covers the new skill's frontmatter;
  `test_skill_distribution_parity.sh` names it a single-location slug and does not compare it;
  `test_readme_inventory.sh` derives from template trees this change does not touch.
