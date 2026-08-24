# Tasks

Executed on branch `v1.52-publication-status-scope`, off `main` at `487890f` (published v1.51).
Ordered by dependency: reproduce before repairing, measure the unrepaired tree before the repair is
in the working tree, repair, prove the other direction, then record.

Requirement references point at `specs/publication-status-classification/spec.md` (PSC).

## 1. Verify the premise before repairing anything

- [x] 1.1 Read both instruments' actual patterns and scopes rather than the brief's paraphrase.
      `validate_published_not_draft.py` matched `^\|\s*(v\d+\.\d+)\s*\|(.*)$` and searched group 2,
      which is the date column and the description together.
      `validate_ledger_dates.py` matched `^\|\s*(v\d+\.\d+)\s*\|\s*([^|]*?)\s*\|(.*)$` and searched
      group 3, the description alone. The two instruments did not search the same string.
- [x] 1.2 Confirm whether the implementations are identical or merely similar. The `DRAFT_ROW`
      constant is byte-identical in both files and neither imports anything from the other. Only the
      slice each applies it to differs, which is a copied rule and not a shared one.
- [x] 1.3 Find every other caller. Outside the two instruments and their two canary suites, the only
      references to either check or to `DRAFT_ROW` are in `STANDARD.md` and in earlier OpenSpec
      packages, all prose. No third consumer exists, so the blast radius of a shared classifier is
      the two instruments and their suites.
- [x] 1.4 Reproduce the measured consequence. Taking the tree at `1444b15` and flipping only the
      v1.50 row's opener to `Drafted and published 2026-08-24 (owner push).`,
      `validate_published_not_draft.py` printed `49 published, 2 unpublished` and exited 0, and
      `validate_ledger_dates.py` printed `2 excluded as drafted, v1.23, v1.50` and exited 0. Both
      returned PASS over a published row that only quotes a declaration.
      (PSC: a published row quotes a declaration mid-description)
- [x] 1.5 Run both instruments against `1444b15` unmodified. Same numbers, which is where the brief's
      figures come from: the row is genuinely in draft there, and the opener and the quotation both
      say so, so the classification is overdetermined and the defect is invisible until the opener
      alone is flipped.
- [x] 1.6 Record why the current tree passes. The published v1.50 row on `main` reads `by the draft
      declaration in the v1.23 row` where the draft row read the token itself. The quotation was
      paraphrased out at publication time, which repaired the document to fit the instrument.

## 2. Decide the shape of the repair, and argue it

- [x] 2.1 Enumerate the real opener forms. Unpublished: `**DRAFT — awaiting owner push.**` (v1.23),
      `**DRAFT, awaiting owner push.**` (the v1.50 and v1.51 drafts), and the bare
      `DRAFT - awaiting owner push` the docstring documents. Published:
      `Drafted and published <date> (owner push).` and `Drafted <date>; published <date> with
      <version>.` "Opens with" therefore tolerates leading whitespace and emphasis markers, and
      nothing else. (PSC: publication status is declared at the opening of a row)
- [x] 2.2 Decide one place or two. One. The argument is written in `design.md` under "one classifier,
      not two anchored patterns": the rule now carries three subtleties, and
      `validate_ledger_dates.py`'s own docstring already asserted a single home of record the code
      did not implement. (PSC: one classifier serves every instrument)
- [x] 2.3 Direction of dependency. The classifier is a peer of both instruments rather than a library
      owned by one, so that renaming or retiring either check does not silently break the other.
- [x] 2.4 Establish the gate's treatment of a module under `scripts/`. Every tracked `*.py` there is a
      discovered check that must self-run and carry a declaration; a module run bare would exit 0
      whatever it contained. It therefore declares `km-gate-instrument:` and names its canaries, and
      the gate refuses unless they run in the same pass. Confirmed in the gate's own output.
      (PSC: the shared classifier is covered by canaries and declared to the release gate)

## 3. Build the shared classifier

- [x] 3.1 `scripts/publication_status.py` holds `HISTORY_HEADING`, `ROW_LINE`, `ROW_CELLS`,
      `DRAFT_OPENER`, `split_row`, `opens_with_draft_declaration` and `is_published`, with the rule,
      its tolerances and the derivation of both stated in the file.
      (PSC: the classification reads the description cell and never the whole row)
