#!/bin/bash
# km-unrepaired-tree: none | a new-capability format check, not a defect repair: no unrepaired tree exists (the contract and the skill this suite guards are born in the same change) and no version is drafted in this change. The failing direction was run FIRST, before the passing fixture was accepted: a violating ledger whose one row carried disposition "archived" was run against the finished checker over the shipped contract and it FAILED, exit 1, printing "VIOLATION: accounts/orion/2026-04-07-account-report.md: disposition 'archived' is not in the contract's disposition enum (extracted | pointer-only | rejected | out-of-scope | deferred)" — a rule-specific finding, not a blanket match. Each mutation case preserves that direction inside the suite; case 9 proves the one-definition rule by reddening the checker with a contract edit alone, and case 9b does the same for the hash-format line. Re-stated in-change for the review repairs: null-value rejection, hash-format derivation, batch correlation, and the campaign-state parser boundary — each was run in its failing direction against the pre-repair checker (null rows passed, a sha1 contract edit stayed green, a B5-orphan ledger passed, and a following table produced false status violations) before the repairs landed. Re-stated for the deployment-doctrine edit, which added case 11's fifth matcher ("a symlink, never a copy"): probed both directions against the shipped SKILL.md before the declaration was written — stripped copy did not match (assert fails, matcher live), real file matched. Re-stated again for the deployment-ROOT correction, which adds a sixth matcher pinning "_KM_Supervisor/.claude/skills/km-vault-upgrade": the original text named the workspace root, a location that is not a git repository and carries no scope guard, so the link there was untracked by anything; the sixth matcher was probed both directions against the corrected SKILL.md before this line was written — over a copy with that path stripped it did NOT match, over the real file it matched — and it exists so the root cannot silently revert to the workspace-root form.
# Fixtures for the vault-upgrade campaign ledger/catalogue format contract
# (skills/km-vault-upgrade/ledger-format.md), added with the km-vault-upgrade skill.
#
# WHAT THIS PROVES, AND WHAT IT DOES NOT.
#
# It proves the ledger/catalogue format contract cannot drift silently: the checker derives its
# enums, required keys, AND the content-hash format FROM the contract's machine-readable block at
# run time, so an edit to those lines reddens this suite without any fixture being touched
# (case 9 renames an enum value in a copy of the contract; case 9b changes the hash algorithm;
# both require the previously-valid fixture to fail). It proves a valid ledger passes and states
# its coverage; that each named mutation — a missing required key, a null-valued required key, an
# unknown disposition, a malformed content hash, duplicate rows for one source, a campaign-state
# row with an unknown status, a ledger batch_id naming no campaign-state batch — fails with a
# rule-specific message; that an empty ledger and a ledger of only flagged rows are valid; that a
# campaign-state table followed directly by another table (the contract's own required structure)
# raises no false violation; and that unreadable or truncated input is REFUSED (exit 2), never
# passed. It also proves, at the level the standard's tests operate for a prose skill, that
# SKILL.md still declares its load-bearing rules — never write entity folders directly, rulings
# carried forward verbatim, never silently dedupe, plan-rulings precedence, and estate
# deployment by symlink rather than copy, and the link's root being the Supervisor tier.
#
# It does NOT prove the skill behaves as SKILL.md says (procedures are exercised at the first
# estate run, against the capability spec's scenarios), that a ledger's rows are TRUE (a
# validator gates intake, not truth), that a hash was computed over the bytes it claims, or that
# an estate adopted the ledger through a governed act. The per-file catalogue table's required
# columns are NOT validated here — that is the estate-side validator follow-up the contract
# names, and the passing line states the limit. Enum-WIDENING contract edits are undetectable by
# construction (a new value reddens no fixture); only the openspec review path guards them. Date
# fields (decided_on, flagged_on) and the manifest's keys are not format-validated. Proving both
# directions proves the checker fires on the class it models, never that it models the right
# class.
#
# BOTH DIRECTIONS. A format checker passes by absence, so the suite carries firing and
# non-firing cases side by side: the valid fixture must pass (and a checker that fires on
# everything proves as little as one that fires on nothing), and each mutation must fail with
# its own rule named. This is new-check doctrine, not defect-repair doctrine: there is no
# unrepaired tree and no manufactured red commit — the failing directions were run first and are
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
    hash_format = block["content-hash-format"]
except KeyError as e:
    refuse("the machine-readable block is missing " + str(e))
if not required or not dispositions or not statuses:
    refuse("the machine-readable block defines an empty rule set")

