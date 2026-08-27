---
name: km-intake
description: Use when this hub has pending proposals in changes/ or unprocessed files in _inbox/. /km-intake applies or rejects each proposal, then turns each inbox file into a sourced proposal.
---

# Skill: km-intake — Pending Proposals + Inbox Files

You have been invoked as `/km-intake`. First handle any pending proposals in `changes/`, then
process any new files in `_inbox/`.

**The arrival of a file in the inbox is not a decision** (added in v1.64). The hub owner put the file there, so asking
whether to process it asks the owner to authorise work already requested. Intake therefore runs
to completion without waiting for a word: classify, digest, resolve the date, file the original
and its digest at their retained home, and produce the proposal — all in one act, committed
together. **Only the resulting proposal waits on the owner**: nothing edits a hub document
without approval, exactly as before. The one thing that can hold a file in the inbox is the date
gate (Step 3.5): a source whose date cannot be resolved stays until the owner supplies one.

---

## Step 0 — Handle pending proposals

Scan `changes/` for `*_proposal.md` files, excluding `PROPOSAL_TEMPLATE.md`.

**No proposals found:** proceed to Step 1.

**Proposals found:** for each proposal file, check whether a matching `*_approval.md` exists:

| State | Action |
|---|---|
| Approval file exists — **APPROVED** | Apply all proposed changes; delete both files; update `sources/transcript-index.md`; commit, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`); report "Applied: `<slug>`" |
| Approval file exists — **APPROVED WITH CONDITIONS** | Apply non-excluded items only, respecting any remarks in the approval; delete both files; update transcript-index; commit; report what was applied and what was skipped |
| Approval file exists — **REJECTED** | **First** capture the approval's Reason + Rule as a `corrections/` note (`trigger: rejected-proposal`, `lifecycle: active`) and commit it — never delete a reviewer's reason. **Then** delete both files; log rejection in `transcript-index.md`; report "Rejected, correction captured: `<slug>`" |
| **No approval file** | Surface to user: "Proposal `<filename>` is pending — no approval file found. Approve in chat to apply now, or I'll leave it and continue." Wait for a response before continuing. |

If the user approves a pending proposal in chat, apply it immediately (same as APPROVED above),
then continue to the next proposal or to Step 1.

After all proposals are handled, report a one-line summary (e.g. "Applied 1, pending 1") and
proceed to Step 1.

---

## Step 1 — Scan inbox

List all files in `_inbox/` excluding `README.md`.

- **Empty:** report "Inbox is empty — nothing to process." and stop.
- **One file:** proceed with that file.
- **Multiple files:** process each in turn, one proposal per file — do not ask which to process;
  the arrival of a file is not a decision. (Combine related files into one proposal only when
  they are plainly one source, e.g. a deck and its own transcript.)

---

## Step 2 — Classify

Determine which category the file falls into:

| Category | Description | Route |
|---|---|---|
| **source/input** | External content to be digested: partner decks, vendor docs, external transcripts, meeting notes from outside the team, research papers | Digest → file to `sources/` at intake → propose hub updates |
| **team output** | Docs produced by the team: memos, briefings, strategy notes, advisory reports | File to `working-docs/<topic>/` at intake, recorded by proposal; no digest needed unless requested |
| **visual asset** | Diagrams, architecture images, photos (.png, .jpg, .svg, .drawio, .vsdx) | File to `assets/architecture/` at intake, recorded by proposal; no digest needed |

If the category is not obvious from the filename and extension, read the first page/slide/section
to determine. If still unclear, ask the user.

**Entity facts (source/input files only):** while digesting, watch for facts that map onto a decision,
risk, stakeholder, milestone, or partner (see `decisions/TEMPLATE.md`, `risks/TEMPLATE.md`,
`stakeholders/TEMPLATE.md`, `milestones/TEMPLATE.md`, `partners/TEMPLATE.md`). When one does, the
proposal (Step 5) targets **both** the new/updated entity note (e.g. `decisions/<slug>.md`) **and** a
one-line link addition to the matching rollup doc (`03`/`04`/`05`/`06`) — using the same
`### N · <filename> — <add/update/remove>` block the proposal template already uses for any file.

---

## Step 3 — Digest (source/input files only)

Read the full content of the file:
- **PDF:** extract all text layers; for scanned/image PDFs, read each page visually
- **PPTX:** for text-based slides, extract text; for image-based slides, extract embedded images
  (use `python3 -c "from pptx import Presentation; ..."`) and read each visually; clean up temp images after
- **DOCX / TXT / MD:** read full content
- **Transcripts:** read full; identify speakers, key decisions, action items, dates

Write `_inbox/<original-name>_digest.md`:

```markdown
# Digest — <original filename>

**Source type:** <partner deck / transcript / external doc / vendor brief / ...>
**Date processed:** <today YYYY-MM-DD>
**Source date:** <date from document, if found>
**Participants / authors:** <if applicable>

## Structure
<Outline of sections, slides, or parts — numbered list>

## Key content
<Main facts organised by theme — decisions, people, dates, technical details, commitments>
<Be specific: quote key sentences where precision matters>

## What's new vs hub
<After skimming current hub docs: what in this source is NOT yet reflected in the hub?>
<What in this source CONTRADICTS what's in the hub?>

## Proposed integration
<Which hub docs (01–07+) should be updated, and with what specific content?>
```

---

## Step 3.5 — Date gate (mandatory, before any move)

**No source leaves `_inbox/` without a resolved date.** See STANDARD.md → Governance Layer → Rule 1.

1. Look for a date in the document itself — issue/version date, sent date, meeting date, "as of" line.
   Record the value **and how it was derived**.
