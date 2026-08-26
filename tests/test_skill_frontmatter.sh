#!/bin/bash
# km-unrepaired-tree: v1.61 | re-stated for the comment-ends-a-scalar repair, which edits this file, and to correct a false claim this file published in v1.60. THE REPAIR. Run against the unrepaired tree at 164ecfb (published v1.60) before the repair was written. The external reviewer's own script (reproduce-indented-comment-continuation.sh, sha256 9415c372b9dd22f519d92ccac6d574b318affa102a9b41be1296251943d55e56, pins 164ecfb36fd7a644365ee9dff41a540130e15e82 internally and re-clones it whatever source root it is handed, so it can test the v1.60 tree and no other) was run here UNMODIFIED against that tree, on an environment identical to theirs (macOS 26.5.2 arm64, bash 3.2.57, ruby 2.6.10p210 with Psych 3.1.0 and libyaml 0.2.1, python 3.9.6, git 2.50.1), and printed 'PASS: 23 skill file(s) ...', 'ALL SKILL FRONTMATTER CHECKS PASSED', checker_exit=0 and ruby_yaml_exit=1 with Psych::SyntaxError 'did not find expected key while parsing a block mapping at line 2 column 1', reporting REPRODUCED. Nine cases were added here in section 7 and run against that same unrepaired tree; FIVE were red. Four reported 'canary NOT caught' -- a column-zero comment then a continuation, an indented comment then a continuation (the reviewer's content byte for byte), a comment deeper than the continuation then another, and an empty '#' comment then a continuation -- and the fifth reported 'legitimate input REJECTED: a comment between two keys', the unrepaired reader folding that comment into name and answering "name 'km-thing # a comment between two keys is a comment, and the key below opens its own value' is not the directory slug". FOUR passed on the unrepaired tree and only two of them legitimately, which is recorded rather than counted as detection: a comment between two sequence entries and a blank line inside a plain scalar passed for their own reasons and pin shapes this reader must keep accepting; a comment ending the block after a scalar, and a comment before the value has started, passed for the WRONG reason, the comment text being folded into description and the inflated word count landing inside the 10-40 budget by luck. On the repaired tree all nine pass, the four detection cases naming '! FRONTMATTER CONTINUATION LINE CONTINUES NO KEY' on the line after the comment, and every canary of sections 3 to 6 still fires. HOW THE REPAIR WAS VERIFIED, AND HOW IT WAS NOT. The reviewer's script CANNOT show the repair, because it re-clones the revision it pins; run against the repaired tree it would test v1.60 again and report REPRODUCED again. It was therefore not used for that, and no claim is made here about what it prints on a repaired tree. Three other means were used and each is named. First, the nine integrated canaries above, one of which carries the reviewer's fixture content byte for byte and is the same three lines their patch writes. Second, a differential measurement against the reference parser: ten comment and blank-line shapes were put to Psych 3.1.0 one at a time, the ten answers are listed in full above section 7, and the repaired reader answers all ten the same way Psych does, so this repair is a MODEL with no declared divergence, unlike the tab rule above it. Third, a DE-PINNED variant of the reviewer's script, modified in exactly one line -- the pinned checkout replaced by a checkout of the source root's own HEAD plus its working-tree diff, and nothing else -- was run against the repaired tree and reported checker_exit=1, ruby_yaml_exit=1 and 'NOT REPRODUCED: checker and reference parser did not disagree in the expected direction'. That variant is a modified script and is declared as one; it is evidence about the tree it was pointed at, which is what the original could not be. AND THE RULE THIS TEACHES, which the gate now enforces mechanically for any declaration citing a digest: A VERIFICATION DECLARATION IS A RECORD OF WHAT WAS RUN, AND A SCRIPT THAT PINS A REVISION CANNOT TESTIFY ABOUT ANY OTHER REVISION. If a fixture pins a revision, the declaration says which tree it tested. WHAT WAS NOT DONE, STATED HERE RATHER THAN LEFT TO BE FOUND (v1.61 draft; binds nothing until that version's own owner push). The runs recorded above happened and their outputs are recorded, but they were NOT COMMITTED AS A RED COMMIT, and this version cites none where v1.58 (fbf8002), v1.59 (998b859) and v1.60 (1294b5d) each cite one. Canaries and repairs were authored in one working tree across the same three instrument files -- tools/km-release-gate.py, tests/test_release_gate.sh and this one, which carries both the repaired reader and its own canaries as interleaved hunks -- so no revision exists at which these cases stand red alone. A retroactive red commit was refused rather than overlooked, because manufacturing one in the version whose own subject is a true statement in a working report becoming a false statement in a published artifact would be the defect this version is about. The evidence is reproducible from git instead, and was reproduced that way here: check_tree taken from `git show 164ecfb:tests/test_skill_frontmatter.sh` returns exit 0 with 0 violation lines on the reviewer's own indented-comment fixture, where the repaired reader returns exit 1 naming '! FRONTMATTER CONTINUATION LINE CONTINUES NO KEY'. The v1.60 declaration this replaces still holds except where it is corrected above: v1.60 | re-stated for the tab-indentation repair. Run against the unrepaired tree at 73f89e8 (published v1.59) before any repair was written, using the external reviewer's OWN reproduction script (reproduce-tab-indentation-false-pass.sh, sha256 526b32d2b21b019ab85540aecc9d504b79b7f5557b89ebd781fad88c5d543832, pins 73f89e80774f7401eebb106572c14824a9e60d15 internally and re-clones it whatever source root it is handed, so it tested the v1.59 tree on every run it ever made) unmodified on a detached clone at that commit, because their environment and this one are identical: macOS 26.5.2 arm64, bash 3.2.57, ruby 2.6.10p210 with Psych 3.1.0 and libyaml 0.2.1, python 3.9.6, git 2.50.1. Their fixture puts a TAB-indented continuation line under description: in all three shipped copies of skills/km-brief/SKILL.md. On the unrepaired tree it printed 'PASS: 23 skill file(s) ...', 'ALL SKILL FRONTMATTER CHECKS PASSED', checker_exit=0 and ruby_yaml_exit=1 with Psych::SyntaxError 'found a tab character that violate indentation while scanning a plain scalar at line 3 column 14', printing REPRODUCED: the v1.59 checker passed tab-indented frontmatter that Ruby YAML rejects. Nine cases were added here and run against the unrepaired tree; SIX were red, reporting 'canary NOT caught': tab-indented continuation (the reviewer's content byte for byte), tab then space as a continuation's indentation, a line whose entire content is one tab, a tab between a sequence indicator and its value, a tab inside a sequence entry's indentation, and a sequence entry indented with a tab. THREE passed on the unrepaired tree and only two of them legitimately, which is recorded rather than counted as detection: the two clean_canary cases -- a tab after the key's colon, and a tab inside the value -- pin shapes libyaml ACCEPTS and that this reader must keep accepting, and they passed for their own reason; the tab-indented COMMENT case passed for the WRONG reason, the tab-indented comment being folded into name and tripping the slug rule with the message "name 'km-thing # a comment indented with a tab' is not the directory slug", so on the unrepaired tree nothing detected a tab at all. On the repaired tree all six fire naming the tab, the comment case fires as a tab rather than as a slug mismatch, and both clean cases still pass. THE NEXT CLAUSE OF THIS SENTENCE WAS FALSE WHEN v1.60 PUBLISHED IT AND IS CORRECTED IN v1.61 (a DRAFT that binds nothing until that version's own owner push): it read 'and the reviewer's script prints NOT REPRODUCED with checker_exit=1'. That script pins 73f89e8 and re-clones it, so it tested v1.59 on every run and printed REPRODUCED on every run; re-measured on 2026-08-26 against the published v1.60 tree it printed 'REPRODUCED: the v1.59 checker passed tab-indented frontmatter that Ruby YAML rejects' at exit 0. It could not have said otherwise, and the drafting report of v1.60 said so in plain words while the artifact said the opposite. The repair was in fact verified by the nine integrated canaries in section 6 of this suite, four of them carrying the reviewer's fixture content byte for byte, six of which were red on the unrepaired tree. The cause is the arm '[[:space:]]' being read as indentation: that class contains the tab, so a tab-indented line was folded as a continuation, and '${#ind_str}' then measured a tab as one column in the v1.59 sequence-indentation comparison. It got there by a repair rather than by an omission -- v1.58 found the original arm written "\t"* inside double quotes, a literal backslash-t that had been INERT since it was written, and made it LIVE without asking whether it should match.  The v1.59 declaration this replaces still holds: v1.59 | re-stated for the top-level-sequence repair, the coverage-claim correction and the subset boundary. Run against the unrepaired tree at be6e4bf (published v1.58) before any repair was written, using the external reviewer's OWN reproduction script (reproduce-invalid-yaml-sequence.sh, sha256 cf6fcbc3d0a7af6d347589c0019ff190c3788949a6ab9c8644b81bfb4b407bbf, pins no revision but reads its checker from the fixed path /private/tmp/km-v158-builder-recheck/repo, so it tested whatever tree stood at that path -- and the digest v1.59 published for this file carried 65 characters and named nothing, corrected here in v1.61, a draft that binds nothing until that version's own owner push) unmodified, because their environment and this one are identical: macOS 26.5.2 arm64, bash 3.2.57, ruby 2.6.10p210 with Psych 3.1.0 and libyaml 0.2.1, python 3.9.6, git 2.50.1. Their fixture is a valid name, a conforming description, and one root-level line reading '- top-level sequence content makes this YAML document invalid'. On the unrepaired tree it reported checker_exit=0 and ruby_yaml_exit=1 with Psych::SyntaxError 'did not find expected key while parsing a block mapping at line 2 column 1', printing REPRODUCED: the v1.58 checker passed a frontmatter block rejected by Ruby YAML. The canary added here carries that fixture byte for byte and reported 'canary NOT caught' on the unrepaired tree, the suite exiting 1 with the other twelve canaries still passing. On the repaired tree the same script reports checker_exit=1 naming '! SEQUENCE ENTRY IS NOT MORE-INDENTED THAN ANY KEY, SO IT CONTINUES NOTHING' on the reviewer's own line. HOW THAT CLAIM WAS RE-VERIFIED IN v1.61 (a draft that binds nothing until that version's own owner push), rather than inherited on the earlier session's word: this script is PATH-pinned, not revision-pinned -- it reads its checker from the fixed /private/tmp/km-v158-builder-recheck/repo, and that path no longer exists -- so it was re-run with THAT ONE LINE re-pointed at this working tree and nothing else changed, and it printed exactly that message at checker_exit=1, then exited 1 at its own 'test CHECK_STATUS -eq 0' without reaching either verdict line. The distinction is the point: a PATH-pinned script can testify about whichever tree stands at that path, so re-pointing it is a re-run rather than a different experiment, whereas a REVISION-pinned script re-clones its commit and can testify about nothing else at all. The cause is one arm the v1.58 repair carried forward from the original pattern without re-deriving it, the leading-marker arm, which accepted a sequence entry at ANY indentation as a continuation of the preceding key; YAML makes it a continuation only when it is more-indented than the key it continues. The positive-direction canary added beside it, a sequence indented under its own key, passes on the unrepaired tree and on the repaired one, because its job is to pin the shape the reader must keep accepting rather than to detect the defect. Two further changes here are claim corrections and carry no unrepaired-tree run, because there is no defect in what the check DOES to run against: the passing line claimed 'every shipped skill file' while reading three directories of a repository that ships a fourth SKILL.md under agents/, and it now states the count and the roots actually read; and the reader now names the plain-scalar subset it models, so a green line is not read as a claim of valid YAML. The v1.58 declaration this replaces still holds in full: re-stated for the folded-value repair. Run against the unrepaired tree at 510cf03 before any repair was written. A fixture whose description first line is 13 words and whose following indented lines are folded into the same plain scalar by any real YAML parser was accepted: check_tree returned exit 0 with zero violation lines, having measured 13 words against the 10-40 residency budget, while Ruby's YAML parser on the same host read the effective value as 97 words. A second fixture, an indented line placed before any key in the block so that it continues nothing at all, was also accepted at exit 0. Two new canaries were added for those and both reported 'canary NOT caught' on the unrepaired tree; the suite exited 1 with the other ten canaries still passing. The cause is two lines of the continuation arm: every indented line was skipped unconditionally, with no state, no record of which key it continued and no requirement that any key precede it, and the budget was then measured against the first physical line alone. A third case was found while repairing rather than by probing: the arm's tab pattern was written "\t"* inside double quotes, which is a literal backslash-t and matched no tab-indented line on this host, so that half of the arm had been inert since it was written. The positive-direction canary added with them, a legitimate two-line description inside the budget, passes on the unrepaired tree and on the repaired one, because its job is to pin the shape the reader must keep accepting rather than to detect the defect. The v1.55 declaration this replaces still holds in full: re-stated for the block-integrity repair. Run against the tree at 13dec55 with the closing '---' deleted from all three shipped copies of skills/km-brief/SKILL.md, the unrepaired check prints "PASS: every shipped skill file carries a conforming name/description frontmatter" and "ALL SKILL FRONTMATTER CHECKS PASSED", exit 0, because awk runs to end of file when no terminator exists and reads the whole body as the block. Four further malformations were probed on the same tree and all four passed it at exit 0 with 0 violation lines: a '...' terminator, a duplicated name key, a duplicated description key, and an extra key. The fifth, an empty block, was already caught at exit 1 with 6 violation lines. A sixth case was found while repairing rather than by probing, and it is the one that matters: requiring merely that SOME closing '---' exists is not enough, because every shipped skill file carries '---' horizontal rules in its prose, so deleting the real terminator moves the delimiter down the document and the block swallows 16 lines of body while both keys stay present and unique. Measured on the repaired check with only the terminator rule in place: exit 0. The repaired check therefore also requires every line inside the block to read as a mapping entry, a continuation, a comment or a blank, and it then fails all five with a named violation each and passes the clean tree unchanged. The v1.27 declaration this replaces was 'unrecorded'; that debt is discharged for the delimiter and duplicate-key rules only.
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
#   5. A line CONTINUES a key only when it is more-indented than that key (repaired in v1.59).
#      Until then a `- ` at any indentation was taken as a continuation, so a top-level sequence
#      entry -- which makes a block mapping unparseable outright -- was accepted. See the block
#      comment inside check_tree.
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