# The hash rule is derived, not hardcoded: "<algo>:<N lowercase hex>, ..." builds the regex, so
# editing the block's content-hash-format line reddens the fixtures (case 9b).
hm = re.match(r"(\w+):<(\d+) lowercase hex>", hash_format)
if not hm:
    refuse("the content-hash-format line could not be parsed into an algorithm and a hex length")
HASH_RE = re.compile(r"^{}:[0-9a-f]{{{}}}$".format(hm.group(1), hm.group(2)))

NULLABLE = {"proposal_ref"}  # the one key the contract permits to be null
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
ledger_batches = []
for i, row in enumerate(rows):
    label = row.get("source_path") or "row {}".format(i) if isinstance(row, dict) else "row {}".format(i)
    if not isinstance(row, dict):
        violations.append("{}: a ledger row is not an object".format(label))
        continue
    for key in required:
        if key not in row:
            violations.append(
                "{}: missing required key '{}'; every row carries all of: {}".format(
                    label, key, " ".join(required)))
        elif row[key] is None and key not in NULLABLE:
            violations.append(
                "{}: null is not a value for '{}'; only proposal_ref may be null".format(
                    label, key))
    d = row.get("disposition")
    if d is not None and d not in dispositions:
        violations.append(
            "{}: disposition '{}' is not in the contract's disposition enum ({})".format(
                label, d, " | ".join(dispositions)))
    h = row.get("content_hash")
    if h is not None and not HASH_RE.match(str(h)):
        violations.append(
            "{}: content_hash '{}' does not match the contract's content-hash-format "
            "({})".format(label, h, hash_format))
    p = row.get("source_path")
    if p is not None:
        if p in seen:
            violations.append(
                "duplicate rows for source_path '{}': one row per source; "
                "re-adjudication updates the row".format(p))
        seen[p] = True
    b = row.get("batch_id")
    if b is not None:
        ledger_batches.append((label, b))
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
    m = re.search(r"^## Campaign state\n(.*?)(?=^#|\Z)", cat, re.S | re.M)
    if not m:
        refuse("the catalogue carries no '## Campaign state' section")
    # Only the FIRST contiguous table block is the campaign-state table. The contract's required
    # structure puts further tables (domain summary, per-file rows) after it without an
    # intervening heading, and reading them as status rows would fire false violations.
    table_batches = set()
    in_table = False
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line.startswith("|"):
            if in_table:
                break
            continue
        in_table = True
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 5 or cells[0] in ("Batch", "") or set(cells[0]) <= set("-: "):
            continue
        cat_rows += 1
        table_batches.add(cells[0])
        status = cells[3]
        if status not in statuses:
            violations.append(
                "campaign-state batch '{}': status '{}' is not in the contract's status enum "
                "({})".format(cells[0], status, " | ".join(statuses)))
    for label, b in ledger_batches:
        if b not in table_batches:
            violations.append(
                "{}: ledger batch_id '{}' names no batch in the campaign-state table; every "
                "ledger batch_id names a batch the table carries".format(label, b))

if violations:
    for v in violations:
        print("VIOLATION: " + v)
    sys.exit(1)
print("ledger format check passed: {} row(s) read ({} flagged), {} campaign-state row(s) read; "
      "required keys, disposition enum, status enum and content-hash format derived from the "
      "contract's machine-readable block; batch correlation checked when a catalogue is given"
      .format(len(rows), flagged, cat_rows))
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
    "source_system": "_KM_Supervisor/sources/systems/vault-example.md",
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

# --- 4b. MUTATION: a null-valued required key fails; presence is not a value -------------------
# Only proposal_ref may be null. A null disposition (key present) previously skipped every
# validation including the duplicate-source check; this case pins the repair.
python3 - "$work/valid.json" "$work/nulldisp.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
data["rows"][0]["disposition"] = None
json.dump(data, open(sys.argv[2], "w"))
PY
out=$(run_check "$work/nulldisp.json"); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "null is not a value for 'disposition'"; then
  pass "a null disposition fails: only proposal_ref may be null"
else
  die "null-disposition mutation not caught with its rule (rc=$rc): $out"
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

# --- 8. THE CAMPAIGN-STATE TABLE: statuses, correlation, and the section boundary --------------
# The fixture reproduces the contract's required structure: the campaign-state table is followed
# by the domain summary table with NO intervening heading. A parser that reads past the first
# table block would report the summary's cells as status violations (the false-fire this case
# pins). The table carries every batch the valid ledger names (B1, B5), per the correlation rule.
cat > "$work/catalogue.md" <<'FIX'
## Campaign state

| Batch | Domain | CQs served | Status | Decided on |
|---|---|---|---|---|
| B1 | accounts | CQ1, CQ3 | applied | 2026-09-02 |
| B2 | events | CQ2 | planned | — |
| B5 | events | CQ2 | proposed | — |

