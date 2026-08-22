#!/bin/bash
# Fixtures for the KM Cockpit side component (components/km-cockpit/, v1.24).
#
# Two halves:
#   1. The component's own regression suite (`selftest`) — the ruled proposal lifecycle, link
#      resolution, root confinement, and the supervisor-actions request channel — must pass
#      manifest-free.
#   2. SINGLE-HUB BINDING, the genuinely new surface of the v1.24-v1.26 train: the full
#      card/answer/pull round-trip against a HUB-LOCAL queue file. A temp hub carries QUEUE.md,
#      a passing decision brief, and a deployment binding with routing keywords; the manifest
#      omits hub_registry_path (single-hub mode). The test proves: the card renders answerable,
#      the POST lands in an ISOLATED state dir, /api/state tracks answered -> executed, and the
#      session CLI (pull, exec) completes the loop. `pull` here runs against the test's own
#      fixture store only — never the live estate store (that store consumes for the estate).
# All content is synthetic; no real person, organization, or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COCKPIT="$ROOT/components/km-cockpit/km-cockpit.py"
work="$(mktemp -d)"
PORT=8493
SERVER_PID=""
cleanup() {
  [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null
  rm -rf "$work"
}
trap cleanup EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# --- 1. Component regression suite, manifest-free -------------------------------------------
if (cd "$work" && python3 "$COCKPIT" selftest >"$work/selftest.log" 2>&1); then
  pass "component selftest (ruled lifecycle, links, confinement, request channel)"
else
  die "component selftest"; tail -5 "$work/selftest.log"
fi

# --- 2. Single-hub round-trip: hub-local queue, isolated state dir --------------------------
hub="$work/Example_Hub"
state="$work/state"
mkdir -p "$hub/queue-briefs" "$hub/cockpit" "$state"

cat > "$hub/QUEUE.md" <<'EOF'
# Owner Queue

## Tier A — needs the owner's word

| Id | Since | Defaults | Decision | Options |
|---|---|---|---|---|
| a1 | 2026-08-01 | - | **Approve the pilot run.** One sentence of context for the reader. | **"approve"** first · **"hold"** stops it |
| a2 | 2026-08-01 | - | **Decide the pre-seed.** Written exactly as SPEC.md documents the schema. | "confirm the pre-seed, drop the prize", "ask Procurement first", "veto" |
| a3 | 2026-08-01 | - | **Options this surface cannot read.** Declared in prose, not as quoted verbs. | approve or hold, your call |

```
| a9 | 2026-08-01 | - | **A worked example.** Fenced, therefore documentation. | "approve", "veto" |
```

## Owner's desk

- **Chase the vendor SOW** — you are waiting on their signed statement of work.
- **Send the retro notes** — you owe the team last sprint's retrospective.

<!-- QUEUE:BEGIN
a1 | a | 2026-08-01 | - | approve the pilot run?
a2 | a | 2026-08-01 | - | decide the pre-seed?
a3 | a | 2026-08-01 | - | unreadable options?
QUEUE:END -->

<!-- SUPERVISOR-ACTIONS:BEGIN
id | since | due | action | evidence
SUPERVISOR-ACTIONS:END -->
EOF

cat > "$hub/queue-briefs/a1.md" <<'EOF'
---
row: a1
tier: a
raised: 2026-08-01
hubs: [example-hub]
reversible: "yes — one line"
delegable: never
---

## 1. The decision
Approve the pilot run.
## 2. Why now
None.
## 3. Why the owner
Only the owner can commit the budget.
## 4. Recommendation & rationale
Approve; the pilot is reversible.
## 5. Supporting facts
- The pilot plan was recorded 2026-08-01 in this KM.
## 6. Conflicts, missing information, uncertainty
None.
## 7. Consequences per option
Approve: it runs. Hold: it waits.
## 8. Affected KMs & artifacts
None.
## 9. Execution preview
None.
## 10. Reversibility & delegability
Reversible; never delegable.
EOF

sed -e 's/^row: a1$/row: a2/' "$hub/queue-briefs/a1.md" > "$hub/queue-briefs/a2.md"
sed -e 's/^row: a1$/row: a3/' "$hub/queue-briefs/a1.md" > "$hub/queue-briefs/a3.md"

cat > "$hub/km-deployment.md" <<'EOF'
---
type: config
title: KM Deployment Binding
initiation-interview: "2026-08-01"
routing-keywords: "pilot, example"
---
EOF

cat > "$hub/cockpit/km-cockpit.json" <<EOF
{
  "estate_root": "..",
  "queue_path": "QUEUE.md",
  "port": $PORT,
  "organization_name": "Example Organization",
  "state_dir": "$state",
  "notifications": false
}
EOF

KM_COCKPIT_CONFIG="$hub/cockpit/km-cockpit.json" python3 "$COCKPIT" serve \
  >"$work/server.log" 2>&1 &
SERVER_PID=$!
up=""
for _ in $(seq 1 20); do
  if curl -s -o /dev/null "http://127.0.0.1:$PORT/"; then up=1; break; fi
  sleep 0.3
done
if [ -n "$up" ]; then pass "server starts from the manifest (single-hub mode)"; else
  die "server did not start"; cat "$work/server.log"; exit 1; fi

for route in / /decisions /activity /hubs /api/state; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT$route")
  if [ "$code" = "200" ]; then pass "route $route -> 200"; else die "route $route -> $code"; fi
done

card=$(curl -s "http://127.0.0.1:$PORT/decisions")
echo "$card" | grep -q 'card-a1' \
  && pass "hub-local queue row renders as a card" || die "card a1 not rendered"
echo "$card" | grep -q '>Approve<' \
  && pass "answer controls present (brief gate passed)" || die "answer controls missing"
echo "$card" | grep -q 'EXAMPLE ORGANIZATION' \
  && pass "organization name from the manifest, not the code" || die "organization name missing"

# --- The options contract (v1.31), proved at the RENDERED surface ---------------------------
# The defect this closes was invisible at the unit level and visible only here: a row written
# exactly as SPEC.md documents it parsed zero options, so the card rendered its title, tier
# badge, hub chips and age — and an action bar containing nothing.
echo "$card" | grep -q '>Confirm the pre-seed, drop the prize<' \
  && pass "spec-form row (plain quoted verbs) renders its answer controls" \
  || die "spec-form row rendered no answer control — the v1.31 defect"
echo "$card" | grep -q '>Ask Procurement first<' \
  && pass "proper noun survives the option label (capitalize() lower-cased it)" \
  || die "option label proper noun destroyed"
python3 - "$PORT" <<'PY' && pass "unreadable-options row reported; readable rows NOT gated" \
  || die "options gate wrong in one direction (see message above)"
import sys, re, urllib.request
html = urllib.request.urlopen(f"http://127.0.0.1:{sys.argv[1]}/decisions").read().decode()

def card(rid):
    m = re.search(r'<article[^>]*data-row="%s".*?</article>' % rid, html, re.S)
    if not m:
        sys.exit(f"{rid} did not render at all")
    return m.group(0)

a3 = card("a3")
if "data-answer-control" in a3:
    sys.exit("a3: answer controls rendered on a row whose options cannot be read")
if "cannot read" not in a3:
    sys.exit("a3: gated with no reason stated in the card")
if "Being prepared" not in a3:
    sys.exit("a3: not routed into the Preparing group")
# The other direction: the gate must not fire on rows it can read.
for rid in ("a1", "a2"):
    body = card(rid)
    if "data-answer-control" not in body:
        sys.exit(f"{rid}: readable row lost its answer controls")
    if "Being prepared" in body:
        sys.exit(f"{rid}: readable row wrongly gated")
PY
echo "$card" | grep -q 'card-a9' \
  && die "a fenced example row rendered as a decision" \
  || pass "fenced example row is documentation, never a card"

# --- dev-0007: a gated card wears a NEUTRAL badge, never its actionable tier badge ------------
# The defect (owner screenshot 2026-08-19): a gated tier-A card rendered the red "Needs you" tier
# badge beside the "being prepared" flag, so one glance both summoned the owner and said nothing
# was for him yet. The fix: the gated glance carries a neutral "Preparing" badge; the tier lives
# only in the badge's title tooltip. Proved in BOTH directions, and failing closed on an empty
# extraction so a fixture drift cannot read as a silent pass.
python3 - "$PORT" <<'PY' && pass "gated card wears neutral 'Preparing' badge, not tier-A 'Needs you'; ungated tier-A still summons" \
  || die "dev-0007 preparing badge wrong in one direction (see message above)"
import sys, re, urllib.request
html = urllib.request.urlopen(f"http://127.0.0.1:{sys.argv[1]}/decisions").read().decode()

def glance(rid):
    m = re.search(r'<article[^>]*data-row="%s".*?</header>' % rid, html, re.S)
    if not m or not m.group(0).strip():
        sys.exit(f"{rid}: glance did not render — fixture extraction empty, failing closed")
    return m.group(0)

# Gated tier-A (a3, options this surface cannot read) is routed into the Preparing group.
a3 = glance("a3")
if "Being prepared" not in a3:
    sys.exit("a3: not the gated/preparing card — fixture drifted, failing closed")
if ">Preparing<" not in a3:
    sys.exit("a3: gated glance is missing the neutral 'Preparing' badge")
if "Needs you" in a3:
    sys.exit("a3: gated glance still shows the actionable tier-A 'Needs you' badge (dev-0007)")

# Canary — an ungated actionable tier-A card (a1) still carries its summons unchanged.
a1 = glance("a1")
if "Needs you" not in a1:
    sys.exit("a1: an ungated tier-A card lost its 'Needs you' badge — the fix over-reached")
if ">Preparing<" in a1:
    sys.exit("a1: an ungated tier-A card wrongly wears the neutral 'Preparing' badge")
PY

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"id":"a1","answer":"approve","recommended":"approve"}' \
  "http://127.0.0.1:$PORT/answer")
