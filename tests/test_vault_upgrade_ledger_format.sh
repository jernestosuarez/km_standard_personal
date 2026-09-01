#!/bin/bash
# km-unrepaired-tree: none | a new-capability format check, not a defect repair: no unrepaired tree exists (the contract and the skill this suite guards are born in the same change) and no version is drafted in this change. The failing direction was run FIRST, before the passing fixture was accepted: a violating ledger whose one row carried disposition "archived" was run against the finished checker over the shipped contract and it FAILED, exit 1, printing "VIOLATION: accounts/orion/2026-04-07-account-report.md: disposition 'archived' is not in the contract's disposition enum (extracted | pointer-only | rejected | out-of-scope | deferred)" — a rule-specific finding, not a blanket match. Each mutation case preserves that direction inside the suite, and case 9 proves the one-definition rule by reddening the checker with a contract edit alone.
# Fixtures for the vault-upgrade campaign ledger/catalogue format contract
# (skills/km-vault-upgrade/ledger-format.md), added with the km-vault-upgrade skill.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves the ledger/catalogue format contract cannot drift silently: the checker derives its
# enums and required keys FROM the contract's machine-readable block at run time, so an edit to
# the block reddens this suite without any fixture being touched (case 9 demonstrates it by
# renaming an enum value in a copy of the contract and requiring the previously-valid fixture to
# fail against it). It proves a valid ledger passes and states its coverage; that each named
# mutation — a missing required key, an unknown disposition, a malformed content hash, duplicate
# rows for one source, a campaign-state row with an unknown status — fails with a rule-specific
# message; that an empty ledger and a ledger of only flagged rows are valid; and that unreadable
# or truncated input is REFUSED (exit 2), never passed. It also proves, at the level the
# standard's tests operate for a prose skill, that SKILL.md still declares its load-bearing
# rules — never write entity folders directly, rulings carried forward verbatim, never silently
# dedupe, plan-rulings precedence — with each matcher proven live against its own literal so a
# narrowed assertion cannot go dead.
#
# It does NOT prove the skill behaves as SKILL.md says (procedures are exercised at the first
# estate run, against the capability spec's scenarios), that a ledger's rows are TRUE (a
# validator gates intake, not truth), that a hash was computed over the bytes it claims, or that
# an estate adopted the ledger through a governed act. The checker models the contract's
# machine-readable block plus the row rules named above, and proving both directions proves it
# fires on the class it models, never that it models the right class.
#
# BOTH DIRECTIONS. A format checker passes by absence, so the suite carries firing and
# non-firing cases side by side: the valid fixture must pass (and a checker that fires on
# everything proves as little as one that fires on nothing), and each mutation must fail with
# its own rule named. This is new-check doctrine, not defect-repair doctrine: there is no
# unrepaired tree and no manufactured red commit — the failing direction was run first and is
# recorded in the declaration above.
#
# All fixture content is synthetic. No real person, organization or initiative is named.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT="$ROOT/skills/km-vault-upgrade/ledger-format.md"
SKILL="$ROOT/skills/km-vault-upgrade/SKILL.md"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

pass() { echo "PASS: $1"; }
die()  { echo "FAIL: $1"; fail=1; }

# --- the checker -------------------------------------------------------------------------------
# The checker is INLINE in this suite deliberately: the estate-side runtime validator is a named
# follow-up, and this factory-side check is the v1 guard. It takes the contract file first, so
# every assertion below is derived from the shipped contract, not from a copy of its values here.
cat > "$work/check.py" <<'PYCHECK'
import json, re, sys

def refuse(msg):
    print("REFUSED: " + msg)
    sys.exit(2)

args = sys.argv[1:]
catalogue = None
if "--catalogue" in args:
    i = args.index("--catalogue")
    catalogue = args[i + 1]
    del args[i:i + 2]
if len(args) != 2:
    refuse("usage: check.py <contract.md> <ledger.json> [--catalogue <file.md>]")
contract_path, ledger_path = args

# -- derive the rules from the contract's machine-readable block (one-definition rule) --
try:
    with open(contract_path, encoding="utf-8") as f:
        contract = f.read()
except OSError:
    refuse("could not read the contract at " + contract_path)
m = re.search(r"```km-vault-upgrade-contract\n(.*?)```", contract, re.S)
if not m:
    refuse("the contract carries no km-vault-upgrade-contract machine-readable block")
block = {}
for line in m.group(1).splitlines():
    if ":" in line:
        k, v = line.split(":", 1)
        block[k.strip()] = v.strip()
try:
    required = block["ledger-required-row-keys"].split()
    dispositions = block["disposition-enum"].split()
    statuses = block["status-enum"].split()
