#!/usr/bin/env python3
"""
hub-mcp — a narrow MCP surface over a knowledge hub.

OPTIONAL AND AGENT-ONLY. The hub is plain markdown and works fully without this server; nothing
here is required to read, write, or govern a hub. This exists so *someone else's* agent can ask a
precise question without being handed the whole directory.

Two design rules, both load-bearing:

1. PUBLISH BOUNDARY — this server reads ONLY the last git commit (`git show HEAD:<path>`). It never
   reads the working tree. An uncommitted edit, an open proposal, an inbox draft or an unresolved
   dispute is invisible through this surface. "Committed = safe to expose" is the standard's rule and
   the server must not be the thing that weakens it.

2. FEW TOOLS, NOT MANY — four intent tools, not one per entity type. Tool-selection accuracy degrades
   as the surface grows; metadata is exposed as resources instead. Resist adding list_decisions,
   list_risks, list_stakeholders... that is the failure mode this design exists to avoid.

Requires: mcp (pip install mcp). Python 3.8+ — deliberately no modern-only syntax, so it
          runs on whatever interpreter the machine already has.
Run:      python3 mcp/server.py /path/to/hub
"""

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Optional, List, Dict

try:
    from mcp.server.fastmcp import FastMCP
except ImportError:
    sys.exit("hub-mcp requires the 'mcp' package:  pip install mcp")

HUB = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
ENTITY_DIRS = ["decisions", "risks", "stakeholders", "milestones", "partners",
               "relationships", "corrections", "claims"]

mcp = FastMCP("hub")


# ── committed state only ──────────────────────────────────────────────────────

def _git(*args):
    """Run git in the hub. Returns '' on failure rather than raising."""
    try:
        return subprocess.run(["git", "-C", str(HUB), *args],
                              capture_output=True, text=True, check=True).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def read_committed(relpath):  # -> Optional[str]
    """Read a file as of HEAD. Never touches the working tree — this is the publish boundary."""
    out = _git("show", f"HEAD:{relpath}")
    return out if out else None


def list_committed(prefix=""):  # -> List[str]
    """List committed .md paths. Empty prefix means the whole tree — git rejects an empty pathspec,
    so omit the argument entirely rather than passing ''."""
    args = ["ls-tree", "-r", "--name-only", "HEAD"]
    if prefix:
        args.append(prefix)
    out = _git(*args)
    return [l for l in out.splitlines() if l.endswith(".md")]


def _is_content(path):
    """True for hub knowledge; False for the hub's own machinery and for anything unpublished.

    A query surface that returns SKILL.md and README.md is answering questions about the tooling,
    not the initiative — noise that buries the fact the caller asked for.
    """
    # unpublished / in-flight — never exposed
    if path.startswith(("_inbox/", "changes/", "archive/")):
        return False
    # the hub's own machinery, not its knowledge
    if path.startswith((".claude/", ".agents/", "mcp/", "docs/")):
        return False
    name = Path(path).name
    if name in ("TEMPLATE.md", "README.md", "index.md", "HANDOVER.md", "hub-manifest.md"):
        return False
    return True


def parse_frontmatter(text):  # -> Dict[str, str]
    """Frontmatter only. Vault-LD: the body is not the graph."""
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    fm = {}
    for line in text[3:end].splitlines():
        line = re.sub(r"\s+#.*$", "", line)          # strip inline comment
        if ":" not in line or line.strip().startswith("#"):
            continue
        k, _, v = line.partition(":")
        v = v.strip().strip('"').strip("'")
        if v:
            fm[k.strip()] = v
    return fm


def load_entities():  # -> List[Dict[str, str]]
    out = []
    for d in ENTITY_DIRS:
        for path in list_committed(f"{d}/"):
            name = Path(path).name
            if name in ("TEMPLATE.md", "index.md", "README.md"):
                continue
            text = read_committed(path)
            if not text:
                continue
            fm = parse_frontmatter(text)
            if not fm.get("type"):
                continue
            # Retired facts were true once. Surfacing them as current is a lie of omission.
            if fm.get("lifecycle") in ("retired", "superseded"):
                continue
            fm["_id"] = Path(path).stem
            fm["_path"] = path
            out.append(fm)
    return out


