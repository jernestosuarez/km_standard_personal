#!/bin/bash
# reader-scan.sh - validate a Reader context's DECLARATION shape.
# Run from any directory: bash /path/to/reader-scan.sh [context-dir]
# Default context-dir is this script's own directory.
#
# WHAT THIS CHECKS, AND WHAT IT DOES NOT
#
# This validates the SHAPE OF THE DECLARATION a Reader context carries: that the tier marker names it
# `reader`, that a governing contract file is present, that an `outputs/` area exists, and that any
# declared scope is a non-empty CLOSED list of hubs. It is deterministic: no LLM judgement, no network.
#
# The scope is validated TOKEN BY TOKEN, never as one whole value. Every member of a closed list must
# itself be a closed member, so an open token is rejected wherever it sits in the list. Validating the
# whole value is how this check once accepted `scope: *, hub-alpha` as a closed scope of two hubs.
#
# It validates the DECLARATION, not ISOLATION. A scoped reader's isolation is convention unless the
# hosting enforces it with separate installs, storage, or credentials (STANDARD.md § Reader tier). No
# check here proves a reader cannot read a hub outside its scope, because that is a hosting fact, not a
# declaration fact. The passing line states exactly this coverage.
#
# Exit status:
#   0 - the declaration is well formed (a full reader, or a scoped reader with a closed scope).
#   1 - ERROR: the declaration is malformed (missing marker, wrong tier, missing contract file or
#       outputs area, or a scope carrying an open token, an empty entry, a duplicate, or a token that
#       is not a well formed hub identifier).
#   2 - REFUSED: the declaration could not be evaluated (directory or marker absent or unreadable, the
#       scope declared more than once, or a scope line carrying bytes the parser cannot read). A
#       refusal is never a pass; it is a coverage gap in the input.

set -u

CTX="${1:-$(cd "$(dirname "$0")" && pwd)}"

errors=0
err() { echo "  ERROR - $1"; errors=$((errors + 1)); }

echo "=== Reader Scan - $(date '+%Y-%m-%d %H:%M') ==="
echo "  context: $CTX"
echo

# --- Refuse rather than pass on input that cannot be evaluated ---
if [ ! -d "$CTX" ]; then
  echo "  REFUSED - context directory not found or not a directory: $CTX"
  echo "  (a refusal is a coverage gap in the input, never a verdict that the reader is clean)"
  exit 2
fi

marker="$CTX/.km-tier"
if [ ! -f "$marker" ]; then
  err ".km-tier marker missing; a Reader context declares its identity by inspection, not memory"
  # No marker means nothing further about the tier can be evaluated; report and exit as ERROR.
  echo
  echo "[ COVERAGE ] validated the reader DECLARATION shape (marker/tier, contract file, outputs, closed scope); NOT isolation, which is a hosting decision."
  echo "RESULT: ERROR ($errors)"
  exit 1
fi
if [ ! -r "$marker" ]; then
  echo "  REFUSED - .km-tier present but unreadable: $marker"
  echo "  (a refusal is a coverage gap in the input, never a verdict that the reader is clean)"
  exit 2
fi

echo "[ MARKER ]"
tier="$(head -n 1 "$marker" | tr -d '[:space:]')"
if [ "$tier" = "reader" ]; then
  echo "  OK - .km-tier first line is 'reader'"
else
  err ".km-tier first line is '$tier', expected 'reader'"
fi
echo

echo "[ CONTRACT ]"
if [ -f "$CTX/CLAUDE.md" ] || [ -f "$CTX/AGENTS.md" ]; then
  echo "  OK - a governing contract file is present (CLAUDE.md and/or AGENTS.md)"
else
  err "no governing contract file (CLAUDE.md or AGENTS.md); the contract is the file, not a remembered rule"
fi
echo

echo "[ OUTPUTS ]"
if [ -d "$CTX/outputs" ]; then
  echo "  OK - outputs/ area present"
else
  err "outputs/ area missing; a Reader writes results into its own outputs/ area"
fi
echo

