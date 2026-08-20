#!/usr/bin/env python3
"""KM Cockpit — the owner decision surface, a side component of the KM Standard.

The cockpit renders the owner queue (QUEUE.md) as full-context decision cards and captures the
owner's answers. It is a SURFACE, NOT A PEN: it never executes anything and never writes estate
state; every answer becomes committed estate artifacts only through a supervisor (or single-hub
agent) session, under the same governance as a chat answer. See SPEC.md in this directory for
the component's normative contract.

Lineage (behavior shipped exactly as proven in deployment, v3.8, 2026-08-17): phases 1+2 + 2.5
decision briefs; the display-contract ruling (canonical row schema Id|Since|Defaults|Decision|
Options, legacy shapes still parse; links resolved relative to the file that carries them with
safe #fragment pass-through; semantic §5 brief validation; gated records rendered in a separate
non-actionable "Preparing for you" group); the pending-proposal state alignment (every pending
hub proposal listed with its truthful lifecycle state — awaiting owner decision / answered
"<verb>" awaiting Supervisor execution / queued / execution recorded, reconciliation pending /
needs decision routing — matched through the queue row and its canonical decision brief, live or
archived, with hub attention badges derived from the same states); and the supervisor-actions
owner interaction ("Waiting on KM Supervisor" with per-action request controls — Ask for update /
Prioritize / Hold — each a REQUEST through the questions pipeline under the stable ref
`supervisor-action:<action-id>`, validated live against the SUPERVISOR-ACTIONS block, never
mutating QUEUE.md; `reply` keyed to the same ref lands back on the action row).

Deployment is CONFIGURATION ONLY: a manifest (km-cockpit.json beside this file, or
$KM_COCKPIT_CONFIG) carries the estate root, queue path, hub-registry path, port, organization
name, and state directory. The per-hub attribution map derives from the governed hub registry;
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
  pull                 print unprocessed ANSWERS as JSON lines, rotate to processed
  questions            print unprocessed owner QUESTIONS, rotate to processed
  reply <id> "text"    attach a supervisor reply to a card (renders under it)
  exec <id> "note"     record that an answer was EXECUTED (note may carry markdown links)
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

CFG = Path.home() / ".config/km-cockpit"


def _state_files():
    """(Re)derive the owner-side state paths from CFG. Separate estates on one machine must
    configure distinct state_dir values, or their answer stores collide."""
    global ANSWERS, PROCESSED, EXECUTIONS, QUESTIONS, QPROCESSED, QREPLIES, NOTIFIED
    ANSWERS = CFG / "answers.jsonl"
    PROCESSED = CFG / "answers-processed.jsonl"
    EXECUTIONS = CFG / "executions.jsonl"
    QUESTIONS = CFG / "questions.jsonl"
    QPROCESSED = CFG / "questions-processed.jsonl"
    QREPLIES = CFG / "question-replies.jsonl"
    NOTIFIED = CFG / "notified.json"


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
            m = re.search(r'^routing-keywords:\s*"?([^"\n]*)"?\s*$', dep_raw, re.M)
            kws = [k.strip().lower() for k in (m.group(1) if m else "").split(",") if k.strip()]
            if re.search(r'^initiation-interview:\s*"?\S', dep_raw, re.M):
                INITIATED.add(".")
        HUBS[key] = (ROOT.name.replace("_", " ").strip(), ".", kws)
        GOV_KEY, FALLBACK_KEY = None, key


def load_config(path=None):
    """Read the deployment manifest and derive every estate binding. Fail closed: a cockpit with
    no manifest serves nothing. Relative paths: estate_root resolves against the manifest's own
    directory; queue_path and hub_registry_path resolve against estate_root."""
    global ROOT, SUP, QUEUE, BRIEFS, HUB_REGISTRY, PORT, ORG, CFG, NOTIFY
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
    reg = cfg.get("hub_registry_path", "")
    HUB_REGISTRY = (ROOT / reg).resolve() if reg else None
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
  .watchlist { margin-top:26px; }
 .watchlist-title { display:flex; align-items:baseline; gap:14px; margin-bottom:10px; }
 .watchlist-title h2 { margin:0; font-size:20px; }
 .watchlist-title p { margin:0; color:var(--km-muted); font-size:12px; }
 .watch-items { border:1px solid var(--km-line); border-radius:8px; background:var(--km-surface);
   box-shadow:var(--km-shadow); overflow:hidden; }
 .watch-item { display:grid; grid-template-columns:34px 40px minmax(0,1fr) auto; gap:10px;
   align-items:start; padding:13px 15px; border-top:1px solid var(--km-line); }
 .watch-item:first-child { border-top:0; }
 .watch-id { font:850 12px ui-monospace, monospace; text-transform:uppercase; }
 .watch-badge { padding:2px 5px; border-radius:3px; background:var(--km-accent-soft);
   color:var(--km-accent); font:800 9px ui-monospace, monospace; text-align:center; }
 .watch-text { min-width:0; font-size:13px; }
 .watch-item time,.watch-date { color:var(--km-muted); font:700 10px ui-monospace, monospace; white-space:nowrap; }
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
    .watchlist-title { display:block; } .watchlist-title p { margin-top:4px; }
   .watch-item { grid-template-columns:32px 38px minmax(0,1fr); }
   .watch-item time,.watch-date { grid-column:3; }
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
async function viewfrag(id, p) {
  const box = document.getElementById('frag-' + id);
  box.style.display = '';
  box.innerHTML = 'loading…';
  box.innerHTML = await (await fetch('/fragment?p=' + encodeURIComponent(p))).text();
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
        flag.innerHTML = '<span class="execflag">✓ executed</span> — ' + s.executed[id];
        card.querySelectorAll('[data-answer-control]').forEach(e => e.style.display = 'none');
      } else if (s.pending.includes(id) || s.queued.includes(id)) {
        card.classList.add('done');
        const verb = (s.answers && s.answers[id]) ? '"' + s.answers[id] + '" ' : '';
        flag.innerHTML = '<span class="doneflag">✓ answer ' + verb + 'recorded — awaiting Supervisor execution</span>';
        card.querySelectorAll('[data-answer-control]').forEach(e => e.style.display = 'none');
      }
    });
  } catch (e) {}
}
setInterval(refresh, 4000);
window.addEventListener('load', refresh);
"""


