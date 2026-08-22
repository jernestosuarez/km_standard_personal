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
# It validates the DECLARATION, not ISOLATION. A scoped reader's isolation is convention unless the
# hosting enforces it with separate installs, storage, or credentials (STANDARD.md § Reader tier). No
# check here proves a reader cannot read a hub outside its scope, because that is a hosting fact, not a
# declaration fact. The passing line states exactly this coverage.
#
# Exit status:
#   0 - the declaration is well formed (a full reader, or a scoped reader with a closed scope).
#   1 - ERROR: the declaration is malformed (missing marker, wrong tier, missing contract file or
#       outputs area, or an OPEN scope).
#   2 - REFUSED: the context could not be evaluated (directory or marker absent or unreadable). A
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
# reader, and the scope must be a non-empty CLOSED list. Open scope (*, all, empty) is unstatable as a
# boundary and is rejected: STANDARD.md § "The scope is a named, closed list".
scope_line="$(grep -i '^scope:' "$marker" | head -n 1 || true)"
if [ -z "$scope_line" ]; then
  echo "  OK - no scope declared; full reader (whole readable estate)"
else
  raw="${scope_line#*:}"
  # normalise: strip surrounding whitespace
  trimmed="$(echo "$raw" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  lowered="$(echo "$trimmed" | tr '[:upper:]' '[:lower:]')"
  if [ -z "$trimmed" ] || [ "$lowered" = "*" ] || [ "$lowered" = "all" ]; then
    err "scope is OPEN ('${trimmed:-<empty>}'); a scoped reader needs a non-empty closed list of hubs"
  else
    # count comma-separated, non-empty entries
    n="$(echo "$trimmed" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | grep -c '.')"
    if [ "$n" -ge 1 ]; then
      echo "  OK - scoped reader; closed scope of $n hub(s): $trimmed"
    else
      err "scope declared but no hub names parsed; expected 'scope: hub-a, hub-b'"
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