# WHAT THIS READER GUARANTEES, AND WHAT IT DOES NOT. (Stated in v1.59.)
#
# This check takes NO YAML library as a dependency, deliberately and permanently: v1.51 exists
# because a shipped tool assumed its author's toolchain, and neither PyYAML nor Ruby's Psych is
# guaranteed in the environment a deployment runs this in. It is therefore an APPROXIMATION, and
# from v1.59 the approximation is named rather than left to be discovered by whoever tests it
# against a real parser.
#
# THE SUBSET IT MODELS. A frontmatter block delimited by `---` on its own line at the top and a
# second `---` on its own line; inside it, a block mapping whose keys stand at column zero and match
# `[A-Za-z_][A-Za-z0-9_.-]*:`; plain scalar values, folded across continuation lines that are
# more-indented than the key they continue, sequence entries included; whole-line comments at column
# zero; and blank lines. That is what this standard's own skill files use, and the check judges
# `name` and `description` on the folded logical value.
#
# WHAT IT DOES NOT MODEL, so a green line is not a claim that any of these were evaluated: flow
# collections, block scalars (`|` and `>`), anchors, aliases, tags, multiple documents, quoted or
# complex keys, nested mappings, and the whole of YAML's scalar resolution. A file this check
# accepts is conforming to THIS STANDARD'S frontmatter contract as modelled here. It is not thereby
# certified as valid YAML, and the passing line says which of the two it means.
#
# THE OTHER DIRECTION IS THE ONE THAT WAS WRONG, AND IT IS THE ONE TIGHTENED. Accepting something a
# parser would refuse is not an approximation, it is a false pass: until v1.59 a root-level `- ` was
# folded into the preceding key, and a block mapping followed by a root sequence is not a subtle
# scalar-resolution difference but a structurally invalid document that no runtime can load and no
# legitimate skill file needs. Bounding the claim would not have made that acceptable; both were
# done.