def page(title, inner, sub="", active="", context=None):
    nav = [("home", "/", "OVERVIEW"), ("decisions", "/decisions", "DECISIONS"),
           ("activity", "/activity", "ACTIVITY"), ("hubs", "/hubs", "HUBS")]
    links = "".join(
        f'<a class="{"active" if key == active else ""}" href="{href}">{label}</a>'
        for key, href, label in nav)
    heading = {"home": "Overview", "decisions": "Decisions", "activity": "Activity",
               "hubs": "Hubs"}.get(active, title.split(" — ", 1)[0])
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
<script>{JS}</script></body></html>"""


# ---------- queue parsing ----------

def parse_cards(raw=None):
    if raw is None:
        raw = QUEUE.read_text(encoding="utf-8")
    joined = []
    for line in raw.splitlines():
        if joined and line.startswith("  ") and not line.lstrip().startswith(("-", "|", "#", "<")) \
                and (joined[-1].lstrip().startswith("|") or joined[-1].lstrip().startswith("- ")):
            joined[-1] += " " + line.strip()
        else:
            joined.append(line)
    cards = []
    fenced = False
    for line in joined:
        s = line.strip()
        # A fenced block is documentation, not queue content (v1.31): the template ships worked
        # example rows so there is something to copy and something to check against, and an
        # example must never render as a decision on the owner's surface.
        if s.startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        m = re.match(r"^\|\s*([ab]\d+)\s*\|(.*)\|\s*$", s)
        if m:
            rid, tier = m.group(1), m.group(1)[0]
            cells = [c.strip() for c in m.group(2).split("|")]
            # Canonical schema (ruled 2026-08-17, dossier §2.1): Id | Since | Defaults | Decision |
            # Options — recognized by the Defaults cell ("-" or a date). The legacy shapes below
            # (tier-A 4-col, tier-B 3-col, repaired 4-col) stay parseable until the queue migrates.
            if len(cells) >= 4 and re.match(r"^(-|\d{2}-\d{2}|\d{4}-\d{2}-\d{2})$", cells[1]):
                when = cells[0]
                if tier == "b" and cells[1] != "-":
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
            cards.append({"id": rid, "when": when, "what": what, "next": nxt, "tier": tier})
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
                dates[p[0]] = {"raised": p[2], "default": p[3]}
    for c in cards:
        c.update(dates.get(c["id"], {}))
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
    ".watch-item": ((3,), "the tier-C row's text"),
    ".supervisor-action-list li": ((1,), "the supervisor-action text from the queue"),
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
    """Extract the queue's short recognition phrase without its full narrative."""
    match = re.search(r"\*\*(.+?)\*\*", card["what"])
    source = match.group(1) if match else card["what"]
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


