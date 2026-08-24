#!/usr/bin/env bash
# km-publish — shared renderer for hub-issued documents.
# Standard: STANDARD.md §"Artifact Generation (Push) — Rendering an issuable artifact (publish)"
#
#   bash km-publish.sh <source.html> [output.pdf]
#   bash km-publish.sh --check-guards <guards-file> <extracted-text-file> [page-count]
#   bash km-publish.sh --preflight [source.html]
#
# Renders with WeasyPrint, bootstrapped at a pinned version into a virtual environment OUTSIDE the
# tree (see "BOOTSTRAP" below; added in v1.51, drafted and unpublished), then applies the source's
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
#       2  REFUSED: usage, missing input, a guard that could not be evaluated, or (added in v1.51,
#          drafted and unpublished) an environment the build could not be performed in at all: no
#          usable interpreter, an override that cannot work, a required external binary absent, or
#          a renderer that would not install. Exit 1 is a claim about the DOCUMENT, a guard fired,
#          and none of those are that. The bootstrap this replaces exited 1 on a missing
#          interpreter, which put "your document reintroduced a corrected defect" and "this host has
#          no Python" behind one status.
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

# ---------------------------------------------------------------------------------------------
# BOOTSTRAP: FINDING AN INTERPRETER, PINNING THE RENDERER, AND STAYING OUT OF THE TREE
# (added in v1.51, drafted and unpublished; this material binds nothing until its own owner push)
#
# What this replaces, quoted as it stood, because the shape of the defect is the argument:
#
#   BREWPY="$(ls -1 /opt/homebrew/bin/python3.1* 2>/dev/null | grep -v config | tail -1 || true)"
#   ...
#   echo "ERROR: no Homebrew python3. One-off setup:  brew install python@3.12 pango gdk-pixbuf libffi"
#   ...
#   "$VENV/bin/pip" install --quiet weasyprint
#
# Five defects in nine lines, and the density is not an accident: bootstrap code is written once on
# the author's machine, succeeds there, and is never exercised again on that machine because the
# environment it builds persists. The failure branch is the branch that never runs.
#
#   1. /opt/homebrew is the Apple Silicon Homebrew prefix and exists nowhere else. Intel macOS
#      Homebrew installs under /usr/local; Linux has no Homebrew prefix at all. Nothing else was
#      consulted, so a usable interpreter first on PATH was never seen.
#   2. The message was a wrong diagnosis stated confidently to the operator least able to see past
#      it: "no Homebrew python3" on a host that has a perfectly good Python, and `brew install` on
#      a platform where brew is not the package manager.
#   3. The install was unpinned, so the same script produced a different renderer over time. This
#      repository has paid for that class once: v1.40 quarantined the MCP surface after an unpinned
#      install resolved to a major version whose interface the code did not use. A renderer is a
#      worse place to learn it twice, because its output is issued outside the organisation.
#   4. The environment was built at tools/.venv, inside the repository, covered by no ignore rule.
#   5. template/hub-scan.sh did not exempt it, so a hub that rendered one document failed its own
#      [ INTEGRITY ] block at the start of every session afterwards, and the remedy an operator
#      reaches for is committing a virtual environment into a governed hub.
#
# Audit finding F-10.
#
# PLATFORM SUPPORT, CLAIMED ONLY WHERE IT WAS EXERCISED:
#   macOS on Apple Silicon (Darwin arm64)  EXERCISED. Discovery, the pin, and an end-to-end render.
#   Linux, Intel macOS, other Unix         WRITTEN AND UNVERIFIED. The path is portable by
#                                          construction and was not run on any of those hosts.
#                                          Saying so is the repair; claiming them would be a fresh
#                                          instance of the class this version closes.
#   Windows, native rather than WSL        OUT OF SCOPE, with the reason: WeasyPrint's native
#                                          library stack there is a separate problem, and it is not
#                                          claimed.
# ---------------------------------------------------------------------------------------------

# THE PIN. One name, one place, the reason beside it (see defect 3 above). An environment carrying
# any other version is rebuilt rather than used, so editing this line is sufficient to change what
# renders, and an environment left over from before the pin cannot survive as a silent third
# version.
WEASYPRINT_PIN="weasyprint==69.0"
WEASYPRINT_VERSION="69.0"

# THE INTERPRETER FLOOR, MEASURED RATHER THAN ASSUMED. weasyprint 69.0 declares
# `Requires-Python: >=3.10` in its own distribution metadata, which is where this number was read
# from. On the authoring host the consequence is visible: /usr/bin/python3 is 3.9.6 and is refused,
# /opt/homebrew/bin/python3.12 is accepted.
MIN_PY_MAJOR=3
MIN_PY_MINOR=10
MIN_PY="${MIN_PY_MAJOR}.${MIN_PY_MINOR}"

