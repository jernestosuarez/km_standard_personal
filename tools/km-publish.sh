#!/usr/bin/env bash
# km-publish — shared renderer for hub-issued documents.
# Standard: STANDARD.md §"Artifact Generation (Push) — Rendering an issuable artifact (publish)"
#
#   bash km-publish.sh <source.html> [output.pdf]
#   bash km-publish.sh --check-guards <guards-file> <extracted-text-file> [page-count]
#
# Renders with WeasyPrint (self-bootstrapping venv in this directory), then applies the source's
# guards sidecar (<source-basename>.guards) to the rendered PDF's extracted text. One rule per line:
#
#   FORBID <ere>        build FAILS if the pattern is present  (case-insensitive)
#   FORBID-WORD <ere>   as FORBID, bounded to whole words      (case-insensitive)
#   REQUIRE <ere>       build FAILS if the pattern is absent
#   REQUIRE-WORD <ere>  as REQUIRE, bounded to whole words
#   PAGES <n>           warn if the page count differs
#   # comment
#
# ---------------------------------------------------------------------------------------------
# WHY THIS GUARD RUNNER LOOKS PARANOID (repaired in v1.30)
#
# A FORBID rule reports a defect by MATCHING, so its pass is an ABSENCE — and an absence is also
# what a mistyped verb, an invalid pattern, a boundary construct the engine ignores, and an
# unreadable PDF all produce. Guards exist because a correction motivated them, so a false pass
# here ships exactly the defect the document was corrected to remove, under a line that says
# "Guards passed". Every way this runner can fail to evaluate a rule therefore REFUSES (exit 2)
# instead of passing:
#
#   * every pattern is compiled by the grep that will actually run it, before the scan;
#   * a boundary construct written into a pattern (\b \B \< \> [[:<:]] [[:>:]]) is PROBED against
#     that same grep against a fixture with a known answer, and the run is refused when it proves
#     inert. This is per-tool and cannot be reasoned about from the platform: on one host
#     /usr/bin/grep -E honours \b while git grep -E ignores it and BSD sed ignores it, and an
#     ignored boundary matches nothing, which is what a clean document also looks like. Use the
#     -WORD verbs instead: grep implements whole-word matching (-w) above the regex engine, so
#     they hold on every host, and a guards file travels between hosts;
#   * extracted text that is missing, empty, or unreadable is refused, never scanned as clean;
#   * an unrecognised guard line is refused, not warned past: a rule that did not run must never
#     be reported inside a passing build;
#   * the passing line names the mode actually run — how many rules of which kind, that the
#     boundary syntax was verified, and how much text was scanned — so a recorded pass states
#     what was checked rather than merely asserting it.
#
# Proven in both directions by tests/test_km_publish_guards.sh, which drives --check-guards and
# needs neither WeasyPrint nor a PDF.
#
# Exit: 0  built, and guards passed (or none present)
#       1  a guard FAILED — the artifact must not be issued
#       2  REFUSED — usage, missing input, or a guard that could not be evaluated
# ---------------------------------------------------------------------------------------------
set -euo pipefail

refuse() { echo "GUARD REFUSED: $*" >&2; exit 2; }

# Does the grep on this host honour the boundary construct this rule uses? Probe the tool that
# will actually run the match, with the flags it will actually run, against a fixture whose answer
# is known: one line where the term stands alone, one where it is a prefix. An honoured construct
# matches the first line and only the first line.
boundary_honoured() {
  local probe="$1"; shift
  local out=""
  out=$(printf 'alpha probeword omega\nprobewordx tail\n' | grep -E "$@" -- "$probe" 2>/dev/null) || true
  [ "$out" = "alpha probeword omega" ]
}

inert() {
  local verb="$1" pat="$2" construct="$3"
  {
    echo "GUARD REFUSED: $verb $pat"
    echo "  The pattern uses $construct, which the 'grep -E' on this host IGNORES. An ignored"
    echo "  boundary matches nothing, and nothing is also what a clean document looks like, so the"
    echo "  build would report a false PASS on the very defect this guard was written to stop."
    echo "  Use ${verb}-WORD instead: grep implements whole-word matching above the regex engine,"
    echo "  so it holds on every host a guards file may be built on."
  } >&2
  exit 2
}

