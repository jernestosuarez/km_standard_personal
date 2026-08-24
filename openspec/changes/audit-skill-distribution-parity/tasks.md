# Tasks

Executed 2026-08-23 on branch `v1.43-skill-distribution-parity`. Tasks are ordered by dependency: measure the
divergence before naming it, decide the direction of repair before repairing, build the gate, prove
it against the defect it was written for, sweep the class, then record.

Requirement references point at `specs/skill-distribution-parity/spec.md` (SDP).

## 1. Measure before acting

- [x] 1.1 Enumerate every skill shipped in more than one location, and the locations. Do not assume
      the audit's list.
- [x] 1.2 Diff all three copies of every such slug, both directions, and record every semantic
      difference rather than only the one the finding names. (SDP: same governed body in every copy)
- [x] 1.3 Confirm the frontmatter of the three `km-brief` copies is identical, so the finding is a
      body defect and the v1.27 check was not silently broken as well.
- [x] 1.4 Confirm the two mirrors are identical to each other, so the divergence is root against
      mirrors and not three-way.
- [x] 1.5 Classify each difference found: drift, or a per-runtime substitution the standard already
      documents. (SDP: permitted differences are documented before they are permitted)

## 2. Decide the direction of repair

- [x] 2.1 Name the canonical location and record why. (SDP: one copy is canonical)
- [x] 2.2 Decide which content is canonical for this repair by reading it, not by inheriting the
      location's authority. The safer body wins. (SDP: the advertised copy is never the weaker one)
- [x] 2.3 State explicitly that no mirror is weakened to match the root.

## 3. Repair the advertised copy

- [x] 3.1 Insert the missing block into `skills/km-brief/SKILL.md`, verbatim from the mirror, at the
      position the mirrors place it.
- [x] 3.2 Confirm the three copies are now equal on the governed body.
- [x] 3.3 Confirm nothing else in the file changed.

## 4. Build the gate

- [x] 4.1 Add `tests/test_skill_distribution_parity.sh`, comparing the governed body of every copy of
      every multi-location slug. (SDP: compares the governed body and not the frontmatter alone)
- [x] 4.2 Delimit the governed body at the closing frontmatter terminator, leaving frontmatter parity
      to the v1.27 check. (SDP)
- [x] 4.3 Normalise exactly one substitution, the harness instruction-file name, reusing the rule
      `[ PROJECTION ]` already applies in a deployed hub. Normalise nothing else. (SDP: permitted
      differences are documented before they are permitted)
- [x] 4.4 Make the check take a root, so it can be pointed at a tree other than the working one.
- [x] 4.5 Fail closed on an unreadable copy, a copy with no frontmatter terminator, a mirror with no
      canonical copy behind it, and an empty slug set. Refuse with no verdict, never pass. (SDP:
      fails closed when it cannot read a copy)
- [x] 4.6 State coverage on a passing run: slugs found, pairs compared, substitutions applied. (SDP:
      states its coverage on a passing run)

## 5. Prove both directions, and prove it against the real defect

- [x] 5.1 The repaired tree passes. (SDP)
- [x] 5.2 A synthetic divergence in a mirror body is caught and the slug named. (SDP: proved against
      the divergence it was written for)
- [x] 5.3 A synthetic divergence in the canonical body is caught, so the check is not one-directional.
- [x] 5.4 A documented per-runtime substitution does not fire, proved on the real `km-propose` copies
      and on a synthetic fixture. (SDP: copies differ only by a documented substitution)
- [x] 5.5 An undocumented difference beside a documented one still fires, so normalisation does not
      swallow the drift next to it.
- [x] 5.6 Each refusal case of 4.5 refuses with no verdict rather than passing.
- [x] 5.7 **Run the check against the unrepaired tree**, materialised from git rather than
      hand-built, and confirm it reports drift and names `km-brief`. This is the strongest evidence
      available that the check detects the defect it was written for. (SDP: runs against the
      unrepaired tree)
- [x] 5.8 Confirm the check does not pass on the unrepaired tree, so 5.7 is not a report printed
      beside a green verdict.

## 6. Sweep the class

- [x] 6.1 Run the gate over every multi-location skill and record which are in parity and which are
      not, including a finding of none.
- [x] 6.2 For any further divergence found: repair it if it is this defect, register it with its
      reason if it is a different one. Do not widen this change to carry a different defect.
- [x] 6.3 Record the single-location skills and why they are out of the gate's reach.

## 7. Record

- [x] 7.1 Graft the canonical-copy naming and the parity obligation into the standard's existing
      skill-file section. Do not create a new top-level section to avoid understanding the structure.
- [x] 7.2 Mark the new material for v1.43 while it is drafted, per the ritual v1.42 amended.
- [x] 7.3 Write the v1.43 version row: cite F-05, name the safety consequence plainly, and record
      that this closes the drift v1.27 deferred.
- [x] 7.4 Flip the header and the lead to v1.43 drafted-unpublished, preserving the published v1.42,
      v1.41 and v1.40 descriptions word for word.
- [x] 7.5 State the limits: parity proves the copies agree and never that they are right; the
      tolerated substitution is one token wide by construction; locally written skills are still
      reached by no check here.

## 8. Verification

- [x] 8.1 `openspec validate audit-skill-distribution-parity --strict` passes.
- [x] 8.2 The new check passes on the repaired tree with its coverage line stated.
- [x] 8.3 Full suite green (16 shell suites plus the Python profile suite).
- [x] 8.4 `python3 scripts/validate_published_not_draft.py` passes, per step 4 of the ritual.
- [x] 8.5 `git diff --check` clean.
- [ ] 8.6 Leakage guard: not run here. It is the steward tier's to run.
- [x] 8.7 Stage by explicit path. Preserve the pre-existing `.gitignore` modification.
- [x] 8.8 Did not push, did not tag, did not merge. Publication is the owner's decision.
