#!/usr/bin/env python3
"""KM Cockpit — the owner decision surface, a side component of the KM Standard.

The cockpit renders the owner queue (QUEUE.md) as full-context decision cards and captures the
owner's answers. It is a SURFACE, NOT A PEN: it never executes anything and never writes estate
state; every answer becomes committed estate artifacts only through a supervisor (or single-hub
agent) session, under the same governance as a chat answer. See SPEC.md in this directory for
the component's normative contract.

Lineage (behavior shipped exactly as proven in the reference deployment): phases 1+2 + 2.5
decision briefs; the display-contract ruling (canonical row schema Id|Since|Defaults|Decision|
Options, legacy shapes still parse; links resolved relative to the file that carries them with
safe #fragment pass-through; semantic §5 brief validation; gated records rendered in a separate
non-actionable "Preparing for you" group); the pending-proposal state alignment (every pending
hub proposal listed with its truthful lifecycle state — awaiting owner decision / answered
"<verb>" awaiting Supervisor execution / queued / execution recorded, reconciliation pending /
directive issued, waiting on the hub's own agent / needs decision routing — matched through the
queue row and its canonical decision brief, live or archived, with hub attention badges derived
from the same states); and the supervisor-actions owner interaction ("Waiting on KM Supervisor"
with per-action request controls — Ask for update / Run next / Hold — each a REQUEST through the
questions pipeline under the stable ref `supervisor-action:<action-id>`, validated live against
the SUPERVISOR-ACTIONS block, never mutating QUEUE.md; `reply` keyed to the same ref lands back
on the action row).

v1.64 brings the component up to the reference deployment's proven lead (SPEC.md carries each
rule): ARITY decides the canonical row schema and an unreadable Defaults cell fails loudly as a
PARSE ERROR card, never a wrong title; a row the queue itself marks ANSWERED (the durable
Decision-cell marker, or the machine block's appended `answered:` field) renders answered
whatever the rotating stores say, and an answered or executed row swaps its tier badge for its
state badge — two states that mean different things never look alike; the LANE axis groups the
decisions board (knowledge | machinery | standard | hand, the machine block's appended 6th
field); informational items carry DISMISS (owner-side view state, append-only, undo always);
every surface renders an item in exactly ONE home and refers to it elsewhere by a count with a
link; the Standard card resolves the PUBLISHED version from the configured publish branch's
committed history (draft H1s walked past), never the working tree; `pull` writes each consumed
answer's trace to the pickup log BEFORE truncating the pending store, so no ordering can lose a
record, and /activity shows the unattended pickups; /activity splits by ACTOR (your decisions /
agents / unattended), reading agent reports from an `agent-reports/` directory beside the queue
file when one exists; and the single-hub initiated read is date-shape checked, so an
unsubstituted placeholder cannot render a hub as initiated while the hub scan quarantines it.

Deployment is CONFIGURATION ONLY: a manifest (km-cockpit.json beside this file, or
$KM_COCKPIT_CONFIG) carries the estate root, queue path, hub-registry path, port, organization
name, state directory, and an optional standard-repo path (the tracked KM Standard checkout the
Home status card reads for its pinned version and push state; omit it and the card does not
render). The per-hub attribution map derives from the governed hub registry;
with no registry configured the cockpit runs in SINGLE-HUB mode against a hub-local queue file —
the same data contract, so minting a supervisor tier later is a manifest change, not a rebuild.

http://127.0.0.1:<port>
  /            home: live stats + urgency
  /decisions   full-context cards; ★ recommended; LIVE state (answered → queued → executed with
               links); per-card "Context" expander rendering linked sources inline; per-card
               "Ask" box — your question reaches the next session, its reply lands ON the card;
               a tier-A/B card is answerable ONLY with a passing decision brief
               (queue-briefs/<row-id>.md) — otherwise controls are disabled and the card states
               what is missing; the Ask channel stays open
  /activity    what your answers caused, newest first, with commits/links
  /view?p=     any estate .md rendered in-app · /open?p= opens locally
  Notifications: the server watches the queue; new tier-A cards and defaults within 24h fire a
  desktop notification (macOS `osascript`; best-effort no-op elsewhere).

CLI (session side):
  pull                 CONSUME pending ANSWERS: append to processed, log each consumption to the
                       pickup log, then truncate — in that order, so a crash loses no record
  questions            print unprocessed owner QUESTIONS, rotate to processed
  reply <id> "text"    attach a supervisor reply to a card (renders under it)
  exec <id> "note"     record that an answer was EXECUTED (note may carry markdown links)
  dismissed            LIST the owner's dismissed informational items — read-only, consumes nothing
  desk                 LIST the owner's effective desk ticks — read-only, consumes nothing
  queue-check [path]   fail-closed options/parse check (three exit codes; safe from status paths)
  selftest             regression fixtures only — needs no manifest, reads no live state

Local-only (binds 127.0.0.1, not configurable), stdlib-only, never published beside a reading
site or docs portal.
"""
import datetime
import html
import json
import os
import re
import subprocess
import sys
import threading
import time
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

# Estate bindings — all None until load_config() reads the deployment manifest. Every command
# except selftest requires the manifest; selftest runs on fixtures alone.
ROOT = None          # estate root (multi-hub workspace root, or the hub root in single-hub mode)
SUP = None           # governance dir: the directory holding the queue file (queue-briefs/ lives here)
QUEUE = None         # the queue file itself
BRIEFS = None        # SUP / "queue-briefs"
HUB_REGISTRY = None  # governed hub registry, or None in single-hub mode
PORT = 8485
ORG = "KM"           # organization name, display only
NOTIFY = True        # desktop notifications (manifest key "notifications"; macOS best-effort)
HUBS = {}            # hub key -> (display name, directory, keywords) — derived, never hardcoded
GOV_KEY = None       # the governance-tier pseudo-hub key (multi-hub mode only)
FALLBACK_KEY = "estate"  # attribution fallback when no keyword matches
INITIATED = set()    # hub directories with full governance (registry status `hub`)
STANDARD_REPO = None  # tracked KM Standard checkout for the status card, or None if not configured
STANDARD_PUBLISH_BRANCH = "main"  # manifest key standard_publish_branch; the branch whose
                                  # committed history the status card resolves the version from
PICKUP_LOG = None    # SUP / "answer-pickup-log.md" once configured: the consumption trace
AGENT_REPORTS = None  # SUP / "agent-reports" once configured: read-only agent activity source

# The PUBLISHED version the status card reports: the vX.Y of the newest publish-branch commit
# whose STANDARD.md H1 carries no draft qualifier. Resolved from committed history, never the
# working tree — a working-tree H1 mid-draft says "(vX.Y draft)", and reporting a drafted number
# as the pinned version is a wrong answer with full confidence (v1.64, from the reference
# deployment's dev-0018).
STD_PUBLISHED_H1_RE = re.compile(r"^#\s+.*\((v\d+\.\d+)(?:\s+([^)]*))?\)\s*$", re.I | re.M)
# Open queue rows about the standard itself (push/publish/RFC decisions) link from the card.
STANDARD_ROW_RE = re.compile(
    r"\brfc-\d+\b|\bkm[ -]standard\b|\bstandard\b[^|]{0,60}?\b(push|publish|version|draft)\b",
    re.I)

CFG = Path.home() / ".config/km-cockpit"


def _state_files():
    """(Re)derive the owner-side state paths from CFG. Separate estates on one machine must
    configure distinct state_dir values, or their answer stores collide."""
    global ANSWERS, PROCESSED, EXECUTIONS, QUESTIONS, QPROCESSED, QREPLIES, NOTIFIED, DISMISSED
    ANSWERS = CFG / "answers.jsonl"
    PROCESSED = CFG / "answers-processed.jsonl"
    EXECUTIONS = CFG / "executions.jsonl"
    QUESTIONS = CFG / "questions.jsonl"
    QPROCESSED = CFG / "questions-processed.jsonl"
    QREPLIES = CFG / "question-replies.jsonl"
    NOTIFIED = CFG / "notified.json"
    DISMISSED = CFG / "dismissed.jsonl"  # owner-side view state: {id, at} + {id, at, undo: true}


_state_files()


def _slug(name):
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-") or "hub"


def load_hubs():
    """Derive the per-hub attribution map from the governed hub registry — never a hardcoded
    list. Multi-hub: one entry per registry row (`| Folder | Status (hub/repo) | Owner |
    Routing keywords |`; key = folder slug, keywords = the row's routing keywords — the folder
    name itself always matches via hubs_of), plus a governance-tier pseudo-hub keyed `estate`.
    Single-hub (no registry configured, or the file absent): the estate root IS the hub — one
    entry, keywords from the hub's own `routing-keywords` deployment field, and that hub is the
    attribution fallback; a hub whose deployment binding records the initiation interview counts
    as initiated."""
    global HUBS, GOV_KEY, FALLBACK_KEY, INITIATED
    HUBS, INITIATED = {}, set()
    if HUB_REGISTRY is not None and HUB_REGISTRY.exists():
        try:
            raw = HUB_REGISTRY.read_text(encoding="utf-8", errors="replace")
        except OSError:
            raw = ""
        for line in raw.splitlines():
            s = line.strip()
            if not s.startswith("|"):
                continue
            cells = [c.strip() for c in s.strip("|").split("|")]
            if len(cells) < 4 or all(re.match(r"^:?-{2,}:?$", c) for c in cells if c):
                continue
            folder = cells[0].strip("*` ").strip()
            if not folder or folder.lower() == "folder":
                continue
            status = cells[1].strip("*` ").lower()
            kws = [k.strip().lower() for k in cells[3].split(",") if k.strip()]
            HUBS[_slug(folder)] = (folder.replace("_", " ").strip(), folder, kws)
            if status.startswith("hub"):
                INITIATED.add(folder)
        gov = SUP.name
        HUBS["estate"] = (f"Estate / {gov}", gov,
                          ["queue", "cockpit", "estate", "supervisor", "standard"])
        GOV_KEY, FALLBACK_KEY = "estate", "estate"
    else:
        key = _slug(ROOT.name)
        kws = []
        dep = ROOT / "km-deployment.md"
        if dep.exists():
            try:
                dep_raw = dep.read_text(encoding="utf-8", errors="replace")
            except OSError:
                dep_raw = ""
            # REGISTERED GAP, NOT CLOSED HERE (recorded in v1.58). `[^"\n]*` cannot cross a
            # newline and `$` under re.M ends at the physical line, so this reads the first line of
            # routing-keywords and never the folded YAML value. A manifest declaring five keywords
            # across two lines routes on two here. The hub scan's own reader of this field carries
            # the same class; both are registered together in STANDARD.md under "A check that reads
            # a compound value validates its parts", and repairing them belongs in a change scoped
            # to those readers rather than inside a repair to an unrelated instrument.
            m = re.search(r'^routing-keywords:\s*"?([^"\n]*)"?\s*$', dep_raw, re.M)
            kws = [k.strip().lower() for k in (m.group(1) if m else "").split(",") if k.strip()]
            # The interview date is SHAPE-CHECKED (v1.64). This read used to accept any non-empty
            # value, so an unsubstituted placeholder (`<YYYY-MM-DD>`) rendered the hub as
            # initiated while hub-scan's [ DEPLOYMENT ] gate — date-shape checked since v1.25
            # precisely so a placeholder cannot pass — quarantined the same hub. Two instruments
            # reading one fact must not disagree about it; this reads the same ISO shape the gate
            # reads. (The check proves the field's shape, never that the date is true.)
            if re.search(r'^initiation-interview:\s*"?\d{4}-\d{2}-\d{2}', dep_raw, re.M):
                INITIATED.add(".")
        HUBS[key] = (ROOT.name.replace("_", " ").strip(), ".", kws)
        GOV_KEY, FALLBACK_KEY = None, key


def load_config(path=None):
    """Read the deployment manifest and derive every estate binding. Fail closed: a cockpit with
    no manifest serves nothing. Relative paths: estate_root resolves against the manifest's own
    directory; queue_path and hub_registry_path resolve against estate_root."""
    global ROOT, SUP, QUEUE, BRIEFS, HUB_REGISTRY, PORT, ORG, CFG, NOTIFY, STANDARD_REPO
    global STANDARD_PUBLISH_BRANCH, PICKUP_LOG, AGENT_REPORTS
    cfg_path = Path(path or os.environ.get("KM_COCKPIT_CONFIG")
                    or SCRIPT_DIR / "km-cockpit.json").resolve()
    if not cfg_path.exists():
        sys.exit(f"km-cockpit: no deployment manifest at {cfg_path} — copy "
                 "km-cockpit.example.json to km-cockpit.json and fill it in")
    cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
    for key in ("estate_root", "queue_path", "organization_name"):
        if not cfg.get(key):
            sys.exit(f"km-cockpit: manifest key {key!r} missing or empty")
    ROOT = (cfg_path.parent / cfg["estate_root"]).resolve()
    QUEUE = (ROOT / cfg["queue_path"]).resolve()
    SUP = QUEUE.parent
    BRIEFS = SUP / "queue-briefs"
    # Conventions beside the queue file, presence-driven, no manifest key: the pickup log is
    # written by this component's own `pull`, and agent-reports/ is a read-only directory a
    # deployment's dispatch machinery fills (a missing directory is a state, never an error).
    PICKUP_LOG = SUP / "answer-pickup-log.md"
    AGENT_REPORTS = SUP / "agent-reports"
    reg = cfg.get("hub_registry_path", "")
    HUB_REGISTRY = (ROOT / reg).resolve() if reg else None
    std = cfg.get("standard_repo_path", "")
    STANDARD_REPO = (ROOT / std).resolve() if std else None
    STANDARD_PUBLISH_BRANCH = str(cfg.get("standard_publish_branch", "main") or "main")
    PORT = int(cfg.get("port", 8485))
    ORG = str(cfg["organization_name"])
    NOTIFY = bool(cfg.get("notifications", True))
    if cfg.get("state_dir"):
        CFG = Path(str(cfg["state_dir"])).expanduser().resolve()
        _state_files()
    load_hubs()


TIER_META = {
    "a": ("Needs you", "#b3261e", "Never defaults — waits for your word"),
    "b": ("Auto-applies", "#7a5900", "Applies its recommendation on the default date unless you veto"),
    "c": ("FYI / reminder", "#3d5afe", "Nothing asked"),
}

# ---------- the row's own ANSWERED marker (v1.64; SPEC.md §3) ----------
# A deployment's pickup machinery may write a consumed owner answer onto the queue row itself:
#     **ANSWERED "<verb>", execution owed by the Supervisor.** <the decision text>
# It leads the Decision cell deliberately, so a human reading the queue file cannot miss it —
# which is exactly why the parser must take it OUT of the cell before reading the cell as
# decision text: decision_title() takes the first bold span as the card's title, and in the
# reference deployment the owner's board once showed a card HEADED by the marker, under a red
# NEEDS YOU badge, on a row he had already answered. The marker is the row's STATE, never its
# identity. Two consequences, both load-bearing:
#   1. parse_cards SPLITS the marker off `what`, so it can never become the title, a
#      hub-inference input, or the queue-context blurb; it re-renders as the answered badge.
#   2. a row carrying it is ANSWERED whatever the answer stores say: the queue file is the
#      record, the jsonl stores are rotating logs. state() folds it into `queued`.
# The em-dash separator form is accepted too, for rows marked under the earlier convention.
ROW_ANSWER_RE = re.compile(
    r'^\*\*ANSWERED\s+"(?P<verb>[^"]*)"\s*[,—–-]\s*'
    r"execution owed by the Supervisor\.\*\*\s*")
# The answered/executed badges REPLACE the tier badge and must beat `.badge.tier-a`'s
# `!important` red, so each carries its own class rather than only an inline colour. A tier-A
# row the owner has answered is not a tier-A row waiting on him, and the two must never look
# alike (SPEC.md §4; two states that mean different things must not render identically).
ANSWERED_META = ("Answered", "#7b5a00",
                 "You answered this. It waits on the Supervisor to execute it, never on you.")
EXECUTED_META = ("Executed", "#1f6b3a",
                 "The Supervisor executed this and recorded it. The row is still on the board "
                 "until the queue is reconciled. Nothing is asked of you.")

# ---------- the Defaults cell (v1.64; SPEC.md §3) ----------
# THE ONE definition of a valid Defaults cell, shared by the parser and by queue-check so the
# owner's board and the session-start check can never disagree about what a row means.
#
# History, because the shape of the defect matters more than the values in it. The canonical row
# is `| Id | Since | Defaults | Decision | Options |`. This parser used to admit that schema only
# when the Defaults cell matched a content whitelist, and FELL THROUGH to a three-cell legacy
# reading when it did not — which shifts every field left by one and makes the Defaults cell the
# card's TITLE. The reference deployment's owner met it first as a card headed `never` (fixed by
# widening the whitelist), then hours later as four cards headed by a date: fixing the VALUE left
# the CLASS, because any third value produced a fourth wrong title. So ARITY, not content, now
# decides the schema: five cells IS a canonical row and its third cell IS the Defaults cell
# whatever it holds. An unreadable value is a defect IN THAT CELL and fails loudly — a PARSE
# ERROR card with no answer controls, and an error out of queue-check — rather than silently
# promoting itself to the headline. A wrong render answers the reader's question and stops them
# looking, which is the worst of the three outcomes available here.
DEFAULTS_CELL_RE = re.compile(r"^(-|never|\d{2}-\d{2}|\d{4}-\d{2}-\d{2})$")
DEFAULTS_CELL_FORMS = '"-", "never", "MM-DD" or "YYYY-MM-DD"'


def split_row_answer(decision_cell):
    """Split the durable ANSWERED marker off a Decision cell -> (decision_text, verb or None)."""
    text = decision_cell.strip()
    m = ROW_ANSWER_RE.match(text)
    if not m:
        return decision_cell, None
    return text[m.end():].strip(), m.group("verb").strip()


# ---------- the lane axis (v1.64; SPEC.md §3) ----------
# Two INDEPENDENT labels per row. Tier is the CLOCK — what happens if the owner says nothing.
# Lane is the CONTEXT — what the owner needs in their head to answer. Lanes group the board; the
# tier badge stays on every card inside a lane, because it is still the clock.
#
# The lane is the LAST field of the QUEUE machine block, appended precisely so every existing
# positional parser is untouched. An absent lane — and a row that predates the field entirely —
# reads as `knowledge`. The cockpit NEVER infers a lane from keywords (contrast hubs_of, which
# does and says so): the assignment belongs to the registering agent, so an unclassified row is
# `knowledge` by contract, not by guess; an unrecognised value reads as `knowledge` for the same
# reason.
LANE_ORDER = ("knowledge", "machinery", "standard", "hand")
DEFAULT_LANE = "knowledge"
LANES = {
    "knowledge": ("Knowledge",
                  "What the estate asserts: facts, identity, terminology, routing, restricted "
                  "marking, outward-facing artifacts. A wrong answer makes the estate say "
                  "something false."),
    "machinery": ("Machinery",
                  "How the estate runs: tooling, the cockpit, routines, scripts, collection "
                  "setup, your own environment. A wrong answer is re-run, not un-done."),
    "standard": ("Standard",
                 "The governed KM Standard: version pushes, RFCs, template changes, pin "
                 "adoption. A wrong answer is inherited by every future deployment."),
    "hand": ("By your hand",
             "Not decisions. Acts only you can perform: run a command, paste a brief, chase a "
             "person, say your own draft is final. Nothing happens until you do it."),
}


def lane_of(value):
    """The lane of a row, tolerant by contract: absent, empty, or unrecognised -> knowledge."""
    v = (value or "").strip().lower()
    return v if v in LANES else DEFAULT_LANE


def hubs_of(text):
    t = text.lower()
    out = []
    for key, (name, d, kws) in HUBS.items():
        if any(k in t for k in kws) or d.lower() in t:
            out.append(key)
    return out or [FALLBACK_KEY]

