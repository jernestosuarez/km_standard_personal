#!/bin/bash
# hub-scan.sh — Hub Integrity & Governance Scan
# Run from any directory: bash /path/to/hub-scan.sh
#
# Every check here is deterministic. No LLM judgement, no network. A check that
# needs an agent to interpret it is not a check — it is a suggestion.

HUB="$(cd "$(dirname "$0")" && pwd)"

# Entity folders that hold one note per instance. Keep in sync with STANDARD.md.
ENTITY_DIRS="decisions risks stakeholders milestones partners relationships corrections claims"

# Staleness threshold in days. Override per hub in 07_glossary.md and change here to match.
STALE_DAYS=${STALE_DAYS:-90}

# Exit status. A check that cannot fail is not a check — nothing can gate on it.
#
#   ERROR    (exit 1) — the hub is structurally broken: a dangling edge, a missing required field,
#                       missing frontmatter, an uncommitted monitored file. These are defects.
#   ADVISORY (exit 0) — the hub is intact and something needs a human: pending inbox, an open
#                       proposal, an active dispute, a stale note. These are prompts, not breaks.
#
# The distinction matters because a gate that fires on prompts gets switched off, and takes the
# real checks with it.
errors=0
advisories=0
err()  { errors=$((errors + 1)); }
adv()  { advisories=$((advisories + 1)); }

echo "=== Hub Scan — $(date '+%Y-%m-%d %H:%M') ==="
echo

# HANDOVER is surfaced first, before any other section, so a resuming session reads the curated
# home of record before reconstructing state from the git log or a diff. A missing HANDOVER.md is a
# defect, not a prompt: the required scaffold file is gone, so it is an ERROR (see the exit-status
# note above), the same rank as missing frontmatter.
echo "[ HANDOVER ]"
if [ -f "$HUB/HANDOVER.md" ]; then
  echo "  READ HANDOVER.md FIRST — before any state reconstruction from the git log or a diff (no exceptions):"
  echo "  → HANDOVER.md ($(grep -m1 '^# ' "$HUB/HANDOVER.md" | sed 's/^# //'))"
else
  echo "  ERROR — HANDOVER.md missing; regenerate via /km-handover before continuing"
  err
fi
echo

# In a multi-hub estate (workspace root also contains _KM_Supervisor/), the estate corrections
# registry binds every hub session: each lifecycle: active note there carries a rule: in force here,
# inherited by reference and never copied down (PROTOCOL.md §Self-improvement loop). Skipped silently
# in a single-hub deployment.
#
# THE COUNT IS OF RULES IN FORCE, NOT OF CURRENT DOCUMENTS (corrected in v1.57, drafted and
# unpublished: this correction binds nothing until its own owner push). `lifecycle:`
# records whether a DOCUMENT is current; it does not make a note a binding rule. `rule:` is what
# does — STANDARD.md §"`rule:` is the whole point": a correction that produces no rule is probably
# an ordinary edit and not a Correction at all. The v1.19 section that introduced this block
# already specified the count as the active notes "whose rule: is in force", and the predicate
# implemented here read `lifecycle: active` alone, so the registry's own README.md (a reference
# document, current, carrying no rule) was counted as a rule that binds — and every scaffold
# document ever added to the directory reproduced it, the count drifting by one more each time.
# Three arms, all of which must hold, and the printed line below states them rather than a wider
# claim: the file is not scaffold, it carries a `rule:`, and it is `lifecycle: active`.
# Scaffold is the standard's own set (README.md, TEMPLATE.md, hub-manifest.md — §"Currency of
# generated documents") plus a generated index.md, which carries `lifecycle: active` by
# construction since v1.15 and is therefore the second shape that reads as current without ever
# asserting anything. A loop rather than a pipeline: hub and estate paths contain spaces, and an
# xargs formulation returns 0 on such a path without saying so.
# STATED LIMIT: a DERIVED artifact of this registry — a generated digest of the rules — that
# rendered `rule:` and `lifecycle: active` at column zero would be counted, because nothing in the
# evidence distinguishes it from a note. No name pattern for such an artifact is written here: the
# standard defines none, and a filename list beside a check is a hand-maintained memory of one
# deployment's directory. The repair for that case belongs in the generator, or in naming the
# artifact under the scaffold set above.
_estate_corr="$(cd "$HUB/.." 2>/dev/null && pwd)/_KM_Supervisor/corrections"
if [ -d "$_estate_corr" ]; then
  echo "[ CORRECTIONS ]"
  _nactive=0
  for _f in "$_estate_corr"/*.md; do
    [ -f "$_f" ] || continue
    case "$(basename "$_f")" in README.md|TEMPLATE.md|hub-manifest.md|index.md) continue ;; esac
    grep -q '^rule:' "$_f" 2>/dev/null || continue
    grep -q '^lifecycle: active' "$_f" 2>/dev/null || continue
    _nactive=$((_nactive + 1))
  done
  echo "  ESTATE RULES BIND — read ../_KM_Supervisor/corrections/ (${_nactive} active rule(s)) at session start;"
  echo "  counted: notes that are not scaffold, carry a rule:, and are lifecycle: active — each is in force in this hub"
  echo
fi

echo "[ INBOX ]"
pending=$(find "$HUB/_inbox" -maxdepth 1 -type f ! -name 'README.md' ! -name '.DS_Store' 2>/dev/null | sort)
if [ -z "$pending" ]; then
  echo "  OK — empty"
else
  echo "  Files pending processing:"
  while IFS= read -r f; do echo "  - $(basename "$f")"; adv; done <<< "$pending"
fi
echo

echo "[ PROPOSALS ]"
proposals=$(find "$HUB/changes" -maxdepth 1 -name '*_proposal.md' ! -name 'PROPOSAL_TEMPLATE.md' 2>/dev/null | sort)
approvals=$(find "$HUB/changes" -maxdepth 1 -name '*_approval.md' ! -name 'APPROVAL_TEMPLATE.md' 2>/dev/null | sort)
if [ -z "$proposals" ]; then
  echo "  OK — no pending proposals"
else
  while IFS= read -r p; do
    pbase=$(basename "$p")
    slug=$(echo "$pbase" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}_[A-Za-z]+_//; s/_proposal\.md$//')
    match=$(echo "$approvals" | grep -F "$slug" || true)
    if [ -n "$match" ]; then
      echo "  READY TO APPLY: $pbase"; adv
    else
      echo "  AWAITING APPROVAL: $pbase"; adv
    fi
  done <<< "$proposals"
fi
echo

# [ QUEUE ] — only when this deployment carries its own owner queue at the hub root (single-hub
# mode; in a multi-hub estate the queue lives at the Supervisor tier and is checked there, by
# `km-cockpit.py queue-check`, which applies the identical rule).
#
# A tier-A/B row DECLARES its answer options in the last cell: exact quoted verbs, recommendation
# first. A row whose options cannot be read is an ERROR, not a silent absence: a decision surface
# reading that row renders a complete-looking card — title, tier badge, age — with an action bar
# containing nothing, so the owner opens the queue to answer and there is nothing to press, with
# no warning anywhere. That was found in front of a client mid-demonstration. The failure mode of
# this check is therefore the failure mode it exists to remove, which is why it is canaried in
# both directions in tests/test_hub_scan_canaries.sh.
if [ -f "$HUB/QUEUE.md" ]; then
  echo "[ QUEUE ]"
  queue_scan=$(awk '
    # Wrapped continuation lines are joined before parsing, exactly as the surface joins them.
    { line = $0
      if (held != "" && line ~ /^  / ) {
        t = line; sub(/^[ \t]+/, "", t)
        if (t !~ /^[-|#<]/) { held = held " " t; next }
      }
      if (held != "") { process(held) }
      held = line
    }
    END { if (held != "") process(held); printf "C\t%d\t%d\n", nrows, NR }

    function process(s,   t, id, tier, n, cells, i, opts) {
      t = s; sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
      if (t ~ /^```/) { fenced = !fenced; return }     # fenced rows are documentation
      if (fenced) return
      if (t !~ /^\|[ \t]*[ab][0-9]+[ \t]*\|/) return
      sub(/^\|/, "", t); sub(/\|$/, "", t)
      n = split(t, cells, "|")
      for (i = 1; i <= n; i++) { sub(/^[ \t]+/, "", cells[i]); sub(/[ \t]+$/, "", cells[i]) }
      id = cells[1]; tier = substr(id, 1, 1)
      nrows++
      # Same shape recognition as the surface: canonical 5-col (Defaults cell is "-" or a date),
      # then the legacy 4/3-col shapes, then the 2-col shape.
      opts = ""
      if (n >= 5 && (cells[2] == "-" || cells[2] ~ /^[0-9][0-9]-[0-9][0-9]$/ || cells[2] ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/)) {
        for (i = 5; i <= n; i++) opts = opts (opts == "" ? "" : " | ") cells[i]
      } else if (n >= 4) {
        for (i = 3; i <= n; i++) opts = opts (opts == "" ? "" : " | ") cells[i]
      } else if (n == 2) {
        opts = (tier == "b") ? "**\"apply\"** **\"veto\"**" : ""
      }
      if (readable(opts, tier)) return
      if (opts ~ /[A-Za-z]/)
        printf "E\t%s\tdeclares answer options this surface cannot read: %s\n", id, opts
      else
        printf "E\t%s\tdeclares no answer options (schema: Id | Since | Defaults | Decision | Options)\n", id
    }

    # Accepted forms, in the same order the surface tries them. No interval expressions: honoured by
    # some awks and ignored by others, and an ignored construct matches nothing, which is exactly
    # what a readable row also looks like. The quoted-label length bound is applied with length()
    # for the same reason.
    function readable(s, tier,   rest) {
      if (s ~ /\*\*"[^"]+"\*\*/) return 1
      rest = s
      while (match(rest, /"[A-Za-z][^"]*"/)) {
        if (RLENGTH <= 62) return 1
        rest = substr(rest, RSTART + RLENGTH)
      }
      if (s ~ /\*\*[A-Za-z][A-Za-z ,+-]*\*\*[ \t]*\(/) return 1
      if (tier == "b") {
        if (s ~ /^[ \t]*\*\*[A-Za-z][^*]*\*\*/) return 1   # legacy prose lead verb
        if (s !~ /[A-Za-z]/) return 1                      # declares nothing: apply/veto stands
      }
      return 0
    }
  ' "$HUB/QUEUE.md" 2>/dev/null)
  queue_cov=$(printf '%s\n' "$queue_scan" | awk -F'\t' '$1=="C"{print $2"\t"$3}')
  queue_rows=$(printf '%s' "$queue_cov" | cut -f1)
  queue_lines=$(printf '%s' "$queue_cov" | cut -f2)
  queue_bad=$(printf '%s\n' "$queue_scan" | awk -F'\t' '$1=="E"{print "  UNANSWERABLE ROW: "$2" — "$3}')
  if [ -z "$queue_cov" ] || { [ -s "$HUB/QUEUE.md" ] && [ "${queue_lines:-0}" -eq 0 ]; }; then
    # Never a pass: a queue with bytes on disk that yielded nothing was NOT checked, whether the
    # file could not be read or the check itself could not run. Advisory rather than error,
    # matching [ READABILITY ] below: size-on-disk with an empty read is the signature of cloud
    # on-demand storage, a condition of the storage and not of the hub. What matters is that this
    # branch cannot be mistaken for "OK".
    echo "  UNREADABLE — QUEUE.md has $( { stat -f%z "$HUB/QUEUE.md" 2>/dev/null || stat -c%s "$HUB/QUEUE.md" 2>/dev/null || echo '?'; } ) bytes on disk and yielded 0 lines; NOT CHECKED (coverage gap, not a clean queue)"
    adv
  elif [ -n "$queue_bad" ]; then
    echo "$queue_bad"
    echo "  Options are exact quoted verbs, recommendation first (bold is optional presentation)."
    while IFS= read -r _; do err; done <<< "$queue_bad"
  else
    echo "  OK — $queue_rows tier-A/B rows read ($queue_lines lines); every row's options are readable"
  fi
  echo
