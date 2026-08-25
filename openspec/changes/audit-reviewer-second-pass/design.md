# Design: audit-reviewer-second-pass (v1.58)

Branch `v1.58-gate-stability-and-frontmatter`, off `main` at `510cf03` (published v1.57).

Three findings. Two of the decisions in them were genuinely open and are argued here rather than
recorded as conclusions.

## 1. Why the fingerprint is not a snapshot, which is the trap in finding 1

The natural repair for "the gate may judge a tree that changed" is "run against an immutable
snapshot". It is wrong here, and wrong in a way that would have been hard to see afterwards.

Since v1.54 this gate deliberately reads the **working tree** — tracked ∪ untracked-not-ignored —
because the maintainer contract orders it to run *before* explicit staging, so a check authored in
the change being gated is guaranteed to be untracked at the moment the gate runs. A snapshot is
naturally built from tracked content (that is what `git stash`, `git archive` and a worktree give
you). Building one here would have withdrawn v1.54's coverage while appearing to add a guarantee —
the gate would have reported the same count and the same PASS with a new check present as without it,
which is the precise defect v1.54 closed. **The worst available outcome is a repair that silently
reopens the defect a previous version closed**, because the tests for that defect all still pass:
v1.54's cases assert discovery over the working tree, and a snapshot taken *after* discovery leaves
them green.

So the route is fail-closed detection rather than isolation. Fingerprint what the gate actually
reads, before and after, and refuse on any difference. This costs no coverage, adds no new tree
semantics, and its failure mode is a refusal rather than a silent narrowing.

**Scope of the fingerprint.** Exactly what discovery reads, via the same pathspecs — factored into
`check_patterns()` so there is no second copy of the list — plus `HEAD`. Content-hashed, because the
reviewer's observed case was a *content* edit that need not change a file's size. `HEAD` alongside,
because the reviewer's other observed event was a *branch change*, which a content hash misses
entirely when the two branches happen to agree on the fingerprinted files.

**Why not the whole tree.** Considered and refused. The suites and tools legitimately write inside
the tree they run in, and a fingerprint over everything converges on a gate that refuses every run.
A gate that always refuses is switched off, and it takes the real checks with it — which is this
standard's own stated reason for keeping the currency check an advisory. The cost of the narrow
scope is real and is stated as limit 5 and pinned by case 21e.

## 2. Fifth limit, or refusal condition? Both, and the reasoning is the deliverable

The question was posed as either/or. The answer is both, and they answer different questions.

**It is a refusal condition, primarily.** The four existing limits are all things the gate *cannot
do at all* — permanent properties of the arrangement, not detectable states. Tree drift is
different: it is **detectable**, and the repair makes it so. What an instrument does with a condition
it can detect is refuse, and the gate already has exactly the verdict category for it: exit 2, *the
gate could not evaluate*. Filing drift as a limit alone would have been the wrong shape — it would
have said "a green gate does not mean the tree held" while leaving the gate green over a tree that
did not hold, which is a limit standing in for a missing control.

**It is also a fifth stated limit, for the residual.** After the repair, a PASS means something
narrower than a reader will assume: the discovered set and `HEAD` were identical at two instants. It
does not mean nothing changed. Two things escape it, and both are permanent properties rather than
work deferred — a change that is undone inside the window is byte-identical at both ends and no
evidence of the middle survives (catching it needs a watcher, a different instrument at a different
cost), and material outside the discovery set is not covered at all. Every sentence of the form *a
green line does not mean this* belongs with the limits. So limit 5 states the residual, not the
defect.

Refusing to add the limit would have left the gate printing four sentences about what a pass does not
mean while a fifth, equally load-bearing, lived only in a docstring.

## 3. Finding 3 decided the order of work, and paid for itself immediately

The brief noted that finding 3 is about what adding a fifth limit costs today. That is not a
coincidence to note; it is the sequencing.

Both routes for finding 3 are defensible — make the claim true, or make it accurate. **Reducing the
count of maintained definitions is better than describing the drift** where it is available, and it
was available here: the header's numbered prose block is the *argument* for each limit, and an
argument belongs beside the thing it argues. Moving it into the definition makes the tuple the single
home for both the statement and the reasoning, deletes the second definition outright, and lets the
third — case 15's four hardcoded `grep -Fq` assertions — be replaced by assertions that derive.

