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

<!-- QUEUE:BEGIN
a1 | a | 2026-08-01 | - | approve the pilot run?
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
echo "$card" | grep -q 'Preparing for you' \
  && die "gated group rendered for a passing brief" || pass "no spurious brief gate"

code=$(curl -s -o /dev/null -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"id":"a1","answer":"approve","recommended":"approve"}' \
  "http://127.0.0.1:$PORT/answer")
[ "$code" = "200" ] && pass "answer POST accepted" || die "answer POST -> $code"
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

# Root confinement holds in single-hub mode too.
code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/view?p=/etc/hosts")
[ "$code" = "403" ] && pass "root confinement refuses an outside path" || die "confinement -> $code"

if [ "$fail" -eq 0 ]; then echo "test_km_cockpit: OK"; else echo "test_km_cockpit: FAIL"; exit 1; fi