fi

echo "[ INTEGRITY ]"
if ! git -C "$HUB" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "  ERROR — hub is not a git repository. Run: git init && git add -A && git commit -m \"init: hub scaffold\""
  err
else
  # Denylist semantics: everything at the hub root is monitored EXCEPT the working areas below,
  # so a new top-level doc is caught automatically. Named files inside sources/ are re-included
  # because the provenance indexes are monitored even though their folder is not.
  #
  # A Python virtual environment is exempted (added in v1.51). It is generated runtime state, never
  # hub content, and before v1.51 nothing here mentioned it: the shared renderer built one at
  # tools/.venv, no ignore rule covered it, and this block therefore reported `?? tools/.venv/` and
  # called err, so a hub that rendered a single document FAILED its own session-start scan every
  # session afterwards and the remedy an operator reaches for is committing a virtual environment
  # into a governed hub. Audit finding F-10. The renderer now builds outside the tree and
  # template/.gitignore covers the in-tree case, so this exemption is the third layer, and it is the
  # one that reaches a hub created before v1.51 whose ignore file is a copy of the old one.
  #
  # The pathspec spelling is the one PROVED to exclude against the git that runs it, not the one
  # that reads best. Against a fixture hub carrying both tools/.venv/ and .venv/, ':(exclude)*/.venv'
  # and ':(exclude)*/.venv/' each excluded NOTHING while producing no error, the same
  # silent-inertness class the publish guard runner's boundary probe exists to catch, and it looks
  # exactly like a clean tree. ':(exclude,glob)**/.venv' with its ':(exclude,glob)**/.venv/**'
  # partner excluded both, at every depth including the root, and tests/test_km_publish_portability.sh
  # holds that pair to it in both directions.
  changes=$(
    git -C "$HUB" status --porcelain -- . \
      ':(exclude)_inbox' ':(exclude)changes' ':(exclude)working-docs' ':(exclude)shareable' \
      ':(exclude)sources' ':(exclude).claude' \
      ':(exclude,glob)**/.venv' ':(exclude,glob)**/.venv/**'
    git -C "$HUB" status --porcelain -- \
      sources.config.md sources/transcript-index.md sources/publication-log.md sources/dates-register.md
    # SourceSystem notes (Rule 6) are governed content inside the otherwise-unmonitored sources/,
    # like the named registers above. The pathspec matches nothing in a hub without the folder.
    [ -d "$HUB/sources/systems" ] && git -C "$HUB" status --porcelain -- sources/systems
  )
  if [ -z "$changes" ]; then
    echo "  OK — committed monitored state is clean"
  else
    echo "  ! UNCOMMITTED OR UNTRACKED MONITORED FILES:"
    echo "$changes" | sed 's/^/    /'
    err
  fi
fi
echo

# Build the monitored document list once — reused by FRONTMATTER, FRESHNESS, LINKS and SHAPE.
monitored_docs=$(
  find "$HUB" -maxdepth 1 -name '*.md' -type f 2>/dev/null
  for dir in sources sources/systems reconciliation $ENTITY_DIRS; do
    find "$HUB/$dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null
  done
)

# The extra documents that [ CURRENCY ] covers but the checks above do not.
#
# The currency scope test is the standard's own: did the file arrive from outside to inform the hub
# (evidence, immutable), or did the hub produce it (current until superseded)? Scoping the check to
# working-docs/ answers a different question, "where do drafts live", and gets it wrong: a hub can
# have an empty working-docs/ and dozens of unmarked generated documents in its entity folders,
# its reconciliation ledger and its numbered hub docs. Every monitored document above is
# hub-produced, so the currency scope is that set plus working-docs/ walked recursively.
#
# Deliberately out of scope, each for a reason and not by oversight:
#   sources/docs/  evidence, immutable by Rule 5, never marked superseded by newer information
#   _inbox/        arriving, not yet filed, and not yet anything the hub asserts
#   changes/       proposals and approvals carry their own governance lifecycle and are transient
#   archive/       already withdrawn from the live set (skip_doc excludes it everywhere)
#   shareable/     published copies whose currency is carried by sources/publication-log.md
#   scaffold       README.md, TEMPLATE.md and hub-manifest.md (skip_doc): see [ CURRENCY ]
currency_extra_docs=$(find "$HUB/working-docs" -name '*.md' -type f 2>/dev/null | sort)

