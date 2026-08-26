# Tasks: audit-reviewer-fifth-pass (v1.61 draft)

Branch `v1.61-link-ledger-and-open-p2s`, off `main` at `164ecfb` (published v1.60).
**Nothing here binds until this version's own owner push.**

## 1. Verify each finding before implementing it

- [x] 1.1 **All three reviewer scripts verified by digest** — `a242059f…`, `9415c372…`, `fa35fad9…`
      — and **read before use**. All three **pin `164ecfb` internally**: one refuses at exit 2 on any
      other `HEAD`, two re-clone the commit whatever root they are handed. None can demonstrate a
      repair, and this is stated in the proposal, the version row and both declarations.
- [x] 1.2 **Finding 1 confirmed by reading.** `check_links()` used `os.path.exists(str(candidate))`
      with no `READS` recording beside it; it was the only existence test in the phase.
- [x] 1.3 **Finding 2 confirmed by reading and by probing.** Ten comment and blank-line shapes put to
      Psych 3.1.0 one at a time; answers recorded in `design.md` and in the suite.
- [x] 1.4 **Finding 3 confirmed by reading.** Case 20c's mechanism was
      `grep -Fq -- "km-release-gate.py --limits"`, a presence test under an absence claim.
- [x] 1.5 **Finding 4 confirmed by measurement.** Both v1.60-cited scripts run against the published
      v1.60 tree printed `REPRODUCED`, not `NOT REPRODUCED`.

## 2. Reproduce, red, before any repair

- [x] 2.1 Reviewer script 1 → `PASS release-gate`, `gate_exit=0`, `REPRODUCED`.
- [x] 2.2 Reviewer script 2 → `checker_exit=0`, `ruby_yaml_exit=1`, `REPRODUCED`.
- [x] 2.3 Reviewer script 3 → `PASS: 20c…`, `suite_exit=0`, `REPRODUCED`.
- [x] 2.4 Cases 21k, 21k2 red (`expected exit 2, got 0` and `got 1`); 21k3 legitimately green.
- [x] 2.5 Frontmatter section 7: four canaries `NOT caught`, one clean canary `REJECTED`.
- [x] 2.6 Cases 22 and 22d red (`expected exit 1, got 0`); 22b, 22c legitimately green.

## 3. Repair

- [x] 3.1 `Reads.probes` and `path_exists`; three call sites moved; both directions in
      `fingerprint_drift`; limit 5 re-stated as the property; coverage line names the count.
- [x] 3.2 `citation_failures` and `CITATION_RE`, with a 16-character floor held by case 22e.
- [x] 3.3 A whole-line comment ends a plain scalar that has already started; `cur_kind` state.
- [x] 3.4 Case 20c narrowed; 20c2 compares against `--limits`; 20c3 injects the reviewer's copy.
- [x] 3.5 Both false declarations corrected, clauses struck in place; every citation states its pin;
      the 65-character digest v1.59 published is corrected.
- [x] 3.6 Workflow comment corrected to name what each of the three cases asserts.

## 4. Prove, both directions and the positive direction

- [x] 4.1 All 26 release-gate cases green, including every case from v1.58, v1.59 and v1.60.
- [x] 4.2 All 22 frontmatter canaries green, including every tab and sequence canary.
- [x] 4.3 **21h still passes**, and the pair 21h/21k now states the boundary exactly.
- [x] 4.4 Earlier reviewer fixtures re-run; de-pinned variants report `NOT REPRODUCED`.

## 5. Sweep

- [x] 5.1 Finding 1's class swept across the gate; result recorded in `Reads`, not in a report.
- [x] 5.2 Registered-not-repaired backlog audited in full: ten items, listed in `design.md` with age.

## 6. Publish-readiness (draft only)

- [x] 6.1 Per-section and shipped-file draft markings, derived whitespace-flat rather than line-wise.
- [x] 6.2 Version-history row, lead, title and H1.
- [ ] 6.3 Owner push. Not merged, not tagged, not pushed.
