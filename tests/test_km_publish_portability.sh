#!/bin/bash
# km-unrepaired-tree: v1.51 | case 10 is the unrepaired-tree run: tools/km-publish.sh is extracted from published main at 44622d5 and driven with `ls` shimmed to return nothing, which is what a host with no Apple Silicon Homebrew prefix presents, while a usable python3.12 stands first on PATH; it exits 1 with "ERROR: no Homebrew python3. One-off setup:  brew install python@3.12 pango gdk-pixbuf libffi" and never looks at PATH. Case 11 is the second unrepaired run: template/hub-scan.sh extracted from the same commit, over a fixture hub carrying tools/.venv/, prints "! UNCOMMITTED OR UNTRACKED MONITORED FILES: ?? tools/.venv/" in its [ INTEGRITY ] block. Case 11d is the third: the same unrepaired scan, over the same fixture hub with a LICENSE.md placed inside tools/.venv/ (which is what the pinned renderer's environment actually carries under site-packages), indexes 23 note names against the repaired scan's 22, so the vendored licence was a name a hub wiki-link could have resolved against. All three are paired here with the repaired tree on the same input, which is what makes any of them evidence.
# Canaries for the publisher's portability repair in tools/km-publish.sh, template/hub-scan.sh and
# the two ignore files (v1.51). Audit finding F-10.
#
# WHY THIS FILE EXISTS
#
# tests/test_km_publish_guards.sh exercises the guard ENGINE and is deliberately untouched by this
# change. Nothing had ever exercised the BOOTSTRAP, and the reason is structural rather than an
# oversight: reaching the bootstrap required a render, and once a render succeeds on the author's
# machine the environment persists and the bootstrap never runs again there. The failure branch,
# the one every host except the author's takes, was the branch nothing could reach. Five defects
# accumulated in nine lines behind that.
#
# The --preflight subcommand added in v1.51 is what makes these cases possible: it runs discovery
# and the binary checks, reports what it resolved, installs nothing and renders nothing.
#
# HOW THE HOSTILE ENVIRONMENTS ARE BUILT, AND WHAT EACH ONE COSTS IN EVIDENCE
#
# Two cases cannot be produced by environment alone on a host that HAS a working interpreter in the
# conventional prefixes, because those prefixes are real directories this suite must not touch. Both
# are produced by a one-line fixture edit to a COPY of the tool, and the edit is named in the case so
# a reader can weigh it:
#
#   * case 5 replaces the candidate NAME LIST with a name that exists nowhere. The prefix loop still
#     runs over the four real prefixes and the real refusal path still fires; only the names searched
#     differ. This is stronger than faking directories, which would have exercised a loop over
#     fixtures rather than over the machine.
#   * case 6 empties the PREFIX LIST, so discovery must succeed from PATH alone. That is the exact
#     thing the unrepaired code could not do.
#
# Everything else is real: real interpreters, the real PATH, the real git, the real hub scan.
#
# WHAT THESE CASES CANNOT DO: the stated limit
#
# They prove the repaired tool refuses and resolves on the class of environment they model, on THIS
# host. They cannot prove it renders on a host this session did not have. One end-to-end render was
# performed by hand here, macOS on Apple Silicon, with the pinned renderer; the Linux path is written
# and unverified and the shipped text says so. A canary is also blind to a defect whose shape the
# fixture cannot represent: if the conventional prefix list is simply wrong for some distribution,
# every case here still passes.
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="$ROOT/tools/km-publish.sh"
SCAN="$ROOT/template/hub-scan.sh"
BASE_REV="44622d5"          # published v1.50, the tree these repairs are measured against

work="$(mktemp -d "${TMPDIR:-/tmp}/km-portability.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail=0
n_pass=0
n_gap=0
pass() { echo "PASS: $1"; n_pass=$((n_pass + 1)); }
die()  { echo "FAIL: $1"; fail=1; }
gap()  { echo "GAP:  $1"; n_gap=$((n_gap + 1)); }

[ -f "$TOOL" ] || { echo "FAIL: tool not found at $TOOL"; exit 1; }
[ -f "$SCAN" ] || { echo "FAIL: hub scan not found at $SCAN"; exit 1; }

