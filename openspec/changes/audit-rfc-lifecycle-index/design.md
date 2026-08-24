# Design

## Context

The repository has three surfaces that speak about RFC disposition and no home of record behind any
of them: a badge counted by hand, a README paragraph written when there were two RFCs, and seven
status banners each maintained by whoever last touched that file. All three drifted, in the way a
copy with no source always drifts. The repair is to create the source, derive the surfaces that can
be derived from it, and check the ones that cannot.

The verification step changed the finding materially, and the design records that because it is the
part a later maintainer will want. Two of the audit's F-09 claims describe defects that are not in
the tree, and one defect the audit does not mention is real. A remediation that had taken the list
on trust would have falsified RFC-002's correct banner and left RFC-007's false one standing.

## Goals / Non-Goals

**Goals.**

- One place recording the disposition of every RFC, written for a reader who has no access to the
  session that produced any of them.
- Status banners that state the truth on the day they are read, with the design record intact.
- A badge count that cannot be wrong by hand, because no hand writes it.
- A check that derives the RFC set from the directory and the implementation facts from the version
  ledger, holding no list of either.

**Non-goals.**

- Judging whether an RFC's design was good, whether it should be implemented, or whether an
  implementation was faithful to it.
- Deciding v1.23's publication, which is the owner's.
- Rewriting design bodies to read as though they had always said what is true now.

## Decision 1: the index is a table, and the table is the home of record

A prose index goes stale exactly as the README paragraph did. The index is a Markdown table with one
row per RFC and a fixed status vocabulary, so it can be parsed, and the badge is rendered from the
parse rather than typed beside it.

The status vocabulary is four terms, and each is defined in the index itself:

| Status | Meaning |
|---|---|
| `ADOPTED` | Implemented by a published version, in full or with narrowings the row names. |
| `PARTIALLY ADOPTED` | Some parts implemented by published versions and others not. |
| `DRAFT` | Normative edits were drafted for a version that has not published. |
| `DESIGN ONLY` | No normative edits ride the document. It binds nothing. |

`DRAFT` and `DESIGN ONLY` are kept apart deliberately. They look the same from a distance and they
are not the same thing: RFC-002 has normative text written and waiting on a push, while RFC-003 and
RFC-005 have none. Collapsing them would erase the fact that v1.23 exists.

## Decision 2: the badge is rendered by the file that validates it

The badge is an SVG in the tree, not a shields.io call, and the repository has no build step. Two
options were available: a separate generator that a maintainer must remember to run, or generation
and validation in one file where the gate runs the validating half on every release.

The second was taken. `scripts/validate_rfc_lifecycle.py` renders the badge from the index when
invoked with `--write-badge`, and on every other invocation asserts that the committed badge and the
README `alt` text are byte-equal to what it would render. The gate discovers and runs it with no
arguments, so a hand-edited badge, a hand-edited `alt`, or an index change made without regenerating
the badge all fail the release gate. That is the plain answer to "how is the count kept true": it is
not maintained, it is regenerated, and the gate refuses a release where the two disagree.

The `alt` text is checked as well as the image, because the image's text is not the text a screen
reader or a text-mode reader receives. A badge repaired in the SVG alone would leave the false claim
on the surface some readers actually get, which is the same class as v1.42's shipped files carrying
a marking the document had cleared.

## Decision 3: implementation facts come from the ledger, and the derivation is a lower bound

The check derives what has been implemented by reading the version-history table for a row that
claims implementation in its own words, matching an implementation verb bound to an RFC reference.
Three rows say so today: v1.35 "implementing `rfcs/RFC-004` Part II", v1.39 "implementing
`rfcs/RFC-006`", v1.41 "implementing `rfcs/RFC-007`".

This is a **lower bound and is stated as one**. The ledger has never used one phrase. v1.22 records
RFC-001's adoption as "Full rationale ... in `rfcs/RFC-001-sor-gateway.md`", and v1.32 records
RFC-004 Part I as "designed in `rfcs/RFC-004`". Neither matches an implementation verb, so neither is
in the derived set. Widening the pattern until it caught them would catch v1.45's row too, which
names RFC-005 while recounting a dangling reference and implements nothing.

