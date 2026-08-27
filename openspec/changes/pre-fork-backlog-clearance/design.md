# Design: pre-fork-backlog-clearance (v1.63)

## 1. The resolved-dispute split, and why frontmatter decides it

The standard's default end state for a dispute is capture-the-reasoning-then-delete, and that
default stands. What the reference deployment demonstrated is a second lawful shape the check
could not see: an owner answer applied under a committed directive, the resolution written into
the dispute file, the original dispute retained below it under retract-in-place, and the file
kept as the record of the adjudication. The check keyed on filename presence alone, so the
retained record read as an open dispute on every scan.

The predicate reads **OKF frontmatter `lifecycle:`**, through the scan's own `fm_field`, because
frontmatter is the layer every other lifecycle judgement in the scan already reads; a body
`Status:` line was rejected as the predicate since the body is precisely what retract-in-place
preserves in its original, open-sounding form. Only the exact value `resolved` counts. The
fail-closed direction is deliberate and is the standard's own rule for checks that report by
absence: no frontmatter, any other value, or an unreadable file stays ACTIVE, and the existing
blocked-on branch already names the unreadable case in its message. The two states render
differently (`! Active disputes:` with an advisory versus `RESOLVED (retained record):` with
none), which is the two-states rule the raising deployment cited.

## 2. The docs-site surface: genericisation and the pass-1/pass-2 symmetry

The estate-local line (blob `57563716` in two installed copies) added one `find` to pass 2 with a
comment naming the deployment's own portal. The canonical absorption keeps the mechanism and
drops every deployment noun: the convention is the path shape `working-docs/*-docs-site/docs/`,
and the comment explains the class (a site source that publishes outward when it deploys) rather
than any instance of it.

One deliberate departure from the estate copy: pass 1 now **excludes** the docs-site tree, as it
already excludes `shareable/` and `changes/`. The estate copy left the pages in the note walk, so
a page carrying restricted content would both contribute evidence records and be a surface —
double-reporting against itself. A surface is scanned as a surface, never collected as evidence
against itself; a restricted marker on a page is still an error through the pass-2 marker check.

The boundary is pinned in both directions (cases 1j and 1k): the rest of `working-docs/` stays a
non-surface, because an internal draft may quote what a published page may not, and widening the
surface to the whole folder would redden every hub that drafts about its own restricted material.
The stated limit: the naming convention is the contract, and a site source living elsewhere is
not scanned.

## 3. The manifest ruling: retire, not verify

The alternative ruling — keep the manifest and ship the verification check the machinery tier
designed — was weighed and refused on the standard's own doctrine. The manifest duplicates
coverage git already provides (Rule 3), it is the hand-maintained-memory artifact class the
standard names as the one that rots, and the measured state (59 of 94 hashes wrong, the
best-maintained copy belonging to the hub that raised the question) shows the convention failing
under the most attentive maintenance it gets. A verifier would convert a false assurance into a
permanently red advisory across seven hubs, all to keep a baseline the integrity model declares
redundant in its first paragraph. Retirement removes the false assurance at the root.

The lingering-copy advisory is deliberately not an error: a legacy hub must not go red over a
file the ruling itself retired, and an error nobody can clear in-session is a gate that gets
switched off. The scaffold sets keep the filename after migration too — a list entry matching
nothing costs nothing, and a fork's legacy hub may arrive carrying one.

## 4. The skill-tree ruling: authority is outside the trees

The two divergence shapes were already errors; the missing half was the repair direction, and the
observed wrong repair (level the pair at whichever copy is newer) closes the finding while
leaving both trees stale. The ruling places authority outside the installed trees entirely: the
pinned canonical for shipped skills (v1.43's canonical-copy rule reaching the deployed hub), the
governed creating act for hub-local ones, with v1.43's obligation 4 (raise to the stronger copy)
kept as an unmechanised judgement. The scan cannot know which slugs are shipped — it has no view
of the canonical repository — so the ruling rides in the finding text rather than in a new
predicate, and the enforcement that is mechanical (both shapes are errors) is unchanged. The
one-tree-only arm had been live since v1.32 with no case; under the standard's own dead-arm rule
an untested arm is indistinguishable from a working one, so case 14n pins it, and its 14n2 half
(the ruling text) is the direction that is red on the unrepaired tree.

## 5. The two no-change verdicts

**km-init:** the canonical skill has carried the merge and withdrawal modes since `77fd1f2`
(v1.35 draft), with draft markings cleared at v1.42. The reporting deployment's installed copy is
a pre-v1.35 generation. A canonical edit cannot fix a stale installed copy, and workspace-level
skills have no mirror-parity check by design (v1.43 states that limit); the adoption handover
carries the refresh.

**working-docs/CURRENCY:** the canonical README and the canonical check agree, and have since the
repository's first commit. The reported contradiction is real in the deployed copy (verified: the
reporting hub's README is the pre-v1.12 text, "not monitored... archived here for reference") and
is repaired by refreshing the README, not the instrument. The reporting agent's recommendation —
exclude `working-docs/` from `[ CURRENCY ]` — was assessed and refused: it would reverse the
v1.12 correction, which repaired exactly the folder-scoping error, and the currency rule's
motivating failure was a working-docs draft. The README's "One check does read them" undercount
becomes "Two checks" with the docs-site paragraph beside it.

## 6. Evidence handling

Estate ledger items, agent reports and installed-copy comparisons were read as evidence about the
canonical tree, never as authority over it; every claim acted on was verified against the
canonical tree or reproduced as a failing case (the red commit `bdab753`). The estate blob was
read with `git cat-file -p` against a type-check control; installed-copy divergence was measured
by line count, content search with a known-positive control, and digest comparison.
