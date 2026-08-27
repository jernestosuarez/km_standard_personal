# Proposal — <slug> (<YYYY-MM-DD>)

**Author:** [Name] ([initials])
**Date:** YYYY-MM-DD
**Hub docs affected:** [e.g. 03_roadmap-milestones.md, 06_risks-decisions.md]
**Source:** [meeting title / transcript / document / date / "discussion in chat YYYY-MM-DD"]

---

## Summary

One paragraph: what is being proposed and why. Include the business or technical motivation.

---

## Changes

### 1 · `<filename>` — <add / update / remove>

**Where:** [section name, table row, or paragraph]
**Change:**
[Exact content to add or replace. Specific enough for the agent to apply without follow-up questions.
For table rows: include the full row. For paragraphs: include the full paragraph.]

**Rationale:** [why this change; cite source]

### 2 · `<filename>` — <add / update / remove>

**Where:** [section name]
**Change:**
[...]

**Rationale:** [...]

---

## Post-apply steps (agent)

1. Verify OKF `timestamp` updated to today on each modified doc
2. Move any inbox files to their destinations (if applicable)
3. Update `sources/transcript-index.md` change log
4. Delete this proposal and its approval file
5. Commit the change, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`).
   Never stage with a blanket add: in synchronized storage a deletion is not durable until the
   sync agent has agreed to it, so an all-changes add can resurrect the proposal and approval
   files step 4 just deleted and re-commit them as live (Rule 3, "Stage explicitly"; added in
   v1.64, drafted and unpublished: binds nothing until its own owner push).
6. Run `hub-scan.sh` to confirm clean state

---

**How to name this file:** `changes/YYYY-MM-DD_<initials>_<slug>_proposal.md`
Example: `changes/2026-07-01_JD_timeline-update_proposal.md`

**Matching approval file:** `changes/YYYY-MM-DD_<slug>_approval.md`
