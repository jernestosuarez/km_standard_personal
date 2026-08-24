## Why

This repository is about to be forked and handed to an external party. All three parts of this
change exist for that one reason: a fork hands these files to readers who cannot ask anyone what was
meant, and each of the three says something the reader cannot resolve alone.

- **F-07, the licence claim.** `README.md` line 111 read, verbatim: *"This standard is free to adopt,
  adapt, fork, and redistribute for any organization's internal or external knowledge management
  needs. No attribution required."* There is no `LICENSE`, `COPYING` or equivalent file in the tree,
  verified by listing it rather than taken from the audit's word. Without one, default copyright
  applies, so the advertised grant is not the effective grant. The badge
  `assets/badges/license.svg` and the README `alt` text carried the same claim in three words,
  `license: free to adopt`, and `STANDARD.md`'s closing line carried it a fourth time.
- **The remediation record is untracked.** `openspec/` holds nine change packages, every one of them
  produced by this remediation and every one of them naming an external QA report of 2026-08-22 as
  its source. The packages are the governance record of what was proposed, and leaving them out of
  the tree leaves the reasoning behind nine versions in a directory a fork does not carry.
- **The report itself cannot come with them, and the reason is a finding.** It was excluded by an
  ignore rule that had never been committed, verified against `.gitignore` at `main` (`ec51128`)
  rather than assumed. Scanning it for this change is what showed the exclusion should stay: the
  canonical leakage guard denylists a term the report uses in an ordinary English sense, so a
  fail-closed control refuses a push carrying the file. See Decision 5.
- **One further stale reference.** `template/README.md` line 73 read: *"Full governance reference: AI
  KM Hub Standard (available from the hub owner)."* No document exists under that name, and
  "available from the hub owner" names a person a fork's reader does not have. The v1.48 agent found
  it, declined to fold it into that change silently, and recorded it for this one.

## What Changes

- `README.md`'s licence section states, in its first sentence, that no licence has been declared and
  that default copyright applies. The owner's stated intent of free adoption is preserved in full and
  named as intent. What is withdrawn is the implication that the intent is operative.
- The badge reads `license: pending` instead of `license: free to adopt`, and the README `alt` text
  matches it.
- `STANDARD.md`'s "The boundary asserts no license" section records the repository's own licence
  state, that the decision is open, and that it belongs to the deployment owner. That section is
  where this standard already speaks about licensing, so it is the natural home of the record. Its
  clause "a license-neutral description of a boundary that anyone may adopt for free" loses the
  four words that made the same unsupported grant.
- `STANDARD.md`'s closing line, which repeated the grant, is repaired with it.
- **No licence is selected, no `LICENSE` file is added, and nothing here reads as legal advice.**
  The owner has not chosen a licence and the maintainer does not choose one for him.
- `openspec/` is committed, 40 files. The external QA report is **not**, and the ignore rule that
  excludes it is committed deliberately this time, carrying its reason in a comment, so that a reader
  who wonders why the audit is absent finds the answer in the rule. Every other ignore rule,
  including `outputs/` and `work/`, is left alone.
- Every reference to the report in this package describes it as an external report of 2026-08-22 held
  in the deployment's records. None names a path a reader would try to open.
- `template/README.md` names `STANDARD.md` as the governing document and points at the hub's own
  `km-deployment.md` for the version, revision and source of the repository it came from, which is a
  route a fork's reader can actually walk.
- **No check is added.** See the design for the argument.
- Not **BREAKING**. No obligation is added or withdrawn, no schema changes, and the one shipped
  surface that changes is the hub template's landing page, whose repair is text.

## Capabilities

### New Capabilities

None. See the design, Decision 4. This change adds no requirement to the standard. Every repair in
it is an application of a rule the standard already publishes: the v1.48 rule that a document is held
to what the system does, and the v1.45 rule that a reference is a promise the reader can open the
thing named. Writing a delta spec here would mean inventing a requirement so that a validator has
something to read, which is the shape of change this remediation exists to stop.

### Modified Capabilities

None.

## Impact

- **Affected material**: the licence section and the badge `alt` of `README.md`;
  `assets/badges/license.svg`; the "The boundary asserts no license" section, the closing line, the
  header, the frontmatter title, the lead and the v1.49 row of `STANDARD.md`; the governance
  reference line of `template/README.md`; `.gitignore`, which gains the ignore rule and its reason;
  and 40 newly tracked files under `openspec/`.
- **Affected deployments**: one shipped surface changes, `template/README.md`. A hub that already
  installed it carries the old reference until it refreshes it, which is an adoption act under that
  hub's own governance. No hub turns red and no check changes.
- **Not in scope**: selecting a licence, adding a `LICENSE` or `COPYING` file, or altering the
  effective reuse grant in either direction. That decision is the owner's and it stays open.
- **Not in scope**: any other `.gitignore` rule.
- **Not in scope**: editing the external report so that it passes a scan, and exempting or narrowing
  the leakage guard so that it stops matching. Both were refused. See Decision 5.
- **Not in scope**: editing the nine existing packages to agree with this resolution. They record
  what was proposed when they were written, and one of them poses the tracking decision as open. A
  record edited to agree with the present is no longer a record.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
