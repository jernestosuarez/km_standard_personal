# Tasks

Executed on 2026-08-24 on branch `audit-spec-filename-convention`, off `main` at `1ec46f1`
(published v1.52). The date is derived from the author date of the commit that records this package,
read in that commit's own recorded offset, per the v1.47 rule. `main` is untouched and nothing is
pushed.

Tasks are ordered by dependency: establish whether the cited convention exists, then measure, then
weigh the repair the finding recommends, then disposition. No repair task exists, because the
investigation returned no repair. This change adds no requirement and carries no delta specification,
so there are no requirement references to point at; the reasoning is in `design.md`, Decision 4.

## 1. Find the convention, or establish that it is absent

- [x] 1.1 Read the finding as written rather than as summarised.
      `KM-STANDARD-AUDIT-2026-08-22.md` §F-13: *"The repository guidance requires project-prefixed
      spec and plan filenames to avoid cross-project cache collisions.
      `components/km-cockpit/SPEC.md` is generic and heavily referenced. Recommendation: Rename it to
      a project-specific name such as `KM-COCKPIT-SPEC.md` and update references atomically."* The
      report itself stays ignored and out of every commit.
- [x] 1.2 Read `STANDARD.md` in full, 4717 lines. No filename-form rule of any kind. The one place
      the document rules on naming is §"Currency of generated documents", rule 4, which governs
      dated versus stable names for hub documents and forbids status in a filename. It says nothing
      about prefixes, projects, or caches.
- [x] 1.3 Read the Standard Maintainer contract, `agents/km-hub-builder/SKILL.md`, in full. No
      filename convention.
- [x] 1.4 Read the active deployment profile for this session, which is held in the organization
      overlay rather than in this repository, in full. No filename convention.
- [x] 1.5 Read the organization overlay, `OVERLAY.md`, 1110 lines. No filename convention.
- [x] 1.6 Read `README.md`. No filename convention. Its only mention of the file is the component
      row at line 70.
- [x] 1.7 Establish that no repository guidance file exists to hold such a rule. There is no
      `CONTRIBUTING.md`, no repository-root `AGENTS.md` or `CLAUDE.md`, and no conventions document
      under `docs/`, which holds six architecture documents and a README.
- [x] 1.8 Search the whole tracked tree, 213 files, for the idea rather than for one phrasing:
      `cache safety`, `cache-safety`, `cache collision`, `cross-project cache`, `project-prefixed`,
      `project prefix`, `prefixed`, `naming convention`, `file naming`, `filename convention`,
      case-insensitive. Every `prefix` hit outside the one below is about interpreter install
      prefixes (v1.51 portability) or JSON-LD namespace prefixes (RFC-003). Every `collision` hit is
      about two documents claiming one purpose or about ontology identity, never about filenames.
- [x] 1.9 Record the single hit and what the document holding it is.
      `openspec/changes/audit-remediation-2026-08-22/KM-STANDARD-OPENSPEC-REVIEW.md` line 197, under
      the heading **Builder constraints**: *"7. Use project-prefixed names for specification and
      build-plan documents."* Line 80 lists "Project-prefixed Cockpit specification filename" as
      wave content and line 161 names a proposed capability `spec-cache-safety`. The document's own
      header reads *"KM Standard OpenSpec Review and Dev-Builder Handoff / Reviewed: 2026-08-22 /
      OpenSpec CLI: 1.4.1 / Disposition: Not implementation-ready"*. It is an external review
      addressed to a builder, committed at `72b61ba` as part of the remediation record. It is not
      repository guidance, it was never adopted as a rule, and no instrument reads it.
- [x] 1.10 Check whether the constraint governs the class of file the finding applies it to. The
      review's subject is the restructuring of the OpenSpec change packages, and its "specification
      and build-plan documents" are the artifacts that task would write. It says nothing about
      component contracts.
- [x] 1.11 Check whether the constraint was followed even in its own scope, and whether it could be.
      It was not. The repository carries thirteen delta specifications named `spec.md`, because
      OpenSpec 1.4.1 requires `specs/<capability>/spec.md`, which the CLI's own validation error
      states. A project-prefix rule over specification documents is incompatible with the change
      tooling this repository runs.
- [x] 1.12 Search the estate outside the canonical repository for the convention, in case it lives
      at the deployment tier. Nothing in the Supervisor tier expresses it either.

**Result of section 1: the cited convention does not exist in this repository, and the finding's
premise does not hold.**

## 2. Measure the reference count rather than repeat the adjective

- [x] 2.1 Count occurrences of the literal string `SPEC.md` across tracked files at `1ec46f1`:
      27 total. `template/hub-scan.sh:1177` names `IMPORT-SPEC.md`, a different document, so it is
      excluded. **26 occurrences referring to `components/km-cockpit/SPEC.md`, across six files.**
- [x] 2.2 Break the count down by file: `STANDARD.md` 12, `components/km-cockpit/km-cockpit.py` 5,
      `components/km-cockpit/README.md` 4, `README.md` 2, `tests/test_km_cockpit.sh` 2,
      `openspec/changes/audit-remediation-2026-08-22/proposal.md` 1.
