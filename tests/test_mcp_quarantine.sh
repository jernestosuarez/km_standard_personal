#!/bin/bash
# km-unrepaired-tree: v1.40 | case 5 is the unrepaired-tree run: the same assertions against an UNQUARANTINED copy of the surface are required to FAIL there, so a pass in cases 2 to 4 is evidence of a refusal rather than of an empty tree.
# Fixtures for the v1.40 quarantine of the optional MCP query surface (template/mcp/).
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves that every content-returning entry point of template/mcp/server.py refuses while
# quarantined and returns no hub content, that the refusal states the quarantine and its reason,
# that starting the surface reports the quarantine rather than starting silently, and that the
# surface's README states only guarantees the implementation keeps.
#
# It does NOT prove any of the four projection gates. v1.40 quarantines the surface and does not
# repair it; the gates are implemented and proved by the separate change
# `audit-mcp-projection-gates`. A test that passes because nothing is served must never be read as
# a gate being proved, so case 6 below asserts the two missing gates as an ACKNOWLEDGED GAP rather
# than as an enforced control.
#
# BOTH DIRECTIONS. A refusal test passes trivially against an empty hub or a broken import, so:
#   - case 1 fails closed if the fixture hub committed nothing to withhold;
#   - case 5 runs the same assertions against an UNQUARANTINED copy of the surface and requires
#     them to FAIL there, which is what makes a pass in cases 2 to 4 evidence of a refusal rather
#     than evidence of an empty tree.
#
# The `mcp` package is not a test dependency: a stub providing the FastMCP decorators is placed on
# PYTHONPATH, so the surface's own logic is exercised without a network install.
#
# All content here is synthetic; no real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER="$ROOT/template/mcp/server.py"
README="$ROOT/template/mcp/README.md"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
hub="$work/hub"
stub="$work/stub"
mkdir -p "$hub/decisions" "$hub/risks" "$hub/stakeholders" "$hub/claims" "$hub/working-docs" \
         "$stub/mcp/server/fastmcp"

fail=0

# ── the fixture hub: one committed note of every content class the exposure named ────────────────

cat > "$hub/decisions/adopt-format.md" <<'EOF'
---
type: Decision
title: Adopt the interchange format
description: Synthetic active decision.
lifecycle: active
status: agreed
owner: fixture-owner
timestamp: 2026-08-01
---

The team adopted the interchange format. FIXTUREMARKER-ACTIVE
EOF

cat > "$hub/decisions/retired-choice.md" <<'EOF'
---
type: Decision
title: Retired vendor choice
description: Synthetic retired decision.
lifecycle: retired
status: agreed
owner: fixture-owner
timestamp: 2026-07-01
---

Body of the retired vendor choice. FIXTUREMARKER-RETIRED
EOF

cat > "$hub/risks/superseded-risk.md" <<'EOF'
---
type: Risk
title: Superseded schedule risk
description: Synthetic superseded risk.
lifecycle: superseded
status: open
owner: fixture-owner
timestamp: 2026-07-02
---

Body of the superseded schedule risk. FIXTUREMARKER-SUPERSEDED
EOF

cat > "$hub/stakeholders/sensitive-contact.md" <<'EOF'
---
type: Stakeholder
title: Sensitive contact
description: Synthetic sensitivity-restricted note.
sensitivity: restricted
lifecycle: active
timestamp: 2026-07-03
---

Body of the sensitive contact note. FIXTUREMARKER-SENSITIVE
EOF

cat > "$hub/claims/classed-claim.md" <<'EOF'
---
type: Claim
title: Classed claim
description: Synthetic accessClass-restricted claim.
accessClass: restricted
lifecycle: active
timestamp: 2026-07-04
---

Body of the classed claim. FIXTUREMARKER-CLASSED
EOF

cat > "$hub/working-docs/unmanifested-note.md" <<'EOF'
---
type: concept
title: Unmanifested note
description: Synthetic note listed in no projection manifest.
lifecycle: active
timestamp: 2026-07-05
---

A note in no manifest. FIXTUREMARKER-UNMANIFESTED
EOF

