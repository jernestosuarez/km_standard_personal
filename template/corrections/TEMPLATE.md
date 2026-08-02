---
type: Correction
title: <what was got wrong, in one line>
correctedBy: "[[<stakeholder-note-name>]]"
date: <YYYY-MM-DD>
trigger: rejected-proposal | dispute | owner-correction | agent-error
rule: <the standing rule this produces — the durable part; write it as an instruction>
supersedes: "[[<entity note this overrides, if any>]]"
lifecycle: active | superseded | retired
tags: [correction]
resource: <where the correction came from — proposal slug, dispute file, or session>
last-reviewed: <YYYY-MM-DD>   # last confirmed still true; NOT the last edit
confidence: high | medium | low   # evidence quality, NOT importance or strength.
                                  # Omit for facts adjudicated via reconciliation —
                                  # those are settled, not estimated.
---

<What was believed or done, and what is actually correct. Two or three sentences.
State the specific instance plainly — the durable part belongs in `rule:`, not here.>

<!--
`rule:` is the point of this note. Correct the behaviour that led to the answer, not the answer.
Fixing an output resolves one instance; a rule resolves the class and survives after the incident
is forgotten. If you cannot write a rule, this is probably not a Correction — it may just be an edit.

`lifecycle:` — a rule that no longer applies must be retired, not left binding. Agents treat every
`active` rule as binding, so a stale rule is worse than no rule. Retired notes are kept for the
audit trail and excluded from agent reads and generated artifacts.

One correction per file (Vault-LD: only frontmatter becomes triples).
-->
