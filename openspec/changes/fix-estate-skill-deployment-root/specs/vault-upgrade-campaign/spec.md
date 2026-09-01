# Capability: vault-upgrade-campaign

Correction to the deployment requirement added by `add-km-vault-upgrade-skill`. The rule stands —
linked, never copied — and the location it names is corrected to the estate's governed unit.

## MODIFIED Requirements

### Requirement: The skill SHALL reach an estate by symlink from the canonical tree, never by copy

The Supervisor tier is the estate's governed unit — a git repository holding estate state, with
its own change rule and its own `CLAUDE.md`/`AGENTS.md` — and the skill SHALL resolve from inside
it: `_KM_Supervisor/.claude/skills/km-vault-upgrade`, plus `_KM_Supervisor/.agents/skills/km-vault-upgrade`
where the estate runs an AGENTS.md surface. Each entry SHALL be a symlink to the standard
checkout's canonical `skills/km-vault-upgrade/`.

The skill SHALL NOT be deployed to the workspace root above the tier: that directory is not a
repository, so a link there is untracked, reached by no scan, and carries no scope guard.

An estate session SHALL run with the tier as its working directory, reaching hubs as siblings at
`../<hub>/`. A new estate SHALL create the links when its Supervisor tier is minted; an existing
estate SHALL adopt them at the skill's first run; every run SHALL health-check them before
campaign work begins.

#### Scenario: First run at a tier with no deployment entry

- **WHEN** the skill runs at a Supervisor tier whose `.claude/skills/` carries no
  `km-vault-upgrade` entry
- **THEN** it offers to create the symlink as an owner-authorized act, and proceeds only once the
  entry resolves into a standard checkout's `skills/` tree

#### Scenario: A copied skill tree is found in place of the link

- **WHEN** the health-check finds `.claude/skills/km-vault-upgrade` as a copied directory
- **THEN** it is reported as drift risk and its replacement with the symlink is offered — never
  left silently

#### Scenario: A link is found at the superseded workspace-root location

- **WHEN** the health-check finds a `km-vault-upgrade` entry under the workspace root's
  `.claude/skills/` rather than inside the tier
- **THEN** the superseded location is reported and relocation into the tier is offered, because a
  link above the tier belongs to no repository

#### Scenario: A newly minted Supervisor tier

- **WHEN** a Supervisor tier is minted from the tier template
- **THEN** it carries `CLAUDE.md` and `AGENTS.md` declaring the tier's routing scope and change
  rule, and its estate-tier skill links are created as part of minting