STYLE = """
 :root { color-scheme:light dark; --km-ink:#263746; --km-accent:#1976ad;
   --km-accent-soft:#e8f3f9; --km-paper:#f6f8fa; --km-surface:#fff; --km-line:#d2dbe2;
   --km-muted:#667886; --km-urgent:#a63d35; --km-success:#39785a; --km-info:#1976ad;
   --km-header:#234c76; --km-shadow:0 8px 24px rgba(30,58,78,.07); }
 * { box-sizing: border-box; }
 body { font: 15px/1.5 "Avenir Next", "Segoe UI", sans-serif; margin:0;
   background:var(--km-paper); color:var(--km-ink); }
 .skip { position:absolute; top:-80px; left:20px; z-index:20; padding:9px 13px;
   background:#fff; color:#123; border-radius:4px; }
 .skip:focus { top:12px; }
 .topbar { min-height:64px; background:var(--km-header); color:#fff; }
 .header-inner { width:min(1440px,100%); min-height:64px; margin:auto; padding:0 34px;
   display:flex; align-items:center; gap:18px; }
 .brand { font-weight:800; letter-spacing:.01em; font-size:20px; white-space:nowrap; }
 .brand small { display:block; color:#c9deec; font:650 9px ui-monospace, monospace;
   letter-spacing:.12em; margin-top:1px; text-transform:uppercase; }
 .live { margin-left:auto; color:#d8e9f3; font:700 9px ui-monospace, monospace; letter-spacing:.1em; }
 .live::before { content:""; display:inline-block; width:7px; height:7px; margin-right:7px;
   background:#4fc0e8; border-radius:50%; }
 .portal-shell { width:min(1440px,100%); margin:auto; padding:42px 34px 72px;
   display:grid; grid-template-columns:180px minmax(0,1fr) 210px; gap:38px; align-items:start; }
 .portal-nav { position:sticky; top:28px; display:flex; flex-direction:column; gap:4px; }
 .portal-nav::before { content:"Workspace"; margin-bottom:9px; color:var(--km-muted);
   font:750 11px ui-monospace, monospace; letter-spacing:.04em; text-transform:uppercase; }
 .portal-nav a { padding:7px 0; color:var(--km-muted); font-size:14px; }
 .portal-nav a.active { color:var(--km-accent); font-weight:800; }
 .portal-nav a:hover { color:var(--km-accent); text-decoration:none; }
 .portal-main { min-width:0; }
 .page-heading { margin:0; font-size:30px; line-height:1.15; letter-spacing:-.025em; }
 .sub { margin:12px 0 26px; color:var(--km-muted); font-size:13px; }
 .page-content { min-width:0; }
 .portal-context { position:sticky; top:28px; color:var(--km-muted); font-size:12px; }
 .portal-context h2 { margin:0 0 12px; color:var(--km-ink); font-size:13px; }
 .portal-context dl { margin:0; }
 .portal-context dt { margin-top:12px; color:var(--km-ink); font-weight:750; }
 .portal-context dd { margin:2px 0 0; }
 .source-note { margin-top:22px; padding:13px; border:1px solid var(--km-line);
   border-radius:7px; background:var(--km-surface); }
 .source-note b { display:block; color:var(--km-ink); margin-bottom:3px; }
 .grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:11px; }
 .stat { min-height:104px; text-align:left; padding:15px 16px; border:1px solid var(--km-line);
   border-radius:8px; background:var(--km-surface); box-shadow:var(--km-shadow); }
 .stat .n { font:850 26px/1 ui-monospace, monospace; }
 .stat .l { color:var(--km-muted); font:750 9px/1.35 ui-monospace, monospace;
   text-transform:uppercase; margin-top:6px; }
 .ledger-section { margin-top:26px; }
 .section-label { display:flex; align-items:center; gap:12px; font:800 10px ui-monospace, monospace;
   letter-spacing:.13em; }
 .section-label::after { content:""; height:1px; background:var(--km-line); flex:1; }
 .section-label .count { background:#006eaf; color:#fff; padding:3px 7px; order:2; }
 .decision-ledger { display:grid; grid-template-columns:minmax(0,1fr); gap:28px; }
 .decision-ledger .ledger-section { margin-top:0; }
 .section-description { margin:6px 0 0; color:var(--km-muted); font-size:12px; }
 .decision-row { margin-top:10px; overflow:hidden; border:1px solid var(--km-line);
   border-left:4px solid var(--km-accent); border-radius:8px; background:var(--km-surface);
   box-shadow:var(--km-shadow); }
 .decision-row.tier-a { border-left-color:var(--km-urgent); }
 .decision-row.tier-b { border-left-color:#8a6500; }
 .decision-row.tier-c { border-left-color:var(--km-info); }
 .decision-row.done { opacity:.72; }
  /* Owner-text grid (§8, layout contract): every track has a BOUNDED maximum, because the
     third one is sized by option labels the owner's queue supplies and an `auto` maximum let a
     sentence-length label take the row and collapse the title to one word per line. */
  .decision-glance { display:grid; grid-template-columns:118px minmax(0,1fr) minmax(190px,38%);
    gap:20px; align-items:center; padding:18px 20px; }
  .decision-identity { display:flex; align-items:center; gap:10px; }
  .decision-title-block { min-width:0; }
  .decision-title-block h3 { margin:0; font-size:18px; font-weight:700; line-height:1.3;
    letter-spacing:-.012em; }
  .decision-meta { display:flex; align-items:center; gap:12px; margin-top:7px; }
  .decision-hubs { display:inline-flex; flex-wrap:wrap; font-weight:400; }
  .decision-actions { display:flex; flex-direction:column; align-items:flex-end; gap:7px; }
  .recommended-answer { color:var(--km-muted); font-size:11px; }
  .recommended-answer b { color:var(--km-ink); }
  .decision-action-buttons { display:flex; gap:7px; flex-wrap:wrap; justify-content:flex-end; }
  /* Owner-supplied label: it wraps inside its own box rather than widening the column. */
  .decision-action-buttons button { max-width:100%; white-space:normal; text-align:center;
    overflow-wrap:anywhere; }
  .stateflag:empty { display:none; }
  .decision-detail { border-top:1px solid var(--km-line); }
  .decision-detail > summary { padding:11px 20px; cursor:pointer; color:var(--km-accent);
    font-size:12px; font-weight:750; list-style-position:inside; }
  .decision-detail > summary:hover { background:var(--km-accent-soft); }
  .decision-detail-body { padding:0 20px 20px; }
  .decision-snapshot { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:1px;
    overflow:hidden; border:1px solid var(--km-line); border-radius:7px; background:var(--km-line); }
  .snapshot-item { min-width:0; padding:16px 17px; background:var(--km-surface); }
  .snapshot-item:first-child { grid-column:1/-1; }
  .snapshot-item:nth-child(2) { background:var(--km-accent-soft); }
  .snapshot-item h4 { margin:0 0 7px; color:var(--km-muted);
    font:800 9px ui-monospace, monospace; letter-spacing:.07em; text-transform:uppercase; }
  .snapshot-item p,.snapshot-item ul { margin:0; font-weight:400; }
  .snapshot-item li + li { margin-top:5px; }
  .decision-proposals { margin-top:14px; }
  .decision-proposals .proposal-review { margin-bottom:0; }
  .decision-deep-links { display:grid; gap:8px; margin-top:14px; padding-top:14px;
    border-top:1px solid var(--km-line); }
  .full-record-link,.decision-deep-section > summary { display:flex; align-items:center;
    justify-content:space-between; gap:12px; padding:10px 12px; border:1px solid var(--km-line);
    border-radius:5px; background:var(--km-surface); cursor:pointer; font-size:12px; font-weight:750; }
  .full-record-link { border-color:#83afc7; background:var(--km-accent-soft); }
  .decision-deep-section > summary::marker { color:var(--km-accent); }
  .decision-deep-section > div { padding:12px; border:1px solid var(--km-line);
    border-top:0; border-radius:0 0 5px 5px; background:var(--km-paper); }
  .queue-context { font-weight:400; }
  .decision-custom-answer,.decision-ask { margin:0; padding:0; border-top:0; }
  .decision-gate { margin:10px 0; padding:10px 12px; border-left:4px solid var(--km-urgent);
   background:color-mix(in srgb,var(--km-urgent) 8%,var(--km-surface)); color:var(--km-muted); }
 .decision-gate b { color:var(--km-urgent); }
 .decision-row.preparing { border-left-color:var(--km-muted); }
 .decision-row.preparing .decision-glance { padding:13px 20px; }
 .decision-row.preparing h3 { font-size:15px; }
 .preparing-flag { color:var(--km-muted); font:750 11px ui-monospace, monospace; }
 .proposal-review { margin:0 0 16px; overflow:hidden; border:1px solid #8ab4ca;
   border-radius:7px; background:var(--km-surface); }
 .proposal-review-head { padding:14px 15px; border-bottom:1px solid var(--km-line); }
 .proposal-review-head h4 { margin:3px 0 0; color:var(--km-ink); font-size:16px; }
 .proposal-meta { display:grid; grid-template-columns:auto minmax(0,1fr); gap:5px 10px;
   margin:0; padding:12px 15px; font-size:12px; }
 .proposal-meta dt { color:var(--km-muted); font-weight:800; }
 .proposal-meta dd { min-width:0; margin:0; overflow-wrap:anywhere; }
 .proposal-summary { padding:0 15px 14px; }
 .proposal-summary p { margin:0; }
 .proposal-full { border-top:1px solid var(--km-line); }
 .proposal-full > summary { padding:11px 15px; cursor:pointer; color:var(--km-accent);
   font-weight:800; }
 .proposal-document { max-height:520px; overflow:auto; padding:4px 16px 18px;
   border-top:1px solid var(--km-line); background:var(--km-paper); }
 .proposal-document h1 { font-size:20px; }
 .proposal-document h2 { margin-top:22px; font-size:17px; }
 .proposal-document h3 { color:var(--km-ink); font:750 15px/1.35 "Avenir Next", "Segoe UI", sans-serif;
   letter-spacing:0; text-transform:none; }
 .authority-guide .badge { display:inline-block; margin-right:4px; }
 .card, .doc, .feed { background:var(--km-surface); border:1px solid var(--km-line);
   border-radius:8px; box-shadow:var(--km-shadow); margin:12px 0 0; overflow:hidden; }
 .card { border-top:4px solid var(--km-accent); padding:0 26px 22px; }
 .card.done { opacity:.68; }
 .row1 { display:grid; grid-template-columns:48px 112px 1fr auto; align-items:center;
   min-height:46px; margin:0 -26px 20px; border-bottom:1px solid var(--km-line); }
 .row1 > span { min-height:46px; display:flex; align-items:center; padding:0 13px;
   border-left:1px solid color-mix(in srgb,var(--km-line) 55%,transparent); }
 .row1 > span:first-child { border-left:0; }
 .rid { font:850 15px ui-monospace, monospace; text-transform:uppercase; }
 .badge { width:max-content; color:#fff; padding:4px 8px;
   font:800 9px ui-monospace, monospace; border-radius:3px; text-transform:uppercase; }
 .badge.tier-a { background:#a63d35 !important; }
 .badge.tier-b { background:#8a6500 !important; }
 .badge.tier-c { background:#0072b5 !important; }
 .when { color:var(--km-muted); font:700 10px ui-monospace, monospace; }
 .what { max-width:850px; margin:0 0 17px; font-size:20px; font-weight:750; line-height:1.3; }
 .next { border-left:4px solid var(--km-accent); padding:9px 14px; margin:18px 0;
   color:color-mix(in srgb,var(--km-ink) 82%,var(--km-muted)); }
 .answer { display:flex; gap:8px; flex-wrap:wrap; align-items:center; margin-top:18px;
   padding-top:18px; border-top:1px solid var(--km-line); }
 button { font:800 10px ui-monospace, monospace; letter-spacing:.04em; padding:10px 15px;
   border:1px solid var(--km-line); border-radius:5px; background:transparent; color:inherit; cursor:pointer; }
 button:hover { background:var(--km-accent-soft); }
 button.rec { background:var(--km-accent); border-color:var(--km-accent); color:#fff; }
 button.rec::before { content:"★ "; }
 button.small { padding:7px 11px; }
 button:focus-visible, input:focus-visible, a:focus-visible, summary:focus-visible {
   outline:3px solid color-mix(in srgb,var(--km-accent) 70%,#fff); outline-offset:3px; }
 input[type=text] { min-width:220px; flex:1; padding:9px 4px; border:0; border-bottom:1px solid var(--km-line);
   background:transparent; color:inherit; font:14px "Avenir Next", "Segoe UI", sans-serif; }
 button:disabled, input:disabled { opacity:.45; cursor:not-allowed; }
 .doneflag { color:#7b5a00; font-weight:750; } .execflag { color:var(--km-success); font-weight:750; }
 .gateflag { color:var(--km-urgent); font-weight:750; }
 .brieflink { margin:8px 0 4px; }
 .brieflink a { display:flex; align-items:center; justify-content:space-between; padding:11px 13px;
   border:1px solid #76a5bf; background:var(--km-accent-soft); color:#005b91;
   font:800 11px ui-monospace, monospace; letter-spacing:.035em; text-transform:uppercase; }
 .brieflink a::after { content:"→"; font-size:16px; }
 .qreply { border-left:4px solid var(--km-info); padding:8px 13px; margin-top:14px; }
 .ctx { margin-top:16px; }
 .ctx summary { cursor:pointer; color:var(--km-ink); font:800 10px ui-monospace, monospace;
   letter-spacing:.04em; text-transform:uppercase; }
 .ctx summary::marker { color:var(--km-accent); }
 .ctxbody { margin-top:10px; border-top:1px solid var(--km-line); padding-top:10px; }
 .ctxlinks a { margin-right:14px; }
 .frag { border:1px solid var(--km-line); padding:12px 15px; margin-top:10px;
   max-height:420px; overflow-y:auto; font-size:14px; background:var(--km-paper); }
 a { color:var(--km-accent); text-decoration:none; } a:hover { text-decoration:underline; }
  .hubchip { color:var(--km-info); font:750 10px ui-monospace, monospace; text-transform:uppercase; }
  .hubchip + .hubchip { margin-left:8px; }
  .feed, .doc { padding:20px 24px; }
  .feed { padding:0; overflow:hidden; }
  .activity-days { display:grid; gap:26px; }
  .activity-day { min-width:0; }
  .activity-date { margin:0 0 8px; padding-bottom:8px; border-bottom:2px solid var(--km-accent);
    color:var(--km-ink); font-size:17px; letter-spacing:-.01em; }
  .activity-date time { font:inherit; }
  .activity-entry { border-bottom:1px solid var(--km-line); background:var(--km-surface); }
  .activity-entry:last-child { border-bottom:0; }
  .activity-summary { display:grid; grid-template-columns:56px 54px minmax(120px,.7fr) auto minmax(220px,1.6fr) auto;
    gap:12px; align-items:center; padding:14px 18px; cursor:pointer; list-style:none; }
  .activity-summary::-webkit-details-marker { display:none; }
  .activity-summary:focus-visible { outline:3px solid var(--km-accent); outline-offset:-3px; }
  .activity-time,.feedid { color:var(--km-muted); font:800 11px ui-monospace, monospace; }
  .feedid { color:var(--km-ink); text-transform:uppercase; }
  .activity-hubs { min-width:0; }
  .activity-state { border-radius:3px; padding:4px 7px; color:#fff;
    font:800 9px ui-monospace, monospace; text-transform:uppercase; white-space:nowrap; }
  .activity-state-executed { background:var(--km-success); }
  .activity-state-awaiting { background:#7a5900; }
  .activity-outcome { min-width:0; font-size:14px; line-height:1.35; }
  .activity-disclosure { color:var(--km-accent); font-size:12px; white-space:nowrap; }
  .hide-details { display:none; }
  .activity-entry[open] .show-details { display:none; }
  .activity-entry[open] .hide-details { display:inline; }
  .activity-detail { padding:0 18px 18px 140px; border-top:1px solid var(--km-line); }
  .activity-detail > .evidence-label { display:block; margin-top:14px; }
  .activity-detail-body { max-width:78ch; margin:8px 0 14px; line-height:1.55; }
  .activity-meta { display:grid; grid-template-columns:auto 1fr; gap:4px 12px; margin:0;
    color:var(--km-muted); font-size:12px; }
  .activity-meta dt { font-weight:750; }
  .activity-meta dd { margin:0; }
  .activity-no-hub { color:var(--km-muted); font-size:11px; }
  .feedat, .meta, .hubmeta { color:var(--km-muted); font:650 10px ui-monospace, monospace; }
 .hub-directory { display:grid; gap:11px; }
 .hub-detail { border:1px solid var(--km-line); border-radius:8px; background:var(--km-surface);
   box-shadow:var(--km-shadow); overflow:hidden; }
 .hub-detail summary { position:relative; display:grid; grid-template-columns:1.4fr 110px 1.2fr 115px; gap:16px;
   align-items:center; padding:15px 28px 15px 17px; cursor:pointer; list-style:none; }
 .hub-detail summary::-webkit-details-marker { display:none; }
 .hub-detail summary::after { content:"+"; position:absolute; right:7px; color:var(--km-accent); }
 .hub-detail[open] summary::after { content:"−"; }
 .hub-detail summary:focus-visible { outline:3px solid var(--km-accent); outline-offset:-3px; }
 .hub-directory-name strong { display:block; margin-top:2px; font-size:15px; }
 .hub-directory-status { justify-self:start; }
 .hub-directory-update { min-width:0; }
 .hub-directory-update time,.hub-directory-update b { display:block; font:800 10px ui-monospace, monospace; }
 .hub-directory-update > span:last-child { display:block; overflow:hidden; color:var(--km-muted);
   font-size:11px; text-overflow:ellipsis; white-space:nowrap; }
 .hub-directory-signals { color:var(--km-muted); font-size:11px; }
 .hub-directory-signals b { color:var(--km-ink); font:850 12px ui-monospace, monospace; }
 .hub-profile-preview { grid-column:1/-1; min-width:0; display:grid;
   grid-template-columns:repeat(2,minmax(0,1fr)); gap:14px; padding-top:11px;
   border-top:1px solid var(--km-line); }
 .hub-profile-preview > span { min-width:0; color:var(--km-muted); font-size:12px;
   overflow-wrap:anywhere; }
 .hub-profile-preview b { display:block; color:var(--km-ink); font-size:10px;
   text-transform:uppercase; letter-spacing:.06em; }
 .hub-detail-body { display:grid; grid-template-columns:1fr 1fr; gap:24px; padding:16px 18px;
   border-top:1px solid var(--km-line); background:var(--km-paper); }
 .hub-detail-body h3 { margin:0 0 7px; font-size:13px; }
 .hub-detail-body ul { margin:0; padding-left:18px; }
 .hub-detail-body li { margin:5px 0; font-size:12px; }
 .muted-item { color:var(--km-muted); }
 .hub-detail-links { display:flex; gap:18px; padding:11px 18px; border-top:1px solid var(--km-line);
   font-weight:750; font-size:12px; }
 .hub-profile-glance,.hub-profile-section { min-width:0; margin-top:14px; padding:20px;
   border:1px solid var(--km-line); border-radius:8px; background:var(--km-surface); }
 .hub-profile-glance { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:16px; }
 .hub-profile-glance > .hubdir,.hub-profile-glance > h2,.hub-profile-glance > div,
 .hub-profile-glance > .profile-source { grid-column:1/-1; }
 .hub-profile-glance h2,.hub-profile-section h2 { margin:0; }
 .hub-profile-glance h3,.hub-profile-section h3 { margin:0 0 6px; font-size:13px; }
 .hub-profile-glance p,.hub-profile-section p { margin:0; overflow-wrap:anywhere; }
 .profile-source { padding-top:12px; border-top:1px solid var(--km-line);
   color:var(--km-muted); font-size:12px; }
 .hub-profile-facts { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:20px; }
  .hub-profile-actions { display:flex; flex-wrap:wrap; gap:18px; margin-top:18px;
    padding-top:13px; border-top:1px solid var(--km-line); font-weight:750; font-size:12px; }
  .supervisor-actions { margin-top:26px; }
  .supervisor-actions-title { display:flex; align-items:baseline; gap:14px; margin-bottom:10px; }
  .supervisor-actions-title h2 { margin:0; font-size:20px; }
  .supervisor-actions-title p { margin:0; color:var(--km-muted); font-size:12px; }
  .supervisor-action-list { margin:0; padding:0; list-style:none; border:1px solid var(--km-line);
    border-radius:8px; background:var(--km-surface); box-shadow:var(--km-shadow); overflow:hidden; }
  .supervisor-action-list li { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:16px;
    align-items:baseline; padding:13px 15px; border-top:1px solid var(--km-line); font-size:13px; }
  .supervisor-action-list li:first-child { border-top:0; }
  .supervisor-action-meta { color:var(--km-muted); font-size:11px; text-align:right; white-space:nowrap; }
  .supervisor-action-list li > .sup-thread, .supervisor-action-list li > .sup-reply,
  .supervisor-action-list li > .sup-controls, .supervisor-action-list li > .sup-confirm {
    grid-column:1/-1; }
  .sup-state { display:inline-block; margin-left:8px; font-size:11px; }
  .sup-reply { margin-top:2px; }
  .sup-thread > summary, .sup-ask > summary { cursor:pointer; color:var(--km-accent);
    font:800 10px ui-monospace, monospace; letter-spacing:.04em; text-transform:uppercase;
    padding:4px 0; }
  .sup-controls { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
  .sup-ask { min-width:0; flex:1 1 260px; }
  .sup-ask .answer { margin-top:6px; padding-top:0; border-top:0; }
  .sup-confirm { color:var(--km-success); font-size:12px; font-weight:750; }
  .sup-confirm:empty { display:none; }
  .sup-confirm.sup-error { color:var(--km-urgent); }
  .sup-guidance { margin:9px 0 0; color:var(--km-muted); font-size:11px; }
  .register-warning { margin:8px 0 0; color:var(--km-urgent); font-size:11px; }
  .watchlist-pointer { margin-top:26px; }
 .watchlist-pointer h2 { margin:0 0 8px; font-size:20px; }
 .desk { margin-top:26px; }
 .desk-title { display:flex; align-items:baseline; gap:14px; margin-bottom:10px; }
 .desk-title h2 { margin:0; font-size:20px; }
 .desk-title p { margin:0; color:var(--km-muted); font-size:12px; }
 .desk-items { border:1px solid var(--km-line); border-radius:8px; background:var(--km-surface);
   box-shadow:var(--km-shadow); overflow:hidden; }
 .desk-item { display:grid; grid-template-columns:46px minmax(0,1fr) auto; gap:12px;
   align-items:start; padding:13px 15px; border-top:1px solid var(--km-line); }
 .desk-item:first-child { border-top:0; }
 .desk-badge { padding:2px 5px; border-radius:3px; background:var(--km-accent-soft);
   color:var(--km-accent); font:800 9px ui-monospace, monospace; text-align:center; }
 .desk-text { min-width:0; font-size:13px; }
 .desk-controls { display:flex; align-items:center; gap:8px; }
 .desk-note { color:var(--km-muted); font-size:11px; }
 .desk-note:empty { display:none; }
 .desk-note.desk-error { color:var(--km-urgent); }
 .desk-strip { display:flex; align-items:center; gap:12px; flex-wrap:wrap;
   padding:11px 15px; margin:0; border:1px dashed var(--km-line); border-radius:6px;
   background:var(--km-accent-soft); color:var(--km-muted); font-size:12px; }
 .desk-done-disclosure { margin-top:12px; }
 .desk-done-disclosure > summary { cursor:pointer; color:var(--km-muted);
   font:800 10px ui-monospace, monospace; letter-spacing:.04em; text-transform:uppercase; }
 .desk-done-note { margin:9px 0; color:var(--km-muted); font-size:12px; }
 .desk-done-list { margin:0; padding:0; list-style:none; border:1px solid var(--km-line);
   border-radius:8px; background:var(--km-surface); overflow:hidden; }
 .desk-done-item { display:grid; grid-template-columns:minmax(0,1fr) auto auto; gap:10px;
   align-items:center; padding:10px 14px; border-top:1px solid var(--km-line); font-size:12.5px; }
 .desk-done-item:first-child { border-top:0; }
 .desk-done-item .feedat { white-space:nowrap; }
 .portfolio-section { margin-top:34px; }
 .portfolio-title { display:flex; align-items:end; justify-content:space-between; gap:22px; margin-bottom:16px; }
 .portfolio-title h2 { margin:0; font-size:24px; line-height:1.15; letter-spacing:-.02em; }
 .portfolio-title p { max-width:500px; margin:0; color:var(--km-muted); font-size:13px; }
 .section-link { flex:0 0 auto; font-weight:750; font-size:12px; }
 .empty-state { padding:18px 20px; border:1px dashed var(--km-line); border-radius:8px;
   background:var(--km-surface); color:var(--km-muted); }
 .empty-state b { color:var(--km-ink); }
 .hub-card-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:17px; }
 .hub-card { min-width:0; display:flex; flex-direction:column; border:1px solid var(--km-line);
   border-top:4px solid var(--km-accent); border-radius:8px; background:var(--km-surface);
   box-shadow:var(--km-shadow); overflow:hidden; }
 .hub-card-head { display:flex; align-items:flex-start; justify-content:space-between; gap:12px;
   padding:18px 19px 14px; }
 .hub-card h3 { margin:3px 0 0; font-size:18px; line-height:1.2; }
 .hubdir { display:block; color:var(--km-muted); font:650 9px ui-monospace, monospace;
   overflow-wrap:anywhere; text-transform:none; }
 .status-group { flex:0 0 auto; text-align:right; }
 .status { display:inline-block; padding:4px 7px; color:#fff; border-radius:3px;
   font:800 9px ui-monospace, monospace; letter-spacing:.035em; text-transform:uppercase; }
 .status-needs-decision { background:var(--km-urgent); }
 .status-pending-changes { background:#7a5900; }
 .status-awaiting-execution { background:#2b6a91; }
 .status-stale { background:#755347; }
 .status-unavailable { background:var(--km-muted); }
 .status-current { background:var(--km-success); }
 .lifecycle { display:block; width:max-content; margin:6px 0 0 auto; padding:2px 6px;
   border:1px solid var(--km-line); color:var(--km-muted); font:750 9px ui-monospace, monospace;
   text-transform:uppercase; border-radius:3px; }
 .hub-card-body { display:grid; grid-template-columns:1.2fr .8fr; gap:15px; padding:0 19px 17px; }
 .evidence-block { min-width:0; }
 .evidence-label { display:block; margin-bottom:5px; color:var(--km-muted);
   font:750 9px ui-monospace, monospace; letter-spacing:.05em; text-transform:uppercase; }
 .update-date { display:block; font:800 11px ui-monospace, monospace; }
 .update-subject { display:block; margin-top:4px; color:var(--km-muted); line-height:1.35; }
 .signals { display:grid; grid-template-columns:auto 1fr; gap:4px 8px; }
 .signals b { font:850 12px ui-monospace, monospace; }
 .signals span { color:var(--km-muted); font-size:11px; }
 .hub-activity { margin:0 19px 17px; padding:12px 13px; border-radius:6px;
   background:var(--km-paper); font-size:12px; }
 .proposal-list { margin:0 19px 17px; padding:12px 13px; border:1px solid #c5dce9;
   border-radius:6px; background:var(--km-accent-soft); }
 .proposal-item + .proposal-item { margin-top:10px; padding-top:10px; border-top:1px solid var(--km-line); }
 .proposal-item a { display:block; font-weight:800; overflow-wrap:anywhere; }
 .proposal-state { display:block; margin-top:3px; color:var(--km-muted); font-size:11px; }
 .hub-detail-body .proposal-list { grid-column:1/-1; margin:0; }
 .recentid { font:800 10px ui-monospace, monospace; text-transform:uppercase; }
 .portfolio-links { margin-top:auto; display:flex; gap:18px; padding:12px 19px;
   border-top:1px solid var(--km-line); font-weight:750; font-size:12px; }
 .urgent { color:var(--km-urgent); font-weight:800; }
 .doc h1,.doc h2,.doc h3,.frag h1,.frag h2,.frag h3 { line-height:1.25; }
 .doc pre,.frag pre { background:var(--km-paper); padding:12px; overflow-x:auto; }
 .doc code,.frag code { background:var(--km-accent-soft); padding:1px 5px; }
 .doc table,.frag table { border-collapse:collapse; display:block; overflow-x:auto; }
 .doc td,.doc th,.frag td,.frag th { border:1px solid var(--km-line); padding:6px 10px; vertical-align:top; }
 .doc blockquote,.frag blockquote { border-left:4px solid var(--km-accent); margin-left:0; padding-left:14px; }
 /* ---------- v1.64 additions (SPEC.md carries each rule) ---------- */
 a.stat { display:block; color:inherit; text-decoration:none; }
 a.stat:hover { border-color:var(--km-accent); }
 .stat-note { margin:12px 0 0; color:var(--km-muted); font-size:12px; }
 .pointer-note { margin:0; padding:11px 14px; border:1px dashed var(--km-line);
   border-radius:7px; background:var(--km-surface); font-size:12.5px; }
 .pointer-note b { color:var(--km-ink); }
 /* An ANSWERED/EXECUTED row replaces its tier badge with these, and they must beat the tier
    rules' own !important — otherwise a tier-A row the owner has already answered keeps its red
    NEEDS YOU. */
 .badge.badge-answered { background:#7b5a00 !important; }
 .badge.badge-executed { background:#1f6b3a !important; }
 .flag-warn { color:var(--km-urgent); font-weight:750; }
 /* The state flag renders owner-supplied answer text: it wraps inside a bounded box rather than
    widening the column (no owner-supplied value may size a layout, SPEC.md §8). */
 .stateflag { display:block; max-width:32ch; white-space:normal; line-height:1.35;
   text-align:right; }
 .decision-actions { min-width:0; }
 .lane-strip { margin-top:20px; }
 .lane-strip-head { display:flex; align-items:baseline; gap:14px; margin-bottom:10px; }
 .lane-strip-head h2 { margin:0; font-size:20px; }
 .lane-strip-head p { margin:0; color:var(--km-muted); font-size:12px; }
 .lane-pills { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:11px; }
 .lane-pill { display:block; padding:14px 15px; border:1px solid var(--km-line);
   border-radius:8px; background:var(--km-surface); box-shadow:var(--km-shadow);
   text-decoration:none; color:inherit; }
 .lane-pill:hover { border-color:var(--km-accent); }
 .lane-pill-n { display:block; font:850 24px/1 ui-monospace, monospace; }
 .lane-pill-l { display:block; margin-top:6px; color:var(--km-muted);
   font:750 9px/1.35 ui-monospace, monospace; text-transform:uppercase; }
 .lane-note { display:block; margin-top:5px; color:var(--km-muted); font-size:11px; }
 .lane-bar { display:flex; flex-wrap:wrap; gap:8px; margin:0 0 6px; }
 .lane-chip { padding:6px 12px; border:1px solid var(--km-line); border-radius:999px;
   background:var(--km-surface); color:var(--km-muted); text-decoration:none;
   font:750 10px ui-monospace, monospace; text-transform:uppercase; letter-spacing:.05em; }
 .lane-chip b { color:var(--km-ink); }
 .lane-chip.on { background:var(--km-header); border-color:var(--km-header); color:#fff; }
 .lane-chip.on b { color:#fff; }
 .lane-scope { margin:0 0 4px; color:var(--km-muted); font-size:12px; }
 .lane-section { border-top:2px solid var(--km-line); padding-top:16px; }
 .lane-heading { display:flex; align-items:baseline; gap:12px; flex-wrap:wrap; }
 .lane-heading h2 { margin:0; font-size:19px; }
 .lane-heading .lane-count { background:var(--km-header); color:#fff; padding:3px 8px;
   font:800 10px ui-monospace, monospace; }
 .lane-def { margin:5px 0 0; color:var(--km-muted); font-size:12px; }
 .lane-section .ledger-section { margin-top:20px; }
 .desk > .pointer-note { margin-bottom:12px; }
 .dismiss-controls { display:flex; align-items:center; gap:8px; }
 .dismiss-note { color:var(--km-muted); font-size:11px; }
 .dismiss-note:empty { display:none; }
 .dismiss-note.dismiss-error { color:var(--km-urgent); }
 .dismissed-strip { display:flex; align-items:center; gap:12px; flex-wrap:wrap;
   padding:11px 15px; margin:0; border:1px dashed var(--km-line); border-radius:6px;
   background:var(--km-accent-soft); color:var(--km-muted); font-size:12px; }
 .dismissed-disclosure { margin-top:12px; }
 .dismissed-disclosure > summary { cursor:pointer; color:var(--km-muted);
   font:800 10px ui-monospace, monospace; letter-spacing:.04em; text-transform:uppercase; }
 .dismissed-note { margin:9px 0; color:var(--km-muted); font-size:12px; }
 .dismissed-list { margin:0; padding:0; list-style:none; border:1px solid var(--km-line);
   border-radius:8px; background:var(--km-surface); overflow:hidden; }
 .dismissed-item { display:grid; grid-template-columns:46px minmax(0,1fr) auto auto; gap:10px;
   align-items:center; padding:10px 14px; border-top:1px solid var(--km-line); font-size:12.5px; }
 .dismissed-item:first-child { border-top:0; }
 .dismissed-item .feedat { white-space:nowrap; }
 .activity-subnav { display:flex; gap:8px; flex-wrap:wrap; margin:0 0 20px; }
 .activity-subnav a { border:1px solid var(--km-line); border-radius:999px; padding:6px 13px;
   font:750 12px/1 ui-sans-serif, system-ui; text-decoration:none; color:var(--km-ink);
   background:var(--km-surface); }
 .activity-subnav a:hover { border-color:var(--km-accent); }
 .sectioncount { display:inline-block; margin-left:5px; padding:1px 7px; border-radius:999px;
   background:var(--km-line); font:800 11px ui-monospace, monospace; vertical-align:middle; }
 .activity-decisions > h2 { margin:0 0 4px; font-size:20px; }
 .activity-unattended > h2 { margin:0 0 4px; font-size:20px; }
 .feeditem { display:grid; grid-template-columns:auto minmax(0,1fr); gap:8px 12px;
   align-items:baseline; padding:12px 16px; border-top:1px solid var(--km-line); }
 .feeditem:first-child { border-top:0; }
 .agent-activity { margin-bottom:36px; }
 .agent-activity > h2 { margin:0 0 4px; font-size:20px; }
 .agent-group { margin-top:16px; overflow:hidden; border:1px solid var(--km-line);
   border-radius:8px; background:var(--km-surface); box-shadow:var(--km-shadow); }
 .agent-group > h3 { margin:0; padding:11px 18px; border-bottom:1px solid var(--km-line);
   font:800 11px ui-monospace, monospace; letter-spacing:.09em; text-transform:uppercase; }
 .agent-group-boundary { border-color:var(--km-urgent); }
 .agent-group-boundary > h3 { background:#fbeceb; color:var(--km-urgent);
   border-bottom-color:var(--km-urgent); }
 .agent-group-note { margin:0; padding:10px 18px; border-bottom:1px solid var(--km-line);
   color:var(--km-muted); font-size:12px; }
 .agent-entry-boundary { border-left:4px solid var(--km-urgent); }
 .agent-state-refused,.agent-state-stopped { background:var(--km-urgent); }
 .agent-state-applied { background:var(--km-success); }
 .agent-state-reported { background:var(--km-info); }
 .agent-meaning { margin:14px 0 6px; color:var(--km-muted); font-size:12px; }
 .agent-read { margin:0 0 12px; font-weight:750; }
 .agent-note { margin:13px 0 0; color:var(--km-muted); font-size:12px; }
 .agent-none { margin-top:16px; }
 .agent-pointer { margin-top:26px; }
 .agent-pointer h2 { margin:0 0 8px; font-size:20px; }
 .agent-unreadable { margin-top:13px; border-style:solid; border-color:#8a6500; }
 .agent-unreadable ul { margin:6px 0 0; padding-left:18px; }
 .supervisor-action-list li > .sup-dependency { grid-column:1/-1; }
 .sup-dependency { margin-top:5px; color:var(--km-muted); font-size:12px; }
 .sup-dependency b { color:var(--km-urgent); }
 .sup-dependency q { color:var(--km-ink); }
 .sup-due-overdue, .sup-due-missing, .sup-due-unreadable { color:var(--km-urgent);
   font-weight:750; }
 .sup-due-today { color:var(--km-accent); font-weight:750; }
 .standard-card { margin-top:18px; }
 .standard-card h2 { font-size:17px; margin:16px 0 4px; }
 .standard-card .std-line { margin:8px 0; font-size:13.5px; }
 .standard-card .std-muted { color:var(--km-muted); font-size:12px; }
 .standard-card ul { margin:5px 0; padding-left:20px; }
 .standard-card li { margin:3px 0; font-size:13px; }
 .standard-card details { margin:3px 0 3px 2px; }
 .standard-card summary { cursor:pointer; color:var(--km-accent); font-size:12.5px; }
 .standard-card .std-path { font:600 10.5px ui-monospace, monospace; color:var(--km-muted); }
 .waiting-estate { margin-top:30px; }
 .waiting-estate h2 { margin:0 0 4px; font-size:19px; }
 .waiting-estate .feed { margin-top:10px; }
 @media (prefers-color-scheme:dark) { :root { --km-ink:#e2e7eb; --km-accent:#55b8e8;
   --km-accent-soft:#19384a; --km-paper:#1c2026; --km-surface:#22272e; --km-line:#3e4650;
   --km-muted:#a9b1b9; --km-urgent:#d66c62; --km-success:#67b98f; --km-info:#73c7ef;
   --km-header:#244b75; --km-shadow:0 8px 24px rgba(0,0,0,.16); }
   .brieflink a { color:#a6ddfa; border-color:#477f9d; } .badge { color:#fff; } }
 @media (max-width:1120px) {
   .portal-shell { grid-template-columns:165px minmax(0,1fr); }
   .portal-context { position:static; grid-column:2; display:grid; grid-template-columns:1fr 1fr;
     gap:18px; margin-top:8px; }
   .portal-context h2 { grid-column:1/-1; margin-bottom:-5px; }
   .source-note { margin-top:0; }
   .hub-card-grid { grid-template-columns:1fr; }
 }
 @media (max-width:720px) {
   .header-inner { padding:0 18px; } .live { display:none; }
   .portal-shell { display:block; padding:22px 16px 56px; }
   .portal-nav { position:static; flex-direction:row; gap:18px; margin:0 0 28px;
     padding-bottom:11px; overflow-x:auto; border-bottom:1px solid var(--km-line); }
   .portal-nav::before { display:none; }
   .portal-nav a { white-space:nowrap; padding:4px 0; }
   .page-heading { font-size:26px; }
   .portal-context { display:block; margin-top:30px; padding-top:22px; border-top:1px solid var(--km-line); }
   .source-note { margin-top:18px; }
   .row1 { grid-template-columns:46px 100px 1fr; }
   .when { display:none !important; } .card { padding-left:18px; padding-right:18px; }
   .row1 { margin-left:-18px; margin-right:-18px; } .what { font-size:18px; }
   .grid { grid-template-columns:repeat(2,minmax(0,1fr)); }
   .portfolio-title { display:block; } .portfolio-title p { margin-top:8px; }
    .section-link { display:inline-block; margin-top:10px; }
    .supervisor-actions-title { display:block; }
    .supervisor-actions-title p { margin-top:4px; }
    .supervisor-action-list li { grid-template-columns:1fr; gap:5px; }
    .supervisor-action-meta { text-align:left; white-space:normal; }
   .desk-title { display:block; } .desk-title p { margin-top:4px; }
   .desk-item { grid-template-columns:1fr; gap:6px; }
    .lane-pills { grid-template-columns:repeat(2,minmax(0,1fr)); }
   .hub-detail summary { position:relative; grid-template-columns:1fr auto; padding-right:24px; }
   .hub-directory-update,.hub-directory-signals { grid-column:1/-1; }
   .hub-directory-update > span:last-child { white-space:normal; }
   .hub-detail-body { grid-template-columns:1fr; }
   .hub-card-grid { grid-template-columns:1fr; }
   .hub-profile-preview,.hub-profile-glance,.hub-profile-facts { grid-template-columns:1fr; }
   .hub-profile-glance > section { grid-column:1; }
    .decision-glance { grid-template-columns:1fr; gap:12px; padding:16px; }
    .decision-title-block { grid-row:1; }
    .decision-identity { grid-row:2; }
    .decision-actions { grid-row:3; align-items:flex-start; }
    .decision-action-buttons { justify-content:flex-start; }
    .decision-meta { align-items:flex-start; flex-direction:column; gap:4px; }
     .decision-snapshot { grid-template-columns:1fr; }
     .snapshot-item:first-child { grid-column:1; }
     .decision-detail-body { padding:0 14px 16px; }
    .activity-summary { grid-template-columns:48px 48px 1fr auto; gap:8px; padding:13px 12px; }
    .activity-hubs { grid-column:3/5; }
    .activity-state { grid-column:1/3; justify-self:start; }
    .activity-outcome { grid-column:3/5; }
    .activity-disclosure { grid-column:3/5; }
    .activity-detail { padding:0 12px 16px; }
  }
 @media (max-width:480px) {
   .brand { font-size:17px; } .brand small { display:none; }
   .grid { grid-template-columns:1fr 1fr; }
   .stat { min-height:95px; padding:13px; }
   .hub-card-head { display:block; }
   .status-group { display:flex; align-items:center; gap:7px; margin-top:12px; text-align:left; }
   .lifecycle { margin:0; }
   .hub-card-body { grid-template-columns:1fr; }
 }
 @media (prefers-reduced-motion:reduce) { *,*::before,*::after { scroll-behavior:auto !important;
   transition:none !important; animation:none !important; } }
"""

