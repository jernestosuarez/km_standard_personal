#!/bin/bash
# km-unrepaired-tree: v1.59 | re-stated for the top-level-sequence repair. Run against the unrepaired tree at be6e4bf (published v1.58) before any repair was written. A fixture carrying a valid name, a valid 15-word description and two top-level '- item' lines was accepted by check_tree at exit 0 with no violation line, while Ruby's YAML parser on the same host answered 'did not find expected key while parsing a block mapping at line 2 column 1' for the same block: the check accepted a document no runtime can load. The canary added for it reported 'canary NOT caught' on the unrepaired tree and the suite exited 1 with the other twelve canaries still passing. The cause is one arm the v1.58 repair carried forward from the original pattern without re-deriving it, the leading-marker arm, which accepts a sequence entry at ANY indentation as a continuation of the preceding key; YAML makes it a continuation only when it is more-indented than the key it continues. The positive-direction canary added beside it, a sequence indented under its own key, passes on the unrepaired tree and on the repaired one, because its job is to pin the shape the reader must keep accepting rather than to detect the defect. The v1.58 declaration this replaces still holds in full: re-stated for the folded-value repair. Run against the unrepaired tree at 510cf03 before any repair was written. A fixture whose description first line is 13 words and whose following indented lines are folded into the same plain scalar by any real YAML parser was accepted: check_tree returned exit 0 with zero violation lines, having measured 13 words against the 10-40 residency budget, while Ruby's YAML parser on the same host read the effective value as 97 words. A second fixture, an indented line placed before any key in the block so that it continues nothing at all, was also accepted at exit 0. Two new canaries were added for those and both reported 'canary NOT caught' on the unrepaired tree; the suite exited 1 with the other ten canaries still passing. The cause is two lines of the continuation arm: every indented line was skipped unconditionally, with no state, no record of which key it continued and no requirement that any key precede it, and the budget was then measured against the first physical line alone. A third case was found while repairing rather than by probing: the arm's tab pattern was written "\t"* inside double quotes, which is a literal backslash-t and matched no tab-indented line on this host, so that half of the arm had been inert since it was written. The positive-direction canary added with them, a legitimate two-line description inside the budget, passes on the unrepaired tree and on the repaired one, because its job is to pin the shape the reader must keep accepting rather than to detect the defect. The v1.55 declaration this replaces still holds in full: re-stated for the block-integrity repair. Run against the tree at 13dec55 with the closing '---' deleted from all three shipped copies of skills/km-brief/SKILL.md, the unrepaired check prints "PASS: every shipped skill file carries a conforming name/description frontmatter" and "ALL SKILL FRONTMATTER CHECKS PASSED", exit 0, because awk runs to end of file when no terminator exists and reads the whole body as the block. Four further malformations were probed on the same tree and all four passed it at exit 0 with 0 violation lines: a '...' terminator, a duplicated name key, a duplicated description key, and an extra key. The fifth, an empty block, was already caught at exit 1 with 6 violation lines. A sixth case was found while repairing rather than by probing, and it is the one that matters: requiring merely that SOME closing '---' exists is not enough, because every shipped skill file carries '---' horizontal rules in its prose, so deleting the real terminator moves the delimiter down the document and the block swallows 16 lines of body while both keys stay present and unique. Measured on the repaired check with only the terminator rule in place: exit 0. The repaired check therefore also requires every line inside the block to read as a mapping entry, a continuation, a comment or a blank, and it then fails all five with a named violation each and passes the clean tree unchanged. The v1.27 declaration this replaces was 'unrecorded'; that debt is discharged for the delimiter and duplicate-key rules only.
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
#      Rules 2, 3 and 4 are applied to the LOGICAL value, folded across every continuation line,
#      never to the value's first physical line (repaired in v1.58). A plain YAML scalar folds each
#      more-indented line that follows it into one value, so a first line inside the budget can
#      carry a folded value far outside it, and until v1.58 that passed. The block is therefore
#      walked with state: a continuation is folded into the key it continues, and an indented line
#      that no key precedes is a violation rather than something to skip.
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
  local root="$1" bad=0 f slug fm name desc words close key val cont cur_key n_name n_desc fmline
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
    #
    # THE VALUE READ IS THE LOGICAL VALUE, NOT ITS FIRST PHYSICAL LINE (repaired in v1.58).
    #
    # A plain YAML scalar folds every more-indented line that follows it into ONE value. Until
    # v1.58 this loop skipped every indented line as a continuation unconditionally -- with no
    # state, no record of WHICH key it continued, and no requirement that any key precede it -- and
    # the budget below was then measured against `sed -n 's/^description: *//p' | head -1`, the
    # first physical line alone. Measured on 510cf03: a description whose first line is 13 words
    # and whose folded value is 97 words was accepted at exit 0 with no violation line, and Ruby's
    # YAML parser on the same host read the 97. The runtime holds a value this check never saw.
    #
    # So the block is walked with state. A line that opens a key sets the current key; an indented
    # line or a sequence entry is folded into that key's value, and is a VIOLATION when no key
    # precedes it, because a line that continues nothing is not a continuation. `name` and
    # `description` are then judged on their folded values.
    #
    # NO YAML PARSER IS TAKEN AS A DEPENDENCY, deliberately. PyYAML is absent on the host this was
    # written on; Ruby's is present, and neither is guaranteed in the environment a deployment runs
    # this in. This repository has already published one version (v1.51) about a shipped tool that
    # assumed its author's toolchain, so the folding is done here in the shell the check already
    # requires. The cost is stated: this models the plain-scalar folding the standard's own skill
    # files use, not the whole of YAML.
    #
    # The tab arm was ALSO inert and that was found while repairing, not by probing: it was written
    # `"\t"*` inside double quotes, which is a literal backslash-t, so no tab-indented line ever
    # matched it. `[[:space:]]*` is the character class the shell actually honours, and this is the
    # v1.29 rule -- a matching construct is verified against the tool that will run it -- met in
    # this repository's own suite.
    cur_key=""; name=""; desc=""; n_name=0; n_desc=0
    while IFS= read -r fmline; do
      case "$fmline" in
        "") continue ;;
        "#"*) continue ;;
        [[:space:]]* | "- "*)
          if [ -z "$cur_key" ]; then
            echo "  ! FRONTMATTER CONTINUATION LINE CONTINUES NO KEY: '${fmline:0:60}': ${f#$root/}"; bad=1; continue
          fi
          # Builtin matching, no subprocess. This loop runs once per block line per check_tree call
          # and check_tree is called about thirty times by the canaries below, so a `printf | sed`
          # pair here cost real time: 196s against the original check's 82s, measured back to back
          # on the same cold tree, on synced storage where a fork is expensive. Warm, which is the
          # only comparable pair, this form runs 1.6s against the original's 1.5s. The gate that
          # runs this suite has a runtime budget of its own.
          [[ "$fmline" =~ ^[[:space:]]*(-[[:space:]]+)?(.*)$ ]] && cont="${BASH_REMATCH[2]}" || cont="$fmline"
          case "$cur_key" in
            name)        name="$name $cont" ;;
            description) desc="$desc $cont" ;;
          esac
          continue ;;
      esac
      if [[ "$fmline" =~ ^([A-Za-z_][A-Za-z0-9_.-]*):([[:space:]].*)?$ ]]; then
        key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
        [[ "$val" =~ ^[[:space:]]*(.*)$ ]] && val="${BASH_REMATCH[1]}"
      else
        echo "  ! FRONTMATTER LINE IS NOT A MAPPING ENTRY: '${fmline:0:60}': ${f#$root/}"; bad=1; cur_key=""; continue
      fi
      cur_key="$key"
      case "$key" in
        name)        n_name=$((n_name + 1)); [ "$n_name" -eq 1 ] && name="$val" ;;
        description) n_desc=$((n_desc + 1)); [ "$n_desc" -eq 1 ] && desc="$val" ;;
      esac
    done <<FMEOF
