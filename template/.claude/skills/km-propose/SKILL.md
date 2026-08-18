---
name: km-propose
description: Use when a hub document, entity note or governance file should change from a discussion, decision or owner correction rather than an inbox file. /km-propose drafts the proposal.
---

# Skill: km-propose — Draft a Change Proposal

> **If the hub owner corrected you in chat rather than asking for a proposal**, you still owe an
> artifact: write a `corrections/` note (`trigger: owner-correction`) capturing the rule the
> correction produces, and commit it with the change. The chat path is the most-used path and the
> easiest place to lose knowledge — a proposal leaves a file behind, a conversation leaves nothing.
> See STANDARD.md §"The exception must produce the same artifact as the formal path".

You have been invoked as `/km-propose`. Help the user draft a change proposal for one or more
hub documents, following the proposal/approval workflow.

This skill **creates a proposal file only** — hub docs are not touched until approval.

---

## When to use this skill

- A contributor wants to suggest hub doc edits based on a discussion, decision, or new information
  that did not arrive as a file in `_inbox/`
- The hub owner wants to record a decision made verbally or in chat
- Governance files (CLAUDE.md, README.md, hub-scan.sh) need updating

If the change originates from a file in `_inbox/`, use `/km-intake` instead — it handles
classification, digest, reconciliation check, and proposal creation in one workflow.

---

## Step 1 — Understand the proposed change

If the user has already described the changes in chat, extract the details from that description
and confirm them — don't ask questions whose answers are already in the conversation.

Otherwise, ask the user:
- **Which hub doc(s) are affected?** (e.g. `03_roadmap-milestones.md`, `06_risks-decisions.md`)
- **Does this describe a decision, risk, stakeholder, milestone, or partner?** If so, which type, and
  what are its typed fields (see the matching entity template: `decisions/TEMPLATE.md`,
  `risks/TEMPLATE.md`, `stakeholders/TEMPLATE.md`, `milestones/TEMPLATE.md`, `partners/TEMPLATE.md`) —
  the proposal will target the entity note itself, plus a one-line link in the matching rollup doc.
- **What changes are proposed?** (specific additions, edits, or removals — the more specific, the better)
- **What is the source or rationale?** (meeting date and title, decision, email, discussion in chat)
- **Author initials** for the proposal filename

---

## Step 2 — Check for conflicts with reconciliation

Before drafting, check if any proposed change touches a fact that is `SETTLED` in
`reconciliation/*.md` topic files, excluding `README.md`.

- If no topic files exist: proceed without a reconciliation check.
- If a proposed change would update a settled fact: flag this to the user.
  Updating a settled fact requires the hub owner to explicitly choose option A/B/C from the
  reconciliation process (see `reconciliation/README.md`). Include a note in the proposal.

---

## Step 3 — Draft the proposal

Create `changes/<YYYY-MM-DD>_<initials>_<slug>_proposal.md`:

- `<YYYY-MM-DD>` = today's date
- `<initials>` = author's initials (e.g. `JS` for Jane Smith); use `agent` if not provided
- `<slug>` = lowercase kebab-case topic (e.g. `timeline-march-2027`, `new-partner-acme`, `stack-update`)

```markdown
# Proposal — <slug> (<YYYY-MM-DD>)

**Author:** <Full name> (<initials>)
**Date:** YYYY-MM-DD
**Hub docs affected:** <comma-separated list of filenames>
**Source:** <meeting title + date / decision / email / "discussion in chat YYYY-MM-DD">

---

## Summary

<One paragraph: what is being changed and why. Include the business or technical motivation.>

---

## Changes

### 1 · `<filename>` — <add / update / remove>

**Where:** <section name, table row, or paragraph identifier>
**Change:**
<The exact content to add or replace. For table rows: include the full row. For new paragraphs:
include the full paragraph text. For removals: quote what is being removed.
Be precise enough that the agent can apply without asking follow-up questions.>

**Rationale:** <why this specific change; cite source>

[Repeat block for each additional file]

---

## Post-apply steps (agent)

1. Verify OKF frontmatter `timestamp` is updated to today's date on each modified doc
2. Log in `sources/transcript-index.md` change log
3. Delete this proposal and its approval file
4. Commit the change, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`)
5. Run `hub-scan.sh` to confirm clean state
```

---

## Step 4 — Report to user

Tell the user:
- Proposal created at: `changes/<filename>`
- Summary of what it proposes (2–3 sentences)
- If reconciliation flags were raised: describe them
- **Next step options:**
  a. **Async approval:** reviewer creates `changes/<YYYY-MM-DD>_<slug>_approval.md` using `APPROVAL_TEMPLATE.md`
  b. **In-chat approval:** hub owner says "apply this" → agent applies immediately without a separate file

---

## Notes

- Do not include speculative content — only what the user has confirmed
- Do not pre-fill content that requires hub owner judgement (e.g. which facts are settled)
- For changes to `hub-scan.sh` or `CLAUDE.md`: note in the proposal that these are governance
  infrastructure files; the hub owner's explicit instruction in chat is sufficient approval
- OKF `timestamp` must always be updated on any modified hub doc — include this in post-apply steps
- Keep proposals atomic: one topic per proposal. If the user wants to change five unrelated things,
  create five separate proposals (ask first whether they want them combined or separate)
