---
type: Risk
title: <Risk name>
impact: high | medium | low
status: open | mitigated | closed
owner: "[[<stakeholder-note-name>]]"   # the NOTE name (file stem), not the display name
tags: [risk]
resource: sources/transcript-index.md
last-reviewed: <YYYY-MM-DD>   # last confirmed still true; NOT the last edit
confidence: high | medium | low   # evidence quality, NOT importance or strength.
                                  # Omit for facts adjudicated via reconciliation —
                                  # those are settled, not estimated.
# accessClass: internal   # optional (Rule 6): public | internal | restricted | record — absent means
#                         # internal; anything derived from restricted material inherits restricted
lifecycle: active   # active | superseded | retired — retired notes stay for the audit
                    # trail but are excluded from km-brief and index generation
supersedes: ""   # "[[<note-name>]]" — the note this replaces. An accepted record is
                 # superseded, never rewritten: the chain is the archaeology.
---

<Description of the risk and the mitigation plan.>
