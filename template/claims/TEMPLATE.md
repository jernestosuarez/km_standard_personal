---
type: Claim
title: <the statement, as one asserted sentence>
owner: "[[<stakeholder-note-name>]]"   # the NOTE name (file stem), not the display name
evidencedBy: [<resolvable pointer>, ...]   # INLINE list — Rule 5's provenance order applies: a pointer
                                           # a later reader can open, not a memory
assertion_method: directory | communication-evidence | meeting-evidence | stated | derived
                                  # `derived` = computed from records — an aggregate that crossed
                                  # under crossing law 2 (Rule 6)
confidence: high | medium | low   # evidence quality, NOT importance or strength.
                                  # Omit for facts adjudicated via reconciliation —
                                  # those are settled, not estimated.
# accessClass: internal   # optional (Rule 6): public | internal | restricted | record — absent means
#                         # internal; anything derived from restricted material inherits restricted.
#                         # Aggregation declassifies; extraction does not.
recordedAt: <YYYY-MM-DD>   # when the hub learned this fact (record time)
# validFrom: <YYYY-MM-DD>    # optional: when the fact starts holding in the world
# validUntil: <YYYY-MM-DD>   # optional: when it stops — a lapsed window is a staleness candidate
#                            # by declaration, not by guess (STANDARD.md §"Scheduled truth")
supersedes: ""   # "[[<note-name>]]" — the claim this replaces. An accepted record is
                 # superseded, never rewritten: the chain is the archaeology.
lifecycle: active   # active | superseded | retired — retired notes stay for the audit
                    # trail but are excluded from km-brief and index generation
tags: [claim]
resource: sources/transcript-index.md
last-reviewed: <YYYY-MM-DD>   # last confirmed still true; NOT the last edit
---

<Context for the statement in `title:` — scope, conditions, and anything a later reader needs to
re-open the evidence. The statement itself lives in `title:`, not here.>

<!--
One claim per file (Vault-LD: only frontmatter becomes triples).
Promotion is optional: reconciliation remains the adjudication process, and a settled topic-file
row only becomes a Claim note when it needs an independent lifecycle, an evidence chain, a
validity window, or a stable identity another hub can reference. Small hubs keep their tables.
A promoted row points here instead of restating the fact — single home of record.
-->
