# Inbox — Drop Files Here

**All** incoming files land here first — no exceptions.

**What goes here:**
- Partner decks, vendor presentations, external PDFs
- External documents, contracts, MoUs
- Raw transcript exports and meeting notes
- Team output files (memos, briefings, strategy notes)
- Architecture images and diagrams
- Any other file to be filed, digested, or moved into the hub

**The arrival of a file here is not a decision** (added in v1.64). Dropping a file is the request
to process it, so intake runs
without waiting for a further word: the agent classifies the file, digests it where it is a
source, resolves its date, and **files it at its retained home in the same act** (`sources/`,
`working-docs/`, `assets/architecture/`), producing a proposal in `changes/`.

**Only the resulting proposal waits on the owner.** No hub document changes without approval —
that rule is untouched; what no longer waits is the move out of this folder.

**The one hold is the date gate:** a source whose date cannot be resolved stays here, with a
`MISSING` row in `sources/dates-register.md` and the question put to the hub owner. Nothing else
sits in this folder between sessions.

**Run `/km-intake` to process files here** (a session that finds files here runs it without
being asked).

> This folder should be empty when nothing is pending and no date question is open.
