# Tasks: hub-scan-two-defects (v1.57)

Branch `v1.57-hub-scan-two-defects`, off `main` at `2005772` (published v1.56).

## 1. Verify the handed-over designs before implementing either

- [x] 1.1 **Defect 1's boundary, confirmed against the standard rather than invented.**
      §"Hub Directory Structure" fixes `00_about.md` … `07_glossary.md` with `[08–10_<additional>.md]`
      optional, and the monitored-files glob beneath it reads `0[0-9]_*.md   10_*.md`, scoped to the
      hub root. The handed-over `NN_*.md` is wider than the standard's own set in both digits and
      location; the narrower form was taken, because this narrowing relaxes a security check.
- [x] 1.2 **A numbered name in a subdirectory is not curated structure.** No section of the standard
      treats one as such. The case pattern anchors on `"$HUB"/` and case 1f asserts the boundary.
- [x] 1.3 **The body-marker path was examined, not assumed.** A body marker has emitted `C` records
      and no `I` record since v1.21, so such a note was already nameable and needs no narrowing;
      applying one would widen what is blocked, not narrow it. Reasoned out in `design.md` §2 and
      asserted in both directions by case 1g.
- [x] 1.4 **Defect 2's predicate, checked against the block's own published specification.** The
      v1.19 section already reads "counting the `lifecycle: active` notes there whose `rule:` is in
      force in this hub". The implementation never matched it. This is a repair to specification, not
      a new rule.
- [x] 1.5 **The scaffold arm did not survive as handed over.** `template.md` is the wrong case
      against the standard's own scaffold set (`README.md`, `TEMPLATE.md`, `hub-manifest.md`), which
      `skip_doc` in the same script already implements; `DIGEST*.md` names an artifact the standard
      defines nowhere and was verified inert (0 `^rule:` lines across all four digests in the measured
      registry). Departure recorded in `design.md` §4, residual registered as a stated limit.

## 2. Reproduce both defects as failing cases, committed red (`61130a8`)

- [x] 2.1 **Defect 1 fixtures.** `03_risks-decisions.md` (root, frontmatter marker),
      `working-docs/03_engagement-note.md` (subdirectory, frontmatter marker),
      `05_partnerships-pipeline.md` (root, body marker).
- [x] 2.2 **Case 1d, the name side.** A `changes/` directive naming the document it restricts. On the
      unrepaired tree:
      `! RESTRICTED IDENTIFIER '03_risks-decisions' on outbound surface: changes/2026-08-24_XX_restrict-claim_directive.md`,
      exit 1. Case FAILS.
- [x] 2.3 **Case 1e, the content side.** A verbatim body line of the same document on a surface. On
      the unrepaired tree the scan raises no `RESTRICTED SECTION TEXT` finding and exits 0. Case
      FAILS.
- [x] 2.4 **Cases 1f and 1g pass on the unrepaired tree, by design.** They pin the boundary the
      narrowing must not cross and the path it does not touch. Recorded as boundary cases, not
      offered as detectors.
- [x] 2.5 **Defect 2 fixture and case.** Two real rules, plus a `README.md` (`type: reference`,
      `lifecycle: active`, no `rule:`), a generated `index.md` (`type: index`, `lifecycle: active`, no
      `rule:`) and a superseded note carrying a rule. On the unrepaired tree the block prints
      `(4 active)` and claims *every lifecycle: active note's rule: is in force in this hub*. Both
      cases FAIL.
- [x] 2.6 **Live-registry reproduction, read-only.** Shipped predicate **90**; designed predicate
      **89**; `README.md` the sole difference. Three independent instruments in that deployment
      already agree on 89.

## 3. Repair, and confirm the canaries turn green

- [x] 3.1 `[ RESTRICTED ]` pass 1: a frontmatter marker on a numbered curated document sets
      `classed` instead of emitting `I`. Body-marker path untouched.
