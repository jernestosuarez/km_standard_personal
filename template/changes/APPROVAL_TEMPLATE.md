# Approval — <slug> (<YYYY-MM-DD>)

**Approver:** [Name]
**Date:** YYYY-MM-DD
**References proposal:** `changes/YYYY-MM-DD_<initials>_<slug>_proposal.md`
**Decision:** [APPROVED / APPROVED WITH CONDITIONS / REJECTED]

---

## Remarks

[Any conditions, scope limits, or additional context the agent must respect when applying.
Leave blank if none.]

## Items excluded

[If APPROVED WITH CONDITIONS: list any proposal items that should NOT be applied.
Leave blank if all items are approved.]

---

## Reason — REQUIRED if REJECTED or APPROVED WITH CONDITIONS

[Why. Be specific: what was wrong, or why each excluded item must not be applied.
For APPROVED WITH CONDITIONS, give a reason per excluded item.

This is not a formality. It is the highest-value knowledge the hub ever captures — you correcting
the record at the exact moment it matters — and it must not die with this file.]

## Rule this produces — REQUIRED if REJECTED or APPROVED WITH CONDITIONS

[The standing instruction that stops this recurring. Write it as an instruction to a future
contributor or agent, not as a comment about this proposal.

  Weak: "the budget figure was wrong"
  Good: "take budget figures from the signed SOW, never from a proposal draft"

Correct the behaviour that led to the answer, not the answer. If there genuinely is no general
lesson, write "no rule — one-off." That is a valid outcome and better recorded than invented.]

---

*Before deleting this file, the agent MUST capture the Reason and Rule above as a `corrections/`
note (`trigger: rejected-proposal`) and commit it. Only then are this file and the matching proposal
deleted. `changes/` is a workspace, not an archive — but the reason outlives it.
See STANDARD.md §"Never delete the reason".*

**How to name this file:** `changes/YYYY-MM-DD_<slug>_approval.md`
The slug must match the proposal slug exactly so the agent can pair them.
Example: proposal `2026-07-01_JD_timeline-update_proposal.md` → approval `2026-07-01_timeline-update_approval.md`
