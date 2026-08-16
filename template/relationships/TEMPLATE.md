---
type: RelationshipAssertion
title: <subject> <predicate> <object>
subject: "[[<stakeholder-note-name>]]"
predicate: <see STANDARD.md § Relationship layer>
object: "[[<stakeholder-note-name>]]"
scope: [<topic or initiative slug>, ...]
confidence: high | medium | low
assertion_method: directory | directory-chain | communication-evidence | meeting-evidence | stated
evidence: [<resolvable reference: source path, page ID, or export + date>]
observed_at: <YYYY-MM-DD>
# accessClass: internal   # optional (Rule 6): public | internal | restricted | record — absent means
#                         # internal. This layer describes people: restricted by default is the norm,
#                         # via the sensitivity marker (see § Relationship layer, Sensitivity).
lifecycle: active   # active | superseded | retired. A relationship that ended is superseded, never deleted.
tags: [relationship]
resource: sources/transcript-index.md
---

<Optional note. State what this edge is for and any caveat.>

<!--
One assertion per file (Vault-LD: only frontmatter becomes triples).
`confidence` is epistemic — how good the evidence is. It is NOT relationship strength,
importance, or a performance judgement. Never use this layer evaluatively.
`evidence` must be resolvable by a later reader. If it is not, say so and lower `confidence`.
-->
