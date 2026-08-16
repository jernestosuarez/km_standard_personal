---
type: SourceSystem
title: <System name>
systemKind: erp | crm | hris | finance | dms | ticketing | transcription | idp | vault-export | other
uriScheme: <scheme://>   # how pointers into this system are written, e.g. gdrive://, notion://, transcript://
connector: manual | mcp:<server-name> | api   # `manual` = the inbox is the connector — the common, fully valid case
defaultAccessClass: public | internal | restricted | record   # class stamped on extracts from this system
                                                              # unless the owner rules otherwise (Rule 6)
refreshPolicy: on-demand | daily | weekly | none   # `none` declares a snapshot honestly — the batch
                                                   # degenerate case of the gateway
owner: "[[<stakeholder-note-name>]]"   # the NOTE name (file stem), not the display name
tags: [source-system]
resource: sources/dates-register.md
last-reviewed: <YYYY-MM-DD>   # last confirmed still true; NOT the last edit
lifecycle: active   # active | superseded | retired — retired notes stay for the audit
                    # trail but are excluded from km-brief and index generation
---

<One paragraph: what this system masters, what the hub takes from it, and on what terms.>

<!--
One system per file (Vault-LD: only frontmatter becomes triples).
Records stay in this system; the hub holds claims about them, with pointers written in
`uriScheme` form (STANDARD.md, Rule 6 — the record boundary and its four crossing laws).
This note is the SYSTEM-level contract. Per-SOURCE dates stay in sources/dates-register.md —
the date gate's control point — and every source arriving from this system is still gated there.
Where connectors are in use, this note is the connector's declarative manifest
(STANDARD.md §"Source connectors (SoR gateway)").
-->