def state():
    executed = {}
    for r in read_jsonl(EXECUTIONS):
        executed[r["id"]] = r
    pending = [r["id"] for r in read_jsonl(ANSWERS) if r["id"] not in executed]
    # A pulled answer whose row is STILL open in QUEUE.md means the row was reopened/repaired
    # (sequencing rule: pull updates the queue immediately; ledger #7: such rows return to open).
    open_ids = {c["id"] for c in parse_cards()}
    queued = [r["id"] for r in read_jsonl(PROCESSED)
              if r["id"] not in executed and r["id"] not in pending and r["id"] not in open_ids]
    replies = {}
    for r in read_jsonl(QREPLIES):
        replies.setdefault(r["id"], []).append(r)
    answers = {}
    for r in read_jsonl(PROCESSED) + read_jsonl(ANSWERS):
        if r.get("id") and r.get("answer"):
            answers[r["id"]] = r["answer"]
    return {"pending": pending, "queued": queued, "executed": executed, "replies": replies,
            "answers": answers}


def rec_stats():
    recs = [r for r in read_jsonl(PROCESSED) + read_jsonl(ANSWERS) if r.get("recommended")]
    followed = sum(1 for r in recs if r["answer"].lower().strip() == r["recommended"].lower().strip())
    return len(recs), followed


def age_days(datestr):
    try:
        return (datetime.date.today() - datetime.date.fromisoformat(datestr)).days
    except Exception:
        return None


# ---------- Waiting on KM Supervisor — owner requests on Supervisor actions ----------
# Ruled 2026-08-17 (_inbox/processed/2026-08-17_KM-Cockpit_supervisor-actions-owner-interaction_
# RULED.md): the register is work owed by the KM Supervisor, never the owner's task list. The
# owner may REQUEST (ask for update / prioritize / hold); every request rides the existing
# questions pipeline under the stable ref `supervisor-action:<action-id>` and reaches the normal
# `questions` pull; the Supervisor's `reply` keyed to the same ref lands back on the row. No
# control edits QUEUE.md or the SUPERVISOR-ACTIONS block, ever — the Supervisor alone updates the
# authoritative row during its own session (a Hold binds its scheduling until released or answered
# with a reasoned alternative the owner can see).

SUP_REF_PREFIX = "supervisor-action:"
SUP_REQUEST_TYPES = {
    "question": None,  # free text, required
    "prioritize": "Please prioritize this action",
    "hold": "Hold this action pending my direction",
}
SUP_CONFIRMATION = "Request recorded — awaiting KM Supervisor acknowledgement."