# Read one frontmatter field. Frontmatter only — the body is not the graph.
# Strips inline YAML comments and surrounding quotes/whitespace, so a documented field
# (`last-reviewed: 2026-07-14  # last confirmed true`) still parses as a value.
fm_field() {
  awk -v k="$2" '
    /^---$/ { n++; if (n==2) exit; next }
    n==1 {
      if ($0 ~ "^" k ":") {
        sub("^" k ":[ ]*", "")
        sub(/[ \t]+#.*$/, "")          # drop inline comment
        gsub(/^[ \t]+|[ \t]+$/, "")    # trim
        gsub(/^"|"$/, "")              # unquote
        print; exit
      }
    }' "$1"
}
skip_doc() {
  case "$1" in */TEMPLATE.md|*/README.md|*/hub-manifest.md) return 0 ;; esac
  case "$1" in "$HUB"/archive/*) return 0 ;; esac
  return 1
}
# Exempt from [ CURRENCY ] only, on top of skip_doc. These four are the machinery a hub runs on,
# not documents it produced: configuration and agent instructions. They have exactly one generation
# by construction, git is their history, and they are replaced rather than superseded, so asking
# which one is current has no answer to give. This is the v1.7 content-versus-infrastructure line
# applied to currency. Exempt from currency is not exempt generally: they stay fully in scope for
# FRONTMATTER, FRESHNESS, LINKS and SHAPE.
skip_currency() {
  case "${1#$HUB/}" in CLAUDE.md|AGENTS.md|HANDOVER.md|sources.config.md) return 0 ;; esac
  return 1
}
# Retired and superseded notes are kept for the audit trail but are no longer live claims:
# they are not nagged about freshness or shape. If retiring a note did not quiet the scan,
# nobody would retire anything — and the whole lifecycle would be decoration.
is_retired() {
  local lc
  lc=$(fm_field "$1" "lifecycle")
  case "$lc" in retired|superseded) return 0 ;; esac
  return 1
}

echo "[ READABILITY ]"
# A read is a claim about a read, not a fact about a file. Cloud-synced storage with on-demand
# files (OneDrive Files-On-Demand, iCloud "optimise storage", Dropbox smart sync) keeps the
# directory entry at full size while the bytes live remotely: the first read triggers a download
# that the reading process does not wait for, so it returns empty and the file materialises a
# moment later. A content check that cannot tell that file from a well-formed file genuinely
# lacking a field reports two different findings under one label. On 2026-07-31 that collapse
# produced eleven false MISSING FRONTMATTER errors across six hubs; all eleven files opened
# with '---'. See STANDARD.md Rule 3, "A read of synced storage can report absence that is
# only lag".
#
# So: probe every document any check below reads, once, here. Size on disk greater than zero while the read
# returns nothing means UNREADABLE, not malformed. Unreadable files are an advisory, not an
# error, because the condition belongs to the storage and not to the hub, and they are excluded
# from every content check below so that no check silently passes over a file it never read.
#
# No retry and no sleep, deliberately. A scan that waits for the tree to materialise reports a
# state that was not true when it started, hides that the hub is not fully local, and makes its
# own runtime nondeterministic. Report honestly; the next run passes clean once sync settles.
#
# The probe covers the currency scope as well as the monitored one, in a single tagged pass: a
# check added later that reads files this loop never probed would be right back to reporting
# "no lifecycle:" for a file whose bytes were simply not local yet. Tag M marks a monitored
# document, C a generated document that only [ CURRENCY ] reads. The loop runs in this shell,
# not a subshell, so its counters survive.
file_size() { stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null; }
unreadable=0
readable_docs=""
readable_generated=""
probe_docs=$(
  printf '%s\n' "$monitored_docs" | sed 's/^/M\t/'
  printf '%s\n' "$currency_extra_docs" | sed 's/^/C\t/'
)
while IFS=$'\t' read -r tag f; do
  [ -z "$f" ] && continue
  skip_doc "$f" && continue
  sz=$(file_size "$f"); sz=${sz:-0}
  got=$(head -c 1 "$f" 2>/dev/null | wc -c | tr -d ' '); got=${got:-0}
  if [ "$sz" -gt 0 ] && [ "$got" -eq 0 ]; then
    echo "  ! UNREADABLE (not downloaded?): ${f#$HUB/} (${sz} bytes on disk, read returned nothing)"
    unreadable=$((unreadable + 1)); adv
    continue
  fi
  [ "$tag" = "M" ] && readable_docs="${readable_docs}${f}"$'\n'
  readable_generated="${readable_generated}${f}"$'\n'
done <<< "$probe_docs"
if [ "$unreadable" -eq 0 ]; then
  echo "  OK: every monitored and generated document could be read"
else
  echo "  The checks below do not cover the file(s) above. Do not treat them as missing content,"
  echo "  and do not write into them. Re-run once the sync has materialised them."
fi
echo

echo "[ DEPLOYMENT ]"
deployment_file="$HUB/km-deployment.md"
merged_tombstone="$HUB/MERGED-INTO.md"
deployment_errors=0
# Hub merge (v1.35). An absorbed hub is tombstoned, never deleted: its
# directory and git history stay, its registry row keeps a `merged` status with a `merged-into`
# column, and its admission rule becomes a refusal. A tombstoned hub is EXPECTED not to scan green,
# because a green scan would assert the directory is still a live hub. So when MERGED-INTO.md is
# present this block reports a TOMBSTONE in place of the interview and keyword checks a live hub
# runs. This is a tombstone, not a quarantine: the estate scan quarantines a hub-shaped directory
# ABSENT from the registry, while a merged hub keeps its registry row and reports a tombstone here.
if [ -f "$merged_tombstone" ]; then
  merged_into=$(fm_field "$merged_tombstone" "merged-into")
  echo "  TOMBSTONE: this hub is merged into ${merged_into:-the survivor named in MERGED-INTO.md}; nothing here is current"
  echo "    A merged hub is tombstoned, never deleted. Its content lives in the survivor, its"
  echo "    admission rule is a refusal, and its registry row carries status merged. This scan is"
  echo "    expected not to go green, and this is a tombstone, not a quarantine."
  deployment_errors=$((deployment_errors + 1))
elif [ ! -f "$deployment_file" ]; then
  echo "  ! MISSING DEPLOYMENT BINDING: km-deployment.md"
  deployment_errors=$((deployment_errors + 1))
elif ! printf '%s\n' "$readable_docs" | grep -qxF "$deployment_file"; then
  echo "  ! DEPLOYMENT BINDING UNREADABLE: km-deployment.md (validation not run)"
else
  canonical_version=$(fm_field "$deployment_file" "canonical-standard-version")
  canonical_revision=$(fm_field "$deployment_file" "canonical-standard-revision")
  canonical_source=$(fm_field "$deployment_file" "canonical-standard-source")
  deployment_state=$(fm_field "$deployment_file" "deployment-state")
  profile_id=$(fm_field "$deployment_file" "organization-profile-id")
  profile_revision=$(fm_field "$deployment_file" "organization-profile-revision")
  enterprise_namespace=$(fm_field "$deployment_file" "enterprise-namespace")
  enterprise_contract_revision=$(fm_field "$deployment_file" "enterprise-contract-revision")

  if [ -z "$canonical_version" ]; then
    echo "  ! canonical-standard-version must be non-empty"
    deployment_errors=$((deployment_errors + 1))
  fi
  if ! printf '%s\n' "$canonical_revision" | grep -Eq '^[0-9a-f]{40}$'; then
    echo "  ! canonical-standard-revision must be a full 40-character lowercase Git revision"
    deployment_errors=$((deployment_errors + 1))
  fi
  if [ -z "$canonical_source" ]; then
    echo "  ! canonical-standard-source must be non-empty"
    deployment_errors=$((deployment_errors + 1))
  fi

  # The purpose interview (v1.25). A hub whose deployment binding records no interview date is
  # QUARANTINED: it never scans green until /km-init's purpose interview has produced the hub
  # definition. The date-shape check also catches an unsubstituted {{INIT_DATE}} placeholder.
  initiation_interview=$(fm_field "$deployment_file" "initiation-interview")
  if ! printf '%s\n' "$initiation_interview" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    echo "  ! HUB NOT INITIATED: initiation-interview carries no date — run the /km-init purpose"
    echo "    interview to produce the hub definition; an uninterviewed hub never scans green"
    deployment_errors=$((deployment_errors + 1))
  else
    # routing-keywords (v1.28). Part of the same manifest the interview produces, and what a
    # supervisor registry and a decision surface read to attribute a source or a decision to this
    # hub. Until v1.28 nothing checked it, so an empty value scanned green while every surface
    # reading the field attributed nothing. Checked only once the interview date is valid: a hub
    # that was never interviewed has one defect, not two, and both are fixed by the same act.
    # Stated limit: this proves the field was filled in, never that the keywords are the right ones.
    # Validated ENTRY BY ENTRY since v1.44 (added in v1.44), because the
    # field is a comma-separated LIST and the v1.28 arms tested the whole value. A value of ", ," is
    # neither "" nor placeholder-bearing, so it fell through every arm and the hub scanned green
    # carrying no keyword at all, the exact state v1.28 was written to prevent, reached by a value
    # the check was not looking at the right granularity to see. The consuming surfaces drop empty
    # entries silently, so nothing downstream reported it either. The placeholder arm was already
    # correct for a list: it is a substring test, so a placeholder in any position still matches.
    #
    # The threshold is AT LEAST ONE usable entry, not every entry usable. A keyword list is a
    # non-empty set, so one usable keyword is all a surface needs to attribute the hub; a reader
    # scope is a closed list, where "closed" is a property of every member and one bad member
    # destroys it. Same rule, different logics, and copying the stricter one here would quarantine
    # a hub over a trailing comma. A stray empty entry beside real keywords is named as an
    # advisory: a typo worth seeing, never grounds to stop a hub scanning.
    routing_keywords=$(fm_field "$deployment_file" "routing-keywords")
    case "$routing_keywords" in
      "")
        echo "  ! routing-keywords is empty — the interview's keywords are part of the hub manifest;"
        echo "    a supervisor registry and a decision surface attribute nothing to a hub without them"
        deployment_errors=$((deployment_errors + 1))
        ;;
      *'{{'*)
        echo "  ! routing-keywords still carries an unsubstituted placeholder — run the /km-init"
        echo "    purpose interview and record the keywords it produced"
        deployment_errors=$((deployment_errors + 1))
        ;;
      *)
        # Split on the delimiter by hand, so an EMPTY entry survives as a token rather than being
        # absorbed into its neighbour or dropped off the end. IFS word splitting would erase the
        # very entries this check exists to see. Same technique as the reader scope walk, which
        # repaired the first instance of this class.
        kw_usable=0; kw_entries=0; kw_empty=""
        kw_rest="$routing_keywords"; kw_last=0
        while [ "$kw_last" -eq 0 ]; do
          case "$kw_rest" in
            *,*) kw_token="${kw_rest%%,*}"; kw_rest="${kw_rest#*,}" ;;
            *)   kw_token="$kw_rest"; kw_last=1 ;;
          esac
          kw_token=$(printf '%s' "$kw_token" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
          kw_entries=$((kw_entries + 1))
          # Well formed means: carries at least one alphanumeric character. Deliberately close to
          # the floor. The field is documented lowercase and the consuming surface lower-cases what
          # it reads, so demanding case here would reject a value the surface handles correctly.
          # An entry of pure punctuation is different: no surface can match on it, and it is
          # indistinguishable from a delimiter artifact.
          if printf '%s' "$kw_token" | grep -q '[[:alnum:]]'; then
            kw_usable=$((kw_usable + 1))
          else
            kw_empty="$kw_empty $kw_entries"
          fi
        done
        if [ "$kw_usable" -eq 0 ]; then
          echo "  ! routing-keywords carries no usable keyword: $kw_entries entry(ies), every one"
          echo "    of them empty or punctuation only. A comma-separated list is judged entry by"
          echo "    entry, because a value made of delimiters is neither absent nor a placeholder,"
          echo "    and a supervisor registry and a decision surface still attribute nothing here"
          deployment_errors=$((deployment_errors + 1))
        else
          for kw_i in $kw_empty; do
            echo "  routing-keywords entry $kw_i is empty or punctuation only. A leading, trailing"
            echo "    or repeated ',' is not a keyword; the hub is still attributable, so this is"
            echo "    reported rather than gated"
            adv
          done
          echo "  OK: routing-keywords declares $kw_usable usable keyword(s) of $kw_entries entry(ies)"
          echo "      (the field is filled in; whether these are the RIGHT keywords is not checked)"
        fi
        ;;
    esac
  fi

  # Hub species (Rule 6, v1.23): optional axes. Absent means station: domain and
  # exposure: compartment, so a hub that never declares them scans exactly as before;
  # a declared value outside the enum is a defect, the same rank as a bad deployment-state.
  station=$(fm_field "$deployment_file" "station")
  exposure=$(fm_field "$deployment_file" "exposure")
  case "$station" in
    ""|org-core|domain|engagement|publication) : ;;
    *)
      echo "  ! station must be org-core, domain, engagement or publication (absent = domain)"
      deployment_errors=$((deployment_errors + 1))
      ;;
  esac
  case "$exposure" in
    ""|never-public|compartment|counterparty|public) : ;;
    *)
      echo "  ! exposure must be never-public, compartment, counterparty or public (absent = compartment)"
      deployment_errors=$((deployment_errors + 1))
      ;;
  esac

  case "$deployment_state" in
    canonical)
      if [ -n "$profile_id" ] || [ -n "$profile_revision" ] \
          || [ -n "$enterprise_namespace" ] || [ -n "$enterprise_contract_revision" ]; then
        echo "  ! canonical deployment must not contain organization or enterprise binding values"
        deployment_errors=$((deployment_errors + 1))
      fi
      if [ "$deployment_errors" -eq 0 ]; then
        echo "  OK: canonical standard binding is complete; no organization profile applied"
      fi
      ;;
    organization-bound)
      if [ -z "$profile_id" ] || [ -z "$profile_revision" ] \
          || [ -z "$enterprise_namespace" ] || [ -z "$enterprise_contract_revision" ]; then
        echo "  ! organization-bound deployment requires all organization and enterprise fields"
        deployment_errors=$((deployment_errors + 1))
      else
        if ! printf '%s\n' "$profile_revision" \
            | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'; then
          echo "  ! organization-profile-revision is not a portable revision identifier"
          deployment_errors=$((deployment_errors + 1))
        fi
        if ! printf '%s\n' "$enterprise_contract_revision" \
            | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'; then
          echo "  ! enterprise-contract-revision is not a portable revision identifier"
          deployment_errors=$((deployment_errors + 1))
        fi
      fi
      if [ "$deployment_errors" -eq 0 ]; then
        echo "  OK: canonical and organization profile bindings are complete"
      fi
      ;;
    *)
      echo "  ! deployment-state must be canonical or organization-bound"
      deployment_errors=$((deployment_errors + 1))
      ;;
  esac
fi
errors=$((errors + deployment_errors))
echo

echo "[ PROJECTION ]"
# The harness projection (v1.32). CLAUDE.md and AGENTS.md restate facts that km-deployment.md
# already homes — the admission rule, the exclusions, the hard exclusions. One interview wrote
# both copies, once, and nothing kept them equal afterwards. This block compares them.
#
# THE HOME OF RECORD IS km-deployment.md. A copy in an instruction file lives inside a bounded
# marked region naming its fact class; EVERY UNMARKED LINE IS OWNER-AUTHORED BY DEFINITION and is
# never read, never compared and never touched. That inversion is the whole design: a hub carrying
# eight sections this standard never heard of is fully conformant here.
#
# DRIFT IS REPORTED, NEVER REPAIRED, and nothing in this scan writes. Either side may hold the
# newer truth — the observed case is an owner who widened an admission rule by writing it in the
# instruction file, because that is the file he reads — so a scan that "fixed" the instruction file
# to match the definition would revert a recorded ruling and report success.
#
# The closed set below is the standard's, not the hub's. Keep it in sync with STANDARD.md
# §"The harness projection". A hub cannot extend it: an open list makes the coverage line
# unmeasurable, and the coverage line is the only honest thing this block has to say about what
# it did not look at.
PROJECTION_CLASSES="purpose scope-in scope-out hard-exclusions audiences knowledge-records-boundary evidence-expectations owner-cadence sensitivity-posture routing-keywords"
PROJECTION_TARGETS="CLAUDE.md AGENTS.md"

# Parse km: marked regions out of one file. Emits, tab-separated:
#   R <kind> <class> <collapsed text>   a closed region
#   E <reason> <class>                  a marker defect
# Text is collapsed to single-spaced words across the whole region, so REFLOWING A REGION IS NOT
# DRIFT and rewording it is. Line breaks are presentation; the words are the fact.
projection_regions() {
  awk '
    { line[NR] = $0 }
    END {
      first = 0; last = 0; open_at = 0
      for (i = 1; i <= NR; i++) {
        if (line[i] ~ /<!--[ \t]*km:(fact|project)[ \t]+[a-z]/) {
          if (open_at) { printf "E\tunterminated\t%s\n", open_class; open_at = 0 }
          k = line[i]
          sub(/^.*<!--[ \t]*km:/, "", k)
          gsub(/[ \t]+/, " ", k)
          split(k, p, " ")
          open_kind = p[1]; open_class = p[2]; open_at = i; buf = ""
          if (!first) first = i
          continue
        }
        if (line[i] ~ /<!--[ \t]*km:end[ \t]*-->/) {
          if (!open_at) { printf "E\torphan-end\t-\n"; continue }
          t = buf
          gsub(/[ \t\r]+/, " ", t); sub(/^ +/, "", t); sub(/ +$/, "", t)
          printf "R\t%s\t%s\t%s\n", open_kind, open_class, t
          inside[open_at] = 1
          for (j = open_at; j <= i; j++) covered[j] = 1
          open_at = 0; last = i
          continue
        }
        if (open_at) buf = buf " " line[i]
      }
      if (open_at) printf "E\tunterminated\t%s\n", open_class

      # Interleaved text: a non-blank line sitting BETWEEN projected regions and inside no region.
      # This is the one place the blind spot narrows. A fact that lives only in an instruction file
      # is invisible to a region comparison by construction — but the observed way an owner writes
      # one is a bullet added NEXT TO the fact he is amending, and that lands here. A line whose
      # next non-blank neighbour opens a region is that region label and is not interleaved text.
      for (i = first; i <= last && last > 0; i++) {
        if (covered[i]) continue
        t = line[i]; gsub(/^[ \t]+|[ \t]+$/, "", t)
        if (t == "") continue
        nxt = ""
        for (j = i + 1; j <= last; j++) {
          u = line[j]; gsub(/^[ \t]+|[ \t]+$/, "", u)
          if (u != "") { nxt = u; break }
        }
        if (nxt ~ /^<!--[ \t]*km:(fact|project)[ \t]+[a-z]/) continue
        printf "I\t%d\t%s\n", i, substr(t, 1, 88)
      }
    }
  ' "$1"
}

projection_errors=0
projection_regions_found=0
projection_compared=0
projection_files_read=0
projection_files_skipped=0
projection_seen_classes=""
projection_interleaved=0

if [ ! -f "$deployment_file" ] || ! printf '%s\n' "$readable_docs" | grep -qxF "$deployment_file"; then
  # REFUSE rather than pass. Without the home of record there is nothing to compare against, and a
  # block that says "OK" here would be reporting that it could not read its own evidence.
  echo "  NOT CHECKED: km-deployment.md is missing or unreadable, so no projection has a source"
  echo "  COVERAGE: 0 instruction file(s) compared (refused for want of evidence, not clean)"
  adv
else
  src_scan=$(projection_regions "$deployment_file")
  src_bad=$(printf '%s\n' "$src_scan" | awk -F'\t' '$1=="E"{print $2"\t"$3}')
  if [ -n "$src_bad" ]; then
    while IFS=$'\t' read -r reason cls; do
      [ -z "$reason" ] && continue
      echo "  ! UNBALANCED MARKERS in km-deployment.md: $reason ($cls)"
      projection_errors=$((projection_errors + 1))
    done <<< "$src_bad"
  fi
  src_regions=$(printf '%s\n' "$src_scan" | awk -F'\t' '$1=="R" && $2=="fact"{print $3"\t"$4}')

  for target in $PROJECTION_TARGETS; do
    tf="$HUB/$target"
    [ -f "$tf" ] || continue
    if ! printf '%s\n' "$readable_docs" | grep -qxF "$tf"; then
      # Present but unreadable: a coverage gap belonging to the storage, never a clean comparison.
      echo "  NOT CHECKED: $target is present but could not be read (coverage gap, not conformance)"
      projection_files_skipped=$((projection_files_skipped + 1))
      adv
      continue
    fi
    projection_files_read=$((projection_files_read + 1))
    tgt_scan=$(projection_regions "$tf")
    # Advisory, not an error, and deliberately: an explanatory sentence written beside a projected
    # fact is legitimate, and a gate that fires on prompts gets switched off — taking the DRIFT and
    # DANGLING errors with it. What matters is that the line is NAMED at the next session start
    # rather than found at an audit months later.
    tgt_interleaved=$(printf '%s\n' "$tgt_scan" | awk -F'\t' '$1=="I"{print $2"\t"$3}')
    if [ -n "$tgt_interleaved" ]; then
      while IFS=$'\t' read -r ln txt; do
        [ -z "$ln" ] && continue
        echo "  UNPROJECTED TEXT beside a projected fact — $target:$ln: $txt"
        projection_interleaved=$((projection_interleaved + 1))
      done <<< "$tgt_interleaved"
      echo "    If that amends one of the facts above, its home of record is km-deployment.md."
      adv
    fi
    tgt_bad=$(printf '%s\n' "$tgt_scan" | awk -F'\t' '$1=="E"{print $2"\t"$3}')
    if [ -n "$tgt_bad" ]; then
      while IFS=$'\t' read -r reason cls; do
        [ -z "$reason" ] && continue
        echo "  ! UNBALANCED MARKERS in $target: $reason ($cls)"
        projection_errors=$((projection_errors + 1))
      done <<< "$tgt_bad"
    fi
    while IFS=$'\t' read -r kind cls text; do
      [ -z "$kind" ] && continue
      projection_regions_found=$((projection_regions_found + 1))
      if [ "$kind" = "fact" ]; then
        echo "  ! MISPLACED SOURCE $cls in $target: km:fact declares a home of record, and the home"
        echo "    of record is km-deployment.md. Use km:project here, or move the fact."
        projection_errors=$((projection_errors + 1))
        continue
      fi
      case " $PROJECTION_CLASSES " in
        *" $cls "*) ;;
        *)
          echo "  ! DANGLING $cls in $target: not a fact class in the standard's closed set"
          projection_errors=$((projection_errors + 1))
          continue
          ;;
      esac
      # A class resolves to its km:fact region in km-deployment.md, or, for a class that lives in
      # frontmatter, to the frontmatter field of the same name.
      want=$(printf '%s\n' "$src_regions" | awk -F'\t' -v c="$cls" '$1==c{print $2; found=1; exit} END{if(!found) exit 3}')
      if [ $? -ne 0 ]; then
        want=$(fm_field "$deployment_file" "$cls")
        if [ -z "$want" ]; then
          echo "  ! DANGLING $cls in $target: no km:fact region and no frontmatter field of that"
          echo "    name in km-deployment.md — the projection has no source to be checked against"
          projection_errors=$((projection_errors + 1))
          continue
        fi
      fi
      projection_compared=$((projection_compared + 1))
      projection_seen_classes="${projection_seen_classes}${cls}"$'\n'
      if [ "$text" != "$want" ]; then
        echo "  ! DRIFT $cls: $target and km-deployment.md hold different text"
        echo "      km-deployment.md: $(printf '%s' "$want" | cut -c1-96)"
        echo "      $target: $(printf '%s' "$text" | cut -c1-96)"
        projection_errors=$((projection_errors + 1))
      fi
    done <<< "$(printf '%s\n' "$tgt_scan" | awk -F'\t' '$1=="R"{print $2"\t"$3"\t"$4}')"
  done

  # The harness carries the same skills twice, once per runtime tree, and two copies of one
  # procedure drift exactly as two copies of one fact do. Compared only when BOTH trees are
  # installed: a single-runtime deployment has one home and nothing to diverge from.
  claude_skills="$HUB/.claude/skills"
  agents_skills="$HUB/.agents/skills"
  mirror_state="not installed"
  if [ -d "$claude_skills" ] && [ -d "$agents_skills" ]; then
    mirror_slugs=$( { ls -1 "$claude_skills" 2>/dev/null; ls -1 "$agents_skills" 2>/dev/null; } | sort -u )
    mirror_n=0
    while IFS= read -r slug; do
      [ -z "$slug" ] && continue
      a="$claude_skills/$slug/SKILL.md"
      b="$agents_skills/$slug/SKILL.md"
      if [ ! -f "$a" ] || [ ! -f "$b" ]; then
        echo "  ! HARNESS MIRROR DIVERGENCE $slug: installed in one runtime tree and not the other"
        projection_errors=$((projection_errors + 1))
        continue
      fi
      mirror_n=$((mirror_n + 1))
      # One legitimate per-runtime difference, and exactly one: each tree names its own harness
      # instruction file. Normalise that noun and nothing else — a comparison that tolerated more
      # would stop reporting the staleness it exists for. Everything still differing is drift.
      if ! diff -q <(sed -e 's/CLAUDE\.md/HARNESS-INSTRUCTIONS/g' -e 's/AGENTS\.md/HARNESS-INSTRUCTIONS/g' "$a") \
                   <(sed -e 's/CLAUDE\.md/HARNESS-INSTRUCTIONS/g' -e 's/AGENTS\.md/HARNESS-INSTRUCTIONS/g' "$b") >/dev/null 2>&1; then
        echo "  ! HARNESS MIRROR DIVERGENCE $slug: the .claude and .agents copies of SKILL.md differ"
        echo "    beyond the harness instruction-file name; one tree was updated and the other was not"
        projection_errors=$((projection_errors + 1))
      fi
    done <<< "$mirror_slugs"
    mirror_state="$mirror_n slug(s) compared across both runtime trees"
  elif [ -d "$claude_skills" ] || [ -d "$agents_skills" ]; then
    mirror_state="one runtime tree installed, nothing to compare"
  fi

  # The coverage line is not decoration and it never collapses into the word OK. It states how much
  # this block was TOLD about and how much of that it found, because the defect it cannot see is a
  # fact that lives only in an instruction file, in no region and no source. That residue is a
  # STATED LIMIT, not a detection: the check reports the size of what it never looked at, and the
  # completeness of the declared list is a judgement reviewed at the hub's cadence, never a check.
  declared_n=$(printf '%s\n' $PROJECTION_CLASSES | wc -l | tr -d ' ')
  unprojected=""
  unprojected_n=0
  for c in $PROJECTION_CLASSES; do
    if ! printf '%s\n' "$projection_seen_classes" | grep -qxF "$c"; then
      unprojected="$unprojected $c"
      unprojected_n=$((unprojected_n + 1))
    fi
  done
  if [ "$projection_errors" -eq 0 ]; then
    echo "  OK: $projection_compared projected region(s) match km-deployment.md"
  fi
  echo "  COVERAGE: $declared_n fact class(es) declared by the standard; $projection_regions_found region(s) found in $projection_files_read instruction file(s); $projection_compared compared; $unprojected_n class(es) not projected in this hub and therefore not checked here"
  [ -n "$unprojected" ] && echo "  NOT PROJECTED (this is the normal state, not a backlog):$unprojected"
  echo "  HARNESS SKILLS: $mirror_state"
  [ "$projection_files_skipped" -gt 0 ] && echo "  $projection_files_skipped instruction file(s) unreadable and not compared"
  # The stated limit, printed with the verdict rather than filed in a document nobody opens. This
  # block cannot see a fact that lives only in an instruction file, in no region and no source;
  # it reports how much it was told about, how much of that it found, and how much text sits beside
  # a projected fact without being one. That the declared list is the RIGHT list is a judgement
  # reviewed at the hub's cadence, never a check.
  echo "  LIMIT: unmarked text is owner-authored by definition and is not compared;"
  echo "  $projection_interleaved line(s) beside a projected fact were named, not judged."
fi
errors=$((errors + projection_errors))
echo

echo "[ FRONTMATTER ]"
# The passing line states HOW MANY documents were checked, not merely that none failed. A check
# that reports a defect by finding one passes by absence, and an absence is also what an empty
# scan set looks like: "OK" over zero files reads identically to "OK" over forty. Every block
# below that can pass by absence names its own coverage for the same reason.
fm_errors=0; fm_checked=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  skip_doc "$f" && continue
  fm_checked=$((fm_checked + 1))
  if [ "$(head -1 "$f")" != '---' ]; then
    echo "  ! MISSING FRONTMATTER: ${f#$HUB/}"
    fm_errors=$((fm_errors + 1))
    continue
  fi
  if ! awk '/^---$/{count++; next} count==1 && /^type:/{ok=1} count==2{exit} END{exit !ok}' "$f"; then
    echo "  ! MISSING type: ${f#$HUB/}"
    fm_errors=$((fm_errors + 1))
  fi
done <<< "$readable_docs"
if [ "$fm_errors" -eq 0 ]; then
  echo "  OK — $fm_checked monitored document(s) carry OKF frontmatter"
else
  errors=$((errors + fm_errors))
fi
echo

echo "[ FRESHNESS ]"
# A fact with no review date is a fact nobody has vouched for lately. `timestamp` is the last EDIT;
# `last-reviewed` is the last time someone confirmed it is still true. They are not the same claim.
fresh_errors=0; fresh_checked=0
today_s=$(date +%s)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  skip_doc "$f" && continue
  is_retired "$f" && continue
  lr=$(fm_field "$f" "last-reviewed")
  [ -z "$lr" ] && continue
  fresh_checked=$((fresh_checked + 1))
  lr_s=$(date -j -f "%Y-%m-%d" "$lr" +%s 2>/dev/null || date -d "$lr" +%s 2>/dev/null)
  if [ -z "$lr_s" ]; then
    echo "  ! UNPARSEABLE last-reviewed ($lr): ${f#$HUB/}"
    fresh_errors=$((fresh_errors + 1)); err; continue
  fi
  age=$(( (today_s - lr_s) / 86400 ))
  if [ "$age" -gt "$STALE_DAYS" ]; then
    echo "  ! STALE (${age}d > ${STALE_DAYS}d): ${f#$HUB/}"
    fresh_errors=$((fresh_errors + 1)); adv
  fi
done <<< "$readable_docs"
if [ "$fresh_checked" -eq 0 ]; then
  echo "  OK — no last-reviewed fields in use (optional)"
elif [ "$fresh_errors" -eq 0 ]; then
  echo "  OK — $fresh_checked reviewed doc(s), none stale (threshold ${STALE_DAYS}d)"
fi
echo

echo "[ LINKS ]"
# Wiki-links in frontmatter are load-bearing graph edges (owner, decidedBy, subject, correctedBy...).
# A typo produces a dangling edge that fails silently — the fact simply stops being reachable.
# Index every note basename once, then check membership. One filesystem walk, not one per link.
# A virtual environment is excluded here too (added in v1.51): a venv carrying the pinned renderer
# holds two LICENSE.md files under site-packages, and admitting them would put a package's licence
# text into the hub's own note index, where a hub note could then resolve a wiki-link against it.
# Audit finding F-10.
note_index=$(find "$HUB" -name '*.md' -not -path '*/.git/*' -not -path '*/_inbox/*' \
             -not -path '*/.venv/*' 2>/dev/null \
             | sed 's#.*/##; s#\.md$##' | sort -u)
#
# Every edge actually tested is tallied, and the tally is printed on the passing line. Without it
# "OK — all frontmatter wiki-links resolve" is the same sentence whether forty edges resolved or
# the walk found none at all, which is exactly how a check that has stopped seeing its inputs goes
# unnoticed. The tally rides the same single walk (a CHECKED marker, filtered out afterwards)
# because the inner loop runs in a subshell whose counters do not survive it.
link_report_raw=$(
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    skip_doc "$f" && continue
    awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$f" \
      | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sed 's/\[\[//; s/\]\]//' | while IFS= read -r target; do
        [ -z "$target" ] && continue
        # skip unfilled template placeholders like [[<stakeholder-note-name>]]
        printf '%s' "$target" | grep -q '[<>]' && continue
        echo "CHECKED"
        if ! printf '%s\n' "$note_index" | grep -qxF "$target"; then
          echo "  ! UNRESOLVED LINK [[${target}]] in ${f#$HUB/}"
        fi
      done
  done <<< "$readable_docs"
)
links_checked=$(printf '%s\n' "$link_report_raw" | grep -c '^CHECKED$')
link_report=$(printf '%s\n' "$link_report_raw" | grep -v '^CHECKED$' | grep 'UNRESOLVED LINK' || true)
notes_indexed=$(printf '%s\n' "$note_index" | grep -c '[^[:space:]]')
if [ -z "$link_report" ]; then
  echo "  OK — ${links_checked} frontmatter wiki-link(s) resolve against ${notes_indexed} indexed note name(s)"
else
  printf '%s\n' "$link_report"
  # counted here, not inside the loop: the loop runs in a subshell and its increments are lost
  errors=$((errors + $(printf '%s\n' "$link_report" | grep -c 'UNRESOLVED LINK')))
fi
echo

echo "[ SHAPE ]"
# An ontology is knowledge, not enforcement. A rule only binds when something deterministic checks it.
# Required fields per entity type — keep in sync with each TEMPLATE.md.
shape_errors=0; shape_checked=0
check_shape() {
  local f="$1" type="$2" required="$3"
  for k in $required; do
    if [ -z "$(fm_field "$f" "$k")" ]; then
      echo "  ! $type missing required '$k': ${f#$HUB/}"
      shape_errors=$((shape_errors + 1))
    fi
  done
}
while IFS= read -r f; do
  [ -z "$f" ] && continue
  skip_doc "$f" && continue
  is_retired "$f" && continue
  ftype=$(fm_field "$f" "type")
  case "$ftype" in
    Decision)              check_shape "$f" Decision "title decidedBy date status"; shape_checked=$((shape_checked+1)) ;;
    Risk)                  check_shape "$f" Risk "title owner status impact"; shape_checked=$((shape_checked+1)) ;;
    Stakeholder)           check_shape "$f" Stakeholder "title role"; shape_checked=$((shape_checked+1)) ;;
    Milestone)             check_shape "$f" Milestone "title targetDate owner"; shape_checked=$((shape_checked+1)) ;;
    Partner)               check_shape "$f" Partner "title status"; shape_checked=$((shape_checked+1)) ;;
    Correction)            check_shape "$f" Correction "title correctedBy date trigger rule lifecycle"; shape_checked=$((shape_checked+1)) ;;
    RelationshipAssertion) check_shape "$f" RelationshipAssertion "subject predicate object confidence assertion_method observed_at"; shape_checked=$((shape_checked+1)) ;;
    SourceSystem)          check_shape "$f" SourceSystem "title systemKind uriScheme connector defaultAccessClass refreshPolicy owner"; shape_checked=$((shape_checked+1)) ;;
    Claim)                 check_shape "$f" Claim "title owner evidencedBy assertion_method recordedAt"; shape_checked=$((shape_checked+1)) ;;
  esac
