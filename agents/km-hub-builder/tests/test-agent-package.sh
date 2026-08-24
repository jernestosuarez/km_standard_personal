#!/usr/bin/env bash
# km-unrepaired-tree: unrecorded | added with the agent package, before this declaration was required; the file records no run against an unrepaired package and one is not reconstructed here.
set -euo pipefail

package_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

profile="$test_root/profile.md"
claude_dir="$test_root/claude"
codex_dir="$test_root/codex"
mkdir -p "$claude_dir" "$codex_dir"

printf '%s\n' '# Test profile' > "$profile"

if "$package_root/scripts/install-agent.sh" --check --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"; then
  echo 'expected pre-install check to fail' >&2
  exit 1
fi

"$package_root/scripts/install-agent.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"
"$package_root/scripts/install-agent.sh" --check --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"
"$package_root/scripts/check-runtime-parity.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"

grep -F "$package_root/SKILL.md" "$claude_dir/km-hub-builder.md"
grep -F "$package_root/SKILL.md" "$codex_dir/km-hub-builder.toml"
grep -F "$profile" "$claude_dir/km-hub-builder.md"
grep -F "$profile" "$codex_dir/km-hub-builder.toml"

printf '%s\n' 'unmanaged' > "$claude_dir/km-hub-builder.md"
if "$package_root/scripts/install-agent.sh" --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"; then
  echo 'expected unmanaged collision to fail' >&2
  exit 1
fi

"$package_root/scripts/install-agent.sh" --replace-existing --profile "$profile" \
  --claude-dir "$claude_dir" --codex-dir "$codex_dir"

echo 'agent package tests passed'
