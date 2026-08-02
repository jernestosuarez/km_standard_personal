#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/km-deployment-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

CANONICAL_REVISION="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

prepare_hub() {
  local name="$1" state="$2" revision="$3" profile_id="$4" profile_revision="$5"
  local namespace="$6" contract_revision="$7"
  local hub="$TEST_ROOT/$name"
  mkdir -p "$hub"
  cp -R "$ROOT/template/." "$hub/"

  while IFS= read -r -d '' file; do
    sed -i.bak -e 's|{{INIT_DATE}}|2026-08-01|g' "$file"
    rm -f "$file.bak"
  done < <(find "$hub" -type f -print0)

  local binding="$hub/km-deployment.md"
  sed -i.bak \
    -e 's|{{KM_STANDARD_VERSION}}|1.14|g' \
    -e "s|{{KM_STANDARD_REVISION}}|$revision|g" \
    -e 's|{{KM_STANDARD_SOURCE}}|https://example.invalid/km-standard.git|g' \
    -e "s|deployment-state: canonical|deployment-state: $state|" \
    -e "s|organization-profile-id: \"\"|organization-profile-id: \"$profile_id\"|" \
    -e "s|organization-profile-revision: \"\"|organization-profile-revision: \"$profile_revision\"|" \
    -e "s|enterprise-namespace: \"\"|enterprise-namespace: \"$namespace\"|" \
    -e "s|enterprise-contract-revision: \"\"|enterprise-contract-revision: \"$contract_revision\"|" \
    "$binding"
  rm -f "$binding.bak"

  git -C "$hub" init -q
  git -C "$hub" add -A
  git -C "$hub" -c user.name='KM Test' -c user.email='km-test@example.invalid' \
    commit -qm 'init: deployment test hub'
  printf '%s\n' "$hub"
}

run_case() {
  local name="$1" state="$2" revision="$3" profile_id="$4" profile_revision="$5"
  local namespace="$6" contract_revision="$7" expected_status="$8" expected_text="$9"
  local hub output status
  hub=$(prepare_hub "$name" "$state" "$revision" "$profile_id" "$profile_revision" \
    "$namespace" "$contract_revision")

  set +e
  output=$(bash "$hub/hub-scan.sh" 2>&1)
  status=$?
  set -e

  if [ "$status" -ne "$expected_status" ]; then
    printf '%s\n' "$output" >&2
    fail "$name returned $status, expected $expected_status"
  fi
  if ! printf '%s\n' "$output" | grep -Fq "$expected_text"; then
    printf '%s\n' "$output" >&2
    fail "$name did not report: $expected_text"
  fi
}

run_case \
  valid-canonical canonical "$CANONICAL_REVISION" "" "" "" "" \
  0 "OK: canonical standard binding is complete; no organization profile applied"

run_case \
  valid-organization-bound organization-bound "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "contract-7" \
  0 "OK: canonical and organization profile bindings are complete"

run_case \
  partial-organization-bound organization-bound "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "" \
  1 "organization-bound deployment requires all organization and enterprise fields"

run_case \
  invalid-canonical-revision canonical "abc123" "" "" "" "" \
  1 "canonical-standard-revision must be a full 40-character lowercase Git revision"

run_case \
  canonical-with-organization-values canonical "$CANONICAL_REVISION" \
  "urn:example:km-profile:main" "profile-1" "urn:example:enterprise:" "contract-7" \
  1 "canonical deployment must not contain organization or enterprise binding values"

echo "deployment binding tests passed"
