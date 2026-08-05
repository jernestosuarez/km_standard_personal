#!/bin/bash
# Fixtures for the [ RESTRICTED ] check (v1.16) in template/hub-scan.sh and for the
# restricted-note exclusion in template/build-indexes.sh.
#
# Negative fixtures prove the check FIRES: a scan that cannot fail is not a check, and a
# sensitivity boundary nobody has ever seen fail is a boundary nobody can trust. Positive
# fixture proves a clean hub still passes, so the gate does not fire on prompts.
# All content here is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
hub="$work/hub"
mkdir -p "$hub/_inbox" "$hub/changes" "$hub/shareable" "$hub/stakeholders" "$hub/decisions"
cp "$ROOT/template/hub-scan.sh" "$hub/hub-scan.sh"
cp "$ROOT/template/build-indexes.sh" "$hub/build-indexes.sh"

cat > "$hub/km-deployment.md" <<'EOF'
---
type: config
title: deployment binding (synthetic fixture)
description: Synthetic canonical binding for the restricted-lint test.
tags: [config]
resource: ./
lifecycle: active
timestamp: 2026-08-03
canonical-standard-version: v1.16
canonical-standard-revision: 0123456789abcdef0123456789abcdef01234567
canonical-standard-source: synthetic-fixture
deployment-state: canonical
---
EOF

cat > "$hub/stakeholders/casey-example.md" <<'EOF'
---
type: Stakeholder
title: Casey Example
description: Synthetic restricted note for the fixture.
tags: [fixture]
resource: ./
role: Synthetic fixture person
sensitivity: restricted
lifecycle: active
timestamp: 2026-08-03
---

A synthetic restricted note. No real person.
EOF

cat > "$hub/shareable/overview.md" <<'EOF'
---
type: brief
title: Shareable overview
description: Synthetic outbound overview for the fixture.
tags: [fixture]
resource: ./
lifecycle: active
timestamp: 2026-08-03
---

Clean external overview with no restricted content.
EOF

# A HANDOVER.md is a required scaffold file since v1.17: hub-scan.sh reports its absence as an error.
# This fixture is a hand-built synthetic hub (not a template copy), so provide one explicitly.
cat > "$hub/HANDOVER.md" <<'EOF'
---
type: handover
title: Session Handover (synthetic fixture)
description: Synthetic handover for the restricted-lint test.
tags: [handover]
resource: ./
lifecycle: active
timestamp: 2026-08-03
---

# Session Handover (synthetic fixture)

Synthetic continuity note. No real content.
EOF

git -C "$hub" init -q
# Blanket staging is used here only because this IS the initial scaffold commit of a brand-new,
# fully synthetic hub: the one narrow exception STANDARD.md Rule 3 carves out.
git -C "$hub" add .
git -C "$hub" -c user.name=fixture -c user.email=fixture@example.invalid \
  commit -qm "init: synthetic fixture hub"

fail=0

# 1. NEGATIVE: a restricted note's name on a shareable surface must fail the scan as an error.
printf '\nSee also [[casey-example]] for details.\n' >> "$hub/shareable/overview.md"
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER 'casey-example'"; then
  echo "PASS: restricted identifier in shareable/ fails the scan"
else
  echo "FAIL: restricted identifier in shareable/ did not fail the scan (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
git -C "$hub" checkout -q -- shareable/overview.md

# 2. NEGATIVE: the restricted marker itself in change-notice free text must fail the scan.
cat > "$hub/changes/2026-08-03_XX_leak_proposal.md" <<'EOF'
# Change Proposal - leak fixture

Quoting a note wholesale into free text, marker and all:

sensitivity: restricted
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED MARKER"; then
  echo "PASS: restricted marker in a change notice fails the scan"
else
  echo "FAIL: restricted marker in a change notice did not fail the scan (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-03_XX_leak_proposal.md"

# 3. build-indexes.sh excludes the restricted note and keeps the non-restricted one.
cat > "$hub/stakeholders/jordan-avery.md" <<'EOF'
---
type: Stakeholder
title: Jordan Avery
description: Synthetic non-restricted note for the fixture.
tags: [fixture]
resource: ./
role: Synthetic fixture person
lifecycle: active
timestamp: 2026-08-03
---
EOF
bash "$hub/build-indexes.sh" >/dev/null
if grep -q "casey-example" "$hub/stakeholders/index.md"; then
  echo "FAIL: build-indexes.sh listed a restricted note in the index"
  fail=1
elif ! grep -q "jordan-avery" "$hub/stakeholders/index.md"; then
  echo "FAIL: build-indexes.sh dropped a non-restricted note from the index"
  fail=1
else
  echo "PASS: build-indexes.sh excludes restricted notes from the generated index"
fi

# 4. POSITIVE: with the index regenerated and everything committed, the hub scans clean.
git -C "$hub" add stakeholders/jordan-avery.md stakeholders/index.md decisions/index.md
git -C "$hub" -c user.name=fixture -c user.email=fixture@example.invalid \
  commit -qm "apply: add fixture stakeholder and generated indexes"
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 0 ] && printf '%s' "$out" | grep -q "OK: no restricted markers or identifiers"; then
  echo "PASS: clean hub passes with [ RESTRICTED ] reporting OK"
else
  echo "FAIL: clean hub did not pass (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "restricted lint fixtures passed"
  exit 0
else
  exit 1
fi