# Compile the pattern with the exact grep and flags that will run it, then probe any boundary
# construct it contains. Refuses rather than letting an unevaluable rule reach a passing build.
assert_expressible() {
  local pat="$1" verb="$2"; shift 2
  local st=0
  printf '' | grep -qE "$@" -- "$pat" >/dev/null 2>&1 || st=$?
  [ "$st" -le 1 ] || refuse "$verb pattern is not a valid extended regular expression: $pat"
  case "$pat" in
    *'\b'*|*'\B'*) boundary_honoured '\bprobeword\b' "$@" || inert "$verb" "$pat" '\b or \B' ;;
  esac
  case "$pat" in
    *'\<'*|*'\>'*) boundary_honoured '\<probeword\>' "$@" || inert "$verb" "$pat" '\< or \>' ;;
  esac
  case "$pat" in
    *'[[:<:]]'*|*'[[:>:]]'*)
      boundary_honoured '[[:<:]]probeword[[:>:]]' "$@" || inert "$verb" "$pat" '[[:<:]] or [[:>:]]' ;;
  esac
}

# Present-or-absent, read as three outcomes and never as two: found, not found, and "grep could
# not answer". The third is the one a boolean test silently converts into a pass.
matches() {
  local file="$1" pat="$2" verb="$3"; shift 3
  local st=0
  grep -qE "$@" -- "$pat" "$file" >/dev/null 2>&1 || st=$?
  case "$st" in
    0) return 0 ;;
    1) return 1 ;;
    *) refuse "grep exited $st evaluating $verb $pat; the text was not scanned" ;;
  esac
}

# Apply a guards file to a file of extracted text.
#   $1 guards file   $2 extracted-text file   $3 page count ("" if unknown)
# Returns 0 (all rules passed) or 1 (at least one rule failed). Refuses (exit 2) on anything it
# could not evaluate.
run_guards() {
  local guards="$1" textfile="$2" pages="${3:-}"
  local fail=0 lines=0 n_forbid=0 n_require=0 n_word=0 n_pages=0

  [ -f "$guards" ]   || refuse "guards file not found: $guards"
  [ -f "$textfile" ] || refuse "extracted-text file not found: $textfile"

  # Text the runner could not read is not text with nothing in it. A guards file evaluated against
  # empty extraction passes every FORBID rule it contains while checking nothing at all, which is
  # the exact false pass this runner exists to prevent.
  local chars
  chars=$(wc -c < "$textfile" | tr -d ' ')
  if [ "${chars:-0}" -eq 0 ] || ! grep -q '[^[:space:]]' "$textfile" 2>/dev/null; then
    refuse "the extracted text is empty (is pdftotext installed, and did the render produce text?);
  a guards file evaluated against no text passes every FORBID rule without checking anything"
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    lines=$((lines + 1))
    case "$line" in
      ''|\#*) ;;
      FORBID-WORD\ *)
        pat="${line#FORBID-WORD }"; n_forbid=$((n_forbid + 1)); n_word=$((n_word + 1))
        assert_expressible "$pat" FORBID -i -w
        if matches "$textfile" "$pat" FORBID -i -w; then
          echo "GUARD FAIL: forbidden whole-word pattern present: $pat" >&2; fail=1
        fi ;;
      FORBID\ *)
        pat="${line#FORBID }"; n_forbid=$((n_forbid + 1))
        assert_expressible "$pat" FORBID -i
        if matches "$textfile" "$pat" FORBID -i; then
          echo "GUARD FAIL: forbidden pattern present: $pat" >&2; fail=1
        fi ;;
      REQUIRE-WORD\ *)
        pat="${line#REQUIRE-WORD }"; n_require=$((n_require + 1)); n_word=$((n_word + 1))
        assert_expressible "$pat" REQUIRE -w
        if ! matches "$textfile" "$pat" REQUIRE -w; then
          echo "GUARD FAIL: required whole-word pattern missing: $pat" >&2; fail=1
        fi ;;
      REQUIRE\ *)
        pat="${line#REQUIRE }"; n_require=$((n_require + 1))
        assert_expressible "$pat" REQUIRE
        if ! matches "$textfile" "$pat" REQUIRE; then
          echo "GUARD FAIL: required pattern missing: $pat" >&2; fail=1
        fi ;;
      PAGES\ *)
        n="${line#PAGES }"; n_pages=$((n_pages + 1))
        case "$n" in
          ''|*[!0-9]*) refuse "PAGES takes a whole number, got: $n" ;;
        esac
        if [ -z "$pages" ]; then
          echo "WARN: PAGES $n could not be checked — the page count is unknown (is pdfinfo installed?)" >&2
        elif [ "$pages" -ne "$n" ]; then
          echo "WARN: expected $n pages, got $pages" >&2
        fi ;;
      *)
        # A warning here would leave a rule the author wrote unevaluated inside a build that then
        # announces "Guards passed". A guard that did not run is not a guard.
        refuse "unrecognised guard line: $line
  Recognised verbs: FORBID, FORBID-WORD, REQUIRE, REQUIRE-WORD, PAGES, and # comments." ;;
    esac
  done < "$guards"

  # A guards file that reads as empty is not a guards file with nothing in it. On cloud-synced
  # storage an on-demand placeholder returns empty on first read while its directory entry still
  # reports the real size, so the loop above would consume no lines and the build would announce
  # "Guards passed" having checked nothing.
  local gsz
  gsz=$(stat -f%z "$guards" 2>/dev/null || stat -c%s "$guards" 2>/dev/null || echo 0)
  if [ "${gsz:-0}" -gt 0 ] && [ "$lines" -eq 0 ]; then
    refuse "$(basename "$guards") is ${gsz} bytes on disk but read as empty (not downloaded?), so no guard was evaluated"
  fi
  if [ "$((n_forbid + n_require + n_pages))" -eq 0 ]; then
    refuse "$(basename "$guards") contains no guard rules, only blank lines or comments;
  a build cannot be reported as guarded by a file that asserts nothing"
  fi

  [ "$fail" -eq 0 ] || return 1

  echo "Guards passed ($(basename "$guards")): ${n_forbid} forbid, ${n_require} require (${n_word} whole-word), ${n_pages} pages; boundary syntax verified against grep -E on this host; ${chars} characters of extracted text scanned"
  return 0
}

