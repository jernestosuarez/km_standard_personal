# Design: audit-reviewer-fifth-pass (v1.61 draft)

**Nothing here binds until this version's own owner push.**

## The paragraph this pass demands, and it is about process rather than code

Five passes. The reviewer has now found, in order: **wrong behaviour** (passes 1–2), **controls
weaker than their claims** (passes 3–4), and now **a defect we found ourselves and chose to disclose
rather than fix, plus a claim we knew was false and published anyway** (pass 5). The first two
categories are engineering. The third is not, and pretending otherwise is how it repeats.

**The rule for registering versus repairing.** A maintainer who finds a defect while repairing
another one has three options and only two of them are legitimate. **Repair it** — the default, and
the answer whenever the repair is reachable in the change already open. **Refer it** — legitimate
only when the thing found is genuinely not the maintainer's to decide: a *policy question* about what
these artifacts may contain, rather than a defect in how an instrument reads its input. A referral is
discharged by putting the question to the owner, never by writing it in a comment where it will be
read as handled. **Defer it** — legitimate only when four conditions hold *together*: the defect is
**bounded and measured** rather than estimated; its **error direction** is stated and is a false
failure rather than a false pass; repairing it inside the current change would genuinely entangle two
repairs, so that a reader could not tell which change a regression came from; and it is deferred **to
a named version**, not to a reader. A registration that meets none of those is a defect shipped with
a note attached, and the note is what makes it feel handled.

**When deferral is legitimate, tested against this repository's own record.** The test that separates
the legitimate case from the comfortable one is a question about evidence: *has the thing that makes
this hard actually been measured, or is it an estimate of difficulty?* v1.60 deferred the comment
defect on the ground that modelling it required modelling what Psych does to a continuation after a
comment. That reason was never measured. Ten probes against Psych — the same method the *same
version* had just made an obligation for boundary constructs — collapse the whole thing to one
sentence. The reason for deferral was an estimate standing where a measurement belonged, and that is
the shape to look for in every future registration. By contrast, the hub-scan frontmatter reader
registered in v1.58 passes the test: it is measured (five keywords declared, two read, three
invisible), its blast radius is every hub that inherits the reader, and it needs its own canaries and
its own unrepaired-tree runs. It is still open, and it is still open **legitimately** — but it now
owes a named version, which it did not before.

**What stops a true statement in a working report from becoming a false statement in a published
artifact.** Nothing did, and that is the finding. The v1.60 drafting report contained the sentence
*"the script cannot show the repair, because it hard-pins `73f89e8` internally"*. The artifact
contained *"the reviewer's script prints NOT REPRODUCED with `checker_exit=1`"*. Same session, same
author, same facts, opposite claims — and the artifact is the one every deployment installs, while
the report is read once. The gap is not care and cannot be closed by resolving to be careful. It is a
**boundary that was never checked in that direction**: every verification in this repository runs
from the artifact outward, and nothing ever ran from the artifact back to the report that produced
it. So:

> **Before publishing, verify the artifact's claims against the report that produced them, and where
> the two disagree the artifact is wrong.** A claim that survives in a working note has been read
> once; a claim in a shipped file is read by every deployment that installs it, and it outlives the
> session that could have corrected it.

Two corollaries, both published as rules in this version.

1. *A verification declaration is a record of what was run, and a script that pins a revision cannot
   testify about any other revision.* Where a declaration cites a script by digest, the citation
   states what that script pins, or states that it pins nothing. The gate enforces the **statement**
   and cannot enforce its **truth**, which is limit 2 and is not repealed.
2. *A published claim found false is corrected in place and visibly.* Strike the clause, name the
   version that struck it, record what was measured instead. A false claim quietly deleted leaves a
   reader of an already-installed copy no way to know their copy ever carried it.

**And the criterion itself.** "No open P2" is not satisfied by an open P2 that has been written down.
Disclosure and closure are different acts and only one of them changes what the artifact does. This
is now written into the standard, so that the next maintainer facing the same temptation meets a rule
rather than a judgement call.