$fm
FMEOF
    [ "$n_name" -gt 1 ] && { echo "  ! DUPLICATE 'name:' declared $n_name times in the block: ${f#$root/}"; bad=1; }
    [ "$n_desc" -gt 1 ] && { echo "  ! DUPLICATE 'description:' declared $n_desc times in the block: ${f#$root/}"; bad=1; }
    # A folded value opens with the separator space; trim it so an empty value still reads as empty.
    [[ "$name" =~ ^[[:space:]]*(.*[^[:space:]])?[[:space:]]*$ ]] && name="${BASH_REMATCH[1]}"
    [[ "$desc" =~ ^[[:space:]]*(.*[^[:space:]])?[[:space:]]*$ ]] && desc="${BASH_REMATCH[1]}"
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

# The other direction, and it is not optional here (added in v1.58). The continuation rule below
# tightens how the block is read, and a reader tightened until it rejects legitimate input is the
# same defect wearing
# the opposite sign: a check that fires on everything proves as little as one that fires on nothing.
# `clean_canary` asserts that a mutation is NOT reported, so the tightening ships beside the shape it
# must keep accepting.
clean_canary() { # <label> <mutation-cmd>
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
  if [ -n "$(check_tree "$work/canary")" ]; then die "clean canary base fixture is not clean"; return; fi
  "$@"
  local out2; out2="$(check_tree "$work/canary")"
  if [ -z "$out2" ]; then pass "legitimate input still accepted: $label"
  else die "legitimate input REJECTED: $label"; printf '%s\n' "$out2"; fi
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

# --- 4. the value a check reads is the LOGICAL value, never its first physical line (v1.58) ---
# Added in v1.58.
#
# A plain YAML scalar folds every more-indented line that follows it into one value. The reader this
# suite drives skipped every indented line as a continuation unconditionally -- no state, no record
# of WHICH key it continued, and no requirement that any key precede it -- and then measured the
# residency budget against `sed -n 's/^description: *//p' | head -1`, the first physical line alone.
# So a description whose first line is inside the budget and whose folded value is far outside it
# passed, and the runtime that reads the file with a real parser holds a value this check never saw.
# This is the class STANDARD.md states under "A check that reads a compound value validates its
# parts, never the whole alone": a value the standard defines as one thing, judged one fragment at a
# time. Here it is the mirror image -- a value that is one thing across several lines, judged by one
# line.
write_folded_over_budget() { # first line inside the budget, folded value far outside it
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description naming its trigger plainly.
  This continuation line is folded into the description value by any real YAML parser, and it runs on
  at considerable length precisely so that the effective value goes straight through the forty word
  residency ceiling this check believes it is enforcing, with filler and yet more filler and still
  more filler words added so the total is unambiguously far above that ceiling by any counting
  method a reader might reasonably apply to it, and then a little more again for good measure.
---

# body
FIX
}
write_folded_within_budget() { # the positive direction: a legitimate two-line description
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger
  and its own invocation, /km-thing, across two lines rather than one.
---

# body
FIX
}
write_orphan_continuation() { # an indented line that continues nothing, because no key precedes it
  cat > "$1" <<'FIX'
---
  this line is indented and no key precedes it, so it continues nothing at all
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
---

# body
FIX
}
canary "folded continuation carries the value over the budget" write_folded_over_budget "$f"
canary "indented line continues no key"                        write_orphan_continuation "$f"
clean_canary "a two-line description inside the budget"        write_folded_within_budget "$f"

# --- 5. a sequence entry continues a key only when it is MORE-INDENTED than that key (v1.59) ---
# THIS SECTION BELONGS TO v1.59 (DRAFT) AND BINDS NOTHING UNTIL THAT VERSION'S OWNER PUSH.
#
# The v1.58 repair above walked the block with state, but it carried one arm of the original
# continuation pattern forward without re-deriving it: "- "*, which accepts a sequence entry at ANY
# indentation as a continuation of the preceding key. YAML does not. A sequence is the value of the
# key above it only when it is more-indented than that key; a "- " at the indentation of the mapping
# itself is a block sequence entry where a mapping key is required, and a parser rejects the
# document outright.
#
# Measured on the unrepaired tree: a block carrying a valid name, a valid 15-word description and
# two top-level "- item" lines was accepted by this suite at exit 0 with no violation line, while
# Ruby's YAML parser on the same host answered
#   did not find expected key while parsing a block mapping at line 2 column 1
# So the reader accepted a block no runtime can load. That is the folded-value defect above with
# the sign reversed: there the check read less of the value than the parser does, here it reads a
# document the parser will not read at all.
#
# The continuation arm therefore compares indentation against the key it would continue instead of
# matching a leading marker, and the positive direction ships beside it: a sequence indented under
# its own key is ordinary YAML and must keep passing.
write_top_level_sequence() { # a "- " at the indentation of the mapping: not a continuation
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger plainly here.
- item one at the top level of the mapping block
- item two at the top level of the mapping block
---

# body
FIX
}
write_indented_sequence() { # the positive direction: a sequence that IS more-indented than its key
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
tags:
  - alpha
  - beta
---

# body
FIX
}
canary "sequence entry at the top level of a mapping block"     write_top_level_sequence "$f"
clean_canary "a sequence indented under the key it belongs to"  write_indented_sequence "$f"

echo
if [ "$fail" -eq 0 ]; then echo "ALL SKILL FRONTMATTER CHECKS PASSED"; else echo "SKILL FRONTMATTER CHECKS FAILED"; fi
exit "$fail"
