#!/bin/bash
# km-unrepaired-tree: v1.56 | added in v1.56 and run against the unrepaired tree first, which is main at aeec51a: case 2 FAILED, naming km-publish as a skill the template installs in both runtime trees and the README's enumeration does not carry, so the landing page told a reader the template ships six per-hub skills when it ships seven. Case 3 PASSED there legitimately, because the nine entity-note folders the README names are exactly the nine directories under template/ carrying a TEMPLATE.md; a case that passes on the unrepaired tree is recorded as passing rather than reworded until it fails. Cases 5 and 6 are the negative direction and were driven against mutated copies of the README on both trees.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# The README's `template/` row enumerates two sets: the entity-note folders the template ships and
# the per-hub agent skills it installs. Both are inventories of a directory, both were written by
# hand, and until v1.56 nothing compared either against the directory it describes. This check
# derives both sets from the tree and requires the README's enumeration to be exactly equal to the
# derivation, in both directions: a member the README omits is a defect, and a member the README
# names that the template does not ship is a defect.
#
# It proves nothing about the rest of the row, about whether the skills are the right skills, or
# about any other sentence on the landing page. It models one class, which is an enumeration of a
# directory written as prose beside the directory, and that class only.
#
# WHY THE README AND NOT THE STANDARD. A landing page is what an adopter and a fork read first, and
# the standard already holds that a claim on an inherited or advertised surface is weighed by the
# number of readers it reaches (§"A document is held to what the system does"). The README's row is
# the only place in this repository that enumerates what the template installs.
#
# BOTH DIRECTIONS. A comparison passes trivially when it compares nothing, so:
#   - case 1 fails closed when either derivation is empty, because an unread directory is not an
#     empty one;
#   - cases 5 and 6 run the same comparison against a deliberately mutated README, one dropping a
#     member and one inventing a member, and require it to fail in each.
#
# All content here is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="$ROOT/README.md"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail=0
pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# ── the comparison, as one program, so the cases and the mutations run identical code ────────────

cat > "$work/inventory.py" <<'PYEOF'
"""Compare the README's two template inventories against the directories they describe.

argv: <repository root> <README path>

Exit 0 when both enumerations equal their derivation, 1 when either differs, 2 when the check
could not evaluate its input. A refusal is never a pass: an unreadable README, an absent row, an
absent parenthetical and an empty derivation are all reported as refusals with their reason, so a
run that compared nothing cannot be recorded as a clean one.
"""
import os
import re
import sys


def refuse(reason):
    print("REFUSED: %s" % reason)
    sys.exit(2)


root, readme_path = sys.argv[1], sys.argv[2]

try:
    with open(readme_path, "r", encoding="utf-8") as handle:
        readme = handle.read()
except (OSError, UnicodeDecodeError) as exc:
    refuse("the README could not be read: %s" % exc)

# ── derivation: the homes of record ──────────────────────────────────────────────────────────────
# The entity-note folders are the directories under template/ that carry a TEMPLATE.md. That is the
# tree's own definition of an entity-note folder and not a list held here, so adding a tenth entity
# type changes this check's answer with no edit to it.

template = os.path.join(root, "template")
if not os.path.isdir(template):
    refuse("template/ is missing, so neither inventory can be derived")

derived_folders = set()
for current, dirnames, filenames in os.walk(template):
    dirnames[:] = [d for d in dirnames if not d.startswith(".")]
    if "TEMPLATE.md" in filenames:
        rel = os.path.relpath(current, template).replace(os.sep, "/")
        derived_folders.add(rel + "/")

# The per-hub skills are the slugs installed in the runtime trees the template ships. Both trees are
# read: deriving from one alone would let the other drift out of this check's sight, and a check that
# picks a favourite tree is a check that has chosen not to look at half its evidence.
trees = {
    ".claude": os.path.join(template, ".claude", "skills"),
    ".agents": os.path.join(template, ".agents", "skills"),
}
tree_slugs = {}
for label, path in trees.items():
    if not os.path.isdir(path):
        refuse("the %s runtime tree is missing at %s" % (label, path))
    slugs = set(
        name for name in os.listdir(path)
        if os.path.isdir(os.path.join(path, name)) and not name.startswith(".")
    )
    if not slugs:
        refuse("the %s runtime tree yielded no skill slug" % label)
    tree_slugs[label] = slugs

if not derived_folders:
    refuse("no directory under template/ carries a TEMPLATE.md, so the folder set is unread")

# ── what the README says ─────────────────────────────────────────────────────────────────────────

def parenthetical(after):
    """The backticked tokens inside the first parenthesis opened after a marker phrase."""
    marker = readme.find(after)
    if marker < 0:
        refuse("the README carries no %r phrase, so its enumeration cannot be located" % after)
    opened = readme.find("(", marker)
    closed = readme.find(")", opened + 1)
    if opened < 0 or closed < 0:
        refuse("the %r phrase is not followed by a parenthetical" % after)
    tokens = re.findall(r"`([^`]+)`", readme[opened + 1:closed])
    if not tokens:
        refuse("the %r parenthetical names nothing in backticks" % after)
    return set(tokens)

