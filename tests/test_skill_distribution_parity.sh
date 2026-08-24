#!/bin/bash
# km-unrepaired-tree: v1.43 | case R3 runs the check against the unrepaired tree at 10d7950, where it names the real divergence between the advertised skill copy and its two mirrors.
# Governed-body parity for skills shipped in more than one location (v1.43),
# STANDARD.md §"Skill files declare their trigger, not their title" → "One canonical copy, and the
# mirrors are mirrors".
#
# WHY THIS EXISTS. Seven skills ship three times: `skills/<slug>/SKILL.md`, which the README presents
# as the distributable per-hub skill, and two runtime mirrors under `template/.claude/skills/` and
# `template/.agents/skills/`. Until v1.43 nothing compared their bodies. `tests/test_skill_frontmatter.sh`
# (v1.27) compares frontmatter, and v1.27's own version row recorded that the root `km-brief` copy was
# missing the index-first and lifecycle-filter guidance its mirrors carry, deferred the repair, and
# stated that the new parity check covered frontmatter only. Nineteen lines, 954 bytes, identical
# frontmatter on all three copies: the advertised copy could surface a retired or superseded fact in a
# memo and present it as true now, and the frontmatter check said the copies were in parity.
#
# WHAT IT COMPARES. The governed instruction body, delimited as everything after the closing
# frontmatter terminator. Frontmatter is left to the v1.27 check so one cause produces one failure.
#
# WHAT IT TOLERATES, AND ONLY THIS. One documented per-runtime substitution: each runtime tree names
# its own harness instruction file, `CLAUDE.md` against `AGENTS.md`. That is the same single
# substitution `[ PROJECTION ]` in `template/hub-scan.sh` already tolerates when it compares the two
# installed trees inside a deployed hub, so a hub and this repository tolerate one list rather than
# two. A difference is documented in the standard first and tolerated here second. A tolerance list
# that grows to fit whatever the tree contains converges on tolerating everything.
#
# WHAT IT REFUSES. It exits 2, with no parity verdict, when a copy cannot be read or is empty, when a
# copy carries no frontmatter terminator so its body cannot be delimited, when a mirror tree holds a
# slug the canonical tree does not, when the canonical tree yields no slug at all, or when it would
# otherwise report success having compared nothing. A parity check that walked an empty tree and
# reported success looks exactly like a clean tree.
#
# COVERAGE, STATED ON A PASSING RUN. Slugs found, how many are multi-location, pairs compared,
# documented substitutions applied, and the single-location slugs it did not compare, named. A
# recorded pass that does not state those is void rather than clean.
#
# LIMIT. Parity proves the copies agree. It never proves they are right: three copies of an unsafe
# body are in perfect parity. The direction of repair is a judgement about content and is written in
# the standard, not in this check. And proving both directions proves this fires on the class it
# models, never that it models the right class, which is why case R3 runs it against the unrepaired
# tree rather than against a synthetic likeness of the defect.
#
# All fixture content is synthetic; no real person, organization or initiative is named.
set -u

# The commit at which the defect existed: published v1.42, before the v1.43 repair. Case R3 reads the
# tree at this commit out of git and runs the check against it.
UNREPAIRED_COMMIT="10d7950"

usage() {
  echo "usage: $0                 run the full canary harness against this repository"
  echo "       $0 --check <root>  run the parity check alone against <root>; 0 parity, 1 drift, 2 refusal"
}