- [x] 2.3 Break the count down by written form, because the form decides which references any check
      would catch. Three resolvable Markdown links (`README.md:70`, `STANDARD.md:3613`,
      `components/km-cockpit/README.md:20`); one code-formatted full path in live prose
      (`STANDARD.md:3536`); nine inside dated version-ledger rows; thirteen in prose and code
      comments that no instrument reads.
- [x] 2.4 Identify the ledger rows precisely, because they are the ones a rename cannot touch:
      v1.24, v1.31, v1.33, v1.34, v1.36, v1.37 and v1.38. Seven rows, nine occurrences.
- [x] 2.5 Test the finding's premise against the tree it describes, by counting tracked basenames.
      `SKILL.md` 24, `README.md` 16, `tasks.md` 13, `spec.md` 13, `proposal.md` 13, `design.md` 12,
      `TEMPLATE.md` 9, `CLAUDE.md` 2, `AGENTS.md` 2, **`SPEC.md` 1.** The named file carries the only
      basename in the repository that does not repeat.
- [x] 2.6 Confirm the one prefixed specification name in the tree is not evidence of a convention.
      `SPEC_km-eval-harness.md` sits at the repository root, where there is no directory to scope it
      and where `DESIGN-RATIONALE_akcp-component-mining.md` and its sibling are named the same way.
      Its own frontmatter describes it as a non-normative proposal spec. Nothing states that its
      naming is a rule, and nothing else in the repository follows it.

## 3. Weigh the repair the finding recommends

- [x] 3.1 Establish what "update references atomically" would actually reach: all 26 occurrences,
      including the nine in seven dated ledger rows.
- [x] 3.2 Hold that against the repository's own published doctrine. v1.45 and v1.50 both rule that a
      dated record corrected to agree with the present is falsified rather than repaired, and both
      repair stale status by adding a dated note beside the record. The recommendation therefore
      forces a choice between falsifying seven ledger rows and leaving nine occurrences naming a file
      no reader can open, which is the F-04 class this remediation published
      `scripts/validate_rfc_references.py` to close.
- [x] 3.3 Consider renaming with seven dated notes appended instead of seven rewrites. Rejected: it
      is a large quantity of published text spent on the spelling of a filename, it creates a new
      maintenance surface, and it buys a property nobody has demonstrated. Recorded in `design.md`,
      Decision 1.
- [x] 3.4 Decide whether a check is warranted, arguing both directions. Recorded in `design.md`,
      Decision 3: no check. It would model an external tool's cache behaviour rather than a property
      of this tree; its exemption list would have to cover 13 `spec.md`, 16 `README.md`, 24
      `SKILL.md` and 9 `TEMPLATE.md` and would converge on tolerating everything, which is the v1.43
      failure mode; and it could make no v1.46 unrepaired-tree declaration, because the condition it
      models has never produced a failure here.

## 4. Disposition and record

- [x] 4.1 Disposition **F-13 as not upheld**. No rename, no reference edit, no check, no version.
- [x] 4.2 Confirm no version is minted, and confirm the reason: nothing in the standard changed, and
      a ledger row is a claim that it did. Recorded in `design.md`, Decision 5.
- [x] 4.3 Name the branch after the change rather than after a version, so that no git object asserts
      a v1.53 that was deliberately not minted. Reported to the owner as a deviation from the
      instructed branch name, with the reason.
- [x] 4.4 Write this package: `proposal.md`, `design.md`, `tasks.md`, and no `specs/` directory.
- [x] 4.5 Record what would reopen the disposition, so that it can be revisited on evidence rather
      than on preference. Recorded in `design.md`, "What would change this disposition".
- [x] 4.6 Record the limits of the disposition: an absence established by search is only as good as
      its terms, and no second actor has looked. Recorded in `design.md`, "Risks and limits".

## 5. Verify and commit

- [x] 5.1 `openspec validate audit-spec-filename-convention --strict` fails with *"Change must have
      at least one delta. No deltas found."* Expected and recorded in `proposal.md` and in
      `design.md`, Decision 4. `audit-licence-honesty-and-record` fails identically for the same
      reason.
- [x] 5.2 `python3 scripts/validate_rfc_references.py` passes. No RFC reference was touched.
- [x] 5.3 `python3 tools/km-release-gate.py` exits 0. Numbers reported to the owner.
- [x] 5.4 Confirm the gate's relative-link walk still resolves every link, including the three
      Markdown links to `components/km-cockpit/SPEC.md` that a rename would have moved. Nothing
      dangles, and nothing dangles because nothing moved.
- [x] 5.5 Leakage, run over the final tree with the canonical instrument, both halves. Counts
      reported to the owner.
- [x] 5.6 `git diff --check` and `git diff --cached --check` clean.
- [x] 5.7 Stage by explicit path. Only the three files of this package are committed.
      `KM-STANDARD-AUDIT-2026-08-22.md` stays ignored and enters no commit. `main` is untouched,
      nothing is pushed, and no tag is created.
- [x] 5.8 Derive the date in the header of this file from the author date of the commit that records
      the package, read in that commit's own recorded offset, in one act.