[ "$code" = "200" ] && pass "answer POST accepted" || die "answer POST -> $code"

# The options gate binds POST as well as rendering: hiding a control is not enforcing a gate.
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"id":"a3","answer":"approve","recommended":"approve"}' \
  "http://127.0.0.1:$PORT/answer")
[ "$code" = "409" ] && pass "answer POST refused for a row whose options cannot be read" \
  || die "unreadable row accepted an answer -> $code"
grep -q '"a3"' "$state/answers.jsonl" 2>/dev/null \
  && die "a refused answer was still written to the store" \
  || pass "nothing written for the refused answer"
grep -q '"a1"' "$state/answers.jsonl" 2>/dev/null \
  && pass "answer landed in the ISOLATED state dir" || die "answer not in isolated store"
curl -s "http://127.0.0.1:$PORT/api/state" | grep -q '"pending": \["a1"\]' \
  && pass "/api/state reports a1 answered (pending execution)" || die "state not pending"

# Session side: pull rotates the fixture store (NEVER the live estate store), exec closes it.
pulled=$(KM_COCKPIT_CONFIG="$hub/cockpit/km-cockpit.json" python3 "$COCKPIT" pull)
echo "$pulled" | grep -q '"id": "a1"' && pass "pull returns the answer" || die "pull empty"
[ -s "$state/answers.jsonl" ] && die "pull did not rotate" || pass "pull rotated to processed"
grep -q '"a1"' "$state/answers-processed.jsonl" \
  && pass "processed store holds the record" || die "processed store empty"