## The registered-not-repaired backlog, in full, with its age

The reviewer has ruled that disclosure is not closure, so this is a defect list. Every item this
repository has ever registered rather than repaired, audited at `164ecfb`. Ages are given in
**versions since registration** as well as in days, because this repository has published six
versions in two days and days understate the distance.

| # | Item | Registered | Age | Class after this audit | State |
|---|---|---|---|---|---|
| 1 | Case 20c certifies *the CI workflow carries no hand copy of the limits* by testing that it **invokes** `--limits`. A workflow with both passes. | v1.60, 2026-08-26 | 1 version, <1 day | Defect — the claim was an absence and the measurement was a presence | **CLOSED in v1.61** (cases 20c, 20c2, 20c3) |
| 2 | A space-indented `# comment` inside a frontmatter block is folded into the preceding value; a following continuation is then accepted, and Psych rejects the document. | v1.60, 2026-08-26 | 1 version, <1 day | Defect — deferral reason was an estimate, not a measurement | **CLOSED in v1.61** (section 7, nine canaries) |
| 3 | The frontmatter check does not require the block to carry **only** `name` and `description`; an extra key passes. | v1.55, 2026-08-25 | 6 versions, 1 day | **Policy question referred to the owner** — what may a shipped skill file carry? `allowed-tools` and its kin are real fields in real runtimes | OPEN, referred |
| 4 | `agents/km-hub-builder/SKILL.md` is outside the frontmatter scan; its `description` is **42 words** against a 10–40 budget. | v1.59, 2026-08-26 | 2 versions, <1 day | **Policy question referred to the owner** — is an agent contract bound by a residency budget written for runtime skill files? Measurement already taken | OPEN, referred |
| 5 | `scripts/validate_published_not_draft.py` names `rfcs/`, `outputs/` and `work/` in its *what is out of scope* prose while `SCAN_ROOTS` also silently excludes `openspec/`, `.github/`, `assets/` and `leakage/`. | v1.59, 2026-08-26 | 2 versions, <1 day | **Documentation defect owed a repair** — a claim narrower than the exclusion it describes; not a policy question and not an approximation | OPEN, owed |
| 6 | Case 15b certifies *the gate's header argues no numbered limit of its own* by matching `^# [0-9]+\. [A-Z]`. A differently formatted enumeration escapes. | v1.60, 2026-08-26 | 1 version, <1 day | **Approximation** — error direction: false **pass** on an unmatched format | OPEN, owed a measurement and a version |
| 7 | Case 15c certifies *every constant the header names is defined* by requiring `^NAME=`. A constant assigned in a tuple or inside a scope reads as undefined. | v1.60, 2026-08-26 | 1 version, <1 day | **Approximation** — error direction: false **failure** | OPEN, owed a measurement and a version |
| 8 | Cases 12/12b of the portability suite certify *the `.gitignore` covers a virtual environment* by requiring the exact line `^\.venv/$`. `.venv`, `/.venv/` and `**/.venv/` all satisfy the property in fact and all fail here. | v1.60, 2026-08-26 | 1 version, <1 day | **Approximation** — error direction: false **failure**; v1.60 called it the cheapest of its group to close, since `git check-ignore` answers the property directly | OPEN, owed a version |
| 9 | Case 20 counts limits by `grep -c '^    Limit($'` over the gate's source. | v1.60, 2026-08-26 | 1 version, <1 day | **Approximation, examined and left alone** — errs only toward a false failure, and the reason is recorded | OPEN by decision |
| 10 | `template/hub-scan.sh`'s general frontmatter-field reader prints the first matching line and stops; a decision surface reads the same field with an expression that cannot cross a newline. Measured: a manifest declaring five routing keywords across two lines is read as **two**, and the hub scans green. | v1.58, 2026-08-25 | 3 versions, 1 day | **Defect, legitimately deferred** — measured, bounded, its own blast radius (every hub inherits the reader), its own canaries and unrepaired-tree runs | OPEN, and now owed a **named version**, which it did not have |