done <<< "$readable_docs"
if [ "$shape_checked" -eq 0 ]; then
  echo "  OK — no entity notes yet"
elif [ "$shape_errors" -eq 0 ]; then
  echo "  OK — $shape_checked entity note(s) carry their required fields"
else
  errors=$((errors + shape_errors))
fi
echo

echo "[ CURRENCY ]"
# A generated document with no `lifecycle:` is draft-grade by definition (STANDARD.md
# §"Currency of generated documents", rule 1), and a reader cannot tell it from a current one.
# Nothing checked this, which is why unmarked generations accumulate: the rule was published,
# no tool asked for it, and the gap is invisible until someone answers from a superseded draft.
#
# Advisory, never an error. Hubs that predate the rule carry a backlog, and an error nobody can
# clear today is a gate that gets switched off, taking the real checks with it.
#
# Scaffold is out of scope, via skip_doc: a folder's README.md, TEMPLATE.md and hub-manifest.md
# describe the folder rather than assert anything, they have exactly one generation by
# construction, so "is this the current one" has no meaning for them. A folder index is also
# where rule 1 puts the status of the non-markdown artifacts beside it, which makes it the
# carrier of other files' currency rather than a bearer of its own. This is the same definition
# of "a document" that every other check here uses, deliberately: two rules disagreeing about
# what counts as a document is how a backlog gets counted twice and fixed never.
#
# A generated entity index.md is in scope, not scaffold: it asserts derived facts about the
# initiative, so the currency rule applies. Its header forbids hand edits, which is why
# build-indexes.sh emits `lifecycle: active` itself (v1.15). An index that still lacks the
# field was built by a pre-v1.15 generator; the fix is to regenerate, never to hand-edit.
#
# One advisory for the whole check, not one per file. A currency backlog is a single prompt with
# many instances; raising one advisory per file would let a hub with an old backlog drown the
# counts that INBOX, PROPOSALS and RECONCILIATION contribute. Every file is still named, because
# an advisory that reports a number and no paths cannot be acted on.
currency_missing=0; currency_checked=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  skip_currency "$f" && continue
  currency_checked=$((currency_checked + 1))
  if [ -z "$(fm_field "$f" "lifecycle")" ]; then
    echo "  ! no lifecycle: ${f#$HUB/}"
    currency_missing=$((currency_missing + 1))
  fi
