# Reader tier scaffold

This folder is what a deployment installs to stand up a **read-only reader context**: a session that
produces outputs from the estate and authors none of it. It is a tier a deployment MAY adopt; a
deployment that runs no separate reading context runs exactly as it does today.

See `STANDARD.md` § *Reader tier: read-only consumption* for the full definition. This README is the
install-and-share note.

## What is in the scaffold

| File | What it is |
|---|---|
| `.km-tier` | The tier marker. First line is `reader`. A scoped reader adds a `scope:` line (below). |
| `CLAUDE.md` / `AGENTS.md` | The governing contract, stated in full. The two carry the same contract text and differ only by the mirror note `AGENTS.md` opens with; keep the contract equal. |
| `outputs/` | Where the Reader writes its results. Nothing here is part of the estate's record. |
| `correction notes/` | Optional. One-line defects the Reader is asked to hand back. |
| `.claude/settings.json` | A host permission file that denies git write commands (Claude Code). One second-layer control; see the honesty note below. |
| `reader-scan.sh` | Validates the reader declaration's shape. It validates the declaration, not isolation. |

## The two instruction mirrors, and what equality means here

`CLAUDE.md` and `AGENTS.md` ship the same contract under the standard's framework-agnostic convention:
`CLAUDE.md` is read by Claude Code, `AGENTS.md` by other agent surfaces. The guarantee that holds is
**equal contract text**, not byte equality. One difference is permitted and it is the only one:

- `AGENTS.md` opens with a short blockquote naming `CLAUDE.md` as its mirror. `CLAUDE.md` carries no
  such note, because a file does not introduce itself as the copy.

Any other difference between the two is a defect. Edit the contract in both, in the same change.

## Standing up a full reader

1. Copy this folder next to the estate, so the hubs and the Supervisor tier sit at `../`.
2. Leave `.km-tier` as `reader` (no scope line): a full reader may read the whole estate.
3. Open the folder in your agent console and ask questions. Outputs go to `outputs/`.

## Standing up a scoped reader

A **scoped reader** may read only a named, closed list of hubs and refuses everything else. To scope a
reader, add a `scope:` line to `.km-tier`:

```
reader
scope: hub-alpha, hub-beta
```

- The list is **closed**: name every hub the reader may read. An open scope (`*`, `all`, or an empty
  list) is not a scoped reader and `reader-scan.sh` rejects it.
- The list is judged **token by token**, never as one whole value, so an open token is rejected
  wherever it sits: `scope: *, hub-alpha` is rejected exactly as a bare `scope: *` is. An empty entry
  from a stray or repeated `,`, a hub named twice, and a token that is not a hub identifier (lowercase
  alphanumerics, hyphen separated) are each rejected and named. A declaration the scan cannot evaluate,
  such as a marker carrying two `scope:` lines, is refused rather than passed.
- A question needing material outside the listed hubs is answered "out of scope for this reader" and
  stopped, not answered partially.
- The scoped reader ignores its target hubs' own build files (their agent instructions, scans, hooks).
  It is a reader, not a hub agent; its contract is this folder's contract file.

## The important part: what is the wall

The contract file tells the reader to stay inside its scope. That is a **contract, not a wall**. It is
a rule the agent follows, not a barrier that stops anyone reading a file that is present.

**The real wall is what the hosting makes present and permitted.** A scoped reader's isolation is
**convention unless the hosting enforces it.** Genuine isolation comes from:

- **What is physically present:** share only the folders the reader is entitled to (this folder and the
  hubs in its scope), so the other knowledge areas are simply not in the workspace.
- **What is permitted:** the `.claude/settings.json` here denies git write commands, and a read-only
  share denies writes at the hosting layer. Note these deny **writing**, not reading; they do not wall
  off a tree that is present.

Real read isolation between a scoped reader and the hubs it may not see is separate installations,
separate storage, or separate credentials. The standard describes the boundary honestly and points at
the hosting for enforcement; it does not pretend the contract is the enforcement, and it does not
describe a scoped reader as an enforced tenant boundary.