# THE SET THIS CHECK READS, NAMED ONCE, AND THE CLAIM IT MAY THEREFORE MAKE. (v1.59.)
#
# Found by the sweep v1.59 ran for the class "a control's scope is narrower than the thing it
# certifies". Until v1.59 the passing line read "every shipped skill file carries a conforming
# name/description frontmatter" while the scan read three directories, and the repository ships a
# fourth SKILL.md: agents/km-hub-builder/SKILL.md, an agent contract that carries the same two
# fields. The claim was broader than the set, which is the shape of the defect the same sweep found
# in the release gate.
#
# The CLAIM is corrected here and the SCOPE is registered rather than widened, deliberately.
# Measured on be6e4bf: that contract's `description` is 42 words, so admitting it to this scan
# would redden the tree, and whether an agent contract is held to a residency budget written for
# runtime skill files is a policy decision about what this standard's agent contracts may carry --
# not a defect in how this check reads its input. Settling it inside a repair to the reader would
# settle it silently, which is the treatment the extra-key question already has above. It is
# written here so the next maintainer finds the question.
# THE TAB MATCHER IS PROBED AGAINST THE LIVE SHELL BEFORE IT IS TRUSTED. (v1.60.)
#
# This is the v1.29 rule -- verify a matching construct against the tool that will actually run it
# -- applied to the construct that made v1.60 necessary. From v1.27 to v1.58 the tab arm here was
# written "\t"* inside double quotes, which is a LITERAL BACKSLASH-T: it matched nothing for as
# long as it stood, and an inert matcher and a clean tree are the same colour. So the matcher is
# run against a string it MUST match and a string it MUST NOT, and this suite REFUSES rather than
# returning a verdict it cannot support. A refusal here is a defect in the construct, never a
# statement about any skill file.
TAB=$'\t'
if [ "${#TAB}" -ne 1 ] || [[ "x${TAB}y" != *"$TAB"* ]] || [[ "xy" == *"$TAB"* ]]; then
  echo "REFUSED: the tab matcher this check depends on is inert in this shell (bash ${BASH_VERSION:-unknown});" >&2
  echo "         an inert matcher and a clean tree look identical, so no verdict is returned." >&2
  exit 2
