#!/usr/bin/env python3
"""
hub-mcp — a narrow MCP surface over a knowledge hub.

QUARANTINED AT v1.40. THIS SURFACE SERVES NOTHING.

Every content-returning entry point below refuses. The surface was written before the standard's
projection contract existed and it does not enforce that contract. The standard requires a consuming
surface to pass four gates before content travels: committed at git HEAD, lifecycle-active, within
the surface's access clearance, and listed in that surface's projection manifest. Measured against
this implementation:

  * the listing path applied gates 1 and 2, and neither 3 nor 4;
  * the direct-identifier path applied gate 1 alone, so an identifier lookup returned retired and
    superseded notes in full, which the listing path correctly withheld;
  * the query path applied gates 1 and 2, and neither 3 nor 4;
  * `hub_scope()` and the three resources applied gate 1 alone.

Access clearance and projection-manifest logic are implemented nowhere in this file. The content
test is a denylist, so a note carrying a restricted marking in an ordinary directory was content by
construction.

Refusing is the correct behaviour for a surface whose contract it cannot keep. It does not degrade
to the listing path because that path happened to enforce lifecycle: a surface that answers at all
invites reliance, and reasoning about which of four gates applies on which path is exactly what
failed here. The quarantine lifts only when every required gate is enforced on every content-
returning path and proved by negative test, under the change `audit-mcp-projection-gates`. It is not
lifted by a repair of one path while another stays unguarded.

OPTIONAL AND AGENT-ONLY. The hub is plain markdown and works fully without this server; nothing
here is required to read, write, or govern a hub. This exists so *someone else's* agent can ask a
precise question without being handed the whole directory.

Two design rules, both load-bearing:

1. PUBLISH BOUNDARY — this server reads ONLY the last git commit (`git show HEAD:<path>`). It never
   reads the working tree. An uncommitted edit, an open proposal, an inbox draft or an unresolved
   dispute is invisible through this surface. That boundary holds, and it was never sufficient on its
   own: committing a fact records it, and decides nothing about who may read it. The earlier rule
   "committed = safe to expose" is withdrawn as this surface's premise.

2. FEW TOOLS, NOT MANY — four intent tools, not one per entity type. Tool-selection accuracy degrades
   as the surface grows; metadata is exposed as resources instead. Resist adding list_decisions,
   list_risks, list_stakeholders... that is the failure mode this design exists to avoid.

Requires: mcp 1.x, the last major line that ships the FastMCP interface this file imports.
          Install it pinned:  pip install "mcp>=1.29,<2"
          mcp 2.0 removed `mcp.server.fastmcp` outright, so an unpinned `pip install mcp` resolves
          to a release this file cannot import.
          Python 3.10 or newer. Every published mcp release, 1.0.0 onward, declares
          Requires-Python >=3.10, so the interpreter floor is set by the dependency and not by the
          syntax used here.
Run:      python3 mcp/server.py /path/to/hub
          While quarantined this reports the quarantine and exits without starting a server.
"""

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Optional, List, Dict


# ── quarantine ────────────────────────────────────────────────────────────────
#
# One switch. It is the single place the serving state is declared, and every content-returning
# entry point below consults it. Flipping it to False re-enables a surface that does not enforce
# the standard's projection contract, which is the defect this quarantine exists to close, so it is
# flipped only by the change that implements and proves the four gates.

QUARANTINED = True
QUARANTINE_VERSION = "v1.40"
QUARANTINE_LIFTED_BY = "audit-mcp-projection-gates"

QUARANTINE_REASON = (
    "This surface is quarantined at %s and returns no hub content.\n"
    "\n"
    "Reason: it does not enforce the projection contract the standard requires of a consuming\n"
    "surface. Of the four required gates (committed at git HEAD, lifecycle-active, within the\n"
    "surface's access clearance, listed in the surface's projection manifest), it enforced\n"
    "committed state everywhere, lifecycle on the listing and query paths only, and access\n"
    "clearance and manifest membership nowhere at all. A direct identifier lookup returned retired\n"
    "and superseded notes in full. The surface's own documentation stated a lifecycle guarantee it\n"
    "did not keep on that path.\n"
    "\n"
    "Committing a fact records it. It does not decide who may read it, so committed state is not\n"
    "grounds for disclosure.\n"
    "\n"
    "This is a quarantine and not a repair. The gates are implemented by the separate change '%s',\n"
    "and the quarantine lifts only when every required gate is enforced on every content-returning\n"
    "entry point and each excluded content class is proved unreachable by identifier lookup and by\n"
    "query. Until then the hub remains fully readable as plain markdown through its own governed\n"
    "channels.\n"
) % (QUARANTINE_VERSION, QUARANTINE_LIFTED_BY)