# --- subcommand: evaluate a guards file against extracted text, no rendering -------------------
if [ "${1:-}" = "--check-guards" ]; then
  shift
  [ $# -ge 2 ] || refuse "usage: km-publish.sh --check-guards <guards-file> <extracted-text-file> [page-count]"
  gstatus=0
  run_guards "$1" "$2" "${3:-}" || gstatus=$?
  exit "$gstatus"
fi

# --- render ------------------------------------------------------------------------------------
[ $# -ge 1 ] || { echo "usage: km-publish.sh <source.html> [output.pdf]" >&2; exit 2; }
SRCDIR="$(cd "$(dirname "$1")" && pwd)"
SRC="$SRCDIR/$(basename "$1")"
[ -f "$SRC" ] || { echo "ERROR: source not found: $SRC" >&2; exit 2; }
OUT="${2:-${SRC%.html}.pdf}"
case "$OUT" in /*) ;; *) OUT="$SRCDIR/$OUT" ;; esac

TOOLS="$(cd "$(dirname "$0")" && pwd)"
VENV="$TOOLS/.venv"; PY="$VENV/bin/python"

if [ ! -x "$PY" ] || ! "$PY" -c "import weasyprint" >/dev/null 2>&1; then
  echo "Bootstrapping WeasyPrint into $VENV ..."
  BREWPY="$(ls -1 /opt/homebrew/bin/python3.1* 2>/dev/null | grep -v config | tail -1 || true)"
  if [ -z "$BREWPY" ]; then
    echo "ERROR: no Homebrew python3. One-off setup:  brew install python@3.12 pango gdk-pixbuf libffi" >&2
    echo "(Xcode's system python cannot work: macOS SIP strips DYLD_*, so it never finds libgobject.)" >&2
    exit 1
  fi
  "$BREWPY" -m venv "$VENV"
  "$VENV/bin/pip" install --quiet weasyprint
fi

"$PY" -m weasyprint "$SRC" "$OUT"
PAGES=$(pdfinfo "$OUT" 2>/dev/null | awk '/^Pages:/{print $2}' || true)
echo "Built $OUT (${PAGES:-?} pages)"

GUARDS="${SRC%.html}.guards"
if [ -f "$GUARDS" ]; then
  TXTFILE="$(mktemp "${TMPDIR:-/tmp}/km-publish-text.XXXXXX")"
  trap 'rm -f "$TXTFILE"' EXIT
  pdftotext "$OUT" "$TXTFILE" 2>/dev/null || true
  gstatus=0
  run_guards "$GUARDS" "$TXTFILE" "${PAGES:-}" || gstatus=$?
  if [ "$gstatus" -ne 0 ]; then
    echo "Build FAILED guards — output kept for inspection: $OUT" >&2
    exit "$gstatus"
  fi
else
  echo "No guards file — build unguarded ($(basename "$GUARDS") not found)"
fi
