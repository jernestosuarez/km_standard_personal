# Design: publication status is declared at the opening of a row, and quoted everywhere else

## The finding, measured rather than reasoned

`scripts/validate_published_not_draft.py` and `scripts/validate_ledger_dates.py` both hold:

```python
DRAFT_ROW = re.compile(r"\*\*DRAFT\b|\bDRAFT\s*[—–-]\s*awaiting owner push")
```

The two lines are identical, and neither file imports anything from the other. Each applies the
pattern with `search`:

- `validate_published_not_draft.py` matches `^\|\s*(v\d+\.\d+)\s*\|(.*)$` and searches group 2, which
  is the date column and the description together;
- `validate_ledger_dates.py` matches `^\|\s*(v\d+\.\d+)\s*\|\s*([^|]*?)\s*\|(.*)$` and searches
  group 3, which is the description alone.

So the two instruments do not even scan the same string, and only one of them could ever have had an
anchored rule applied to it without further surgery. That asymmetry is itself evidence that the rule
was copied rather than shared.

### Reproduction

The tree at `1444b15`, the v1.50 draft commit, carries the row

```
| v1.50 | 2026-08-24 | **DRAFT, awaiting owner push.** ... evidenced by the absence of a `v1.23`
tag, by the v1.23 row's own `**DRAFT — awaiting owner push**`, by this document's lead, ...
```

Taking that tree and flipping only the opener to `Drafted and published 2026-08-24 (owner push).`,
which is exactly the edit a publishing commit makes, reproduces the state the v1.50 publish was
measured in:

```
PASS published-not-draft: 51 versions classified ... (49 published, 2 unpublished)
PASS ledger-date-integrity: ...
  coverage: 51 row(s) read, 29 compared ..., 2 excluded as drafted, 20 unresolved
  excluded (the ledger declares them drafted, so they have no publish commit): v1.23, v1.50
```

Both exit 0. A genuinely published row is classified unpublished by both instruments because a
quotation of another row's declaration sits in the middle of its description. The consequence in each
instrument is a silent withdrawal of coverage rather than a wrong answer: one stops comparing the
date, the other stops judging the markings.

The published v1.50 row on `main` reads `by the draft declaration in the v1.23 row` where the draft
commit read the token itself. The quotation was paraphrased out at publication time. That is a repair
of the document to fit the instrument, and it is the wrong direction.

## The decision: anchor the rule to the opening of the description cell

A version-history row's description is unpublished when it **opens with** a draft declaration. What
"opens with" tolerates is decided by the forms the ledger actually uses:

| Real opener | Status | Why it must classify that way |
|---|---|---|
| `**DRAFT — awaiting owner push.**` (v1.23) | unpublished | the published convention, em dash form |
| `**DRAFT, awaiting owner push.**` (v1.50 draft, v1.51 draft) | unpublished | the same convention, comma form |
| `DRAFT - awaiting owner push` | unpublished | the bare form the existing docstring documents |
| `Drafted and published 2026-08-24 (owner push).` | published | the published stamp |
| `Drafted 2026-08-14; published 2026-08-16 with v1.22.` (v1.20, v1.21) | published | published inside a later train |

The rule is therefore: skip leading whitespace, skip an optional run of emphasis markers, and require
the literal uppercase token `DRAFT` at a word boundary. That accepts every real draft opener, rejects
every real published opener, and refuses to read a token sitting anywhere later in the cell.

Three narrower choices inside that, each with a reason.

**Emphasis is skipped, other text is not.** `**DRAFT` and `DRAFT` are the same declaration wearing
different presentation, exactly as the queue's option rule says quotes make a verb an option while
emphasis is presentation. Anything other than whitespace and emphasis before the token means the
declaration is not what the cell opens with.

**The token is matched in upper case.** The convention this standard documents and every real row uses
is `DRAFT`. Matching case-insensitively would buy tolerance of a form nobody writes, at the cost of
reaching for `Draft` in ordinary prose. The strict direction is also the safe one in both instruments:
an unrecognised opener classifies as published, which in `validate_published_not_draft.py` can raise a
false alarm a maintainer clears by reading the row and can never let a stale marking through, and in
`validate_ledger_dates.py` sends the version to the resolver, where a version that never published
resolves to nothing and is named in the coverage gap rather than passed.

**The date column is not consulted.** A declaration is a statement in the description. Passing the
date column into the classifier is what `validate_published_not_draft.py` does today, and it is why
that instrument could not have been anchored without splitting the row first.

## The decision: one classifier, not two anchored patterns

The rule could be written twice, once in each instrument. It should not be.

*For duplication.* Each instrument stays a single dependency-free file, readable end to end, with
nothing to resolve on an import path. That is a real property of the current scripts and it is worth
something in a repository that expects to be forked.

*Against duplication, and this decides it.* The rule is now subtle in three separate ways: where the
row is cut, what may precede the token, and what case the token carries. A subtle rule written twice
is two rules that agree today. This standard already names that class in three places, in the
Supervisor tier for shared entities, in the Agent Tier for thin definitions, and in v1.43 for the
skill copies, and each time the finding was that the copies had already drifted. Here the drift would
be worse than usual, because publication status is supposed to have exactly one home of record:
`validate_ledger_dates.py`'s own docstring says it excludes a drafted version "using the same
convention `validate_published_not_draft.py` reads, so publication status has one home of record".
That sentence describes an intent the code does not implement. The repair implements it.

`scripts/publication_status.py` therefore holds the row matcher, the row splitter and the classifier,
and both instruments import it. Neither keeps a pattern.

**What the shared file costs, stated rather than hidden.** It is a module and not a check, and the
release gate discovers every tracked `*.py` under any `scripts/` directory as a check. A module run
with no arguments would exit 0 whatever it contained, which is a check that cannot fail. So it
declares itself with `km-gate-instrument:`, names `tests/test_publication_status_scope.sh` as the
canaries that cover it, and the gate refuses unless those canaries run in the same pass. That is the
mechanism working as designed: nothing discovered is dropped in silence.

**Direction of dependency.** The classifier is a peer of both instruments rather than a library owned
by one of them. Making `validate_ledger_dates.py` import from `validate_published_not_draft.py` would
have been smaller, and it would assert a hierarchy between two checks that do not have one, so that
renaming or retiring either breaks the other for no reason a reader could infer.

## Why the negative direction is the whole proof here

The current tree passes today, before any repair. A pattern narrowed until `main` goes green would
also pass, and so would a pattern that had stopped matching entirely. The only evidence that
separates a working repair from either is a row that is genuinely published and quotes a declaration:

- before the repair, both instruments classify it unpublished;
- after the repair, both classify it published;
- and a row that genuinely opens with a declaration still classifies unpublished after the repair, so
  the instruments are not blinded in the other direction.

The tree at `1444b15` supplies the third of those from real material: v1.50 is genuinely drafted
there and must still be excluded, by its opener, with the quotation sitting untouched further along
the same cell.

## What this does not reach

- It says nothing about whether the version-history table is honest. A row claiming a version
  published that nobody pushed is agreed with by both instruments, before and after.
- It says nothing about a draft declaration written in a form nobody has used, and the strict
  direction means such a row reads as published. That is a stated property rather than an oversight,
  and both instruments' downstream behaviour on it is safe.
- Proving both directions proves the classifier fires on the class it models, never that it models the
  right class. The class it models is now "the description cell opens with a declaration", which is
  what the ritual actually writes; the earlier class was "the row contains the token anywhere", which
  nothing ever intended.