JS = """
async function send(id, answer, rec) {
  if (!answer || !answer.trim()) return;
  await fetch('/answer', {method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({id: id, answer: answer.trim(), recommended: rec || ''})});
  refresh();
}
async function ask(id) {
  const el = document.getElementById('q-' + id);
  if (!el || !el.value.trim()) return;
  await fetch('/question', {method: 'POST', headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({id: id, question: el.value.trim()})});
  el.value = ''; el.placeholder = 'sent — the reply lands on this card';
}
async function supSend(aid, type, text) {
  const c = document.getElementById('sup-confirm-' + aid);
  try {
    const r = await fetch('/supervisor-request', {method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({action: aid, type: type, text: text || ''})});
    const t = await r.text();
    if (c) { c.textContent = t; c.classList.toggle('sup-error', !r.ok); }
  } catch (e) {
    if (c) { c.textContent = 'Not recorded — the cockpit server did not respond.';
      c.classList.add('sup-error'); }
  }
}
function supAsk(aid) {
  const el = document.getElementById('sup-q-' + aid);
  if (!el || !el.value.trim()) return;
  supSend(aid, 'question', el.value.trim());
  el.value = '';
}
async function tick(id) {
  const note = document.getElementById('desk-note-' + id);
  try {
    const r = await fetch('/desk', {method: 'POST',
      headers: {'Content-Type': 'application/json'}, body: JSON.stringify({id: id})});
    if (!r.ok) {
      if (note) { note.textContent = await r.text(); note.classList.add('desk-error'); }
      return;
    }
    document.querySelectorAll('[data-desk-item="' + id + '"]').forEach(
      el => el.style.display = 'none');
    document.querySelectorAll('[data-desk-strip="' + id + '"]').forEach(
      el => el.style.display = '');
  } catch (e) {
    if (note) { note.textContent = 'Not recorded — the cockpit server did not respond.';
      note.classList.add('desk-error'); }
  }
}
async function untick(id) {
  const strip = document.querySelector('[data-desk-strip="' + id + '"]');
  try {
    const r = await fetch('/desk', {method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({id: id, undo: true})});
    if (!r.ok) {
      if (strip) strip.textContent = await r.text();
      return;
    }
  } catch (e) {
    if (strip) strip.textContent = 'Not restored — the cockpit server did not respond.';
    return;
  }
  location.reload();
}
async function dismiss(id) {
  const note = document.getElementById('dismiss-note-' + id);
  try {
    const r = await fetch('/dismiss', {method: 'POST',
      headers: {'Content-Type': 'application/json'}, body: JSON.stringify({id: id})});
    if (!r.ok) {
      if (note) { note.textContent = await r.text(); note.classList.add('dismiss-error'); }
      return;
    }
    document.querySelectorAll('[data-dismissable="' + id + '"]').forEach(
      el => el.style.display = 'none');
    document.querySelectorAll('[data-dismissed-strip="' + id + '"]').forEach(
      el => el.style.display = '');
  } catch (e) {
    if (note) { note.textContent = 'Not recorded — the cockpit server did not respond.';
      note.classList.add('dismiss-error'); }
  }
}
async function undismiss(id) {
  const strip = document.querySelector('[data-dismissed-strip="' + id + '"]');
  try {
    const r = await fetch('/dismiss', {method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({id: id, undo: true})});
    if (!r.ok) {
      if (strip) strip.textContent = await r.text();
      return;
    }
  } catch (e) {
    if (strip) strip.textContent = 'Not restored — the cockpit server did not respond.';
    return;
  }
  location.reload();
}
async function viewfrag(id, p) {
  const box = document.getElementById('frag-' + id);
  box.style.display = '';
  box.innerHTML = 'loading…';
  box.innerHTML = await (await fetch('/fragment?p=' + encodeURIComponent(p))).text();
}
function setBadge(card, meta) {
  // A surface that changes while nobody is looking must announce the change: without this, a
  // page left open kept the red tier badge beside a tick it now contradicted.
  const b = card.querySelector('[data-badge]');
  if (!b || b.textContent === meta.label) return;
  b.classList.remove('badge-answered', 'badge-executed');
  b.classList.add(meta.cls);
  b.style.background = meta.color;
  b.title = meta.tip;
  b.textContent = meta.label;
}
async function refresh() {
  try {
    const s = await (await fetch('/api/state')).json();
    document.querySelectorAll('[data-decision-row][data-row]').forEach(card => {
      const id = card.dataset.row;
      const flag = card.querySelector('.stateflag');
      if (!flag) return;
      if (s.executed[id]) {
        card.classList.add('done');
        setBadge(card, KM_BADGE.executed);
        flag.innerHTML = '<span class="execflag">✓ Execution recorded — reconciliation pending</span> — ' + s.executed[id];
        card.querySelectorAll('[data-answer-control]').forEach(e => e.style.display = 'none');
      } else if (s.pending.includes(id) || s.queued.includes(id)) {
        card.classList.add('done');
        setBadge(card, KM_BADGE.answered);
        // /api/state serves the verb already shortened and escaped server-side (short_verb).
        // Two truthful phrasings of the ONE answered state: a consumed answer (queued) is being
        // executed by the Supervisor; an unconsumed one awaits the pickup. Either way the row is
        // ANSWERED — never answerable again until executed.
        const a = (s.answers && s.answers[id]) ? s.answers[id] : '';
        flag.innerHTML = s.queued.includes(id)
          ? '<span class="doneflag">✓ Answered' + (a ? ' “' + a + '”' : '') + ' — executing</span>'
          : (a ? '<span class="doneflag">✓ “' + a + '” recorded — awaiting execution</span>'
               : '<span class="doneflag">✓ answer recorded — awaiting execution</span>');
        card.querySelectorAll('[data-answer-control]').forEach(e => e.style.display = 'none');
      }
    });
  } catch (e) {}
}
setInterval(refresh, 4000);
window.addEventListener('load', refresh);
"""

# The badge metadata the poll swaps in is SERIALISED FROM THE PYTHON CONSTANTS the server renders
# from, never restated in the JS. Two copies of a label drift, and a client that disagreed with
# the server about what a row's state is called is the same defect one layer down.
BADGE_JS = "const KM_BADGE = " + json.dumps({
    "executed": {"cls": "badge-executed", "color": EXECUTED_META[1],
                 "label": EXECUTED_META[0], "tip": EXECUTED_META[2]},
    "answered": {"cls": "badge-answered", "color": ANSWERED_META[1],
                 "label": ANSWERED_META[0], "tip": ANSWERED_META[2]},
}) + ";\n"


def page(title, inner, sub="", active="", context=None):
    nav = [("home", "/", "OVERVIEW"), ("decisions", "/decisions", "DECISIONS"),
           ("activity", "/activity", "ACTIVITY"), ("hubs", "/hubs", "HUBS"),
           ("desk", "/desk", "YOUR DESK")]
    links = "".join(
        f'<a class="{"active" if key == active else ""}" href="{href}">{label}</a>'
        for key, href, label in nav)
    heading = {"home": "Overview", "decisions": "Decisions", "activity": "Activity",
               "hubs": "Hubs", "desk": "Your desk"}.get(active, title.split(" — ", 1)[0])
    context_html = context if context is not None else """<h2>Status guide</h2>
<dl><dt>Needs decision</dt><dd>An open Tier A or B item is linked to the hub, or a proposal awaits your decision.</dd>
<dt>Pending changes</dt><dd>A proposal in the hub still needs decision routing.</dd>
<dt>Awaiting execution</dt><dd>You already answered; the KM Supervisor owes the execution.</dd>
<dt>Current / stale</dt><dd>Git movement is within or beyond 30 days.</dd></dl>
<div class="source-note"><b>Read-only evidence</b>QUEUE.md, execution records, Git history, proposals, and the governed hub registry.</div>"""
    return f"""<!DOCTYPE html><html><head><meta charset="utf-8"><title>{html.escape(title)}</title>
<meta name="viewport" content="width=device-width,initial-scale=1"><style>{STYLE}</style></head><body>
<a class="skip" href="#main-content">Skip to content</a>
<header class="topbar"><div class="header-inner">
<div class="brand">KM Cockpit<small>{html.escape(ORG.upper())} · DECISION SURFACE</small></div>
<span class="live">LIVE / QUEUE.MD</span></div></header>
<div class="portal-shell" data-layout="portal-shell">
<nav class="portal-nav" aria-label="Primary">{links}</nav>
<main id="main-content" class="portal-main"><h1 class="page-heading">{html.escape(heading)}</h1>
{f'<div class="sub">{sub}</div>' if sub else ''}<div class="page-content">{inner}</div></main>
<aside class="portal-context" aria-label="Cockpit context">{context_html}</aside>
</div>
<script>{BADGE_JS}{JS}</script></body></html>"""


# ---------- queue parsing ----------

def parse_cards(raw=None):
    if raw is None:
        raw = QUEUE.read_text(encoding="utf-8")
    cards = []
    fenced = False
    for line in _join_wrapped(raw):
        s = line.strip()
        # A fenced block is documentation, not queue content (v1.31): the template ships worked
        # example rows so there is something to copy and something to check against, and an
        # example must never render as a decision on the owner's surface.
        if s.startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        # Tolerate markdown emphasis / code ticks around the id (v1.64). A row written as
        # `| **b57** |` used to drop out entirely here, so an open decision VANISHED from the
        # board while its ask still circulated elsewhere. The fail-closed machine-block
        # cross-check at the end catches any that still slip through.
        m = re.match(r"^\|\s*[*_`]*([ab]\d+)[*_`]*\s*\|(.*)\|\s*$", s)
        if m:
            rid, tier = m.group(1), m.group(1)[0]
            cells = [c.strip() for c in m.group(2).split("|")]
            # Canonical schema: Id | Since | Defaults | Decision | Options. ARITY DECIDES IT,
            # never the Defaults cell's content (v1.64; see DEFAULTS_CELL_RE for why this is a
            # class and not a value). Five cells is a canonical row and cells[1] is its Defaults
            # cell whatever it holds; an unreadable value FAILS LOUDLY here instead of falling
            # through to the three-cell legacy reading, which shifted every field left by one
            # and rendered the Defaults cell as the card's title. The legacy shapes below stay
            # parseable until a queue migrates.
            if len(cells) >= 4:
                if not DEFAULTS_CELL_RE.match(cells[1]):
                    cards.append({
                        "id": rid, "tier": tier, "when": cells[0],
                        "what": (f"⚠ This row's Defaults cell reads {cells[1]!r}, which is not a "
                                 f"default the board can read. Write it as one of "
                                 f"{DEFAULTS_CELL_FORMS} in the queue file. Shown as a defect so "
                                 f"it cannot render as this card's title."),
                        "next": "",
                        "parse_error": True,
                        "parse_error_reason": (f"Defaults cell {cells[1]!r} is not one of "
                                               f"{DEFAULTS_CELL_FORMS}")})
                    continue
                when = cells[0]
                if tier == "b" and cells[1] not in ("-", "never"):
                    when = f"{cells[0]} · defaults {cells[1]}"
                what, nxt = cells[2], " | ".join(cells[3:])
            elif len(cells) >= 3:
                when, what, nxt = cells[0], cells[1], " | ".join(cells[2:])
            elif len(cells) == 2:
                when = ("default " + cells[0]) if tier == "b" else cells[0]
                what = cells[1]
                nxt = ('Recommended: let it **"apply"** (run it now, or it applies itself on the '
                       'default date). **"veto"** stops it.') if tier == "b" else ""
            else:
                continue
            # The ANSWERED marker is state, not decision text: take it out here, once, so every
            # downstream reader of `what` (title, hub inference, queue context) sees the decision
            # and nothing else. The verb travels beside it (v1.64).
            what, answered_row = split_row_answer(what)
            cards.append({"id": rid, "when": when, "what": what, "next": nxt, "tier": tier,
                          "answered_row": answered_row})
            continue
        m = re.match(r"^- \*\*(c\d+)[ —:-]*([^*]*)\*\*[ :—-]*(.*)$", s)
        if m:
            label, rest = m.group(2).strip(), m.group(3).strip()
            what = f"**{label}** — {rest}" if label else rest
            cards.append({"id": m.group(1), "when": "", "what": what, "next": "", "tier": "c"})
    order = {"a": 0, "b": 1, "c": 2}
    cards.sort(key=lambda c: (order[c["tier"]], int(c["id"][1:])))
    dates = {}
    mb = re.search(r"QUEUE:BEGIN.*?\n(.*?)QUEUE:END", raw, re.S)
    if mb:
        for line in mb.group(1).splitlines():
            p = [x.strip() for x in line.split("|")]
            if len(p) >= 4 and re.match(r"^[abc]\d+$", p[0]):
                # `lane` is field 6, appended last so every positional reader above is untouched;
                # a row written before the field existed has len(p) == 5 and takes the contract
                # default. `answered:<verb>` is appended after it for the same reason; scan the
                # tail rather than indexing, so a later appended field cannot displace it.
                answered_mb = next(
                    (x.split(":", 1)[1].strip() for x in p[6:] if x.startswith("answered:")), None)
                dates[p[0]] = {"raised": p[2], "default": p[3],
                               "lane": lane_of(p[5] if len(p) >= 6 else ""),
                               "answered_mb": answered_mb}
    for c in cards:
        c.update(dates.get(c["id"], {}))
        # A rendered row with no machine-block line at all still gets a lane.
        c["lane"] = lane_of(c.get("lane"))
    # FAIL CLOSED (v1.64): a row present in the QUEUE machine block but with NO rendered card
    # must SURFACE here, never vanish — a silent row-drop is invisible precisely because the
    # dropped row produces nothing to see. The placeholder makes a parse failure loud.
    seen = {c["id"] for c in cards}
    for rid, meta in dates.items():
        if rid in seen:
            continue
        cards.append({"id": rid, "tier": rid[0], "when": meta.get("raised", ""),
                      "what": ("⚠ This row is in the QUEUE machine block but its rendered row "
                               "did not parse — fix its formatting in the queue file. Shown so "
                               "it is not silently dropped."),
                      "next": "", "raised": meta.get("raised", ""),
                      "default": meta.get("default", ""),
                      "lane": meta.get("lane", lane_of("")), "parse_error": True})
    cards.sort(key=lambda c: (order[c["tier"]], int(c["id"][1:])))
    return cards


def parse_supervisor_actions():
    queue = QUEUE
    if not queue.exists():
        return {"state": "missing", "actions": [], "malformed": 0}
    raw = queue.read_text(encoding="utf-8")
    match = re.search(
        r"<!-- SUPERVISOR-ACTIONS:BEGIN\s*\n(.*?)\nSUPERVISOR-ACTIONS:END -->",
        raw,
        re.S,
    )
    if not match:
        return {"state": "missing", "actions": [], "malformed": 0}
    actions, malformed = [], 0
    for index, line in enumerate(match.group(1).splitlines()):
        if not line.strip() or (index == 0 and line.strip().lower().startswith("id |")):
            continue
        cells = [cell.strip() for cell in line.split("|")]
        if len(cells) != 5 or not cells[0]:
            malformed += 1
            continue
        actions.append(dict(zip(("id", "since", "due", "action", "evidence"), cells)))
    return {"state": "present", "actions": actions, "malformed": malformed}


# Accepted option forms in the Options cell, tried in order (ruled v1.31). The canonical schema
# is "exact quoted verbs, recommendation first"; bold is presentation, never part of the data, so
# a queue written exactly as SPEC.md §3 and the template describe it must parse. The two bold
# forms stay accepted so every queue written against the previous parser keeps working.
OPTION_FORMS = (
    r"\*\*\"([^\"]+)\"\*\*",                        # bold + quoted (legacy emphasis)
    r"\"([A-Za-z][^\"]{0,59})\"",                   # quoted — the canonical schema form
    r"\*\*([A-Za-z][A-Za-z ,+-]{1,24})\*\*\s*\(",   # legacy prose: **Verb** (context)
)


def options_of(card):
    if card.get("parse_error"):
        # A row that failed to parse offers no options at all — above all not the tier-B
        # synthetic pair, which would answer a question the surface never read (v1.64).
        return []
    found = []
    for form in OPTION_FORMS:
        found = re.findall(form, card["next"])
        if found:
            break
    if card["tier"] == "b":
        # Ruled 2026-08-17: a tier-B card offers its SPECIFIC default action first, veto second;
        # generic "apply" only when the row names no precise verb (ledger #3 still holds: real
        # row options always win over synthetics). Amended v1.31: the synthetic pair fires ONLY
        # when the row declares NO options. A row that declares options the parser cannot read is
        # not a row with "no precise verb" — it is a row the surface failed to read, and
        # answering it against a synthesised pair records an answer the row never offered (and a
        # follow-rate hit against an option the owner was never shown). That case is reported by
        # options_gate() instead.
        if not found:
            lead = re.match(r"\s*\*\*([A-Za-z][^*]{0,40}?)\*\*", card["next"])
            if lead:
                found = [re.sub(r"\s+(it|them|this|that|now)$", "", lead.group(1).strip(),
                                flags=re.I)]
            elif not declares_options(card):
                found = ["apply"]
        if found and not any(o.lower().strip() == "veto" for o in found):
            found = list(found) + ["veto"]
    seen, out = set(), []
    for o in found:
        k = o.lower().strip()
        if k and k not in seen:
            seen.add(k)
            out.append(o.strip())
    return out[:4]


def declares_options(card):
    """True when the row's Options cell holds content that is meant to be an option list —
    i.e. the row is declaring something. Distinguishes "declared but unreadable" (a defect to
    report) from "declared nothing" (a defect of a different, quieter kind)."""
    return bool(re.search(r"[A-Za-z]", card.get("next", "")))


def options_gate(card, opts):
    """A tier-A/B row that yields no answer options is REPORTED, never silently emptied
    (ruled v1.31, from a live demonstration where a spec-conformant queue rendered an action bar
    with nothing in it while the card looked complete). Returns None when answerable, otherwise
    the gate reason, which routes the card into the "Preparing for you" group exactly like a
    failing decision brief. Rendering an empty action bar is a false pass: the owner sees a
    complete-looking card and no control, with nothing anywhere saying why."""
    if card.get("parse_error"):
        # A row that failed to parse is never answerable, whatever else it declares: answering it
        # would record a word against a question the surface could not even read (v1.64).
        return (card.get("parse_error_reason")
                or "the row is in the QUEUE machine block but its rendered row failed to parse")
    if card.get("tier") == "c" or opts:
        return None
    if declares_options(card):
        return ('the row declares answer options this surface cannot read — the canonical schema '
                'is exact quoted verbs, recommendation first (for example: "approve", "veto")')
    return ('the row declares no answer options (canonical schema: '
            'Id | Since | Defaults | Decision | Options)')


def sentence_case(text):
    """Upper-case the first character and leave every other character alone. str.capitalize()
    LOWER-cases the remainder, which destroys proper nouns in an option label — and the option
    label is rendered on a surface shown to the person it names."""
    return text[:1].upper() + text[1:]


# ---------- The layout contract (§8, ruled v1.31) ----------
#
# NO OWNER-SUPPLIED VALUE MAY SIZE A LAYOUT. An option label, an answer, a note, a queue row's
# text: all of it is unbounded text arriving from a file the surface does not control, and all of
# it renders inside a box whose size the layout decides. The instance that produced the rule was a
# grid track with an `auto` maximum sized by option labels the length of sentences, which took the
# row and collapsed the title column beside it; the class is wider than that instance, so the
# contract is stated once and checked, rather than patched wherever it next appears.
#
# COVERAGE, stated because a check that does not state it is a word rather than evidence: this
# instrument checks the tracks NAMED BELOW in the grids named below. It cannot discover that a new
# grid renders owner text — that registration is a human act, required by §8 of the SPEC in the
# same change that adds the surface. It therefore catches "a registered track lost its bound",
# never "a new surface was never registered".
OWNER_TEXT_GRIDS = {
    # selector: (1-based track positions carrying owner-supplied text, what the owner supplies)
    ".decision-glance": ((2, 3), "the queue's Decision text, and the row's own option labels"),
    ".activity-summary": ((5,), "the recorded answer or execution note"),
    ".supervisor-action-list li": ((1,), "the supervisor-action text from the queue"),
    ".desk-item": ((2,), "the owner's desk item text from the queue"),
    ".desk-done-item": ((1,), "the ticked desk item text from the queue"),
    # v1.64 surfaces, registered in the same change that added them (SPEC.md §8): the tier-C
    # watch-item grid left with the watchlist (tier C now renders as decision rows), and these
    # arrived with dismissal and the actor-split activity page.
    ".dismissed-item": ((2,), "the dismissed item's queue text"),
    ".feeditem": ((2,), "the pickup-log line or owed-proposal state text"),
}
UNBOUNDED_TRACK_MAX = ("auto", "max-content")


def _split_tracks(value):
    """Split a grid-template-columns value into tracks, not splitting inside parentheses."""
    tracks, depth, cur = [], 0, ""
    for ch in value:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch.isspace() and depth == 0:
            if cur:
                tracks.append(cur)
                cur = ""
        else:
            cur += ch
    if cur:
        tracks.append(cur)
    return tracks


def _track_max(track):
    """The maximum a track can grow to: the second argument of minmax(), else the track."""
    m = re.match(r"^minmax\((.*)\)$", track.strip())
    if not m:
        return track.strip().lower()
    parts, depth, cur = [], 0, ""
    for ch in m.group(1):
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append(cur)
            cur = ""
        else:
            cur += ch
    parts.append(cur)
    return parts[-1].strip().lower()


def layout_contract_violations(style=None):
    """Returns (violations, coverage). A violation is a registered owner-text track whose maximum
    is unbounded, so the owner's own text decides how wide the column is."""
    css = STYLE if style is None else style
    violations, decls, tracks_checked = [], 0, 0
    for selector, (positions, what) in OWNER_TEXT_GRIDS.items():
        pattern = re.escape(selector) + r"\s*\{([^{}]*)\}"
        found_selector = False
        for block in re.finditer(pattern, css):
            body = block.group(1)
            m = re.search(r"grid-template-columns\s*:\s*([^;}]+)", body)
            if not m:
                continue
            found_selector = True
            decls += 1
            tracks = _split_tracks(m.group(1))
            for pos in positions:
                if pos > len(tracks):
                    continue          # a narrower declaration (single-column breakpoint)
                tracks_checked += 1
                if _track_max(tracks[pos - 1]) in UNBOUNDED_TRACK_MAX:
                    violations.append(
                        f"{selector} track {pos} ({what}) has an unbounded maximum "
                        f"'{tracks[pos - 1]}' — owner text sizes this layout")
        if not found_selector:
            # Fail closed: a registered selector the checker cannot find is an unevaluated rule,
            # never a passing one.
            violations.append(
                f"{selector} is registered as an owner-text grid but no "
                f"grid-template-columns declaration for it was found")
    coverage = (f"{len(OWNER_TEXT_GRIDS)} registered owner-text grids, {decls} declarations, "
                f"{tracks_checked} owner-text tracks")
    return violations, coverage


def links_of(card):
    """Queue rows live in QUEUE.md, so their links resolve from SUP. Returns
    (label, path, is_md, fragment) — the fragment is carried, never part of the filename."""
    out = []
    for m in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", card["what"] + " " + card["next"]):
        target, _, frag = urllib.parse.unquote(m.group(2)).partition("#")
        if not target:
            continue
        p = (SUP / target).resolve()
        if p.exists():
            out.append((m.group(1), str(p), p.suffix == ".md", frag))
    return out


def _proposal_links(text, base):
    """Proposal links in TEXT, each resolved relative to BASE — the directory of the file that
    carries the link (containing-file contract, ruled 2026-08-17) — ROOT-confined, #fragments
    stripped. Targets may be missing (that is state 4's whole point)."""
    out = []
    for match in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", text):
        target, _, _frag = urllib.parse.unquote(match.group(2)).partition("#")
        if not target.endswith("_proposal.md"):
            continue
        path = (Path(base) / target).resolve()
        try:
            path.relative_to(ROOT.resolve())
        except ValueError:
            continue
        out.append((match.group(1), path))
    return out


def brief_path_of(rid):
    """The canonical decision brief for a row: live first, then archived (rows close)."""
    for p in (BRIEFS / f"{rid}.md", BRIEFS / "archive" / f"{rid}.md"):
        if p.exists():
            return p
    return None


def linked_proposals(card):
    """Proposal links from the queue row and its canonical decision brief (ruled 2026-08-17:
    matching follows the brief, where the canonical proposal link lives — the b22/Openlane
    incident), de-duplicated by canonical path."""
    found = _proposal_links(card["what"] + " " + card["next"], SUP)
    brief = brief_path_of(card["id"])
    if brief:
        try:
            found += _proposal_links(brief.read_text(encoding="utf-8", errors="replace"),
                                     brief.parent)
        except OSError:
            pass
    seen, out = set(), []
    for label, path in found:
        canonical = str(path)
        if canonical not in seen:
            seen.add(canonical)
            out.append((label, path))
    return out


def proposal_record(path):
    """Read the compact evidence needed to identify and review a proposal."""
    path = Path(path).resolve()
    record = {
        "path": str(path),
        "name": path.name,
        "title": path.stem.replace("_", " "),
        "date": "",
        "author": "",
        "source": "",
        "artifacts": "",
        "summary": "",
    }
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        record["error"] = "Exact proposal unavailable"
        return record
    heading = re.search(r"^#\s+(.+)$", text, re.M)
    if heading:
        record["title"] = heading.group(1).strip()
    for label, key in (("Date", "date"), ("Author", "author"), ("Source", "source"),
                       ("Hub docs affected", "artifacts")):
        match = re.search(rf"^\*\*{re.escape(label)}:\*\*\s*(.+)$", text, re.M)
        if match:
            record[key] = match.group(1).strip()
    summary = re.search(r"^## Summary\s*$\n(.*?)(?=^## |\Z)", text, re.M | re.S)
    if summary:
        record["summary"] = re.sub(r"\n---\s*$", "", summary.group(1).strip())
    record["text"] = text
    return record


def proposal_decisions(cards):
    """Map canonical proposal paths to the queue decisions that govern them. Sources, weakest
    first: every decision brief, archived then live (a pulled row LEAVES QUEUE.md, so its brief
    is the surviving link source for the queued/executed states), then the open rows themselves.
    Archived briefs also resolve from queue-briefs/ — their links were authored there and the
    archive move does not rewrite them."""
    mapping = {}
    for directory in (BRIEFS / "archive", BRIEFS):
        if not directory.is_dir():
            continue
        for brief in sorted(directory.glob("*.md")):
            rid = brief.stem
            if not re.match(r"^[ab]\d+$", rid):
                continue
            try:
                text = brief.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            bases = (directory,) if directory == BRIEFS else (directory, BRIEFS)
            for base in bases:
                for _label, path in _proposal_links(text, base):
                    mapping[str(path)] = rid
    for card in cards:
        for _label, path in linked_proposals(card):
            mapping[str(path)] = card["id"]
    return mapping


def short_verb(answer):
    """A recorded answer compressed to a readable verb (free-text answers can be sentences)."""
    verb = " ".join((answer or "").split())
    return verb if len(verb) <= 40 else verb[:40].rstrip() + "…"


def proposal_lifecycle(decision_id, st):
    """The ruled display state of a governed proposal (2026-08-17 ruling; correction:
    needing-attention-signals-must-resolve-to-a-visible-item). Returns (state, label). The
    'answered' label always quotes the recorded verb — a veto renders truthfully."""
    if not decision_id:
        return "unrouted", "Needs decision routing"
    if decision_id in st["executed"]:
        return "executed", f"Execution recorded — proposal reconciliation pending ({decision_id})"
    if decision_id in st["queued"]:
        return "queued", f"Queued for KM Supervisor execution ({decision_id})"
    if decision_id in st["pending"]:
        verb = short_verb(st.get("answers", {}).get(decision_id, "")) or "answered"
        return "answered", f'Answered "{verb}" — awaiting KM Supervisor execution ({decision_id})'
    return "open", f"Awaiting owner decision {decision_id}"


def render_proposal_reviews(card):
    reviews = []
    for _label, path in linked_proposals(card):
        proposal = proposal_record(path)
        if proposal.get("error"):
            reviews.append(
                f'<div class="decision-gate"><b>Exact proposal unavailable.</b> '
                f'{html.escape(proposal["name"])}</div>')
            continue
        pbase = Path(proposal["path"]).parent
        meta = []
        for label, key in (("Author", "author"), ("Date", "date"), ("Source", "source"),
                           ("Affected artifacts", "artifacts")):
            if proposal.get(key):
                meta.append(f'<dt>{label}</dt><dd>{md_inline(proposal[key], pbase)}</dd>')
        summary = (f'<div class="proposal-summary">{md_to_html(proposal["summary"], pbase)}</div>'
                   if proposal.get("summary") else "")
        reviews.append(f"""<article class="proposal-review">
<header class="proposal-review-head"><span class="evidence-label">Proposal review</span>
<h4>{html.escape(proposal['title'])}</h4></header>
<dl class="proposal-meta">{''.join(meta)}</dl>{summary}
<details class="proposal-full"><summary>Review exact change</summary>
<div class="proposal-document">{md_to_html(proposal['text'], pbase)}</div></details></article>""")
    return "".join(reviews)


# ---------- decision briefs (phase 2.5, dossier §8.5, owner-accepted a15) ----------

BRIEF_FM_KEYS = ("row", "tier", "raised", "hubs", "reversible", "delegable")
BRIEF_MANDATORY = (1, 3, 4, 5, 7, 10)  # non-empty; 2/6/8/9 must exist but may state none/unknown


def brief_check(rid):
    """Validate queue-briefs/<rid>.md. Returns (path, None) when passing,
    (path-or-None, first-missing-thing) when missing or failing. Read-only."""
    p = BRIEFS / f"{rid}.md"
    if not p.exists():
        return None, f"no brief file (queue-briefs/{rid}.md)"
    text = p.read_text(encoding="utf-8", errors="replace")
    fm, body = {}, text
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            for line in text[4:end].splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    fm[k.strip()] = v.strip()
            body = text[end + 4:]
    for k in BRIEF_FM_KEYS:
        if not fm.get(k):
            return p, f"frontmatter key '{k}' missing or empty"
    secs, cur = {}, None
    for line in body.splitlines():
        m = re.match(r"^##\s*(\d+)\b", line)
        if m:
            cur = int(m.group(1))
            secs[cur] = []
        elif cur is not None:
            secs[cur].append(line)
    for n in range(1, 11):
        if n not in secs:
            return p, f"section {n} missing"
    for n in BRIEF_MANDATORY:
        if not "\n".join(secs[n]).strip():
            return p, f"section {n} empty"
    # §5 provenance is SEMANTIC (ruled 2026-08-17): bullets OR table rows are facts; a fact (or
    # the fact group as a whole) passes when source + ISO date + KM are explicit. Group-level
    # provenance — a plain paragraph in the section, or the brief's own mandatory `hubs`
    # frontmatter naming the KM — covers facts that share it (a20's table-with-shared-source).
    facts, group, table_rows = [], [], 0
    for line in secs[5]:
        stripped = line.strip()
        if re.match(r"^\s*[-*] ", line):
            facts.append(re.sub(r"^\s*[-*] ", "", stripped))
            table_rows = 0
        elif stripped.startswith("|"):
            cells = [c.strip() for c in stripped.strip("|").split("|")]
            if all(re.match(r"^:?-{2,}:?$", c) for c in cells):
                continue
            table_rows += 1
            if table_rows > 1:  # first row is the header
                facts.append(" ".join(cells))
        elif line.startswith((" ", "\t")) and facts and stripped:
            facts[-1] += " " + stripped  # wrapped fact lines join
        elif stripped:
            group.append(stripped)  # shared provenance for the fact group
    grouptext = " ".join(group)
    def _sourced(fact):
        scope = f"{fact} {grouptext}"
        return bool(re.search(r"\d{4}-\d{2}-\d{2}", scope)) and \
            (re.search(r"\bKM\b", scope) or fm.get("hubs"))
    if not any(_sourced(f) for f in facts):
        return p, ("section 5 has no sourced fact — needs a bullet or table row with source, "
                   "ISO date, and KM (shared provenance below a table counts for its group)")
    return p, None


def decision_brief_sections(path):
    """Return the numbered decision-brief sections for presentation."""
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    body = text
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            body = text[end + 4:]
    sections, current = {}, None
    for line in body.splitlines():
        match = re.match(r"^##\s*(\d+)\b", line)
        if match:
            current = int(match.group(1))
            sections[current] = []
        elif current is not None:
            sections[current].append(line)
    normalized = {}
    for number, lines in sections.items():
        value = "\n".join(lines).strip()
        normalized[number] = re.sub(r"(?<!\n)\n(?!\n|[ \t]*[-*] )", " ", value)
    return normalized


def decision_title(card):
    """Extract the queue's short recognition phrase without its full narrative.

    The ANSWERED marker is stripped FIRST. parse_cards already splits it off `what`, so this is
    the floor that holds if a marker ever reaches here by another route — a hand-written row, a
    future caller building a card dict itself. A title is the decision's identity; the marker is
    the row's state, and a card headed by it hides the very thing the owner is looking for."""
    cell = ROW_ANSWER_RE.sub("", card["what"].strip())
    match = re.search(r"\*\*(.+?)\*\*", cell)
    source = match.group(1) if match else cell
    source = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", source)
    source = re.sub(r"[*_`]+", "", source).strip().split("\n", 1)[0]
    sentence = re.match(r"^(.+?[.!?])(?:\s|$)", source)
    return (sentence.group(1) if sentence else source).strip()


