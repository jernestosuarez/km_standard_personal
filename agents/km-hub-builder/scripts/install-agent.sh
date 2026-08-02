#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)
contract_path="$package_root/SKILL.md"
claude_template="$package_root/adapters/claude/km-hub-builder.md"
codex_template="$package_root/adapters/codex/km-hub-builder.toml"
managed_marker='managed_by: km-hub-builder/install-agent.sh'

profile_path=''
claude_dir="${HOME}/.claude/agents"
codex_dir="${HOME}/.codex/agents"
check_only=0
replace_existing=0

usage() {
  echo "Usage: $0 --profile /absolute/path/profile.md [--claude-dir DIR] [--codex-dir DIR] [--check] [--replace-existing]" >&2
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
    --check)
      check_only=1
      shift
      ;;
    --replace-existing)
      replace_existing=1
      shift
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
case "$profile_path" in
  /*) ;;
  *) echo '--profile must be an absolute path.' >&2; exit 2 ;;
esac
[[ -r "$profile_path" ]] || { echo "Profile is not readable: $profile_path" >&2; exit 2; }
[[ -r "$contract_path" ]] || { echo "Contract is not readable: $contract_path" >&2; exit 2; }
[[ -r "$claude_template" ]] || { echo "Claude template is not readable: $claude_template" >&2; exit 2; }
[[ -r "$codex_template" ]] || { echo "Codex template is not readable: $codex_template" >&2; exit 2; }

render_root=$(mktemp -d)
trap 'rm -rf "$render_root"' EXIT
rendered_claude="$render_root/km-hub-builder.md"
rendered_codex="$render_root/km-hub-builder.toml"

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[&|\\]/\\&/g'
}

contract_escaped=$(escape_sed_replacement "$contract_path")
profile_escaped=$(escape_sed_replacement "$profile_path")

sed \
  -e "s|@CONTRACT_PATH@|$contract_escaped|g" \
  -e "s|@PROFILE_PATH@|$profile_escaped|g" \
  "$claude_template" > "$rendered_claude"
sed \
  -e "s|@CONTRACT_PATH@|$contract_escaped|g" \
  -e "s|@PROFILE_PATH@|$profile_escaped|g" \
  "$codex_template" > "$rendered_codex"

claude_target="$claude_dir/km-hub-builder.md"
codex_target="$codex_dir/km-hub-builder.toml"

if [[ $check_only -eq 1 ]]; then
  status=0
  if [[ ! -f "$claude_target" ]]; then
    echo "Missing deployment: $claude_target" >&2
    status=1
  elif ! cmp -s "$rendered_claude" "$claude_target"; then
    echo "Drifted deployment: $claude_target" >&2
    status=1
  fi
  if [[ ! -f "$codex_target" ]]; then
    echo "Missing deployment: $codex_target" >&2
    status=1
  elif ! cmp -s "$rendered_codex" "$codex_target"; then
    echo "Drifted deployment: $codex_target" >&2
    status=1
  fi
  [[ $status -eq 0 ]] && echo 'Both runtime adapters match their repository templates.'
  exit "$status"
fi

for target in "$claude_target" "$codex_target"; do
  if [[ -e "$target" ]] && ! grep -Fq "$managed_marker" "$target" && [[ $replace_existing -ne 1 ]]; then
    echo "Refusing unmanaged existing file: $target" >&2
    echo 'Re-run with --replace-existing after reviewing the conflict.' >&2
    exit 1
  fi
done

mkdir -p "$claude_dir" "$codex_dir"
cp "$rendered_claude" "$claude_target"
cp "$rendered_codex" "$codex_target"
chmod 0644 "$claude_target" "$codex_target"

echo "Installed Claude adapter: $claude_target"
echo "Installed Codex adapter: $codex_target"