stated_folders = parenthetical("entity-note folders")
stated_skills = parenthetical("per-hub agent skills")

# ── the verdict ──────────────────────────────────────────────────────────────────────────────────

problems = []

if tree_slugs[".claude"] != tree_slugs[".agents"]:
    only_claude = sorted(tree_slugs[".claude"] - tree_slugs[".agents"])
    only_agents = sorted(tree_slugs[".agents"] - tree_slugs[".claude"])
    problems.append(
        "the two runtime trees do not install the same skills: only in .claude %s; only in "
        ".agents %s" % (only_claude or "none", only_agents or "none")
    )

derived_skills = tree_slugs[".claude"] | tree_slugs[".agents"]

for label, stated, derived in (
    ("entity-note folder", stated_folders, derived_folders),
    ("per-hub skill", stated_skills, derived_skills),
):
    missing = sorted(derived - stated)
    invented = sorted(stated - derived)
    if missing:
        problems.append(
            "the README's %s enumeration omits %s, which the template ships"
            % (label, ", ".join(missing))
        )
    if invented:
        problems.append(
            "the README's %s enumeration names %s, which the template does not ship"
            % (label, ", ".join(invented))
        )

if problems:
    for problem in problems:
        print(problem)
    sys.exit(1)

print(
    "README inventory agrees with the tree: %d entity-note folder(s) derived from a TEMPLATE.md "
    "under template/ and %d per-hub skill slug(s) derived from both runtime trees, each set "
    "compared in both directions against the README's own enumeration"
    % (len(derived_folders), len(derived_skills))
)
sys.exit(0)
PYEOF

# ── 1. fail closed: the derivation must be non-empty, or the comparison proves nothing ───────────

out=$(python3 "$work/inventory.py" "$ROOT" "$README" 2>&1); status=$?
if [ "$status" -eq 2 ]; then
  die "1. the check refused rather than deriving the inventories"$'\n'"$out"
else
  pass "1. both inventories were derived from the tree; the comparison had evidence to work from"
fi

# ── 2 and 3. the README's two enumerations equal their derivation ────────────────────────────────

if [ "$status" -eq 0 ]; then
  pass "2/3. $out"
elif [ "$status" -eq 1 ]; then
  die "2/3. the README's template inventory does not match the tree"$'\n'"$out"
fi

# ── 4. refusal, not a pass, when the evidence cannot be read ─────────────────────────────────────

cp "$README" "$work/absent.md"
python3 - "$work/absent.md" <<'EOF'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read().replace("per-hub agent skills", "the skills")
open(path, "w", encoding="utf-8").write(text)
EOF
out=$(python3 "$work/inventory.py" "$ROOT" "$work/absent.md" 2>&1); status=$?
if [ "$status" -eq 2 ] && printf '%s' "$out" | grep -q "REFUSED"; then
  pass "4. a README whose enumeration cannot be located is refused, never reported clean"
else
  die "4. a missing enumeration was not refused (status $status)"$'\n'"$out"
fi

# ── 5. NEGATIVE: a member the template ships and the README drops must fail ──────────────────────
# This is the shape of the defect this check was written for: the README enumerated six per-hub
# skills while both runtime trees installed seven.

dropped=$(ls "$ROOT/template/.claude/skills" | head -1)
cp "$README" "$work/dropped.md"
python3 - "$work/dropped.md" "$dropped" <<'EOF'
import sys
path, slug = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
for form in ("`%s`, " % slug, ", `%s`" % slug):
    if form in text:
        text = text.replace(form, "", 1)
        break
else:
    raise SystemExit("fixture could not drop %s from the README" % slug)
open(path, "w", encoding="utf-8").write(text)
EOF
out=$(python3 "$work/inventory.py" "$ROOT" "$work/dropped.md" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "omits $dropped"; then
  pass "5. a skill dropped from the README's enumeration is caught and named"
else
  die "5. dropping $dropped from the enumeration did not fail the check (status $status)"$'\n'"$out"
fi

# ── 6. NEGATIVE: a member the README invents and the template does not ship must fail ────────────

cp "$README" "$work/invented.md"
python3 - "$work/invented.md" <<'EOF'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
marker = "entity-note folders (`"
if marker not in text:
    raise SystemExit("fixture could not find the entity-note enumeration")
text = text.replace(marker, marker[:-1] + "`km-not-a-folder/`, `", 1)
open(path, "w", encoding="utf-8").write(text)
EOF
out=$(python3 "$work/inventory.py" "$ROOT" "$work/invented.md" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "km-not-a-folder"; then
  pass "6. a folder the README names and the template does not ship is caught and named"
else
  die "6. an invented folder did not fail the check (status $status)"$'\n'"$out"
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "ALL README INVENTORY CHECKS PASSED"
  exit 0
fi
echo "README INVENTORY CHECKS FAILED"
exit 1