def record_supervisor_request(action_id, mtype, text="", register=None, now=None):
    """Validate and append one owner request on a Supervisor action. Returns (http-code,
    message). Action ids are parsed LIVE from the SUPERVISOR-ACTIONS block on every request —
    never a hardcoded list; invalid ids and types are rejected. Appends only to the append-only
    questions store; never touches QUEUE.md."""
    if mtype not in SUP_REQUEST_TYPES:
        return 400, f"invalid request type {mtype!r} — question, prioritize, or hold"
    register = parse_supervisor_actions() if register is None else register
    if action_id not in {a["id"] for a in register["actions"]}:
        return 404, f"unknown supervisor action id {action_id!r}"
    message = SUP_REQUEST_TYPES[mtype] or " ".join((text or "").split())
    if not message:
        return 400, "an update request needs text"
    CFG.mkdir(parents=True, exist_ok=True)
    with QUESTIONS.open("a") as f:
        f.write(json.dumps({"id": SUP_REF_PREFIX + action_id, "type": mtype,
                            "question": message,
                            "at": now or time.strftime("%Y-%m-%d %H:%M:%S")}) + "\n")
    return 200, SUP_CONFIRMATION


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
            due_text = ""
            if action["due"] != "-":
                due_age = age_days(action["due"])
                due_text = (" · Date unavailable" if due_age is None else
                            f' · {"Overdue" if due_age > 0 else "Due"} '
                            f'{html.escape(action["due"])}')
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
                    f'<button class="small" onclick="supSend(\'{aid}\', \'prioritize\')">Prioritize</button>'
                    f'<button class="small" onclick="supSend(\'{aid}\', \'hold\')">Hold</button></div>'
                    f'<div class="sup-confirm" id="sup-confirm-{html.escape(aid)}" role="status"></div>')
            items.append(
                f'<li data-sup-action="{html.escape(aid)}" data-sup-state="{astate}">'
                f'<div>{md_inline(action["action"])}{flag}</div>'
                f'<div class="supervisor-action-meta">{age_text}{due_text} · '
                f'{md_inline(action["evidence"])}</div>'
                f'{reply_html}{thread}{controls}</li>'
            )
        body = f'<ol class="supervisor-action-list">{"".join(items)}</ol>'
    malformed = register["malformed"]
    warning = (f'<p class="register-warning">{malformed} malformed entr'
               f'{"y" if malformed == 1 else "ies"} omitted.</p>' if malformed else "")
    guidance = ('<p class="sup-guidance">Anything that needs your decision is never held here — '
                'it is registered on the <a href="/decisions">Decisions</a> page as a governed '
                'Tier A or B row with explicit options.</p>')
    return ('<section class="supervisor-actions" aria-labelledby="supervisor-actions-heading">'
            '<div class="supervisor-actions-title">'
            '<h2 id="supervisor-actions-heading">Waiting on KM Supervisor</h2>'
            '<p>Work owed by the KM Supervisor. No owner action is required unless you choose '
            'to redirect it.</p></div>' + body + warning + guidance + '</section>')