| Domain | Route | Files | Knowledge candidates | Records |
|---|---|---|---|---|
| accounts | hub-a | 12 | 9 | 3 |

## Something else
FIX
out=$(run_check "$work/valid.json" "$work/catalogue.md"); rc=$?
if [ "$rc" -eq 0 ] && printf '%s\n' "$out" | grep -Fq "3 campaign-state row(s) read"; then
  pass "a contract-shaped catalogue passes: statuses valid, batches correlated, no false fire on the following table"
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

# --- 8c. MUTATION: a ledger batch_id naming no campaign-state batch fails ----------------------
grep -v '^| B5 |' "$work/catalogue.md" > "$work/catalogue-nob5.md"
out=$(run_check "$work/valid.json" "$work/catalogue-nob5.md"); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "ledger batch_id 'B5' names no batch in the campaign-state table"; then
  pass "a ledger batch_id absent from the campaign-state table fails with the correlation rule"
else
  die "orphan-batch mutation not caught with its rule (rc=$rc): $out"
fi

# --- 9. THE CONTRACT-EDIT DIRECTION: editing the machine-readable block reddens the suite ------
# The one-definition rule is only real if an edit to the block fires without any fixture edit.
# A copy of the shipped contract has one enum value renamed; the previously-valid fixture must
# now fail against it. The shipped contract is never modified. (Scope: this proves the
# fixture-exercised value class; an enum-WIDENING edit reddens nothing by construction.)
sed 's/^disposition-enum: extracted /disposition-enum: harvested /' "$CONTRACT" > "$work/contract-edited.md"
grep -Fq "disposition-enum: harvested" "$work/contract-edited.md" \
  || die "the contract-edit fixture did not take; this direction would prove nothing"
out=$(python3 "$work/check.py" "$work/contract-edited.md" "$work/valid.json" 2>&1); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "disposition 'extracted' is not in the contract's disposition enum"; then
  pass "renaming an enum value in the contract block reddens the check without touching fixtures"
else
  die "a contract edit did not redden the check (rc=$rc): $out"
fi

# --- 9b. THE HASH-FORMAT LINE IS DERIVED TOO: changing the algorithm reddens the fixtures ------
sed 's/^content-hash-format: sha256:/content-hash-format: sha1:/' "$CONTRACT" > "$work/contract-sha1.md"
grep -Fq "content-hash-format: sha1:" "$work/contract-sha1.md" \
  || die "the hash-format edit fixture did not take; this direction would prove nothing"
out=$(python3 "$work/check.py" "$work/contract-sha1.md" "$work/valid.json" 2>&1); rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -Fq "does not match the contract's content-hash-format"; then
  pass "changing the block's hash algorithm reddens the fixtures: the hash rule is derived, not hardcoded"
else
  die "a hash-format contract edit did not redden the check (rc=$rc): $out"
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
# The file is required non-empty so nothing passes by reading nothing, and each literal is
# required non-empty so a narrowed call cannot pass vacuously. (The real liveness proof is that
# the SKILL grep sits in the pass path: a drifted literal fails loudly.)
[ -s "$SKILL" ] || die "skills/km-vault-upgrade/SKILL.md is missing or empty — the checks below would read nothing"

assert_skill() { # <literal-substring> <human-description>
  [ -n "$1" ] || { die "matcher inert (empty literal) for: $2"; return; }
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
assert_skill "a symlink, never a copy" "estate deployment resolves by symlink, not by copied tree"
assert_skill "_KM_Supervisor/.claude/skills/km-vault-upgrade" "the link resolves inside the Supervisor tier, not at the workspace root"

# --- summary -----------------------------------------------------------------------------------
if [ "$fail" -eq 0 ]; then
  echo "vault-upgrade ledger format tests passed"
  echo "COVERAGE: 1 valid ledger, 2 valid edge ledgers, 5 ledger mutations, 2 campaign-state"
  echo "  mutations, 2 contract-edit directions, 4 refusals, 6 skill literals; required keys,"
  echo "  enums and hash format asserted from the contract's machine-readable block, not from"
  echo "  values copied here; batch correlation checked against the campaign-state table"
  echo "LIMIT: the checker gates format, not truth; the per-file catalogue columns, date-field"
  echo "  formats and manifest keys are not validated (estate-side validator follow-up);"
  echo "  enum-widening contract edits redden nothing by construction; skill BEHAVIOR is"
  echo "  exercised at the first estate run against the capability spec's scenarios"
  exit 0
else
  exit 1
fi
