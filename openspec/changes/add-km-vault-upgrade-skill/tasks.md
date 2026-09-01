# Tasks: add-km-vault-upgrade-skill

Drafted on `main` at `045515c`. **No STANDARD.md version is drafted by this change.**

## 1. Format contract (U2)

- [x] 1.1 Write `skills/km-vault-upgrade/ledger-format.md`: ledger row contract
      (JSON schema-by-example), catalogue column contract, campaign-state table contract
      (batch-id, domain, CQs served, status enum `planned | proposed | approved | applied |
      rejected`, decided-on, batch-id ↔ ledger-row correlation), disposition enum
      `extracted | pointer-only | rejected | out-of-scope | deferred`, FLAG semantics on hash
      change.
- [x] 1.2 Decide and document content-hash normalization with concrete examples (raw bytes,
      SHA-256, no normalization — see design.md).
- [x] 1.3 One machine-readable block carries the enums and required keys; the format test parses
      its assertions from it (one-definition rule).
- [x] 1.4 Document ledger adoption as a governed act and `_scratch/` staging for everything else.

## 2. Skill body, Episodes I–III (U3)

- [x] 2.1 Frontmatter: `name: km-vault-upgrade`, one trigger-phrased description naming
      `/km-vault-upgrade <vault-path>` (10–40 words, no colon-space in the value).
- [x] 2.2 Governing principles block; Step 1 idempotent registration; mechanical catalogue with
      rulings carried forward verbatim; interview gate with QUEUE row on block; per-fact
      extraction with edge closure, accessClass stamping, `--dry-run` for mixed sources,
      `_unrouted/` for out-of-scope; rejection → `corrections/` rule loop.

## 3. Skill body, Episodes IV–V (U4)

- [x] 3.1 Apply contract (exact paths, `KM-Agent:` trailer, `build-indexes.sh`, `hub-scan.sh`
      green); ledger use and re-run semantics (hash match ⇒ skip, changed ⇒ FLAG); duplicate
      reconciliation (source-of-record, per-diff, never silent dedupe); evidenced close
      (CQ re-check N→Y, `/km-handover`, QUEUE cleared, incumbent retired `lifecycle: retired`).

## 4. Format test (U5)

- [x] 4.1 Write `tests/test_vault_upgrade_ledger_format.sh`: valid fixture passes with coverage
      stated; each named mutation fails with a rule-specific message; empty ledger valid;
      truncated JSON refused (exit 2); assertions parsed from the contract's machine-readable
      block; literal-conformance cases for the skill's load-bearing declarations, each matcher
      proven live.
- [x] 4.2 Run the failing direction FIRST against a violating fixture; record that run in the
      `km-unrepaired-tree` declaration's result text. Declaration token: `none` with the reason
      (new-capability check, no defect, no version drafted). The suite lands green.

## 5. Surfaces and gate (U6)

- [x] 5.1 Extend README's `skills/` repository-map prose row with vault-onboarding phrasing
      (the tested per-hub parenthetical row untouched).
- [x] 5.2 Run `python3 tools/km-release-gate.py` directly; record the exit status. Exact-path
      staging throughout.

## 6. Estate deployment doctrine (post-review correction)

- [x] 6.1 SKILL.md: deployment-by-symlink block ("a symlink, never a copy") + Step 0 health-check
      (missing entry → offer the link, owner-authorized; a copy → drift risk, replacement offered).
- [x] 6.2 Supervisor tier template README: "Workspace-level skills: linked, never copied" section
      naming the two control points (instance minting, per-run health-check).
- [x] 6.3 spec.md: deployment requirement + first-run and copied-tree scenarios; test pins the
      "a symlink, never a copy" literal.