def unique_decision_links(card, brief=None):
    """Return ordinary evidence once, excluding governed brief/proposal artifacts."""
    excluded = {str(path.resolve()) for _label, path in linked_proposals(card)}
    if brief:
        excluded.add(str(Path(brief).resolve()))
    seen, unique = set(), []
    for label, path, is_md, frag in links_of(card):
        canonical = str(Path(path).resolve())
        if canonical in excluded or canonical in seen:
            continue
        seen.add(canonical)
        unique.append((label, canonical, is_md, frag))
    return unique


def md_inline(s, base=None):
    """Render inline markdown. Links resolve relative to BASE — the directory of the file that
    carries them (ruled 2026-08-17: queue rows → QUEUE.md's dir, briefs → queue-briefs/, any
    /view'd doc → its own dir). #fragments pass through to /view unchanged (quoted, never a
    filename part). Default base is SUP: QUEUE.md's own directory."""
    base = SUP if base is None else Path(base)
    out, pos = [], 0
    for m in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", s):
        out.append(html.escape(s[pos:m.start()]))
        target, _, frag = urllib.parse.unquote(m.group(2)).partition("#")
        if not target:  # pure in-document anchor: [x](#section)
            out.append(f'<a href="#{urllib.parse.quote(frag)}">{html.escape(m.group(1))}</a>')
            pos = m.end()
            continue
        p = (base / target).resolve()
        route = "view" if p.suffix == ".md" else "open"
        anchor = f"#{urllib.parse.quote(frag)}" if frag and route == "view" else ""
        out.append(f'<a href="/{route}?p={urllib.parse.quote(str(p))}{anchor}">{html.escape(m.group(1))}</a>')
        pos = m.end()
    out.append(html.escape(s[pos:]))
    t = "".join(out)
    t = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", t)
    t = re.sub(r"~~(.+?)~~", r"<s>\1</s>", t)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    return t


# ---------- state ----------

def read_jsonl(p):
    if not p.exists():
        return []
    out = []
    for line in p.read_text().splitlines():
        try:
            out.append(json.loads(line))
        except Exception:
            pass
    return out


def executed_records():
    """Execution-ledger records that ARE executions. A status:"recorded" entry is a bookkeeping
    acknowledgement — answered, not executed — and must never appear on any surface that presents
    work as done ("Recent executions", the executed count). /activity renders those entries
    itself, truthfully labelled (v1.64)."""
    return [r for r in read_jsonl(EXECUTIONS) if r.get("status") != "recorded"]


def _decision_answers(path):
    """Answer records that are DECISIONS. A desk tick rides the same channel (so the ordinary
    `pull` consumes it) but it is not an owner decision, and it must never be counted as one:
    conflating the two would inflate "awaiting Supervisor execution" with the owner's own
    personal follow-ups (dev-0013)."""
    return [r for r in read_jsonl(path) if not str(r.get("id", "")).startswith(DESK_PREFIX)]


def state():
    # An execution record with status "recorded" is a BOOKKEEPING acknowledgement (an unattended
    # answer pickup captured the owner's answer) and is NOT the work being done. It must never
    # count as executed, or an answered-but-undone row shows as resolved. A record with no status
    # field is a genuine execution — every record that predates this schema is real and unchanged,
    # so the absence of a status can only mean "executed", never "unknown".
    executed, recorded = {}, {}
    for r in read_jsonl(EXECUTIONS):
        # A desk tick is the owner's own follow-up (DESK_PREFIX), never a decision, so it must
        # never land in executed/recorded; it is the same exclusion the desk lane applies
        # elsewhere, extended to the execution ledger. Without it a cleared personal follow-up
        # would fold (via recorded -> queued) into "awaiting Supervisor execution" (dev-0013).
        if str(r.get("id", "")).startswith(DESK_PREFIX):
            continue
        if r.get("status") == "recorded":
            recorded[r["id"]] = r
            executed.pop(r["id"], None)      # a later "recorded" reopens; discipline over presence
        else:
            executed[r["id"]] = r
            recorded.pop(r["id"], None)      # a real execution supersedes an earlier bookkeeping note
    pending = [r["id"] for r in _decision_answers(ANSWERS) if r["id"] not in executed]
    # TWO STATES ONLY (v1.64, an owner-ruled evolution in the reference deployment that
    # supersedes the earlier reopened-row reading): a row is ANSWERED from the moment the owner's
    # answer exists — INCLUDING after a pickup CONSUMED it into the processed store — until a
    # status-less execution record marks it EXECUTED. There is no third state. So a consumed
    # answer whose row is still open in the queue stays answered/queued here: during the
    # execution window the row IS still open, and re-rendered answer buttons on it were the
    # recurring display lie. TRADEOFF, stated plainly: this code previously read
    # open-row-with-consumed-answer as a REOPEN and made the row answerable again. A reopen is
    # only reliably signalled by the row's text or brief CHANGING after the answer, which these
    # stores do not record, so the two cases cannot be told apart from here. The non-answerable
    # rendering is preferred: a false "answerable" re-collects an answer the estate already
    # holds, while a genuine reopen is re-registered under a NEW id and is untouched by this.
    queued = [r["id"] for r in _decision_answers(PROCESSED)
              if r["id"] not in executed and r["id"] not in pending]
    # A "recorded" row (answer captured, work owed) is the SAME owner-visible state as queued —
    # "answered, awaiting Supervisor execution" — so fold it in and let every renderer handle it.
    # It stays in `recorded` for provenance.
    for rid in recorded:
        if rid not in queued and rid not in executed and rid not in pending:
            queued.append(rid)
    # Dedupe: the processed store can carry the same id twice when a row is re-answered and
    # re-pulled, which would double-count it in "awaiting execution".
    pending = list(dict.fromkeys(pending))
    queued = list(dict.fromkeys(queued))
    replies = {}
    for r in read_jsonl(QREPLIES):
        replies.setdefault(r["id"], []).append(r)
    answers = {}
    for r in _decision_answers(PROCESSED) + _decision_answers(ANSWERS):
        if r.get("id") and r.get("answer"):
            answers[r["id"]] = r["answer"]
    # THE ROW'S OWN MARKER IS AN ANSWER SOURCE (v1.64). The queue file is the record; the two
    # jsonl stores are rotating logs. A row the pickup marked but whose store record has aged
    # out, been pruned, or was written by a different deployment must still read ANSWERED —
    # otherwise the board offers answer controls under the owner's own answer. Read HERE rather
    # than at each render site, so every executed|pending|queued computation, the lane counts
    # and the card agree.
    marked = row_answers()
    for rid, verb in marked.items():
        if rid not in executed and rid not in pending and rid not in queued:
            queued.append(rid)
        answers.setdefault(rid, verb)
    return {"pending": pending, "queued": queued, "executed": executed,
            "recorded": list(recorded), "replies": replies, "answers": answers,
            "row_marked": marked}


def row_answers(raw=None):
    """{id: verb} for every queue row carrying the durable ANSWERED marker (Decision cell, or
    the machine block's appended `answered:` field).

    Fails SOFT on an unreadable queue and only there: this feeds a state() that many surfaces
    call, and a fixture with no queue file must not take the whole cockpit down. A queue that IS
    readable but carries a malformed marker simply yields no verb for that row, and the row keeps
    whatever the answer stores say about it."""
    if raw is None:
        if QUEUE is None:
            return {}
        try:
            raw = QUEUE.read_text(encoding="utf-8")
        except OSError:
            return {}
    out = {}
    for c in parse_cards(raw):
        verb = c.get("answered_row") or c.get("answered_mb")
        if verb:
            out[c["id"]] = verb
    return out


def rec_stats():
    recs = [r for r in _decision_answers(PROCESSED) + _decision_answers(ANSWERS)
            if r.get("recommended")]
    followed = sum(1 for r in recs if r["answer"].lower().strip() == r["recommended"].lower().strip())
    return len(recs), followed


def age_days(datestr):
    try:
        return (datetime.date.today() - datetime.date.fromisoformat(datestr)).days
    except Exception:
        return None


# ---------- Dismissal of informational items (v1.64; SPEC.md §4) ----------
# "The information should have a way to be dismissed; if not dismissed, the message stays."
# Four things this is, and is not:
#   1. It covers INFORMATIONAL items only — tier-C FYI cards and the "Preparing for you" gate
#      notices. A tier-A/B decision card is never dismissible: it leaves the board by being
#      ANSWERED. A "Waiting on KM Supervisor" action is never dismissible: it is work owed, and
#      it leaves when the work is done.
#   2. Persistence is the DEFAULT. Nothing here expires, times out, or hides itself on a
#      seen-heuristic; dismissal is the only exit and it is always the owner's hand.
#   3. It is OWNER-SIDE VIEW STATE, never an estate write — an append to dismissed.jsonl,
#      exactly like an answer. The queue file is not touched: the item stays in the record, it
#      only leaves the owner's screen.
#   4. Undo is immediate and re-revealing is permanent: the card offers Undo the instant it is
#      dismissed, and each informational section carries an "N dismissed" disclosure that
#      restores any of them. Dismissal must never feel like deletion.
# The store is append-only: an undo is itself an appended record ({"id", "at", "undo": true}),
# never a rewrite, and the LAST record for an id wins.


def dismissals(records=None):
    """Effective dismissals: id -> the record that dismissed it. Read-only."""
    latest = {}
    for r in (read_jsonl(DISMISSED) if records is None else records):
        if r.get("id"):
            latest[r["id"]] = r
    return {rid: r for rid, r in latest.items() if not r.get("undo")}


def dismissible_ids(cards=None):
    """Ids the owner may dismiss: tier-C rows, and tier-A/B records currently GATED (a missing
    or failing decision brief, or options the surface cannot read — they render in the
    non-actionable "Preparing for you" group). Computed live from the queue on every request —
    never a hardcoded list — so a record whose gate later clears returns to its tier as an
    answerable card, dismissal or not."""
    cards = parse_cards() if cards is None else cards
    out = set()
    for c in cards:
        if c["tier"] == "c":
            out.add(c["id"])
        elif c["tier"] in ("a", "b"):
            if brief_check(c["id"])[1] or options_gate(c, options_of(c)):
                out.add(c["id"])
    return out


def record_dismissal(item_id, undo=False, cards=None, now=None):
    """Append one dismissal (or its undo) for an informational item. Returns (http-code,
    message). Validates against the live queue; appends only to the append-only owner store;
    never touches the queue file."""
    item_id = (item_id or "").strip()
    if item_id not in dismissible_ids(cards):
        return 404, (f"{item_id or 'that item'} is not a dismissible informational item — "
                     "decisions leave by being answered, Supervisor work by being done")
    CFG.mkdir(parents=True, exist_ok=True)
    record = {"id": item_id, "at": now or time.strftime("%Y-%m-%d %H:%M:%S")}
    if undo:
        record["undo"] = True
    with DISMISSED.open("a") as f:
        f.write(json.dumps(record) + "\n")
    return 200, ("Restored to your view." if undo else
                 "Dismissed from your view — it stays in the queue file, the record.")


def dismissed_listing():
    """The `dismissed` CLI view: one JSON line per effective dismissal. READ-ONLY by
    construction — it consumes nothing and rotates nothing (never call a consuming verb from a
    status path)."""
    return [json.dumps(r, sort_keys=True) for r in dismissals().values()]


def dismiss_control(rid):
    """The owner's only control on an informational item."""
    return (f'<div class="dismiss-controls">'
            f'<button class="small" title="Hide this from your cockpit view. It stays in the '
            f'queue file, and you can restore it." onclick="dismiss(\'{rid}\')">Dismiss</button>'
            f'<span class="dismiss-note" id="dismiss-note-{rid}" role="status"></span></div>')


def dismiss_strip(rid):
    """The Undo affordance, rendered with the card and revealed the instant it is dismissed —
    same page render, no reload, so a mis-click is recoverable on the spot."""
    return (f'<div class="dismissed-strip" data-dismissed-strip="{rid}" style="display:none" '
            f'role="status"><span><b>{rid}</b> dismissed — it stays in the queue file, the '
            f'record.</span><button class="small" onclick="undismiss(\'{rid}\')">Undo</button>'
            f'</div>')


def dismissed_entry(card, at=""):
    """One line in the "N dismissed" disclosure: enough to recognise the item, and Restore."""
    text = card["what"][:180] + ("…" if len(card["what"]) > 180 else "")
    when = (f'<span class="feedat">dismissed {html.escape(at)}</span>' if at else
            '<span class="feedat">dismissed</span>')
    return (f'<li class="dismissed-item"><span class="rid">{html.escape(card["id"])}</span>'
            f'<span class="dismissed-text">{md_inline(text)}</span>{when}'
            f'<button class="small" onclick="undismiss(\'{card["id"]}\')">Restore</button></li>')


def render_dismissed_disclosure(entries):
    """The small foot disclosure. Absent when nothing is dismissed; never a count that
    dead-ends — it opens onto the items themselves, each with Restore."""
    if not entries:
        return ""
    return (f'<details class="dismissed-disclosure"><summary>{len(entries)} dismissed</summary>'
            '<p class="dismissed-note">Dismissed items are hidden from this view only. They stay '
            'in the queue file, which is the record, and the Supervisor still sees them. '
            'Restore any of them here.</p>'
            f'<ul class="dismissed-list">{"".join(entries)}</ul></details>')


# ---------- Waiting on KM Supervisor — owner requests on Supervisor actions ----------
# Ruled 2026-08-17 (_inbox/processed/2026-08-17_KM-Cockpit_supervisor-actions-owner-interaction_
# RULED.md): the register is work owed by the KM Supervisor, never the owner's task list. The
# owner may REQUEST (ask for update / run next / hold); every request rides the existing
# questions pipeline under the stable ref `supervisor-action:<action-id>` and reaches the normal
# `questions` pull; the Supervisor's `reply` keyed to the same ref lands back on the row. No
# control edits QUEUE.md or the SUPERVISOR-ACTIONS block, ever — the Supervisor alone updates the
# authoritative row during its own session (a Hold binds its scheduling until released or answered
# with a reasoned alternative the owner can see).

SUP_REF_PREFIX = "supervisor-action:"
SUP_REQUEST_TYPES = {
    "question": None,  # free text, required
    "run-next": "Run this next — make this the next action you pick up",
    "hold": "Hold this action pending my direction",
}
SUP_CONFIRMATION = "Request recorded — awaiting KM Supervisor acknowledgement."
SUP_RUN_NEXT_CONFIRMATION = "Recorded — the KM Supervisor picks this up next."
# The superseded control, kept ONLY as a named rejection (v1.64): an owner on a page rendered
# before this version must be told the click was not recorded, not have it filed under a word
# they no longer have. Nothing is written on this path. Prioritize was retired on the owner's
# own challenge in the reference deployment: a relative nudge was never a usable instruction,
# and the distinction it rested on (an owner ANSWER versus a request on Supervisor work) was
# semantic, not structural — both are one recorded word the cockpit never executes.
SUP_RETIRED_TYPES = {
    "prioritize": "the Prioritize control is now Run next — nothing was recorded; "
                  "reload this page and press Run next",
}

# ---- the dependency, which is the one real difference from a queue row (v1.64) ----
# The SUPERVISOR-ACTIONS block is five cells and nothing else, so a blocker can only live INSIDE
# the action prose. It is therefore QUOTED, never parsed into a field the estate never wrote.
# The cue list is deliberately narrow: a missed dependency costs nothing (the full action text
# is rendered immediately above the quote), an invented one would put words in the estate's
# mouth. Run next over a stated dependency is RECORDED, never refused — the owner may override —
# and the clause travels into the pulled record and the confirmation, so both sides see what is
# being overridden and the Supervisor either runs it or comes back with why not.
SUP_DEPENDENCY_CUES = re.compile(
    r"(\bwaits? on\b|\bwaiting on\b|\bblocked by\b|\bdepends on\b|\bdependent on\b"
    r"|\btrigger is\b|\btrigger:|\bpending (?:his|her|my|the|owner)\b"
    r"|\brequires\b[^.;]{0,90}?\bbefore\b|\bcannot\b[^.;]{0,60}?\buntil\b"
    r"|\bonly after\b|\bnot before\b)", re.I)


def supervisor_dependencies(text, limit=2, cap=200):
    """The clauses of an action's own text that say what it is waiting on, verbatim (trimmed
    with an ellipsis past CAP, trailing clause separators dropped). Empty when the text names
    nothing: the card then shows the action text alone rather than a guessed field. When a
    quoted clause reads badly, fix the action text so the dependency leads — never front-trim
    the quote in the renderer, because trimming can lop a negation and turn a quote into a
    claim."""
    out = []
    for chunk in re.split(r"(?<=[.;])\s+", " ".join((text or "").split())):
        chunk = chunk.strip()
        if not chunk or not SUP_DEPENDENCY_CUES.search(chunk):
            continue
        if len(chunk) > cap:
            chunk = chunk[:cap].rsplit(" ", 1)[0].rstrip(",;:") + " …"
        chunk = chunk.rstrip(" ;")
        if chunk and chunk not in out:
            out.append(chunk)
        if len(out) >= limit:
            break
    return out


def due_status(due):
    """(state, text) for an action's due cell, the same ISO-against-today comparison the
    session-start scan makes, so the board and the scan cannot tell different stories. An
    absent due date renders as a defect rather than as blank space, because "when a session
    picks it up" is not a plan."""
    due = (due or "").strip()
    if not due or due == "-":
        return "missing", "No due date"
    days = age_days(due)
    if days is None:
        return "unreadable", f"Due date unreadable ({due})"
    if days > 0:
        return "overdue", f"Overdue by {days} day{'s' if days != 1 else ''} — was due {due}"
    if days == 0:
        return "today", f"Due TODAY ({due})"
    return "ahead", f"Due {due} (in {-days} day{'s' if days != -1 else ''})"


def record_supervisor_request(action_id, mtype, text="", register=None, now=None):
    """Validate and append one owner request on a Supervisor action. Returns (http-code,
    message). Action ids are parsed LIVE from the SUPERVISOR-ACTIONS block on every request —
    never a hardcoded list; invalid ids and types are rejected. Appends only to the append-only
    questions store; never touches the queue file.

    Run next is never refused, whatever the action says it is waiting on: the owner may
    override. The dependency is carried instead — into the record the Supervisor pulls AND into
    the confirmation the owner reads, so nothing is swallowed on either side."""
    if mtype in SUP_RETIRED_TYPES:
        return 400, SUP_RETIRED_TYPES[mtype]
    if mtype not in SUP_REQUEST_TYPES:
        return 400, f"invalid request type {mtype!r} — question, run-next, or hold"
    register = parse_supervisor_actions() if register is None else register
    action = next((a for a in register["actions"] if a["id"] == action_id), None)
    if action is None:
        return 404, f"unknown supervisor action id {action_id!r}"
    message = SUP_REQUEST_TYPES[mtype] or " ".join((text or "").split())
    if not message:
        return 400, "an update request needs text"
    confirmation = SUP_RUN_NEXT_CONFIRMATION if mtype == "run-next" else SUP_CONFIRMATION
    if mtype == "run-next":
        stated = supervisor_dependencies(action["action"], limit=1, cap=140)
        if stated:
            message += (f' (the action states: "{stated[0]}" — run it or come back with why not)')
            confirmation += (f' Note: this action states it is waiting on something — '
                             f'"{stated[0]}". The Supervisor will either run it or come back '
                             f'with why not.')
    CFG.mkdir(parents=True, exist_ok=True)
    with QUESTIONS.open("a") as f:
        f.write(json.dumps({"id": SUP_REF_PREFIX + action_id, "type": mtype,
                            "question": message,
                            "at": now or time.strftime("%Y-%m-%d %H:%M:%S")}) + "\n")
    return 200, confirmation


def supervisor_action_messages():
    """Owner requests (unpulled and pulled — a pull is not an acknowledgement) and Supervisor
    replies, keyed by action id, each list oldest-first."""
    requests, replies = {}, {}
    for r in read_jsonl(QUESTIONS) + read_jsonl(QPROCESSED):
        rid = r.get("id", "")
        if rid.startswith(SUP_REF_PREFIX):
            requests.setdefault(rid[len(SUP_REF_PREFIX):], []).append(r)
    for r in read_jsonl(QREPLIES):
        rid = r.get("id", "")
        if rid.startswith(SUP_REF_PREFIX):
            replies.setdefault(rid[len(SUP_REF_PREFIX):], []).append(r)
    for d in (requests, replies):
        for records in d.values():
            records.sort(key=lambda r: r.get("at", ""))
    return requests, replies


def supervisor_action_state(reqs, reps):
    """(state, latest-request, latest-reply): open — nothing awaiting acknowledgement;
    sent — the latest request has no reply yet; replied — the reply is at least as new."""
    if not reqs:
        return "open", None, (reps[-1] if reps else None)
    last_req, last_rep = reqs[-1], (reps[-1] if reps else None)
    if last_rep and last_rep.get("at", "") >= last_req.get("at", ""):
        return "replied", last_req, last_rep
    return "sent", last_req, last_rep


def render_supervisor_actions(register, messages=None):
    requests, replies = supervisor_action_messages() if messages is None else messages
    if register["state"] == "missing":
        body = ('<div class="empty-state"><b>Supervisor action register unavailable.</b> '
                'Check QUEUE.md.</div>')
    elif not register["actions"]:
        body = ('<div class="empty-state">'
                'Nothing currently owed by the KM Supervisor.</div>')
    else:
        items = []
        for action in register["actions"]:
            aid = action["id"]
            age = age_days(action["since"])
            age_text = ("Date unavailable" if age is None else
                        f'Open {age} day{"s" if age != 1 else ""}')
            dstate, dlabel = due_status(action["due"])
            due_text = (f' · <span class="sup-due sup-due-{dstate}">'
                        f'{html.escape(dlabel)}</span>')
            stated = supervisor_dependencies(action["action"])
            dep_html = ""
            if stated:
                dep_html = ('<div class="sup-dependency"><b>Stated dependency</b> — quoted '
                            'from the action above: '
                            + " ".join(f"<q>{html.escape(d)}</q>" for d in stated)
                            + '</div>')
            astate, last_req, last_rep = supervisor_action_state(
                requests.get(aid, []), replies.get(aid, []))
            flag = ""
            if astate == "sent":
                flag = ('<span class="sup-state doneflag">Request sent — awaiting '
                        'KM Supervisor acknowledgement</span>')
            elif astate == "replied":
                flag = '<span class="sup-state execflag">Supervisor replied</span>'
            reply_html = ""
            if astate == "replied" and last_rep:
                reply_html = (f'<div class="qreply sup-reply"><b>Supervisor:</b> '
                              f'{md_inline(last_rep.get("reply", ""))} '
                              f'<span class="feedat">{html.escape(last_rep.get("at", ""))}</span></div>')
            thread = ""
            if last_req:
                thread = (f'<details class="sup-thread"><summary>Latest request</summary>'
                          f'<div class="qreply"><b>You ({html.escape(last_req.get("type", "question"))}):</b> '
                          f'{html.escape(last_req.get("question", ""))} '
                          f'<span class="feedat">{html.escape(last_req.get("at", ""))}</span></div></details>')
            controls = ""
            # Controls only on ids safe to carry into onclick handlers; anything else stays
            # rendered read-only (the block is hand-maintained — defensive, not expected).
            if re.match(r"^[A-Za-z0-9][A-Za-z0-9_.:-]*$", aid):
                controls = (
                    f'<div class="sup-controls" data-sup-controls="{html.escape(aid)}">'
                    f'<details class="sup-ask"><summary>Ask for update</summary>'
                    f'<div class="answer"><input type="text" id="sup-q-{html.escape(aid)}" '
                    f'placeholder="What would you like to know about this work?">'
                    f'<button class="small" onclick="supAsk(\'{aid}\')">Send</button></div></details>'
                    f'<button class="small" title="Record that this is the next action the '
                    f'KM Supervisor picks up — recorded here, executed in its own session." '
                    f'onclick="supSend(\'{aid}\', \'run-next\')">Run next</button>'
                    f'<button class="small" title="Bind the scheduling of this action until you '
                    f'release it." onclick="supSend(\'{aid}\', \'hold\')">Hold</button></div>'
                    f'<div class="sup-confirm" id="sup-confirm-{html.escape(aid)}" role="status"></div>')
            items.append(
                f'<li data-sup-action="{html.escape(aid)}" data-sup-state="{astate}">'
                f'<div>{md_inline(action["action"])}{flag}</div>'
                f'<div class="supervisor-action-meta">{age_text}{due_text} · '
                f'{md_inline(action["evidence"])}</div>'
                f'{dep_html}{reply_html}{thread}{controls}</li>'
            )
        body = f'<ol class="supervisor-action-list">{"".join(items)}</ol>'
    malformed = register["malformed"]
    warning = (f'<p class="register-warning">{malformed} malformed entr'
               f'{"y" if malformed == 1 else "ies"} omitted.</p>' if malformed else "")
    guidance = ('<p class="sup-guidance">Run next records one word for the KM Supervisor to act '
                'on at its next pull; nothing here is executed by this page, and an action that '
                'states a dependency is still triggered — the Supervisor runs it or comes back '
                'with why not. Anything that needs your decision is never held here: it is '
                'registered on the <a href="/decisions">Decisions</a> page as a governed Tier A '
                'or B row with explicit options.</p>')
    return ('<section class="supervisor-actions" aria-labelledby="supervisor-actions-heading">'
            '<div class="supervisor-actions-title">'
            '<h2 id="supervisor-actions-heading">Waiting on KM Supervisor</h2>'
            '<p>Work owed by the KM Supervisor. No owner action is required unless you choose '
            'to redirect it.</p></div>' + body + warning + guidance + '</section>')


def render_watchlist_pointer(cards):
    """Tier-C FYI on the Overview: a COUNT and a link, never the items (v1.64, the one-home
    rule — SPEC.md §5.5). Tier C has ONE home — the decisions board, inside its lane — because
    that is where it is acted on: the Dismiss control belongs with the item, and the
    "N dismissed" restore disclosure with it. This line says how many there are and takes one
    click to them."""
    if not cards:
        return ""
    dismissed = dismissals()
    shown = [c for c in cards if c["id"] not in dismissed]
    hidden = len(cards) - len(shown)
    lead = (f'<b>{len(shown)} item{"" if len(shown) == 1 else "s"} in view</b>'
            if shown else "<b>Nothing in view</b>")
    tail = (f' {hidden} dismissed, restorable there.' if hidden else "")
    return f"""<section class="watchlist-pointer" aria-labelledby="watchlist-heading">
<h2 id="watchlist-heading">Watchlist</h2>
<p class="pointer-note">{lead} — information and reminders, nothing asked, nothing expiring.
Each sits in its own lane on the <a href="/decisions">decisions board →</a>, which is where you
dismiss it and where a dismissed one is restored.{tail}</p></section>"""


# ---------- the lane axis on the board (v1.64; SPEC.md §3) ----------

def lane_counts(cards, st=None):
    """Open decision rows (tier A and B, not yet answered) per lane. Counts ROWS — exactly what
    the global tier counts beside it count — so the two are directly comparable and the halt
    stays global. Desk items are NOT folded in: they are counted separately, as themselves."""
    st = state() if st is None else st
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    counts = {lane: 0 for lane in LANE_ORDER}
    for c in cards:
        if c["tier"] in ("a", "b") and c["id"] not in resolved:
            # A row with no answerable option renders GATED, not answerable, so it must not
            # inflate the answerable lane counts — a count the board then refuses to let the
            # owner act on is a dead-end signal. Machine-block-only parse errors keep counting:
            # they render LOUD inside their tier section, not gated out.
            if not c.get("parse_error") and not options_of(c):
                continue
            counts[lane_of(c.get("lane"))] += 1
    return counts


def render_lane_strip(counts):
    """Per-lane counts on the Overview: the ONE place the per-lane split is stated. It does not
    restate the desk count — the desk has its own page and tile — and it must not, because
    these pills link to /decisions?lane=…, which renders rows and not the desk."""
    pills = []
    for lane in LANE_ORDER:
        name, _desc = LANES[lane]
        note = ""
        if lane == "hand":
            note = '<span class="lane-note">acts, not decisions</span>'
        pills.append(f'<a class="lane-pill" href="/decisions?lane={lane}">'
                     f'<span class="lane-pill-n">{counts.get(lane, 0):02d}</span>'
                     f'<span class="lane-pill-l">{html.escape(name)}</span>{note}</a>')
    return f"""<section class="lane-strip" aria-labelledby="lane-strip-heading">
<div class="lane-strip-head"><h2 id="lane-strip-heading">Open rows by lane</h2>
<p>The same open tier A and B rows counted above, split by what you need in your head to answer:
tier is the clock, the lane is the context. This is the only per-lane statement of those numbers;
the halt and the defaults act on the estate totals above. Open a lane to work through its rows.</p></div>
<div class="lane-pills">{"".join(pills)}</div></section>"""


def lane_href(lane=None, hub_filter=None):
    parts = [(k, v) for k, v in (("lane", lane), ("hub", hub_filter)) if v]
    return "/decisions" + ("?" + urllib.parse.urlencode(parts) if parts else "")


def render_lane_bar(counts, active=None, hub_filter=None):
    """The lane selector on the decisions board: one lane at a time, or all of them grouped.
    It counts ROWS only; the desk is not counted here, because this board does not render the
    desk and a count must never point at a page that does not show the thing it counts."""
    chips = [f'<a class="lane-chip{"" if active else " on"}" href="{lane_href(None, hub_filter)}"'
             ' title="Every lane, grouped">All lanes</a>']
    for lane in LANE_ORDER:
        name, desc = LANES[lane]
        tip = f"{desc} Count: open tier A and B rows; tier C and prepared items also sit here."
        chips.append(
            f'<a class="lane-chip{" on" if active == lane else ""}" '
            f'href="{lane_href(lane, hub_filter)}" title="{html.escape(tip)}">'
            f'{html.escape(name)} <b>{counts.get(lane, 0):02d}</b></a>')
    return f'<nav class="lane-bar" aria-label="Lane">{"".join(chips)}</nav>'


def lane_scope_note(active, counts, desk_open=0):
    """When one lane is showing, say what the OTHER lanes still hold. A scoped view must never
    hide the size of what it scoped out."""
    if not active:
        return ""
    others = [f"{LANES[l][0].lower()} {counts.get(l, 0)}" for l in LANE_ORDER if l != active]
    desk = (f' Your desk holds {desk_open} item{"" if desk_open == 1 else "s"}, on '
            '<a href="/desk">Your desk</a>.' if desk_open and active != "hand" else "")
    return (f'<p class="lane-scope">Showing <b>{html.escape(LANES[active][0])}</b> only. '
            f'Still open elsewhere: {html.escape(", ".join(others))}.{desk} '
            f'<a href="{lane_href(None)}">Show all lanes</a></p>')


def hand_row_pointers(cards=None, st=None):
    """Open `hand`-lane rows (tier A/B, not yet answered), as compact pointers for the desk.
    The two surfaces carry the SAME KIND of material — acts only the owner can perform, neither
    a decision — and are reconciled at the SECTION, not the card: a registered hand row keeps
    its brief, options and answer channel on the board's hand lane; a desk bullet keeps Mark
    done on the desk. One act never gets two sets of controls."""
    cards = parse_cards() if cards is None else cards
    st = state() if st is None else st
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    out = []
    for c in cards:
        if lane_of(c.get("lane")) != "hand" or c["tier"] not in ("a", "b"):
            continue
        if c["id"] in resolved:
            continue
        age = age_days(c.get("raised", ""))
        out.append({"id": c["id"], "title": decision_title(c),
                    "age": f"open {age}d" if age else ""})
    return out


def render_hand_rows(rows):
    """A POINTER, not a list. Registered `hand` rows are the same kind of material as the desk,
    but they are ACTED on where their case, options and answer buttons live: the decisions
    board's hand lane. So the desk never re-lists them — their number is stated once, in the
    lane counts, and this line is the way in (an item is rendered in exactly one place; every
    other surface refers to it by count with a link)."""
    if not rows:
        return ""
    return ('<p class="pointer-note">Some registered rows are also acts by your hand — the same '
            'kind of thing as the items below, but each carries a full case and options. They '
            'are answered where they live: <a href="/decisions?lane=hand">the "By your hand" '
            'lane →</a>.</p>')