done <<< "$readable_generated"
if [ "$currency_checked" -eq 0 ]; then
  echo "  OK: no generated documents"
elif [ "$currency_missing" -eq 0 ]; then
  echo "  OK: $currency_checked generated document(s) carry lifecycle:"
else
  echo "  $currency_missing of $currency_checked generated document(s) carry no lifecycle: and are"
  echo "  draft-grade by default. Mark each one; do not infer currency from folder or file date."
  adv
fi
echo

echo "[ RESTRICTED ]"
# The sensitivity boundary, mechanically checked (v1.16; narrowed in v1.21). A note, or a
# section inside one, is marked restricted by a line beginning `sensitivity: restricted`. The
# rule the marker states is a boundary rule: restricted content is never surfaced outside its
# bound. This check enforces it on the hub's outbound surfaces:
#   shareable/            leaves the team by definition
#   changes/ free text    proposals and approvals travel to reviewers and other tiers
#   generated indexes     the hub's summary surface; build-indexes.sh excludes restricted notes,
#                         so a hit here clears by regenerating, never by hand-editing
# WHERE the marker sits decides WHAT is restricted (narrowed in v1.21):
#   frontmatter marker    the whole note is restricted, name included — the note's name on a
#                         surface discloses the existence and identity of the restricted record
#   body marker           the SECTION the marker opens is restricted — the section's verbatim
#                         text is blocked on surfaces, but the note's name/path stays nameable,
#                         so the note can still be the target of a governed proposal. (Before
#                         v1.21 one restricted section made the whole file's name an error on
#                         every outbound surface, so the governed route to changing such a file
#                         was itself blocked.)
# ONE EXCEPTION TO THE FRONTMATTER RULE, and it is v1.21's own reasoning reaching a case it should
# always have covered (narrowed in v1.57, drafted and unpublished: this narrowing binds nothing
# until its own owner push): on a NUMBERED CURATED DOCUMENT — a root-level
# `0[0-9]_*.md` or `10_*.md`, the fixed hub structure — a frontmatter marker restricts the CONTENT
# and leaves the NAME nameable. A numbered document's name is the hub's public structure, not a
# disclosive record identifier, and blocking it made a directive that restricts such a document's
# content unable to name the document it restricts, so the hub's scan failed at every session start
# and buried its real integrity errors underneath. The BODY-marker path is deliberately UNCHANGED
# and was examined rather than assumed: a body marker already emits section text and never the
# name, so a numbered curated document marked in the body was already nameable and needs no
# narrowing; applying one there would only widen what is blocked.
# Three findings, all ERRORS: the marker itself on a surface (restricted content copied there
# wholesale), the name of a frontmatter-restricted note on a surface, as a wiki-link or a bare
# word (disclosing the existence and identity of the restricted record), and a verbatim line of
# a body-restricted section on a surface. Errors, not advisories, deliberately: unlike history,
# an outbound file can be fixed before it ships, so this gate is clearable and stays on.
# Stated limits of the narrowing: section text is matched as verbatim lines of at least 16
# characters, so paraphrase and very short lines escape, and a body-marked note's existence and
# name are disclosable by design. A note whose name or existence is itself sensitive must carry
# the marker in FRONTMATTER; the name block then covers it.
# Readability: shareable/ and changes/ are not in the [ READABILITY ] probe set, so this check
# probes what it reads itself. A surface it could not read is reported and never counted as
# clean, and an unreadable note is reported as an identifier-coverage gap. A check must not pass
# because it failed to read its evidence.
# Classification-aware since v1.22 (Rule 6): a note whose FRONTMATTER carries
# `accessClass: restricted` or `accessClass: record` is restricted CONTENT with a nameable NAME —
# existence crosses; contents don't (crossing law 3). Its whole body is treated like a
# body-restricted section: verbatim text blocked on outbound surfaces, name and path still
# nameable, so a record-class catalogue entry can be pointed at without being reproduced.
# Verbatim matching is the declassification rule by construction: an aggregate is not a verbatim
# line of any restricted note, so it passes; an extracted line is, so it does not ("aggregation
# declassifies; extraction does not"). A note whose name or existence is itself sensitive still
# uses the `sensitivity: restricted` FRONTMATTER marker, which blocks the name as well. The class
# line itself on a surface means a classed note's frontmatter was copied there wholesale — an
# error, same as the marker.
restricted_marker='^sensitivity:[[:space:]]*restricted([^A-Za-z0-9-]|$)'
restricted_class='^accessClass:[[:space:]]*(restricted|record)([^A-Za-z0-9-]|$)'
restricted_errors=0
restricted_surface_unreadable=0

