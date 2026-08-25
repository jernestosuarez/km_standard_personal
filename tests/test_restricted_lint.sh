#!/bin/bash
# km-unrepaired-tree: v1.57 | cases 1d and 1e were run against the UNREPAIRED template/hub-scan.sh first and both fail there: the scan reported "! RESTRICTED IDENTIFIER '03_risks-decisions' on outbound surface: changes/2026-08-24_XX_restrict-claim_directive.md", and it raised no RESTRICTED SECTION TEXT finding at all over a verbatim quotation of the same document, exiting 0. Cases 1f and 1g pass on both trees by design: they pin the boundary the narrowing must not cross and the body-marker path it does not touch, and neither is offered as a detector. The v1.16 and v1.21 cases predate this declaration and no run against their own unrepaired trees is reconstructed here.
# Fixtures for the [ RESTRICTED ] check (v1.16; narrowed in v1.21) in template/hub-scan.sh and
# for the restricted-note exclusion in template/build-indexes.sh.
#
# Negative fixtures prove the check FIRES: a scan that cannot fail is not a check, and a
# sensitivity boundary nobody has ever seen fail is a boundary nobody can trust. Positive
# fixture proves a clean hub still passes, so the gate does not fire on prompts. The v1.21
# narrowing fixtures prove BOTH sides of the narrowed rule: a note restricted only in one body
# section stays nameable on outbound surfaces, while that section's verbatim text does not
# travel, and a frontmatter-restricted note's name is still blocked.
# The v1.22 classification fixtures prove both sides of the accessClass rule (Rule 6): a note
# classed restricted/record stays NAMEABLE on outbound surfaces (existence crosses), while its
# BODY text does not travel and its class line on a surface is an error; build-indexes.sh
# excludes classed notes from generated indexes.
# The v1.57 cases (1d-1g) prove both sides of the numbered-curated-document narrowing: a
# root-level 0[0-9]_*.md or 10_*.md restricted in frontmatter is NAMEABLE on an outbound surface
# while its body text is blocked, a numbered name in a subdirectory is still blocked, and the
# body-marker path is unchanged. (Added in v1.57.)
# All content here is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
hub="$work/hub"
mkdir -p "$hub/_inbox" "$hub/changes" "$hub/shareable" "$hub/stakeholders" "$hub/decisions" \
         "$hub/working-docs" "$hub/claims"
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
initiation-interview: "2026-08-03"
routing-keywords: "fixture, synthetic"
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

# A mixed note: open content plus ONE body-marked restricted section (v1.21 narrowing fixture).
# The note's name must stay nameable on outbound surfaces; the section's text must not travel.
cat > "$hub/working-docs/negotiation-brief.md" <<'EOF'
---
type: concept
title: Negotiation brief
description: Synthetic mixed note with one restricted section, for the v1.21 narrowing fixture.
tags: [fixture]
resource: ./
lifecycle: active
timestamp: 2026-08-14
---

# Negotiation brief

Open context that anyone on the team may cite.

## Fallback position

sensitivity: restricted

The synthetic fallback is to concede the annex and hold the fee schedule.

## Next steps

Open again after the restricted span; schedule the review call.
EOF

# A restricted-CLASS note (v1.22, Rule 6): frontmatter accessClass, no sensitivity marker.
# Its name must stay nameable on outbound surfaces (existence crosses); its body must not travel.
cat > "$hub/claims/synthetic-funding-claim.md" <<'EOF'
---
type: Claim
title: Synthetic funding claim for the accessClass fixture
description: Synthetic restricted-class claim note.
owner: "[[casey-example]]"
evidencedBy: [sources/docs/synthetic-ledger.md]
assertion_method: derived
accessClass: restricted
recordedAt: 2026-08-16
lifecycle: active
tags: [fixture]
resource: ./
timestamp: 2026-08-16
---

The synthetic ledger extract routes nine hundred units through the fixture account.
EOF

