# Design: add-km-vault-upgrade-skill

**No STANDARD.md version is drafted by this change.**

## Skill class: workspace-level, canonical-only

The campaign is estate work run at the Supervisor, like initiation and routing. The skill therefore
lives at `skills/km-vault-upgrade/` with no mirror copies under `template/.claude/skills/` or
`template/.agents/skills/`. Consequences, each verified against the shipped checks rather than
assumed: `test_skill_distribution_parity.sh` counts a slug with no mirror as single-location and
does not compare it; `test_readme_inventory.sh` derives its expectations from template trees, which
this change does not touch; only the README's untested `skills/` prose row is extended. Both origin
assumptions — "factory ships the command" and "the campaign runs at the Supervisor tier" — hold
simultaneously: the factory ships it, the estate operates it.

## The ledger is an import-package contract instance

The standard's import-package contract (one canonical machine-readable JSON, self-describing, match
hints over duplicate records, a mechanical validator that gates intake, not truth) already names
the shape a re-runnable bulk import needs; the campaign ledger instantiates it rather than
inventing a parallel format. One canonical JSON file at the estate Supervisor
(`_KM_Supervisor/campaign-ledger.json` when adopted), rows of
`{source_path, content_hash, disposition, proposal_ref, batch_id, decided_on}`.

**Adoption is a governed act.** The ledger is new estate state, so the skill *instructs* its
adoption under the tier's generic change rule — owner authorization in session plus a git commit
stating the reason — and never creates estate state silently. The supervisor template's
growth-conditions table names six capabilities and not this one; adding a seventh row is
deliberately left to the follow-up that ships the estate-side runtime validator, so this change
keeps every existing skill file untouched.

**One-definition rule.** `ledger-format.md` carries exactly one machine-readable block (required
row keys, the disposition enum, the campaign-state status enum, the content-hash format, and the
catalogue's required columns). The format test derives its assertions from the block at run time
— row keys, both enums, and the hash format — so an edit to those lines reddens the test; the
catalogue-columns line is validated by the estate-side follow-up, and the test names that limit
on every pass. Prose elaborates, never redefines.

**Content-hash normalization** is decided in the contract itself, with examples: SHA-256 over the
file's raw bytes, no whitespace or frontmatter normalization. The vault is the system of record and
any byte change is a change the owner should see as a FLAG; a normalizing hash that silently
equates two byte-states would decide on the owner's behalf which differences matter.

## The catalogue format is standardized from the incumbent's

Same columns the 2026-08-31 catalogue proved in use (domain, file, date, date-source, class,
route/size) plus an explicit owner-rulings section carried forward verbatim on re-catalogue —
rulings are decisions, and re-deriving a decision is how a re-run silently reverses one. The
incumbent catalogue becomes the first valid instance retroactively. Campaign state (the batch
table: batch-id, domain, CQs served, status, decided-on) lives in the catalogue file's header,
updated per session — resumability without new state files beyond the ledger.

## Working state stays in `_scratch/`

Batch staging, extraction intermediates, and dry-run routing tables are declared-lifetime scratch
(git-ignored, wipeable, per the scratch-plane doctrine). Only the ledger, the catalogue, and the
proposals touch governed trees, so a half-done batch leaves no debris a scan would have to explain.

## "Arrival is not a decision" is preserved

The skill never pauses per file. The holds are exactly three, each an owner decision the standard
already requires: the date gate (mtime-only sources confirmed at intake), the boundary interview
per domain (an uninterviewed domain blocks its batch and surfaces a QUEUE row), and per-domain
proposal approval. Everything else — cataloguing, extraction, edge-closure computation, ledger
writes — runs to completion unasked.

## The Episode V lifecycle conflict, resolved

The origin spec says the incumbent plan retires as `lifecycle: superseded`; the incumbent's own
Phase 6 (as amended 2026-08-31) says `lifecycle: retired`. The origin states its own precedence
rule — the plan's owner rulings win until superseded — so the skill's close step uses
`lifecycle: retired`, pointing at the closing commit.

## No new gate check beyond the format test

`SKILL.md` is auto-covered on arrival: the frontmatter suite discovers it by directory walk, the
gate resolves its relative links, and the gate fingerprints it as a tracked file. Skill bodies are
procedures; their behavioral conformance is the spec's scenario list, exercised at the first
estate run. Only the ledger/catalogue format — machine-read state that can drift silently —
warrants a new discovered test, and that test also carries literal-conformance cases (the
`test_hub_merge.sh` pattern, each matcher proven live) for the skill's load-bearing declarations:
never write entity folders, rulings carried forward verbatim, never silently dedupe.

## Estate deployment: linked, never copied (post-review correction)

The first drafting assumed the incumbent's mechanism — copy the skill into the estate's
`.claude/skills/`. The owner corrected it: a copied skill inside a deployed estate is exactly the
drift class the parity work already measured, and no factory check reaches it. The skill now
deploys as a symlink from `<workspace>/.claude/skills/km-vault-upgrade` to the checkout's
canonical `skills/km-vault-upgrade/`, with two control points and only these: Supervisor-tier
minting incorporates the links into new instances (tier template README section), and the
skill's own Step 0 health-checks the link on every run at existing estates — a missing entry is
offered for creation under owner authorization, a copy is reported as drift risk and offered for
replacement, never left silently. Per-hub skills are out of this doctrine's scope: hubs receive
them from `template/` at initiation and the parity suite governs those copies.
