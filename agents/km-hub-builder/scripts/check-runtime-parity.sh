#!/usr/bin/env bash
# km-unrepaired-tree: unrecorded | added with the agent package, before this declaration was required; no run against an unrepaired tree is recorded for it and one is not reconstructed here.
# km-gate-instrument: agents/km-hub-builder/tests/test-agent-package.sh | an instrument, not a self-running check: it takes a required --profile path and exits 2 with a usage line when run bare, so the gate runs the package tests that drive it instead.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)
contract_path="$package_root/SKILL.md"
installer="$script_dir/install-agent.sh"

profile_path=''
claude_dir="${HOME}/.claude/agents"
codex_dir="${HOME}/.codex/agents"

usage() {
  echo "Usage: $0 --profile /absolute/path/profile.md [--claude-dir DIR] [--codex-dir DIR]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      profile_path=$2
      shift 2
      ;;
    --claude-dir)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      claude_dir=$2
      shift 2
      ;;
    --codex-dir)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      codex_dir=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

[[ -n "$profile_path" ]] || { usage; echo 'Missing --profile.' >&2; exit 2; }

"$installer" --check --profile "$profile_path" --claude-dir "$claude_dir" --codex-dir "$codex_dir"

claude_target="$claude_dir/km-hub-builder.md"
codex_target="$codex_dir/km-hub-builder.toml"

for target in "$claude_target" "$codex_target"; do
  grep -Fq "$contract_path" "$target" || { echo "Contract path missing from $target" >&2; exit 1; }
  grep -Fq "$profile_path" "$target" || { echo "Profile path missing from $target" >&2; exit 1; }
done

echo "Claude: $claude_target"
echo "Codex: $codex_target"
echo "Contract: $contract_path"
echo "Profile: $profile_path"
echo 'Runtime adapter parity passed.'
