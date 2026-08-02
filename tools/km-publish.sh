#!/usr/bin/env bash
# km-publish — shared renderer for hub-issued documents.
# Standard: STANDARD.md §"Artifact Generation (Push) — Rendering an issuable artifact (publish)"
#
#   bash km-publish.sh <source.html> [output.pdf]
#
# Renders with WeasyPrint (self-bootstrapping venv in this directory), then applies the
# source's guards sidecar (<source-basename>.guards) if present:
#   FORBID <regex>   — build fails if present in the rendered text (case-insensitive)
#   REQUIRE <regex>  — build fails if absent
#   PAGES <n>        — warn if page count differs
set -euo pipefail

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
PAGES=$(pdfinfo "$OUT" 2>/dev/null | awk '/^Pages:/{print $2}')
echo "Built $OUT (${PAGES:-?} pages)"

GUARDS="${SRC%.html}.guards"
if [ -f "$GUARDS" ]; then
  TXT=$(pdftotext "$OUT" - 2>/dev/null || true)
  FAIL=0
  LINES=0
  while IFS= read -r line || [ -n "$line" ]; do
    LINES=$((LINES + 1))
    case "$line" in
      ''|\#*) ;;
      FORBID\ *)  pat="${line#FORBID }"
                  if grep -qiE -- "$pat" <<<"$TXT"; then echo "GUARD FAIL: forbidden pattern present: $pat" >&2; FAIL=1; fi ;;
      REQUIRE\ *) pat="${line#REQUIRE }"
                  if ! grep -qE -- "$pat" <<<"$TXT"; then echo "GUARD FAIL: required pattern missing: $pat" >&2; FAIL=1; fi ;;
      PAGES\ *)   n="${line#PAGES }"
                  [ "${PAGES:-0}" -eq "$n" ] 2>/dev/null || echo "WARN: expected $n pages, got ${PAGES:-?}" >&2 ;;
      *) echo "WARN: unrecognised guard line ignored: $line" >&2 ;;
    esac
  done < "$GUARDS"
  # A guards file that reads as empty is not a guards file with nothing in it. On cloud-synced
  # storage an on-demand placeholder returns empty on first read while its directory entry still
  # reports the real size, so the loop above would consume no lines and the build would announce
  # "Guards passed" having checked nothing. Never claim a pass for a check that did not run.
  GSZ=$(stat -f%z "$GUARDS" 2>/dev/null || stat -c%s "$GUARDS" 2>/dev/null || echo 0)
  if [ "${GSZ:-0}" -gt 0 ] && [ "$LINES" -eq 0 ]; then
    echo "GUARD FAIL: $(basename "$GUARDS") is ${GSZ} bytes on disk but read as empty (not downloaded?), so no guard was evaluated" >&2
    echo "Build FAILED guards, output kept for inspection: $OUT" >&2
    exit 1
  fi
  [ "$FAIL" -eq 0 ] || { echo "Build FAILED guards — output kept for inspection: $OUT" >&2; exit 1; }
  echo "Guards passed ($(basename "$GUARDS"))"
else
  echo "No guards file — build unguarded ($(basename "$GUARDS") not found)"
fi
