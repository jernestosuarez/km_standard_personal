#!/bin/bash
# Canaries for template/hub-scan.sh (v1.30; [ QUEUE ] added v1.31) — the session-start integrity
# and governance scan.
#
# WHY THIS FILE EXISTS
#
# Almost every block in hub-scan.sh reports a defect by FINDING something, so a clean hub and a
# broken check produce the same output: a line beginning "OK". Eleven blocks reported by absence
# with nothing anywhere proving they can fire — INBOX, PROPOSALS, INTEGRITY, READABILITY,
# FRONTMATTER, FRESHNESS, LINKS, SHAPE, CURRENCY, RECONCILIATION, and the AGENT false-dispatch walk.
# The scan is the standard's enforced session-start entry point and it is inherited by every hub, so
# a block that has silently stopped firing produces a green estate that means nothing, in every hub
# at once, with no symptom to notice.
#
# LINKS is proven first and deliberately: it decides graph-edge integrity for every hub, its failure
# mode is a dangling edge that "fails silently — the note still renders, the scan still passes, and
# the fact is simply unreachable" (STANDARD.md §"Validating the graph"), and its own matching
# (`grep -qxF` against an index of note stems, inside a subshell whose counters do not survive) has
# exactly the shape that produced the v1.29 false pass in another instrument.
#
# HOW EACH CASE WORKS
#
# One clean fixture hub is built from template/ and proven green. Every case then copies it, injects
# ONE known violation, commits that injection (so the INTEGRITY block does not fire on it and mask
# the case), re-runs the scan, and requires both the naming line and the exit class. The clean
# fixture is re-asserted at the end, so a case that leaked state into it cannot hide.
#
# WHAT A CANARY CANNOT DO — the stated limit, and it is not a small one
#
# These cases prove each block fires on the violation class it MODELS. They cannot prove the block
# models the right class, and they are blind to a check whose gap is structural rather than a
# matching bug. The demonstrated example, from a deployment: a hub's manifest was missing a row
# for a governed file, and no hub-scan run could ever have caught it, because INTEGRITY is
# git-backed — it compares the working tree against committed history, so a file absent from a
# hand-maintained manifest is INVISIBLE to it rather than flagged. No canary of INTEGRITY finds
# that, because the check is working exactly as written; the evidence it consults simply cannot
# represent the defect. Proving both directions closes the "the check stopped firing" failure. It
# says nothing about "the check never looked here", which is answered by naming each block's
# coverage, not by testing it.
#
# [ QUEUE ] (v1.31) is the twelfth block and the only conditional one: it runs when the hub carries
# its own owner queue, which is the single-hub deployment shape. Its cases therefore also assert
# that it stays SILENT in a hub with no queue, and that its verdict matches `km-cockpit.py
# queue-check` on the same file — two implementations of one rule, and nothing else holding them
# together.
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/template"

work="$(mktemp -d "${TMPDIR:-/tmp}/km-hubscan-canary.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

[ -d "$TEMPLATE" ] || { echo "FAIL: template not found at $TEMPLATE"; exit 1; }