# --- v1.57 fixtures: the numbered curated document ---------------------------------------------
# A NUMBERED CURATED DOCUMENT is a root-level `0[0-9]_*.md` or `10_*.md` — the hub structure
# STANDARD.md fixes under "Hub Directory Structure" and lists in its monitored-files glob. Its NAME
# is the hub's public structure, not a disclosive record identifier, so a frontmatter
# `sensitivity: restricted` marker on one restricts its CONTENT and leaves its name nameable —
# existence crosses; contents don't (v1.22, crossing law 3). Before v1.57 the marker blocked the
# NAME, so a directive restricting such a document could not name the document it was restricting.
cat > "$hub/03_risks-decisions.md" <<'EOF'
---
type: decisions
title: Risks and decisions (synthetic fixture)
description: Synthetic numbered curated document carrying a frontmatter restricted marker.
tags: [fixture]
resource: ./
sensitivity: restricted
lifecycle: active
timestamp: 2026-08-24
---

# 03 - Risks and Decisions

The synthetic commercial claim overstates the fixture pipeline by a factor of three.
EOF

# A numbered name in a SUBDIRECTORY is not hub structure. The narrowing must not reach it: this
# note's NAME stays blocked, which is the no-bypass side of the v1.57 change.
cat > "$hub/working-docs/03_engagement-note.md" <<'EOF'
---
type: concept
title: Engagement note (synthetic fixture)
description: Synthetic numbered-looking note in a subdirectory, restricted in frontmatter.
tags: [fixture]
resource: ./
sensitivity: restricted
lifecycle: active
timestamp: 2026-08-24
---

The synthetic engagement note holds a fixture identity that must not be named outside its bound.
EOF

# A numbered curated document restricted only in ONE BODY SECTION. The body-marker path is
# unchanged by v1.57 and this fixture is what proves it was examined rather than assumed: a body
# marker already emits section text only and never the name, so the name was already nameable.
cat > "$hub/05_partnerships-pipeline.md" <<'EOF'
---
type: partnerships
title: Partnerships pipeline (synthetic fixture)
description: Synthetic numbered curated document with one body-marked restricted section.
tags: [fixture]
resource: ./
lifecycle: active
timestamp: 2026-08-24
---

# 05 - Partnerships Pipeline

Open pipeline narrative that anyone on the team may cite in a proposal.

## Reserved position

sensitivity: restricted

The synthetic reserve position holds a fixture floor of four hundred units.

## Open again

Ordinary pipeline text resumes after the restricted span.
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

# 1b. NARROWING (v1.21), name side: a note restricted only in one BODY section stays nameable on
#     an outbound surface, and its open (non-restricted) text travels freely. Only the restricted
#     section's own text is bound. Exit status is not asserted here: the appended line makes the
#     surface file uncommitted, which is [ INTEGRITY ]'s finding, not this check's.
printf '\nAn update is queued for [[negotiation-brief]]. Open context that anyone on the team may cite.\nOpen again after the restricted span; schedule the review call.\n' >> "$hub/shareable/overview.md"
out=$(bash "$hub/hub-scan.sh" 2>&1)
if printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER 'negotiation-brief'"; then
  echo "FAIL: a body-section-marked note's NAME on a surface was flagged (v1.21 narrowing regressed)"
  printf '%s\n' "$out"
  fail=1
elif printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from 'negotiation-brief')"; then
  echo "FAIL: OPEN text of a section-marked note on a surface was flagged as restricted"
  printf '%s\n' "$out"
  fail=1
else
  echo "PASS: a body-section-marked note stays nameable and its open text travels"
fi
git -C "$hub" checkout -q -- shareable/overview.md

# 1c. NARROWING (v1.21), text side: a verbatim line of the body-restricted section in change-notice
#     free text must fail the scan as an error.
cat > "$hub/changes/2026-08-14_XX_fallback_proposal.md" <<'EOF'
# Change Proposal - fallback fixture