The reader is not contorted by this. The header now points at the definition in four lines instead of
arguing forty; the argument is still prose, still in full, and now sits where the statement it argues
sits. Reading the definition top to bottom is *better*, not worse: the old arrangement had statement
and argument 190 lines apart and in different orders — the header's entries stood in file order 1, 3,
2, 4, which is what separate maintenance looks like when nobody is checking.

**And the proof is the work, not an argument about the work.** This version adds a fifth limit. Adding
it was an edit to `LIMITS` and to nothing else. It also made true, with no edit at all, the identical
claim `.github/workflows/release-gate.yml` has carried since v1.55 — which the sweep found, and which
is the strongest available evidence that the route taken was the right one: reducing the definitions
repaired a second file by not touching it.

## 4. The checks for finding 3 had to be anchored, and then proved not to be silenced

Written unanchored first, cases 15a and 15c reported **this change's own repair** as the defect. A
repair to this class necessarily quotes the wording it removes — in the version row, in the header's
account of what was wrong, in the `km-unrepaired-tree` declaration. That is v1.52's class ("a status
is read where a status is declared, and quoted everywhere else") and v1.55's ("a directive token is
read where a directive is declared"), met on the checks written to close a different one.

Two anchors, both rules rather than conveniences: text inside double quotes or backticks is a
quotation and is blanked; the `km-unrepaired-tree` line is a **dated record**, which this standard
forbids rewriting to agree with the present, and is blanked in place so reported line numbers stay
true.

Anchoring is a narrowing, and v1.52 states the trap plainly: *a rule narrowed until the tree goes
green passes, and so does a rule that has stopped matching entirely.* So cases **15d and 15e** run
both anchored greps against a copy of the gate carrying the v1.55 wording as a **live claim** rather
than as a quotation, and require both to fire. Without those two cases, this change could have
anchored its own checks into silence and nothing in the repository would have said so.

## 5. Finding 2: state, not a parser

Two routes were offered: validate the effective YAML value, or make continuation handling
state-aware. The dependency question decides it.

**PyYAML is not installed on the authoring host**; Ruby's YAML is. Neither is guaranteed in the
environment a deployment runs this check in, and v1.51 already published about a shipped tool that
assumed its author's toolchain. A check that acquires a parser dependency to fix a reader defect
trades a false pass for a refusal on hosts that lack the parser — or, worse, for a check that is
quietly skipped.

So the reader is made state-aware and folds the value itself, in the shell the check already
requires. Ruby's parser was used to *establish the ground truth* for the reproduction (97 words
against the check's 13) and is depended on by nothing that ships. The limit is stated in the check:
it models the plain-scalar folding these files use, not the whole of YAML.

**Performance was a real constraint and changed the implementation.** Written with `printf | sed` per
block line, the suite ran **196s against the original's 82s**, measured back to back on the same cold
tree — this loop runs about thirty times across the canaries, on synced storage where a fork is
expensive, and the gate that runs it has a runtime budget. Rewritten with `[[ =~ ]]` and
`BASH_REMATCH`, it spawns no subprocess per line. **Measured warm, and stated carefully because the
two figures are not comparable otherwise: the repaired check runs in 1.6s against the original's
1.5s** — the cost of the repair is about a tenth of a second, not the 78s a naive reading of the cold
numbers would suggest, and not a speed-up either. An earlier draft of this note claimed "3.8s, faster
than the version it replaces", which compared a partly-warm run of the new against a cold run of the
old; it was corrected before this change was committed. A correctness repair that triples a check's
runtime is a repair that gets the check moved out of the gate later, and the way to know which
happened is to measure both on the same cache state.

**A third defect surfaced while repairing rather than by probing.** The continuation arm's tab
pattern was written `"\t"*` inside double quotes — a literal backslash-t — so no tab-indented line had
ever matched it. This is v1.29's rule (verify a matching construct against the tool that will run it;
an ignored construct matches nothing, and nothing is what clean input also looks like) found in this
repository's own suite.

## 6. What the sweeps found, and why one is registered rather than repaired

**Finding 2's class** — a check reads the first physical line of a value whose logical value spans
lines — was swept across every shipped check, tool and surface.

