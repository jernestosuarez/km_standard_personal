# Skill: km-brief — Generate an Audience-Tailored Artifact

You have been invoked as `/km-brief`. Generate a memo, briefing, or status report by querying this
hub's entity notes (`decisions/`, `risks/`, `milestones/`, `stakeholders/`, `partners/`) rather than
freehand-reading and re-synthesizing the numbered hub docs from scratch. This is the **push** side of
the hub: drafting is free, but sending anything externally still goes through the normal
proposal/approval workflow (Rule 2) — this skill does not bypass it.

**Read-only query, only reflecting settled state.** Only read entity notes and hub docs as they exist
in the current git commit (`HEAD`). If `hub-scan.sh`'s `[ INTEGRITY ]` section reports any uncommitted
or untracked file, surface that to the user before drafting — an artifact generated from uncommitted
facts isn't reproducible or auditable. This is the standard's "committed = safe to expose" principle:
the git commit is the publish boundary for both push and pull.

---

## Step 1 — Ask (if not already given)

- **Audience:** e.g. "upper management", "the team", a named partner.
- **Format:** briefing / status report / memo (ask, or infer from audience — management defaults to
  briefing, team defaults to status report).

---

## Step 2 — Query entity notes

Read every `*.md` file in `decisions/`, `risks/`, `milestones/`, `stakeholders/`, `partners/`,
excluding `TEMPLATE.md`. For each, extract its frontmatter (`type`, `status`, `owner`/`decidedBy`,
dates) and its one-paragraph body.

Filter and rank by audience:

| Audience | Include | Detail level |
|---|---|---|
| Upper management | Open decisions, open/high-impact risks, upcoming milestones (`status: planned` or `in-progress`) | Top-level: one line per fact, no internal process detail |
| The team | All entity notes regardless of status | Full: include narrative body, not just frontmatter |
| A named partner | Only entities that link to that partner (via `owner`, or a wiki-link in the body referencing the partner's note) | Only what's relevant to that partner's relationship |

If the audience doesn't match one of these, ask a clarifying question rather than guessing scope.

---

## Step 3 — Draft the artifact

Write `working-docs/<topic>/<YYYY-MM-DD>_<audience-slug>_<format>.md` with OKF frontmatter:

```markdown
---
type: brief
title: <Format> for <Audience> — <YYYY-MM-DD>
description: <One sentence: what this covers and for whom.>
tags: [brief, generated]
resource: working-docs/
lifecycle: active
timestamp: YYYY-MM-DD
---

# <Format> for <Audience> — <YYYY-MM-DD>

## Decisions
- <one line per included decision> — [[decision-slug]]

## Risks
- <one line per included risk> — [[risk-slug]]

## Milestones
- <one line per included milestone> — [[milestone-slug]]

<Additional sections as the audience/format calls for — narrative synthesis is fine, but every
fact stated must carry a wiki-link back to its source entity note. Never restate a fact without a
traceable link — that link is the artifact's provenance.>
```

`<topic>` is a short slug for the audience or purpose (e.g. `management-briefings`,
`partner-updates`). Reuse an existing `working-docs/` subfolder if one already fits.

**If this artifact replaces an earlier one for the same purpose, supersede it in the same act.**
The new file carries `supersedes: <path>`; the old file is changed to `lifecycle: superseded` plus
`superseded-by: <path>`. Two documents claiming the same purpose while both `lifecycle: active` is
a defect, not a filing choice (STANDARD.md §"Currency of generated documents", rules 2 and 5).
Never infer that the older one is dead from its date or its folder.

---

## Step 4 — Report to user

- Draft path: `working-docs/<topic>/<filename>`
- One-line summary of what it covers and for whom
- **No proposal/approval was needed to draft this** — it's team output, per the existing governance
  (`working-docs/README.md`).

---

## Step 5 — If sending externally

Promoting the draft to `shareable/` (or otherwise sending it outside the team) requires the normal
proposal/approval workflow — see `shareable/README.md`. Once that proposal is approved, applied, and
committed:

1. Note the commit hash the artifact was generated from (`git log -1 --format=%H` at draft time, or the
   apply commit itself).
2. Add a row to `sources/publication-log.md`: date sent, artifact, audience, the commit, and who sent it.
3. Commit that log update along with the rest of the apply (same commit, or a follow-up one) — do not
   leave it uncommitted.