fi

skill_scan_roots() { # <root>: sets SKILL_ROOTS to the directories this check reads. One definition.
  SKILL_ROOTS=("$1/skills" "$1/template/.claude/skills" "$1/template/.agents/skills")
}

# --- the checker, as a function, so the canaries can run it against a synthetic tree ---
# Usage: check_tree <root>  → prints one line per violation, exit 1 if any
check_tree() {
  skill_scan_roots "$1"
  local root="$1" bad=0 f slug fm name desc words close key val cont cur_key cur_indent cur_kind n_name n_desc fmline ind_str seq_lead rest ind is_seq
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
    #
    # A CONTINUATION IS DECIDED BY INDENTATION, NEVER BY A LEADING MARKER (repaired in v1.59).
    #
    # The v1.58 repair above added the state, and carried one arm of the original pattern forward
    # without re-deriving it: `"- "*`, which accepted a sequence entry at ANY indentation as a
    # continuation of the preceding key. YAML makes a sequence the value of a key only when it is
    # more-indented than that key. A `- ` at the indentation of the mapping is a block sequence
    # entry where a mapping key is required, and a parser rejects the whole document. Measured on
    # be6e4bf: a block with a valid `name`, a valid 15-word `description` and two top-level
    # `- item` lines was accepted at exit 0 with no violation line, while Ruby's YAML parser on the
    # same host answered `did not find expected key while parsing a block mapping at line 2
    # column 1`. So the check accepted a document no runtime can load.
    #
    # The lesson is about the repair rather than the arm: v1.58 repaired a LINE instead of
    # re-deriving what the line was for, and an untested arm rode through unexamined. Each line is
    # now measured against the indentation of the key it would continue, which is `cur_indent`, and
    # a sequence entry that is not more-indented than any key is named as continuing nothing.
    cur_key=""; cur_indent=0; cur_kind=""; name=""; desc=""; n_name=0; n_desc=0
    while IFS= read -r fmline; do
      # A BLANK LINE ENDS NOTHING. Inside a plain scalar it is a line break that a parser folds,
      # and Psych accepts a continuation after it, so the state is carried across untouched.
      # A COMMENT IS NOT SKIPPED BLIND ANY MORE (v1.61 draft; binds nothing until that version's own owner push); see the comment arm below the tab check.
      # It used to be skipped here, at column zero only, which had two consequences: an INDENTED
      # comment was never recognised as a comment at all and was folded into the preceding value as
      # an ordinary continuation, and a column-zero comment left the current key open so that
      # whatever followed was folded too. Both are false passes -- Psych rejects a continuation
      # after a comment in either position -- and the second was invisible because the first was
      # the one a reviewer could see.
      case "$fmline" in
        "") continue ;;
      esac
      # THE INDENTATION REGION of the line: its leading whitespace, plus -- on a sequence entry --
      # the `-` indicator and the whitespace after it. [[:space:]] is used to CAPTURE the region,
      # deliberately, so that a tab inside it is SEEN here and rejected below rather than never
      # matched and silently mis-measured. `rest` is what follows that region: the continuation arm
      # takes its value straight from it, so nothing downstream re-derives the region a second time.
      [[ "$fmline" =~ ^([[:space:]]*)((-[[:space:]]+|-$)?)(.*)$ ]] \
        && { ind_str="${BASH_REMATCH[1]}"; seq_lead="${BASH_REMATCH[2]}"; rest="${BASH_REMATCH[4]}"; } \
        || { ind_str=""; seq_lead=""; rest="$fmline"; }
      # INDENTATION IS SPACES, AND A TAB IN IT IS A REJECTION NAMING THE TAB. (v1.60.)
      # YAML forbids tabs in indentation. Until v1.60 this reader read `[[:space:]]` AS the
      # indentation -- a class that contains the tab -- so a tab-indented continuation was folded
      # into the preceding key and the block was accepted, while Psych answered "found a tab
      # character that violate indentation while scanning a plain scalar". That is a false pass by
      # this standard's own words: reading LESS of a valid document than a parser does is an
      # approximation and is legitimate once named; accepting a document a parser REFUSES is not.
      # The rejection also makes the v1.59 comparison below sound, which it was not: with tabs
      # excluded from the region, `${#ind_str}` is a true column count rather than a measurement
      # that scores a tab as one column and compares it against spaces.
      # This is STRICTER than libyaml in one named place: libyaml accepts `  <TAB>text`, where the
      # indentation is already satisfied by a space and the tab is separation. Rejecting it is a
      # house rule this standard draws on purpose, and the error it can make is a false FAIL on a
      # document mixing spaces and tabs in one indent, never a false pass. A tab that is NOT in the
      # indentation region -- after the key's colon, or inside a value -- is untouched, and two
      # clean_canary cases below require exactly that.
      if [[ "$ind_str$seq_lead" == *"$TAB"* ]]; then
        echo "  ! TAB IN THE INDENTATION OF A FRONTMATTER LINE; YAML FORBIDS IT AND INDENTATION HERE IS SPACES: '${fmline:0:60}': ${f#$root/}"; bad=1; cur_key=""; cur_kind=""; continue
      fi
      ind=${#ind_str}
      is_seq=0
      [ -n "$seq_lead" ] && is_seq=1
      # A WHOLE-LINE COMMENT ENDS A PLAIN SCALAR THAT HAS ALREADY STARTED.
      # (v1.61 draft; binds nothing until that version's own owner push.)
      #
      # It ends nothing else, and that is the whole of the rule. It does not end a block sequence,
      # it does not end a key whose value has not started, and a blank line ends nothing at all.
      # Every one of those was measured against Psych on the reference environment rather than
      # reasoned about; the ten shapes and their answers are listed above section 7 of this suite.
      #
      # v1.60 registered this rather than repairing it, on the ground that modelling what a parser
      # does to a continuation after a comment was a repair riding inside the tab repair. The
      # premise was wrong on the facts: the model is one sentence and one extra piece of state, and
      # what was missing was a measurement, not a parser. Rejecting the construct outright was the
      # honest fallback and was refused once the probes came back, because it would refuse a comment
      # between two sequence entries, which is ordinary YAML.
      #
      # `cur_kind` is what the current key's value is: empty (not started), `scalar`, or `seq`. It
      # is read here and set at every point below where a value begins or a key is cleared.
      #
      # The tab check above runs FIRST, deliberately: a tab-indented comment is a tab rejection, as
      # it has been since v1.60, and its canary still requires that message rather than this one.
      if [ -z "$seq_lead" ]; then
        case "$rest" in
          "#"*)
            [ "$cur_kind" = "scalar" ] && { cur_key=""; cur_indent=0; cur_kind=""; }
            continue ;;
        esac
      fi
      if [ "$ind" -gt "$cur_indent" ] && [ -n "$cur_key" ]; then
        # `rest` already IS the line with its indentation region removed, computed once above.
        # Taking `rest` here is a v1.60 change.
        # Until v1.60 this arm re-derived the region with a second `[[:space:]]`-based match, which
        # is one more place for the same wrong assumption to live and one more place to keep in
        # step; taking the value the single derivation produced removes both.
        cont="$rest"
        # What kind of value this key is carrying, which the comment arm above reads. A sequence
        # entry makes it a sequence and it stays one: a plain line under an entry is that ENTRY's
        # own scalar continuing, not the key's, and a comment does not end a sequence either way.
        if [ "$is_seq" -eq 1 ]; then cur_kind="seq"
        elif [ "$cur_kind" != "seq" ]; then cur_kind="scalar"
        fi
        case "$cur_key" in
          name)        name="$name $cont" ;;
          description) desc="$desc $cont" ;;
        esac
        continue
      fi
      if [ "$ind" -gt 0 ]; then
        echo "  ! FRONTMATTER CONTINUATION LINE CONTINUES NO KEY: '${fmline:0:60}': ${f#$root/}"; bad=1; continue
      fi
      if [ "$is_seq" -eq 1 ]; then
        echo "  ! SEQUENCE ENTRY IS NOT MORE-INDENTED THAN ANY KEY, SO IT CONTINUES NOTHING: '${fmline:0:60}': ${f#$root/}"; bad=1; cur_key=""; cur_kind=""; continue
      fi
      if [[ "$fmline" =~ ^([A-Za-z_][A-Za-z0-9_.-]*):([[:space:]].*)?$ ]]; then
        key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
        [[ "$val" =~ ^[[:space:]]*(.*)$ ]] && val="${BASH_REMATCH[1]}"
      else
        echo "  ! FRONTMATTER LINE IS NOT A MAPPING ENTRY: '${fmline:0:60}': ${f#$root/}"; bad=1; cur_key=""; cur_kind=""; continue
      fi
      cur_key="$key"; cur_indent="$ind"
      # `description:` with nothing after it has not started its value, so a comment on the next
      # line ends nothing and the value may still begin below it. Psych accepts exactly that.
      if [ -n "$val" ]; then cur_kind="scalar"; else cur_kind=""; fi
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
  done < <(find "${SKILL_ROOTS[@]}" -name SKILL.md -type f 2>/dev/null | sort)
  return $bad
}

