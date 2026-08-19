#!/bin/bash
# Canaries for the publish guard runner in tools/km-publish.sh (v1.30).
#
# A FORBID guard reports a defect by MATCHING, so its pass is an ABSENCE — the same output as a
# mistyped verb, an invalid pattern, a boundary construct the engine ignores, or a PDF whose text
# never got extracted. A check whose pass and whose breakage look identical has to be proven in
# BOTH directions or its output means nothing, and here the cost of a false pass is concrete: every
# guard traces to a correction, so a build that says "Guards passed" while the rule never ran
# reissues exactly the defect the document was corrected to remove.
#
# The runner is driven through its --check-guards subcommand, so these cases need neither
# WeasyPrint nor a PDF and run anywhere bash and grep do.
#
# Fifteen cases and twenty-four assertions, each one able to fail:
#    1. A real violation is CAUGHT (exit 1) and the offending pattern is named.
#    2. Genuinely clean text PASSES (exit 0) and the passing line states what was checked.
#    3. FORBID is case-insensitive, as its contract says.
#    4. A REQUIRE rule whose pattern is absent FAILS (exit 1).
#    5. The ignored-boundary false pass can never recur: a \b pattern over text that contains the
#       term is caught (1) or refused (2), never 0 — asserted portably, so the case holds on a host
#       whose grep does honour \b and on one whose grep does not.
#    5c/5d. The refusal branch is proven to FIRE, against a shimmed grep that ignores boundary
#       constructs, because on a host whose grep honours all of them nothing else exercises it and
#       an unexercised refusal is code shipped on the strength of having read it.
#    6. FORBID-WORD actually bounds the match; plain FORBID is genuinely the looser mode.
#    7. REQUIRE-WORD is not satisfied by the term appearing only inside a longer word.
#    8. Empty extracted text is REFUSED (2), not passed: unscanned text is not clean text.
#    9. A guards file asserting nothing (comments only) is REFUSED, not reported as a guarded pass.
#   10. An unrecognised guard verb is REFUSED, not warned past into a passing build.
#   11. An invalid regular expression is REFUSED, not silently treated as "no match".
#   12. A missing guards file and a missing text file are REFUSED.
#   13. PAGES drift warns without failing; a non-numeric PAGES value is REFUSED.
#   14. Exit codes are read unpiped, so a pipeline cannot mask them (this file's own discipline).
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="$ROOT/tools/km-publish.sh"

work="$(mktemp -d "${TMPDIR:-/tmp}/km-guards-test.XXXXXX")"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

[ -f "$TOOL" ] || { echo "FAIL: tool not found at $TOOL"; exit 1; }

# $1 name -> writes $work/$1.guards and $work/$1.txt from stdin-supplied heredocs by the caller.
guards() { printf '%s\n' "$2" > "$work/$1.guards"; }
text()   { printf '%s\n' "$2" > "$work/$1.txt"; }

# Run the guard runner. Sets $out and $st. The status is captured directly from the command, never
# through a pipe, because a pipeline's exit status is the last command's and not the tool's.
run() {
  local name="$1"; shift
  out="$(bash "$TOOL" --check-guards "$work/$name.guards" "$work/$name.txt" "$@" 2>&1)"
  st=$?
}

# --- 1. a real violation is caught --------------------------------------------------------------
guards violation 'FORBID zorbnix'
text   violation 'The report mentions zorbnix on this line.'
run violation
if [ "$st" -eq 1 ] && printf '%s' "$out" | grep -q 'GUARD FAIL: forbidden pattern present: zorbnix'; then
  pass "1. a forbidden pattern present in the text is caught (exit 1) and named"
else
  die "1. violation not caught: status $st, output: $out"
fi

# --- 2. clean text passes, and says what it checked ----------------------------------------------
guards clean 'FORBID zorbnix
REQUIRE Quarterly Summary
PAGES 3'
text   clean 'Quarterly Summary of the delivery programme.'
run clean 3
if [ "$st" -eq 0 ] \
   && printf '%s' "$out" | grep -q 'Guards passed' \
   && printf '%s' "$out" | grep -q '1 forbid, 1 require' \
   && printf '%s' "$out" | grep -q 'boundary syntax verified' \
   && printf '%s' "$out" | grep -q 'characters of extracted text scanned'; then
  pass "2. clean text passes and the passing line names the mode actually run"
else
  die "2. clean text did not pass cleanly: status $st, output: $out"
fi

# --- 3. FORBID is case-insensitive ---------------------------------------------------------------
guards nocase 'FORBID zorbnix'
text   nocase 'The heading reads ZORBNIX in capitals.'
run nocase
if [ "$st" -eq 1 ]; then
  pass "3. FORBID matches case-insensitively, as its contract states"
else
  die "3. case-insensitive FORBID did not fire: status $st, output: $out"
fi

# --- 4. a missing REQUIRE fails -------------------------------------------------------------------
guards req 'REQUIRE Issued by the programme office'
text   req 'A document with no issuing statement at all.'
run req
if [ "$st" -eq 1 ] && printf '%s' "$out" | grep -q 'required pattern missing'; then
  pass "4. a required pattern that is absent fails the build"