**Ten items. Two closed here. Three policy questions the owner must answer. Four approximations that
now owe a measured error direction and a version by which they are answered. One measured defect
whose deferral holds and which now owes a version.**

Three things are deliberately **not** on this list, and saying why is part of the audit.

- **The gate's five stated `LIMITS`** are residuals of what a black-box runner can establish, not
  registrations. Each is argued in the gate itself and each is printed with every verdict. Limit 5 is
  the one this version moved, and it moved because part of what it covered was not a residual at all.
- **Cases 19j and 21h**, which pin a gap *as a gap*. A case that asserts a residual is a control over
  the boundary, not an open defect; this repository already publishes the rule that such a case is
  **inverted** when the gap closes rather than deleted. 21h survives this version unchanged, and 21k
  is what makes it say the true thing.
- **The `agents/` scope of the leakage guard and the denylist's absence from this repository**, which
  are design decisions with published arguments rather than deferrals.

## Finding 1: why the repair is at the question and not at a fourth proxy

The boundary of "what the run read" has now moved in three consecutive versions:

| Version | The covered set was… | How it failed |
|---|---|---|
| v1.58 | the **discovery set** (`*.sh`, `*.py` under `tests/`, `scripts/`) | the gate reads far more than it discovers |
| v1.59 | a **declared table** of input classes, held by a grep over the gate's source | a phase spelling its pathspec differently walked past the grep |
| v1.60 | **what the accessors handed out** | a phase that opens nothing hands nothing out |
| v1.61 | **every answer the run took from the tree** | — |

Each of the first three is a *proxy*: a stand-in that is easy to check and is not the thing. The
failure mode is identical every time — some phase takes an answer from the tree by a route the proxy
does not name — and a fourth proxy would fail the fourth way. So the property is stated at the
question:

> **Every answer this run took from the tree is taken again at the verdict, and must be the same
> answer.** A read of content is answered by its bytes. A question about a path's presence is
> answered by yes or no, and both directions of that answer can change.

That is not a wider list. It is what a verdict *is*: questions asked and answers used. Anything the
gate can ask about the working tree is asked through an accessor, and the sweep for what else asks is
recorded in the gate rather than in this file, so it is beside the code it constrains.

**Alternatives weighed and refused.**

- *Record only link targets.* Refused. That is a patch on one instance of a class, and the class is
  the finding. The reviewer asked for the class explicitly and was right to.
- *Hash a probed path's content as well as its presence.* Refused, and the reason is mechanical
  rather than stylistic: the run asked whether the path exists, and holding it to more than it asked
  reports drift the verdict never relied on. A gate that refuses over what it did not read is the
  failure mode that gets a gate switched off — the same argument that keeps ignored artifacts outside
  the fingerprint.
- *Fingerprint the whole tree.* Refused for the reason already published in limit 5: the suites and
  the tools legitimately write inside the tree.
- *A process-wide audit hook, closing the residual completely.* Refused, as in v1.60: it would record
  the gate's own source, every temporary file the suites write and every path git touches.

**The residual, restated rather than implied closed.** A path this run never asked about at all is
outside. An answer that changes and changes back inside the window is identical at both ends. A phase
that bypasses every accessor — an `open()` or an `os.path.exists()` on a path it built itself — is
outside the ledger and no check in this repository detects it. And `exists_at`, which asks about a
**base revision** rather than the working tree, is deliberately outside: a revision is not what this
fingerprint is about.

## Finding 2: model, not house rule, and why the fallback was refused

The honest fallback if the model had proved out of reach was to **reject** the construct with a named
reason — stricter than YAML in a stated place, which the tab rule already establishes as an acceptable
shape with its error direction declared. It was weighed and **refused once the probes came back**,
for a reason the probes themselves supplied: a rejection would refuse a comment between two sequence
entries, which Psych accepts and which a shipped file may legitimately want. The measured answers:

