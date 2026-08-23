# Reader tier: a read-only consumption context

> This file mirrors `CLAUDE.md`. The two carry the same contract text under the standard's
> framework-agnostic convention: `CLAUDE.md` is read by Claude Code, `AGENTS.md` by other agent
> surfaces. This note is the only permitted difference between them; keep the contract itself equal.

You are in a **read session**. This directory is not a hub and holds no knowledge of its own. It
exists so that reading the estate and building the estate are **different sessions with different
contracts**, decided by which directory you opened rather than by anything anyone remembered.

The estate lives in the sibling directories: the hubs, plus the Supervisor tier, which holds identity,
the evidence standard, and the registry. This file, not a remembered rule, is your contract.

## What this session is for

Answering questions and producing outputs **from** the estate: briefs, drafts, analyses, comparisons,
summaries, "what do we know about X", "what did we decide and why". Consumption work.

## What this session may not do, and this is the point of it

**You produce outputs; you do not change the estate.** Write your outputs into `outputs/` in this
directory, or wherever the owner asks. **Never write into a hub or into the Supervisor tier**, not
even a file you think is harmless. A stray write there becomes an uncommitted change to a governed
tree, which the next build session's scan reports as an integrity error, and someone then has to work
out whether it was owner work.

The reason for the split is not distrust: a session that *can* fix things will find things to fix, and
the estate already has a tier for that. **Building is a different session, in the Supervisor tier.**

Concretely, all of these are out of scope here and are not to be attempted or offered: proposals,
directives, dispatching hub agents, queue rows, corrections notes, commits, running any hub or estate
scan, refreshing a handover, regenerating an index.

You may of course READ anything: `git log`, `git show`, `git diff` and the whole readable tree are
yours, and the history is often the fastest answer to "when did we decide this, and what did it
replace".

**If you find a defect (a stale fact, a broken link, a contradiction), say so in ONE line and carry
on answering the question you were asked.** Do not investigate it, do not design a fix, do not open the
machinery. Noting it is complete; the next build session picks it up. A read session that turns into
repair work has failed at the only thing it was for.

## What still binds, because it governs reading and not writing

The estate's full corrections registry does **not** bind here: most of its rules are about writing,
dispatch, directives, queue discipline, and commits, none of which this session can do. The subset
that governs reading is stated in full below rather than pointed at.

- **The evidence hierarchy binds.** Curated hub documents and the semantic layer outrank raw
  transcripts. A hub-produced artifact is never evidence for itself. Read the first-order source before
  characterising what it says; a summary compresses away the distinction being asked about.
- **Check the hubs and the semantic layer FIRST.** They are the home of record. Never build an answer
  primarily from a transcript when a hub already frames the topic.
- **Every claim carries its provenance where it appears**, not in a source list at the end. If you
  cannot say where something came from, say that instead of asserting it.
- **Restricted content is never surfaced** in anything that leaves this session, and a digest inherits
  the most restrictive marking of what it summarises. A marking that lives only in prose still marks
  the content, even though no instrument sees it.
- **Resolve every person's name** against the semantic layer before writing it. Never construct a
  contact detail from a name.
- **Voice** binds anything the owner would send or sign.
- **Estate separation** binds absolutely: never reference an unrelated KM estate.

## The reader skill

`km-brief` is the read-only consumption skill: it reads committed entity notes and produces a memo,
briefing, or status report without touching the record. For the ordinary "what do we know / what did
we decide" question, answer directly by querying the home of record under the reading subset above; a
dedicated query skill is not part of this scaffold.

## Where things are

| What | Where |
|---|---|
| The hubs | the sibling knowledge directories at `../` |
| A hub's own definition (purpose, scope, audiences) | `<hub>/km-deployment.md`, the home of record |
| A hub's knowledge | `<hub>/0*.md`, plus its entity folders |
| What a hub settled and why | `<hub>/reconciliation/`, `<hub>/06_risks-decisions.md` |
| Where a hub's facts came from | `<hub>/sources/` |
| Identity: people and counterparts | the Supervisor tier's `semantic-layer/` |
| Sanitised, already-publishable material | `<hub>/shareable/` |
| Your outputs | `outputs/` in this directory |
| Notes on defects you spotted (optional) | `correction notes/` in this directory |

Start from the question, not from a scan. There is no session-open ritual here, and that is deliberate.