# Pass 1: walk every note in the hub except the surfaces themselves, the inbox (arriving, not
# yet asserted), templates and indexes. Emit, tab-separated (narrowed in v1.21; classes v1.22):
#   I <note-name>          frontmatter-restricted note: its NAME is blocked on surfaces
#   C <note-name> <line>   verbatim content line of a body-restricted section, or any body line
#                          of a note classed restricted/record in frontmatter: TEXT is blocked
#   U <path>               unreadable: identifier/section coverage gap
restricted_id_scan=$(
  find "$HUB" -name '*.md' -type f \
      -not -path '*/.git/*' \
      -not -path '*/.venv/*' \
      -not -path "$HUB/_inbox/*" \
      -not -path "$HUB/shareable/*" \
      -not -path "$HUB/changes/*" 2>/dev/null | sort \
  | while IFS= read -r f; do
      # Leading paren keeps this case parseable inside $( ) on bash 3.2 (macOS default).
      case "$f" in (*/TEMPLATE.md|*/index.md) continue ;; esac
      # A NUMBERED CURATED DOCUMENT is a root-level `0[0-9]_*.md` or `10_*.md` — the fixed hub
      # structure of STANDARD.md §"Hub Directory Structure" and its monitored-files glob, and
      # nothing else. Its NAME is the hub's public structure, not a disclosive record identifier,
      # so a frontmatter marker on one restricts its CONTENT and leaves the name nameable (added in
      # v1.57, drafted and unpublished: it binds nothing until its own owner push;
      # see the awk below). Root-scoped on purpose: a numbered name in a SUBDIRECTORY is an
      # ordinary note, the standard treats no such file as curated structure, and widening this to
      # any `NN_*.md` anywhere would turn a false positive into a false negative.
      curated=0
      case "$f" in ("$HUB"/0[0-9]_*.md|"$HUB"/10_*.md) curated=1 ;; esac
      sz=$(file_size "$f"); sz=${sz:-0}
      got=$(head -c 1 "$f" 2>/dev/null | wc -c | tr -d ' '); got=${got:-0}
      if [ "$sz" -gt 0 ] && [ "$got" -eq 0 ]; then
        printf 'U\t%s\n' "${f#$HUB/}"
      elif grep -I -Eq "$restricted_marker" "$f" 2>/dev/null \
        || grep -I -Eq "$restricted_class" "$f" 2>/dev/null; then
        # Classify the marker's position: frontmatter restricts the whole note (I record);
        # a body marker restricts the section it opens, up to the next heading at the same or
        # a higher level (C records, one per non-trivial verbatim line). A marker before any
        # heading restricts the rest of the body. An accessClass of restricted/record counts
        # only in FRONTMATTER (it is an OKF field, not a marker) and restricts the whole BODY
        # as C records while leaving the name nameable — existence crosses; contents don't
        # (v1.22). Binary files were already excluded by grep -I.
        awk -v stem="$(basename "$f" .md)" -v mrk="$restricted_marker" -v cls="$restricted_class" \
            -v curated="$curated" '
          NR==1 && $0=="---" { infm=1; next }
          infm {
            if ($0=="---") infm=0
            # A frontmatter marker on a NUMBERED CURATED DOCUMENT sets classed instead of emitting
            # the I record (added in v1.57, drafted and unpublished: it binds nothing until its own
            # owner push): the content is blocked verbatim and the name stays nameable,
            # which is exactly the treatment accessClass: restricted|record gets on the next line,
            # for the reason the comment there already gives - existence crosses, contents do not
            # (v1.22). Before this, a directive restricting the content of such a document could
            # not name the document it was restricting, so the scan of the hub failed at every
            # session start and buried the real integrity errors underneath.
            # (No apostrophes in this comment: the awk program is a single-quoted shell word.)
            else if ($0 ~ mrk) { if (curated+0) classed=1; else print "I\t" stem }
            else if ($0 ~ cls) classed=1
            next
          }
          {
            if ($0 ~ /^#+[ \t]/) {
              n=0; while (substr($0, n+1, 1)=="#") n++
              # A heading at or above the restricted section own level closes the span; a
              # deeper heading is part of the section and is treated as its content.
              if (span && n <= base) span=0
              cur=n
            }
            if ($0 ~ mrk) { if (!span) { span=1; base=cur }; next }
            if (span || classed) {
              line=$0
              gsub(/^[ \t]+|[ \t]+$/, "", line)
              if (length(line) >= 16) print "C\t" stem "\t" line
            }
          }
        ' "$f" 2>/dev/null
      fi
    done
)
restricted_ids=$(printf '%s\n' "$restricted_id_scan" | awk -F'\t' '$1=="I"{print $2}' | sort -u)
restricted_section_lines=$(printf '%s\n' "$restricted_id_scan" | awk -F'\t' '$1=="C"' | sort -u)
restricted_ids_unreadable=$(printf '%s\n' "$restricted_id_scan" | awk -F'\t' '$1=="U"{print $2}')

