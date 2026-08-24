# Design

## Context

F-13 is the only finding in the audit of 2026-08-22 that nobody had checked. It is also the only one
whose repair is a rename, which is the cheapest kind of change to make and one of the most expensive
to reverse once a fork has taken a copy. Three of the audit's findings have already failed
verification during this remediation, including two overcounts and one omission on F-09 alone, so the
first act here is measurement.

The finding asserts a fact about this repository. Everything else in it follows from that fact.

```
claim        "The repository guidance requires project-prefixed spec and plan filenames
              to avoid cross-project cache collisions."

searched     STANDARD.md            4717 lines, read in full   -> no such rule
             README.md                                          -> no such rule
             agents/km-hub-builder/SKILL.md (maintainer contract)-> no such rule
             the active deployment profile, held in the overlay  -> no such rule
             the organization overlay, OVERLAY.md, 1110 lines    -> no such rule
             scripts/, tools/, tests/, .github/workflows/        -> no check reads a filename form
             the whole tracked tree, 213 files

             grep -i "cache safety|cache-safety|cache collision|cross-project cache|
                      project-prefixed|project prefix|naming convention|file naming"

found        openspec/changes/audit-remediation-2026-08-22/KM-STANDARD-OPENSPEC-REVIEW.md:197
             "7. Use project-prefixed names for specification and build-plan documents."
             and the same idea at :80 and :161, in the same document

what that    "# KM Standard OpenSpec Review and Dev-Builder Handoff
document is   Reviewed: 2026-08-22   OpenSpec CLI: 1.4.1
              Disposition: Not implementation-ready; restructure the OpenSpec artifacts
              before executing remediation tasks."
             committed at 72b61ba as part of the remediation record

there is     no CONTRIBUTING.md, no repository-root AGENTS.md or CLAUDE.md,
no other      no .cursor rules, no docs/ guidance file. `docs/` holds six architecture
guidance      documents and no conventions page.
```

The one hit is an external review addressed to a builder, listed under a heading called **Builder
constraints**, alongside instructions like *"Do not publish, push, merge, tag, or choose a licence."*
Those are constraints on one task, not standing rules of the repository, and the review's own subject
is the restructuring of the OpenSpec change packages, so its "specification and build-plan documents"
are the `proposal.md` / `design.md` / `tasks.md` / `spec.md` artifacts that task would write. The
constraint was not followed even there, and could not have been: OpenSpec 1.4.1 requires a delta
specification at `specs/<capability>/spec.md`, and the repository carries thirteen files under that
exact generic name because the tool mandates it.

## Goals / Non-Goals

**Goals:**

- Establish whether the cited convention exists in this repository, by search rather than by
  assumption, and quote it if it does.
- Measure the reference count instead of repeating the audit's adjective.
- Determine what the recommended repair would actually cost, against the rules this repository
  already publishes.
- Record the disposition where a fork's reader will meet it.
- Say plainly which parts of this reasoning would change if the premise were later made true.

**Non-Goals:**

- Renaming `components/km-cockpit/SPEC.md`. See Decision 1.
- Writing a project-prefix rule into the standard so that the finding becomes correct. See
  Decision 1.
- Adding a check over filename form. See Decision 3.
- Producing a version. See Decision 5.
- Editing the external review, or any of the seven dated ledger rows that name the file.

## Decision 1: the convention does not exist here, so nothing is renamed

**Decision.** F-13 is dispositioned as **not upheld**. `components/km-cockpit/SPEC.md` keeps its
name.

**Why.** A rename made to satisfy a rule the repository does not hold is a change with no authority
behind it. The maintainer contract is explicit that a standard changes only on a direct owner
instruction, an approved promotion handover, or an owner-requested repair of a **demonstrated**
defect, and that evidence is not authority. An external report asserting that a rule exists is
evidence about the report. The rule was looked for and is not there.

