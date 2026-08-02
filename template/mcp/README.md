# MCP query surface — optional, agent-only

A narrow MCP server exposing this hub's **committed** state to an agent.

**You do not need this.** The hub is plain markdown and works fully without it — for humans and for
agents that can read files. This exists so a *third party's* agent can ask a precise question without
being handed the whole directory. Delete this folder and nothing else changes.

## Run

```bash
pip install mcp
python3 mcp/server.py /path/to/hub
```

Python 3.8+. The only dependency is `mcp`.

## What it exposes

| Tool | |
|---|---|
| `hub_scope()` | Competency questions + what this hub does **not** cover. Call first. |
| `list_entities(type, status, owner)` | Active entity notes |
| `get_entity(id)` | One note |
| `query_facts(question)` | Where the facts are, so you can cite them |

Resources: `hub://about`, `hub://glossary`, `hub://index/{folder}`.

## Two rules it will not bend

**It reads only the last commit.** Uncommitted edits, open proposals, inbox drafts and unresolved
disputes are invisible. Committed = safe to expose. If you need something visible here, commit it
through the normal proposal/approval flow — that is the point, not an obstacle.

**Four tools, not forty.** Do not add one per entity type. Tool-selection accuracy degrades as the
surface grows; that is precisely the failure this design avoids.

Retired and superseded notes are never returned — they were true once, and returning them as current
is a lie of omission.
