#!/bin/bash
# hub-scan.sh — Hub Integrity & Governance Scan
# Run from any directory: bash /path/to/hub-scan.sh
#
# Every check here is deterministic. No LLM judgement, no network. A check that
# needs an agent to interpret it is not a check — it is a suggestion.

HUB="$(cd "$(dirname "$0")" && pwd)"

# Entity folders that hold one note per instance. Keep in sync with STANDARD.md.
ENTITY_DIRS="decisions risks stakeholders milestones partners relationships corrections"

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

echo "[ INTEGRITY ]"
if ! git -C "$HUB" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "  ERROR — hub is not a git repository. Run: git init && git add -A && git commit -m \"init: hub scaffold\""
  err
else
  # Denylist semantics: everything at the hub root is monitored EXCEPT the working areas below,
  # so a new top-level doc is caught automatically. Named files inside sources/ are re-included
  # because the provenance indexes are monitored even though their folder is not.
  changes=$(
    git -C "$HUB" status --porcelain -- . \
      ':(exclude)_inbox' ':(exclude)changes' ':(exclude)working-docs' ':(exclude)shareable' \
      ':(exclude)sources' ':(exclude).claude'
    git -C "$HUB" status --porcelain -- \
      sources.config.md sources/transcript-index.md sources/publication-log.md sources/dates-register.md
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
  for dir in sources reconciliation $ENTITY_DIRS; do
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
deployment_errors=0
if [ ! -f "$deployment_file" ]; then
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

echo "[ FRONTMATTER ]"
fm_errors=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  skip_doc "$f" && continue
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
  echo "  OK — monitored documents have OKF frontmatter"
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
note_index=$(find "$HUB" -name '*.md' -not -path '*/.git/*' -not -path '*/_inbox/*' 2>/dev/null \
             | sed 's#.*/##; s#\.md$##' | sort -u)
link_report=$(
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    skip_doc "$f" && continue
    awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$f" \
      | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sed 's/\[\[//; s/\]\]//' | while IFS= read -r target; do
        [ -z "$target" ] && continue
        # skip unfilled template placeholders like [[<stakeholder-note-name>]]
        printf '%s' "$target" | grep -q '[<>]' && continue
        if ! printf '%s\n' "$note_index" | grep -qxF "$target"; then
          echo "  ! UNRESOLVED LINK [[${target}]] in ${f#$HUB/}"
        fi
      done
  done <<< "$readable_docs"
)
if [ -z "$link_report" ]; then
  echo "  OK — all frontmatter wiki-links resolve"
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