# --- 1. the real repository passes ---
out="$(check_tree "$ROOT")"
skill_scan_roots "$ROOT"
scanned=$(find "${SKILL_ROOTS[@]}" -name SKILL.md -type f 2>/dev/null | wc -l | tr -d ' ')
if [ -z "$out" ]; then
  pass "$scanned skill file(s) under skills/, template/.claude/skills/ and template/.agents/skills/ conform to this standard's name/description frontmatter contract, read as the plain-scalar subset stated above and not by a YAML parser; agent contracts under agents/ are out of scope (see the note above skill_scan_roots)"
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
# THIS SECTION BELONGS TO v1.59.
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
  # THE REVIEWER'S OWN FIXTURE, BYTE FOR BYTE, and that is the point of it. A canary derived from a
  # description of a finding tests the description; this block is lifted from
  # reproduce-invalid-yaml-sequence.sh, the script the external reviewer ran, so what is asserted
  # here is the defect they observed rather than this maintainer's reading of their report.
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and invocation plainly for this independent review.
- top-level sequence content makes this YAML document invalid
---

# Remaining body
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

# --- 6. INDENTATION IS SPACES; A TAB IN IT IS A REJECTION NAMING THE TAB (v1.60) ---
# THIS SECTION BELONGS TO v1.60.
#
# YAML FORBIDS TABS IN INDENTATION, and until v1.60 this reader treated `[[:space:]]` -- a class
# that CONTAINS the tab -- as indentation. A tab-indented continuation was folded into the
# preceding key and the block was accepted, while a real parser refuses the document outright.
#
# HOW IT GOT HERE IS THE SHARPER LESSON. The original tab arm was written `"\t"*` inside double
# quotes, which is a literal backslash-t: it was INERT since the day it was written and no
# tab-indented line ever matched it. v1.58 found that and made the arm LIVE by switching to
# `[[:space:]]`, without asking whether the arm SHOULD match. Making a dead arm live is how an
# inert arm became a false pass, and it is the same failure as v1.59's: a LINE was repaired
# instead of the question the line existed to answer being re-derived.
#
# THE BOUNDARY IS MEASURED AGAINST THE PARSER, NOT ASSUMED. On the reference environment (ruby
# 2.6.10p210, Psych 3.1.0, libyaml 0.2.1) the following were probed one at a time:
#
#   `description: a` then a line beginning with a TAB          -> rejected, "found a tab character
#                                                                 that violate indentation"
#   the same with TAB then SPACE                               -> rejected
#   the same with TAB TAB                                      -> rejected
#   a line whose entire content is one TAB                     -> rejected (it is not a blank line)
#   a comment line indented with a TAB                         -> rejected
#   a sequence entry indented with a TAB                       -> rejected
#   `  -<TAB>alpha`  (TAB between the indicator and the value) -> rejected, "found character that
#                                                                 cannot start any token"
#   `   <TAB>- alpha` (TAB inside the indentation of a seq)    -> rejected
#   `description:<TAB>value`  (TAB after the key's colon)      -> ACCEPTED; that tab is separation
#                                                                 space, not indentation
#   `description: aa<TAB>bb`  (TAB inside the value)           -> ACCEPTED
#   `description: a` then SPACE(s) then TAB then text          -> ACCEPTED; the indentation was
#                                                                 already satisfied by the space
#
# THE RULE THIS READER ADOPTS IS STRICTER THAN THE LAST OF THOSE, DELIBERATELY, AND THE DIVERGENCE
# IS DECLARED RATHER THAN DISCOVERED. Indentation here is SPACES. A tab anywhere in a line's
# indentation region -- its leading whitespace, plus the `-` indicator and the whitespace after it
# on a sequence entry -- is a rejection naming the tab. That refuses `  <TAB>text`, which libyaml
# accepts, and it is a house rule this standard is entitled to draw: the error it can produce is a
# false FAIL on a document mixing spaces and tabs in one indent, never a false PASS, and no shipped
# skill file does that. It is what makes the v1.59 indentation-width comparison sound as well:
# once the indentation region can hold spaces only, `${#ind_str}` is a true column count instead of
# a measurement that scores a tab as one column.
#
# The tabs below are written with `printf '%b'` rather than a heredoc, because a heredoc carrying a
# literal tab is invisible in a diff and one stray editor is enough to turn this whole section
# inert -- which is precisely the defect being repaired.
write_tab_continuation() { # THE REVIEWER'S OWN CONTENT, byte for byte: a TAB then their words
  printf '%b' '---\nname: km-thing\ndescription: Use when someone needs a memo briefing or status report drawn from this hub\n\twith traceable source evidence\n---\n\n# body\n' > "$1"
}
write_tab_then_space_continuation() {
  printf '%b' '---\nname: km-thing\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger\n\t and its own invocation here\n---\n\n# body\n' > "$1"
}
write_tab_only_line() { # a line whose entire content is one tab is not a blank line to a parser
  printf '%b' '---\nname: km-thing\n\t\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\n---\n\n# body\n' > "$1"
}
write_tab_indented_comment() {
  printf '%b' '---\nname: km-thing\n\t# a comment indented with a tab\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\n---\n\n# body\n' > "$1"
}
write_tab_after_seq_dash() { # `  -<TAB>alpha`: the tab is in the entry's indentation region
  printf '%b' '---\nname: km-thing\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\ntags:\n  -\talpha\n---\n\n# body\n' > "$1"
}
write_tab_before_seq_dash() { # `   <TAB>- alpha`: the tab is inside the leading whitespace
  printf '%b' '---\nname: km-thing\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\ntags:\n   \t- alpha\n---\n\n# body\n' > "$1"
}
write_tab_indented_sequence() { # a sequence entry whose whole indentation is a tab
  printf '%b' '---\nname: km-thing\ndescription: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\ntags:\n\t- alpha\n---\n\n# body\n' > "$1"
}
# The other direction, and it is what keeps the rule above from being "reject anything with a tab
# in it". Each of these is ACCEPTED by libyaml on the reference environment and must be accepted
# here, so the tightening ships beside the shapes it must keep taking.
write_tab_after_key_colon() { # `description:<TAB>value`: separation space, not indentation
  printf '%b' '---\nname: km-thing\ndescription:\tUse when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.\n---\n\n# body\n' > "$1"
}
write_tab_inside_value() { # a tab in the middle of a value is not indentation either
  printf '%b' '---\nname: km-thing\ndescription: Use when a synthetic fixture needs a conforming\tdescription that names its trigger and its own invocation, /km-thing, plainly.\n---\n\n# body\n' > "$1"
}
canary "tab-indented continuation line"                    write_tab_continuation "$f"
canary "tab then space as a continuation's indentation"    write_tab_then_space_continuation "$f"
canary "a line whose entire content is one tab"            write_tab_only_line "$f"
canary "tab-indented comment line"                         write_tab_indented_comment "$f"
canary "tab between a sequence indicator and its value"    write_tab_after_seq_dash "$f"
canary "tab inside a sequence entry's indentation"         write_tab_before_seq_dash "$f"
canary "sequence entry indented with a tab"                write_tab_indented_sequence "$f"
clean_canary "a tab after the key's colon is separation"   write_tab_after_key_colon "$f"
clean_canary "a tab inside the value is not indentation"   write_tab_inside_value "$f"