def render_watchlist(cards):
    if not cards:
        return ""
    items = []
    for card in cards:
        text = card["what"][:280]
        raised = card.get("raised", "")
        date = (f'<time datetime="{html.escape(raised)}">{html.escape(raised)}</time>'
                if raised else '<span class="watch-date">Open FYI</span>')
        items.append(f"""<article class="watch-item">
<span class="watch-id">{html.escape(card['id'])}</span><span class="watch-badge">FYI</span>
<div class="watch-text">{md_inline(text)}{"…" if len(card['what']) > 280 else ""}</div>{date}
</article>""")
    return f"""<section class="watchlist" aria-labelledby="watchlist-heading">
<div class="watchlist-title"><h2 id="watchlist-heading">Watchlist</h2>
<p>Time-bound reminders and information to keep in view.</p></div>
<div class="watch-items">{''.join(items)}</div></section>"""


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
    n_rec, n_followed = rec_stats()
    rate = f"{100 * n_followed // n_rec}%" if n_rec else "—"
    halt = "ON" if len(a) + len(b) > 10 else "off"
    stats = f"""
<div class="grid">
 <div class="stat"><div class="n urgent">{len(open_a)}</div><div class="l">need your word (tier A)</div></div>
 <div class="stat"><div class="n">{len(open_b)}</div><div class="l">tier B open</div></div>
 <div class="stat"><div class="n">{len(soon)}</div><div class="l">defaults within 48 h</div></div>
 <div class="stat"><div class="n">{oldest}d</div><div class="l">oldest open tier-A</div></div>
 <div class="stat"><div class="n">{len(st['pending']) + len(st['queued'])}</div><div class="l">answered · awaiting supervisor execution</div></div>
 <div class="stat"><div class="n">{len(st['executed'])}</div><div class="l">answers executed</div></div>
 <div class="stat"><div class="n">{rate}</div><div class="l">recommendation follow-rate<br>({n_followed}/{n_rec})</div></div>
 <div class="stat"><div class="n">{halt}</div><div class="l">routine decision-halt</div></div>
</div>"""
    urgent_rows = ""
    if soon:
        items = "".join(
            f'<li><b>{i}</b> defaults <b>{d}</b> ({"today" if dd <= 0 else f"in {dd}d"}) — <a href="/decisions#card-{i}">review</a></li>'
            for i, d, dd in soon)
        urgent_rows = f'<div class="card"><b>Closing soon</b><ul>{items}</ul></div>'
    rows = hub_portfolio(cards, st, read_jsonl(EXECUTIONS))
    attention = [row for row in rows if row["status"] != "Current"]
    supervisor_actions = render_supervisor_actions(parse_supervisor_actions())
    watchlist = render_watchlist(c_)
    portfolio = render_hub_portfolio(
        attention,
        heading="Hubs needing attention",
        intro="Exceptions only: open decisions, proposals needing decision or routing, answered work awaiting Supervisor execution, stale hubs, or unavailable evidence.",
        show_all=True,
    )
    inner = (stats + urgent_rows
             + supervisor_actions
             + watchlist
             + portfolio
             )
    unpulled = []
    na = len(read_jsonl(ANSWERS))
    nq = len(read_jsonl(QUESTIONS))
    if na:
        unpulled.append(f"{na} answer{'s' if na != 1 else ''}")
    if nq:
        unpulled.append(f"{nq} question{'s' if nq != 1 else ''}")
    unpulled_line = (f"<br><b>{' and '.join(unpulled)} recorded, awaiting the next supervisor pull</b>"
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
<div class="source-note"><b>Reading order</b>Decide at a glance. Open rationale or the full record only when needed.</div>"""


def decisions(hub_filter=None):
    cards = parse_cards()
    st = state()
    prefix = []
    by_tier = {"a": [], "b": [], "c": []}
    preparing = []
    if hub_filter and hub_filter in HUBS:
        prefix.append(f'<div class="sub" style="padding:0">Filtered to <b>{html.escape(HUBS[hub_filter][0])}</b> · <a href="/decisions">show all</a></div>')
    visible_cards = []
    for source_card in cards:
        c = dict(source_card)
        c["hubs"] = hubs_of(c["what"] + " " + c["next"])
        if hub_filter and hub_filter not in c["hubs"]:
            continue
        visible_cards.append(c)
    for c in visible_cards:
        tier = c["tier"]
        label, color, tip = TIER_META[c["tier"]]
        rid = c["id"]
        ex = st["executed"].get(rid)
        answered = rid in st["pending"] or rid in st["queued"]
        opts = options_of(c)
        rec = opts[0] if opts else ""
        # Phase 2.5 gate (§8.5): tier-A/B cards answer only against a passing decision brief.
        # Options gate (§3, added v1.31): and only when the row's declared options are readable.
        brief, gate = None, None
        if c["tier"] in ("a", "b"):
            bp, gate = brief_check(rid)
            if gate is None:
                brief = str(bp)
            gate = gate or options_gate(c, opts)
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
            # Ruled 2026-08-17 (§8.5 amended): a gated/incomplete record renders in the compact
            # "Preparing for you" group — visible and auditable, NO answer controls, the precise
            # gate reason inside the expanded details only, never in the glance. The Ask channel
            # stays open (§8.5). The actionable tiers are never deformed by it.
            queue_what = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", c["what"])
            preparing.append(f"""<article class="decision-row preparing tier-{tier}" data-decision-row data-row="{rid}" id="card-{rid}">
<header class="decision-glance" data-level="preparing">
<div class="decision-identity"><span class="rid">{rid}</span>
<span class="badge" style="background:#5f6368" title="Tier {tier.upper()} once ready — {tip}. Not ready for your word yet.">Preparing</span></div>
<div class="decision-title-block"><h3>{html.escape(decision_title(c))}</h3>
<div class="decision-meta"><span class="decision-hubs">{hub_chips(c["hubs"])}</span>
<span class="when">{html.escape(c['when'])}{agetxt}</span></div></div>
<div class="decision-actions"><span class="preparing-flag">Being prepared — nothing for you to do yet</span></div></header>
<details class="decision-detail"><summary>Details for audit</summary>
<div class="decision-detail-body">
<p class="decision-gate"><b>Returned to the Supervisor.</b> {html.escape(gate)}</p>
<div class="decision-deep-links">
<details class="decision-deep-section"><summary>Full queue context</summary>
<div class="queue-context">{md_inline(queue_what)}</div></details>{ask_supervisor}</div>
</div></details></article>""")
            continue
        quick_controls = ""
        custom_controls = ""
        flag = ""
        if ex:
            flag = f'<span class="execflag">✓ executed</span> — {md_inline(ex.get("note", ""))}'
        elif answered:
            verb = short_verb(st["answers"].get(rid, ""))
            flag = (f'<span class="doneflag">✓ answer "{html.escape(verb)}" recorded — '
                    'awaiting Supervisor execution</span>' if verb else
                    '<span class="doneflag">✓ answer recorded — executing…</span>')
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
        actions = ""
        if tier != "c":
            recommendation = (f'<span class="recommended-answer">Recommended: '
                              f'<b>{html.escape(sentence_case(rec))}</b></span>' if rec else "")
            actions = (f'<div class="decision-actions" data-decision="{rid}" '
                       f'aria-label="Answer and state">{recommendation}'
                       f'<div class="decision-action-buttons">{quick_controls}</div>'
                       f'<span class="stateflag">{flag}</span></div>')
        by_tier[tier].append(f"""<article class="decision-row tier-{tier}{done_class}" data-decision-row data-row="{rid}" id="card-{rid}">
<header class="decision-glance" data-level="decide-now">
<div class="decision-identity"><span class="rid">{rid}</span>
<span class="badge tier-{tier}" style="background:{color}" title="{tip}">{label}</span></div>
<div class="decision-title-block"><h3>{html.escape(decision_title(c))}</h3>
<div class="decision-meta"><span class="decision-hubs">{hub_chips(c["hubs"])}</span>
<span class="when">{html.escape(c['when'])}{agetxt}</span></div></div>{actions}</header>
<details class="decision-detail"><summary>Need more detail?</summary>
<div class="decision-detail-body">{snapshot}{proposal_section}
<div class="decision-deep-links" data-level="full-record">{briefhtml}{sources}{queue_context}{ask_supervisor}{other_answer}</div>
</div></details></article>""")
    groups = "".join(
        f'<section class="ledger-section" data-tier="{tier}" aria-labelledby="tier-{tier}-title">'
        f'<div class="section-label"><span id="tier-{tier}-title">{TIER_SECTIONS[tier]}</span>'
        f'<span class="count">{len(by_tier[tier]):02d}</span></div>'
        f'<p class="section-description">{TIER_DESCRIPTIONS[tier]}</p>'
        f'{"".join(by_tier[tier])}</section>'
        for tier in ("a", "b", "c") if by_tier[tier])
    if preparing:
        groups += (
            '<section class="ledger-section preparing-section" data-tier="preparing" '
            'aria-labelledby="tier-preparing-title">'
            '<div class="section-label"><span id="tier-preparing-title">PREPARING FOR YOU — '
            'SUPERVISOR CORRECTION REQUIRED</span>'
            f'<span class="count">{len(preparing):02d}</span></div>'
            '<p class="section-description">Visible for audit; not yet answerable. The Supervisor '
            'owes each a completed decision brief before it joins its tier.</p>'
            f'{"".join(preparing)}</section>')
    if groups:
        body = f'<div class="decision-ledger" data-view="decision-ledger">{groups}</div>'
    else:
        body = ('<div class="empty-state"><b>No decisions in this view.</b> '
                'Choose another hub or show all decisions.</div>')
    return page("Decisions — KM Cockpit", "".join(prefix) + body,
                sub="Decide at a glance. Open more detail only when you need it.",
                active="decisions", context=decision_authority_context())


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


def activity(hub_filter=None):
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
        if record["id"] in done_ids:
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
    grouped = (f'<div class="activity-days">{"".join(sections)}</div>'
               if sections else '<div class="feed">Nothing yet.</div>')
    return page("Activity — KM Cockpit", prefix + grouped,
                sub="every answer you gave, and what the estate did with it — newest first",
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
    executions = read_jsonl(EXECUTIONS) if executions is None else executions
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
            proposals.append(proposal)
        awaiting_exec = sum(1 for p in proposals
                            if p["state"] in ("answered", "queued", "executed"))
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
    executions = read_jsonl(EXECUTIONS)
    rows = hub_portfolio(cards, st, executions)
    return page("Hubs — KM Cockpit", render_hub_directory(rows, cards, st, executions),
                sub="the complete hub directory — status at a glance, evidence and recent history on expansion",
                active="hubs")


def hub_profile_page(key):
    if key not in HUBS or key == GOV_KEY:
        return None
    cards = parse_cards()
    st = state()
    executions = read_jsonl(EXECUTIONS)
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
            self._send(200, decisions(q.get("hub", [None])[0]))
        elif u.path == "/activity":
            self._send(200, activity(q.get("hub", [None])[0]))
        elif u.path == "/hubs":
            self._send(200, hubs_page())
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
    req1 = {"id": "supervisor-action:act-one", "type": "prioritize",
            "question": "Please prioritize this action", "at": "2026-08-17 10:00:00"}
    open_html = render_supervisor_actions(reg, ({}, {}))
    check("section renamed Waiting on KM Supervisor",
          "Waiting on KM Supervisor" in open_html and "KM Supervisor actions" not in open_html)
    check("supporting label present",
          "No owner action is required unless you choose to redirect it" in open_html)
    check("controls on every action",
          open_html.count("Ask for update") == 2 and open_html.count(">Prioritize<") == 2
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
          and "Please prioritize this action" in sent_html)
    rep1 = {"id": "supervisor-action:act-one", "reply": "Prioritized — runs first tomorrow.",
            "at": "2026-08-17 11:00:00"}
    replied_html = render_supervisor_actions(reg, ({"act-one": [req1]}, {"act-one": [rep1]}))
    check("reply renders inline on the row with its timestamp",
          'data-sup-state="replied"' in replied_html
          and "Prioritized — runs first tomorrow." in replied_html
          and "2026-08-17 11:00:00" in replied_html)
    saved_q = (QUESTIONS, QPROCESSED, QREPLIES)
    try:
        with tempfile.TemporaryDirectory() as td:
            QUESTIONS = Path(td) / "questions.jsonl"
            QPROCESSED = Path(td) / "questions-processed.jsonl"
            QREPLIES = Path(td) / "question-replies.jsonl"
            code, msg = record_supervisor_request("act-one", "prioritize", register=reg)
            check("valid request accepted with the ruled confirmation",
                  code == 200 and msg == SUP_CONFIRMATION)
            recorded = read_jsonl(QUESTIONS)
            check("stable ref, type, and message stored in the questions pipeline",
                  len(recorded) == 1
                  and recorded[0]["id"] == "supervisor-action:act-one"
                  and recorded[0]["type"] == "prioritize"
                  and recorded[0]["question"] == "Please prioritize this action")
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
            print(f"  {rid} — {gate}")
        return 1
    print(f"queue-check: OK — {len(cards)} tier-A/B rows read in {p}, "
          "every row's declared options are readable")
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
        lines = rotate(ANSWERS, PROCESSED)
        print("\n".join(lines) if lines else "pull: no new answers")
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
        CFG.mkdir(parents=True, exist_ok=True)
        with EXECUTIONS.open("a") as f:
            f.write(json.dumps({"id": sys.argv[2], "note": sys.argv[3],
                                "at": time.strftime("%Y-%m-%d %H:%M:%S")}) + "\n")
        print(f"execution recorded for {sys.argv[2]}")
    elif cmd == "serve":
        if NOTIFY:
            threading.Thread(target=notify_loop, daemon=True).start()
        print(f"km-cockpit ({ORG}): http://127.0.0.1:{PORT}")
        ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
    else:
        sys.exit("usage: km-cockpit.py [serve|pull|questions|reply <id> <text>|exec <id> <note>|"
                 "queue-check [<queue path>]|selftest]")


if __name__ == "__main__":
    main_cli()