def render_hub_portfolio(rows, heading="Knowledge hub portfolio", intro=None, show_all=False):
    intro = (intro or
             "Attention first. Status is derived from open decisions, pending proposals, Git recency, and the governed hub registry.")
    body = []
    for row in rows:
        status_class = re.sub(r"[^a-z]+", "-", row["status"].lower()).strip("-")
        if row["last_date"]:
            update = (f'<time class="update-date" datetime="{row["last_date"]}">'
                      f'{row["last_date"]}</time>'
                      f'<span class="update-subject">{html.escape(row["last_subject"] or "Commit recorded")}</span>')
        else:
            update = ('<span class="update-date">No Git update available</span>'
                      '<span class="update-subject">Repository history could not be read</span>')
        recent = row["recent"]
        if recent:
            note = recent.get("note", "")
            activity = (f'<span class="recentid">{html.escape(recent.get("id", ""))}</span> '
                        f'{md_inline(note[:90])}{"…" if len(note) > 90 else ""}'
                        f'<span class="hubdir">{html.escape(recent.get("at", "")[:10])}</span>')
        else:
            activity = '<span class="update-subject">No recent execution</span>'
        body.append(f"""<article class="hub-card hub-status-{status_class}" data-status="{status_class}">
<header class="hub-card-head"><div><span class="hubdir">{html.escape(row['dirname'])}</span>
<h3>{html.escape(row['name'])}</h3></div><div class="status-group">
<span class="status status-{status_class}">{html.escape(row['status'])}</span>
<span class="lifecycle">{html.escape(row['lifecycle'])}</span></div></header>
<div class="hub-card-body"><div class="evidence-block"><span class="evidence-label">Last update</span>{update}</div>
<div class="evidence-block"><span class="evidence-label">Supervisor signals</span>
<div class="signals"><b>{row['linked']}</b><span>Open owner decisions (A/B)</span>
<b>{row['owner_pending']}</b><span>Proposals needing decision or routing</span>
<b>{row['awaiting_exec']}</b><span>Awaiting Supervisor execution</span></div></div></div>
<div class="hub-activity"><span class="evidence-label">Recent activity</span>{activity}</div>
{render_proposal_list(row.get('proposals', []))}
<footer class="portfolio-links">
<a aria-label="Open {html.escape(row['name'])} decisions" href="/decisions?hub={row['key']}">Decisions →</a>
<a aria-label="Open {html.escape(row['name'])} activity" href="/activity?hub={row['key']}">Activity →</a>
</footer></article>""")
    content = (f'<div class="hub-card-grid" data-view="hub-card-grid">{"".join(body)}</div>'
               if body else
               '<div class="empty-state"><b>No hubs need attention.</b> All configured hubs are current.</div>')
    all_link = '<a class="section-link" href="/hubs">View all hubs →</a>' if show_all else ""
    return f"""<section class="portfolio-section" aria-labelledby="portfolio-heading">
<div class="portfolio-title"><div><h2 id="portfolio-heading">{html.escape(heading)}</h2>
<p>{html.escape(intro)}</p></div>{all_link}</div>{content}
</section>"""


# ---------- pages ----------

# ---------- The owner's desk (added v1.36; SPEC.md §3, STANDARD.md → "The owner's desk") ----------
# The desk holds the deployment owner's PERSONAL follow-ups: things the owner is waiting on and
# things the owner owes someone. They are a HAND LANE, not estate decisions: they never default,
# they never expire, and they never occupy a decision row in tiers A/B/C. The desk lives in its own
# section, after Hubs. Until this section existed the cockpit parsed the decision tiers only, so
# every desk nudge added to the queue was invisible on the owner's surface while the estate believed
# it was surfaced.
#
# The control is a TICK, not a Dismiss. Dismissing a commitment would hide a live obligation; a tick
# records "done" so the estate can stop nudging. The tick rides the ANSWERS channel —
# {"id": "desk-<slug>", "answer": "done", "done": true, "item": "<text>"} — so the ordinary
# supervisor `pull` consumes it exactly like an answer and the nudge is pruned from the queue in the
# supervisor's own session. The cockpit NEVER edits the queue file: the desk on screen is derived
# from the file on every request, and the owner's tick is owner-side state, appended, never a rewrite.
#
# IDS. Desk items are prose bullets with no ids of their own, so the id is DERIVED: "desk-" plus a
# slug of the bullet's leading **bold phrase** (falling back to its first words when a bullet carries
# no bold lead). A derived id survives the owner or the supervisor editing the rest of the bullet —
# dates and owed items change while the commitment stays the same. The stated limit: RENAMING THE
# BOLD LEAD MINTS A NEW ID, so a ticked item whose lead is reworded returns to the desk. That failure
# direction is deliberate — the estate re-nudges rather than silently dropping a commitment the owner
# never ticked.

DESK_PREFIX = "desk-"
DESK_HEADING_RE = re.compile(r"^##\s+Owner'?s desk\b", re.I)


def _join_wrapped(raw):
    """Join continuation lines onto the row or bullet they belong to: long bullets wrap in the
    queue file, and parsing them line-by-line once produced mangled items."""
    joined = []
    for line in raw.splitlines():
        if joined and line.startswith("  ") and not line.lstrip().startswith(("-", "|", "#", "<")) \
                and (joined[-1].lstrip().startswith("|") or joined[-1].lstrip().startswith("- ")):
            joined[-1] += " " + line.strip()
        else:
            joined.append(line)
    return joined


def desk_slug(text, limit=48):
    """Deterministic, url/onclick-safe slug: link labels kept, markdown emphasis dropped,
    everything outside [a-z0-9] collapsed to a hyphen."""
    t = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", text)
    t = re.sub(r"[*_`~]", "", t)
    t = re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")
    return t[:limit].strip("-") or "item"


def parse_desk(raw=None):
    """The items under the queue file's "## Owner's desk" heading, one card per bullet. Read-only.
    One bullet = one item: the granularity is the queue's own, never a split the cockpit invents out
    of prose punctuation. Returns [{id, label, text}] in file order."""
    if raw is None:
        if QUEUE is None or not QUEUE.exists():
            return []
        raw = QUEUE.read_text(encoding="utf-8")
    items, inside, used = [], False, {}
    for line in _join_wrapped(raw):
        if line.startswith("##"):
            inside = bool(DESK_HEADING_RE.match(line))
            continue
        if not inside:
            continue
        if line.startswith("<!--"):
            break
        if not line.startswith("- "):
            continue
        text = line[2:].strip()
        if not text:
            continue
        lead = re.match(r"\*\*(.+?)\*\*", text)
        label = lead.group(1).strip() if lead else " ".join(text.split()[:8])
        slug = desk_slug(label)
        used[slug] = used.get(slug, 0) + 1
        # Two bullets whose leads slug identically are disambiguated by order of appearance.
        rid = DESK_PREFIX + (slug if used[slug] == 1 else f"{slug}-{used[slug]}")
        items.append({"id": rid, "label": label, "text": text})
    return items


def desk_records():
    """Every desk record, oldest first, from BOTH the unpulled and the pulled answer stores: a tick
    must not reappear on the desk merely because the supervisor pulled it."""
    recs = [r for r in read_jsonl(PROCESSED) + read_jsonl(ANSWERS)
            if str(r.get("id", "")).startswith(DESK_PREFIX)]
    return sorted(recs, key=lambda r: r.get("at", ""))


def desk_ticks(records=None):
    """Effective ticks: id -> the record that ticked it. Append-only store, last record wins, an
    untick is itself a record. Read-only."""
    latest = {}
    for r in (desk_records() if records is None else records):
        latest[r["id"]] = r
    return {rid: r for rid, r in latest.items() if r.get("done")}


def record_desk_tick(item_id, undo=False, items=None, now=None):
    """Append one tick (or its undo) for a desk item. Returns (http-code, message). Validates
    against the live desk parsed from the queue; appends only to the append-only owner store; never
    touches the queue file, never executes anything."""
    item_id = (item_id or "").strip()
    items = parse_desk() if items is None else items
    item = next((i for i in items if i["id"] == item_id), None)
    if item is None:
        return 404, (f"{item_id or 'that item'} is not an item on your desk — the desk is parsed "
                     "live from the queue on every request")
    CFG.mkdir(parents=True, exist_ok=True)
    record = {"id": item_id, "answer": "not done" if undo else "done", "done": not undo,
              "item": item["text"][:300], "at": now or time.strftime("%Y-%m-%d %H:%M:%S")}
    if undo:
        record["undo"] = True
    with ANSWERS.open("a") as f:
        f.write(json.dumps(record) + "\n")
    return 200, ("Back on your desk." if undo else
                 "Marked done — the Supervisor drops the nudge on its next pull.")


def desk_control(rid):
    """The owner's only control on a desk item. Deliberately NOT Dismiss: these are live
    commitments, and hiding one without resolving it is the failure mode to avoid."""
    return (f'<div class="desk-controls">'
            f'<button class="small" title="Record this as done. The Supervisor removes the '
            f'nudge from the queue on its next pull; you can undo it here." '
            f'onclick="tick(\'{rid}\')">Mark done</button>'
            f'<span class="desk-note" id="desk-note-{rid}" role="status"></span></div>')


def desk_strip(rid):
    """The Undo affordance, rendered with the item and revealed the instant it is ticked — same
    page render, no reload, so a mis-click is recoverable on the spot."""
    return (f'<div class="desk-strip" data-desk-strip="{rid}" style="display:none" '
            f'role="status"><span>Marked <b>done</b> — the Supervisor prunes the nudge on its '
            f'next pull.</span><button class="small" onclick="untick(\'{rid}\')">Undo</button>'
            f'</div>')


def desk_done_entry(item, at=""):
    """One line in the "N done" disclosure: enough to recognise the item, and a way back."""
    text = item["text"][:180] + ("…" if len(item["text"]) > 180 else "")
    when = (f'<span class="feedat">done {html.escape(at)}</span>' if at else
            '<span class="feedat">done</span>')
    return (f'<li class="desk-done-item"><span class="desk-text">{md_inline(text)}</span>'
            f'{when}<button class="small" onclick="untick(\'{item["id"]}\')">Undo</button></li>')


def render_desk_done_disclosure(entries):
    """The small foot disclosure — never a count that dead-ends: it opens onto the items themselves,
    each with Undo."""
    if not entries:
        return ""
    return (f'<details class="desk-done-disclosure"><summary>{len(entries)} marked done'
            '</summary><p class="desk-done-note">These stay in the queue until the KM Supervisor '
            'picks the tick up on its next pull and removes the nudge. Undo any of them here.</p>'
            f'<ul class="desk-done-list">{"".join(entries)}</ul></details>')


def render_desk(items=None, ticks=None, hand_rows=None):
    """The owner's desk section. Compact cards, clearly separated from the decision tiers and
    from Supervisor work: nothing here is a decision and nothing here is owed by the Supervisor.
    A ticked item moves off the active list into the done disclosure; open `hand` rows are
    pointed at, never re-listed (one home per item, v1.64)."""
    items = parse_desk() if items is None else items
    ticks = desk_ticks() if ticks is None else ticks
    rows, done = [], []
    for item in items:
        rid = item["id"]
        if rid in ticks:
            done.append(desk_done_entry(item, ticks[rid].get("at", "")))
            continue
        rows.append(f"""<article class="desk-item" data-desk-item="{html.escape(rid)}">
<span class="desk-badge">DESK</span>
<div class="desk-text">{md_inline(item["text"])}</div>
{desk_control(rid)}</article>{desk_strip(rid)}""")
    body = (f'<div class="desk-items">{"".join(rows)}</div>' if rows else
            '<div class="empty-state">Nothing open on your desk. Your own follow-ups appear here '
            'when the queue carries an <b>Owner\'s desk</b> section.</div>')
    return f"""<section class="desk" id="desk" aria-labelledby="desk-heading">
<div class="desk-title"><h2 id="desk-heading">Your desk</h2>
<p>Your own follow-ups: what you are waiting on and what you owe someone. Not decisions, and not
Supervisor work. Nothing here defaults or expires: an item stays until you mark it done.</p></div>
{render_hand_rows(hand_rows or [])}{body}{render_desk_done_disclosure(done)}</section>"""


def desk_page():
    cards = parse_cards()
    st = state()
    return page("KM Cockpit — Your desk",
                render_desk(hand_rows=hand_row_pointers(cards, st)), active="desk")


_standard_cache = {}


def published_standard(repo, publish_branch):
    """Return (version, full commit, failure) from LOCAL publish-branch history: the newest
    commit on the branch whose committed STANDARD.md H1 carries a version with no draft
    qualifier. Resolved from committed history, never the working tree — a working-tree H1
    mid-draft reads "(vX.Y draft)", and reporting a drafted number as the pinned version is a
    wrong answer with full confidence (v1.64)."""
    ref = f"refs/heads/{publish_branch}"
    resolved = subprocess.run(
        ["git", "-C", str(repo), "rev-parse", "--verify", f"{ref}^{{commit}}"],
        capture_output=True, text=True, timeout=10)
    if resolved.returncode != 0:
        return "", "", f"publish branch '{publish_branch}' not found"
    history = subprocess.run(
        ["git", "-C", str(repo), "rev-list", resolved.stdout.strip(), "--", "STANDARD.md"],
        capture_output=True, text=True, timeout=10)
    if history.returncode != 0:
        detail = (history.stderr.strip() or "git rev-list failed").splitlines()[0]
        return "", "", f"cannot read STANDARD.md history: {detail[:120]}"
    for commit in (line.strip() for line in history.stdout.splitlines() if line.strip()):
        shown = subprocess.run(
            ["git", "-C", str(repo), "show", f"{commit}:STANDARD.md"],
            capture_output=True, text=True, timeout=10)
        if shown.returncode != 0:
            detail = (shown.stderr.strip() or "git show failed").splitlines()[0]
            return "", "", f"cannot read committed STANDARD.md: {detail[:120]}"
        match = STD_PUBLISHED_H1_RE.search(shown.stdout[:6000])
        if not match or re.search(r"\bdraft\b", match.group(2) or "", re.I):
            continue
        return match.group(1), commit, ""
    return "", "", "no non-draft STANDARD.md commit on publish branch"


def standard_info(repo=None, publish_branch=None):
    """Read-only LOCAL state of the tracked KM Standard checkout for the Home status card.
    Local git plumbing only, never a fetch and never any network call: the render must not depend
    on connectivity, and the origin comparison is honestly 'as of the last fetch' (the mtime of
    .git/FETCH_HEAD). A missing or unreadable checkout reports itself instead of fabricating
    state. When no checkout is configured (STANDARD_REPO is None), the card does not render.
    The default call (the live card) is cached 60 seconds; explicit repo arguments (fixtures)
    are never cached."""
    cached = repo is None and publish_branch is None
    repo = Path(repo) if repo else STANDARD_REPO
    publish_branch = publish_branch or STANDARD_PUBLISH_BRANCH
    info = {"configured": True, "ok": False, "missing": False, "error": "",
            "version": "", "publish_branch": publish_branch, "published_commit": "",
            "publication_error": "", "ahead": 0, "behind": 0, "unpushed": [],
            "drafts": [], "fetched": ""}
    if repo is None:
        info["configured"] = False
        return info
    if cached:
        # Keyed on the reflog's mtime as well as the clock, so a commit in the checkout
        # invalidates the cache immediately: a card that keeps saying "in sync" for a minute
        # after a commit is a wrong render with full confidence.
        try:
            reflog_mtime = (repo / ".git" / "logs" / "HEAD").stat().st_mtime
        except OSError:
            reflog_mtime = 0
        hit = _standard_cache.get("info")
        if hit and time.time() - hit[0] < 60 and hit[2] == reflog_mtime:
            return hit[1]
    if not repo.is_dir() or not (repo / ".git").exists():
        info["missing"] = True
        info["error"] = f"standard checkout not found at {repo}"
        return info
    try:
        version, commit, failure = published_standard(repo, publish_branch)
        info["version"] = version
        info["published_commit"] = commit
        info["publication_error"] = failure
    except (OSError, subprocess.SubprocessError) as exc:
        info["publication_error"] = f"git unavailable while reading publication: {exc}"[:160]
    try:  # push state: the publish branch versus its origin counterpart, local git only
        origin_ref = f"origin/{publish_branch}"
        local_ref = f"refs/heads/{publish_branch}"
        r = subprocess.run(["git", "-C", str(repo), "rev-list", "--left-right", "--count",
                            f"{origin_ref}...{local_ref}"],
                           capture_output=True, text=True, timeout=10)
        if r.returncode == 0:
            behind, ahead = (int(x) for x in r.stdout.split())
            info["behind"], info["ahead"], info["ok"] = behind, ahead, True
            if ahead:
                lg = subprocess.run(["git", "-C", str(repo), "log",
                                     f"{origin_ref}..{local_ref}",
                                     "--format=%h %s"], capture_output=True, text=True, timeout=10)
                if lg.returncode == 0:
                    info["unpushed"] = [s for s in lg.stdout.strip().splitlines() if s][:20]
        else:
            info["error"] = ((r.stderr.strip() or "git failed").splitlines()[0])[:160]
    except Exception as e:
        info["error"] = f"git unavailable: {e}"[:160]
    try:
        info["fetched"] = time.strftime("%Y-%m-%d %H:%M",
                                        time.localtime((repo / ".git" / "FETCH_HEAD").stat().st_mtime))
    except OSError:
        pass
    # Draft RFCs: status banner reads DRAFT. Rendered inline (title, status, path) rather than
    # as /view links, because the checkout lives outside the estate root and the file routes'
    # confinement is a boundary this card must not widen.
    rfcs = repo / "rfcs"
    for f in (sorted(rfcs.glob("*.md")) if rfcs.is_dir() else []):
        try:
            head = f.read_text(encoding="utf-8", errors="replace")[:4000]
        except OSError:
            continue
        sm = re.search(r"\*\*Status:\s*DRAFT\b[^*]*\*\*", head, re.I)
        if not sm:
            continue
        tm = re.search(r"^title:\s*(.+)$", head, re.M)
        vm = re.search(r"[Dd]rafted as \*{0,2}(v\d[\w.]*)", head)
        info["drafts"].append({"file": f.name,
                               "title": (tm.group(1).strip() if tm else f.stem),
                               "status": re.sub(r"\*+", "", sm.group(0)).strip(),
                               "drafts_version": vm.group(1) if vm else ""})
    if cached:
        try:
            reflog_mtime = (repo / ".git" / "logs" / "HEAD").stat().st_mtime
        except OSError:
            reflog_mtime = 0
        _standard_cache["info"] = (time.time(), info, reflog_mtime)
    return info


def render_standard_card(info, related=()):
    """The KM Standard status card on Home: read-only visibility on the standard checkout the
    deployment tracks, showing the PUBLISHED version resolved from the publish branch's committed
    history and the checkout's push state against origin. Display only, never a control (a
    surface, not a pen, SPEC.md §1); a standard change that needs the owner is a governed
    tier-A/B decision, never a button here — decision-shaped items link their queue row. The
    checkout lives OUTSIDE the estate root, so this card emits no file link into it: the
    file-serving routes' root confinement (§4) is a boundary this card must not widen. Returns
    "" when no checkout is configured, so a deployment that keeps none shows nothing rather
    than a guess."""
    if not info.get("configured"):
        return ""
    lines = []
    if info["missing"]:
        lines.append('<div class="std-line">The tracked KM Standard checkout is <b>unavailable</b>, '
                     'so nothing is shown rather than guessed.</div>'
                     f'<div class="std-line std-path">{html.escape(info["error"])}</div>')
    else:
        if info["version"] and info["published_commit"]:
            branch = html.escape(info["publish_branch"])
            short_commit = html.escape(info["published_commit"][:7])
            lines.append(f'<div class="std-line"><b>Published {html.escape(info["version"])}</b> '
                         f'<span class="std-muted">— {branch} at '
                         f'<code>{short_commit}</code></span></div>')
        else:
            detail = info.get("publication_error") or "published commit not readable"
            lines.append('<div class="std-line"><b>Published version unavailable.</b> '
                         f'<span class="std-muted">{html.escape(detail)}</span></div>')
        if info["ok"]:
            if info["ahead"]:
                n = info["ahead"]
                subjects = "".join(f"<li><code>{html.escape(s)}</code></li>"
                                   for s in info["unpushed"])
                lines.append(f'<div class="std-line"><b>{n} commit{"s" if n != 1 else ""} not yet '
                             f'pushed to origin</b><details><summary>unpushed commit'
                             f'{"s" if n != 1 else ""}</summary><ul>{subjects}</ul></details></div>')
            else:
                lines.append('<div class="std-line"><b>In sync with origin</b> '
                             '<span class="std-muted">(as of the last fetch)</span></div>')
            if info["behind"]:
                lines.append(f'<div class="std-line">origin carries <b>{info["behind"]} '
                             f'commit{"s" if info["behind"] != 1 else ""}</b> not yet pulled '
                             'locally.</div>')
        else:
            lines.append('<div class="std-line">Local-vs-origin state unavailable: '
                         f'{html.escape(info["error"] or "git failed")}.</div>')
        if info["drafts"]:
            items = "".join(
                f'<li>{html.escape(d["title"])}'
                + (f' <b>(drafts {html.escape(d["drafts_version"])})</b>' if d["drafts_version"] else "")
                + f' — <span class="std-muted">{html.escape(d["status"])}</span> '
                  f'<span class="std-path">rfcs/{html.escape(d["file"])}</span></li>'
                for d in info["drafts"])
            lines.append(f'<div class="std-line">Draft RFCs ({len(info["drafts"])}):<ul>{items}</ul></div>')
        for rid, txt in related:
            plain = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", txt).replace("**", "").strip()
            plain = plain[:140] + ("…" if len(plain) > 140 else "")
            lines.append(f'<div class="std-line">Open decision on this: '
                         f'<a href="/decisions#card-{html.escape(rid)}"><b>{html.escape(rid)}</b></a>'
                         f' — {html.escape(plain)} '
                         f'<a href="/decisions#card-{html.escape(rid)}">review →</a></div>')
        fetched = info["fetched"]
        lines.append('<div class="std-line std-muted">Origin state is as of the last local fetch'
                     + (f": {html.escape(fetched)}" if fetched else " (no fetch recorded)")
                     + '. This card reads local git only and never contacts the network.</div>')
    return ('<section class="card standard-card" aria-labelledby="standard-heading">'
            '<h2 id="standard-heading">KM Standard</h2>' + "".join(lines) + "</section>")


def home():
    cards = parse_cards()
    st = state()
    a = [c for c in cards if c["tier"] == "a"]
    b = [c for c in cards if c["tier"] == "b"]
    c_ = [c for c in cards if c["tier"] == "c"]
    # Open owner decisions never conflate with answered-but-unexecuted work (ruling 2026-08-17):
    # a row the owner already answered is the Supervisor's debt, not his.
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    open_a = [c for c in a if c["id"] not in resolved]
    open_b = [c for c in b if c["id"] not in resolved]
    ages = [age_days(x.get("raised", "")) for x in open_a]
    oldest = max([x for x in ages if x is not None], default=0)
    soon = []
    for x in open_b:
        d = x.get("default", "-")
        try:
            dd = (datetime.date.fromisoformat(d) - datetime.date.today()).days
            if dd <= 2:
                soon.append((x["id"], d, dd))
        except Exception:
            pass
    desk_items = parse_desk()
    ticks = desk_ticks()
    open_desk = [i for i in desk_items if i["id"] not in ticks]
    n_rec, n_followed = rec_stats()
    rate = f"{100 * n_followed // n_rec}%" if n_rec else "—"
    halt = "ON" if len(a) + len(b) > 10 else "off"
    # Each number is stated ONCE, where a reader would look for it (the one-home rule, v1.64).
    # This grid holds the ESTATE TOTALS the governance acts on — the routine decision-halt and
    # the tier-B default clock are computed from tier A + tier B — plus the state no other
    # surface reports (desk load, execution debt, follow-rate). The per-lane split of the SAME
    # open rows is stated once, in the lane strip below, and nowhere else; "defaults within
    # 48 h" is stated by the Closing-soon list itself. Every tile that stands for items is a
    # LINK to the page that actually renders them.
    stats = f"""
<div class="grid">
 <a class="stat" href="/decisions" title="Every open tier-A row, all lanes"><div class="n urgent">{len(open_a)}</div><div class="l">need your word (tier A)</div></a>
 <a class="stat" href="/decisions" title="Every open tier-B row, all lanes"><div class="n">{len(open_b)}</div><div class="l">tier B open · applies on its date</div></a>
 <div class="stat"><div class="n">{oldest}d</div><div class="l">oldest open tier-A</div></div>
 <a class="stat" href="/desk" title="Your desk, on its own page"><div class="n">{len(open_desk)}</div><div class="l">on your desk</div></a>
 <a class="stat" href="/activity" title="Every answer and what the estate did with it"><div class="n">{len(st['pending']) + len(st['queued'])}</div><div class="l">answered · awaiting supervisor execution</div></a>
 <a class="stat" href="/activity"><div class="n">{len(st['executed'])}</div><div class="l">answers executed</div></a>
 <div class="stat"><div class="n">{rate}</div><div class="l">recommendation follow-rate<br>({n_followed}/{n_rec})</div></div>
 <div class="stat"><div class="n">{halt}</div><div class="l">routine decision-halt</div></div>
</div>
<p class="stat-note"><b>Estate totals, and the state the estate acts on.</b> The decision-halt
trips on tier A + tier B over 10, and each tier-B row applies its recommendation on its own date,
so those two totals are governed numbers and are kept here. The same open rows split by lane are
below; the rows themselves are rendered only on the <a href="/decisions">decisions
board</a>.</p>"""
    urgent_rows = ""
    if soon:
        # The exception list states its own number; there is no separate "defaults within 48 h"
        # tile restating it (each number stated once).
        items = "".join(
            f'<li><b>{i}</b> defaults <b>{d}</b> ({"today" if dd <= 0 else f"in {dd}d"}) — <a href="/decisions#card-{i}">review</a></li>'
            for i, d, dd in soon)
        urgent_rows = (f'<div class="card"><b>Closing soon — {len(soon)} tier-B default'
                       f'{"" if len(soon) == 1 else "s"} within 48 h</b>'
                       f'<ul>{items}</ul></div>')
    rows = hub_portfolio(cards, st, executed_records())
    attention = [row for row in rows if row["status"] != "Current"]
    std_related = [(c["id"], c["what"]) for c in a + b
                   if c["id"] not in (set(st["executed"]) | set(st["pending"]) | set(st["queued"]))
                   and STANDARD_ROW_RE.search(f'{c["what"]} {c["next"]}')]
    supervisor_actions = render_supervisor_actions(parse_supervisor_actions())
    standard_card = render_standard_card(standard_info(), related=std_related)
    lane_strip = render_lane_strip(lane_counts(cards, st))
    agent_pointer = render_agent_pointer()
    watchlist = render_watchlist_pointer(c_)
    portfolio = render_hub_portfolio(
        attention,
        heading="Hubs needing attention",
        intro="Exceptions only: open decisions, proposals needing decision or routing, answered work awaiting Supervisor execution, stale hubs, or unavailable evidence.",
        show_all=True,
    )
    inner = (stats + lane_strip + urgent_rows
             + standard_card
             + supervisor_actions
             + agent_pointer
             + watchlist
             + portfolio
             )
    unpulled = []
    na = len(_decision_answers(ANSWERS))
    nd = len([r for r in read_jsonl(ANSWERS) if str(r.get("id", "")).startswith(DESK_PREFIX)])
    nq = len(read_jsonl(QUESTIONS))
    if na:
        unpulled.append(f"{na} answer{'s' if na != 1 else ''}")
    if nd:
        unpulled.append(f"{nd} desk tick{'s' if nd != 1 else ''}")
    if nq:
        unpulled.append(f"{nq} question{'s' if nq != 1 else ''}")
    unpulled_line = (f"<br><b>{', '.join(unpulled)} recorded, awaiting the next supervisor pull</b>"
                     if unpulled else "")
    return page("KM Cockpit", inner,
                sub=f"as of {time.strftime('%Y-%m-%d %H:%M')} · live from QUEUE.md · cards update themselves as the estate executes{unpulled_line}",
                active="home")


def hub_chips(keys):
    return "".join(
        f'<a class="hubchip" href="/decisions?hub={k}">{html.escape(HUBS[k][0])}</a>' for k in keys)


TIER_SECTIONS = {
    "a": "TIER A / OWNER AUTHORITY",
    "b": "TIER B / DEFAULT AUTHORITY",
    "c": "TIER C / INFORMATION",
}

TIER_DESCRIPTIONS = {
    "a": "Explicit choices that wait for the owner's word.",
    "b": "Recommended actions that apply unless the owner intervenes.",
    "c": "Information and reminders; no answer is required.",
}


def decision_authority_context():
    return """<h2>Decision authority</h2><dl class="authority-guide">
<dt><span class="badge tier-a">Tier A</span> Your authority</dt>
<dd>Explicit owner decision. Never defaults; it waits for your word.</dd>
<dt><span class="badge tier-b">Tier B</span> Default authority</dt>
<dd>The recommended action applies unless you veto or change it.</dd>
<dt><span class="badge tier-c">Tier C</span> Information</dt>
<dd>For awareness only. No answer is required.</dd></dl>
<h2>Lanes</h2><p class="lane-def">Tier is the clock. The lane is the context: what you need in
your head to answer. Pick one lane and stay in it.</p><dl class="authority-guide">""" + "".join(
        f"<dt>{html.escape(LANES[l][0])}</dt><dd>{html.escape(LANES[l][1])}</dd>"
        for l in LANE_ORDER) + """</dl>
<div class="source-note"><b>Reading order</b>Decide at a glance. Open rationale or the full record only when needed.</div>"""


def render_waiting_on_estate(rows=None):
    """Everything the estate owes, BY NAME, on the page where the owner looks for it (v1.64;
    a count that does not resolve to a visible item is a display defect). Hub proposals the
    owner has already answered wait on a hub's agent or the Supervisor, never on the owner —
    naming them here is what keeps "awaiting execution" from dead-ending."""
    rows = hub_portfolio() if rows is None else rows
    items = []
    for row in rows:
        for p in row.get("proposals", []):
            if p.get("state") in ("open", None):
                continue                      # that one waits on the owner, already on the board
            items.append({
                "who": row["name"],
                "what": Path(p["path"]).name.replace("_", " ").replace(".md", ""),
                "state": p.get("label", ""),
            })
    if not items:
        return ""
    feed = "".join(
        f'<div class="feeditem"><span class="feedid">{html.escape(i["who"])}</span> '
        f'<div class="activity-outcome"><b>{html.escape(i["what"])}</b><br>'
        f'<span class="sub">{html.escape(i["state"])}</span></div></div>'
        for i in items)
    return ('<section class="waiting-estate" id="waiting" aria-labelledby="waiting-heading">'
            f'<h2 id="waiting-heading">Waiting on the estate, not on you '
            f'<span class="sectioncount">{len(items)}</span></h2>'
            '<p class="section-description">You have already answered these. They are named here '
            'so "awaiting execution" always resolves to something you can see, and so you can '
            'tell what waits on a hub\'s agent from what waits on the Supervisor.</p>'
            f'<div class="feed">{feed}</div></section>')