BASH_BIN="$(command -v bash)"
[ -n "$BASH_BIN" ] || { echo "FAIL: bash is not on PATH"; exit 1; }

SRC="$work/doc.html"
printf '<html><body><h1>Synthetic probe</h1><p>portability</p></body></html>\n' > "$SRC"

# Run --preflight. Status captured directly, never through a pipe: a pipeline's status is the last
# command's and not the tool's, which is this suite's own discipline as much as the guard suite's.
preflight() {
  out="$("$BASH_BIN" "$TOOL" --preflight "$@" 2>&1)"
  st=$?
}

# --- 1. preflight resolves an environment and states what it resolved ---------------------------
preflight
if [ "$st" -eq 0 ] \
   && printf '%s\n' "$out" | grep -q '^platform: ' \
   && printf '%s\n' "$out" | grep -q '^python: ' \
   && printf '%s\n' "$out" | grep -q '^pin: ' \
   && printf '%s\n' "$out" | grep -q '^venv: ' \
   && printf '%s\n' "$out" | grep -q '^preflight OK$'; then
  pass "1. preflight resolves an environment and reports platform, interpreter, pin and venv"
else
  die "1. preflight did not resolve: status $st, output: $out"
fi

RESOLVED_PY="$(printf '%s\n' "$out" | awk '/^python: /{print $2}')"

# --- 2. an explicit override is honoured ---------------------------------------------------------
if [ -n "$RESOLVED_PY" ] && [ -x "$RESOLVED_PY" ]; then
  out="$(KM_PUBLISH_PYTHON="$RESOLVED_PY" "$BASH_BIN" "$TOOL" --preflight 2>&1)"; st=$?
  if [ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -q "^python: *$RESOLVED_PY "; then
    pass "2. KM_PUBLISH_PYTHON is honoured and the interpreter it names is the one reported"
  else
    die "2. override not honoured: status $st, output: $out"
  fi
else
  gap "2. no resolved interpreter to re-supply as an override"
fi

# --- 3. an override that cannot work is refused BY NAME and is not searched past -----------------
out="$(KM_PUBLISH_PYTHON=/no/such/interpreter "$BASH_BIN" "$TOOL" --preflight 2>&1)"; st=$?
if [ "$st" -eq 2 ] \
   && printf '%s\n' "$out" | grep -q 'KM_PUBLISH_PYTHON=/no/such/interpreter' \
   && printf '%s\n' "$out" | grep -q 'not on PATH' \
   && printf '%s\n' "$out" | grep -q 'does NOT fall back to a search' \
   && ! printf '%s\n' "$out" | grep -q '^preflight OK$'; then
  pass "3. an override naming a missing interpreter is refused, quoted back, and not searched past"
else
  die "3. bad override not refused as specified: status $st, output: $out"
fi

# --- 4. an interpreter below the measured floor is rejected --------------------------------------
# The floor is the pinned renderer's own Requires-Python, and this case uses a REAL interpreter below
# it rather than a fixture. A host with nothing below the floor reports a gap: an absent case is a
# coverage gap and never a pass.
OLD_PY=""
for cand in /usr/bin/python3 python3.9 python3.8 /usr/bin/python; do
  p="$(command -v "$cand" 2>/dev/null)" || continue
  [ -n "$p" ] || continue
  if ! "$p" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)' >/dev/null 2>&1; then
    OLD_PY="$p"; break
  fi
done
if [ -n "$OLD_PY" ]; then
  out="$(KM_PUBLISH_PYTHON="$OLD_PY" "$BASH_BIN" "$TOOL" --preflight 2>&1)"; st=$?
  if [ "$st" -eq 2 ] \
     && printf '%s\n' "$out" | grep -q "KM_PUBLISH_PYTHON=$OLD_PY" \
     && printf '%s\n' "$out" | grep -q 'CPython 3.10 or newer' \
     && printf '%s\n' "$out" | grep -q 'Requires-Python'; then
    pass "4. an interpreter below the floor ($OLD_PY) is rejected, and the refusal names the minimum"
  else
    die "4. below-floor interpreter not rejected as specified: status $st, output: $out"
  fi
else
  gap "4. this host carries no interpreter below the 3.10 floor, so the rejection branch was not exercised"
