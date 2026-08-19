#!/bin/bash
# The canonical leakage instrument: scan every tracked text file for a denylist pattern.
#
# This check reports leakage by MATCHING, so a pass is an ABSENCE, and an absence is evidence only
# when three things hold: the pattern could match, the engine honoured it, and there was something to
# read. All three are checked here and each one fails CLOSED (exit 2), because a guard that reports
# success while letting through exactly what it exists to stop is worse than no guard at all.
#
# Repaired in v1.29 from a demonstrated false pass. The instrument invokes `git grep -E`, whose
# regex engine IGNORES `\b`: `\bTerm\b` matched nothing and printed "canonical leakage check passed"
# against a tree carrying 89 matching lines in one file. Note that this is per-tool and cannot be
# reasoned about from the platform — on the same host `/usr/bin/grep -E` honours `\b`, `git grep -E`
# does not, and BSD `sed` does not — so the boundary construct is PROBED against the live engine
# before the scan, never assumed. Word boundaries are now requested with `-w`, which git implements
# above the regex engine and is therefore portable; case-insensitive matching, which the old form
# could not express at all, is `-i`.
#
# Usage: test_canonical_leakage.sh [-i] [-w] EXTENDED_REGULAR_EXPRESSION
#   -i  case-insensitive, for the case-insensitive half of a denylist
#   -w  whole word: the match must be bounded by non-word characters
#
# Exit: 0  clean — pattern verified expressible, N tracked files scanned, no match
#       1  leakage found — matching lines printed on stdout
#       2  REFUSED — usage error, unreadable repository, empty scan set, or inert boundary syntax
#
# Proven in both directions by tests/test_canonical_leakage_guard.sh. No real organization, person or
# initiative is named in this file or in its fixtures.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

refuse() {
  echo "canonical leakage check REFUSED: $*" >&2
  exit 2
}

usage() {
  echo "Usage: $0 [-i] [-w] EXTENDED_REGULAR_EXPRESSION" >&2
  echo "  -i  case-insensitive    -w  whole word (portable boundary; do not use \\b)" >&2
  exit 2
}

ci=0
wordwise=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -i) ci=1; shift ;;
    -w) wordwise=1; shift ;;
    -iw|-wi) ci=1; wordwise=1; shift ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; usage ;;
    *) break ;;
  esac
done

[ "$#" -eq 1 ] || usage
[ -n "$1" ] || usage
pattern="$1"

# --- Does this engine honour the boundary construct the pattern uses? ---------------------------
# Probe the tool that will actually run the scan, with the flags it will actually run, against a
# fixture whose answer is known: one line where the term stands alone, one where it is a prefix. A
# working boundary construct matches the first line and only the first line.
boundary_honoured() {
  local probe="$1" dir out
  dir="$(mktemp -d "${TMPDIR:-/tmp}/km-leak-probe.XXXXXX")" || return 1
  printf 'alpha probeword omega\nprobewordx tail\n' > "$dir/probe.txt"
  out="$(cd "$dir" && git grep --no-index -I -h -E -e "$probe" -- probe.txt 2>/dev/null)"
  rm -rf "$dir"
  [ "$out" = "alpha probeword omega" ]
}

inert() {
  {
    echo "canonical leakage check REFUSED: the pattern uses $1, which the regex engine behind"
    echo "  'git grep -E' on this host IGNORES. An ignored boundary matches nothing, and nothing is"
    echo "  also what a clean tree looks like, so the scan would report a false PASS."
    echo "  Use -w instead: git implements whole-word matching above the regex engine, so it works"
    echo "  on every host."
  } >&2
  exit 2
}

case "$pattern" in
  *'\b'*|*'\B'*) boundary_honoured '\bprobeword\b'             || inert '\b or \B' ;;
esac
case "$pattern" in
  *'\<'*|*'\>'*) boundary_honoured '\<probeword\>'             || inert '\< or \>' ;;
esac
case "$pattern" in
  *'[[:<:]]'*|*'[[:>:]]'*)
                 boundary_honoured '[[:<:]]probeword[[:>:]]'   || inert '[[:<:]] or [[:>:]]' ;;
esac

# --- Was there anything to read? ---------------------------------------------------------------
# A pass over an empty scan set is not a clean tree, it is an unread one. Enumerate first, and never
# through a pipe, whose exit status is the last command's and not git's.
tracked="$(git -C "$ROOT" ls-files -- . 2>/dev/null)" \
  || refuse "cannot enumerate tracked files under $ROOT (is it a git repository?)"
files="$(printf '%s\n' "$tracked" | grep -c '[^[:space:]]')"
[ "${files:-0}" -ge 1 ] \
  || refuse "zero tracked files under $ROOT; a pass on an empty scan set is not evidence"

# --- Scan -------------------------------------------------------------------------------------
opts=(-n -I -E)
mode="case-sensitive"
if [ "$ci" -eq 1 ]; then opts+=(-i); mode="case-insensitive"; fi
if [ "$wordwise" -eq 1 ]; then opts+=(-w); mode="$mode, whole-word"; else mode="$mode, substring"; fi

errfile="$(mktemp "${TMPDIR:-/tmp}/km-leak-err.XXXXXX")" || refuse "cannot create a temporary file"
trap 'rm -f "$errfile"' EXIT

matches="$(git -C "$ROOT" grep "${opts[@]}" -e "$pattern" -- . 2>"$errfile")"
status=$?

case "$status" in
  0)
    printf '%s\n' "$matches"
    exit 1
    ;;
  1)
    echo "canonical leakage check passed: $mode, boundary syntax verified, $files tracked files scanned, no match"
    exit 0
    ;;
  *)
    [ -s "$errfile" ] && cat "$errfile" >&2
    refuse "git grep exited $status; the tree was not scanned"
    ;;
esac