# --- 7. A WHOLE-LINE COMMENT ENDS A PLAIN SCALAR; IT DOES NOT END A SEQUENCE (v1.61) ---
# THIS SECTION BELONGS TO v1.61, WHICH IS A DRAFT AND BINDS NOTHING UNTIL THAT VERSION'S OWN
# OWNER PUSH.
#
# v1.60's own sweep found this and registered it rather than repairing it: a space-indented
# `# comment` inside the block is a comment to Psych, and this reader folded it into the preceding
# value as an ordinary continuation, then accepted whatever followed. The registered reason was that
# modelling it "requires modelling what Psych does to a continuation that follows a comment, and
# doing that inside a repair to tab handling would be a repair riding inside a repair". An external
# reviewer then demonstrated the false pass with a real fixture, and ruled -- correctly -- that
# disclosure does not satisfy a no-open-defect criterion. So it is repaired here, on its own, with
# its own canaries.
#
# THE MODEL WAS NOT OUT OF REACH; IT WAS NEVER MEASURED. It is one rule, and it was derived by
# probing the reference parser rather than by reasoning about the specification. On the reference
# environment (ruby 2.6.10p210, Psych 3.1.0, libyaml 0.2.1), one shape at a time:
#
#   scalar, then `# c` at column 0, then a continuation      -> REJECTED, "did not find expected key"
#   scalar, then `  # c` indented, then a continuation       -> REJECTED  (the reviewer's fixture)
#   scalar, a continuation, then `    # c` deeper, then
#            another continuation                            -> REJECTED
#   scalar, then `  #` (an empty comment), then a
#            continuation                                    -> REJECTED
#   scalar, then a comment, then NOTHING                     -> ACCEPTED
#   scalar, then a comment, then a new key at column 0       -> ACCEPTED
#   key with an EMPTY value, then a comment, then the value
#            as a continuation                               -> ACCEPTED
#   a sequence entry, then a comment, then another entry     -> ACCEPTED
#   a sequence entry with its own continuation, then a
#            comment, then another entry                     -> ACCEPTED
#   a blank line inside a plain scalar, then a continuation  -> ACCEPTED (a blank is a line break,
#                                                              not a terminator)
#
# One sentence covers every one of them: A WHOLE-LINE COMMENT ENDS A PLAIN SCALAR THAT HAS ALREADY
# STARTED. It does not end a block sequence, it does not end a key whose value has not started yet,
# and a blank line ends nothing. So the reader keeps one more piece of state -- what kind of value
# the current key is carrying -- and a comment clears the current key only when that value is a
# plain scalar in progress. What follows a cleared key then meets the rule that has stood since
# v1.58: a line that continues nothing is a violation naming itself.
#
# THIS IS A MODEL, NOT A HOUSE RULE, and the difference is worth stating because the tab rule
# directly above IS a house rule. Every shape listed here was measured, and every one is answered
# the same way by this reader and by Psych, so there is no declared divergence to record. Rejecting
# the construct outright was weighed -- it was the honest fallback if the model proved out of reach
# -- and refused once the probes came back, because a rejection would make this reader refuse
# `  # c` between two sequence entries, which is ordinary YAML a shipped file may legitimately want.
write_col0_comment_then_continuation() {
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger
# this comment at column zero ends the scalar
  and this line then continues nothing at all
---

# body
FIX
}
write_indented_comment_then_continuation() {
  # THE REVIEWER'S OWN CONTENT, BYTE FOR BYTE, from reproduce-indented-comment-continuation.sh
  # (sha256 9415c372b9dd22f519d92ccac6d574b318affa102a9b41be1296251943d55e56, pins
  # 164ecfb36fd7a644365ee9dff41a540130e15e82 and therefore tests only the v1.60 tree). The three
  # lines below are what their patch writes into skills/km-brief/SKILL.md, so what is asserted here
  # is the defect they observed rather than this maintainer's reading of their report.
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when someone needs a memo briefing or status report drawn from this hub
  # this YAML comment interrupts the scalar continuation
  with traceable source evidence
---

# body
FIX
}
write_deeper_comment_then_continuation() {
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger
  and its own invocation here
    # a comment deeper than the continuation still ends the scalar
  and this line then continues nothing at all
---

# body
FIX
}
write_empty_comment_then_continuation() { # `  #` with no text after it is still a comment
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger
  #
  and this line then continues nothing at all
---

# body
FIX
}
# The other direction. Five shapes Psych ACCEPTS, so a reader tightened until it refuses them has
# swapped a false pass for a false failure, which is the same defect wearing the opposite sign.
write_comment_then_end_of_block() {
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
  # a comment that ends the scalar and is followed by nothing
---

# body
FIX
}
write_comment_then_new_key() {
  cat > "$1" <<'FIX'
---
name: km-thing
  # a comment between two keys is a comment, and the key below opens its own value
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
---

# body
FIX
}
write_comment_before_a_value_starts() { # the key's value has not started, so nothing is ended
  cat > "$1" <<'FIX'
---
name: km-thing
description:
  # the value has not started yet, so this comment ends nothing
  Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
---

# body
FIX
}
write_comment_between_sequence_entries() { # a comment does not end a block sequence
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger and its own invocation, /km-thing, plainly.
tags:
  - alpha
  # a comment between two entries leaves the sequence open
  - beta
---

# body
FIX
}
write_blank_line_then_continuation() { # a blank line is a line break inside the scalar, not an end
  cat > "$1" <<'FIX'
---
name: km-thing
description: Use when a synthetic fixture needs a conforming description that names its trigger

  and its own invocation, /km-thing, across a blank line.
---

# body
FIX
}
canary "column-zero comment then a continuation"            write_col0_comment_then_continuation "$f"
canary "indented comment then a continuation"               write_indented_comment_then_continuation "$f"
canary "comment deeper than the continuation, then another" write_deeper_comment_then_continuation "$f"
canary "an empty comment then a continuation"               write_empty_comment_then_continuation "$f"
clean_canary "a comment ending the block after a scalar"    write_comment_then_end_of_block "$f"
clean_canary "a comment between two keys"                   write_comment_then_new_key "$f"
clean_canary "a comment before the value has started"       write_comment_before_a_value_starts "$f"
clean_canary "a comment between two sequence entries"       write_comment_between_sequence_entries "$f"
clean_canary "a blank line inside a plain scalar"           write_blank_line_then_continuation "$f"

# AND THE PROBE AT THE TOP OF THIS FILE IS ITSELF PROVED IN BOTH DIRECTIONS. (v1.60.) It refuses
# when the tab matcher is inert; these two lines show that the inert form and the live form are
# genuinely distinguishable in this shell, so the probe is separating two states rather than
# agreeing with whatever it is given. The first is the exact construct that stood in this file
# from v1.27 to v1.58 and matched nothing the whole time.
if [[ "x${TAB}y" == *"\t"* ]]; then
  die 'the literal backslash-t form MATCHED a real tab; the probe above cannot tell inert from live'
else
  pass 'the literal backslash-t form is inert against a real tab, as it was from v1.27 to v1.58'
fi
if [[ "x${TAB}y" == *"$TAB"* ]]; then
  pass 'the live tab matcher this reader uses does match a real tab'
else
  die 'the live tab matcher did not match a real tab'
fi

echo
if [ "$fail" -eq 0 ]; then echo "ALL SKILL FRONTMATTER CHECKS PASSED"; else echo "SKILL FRONTMATTER CHECKS FAILED"; fi
exit "$fail"