def decisions(hub_filter=None, lane_filter=None):
    cards = parse_cards()
    st = state()
    dismissed = dismissals()
    desk_items = parse_desk()
    ticks = desk_ticks()
    open_desk = [i for i in desk_items if i["id"] not in ticks]
    lane_filter = lane_filter if lane_filter in LANES else None
    prefix = []
    # Grouped by LANE first (the context), tier sections inside each lane (the clock). v1.64.
    by_lane = {lane: {"a": [], "b": [], "c": []} for lane in LANE_ORDER}
    dismissed_c = {lane: [] for lane in LANE_ORDER}
    dismissed_preparing = []
    preparing = []
    if hub_filter and hub_filter in HUBS:
        prefix.append(f'<div class="sub" style="padding:0">Filtered to <b>{html.escape(HUBS[hub_filter][0])}</b> · <a href="{lane_href(lane_filter)}">show all hubs</a></div>')
    visible_cards = []
    for source_card in cards:
        c = dict(source_card)
        c["hubs"] = hubs_of(c["what"] + " " + c["next"])
        if hub_filter and hub_filter not in c["hubs"]:
            continue
        visible_cards.append(c)
    # Counts are taken BEFORE the lane filter, so the bar always shows the whole board. The desk
    # is not hub-attributed, so a hub-filtered view neither renders nor counts it: a "+N" the
    # view then refuses to show would be exactly the dead-end signal this surface forbids.
    counts = lane_counts(visible_cards, st)
    desk_shown = 0 if hub_filter else len(open_desk)
    prefix.append(render_lane_bar(counts, lane_filter, hub_filter))
    prefix.append(lane_scope_note(lane_filter, counts, desk_shown))
    for c in visible_cards:
        if lane_filter and lane_of(c.get("lane")) != lane_filter:
            continue
        lane = lane_of(c.get("lane"))
        tier = c["tier"]
        label, color, tip = TIER_META[c["tier"]]
        rid = c["id"]
        if tier == "c" and rid in dismissed:
            dismissed_c[lane].append(dismissed_entry(c, dismissed[rid].get("at", "")))
            continue
        if c.get("parse_error"):
            # Fail-closed surface for a row that failed to parse (a malformed Defaults cell, or
            # a machine-block row with no rendered table row). Never answerable — it is a
            # formatting defect to fix, not a decision to take, and it renders LOUD in its tier
            # section rather than sliding into the Preparing group (v1.64).
            by_lane[lane][tier].append(
                f'<article class="decision-row tier-{tier}" data-decision-row data-row="{rid}" '
                f'id="card-{rid}"><header class="decision-glance">'
                f'<div class="decision-identity"><span class="rid">{rid}</span>'
                f'<span class="badge" style="background:#b3261e" '
                f'title="{html.escape(c.get("parse_error_reason") or "Row failed to parse")}">'
                f'PARSE ERROR</span></div>'
                f'<div class="decision-title-block"><h3>{html.escape(decision_title(c))}</h3></div>'
                f'<div class="decision-actions"><span class="stateflag flag-warn">'
                f'{html.escape(c["what"])}</span></div></header></article>')
            continue
        ex = st["executed"].get(rid)
        # A recorded row (answer captured, work owed) is answered-awaiting-execution, never
        # answerable again: include it so it never renders answer controls while still on the
        # board (two states only, v1.64).
        answered = rid in st["pending"] or rid in st["queued"] or rid in st.get("recorded", [])
        # The row's own durable marker, for the flag's wording below: when the row states the
        # execution is owed, the card says what the row says rather than paraphrasing it.
        row_answer = c.get("answered_row") or c.get("answered_mb")
        # TWO STATES MUST NOT LOOK ALIKE (v1.64). The tier badge is the CLOCK — what happens if
        # the owner says nothing — and on an answered or executed row that clock has stopped.
        # The tier is kept in the tooltip; it is context now, not a call on the owner.
        badge_class = f"tier-{tier}"
        if ex:
            label, color, badge_tip = EXECUTED_META
            tip = f"{badge_tip} (registered tier {tier.upper()}: {TIER_META[tier][2]})"
            badge_class = "badge-executed"
        elif answered:
            label, color, badge_tip = ANSWERED_META
            tip = f"{badge_tip} (registered tier {tier.upper()}: {TIER_META[tier][2]})"
            badge_class = "badge-answered"
        opts = options_of(c)
        rec = opts[0] if opts else ""
        # Gates, in order (both route into "Preparing for you"; SPEC.md §4): the options gate
        # first — a row with no answerable option is not answerable whatever its brief says —
        # then the phase-2.5 decision-brief gate.
        brief, gate = None, None
        gate_badge = "Preparing"
        gate_flag = "Being prepared — nothing for you to do yet"
        gate_tip = f"Tier {tier.upper()} once ready — {tip}. Not ready for your word yet."
        if c["tier"] in ("a", "b"):
            ogate = options_gate(c, opts)
            if ogate:
                gate = ogate
                gate_badge = "Gated"
                gate_flag = "Options unreadable — repair the row's options cell (quoted form)"
                gate_tip = (f"Tier {tier.upper()} once repaired — {tip}. The row declares "
                            "options this surface cannot read, so it is not answerable yet.")
            else:
                bp, gate = brief_check(rid)
                if gate is None:
                    brief = str(bp)
        replies = "".join(
            f'<div class="qreply"><b>Supervisor:</b> {md_inline(r["reply"])} <span class="feedat">{r.get("at", "")}</span></div>'
            for r in st["replies"].get(rid, []))
        age = age_days(c.get("raised", ""))
        agetxt = f" · open {age}d" if age is not None and age > 0 else ""
        ask_supervisor = (f'<details class="decision-deep-section decision-question">'
                          f'<summary>Ask Supervisor</summary><div aria-label="Ask Supervisor">'
                          f'{replies}<div class="answer decision-ask">'
                          f'<input type="text" id="q-{rid}" placeholder="Ask the Supervisor about {rid}">'
                          f'<button class="small" onclick="ask(\'{rid}\')">Ask</button></div></div></details>')
        if gate and not ex and not answered:
            # A gated/incomplete record renders in the compact "Preparing for you" group —
            # visible and auditable, NO answer controls, the precise gate reason inside the
            # expanded details only, never in the glance. The Ask channel stays open. The
            # actionable tiers are never deformed by it. Gate notices are informational, so they
            # carry Dismiss (v1.64).
            if rid in dismissed:
                dismissed_preparing.append(dismissed_entry(c, dismissed[rid].get("at", "")))
                continue
            queue_what = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", c["what"])
            preparing.append(f"""<article class="decision-row preparing tier-{tier}" data-decision-row data-row="{rid}" data-dismissable="{rid}" id="card-{rid}">
<header class="decision-glance" data-level="preparing">
<div class="decision-identity"><span class="rid">{rid}</span>
<span class="badge" style="background:#5f6368" title="{html.escape(gate_tip)}">{html.escape(gate_badge)}</span></div>
<div class="decision-title-block"><h3>{html.escape(decision_title(c))}</h3>
<div class="decision-meta"><span class="decision-hubs">{hub_chips(c["hubs"])}</span>
<span class="when">{html.escape(c['when'])}{agetxt}</span></div></div>
<div class="decision-actions"><span class="preparing-flag">{html.escape(gate_flag)}</span>{dismiss_control(rid)}</div></header>
<details class="decision-detail"><summary>Details for audit</summary>
<div class="decision-detail-body">
<p class="decision-gate"><b>Returned to the Supervisor.</b> {html.escape(gate)}</p>
<div class="decision-deep-links">
<details class="decision-deep-section"><summary>Full queue context</summary>
<div class="queue-context">{md_inline(queue_what)}</div></details>{ask_supervisor}</div>
</div></details></article>""" + dismiss_strip(rid))
            continue
        quick_controls = ""
        custom_controls = ""
        flag = ""
        if ex:
            # The state has a name (proposal_lifecycle uses it too): execution recorded,
            # reconciliation pending. Saying it here is what tells the owner why a row they
            # have finished with is still on the board.
            flag = ('<span class="execflag">✓ Execution recorded — reconciliation pending</span>'
                    f' — {md_inline(ex.get("note", ""))}')
        elif answered:
            verb = short_verb(st["answers"].get(rid, ""))
            chip = verb if len(verb) <= 28 else verb[:28].rstrip() + "…"
            quoted = f" “{html.escape(chip)}”" if verb else ""
            # Truthful phrasings of the ONE answered state (two states only, v1.64): a
            # bookkeeping-recorded answer and an unconsumed answer await execution; a row the
            # queue itself marks answered says the execution is owed; a consumed answer is being
            # executed right now. None ever shows answer controls, and none ever reads
            # "executed".
            if rid in st.get("recorded", []):
                flag = f'<span class="doneflag">✓ Answered{quoted} — awaiting execution</span>'
            elif row_answer:
                flag = (f'<span class="doneflag">✓ Answered{quoted}, execution owed by the '
                        'Supervisor</span>')
            elif rid in st["queued"]:
                flag = f'<span class="doneflag">✓ Answered{quoted} — executing</span>'
            else:
                flag = (f'<span class="doneflag">✓{quoted} recorded — awaiting '
                        'execution</span>' if verb else
                        '<span class="doneflag">✓ answer recorded — awaiting execution</span>')
        elif c["tier"] != "c":
            quick_controls = "".join(
                f"""<button data-answer-control class="{'rec' if o == rec else ''}" onclick="send('{rid}', '{html.escape(o)}', '{html.escape(rec)}')">{html.escape(sentence_case(o))}</button>"""
                for o in opts)
            custom_controls = f"""<input type="text" data-answer-control id="in-{rid}" placeholder="Type another answer…">
<button data-answer-control onclick="send('{rid}', document.getElementById('in-{rid}').value, '{html.escape(rec)}')">Send</button>"""
        sections = decision_brief_sections(brief) if brief else {}
        lks = unique_decision_links(c, brief)
        briefhtml = (f'<a class="full-record-link" href="/view?p={urllib.parse.quote(brief)}">'
                     'Open full decision record <span aria-hidden="true">→</span></a>'
                     if brief else "")
        proposal_reviews = render_proposal_reviews(c)
        linkparts = []
        for nm, pth, is_md, fr in lks:
            if is_md:
                anchor = f"#{urllib.parse.quote(fr)}" if fr else ""
                linkparts.append(
                    f"""<a href="/view?p={urllib.parse.quote(pth)}{anchor}" onclick="viewfrag('{rid}', '{html.escape(pth)}'); return false">{html.escape(nm)}</a>""")
            else:
                linkparts.append(f'<a href="/open?p={urllib.parse.quote(pth)}">{html.escape(nm)} ↗</a>')
        linkhtml = "".join(linkparts)
        done_class = " done" if ex or answered else ""
        proposal_section = (f'<section class="decision-proposals" aria-label="Proposal review">'
                            f'{proposal_reviews}</section>' if proposal_reviews else "")
        snapshot = ""
        if sections:
            snapshot_items = []
            for title, number in (("What changes", 1), ("Recommendation", 4),
                                  ("Why this matters", 7), ("Scope", 8),
                                  ("Risk and reversibility", 10)):
                if sections.get(number):
                    snapshot_items.append(
                        f'<section class="snapshot-item"><h4>{title}</h4>'
                        f'{md_to_html(sections[number], BRIEFS)}</section>')
            snapshot = (f'<div class="decision-snapshot" data-level="understand-why">'
                        f'{"".join(snapshot_items)}</div>')
        sources = (f'<details class="decision-deep-section"><summary>View sources</summary>'
                   f'<div class="ctxlinks">{linkhtml}</div>'
                   f'<div class="frag" id="frag-{rid}" style="display:none"></div></details>'
                   if linkhtml else "")
        queue_what = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", c["what"])
        queue_next_text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", c["next"])
        queue_next = (f'<div class="next">{md_inline(queue_next_text)}</div>'
                      if queue_next_text else "")
        queue_context = (f'<details class="decision-deep-section"><summary>Full queue context</summary>'
                         f'<div class="queue-context">{md_inline(queue_what)}{queue_next}'
                         f'</div></details>')
        other_answer = (f'<details class="decision-deep-section"><summary>Give another answer</summary>'
                        f'<div class="answer decision-custom-answer">{custom_controls}</div></details>'
                        if custom_controls else "")
        if tier == "c":
            # Informational: the owner's only control is Dismiss. A tier-A/B card never gets
            # one — it leaves the board by being ANSWERED (v1.64).
            actions = f'<div class="decision-actions">{dismiss_control(rid)}</div>'
        else:
            recommendation = (f'<span class="recommended-answer">Recommended: '
                              f'<b>{html.escape(sentence_case(rec))}</b></span>' if rec else "")
            actions = (f'<div class="decision-actions" data-decision="{rid}" '
                       f'aria-label="Answer and state">{recommendation}'
                       f'<div class="decision-action-buttons">{quick_controls}</div>'
                       f'<span class="stateflag">{flag}</span></div>')
        dismiss_attr = f' data-dismissable="{rid}"' if tier == "c" else ""
        strip = dismiss_strip(rid) if tier == "c" else ""
        by_lane[lane][tier].append(f"""<article class="decision-row tier-{tier}{done_class}" data-decision-row data-row="{rid}"{dismiss_attr} id="card-{rid}">
<header class="decision-glance" data-level="decide-now">
<div class="decision-identity"><span class="rid">{rid}</span>
<span class="badge {badge_class}" data-badge style="background:{color}" title="{html.escape(tip)}">{html.escape(label)}</span></div>
<div class="decision-title-block"><h3>{html.escape(decision_title(c))}</h3>
<div class="decision-meta"><span class="decision-hubs">{hub_chips(c["hubs"])}</span>
<span class="when">{html.escape(c['when'])}{agetxt}</span></div></div>{actions}</header>
<details class="decision-detail"><summary>Need more detail?</summary>
<div class="decision-detail-body">{snapshot}{proposal_section}
<div class="decision-deep-links" data-level="full-record">{briefhtml}{sources}{queue_context}{ask_supervisor}{other_answer}</div>
</div></details></article>""" + strip)
    groups = ""
    for lane in LANE_ORDER:
        if lane_filter and lane != lane_filter:
            continue
        inner = ""
        for tier in ("a", "b", "c"):
            foot = render_dismissed_disclosure(dismissed_c[lane]) if tier == "c" else ""
            # A section every one of whose items is dismissed still renders, so its disclosure —
            # the way back — is never lost with the last visible card.
            if not by_lane[lane][tier] and not foot:
                continue
            sid = f"{lane}-tier-{tier}-title"
            inner += (
                f'<section class="ledger-section" data-tier="{tier}" aria-labelledby="{sid}">'
                f'<div class="section-label"><span id="{sid}">{TIER_SECTIONS[tier]}</span>'
                f'<span class="count">{len(by_lane[lane][tier]):02d}</span></div>'
                f'<p class="section-description">{TIER_DESCRIPTIONS[tier]}</p>'
                f'{"".join(by_lane[lane][tier])}{foot}</section>')
        # The desk is the same KIND of material as the hand rows, but it has ONE home and this
        # is not it: the hand lane carries a count-and-link pointer, never a second set of
        # Mark-done controls.
        if lane == "hand" and not hub_filter and open_desk:
            inner += ('<p class="pointer-note"><b>{n} item{s} on your desk</b> — your own '
                      'follow-ups, with Mark done, live on <a href="/desk">Your desk →</a></p>'
                      ).format(n=len(open_desk), s="" if len(open_desk) == 1 else "s")
        if not inner:
            continue
        name, desc = LANES[lane]
        groups += (
            f'<section class="lane-section" data-lane="{lane}" aria-labelledby="lane-{lane}-title">'
            f'<div class="lane-heading"><h2 id="lane-{lane}-title">{html.escape(name)}</h2>'
            f'<span class="lane-count">{counts.get(lane, 0):02d} open</span></div>'
            f'<p class="lane-def">{html.escape(desc)}</p>{inner}</section>')
    preparing_foot = render_dismissed_disclosure(dismissed_preparing)
    if preparing or preparing_foot:
        groups += (
            '<section class="ledger-section preparing-section" data-tier="preparing" '
            'aria-labelledby="tier-preparing-title">'
            '<div class="section-label"><span id="tier-preparing-title">PREPARING FOR YOU — '
            'SUPERVISOR CORRECTION REQUIRED</span>'
            f'<span class="count">{len(preparing):02d}</span></div>'
            '<p class="section-description">Visible for audit; not yet answerable. The Supervisor '
            'owes each a completed decision brief before it joins its tier.</p>'
            f'{"".join(preparing)}{preparing_foot}</section>')
    if groups:
        body = f'<div class="decision-ledger" data-view="decision-ledger">{groups}</div>'
    elif lane_filter:
        body = ('<div class="empty-state"><b>Nothing in the '
                f'{html.escape(LANES[lane_filter][0])} lane'
                + (" for this hub" if hub_filter else "") + '.</b> '
                f'<a href="{lane_href(None, hub_filter)}">Show all lanes</a>.</div>')
    else:
        body = ('<div class="empty-state"><b>No decisions in this view.</b> '
                'Choose another hub or show all decisions.</div>')
    sub = "Decide at a glance. Open more detail only when you need it."
    if lane_filter:
        sub = f"One lane at a time: {LANES[lane_filter][0].lower()}. " + sub
    return page("Decisions — KM Cockpit", "".join(prefix) + body + render_waiting_on_estate(),
                sub=sub, active="decisions", context=decision_authority_context())


def activity_outcome(value, limit=140):
    """Return a plain, single-line recognition phrase without changing source evidence."""
    plain = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", value or "")
    plain = re.sub(r"[*_`]+", "", plain)
    plain = re.sub(r"\s+", " ", plain).strip()
    sentence = re.match(r"^(.+?[.!?])(?:\s|$)", plain)
    outcome = sentence.group(1) if sentence else plain
    if len(outcome) <= limit:
        return outcome
    shortened = outcome[:limit].rsplit(" ", 1)[0].rstrip(".,;:")
    return (shortened or outcome[:limit].rstrip()) + "…"


def activity_timestamp(value):
    """Return compact display time plus an ISO datetime value when the timestamp is valid."""
    try:
        parsed = datetime.datetime.fromisoformat(value)
    except (TypeError, ValueError):
        return "—", ""
    return parsed.strftime("%H:%M"), parsed.isoformat()


def render_activity_entry(record, kind, hub_keys=None):
    hub_keys = hub_keys or []
    raw_at = record.get("at", "") or ""
    display_time, machine_time = activity_timestamp(raw_at)
    if machine_time:
        compact_time = (f'<time class="activity-time" datetime="{html.escape(machine_time)}">'
                        f'{html.escape(display_time)}</time>')
        full_time = (f'<time datetime="{html.escape(machine_time)}">'
                     f'{html.escape(raw_at)}</time>')
    else:
        compact_time = '<span class="activity-time">—</span>'
        full_time = '<span>Date unavailable</span>'

    if kind == "execution":
        source = record.get("note", "")
        # A ledger record with status "recorded" is a bookkeeping acknowledgement (an unattended
        # pickup captured the answer). Two states only (v1.64): it is ANSWERED — awaiting
        # execution, and must never render as executed.
        if record.get("status") == "recorded":
            state_class, state_label = "awaiting", "Answered — awaiting execution"
            outcome = activity_outcome(source) or "Answer acknowledged, work owed"
            full_record = ('<p>Bookkeeping acknowledgement: an unattended pickup captured the '
                           'owner’s answer, but the work is not yet executed.</p>'
                           + md_inline(source))
        else:
            state_class, state_label = "executed", "Executed"
            outcome = activity_outcome(source) or "Execution recorded"
            full_record = md_inline(source)
    else:
        source = record.get("answer", "")
        state_class, state_label = "awaiting", "Awaiting Supervisor"
        outcome = f'Answer “{source[:60]}” recorded'
        full_record = (f'<p>Answer “{html.escape(source)}” was recorded and is awaiting '
                       'KM Supervisor execution.</p>')

    hubs = hub_chips(hub_keys) if hub_keys else '<span class="activity-no-hub">No hub attribution</span>'
    return f"""<details class="activity-entry">
<summary class="activity-summary">
{compact_time}<span class="feedid">{html.escape(record["id"])}</span>
<span class="activity-hubs">{hubs}</span>
<span class="activity-state activity-state-{state_class}">{state_label}</span>
<span class="activity-outcome">{html.escape(outcome)}</span>
<span class="activity-disclosure"><span class="show-details">View details</span>
<span class="hide-details">Hide details</span></span>
</summary>
<div class="activity-detail"><span class="evidence-label">Full activity record</span>
<div class="activity-detail-body">{full_record}</div>
<dl class="activity-meta"><dt>Recorded</dt><dd>{full_time}</dd>
<dt>Hub attribution</dt><dd>{hubs}</dd></dl></div>
</details>"""


# ---------- unattended answer pickups (v1.64; SPEC.md §3) ----------
# `pull` writes one `consumed, processing` line per record to the pickup log BEFORE truncating
# the pending store (see pull_answers), so the log is the trace of the owner's own input being
# consumed while nobody was watching. This panel is the other half: the consumed answers must be
# VISIBLE, because the pull rotated them out of the store and the log is their only trace.
# Line format: `- <date> <id> — answered "<verbatim>" — <what happened to it>`


def unattended_pickups():
    """Parsed pickup-log lines, newest first. Read-only; a missing log is a state, not an
    error."""
    out = []
    if PICKUP_LOG is None or not PICKUP_LOG.exists():
        return out
    for line in PICKUP_LOG.read_text(encoding="utf-8", errors="replace").splitlines():
        m = re.match(r"^-\s*(\d{4}-\d{2}-\d{2})\s+(\S+)\s*[—-]\s*(.*)$", line.strip())
        if m:
            out.append({"at": m.group(1), "id": m.group(2), "what": m.group(3)})
    out.reverse()
    return out


def render_unattended(limit=25):
    picks = unattended_pickups()
    body = "".join(
        f'<div class="feeditem"><span class="feedid">{html.escape(p["id"])}</span> '
        f'<div class="activity-outcome"><span class="feedat">{html.escape(p["at"])}</span> '
        f'{md_inline(p["what"])}</div></div>'
        for p in picks[:limit]) or (
        '<div class="feeditem"><i>Nothing yet — every answer so far was picked up in a live '
        'session.</i></div>')
    return ('<section class="activity-unattended" id="unattended" '
            'aria-labelledby="activity-unattended-heading">'
            f'<h2 id="activity-unattended-heading">Picked up without you asking '
            f'<span class="sectioncount">{len(picks)}</span></h2>'
            '<p class="section-description">Answers the estate collected on its own, while no '
            'session was running. Bookkeeping only: nothing here wrote into a hub, dispatched '
            'an agent, or decided anything.</p>'
            f'<div class="feed">{body}</div></section>')


# ---------- agent activity (agent-reports/ beside the queue file, read-only; v1.64) ----------
# Different material from the answer feed: that feed is what the estate did with the OWNER'S
# decisions; this is what the estate's agents did on their own dispatches. Sourced from curated
# frontmatter in agent-reports/ (never from git-log parsing): git records what an agent CHANGED,
# and a refusal changes nothing, so the report file is the only record a refusal has. The
# directory is a convention a deployment's dispatch machinery fills; a deployment with none sees
# the section say so and nothing else — the CONTRACT ships here, the machinery that writes the
# reports stays the deployment's own.

AGENT_REPORT_CAP = 12  # entries rendered; the footer states what is not shown and where it is
# outcome -> (group, badge, what it means in the owner's words)
AGENT_OUTCOMES = {
    "refused": ("boundary", "Refused",
                "the agent declined work it was not authorised to do"),
    "stopped": ("boundary", "Stopped",
                "the agent halted because the work could not be done as directed"),
    "applied": ("routine", "Applied", "the work was carried out and committed"),
    "reported": ("routine", "Reported",
                 "the agent reported findings without changing anything"),
}
AGENT_ROW_RE = re.compile(r"^[abc]\d+$", re.I)
AGENT_FILE_DATE_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})")


def _frontmatter(raw):
    """Split a leading `---` frontmatter block into (mapping, body). A file with no block, or
    with an unterminated one, yields ({}, raw) — it is then REPORTED as unreadable, never
    guessed at."""
    if not raw.startswith("---\n"):
        return {}, raw
    end = raw.find("\n---", 4)
    if end == -1:
        return {}, raw
    fm = {}
    for line in raw[4:end].splitlines():
        if ":" in line and not line.startswith(("#", " ", "\t", "-")):
            key, value = line.split(":", 1)
            fm[key.strip()] = value.strip()
    return fm, raw[end + 4:]


def _fm_list(value):
    """Parse a flow-style frontmatter list (`[a, b]`, `a, b`, or empty) into a list."""
    v = (value or "").strip()
    if v.startswith("[") and v.endswith("]"):
        v = v[1:-1]
    return [item.strip().strip("'\"") for item in v.split(",") if item.strip().strip("'\"")]


def agent_hub_keys(values):
    """Map a report's `hubs:` values onto HUBS keys. An unrecognised value is kept VERBATIM as a
    plain label, never guessed into a hub; a report naming no hub reads as the attribution
    fallback, exactly like hubs_of(). Returns (keys, unmatched-labels)."""
    keys, unmatched = [], []
    for value in values:
        v = value.strip().lower()
        hit = next((k for k, (name, d, _kw) in HUBS.items()
                    if v in (k, d.lower(), name.lower())), None)
        if hit and hit not in keys:
            keys.append(hit)
        elif not hit and value.strip():
            unmatched.append(value.strip())
    if not keys and not unmatched:
        keys = [FALLBACK_KEY]
    return keys, unmatched


def agent_report_date(fm_value, filename):
    """Frontmatter timestamp first, the filename's date prefix second, "" when neither parses.
    Never invents a date from the file's mtime: an undated report displays as undated."""
    match = AGENT_FILE_DATE_RE.match(filename or "")
    for candidate in (str(fm_value or "").strip()[:10], match.group(1) if match else ""):
        try:
            return datetime.date.fromisoformat(candidate).isoformat()
        except ValueError:
            continue
    return ""


def parse_agent_reports(directory=None):
    """Read agent-reports/ frontmatter. READ-ONLY, and honest about what it cannot read: a file
    with no frontmatter, no agent, or an outcome outside the four governed values is listed as
    unreadable BY NAME rather than given a fabricated outcome or silently dropped. A missing
    directory is a state, not an error. Returns {state, path, reports, unreadable}."""
    directory = AGENT_REPORTS if directory is None else Path(directory)
    if directory is None or not directory.is_dir():
        return {"state": "missing", "path": str(directory or ""), "reports": [],
                "unreadable": []}
    reports, unreadable = [], []
    for p in sorted(directory.glob("*.md")):
        try:
            raw = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            unreadable.append({"file": p.name, "path": str(p),
                               "problem": "the file could not be read"})
            continue
        fm, body = _frontmatter(raw)
        if fm.get("type", "agent-report") != "agent-report":
            continue  # the directory's own README, and any other index file filed beside it
        outcome = fm.get("outcome", "").strip().lower()
        if not fm:
            problem = "no readable frontmatter"
        elif not fm.get("agent"):
            problem = "frontmatter names no agent"
        elif outcome not in AGENT_OUTCOMES:
            problem = (f"outcome '{outcome}' is not one of {', '.join(AGENT_OUTCOMES)}"
                       if outcome else "frontmatter states no outcome")
        else:
            problem = ""
        if problem:
            unreadable.append({"file": p.name, "path": str(p), "problem": problem})
            continue
        heading = re.search(r"^#\s+(.+)$", body, re.M)
        reports.append({
            "file": p.name,
            "path": str(p),
            "agent": fm.get("agent", ""),
            "dispatched_by": fm.get("dispatched-by", ""),
            "row": fm.get("row", "").strip(),
            "outcome": outcome,
            "group": AGENT_OUTCOMES[outcome][0],
            "commits": _fm_list(fm.get("commits")),
            "hubs": _fm_list(fm.get("hubs")),
            "date": agent_report_date(fm.get("timestamp"), p.name),
            "title": heading.group(1).strip() if heading else p.stem,
        })
    reports.sort(key=lambda r: (bool(r["date"]), r["date"], r["file"]), reverse=True)
    return {"state": "ok", "path": str(directory), "reports": reports, "unreadable": unreadable}


def _plural(n, word, suffix="s"):
    return f"{n} {word}{'' if n == 1 else suffix}"


def agent_reports_for(data, hub_filter=None):
    """The reports in scope for a view. A hub filter uses the report's own `hubs:` field."""
    reports = data["reports"]
    if hub_filter and hub_filter in HUBS:
        reports = [r for r in reports if hub_filter in agent_hub_keys(r["hubs"])[0]]
    return reports


def render_agent_entry(rep):
    """One report at a glance — agent, what it served, outcome, date — opening onto its own
    words. The report FILE is the evidence, so the link to it is the first thing in the body."""
    group, label, meaning = AGENT_OUTCOMES[rep["outcome"]]
    keys, unmatched = agent_hub_keys(rep["hubs"])
    chips = hub_chips(keys) + "".join(
        f'<span class="activity-no-hub">{html.escape(u)}</span>' for u in unmatched)
    if rep["date"]:
        when = (f'<time class="activity-time" datetime="{rep["date"]}">'
                f'{html.escape(rep["date"][5:])}</time>')
        filed = f'<time datetime="{rep["date"]}">{html.escape(rep["date"])}</time>'
    else:
        when = '<span class="activity-time">—</span>'
        filed = "date not stated in the report"
    row = (rep["row"] or "").strip()
    if AGENT_ROW_RE.match(row):
        # Stated, never linked: the row is usually closed by now, and a link to a board that no
        # longer renders it would dead-end.
        served = f"queue row {html.escape(row.lower())}"
    elif row.lower() in ("", "none", "n/a", "-"):
        served = "no queue row — dispatched work"
    else:
        served = html.escape(row)
    if rep["commits"]:
        commits = ", ".join(f'<code>{html.escape(c)}</code>' for c in rep["commits"])
    elif group == "boundary":
        commits = "none — nothing was changed, so this report is the only record"
    else:
        commits = "none recorded"
    link = f'/view?p={urllib.parse.quote(rep["path"])}'
    return f"""<details class="activity-entry agent-entry agent-entry-{group}"
data-agent-outcome="{rep["outcome"]}" data-agent-file="{html.escape(rep["file"])}">
<summary class="activity-summary">
{when}<span class="feedid">{html.escape(rep["agent"])}</span>
<span class="activity-hubs">{chips}</span>
<span class="activity-state agent-state-{rep["outcome"]}">{label}</span>
<span class="activity-outcome">{html.escape(rep["title"])}</span>
<span class="activity-disclosure"><span class="show-details">View details</span>
<span class="hide-details">Hide details</span></span>
</summary>
<div class="activity-detail">
<p class="agent-meaning">{label} — {meaning}.</p>
<p class="agent-read"><a href="{link}">Read the report in the agent's own words →</a></p>
<dl class="activity-meta"><dt>Agent</dt><dd>{html.escape(rep["agent"])}</dd>
<dt>Dispatched by</dt><dd>{html.escape(rep["dispatched_by"] or "not stated")}</dd>
<dt>Served</dt><dd>{served}</dd>
<dt>Hubs</dt><dd>{chips}</dd>
<dt>Commits</dt><dd>{commits}</dd>
<dt>Filed</dt><dd>{filed}</dd>
<dt>Report file</dt><dd><a href="{link}">{html.escape(rep["file"])}</a></dd></dl>
</div></details>"""