else
  die "4. missing REQUIRE did not fail: status $st, output: $out"
fi

# --- 5. the ignored-boundary false pass can never recur -------------------------------------------
# The v1.29 defect in a second instrument: an engine that ignores \b matches nothing, and nothing is
# what a clean document also looks like. Whatever this host's grep does, exit 0 is wrong here.
guards boundary 'FORBID \bzorbnix\b'
text   boundary 'The report mentions zorbnix on this line.'
run boundary
if [ "$st" -eq 1 ]; then
  pass "5. a \\b pattern over matching text: engine honours it here, violation CAUGHT (exit 1)"
elif [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'IGNORES'; then
  pass "5. a \\b pattern over matching text: engine ignores it here, run REFUSED (exit 2)"
else
  die "5. a \\b pattern produced status $st — it must never be 0. Output: $out"
fi

# The same assertion on clean text: a refusing host must refuse there too, so the refusal cannot be
# mistaken for a verdict about the document.
guards boundary_clean 'FORBID \bzorbnix\b'
text   boundary_clean 'A document with nothing forbidden in it.'
run boundary_clean
if [ "$st" -eq 0 ] || [ "$st" -eq 2 ]; then
  pass "5b. the \\b decision is a property of the engine, not of the document (status $st both ways)"
else
  die "5b. unexpected status $st for a \\b pattern over clean text. Output: $out"
fi

# The refusal branch itself must be proven to fire, and on a host whose grep honours every boundary
# construct (this one does: \b, \< and [[:<:]] all bound correctly here) nothing exercises it. So
# stand up a grep that IGNORES boundary constructs — exactly what `git grep -E` did in the v1.29
# incident — put it first on PATH, and require the runner to refuse rather than pass. Without this
# case the refusal is untested code shipped on the strength of reading it.
mkdir -p "$work/inert-bin"
cat > "$work/inert-bin/grep" <<'SHIM'
#!/bin/bash
# An engine that silently drops boundary constructs, like the one that produced the v1.29 defect.
args=()
for a in "$@"; do
  a="${a//\\b/}"; a="${a//\\B/}"; a="${a//\\</}"; a="${a//\\>/}"
  a="${a//\[\[:<:\]\]/}"; a="${a//\[\[:>:\]\]/}"
  args+=("$a")
done
exec /usr/bin/grep "${args[@]}"
SHIM
chmod +x "$work/inert-bin/grep"
guards inert 'FORBID \bzorbnix\b'
text   inert 'The report mentions zorbnix on this line.'
out="$(PATH="$work/inert-bin:$PATH" bash "$TOOL" --check-guards "$work/inert.guards" "$work/inert.txt" 2>&1)"; st=$?
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'IGNORES' && printf '%s' "$out" | grep -q 'FORBID-WORD'; then
  pass "5c. against an engine that ignores \\b the run is REFUSED and points at FORBID-WORD"
else
  die "5c. an inert boundary engine did not trigger a refusal: status $st, output: $out"
fi

# And the same engine must not be able to produce a clean pass either, which is the actual defect
# shape: the pattern cannot match, so the document looks clean whatever it contains.
guards inert_clean 'FORBID \bzorbnix\b'
text   inert_clean 'A document with nothing forbidden in it.'
out="$(PATH="$work/inert-bin:$PATH" bash "$TOOL" --check-guards "$work/inert_clean.guards" "$work/inert_clean.txt" 2>&1)"; st=$?
if [ "$st" -eq 2 ]; then
  pass "5d. an inert engine can never produce exit 0 — the false pass of v1.29 cannot recur here"
else
  die "5d. an inert engine produced status $st on clean text; it must be 2. Output: $out"
fi

# --- 6. FORBID-WORD bounds the match; FORBID does not ----------------------------------------------
guards word_bounded 'FORBID-WORD zorbnix'
text   word_bounded 'The identifier zorbnixed appears, which is a different word.'
run word_bounded
if [ "$st" -eq 0 ]; then
  pass "6a. FORBID-WORD does not fire on the term inside a longer word"
else
  die "6a. FORBID-WORD over-matched: status $st, output: $out"
fi

guards word_hit 'FORBID-WORD zorbnix'
text   word_hit 'The identifier zorbnix appears on its own.'
run word_hit
if [ "$st" -eq 1 ] && printf '%s' "$out" | grep -q 'forbidden whole-word pattern present'; then
  pass "6b. FORBID-WORD fires on the term standing alone"
else
  die "6b. FORBID-WORD failed to fire: status $st, output: $out"
fi

guards substr 'FORBID zorbnix'
text   substr 'The identifier zorbnixed appears, which is a different word.'
run substr
if [ "$st" -eq 1 ]; then
  pass "6c. plain FORBID is genuinely the looser substring mode"
else
  die "6c. plain FORBID behaved as if bounded: status $st, output: $out"
fi

# --- 7. REQUIRE-WORD is not satisfied by a substring ------------------------------------------------
guards req_word 'REQUIRE-WORD zorbnix'
text   req_word 'Only zorbnixed appears here, never the bare term.'
run req_word
if [ "$st" -eq 1 ] && printf '%s' "$out" | grep -q 'required whole-word pattern missing'; then
  pass "7. REQUIRE-WORD is not satisfied by the term inside a longer word"
else
  die "7. REQUIRE-WORD accepted a substring: status $st, output: $out"
fi

# --- 8. empty extracted text is refused, not passed --------------------------------------------------
guards empty_text 'FORBID zorbnix'
: > "$work/empty_text.txt"
run empty_text
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'extracted text is empty'; then
  pass "8a. zero-byte extracted text is REFUSED, not scanned as clean"
else
  die "8a. empty text was not refused: status $st, output: $out"
fi

guards blank_text 'FORBID zorbnix'
printf '   \n\n\t\n' > "$work/blank_text.txt"
run blank_text
if [ "$st" -eq 2 ]; then
  pass "8b. whitespace-only extracted text is REFUSED"
else
  die "8b. whitespace-only text was not refused: status $st, output: $out"
fi

# --- 9. a guards file that asserts nothing is refused -------------------------------------------------
guards no_rules '# only a comment
# and another'
text   no_rules 'A perfectly ordinary document.'
run no_rules
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'no guard rules'; then
  pass "9. a guards file containing no rules is REFUSED, never reported as a guarded pass"
else
  die "9. rule-free guards file was not refused: status $st, output: $out"
fi

# --- 10. an unrecognised verb is refused ---------------------------------------------------------------
guards typo 'FORBIDD zorbnix'
text   typo 'The report mentions zorbnix on this line.'
run typo
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'unrecognised guard line'; then
  pass "10. a mistyped guard verb is REFUSED, not warned past into a passing build"
else
  die "10. mistyped verb was not refused: status $st, output: $out"
fi

# --- 11. an invalid regular expression is refused --------------------------------------------------------
guards badre 'FORBID zorbnix[)'
text   badre 'A perfectly ordinary document.'
run badre
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'not a valid extended regular expression'; then
  pass "11. an invalid pattern is REFUSED, not silently read as no match"
else
  die "11. invalid pattern was not refused: status $st, output: $out"
fi

# --- 12. missing inputs are refused ------------------------------------------------------------------------
out="$(bash "$TOOL" --check-guards "$work/nonexistent.guards" "$work/clean.txt" 2>&1)"; st=$?
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'guards file not found'; then
  pass "12a. a missing guards file is REFUSED"
else
  die "12a. missing guards file not refused: status $st, output: $out"
fi

out="$(bash "$TOOL" --check-guards "$work/clean.guards" "$work/nonexistent.txt" 2>&1)"; st=$?
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'extracted-text file not found'; then
  pass "12b. a missing extracted-text file is REFUSED"
else
  die "12b. missing text file not refused: status $st, output: $out"
fi

out="$(bash "$TOOL" --check-guards 2>&1)"; st=$?
if [ "$st" -eq 2 ]; then
  pass "12c. --check-guards with no arguments is REFUSED"
else
  die "12c. bare --check-guards not refused: status $st, output: $out"
fi

# --- 13. PAGES warns, and a non-numeric page count is refused -------------------------------------------------
guards pages 'REQUIRE Quarterly
PAGES 7'
text   pages 'Quarterly Summary of the delivery programme.'
run pages 3
if [ "$st" -eq 0 ] && printf '%s' "$out" | grep -q 'expected 7 pages, got 3'; then
  pass "13a. PAGES drift warns without failing the build"
else
  die "13a. PAGES drift behaved unexpectedly: status $st, output: $out"
fi

run pages
if [ "$st" -eq 0 ] && printf '%s' "$out" | grep -q 'page count is unknown'; then
  pass "13b. an unknown page count says so rather than reporting a silent pass"
else
  die "13b. unknown page count behaved unexpectedly: status $st, output: $out"
fi

guards badpages 'PAGES many'
text   badpages 'A perfectly ordinary document.'
run badpages 3
if [ "$st" -eq 2 ] && printf '%s' "$out" | grep -q 'PAGES takes a whole number'; then
  pass "13c. a non-numeric PAGES value is REFUSED"
else
  die "13c. non-numeric PAGES not refused: status $st, output: $out"
fi

# --- 14. the runner's own exit code is not masked by a pipeline -------------------------------------------------
bash "$TOOL" --check-guards "$work/violation.guards" "$work/violation.txt" >/dev/null 2>&1
direct=$?
bash "$TOOL" --check-guards "$work/violation.guards" "$work/violation.txt" 2>&1 | tail -1 >/dev/null
piped=$?
if [ "$direct" -eq 1 ] && [ "$piped" -eq 0 ]; then
  pass "14. exit codes are read unpiped: direct $direct, through a pipe $piped (a pipeline reports tail)"
else
  die "14. pipeline exit-status demonstration did not hold: direct $direct, piped $piped"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "km-publish guard canaries: all cases passed"
  exit 0
fi
echo "km-publish guard canaries: FAILURES above"
exit 1