The consequence is honest and worth stating rather than engineering around: the check fires on a
contradiction it can see and stays silent on an adoption the ledger never claimed in those words. It
covers the class that produced this finding, a version that says it implemented an RFC whose
document still says nothing implemented it, and the index carries the rest under a maintainer's
judgement, which is where a judgement belongs.

## Decision 4: a stale banner is detected by what it does not name

A banner is prose, and prose cannot be diffed against truth. But a corrected banner has one property
a stale one lacks: it names the version that implemented the document. So the arm is mechanical
without being a word check. For every RFC the ledger claims a version implemented, that version's
identifier must appear in the RFC's own status banner, defined as the first run of blockquote lines
after the H1.

This deliberately does not require particular wording, does not forbid the original sentence from
remaining, and does not read the design body at all. It is satisfied by the pattern v1.45 already
established on RFC-005: leave the banner's original text standing as the dated statement it was, and
add a dated note recording what has happened since.

## Decision 5: a dated record is corrected in its status and nowhere else

v1.45 grafted the rule and this change is its second application. Each of the three corrected
banners keeps every word it had. What is added is a note carrying the date of the correction, the
versions that implemented the document, and, where the implementation narrowed the design, the
narrowing, quoted from what the implementing version itself recorded rather than re-derived here.

RFC-004 gets one further judgement, recorded because it looks like an omission otherwise. Part I
carries its own status addendum dated 2026-08-20 saying Part I was taken to "**v1.32, drafted and
unpublished**". v1.32 has since published, so the sentence is stale in the present tense and true as
of the day it carries. It is **left alone**, and the top-of-document note states that Part I's
addendum is dated and describes that day. Editing a dated addendum to agree with the present is the
precise act v1.45 forbids, and the correct place for the current fact is the note that carries
today's date and the index that carries no date at all.

## Decision 6: the check fails on a missing index and refuses on an unparsable one

The two are different states and folding them together would break the evidence run this change
needs. An absent index is a fully evaluated finding: the directory was read, seven RFCs were found,
none is covered. That is the defect under repair and it is reported as a failure that names every
uncovered RFC. An index that is present but yields no parsable row, or carries a status outside the
declared vocabulary, is input the check could not evaluate, and it refuses with exit 2 rather than
reporting seven uncovered RFCs it never actually looked for.

The check also refuses when `STANDARD.md` cannot be read or carries no version-history table, when
`rfcs/` is missing, unlistable or yields no RFC, when the badge is missing or yields no message, and
when `README.md` cannot be read or does not reference the badge. An unread directory is not an empty
one.

## Decision 7: the badge arm still speaks when there is no index

Against `main` as it stands there is no index, so the badge cannot be compared with one. Reporting
only "no index" there would leave the false count unnamed in the very run that is meant to prove the
check detects it. So when the index is absent the badge is judged against the ledger-derived
implemented count instead, and the failure says both things: that the count is wrong and that it is
underived. Against a repaired tree this branch is unreachable, which is why the canaries exercise it
directly as well as through the evidence run.

## Risks / Trade-offs

- **The index is maintained by hand and can go stale.** The check reduces the surface it can go
  stale on (coverage, ledger agreement and badge agreement are all mechanical), but a row whose Notes
  cell describes a narrowing wrongly is not reached by anything. This is the same limit v1.48
  recorded for a judgement claim, and it is stated in the version row rather than implied away.
- **The ledger derivation is a lower bound.** See Decision 3. An RFC adopted by a version that never
  wrote the word is invisible to the ledger arm and is carried by the index alone.
- **The status vocabulary is fixed and the check refuses an unknown term.** Adding a fifth status is
  a deliberate edit to the check, which is the intended cost: a vocabulary that anything can join is
  not a vocabulary.
- **Proving both directions proves the check fires on the class it models, never that it models the
  right class.** A design document that should exist and was never written is reached by no arm
  here, for the reason v1.30 already gives.

## Migration Plan

None. Nothing a deployment installs changes. A hub adopting v1.50 adopts a version pin and a
maintainer-side check.

## Open Questions

- Whether v1.23 publishes, and therefore whether RFC-002 moves from `DRAFT` to `ADOPTED`, is the
  owner's decision and is untouched here. The index records the state as it is, with the reason.