def render_agent_activity(data=None, hub_filter=None):
    """The Agent activity section — its ONE home is the Activity page; the Overview states it as
    a count with a link and never repeats an entry. Refusals and stops lead, in their own
    bordered group, and claim the cap before routine reports do: a view that shows twelve
    applies and hides one refusal has failed its only job."""
    data = parse_agent_reports() if data is None else data
    head = ('<section class="agent-activity" id="agents" aria-labelledby="agent-activity-heading">'
            '<h2 id="agent-activity-heading">Agent activity</h2>'
            '<p class="section-description">What the estate\'s agents did on their own '
            'dispatches: what they checked, judged, and refused. Git records what an agent '
            'changed; a refusal changes nothing, so its report file is the only record it has. '
            'Nothing in this section is waiting on you — your own decisions are below.</p>')
    if data["state"] == "missing":
        return head + ('<p class="pointer-note agent-none"><b>No agent-reports directory</b> — '
                       'nothing is filed beside the queue file, so there is nothing to show. '
                       'This section reports only what a deployment\'s dispatch machinery files '
                       'there.</p></section>')
    reports = agent_reports_for(data, hub_filter)
    boundary = [r for r in reports if r["group"] == "boundary"]
    routine = [r for r in reports if r["group"] == "routine"]
    shown_b = boundary[:AGENT_REPORT_CAP]
    shown_r = routine[:max(0, AGENT_REPORT_CAP - len(shown_b))]
    blocks = []
    if shown_b:
        nouns = {"refused": "refusal", "stopped": "stop"}
        counts = ", ".join(
            _plural(len([r for r in shown_b if r["outcome"] == o]), noun)
            for o, noun in nouns.items()
            if any(r["outcome"] == o for r in shown_b))
        blocks.append(
            '<div class="agent-group agent-group-boundary">'
            f'<h3>Boundaries held — {counts}</h3>'
            '<p class="agent-group-note">An agent declining or halting work it was not '
            'authorised to do, or could not do as directed. These are the estate\'s rules '
            'holding, including against the Supervisor. None of them produced a commit.</p>'
            + "".join(render_agent_entry(r) for r in shown_b) + '</div>')
    elif reports:
        blocks.append('<p class="pointer-note agent-none">No refusal or stop among the '
                      f'{_plural(len(reports), "report")} in view.</p>')
    if shown_r:
        blocks.append(
            '<div class="agent-group">'
            f'<h3>Applied and reported — {len(shown_r)}</h3>'
            + "".join(render_agent_entry(r) for r in shown_r) + '</div>')
    if not reports:
        scope = (f' attributed to {html.escape(HUBS[hub_filter][0])}'
                 if hub_filter and hub_filter in HUBS else "")
        blocks.append('<p class="pointer-note agent-none">No agent report'
                      f'{scope} has been filed yet.</p>')
    hidden = len(reports) - len(shown_b) - len(shown_r)
    note = (f'Showing {len(shown_b) + len(shown_r)} of '
            f'{_plural(len(reports), "filed report")}, newest first'
            + (f'; {_plural(hidden, "older report")} not shown here' if hidden else "")
            + (f'. Filtered to {html.escape(HUBS[hub_filter][0])}'
               if hub_filter and hub_filter in HUBS else "")
            + '. Every report lives in <code>agent-reports/</code> beside the queue file — '
            f'<a href="/open?p={urllib.parse.quote(data["path"])}">open the folder</a>.')
    blocks.append(f'<p class="agent-note">{note}</p>')
    if data["unreadable"]:
        items = "".join(
            f'<li><a href="/view?p={urllib.parse.quote(u["path"])}">{html.escape(u["file"])}</a>'
            f' — {html.escape(u["problem"])}</li>' for u in data["unreadable"])
        blocks.append(
            '<p class="pointer-note agent-unreadable"><b>'
            f'{_plural(len(data["unreadable"]), "file")} in agent-reports could not be read as a '
            'report</b> — named here rather than counted into anything or guessed at:'
            f'<ul>{items}</ul></p>')
    return head + "".join(blocks) + "</section>"


def render_agent_pointer(data=None):
    """The Agent activity section's ONLY appearance outside the Activity page: a count and a
    link, never an entry (the one-home rule)."""
    data = parse_agent_reports() if data is None else data
    reports, bad = data["reports"], data["unreadable"]
    if data["state"] == "missing" or not (reports or bad):
        return ""
    boundary = [r for r in reports if r["group"] == "boundary"]
    lead = (f'<b>{_plural(len(reports), "agent report")}, '
            + (f'{len(boundary)} refused or stopped</b>' if boundary
               else "none refused or stopped</b>"))
    tail = (f' {_plural(len(bad), "file")} there could not be read as a report.' if bad else "")
    return f"""<section class="agent-pointer" aria-labelledby="agent-pointer-heading">
<h2 id="agent-pointer-heading">Agent activity</h2>
<p class="pointer-note">{lead} — what the estate's agents checked, judged and refused on their
own dispatches. Nothing here needs you. Each one, in the agent's own words, is on the
<a href="/activity#agents">Activity page →</a>.{tail}</p></section>"""


def activity_subnav(counts):
    items = "".join(
        f'<a href="#{anchor}">{label} <span class="sectioncount">{n}</span></a>'
        for anchor, label, n in counts)
    return f'<nav class="activity-subnav" aria-label="Activity sections">{items}</nav>'


def activity(hub_filter=None, show_all=False):
    ex = read_jsonl(EXECUTIONS)
    pend = read_jsonl(ANSWERS) + read_jsonl(PROCESSED)
    done_ids = {record["id"] for record in ex}
    prefix = ""
    entries = []
    if hub_filter and hub_filter in HUBS:
        prefix = (f'<div class="sub" style="padding:0 0 8px">Filtered to '
                  f'<b>{html.escape(HUBS[hub_filter][0])}</b> · '
                  f'<a href="/activity">show all</a></div>')
    for record in ex:
        if str(record.get("id", "")).startswith(DESK_PREFIX):
            continue  # desk ids surface on the desk alone (dev-0013)
        hks = hubs_of(record.get("note", ""))
        if hub_filter and hub_filter not in hks:
            continue
        entries.append({
            "at": record.get("at", "") or "",
            "html": render_activity_entry(record, "execution", hks),
        })
    card_hubs = {
        card["id"]: hubs_of(card["what"] + " " + card["next"])
        for card in parse_cards()
    }
    for record in pend:
        if record["id"] in done_ids or str(record.get("id", "")).startswith(DESK_PREFIX):
            continue
        answer_hubs = card_hubs.get(record["id"], [])
        if hub_filter and hub_filter not in answer_hubs:
            continue
        entries.append({
            "at": record.get("at", "") or "",
            "html": render_activity_entry(record, "answer", answer_hubs),
        })
    for entry in entries:
        try:
            entry["date"] = datetime.date.fromisoformat(entry["at"][:10]).isoformat()
        except (TypeError, ValueError):
            entry["date"] = ""
    entries.sort(
        key=lambda entry: (bool(entry["date"]), entry["date"], entry["at"]),
        reverse=True,
    )
    groups = {}
    for entry in entries:
        groups.setdefault(entry["date"], []).append(entry["html"])
    sections = []
    for date_value, rows in groups.items():
        if date_value:
            day = datetime.date.fromisoformat(date_value)
            label = f"{day.day} {day.strftime('%B %Y')}"
            heading = f'<time datetime="{date_value}">{label}</time>'
            heading_id = f"activity-date-{date_value}"
        else:
            heading = "Date unavailable"
            heading_id = "activity-date-unavailable"
        sections.append(
            f'<section class="activity-day" aria-labelledby="{heading_id}" '
            f'data-activity-date="{date_value or "unavailable"}">'
            f'<h2 class="activity-date" id="{heading_id}">{heading}</h2>'
            f'<div class="feed">{"".join(rows)}</div></section>'
        )
    # CAP: an unbounded feed buries the entries that matter. Show the most recent days; the rest
    # stay one click away rather than scrolled past.
    DAYS = 7
    hidden = max(0, len(sections) - DAYS)
    if hidden and not show_all:
        more = (f'<p class="section-description"><a href="/activity?all=1">Show '
                f'{hidden} earlier day(s)</a></p>')
        sections = sections[:DAYS]
    else:
        more = ""
    grouped = (f'<div class="activity-days">{"".join(sections)}</div>{more}'
               if sections else '<div class="feed">Nothing yet.</div>')
    # SPLIT BY ACTOR (v1.64): what YOU decided, what an AGENT did on a dispatch, and what ran
    # UNATTENDED. One feed mixing all three hides the entries that matter — a refusal, or an
    # answer consumed while nobody watched. Refusals render above routine applies, never
    # interleaved.
    decisions_feed = (
        '<section class="activity-decisions" id="decisions" '
        'aria-labelledby="activity-decisions-heading">'
        f'<h2 id="activity-decisions-heading">Your decisions '
        f'<span class="sectioncount">{len(entries)}</span></h2>'
        '<p class="section-description">Every answer you gave, and what the estate did with '
        'it.</p>' + grouped + '</section>')
    _ar = parse_agent_reports()
    agents_html = render_agent_activity(_ar, hub_filter=hub_filter)
    unattended_html = render_unattended()
    nav = activity_subnav([
        ("decisions", "Your decisions", len(entries)),
        # parse_agent_reports() returns a DICT, so len() on it would count keys, not reports.
        # Count the reports, and count an unreadable file too: a report the parser cannot read
        # still happened.
        ("agents", "Agents", len(_ar.get("reports", [])) + len(_ar.get("unreadable", []))),
        ("unattended", "Unattended", len(unattended_pickups())),
    ])
    return page("Activity — KM Cockpit",
                prefix + nav + decisions_feed + agents_html + unattended_html,
                sub="split by who acted: your decisions, the agents' own dispatches, and what "
                    "the estate picked up unattended — newest first",
                active="activity")


_hubinfo_cache = {"at": 0, "data": {}}


def hub_live_info(dirname):
    """Pending proposals + last commit, cached 60s (11 git calls otherwise)."""
    now = time.time()
    if now - _hubinfo_cache["at"] > 60:
        _hubinfo_cache["data"] = {}
        _hubinfo_cache["at"] = now
    if dirname in _hubinfo_cache["data"]:
        return _hubinfo_cache["data"][dirname]
    d = ROOT / dirname
    proposal_paths = sorted((d / "changes").glob("*_proposal.md")) if (d / "changes").exists() else []
    try:
        last = subprocess.run(["git", "-C", str(d), "log", "-1", "--date=short", "--format=%ad %s"],
                              capture_output=True, text=True, timeout=10).stdout.strip()
    except Exception:
        last = "?"
    info = {"pending": len(proposal_paths), "proposals": [proposal_record(p) for p in proposal_paths],
            "last": last[:110]}
    _hubinfo_cache["data"][dirname] = info
    return info


PROFILE_PLACEHOLDERS = (
    "content to be populated",
    "to be added",
    "not recorded",
    "what the initiative is, why it exists, current status, and scope",
)


def meaningful_profile_text(value):
    plain = re.sub(r"[*_>`]", "", value or "").strip()
    return "" if not plain or any(p in plain.lower() for p in PROFILE_PLACEHOLDERS) else plain


def first_section_paragraph(body, heading):
    match = re.search(
        rf"^##\s+{re.escape(heading)}\s*$\n(.*?)(?=^##\s|\Z)",
        body,
        re.I | re.M | re.S,
    )
    if not match:
        return ""
    for paragraph in re.split(r"\n\s*\n", match.group(1).strip()):
        lines = [line.strip() for line in paragraph.splitlines()
                 if line.strip() and not line.lstrip().startswith(("|", "---"))]
        value = meaningful_profile_text(" ".join(lines))
        if value:
            return value
    return ""


def hub_profile(dirname):
    path = ROOT / dirname / "01_project-brief.md"
    empty = {
        "path": str(path),
        "title": "",
        "timestamp": "",
        "purpose": "",
        "current": "",
        "why": "",
        "scope": "",
    }
    try:
        raw = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return empty
    frontmatter, body = {}, raw
    if raw.startswith("---\n"):
        end = raw.find("\n---", 4)
        if end != -1:
            for line in raw[4:end].splitlines():
                if ":" in line:
                    key, value = line.split(":", 1)
                    frontmatter[key.strip()] = value.strip()
            body = raw[end + 4:]
    purpose = first_section_paragraph(body, "What this initiative is")
    if not purpose:
        purpose = meaningful_profile_text(frontmatter.get("description", ""))
    return {
        **empty,
        "title": frontmatter.get("title", ""),
        "timestamp": frontmatter.get("timestamp", ""),
        "purpose": purpose,
        "current": first_section_paragraph(body, "Current status"),
        "why": first_section_paragraph(body, "Why it exists"),
        "scope": first_section_paragraph(body, "Scope"),
    }


def initiated_hubs():
    """Hub directories with full governance, derived at load_hubs() time: registry status `hub`
    in multi-hub mode; a recorded initiation interview in single-hub mode."""
    return INITIATED


def last_update_parts(value):
    match = re.match(r"^(\d{4}-\d{2}-\d{2})(?:\s+(.*))?$", value or "")
    if not match:
        return None, ""
    try:
        return datetime.date.fromisoformat(match.group(1)), (match.group(2) or "")
    except ValueError:
        return None, ""


def hub_portfolio(cards=None, st=None, executions=None):
    """Build the read-only supervisor portfolio from existing estate evidence."""
    cards = parse_cards() if cards is None else cards
    st = state() if st is None else st
    executions = executed_records() if executions is None else executions
    initiated = initiated_hubs()
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    priority = {"Needs decision": 0, "Pending changes": 1, "Awaiting execution": 2,
                "Stale": 3, "Unavailable": 4, "Current": 5}
    decision_by_proposal = proposal_decisions(cards)
    rows = []
    for configured_order, (key, (name, dirname, _keywords)) in enumerate(HUBS.items()):
        if key == GOV_KEY:
            continue
        linked = [card for card in cards
                  if card["tier"] in ("a", "b")
                  and card["id"] not in resolved
                  and key in hubs_of(card["what"] + " " + card["next"])]
        info = hub_live_info(dirname)
        proposals = []
        for source_proposal in info.get("proposals", []):
            proposal = dict(source_proposal)
            proposal["decision_id"] = decision_by_proposal.get(
                str(Path(proposal["path"]).resolve()))
            proposal["state"], proposal["label"] = proposal_lifecycle(
                proposal["decision_id"], st)
            # A proposal file is DELETED when the hub's agent applies it, so a proposal STILL
            # PRESENT here has NOT been applied, whatever the row's execution note says. The
            # exec note is a CLAIM; the file's presence is the FACT, and the fact wins (v1.64).
            if proposal["state"] == "executed":
                proposal["state"] = "awaiting-hub"
                proposal["label"] = ("Directive issued — waiting on this hub's own agent to "
                                     f"apply it ({proposal['decision_id']})")
            proposals.append(proposal)
        awaiting_exec = sum(1 for p in proposals
                            if p["state"] in ("answered", "queued", "executed", "awaiting-hub"))
        owner_pending = len(proposals) - awaiting_exec
        prop_states = {p["state"] for p in proposals}
        last_date, last_subject = last_update_parts(info.get("last", ""))
        # The attention badge derives from the same lifecycle states as the proposal list
        # (ruling 2026-08-17): a hub whose only pending work is answered-awaiting-execution
        # says so, never a generic "pending changes" contradiction.
        if linked or "open" in prop_states:
            status = "Needs decision"
        elif "unrouted" in prop_states:
            status = "Pending changes"
        elif proposals:
            status = "Awaiting execution"
        elif last_date is None:
            status = "Unavailable"
        elif (datetime.date.today() - last_date).days > 30:
            status = "Stale"
        else:
            status = "Current"
        recent = next((record for record in sorted(
            executions, key=lambda record: record.get("at", ""), reverse=True)
            if key in hubs_of(record.get("note", ""))), None)
        rows.append({
            "key": key,
            "name": name,
            "dirname": dirname,
            "status": status,
            "lifecycle": "Active" if dirname in initiated else "Not initiated",
            "last_date": last_date.isoformat() if last_date else "",
            "last_subject": last_subject,
            "linked": len(linked),
            "pending": info.get("pending", 0),
            "owner_pending": owner_pending,
            "awaiting_exec": awaiting_exec,
            "proposals": proposals,
            "recent": recent,
            "profile": hub_profile(dirname),
            "configured_order": configured_order,
        })
    return sorted(rows, key=lambda row: (priority[row["status"]], row["configured_order"]))


def render_proposal_list(proposals):
    """Every pending proposal, by name, with its ruled lifecycle state. While the governing row
    is still open (open / answered) the item leads to the decision card — unfiltered, so the
    click always lands — with the exact proposal record one step behind; once the row has left
    the queue (queued / executed) or no decision governs it, the proposal record IS the item."""
    if not proposals:
        return ""
    items = []
    for proposal in proposals:
        decision_id = proposal.get("decision_id")
        pstate = proposal.get("state", "open" if decision_id else "unrouted")
        label = proposal.get("label") or (
            f"Awaiting owner decision {decision_id}" if decision_id else "Needs decision routing")
        record_href = f'/view?p={urllib.parse.quote(proposal["path"])}'
        if pstate in ("open", "answered"):
            href = f'/decisions#card-{decision_id}'
            secondary = f' · <a href="{record_href}">proposal record</a>'
        else:
            href = record_href
            secondary = ""
        date = f' · {html.escape(proposal.get("date", ""))}' if proposal.get("date") else ""
        items.append(
            f'<div class="proposal-item" data-proposal-state="{pstate}">'
            f'<a href="{href}">{html.escape(proposal["title"])}</a>'
            f'<span class="proposal-state">{html.escape(label)}{date}{secondary}</span></div>')
    return (f'<div class="proposal-list"><span class="evidence-label">Pending proposals</span>'
            f'{"".join(items)}</div>')


def short_profile_text(value, limit=180):
    if len(value) <= limit:
        return value
    shortened = value[:limit].rsplit(" ", 1)[0].rstrip(".,;:")
    return shortened + "…"


def render_hub_directory(rows, cards, st, executions):
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    parts = []
    for row in rows:
        key = row["key"]
        open_rows = [card for card in cards
                     if card["tier"] in ("a", "b")
                     and card["id"] not in resolved
                     and key in hubs_of(card["what"] + " " + card["next"])]
        recent = [record for record in sorted(
            executions, key=lambda item: item.get("at", ""), reverse=True)
            if key in hubs_of(record.get("note", ""))][:4]
        open_html = "".join(
            f'<li><a href="/decisions#card-{card["id"]}"><b>{card["id"]}</b></a> '
            f'{md_inline(card["what"][:150])}{"…" if len(card["what"]) > 150 else ""}</li>'
            for card in open_rows) or "<li class='muted-item'>Nothing waiting on you</li>"
        recent_html = "".join(
            f'<li><b>{record["id"]}</b> {md_inline(record.get("note", "")[:170])}'
            f'{"…" if len(record.get("note", "")) > 170 else ""} '
            f'<span class="feedat">{html.escape(record.get("at", "")[:10])}</span></li>'
            for record in recent) or "<li class='muted-item'>No recent executions</li>"
        status_class = re.sub(r"[^a-z]+", "-", row["status"].lower()).strip("-")
        if row["last_date"]:
            update = (f'<time datetime="{row["last_date"]}">{row["last_date"]}</time>'
                      f'<span>{html.escape(row["last_subject"] or "Commit recorded")}</span>')
        else:
            update = '<b>No Git update available</b><span>Repository history could not be read</span>'
        profile = row["profile"]
        purpose = (md_inline(short_profile_text(profile["purpose"])) if profile["purpose"]
                   else '<span class="muted-item">Purpose not recorded</span>')
        current = (md_inline(short_profile_text(profile["current"])) if profile["current"]
                   else '<span class="muted-item">Current situation not recorded</span>')
        preview = (f'<span class="hub-profile-preview"><span><b>Purpose</b>{purpose}</span>'
                   f'<span><b>Now</b>{current}</span></span>')
        parts.append(f"""<details class="hub-detail" data-status="{status_class}">
<summary><span class="hub-directory-name"><span class="hubdir">{html.escape(row['dirname'])}</span>
<strong>{html.escape(row['name'])}</strong></span>
<span class="hub-directory-status"><span class="status status-{status_class}">{html.escape(row['status'])}</span>
<span class="lifecycle">{html.escape(row['lifecycle'])}</span></span>
<span class="hub-directory-update"><span class="evidence-label">Last update</span>{update}</span>
<span class="hub-directory-signals"><b>{row['linked']}</b> linked A/B <b>{row['owner_pending']}</b> proposals <b>{row['awaiting_exec']}</b> awaiting execution</span>
{preview}</summary>
<div class="hub-detail-body"><div><h3>Open linked decisions</h3><ul>{open_html}</ul></div>
<div><h3>Recent executions</h3><ul>{recent_html}</ul></div>
{render_proposal_list(row.get('proposals', []))}</div>
<footer class="hub-detail-links"><a href="/hubs/{key}">Open hub profile →</a>
<a href="/decisions?hub={key}">Decisions →</a>
<a href="/activity?hub={key}">Activity →</a></footer></details>""")
    return f'<div class="hub-directory" data-view="hub-directory">{"".join(parts)}</div>'


def hubs_page():
    cards = parse_cards()
    st = state()
    executions = executed_records()
    rows = hub_portfolio(cards, st, executions)
    return page("Hubs — KM Cockpit", render_hub_directory(rows, cards, st, executions),
                sub="the complete hub directory — status at a glance, evidence and recent history on expansion",
                active="hubs")


def hub_profile_page(key):
    if key not in HUBS or key == GOV_KEY:
        return None
    cards = parse_cards()
    st = state()
    executions = executed_records()
    row = next((record for record in hub_portfolio(cards, st, executions)
                if record["key"] == key), None)
    if not row:
        return None
    profile = row["profile"]
    resolved = set(st["executed"]) | set(st["pending"]) | set(st["queued"])
    open_cards = [card for card in cards
                  if card["tier"] in ("a", "b")
                  and card["id"] not in resolved
                  and key in hubs_of(card["what"] + " " + card["next"])]
    open_html = "".join(
        f'<li><a href="/decisions?hub={key}#card-{card["id"]}"><b>{card["id"]}</b></a> '
        f'{md_inline(card["what"])}</li>' for card in open_cards
    ) or '<li class="muted-item">Nothing waiting on you</li>'
    recent = row.get("recent")
    recent_html = (f'<p><b>{html.escape(recent["id"])}</b> '
                   f'{md_inline(recent.get("note", ""))}</p>') if recent else (
                   '<p class="muted-item">No recent execution</p>')

    def profile_value(value, missing):
        return md_inline(value) if value else f'<span class="muted-item">{missing}</span>'

    source = Path(profile["path"])
    source_html = (
        f'<a href="/view?p={urllib.parse.quote(str(source))}">'
        f'Open {html.escape(row["name"])} project brief →</a>'
        if source.exists() else '<span class="muted-item">Project brief not available</span>'
    )
    status_class = re.sub(r"[^a-z]+", "-", row["status"].lower()).strip("-")
    body = f'''<article class="hub-profile">
<header class="hub-profile-glance"><span class="hubdir">{html.escape(row["dirname"])}</span>
<h2>{html.escape(row["name"])}</h2>
<div><span class="status status-{status_class}">{html.escape(row["status"])}</span>
<span class="lifecycle">{html.escape(row["lifecycle"])}</span></div>
<section><h3>Purpose</h3><p>{profile_value(profile["purpose"], "Purpose not recorded")}</p></section>
<section><h3>Current situation</h3><p>{profile_value(profile["current"], "Current situation not recorded")}</p></section>
<p class="profile-source">Recorded {html.escape(profile["timestamp"] or "date unavailable")} · {source_html}</p></header>
<section class="hub-profile-section"><h2>What this hub covers</h2>
<h3>Why it exists</h3><p>{profile_value(profile["why"], "Why this hub exists is not recorded")}</p>
<h3>Scope</h3><p>{profile_value(profile["scope"], "Scope not recorded")}</p></section>
<section class="hub-profile-section"><h2>What needs supervision</h2>
<div class="hub-profile-facts"><section><h3>Open linked decisions</h3><ul>{open_html}</ul></section>
<section><h3>Most recent execution</h3>{recent_html}</section></div>
{render_proposal_list(row.get("proposals", []))}
<nav class="hub-profile-actions" aria-label="{html.escape(row["name"])} profile actions">
<a href="/decisions?hub={key}">Decisions →</a>
<a href="/activity?hub={key}">Activity →</a></nav>
</section></article>'''
    context = (f'<h2>Profile evidence</h2><p>Hub meaning comes from the governed project brief. '
               f'Operational state comes from live cockpit evidence.</p>{source_html}')
    return page(f'{row["name"]} — Hub profile', body,
                sub="purpose, current situation and supervisory evidence",
                active="hubs", context=context)


def md_to_html(text, base=None):
    fm = ""
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            fm = text[4:end]
            text = text[end + 4:]
    out, in_code, in_table, in_list = [], False, False, False
    if fm:
        title = next((l.split(":", 1)[1].strip() for l in fm.splitlines() if l.startswith("title:")), "")
        out.append(f'<div class="meta">{html.escape(title)}</div>')
    for line in text.splitlines():
        if line.startswith("```"):
            out.append("</pre>" if in_code else "<pre>")
            in_code = not in_code
            continue
        if in_code:
            out.append(html.escape(line))
            continue
        if line.startswith("|"):
            raw_cells = [x.strip() for x in line.strip("|").split("|")]
            if all(re.match(r"^:?-{2,}:?$", c) for c in raw_cells):
                continue
            if not in_table:
                out.append("<table>")
                in_table = True
            out.append("<tr>" + "".join(f"<td>{md_inline(c, base)}</td>" for c in raw_cells) + "</tr>")
            continue
        elif in_table:
            out.append("</table>")
            in_table = False
        if re.match(r"^\s*[-*] ", line):
            if not in_list:
                out.append("<ul>")
                in_list = True
            item = re.sub(r"^\s*[-*] ", "", line)
            out.append(f"<li>{md_inline(item, base)}</li>")
            continue
        elif in_list and line.strip() == "":
            out.append("</ul>")
            in_list = False
        m = re.match(r"^(#{1,4})\s+(.*)$", line)
        if m:
            n = len(m.group(1))
            # Stable heading anchors so #fragment links land (safe pass-through, ruled 2026-08-17).
            plain = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", m.group(2))
            anchor = re.sub(r"[^a-z0-9]+", "-", re.sub(r"[*_`]", "", plain).lower()).strip("-")
            aid = f' id="{anchor}"' if anchor else ""
            out.append(f"<h{n}{aid}>{md_inline(m.group(2), base)}</h{n}>")
        elif line.startswith(">"):
            out.append(f"<blockquote>{md_inline(line.lstrip('> '), base)}</blockquote>")
        elif line.strip() == "":
            out.append("<br>")
        else:
            out.append(f"<p>{md_inline(line, base)}</p>")
    if in_table:
        out.append("</table>")
    if in_list:
        out.append("</ul>")
    return "".join(out)


def view(pth):
    """Returns (http-status, html). Root confinement stays exactly as is; a genuinely missing
    target is a real 404 (ruled 2026-08-17), both with the safe in-app message."""
    p = Path(pth).resolve()
    if not str(p).startswith(str(ROOT)):
        return 403, page("Not available", '<div class="card">Outside the estate root.</div>')
    if not p.exists():
        return 404, page("Not found", '<div class="card">This document is missing from the '
                         'estate — it may have moved or been archived.</div>')
    rel = p.relative_to(ROOT)
    body = f"""<div class="doc"><div class="meta">{html.escape(str(rel))} ·
<a href="/open?p={urllib.parse.quote(str(p))}">open locally</a></div>
{md_to_html(p.read_text(encoding='utf-8', errors='replace'), base=p.parent)}</div>"""
    return 200, page(p.name, body)


# ---------- notifications (phase 1) ----------

def notify_loop():
    while True:
        try:
            seen = json.loads(NOTIFIED.read_text()) if NOTIFIED.exists() else {"a": [], "due": []}
            seen.setdefault("ack", [])
            st = state()
            cards = parse_cards()
            msgs = []
            for c in cards:
                if c["tier"] == "a" and c["id"] not in seen["a"] and c["id"] not in st["executed"]:
                    msgs.append(f"New decision needs you: {c['id']}")
                    seen["a"].append(c["id"])
                if c["tier"] == "b":
                    try:
                        dd = (datetime.date.fromisoformat(c.get("default", "-")) - datetime.date.today()).days
                        key = f"{c['id']}@{c.get('default')}"
                        if dd <= 1 and key not in seen["due"]:
                            msgs.append(f"{c['id']} auto-applies {'today' if dd <= 0 else 'tomorrow'}")
                            seen["due"].append(key)
                    except Exception:
                        pass
            # Acknowledge owner submissions the moment they land (mid-session answers went
            # unacknowledged twice on 2026-08-16). Keyed by id+at so a record leaving the
            # file at pull time (rotation) never errors and never renotifies.
            for r in read_jsonl(ANSWERS):
                key = f"ans:{r.get('id')}@{r.get('at')}"
                if key not in seen["ack"]:
                    msgs.append(f"Answer on {r.get('id')} recorded — executes at the next supervisor pull")
                    seen["ack"].append(key)
            for r in read_jsonl(QUESTIONS):
                key = f"q:{r.get('id')}@{r.get('at')}"
                if key not in seen["ack"]:
                    msgs.append(f"Question on {r.get('id')} recorded — answered at the next pull")
                    seen["ack"].append(key)
            for m in msgs:
                subprocess.Popen(["osascript", "-e",
                                  f'display notification "{m}" with title "KM Cockpit" sound name "default"'])
            CFG.mkdir(parents=True, exist_ok=True)
            NOTIFIED.write_text(json.dumps(seen))
        except Exception:
            pass
        time.sleep(60)


# ---------- server ----------