TODAY="$(date +%Y-%m-%d)"
REV="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Commit inside a fixture hub. Fails closed on a path that is empty or outside the scratch tree:
# `git -C ""` silently operates on the current directory, and a test harness that stages -A there
# commits the maintainer's own uncommitted work under a fixture's message. That happened once while
# this file was being written, which is why the guard is here rather than in a comment.
git_commit() {
  local hub="$1"
  case "$hub" in
    "$work"/*) ;;
    *) echo "FAIL: git_commit refused: '$hub' is not inside the scratch tree $work" >&2; exit 1 ;;
  esac
  [ -d "$hub/.git" ] || { echo "FAIL: git_commit refused: $hub is not a git repository" >&2; exit 1; }
  git -C "$hub" add -A
  git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
    commit -qm "${2:-fixture}"
}

# Build the clean reference hub once. Placeholder dates are stamped with TODAY rather than a fixed
# date on purpose: a fixture carrying a hardcoded last-reviewed turns amber on its own after
# STALE_DAYS and teaches whoever hits it that the suite is unreliable.
build_clean() {
  local hub="$work/clean"
  mkdir -p "$hub"
  cp -R "$TEMPLATE/." "$hub/"
  while IFS= read -r f; do
    sed -i.bak \
      -e "s|{{INIT_DATE}}|$TODAY|g" \
      -e 's|{{ROUTING_KEYWORDS}}|alpha, beta, gamma|g' \
      -e 's|{{KM_STANDARD_VERSION}}|1.30|g' \
      -e "s|{{KM_STANDARD_REVISION}}|$REV|g" \
      -e 's|{{KM_STANDARD_SOURCE}}|https://example.invalid/km-standard.git|g' \
      -e 's|{{PROJECT_NAME}}|Sample Initiative|g' \
      "$f"
    rm -f "$f.bak"
  done < <(find "$hub" -type f)

  # Two real entity notes, so LINKS and SHAPE have a graph to be right about. Without them both
  # blocks report "nothing to check" and their OK line proves nothing at all.
  cat > "$hub/stakeholders/jordan-avery.md" <<EOF
---
type: Stakeholder
title: Jordan Avery
role: Programme lead
organisation: Sample Organisation
involvement: core
tags: [stakeholder]
resource: sources/transcript-index.md
last-reviewed: $TODAY
lifecycle: active
---

Synthetic fixture person.
EOF
  cat > "$hub/decisions/dec-001-scope.md" <<EOF
---
type: Decision
title: Adopt the sample scope
decidedBy: "[[jordan-avery]]"
date: $TODAY
status: settled
tags: [decision]
resource: sources/transcript-index.md
last-reviewed: $TODAY
lifecycle: active
---

Synthetic fixture decision.
EOF
  git -C "$hub" init -q
  git_commit "$hub" 'init: canary fixture hub'
}

# Copy the proven-clean hub, including its git history, so every case starts from a green scan.
# All arguments to `local` are expanded before any of them is assigned, so a second variable
# referring to the first is unbound. Two statements, deliberately.
fork() {
  local name="$1"
  local hub="$work/$name"
  cp -R "$work/clean" "$hub"
  printf '%s' "$hub"
}

# Run the scan. Sets $out and $st. Status is captured directly, never through a pipe, because a
# pipeline's exit status is the last command's and not the scan's.
scan() {
  out="$(bash "$1/hub-scan.sh" 2>&1)"
  st=$?
}

# Assert a block's line and the exit class in one place, so no case can assert only half of it.
expect() {
  local name="$1" hub="$2" want_status="$3" want_text="$4"
  scan "$hub"
  if [ "$st" -ne "$want_status" ]; then
    die "$name: exit $st, expected $want_status"$'\n'"$out"
    return
  fi
  # `--` matters: an expected line beginning with "- " is read as an option otherwise, and grep's
  # usage error would be indistinguishable from the scan not reporting the line.
  if ! printf '%s\n' "$out" | grep -Fq -- "$want_text"; then
    die "$name: scan did not report: $want_text"$'\n'"$out"
    return
  fi
  pass "$name"
}

build_clean

# --- 0. the positive direction: a clean hub is green, and every block says so --------------------
scan "$work/clean"
if [ "$st" -ne 0 ]; then
  die "0. the clean fixture does not scan green — every case below starts from a broken baseline"$'\n'"$out"
else
  missing=""
  for block in \
    '[ INBOX ]' '[ PROPOSALS ]' '[ INTEGRITY ]' '[ READABILITY ]' '[ FRONTMATTER ]' \
    '[ FRESHNESS ]' '[ LINKS ]' '[ SHAPE ]' '[ CURRENCY ]' '[ RECONCILIATION ]' '[ AGENT ]'; do
    printf '%s\n' "$out" | grep -Fq "$block" || missing="$missing $block"
  done
  if [ -n "$missing" ]; then
    die "0. blocks absent from the scan output:$missing"
  elif printf '%s\n' "$out" | grep -Fq '=== OK — clean ==='; then
    pass "0. a clean fixture hub scans green and prints all eleven blocks"
  else
    die "0. clean fixture did not print the clean verdict"$'\n'"$out"
  fi
fi

# --- 1. [ LINKS ] — first, because it decides graph-edge integrity for every hub -----------------
hub="$(fork links_dangling)"
sed -i.bak 's|\[\[jordan-avery\]\]|[[jordan-averyy]]|' "$hub/decisions/dec-001-scope.md"
rm -f "$hub/decisions/dec-001-scope.md.bak"
git_commit "$hub" 'inject: dangling frontmatter wiki-link'
expect "1a. [ LINKS ] catches a dangling frontmatter wiki-link (error, exit 1)" \
  "$hub" 1 'UNRESOLVED LINK [[jordan-averyy]] in decisions/dec-001-scope.md'

# The edge that resolves must NOT be reported, or the block is matching everything and its firing
# proves nothing. Asserted on the clean fixture's own output, captured above.
hub="$(fork links_ok)"
scan "$hub"
if [ "$st" -eq 0 ] \
   && printf '%s\n' "$out" | grep -Eq 'OK — [1-9][0-9]* frontmatter wiki-link\(s\) resolve against [1-9][0-9]* indexed note name'; then
  pass "1b. [ LINKS ] passes an edge that genuinely resolves, and names its coverage"
else
  die "1b. [ LINKS ] did not pass a resolving edge: exit $st"$'\n'"$out"
fi

# A link inside an unfilled template placeholder must stay skipped, or every scaffolded hub is red
# on its first run and the block gets switched off before it ever catches a real dangling edge.
hub="$(fork links_placeholder)"
cat > "$hub/risks/TEMPLATE-like.md" <<EOF
---
type: Risk
title: Sample risk
owner: "[[<stakeholder-note-name>]]"
status: open
impact: low
last-reviewed: $TODAY
lifecycle: active
---
EOF
git_commit "$hub" 'inject: unfilled placeholder link'
scan "$hub"
if [ "$st" -eq 0 ] && ! printf '%s\n' "$out" | grep -Fq 'UNRESOLVED LINK'; then
  pass "1c. [ LINKS ] skips an unfilled template placeholder link"
else
  die "1c. [ LINKS ] fired on a template placeholder: exit $st"$'\n'"$out"
fi

# --- 2. [ SHAPE ] ---------------------------------------------------------------------------------
hub="$(fork shape)"
sed -i.bak '/^decidedBy:/d' "$hub/decisions/dec-001-scope.md"
rm -f "$hub/decisions/dec-001-scope.md.bak"
git_commit "$hub" 'inject: Decision missing decidedBy'
expect "2. [ SHAPE ] catches an entity note missing a required field (error, exit 1)" \
  "$hub" 1 "Decision missing required 'decidedBy': decisions/dec-001-scope.md"

# --- 3. [ FRONTMATTER ] ---------------------------------------------------------------------------
hub="$(fork frontmatter_missing)"
printf '# A hub document with no frontmatter at all\n' > "$hub/08_unmarked.md"
git_commit "$hub" 'inject: monitored doc with no frontmatter'
expect "3a. [ FRONTMATTER ] catches a monitored document with no frontmatter (error, exit 1)" \
  "$hub" 1 'MISSING FRONTMATTER: 08_unmarked.md'

hub="$(fork frontmatter_notype)"
printf -- '---\ntitle: No type declared\nlifecycle: active\n---\n\nBody.\n' > "$hub/09_untyped.md"
git_commit "$hub" 'inject: frontmatter without type'
expect "3b. [ FRONTMATTER ] catches frontmatter carrying no type: (error, exit 1)" \
  "$hub" 1 'MISSING type: 09_untyped.md'

# --- 4. [ INTEGRITY ] -----------------------------------------------------------------------------
hub="$(fork integrity_dirty)"
printf '\nAn edit made outside the proposal workflow.\n' >> "$hub/01_project-brief.md"
expect "4a. [ INTEGRITY ] catches an uncommitted edit to a monitored file (error, exit 1)" \
  "$hub" 1 'UNCOMMITTED OR UNTRACKED MONITORED FILES'

hub="$(fork integrity_untracked)"
printf -- '---\ntype: brief\nlifecycle: active\n---\n\nNew.\n' > "$hub/10_untracked.md"
expect "4b. [ INTEGRITY ] catches an untracked monitored file (error, exit 1)" \
  "$hub" 1 '10_untracked.md'

# --- 5. [ READABILITY ] ---------------------------------------------------------------------------
# A file with bytes on disk whose read returns nothing. The real condition is a cloud on-demand
# placeholder, which cannot be created here; an unreadable mode reproduces the same observable
# (size > 0, read yields nothing) and exercises the same branch. Stated limit, not a claim to have
# reproduced Files-On-Demand. Skipped when running as root, for whom no file is unreadable.
if [ "$(id -u)" -eq 0 ]; then
  echo "SKIP: 5. [ READABILITY ] canary needs a non-root user"
else
  hub="$(fork readability)"
  chmod 000 "$hub/07_glossary.md"
  scan "$hub"
  chmod 644 "$hub/07_glossary.md"
  # The exit class is deliberately not asserted here. An unreadable-mode file also makes `git
  # status` report the path as modified, so the run exits 1 through INTEGRITY — an artefact of the
  # proxy, not of the block under test. What is asserted is the READABILITY block's own contract:
  # advisory wording, a stated coverage gap, and no false MISSING FRONTMATTER for the same file,
  # which is the exact collapse that produced eleven false errors across six hubs in one estate.
  if printf '%s\n' "$out" | grep -Fq 'UNREADABLE (not downloaded?): 07_glossary.md' \
     && printf '%s\n' "$out" | grep -Fq 'COVERAGE:' \
     && ! printf '%s\n' "$out" | grep -Fq 'MISSING FRONTMATTER: 07_glossary.md'; then
    pass "5. [ READABILITY ] reports an unreadable file as an advisory, states the coverage gap, and does not mis-report it as missing frontmatter"
  else
    die "5. [ READABILITY ] canary failed (exit $st)"$'\n'"$out"
  fi
fi

# --- 6. [ FRESHNESS ] -----------------------------------------------------------------------------
hub="$(fork freshness_stale)"
old="$(date -v-400d +%Y-%m-%d 2>/dev/null || date -d '400 days ago' +%Y-%m-%d)"
sed -i.bak "s|^last-reviewed: .*|last-reviewed: $old|" "$hub/stakeholders/jordan-avery.md"
rm -f "$hub/stakeholders/jordan-avery.md.bak"
git_commit "$hub" 'inject: stale last-reviewed'
expect "6a. [ FRESHNESS ] catches a note past the staleness threshold (advisory, exit 0)" \
  "$hub" 0 'STALE'

hub="$(fork freshness_unparseable)"
sed -i.bak 's|^last-reviewed: .*|last-reviewed: sometime last spring|' "$hub/stakeholders/jordan-avery.md"
rm -f "$hub/stakeholders/jordan-avery.md.bak"
git_commit "$hub" 'inject: unparseable last-reviewed'
expect "6b. [ FRESHNESS ] catches an unparseable last-reviewed (error, exit 1)" \
  "$hub" 1 'UNPARSEABLE last-reviewed (sometime last spring): stakeholders/jordan-avery.md'

# --- 7. [ CURRENCY ] ------------------------------------------------------------------------------
hub="$(fork currency)"
mkdir -p "$hub/working-docs/memos"
printf -- '---\ntype: brief\ntitle: Unmarked memo\n---\n\nA generated document with no lifecycle.\n' \
  > "$hub/working-docs/memos/2026-08-19_unmarked-memo.md"
git_commit "$hub" 'inject: generated doc with no lifecycle'
expect "7. [ CURRENCY ] catches a generated document carrying no lifecycle: (advisory, exit 0)" \
  "$hub" 0 'no lifecycle: working-docs/memos/2026-08-19_unmarked-memo.md'

# --- 8. [ INBOX ] ---------------------------------------------------------------------------------
hub="$(fork inbox)"
printf 'A file dropped for processing.\n' > "$hub/_inbox/2026-08-19_partner-deck-digest.md"
git_commit "$hub" 'inject: pending inbox file'
expect "8. [ INBOX ] lists a file pending processing (advisory, exit 0)" \
  "$hub" 0 '- 2026-08-19_partner-deck-digest.md'

# --- 9. [ PROPOSALS ] -----------------------------------------------------------------------------
hub="$(fork proposals_awaiting)"
printf '# Proposal\n' > "$hub/changes/2026-08-19_ja_sample-change_proposal.md"
git_commit "$hub" 'inject: proposal without approval'
expect "9a. [ PROPOSALS ] reports a proposal awaiting approval (advisory, exit 0)" \
  "$hub" 0 'AWAITING APPROVAL: 2026-08-19_ja_sample-change_proposal.md'

hub="$(fork proposals_ready)"
printf '# Proposal\n' > "$hub/changes/2026-08-19_ja_sample-change_proposal.md"
printf '# Approval\n' > "$hub/changes/2026-08-19_sample-change_approval.md"
git_commit "$hub" 'inject: proposal with matching approval'
expect "9b. [ PROPOSALS ] reports a proposal ready to apply (advisory, exit 0)" \
  "$hub" 0 'READY TO APPLY: 2026-08-19_ja_sample-change_proposal.md'

# --- 10. [ RECONCILIATION ] -----------------------------------------------------------------------
hub="$(fork reconciliation_owner)"
mkdir -p "$hub/reconciliation/_disputes"
printf '# Dispute\n\n**Blocked on:** Hub Owner\n' \
  > "$hub/reconciliation/_disputes/2026-08-19_timeline_dispute.md"
git_commit "$hub" 'inject: dispute blocked on the hub owner'
expect "10a. [ RECONCILIATION ] reports a dispute blocked on the hub owner (advisory, exit 0)" \
  "$hub" 0 '2026-08-19_timeline_dispute.md (blocked on: Hub Owner, decision required)'

hub="$(fork reconciliation_counterpart)"
mkdir -p "$hub/reconciliation/_disputes"
printf '# Dispute\n\n**Blocked on:** the counterpart organisation\n' \
  > "$hub/reconciliation/_disputes/2026-08-19_partner_dispute.md"
git_commit "$hub" 'inject: dispute blocked on a counterpart'
expect "10b. [ RECONCILIATION ] does not assert a hub-owner action for a dispute blocked elsewhere" \
  "$hub" 0 '(blocked on: the counterpart organisation, no hub-owner action)'

hub="$(fork reconciliation_unstated)"
mkdir -p "$hub/reconciliation/_disputes"
printf '# Dispute\n\nNo blocker line at all.\n' \
  > "$hub/reconciliation/_disputes/2026-08-19_scope_dispute.md"
git_commit "$hub" 'inject: dispute with no blocker stated'
expect "10c. [ RECONCILIATION ] reports an unstated blocker as unstated, never as the owner" \
  "$hub" 0 '(blocked-on not stated or file unreadable)'

# --- 11. [ AGENT ] — the false-dispatch walk ------------------------------------------------------
hub="$(fork agent_false_dispatch)"
mkdir -p "$hub/.claude/agents"
printf -- '---\nname: km-sample-initiative\nkm_tier: hub\nscope_enforcement: convention\n---\n\nPointer.\n' \
  > "$hub/.claude/agents/km-sample-initiative.md"
git_commit "$hub" 'chore: mint the hub agent definition'
printf '\nA later edit.\n' >> "$hub/01_project-brief.md"
git -C "$hub" add -A
git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
  commit -qm 'apply: sample change

KM-Agent: km-supervisor
Dispatched-By: km-supervisor'
expect "11a. [ AGENT ] catches a Dispatched-By trailer whose KM-Agent is not this hub's agent (advisory, exit 0)" \
  "$hub" 0 'FALSE DISPATCH CLAIM'

# A genuine dispatch — the hub's own agent authored it — must NOT be reported, or the check is
# flagging every dispatched commit and its firing means nothing.
hub="$(fork agent_true_dispatch)"
mkdir -p "$hub/.claude/agents"
printf -- '---\nname: km-sample-initiative\nkm_tier: hub\nscope_enforcement: convention\n---\n\nPointer.\n' \
  > "$hub/.claude/agents/km-sample-initiative.md"
git_commit "$hub" 'chore: mint the hub agent definition'
printf '\nA later edit.\n' >> "$hub/01_project-brief.md"
git -C "$hub" add -A
git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
  commit -qm 'apply: sample change

KM-Agent: km-sample-initiative
Dispatched-By: km-supervisor'
scan "$hub"
if [ "$st" -eq 0 ] && ! printf '%s\n' "$out" | grep -Fq 'FALSE DISPATCH CLAIM'; then
  pass "11b. [ AGENT ] does not flag a dispatch the hub's own agent genuinely authored"
else
  die "11b. [ AGENT ] flagged a legitimate dispatch: exit $st"$'\n'"$out"
fi

# --- 12. [ QUEUE ] — the row a decision surface cannot read (added v1.31) -------------------------
#
# The block is conditional: it runs only in a single-hub deployment, where the owner queue lives at
# the hub root. Its violation class is a tier-A/B row whose declared options no decision surface can
# read, which renders as a complete-looking card with an empty action bar — a false pass on the one
# surface where the owner acts. Both directions are asserted, plus the case that matters most for a
# check inherited by every hub: the block must stay SILENT in a hub that carries no queue.
queue_fixture() {   # $1 = hub, $2... = extra rows
  local hub="$1"; shift
  {
    # Frontmatter and lifecycle so [ FRONTMATTER ] and [ CURRENCY ] stay quiet: this case is
    # about [ QUEUE ] and nothing else, and a fixture that trips two other blocks would let a
    # dead [ QUEUE ] block pass on somebody else's error.
    printf -- '---\ntype: index\ntitle: Owner Queue\ntags: [owner-queue]\nlifecycle: active\n---\n\n'
    printf '# Owner Queue\n\n| Id | Since | Defaults | Decision | Options |\n|---|---|---|---|---|\n'
    printf '| a1 | 08-19 | - | **A readable row.** Context. | "approve", "veto" |\n'
    printf '%s\n' "$@"
  } > "$hub/QUEUE.md"
  git_commit "$hub" 'inject: owner queue'
}

hub="$(fork queue_unreadable)"
queue_fixture "$hub" '| a2 | 08-19 | - | **Options written as prose.** Context. | approve or hold, your call |'
expect "12a. [ QUEUE ] catches a row whose declared options cannot be read (error, exit 1)" \
  "$hub" 1 'UNANSWERABLE ROW: a2'

hub="$(fork queue_none_declared)"
queue_fixture "$hub" '| a3 | 08-19 | - | **No options at all.** Context. |  |'
expect "12b. [ QUEUE ] catches a tier-A row that declares no options (error, exit 1)" \
  "$hub" 1 'declares no answer options'

hub="$(fork queue_clean)"
queue_fixture "$hub" \
  '| a4 | 08-19 | - | **Legacy bold form.** Context. | **"approve"** first · **"hold"** stops it |' \
  '| b1 | 08-19 | 08-26 | **Tier B, specific verb first.** Context. | "publish it", "veto" |' \
  '```' \
  '| a9 | 08-19 | - | **A worked example.** Fenced, so documentation. | "approve", "veto" |' \
  '```'
scan "$hub"
if [ "$st" -eq 0 ] \
   && printf '%s\n' "$out" | grep -Eq 'OK — [1-9][0-9]* tier-A/B rows read \([1-9][0-9]* lines\)' \
   && ! printf '%s\n' "$out" | grep -Fq 'UNANSWERABLE ROW'; then
  pass "12c. [ QUEUE ] passes readable rows in every accepted form, and names its coverage"
else
  die "12c. [ QUEUE ] fired on a readable queue: exit $st"$'\n'"$out"
fi

# A fenced example row is documentation. If the block read it as a row, every deployment copying
# the template's worked examples would be red on day one and would delete the examples.
printf '%s\n' "$out" | grep -Fq 'UNANSWERABLE ROW: a9' \
  && die "12d. [ QUEUE ] read a fenced example row as a live row" \
  || pass "12d. [ QUEUE ] treats a fenced example row as documentation"

# A hub with no queue of its own (the multi-hub case: the queue lives at the Supervisor tier).
scan "$work/clean"
if ! printf '%s\n' "$out" | grep -Fq '[ QUEUE ]'; then
  pass "12e. [ QUEUE ] stays silent in a hub that carries no queue"
else
  die "12e. [ QUEUE ] fired in a hub with no QUEUE.md"$'\n'"$out"
fi

# The scan and the decision surface must return the SAME verdict on the same file, or a queue can
# be green in the session and empty on the owner's screen. Two implementations, one rule: this is
# the only thing holding them together.
cockpit="$ROOT/components/km-cockpit/km-cockpit.py"
if [ -f "$cockpit" ]; then
  python3 "$cockpit" queue-check "$work/queue_unreadable/QUEUE.md" >/dev/null 2>&1
  cock_bad=$?
  python3 "$cockpit" queue-check "$work/queue_clean/QUEUE.md" >/dev/null 2>&1
  cock_ok=$?
  if [ "$cock_bad" -eq 1 ] && [ "$cock_ok" -eq 0 ]; then
    pass "12f. km-cockpit.py queue-check agrees with [ QUEUE ] on both fixtures"
  else
    die "12f. the two instruments disagree: cockpit said $cock_bad on the bad queue, $cock_ok on the clean one"
  fi
else
  die "12f. km-cockpit.py not found — the cross-check did not run (coverage gap, not a pass)"
fi

# --- the fixture is still clean ------------------------------------------------------------------
# A case that mutated the shared fixture instead of its own copy would otherwise pass here and
# silently weaken every case above it.
scan "$work/clean"
if [ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -Fq '=== OK — clean ==='; then
  pass "13. the reference fixture is still green after every case (no case leaked into it)"
else
  die "13. the reference fixture is no longer green — a case mutated the shared hub: exit $st"$'\n'"$out"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "hub-scan canaries: all cases passed"
  exit 0
fi
echo "hub-scan canaries: FAILURES above"
exit 1
