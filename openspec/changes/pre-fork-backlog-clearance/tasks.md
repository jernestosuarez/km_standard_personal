# Tasks: pre-fork-backlog-clearance (v1.63)

Draft on `main`, off `c5341d9` (published v1.62). Owner direction 2026-08-27: clear the whole
canonical backlog before the fork; nothing stays behind. Not merged as published, not tagged, not
pushed: the wave ends at a gated, unpushed draft.

## 1. Verify every dispatched claim against the canonical tree before acting

- [x] 1.1 Repository state verified: clean at `c5341d9`, even with origin, no unexplained change.
- [x] 1.2 The working-docs/CURRENCY contradiction does not exist in the canonical pair: the
      shipped `template/working-docs/README.md` discloses the currency read and has since the
      repository's first commit; the reporting hub's copy is the pre-v1.12 text. Verified by
      reading both files and `git log --follow` on the canonical one.
- [x] 1.3 The same property swept across every shipped monitoring claim found the class live in
      `template/shareable/README.md` ("not monitored" versus the v1.16 restricted lint), which
      became repair 3.
- [x] 1.4 The merge and withdrawal modes are present in canonical `skills/km-init/SKILL.md`
      (since `77fd1f2`, v1.35 draft; markings cleared at v1.42); the reporting deployment's
      installed copy is 280 lines with zero occurrences of "merge" against the canonical 756.
      Measured, not taken from the ledger.
- [x] 1.5 The estate's docs-site line read from blob `57563716` via `git cat-file -p` with a
      type-check control; genericised on absorption, and the estate copy's one design gap (pages
      left in the note walk) departed from deliberately, recorded in `design.md` §2.
- [x] 1.6 The manifest damage figures (59 of 94, four hubs with none) taken from the raising
      tier's own verified measurement of 2026-08-26, cited as evidence for a ruling rather than
      re-measured here: the ruling turns on the artifact class, not the exact count.
- [x] 1.7 Duplication assessment by property search, both case forms, with controls:
      `docs-site`/`Docs-site`/`docs site` 0 files, `lifecycle: resolved` 0, `retained record` 0;
      known-positive `shareable` 14 files, known-negative nonsense token 0.

## 2. Reproduce the defects as failing cases, committed red (`bdab753`)

- [x] 2.1 Probes run against the unrepaired template at `c5341d9` from a guarded script (all git
      operations refused outside the scratch tree): resolved dispute rendered active at exit 0;
      restricted text on a docs-site page invisible at exit 0; one-tree-only mirror arm fired at
      exit 1 (a pin, not a detector); injected manifest invisible at exit 0.
- [x] 2.2 Canary cases written and committed red: 10d/10d2/10e2, 14n2, 15 in
      `tests/test_hub_scan_canaries.sh`; 1h/1i in `tests/test_restricted_lint.sh`; boundary and
      clean-side pins 1j/1k and 14n's firing half green on both trees by design.
- [x] 2.3 Both suites' `km-unrepaired-tree` declarations re-stated in the red commit, recording
      the runs above.

## 3. Repair and rule

- [x] 3.1 `[ RECONCILIATION ]` split implemented, fail-closed on the exact value `resolved`.
- [x] 3.2 `[ RESTRICTED ]` pass-2 docs-site surface added; pass-1 exclusion added; block comment
      states the convention and its limit.
- [x] 3.3 `[ INTEGRITY ]` retired-manifest advisory added.
- [x] 3.4 `[ PROJECTION ]` mirror findings carry the ruling; first lines kept byte-identical so
      the existing 14k canary still matches.
- [x] 3.5 STANDARD.md: resolved-in-place subsection and updated snippet; docs-site paragraph;
      Rule 3 manifest-retirement subsection plus scaffold-set annotations; skill-tree ruling in
      §"The harness carries its skills twice"; draft lead and v1.63 row.
- [x] 3.6 Directory contracts levelled: `working-docs/README.md` (two checks, docs-site
      paragraph), `shareable/README.md` (false claim corrected, correction named in place),
      `reconciliation/README.md` (retained-resolution option).

## 4. Verify

- [x] 4.1 Both edited suites green against the repaired tree; the red set was exactly the
      intended set before repair.
- [x] 4.2 Release gate run over the draft tree before staging; validators
      (`validate_published_not_draft.py`, `validate_ledger_dates.py`) pass with v1.63 classified
      drafted. Results recorded in the draft commit message.
- [x] 4.3 Leakage: canonical leakage suite run in both modes with its controls; added lines
      inspected for deployment nouns in both directions (none crossed inward; the ruling texts
      name no estate, hub, portal or person).
- [x] 4.4 `git diff --check` clean; staged by explicit path; trailer `KM-Agent: km-hub-builder`.

## 5. Hand over (at publication, not now)

- [ ] 5.1 On the owner push: publish ritual (clear the v1.63 markings everywhere the version
      wrote them, stamp the row from the publishing commit, run the gate inside the publishing
      commit), then the adoption handover to the Supervisor inbox carrying the per-hub actions
      recorded in the v1.63 row.