fi

# --- 5. no usable interpreter anywhere: the refusal names the platform and the requirement -------
# Fixture edit, named: the candidate NAME LIST is replaced with a name that exists nowhere. The PATH
# search and the loop over the four real conventional prefixes both run for real.
sed 's/^PY_CANDIDATES=.*/PY_CANDIDATES="python9.99"/' "$TOOL" > "$work/nopy.sh"
if grep -q '^PY_CANDIDATES="python9.99"$' "$work/nopy.sh"; then
  out="$("$BASH_BIN" "$work/nopy.sh" --preflight 2>&1)"; st=$?
  host_os="$(uname -s 2>/dev/null || echo unknown)"
  if [ "$st" -eq 2 ] \
     && printf '%s\n' "$out" | grep -q 'found no usable Python' \
     && printf '%s\n' "$out" | grep -q "platform: *$host_os" \
     && printf '%s\n' "$out" | grep -q 'CPython 3.10 or newer' \
     && printf '%s\n' "$out" | grep -q 'searched: *PATH' \
     && printf '%s\n' "$out" | grep -q 'KM_PUBLISH_PYTHON' \
     && ! printf '%s\n' "$out" | grep -q 'no Homebrew python3'; then
    pass "5. discovery failure names the platform, the requirement, what was searched, and the override"
  else
    die "5. discovery failure message wrong: status $st, output: $out"
  fi
else
  die "5. the fixture edit did not apply, so nothing about discovery failure was proved"
fi

