#!/bin/bash
# km-unrepaired-tree: v1.55 | re-stated for the block-integrity repair. Run against the tree at 13dec55 with the closing '---' deleted from all three shipped copies of skills/km-brief/SKILL.md, the unrepaired check prints "PASS: every shipped skill file carries a conforming name/description frontmatter" and "ALL SKILL FRONTMATTER CHECKS PASSED", exit 0, because awk runs to end of file when no terminator exists and reads the whole body as the block. Four further malformations were probed on the same tree and all four passed it at exit 0 with 0 violation lines: a '...' terminator, a duplicated name key, a duplicated description key, and an extra key. The fifth, an empty block, was already caught at exit 1 with 6 violation lines. A sixth case was found while repairing rather than by probing, and it is the one that matters: requiring merely that SOME closing '---' exists is not enough, because every shipped skill file carries '---' horizontal rules in its prose, so deleting the real terminator moves the delimiter down the document and the block swallows 16 lines of body while both keys stay present and unique. Measured on the repaired check with only the terminator rule in place: exit 0. The repaired check therefore also requires every line inside the block to read as a mapping entry, a continuation, a comment or a blank, and it then fails all five with a named violation each and passes the clean tree unchanged. The v1.27 declaration this replaces was 'unrecorded'; that debt is discharged for the delimiter and duplicate-key rules only.
# Fixtures for skill-file frontmatter (v1.27), STANDARD.md §"Skill files declare their trigger".
#
# Every skill file this standard ships must carry YAML frontmatter with exactly the two fields a
# runtime reads before invocation: `name` (the directory slug, which is also the invocation) and
# `description` (when to use it, in trigger terms). Four things must hold, and each can fail:
#   1. Every shipped skill file has frontmatter with both fields, in a block that is OPENED and
#      CLOSED by `---` on its own line, with each field declared exactly once. A reader that stops
#      at end of file cannot tell a block from a document: every key in the body becomes a key in
#      the block, and a reader that takes the first match of a key discards a contradicting value
#      that a differently written reader would have used. Both were false passes until v1.55.
#   2. `name` equals the skill's own directory name, so the listing and the invocation agree.
#   3. `description` survives a plain-scalar parse: no colon-followed-by-space in the value.
#      A quoted scalar is one naive frontmatter reader away from showing its own quote marks.
#   4. `description` stays inside the residency budget (roughly 15-30 words; 10-40 enforced).
# The same slug shipped in several trees (root distribution copy, .claude mirror, .agents mirror)
# must carry byte-identical frontmatter, or the copies drift the moment one is edited.
# Each check is then proved against a synthetic violation, so a check that cannot fail is caught.
# ONE GAP IS REGISTERED RATHER THAN CLOSED. This check does not require the block to carry ONLY the
# two fields; an extra key passes. `allowed-tools` and its kin are real fields in real runtimes, so
# refusing them is a policy decision about what this standard's skill files may carry, not a defect
# in how this check reads its input, and settling it inside a repair to the reader would settle it
# silently. It is written here so the next maintainer finds the question. (Registered v1.55.)
# All fixture content is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# --- the checker, as a function, so the canaries can run it against a synthetic tree ---
# Usage: check_tree <root>  → prints one line per violation, exit 1 if any
check_tree() {
  local root="$1" bad=0 f slug fm name desc words close key n_key fmline
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    slug="$(basename "$(dirname "$f")")"
    if [ "$(head -1 "$f")" != '---' ]; then
      echo "  ! NO FRONTMATTER: ${f#$root/}"; bad=1; continue
    fi
    # The block must be CLOSED. Without this the extraction below runs to end of file and reads the
    # whole document as frontmatter, which is how an unterminated block passed as conforming.
    close="$(awk 'NR>1 && /^---$/{print NR; exit}' "$f")"
    if [ -z "$close" ]; then
      echo "  ! UNTERMINATED FRONTMATTER: no closing '---' on its own line: ${f#$root/}"; bad=1; continue
    fi
    fm="$(sed -n "2,$((close - 1))p" "$f")"
    # Every line in the block must be something YAML would read as a mapping entry, a continuation,
    # a comment or a blank. Finding *a* closing `---` is not enough on its own: every shipped skill
    # file carries `---` horizontal rules in its prose, so deleting the real terminator merely moves
    # the closing delimiter down the document and the block swallows the body. The keys are still
    # there, still unique, and the block still "closes". This rule is what makes the swallowed prose
    # visible.
    while IFS= read -r fmline; do
      case "$fmline" in
        "" | "#"*) continue ;;
        " "* | "\t"* | "- "*) continue ;;
      esac
      case "$fmline" in
        *": "* | *":") ;;
        *) echo "  ! FRONTMATTER LINE IS NOT A MAPPING ENTRY: '${fmline:0:60}': ${f#$root/}"; bad=1; continue ;;
      esac
      printf '%s' "$fmline" | grep -q '^[A-Za-z_][A-Za-z0-9_.-]*:' || {
        echo "  ! FRONTMATTER LINE IS NOT A MAPPING ENTRY: '${fmline:0:60}': ${f#$root/}"; bad=1; }
    done <<FMEOF