There is a second and independent reason, and it would stand even if the convention were real. The
repair as recommended, updating every reference atomically, reaches seven dated version-ledger rows.
The repository rules twice, at v1.45 and again at v1.50, that a dated record corrected to agree with
the present is falsified rather than repaired, and it repairs stale status by adding a dated note
beside the record rather than by rewriting it. So the recommendation offers only two outcomes: seven
falsified ledger rows, or nine occurrences in published text naming a file that no longer exists,
which is precisely the F-04 class this remediation published `scripts/validate_rfc_references.py`
to close. Neither is an improvement on a filename that has never caused a failure.

**What was considered and rejected.** Renaming and leaving the ledger rows alone with seven dated
notes appended. It is internally consistent with the repository's doctrine and it is a great deal of
published text spent on the spelling of a filename, with the notes themselves becoming a new
maintenance surface. The cost is real and the benefit is a property nobody has demonstrated.

## Decision 2: the count, measured

**Decision.** "Heavily referenced" is replaced by numbers.

```
occurrences of the literal string SPEC.md, tracked files, at main 1ec46f1

  STANDARD.md                                                   12
  components/km-cockpit/km-cockpit.py                            5
  components/km-cockpit/README.md                                4
  README.md                                                      2
  tests/test_km_cockpit.sh                                       2
  openspec/changes/audit-remediation-2026-08-22/proposal.md       1
  template/hub-scan.sh                                            1   <- IMPORT-SPEC.md,
                                                                          a different document,
                                                                          not a reference to this one
                                                              ----
  referring to components/km-cockpit/SPEC.md                     26   across 6 files

by written form

  resolvable Markdown links                                       3   README.md:70,
                                                                      STANDARD.md:3613,
                                                                      components/km-cockpit/README.md:20
  code-formatted full path, live prose                            1   STANDARD.md:3536
  inside dated version-ledger rows                                9   v1.24, v1.31, v1.33, v1.34,
                                                                      v1.36, v1.37, v1.38  (7 rows)
  prose and code comments no instrument reads                    13
```

Two things follow. The three Markdown links are the only occurrences any check would catch if the
file moved, through the release gate's relative-link walk. And nine of the twenty-six, more than a
third, sit in the one class of text this repository does not rewrite.

**The premise is also contradicted by the tree.** If generic specification filenames were a hazard
here, the hazard would be visible in the basenames that repeat:

```
tracked basenames, most frequent first

  SKILL.md      24        README.md     16        tasks.md      13
  spec.md       13        proposal.md   13        design.md     12
  TEMPLATE.md    9        CLAUDE.md      2        AGENTS.md      2
  SPEC.md        1
```

`SPEC.md` is unique in the repository. Thirteen files are literally named `spec.md`, because that is
what OpenSpec requires of a delta specification, and the repository could not adopt the cited
convention for its specification documents without breaking its own change tooling. The finding names
the least collision-prone generic specification name in the tree.

## Decision 3: no check is added, and the argument runs both ways

**Decision.** No instrument over filename form is written.

**The case for one.** If the convention were real and mechanical, it would be exactly the kind of
rule this repository prefers to check rather than state: a filename is a property of the tree, a
prefix is a string test, and the repository's own doctrine says a rule only binds when something
deterministic checks it. That argument is sound in form. It fails on its premise, which is Decision 1.

**The case against, and it holds even if the premise were granted.** Three reasons.

*It would model an external tool's behaviour, not a property of this tree.* Cross-project cache
collision is a claim about some consumer that keys by basename. No such consumer exists in this
repository, and nothing in the tree can represent whether one exists elsewhere. An instrument built
over that models whether a filename was edited rather than whether any collision is possible, which
is the failure mode the repository already names for judgement claims at v1.48.