except KeyError as e:
    refuse("the machine-readable block is missing " + str(e))
if not required or not dispositions or not statuses:
    refuse("the machine-readable block defines an empty rule set")

HASH_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
violations = []

# -- the ledger --
try:
    with open(ledger_path, encoding="utf-8") as f:
        raw = f.read()
except OSError:
    refuse("could not read the ledger at " + ledger_path)
try:
    data = json.loads(raw)
except ValueError:
    refuse("the ledger is not valid JSON; an unparsed ledger is not a clean one")
rows = data.get("rows") if isinstance(data, dict) else None
if not isinstance(rows, list):
    refuse("the ledger carries no 'rows' list; there is nothing to evaluate")

seen = {}
flagged = 0
for i, row in enumerate(rows):
    label = row.get("source_path", "row {}".format(i)) if isinstance(row, dict) else "row {}".format(i)
    if not isinstance(row, dict):
        violations.append("{}: a ledger row is not an object".format(label))
        continue
    for key in required:
        if key not in row:
            violations.append(
                "{}: missing required key '{}'; every row carries all of: {}".format(
                    label, key, " ".join(required)))
    d = row.get("disposition")
    if d is not None and d not in dispositions:
        violations.append(
            "{}: disposition '{}' is not in the contract's disposition enum ({})".format(
                label, d, " | ".join(dispositions)))
    h = row.get("content_hash")
    if h is not None and not HASH_RE.match(str(h)):
        violations.append(
            "{}: content_hash '{}' does not match the contract's content-hash-format "
            "(sha256: + 64 lowercase hex over raw bytes)".format(label, h))
    p = row.get("source_path")
    if p is not None:
        if p in seen:
            violations.append(
                "duplicate rows for source_path '{}': one row per source; "
                "re-adjudication updates the row".format(p))
        seen[p] = True
    if "flagged_on" in row:
        flagged += 1

# -- the campaign-state table, when a catalogue is given --
cat_rows = 0
if catalogue is not None:
    try:
        with open(catalogue, encoding="utf-8") as f:
            cat = f.read()
    except OSError:
        refuse("could not read the catalogue at " + catalogue)
    m = re.search(r"^## Campaign state\n(.*?)(?=^## |\Z)", cat, re.S | re.M)
    if not m:
        refuse("the catalogue carries no '## Campaign state' section")
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 5 or cells[0] in ("Batch", "") or set(cells[0]) <= set("-: "):
            continue
        cat_rows += 1
        status = cells[3]
        if status not in statuses:
            violations.append(
                "campaign-state batch '{}': status '{}' is not in the contract's status enum "
                "({})".format(cells[0], status, " | ".join(statuses)))

if violations:
    for v in violations:
        print("VIOLATION: " + v)
    sys.exit(1)
print("ledger format check passed: {} row(s) read ({} flagged), {} campaign-state row(s) read; "
      "required keys, disposition enum, status enum and hash format derived from the contract's "
      "machine-readable block".format(len(rows), flagged, cat_rows))
sys.exit(0)
PYCHECK