class H(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _send(self, code, body, ctype="text/html; charset=utf-8"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.end_headers()
        self.wfile.write(body.encode())

    def do_GET(self):
        u = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(u.query)
        if u.path == "/":
            self._send(200, home())
        elif u.path == "/decisions":
            self._send(200, decisions(q.get("hub", [None])[0], q.get("lane", [None])[0]))
        elif u.path == "/activity":
            self._send(200, activity(q.get("hub", [None])[0],
                                     show_all="all=1" in (u.query or "")))
        elif u.path == "/hubs":
            self._send(200, hubs_page())
        elif u.path == "/desk":
            self._send(200, desk_page())
        elif u.path.startswith("/hubs/"):
            key = urllib.parse.unquote(u.path[len("/hubs/"):])
            rendered = hub_profile_page(key)
            if rendered is None:
                self._send(404, page(
                    "Hub not found",
                    '<div class="card"><p>Hub not found.</p>'
                    '<a href="/hubs">Return to Hubs</a></div>',
                    active="hubs",
                ))
            else:
                self._send(200, rendered)
        elif u.path == "/api/state":
            st = state()
            live = set(st["pending"]) | set(st["queued"])
            self._send(200, json.dumps({
                "pending": st["pending"], "queued": st["queued"],
                "answers": {k: html.escape(short_verb(v)) for k, v in st["answers"].items()
                            if k in live},
                "executed": {k: md_inline(v.get("note", "")) for k, v in st["executed"].items()}}),
                "application/json")
        elif u.path == "/view":
            code, body = view(q.get("p", [""])[0])
            self._send(code, body)
        elif u.path == "/fragment":
            p = Path(q.get("p", [""])[0]).resolve()
            if str(p).startswith(str(ROOT)) and p.exists() and p.suffix == ".md":
                self._send(200, md_to_html(p.read_text(encoding="utf-8", errors="replace"),
                                           base=p.parent))
            else:
                self._send(403, "outside the estate root")
        elif u.path == "/open":
            p = Path(q.get("p", [""])[0]).resolve()
            if str(p).startswith(str(ROOT)) and p.exists():
                subprocess.Popen(["open", str(p)])
                self._send(200, "<script>history.back()</script>opened locally")
            else:
                self._send(403, "outside the estate root")
        else:
            self._send(404, "not found")

    def do_POST(self):
        data = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        CFG.mkdir(parents=True, exist_ok=True)
        now = time.strftime("%Y-%m-%d %H:%M:%S")
        if self.path == "/answer":
            card = next((c for c in parse_cards() if c["id"] == data["id"]), None)
            if card and card["tier"] in ("a", "b"):
                _brief, gate = brief_check(card["id"])
                if gate:
                    self._send(409, f"awaiting decision brief: {gate}", "text/plain")
                    return
                # The same gate on POST as in rendering (§4): a row whose options this surface
                # cannot read is not answerable through it either, however the request arrived.
                gate = options_gate(card, options_of(card))
                if gate:
                    self._send(409, f"returned to the Supervisor: {gate}", "text/plain")
                    return
            with ANSWERS.open("a") as f:
                f.write(json.dumps({"id": data["id"], "answer": data["answer"],
                                    "recommended": data.get("recommended", ""), "at": now}) + "\n")
            self._send(200, "ok", "text/plain")
        elif self.path == "/question":
            with QUESTIONS.open("a") as f:
                f.write(json.dumps({"id": data["id"], "question": data["question"], "at": now}) + "\n")
            self._send(200, "ok", "text/plain")
        elif self.path == "/supervisor-request":
            code, msg = record_supervisor_request(
                data.get("action", ""), data.get("type", ""), data.get("text", ""))
            self._send(code, msg, "text/plain")
        elif self.path == "/desk":
            code, msg = record_desk_tick(data.get("id", ""), undo=bool(data.get("undo")))
            self._send(code, msg, "text/plain")
        elif self.path == "/dismiss":
            # Owner-side view state only — an append, never a queue-file edit.
            code, msg = record_dismissal(data.get("id", ""), bool(data.get("undo")))
            self._send(code, msg, "text/plain")
        else:
            self._send(404, "not found")


# ---------- selftest (regression coverage, ruled 2026-08-17) ----------

def selftest():
    """Regression coverage for the ruled proposal lifecycle: the four governed states + the
    unrouted fallback, row-and-brief link resolution relative to each containing file, dedup by
    canonical path, root confinement (with an escape canary), and routing survival after a row
    closes or its brief archives. Pure fixtures in a temp dir: never reads QUEUE.md, never
    touches the owner's JSONL state, never pulls."""
    import tempfile
    global ROOT, SUP, BRIEFS, QUEUE, QUESTIONS, QPROCESSED, QREPLIES
    if ROOT is None:  # selftest runs manifest-free; give link resolution a safe, unused base
        ROOT = Path.cwd().resolve()
        SUP = ROOT
        BRIEFS = SUP / "queue-briefs"
        QUEUE = SUP / "QUEUE.md"
    failures = []

    def check(name, cond):
        print(("PASS " if cond else "FAIL ") + name)
        if not cond:
            failures.append(name)

    st = {"pending": ["b2"], "queued": ["b3"],
          "executed": {"b4": {"id": "b4", "note": "n", "at": ""}},
          "answers": {"b2": "accept", "b3": "apply"}, "replies": {}}
    check("state open", proposal_lifecycle("b1", st) == ("open", "Awaiting owner decision b1"))
    check("state answered quotes the verb", proposal_lifecycle("b2", st) ==
          ("answered", 'Answered "accept" — awaiting KM Supervisor execution (b2)'))
    check("state answered: a veto renders truthfully",
          proposal_lifecycle("b9", {**st, "pending": ["b9"], "answers": {"b9": "veto"}})[1]
          == 'Answered "veto" — awaiting KM Supervisor execution (b9)')
    check("state queued", proposal_lifecycle("b3", st) ==
          ("queued", "Queued for KM Supervisor execution (b3)"))
    check("state executed", proposal_lifecycle("b4", st) ==
          ("executed", "Execution recorded — proposal reconciliation pending (b4)"))
    check("state unrouted fallback", proposal_lifecycle(None, st) ==
          ("unrouted", "Needs decision routing"))
    saved = (ROOT, SUP, BRIEFS)
    try:
        with tempfile.TemporaryDirectory() as td:
            ROOT = Path(td).resolve()
            SUP = ROOT / "_KM_Supervisor"
            BRIEFS = SUP / "queue-briefs"
            (BRIEFS / "archive").mkdir(parents=True)
            changes = ROOT / "Hub" / "changes"
            changes.mkdir(parents=True)
            prop = (changes / "2026-01-01_SUP_x_proposal.md").resolve()
            prop.write_text("# X\n")
            (BRIEFS / "b7.md").write_text(
                "## 5\n- fact [the proposal](../../Hub/changes/2026-01-01_SUP_x_proposal.md)\n"
                "## 9\n[the proposal](../../Hub/changes/2026-01-01_SUP_x_proposal.md)\n"
                "[escape attempt](../../../outside_proposal.md)\n")
            raw = ("| b7 | 01-01 | 2026-01-08 | **Synthetic.** row link "
                   "[row proposal](../Hub/changes/2026-01-01_SUP_x_proposal.md) "
                   "| **\"apply\"** |\n")
            cards = parse_cards(raw)
            check("parse_cards raw fixture yields the row", [c["id"] for c in cards] == ["b7"])
            links = linked_proposals(cards[0])
            check("row + brief links dedup to one canonical path",
                  [str(p) for _l, p in links] == [str(prop)])
            check("root-escape canary refused",
                  all("outside" not in str(p) for _l, p in links))
            check("open row routes the proposal",
                  proposal_decisions(cards).get(str(prop)) == "b7")
            check("closed row still routes via its surviving brief",
                  proposal_decisions([]).get(str(prop)) == "b7")
            (BRIEFS / "b7.md").rename(BRIEFS / "archive" / "b7.md")
            check("archived brief still routes",
                  proposal_decisions([]).get(str(prop)) == "b7")
    finally:
        ROOT, SUP, BRIEFS = saved
    # The rendered surface: each state's label and destination, from synthetic proposal rows.
    base = {"path": "/tmp/x_proposal.md", "title": "X", "date": "2026-01-01"}
    unrouted = render_proposal_list([{**base, "decision_id": None,
                                      "state": "unrouted", "label": "Needs decision routing"}])
    check("render unrouted says needs decision routing",
          "Needs decision routing" in unrouted and 'data-proposal-state="unrouted"' in unrouted)
    answered = render_proposal_list([{**base, "decision_id": "b2", "state": "answered",
                                      "label": 'Answered "accept" — awaiting KM Supervisor execution (b2)'}])
    check("render answered links the decision card and the proposal record",
          "/decisions#card-b2" in answered and "proposal record" in answered
          and "awaiting KM Supervisor execution (b2)" in answered)
    queued_html = render_proposal_list([{**base, "decision_id": "b3", "state": "queued",
                                         "label": "Queued for KM Supervisor execution (b3)"}])
    check("render queued leads to the proposal record",
          "/view?p=" in queued_html and "Queued for KM Supervisor execution (b3)" in queued_html)
    # --- Waiting on KM Supervisor (ruled 2026-08-17, supervisor-actions owner interaction) ---
    # Fixture register + fixture message stores only: never reads QUEUE.md, never touches the
    # owner's live JSONL state, never pulls.
    reg = {"state": "present", "malformed": 0, "actions": [
        {"id": "act-one", "since": "2026-08-01", "due": "-",
         "action": "Reconcile the thing.", "evidence": "[handover](HANDOVER.md)"},
        {"id": "act-two", "since": "2026-08-01", "due": "2026-08-02",
         "action": "Repoint the other thing.", "evidence": "[hygiene](HANDOVER.md)"},
    ]}
    req1 = {"id": "supervisor-action:act-one", "type": "run-next",
            "question": "Run this next — make this the next action you pick up",
            "at": "2026-08-17 10:00:00"}
    open_html = render_supervisor_actions(reg, ({}, {}))
    check("section renamed Waiting on KM Supervisor",
          "Waiting on KM Supervisor" in open_html and "KM Supervisor actions" not in open_html)
    check("supporting label present",
          "No owner action is required unless you choose to redirect it" in open_html)
    check("controls on every action",
          open_html.count("Ask for update") == 2 and open_html.count(">Run next<") == 2
          and open_html.count(">Hold<") == 2)
    check("evidence link retained", "/view?p=" in open_html and ">handover<" in open_html)
    check("open state when nothing awaits acknowledgement",
          'data-sup-state="open"' in open_html and "Request sent" not in open_html)
    check("overdue derivation retained", "Overdue" in open_html and "2026-08-02" in open_html)
    check("decision-misclassification guidance text",
          "never held here" in open_html and "governed Tier A or B row" in open_html)
    sent_html = render_supervisor_actions(reg, ({"act-one": [req1]}, {}))
    check("request-sent state renders awaiting acknowledgement",
          'data-sup-state="sent"' in sent_html
          and "Request sent — awaiting KM Supervisor acknowledgement" in sent_html
          and "Run this next" in sent_html)
    rep1 = {"id": "supervisor-action:act-one", "reply": "Scheduled — runs first tomorrow.",
            "at": "2026-08-17 11:00:00"}
    replied_html = render_supervisor_actions(reg, ({"act-one": [req1]}, {"act-one": [rep1]}))
    check("reply renders inline on the row with its timestamp",
          'data-sup-state="replied"' in replied_html
          and "Scheduled — runs first tomorrow." in replied_html
          and "2026-08-17 11:00:00" in replied_html)
    saved_q = (QUESTIONS, QPROCESSED, QREPLIES)
    try:
        with tempfile.TemporaryDirectory() as td:
            QUESTIONS = Path(td) / "questions.jsonl"
            QPROCESSED = Path(td) / "questions-processed.jsonl"
            QREPLIES = Path(td) / "question-replies.jsonl"
            code, msg = record_supervisor_request("act-one", "run-next", register=reg)
            check("valid request accepted with the ruled confirmation",
                  code == 200 and msg == SUP_RUN_NEXT_CONFIRMATION)
            recorded = read_jsonl(QUESTIONS)
            check("stable ref, type, and message stored in the questions pipeline",
                  len(recorded) == 1
                  and recorded[0]["id"] == "supervisor-action:act-one"
                  and recorded[0]["type"] == "run-next"
                  and recorded[0]["question"].startswith("Run this next"))
            check("invalid action id rejected",
                  record_supervisor_request("no-such-action", "hold", register=reg)[0] == 404)
            check("invalid message type rejected",
                  record_supervisor_request("act-one", "complete", register=reg)[0] == 400)
            check("empty update question rejected",
                  record_supervisor_request("act-one", "question", "  ", register=reg)[0] == 400)
            check("nothing written on rejection", len(read_jsonl(QUESTIONS)) == 1)
            # ack round-trip: reply keyed to the same stable ref flips the row to replied,
            # surviving the pull (rotation) — a pull is not an acknowledgement.
            QUESTIONS.rename(QPROCESSED)
            reqs, reps = supervisor_action_messages()
            check("pulled-but-unreplied still reads as sent",
                  supervisor_action_state(reqs.get("act-one", []),
                                          reps.get("act-one", []))[0] == "sent")
            with QREPLIES.open("a") as f:
                f.write(json.dumps({"id": "supervisor-action:act-one", "reply": "ack",
                                    "at": "2099-01-01 00:00:00"}) + "\n")
            reqs, reps = supervisor_action_messages()
            state_name, _rq, rp = supervisor_action_state(reqs.get("act-one", []),
                                                          reps.get("act-one", []))
            check("ack round-trip lands the reply on the action row",
                  state_name == "replied" and rp["reply"] == "ack")
    finally:
        QUESTIONS, QPROCESSED, QREPLIES = saved_q
    # --- The options contract (ruled v1.31) ---------------------------------------------------
    # Found in a live demonstration: SPEC.md §3 says "exact quoted verbs, recommendation first",
    # the parser required bold AND quoted, so a queue written exactly as specified parsed zero
    # options and the card rendered an action bar with nothing in it. Both directions are proved
    # here: the forms that must parse, and the rows that must be REPORTED rather than emptied.
    spec_row = {"id": "a1", "tier": "a",
                "next": '"run after the call", "veto", "run now"'}
    check("spec form parses: plain quoted verbs, recommendation first",
          options_of(spec_row) == ["run after the call", "veto", "run now"])
    check("spec form is answerable (no gate)", options_gate(spec_row, options_of(spec_row)) is None)
    check("legacy bold+quoted still parses",
          options_of({"id": "a2", "tier": "a", "next": '**"approve"** first · **"hold"** stops it'})
          == ["approve", "hold"])
    check("legacy prose **Verb** (…) still parses",
          options_of({"id": "a3", "tier": "a", "next": "**Approve** (runs it) or **Hold** (waits)"})
          == ["Approve", "Hold"])
    check("sentence-length option labels survive whole",
          options_of({"id": "a4", "tier": "a",
                      "next": '"confirm the pre-seed, drop the prize", "veto"'})
          == ["confirm the pre-seed, drop the prize", "veto"])
    unreadable_a = {"id": "a5", "tier": "a", "next": "approve or hold, your call"}
    check("tier A: unreadable options yield none",
          options_of(unreadable_a) == [])
    check("tier A: unreadable options are REPORTED, never an empty action bar",
          "cannot read" in (options_gate(unreadable_a, options_of(unreadable_a)) or ""))
    check("tier A: an empty Options cell is reported as declaring none",
          "declares no answer options"
          in (options_gate({"id": "a6", "tier": "a", "next": ""}, []) or ""))
    unreadable_b = {"id": "b5", "tier": "b", "next": "apply or stop it, your call"}
    check("tier B: NO synthetic pair when the row declared options that failed to read",
          options_of(unreadable_b) == [])
    check("tier B: that row is gated, not answered against a synthetic pair",
          options_gate(unreadable_b, options_of(unreadable_b)) is not None)
    check("tier B: synthetic apply/veto still fires when the row declares nothing",
          options_of({"id": "b6", "tier": "b", "next": ""}) == ["apply", "veto"])
    check("tier B: a real row option still wins over the synthetic one",
          options_of({"id": "b7", "tier": "b", "next": '"run the migration"'})
          == ["run the migration", "veto"])
    check("tier C is never gated on options",
          options_gate({"id": "c1", "tier": "c", "next": ""}, []) is None)
    check("proper nouns survive the option label (capitalize() destroyed them)",
          sentence_case("ask Procurement first") == "Ask Procurement first")
    check("sentence_case still upper-cases the first character",
          sentence_case("approve") == "Approve" and sentence_case("") == "")
    fenced = ("```\n| a9 | 01-01 | - | **Example.** ctx | \"approve\", \"veto\" |\n```\n"
              "| a8 | 01-01 | - | **Real.** ctx | \"approve\", \"veto\" |\n")
    check("a fenced example row is documentation, never a card on the owner's surface",
          [c["id"] for c in parse_cards(fenced)] == ["a8"])
    # --- The layout contract (ruled v1.31) ----------------------------------------------------
    violations, coverage = layout_contract_violations()
    check(f"layout contract holds — {coverage}", not violations)
    check("layout canary: an unbounded owner-text track IS caught",
          any("unbounded maximum" in v for v in layout_contract_violations(
              STYLE.replace("grid-template-columns:118px minmax(0,1fr) minmax(190px,38%)",
                            "grid-template-columns:118px minmax(0,1fr) minmax(190px,auto)"))[0]))
    check("layout canary: a registered grid the checker cannot find REFUSES, never passes",
          any("no grid-template-columns declaration" in v for v in
              layout_contract_violations(STYLE.replace(".decision-glance {", ".gone {"))[0]))
    # --- v1.64: the row's own ANSWERED marker ------------------------------------------------
    marked = ('**ANSWERED "restrict", execution owed by the Supervisor.** '
              '**Restrict the claim.** Context sentence.')
    text, verb = split_row_answer(marked)
    check("ANSWERED marker splits off the Decision cell with its verb",
          verb == "restrict" and text.startswith("**Restrict the claim.**"))
    check("the em-dash marker form (earlier convention) still splits",
          split_row_answer('**ANSWERED "apply" — execution owed by the Supervisor.** X')[1]
          == "apply")
    check("a cell with no marker is untouched",
          split_row_answer("**Plain decision.** ctx") == ("**Plain decision.** ctx", None))
    check("decision_title never titles a card by the marker",
          decision_title({"what": text}) == "Restrict the claim.")
    marked_raw = ('| a11 | 2026-08-01 | - | **ANSWERED "restrict", execution owed by the '
                  'Supervisor.** **Restrict the claim.** ctx | "restrict", "veto" |\n')
    mc = parse_cards(marked_raw)[0]
    check("parse_cards splits the marker and carries the verb",
          mc["answered_row"] == "restrict" and mc["what"].startswith("**Restrict the claim.**"))
    check("row_answers folds the marker into an answer source",
          row_answers(marked_raw) == {"a11": "restrict"})
    mb_raw = ('| a12 | 2026-08-01 | - | **Decide.** ctx | "yes", "no" |\n'
              "<!-- QUEUE:BEGIN\n"
              "a12 | a | 2026-08-01 | - | decide? | knowledge | answered:yes\n"
              "QUEUE:END -->\n")
    check("the machine block's appended answered: field reads as an answer source",
          row_answers(mb_raw) == {"a12": "yes"})
    check("the machine block's appended lane field reads positionally, absent -> knowledge",
          [c["lane"] for c in parse_cards(mb_raw)] == ["knowledge"]
          and lane_of("machinery") == "machinery" and lane_of("") == "knowledge"
          and lane_of("nonsense") == "knowledge")
    # --- v1.64: the badge constants the client poll swaps in are serialised, never restated ---
    check("BADGE_JS derives from the server's own ANSWERED/EXECUTED constants",
          ANSWERED_META[0] in BADGE_JS and EXECUTED_META[0] in BADGE_JS
          and ANSWERED_META[1] in BADGE_JS and EXECUTED_META[1] in BADGE_JS)
    # --- v1.64: dismissal is owner-side view state, validated live, undone in place ----------
    saved_dis = DISMISSED
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["DISMISSED"] = Path(td) / "dismissed.jsonl"
            fix_cards = parse_cards('| a13 | 2026-08-01 | - | **Gated.** ctx | prose options |\n'
                                    "- **c9 — note** — an informational card\n")
            check("a tier-C row and a gated tier-A row are dismissible; nothing else is",
                  dismissible_ids(fix_cards) == {"a13", "c9"})
            code, _ = record_dismissal("c9", cards=fix_cards, now="2026-08-27 00:00:00")
            check("a valid dismissal is recorded", code == 200
                  and set(dismissals()) == {"c9"})
            code, _ = record_dismissal("c9", undo=True, cards=fix_cards,
                                       now="2026-08-27 00:00:01")
            check("an undo is an appended record and the last record wins",
                  code == 200 and dismissals() == {}
                  and len(read_jsonl(DISMISSED)) == 2)
            check("a decision row is never dismissible",
                  record_dismissal("a99", cards=fix_cards)[0] == 404)
    finally:
        globals()["DISMISSED"] = saved_dis
    # --- v1.64: run-next, the retired control, the dependency quote, the due state -----------
    reg64 = {"state": "present", "malformed": 0, "actions": [
        {"id": "act-dep", "since": "2026-08-01", "due": "-",
         "action": "Re-point the mirror. Blocked by the vendor's reply; waits on their window.",
         "evidence": "[handover](HANDOVER.md)"}]}
    saved_q64 = QUESTIONS
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["QUESTIONS"] = Path(td) / "questions.jsonl"
            code, msg = record_supervisor_request("act-dep", "prioritize", register=reg64)
            check("the retired Prioritize control is REFUSED by name, never re-filed",
                  code == 400 and "Run next" in msg
                  and not Path(td, "questions.jsonl").exists())
            code, msg = record_supervisor_request("act-dep", "run-next", register=reg64)
            recorded64 = read_jsonl(QUESTIONS)
            check("run-next over a stated dependency is RECORDED with the clause carried",
                  code == 200 and "waiting on something" in msg
                  and len(recorded64) == 1 and "Blocked by" in recorded64[0]["question"])
    finally:
        globals()["QUESTIONS"] = saved_q64
    check("supervisor_dependencies quotes the stated clause verbatim and nothing else",
          supervisor_dependencies("Do the thing. Blocked by the vendor's reply.")
          == ["Blocked by the vendor's reply."]
          and supervisor_dependencies("Do the thing, no blocker named.") == [])
    check("due_status: overdue/today/ahead/missing/unreadable are distinct states",
          due_status("-")[0] == "missing" and due_status("garbage")[0] == "unreadable"
          and due_status(datetime.date.today().isoformat())[0] == "today"
          and due_status((datetime.date.today() - datetime.timedelta(days=2)).isoformat())[0]
          == "overdue"
          and due_status((datetime.date.today() + datetime.timedelta(days=2)).isoformat())[0]
          == "ahead")
    # --- v1.64: pull writes the trace BEFORE truncating, and the log survives the consumer ---
    saved_pull = (ANSWERS, PROCESSED, PICKUP_LOG)
    try:
        with tempfile.TemporaryDirectory() as td:
            globals()["ANSWERS"] = Path(td) / "answers.jsonl"
            globals()["PROCESSED"] = Path(td) / "answers-processed.jsonl"
            globals()["PICKUP_LOG"] = Path(td) / "answer-pickup-log.md"
            ANSWERS.write_text(json.dumps({"id": "b42", "answer": "apply",
                                           "at": "2026-08-27 00:00:00"}) + "\n")
            pulled = pull_answers()
            log = PICKUP_LOG.read_text()
            check("pull consumes, rotates, and logs the consumption trace",
                  len(pulled) == 1 and ANSWERS.read_text() == ""
                  and '"b42"' in PROCESSED.read_text()
                  and "b42" in log and "consumed, processing" in log)
            check("the logged line is what the unattended panel parses",
                  [p["id"] for p in unattended_pickups()] == ["b42"])
            check("an empty pending store pulls nothing and logs nothing",
                  pull_answers() == [] and PICKUP_LOG.read_text() == log)
            # THE STEP ORDER IS THE GUARANTEE: a failure before truncation leaves the answers
            # pending, so the next pull retries them and no record is lost.
            ANSWERS.write_text(json.dumps({"id": "b43", "answer": "veto"}) + "\n")
            PICKUP_LOG.unlink()
            PICKUP_LOG.mkdir()          # a directory where a file must be: the log write fails
            try:
                pull_answers()
                failed_before_truncate = False
            except Exception:
                failed_before_truncate = True
            check("a failure at the log step leaves the pending store UNTOUCHED (no ordering "
                  "loses a record)",
                  failed_before_truncate and '"b43"' in ANSWERS.read_text())
    finally:
        (globals()["ANSWERS"], globals()["PROCESSED"], globals()["PICKUP_LOG"]) = saved_pull
    # --- v1.64: the agent-reports reader is honest about what it cannot read ----------------
    with tempfile.TemporaryDirectory() as td:
        d = Path(td) / "agent-reports"
        d.mkdir()
        (d / "2026-08-01_ok.md").write_text(
            "---\ntype: agent-report\nagent: km-example-hub\nrow: a1\noutcome: refused\n"
            "hubs: [example]\ntimestamp: 2026-08-01\n---\n\n# Refused the directive\n")
        (d / "2026-08-02_bad.md").write_text(
            "---\ntype: agent-report\nagent: km-example-hub\noutcome: exploded\n---\n\n# X\n")
        (d / "README.md").write_text("---\ntype: reference\n---\n\n# About this directory\n")
        data = parse_agent_reports(d)
        check("agent reports parse; an ungoverned outcome is named unreadable, never guessed",
              [r["outcome"] for r in data["reports"]] == ["refused"]
              and len(data["unreadable"]) == 1
              and "exploded" in data["unreadable"][0]["problem"])
        check("a missing agent-reports directory is a state, not an error",
              parse_agent_reports(Path(td) / "absent")["state"] == "missing")
    # --- v1.64: a proposal still present is not executed (awaiting-hub) ----------------------
    st64 = {"pending": [], "queued": [], "executed": {"b8": {"id": "b8", "note": "", "at": ""}},
            "answers": {}, "replies": {}, "recorded": []}
    pstate, plabel = proposal_lifecycle("b8", st64)
    check("proposal_lifecycle still reports executed (the portfolio downgrades it)",
          pstate == "executed")
    print("selftest:", "FAIL" if failures else "OK")
    if failures:
        sys.exit(1)


# ---------- CLI ----------

def queue_check(path):
    """Report every tier-A/B row whose declared options this surface cannot read (§3, v1.31).

    The estate instrument for the rule that a row the surface cannot read is REPORTED, never
    silently emptied. `hub-scan.sh` carries the same check for a hub-local queue; a supervisor
    tier, where hub-scan does not run, calls this. Read-only: never writes, never serves.

    Exit codes are three, not two, because "could not answer" is not "clean":
      0 — every row checked is answerable (the line states how many rows were read)
      1 — at least one row declares options the surface cannot read
      2 — REFUSED: no path given, or the file is missing or unreadable
    """
    if not path or not str(path).strip():
        print("queue-check: REFUSED — no queue path given (an empty path is not an empty queue)")
        return 2
    p = Path(path).expanduser()
    try:
        raw = p.read_text(encoding="utf-8")
    except OSError as e:
        print(f"queue-check: REFUSED — cannot read {p} ({e.__class__.__name__})")
        return 2
    cards = [c for c in parse_cards(raw) if c["tier"] in ("a", "b")]
    bad = []
    for c in cards:
        gate = options_gate(c, options_of(c))
        if gate:
            bad.append((c["id"], gate))
    if bad:
        print(f"queue-check: {len(bad)} of {len(cards)} tier-A/B rows in {p} are not answerable")
        for rid, gate in bad:
            # A parse failure states WHICH cell defeated it (v1.64): a malformed Defaults cell
            # and a row missing from the board must not read identically at session start.
            print(f"  {rid} — {gate}")
        print(f'  repair the named cell: options take the quoted form ("verb", recommendation '
              f'first); a Defaults cell takes one of {DEFAULTS_CELL_FORMS}')
        return 1
    print(f"queue-check: OK — {len(cards)} tier-A/B rows read in {p}, "
          "every row parses and every row's declared options are readable")
    return 0


def rotate(src, dst):
    if not src.exists() or not src.read_text().strip():
        return []
    lines = src.read_text().splitlines()
    with dst.open("a") as f:
        for line in lines:
            f.write(line + "\n")
    src.write_text("")
    return lines


def pull_answers():
    """CONSUME the pending owner answers, writing each one's trace BEFORE the consumption is
    final (v1.64; SPEC.md §3).

    WHY THE ORDER IS WHAT IT IS. Consumption is irreversible: once an id leaves the pending
    store the cockpit never offers it again. In the reference deployment a run once consumed
    twelve answers and logged eight, and the four it dropped were recoverable only because the
    owner happened to look at his board — the caller's step order was mark, then process, then
    log, so any failure between the mark and the log destroyed the record entirely. So the log
    line is no longer the CALLER's obligation, which it can forget or die before meeting: it is
    written HERE, by the consume path, for every consumer — an unattended routine and a live
    session alike — carrying the non-terminal verdict `consumed, processing`. The consumer then
    resolves that line to its outcome in the log; a crash at any point after this function
    leaves a line naming what was taken and saying it was never finished.

    THE STEP ORDER IS THE GUARANTEE:
        1. read the pending answers            (nothing is committed yet)
        2. append them to the processed store  (duplicates here are harmless and already occur)
        3. append one log line each            (the trace)
        4. TRUNCATE the pending store          (the irreversible act, LAST)
    A failure at 2 or 3 leaves the pending store untouched, so the answers stay pending and the
    next pull retries them. There is no ordering that loses a record."""
    if not ANSWERS.exists():
        return []
    lines = [l for l in ANSWERS.read_text().splitlines() if l.strip()]
    if not lines:
        return []
    with PROCESSED.open("a") as f:                                     # 2
        for line in lines:
            f.write(line + "\n")
    _log_consumption(lines)                                            # 3
    ANSWERS.write_text("")                                             # 4
    return lines


def _log_consumption(lines):
    """One `consumed, processing` line per record, appended to the pickup log beside the queue
    file. The consumer resolves each line to its outcome; an unresolved line is the honest
    record that a pulled answer was never finished."""
    if PICKUP_LOG is None:
        return
    stamp = time.strftime("%Y-%m-%d %H:%M:%S")
    day = stamp[:10]
    out = []
    for line in lines:
        try:
            r = json.loads(line)
        except Exception:
            continue
        rid = str(r.get("id", "")).strip()
        if not rid:
            continue
        verb = str(r.get("answer", "")).replace('"', "'")
        out.append(f'- {day} {rid} — answered "{verb}" — [consumed, processing] consumed '
                   f"{stamp} by `km-cockpit.py pull`; whoever pulled now owns this record and "
                   "resolves this line to its outcome.")
    if not out:
        return
    if not PICKUP_LOG.exists():
        PICKUP_LOG.write_text("# Unattended answer pickups\n\n", encoding="utf-8")
    text = PICKUP_LOG.read_text(encoding="utf-8")
    if not text.endswith("\n"):
        text += "\n"
    PICKUP_LOG.write_text(text + "\n".join(out) + "\n", encoding="utf-8")


def desk_listing():
    """The `desk` CLI view: one JSON line per effective tick. READ-ONLY by construction — it
    consumes nothing and rotates nothing. The consuming path for a tick is the ordinary `pull`,
    which already owns the whole estate's answer records."""
    return [json.dumps(r, sort_keys=True) for r in desk_ticks().values()]


def main_cli():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "serve"
    if cmd == "selftest":
        selftest()
        return
    if cmd == "queue-check" and len(sys.argv) > 2:
        sys.exit(queue_check(sys.argv[2]))    # explicit path: runs manifest-free
    load_config()
    if cmd == "queue-check":
        sys.exit(queue_check(QUEUE))
    if cmd == "pull":
        lines = pull_answers()
        print("\n".join(lines) if lines else "pull: no new answers")
    elif cmd == "dismissed":
        # READ-ONLY. Lists what the owner has taken off the screen; consumes nothing, rotates
        # nothing, and is therefore safe to call from a status path (unlike `pull`).
        lines = dismissed_listing()
        print("\n".join(lines) if lines else "dismissed: none")
    elif cmd == "desk":
        # READ-ONLY. Lists what the owner has marked done on the desk; consumes nothing and
        # rotates nothing (the ticks themselves arrive through the ordinary `pull`).
        lines = desk_listing()
        print("\n".join(lines) if lines else "desk: nothing marked done")
    elif cmd == "questions":
        lines = rotate(QUESTIONS, QPROCESSED)
        print("\n".join(lines) if lines else "questions: none")
    elif cmd == "reply":
        CFG.mkdir(parents=True, exist_ok=True)
        with QREPLIES.open("a") as f:
            f.write(json.dumps({"id": sys.argv[2], "reply": sys.argv[3],
                                "at": time.strftime("%Y-%m-%d %H:%M:%S")}) + "\n")
        print(f"reply attached to {sys.argv[2]}")
    elif cmd == "exec":
        # exec <id> <note> [status]
        #   (no status)  a genuine execution — the work was done
        #   recorded     the answer was captured but the work is still owed (unattended pickup)
        CFG.mkdir(parents=True, exist_ok=True)
        rec = {"id": sys.argv[2], "note": sys.argv[3],
               "at": time.strftime("%Y-%m-%d %H:%M:%S")}
        if len(sys.argv) > 4 and sys.argv[4]:
            rec["status"] = sys.argv[4]
        with EXECUTIONS.open("a") as f:
            f.write(json.dumps(rec) + "\n")
        print(f"{'answer recorded (work owed)' if rec.get('status') == 'recorded' else 'execution recorded'} for {sys.argv[2]}")
    elif cmd == "serve":
        if NOTIFY:
            threading.Thread(target=notify_loop, daemon=True).start()
        print(f"km-cockpit ({ORG}): http://127.0.0.1:{PORT}")
        ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
    else:
        sys.exit("usage: km-cockpit.py [serve|pull|questions|reply <id> <text>|"
                 "exec <id> <note> [status]|dismissed|desk|queue-check [<queue path>]|selftest]")


if __name__ == "__main__":
    main_cli()
