#!/usr/bin/env bash
# km-unrepaired-tree: v1.55 | re-stated for the effect-not-status repair. Run against the tree at 13dec55 with a branch added to scripts/install-agent.sh that prints both "Installed ..." lines and exits 0 without copying anything whenever --replace-existing is passed, the unrepaired suite printed "agent package tests passed" and exited 0 while the unmanaged file still held the single word "unmanaged". The repaired suite fails that same mutation at the replacement case, naming the file and what it still contains. The sweep behind this file is recorded below.
#
# WHAT THIS SUITE ASSERTS, AND WHY IT IS SHAPED THIS WAY.
#
# Its subject is an INSTALLER: an operation whose product is a change to a tree, not a verdict. So
# every case here asserts the state of the tree afterwards, and none of them accepts an exit status
# as evidence that the operation occurred. An operation that returns success without acting is
# indistinguishable, to a status-only assertion, from one that acted, and that is exactly what an
# external reviewer demonstrated here on 2026-08-25.
#
# The corresponding rule for a REFUSAL is the one most easily forgotten: a refusal that is asserted
# only by its exit status can be produced by any error at all, including one that damaged the file
# the refusal exists to protect. So each refusal here is asserted three ways: the status, the reason
# named in the message, and the file left byte-identical to what it was before.
#
# THE SWEEP THIS FILE CAME FROM. All 23 shell suites in this repository were read for cases that
# assert an exit status where an effect is meant. This is the only file that holds the class, because
# it is the only suite whose subject is a mutating tool; every other suite exercises a checker, a
# scanner or a validator, whose product IS its verdict, so there the status is the effect. A weaker
# sibling was found and is registered rather than repaired: several validator suites assert a
# refusal status without asserting which reason produced it, tests/test_km_publish_guards.sh cases
# 3, 5b, 6a, 6c, 8b and 12c being the clearest. Those cases observe the tool's whole output and
# leave nothing unobserved, so they are a different defect, and widening this change to reach them
# would correct something other than the thing under review.
set -euo pipefail

package_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

profile="$test_root/profile.md"
claude_dir="$test_root/claude"
codex_dir="$test_root/codex"
claude_target="$claude_dir/km-hub-builder.md"
codex_target="$codex_dir/km-hub-builder.toml"
managed_marker='managed_by: km-hub-builder/install-agent.sh'
mkdir -p "$claude_dir" "$codex_dir"

fail() { echo "FAIL: $*" >&2; exit 1; }

# --- effect assertions. Each names the file and what it holds, never an exit status. -------------
assert_absent() {
  [[ ! -e "$1" ]] || fail "$2: $1 exists and should not"
}
assert_managed() {
  [[ -f "$1" ]] || fail "$2: $1 was not written at all"
  grep -Fq "$managed_marker" "$1" \
    || fail "$2: $1 exists but carries no managed marker, so it was not written by the installer"
}
assert_contains() {
  grep -Fq "$2" "$1" || fail "$3: $1 does not contain $2"
}
assert_absent_content() {
  ! grep -Fq "$2" "$1" || fail "$3: $1 still contains $2"
}
assert_unchanged() {
  cmp -s "$1" "$2" || fail "$3: $1 is no longer byte-identical to the state it was in before"
}

printf '%s\n' '# Test profile' > "$profile"

# --- 1. the pre-install check fails, names what is missing, and creates nothing -------------------
assert_absent "$claude_target" '1'
assert_absent "$codex_target" '1'
set +e
out=$("$package_root/scripts/install-agent.sh" --check --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" 2>&1); status=$?
set -e
[[ $status -ne 0 ]] || fail '1. the pre-install check returned success with nothing installed'
printf '%s' "$out" | grep -Fq "Missing deployment: $claude_target" \
  || fail "1. the pre-install check did not name the missing Claude adapter: $out"
printf '%s' "$out" | grep -Fq "Missing deployment: $codex_target" \
  || fail "1. the pre-install check did not name the missing Codex adapter: $out"
assert_absent "$claude_target" '1. the check wrote a file'
assert_absent "$codex_target" '1. the check wrote a file'

# --- 2. the install writes both adapters, managed, naming the contract and the profile ------------
"$package_root/scripts/install-agent.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" > /dev/null
assert_managed "$claude_target" '2'
assert_managed "$codex_target" '2'
assert_contains "$claude_target" "$package_root/SKILL.md" '2'
assert_contains "$codex_target" "$package_root/SKILL.md" '2'
assert_contains "$claude_target" "$profile" '2'
assert_contains "$codex_target" "$profile" '2'

# The installed state is the reference every later case is compared against.
cp "$claude_target" "$test_root/claude.installed"
cp "$codex_target" "$test_root/codex.installed"

# --- 3. the post-install check passes, says so, and changes nothing -------------------------------
out=$("$package_root/scripts/install-agent.sh" --check --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" 2>&1)
printf '%s' "$out" | grep -Fq 'Both runtime adapters match their repository templates.' \
  || fail "3. the post-install check passed without saying what it matched: $out"
assert_unchanged "$claude_target" "$test_root/claude.installed" '3. the check mutated the adapter'
assert_unchanged "$codex_target" "$test_root/codex.installed" '3. the check mutated the adapter'

# --- 4. runtime parity passes, says so, and changes nothing ---------------------------------------
out=$("$package_root/scripts/check-runtime-parity.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" 2>&1)
printf '%s' "$out" | grep -Fq 'Runtime adapter parity passed.' \
  || fail "4. parity passed without saying so: $out"
assert_unchanged "$claude_target" "$test_root/claude.installed" '4. parity mutated the adapter'
assert_unchanged "$codex_target" "$test_root/codex.installed" '4. parity mutated the adapter'

# --- 5. an unmanaged collision is refused, by name, and the file is left exactly as it was ---------
printf '%s\n' 'unmanaged' > "$claude_target"
cp "$claude_target" "$test_root/claude.unmanaged"
set +e
out=$("$package_root/scripts/install-agent.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" 2>&1); status=$?
set -e
[[ $status -ne 0 ]] || fail '5. the installer overwrote an unmanaged file and returned success'
printf '%s' "$out" | grep -Fq "Refusing unmanaged existing file: $claude_target" \
  || fail "5. the refusal did not name the unmanaged file, so any error would have satisfied this case: $out"
assert_unchanged "$claude_target" "$test_root/claude.unmanaged" '5. the refusal damaged the file it protects'
assert_absent_content "$claude_target" "$managed_marker" '5. the refusal installed anyway'

# --- 6. --replace-existing actually replaces. This is the case the reviewer broke. ----------------
"$package_root/scripts/install-agent.sh" --replace-existing --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir" > /dev/null
assert_managed "$claude_target" '6. --replace-existing'
assert_absent_content "$claude_target" 'unmanaged' '6. --replace-existing left the unmanaged content in place'
assert_unchanged "$claude_target" "$test_root/claude.installed" \
  '6. --replace-existing did not restore the adapter a clean install produces'
assert_unchanged "$codex_target" "$test_root/codex.installed" \
  '6. --replace-existing disturbed the adapter that was not in collision'

echo 'agent package tests passed'