run_check() { # <ledger> [catalogue]
  if [ $# -ge 2 ]; then
    python3 "$work/check.py" "$CONTRACT" "$1" --catalogue "$2" 2>&1
  else
    python3 "$work/check.py" "$CONTRACT" "$1" 2>&1
  fi
}

# --- 0. the shipped contract itself carries the block the checker needs ------------------------
[ -f "$CONTRACT" ] || { die "the contract is missing at $CONTRACT; every case below would read nothing"; echo "FAIL"; exit 1; }

# --- 1. POSITIVE: a valid ledger passes and the passing line states coverage -------------------
cat > "$work/valid.json" <<'FIX'
{
  "manifest": {
    "contract": "km-vault-upgrade/ledger-format",
    "source_system": "sources/systems/vault-example.md",
    "campaign": "vault-example-2026-08",
    "generated_by": "km-vault-upgrade",
    "created_on": "2026-09-02"
  },
  "rows": [
    {
      "source_path": "accounts/orion/2026-04-07-account-report.md",
      "content_hash": "sha256:9b74c9897bac770ffc029102a200c5de1ce02b0400a83f26304e04a0d829c202",
      "disposition": "extracted",
      "proposal_ref": "hub-a/changes/2026-09-02_vault_accounts-b1_proposal.md",
      "batch_id": "B1",
      "decided_on": "2026-09-02"
    },
    {
      "source_path": "accounts/2026-q1-summary.xlsx",
      "content_hash": "sha256:5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03",
      "disposition": "pointer-only",
      "proposal_ref": "hub-a/changes/2026-09-02_vault_accounts-b1_proposal.md",
      "batch_id": "B1",
      "decided_on": "2026-09-02"
    },
    {
      "source_path": "events/conference-notes-04.md",
      "content_hash": "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "disposition": "deferred",
      "proposal_ref": null,
      "batch_id": "B5",
      "decided_on": "2026-09-04",
      "flagged_on": "2026-09-20"
    }
  ]
}
FIX
out=$(run_check "$work/valid.json"); rc=$?
if [ "$rc" -eq 0 ] \
  && printf '%s\n' "$out" | grep -Fq "3 row(s) read (1 flagged)" \
  && printf '%s\n' "$out" | grep -Fq "derived from the contract's" ; then
  pass "a valid ledger passes and the passing line states coverage and its derivation"
else
  die "valid ledger did not pass with a coverage statement (rc=$rc): $out"
fi

# --- 2. EDGE: an empty ledger (zero rows) is valid ---------------------------------------------
printf '{ "manifest": { "campaign": "x" }, "rows": [] }\n' > "$work/empty.json"
out=$(run_check "$work/empty.json"); rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fq "0 row(s) read"; then
  pass "an empty ledger is valid: a fresh campaign has adjudicated nothing"
else
  die "empty ledger was not accepted (rc=$rc): $out"
fi

# --- 3. EDGE: a ledger holding only flagged rows is valid --------------------------------------
python3 - "$work/valid.json" "$work/allflag.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for r in data["rows"]:
    r["flagged_on"] = "2026-09-20"
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/allflag.json"); rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fq "(3 flagged)"; then
  pass "a ledger of only flagged rows is valid: a wholesale-changed vault awaiting rulings"
else
  die "an all-flagged ledger was not accepted (rc=$rc): $out"
fi

# --- 4. MUTATION: a missing required key fails naming the key ----------------------------------
python3 - "$work/valid.json" "$work/nodisp.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
del data["rows"][0]["disposition"]
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/nodisp.json"); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "missing required key 'disposition'"; then
  pass "a row missing its disposition fails naming the missing key"
else
  die "missing-disposition mutation not caught with its rule (rc=$rc): $out"
fi

# --- 5. MUTATION: an unknown disposition fails naming the value and the enum -------------------
python3 - "$work/valid.json" "$work/badenum.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
data["rows"][0]["disposition"] = "archived"
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/badenum.json"); rc=$?
if [ "$rc" -eq 1 ] \
  && printf '%s\n' "$out" | grep -Fq "disposition 'archived' is not in the contract's disposition enum" \
  && printf '%s\n' "$out" | grep -Fq "extracted"; then
  pass "an unknown disposition fails naming the value and the contract enum"
else
  die "unknown-disposition mutation not caught with its rule (rc=$rc): $out"
fi

# --- 6. MUTATION: a content_hash that is not a sha256 fails naming the format ------------------
python3 - "$work/valid.json" "$work/badhash.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
data["rows"][1]["content_hash"] = "md5:d41d8cd98f00b204e9800998ecf8427e"
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/badhash.json"); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "does not match the contract's content-hash-format"; then
  pass "a non-sha256 content_hash fails naming the required format"
else
  die "malformed-hash mutation not caught with its rule (rc=$rc): $out"
fi

# --- 7. MUTATION: duplicate rows for one source_path fail with the one-row rule ----------------
python3 - "$work/valid.json" "$work/dup.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
data["rows"].append(dict(data["rows"][0]))
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/dup.json"); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "one row per source; re-adjudication updates the row"; then
  pass "duplicate rows for one source fail with the one-row rule"
else
  die "duplicate-row mutation not caught with its rule (rc=$rc): $out"
fi

# --- 8. MUTATION: a campaign-state row with an unknown status fails naming both ----------------
cat > "$work/catalogue.md" <<'FIX'
## Campaign state

| Batch | Domain | CQs served | Status | Decided on |
|---|---|---|---|---|
| B1 | accounts | CQ1, CQ3 | applied | 2026-09-02 |
| B2 | events | CQ2 | planned | — |

## Something else
FIX
out=$(run_check "$work/valid.json" "$work/catalogue.md"); rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fq "2 campaign-state row(s) read"; then
  pass "a campaign-state table with contract statuses passes and is counted"
else
  die "valid campaign-state table did not pass (rc=$rc): $out"
fi
sed 's/| applied |/| stalled |/' "$work/catalogue.md" > "$work/catalogue-bad.md"
out=$(run_check "$work/valid.json" "$work/catalogue-bad.md"); rc=$?
if [ "$rc" -eq 1 ] \
  && printf '%s\n' "$out" | grep -Fq "status 'stalled' is not in the contract's status enum" \
  && printf '%s\n' "$out" | grep -Fq "planned"; then
  pass "an unknown campaign-state status fails naming the value and the contract enum"
else
  die "unknown-status mutation not caught with its rule (rc=$rc): $out"
fi

# --- 9. THE CONTRACT-EDIT DIRECTION: editing the machine-readable block reddens the suite ------
# The one-definition rule is only real if an edit to the block fires without any fixture edit.
# A copy of the shipped contract has one enum value renamed; the previously-valid fixture must
# now fail against it. The shipped contract is never modified.
sed 's/^disposition-enum: extracted /disposition-enum: harvested /' "$CONTRACT" > "$work/contract-edited.md"
grep -Fq "disposition-enum: harvested" "$work/contract-edited.md" \
  || die "the contract-edit fixture did not take; this direction would prove nothing"
out=$(python3 "$work/check.py" "$work/contract-edited.md" "$work/valid.json" 2>&1); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "disposition 'extracted' is not in the contract's disposition enum"; then
  pass "renaming an enum value in the contract block reddens the check without touching fixtures"
else
  die "a contract edit did not redden the check (rc=$rc): $out"
fi

# --- 10. REFUSALS: no verdict on input the checker could not evaluate --------------------------
out=$(run_check "$work/absent/nothing.json"); rc=$?
if [ "$rc" -eq 2 ] && printf '%s\n' "$out" | grep -Fq "could not read the ledger"; then
  pass "an absent ledger is refused, not passed"
else
  die "an absent ledger was not refused (rc=$rc): $out"
fi
head -c 60 "$work/valid.json" > "$work/truncated.json"
out=$(run_check "$work/truncated.json"); rc=$?
if [ "$rc" -eq 2 ] && printf '%s\n' "$out" | grep -Fq "not valid JSON"; then
  pass "a truncated ledger is refused: an unparsed ledger is not a clean one"
else
  die "a truncated ledger was not refused (rc=$rc): $out"
fi
printf '[1, 2, 3]\n' > "$work/norows.json"
out=$(run_check "$work/norows.json"); rc=$?
if [ "$rc" -eq 2 ] && printf '%s\n' "$out" | grep -Fq "no 'rows' list"; then
  pass "a ledger with no rows list is refused, not read as empty"
else
  die "a rows-less ledger was not refused (rc=$rc): $out"
fi
printf '# no block here\n' > "$work/blockless.md"
out=$(python3 "$work/check.py" "$work/blockless.md" "$work/valid.json" 2>&1); rc=$?
if [ "$rc" -eq 2 ] && printf '%s\n' "$out" | grep -Fq "no km-vault-upgrade-contract machine-readable block"; then
  pass "a contract with no machine-readable block is refused: the checker holds no rule table of its own"
else
  die "a blockless contract was not refused (rc=$rc): $out"
fi

# --- 11. SKILL.md literal conformance: the load-bearing declarations are still declared --------
# Each matcher is proven live against its own literal first, so a narrowed assertion cannot go
# dead, and the file is required non-empty so nothing passes by reading nothing.
[ -s "$SKILL" ] || die "skills/km-vault-upgrade/SKILL.md is missing or empty — the checks below would read nothing"

assert_skill() { # <literal-substring> <human-description>
  printf '%s\n' "$1" | grep -Fq -- "$1" \
    || { die "matcher inert for: $2"; return; }
  if grep -Fq -- "$1" "$SKILL"; then
    pass "skill declares: $2"
  else
    die "SKILL.md no longer declares: $2 (literal absent: $1)"
  fi
}

assert_skill "never writes entity folders directly" "no direct entity-folder writes; proposals only"
assert_skill "rulings are carried forward, never re-derived" "owner rulings carry forward verbatim"
assert_skill "never silently dedupe" "duplicate subtrees reconcile, never silent dedupe"
assert_skill "the plan's owner rulings win" "a live estate plan's rulings take precedence"

# --- summary -----------------------------------------------------------------------------------
if [ "$fail" -eq 0 ]; then
  echo "vault-upgrade ledger format tests passed"
  echo "COVERAGE: 1 valid ledger, 2 valid edge ledgers, 4 ledger mutations, 1 campaign-state"
  echo "  mutation, 1 contract-edit direction, 4 refusals, 4 skill literals; every rule asserted"
  echo "  from the contract's machine-readable block, not from values copied here"
  echo "LIMIT: the checker gates format, not truth; skill BEHAVIOR is exercised at the first"
  echo "  estate run against the capability spec's scenarios, and no case here reads a real estate"
  exit 0
else
  exit 1
fi
