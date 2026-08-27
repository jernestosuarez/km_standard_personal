# Shareable

Sanitised documents safe for sharing outside the team: with partners, clients, other UN agencies,
or the public.

**Before placing a file here, verify it contains no:**
- Budget figures or financial details not intended for external sharing
- Personnel or HR information
- Client-confidential data
- Internal governance details not relevant to the external audience
- Draft or unapproved content

Files here represent the team's public-facing outputs. They should be polished, approved, and
ready to share as-is.

## Typical content

- Overview decks for partner briefings (sanitised of internal notes)
- Published reports and white papers
- Framework documents intended for broad distribution (e.g. this KM standard)
- Use-case descriptions for client or partner consumption

## Governance note

Files in `shareable/` are not **integrity-monitored** by `hub-scan.sh`: the scan does not require
them to be committed or to carry OKF frontmatter. They are an **outbound surface**, and the
`[ RESTRICTED ]` check reads every file here on every scan: a restricted marker, a restricted
note's name, or a verbatim line of restricted content in this folder fails the scan as an error
(STANDARD.md §"Validating the graph"). This paragraph previously said the folder was "not
monitored", which was false as shipped — the restricted lint has read this surface since v1.16 —
and a directory contract that contradicts the instrument beside it teaches the reader to trust
the wrong one (corrected in v1.63, drafted and unpublished: the correction binds nothing until
its own owner push).

Moving a file here from `_inbox/` or `working-docs/` follows the normal proposal/approval
workflow, and each outward send is logged in `sources/publication-log.md`.