def quarantine_notice():
    """The operator-facing statement of the quarantined state and its reason."""
    return "hub-mcp: QUARANTINED\n\n" + QUARANTINE_REASON


def _refuse(entry_point):
    """The caller-facing refusal. Returns no content, and says why rather than reading as empty."""
    return ("REFUSED: hub-mcp entry point '%s' served no content.\n\n" % entry_point) + QUARANTINE_REASON


# Reported before the dependency import, so an operator following the install instructions in a
# clean environment meets the quarantine rather than an ImportError from a missing or wrong-major
# `mcp`. A quarantined surface has no reason to reach its transport at all.
if QUARANTINED and __name__ == "__main__":
    sys.stderr.write(quarantine_notice())
    sys.exit(2)

try:
    from mcp.server.fastmcp import FastMCP
except ImportError:
    sys.exit("hub-mcp needs the FastMCP interface, which ships in mcp 1.x only:  "
             'pip install "mcp>=1.29,<2"   (mcp 2.0 removed mcp.server.fastmcp)')

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

    QUARANTINED: refuses and returns no entity records.

    When serving, this path returned committed state only, and withheld retired and superseded
    notes. It applied no access-clearance and no projection-manifest gate, so a note carrying a
    restricted marking was listed with its frontmatter like any other.
    """
    if QUARANTINED:
        return _refuse("list_entities")
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
    """Fetch one entity note by id (its filename without .md), as of the last commit.

    QUARANTINED: refuses and returns no entity content.

    This was the sharpest of the surface's defects. When serving, it applied the committed-state
    gate alone, with no lifecycle, clearance, or manifest check, so an identifier lookup returned
    the full raw text of retired and superseded notes that the listing path withheld.
    """
    if QUARANTINED:
        return _refuse("get_entity")
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

    QUARANTINED: refuses and returns no matches.

    When serving, this path applied the committed-state and lifecycle gates and neither of the other
    two, and its content test is a denylist: anything outside a short list of excluded directories
    and filenames is content by construction, so a restricted note in an ordinary directory had its
    path and title returned.
    """
    if QUARANTINED:
        return _refuse("query_facts")
    terms =[t for t in re.findall(r"\w+", question.lower()) if len(t) > 3]
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

    QUARANTINED: refuses and returns no brief content. It returned three named sections of the
    project brief verbatim under the committed-state gate alone.
    """
    if QUARANTINED:
        return _refuse("hub_scope")
    brief = read_committed("01_project-brief.md") or ""
    out = {}
    for heading in ("Competency questions", "What this hub does not cover", "Scope"):
        m = re.search(rf"^## {re.escape(heading)}\s*$(.*?)(?=^## |\Z)", brief, re.M | re.S)
        out[heading] = m.group(1).strip() if m else "not declared"
    out["_warning"] = ("Absence of a fact here does not mean it is false — it may simply be outside "
                       "this hub's coverage. Check 'What this hub does not cover' and route.")
    return json.dumps(out, indent=2)


# ── resources: metadata, not tools ───────────────────────────────────────────
#
# These return file content too, so the quarantine binds them exactly as it binds the tools. They
# are not in the gate matrix that framed the finding, which is why each one is named here: a
# refusal that covers only the paths someone remembered to enumerate is not a refusal.

@mcp.resource("hub://about")
def about():
    if QUARANTINED:
        return _refuse("hub://about")
    return read_committed("00_about.md") or "not available"


@mcp.resource("hub://glossary")
def glossary():
    if QUARANTINED:
        return _refuse("hub://glossary")
    return read_committed("07_glossary.md") or "not available"


@mcp.resource("hub://index/{folder}")
def folder_index(folder):
    if QUARANTINED:
        return _refuse("hub://index/{folder}")
    if folder not in ENTITY_DIRS:
        return f"Unknown folder. Known: {', '.join(ENTITY_DIRS)}"
    return read_committed(f"{folder}/index.md") or "no index — run build-indexes.sh and commit"


if __name__ == "__main__":
    # Unreachable while QUARANTINED: the notice above exits before the dependency import. Kept as
    # the second half of the same guard, so the surface cannot start silently if the module is
    # reached by any other route.
    if QUARANTINED:
        sys.stderr.write(quarantine_notice())
        sys.exit(2)
    if not _git("rev-parse", "--is-inside-work-tree"):
        sys.exit(f"{HUB} is not a git repository. This surface reads committed state; there is none.")
    mcp.run()
