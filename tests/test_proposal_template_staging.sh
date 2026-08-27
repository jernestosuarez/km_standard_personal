#!/bin/bash
# km-unrepaired-tree: v1.64 | run against the unrepaired tree at ac63d2f (v1.63 draft): case 1 FAILED — template/changes/PROPOSAL_TEMPLATE.md carries the explicit-path staging step and NO blanket-add prohibition, so the check names the missing prohibition and exits 1; the fixture cases proving both directions behaved as designed on the same tree.
#
# The proposal template's staging discipline (RFC-008, v1.64).
#
# WHAT THIS CHECKS. The shipped proposal template (template/changes/PROPOSAL_TEMPLATE.md) must
# carry BOTH halves of the staging discipline in its post-apply steps:
#   1. the explicit-path staging step — `git add <path>`, each touched path staged by name;
#   2. the blanket-add prohibition — the sentence telling the applying agent never to stage with
#      a blanket add, because in synchronized storage a deletion is not durable and a blanket add
#      re-commits the proposal and approval files the apply just deleted (Rule 3, "Stage
#      explicitly").
#
# WHY PRESENCE, NEVER TOKEN-ABSENCE. The criterion this check replaces was "grep finds no
# `git add -A` in the template" — and a template with NO staging step at all satisfies it
# perfectly. That false green let the one file that most needed the fix pass a conformance wave
# in the deployment that reported this (RFC-008 records the incident, genericised). A control
# whose claim is an absence must measure the absence against the presence that makes it
# meaningful (v1.61): this check requires the staging step to be PRESENT, the prohibition to be
# PRESENT, and any blanket-add instruction to be ABSENT — three findings, each named.
#
# Both directions are proved on synthetic fixtures, then the real shipped template is judged.
# Refuses (exit 2) rather than passes on a template it cannot read.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/template/changes/PROPOSAL_TEMPLATE.md"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# The checker under test, as a function so the fixtures and the real template share one truth.
#   exit 0 — both halves present, no blanket-add instruction
#   exit 1 — a finding (each named on stdout)
#   exit 2 — REFUSED: the file is missing or unreadable (an unread template is not a clean one)
check_template() {
  local f="$1"
  local text
  if [ ! -f "$f" ]; then
    echo "REFUSED: no proposal template at $f"
    return 2
  fi
  if ! text="$(cat "$f" 2>/dev/null)" || [ -z "$text" ]; then
    echo "REFUSED: proposal template at $f is empty or unreadable"
    return 2
  fi
  local findings=0
  # 1. The explicit-path staging step must be PRESENT. Its absence is the false-green case:
  #    a template with no staging step trivially contains no blanket add.
  if ! printf '%s' "$text" | grep -q 'git add <path>'; then
    echo "FINDING: no explicit-path staging step (git add <path> ...) in the post-apply steps"
    findings=1
  fi
  # 2. The blanket-add prohibition must be PRESENT, beside the step it governs.
  if ! printf '%s' "$text" | grep -qi 'never stage with a blanket add'; then
    echo "FINDING: no blanket-add prohibition beside the staging step (Rule 3, Stage explicitly)"
    findings=1
  fi
  # 3. No blanket-add instruction may be present. This is the absence half, measured only
  #    alongside the presences above so it can never pass on an empty file.
  if printf '%s' "$text" | grep -qE 'git add (-A|--all|\.)'; then
    echo "FINDING: the template instructs a blanket add (git add -A/--all/.)"
    findings=1
  fi
  return "$findings"
}

# --- Both directions on fixtures --------------------------------------------------------------

good="$work/good.md"
cat > "$good" <<'EOF'
## Post-apply steps (agent)
5. Commit the change, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`).
   Never stage with a blanket add: in synchronized storage a deletion is not durable, so a blanket
   add can resurrect the proposal and approval files this apply just deleted (Rule 3).
EOF
check_template "$good" >/dev/null \
  && pass "fixture with both halves passes" \
  || die "fixture with both halves failed"

no_staging="$work/no-staging.md"
cat > "$no_staging" <<'EOF'
## Post-apply steps (agent)
5. Commit the change. Never stage with a blanket add.
EOF
out="$(check_template "$no_staging")" && die "fixture with NO staging step passed — the false-green class this check exists to close" \
  || { echo "$out" | grep -q "no explicit-path staging step" \
       && pass "fixture with no staging step at all is caught (the false-green class)" \
       || die "no-staging fixture failed for the wrong reason: $out"; }

no_prohibition="$work/no-prohibition.md"
cat > "$no_prohibition" <<'EOF'
## Post-apply steps (agent)
5. Commit the change, staging each touched path by name (`git add <path> ... && git commit -m "apply: <slug>"`)
EOF
out="$(check_template "$no_prohibition")" && die "fixture without the prohibition passed" \
  || { echo "$out" | grep -q "no blanket-add prohibition" \
       && pass "fixture without the prohibition is caught" \
       || die "no-prohibition fixture failed for the wrong reason: $out"; }

blanket="$work/blanket.md"
cat > "$blanket" <<'EOF'
## Post-apply steps (agent)
5. Commit the change, staging each touched path by name (`git add <path> ...`).
   Never stage with a blanket add.
6. Or just run `git add -A` when in a hurry.
EOF
out="$(check_template "$blanket")" && die "fixture instructing a blanket add passed" \
  || { echo "$out" | grep -q "instructs a blanket add" \
       && pass "fixture instructing git add -A is caught" \
       || die "blanket fixture failed for the wrong reason: $out"; }

check_template "$work/absent.md" >/dev/null
[ "$?" = "2" ] && pass "a missing template REFUSES (exit 2), never passes" \
  || die "a missing template did not refuse"

: > "$work/empty.md"
check_template "$work/empty.md" >/dev/null
[ "$?" = "2" ] && pass "an empty template REFUSES (exit 2), never passes" \
  || die "an empty template did not refuse"

# --- The real shipped template ----------------------------------------------------------------

if out="$(check_template "$TEMPLATE")"; then
  pass "shipped template/changes/PROPOSAL_TEMPLATE.md carries the staging step and the prohibition"
else
  rc=$?
  if [ "$rc" = "2" ]; then
    die "shipped proposal template REFUSED: $out"
  else
    die "shipped proposal template has findings:"
    echo "$out"
  fi
fi

if [ "$fail" -eq 0 ]; then echo "test_proposal_template_staging: OK"; else
  echo "test_proposal_template_staging: FAIL"; exit 1; fi