# Pass 2: scan the outbound surfaces.
restricted_surfaces=$(
  find "$HUB/shareable" -name '*.md' -type f 2>/dev/null
  find "$HUB/changes" -name '*.md' -type f \
      ! -name 'PROPOSAL_TEMPLATE.md' ! -name 'APPROVAL_TEMPLATE.md' 2>/dev/null
  for dir in $ENTITY_DIRS; do
    [ -f "$HUB/$dir/index.md" ] && echo "$HUB/$dir/index.md"
  done
)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  sz=$(file_size "$f"); sz=${sz:-0}
  got=$(head -c 1 "$f" 2>/dev/null | wc -c | tr -d ' '); got=${got:-0}
  if [ "$sz" -gt 0 ] && [ "$got" -eq 0 ]; then
    echo "  ! UNREADABLE (not downloaded?): ${f#$HUB/} (not checked for restricted content)"
    restricted_surface_unreadable=$((restricted_surface_unreadable + 1)); adv
    continue
  fi
  if grep -I -Eq "$restricted_marker" "$f" 2>/dev/null; then
    echo "  ! RESTRICTED MARKER on outbound surface: ${f#$HUB/}"
    restricted_errors=$((restricted_errors + 1))
  fi
  # A restricted/record class line on a surface means a classed note's frontmatter was copied
  # there wholesale (v1.22). `accessClass: internal` and `accessClass: public` are not findings.
  if grep -I -Eq "$restricted_class" "$f" 2>/dev/null; then
    echo "  ! RESTRICTED ACCESS CLASS on outbound surface: ${f#$HUB/}"
    restricted_errors=$((restricted_errors + 1))
  fi
  while IFS= read -r rid; do
    [ -z "$rid" ] && continue
    if grep -I -qwF -- "$rid" "$f" 2>/dev/null; then
      echo "  ! RESTRICTED IDENTIFIER '$rid' on outbound surface: ${f#$HUB/}"
      restricted_errors=$((restricted_errors + 1))
    fi
  done <<< "$restricted_ids"
  # Body-restricted sections: their verbatim text must not reach a surface, even though the
  # containing note's name may (narrowed in v1.21).
  while IFS= read -r crec; do
    [ -z "$crec" ] && continue
    cstem=$(printf '%s\n' "$crec" | cut -f2)
    ctext=$(printf '%s\n' "$crec" | cut -f3-)
    [ -z "$ctext" ] && continue
    if grep -I -qF -- "$ctext" "$f" 2>/dev/null; then
      echo "  ! RESTRICTED SECTION TEXT (from '$cstem') on outbound surface: ${f#$HUB/}"
      restricted_errors=$((restricted_errors + 1))
    fi
  done <<< "$restricted_section_lines"
