# Capability: hub-session-scan

What the session-start scan every hub inherits reports about resolved disputes, docs-site pages,
a legacy integrity manifest, and divergent runtime skill trees.

## ADDED Requirements

### Requirement: A dispute resolved in place is reported as a retained record, never as active

A dispute file in `reconciliation/_disputes/` whose OKF frontmatter carries `lifecycle: resolved`
SHALL be reported as `RESOLVED (retained record)` and SHALL NOT be listed under active disputes or
raise the active-dispute advisory. Only that exact value SHALL count: a file with no frontmatter,
any other lifecycle value, or a file the scan cannot read SHALL remain an active dispute, because
a check reporting by absence must never read *could not evaluate* as *nothing open*. Where both
states are present in one folder, they SHALL render differently in one run.

#### Scenario: A retained resolved dispute stops nagging

- **WHEN** a dispute file carries `lifecycle: resolved` in frontmatter
- **THEN** the scan reports it as `RESOLVED (retained record)` at exit 0
- **AND** it does not appear under `! Active disputes:`

#### Scenario: An active dispute beside it still fires

- **WHEN** the same folder also holds a dispute with no frontmatter
- **THEN** that dispute is listed under `! Active disputes:` with its blocked-on reading unchanged

### Requirement: A docs-site source tree is an outbound surface

Every markdown page under `working-docs/*-docs-site/docs/` SHALL be scanned by the restricted
check exactly as `shareable/` is: restricted markers, restricted note names, restricted-class
lines and verbatim restricted section text on a page are errors. Those pages SHALL be excluded
from the restricted check's note walk, as every other surface is. Content elsewhere under
`working-docs/` SHALL NOT be treated as an outbound surface, and the naming convention SHALL be
stated as the check's limit.

#### Scenario: Restricted text on a published page

- **WHEN** a docs-site page carries a verbatim line of a body-restricted section
- **THEN** the scan raises a restricted-section-text finding and exits with its error status

#### Scenario: A restricted note named on a published page

- **WHEN** a docs-site page names a frontmatter-restricted note
- **THEN** the scan raises a restricted-identifier finding and exits with its error status

#### Scenario: The boundary does not widen

- **WHEN** an ordinary working document outside a docs-site tree carries the same verbatim line
- **THEN** the scan raises no outbound-surface finding for it

### Requirement: A lingering hand-maintained manifest is named as retired, never gated on

Where `hub-manifest.md` exists at the hub root, the scan SHALL report it as a retired convention
— an advisory naming the removal route — and SHALL NOT treat it as an error, read its contents,
or build any check over them. The scaffold exclusions SHALL keep the filename so a lingering copy
is not misread as a generated document.

#### Scenario: A legacy hub carries a manifest

- **WHEN** `hub-manifest.md` is present
- **THEN** the scan prints the retirement advisory at exit 0 (absent other findings)

#### Scenario: A migrated hub is silent

- **WHEN** no `hub-manifest.md` exists
- **THEN** the scan prints nothing about a manifest

### Requirement: Mirror findings carry the skill-tree ruling

The projection block's two mirror findings SHALL remain errors and SHALL state the repair route
the ruling fixes: a skill installed in one runtime tree only is installed in the other tree in
the same governed act or retired from both, and divergent copies of one skill are repaired by
refreshing both trees from the pinned canonical (shipped skill) or raising both to the stronger
copy (hub-local skill), never by levelling at whichever copy is newer.

#### Scenario: A one-tree skill names the ruling

- **WHEN** a skill directory exists in one installed runtime tree and not the other
- **THEN** the scan reports the divergence as an error
- **AND** the finding states that a skill belongs in both trees or in neither
