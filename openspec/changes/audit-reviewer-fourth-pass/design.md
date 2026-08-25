# Design: audit-reviewer-fourth-pass (v1.60 draft)

**Nothing in this document binds until v1.60's own owner push.**

## The thing to address first: four passes, and the last two were about the control, not the code

Four external passes, each finding real defects in the prior pass's repair. The first two found
**behaviour** that was wrong: a gate that passed over a tree that moved underneath it, an identity
read that could not see a branch. The last two found something else, and they found the same thing
twice.

- v1.59: case 21d's **title** promised that a branch change was caught. Its fixture moved `HEAD` with
  an empty commit — commit movement, a different act. The control was weaker than the claim it
  certified.
- v1.60: case 21j's **title** promised that every phase takes its pathspecs from the structure the
  fingerprint iterates. Its mechanism was a grep for one spelling of one call. The control was weaker
  than the claim it certified.

So the question is fair and the answer is yes: **this repository writes checks that assert properties
they can only approximate, and then reads the check's green as the property.** It is worth being
precise about why, because the cause is not carelessness. Every one of these controls was written in
the same motion as the repair it guards, by the person who had just built the mechanism, at the
moment when the mechanism's *shape* was most vivid and its *boundary* least examined. A grep for
`git_tracked(root, [` is what the property looks like from inside the diff that created it. It is
the mechanism photographed, not the property stated. The repository's own doctrine already names the
failure — *proving a check in both directions proves it fires on the class it models, never that it
models the right class* — and both v1.59 and v1.60 are that doctrine catching its author. That is not
a failure of the doctrine; it is the doctrine working exactly one pass too late, every time, because
the person who can see the gap is never the person who wrote it.

**Where else is it true.** The sweep for this class was run across every check in this repository that
greps source text to certify a property of code, and returned three more, all registered here with
their error directions rather than repaired inside a change to something else:

| Case | Claims | Enforces | Error direction |
|---|---|---|---|
| 20c | the CI workflow obtains the limits from the gate **rather than copying them** | the string `km-release-gate.py --limits` appears in the workflow | **false pass**: a workflow could invoke the flag *and* carry a copy |
| 15b | the header **argues no numbered limit of its own** | no line matches `^# [0-9]+\. [A-Z]` | **false pass**: any other enumeration style |
| 15c | every constant the header names **is defined** | a line matches `^NAME=` | **false failure**: tuple assignment, or a definition inside a scope |
| 20 | `--limits` prints every limit the gate defines | `grep -c '^    Limit($'` | **false failure** only: a miscount breaks the equality, never satisfies it |

20c is the sharpest and is the one to close next, because a control that certifies *absence of a copy*
by confirming *presence of an invocation* is not an approximation of its claim at all — it is a
different claim. Cases 15a and 20d grep **prose** to certify a claim about prose; the pattern is the
direct measurement there and they are not this class, which is stated so the sweep's boundary is
visible rather than assumed.

**The structural alternative, so the next version is about the class rather than the instance.** Every
one of these controls exists because a property of the code is not observable at runtime and so was
inferred from the text. The general repair is to **make the property observable**. That is what v1.60
does for 21j: the covered set stops being something you can read off the source and becomes something
the run reports about itself. The same move is available to 20c (have the gate emit its limits with a
provenance marker the workflow must echo, so a hand copy is detectable rather than merely improbable)
and to 20 (import the gate and read `len(LIMITS)` instead of counting a text pattern). It is *not*
available to 15b and 15c, which are genuinely claims about a document's shape; those should stop
saying *the header argues no numbered limit* and start saying *no line in the header matches this
enumeration form*, which is the accurate claim and is worth less — which is the point. **When a
property cannot be made observable, the honest repair is to narrow the claim to what the pattern
actually measures, not to lengthen the pattern until the current tree goes green.**

## Finding 1: why the runtime ledger, and why not a better grep