- [x] 3.2 Declared `km-gate-instrument: tests/test_publication_status_scope.sh` and
      `km-unrepaired-tree: v1.52` carrying both instruments' unrepaired numbers.
- [x] 3.3 Strict direction confirmed and stated: an unrecognised opener classifies published, which
      in `validate_published_not_draft.py` can only raise a false alarm and in
      `validate_ledger_dates.py` sends the version to the resolver, where it is named in the coverage
      gap. Neither instrument passes by that route.
      (PSC: the token appears in an unrecognised opening form)

## 4. Repair both instruments

- [x] 4.1 `validate_published_not_draft.py` imports the classifier, splits the row before classifying
      it, and refuses on a row it cannot split rather than leaving the version unclassified.
- [x] 4.2 `validate_ledger_dates.py` imports the classifier and holds no pattern. Its own row parser
      is replaced by `split_row`, so both instruments cut a row identically.
- [x] 4.3 Both `km-unrepaired-tree` declarations re-stated naming v1.52 and the real numbers. The
      gate reports `2 check file(s) added, 4 changed, of 34 declared` and accepts them.
- [x] 4.4 Both docstrings rewritten so the prose and the code state the same rule, with the v1.50
      measurement recorded in each.

## 5. Prove both directions

- [x] 5.1 `tests/test_publication_status_scope.sh`: 6 declaration forms, 4 published forms, the
      quoting row and its mirror, a superseded-pattern comparison over the same fixtures, 3
      row-splitting cases, a date-column case, and the real-row evidence case at `1444b15`. All pass.
- [x] 5.2 `tests/test_published_not_draft.sh` case 11: a published row quoting a declaration now
      fails with its markings judged (11a), a drafted row quoting the same one still passes with
      `1 unpublished` (11b), and the real tree at `1444b15` stays exempt as it stands while the
      opener-flipped copy fails naming 3 real stale markings (11c).
      (PSC: both instruments are proved against a tree where the quotation was live)
- [x] 5.3 `tests/test_ledger_dates.sh` case 10: a published row quoting a declaration is compared and
      its wrong date caught (10a), a drafted row quoting the same one is still excluded (10b), and
      the real ledger at `1444b15` is run in three states, excluded as it stands, compared with the
      opener flipped, and failing when a wrong date is put on that now-compared row (10c).
- [x] 5.4 The `1444b15` evidence case is in all three suites, driven from git rather than from a
      copied fixture, and reports a coverage gap rather than a verdict where the commit is absent.
- [x] 5.5 The before-state numbers are recorded in the suites' own `km-unrepaired-tree` declarations,
      so a later reader finds what the unrepaired instruments said without reading a report.

## 6. Record and verify

- [x] 6.1 `STANDARD.md` §"Standard Maintainer" gains "A status is read where a status is declared, and
      quoted everywhere else (added in v1.52, drafted and unpublished)", carrying the demonstration,
      the silent-withdrawal-of-coverage property, and the clause that it binds nothing until its own
      owner push.
- [x] 6.2 The v1.52 row states the defect, both instruments' actual reported numbers, the three stale
      markings the exemption hid, the repair, the unification argument, the proofs, and plainly that
      two green checks were blind and that house practice rather than an unusual input caused it.
- [x] 6.3 Header and lead flipped to v1.52 drafted and unpublished. The published v1.51, v1.50 and
      v1.49 descriptions are preserved word for word; the only edit to them is the v1.51 paragraph's
      opening phrase, which becomes "The current published version is", as every prior draft has done.
- [x] 6.4 The v1.52 row quotes a declaration token verbatim, deliberately. It is the case the repair
      makes safe, the repair is in place and proved before the quotation was written, and it leaves a
      live proof in the ledger that the next publishing session will run. The row is currently
      excluded by its own opener with the quotation sitting live in the same cell, which both
      instruments confirm.
- [x] 6.5 The row's date is derived from this change's own commit and from nothing else.
- [x] 6.6 `python3 tools/km-release-gate.py` exits 0: 33 checks discovered, 28 run, 5 skipped as
      instruments covered by their canaries, 34 declarations read.
- [x] 6.7 The canonical leakage instrument run over the final tree, both halves, against a freshly
      regenerated denylist: case-insensitive whole-word over 750 terms and case-sensitive whole-word
      over 10, 209 tracked files scanned each, no match.
- [x] 6.8 Not pushed. Publication is the owner's decision.