echo "[ SCOPE ]"
# A scope line is optional. Absent => full reader (may read the whole estate). Present => scoped
# reader, and the scope must be a non-empty CLOSED list, validated one token at a time.
#
# Whole-value validation is the defect this replaces: it rejected an exact `*` and an exact `all` and
# accepted either one when it was hidden among well-formed neighbours. A list is closed only if every
# one of its members is closed, so each token is judged on its own and named when it offends.
#
# A hub identifier is the standard's own hub slug (STANDARD.md, Naming convention): lowercase
# alphanumerics in hyphen-separated runs, no leading or trailing hyphen. No new form is invented here.
HUB_ID_RE='^[a-z0-9]+(-[a-z0-9]+)*$'

# Two scope declarations cannot be resolved into one governing scope. Refuse; do not pick one.
scope_count="$(grep -c -i '^[[:space:]]*scope:' "$marker" || true)"
if [ "${scope_count:-0}" -gt 1 ]; then
  echo "  REFUSED - the marker declares 'scope:' $scope_count times; which one governs could not be evaluated"
  echo "  (a refusal is a coverage gap in the input, never a verdict that the reader is clean)"
  exit 2
fi

scope_line="$(grep -i '^[[:space:]]*scope:' "$marker" | head -n 1 || true)"
if [ -z "$scope_line" ]; then
  echo "  OK - no scope declared; full reader (whole readable estate)"
else
  raw="${scope_line#*:}"
  # A scope line carrying bytes outside the printable set cannot be tokenised in a way this parser can
  # justify. Refuse rather than guess: an unevaluable declaration is a coverage gap, never a pass.
  if printf '%s' "$raw" | LC_ALL=C grep -q '[^[:print:] ]'; then
    echo "  REFUSED - the scope line carries characters this parser could not be evaluated against"
    echo "  (a refusal is a coverage gap in the input, never a verdict that the reader is clean)"
    exit 2
  fi
  trimmed="$(printf '%s' "$raw" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  if [ -z "$trimmed" ]; then
    err "scope declared but empty; a scoped reader needs a non-empty closed list of hubs"
  else
    scope_bad=0
    seen=""
    validated=""
    n=0
    rest="$trimmed"
    last=0
    # Split on the delimiter by hand so an EMPTY entry survives as a token rather than being absorbed
    # into its neighbour or dropped off the end. A stray ',' must be reported, never eaten.
    while [ "$last" -eq 0 ]; do
      case "$rest" in
        *,*) token="${rest%%,*}"; rest="${rest#*,}" ;;
        *)   token="$rest"; last=1 ;;
      esac
      token="$(printf '%s' "$token" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
      n=$((n + 1))
      if [ -z "$token" ]; then
        err "scope entry $n is an EMPTY entry; a leading, trailing or repeated ',' is not a hub name"
        scope_bad=1
        continue
      fi
      lowered="$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')"
      if [ "$lowered" = "*" ] || [ "$lowered" = "all" ]; then
        err "scope entry $n is an OPEN token ('$token'); a list is closed only if every member is closed"
        scope_bad=1
        continue
      fi
      if ! printf '%s' "$token" | grep -Eq "$HUB_ID_RE"; then
        err "scope entry $n ('$token') is not a well formed hub identifier (lowercase alphanumerics, hyphen separated)"
        scope_bad=1
        continue
      fi
      case " $seen " in
        *" $token "*)
          err "scope entry $n ('$token') is a duplicate; a hub is named once in a closed list"
          scope_bad=1
          continue
          ;;
      esac
      seen="$seen $token"
      if [ -z "$validated" ]; then validated="$token"; else validated="$validated, $token"; fi
    done
    if [ "$scope_bad" -eq 0 ]; then
      # Report the VALIDATED tokens, never the raw line, so no delimiter can reach a reported hub name.
      echo "  OK - scoped reader; closed scope of $n hub(s): $validated"
    fi
  fi
fi
echo

echo "[ COVERAGE ] validated the reader DECLARATION shape (marker/tier, contract file, outputs, closed scope); NOT isolation, which is a hosting decision."
if [ "$errors" -eq 0 ]; then
  echo "RESULT: OK - declaration well formed"
  exit 0
else
  echo "RESULT: ERROR ($errors)"
  exit 1
fi