$fm
FMEOF
    for key in name description; do
      n_key="$(printf '%s\n' "$fm" | grep -c "^$key:")"
      if [ "$n_key" -gt 1 ]; then
        echo "  ! DUPLICATE '$key:' declared $n_key times in the block: ${f#$root/}"; bad=1
      fi
    done
    name="$(printf '%s\n' "$fm" | sed -n 's/^name: *//p' | head -1)"
    desc="$(printf '%s\n' "$fm" | sed -n 's/^description: *//p' | head -1)"
    if [ -z "$name" ]; then echo "  ! NO name: ${f#$root/}"; bad=1; fi
    if [ -z "$desc" ]; then echo "  ! NO description: ${f#$root/}"; bad=1; continue; fi
    if [ -n "$name" ] && [ "$name" != "$slug" ]; then
      echo "  ! name '$name' is not the directory slug '$slug': ${f#$root/}"; bad=1
    fi
    case "$desc" in *": "*) echo "  ! description would not parse as a plain scalar (': '): ${f#$root/}"; bad=1 ;; esac
    words=$(printf '%s\n' "$desc" | wc -w | tr -d ' ')
    if [ "$words" -lt 10 ] || [ "$words" -gt 40 ]; then
      echo "  ! description is $words words, outside the 10-40 residency budget: ${f#$root/}"; bad=1
    fi
  done < <(find "$root/skills" "$root/template/.claude/skills" "$root/template/.agents/skills" \
             -name SKILL.md -type f 2>/dev/null | sort)
  return $bad
}

# --- 1. the real repository passes ---
out="$(check_tree "$ROOT")"
if [ -z "$out" ]; then
  pass "every shipped skill file carries a conforming name/description frontmatter"
else
  die "shipped skill files violate the contract:"; printf '%s\n' "$out"
fi

# --- 2. the same slug carries identical frontmatter in every tree it ships in ---
drift=0
for d in "$ROOT"/skills/*/; do
  slug="$(basename "$d")"
  ref="$(awk 'NR>1 && /^---$/{exit} NR>1' "$d/SKILL.md" 2>/dev/null)"
  for mirror in "$ROOT/template/.claude/skills/$slug/SKILL.md" "$ROOT/template/.agents/skills/$slug/SKILL.md"; do
    [ -f "$mirror" ] || continue
    if [ "$(awk 'NR>1 && /^---$/{exit} NR>1' "$mirror")" != "$ref" ]; then
      echo "  ! frontmatter drift: $slug differs between skills/ and ${mirror#$ROOT/}"; drift=1
    fi
  done
done
[ "$drift" -eq 0 ] && pass "mirrors carry frontmatter identical to the distribution copy" \
                   || die "mirrored skill frontmatter has drifted"

# --- 3. canaries: each rule must actually fire ---
canary() { # <label> <mutation-cmd>
  local label="$1"; shift
  rm -rf "$work/canary"
  mkdir -p "$work/canary/skills/km-thing" "$work/canary/template/.claude/skills" "$work/canary/template/.agents/skills"
  cat > "$work/canary/skills/km-thing/SKILL.md" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
---

# body
FIX
  # sanity: the fixture is clean before mutation
  if [ -n "$(check_tree "$work/canary")" ]; then die "canary base fixture is not clean"; return; fi
  "$@"
  if [ -n "$(check_tree "$work/canary")" ]; then pass "canary caught: $label"; else die "canary NOT caught: $label"; fi
}
f="$work/canary/skills/km-thing/SKILL.md"
canary "missing frontmatter"      bash -c 'tail -n +5 "$0" > "$0.t" && mv "$0.t" "$0"' "$f"
canary "missing description"      bash -c 'sed -i.bak "/^description:/d" "$0" && rm -f "$0.bak"' "$f"
canary "name not the slug"        bash -c 'sed -i.bak "s/^name: .*/name: km-other/" "$0" && rm -f "$0.bak"' "$f"
canary "unparseable plain scalar" bash -c 'sed -i.bak "s/^description: /description: Trigger: /" "$0" && rm -f "$0.bak"' "$f"
canary "over the word budget"     bash -c 'sed -i.bak "s/^description: .*/& and then it continues well past any reasonable residency budget with filler words added purely to push this sentence over the enforced ceiling of forty words in total, twice over if need be/" "$0" && rm -f "$0.bak"' "$f"
canary "unterminated block"       bash -c 'sed -i.bak "4d" "$0" && rm -f "$0.bak"' "$f"
# The same mutation on a fixture whose BODY carries a `---` rule, which every shipped skill file
# does. The block then finds a closing delimiter further down and swallows the prose between.
canary "terminator deleted, body rule swallowed" bash -c 'sed -i.bak "4d" "$0" && printf "You have been invoked as /km-thing, and this prose is now inside the block.\n\n---\n\nmore body\n" >> "$0" && rm -f "$0.bak"' "$f"
canary "closed with '...' not ---" bash -c 'sed -i.bak "4s/^---$/.../" "$0" && rm -f "$0.bak"' "$f"
canary "duplicate name key"       bash -c 'sed -i.bak "2a\\
name: km-other" "$0" && rm -f "$0.bak"' "$f"
canary "duplicate description key" bash -c 'sed -i.bak "3a\\
description: A second and contradictory description that a first-match reader silently discards here." "$0" && rm -f "$0.bak"' "$f"

echo
if [ "$fail" -eq 0 ]; then echo "ALL SKILL FRONTMATTER CHECKS PASSED"; else echo "SKILL FRONTMATTER CHECKS FAILED"; fi
exit "$fail"