# ── tools: four, deliberately ────────────────────────────────────────────────

@mcp.tool()
def list_entities(type="", status="", owner=""):
    """List active entity notes, optionally filtered by type, status, or owner.

    Returns committed state only. Retired and superseded notes are never returned.
    """
    rows = load_entities()
    if type:
        rows = [r for r in rows if r.get("type", "").lower() == type.lower()]
    if status:
        rows = [r for r in rows if r.get("status", "").lower() == status.lower()]
    if owner:
        o = owner.lower().strip("[]")
        rows = [r for r in rows
                if o in (r.get("owner", "") + r.get("decidedBy", "") + r.get("correctedBy", "")).lower()]
    if not rows:
        return "No matching entities in committed state."
    out = []
    for r in rows:
        d = dict((k, v) for k, v in r.items() if not k.startswith("_"))
        d["id"] = r["_id"]
        out.append(d)
    return json.dumps(out, indent=2)


@mcp.tool()
def get_entity(id):
    """Fetch one entity note by id (its filename without .md), as of the last commit."""
    for d in ENTITY_DIRS:
        text = read_committed(f"{d}/{id}.md")
        if text:
            return text
    return f"No committed entity note '{id}'. It may be uncommitted — this surface only exposes committed state."


@mcp.tool()
def query_facts(question):
    """Search committed hub docs and entity notes for a question's terms.

    Deliberately a keyword search, not an answer engine: it returns the facts and their location so
    the caller can reason and cite. It does not synthesise, and it cannot see uncommitted work.
    """
    terms = [t for t in re.findall(r"\w+", question.lower()) if len(t) > 3]
    if not terms:
        return "Ask a more specific question."
    hits = []
    for path in list_committed():
        if not _is_content(path):
            continue
        text = read_committed(path)
        if not text:
            continue
        low = text.lower()
        score = sum(low.count(t) for t in terms)
        if score:
            fm = parse_frontmatter(text)
            if fm.get("lifecycle") in ("retired", "superseded"):
                continue
            hits.append((score, path, fm.get("title", Path(path).stem)))
    if not hits:
        return "Nothing in committed state matches. This may be outside the hub's coverage — check hub_scope()."
    hits.sort(reverse=True)
    return json.dumps([{"path": p, "title": t, "matches": s} for s, p, t in hits[:10]], indent=2)


@mcp.tool()
def hub_scope():
    """What this hub is for, what it answers, and — critically — what it does NOT cover.

    Call this first. A hub cannot answer everything; the boundary tells you when to route elsewhere
    rather than assume silence means 'no'.
    """
    brief = read_committed("01_project-brief.md") or ""
    out = {}
    for heading in ("Competency questions", "What this hub does not cover", "Scope"):
        m = re.search(rf"^## {re.escape(heading)}\s*$(.*?)(?=^## |\Z)", brief, re.M | re.S)
        out[heading] = m.group(1).strip() if m else "not declared"
    out["_warning"] = ("Absence of a fact here does not mean it is false — it may simply be outside "
                       "this hub's coverage. Check 'What this hub does not cover' and route.")
    return json.dumps(out, indent=2)


# ── resources: metadata, not tools ───────────────────────────────────────────

@mcp.resource("hub://about")
def about():
    return read_committed("00_about.md") or "not available"


@mcp.resource("hub://glossary")
def glossary():
    return read_committed("07_glossary.md") or "not available"


@mcp.resource("hub://index/{folder}")
def folder_index(folder):
    if folder not in ENTITY_DIRS:
        return f"Unknown folder. Known: {', '.join(ENTITY_DIRS)}"
    return read_committed(f"{folder}/index.md") or "no index — run build-indexes.sh and commit"


if __name__ == "__main__":
    if not _git("rev-parse", "--is-inside-work-tree"):
        sys.exit(f"{HUB} is not a git repository. This surface reads committed state; there is none.")
    mcp.run()
