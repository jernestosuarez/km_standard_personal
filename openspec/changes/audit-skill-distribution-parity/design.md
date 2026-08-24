# Design

## Context

Seven skills ship in three locations each: `skills/<slug>/SKILL.md`, which the README presents as the
distributable per-hub skill, and two runtime mirrors under `template/.claude/skills/<slug>/` and
`template/.agents/skills/<slug>/`. Two further skills, `km-init` and `km-supervise`, ship in the
canonical location only, because they are workspace-level rather than per-hub. Nothing in this
repository compares the bodies of the duplicated seven.

Measured against `main` at `10d7950`, published v1.42, byte for byte:

| Slug | root vs `.claude` | `.claude` vs `.agents` | Classification |
|---|---|---|---|
| `km-brief` | 19 lines present in the mirror and absent from the root | identical, same MD5 | **Drift** |
| `km-gather` | identical | identical | In parity |
| `km-handover` | identical | identical | In parity |
| `km-intake` | identical | identical | In parity |
| `km-propose` | identical | 2 lines, `CLAUDE.md` against `AGENTS.md` | Documented substitution |
| `km-publish` | identical | identical | In parity |
| `km-start` | identical | identical | In parity |

The `km-brief` divergence is one contiguous block, inserted in the mirrors after the horizontal rule
that closes the read-only-query paragraph, 954 bytes across 19 lines. The three copies carry
byte-identical frontmatter, and the two mirrors are byte-identical to each other. So the whole of the
finding is: one block, present in both mirrors, absent from the advertised copy.

The block carries three instructions. Read the index first, because each entity folder's `index.md`
lists active notes only and navigating by it avoids loading every note. Include only
`lifecycle: active` and exclude `superseded` and `retired`, because a retired fact was true once and
surfacing it in a memo presents it as true now, with the escape hatch that a genuinely needed retired
fact is stated and dated. Honour `confidence`, saying so when an artifact rests on low-confidence
facts rather than laundering them into assertions by omission.

The `km-propose` difference is not drift. It is the one designed per-runtime difference v1.32 already
named: each runtime tree names its own harness instruction file. `[ PROJECTION ]` in
`template/hub-scan.sh` already tolerates exactly that substitution, and exactly that one, when it
compares the two installed trees inside a deployed hub.

That last point is the shape of the gap. A deployed hub has a body-level parity check over its two
runtime trees. The standard's own repository has a body-level parity check over nothing, and its
frontmatter-level check does not reach the root copy's body at all. The advertised copy is the one
surface with no comparison behind it, which is why it is the one that drifted.

## Goals / Non-Goals

**Goals:**

- Bring the advertised copy up to the safer body, closing F-05 and the drift v1.27 deferred.
- Name a canonical copy in the standard, so "which one is right" has a written answer.
- Gate the duplication at the body level, with the tolerance list documented before it is tolerated.
- Prove the gate against the real divergence, not only against a synthetic likeness of it.
- Sweep every other multi-location skill for the same class and record the result either way.

**Non-Goals:**

- Generating the mirrors from the canonical copy. See Decision 3.
- Reaching skills a deployment writes locally. That limit is v1.27's and stands unchanged.
- De-duplicating the three trees into one. The three locations exist because three runtimes read
  three paths, and collapsing them is a distribution change well beyond this finding.
- Repairing anything in `km-brief` other than the missing block. This change closes a parity defect
  and is not an occasion to rewrite a skill.

## Decisions

### Decision 1: the safer body is canonical, and the root is the canonical location

Two questions hide inside "establish one canonical source", and they have different answers.

**Which location is canonical?** `skills/<slug>/SKILL.md`. It is the location the README advertises,
the location `tests/test_skill_frontmatter.sh` already treats as the reference when it compares
frontmatter, and the location a fork or an adopter reaches first. Naming any other location canonical
would leave the advertised copy derived from something a reader has to go and find.

**Which content is canonical for this repair?** The mirrors'. The root is missing a protection, the
mirrors carry it, and the repair direction follows the content and not the location. Making the
mirrors match the root would have produced three copies in perfect parity and three deployments able
to publish retired facts, which is a parity check that certifies the wrong thing.

Rejected: making the root canonical by content on the grounds that it is canonical by location. That
reasoning is what makes a parity gate dangerous. Parity is a property of a set of copies and says
nothing about whether the set is right, so the direction of repair is decided by reading the content,
every time, and the standard says so.

### Decision 2: a companion check, not an extension of the frontmatter check

**Chosen**: a new `tests/test_skill_distribution_parity.sh`, leaving `tests/test_skill_frontmatter.sh`
as it is.

Three reasons, in order of weight.

1. **They model different classes and should fail separately.** The frontmatter check models
   discoverability: a runtime holds the frontmatter before invocation and decides on it. The parity
   check models distribution: the copy a deployment installs is the skill it runs. When one fails, a
   maintainer should learn which class broke from the name of the failing check, and folding both
   into one file makes every failure a lookup.