host_os="$(uname -s 2>/dev/null || echo unknown)"
host_arch="$(uname -m 2>/dev/null || echo unknown)"

have() { command -v "$1" >/dev/null 2>&1; }

# WHERE THE ENVIRONMENT LIVES: outside every governed tree, keyed by the pinned version, and
# overridable. Out-of-tree was chosen over ignore-in-place for one reason, and it is adoption
# rather than taste: an ignore rule has to reach every tree the tool can run in, including hubs
# created before this version whose .gitignore is a copy of the old one, and a deployment that
# misses that adoption action fails its own session-start scan. Moving the directory repairs every
# tree at once. The ignore rule and the scan exemption are added as well, because KM_PUBLISH_VENV
# lets an operator legitimately point the environment back inside a tree, and because a hub that
# already ran the old publisher has a tools/.venv sitting there today that no new tool removes.
default_venv() {
  local base
  if [ -n "${XDG_CACHE_HOME:-}" ]; then base="$XDG_CACHE_HOME/km-publish"
  elif [ -n "${HOME:-}" ]; then base="$HOME/.cache/km-publish"
  else base="${TMPDIR:-/tmp}/km-publish-$(id -u 2>/dev/null || echo 0)"
  fi
  printf '%s/venv-%s\n' "$base" "$WEASYPRINT_VERSION"
}
VENV="${KM_PUBLISH_VENV:-$(default_venv)}"
PY="$VENV/bin/python"

# The candidate names, newest first, and the prefixes searched after PATH. The prefixes exist for
# one real case rather than for completeness: a package manager installs outside the PATH a
# non-login shell inherits, which is exactly the Intel-macOS-Homebrew shape the old code
# half-handled and got wrong.
PY_CANDIDATES="python3.14 python3.13 python3.12 python3.11 python3.10 python3 python"
PY_PREFIXES="/opt/homebrew/bin /usr/local/bin /usr/bin /opt/local/bin"

# Two questions, not one. Version alone is not enough: several Linux distributions ship a python3
# that cannot create a virtual environment, and discovering that at `python3 -m venv` produces an
# error about ensurepip rather than about the interpreter, which sends the operator to the wrong
# place.
python_usable() {
  local p="${1:-}"
  [ -n "$p" ] || return 1
  command -v "$p" >/dev/null 2>&1 || return 1
  "$p" -c "import sys, venv, ensurepip; raise SystemExit(0 if sys.version_info >= (${MIN_PY_MAJOR}, ${MIN_PY_MINOR}) else 1)" \
    >/dev/null 2>&1
}

python_version_of() {
  "$1" -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])' 2>/dev/null || echo unknown
}

# Returns 0 and prints the interpreter; 2 when an override was set and cannot be used; 1 when the
# search found nothing. The override is never searched past: an override quietly ignored makes the
# operator's account of which interpreter ran false, which is worse than having no override at all.
discover_python() {
  local c d
  if [ -n "${KM_PUBLISH_PYTHON:-}" ]; then
    if python_usable "$KM_PUBLISH_PYTHON"; then
      command -v "$KM_PUBLISH_PYTHON"
      return 0
    fi
    return 2
  fi
  for c in $PY_CANDIDATES; do
    if python_usable "$c"; then command -v "$c"; return 0; fi
  done
  for d in $PY_PREFIXES; do
    for c in $PY_CANDIDATES; do
      if python_usable "$d/$c"; then printf '%s\n' "$d/$c"; return 0; fi
    done
  done
  return 1
}

# Platform-selected guidance. The macOS SIP sentence from the old error is real knowledge and is
# kept, as a note in the macOS branch, where it is worth reading, rather than as the whole
# diagnosis shown to everyone, where it was noise.
platform_hint() {
  case "$host_os" in
    Darwin)
      echo "  install:     brew install python@3.12 pango gdk-pixbuf libffi"
      echo "  macOS note:  Xcode's /usr/bin/python3 cannot work here even when it is new enough."
      echo "               Under System Integrity Protection the loader strips DYLD_* from"
      echo "               processes launched from protected system paths, so it never finds"
      echo "               libgobject, which WeasyPrint's cffi bindings load."
      ;;
    Linux)
      echo "  install:     sudo apt install python3 python3-venv libpango-1.0-0 libpangoft2-1.0-0 \\"
      echo "                                libharfbuzz0b libffi-dev        (Debian, Ubuntu)"
      echo "               sudo dnf install python3 python3-devel pango harfbuzz libffi"
      echo "                                                                (Fedora, RHEL)"
      echo "  note:        this Linux guidance is WRITTEN AND UNVERIFIED. It was not exercised on"
      echo "               a Linux host, and it says so rather than implying that it was."
      ;;
    *)
      echo "  install:     CPython ${MIN_PY} or newer with venv and ensurepip, plus the native"
      echo "               pango, cairo, harfbuzz and libffi libraries WeasyPrint's cffi bindings"
      echo "               load."
      echo "  note:        this path is WRITTEN AND UNVERIFIED on ${host_os}."
      ;;
  esac
}

