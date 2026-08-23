# MCP query surface — optional, agent-only

## Quarantined at v1.40. Do not enable it. It serves nothing.

Every entry point of this surface refuses. It returns no entity notes, no listings, no query
matches, and no resources, and starting it prints the quarantine and exits without opening a
transport.

**Why.** The standard requires every consuming surface to pass four gates before content travels:
committed at git HEAD, lifecycle-active, within the surface's access clearance, and listed in that
surface's projection manifest. This surface was written before that contract existed and was never
brought forward to it. Measured against the code:

| Required gate | `list_entities()` | `get_entity(id)` | `query_facts()` | `hub_scope()`, resources |
|---|---|---|---|---|
| Committed at git HEAD | enforced | enforced | enforced | enforced |
| Lifecycle-active | enforced | **not enforced** | enforced | **not enforced** |
| Within access clearance | **not implemented anywhere** | not implemented | not implemented | not implemented |
| In the projection manifest | **not implemented anywhere** | not implemented | not implemented | not implemented |

No sensitivity, clearance, or manifest logic exists anywhere in `server.py`. The content test in
`query_facts()` is a denylist rather than an allowlist, so a note carrying a restricted marking in
an ordinary directory was treated as content by construction.

**The claim this file used to make, and its correction.** This README previously stated, without
qualification, that retired and superseded notes are never returned. That was true of the listing
path and of `query_facts()`, and **false of `get_entity(id)`**, which returned the full raw text of
any committed note in an entity directory after a committed-state check alone. An operator who read
that sentence was told a control existed on every path and could reasonably have placed material
behind it. A guarantee that holds on one retrieval path is not written here as though it holds on
all of them.

**The premise underneath, also corrected.** This file used to say "committed = safe to expose".
Committing a fact records it. It does not decide who may read it. Committed state is evidence that
something passed review, never evidence that a given caller is cleared to receive it.

**This change quarantines. It does not repair.** The four gates are implemented and proved by the
separate change `audit-mcp-projection-gates`, which is what lifts the quarantine. The quarantine is
not lifted by a repair of one path while another stays unguarded.

**Nothing else changes.** The hub is plain markdown and is fully readable without this surface, by
humans and by agents that read files. A deployment that had this surface enabled loses it, which is
the intended outcome: it stops answering rather than answering under a contract it cannot keep. A
deployment that never enabled it is unaffected, and no hub content changes in either case. Delete
this folder and nothing else changes.

## Run

There is nothing to run while quarantined. The commands below are recorded so the instructions are
correct when the quarantine lifts, and so an operator who runs them today meets the quarantine
notice rather than an import error.

```bash
pip install "mcp>=1.29,<2"
python3 mcp/server.py /path/to/hub
```

**Python 3.10 or newer.** Every published `mcp` release, 1.0.0 onward, declares
`Requires-Python >=3.10`. The floor stated here previously was 3.8, which no configuration carrying
this dependency has ever satisfied.

**The pin is load-bearing.** `server.py` imports `mcp.server.fastmcp`, and `mcp` 2.0 removed that
module outright. An unpinned `pip install mcp` resolves to the 2.x line, where the import fails and
the server exits reporting that the package is missing when in fact it is installed at the wrong
major version. `mcp` 1.29.0 was verified to ship `mcp/server/fastmcp/` with `FastMCP` exported.
Moving to the 2.x interface is a migration this file does not contain.

## What it exposes

Nothing, while quarantined. When serving, the surface offered:

| Tool | |
|---|---|
| `hub_scope()` | Competency questions + what this hub does **not** cover. Call first. |
| `list_entities(type, status, owner)` | Active entity notes |
| `get_entity(id)` | One note |
| `query_facts(question)` | Where the facts are, so you can cite them |

Resources: `hub://about`, `hub://glossary`, `hub://index/{folder}`. These return file content and
are bound by the quarantine exactly as the four tools are.

## Two rules it will not bend

**It reads only the last commit.** Uncommitted edits, open proposals, inbox drafts and unresolved
disputes are invisible. That boundary holds, and it was never sufficient on its own, for the reason
above: commitment is not clearance. If you need something visible here, commit it through the normal
proposal/approval flow.

**Four tools, not forty.** Do not add one per entity type. Tool-selection accuracy degrades as the
surface grows; that is precisely the failure this design avoids.