The reflex repair was available and was refused. More spellings, a regex over call forms, a check that
`git_tracked` is only ever called with a name resolving into `INPUT_CLASSES` — each is a longer
pattern, and each is defeated by a helper function, a local variable, a comprehension or a `functools`
wrapper. The reviewer needed one line and a tuple to defeat the current one. **A pattern that has to
anticipate every way a call can be written is not a guarantee; it is a race the author always loses,
because the author writes the pattern first.**

The design adopted is the one the brief pushed for and it holds up under the cases:

- `git_tracked`, `git_untracked` and `read_text` become **recording accessors**. Each registers, into
  a module-level `Reads` ledger, the pathspec group it enumerated and the digest of every path it
  handed out or opened, at the moment it first saw it.
- `_git_ls` is the raw, **non-recording** enumerator. The fingerprint uses it, so reading the ledger
  does not grow the ledger.
- The closing fingerprint takes `extra_specs` and `extra_rels` from the ledger, re-enumerates every
  pathspec the run actually asked for and re-hashes every path it actually opened.
- The `before` side is the opening `INPUT_CLASSES` baseline **extended** by the ledger's earliest
  observation of anything the baseline did not hold, with the baseline winning on overlap because it
  is the earlier of the two reads.

**Why `INPUT_CLASSES` survives.** It is no longer the guarantee, and the code and the comments now say
so. It survives as the **opening baseline**, and that is not decoration: it pins a file from `t=0`
rather than from the moment its phase happens to reach it, and it is what keeps case 21c — a
check-shaped file *appearing* mid-run — visible, since a file that never existed was never read and
would otherwise be invisible to a pure read-ledger. Set-level appearance and disappearance need an
enumeration; content-level drift needs a digest. The design keeps both and derives the second from the
run.

**What this closes, stated as a mechanism rather than as a hope.** A phase added tomorrow cannot obtain
a file without going through an accessor, and cannot go through an accessor without being recorded.
The guarantee stops needing a check because it stops being possible to violate by writing the phase
differently. Case 21j is therefore no longer an assertion about this file's text: it injects the
reviewer's own `check_text` — tuple pathspec and all, with its anchors asserted so a refactor fails it
loudly rather than silently building an unmodified gate — into a copy of the real gate, and requires
that a mid-run `.txt` change is refused **with no edit to any list and no edit to the case**.

**What it does not close, stated precisely, because the brief asked for exactly this.** A phase that
obtained a file **without** going through `git_tracked`, `git_untracked` or `read_text` — a bare
`open()` on a path it built itself, an `os.walk`, a `subprocess` that reads a file — is outside the
ledger, and **no check in this repository detects that**. It is narrower than the v1.59 residual,
which any unrecognised spelling of a pathspec escaped, and it is not zero. It is written into the
gate's own limit 5, where a reader of a passing verdict meets it, rather than into this document
alone.

**The audit-hook alternative was weighed and refused for a mechanical reason.** Python's
`sys.addaudithook` observes the `open` event process-wide and would close the residual completely. It
would also record the gate's own source, every temporary file the discovered suites write into
`mktemp` directories, every path `git` touches through `subprocess`, and every module the interpreter
imports. The fingerprint would then cover a set that changes on every run by construction, and the
gate would refuse itself — which is the failure mode that gets a gate switched off and takes the real
checks with it, the same argument that keeps ignored artifacts outside the fingerprint. Refused, and
recorded as refused rather than as future work.

**21h and 21j are now a matched pair and must be read together.** Under v1.59, 21h passed while a real
`.txt`-reading phase stood in the gate, so `notes.txt` was an input and the gap pin was certifying the
wrong thing. The pair now says the true thing exactly: 21h requires that a class the **unmodified**
gate never reads is not covered; 21j requires that the same class **is** covered the moment a phase
actually reads it. The boundary is *what was read*, and both sides of it are held.

## Finding 2: deriving the rule from the parser instead of from the shell

`[[:space:]]` is the shell's whitespace and it contains the tab. YAML forbids tabs in indentation. A
reader that captures indentation with `[[:space:]]*` therefore folds a tab-indented continuation into
the preceding key and accepts a document Psych refuses — a **false pass** by the paragraph v1.59
itself added.