requirement_lines() {
  echo "  platform:    ${host_os} ${host_arch}"
  echo "  requires:    CPython ${MIN_PY} or newer, able to create a virtual environment"
  echo "               (the pinned renderer ${WEASYPRINT_PIN} declares Requires-Python >=${MIN_PY})"
}

no_python() {
  {
    echo "ERROR: km-publish found no usable Python on this host."
    requirement_lines
    echo "  searched:    PATH, for ${PY_CANDIDATES}"
    echo "               then ${PY_PREFIXES}"
    echo "  override:    set KM_PUBLISH_PYTHON to the interpreter you want used, e.g."
    echo "               KM_PUBLISH_PYTHON=/usr/local/bin/python3.12 bash km-publish.sh doc.html"
    platform_hint
  } >&2
  exit 2
}

bad_override() {
  {
    echo "ERROR: KM_PUBLISH_PYTHON names an interpreter km-publish cannot use."
    echo "  KM_PUBLISH_PYTHON=${KM_PUBLISH_PYTHON}"
    if have "${KM_PUBLISH_PYTHON}"; then
      echo "  found:       $(command -v "${KM_PUBLISH_PYTHON}") (Python $(python_version_of "${KM_PUBLISH_PYTHON}"))"
      echo "  rejected:    it is below ${MIN_PY}, or it cannot import venv and ensurepip."
    else
      echo "  rejected:    it is not on PATH and is not an executable file."
    fi
    requirement_lines
    echo "  km-publish does NOT fall back to a search here. An override that is quietly ignored"
    echo "  leaves the operator with a false account of which interpreter ran."
    platform_hint
  } >&2
  exit 2
}

# An external binary this build genuinely needs. Checked BEFORE the work that depends on it: the
# same absence reported afterwards arrives as a confusing downstream error: an empty page count,
# or extracted text the guard runner has to refuse, and asks a question that could have been
# answered before anything was rendered.
need_binary() {
  have "$1" && return 0
  {
    echo "ERROR: km-publish needs '$1' and it is not on PATH."
    echo "  needed for:  $2"
    echo "  platform:    ${host_os} ${host_arch}"
    case "$host_os" in
      Darwin) echo "  install:     brew install poppler" ;;
      Linux)
        echo "  install:     sudo apt install poppler-utils     (Debian, Ubuntu)"
        echo "               sudo dnf install poppler-utils     (Fedora, RHEL)"
        echo "  note:        this Linux guidance is WRITTEN AND UNVERIFIED." ;;
      *)      echo "  install:     the poppler utilities, which supply pdfinfo and pdftotext" ;;
    esac
  } >&2
  exit 2
}

# Is the environment present AND carrying the pinned version? Two questions, because an environment
# that imports weasyprint at some other version is exactly the drift the pin exists to remove.
venv_ready() {
  [ -x "$PY" ] || return 1
  local v=""
  v="$("$PY" -c 'import weasyprint; print(weasyprint.__version__)' 2>/dev/null)" || return 1
  [ "$v" = "$WEASYPRINT_VERSION" ]
}

resolve_python_or_die() {
  local st=0 p=""
  p="$(discover_python)" || st=$?
  case "$st" in
    0) printf '%s\n' "$p" ;;
    2) bad_override ;;
    *) no_python ;;
  esac
}

