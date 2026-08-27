# Change: pre-fork-backlog-clearance (v1.63)

## Why

The deployment owner directed (2026-08-27) that the whole canonical backlog raised by the
reference deployment be cleared before he forks the standard: "include all enhancements and
defects. Nothing stays behind." Six items were dispatched, all raised by the reference
deployment's Standard-tier ledger between 2026-08-23 and 2026-08-26, each verified here against
the canonical tree rather than taken from the ledger's account. Three are defects in shipped
surfaces, two are rulings the standard owed, and two resolve as **no-change** with the reason
recorded — a verdict without its reason is dropped work, and this repository already records a
no-change verdict in a version row once (v1.62's fifth candidate).

**Defect 1 (reported as: the reconciliation check counts every `_disputes/` file as active).**
Verified and reproduced: a dispute file carrying `lifecycle: resolved` in OKF frontmatter — the
retract-in-place shape a deployment used for a dispute resolved by an owner answer — is reported
under `! Active disputes:` at exit 0 by the unrepaired `template/hub-scan.sh`, on every scan,
forever. Two states that mean different things rendered identically.

**Defect 2 (reported as: canonical `hub-scan.sh` does not lint the docs-site outbound surface).**
Verified and reproduced: a page under `working-docs/*-docs-site/docs/` carrying a verbatim line of
a body-restricted section produced `OK: no restricted markers, classes, identifiers or section
text on outbound surfaces` at exit 0. Two installed scan copies in the reference deployment carry
the surface as a hub-local line added under an owner word, which every template refresh threatens
to overwrite; the capability is absorbed genericised, with no organization, portal, hub or person
name crossing.

**Defect 3 (found by the sweep defect report 1 of the ledger demanded, not reported directly).**
The ledger's first item said the `[ CURRENCY ]` check scans `working-docs/` while that directory's
README declares its files unmonitored. In canonical that pair already agrees — the shipped
`working-docs/README.md` has disclosed the currency read since this repository's first commit —
but the sweep of the same property (shipped monitoring claims held against the shipped
instrument) found the class live one directory over: `template/shareable/README.md` says the
folder is "not monitored by `hub-scan.sh`" while the `[ RESTRICTED ]` check has read that surface
since v1.16. False as shipped, in a file every hub installs.

**Ruling 1 (hub-manifest.md).** The hand-maintained hash manifest is not in the canonical
template, four of the reference deployment's eleven hubs carry none, and 59 of 94 recorded hashes
across the seven that do were measured wrong (verified 2026-08-26, recorded in that deployment's
ledger). Ruled **retired**: git history is the sole integrity baseline; migration stated; a
lingering copy becomes an advisory, never an error.

**Ruling 2 (the two runtime skill trees).** A deployment's `.claude` and `.agents` trees held one
shipped skill at two different published versions, and a hub-local skill in one tree only. Ruled:
neither installed tree is authoritative; a refresh writes both trees in one act; a hub-local skill
belongs in both trees or in neither. `[ PROJECTION ]` already errors on both divergence shapes;
its findings now carry the repair route, and the previously untested one-tree-only arm is pinned.

**No-change (the initiation skill's merge and withdrawal modes).** Reported absent from "the
installed initiation skill". Verified present in canonical `skills/km-init/SKILL.md` since the
v1.35 draft (`77fd1f2`); the reporting deployment's installed copy is a 280-line pre-v1.35
generation against the canonical 756, with zero occurrences of "merge". The repair is an adoption
act (refresh the installed workspace-level skill), not a canonical edit.

## What changes

- `template/hub-scan.sh`: `[ RECONCILIATION ]` splits retained resolved disputes (frontmatter
  `lifecycle: resolved`, exact value, fail-closed) from active ones; `[ RESTRICTED ]` adds the
  docs-site surface to pass 2 and excludes it from pass 1; `[ INTEGRITY ]` names a lingering
  `hub-manifest.md` as a retired-convention advisory; `[ PROJECTION ]`'s mirror findings carry
  the skill-tree ruling.
- `STANDARD.md`: the resolved-in-place dispute subsection and updated reconciliation snippet; the
  docs-site surface paragraph in §"Validating the graph"; the manifest-retirement subsection in
  Rule 3 plus scaffold-set annotations; the skill-tree ruling in §"The harness carries its skills
  twice"; the v1.63 draft lead and version row.
- `template/working-docs/README.md`, `template/shareable/README.md`,
  `template/reconciliation/README.md`: directory contracts brought level with the instrument.
- `tests/test_hub_scan_canaries.sh` (cases 10d/10e, 14n, 15) and `tests/test_restricted_lint.sh`
  (cases 1h–1k): both directions per change, committed red at `bdab753` before any repair, with
  the unrepaired-tree runs recorded in each suite's declaration.

## What does not change

The `[ CURRENCY ]` scope is untouched: excluding `working-docs/` (the remedy the reporting hub's
agent recommended against its own pre-v1.12 README) would reverse the published v1.12 correction,
whose motivating failure was an agent answering from a superseded working-docs draft. No line of
`skills/km-init/SKILL.md` changes. No entity schema, contract, component or agent adapter changes.

## Impact on deployments

Nothing binds until the owner push. On adoption: re-deploy `hub-scan.sh`; refresh the three
directory READMEs; remove any `hub-manifest.md` through each hub's own governance; refresh stale
installed copies of workspace-level skills. A hub whose docs-site pages quote restricted material
goes red on the refreshed scan — the check working, not a regression.
