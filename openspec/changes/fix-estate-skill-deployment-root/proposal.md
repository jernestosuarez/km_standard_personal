# Proposal: fix-estate-skill-deployment-root

**No STANDARD.md version is drafted by this change.**

## Why

`add-km-vault-upgrade-skill` shipped the rule that an estate-tier skill reaches a deployment as a
symlink rather than a copy. It named the wrong location for that link: `<workspace>/.claude/skills/`,
the folder above the Supervisor tier. Measured against a real estate, that location fails every
property the rule exists to secure:

| | workspace root (`~/km`) | Supervisor tier (`_KM_Supervisor/`) | a hub |
|---|---|---|---|
| git repository | **no** | yes | yes |
| `CLAUDE.md` / `AGENTS.md` | **no** | no (until this change) | yes |
| carries a change rule | **no** | yes | yes |
| holds governed state | no | yes | yes |

A link at the workspace root is untracked by any repository, reached by no scan, and orphaned from
any scope guard. The standard's own shape — visible in every hub — is that skills resolve from
`.claude/skills/` beside a `CLAUDE.md`/`AGENTS.md` at the root of a governed, version-controlled
unit. The estate's governed unit is the Supervisor tier, not the folder containing it.

The tier was also missing the scope-guard pair itself, which is why the wrong location looked
plausible: nothing at either level carried one. That gap is closed here rather than left to make
the same mistake available again.

## What Changes

1. **The link moves into the tier** — `_KM_Supervisor/.claude/skills/<slug>`, plus
   `.agents/skills/<slug>` where the estate runs an AGENTS.md surface. `skills/km-vault-upgrade/SKILL.md`
   states the corrected location and the reason, and its Step 0 health-check now also detects a
   link at the superseded workspace-root location and offers to relocate it.
2. **The estate session runs in the tier** — cwd is `_KM_Supervisor/`, with hubs as siblings at
   `../<hub>/`. Paths through the skill body are re-anchored accordingly, and the anchor is stated
   once rather than left implicit.
3. **The tier template gains its scope guard** — `CLAUDE.md` and `AGENTS.md` in
   `skills/km-supervise/_KM_Supervisor_template/`, declaring the tier's **routing** scope (not an
   admission rule), its change rule, and the skills it resolves. A newly minted tier is now a
   properly constituted unit, structurally the same shape as a hub.
4. **The tier template's skills section is corrected** — retitled "Estate-tier skills: linked here,
   never copied, never at the workspace root", stating why the location is the tier and not the
   folder above it.
5. **Spec and operator guide follow** — the deployment requirement is restated as MODIFIED with the
   corrected location and a third scenario for the superseded-location case; `docs/vault-onboarding.md`
   §2–§4 carry the corrected commands and execution roots.

Explicitly **not in scope**: any STANDARD.md normative edit or version bump; a deploy script
(named follow-up); changes to `km-supervise`'s or `km-init`'s own SKILL.md bodies; per-hub skill
distribution, which is a different class governed by the parity suite.

## Impact

- `skills/km-vault-upgrade/SKILL.md`, `skills/km-supervise/_KM_Supervisor_template/` (README
  section corrected; `CLAUDE.md` and `AGENTS.md` added), `docs/vault-onboarding.md`,
  `tests/test_vault_upgrade_ledger_format.sh` (one added literal, declaration re-stated), and this
  package.
- No STANDARD.md edit. No `template/` (reference hub) edit. No existing skill *body* other than
  `km-vault-upgrade`'s is modified.
- The tier template's added files are mint-time artifacts: a **newly minted** tier gets them; an
  existing tier adopts them by an owner-authorized commit, as `docs/vault-onboarding.md` §2
  describes. Adding them changes no already-deployed estate on its own.
- Existing suites stay green: the tier template is read by no test (verified), so adding two files
  to it moves no expectation; `test_readme_inventory.sh` derives from `template/` trees this change
  does not touch.