cat > "$hub/00_about.md" <<'EOF'
---
type: brief
title: About the fixture hub
description: Synthetic about page.
timestamp: 2026-07-06
---

About body. FIXTUREMARKER-ABOUT
EOF

cat > "$hub/07_glossary.md" <<'EOF'
---
type: brief
title: Glossary
description: Synthetic glossary.
timestamp: 2026-07-06
---

Glossary body. FIXTUREMARKER-GLOSSARY
EOF

cat > "$hub/01_project-brief.md" <<'EOF'
---
type: brief
title: Project brief
description: Synthetic brief.
timestamp: 2026-07-06
---

## Competency questions

What does the fixture answer? FIXTUREMARKER-SCOPE

## What this hub does not cover

Anything real.
EOF

cat > "$hub/decisions/index.md" <<'EOF'
---
type: index
title: Decisions index
description: Synthetic index.
timestamp: 2026-07-06
---

- adopt-format FIXTUREMARKER-INDEX
EOF

git -C "$hub" init -q
# Blanket staging is used here only because this IS the initial scaffold commit of a brand-new,
# fully synthetic hub: the one narrow exception STANDARD.md Rule 3 carves out.
git -C "$hub" add .
git -C "$hub" -c user.name=fixture -c user.email=fixture@example.invalid \
  commit -qm "init: synthetic fixture hub"

# ── the stub transport: the surface's logic without the mcp dependency ───────────────────────────

: > "$stub/mcp/__init__.py"
: > "$stub/mcp/server/__init__.py"
cat > "$stub/mcp/server/fastmcp/__init__.py" <<'EOF'
"""Test stub for mcp.server.fastmcp. The decorators return the function unchanged."""


class FastMCP(object):
    def __init__(self, name):
        self.name = name

    def tool(self, *a, **k):
        def deco(fn):
            return fn
        return deco

    def resource(self, *a, **k):
        def deco(fn):
            return fn
        return deco

    def run(self):
        raise AssertionError("stub FastMCP.run() must never be reached in a test")
EOF

# ── the driver: call every content-returning entry point and report what came back ───────────────

cat > "$work/drive.py" <<'EOF'
import importlib.util
import json
import sys