2. Add or refresh the source's row in `sources/dates-register.md`.
3. If no date is found, set the row to `MISSING`, **present the register to the hub owner and ask**.
   Do not proceed to the move: the file stays in `_inbox/` and the date question rides the
   proposal — this is the one thing that holds a file in the inbox.
4. A source may only be moved out of `_inbox/` when its row is `CONFIRMED`,
   `UNKNOWN — reconstruction pending`, or `N/A — reference artifact` (owner-marked; reference
   artifacts are excluded from timelines).
5. **Never guess or backfill.** An inferred date is `ESTIMATED` with its basis stated, and stays that
   way until the owner confirms it.

Record the resolved date in the digest header and in the proposal.

## Step 4 — Reconciliation check

After creating the digest:

1. Check if `reconciliation/` directory exists and contains topic files (`*.md` excluding `README.md`)
2. If no topic files exist: note "Reconciliation layer not yet initialised — no check performed."
3. If topic files exist:
   a. Read each topic file and extract all `SETTLED` facts
   b. Extract key claims from the digest (dates, decisions, roles, technical choices, commitments)
   c. Compare: does any claim in the digest contradict a SETTLED fact?
   d. **No contradiction:** note "Reconciliation check: no conflicts found."
   e. **Contradiction found:** for each conflict:
      - Create `reconciliation/_disputes/YYYY-MM-DD_<topic>_dispute.md` using the dispute template
        from `reconciliation/README.md`
      - The dispute file must not be applied — it is created directly as a working document

---

## Step 5 — File the source and create the proposal

**The move happens now, in the same act as the proposal — never deferred to approval** (added in
v1.64). Provided the date gate
passed (Step 3.5):

1. Move `_inbox/<original filename>` → `sources/<subfolder>/<original filename>`
2. Move `_inbox/<digest filename>` → `sources/<subfolder>/<digest filename>`
3. Create the proposal (below), naming where the files now live
4. Commit the move, the digest, the dates-register row and the proposal together, staging each
   path by name (`git add <path> ... && git commit -m "intake: <slug>"`) — never a blanket add

An ingested source is **evidence**, kept unmodified as permanent reference, so filing it asserts
nothing about the hub's content: if the owner later rejects the proposal, the hub documents do
not change and the source stays in `sources/` as the record of what was received. The provenance
entry in `sources/transcript-index.md` is a monitored-document edit and still rides the apply.

Create `changes/<YYYY-MM-DD>_agent_<slug>_proposal.md`:

Derive `<slug>` from the source filename: lowercase, hyphens (e.g. `partner-deck-mistral-intro`).

```markdown
# Proposal — <slug> (<YYYY-MM-DD>)

**Author:** Agent (via /km-intake)
**Date:** YYYY-MM-DD
**Hub docs affected:** <list>
**Source:** `sources/<subfolder>/<original filename>` (filed at intake from `_inbox/`)

---

## Summary

<One paragraph: what this source contains and what it adds to the hub.>

## Reconciliation status

<"No conflicts found." OR list of dispute files created with one-line description of each conflict.>
<If disputes exist, add: ⚠ RECONCILIATION REQUIRED — see dispute files listed above.>

---

## Changes

### 1 · `<hub-doc>.md` — <add / update / restructure>

**Where:** <section name>
**Change:**
<Exact proposed content — specific enough to apply without ambiguity>

[Repeat for each affected hub doc]

---

## Post-apply steps (agent)

1. Update `sources/transcript-index.md` with a new provenance entry
2. Delete this proposal and its approval file
3. Commit the change, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`).
   Never stage with a blanket add: in synchronized storage a deletion is not durable, so an
   all-changes add can resurrect the files step 2 just deleted (Rule 3, "Stage explicitly")
4. Run `hub-scan.sh` to confirm clean state
```

For **team output** and **visual asset** files, the move likewise happens at intake — to
`working-docs/<topic>/` or `assets/architecture/` — and the proposal records it:

```markdown
# Proposal — file-record-<slug> (<YYYY-MM-DD>)

**Author:** Agent (via /km-intake)
**Date:** YYYY-MM-DD
**Source:** `<working-docs or assets/architecture>/<filename>` (filed at intake from `_inbox/`)
**Action:** Record only — the file is filed; this adds its provenance entry

---

## Summary

`<filename>` is a <team output / visual asset>, filed at intake. No digest needed. Approving
this records it in the provenance index; nothing else changes.

## Post-apply steps (agent)

1. Log in `sources/transcript-index.md`
2. Delete this proposal and its approval file
3. Commit, staging each touched path by name — never a blanket add
4. Run `hub-scan.sh`
```

---

## Step 6 — Report to user

Tell the user:
- What was found and classified, and where each file was filed
- Key findings from the digest (3–5 bullet points)
- Reconciliation status (clean or list of disputes)
- Any file HELD in `_inbox/` by the date gate, with its `MISSING` register row and the ask
- Proposal path: `changes/<filename>`
- **Next step:** review the proposal, then either:
  - Create `changes/<YYYY-MM-DD>_<slug>_approval.md` using `APPROVAL_TEMPLATE.md`, OR
  - Confirm approval in chat ("apply this") and the agent applies immediately

---

## Notes

- Never edit hub docs directly in this skill — always through the proposal
- For password-protected or unreadable files: report and stop; do not guess content
- For very large files (100+ pages): summarise key sections; note that full text is in the source file
- Initials `agent` are used in the proposal filename when no contributor initials are specified
- If the user says "apply immediately" after reviewing the digest in chat, apply the proposal and perform post-apply steps without waiting for a separate approval file