done <<< "$restricted_surfaces"
if [ -n "$restricted_ids_unreadable" ]; then
  echo "  ! Identifier coverage incomplete: note(s) below could not be read, so the set of"
  echo "    restricted note names and section text checked against the surfaces may be missing"
  echo "    entries:"
  printf '%s\n' "$restricted_ids_unreadable" | sed 's/^/    - /'
  adv
fi
if [ "$restricted_errors" -gt 0 ]; then
  errors=$((errors + restricted_errors))
elif [ "$restricted_surface_unreadable" -gt 0 ] || [ -n "$restricted_ids_unreadable" ]; then
  echo "  No restricted content found on the surfaces that could be read (coverage incomplete)"
else
  echo "  OK: no restricted markers, classes, identifiers or section text on outbound surfaces"
fi
echo

echo "[ RECONCILIATION ]"
disputes=$(find "$HUB/reconciliation/_disputes" -maxdepth 1 -name '*_dispute.md' 2>/dev/null | sort)
if [ -z "$disputes" ]; then
  echo "  OK — no active disputes"
else
  # An open dispute is not automatically an owner action item. A dispute waiting on a counterpart
  # to reply is waiting on that counterpart, and reporting it as "hub-owner decision required"
  # every day, for weeks, is how a scan teaches its reader to skip the line. The old check keyed
  # off the filename and read nothing from the file; this reads the field the file carries.
  #
  # An unstated blocker is reported as unstated rather than assumed to be the owner. Assuming the
  # owner is the thing that was wrong, and a dispute file that could not be read looks identical
  # to one with no field, so the message names both possibilities instead of picking one.
  echo "  ! Active disputes:"
  while IFS= read -r f; do
    blocked=$(sed -n 's/^\*\*Blocked on:\*\*[[:space:]]*//p' "$f" 2>/dev/null | head -1)
    blocked=$(printf '%s' "$blocked" | sed 's/[[:space:]]*$//')
    case "$blocked" in
      "")           echo "    - $(basename "$f") (blocked-on not stated or file unreadable)" ;;
      "Hub Owner")  echo "    - $(basename "$f") (blocked on: Hub Owner, decision required)" ;;
      *)            echo "    - $(basename "$f") (blocked on: $blocked, no hub-owner action)" ;;
    esac
    adv
  done <<< "$disputes"
fi
echo

echo "[ AGENT ]"
# Attribution advisory (Agent Tier, added 2026-07-30 — KM-Standard STANDARD.md §"Agent Tier").
# Scope enforcement is a declared convention, not a technical boundary; the compensating control is
# that every commit should carry a `KM-Agent: <name>` trailer. Checks HEAD only — commits before
# this hub minted an agent definition predate the convention and are not retroactively audited
# (grandfathered, matching this estate's own IMPORT-SPEC.md precedent). Always advisory, never error:
# a foreign-agent trailer may be a legitimate, owner-directed override — the point is visibility.
agent_file=$(find "$HUB/.claude/agents" -maxdepth 1 -name 'km-*.md' 2>/dev/null | head -1)
if [ -z "$agent_file" ]; then
  echo "  OK — no agent definition (Agent Tier not in use for this hub)"
elif ! git -C "$HUB" rev-parse HEAD >/dev/null 2>&1; then
  echo "  OK — no commits yet"
else
  own_agent=$(fm_field "$agent_file" "name")
  trailer=$(git -C "$HUB" log -1 --pretty='%(trailers:key=KM-Agent,valueonly)' 2>/dev/null | tr -d '[:space:]')
  if [ -z "$own_agent" ]; then
    # Say what is true: the expected name could not be read. Comparing a trailer against an
    # empty string would report every commit as foreign-agent work (see [ READABILITY ]).
    echo "  ! agent definition unreadable or carries no name: ${agent_file#$HUB/} (attribution and dispatch checks not run, advisory)"; adv
  elif [ -z "$trailer" ]; then
    echo "  ! HEAD commit carries no KM-Agent trailer (advisory)"; adv
  elif [ "$trailer" != "$own_agent" ]; then
    echo "  ! HEAD commit attributed to foreign agent '$trailer' (this hub's agent: '$own_agent') (advisory)"; adv
  else
    echo "  OK — HEAD attributed to $own_agent"
  fi

  # A false `Dispatched-By:` trailer (added 2026-08-01).
  #
  # `Dispatched-By:` asserts that a dispatched agent authored the commit. Only that agent may write
  # one. A commit carrying `Dispatched-By:` whose `KM-Agent:` is not this hub's own agent says an
  # author outside the hub claimed a dispatched agent acted, and that is not a typo, it is the exact
  # trace a bypassed route leaves. Where the foreign-agent line above can be a legitimate
  # owner-directed override, this cannot: the trailer is the compensating control for a tier with no
  # mechanical enforcement, so a false one corrupts the only audit trail the estate has.
  #
  # Two deliberate differences from the HEAD check above.
  #
  # It walks a window of history rather than HEAD alone, because a false trailer is a durable defect
  # in the record and not a transient state: check only HEAD and the next commit buries it forever.
  # No grandfathering is needed here, unlike KM-Agent: the trailer did not exist before the
  # convention did, so a commit carrying one is in scope by construction.
  #
  # It stays advisory even though it is a real violation, because history cannot be rewritten to
  # clear it. An error no one can ever clear is a permanently red gate, and a permanently red gate
  # is switched off. The remedy is a `corrections/` note naming the commit, not a repair.
  #
  # Guarded on a readable own_agent for the same reason the branch above is: with an empty expected
  # name, every legitimately dispatched commit compares unequal and gets reported as a false claim.
  # A check that fires hardest when it knows least is worse than one that says it did not run.
  if [ -n "$own_agent" ]; then
    window=${DISPATCH_SCAN_COMMITS:-50}
    false_dispatch=$(
      git -C "$HUB" log -n "$window" \
        --pretty=format:'%h%x1f%(trailers:key=KM-Agent,valueonly,separator=%x2C)%x1f%(trailers:key=Dispatched-By,valueonly,separator=%x2C)%x1f%s' \
        2>/dev/null \
      | awk -F'\037' -v own="$own_agent" '
          {
            km = $2; dis = $3
            gsub(/[ \t\r\n]/, "", km); gsub(/[ \t\r\n]/, "", dis)
            if (dis != "" && km != own) {
              printf "  ! FALSE DISPATCH CLAIM in %s: Dispatched-By: %s, but KM-Agent: %s (this hub: %s)\n", \
                $1, dis, (km == "" ? "(none)" : km), own
              printf "      %s\n", $4
            }
          }'
    )
    if [ -n "$false_dispatch" ]; then
      printf '%s\n' "$false_dispatch"
      echo "  A Dispatched-By: trailer may only be written by the agent that was dispatched. Capture"
      echo "  each commit above as a corrections/ note; history is not rewritten to clear this."
      adv
    fi
  fi
fi
echo
# Coverage is stated separately from the verdict. A clean result on a partially readable tree is
# a narrower claim than a clean result on a whole one, and the reader is entitled to know which
# one this is.
if [ "$unreadable" -gt 0 ]; then
  echo "COVERAGE: $unreadable monitored document(s) could not be read and were not checked."
fi
if [ "$errors" -gt 0 ]; then
  echo "=== FAIL — $errors error(s), $advisories advisory(ies) ==="
  echo "Errors are defects: fix them. Advisories need a human, not a repair."
  exit 1
elif [ "$advisories" -gt 0 ]; then
  echo "=== OK — no errors, $advisories advisory(ies) ==="
  exit 0
else
  echo "=== OK — clean ==="
  exit 0
fi