# --- subcommand: evaluate a guards file against extracted text, no rendering -------------------
if [ "${1:-}" = "--check-guards" ]; then
  shift
  [ $# -ge 2 ] || refuse "usage: km-publish.sh --check-guards <guards-file> <extracted-text-file> [page-count]"
  gstatus=0
  run_guards "$1" "$2" "${3:-}" || gstatus=$?
  exit "$gstatus"
fi

# --- subcommand: resolve the environment and the external tools, render nothing ----------------
# This is what makes the bootstrap testable (added in v1.51, drafted and unpublished). Before it,
# reaching the bootstrap required a render, so the branch that fails on every host but the author's
# was the branch nothing could exercise. --preflight runs discovery and the binary checks, reports
# what it resolved, installs nothing, and refuses on anything that would fail a real build.
if [ "${1:-}" = "--preflight" ]; then
  shift
  PRESRC=""
  if [ $# -ge 1 ]; then
    PRESRC="$1"
    [ -f "$PRESRC" ] || refuse "source not found: $PRESRC"
  fi
  PREPY="$(resolve_python_or_die)"
  echo "platform:   ${host_os} ${host_arch}"
  echo "python:     ${PREPY} (Python $(python_version_of "$PREPY"))"
  echo "pin:        ${WEASYPRINT_PIN}"
  if venv_ready; then
    echo "venv:       ${VENV} (present, ${WEASYPRINT_VERSION})"
  elif [ -e "$VENV" ]; then
    echo "venv:       ${VENV} (present but not at the pin; it would be rebuilt)"
  else
    echo "venv:       ${VENV} (absent; it would be bootstrapped)"
  fi
  if have pdfinfo; then
    echo "pdfinfo:    $(command -v pdfinfo)"
  else
    echo "pdfinfo:    MISSING: the page count will be unknown and a PAGES rule cannot be checked (poppler supplies it)"
  fi
  if have pdftotext; then
    echo "pdftotext:  $(command -v pdftotext)"
  else
    echo "pdftotext:  MISSING (poppler supplies it)"
    if [ -n "$PRESRC" ] && [ -f "${PRESRC%.html}.guards" ]; then
      need_binary pdftotext "applying $(basename "${PRESRC%.html}.guards") to the rendered PDF's extracted text"
    fi
  fi
  echo "preflight OK"
  exit 0
fi

# --- render ------------------------------------------------------------------------------------
[ $# -ge 1 ] || { echo "usage: km-publish.sh <source.html> [output.pdf]" >&2
                  echo "       km-publish.sh --check-guards <guards-file> <extracted-text-file> [page-count]" >&2
                  echo "       km-publish.sh --preflight [source.html]" >&2; exit 2; }
SRCDIR="$(cd "$(dirname "$1")" && pwd)"
SRC="$SRCDIR/$(basename "$1")"
[ -f "$SRC" ] || { echo "ERROR: source not found: $SRC" >&2; exit 2; }
OUT="${2:-${SRC%.html}.pdf}"
case "$OUT" in /*) ;; *) OUT="$SRCDIR/$OUT" ;; esac
GUARDS="${SRC%.html}.guards"

# The external tools, before the work. pdftotext and pdfinfo are NOT the same requirement, and
# treating them alike would be wrong in one direction or the other. Guards are applied to extracted
# text, so without pdftotext a guarded build cannot be evaluated at all, and that is a refusal. The
# page count only decorates the build line and drives PAGES, which is a warning rule by contract, so
# a missing pdfinfo warns and the build proceeds.
if [ -f "$GUARDS" ]; then
  need_binary pdftotext "applying $(basename "$GUARDS") to the rendered PDF's extracted text"
fi
if ! have pdfinfo; then
  echo "WARN: pdfinfo is not on PATH, so the page count is unknown and any PAGES rule cannot be checked (poppler supplies it)." >&2
fi

if ! venv_ready; then
  PYBOOT="$(resolve_python_or_die)"
  echo "Bootstrapping ${WEASYPRINT_PIN} into ${VENV} using ${PYBOOT} (Python $(python_version_of "$PYBOOT")) ..."
  if [ -e "$VENV" ]; then
    # Fail closed rather than remove something this script did not build. KM_PUBLISH_VENV is an
    # operator-supplied path, and `rm -rf` on an operator-supplied path with no test is how a tool
    # deletes a home directory.
    case "$VENV" in
      ""|/) echo "ERROR: refusing to rebuild an environment at '$VENV'." >&2; exit 2 ;;
    esac
    [ -f "$VENV/pyvenv.cfg" ] || {
      echo "ERROR: $VENV exists and is not a virtual environment, so km-publish will not remove it." >&2
      echo "       Set KM_PUBLISH_VENV to a path km-publish may own." >&2
      exit 2
    }
    rm -rf "$VENV"
  fi
  mkdir -p "$(dirname "$VENV")"
  "$PYBOOT" -m venv "$VENV" || {
    echo "ERROR: ${PYBOOT} could not create a virtual environment at ${VENV}." >&2; exit 2; }
  "$VENV/bin/pip" install --quiet --disable-pip-version-check "$WEASYPRINT_PIN" || {
    echo "ERROR: could not install ${WEASYPRINT_PIN} into ${VENV}." >&2
    echo "       This step needs network access on first run, and on some platforms a compiler for" >&2
    echo "       the cffi bindings." >&2
    exit 2; }
  venv_ready || {
    echo "ERROR: ${VENV} was built but does not import ${WEASYPRINT_VERSION}." >&2; exit 2; }
fi

"$PY" -m weasyprint "$SRC" "$OUT"
PAGES=$(pdfinfo "$OUT" 2>/dev/null | awk '/^Pages:/{print $2}' || true)
echo "Built $OUT (${PAGES:-?} pages)"

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