Quoting the restricted section of the mixed note:

The synthetic fallback is to concede the annex and hold the fee schedule.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from 'negotiation-brief')"; then
  echo "PASS: restricted section text in a change notice fails the scan"
else
  echo "FAIL: restricted section text in a change notice did not fail the scan (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-14_XX_fallback_proposal.md"

# 1d. NARROWING (v1.57), name side and the defect this version repairs: a NUMBERED CURATED
#     DOCUMENT restricted in frontmatter stays NAMEABLE on an outbound surface. The live case is a
#     directive that restricts a document's content: it cannot restrict what it may not name, and
#     before v1.57 the scan errored on the directive at every session start.
cat > "$hub/changes/2026-08-24_XX_restrict-claim_directive.md" <<'EOF'
# Change Proposal - restrict a claim in a numbered curated document

Restrict the adverse commercial claim in 03_risks-decisions.md. A directive that restricts a
document's content has to be able to name the document it is restricting.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1)
if printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER '03_risks-decisions'"; then
  echo "FAIL: a numbered curated document's NAME on a surface was flagged (v1.57 narrowing regressed)"
  printf '%s\n' "$out"
  fail=1
else
  echo "PASS: a frontmatter-restricted numbered curated document stays nameable"
fi
rm "$hub/changes/2026-08-24_XX_restrict-claim_directive.md"

# 1e. NARROWING (v1.57), text side: the narrowing frees the NAME and must not free the CONTENT.
#     A verbatim body line of the same document in change-notice free text is an error, exactly as
#     it is for a note classed restricted in frontmatter.
cat > "$hub/changes/2026-08-24_XX_quote-claim_proposal.md" <<'EOF'
# Change Proposal - quoting a numbered curated document's restricted body

The synthetic commercial claim overstates the fixture pipeline by a factor of three.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from '03_risks-decisions')"; then
  echo "PASS: a frontmatter-restricted numbered curated document's body text is blocked"
else
  echo "FAIL: body text of a frontmatter-restricted numbered curated document travelled (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-24_XX_quote-claim_proposal.md"

# 1f. NO BYPASS (v1.57): a numbered NAME in a SUBDIRECTORY is not hub structure, so the narrowing
#     must not reach it and the note's name stays blocked. This case passes on the unrepaired tree
#     too, which is the point of it: it pins the boundary the narrowing must not cross.
cat > "$hub/changes/2026-08-24_XX_subdir-name_proposal.md" <<'EOF'
# Change Proposal - naming a numbered-looking note held in a subdirectory

Update 03_engagement-note before the next review.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER '03_engagement-note'"; then
  echo "PASS: a numbered name in a subdirectory is still blocked (narrowing is root-scoped)"
else
  echo "FAIL: the v1.57 narrowing leaked to a subdirectory note (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-24_XX_subdir-name_proposal.md"

# 1g. THE BODY-MARKER PATH IS UNCHANGED (v1.57), asserted rather than assumed: a numbered curated
#     document restricted only in one body section is nameable already, because a body marker emits
#     section text and never the name (v1.21). Both sides are asserted in one pass.
cat > "$hub/changes/2026-08-24_XX_bodymark_proposal.md" <<'EOF'
# Change Proposal - naming a body-marked numbered curated document

Amend the open pipeline narrative in 05_partnerships-pipeline.md.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1)
if printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER '05_partnerships-pipeline'"; then
  echo "FAIL: a body-marked numbered curated document's name was flagged"
  printf '%s\n' "$out"
  fail=1
else
  echo "PASS: a body-marked numbered curated document stays nameable (v1.21 path unchanged)"
fi
cat > "$hub/changes/2026-08-24_XX_bodymark_proposal.md" <<'EOF'
# Change Proposal - quoting a body-marked section