# Reopened-row protection: a pulled answer whose row is STILL open in the queue reads as
# neither pending nor queued (the row was reopened/repaired — the card returns to open).
curl -s "http://127.0.0.1:$PORT/api/state" | grep -q '"queued": \[\]' \
  && pass "row still open after pull is NOT queued (reopened protection)" \
  || die "reopened protection missing"

# The sequencing rule: the pulling session updates the queue immediately — answered rows
# leave the open tables. Then, and only then, the answer reads as queued for execution.
python3 - "$hub/QUEUE.md" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
p.write_text("\n".join(l for l in p.read_text().splitlines()
                       if not l.startswith("| a1 ")) + "\n")
PY
curl -s "http://127.0.0.1:$PORT/api/state" | grep -q '"queued": \["a1"\]' \
  && pass "queue updated -> pulled answer reads as queued" || die "state not queued"

KM_COCKPIT_CONFIG="$hub/cockpit/km-cockpit.json" python3 "$COCKPIT" \
  exec a1 "executed: pilot approved, commit recorded" >/dev/null
curl -s "http://127.0.0.1:$PORT/api/state" | grep -q '"a1": "executed' \
  && pass "execution recorded and served" || die "execution not in state"
curl -s "http://127.0.0.1:$PORT/activity" | grep -q 'pilot approved' \
  && pass "activity feed carries the execution note" || die "activity missing execution"