# ---------------------------------------------------------------------------
# The check itself. Takes a root. Prints findings. 0 parity, 1 drift, 2 refusal.
# ---------------------------------------------------------------------------
parity_check() {
  local root="$1"
  local canon="$root/skills"
  local -a mirrors=("$root/template/.claude/skills" "$root/template/.agents/skills")
  local refuse=0 drift=0
  local slugs="" slug f
  local n_slugs=0 n_multi=0 n_pairs=0 n_subs=0 n_single=0 single_named=""

  if [ ! -d "$canon" ]; then
    echo "  ? REFUSE: no canonical skills directory at ${canon}; nothing to compare and no verdict"
    return 2
  fi

  slugs="$(find "$canon" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's:.*/::' | sort)"
  if [ -z "$slugs" ]; then
    echo "  ? REFUSE: the canonical location holds no skill; a parity verdict over nothing is not a pass"
    return 2
  fi

  # A mirror with no canonical copy behind it has no reference to be compared against, and silently
  # skipping it is how a skill comes to ship from a mirror alone.
  local m mslug
  for m in "${mirrors[@]}"; do
    [ -d "$m" ] || continue
    while IFS= read -r mslug; do
      [ -z "$mslug" ] && continue
      if [ ! -d "$canon/$mslug" ]; then
        echo "  ? REFUSE: '$mslug' is present in ${m#$root/} and absent from the canonical location"
        refuse=1
      fi
    done < <(find "$m" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed 's:.*/::' | sort)
  done

  # Body extraction. Refuses rather than guessing: a file that does not open with a frontmatter
  # terminator, or never closes one, has no body this check can identify.
  body_of() { # <file> ; prints body on stdout, or nothing and returns 1
    local file="$1"
    [ -r "$file" ] || return 1
    [ -s "$file" ] || return 1
    [ "$(head -1 "$file")" = '---' ] || return 1
    # The terminator is verified before the body is extracted, so a file that never closes its
    # frontmatter is refused rather than having its whole text taken for a body.
    awk 'NR>1 && /^---$/{found=1; exit} END{exit !found}' "$file" || return 1
    awk 'NR==1{next} !seen && /^---$/{seen=1; next} seen' "$file" 2>/dev/null || return 1
    return 0
  }

  # The one documented per-runtime substitution, and nothing else.
  normalise() { sed -e 's/CLAUDE\.md/HARNESS-INSTRUCTIONS/g' -e 's/AGENTS\.md/HARNESS-INSTRUCTIONS/g'; }
  count_subs() { grep -o -e 'CLAUDE\.md' -e 'AGENTS\.md' | wc -l | tr -d ' '; }

  local ref_body mir_body ref_norm mir_norm mirror_file rel diffn
  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    n_slugs=$((n_slugs + 1))
    f="$canon/$slug/SKILL.md"
    if ! ref_body="$(body_of "$f")"; then
      echo "  ? REFUSE: cannot read or delimit the governed body of ${f#$root/}"
      refuse=1; continue
    fi
    local present=0
    for m in "${mirrors[@]}"; do
      mirror_file="$m/$slug/SKILL.md"
      [ -e "$mirror_file" ] || continue
      present=$((present + 1))
    done
    if [ "$present" -eq 0 ]; then
      n_single=$((n_single + 1)); single_named="$single_named $slug"; continue
    fi
    n_multi=$((n_multi + 1))
    for m in "${mirrors[@]}"; do
      mirror_file="$m/$slug/SKILL.md"
      [ -e "$mirror_file" ] || continue
      rel="${mirror_file#$root/}"
      if ! mir_body="$(body_of "$mirror_file")"; then
        echo "  ? REFUSE: cannot read or delimit the governed body of ${rel}"
        refuse=1; continue
      fi
      n_pairs=$((n_pairs + 1))
      n_subs=$((n_subs + $(printf '%s\n' "$ref_body" | count_subs) + $(printf '%s\n' "$mir_body" | count_subs)))
      ref_norm="$(printf '%s\n' "$ref_body" | normalise)"
      mir_norm="$(printf '%s\n' "$mir_body" | normalise)"
      if [ "$ref_norm" != "$mir_norm" ]; then
        diffn="$(diff <(printf '%s\n' "$ref_norm") <(printf '%s\n' "$mir_norm") | grep -c '^[<>]')"
        echo "  ! BODY DIVERGENCE $slug: skills/$slug/SKILL.md and ${rel} differ in $diffn line(s)"
        echo "    beyond the documented harness instruction-file substitution; the copies are not the same skill"
        drift=1
      fi
    done
  done <<< "$slugs"

  if [ "$refuse" -eq 1 ]; then
    echo "  ? REFUSED: input this check could not evaluate. No parity verdict was reached."
    return 2
  fi
  if [ "$n_pairs" -eq 0 ]; then
    echo "  ? REFUSE: no copy pair was compared; success here would be indistinguishable from parity"
    return 2
  fi
  if [ "$drift" -eq 1 ]; then
    echo "  COVERAGE: $n_slugs slug(s) canonical; $n_multi multi-location; $n_pairs pair(s) compared; $n_subs documented substitution(s) applied"
    return 1
  fi
  echo "  OK: every skill shipped in more than one location carries the same governed body"
  echo "  COVERAGE: $n_slugs slug(s) canonical; $n_multi multi-location; $n_pairs pair(s) compared; $n_subs documented substitution(s) applied; $n_single single-location slug(s) not compared:${single_named:- none}"
  echo "  LIMIT: parity proves the copies agree, never that they are right; skills written locally in a deployed hub are reached by no check here"
  return 0
}