**The boundary was probed, not assumed**, which is the whole method here. Eleven shapes were run one
at a time against Psych 3.1.0 / libyaml 0.2.1 and the answers are recorded in the check beside the
rule. Three of them are the interesting ones because the parser **accepts** them:

- `description:<TAB>value` — accepted. The tab is separation after the key's indicator, not
  indentation. The reader must keep accepting it, and a clean canary requires that.
- `description: aa<TAB>bb` — accepted. A tab inside a value is not indentation. Clean canary.
- `description: a` then `  <TAB>text` — **accepted**. A space has already satisfied the required
  indentation, so the tab is separation.

And the ones that surprised the naive rule:

- `  -<TAB>alpha` — **rejected** (`found character that cannot start any token`). The tab between the
  sequence indicator and its value is inside the entry's indentation region as libyaml scans it, not
  separation. So the rule cannot be "leading whitespace only"; the region includes the `-` and what
  follows it.
- A line whose entire content is one tab — **rejected**. It is not a blank line.

**The adopted rule is stricter than libyaml in exactly one place and the divergence is declared.**
Indentation here is spaces; a tab anywhere in the indentation region — leading whitespace, plus the
`-` indicator and the whitespace after it on a sequence entry — is a rejection naming the tab. That
refuses `  <TAB>text`, which libyaml accepts. This is a house rule the standard is entitled to draw,
and the argument for it is the error direction: it can produce a **false failure** on a document
mixing spaces and tabs in one indent, and it cannot produce a false pass. No shipped skill file does
it. Stating that asymmetry is what makes it a declared contract rather than a discovered defect, and
it is now written into `compound-value-validation` as a general obligation.

**The neighbour the brief asked about was real and is repaired.** The v1.59 sequence-indentation
comparison measured `${#ind_str}` over a region that could contain tabs, scoring a tab as one column
and comparing it against spaces. With tabs excluded from the region the comparison is sound **by
construction** rather than by a second arm — the rejection makes the width meaningful. And the
continuation arm's own second `[[:space:]]`-based re-derivation of the region is gone; it takes the
value the single derivation already produced, which removes one more place for the same wrong
assumption to live.

**On how the defect arrived, which is the part worth generalising.** The tab arm was written `"\t"*`
inside double quotes — a literal backslash-t — and was **inert from the day it was written**. v1.58
found the inertness and repaired it by substituting a class the shell honours. That made the arm live
for the first time, and wrong in the same motion. The lesson is not "check your escaping": it is that
**discovering a matcher never fired is discovering its rule was never tested**. The rule was unproven,
not merely unenforced, and connecting it is authoring it. v1.58 repaired a spelling and kept an intent
on trust — which is the same failure as v1.59's, one level deeper, since there the line at least did
something.

Hence the last piece: **the tab matcher is probed against the live shell before the suite returns any
verdict**, against a string it must match and a string it must not, and the suite **REFUSES** if the
probe shows it inert. This is the repository's own v1.29 rule — verify a matching construct against
the tool that will run it — applied to the construct that made this version necessary, and it is the
same treatment the leakage instrument already gives its boundary constructs. Two canaries prove the
probe separates the states, one of them asserting that the literal backslash-t form is genuinely
inert against a real tab, so the probe cannot be a check that agrees with whatever it is given.

## Registered, not repaired

- **The three spelling-for-property controls** in the table above (20c, 15b, 15c), plus case 20 left
  alone with its reason. Repairing four unrelated controls inside a repair to a fifth is the kind of
  scope creep this repository already refuses elsewhere; they are named so the next version can be
  about the class.
- **A space-indented `# comment` inside a frontmatter block** is a comment to Psych and is folded into
  the preceding value by this reader, which can move a description's word count in either direction.
  No shipped file does it. Modelling it correctly requires modelling what Psych does to a continuation
  that *follows* a comment — which it rejects — so this is a second reader change riding inside a
  repair to tab handling, and it is registered instead.