# --- dev-0009: a bookkeeping capture is NOT work done -----------------------------------------
# An unattended answer pickup writes an execution record marked `status: recorded` — the answer
# was captured but the work is still owed. Such a record must never count as executed (or an
# answered-but-undone row shows as resolved and the executed tally lies), and it must surface as
# awaiting execution instead. A record with no status stays a genuine execution (a1, above), so
# the split is proved in BOTH directions on the same live state. `z9` is not a queue row, so its
# only route into "awaiting execution" is the recorded fold. Fails closed if /api/state is empty.
KM_COCKPIT_CONFIG="$hub/cockpit/km-cockpit.json" python3 "$COCKPIT" \
  exec z9 "answer captured by the unattended pickup, work owed" recorded >/dev/null
python3 - "$PORT" <<'PY' && pass "recorded capture is awaiting-execution, not executed; status-absent still executes (dev-0009, both directions)" \
  || die "dev-0009 execution-status split wrong in one direction (see message above)"
import sys, json, urllib.request
s = json.load(urllib.request.urlopen(f"http://127.0.0.1:{sys.argv[1]}/api/state"))
if not s.get("queued") and not s.get("executed"):
    sys.exit("state carried neither queued nor executed ids — fixture empty, failing closed")
# The bookkeeping capture must NOT read as executed and MUST read as awaiting execution.
if "z9" in s["executed"]:
    sys.exit("z9: a bookkeeping capture (status recorded) counted as executed — the dev-0009 defect")
if "z9" not in s["queued"]:
    sys.exit("z9: a recorded capture did not surface as awaiting Supervisor execution")
# The other direction: a status-absent record is a genuine execution and stays counted as done.
if "a1" not in s["executed"]:
    sys.exit("a1: a status-absent record stopped counting as executed — the fix over-reached")
if "a1" in s["queued"]:
    sys.exit("a1: a genuine execution wrongly shows as awaiting execution")
PY

# --- dev-0005: the owner's desk — a hand lane derived from the queue, never written ----------
# The desk holds the owner's PERSONAL follow-ups as bullets under "## Owner's desk". They are a hand
# lane: they render in their own section after Hubs, never as decision cards in tiers A/B/C, the id is
# derived as desk-<slug> from the bullet's bold lead, the cockpit derives the desk from the queue and
# never writes it, and Mark done rides the answers channel and moves the item to the done disclosure.
code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/desk")
[ "$code" = "200" ] && pass "route /desk -> 200" || die "route /desk -> $code"

# Direction 1: the desk bullet renders in the desk section; it is NOT a card in the A/B/C tiers.
python3 - "$PORT" <<'PY' && pass "desk-<slug> hand-lane item renders in the desk section and NOT in tiers A/B/C (dev-0005, both directions)" \
  || die "dev-0005 desk/tier classification wrong in one direction (see message above)"
import sys, re, urllib.request
base = f"http://127.0.0.1:{sys.argv[1]}"
desk = urllib.request.urlopen(base + "/desk").read().decode()
dec = urllib.request.urlopen(base + "/decisions").read().decode()

m = re.search(r'<section class="desk".*?</section>', desk, re.S)
if not m or not m.group(0).strip():
    sys.exit("desk section did not render — fixture extraction empty, failing closed")
section = m.group(0)
rid = "desk-chase-the-vendor-sow"
if f'data-desk-item="{rid}"' not in section:
    sys.exit(f"{rid}: derived desk id did not render as an active desk item")
if "Chase the vendor SOW" not in section:
    sys.exit("the desk bullet text is missing from the desk section")
# The other direction: a desk item is a hand lane, never a decision card.
if "desk-chase" in dec or "Chase the vendor SOW" in dec:
    sys.exit("a desk item leaked onto the decisions board (tiers A/B/C)")
for tier_card in re.findall(r'data-row="([^"]+)"', dec):
    if tier_card.startswith("desk-"):
        sys.exit(f"{tier_card}: a desk id rendered as a decision card")
PY

# Direction 2: a done record moves the item to the done disclosure and off the active list.
before=$(shasum "$hub/QUEUE.md" | awk '{print $1}')
code=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"id":"desk-chase-the-vendor-sow"}' \
  "http://127.0.0.1:$PORT/desk")
[ "$code" = "200" ] && pass "desk Mark-done POST accepted" || die "desk POST -> $code"
grep -q '"desk-chase-the-vendor-sow"' "$state/answers.jsonl" 2>/dev/null \
  && pass "desk tick landed in the ISOLATED owner store (answers channel)" \
  || die "desk tick not written to the isolated store"