# --- check-only mode, so the check can be pointed at any tree ---
if [ "${1:-}" = "--check" ]; then
  if [ -z "${2:-}" ]; then usage; exit 2; fi
  parity_check "$2"; exit $?
elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage; exit 0
elif [ $# -gt 0 ]; then
  usage; exit 2
fi

# ---------------------------------------------------------------------------
# Harness
# ---------------------------------------------------------------------------
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SELF="$ROOT/tests/test_skill_distribution_parity.sh"
work="$(mktemp -d)"
trap 'chmod -R u+rwX "$work" 2>/dev/null; rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# --- R1. the real repository is in parity ---
out="$(parity_check "$ROOT")"; rc=$?
if [ "$rc" -eq 0 ]; then
  pass "R1 every shipped skill is in governed-body parity across the locations it ships in"
  printf '%s\n' "$out" | sed 's/^/      /'
else
  die "R1 the repository is not in governed-body parity (rc=$rc):"; printf '%s\n' "$out"
fi

# --- R2. the real km-propose copies differ only by the documented substitution and do not fire ---
if printf '%s\n' "$out" | grep -q 'BODY DIVERGENCE km-propose'; then
  die "R2 the documented harness instruction-file substitution was reported as drift"
else
  if diff -q "$ROOT/template/.claude/skills/km-propose/SKILL.md" \
             "$ROOT/template/.agents/skills/km-propose/SKILL.md" >/dev/null 2>&1; then
    die "R2 fixture gone: km-propose no longer carries the documented per-runtime difference, so this case proves nothing"
  else
    pass "R2 km-propose really does differ per runtime in the shipped tree and is not reported as drift"
  fi
fi

# --- fixture builder: two slugs, one plain, one carrying the documented substitution ---
build_fixture() {
  local d="$1"
  rm -rf "$d"
  mkdir -p "$d/skills/km-thing" "$d/skills/km-other" \
           "$d/template/.claude/skills/km-thing" "$d/template/.claude/skills/km-other" \
           "$d/template/.agents/skills/km-thing" "$d/template/.agents/skills/km-other"
  cat > "$d/skills/km-thing/SKILL.md" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
---

# body

Only include entries whose lifecycle is active.
FIX
  cp "$d/skills/km-thing/SKILL.md" "$d/template/.claude/skills/km-thing/SKILL.md"
  cp "$d/skills/km-thing/SKILL.md" "$d/template/.agents/skills/km-thing/SKILL.md"
  cat > "$d/skills/km-other/SKILL.md" <<'FIX'
---
name: km-other
description: Use when a synthetic fixture needs a second conforming description naming its trigger and its own invocation, /km-other, plainly.
---

# body

Governance files (CLAUDE.md, README.md) need updating.
FIX
  cp "$d/skills/km-other/SKILL.md" "$d/template/.claude/skills/km-other/SKILL.md"
  sed 's/CLAUDE\.md/AGENTS.md/' "$d/skills/km-other/SKILL.md" > "$d/template/.agents/skills/km-other/SKILL.md"
}

# --- canary runner: <expected-rc> <label> <mutation...> ---
canary() {
  local want="$1" label="$2"; shift 2
  local d="$work/canary"
  build_fixture "$d"
  local base_out base_rc
  base_out="$(parity_check "$d")"; base_rc=$?
  if [ "$base_rc" -ne 0 ]; then
    die "canary base fixture is not clean (rc=$base_rc): $label"; printf '%s\n' "$base_out"; return
  fi
  "$@"
  local got_out got_rc
  got_out="$(parity_check "$d")"; got_rc=$?
  if [ "$got_rc" -eq "$want" ]; then
    pass "canary (rc=$got_rc as expected): $label"
  else
    die "canary expected rc=$want and got rc=$got_rc: $label"; printf '%s\n' "$got_out"
  fi
}

D="$work/canary"

# C0. the base fixture is clean, which is also the proof that the documented substitution in
#     km-other does not fire. A check that matches everything proves as little as one that matches
#     nothing.
build_fixture "$D"
out0="$(parity_check "$D")"; rc0=$?
if [ "$rc0" -eq 0 ] && ! printf '%s\n' "$out0" | grep -q 'BODY DIVERGENCE'; then
  pass "C0 a fixture whose copies differ only by the documented substitution is reported as parity"
else
  die "C0 the documented substitution fired (rc=$rc0):"; printf '%s\n' "$out0"
fi

# C1. drift introduced in a mirror body
canary 1 "C1 a line added to a mirror body is caught" \
  bash -c 'printf "%s\n" "Include retired entries when convenient." >> "$1/template/.claude/skills/km-thing/SKILL.md"' _ "$D"

# C2. drift introduced in the canonical body: the check is not one-directional
canary 1 "C2 a line added to the canonical body is caught" \
  bash -c 'printf "%s\n" "Include retired entries when convenient." >> "$1/skills/km-thing/SKILL.md"' _ "$D"

# C3. a line removed from the canonical body, which is the shape of the real defect
canary 1 "C3 a governance line removed from the canonical copy is caught" \
  bash -c 'sed -i.bak "/lifecycle is active/d" "$1/skills/km-thing/SKILL.md" && rm -f "$1/skills/km-thing/SKILL.md.bak"' _ "$D"

# C4. an undocumented difference sitting beside a documented one still fires: normalisation must not
#     swallow the drift next to what it normalises
canary 1 "C4 drift beside a documented substitution is not swallowed by normalisation" \
  bash -c 'printf "%s\n" "An extra sentence." >> "$1/template/.agents/skills/km-other/SKILL.md"' _ "$D"

# C5. a copy with no frontmatter terminator: body cannot be delimited, so no verdict
canary 2 "C5 a copy with no frontmatter terminator is refused, not compared" \
  bash -c 'f="$1/template/.claude/skills/km-thing/SKILL.md"; awk "BEGIN{n=0} /^---\$/{n++; if(n==2) next} {print}" "$f" > "$f.t" && mv "$f.t" "$f"' _ "$D"

# C6. an empty copy
canary 2 "C6 an empty copy is refused, not read as an empty body in parity" \
  bash -c ': > "$1/template/.agents/skills/km-thing/SKILL.md"' _ "$D"

# C7. an unreadable copy. Skipped under a uid that bypasses the permission bits, and the skip is
#     reported as a coverage gap rather than folded into the verdict.
if [ "$(id -u)" -eq 0 ]; then
  echo "SKIP: C7 unreadable-copy refusal not provable as uid 0; coverage gap, not a pass"
else
  canary 2 "C7 an unreadable copy is refused" \
    bash -c 'chmod 000 "$1/skills/km-thing/SKILL.md"' _ "$D"
fi

# C8. a mirror slug with no canonical copy behind it
canary 2 "C8 a mirror slug with no canonical copy is refused" \
  bash -c 'mkdir -p "$1/template/.claude/skills/km-orphan" && cp "$1/skills/km-thing/SKILL.md" "$1/template/.claude/skills/km-orphan/SKILL.md" && sed -i.bak "s/^name: .*/name: km-orphan/" "$1/template/.claude/skills/km-orphan/SKILL.md" && rm -f "$1/template/.claude/skills/km-orphan/SKILL.md.bak"' _ "$D"

# C9. an empty canonical tree
canary 2 "C9 an empty canonical location is refused, never reported as universal parity" \
  bash -c 'rm -rf "$1/skills"/*' _ "$D"

# C10. every slug single-location: nothing to compare, so no verdict
canary 2 "C10 a tree with no mirrors at all is refused rather than passed" \
  bash -c 'rm -rf "$1/template/.claude/skills" "$1/template/.agents/skills"' _ "$D"

# --- R3. the check, run against the UNREPAIRED tree, names the real divergence ---------------------
# This is the strongest evidence available that the check detects the defect it was written for: the
# input is the defect itself, read out of git, rather than a synthetic likeness of it. A failure to
# materialise that tree is reported as a coverage gap and never as a pass.
unrep="$work/unrepaired"
mkdir -p "$unrep"
if ! git -C "$ROOT" rev-parse --verify --quiet "${UNREPAIRED_COMMIT}^{commit}" >/dev/null; then
  die "R3 commit $UNREPAIRED_COMMIT is not present, so the unrepaired tree could not be read: coverage gap, not a pass"
elif ! git -C "$ROOT" archive "$UNREPAIRED_COMMIT" skills template 2>/dev/null | tar -x -C "$unrep" 2>/dev/null; then
  die "R3 could not extract the tree at $UNREPAIRED_COMMIT: coverage gap, not a pass"
elif [ ! -f "$unrep/skills/km-brief/SKILL.md" ]; then
  die "R3 the extracted tree carries no km-brief copy, so it is not the tree this case needs"
else
  u_out="$("$SELF" --check "$unrep")"; u_rc=$?
  if [ "$u_rc" -eq 1 ] && printf '%s\n' "$u_out" | grep -q 'BODY DIVERGENCE km-brief'; then
    n=$(printf '%s\n' "$u_out" | grep -c 'BODY DIVERGENCE km-brief')
    pass "R3 run against the unrepaired tree at $UNREPAIRED_COMMIT the check reports drift and names km-brief ($n mirror(s))"
    printf '%s\n' "$u_out" | sed 's/^/      /'
  else
    die "R3 the check did not report the real km-brief divergence against $UNREPAIRED_COMMIT (rc=$u_rc):"
    printf '%s\n' "$u_out"
  fi
  # R4. and it must not also pass there: a finding printed beside a green verdict is not a detection.
  if [ "$u_rc" -eq 0 ]; then
    die "R4 the check returned parity on the unrepaired tree"
  else
    pass "R4 the check does not return parity on the unrepaired tree (rc=$u_rc)"
  fi
  # R5. no other slug diverges in the unrepaired tree, so the sweep's finding of one is the check's
  #     finding too, not an artefact of where the maintainer happened to look.
  others="$(printf '%s\n' "$u_out" | grep 'BODY DIVERGENCE' | grep -v 'km-brief' || true)"
  if [ -z "$others" ]; then
    pass "R5 km-brief is the only governed-body divergence in the unrepaired tree"
  else
    die "R5 the unrepaired tree carries further divergence this change did not account for:"; printf '%s\n' "$others"
  fi
fi

echo
if [ "$fail" -eq 0 ]; then echo "ALL SKILL DISTRIBUTION PARITY CHECKS PASSED"; else echo "SKILL DISTRIBUTION PARITY CHECKS FAILED"; fi
exit "$fail"
