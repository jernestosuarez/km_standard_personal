## Why

The same skill ships in three places in this repository, and one of the three is weaker than the
other two. `skills/km-brief/SKILL.md` is 109 lines. `template/.claude/skills/km-brief/SKILL.md` and
`template/.agents/skills/km-brief/SKILL.md` are 128 lines each. The 19 lines the root copy lacks are
the governance block that tells the skill to navigate by each entity folder's `index.md`, to include
only `lifecycle: active` entities and exclude `superseded` and `retired`, and to say so when an
artifact rests on low-confidence facts.

The root copy is the one the README presents as the distributable per-hub skill. So the copy a
deployment is invited to install is the copy that can surface a retired or superseded fact in a memo
and present it as true now. A retired fact was true once, which is exactly why publishing it reads as
current rather than as obviously wrong.

This is audit finding F-05. It is not newly discovered: v1.27's own version row recorded the drift,
named it pre-existing, and deliberately deferred the repair so that v1.27 would add frontmatter and
nothing else. The same row states that the mirror-parity check v1.27 shipped covers frontmatter only.
The deferral was honest and the gate it left open is now several published versions old, and the
owner is about to cut an external fork from a tag, which would carry the weaker copy outward under
the repository's own recommendation.

The class of the finding is wider than the one file: a procedure duplicated across locations with no
gate on the duplication. The gate is the change, and `km-brief` is the instance that proves it was
needed.

## What Changes

- The root distribution copy of `km-brief` is brought up to the safer body its runtime mirrors
  already carry. No mirror is weakened to match the root.
- `skills/<slug>/SKILL.md` is named the canonical copy of every skill this standard ships, and the
  two runtime trees are named as mirrors of it. The naming is written into the standard rather than
  left as a convention a reader has to infer from the README.
- A new check, `tests/test_skill_distribution_parity.sh`, compares the **governed instruction body**
  of every skill shipped in more than one location, not the frontmatter alone. It permits exactly one
  documented per-runtime substitution, the harness instruction-file name, which is the same single
  substitution `[ PROJECTION ]` in `template/hub-scan.sh` already tolerates for a deployed hub.
- The check **fails closed**: a copy it cannot read, a copy with no frontmatter terminator, an empty
  slug set, or a mirror with no canonical copy is a refusal with no verdict, never a pass.
- The check states its coverage on a passing run: slugs found, pairs compared, and substitutions
  applied, so a recorded pass that scanned nothing is void rather than clean.
- The check is proved in both directions and against the unrepaired tree, where it names the real
  19-line divergence rather than a synthetic likeness of it.
- Every other skill shipped in more than one location is swept for the same class, and the result is
  recorded whether or not it finds anything.
- Not **BREAKING**. A deployment that installed the root copy gains instructions it should have had,
  and a deployment that installed either mirror is unchanged.

## Capabilities

### New Capabilities

- `skill-distribution-parity`: what it means for a skill shipped in more than one location to be the
  same skill in each, which copy is canonical, what may legitimately differ between copies, and what
  the parity gate must compare and must refuse.

### Modified Capabilities

None. The repository carries no base capability specifications under `openspec/specs/`, so the
capability is introduced as `ADDED`.

## Impact

- **Affected material**: `skills/km-brief/SKILL.md`, repaired; the skill-file section of
  `STANDARD.md`, where the canonical copy is named and the parity obligation is grafted into the
  section that already owns skill-file conformance; and the test suite, gaining one companion check.
- **Affected deployments**: any deployment that installed the root `km-brief` copy. It gains the
  index-first, lifecycle-filter and confidence instructions on adoption. No hub content changes, and
  no deployment loses a capability.
- **Not in scope**: generating the mirrors from the canonical copy at build time. The gate compares
  and does not write. A generator that overwrote a mirror would have repaired this defect in the
  wrong direction had the root copy been the newer one, and the standard's doctrine on drift is that
  the instrument reports and the owner decides.
- **Not in scope**: skills a deployment writes locally. Those remain reached by no check in this
  repository, as v1.27 already stated, and by `[ PROJECTION ]` in a deployed hub for the mirror half.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