server_path, hub = sys.argv[1], sys.argv[2]
sys.argv = ["server.py", hub]
spec = importlib.util.spec_from_file_location("hubmcp_under_test", server_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

out = {}
out["list_entities"] = module.list_entities()
out["get_entity:active"] = module.get_entity("adopt-format")
out["get_entity:retired"] = module.get_entity("retired-choice")
out["get_entity:superseded"] = module.get_entity("superseded-risk")
out["get_entity:sensitive"] = module.get_entity("sensitive-contact")
out["get_entity:classed"] = module.get_entity("classed-claim")
out["query_facts"] = module.query_facts("body vendor schedule contact claim note format")
out["hub_scope"] = module.hub_scope()
out["hub://about"] = module.about()
out["hub://glossary"] = module.glossary()
out["hub://index"] = module.folder_index("decisions")
print(json.dumps(out))
EOF

# ── the assertions: run once against a given copy of the surface ─────────────────────────────────
# Prints one line per verdict and returns 0 only when every entry point refused with no content.

cat > "$work/assert.py" <<'EOF'
import json
import sys

results = json.loads(sys.stdin.read())
problems = []
for entry, value in sorted(results.items()):
    if "FIXTUREMARKER" in value:
        problems.append("%s returned hub content" % entry)
        continue
    if not value.startswith("REFUSED:"):
        problems.append("%s did not refuse" % entry)
        continue
    if "quarantined" not in value:
        problems.append("%s refused without stating the quarantine" % entry)
    if "Reason:" not in value:
        problems.append("%s refused without stating a reason" % entry)
if problems:
    for p in problems:
        print(p)
    sys.exit(1)
print("all %d entry points refused, stating the quarantine and its reason" % len(results))
sys.exit(0)
EOF

run_surface() {  # $1 = path to a server.py copy; prints the driver JSON
  PYTHONPATH="$stub" python3 "$work/drive.py" "$1" "$hub" 2>"$work/drive.err"
}

# ── 1. FAIL CLOSED: the fixture must actually hold content to withhold ───────────────────────────
# A refusal test passes against an empty hub. If extraction produced nothing, that is a defect in
# the fixture and must never read as a clean quarantine.

committed=$(git -C "$hub" ls-tree -r --name-only HEAD | grep -c '\.md$')
markers=$(git -C "$hub" grep -c -l 'FIXTUREMARKER' HEAD -- '*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$committed" -ge 10 ] && [ "$markers" -ge 1 ]; then
  echo "PASS: fixture extraction is non-empty ($committed committed notes carrying content markers)"
else
  echo "FAIL: fixture extraction is empty or short ($committed notes); the refusal cases below"
  echo "      would pass vacuously, so the run is void rather than clean"
  fail=1
fi

# ── 2. Every content-returning entry point refuses while quarantined ─────────────────────────────
# MSS: a surface that cannot enforce its contract refuses to serve. Covers the three paths in the
# gate matrix AND hub_scope() plus the three resources, which the matrix did not enumerate: a
# refusal covering only the paths someone remembered to list is not a refusal.

quarantined_json=$(run_surface "$SERVER")
if [ -z "$quarantined_json" ]; then
  echo "FAIL: the quarantined surface produced no driver output; stderr follows"
  cat "$work/drive.err"
  fail=1
else
  out=$(printf '%s' "$quarantined_json" | python3 "$work/assert.py"); status=$?
  if [ "$status" -eq 0 ]; then
    echo "PASS: $out"
  else
    echo "FAIL: the quarantined surface did not refuse on every entry point"
    printf '%s\n' "$out"
    fail=1
  fi
fi

# ── 3. Starting the surface reports the quarantine rather than starting silently ─────────────────
# MSS: the quarantine is discoverable before it is relied on. Run with no `mcp` on the path, which
# is also the clean-environment case in MDC: the operator must meet the quarantine, not an
# ImportError.

start_out=$(python3 "$SERVER" "$hub" 2>&1); start_status=$?
if [ "$start_status" -ne 0 ] \
   && printf '%s' "$start_out" | grep -q "QUARANTINED" \
   && printf '%s' "$start_out" | grep -q "Reason:" \
   && ! printf '%s' "$start_out" | grep -qi "ImportError\|No module named"; then
  echo "PASS: starting the surface reports the quarantine and its reason, and does not serve"
else
  echo "FAIL: starting the surface did not report the quarantine (exit $start_status)"
  printf '%s\n' "$start_out"
  fail=1
fi

# ── 4. The README states only guarantees the implementation keeps ────────────────────────────────
# MDC: documentation states only guarantees the implementation keeps; the quarantine is stated where
# an operator meets it first; the install instructions resolve to a runnable configuration.

readme_head=$(head -n 12 "$README")
if printf '%s' "$readme_head" | grep -qi "quarantin"; then
  echo "PASS: the README states the quarantine in its opening lines"
else
  echo "FAIL: the README does not state the quarantine where an operator meets it first"
  fail=1
fi

if grep -q "Retired and superseded notes are never returned" "$README"; then
  echo "FAIL: the README still carries the unconditional lifecycle guarantee, which is false on"
  echo "      get_entity(id)"
  fail=1
else
  echo "PASS: the unconditional lifecycle guarantee is gone from the README"
fi

if grep -q '`get_entity(id)`' "$README" && grep -qi "not enforced" "$README"; then
  echo "PASS: the README names the path on which the lifecycle guarantee does not hold"
else
  echo "FAIL: the README does not name the path on which the lifecycle guarantee does not hold"
  fail=1
fi

if grep -qi "access clearance" "$README" && grep -qi "projection manifest" "$README" \
   && grep -qi "not implemented anywhere" "$README"; then
  echo "PASS: the README names the two never-implemented gates as not enforced"
else
  echo "FAIL: the README omits a required gate the implementation performs nowhere"
  fail=1
fi

# Two defects were found writing this case and both are recorded here rather than smoothed away.
# The claim is written "Committed = safe to expose" with a leading capital, and a case-sensitive
# pattern passed against the uncorrected file during the negative run: a check that misses the
# string it exists to find looks exactly like a clean one. Matching case-insensitively then flagged
# the corrected file, because the correction quotes the claim in order to withdraw it. So the check
# is on ASSERTION, not on occurrence: the premise may appear only on a line that withdraws it, and
# the correction itself must be present.
asserted=$(grep -in "committed = safe to expose" "$README" \
           | grep -viE "used to say|withdraw|previously|no longer" | wc -l | tr -d ' ')
if [ "$asserted" -eq 0 ] && grep -qi "does not decide who may read it" "$README"; then
  echo "PASS: the committed-equals-safe premise is withdrawn and corrected in the README"
else
  echo "FAIL: the README still asserts the committed-equals-safe premise on $asserted line(s),"
  echo "      or does not carry the correction that commitment is not clearance"
  fail=1
fi

if grep -q 'pip install "mcp>=1.29,<2"' "$README" && grep -q "Python 3.10 or newer" "$README" \
   && ! grep -q "^pip install mcp$" "$README" && ! grep -q "Python 3.8+" "$README"; then
  echo "PASS: the install instructions are pinned to the interface the surface imports, at the"
  echo "      interpreter floor the dependency actually requires"
else
  echo "FAIL: the install instructions still resolve to an interface the surface does not import,"
  echo "      or state an interpreter floor below what the dependency requires"
  fail=1
fi

# ── 5. NEGATIVE DIRECTION: the same assertions must fail against an unquarantined surface ────────
# Without this, cases 2 and 3 prove only that something went wrong somewhere. This is also the
# traceability case in MDC: with the enforcement removed, the surviving claim is reported.

unquarantined="$work/server_unquarantined.py"
sed 's/^QUARANTINED = True$/QUARANTINED = False/' "$SERVER" > "$unquarantined"
if grep -q "^QUARANTINED = False$" "$unquarantined"; then
  canary_json=$(run_surface "$unquarantined")
  if [ -z "$canary_json" ]; then
    echo "FAIL: the unquarantined canary produced no output, so the negative direction is untested"
    cat "$work/drive.err"
    fail=1
  else
    canary_out=$(printf '%s' "$canary_json" | python3 "$work/assert.py"); canary_status=$?
    leaked=$(printf '%s' "$canary_json" | grep -c "FIXTUREMARKER")
    if [ "$canary_status" -ne 0 ] && [ "$leaked" -ge 1 ]; then
      echo "PASS: with the quarantine removed the same assertions FAIL and hub content comes back,"
      echo "      so a pass above is evidence of a refusal and not of an empty fixture"
    else
      echo "FAIL: the assertions passed against an unquarantined surface (exit $canary_status);"
      echo "      they cannot detect a serving surface and prove nothing above"
      fail=1
    fi
  fi
else
  echo "FAIL: could not build the unquarantined canary; the QUARANTINED switch was not found in"
  echo "      the expected form, so the negative direction could not be run"
  fail=1
fi

# ── 6. THE ACKNOWLEDGED GAP, asserted as a gap and never as a control ────────────────────────────
# v1.40 quarantines and does not repair. Nothing above may be read as proving a gate. This case
# pins the opposite: the two gates that exist nowhere still exist nowhere, which is precisely why
# the quarantine stands. When `audit-mcp-projection-gates` implements them, this case is expected
# to fail and must be replaced by that change's own gate tests.

if grep -qiE '^[^#]*\b(accessClass|sensitivity|clearance)\b.*(<=|ceiling|allow|deny)' "$SERVER" \
   || grep -qiE 'projection_manifest|manifest\s*=|load_manifest' "$SERVER"; then
  echo "FAIL: clearance or manifest logic appears in the surface. If the gates are implemented,"
  echo "      this quarantine test is superseded by the gate tests and must be replaced."
  fail=1
else
  echo "PASS: access clearance and projection manifest remain unimplemented, stated as the"
  echo "      acknowledged gap the quarantine closes and not as a control this change proves"
fi

if [ "$fail" -eq 0 ]; then
  echo "mcp quarantine fixtures passed"
  exit 0
else
  exit 1
fi