The synthetic reserve position holds a fixture floor of four hundred units.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from '05_partnerships-pipeline')"; then
  echo "PASS: a body-marked section's text is still blocked on a surface (v1.21 path unchanged)"
else
  echo "FAIL: a body-marked section's text travelled (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-24_XX_bodymark_proposal.md"

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

# 2b. CLASSIFICATION (v1.22), name side: a note classed restricted in FRONTMATTER stays nameable
#     on an outbound surface — existence crosses (law 3) — and an aggregate derived from it (not a
#     verbatim line) travels freely: aggregation declassifies; extraction does not. Exit status is
#     not asserted (the appended line makes the surface file uncommitted — [ INTEGRITY ]'s finding).
printf '\nTotals derive from [[synthetic-funding-claim]]. Aggregate exposure is under one thousand units.\n' >> "$hub/shareable/overview.md"
out=$(bash "$hub/hub-scan.sh" 2>&1)
if printf '%s' "$out" | grep -q "RESTRICTED IDENTIFIER 'synthetic-funding-claim'"; then
  echo "FAIL: a restricted-CLASS note's NAME on a surface was flagged (existence must cross)"
  printf '%s\n' "$out"
  fail=1
elif printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from 'synthetic-funding-claim')"; then
  echo "FAIL: an aggregate (non-verbatim) line was flagged as restricted-class body text"
  printf '%s\n' "$out"
  fail=1
else
  echo "PASS: a restricted-class note stays nameable and an aggregate derived from it travels"
fi
git -C "$hub" checkout -q -- shareable/overview.md

# 2c. CLASSIFICATION (v1.22), text side: a verbatim body line of a restricted-class note in
#     change-notice free text must fail the scan as an error — that is extraction.
cat > "$hub/changes/2026-08-16_XX_extract_proposal.md" <<'EOF'
# Change Proposal - extraction fixture

Quoting the body of the restricted-class claim note:

The synthetic ledger extract routes nine hundred units through the fixture account.
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED SECTION TEXT (from 'synthetic-funding-claim')"; then
  echo "PASS: restricted-class body text in a change notice fails the scan"
else
  echo "FAIL: restricted-class body text in a change notice did not fail the scan (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-16_XX_extract_proposal.md"

# 2d. CLASSIFICATION (v1.22), class line: a restricted/record class line on a surface means a
#     classed note's frontmatter was copied there wholesale — an error, same as the marker.
cat > "$hub/changes/2026-08-16_XX_classline_proposal.md" <<'EOF'
# Change Proposal - class-line fixture

Quoting a classed note wholesale into free text, frontmatter and all:

accessClass: record
EOF
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q "RESTRICTED ACCESS CLASS"; then
  echo "PASS: restricted access class line in a change notice fails the scan"
else
  echo "FAIL: restricted access class line in a change notice did not fail the scan (exit $status)"
  printf '%s\n' "$out"
  fail=1
fi
rm "$hub/changes/2026-08-16_XX_classline_proposal.md"

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

# 3b. build-indexes.sh excludes a restricted-CLASS note from its index (v1.22): an index row
#     carries title and fields, which for a classed note is extraction, not existence.
if grep -q "synthetic-funding-claim" "$hub/claims/index.md"; then
  echo "FAIL: build-indexes.sh listed a restricted-class note in the claims index"
  fail=1
else
  echo "PASS: build-indexes.sh excludes restricted-class notes from the generated index"
fi

# 4. POSITIVE: with the index regenerated and everything committed, the hub scans clean.
git -C "$hub" add stakeholders/jordan-avery.md stakeholders/index.md decisions/index.md claims/index.md
git -C "$hub" -c user.name=fixture -c user.email=fixture@example.invalid \
  commit -qm "apply: add fixture stakeholder and generated indexes"
out=$(bash "$hub/hub-scan.sh" 2>&1); status=$?
if [ "$status" -eq 0 ] && printf '%s' "$out" | grep -q "OK: no restricted markers, classes, identifiers or section text"; then
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