# The cockpit derives the desk from the queue and NEVER writes it: QUEUE.md is byte-identical.
after=$(shasum "$hub/QUEUE.md" | awk '{print $1}')
[ "$before" = "$after" ] && pass "cockpit did not write QUEUE.md (derive-never-edit)" \
  || die "QUEUE.md changed after a desk POST — the cockpit wrote the queue"

python3 - "$PORT" <<'PY' && pass "ticked desk item moves to the done disclosure and off the active list (dev-0005)" \
  || die "dev-0005 done-record handling wrong (see message above)"
import sys, re, urllib.request
desk = urllib.request.urlopen(f"http://127.0.0.1:{sys.argv[1]}/desk").read().decode()
rid = "desk-chase-the-vendor-sow"
m = re.search(r'<section class="desk".*?</section>', desk, re.S)
if not m or not m.group(0).strip():
    sys.exit("desk section did not render after the tick — failing closed")
section = m.group(0)
active = re.search(r'<div class="desk-items">(.*?)</div>\s*(?:<details|</section)', section, re.S)
if active and f'data-desk-item="{rid}"' in active.group(1):
    sys.exit(f"{rid}: a ticked item is still on the active desk list")
disc = re.search(r'<details class="desk-done-disclosure">.*?</details>', section, re.S)
if not disc:
    sys.exit("no done disclosure rendered after a tick")
if rid not in disc.group(0):
    sys.exit(f"{rid}: a ticked item is not in the done disclosure")
# The other item stays active — the tick moved exactly one item.
if 'data-desk-item="desk-send-the-retro-notes"' not in section:
    sys.exit("desk-send-the-retro-notes: an untouched item fell off the active desk")
PY

# --- dev-0013: a desk tick is never a decision awaiting execution ----------------------------
# Desk ticks ride the ANSWERS channel, so state() must exclude DESK_PREFIX ids from the decision
# accounting or a cleared personal follow-up reads as "answered, awaiting Supervisor execution".
# desk-chase-the-vendor-sow was ticked above (a done record in the answer store); it must appear
# in NONE of pending/queued/executed/recorded, yet STILL render in the desk done disclosure. Both
# directions on the same live state, with a genuine decision (z9, awaiting execution) as the canary
# that the exclusion did not swallow real work. Fails closed if /api/state carries no decision ids.
python3 - "$PORT" <<'PY' && pass "desk tick counts in NO decision/execution set yet still renders in the done disclosure; a real decision still counts (dev-0013, both directions)" \
  || die "dev-0013 desk-execution exclusion wrong in one direction (see message above)"
import sys, re, json, urllib.request
base = f"http://127.0.0.1:{sys.argv[1]}"
s = json.load(urllib.request.urlopen(base + "/api/state"))
# /api/state serves pending, queued, executed; a desk id in `recorded` would fold into `queued`
# (state() folds recorded -> queued), so the queued assertion covers the recorded set too.
sets = {k: (list(s[k]) if isinstance(s[k], list) else list(s[k].keys()))
        for k in ("pending", "queued", "executed")}
if not any(sets.values()):
    sys.exit("state carried no decision ids in any set (fixture empty), failing closed")
# Direction 1: no desk id may appear in any decision/execution set.
for name, ids in sets.items():
    leaked = [i for i in ids if str(i).startswith("desk-")]
    if leaked:
        sys.exit(f"{name}: desk ids counted as decisions/executions {leaked}: the dev-0013 defect")
# Canary: the exclusion must not swallow a genuine decision awaiting execution.
if "z9" not in sets["queued"]:
    sys.exit("z9: a real decision awaiting execution stopped counting: the fix over-reached")
# Direction 2: the ticked desk item still surfaces in the desk done disclosure.
desk = urllib.request.urlopen(base + "/desk").read().decode()
m = re.search(r'<details class="desk-done-disclosure">.*?</details>', desk, re.S)
if not m or not m.group(0).strip():
    sys.exit("desk done disclosure did not render, failing closed")
if "desk-chase-the-vendor-sow" not in m.group(0):
    sys.exit("desk-chase-the-vendor-sow: the ticked item vanished from the done disclosure")
PY

# Root confinement holds in single-hub mode too.
code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/view?p=/etc/hosts")
[ "$code" = "403" ] && pass "root confinement refuses an outside path" || die "confinement -> $code"

if [ "$fail" -eq 0 ]; then echo "test_km_cockpit: OK"; else echo "test_km_cockpit: FAIL"; exit 1; fi