2. **The parity check must run against an arbitrary tree, and the frontmatter check is not built to.**
   The strongest evidence required here is a run against the unrepaired tree. That means the checker
   takes a root, and the harness materialises the pre-repair tree from git and points it there.
   `check_tree` in the frontmatter file already takes a root for its canaries, but its mirror-parity
   section is written against a fixed `$ROOT` and would have to be restructured. Restructuring a
   passing v1.27 check in a change about a different defect is the widening this standard warns
   against.

3. **The parity check owes a coverage line the frontmatter check does not have.** It reports slugs
   found, pairs compared and substitutions applied. Merging the two would either give one file two
   coverage lines or blend two coverage claims into one, and a blended coverage claim is how a check
   comes to certify a class it did not examine.

Rejected: extending `test_skill_frontmatter.sh`. It is the smaller diff and it is the wrong seam. The
cost of the choice is stated: two files now walk the same three trees, and a future change to the
tree layout has to touch both.

### Decision 3: the gate compares and never writes

The check reports divergence and repairs nothing. A generator that regenerated the mirrors from the
canonical copy would, applied to this very tree before the repair, have overwritten the two safe
mirrors with the unsafe root and reported success. Direction of repair is a judgement about content,
and the standard already holds this position for fact projection: nothing repairs drift, the report
prints both sides, and the owner decides.

### Decision 4: exactly one tolerated substitution, and it is the one already documented

The check normalises `CLAUDE.md` and `AGENTS.md` to a single token before comparing, and normalises
nothing else. This is not a new tolerance. It is the substitution v1.32 designed, wrote into the
standard, and implemented in `template/hub-scan.sh`, and reusing it means a deployed hub and the
standard's own repository tolerate the same one difference rather than two drifting lists.

The rule attached to it matters more than the substitution: a difference is documented in the
standard first and tolerated by the check second. A tolerance list that grows to accommodate whatever
the tree happens to contain converges on tolerating everything, which is a check that cannot fail.

### Decision 5: the governed body is what is compared, and the frontmatter is left to v1.27's check

The parity check delimits the body as everything after the closing frontmatter terminator and
compares that. Frontmatter parity is already enforced, byte for byte, by
`tests/test_skill_frontmatter.sh`, and comparing it twice would mean two checks failing for one
cause. Delimiting the body also forces the refusal in Decision 6: a copy with no terminator has no
body the check can identify, and it says so instead of comparing whatever it found.

### Decision 6: refuse rather than pass on anything unevaluable

The check exits with a refusal, and no parity verdict, when a copy is unreadable, when a copy has no
frontmatter terminator, when a mirror tree holds a slug the canonical tree does not, or when it found
no slug at all. The last case is the one that matters most: a parity check that walks an empty or
mislocated tree and reports success looks exactly like a clean tree, and this repository has already
recorded that failure shape twice, in the leakage guard's inert-boundary refusal and in the
projection block's refusal on an unreadable home of record.

## Risks / Trade-offs

- **A parity gate can be read as a safety gate.** It proves the copies agree, never that they are
  right. Mitigated by Decision 1, which puts the direction of repair in the standard as a judgement
  about content, and by stating the limit in the section itself.
- **Two checks now walk the same three trees.** A change to the distribution layout touches both.
  Accepted, per Decision 2.
- **The tolerated substitution is a real hole, by construction.** A skill whose bodies genuinely
  differ only in the harness instruction-file name is indistinguishable from one where that
  difference is drift. It is one token wide, it is the same hole `[ PROJECTION ]` already carries,
  and widening it is a documented act.
- **Proving both directions proves the check fires on the class it models, never that it models the
  right class.** The run against the unrepaired tree narrows this further than a synthetic canary
  can, because the input is the defect itself, and it does not close it.
- **Hubs already deployed do not inherit the repair by upgrading the standard.** An installed
  `km-brief` copy is backfilled as an adoption act under the hub's own governance, exactly as v1.27's
  frontmatter fix was. Stated in the version row so no deployment assumes otherwise.

## Migration Plan

1. Repair `skills/km-brief/SKILL.md` by inserting the block verbatim from the mirror, at the position
   the mirrors place it.
2. Add the companion check and its canaries.
3. Graft the canonical-copy naming and the parity obligation into the standard's existing skill-file
   section, marked for v1.43 while drafted.
4. Verify: the new check, the full suite, `scripts/validate_published_not_draft.py`, `git diff --check`.
5. Adoption: a deployment refreshes its installed `km-brief` under its own governance. Rollback is
   the removal of the block, which restores the defect and is therefore not a rollback anyone wants.

## Open Questions

- Should the canonical copy and the mirrors eventually become one file with a distribution step?
  That is a change to how the standard is packaged, it touches every adopter's install path, and it
  is not answered here.
- The sweep covers skills. Other material is duplicated across the trees, notably the reader
  scaffold's two instruction mirrors, which v1.41 documented as differing by a mirror note. Whether
  the parity question should be raised from skills to every duplicated shipped file belongs with the
  release gate, F-06, and not with this repair.