- [x] 3.2 `[ CORRECTIONS ]`: three-armed predicate, written as a loop; empty-glob guard; printed line
      rewritten to state the predicate.
- [x] 3.3 `bash tests/test_restricted_lint.sh` → all 15 cases PASS, exit 0.
- [x] 3.4 `bash tests/test_corrections_binding.sh` → all 5 cases PASS, exit 0.

## 4. Prove the positive direction

- [x] 4.1 **A genuinely disclosive record note still has its name blocked.** Case 1 of the same
      suite: `[[casey-example]]`, a `stakeholders/` note marked in frontmatter, on `shareable/` →
      `RESTRICTED IDENTIFIER 'casey-example'`, exit 1. PASS on the repaired tree.
- [x] 4.2 **A numbered name in a subdirectory is still blocked** (case 1f). PASS on both trees.
- [x] 4.3 **A body-marked numbered document's section text is still blocked** (case 1g). PASS.
- [x] 4.4 **A real correction carrying a `rule:` is still counted** — the repaired count of 2 is the
      two notes that carry one, and the live-registry figure of 89 is 89 real rules.
- [x] 4.5 **A single-hub deployment is still unaffected** — the standalone-silence case still passes.

## 5. Sweep for the class, in both cases, and record the findings of none

- [x] 5.1 **Defect 1's class: a check treats a structural name as a disclosive identifier.** Swept
      every instrument that matches a name against a boundary. **Exactly one instance, the one
      repaired.** `[ RESTRICTED ]` is the only check in the repository that decides whether a NAME may
      cross a boundary. Examined and clear: `template/build-indexes.sh` (uses a basename to build an
      index link, and indexes only entity folders, which hold no numbered documents);
      `template/mcp/server.py` (`Path(path).stem` is an identifier on a quarantined surface, not a
      disclosure gate); `components/km-cockpit/km-cockpit.py` (`path.stem` titles a proposal);
      `tests/test_canonical_leakage.sh` (an organization name is disclosive wherever it sits, which is
      the design rather than the class).
- [x] 5.2 **Defect 2's class: a check reads `lifecycle:` as if it meant `binds`.** Swept every use of
      the field in shipped code. **Exactly one instance, the one repaired.** Reading it as currency,
      which is what it means: `is_current` in `template/hub-scan.sh`, `[ CURRENCY ]`, the row filter
      in `template/build-indexes.sh`, and the projection gate in `template/mcp/server.py`.
      `scripts/validate_organization_profile.py` validates the enum. `scripts/validate_rfc_lifecycle.py`
      names an RFC disposition derived from the ledger, not the field.
- [x] 5.3 **One near-neighbour registered rather than repaired.**
      `components/km-cockpit/km-cockpit.py` renders a hub's registry membership in a column it also
      calls `lifecycle` (`"Active" if dirname in initiated else "Not initiated"`). That is a naming
      collision over a different property, not a false predicate: it reads registry membership and
      never the field. Registered here rather than widening this change.

## 6. Ship the change

- [x] 6.1 `km-unrepaired-tree:` re-stated on both edited checks, recording the v1.57 runs.
- [x] 6.2 Draft markings per section, in section bodies: `STANDARD.md` (two subsections and the lead),
      `template/hub-scan.sh` (both comment blocks and both inline arms), and both suites' headers.
- [x] 6.3 `python3 scripts/validate_published_not_draft.py` → PASS.
- [x] 6.4 `python3 tools/km-release-gate.py` → exit 0, `0 discovered check(s) untracked`.
- [x] 6.5 `openspec validate hub-scan-two-defects --strict` → passes.
- [x] 6.6 `git diff --check` clean; explicit-path staging only.

## 7. Out of scope

- [ ] 7.1 **Re-deploying the repaired scan across divergent installed hub copies.** The ledger item
      this answers names two acts and this version is the first alone. Writing into a hub is that
      hub's own act under its own governance, and no dispatched agent may do it. It becomes an estate
      action in the handover.
