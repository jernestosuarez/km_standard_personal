#!/bin/bash
# handover-hooks.sh — the WRITE side of the hub handover (v1.18).
#
# The read side (v1.17) is enforced at session START: hub-scan.sh surfaces HANDOVER.md first, ahead
# of every other section, so a resuming agent reads the curated record before reconstructing state.
# This is its mirror at session END. The handover is a JUDGMENT-layer artifact — only the model can
# write it — so this uses the Stop hook, the one lever that can block a session from ending and hand
# the model an actionable instruction, to force a refresh before the session's context is lost.
#
# Two subcommands, wired in .claude/settings.json:
#   baseline   SessionStart hook — record HEAD at session start, per session_id, so the Stop hook can
#              tell what THIS session changed.
#   check      Stop hook — if the session landed commits but did not touch HANDOVER.md, block ONCE and
#              instruct the model to refresh it with /km-handover. Guarded against loops.
#
# There is deliberately NO SessionEnd hook. The supervisor tier regenerates a deterministic STATE.md
# out-of-band on SessionEnd; a hub has no STATE.md equivalent. The one candidate, build-indexes.sh,
# writes MONITORED files (decisions/index.md and its siblings) that must be committed through the
# governed proposal/apply flow — regenerating them detached at session end would leave uncommitted
# monitored changes that hub-scan.sh's [INTEGRITY] check flags on the next session, fighting Rule 3.
# build-indexes.sh already runs at apply time, exactly when an entity note changes. There is no
# suitable deterministic hub artifact for a background regeneration, so this hook is omitted, not
# invented.
#
# Design limits (honest): Stop fires at every turn end, not a true "session end" (no such signal
# exists), so this GUARANTEES one handover refresh per working session, not that the handover is the
# session's final word. /clear does not fire Stop at all. The read side and the periodic hygiene pass
# are the backstop for both. Tune the heuristic here, never by weakening the read side.

set -euo pipefail
HUB="$(cd "$(dirname "$0")" && pwd)"
TMP="${TMPDIR:-/tmp}"
mode="${1:-}"

read_input() { cat; }
sid_of() { printf '%s' "$1" | jq -r '.session_id // "nosession"' 2>/dev/null || echo "nosession"; }

case "$mode" in
  baseline)
    input="$(read_input)"; sid="$(sid_of "$input")"
    head="$(cd "$HUB" && git rev-parse HEAD 2>/dev/null || true)"
    [ -n "$head" ] && printf '%s' "$head" > "$TMP/km-hov-base-$sid"
    rm -f "$TMP/km-hov-nudge-$sid"   # fresh session, re-arm the one-shot nudge
    exit 0
    ;;

  check)
    input="$(read_input)"; sid="$(sid_of "$input")"
    # loop guard 1: if this stop is itself the continuation of a stop-hook block, never re-block.
    active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null || echo false)"
    [ "$active" = "true" ] && exit 0
    nudge="$TMP/km-hov-nudge-$sid"
    base="$TMP/km-hov-base-$sid"
    # loop guard 2: block at most once per session.
    [ -f "$nudge" ] && exit 0
    # can't judge without a session baseline → do nothing.
    [ -f "$base" ] || exit 0
    start="$(cat "$base")"
    head="$(cd "$HUB" && git rev-parse HEAD 2>/dev/null || true)"
    [ -n "$head" ] || exit 0
    # Substantive work = COMMITS landed this session. Uncommitted/untracked files are hub-scan.sh's
    # [INTEGRITY] concern, not the handover's — counting them would false-positive on stray scratch.
    [ "$start" = "$head" ] && exit 0
    # did those commits touch HANDOVER.md? (in-range, or the handover is staged/dirty right now)
    touched=0
    (cd "$HUB" && git diff --name-only "$start" "$head" 2>/dev/null) | grep -qx "HANDOVER.md" && touched=1
    (cd "$HUB" && git status --short 2>/dev/null) | grep -qE '(^|[[:space:]])HANDOVER\.md$' && touched=1
    [ "$touched" = "1" ] && exit 0
    # substantive work, handover untouched → block once.
    touch "$nudge"
    jq -n '{
      decision: "block",
      reason: "SESSION-END HANDOVER CHECK (hub write-side hook): this session landed commits that changed hub state but HANDOVER.md was not updated. Before you stop, refresh it so the next session inherits the intended state, not one inferred from the git log: run /km-handover to rewrite section 5 (Current state & open items) with what actually changed this session — what was done, any open items or proposals awaiting approval, and the next steps for the next agent — then commit HANDOVER.md. If nothing meaningful changed and the handover genuinely needs no update, say so in one line and stop; this check will not fire again this session."
    }'
    exit 0
    ;;

  *)
    echo "usage: handover-hooks.sh {baseline|check}" >&2
    exit 2
    ;;
esac