`.km-tier`'s `tier` and `scope:` reads were examined and **excluded with reason**: the standard
defines that marker as line-oriented ("whose first line is the word `reader`", "declared ... on a
`scope:` line"), not as YAML, so those values are single-valued by construction and the rule's own
stated trigger does not reach them. The frontmatter openers (`head -1` against `---`) are
physical-line tests by definition. `hub-scan.sh`'s `lifecycle: active` and marker greps are
line-anchored because the standard defines those markers as lines.

The class **was** found, twice, on `routing-keywords` — the very field v1.44 was written about.
`fm_field()` in `template/hub-scan.sh` does `print; exit` on the first matching line; the cockpit's
reader uses `[^"\n]*` under `re.M`, which cannot cross a newline. Measured on a manifest declaring
five keywords folded across two lines: YAML reads all five, `fm_field` reads `alpha, beta,` — two
keywords plus a stray empty entry, which the v1.44 gate then correctly splits per token — and the
cockpit reads two. **The per-token repair was right and was handed a truncated value.**

It is **registered, not repaired here**, and the reason is scope discipline rather than budget.
`fm_field()` serves every field the session-start scan reads and is inherited by every hub; changing
it reaches `[ FRONTMATTER ]`, `[ SHAPE ]`, `[ LINKS ]`, `[ CURRENCY ]` and `[ PROJECTION ]`. That is a
change with its own blast radius, its own canaries and its own unrepaired-tree runs. Settling it
inside a repair to an unrelated reader is exactly the move `tests/test_skill_frontmatter.sh` already
refuses in its own registered gap, and would settle it silently. It is registered in both readers'
source and in `STANDARD.md`, so it is a claim an instrument's next maintainer meets rather than prose
in a report.

**Finding 3's class** — a comment claims a single definition where several are maintained — was swept
across every such claim in shipped code. `scripts/publication_status.py`'s claim was verified
genuinely single (both validators import it rather than holding copies). `tests/test_readme_inventory.sh`'s
"the only place ... that enumerates what the template installs" is loose — the standard's directory
tree enumerates the entity folders too — but it is a claim about where an enumeration appears rather
than a definition whose count can drift silently, and the check itself derives; examined, not the
class. The cockpit's "the only place desk ids surface" is a claim about runtime behaviour verified by
the filter directly below it.

One real instance was found and **repaired**: `tools/km-publish.sh` reads *"THE PIN. One name, one
place ... editing this line is sufficient to change what renders"* above **two** literals,
`WEASYPRINT_PIN="weasyprint==69.0"` and `WEASYPRINT_VERSION="69.0"`. The second is what `venv_ready`
verifies the installed renderer against and what the environment path is built from, so editing the
pin alone would install one version and verify against another. **It fails closed, which is why
nothing caught it** — and a failing-closed defect under a comment claiming it cannot happen is still
the class. The bare version now derives from the pin; case 7c counts the version literals and requires
the derivation to hold.

## 7. What does not survive verification, and what is deliberately not built

Every one of the three findings survived verification, including finding 3's classification: checked
against v1.55's own tree at `aeec51a`, the sentence, the four numbered header entries and the four
hardcoded assertions all stood there together, so the claim was false when written and is corrected
under the v1.47 rule rather than dated under v1.56's.

One detail of finding 3 is **narrower than stated, and it is recorded rather than glossed**. "A fifth
limit is an edit to three places" is true of the *maintained prose*, but no test would have failed on
the addition: case 15's four assertions only required those four strings to be present, so a fifth
limit would have left them green, and case 20 already derived its count from the tuple. The third
place was coupled to the header's exact **wording**, not to the set's **size**. That makes the claim
false for the reason given — the file would have contradicted itself, and its own "the count is not
restated in prose anywhere" was already false — rather than because a check would have caught it. The
distinction matters because it is the argument for making case 15 derive: nothing mechanical was
holding the three definitions together, which is how they drifted into file order 1, 3, 2, 4 unnoticed.

**Not built, with the reason.** No watcher process observes the tree during a gate run. That would
close the change-and-change-back residual, and it is a different instrument with a different cost and
a different failure mode (a watcher that dies mid-run reports a clean window). Naming it here keeps a
later maintainer from reading "tree stability is solved" off limit 5. And no check compares the
fingerprint's scope against the set the suites actually read, because that set is not knowable without
tracing every check's I/O; the scope is declared and pinned by case 21e instead.
