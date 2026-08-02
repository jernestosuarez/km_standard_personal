#!/bin/bash
set -u

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  echo "Usage: $0 EXTENDED_REGULAR_EXPRESSION" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
pattern="$1"

matches=$(git -C "$ROOT" grep -n -I -E -e "$pattern" -- . 2>&1)
status=$?

case "$status" in
  0)
    printf '%s\n' "$matches"
    exit 1
    ;;
  1)
    echo "canonical leakage check passed"
    exit 0
    ;;
  *)
    printf '%s\n' "$matches" >&2
    exit "$status"
    ;;
esac