# --- 6. discovery works from PATH alone, with no package-manager prefix consulted ----------------
# This is the thing the unrepaired tool could not do at all.
sed 's|^PY_PREFIXES=.*|PY_PREFIXES=""|' "$TOOL" > "$work/nopfx.sh"
if grep -q '^PY_PREFIXES=""$' "$work/nopfx.sh"; then
  out="$("$BASH_BIN" "$work/nopfx.sh" --preflight 2>&1)"; st=$?
  if [ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -q '^python: '; then
    pass "6. an interpreter is found from PATH alone, with the conventional prefixes removed"
  else
    die "6. PATH-only discovery failed: status $st, output: $out"
  fi
else
  die "6. the fixture edit did not apply, so PATH-only discovery was not proved"
fi

# --- 7. the dependency is pinned, and the pin is what preflight reports --------------------------
if grep -qE '^WEASYPRINT_PIN="weasyprint==[0-9]+(\.[0-9]+)*"$' "$TOOL"; then
  pin="$(sed -n 's/^WEASYPRINT_PIN="\(.*\)"$/\1/p' "$TOOL")"
  preflight
  if printf '%s\n' "$out" | grep -q "^pin: *$pin$"; then
    pass "7. the dependency is pinned ($pin) and preflight reports that same pin"
  else
    die "7. preflight does not report the pin held in the tool: $pin; output: $out"
  fi
else
  die "7. no pinned WEASYPRINT_PIN in $TOOL: an unpinned install resolves to a different renderer over time"
fi
# Comment lines are stripped first: the tool quotes the old unpinned line verbatim in its own
# explanation of the defect, and a check that cannot tell a quotation from code would report the
# record of the repair as the defect.
if grep -vE '^[[:space:]]*#' "$TOOL" | grep -qE 'pip[^#]*install[^#]*[[:space:]]weasyprint[[:space:]]*$'; then
  die "7b. an unpinned 'pip install weasyprint' is still present in the tool"
else
  pass "7b. no unpinned install of the renderer remains in the tool"
fi

# --- 8. the environment is outside the tree by default, and relocatable -------------------------
preflight
venvpath="$(printf '%s\n' "$out" | awk '/^venv: /{print $2}')"
case "$venvpath" in
  "$ROOT"/*) die "8. the default environment is inside the repository: $venvpath" ;;
  "") die "8. preflight reported no environment path" ;;
  *) pass "8. the default environment is outside the repository ($venvpath)" ;;
esac
out="$(KM_PUBLISH_VENV="$work/relocated" "$BASH_BIN" "$TOOL" --preflight 2>&1)"; st=$?
if [ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -q "^venv: *$work/relocated "; then
  pass "8b. KM_PUBLISH_VENV relocates the environment"
else
  die "8b. KM_PUBLISH_VENV was not honoured: status $st, output: $out"
fi

# --- 9. the external binaries are checked by name, and the two are not the same requirement ------
# A sandbox PATH is built from a fixed list of utilities, deliberately omitting the poppler pair.
sandbox="$work/sandbox-bin"
mkdir -p "$sandbox"
for b in uname id basename dirname mktemp grep awk sed cat rm mkdir stat wc tr ls env sh; do
  src="$(command -v "$b" 2>/dev/null)" || continue
  [ -n "$src" ] && ln -sf "$src" "$sandbox/$b"
done
if PATH="$sandbox" command -v pdftotext >/dev/null 2>&1; then
  gap "9. pdftotext is reachable from the sandbox PATH, so its absence could not be simulated"
elif [ -z "$RESOLVED_PY" ]; then
  gap "9. no interpreter to supply as an override inside the sandbox PATH"
else
  printf 'FORBID zorbnix\n' > "$work/doc.guards"
  out="$(PATH="$sandbox" KM_PUBLISH_PYTHON="$RESOLVED_PY" "$BASH_BIN" "$TOOL" --preflight "$SRC" 2>&1)"; st=$?
  if [ "$st" -eq 2 ] \
     && printf '%s\n' "$out" | grep -q "needs 'pdftotext'" \
     && printf '%s\n' "$out" | grep -qi 'poppler'; then
    pass "9. a guarded source with pdftotext absent is refused before rendering, naming the binary and poppler"
  else
    die "9. missing pdftotext not reported as specified: status $st, output: $out"
  fi
  if printf '%s\n' "$out" | grep -q '^pdfinfo: *MISSING'; then
    pass "9b. a missing pdfinfo is named, and its consequence for the page count is stated"
  else
    die "9b. missing pdfinfo not named: $out"
  fi
  rm -f "$work/doc.guards"
  out="$(PATH="$sandbox" KM_PUBLISH_PYTHON="$RESOLVED_PY" "$BASH_BIN" "$TOOL" --preflight "$SRC" 2>&1)"; st=$?
  if [ "$st" -eq 0 ] && printf '%s\n' "$out" | grep -q '^preflight OK$'; then
    pass "9c. an unguarded source with pdftotext absent is NOT refused: nothing needed it"
  else
    die "9c. an unguarded build was blocked by a binary it does not need: status $st, output: $out"
  fi
fi

# --- 10. THE UNREPAIRED-TREE RUN, and the repaired tree on the same input ------------------------
if ! git -C "$ROOT" rev-parse --verify --quiet "${BASE_REV}^{commit}" >/dev/null 2>&1; then
  gap "10. $BASE_REV is not present in this clone, so the unrepaired publisher could not be run"
elif ! git -C "$ROOT" show "$BASE_REV:tools/km-publish.sh" > "$work/old-publish.sh" 2>/dev/null; then
  gap "10. tools/km-publish.sh could not be read out of $BASE_REV"
else
  # `ls` is shimmed to return nothing, which is exactly what /opt/homebrew/bin/python3.1* yields on
  # Intel macOS and on Linux. Nothing else is changed: a usable interpreter is first on PATH.
  mkdir -p "$work/lsshim"
  printf '#!/bin/sh\nexit 1\n' > "$work/lsshim/ls"
  chmod +x "$work/lsshim/ls"
  out="$(PATH="$work/lsshim:$PATH" "$BASH_BIN" "$work/old-publish.sh" "$SRC" 2>&1)"; st=$?
  if [ "$st" -eq 1 ] \
     && printf '%s\n' "$out" | grep -q 'no Homebrew python3' \
     && printf '%s\n' "$out" | grep -q 'brew install'; then
    pass "10. the UNREPAIRED publisher from $BASE_REV fails on a host with no Homebrew prefix, prescribing brew"
  else
    die "10. the unrepaired run did not reproduce: status $st, output: $out"
  fi
  # The other direction, same shimmed environment, same source.
  out="$(PATH="$work/lsshim:$PATH" "$BASH_BIN" "$TOOL" --preflight "$SRC" 2>&1)"; st=$?
  if [ "$st" -eq 0 ] \
     && printf '%s\n' "$out" | grep -q '^preflight OK$' \
     && ! printf '%s\n' "$out" | grep -q 'Homebrew'; then
    pass "10b. the REPAIRED publisher resolves an interpreter in that same environment"
  else
    die "10b. the repaired tool did not resolve where the unrepaired one failed: status $st, output: $out"
  fi
fi

# --- 11. the hub scan: an environment directory must not fail a hub's own integrity check --------
# The fixture hub is built from template/ and committed, then an environment directory is created in
# it. The [ INTEGRITY ] BLOCK is what is asserted, never the scan's overall exit status: a fixture hub
# built this cheaply carries unrelated findings, and reading the whole verdict would make this case
# pass or fail for reasons that have nothing to do with .venv.
integrity_block() { sed -n '/\[ INTEGRITY \]/,/^$/p' "$1"; }

# The fixture is deliberately a LEGACY hub: its .gitignore is the one shipped at $BASE_REV, with no
# rule for a virtual environment. That is the hard case and the one that matters: a hub created
# before v1.51 does not get a new ignore file when its owner takes a new tool, and it isolates the
# scan exemption as the thing being proved, rather than letting the repaired ignore file do the work.
hub="$work/hub"
mkdir -p "$hub"
cp -R "$ROOT/template/." "$hub/"
mkdir -p "$hub/tools"
cp "$TOOL" "$hub/tools/"
legacy_ignore=0
if git -C "$ROOT" show "$BASE_REV:template/.gitignore" > "$hub/.gitignore" 2>/dev/null; then
  legacy_ignore=1
fi
git -C "$hub" init -q .
git -C "$hub" add -A
git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' commit -qm fixture
mkdir -p "$hub/tools/.venv/bin" "$hub/.venv/bin"
echo x > "$hub/tools/.venv/bin/python"
echo x > "$hub/.venv/bin/python"

if [ "$legacy_ignore" -ne 1 ]; then
  gap "11. template/.gitignore could not be read out of $BASE_REV, so the legacy-hub fixture was not built"
elif grep -q '\.venv' "$hub/.gitignore"; then
  die "11. the fixture's legacy .gitignore already mentions .venv, so the case proves nothing"
elif git -C "$ROOT" show "$BASE_REV:template/hub-scan.sh" > "$hub/hub-scan-unrepaired.sh" 2>/dev/null; then
  "$BASH_BIN" "$hub/hub-scan-unrepaired.sh" > "$work/scan-old.txt" 2>&1
  if integrity_block "$work/scan-old.txt" | grep -q 'UNCOMMITTED OR UNTRACKED' \
     && integrity_block "$work/scan-old.txt" | grep -q '\.venv'; then
    pass "11. the UNREPAIRED hub scan from $BASE_REV reports the environment directory as a monitored defect"
  else
    die "11. the unrepaired scan did not fire on .venv: $(integrity_block "$work/scan-old.txt")"
  fi
  rm -f "$hub/hub-scan-unrepaired.sh"
else
  gap "11. template/hub-scan.sh could not be read out of $BASE_REV"
fi

# The repaired scan, same hub, same directories. The scan is copied in rather than run from the
# repository because hub-scan.sh derives the hub from its own location.
cp "$SCAN" "$hub/hub-scan.sh"
"$BASH_BIN" "$hub/hub-scan.sh" > "$work/scan-new.txt" 2>&1
if integrity_block "$work/scan-new.txt" | grep -q '\.venv'; then
  die "11b. the repaired scan still reports the environment directory: $(integrity_block "$work/scan-new.txt")"
else
  pass "11b. the repaired hub scan does not report a virtual environment at any depth, in a hub whose ignore file predates v1.51"
fi

# And the exemption must not have blinded the block. A genuinely untracked monitored document is
# introduced, and the block is required to fire on it: an exclusion that silently swallows everything
# looks identical to a clean hub, which is the failure class this repository writes canaries for.
printf -- '---\ntype: brief\n---\n\n# Synthetic\n' > "$hub/99_synthetic.md"
"$BASH_BIN" "$hub/hub-scan.sh" > "$work/scan-new2.txt" 2>&1
if integrity_block "$work/scan-new2.txt" | grep -q 'UNCOMMITTED OR UNTRACKED' \
   && integrity_block "$work/scan-new2.txt" | grep -q '99_synthetic.md'; then
  pass "11c. the repaired block still fires on a genuinely untracked monitored document"
else
  die "11c. the exemption blinded the block: $(integrity_block "$work/scan-new2.txt")"
fi

# --- 11d. the walk exclusions: a markdown file inside an environment is not a hub note -----------
# [ INTEGRITY ] is not the only walk that reaches an environment directory. The environment the
# pinned renderer builds carries LICENSE.md files under site-packages, and the [ LINKS ] note index
# walks the whole hub for *.md, so without an exclusion a vendored licence becomes a name a hub
# wiki-link can resolve against. Unrepaired and repaired are run on the SAME fixture with the same
# file present, which is what makes the difference evidence rather than a count.
indexed_of() { sed -n 's/.*resolve against \([0-9][0-9]*\) indexed note name(s).*/\1/p' "$1" | head -1; }
printf -- '# vendored licence\n' > "$hub/tools/.venv/LICENSE.md"
old_idx=""
if git -C "$ROOT" show "$BASE_REV:template/hub-scan.sh" > "$hub/hub-scan-unrepaired.sh" 2>/dev/null; then
  "$BASH_BIN" "$hub/hub-scan-unrepaired.sh" > "$work/scan-old-md.txt" 2>&1
  old_idx="$(indexed_of "$work/scan-old-md.txt")"
  rm -f "$hub/hub-scan-unrepaired.sh"
fi
"$BASH_BIN" "$hub/hub-scan.sh" > "$work/scan-venv-md.txt" 2>&1
new_idx="$(indexed_of "$work/scan-venv-md.txt")"
if [ -z "$old_idx" ] || [ -z "$new_idx" ]; then
  gap "11d. the [ LINKS ] line reported no indexed-note count on one of the two runs, so the walk exclusion was not measured"
elif [ "$old_idx" -gt "$new_idx" ]; then
  pass "11d. the UNREPAIRED walk indexes a vendored licence inside the environment ($old_idx names) and the repaired one does not ($new_idx)"
else
  die "11d. the walk exclusion did not change the indexed-note count: unrepaired $old_idx, repaired $new_idx"
fi
# And it is an exclusion rather than a blanket refusal to walk: a real hub note still lands.
printf -- '---\ntype: brief\n---\n\n# Outside\n' > "$hub/98_outside.md"
"$BASH_BIN" "$hub/hub-scan.sh" > "$work/scan-outside-md.txt" 2>&1
out_idx="$(indexed_of "$work/scan-outside-md.txt")"
if [ -n "$new_idx" ] && [ -n "$out_idx" ] && [ "$out_idx" -gt "$new_idx" ]; then
  pass "11e. a markdown file outside the environment is still indexed ($out_idx), so the exclusion is not a blanket one"
else
  die "11e. the exclusion blinded the note-index walk: with the note $out_idx, without it $new_idx"
fi

# --- 12. the ignore rules are present in both trees ----------------------------------------------
if grep -q '^\.venv/$' "$ROOT/.gitignore"; then
  pass "12. the canonical .gitignore covers a virtual environment"
else
  die "12. the canonical .gitignore has no rule for a virtual environment"
fi
if grep -q '^\.venv/$' "$ROOT/template/.gitignore"; then
  pass "12b. the shipped template .gitignore covers a virtual environment, so every new hub inherits it"
else
  die "12b. template/.gitignore has no rule for a virtual environment"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "km-publish portability canaries passed: ${n_pass} assertion(s), ${n_gap} coverage gap(s); coverage is interpreter discovery (override honoured, override refused, below-floor rejected, no-interpreter refusal, PATH-only discovery), the dependency pin, the environment location, the poppler binaries in all three of their states, the unrepaired publisher from ${BASE_REV} and the unrepaired hub scan paired with the repaired tree on the same input, the hub scan's note-index walk in both directions, and the two ignore rules. NOT covered: rendering on any host other than this one, and whether the conventional prefix list is right for a distribution nobody here ran."
  exit 0
fi
echo "km-publish portability canaries FAILED"
exit 1