| Shape | Psych | Repaired reader |
|---|---|---|
| scalar, `# c` at column 0, continuation | rejected | violation naming the continuation |
| scalar, `  # c` indented, continuation (the reviewer's) | rejected | violation |
| scalar, continuation, `    # c` deeper, continuation | rejected | violation |
| scalar, `  #` empty comment, continuation | rejected | violation |
| scalar, comment, nothing | accepted | accepted |
| scalar, comment, new key at column 0 | accepted | accepted |
| key with empty value, comment, value as continuation | accepted | accepted |
| sequence entry, comment, entry | accepted | accepted |
| sequence entry with continuation, comment, entry | accepted | accepted |
| blank line inside a plain scalar, continuation | accepted | accepted |

Ten of ten agree, so this repair carries **no declared divergence** — unlike the tab rule beside it,
which does. The distinction is now published: a **model** answers every measured shape as the parser
does; a **house rule** diverges in a named place with its error direction stated.

## Finding 3: splitting a claim rather than lengthening a pattern

The trap the reviewer named is real: the case's claim is *absence of a copy*, and checking for an
invocation checks a different thing. Both honest repairs were available — compare the workflow's
limit text against the gate's own `LIMITS`, or narrow the case's claim to what it measures — and
**both were done**, because they answer different halves of a claim that was conflating two things.

The comparison is against the gate's `--limits` **output**, not against its source, for two reasons:
that output is the surface CI reads, so what is compared is what a copier would have copied; and it
cannot go stale when a limit is added, reworded or removed. **No pattern was lengthened.** The one
threshold in the change — sixteen alphanumeric characters as the floor for reading a token as a
digest — is held by its own case (22e) precisely so that it is a rule rather than a patch applied
until the tree went green.

## Finding 4: what "verified" now has to mean

The scripts pin, so they cannot testify about a repaired tree. What replaced them, each named in the
declarations:

1. **Integrated canaries carrying the reviewers' fixtures byte for byte** — the mutator `rm
   notes.txt`, the three-line comment block, the five verbatim limit statements. A canary derived
   from a *description* of a finding tests the description.
2. **Differential measurement against the reference implementation**, ten shapes for finding 2.
3. **De-pinned variants, declared as modified scripts** with the single changed line named. Modified
   in exactly one line each, they reported `NOT REPRODUCED` against the repaired tree — evidence
   about the tree they were pointed at, which is what the originals could not be.

**And the earlier passes' fixtures were re-run, not inherited.** The v1.59 pair pin `73f89e8` and
were run de-pinned (one line changed each): `NOT REPRODUCED` on both, `checker_exit=1` and
`suite_exit=1`. The v1.58 pair pin a *path* rather than a revision — `/private/tmp/km-v158-builder-
recheck/repo`, which no longer exists — so they were re-run with that one line re-pointed at this
working tree: the sequence fixture printed
`! SEQUENCE ENTRY IS NOT MORE-INDENTED THAN ANY KEY, SO IT CONTINUES NOTHING` at `checker_exit=1`,
and the branch-switch fixture printed
`REFUSED release-gate: … the checked-out ref changed from refs/heads/main to refs/heads/km-other` at
`exit=2`, `branch=km-other`. **Both v1.59 declarations were corrected twice in this pass as a
result:** first weakened to *"not re-verifiable at this remove"*, then corrected again once the
re-pointed runs came back, because a path-pinned script *can* testify about whichever tree stands at
that path and re-pointing it is a re-run rather than a different experiment. The distinction between
a **revision** pin and a **path** pin is what decides that, and it is now written into the
declarations rather than into this file.

And one thing that is **not** claimed, because it is not true: two of the three scripts, run against a
repaired tree, do not print `NOT REPRODUCED` at all. They assert the *unrepaired* output with
`grep -F` under `set -e` and die at that grep when the line is absent, exiting 1 silently. Recording
that they "print NOT REPRODUCED" would have been a second false claim of exactly the kind this
finding is about.