*Its tolerance list would converge on tolerating everything.* The check would fail immediately on the
thirteen `spec.md` files OpenSpec mandates, on sixteen `README.md`, on twenty-four `SKILL.md` and on
nine `TEMPLATE.md`. Exempting each is the pattern v1.43 names as fatal to a check: a tolerance list
that widens to fit whatever the tree happens to contain converges on tolerating everything, which is
a check that cannot fail. After the exemptions the instrument would guard one file, and a check that
guards one file is that file's name written twice.

*It would have no unrepaired-tree declaration to make.* Since v1.46, a check must record what it
found when run against the tree it was written to catch. There is no such tree here. The condition
the check would model has never produced a failure in this repository, so the declaration would have
to read `none`, and a check born with nothing to plead is a check nobody has shown to work.

## Decision 4: no delta specification, and the validator's failure is the honest result

**Decision.** This package carries `proposal.md`, `design.md` and `tasks.md` and no `specs/`
directory. `openspec validate audit-spec-filename-convention --strict` fails with *"Change must have
at least one delta. No deltas found."*

**Why that is correct rather than an omission.** A delta specification states a requirement the
standard is adding or changing. This change adds none. To write one, the package would have to
introduce the cache-safety requirement into the standard, so that the rename would then conform to a
rule the repository holds. That is inventing the authority the investigation was asked to look for,
and it would convert a disproved premise into a published obligation binding every deployment,
because a validator wanted a file to read.

The precedent is `audit-licence-honesty-and-record`, which carries no delta for the same reason and
fails the same validation identically. Both are recorded here rather than hidden, so a reader running
the validator over the change directory finds the two known failures explained rather than
mysterious.

## Decision 5: no version is minted

**Decision.** There is no v1.53 for F-13.

**Why.** A version row is a claim that the standard changed. Nothing in the standard changed. Minting
a version whose row said "investigated a finding and made no change" would put a number on a
non-event, and every deployment that reads the ledger to decide whether to re-pin would spend
attention on it. The disposition belongs in this package and in whatever record the owner keeps of
the audit, which is where a finding that was examined and not upheld should live.

The branch this package was written on is named after the change, not after a version, for the same
reason: a branch called `v1.53-...` would assert a version that was deliberately not minted.

## What would change this disposition

Stated so that a later maintainer does not have to re-derive it, and so that the disposition can be
reopened on evidence rather than on preference:

1. **The owner adopts the convention.** If the deployment owner rules that specification and plan
   documents in this repository carry a project prefix, the rule goes into `STANDARD.md` first, with
   its reason, its scope, and an honest statement of which existing files it exempts and why. The
   rename then follows from a published rule, and the ledger rows are handled by dated notes under
   the v1.45 procedure rather than by rewriting.
2. **A real consumer is demonstrated.** If some tool this repository or a fork actually uses is shown
   to key documents by basename and to collide across projects, that is a demonstrated defect, and
   the repair is authorised as one. The demonstration is the thing that is missing today, not the
   argument.
3. **A second file named `SPEC.md` appears.** The uniqueness recorded in Decision 2 is a measurement
   of the tree at `1ec46f1`, not a property of it. A second `SPEC.md` would not make the cited
   convention real, and it would make the disambiguation question worth asking on its own merits.

## Risks and limits

- **This disposition rests on a search, and a search proves absence only as well as its terms.** The
  terms are recorded in the Context block above and the tasks file records what was run, so the claim
  is checkable rather than asserted. If the convention exists somewhere under wording none of those
  terms reach, this finding is wrongly dispositioned and the record above is what a later reader uses
  to find that out.
- **Nobody other than the author has looked.** This package is an adversarial pass over an external
  report, performed by a single agent. The minimum viable independence is a second actor against the
  specific class, and it is not present here, which is the same limit the release gate states about
  itself and it is stated rather than deferred.
- **This says nothing about the content of `components/km-cockpit/SPEC.md`.** The finding is about the
  filename, and so is this disposition. Whether the specification is current, correct, or complete
  against the component beside it is a different question that no part of this investigation touched.
