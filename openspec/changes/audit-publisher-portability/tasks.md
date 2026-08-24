# Tasks

Executed 2026-08-24 on branch `v1.51-publisher-portability`, off `main` at `44622d5` (published
v1.50). Ordered by dependency: verify every claim first-hand, run the unrepaired tree before any
repair enters the working tree, repair, prove the other direction, then record.

**Two sessions, and the record says which did what.** The first session was terminated by an
authentication error partway through section 5, leaving the repairs to the tool, the ignore files and
the hub scan in an uncommitted working tree, and leaving sections 7 and 8 ticked while `STANDARD.md`
had not been touched at all. A tick standing for work that was not done is the same class of false
statement this repository has spent five versions repairing, so those ticks were cleared and re-earned
rather than inherited. The second session read the inherited work, judged it, corrected it where it
disagreed, completed sections 5 to 8, and owns the result.

Requirement references point at `specs/publisher-portability/spec.md` (PP).

## 1. Verify every claim before repairing

- [x] 1.1 Read the bootstrap block of `tools/km-publish.sh` and record it verbatim.
- [x] 1.2 Record what `/opt/homebrew` is and which platforms it does not exist on.
- [x] 1.3 Record the error text verbatim and identify what it prescribes.
- [x] 1.4 Record the unpinned install line and the v1.40 precedent for the class.
- [x] 1.5 Run `git check-ignore -v tools/.venv` and record the exit status and output.
- [x] 1.6 Search `template/hub-scan.sh` for `.venv` and record the match count.
- [x] 1.7 Build a fixture hub from `template/` with `tools/` tracked and `tools/.venv/` present, run
      the unrepaired `hub-scan.sh`, and record the `[ INTEGRITY ]` block and the exit status.
      (PP: generated runtime state does not dirty a governed tree)
- [x] 1.8 Record every call to an external binary in the script and what happens today when it is
      absent. (PP: external binaries are checked by name)

## 2. The unrepaired-tree run, before any repair is in the working tree

- [x] 2.1 Extract `tools/km-publish.sh` from published `main` at `44622d5` into a scratch tree.
- [x] 2.2 Run it with `ls` shimmed to return nothing, which is what a host with no Apple Silicon
      Homebrew prefix presents, on a real HTML source, with a usable `python3.12` first on `PATH`.
      Record the exit status and the message. **Result: exit 1, `ERROR: no Homebrew python3. One-off
      setup:  brew install python@3.12 pango gdk-pixbuf libffi`.** (PP: portable discovery; PP: a
      refusal names the platform)
- [x] 2.3 Record that the run never considered the usable interpreter on `PATH`.
- [x] 2.4 Record the fixture-hub scan result from 1.7 as the unrepaired run for the tree-dirtying
      defect.

## 3. Measure what the repair must assert

- [x] 3.1 Install `weasyprint` unpinned into a scratch environment and record which version the
      resolver returns today. **Result: 69.0.**
- [x] 3.2 Read `Requires-Python` from the installed distribution's own metadata rather than from
      documentation. **Result: `>=3.10`.** (PP: the minimum version is derived, not assumed)
- [x] 3.3 Record the interpreter inventory of the authoring host and which candidates the floor
      accepts and rejects. **Result: `/usr/bin/python3` is 3.9.6 and is rejected;
      `/opt/homebrew/bin/python3.12` is accepted.**
- [x] 3.4 Perform one end-to-end render with the pinned version and confirm the PDF and its extracted
      text. **Result: rendered, `Producer: WeasyPrint 69.0`, text extracted.**
- [x] 3.5 Determine which git pathspec spellings actually exclude a nested and a root-level `.venv`
      against the git that will run the scan, and record the spellings that excluded nothing.
      (PP: an exclusion pattern is written but does not match)

## 4. Repair the tool

- [x] 4.1 Add the pin as one named variable with its reason recorded beside it. (PP: a bootstrapped
      dependency is pinned)
- [x] 4.2 Add version-and-venv capability checking for a candidate interpreter. (PP: the minimum
      interpreter version)
- [x] 4.3 Add discovery: override first, then `PATH`, then conventional prefixes. (PP: portable
      discovery)
- [x] 4.4 Refuse rather than search past an unusable override. (PP: the override names an interpreter
      that cannot work)
- [x] 4.5 Write the refusal message with platform, requirement, what was searched, the override, and
      platform-selected install guidance; keep the macOS SIP note in the macOS branch. (PP: a refusal
      names the platform)
- [x] 4.6 Move the environment out of the tree, keyed by the pin, overridable. (PP: generated runtime
      state)
- [x] 4.7 Rebuild an environment whose installed version does not match the pin. (PP: an environment
      predates the current pin)
- [x] 4.8 Check `pdftotext` as required-when-guarded and `pdfinfo` as a named warning. (PP: external
      binaries)
- [x] 4.9 Add `--preflight`. (PP: a bootstrap is testable without performing the work)
- [x] 4.10 Mark every addition with the drafted version and state that it binds nothing until its own
      owner push.

## 5. Defend the tree as well as move the environment

- [x] 5.1 Add the ignore rule to the canonical `.gitignore` with its reason.
- [x] 5.2 Add the ignore rule to `template/.gitignore`, which every hub inherits.
- [x] 5.3 Add the `[ INTEGRITY ]` exemption to `template/hub-scan.sh` using the pathspec spelling
      proved in 3.5, with the reason recorded.
- [x] 5.4 Exempt an environment from the scan's two other whole-tree markdown walks, the `[ LINKS ]`
      note index and the restricted-surface walk, which the first session did not reach. Measured
      first: the environment the pinned renderer builds carries two `LICENSE.md` files under
      site-packages, so without this a vendored licence becomes a name a hub wiki-link can resolve
      against. (PP: generated runtime state does not dirty a governed tree)

## 6. Prove both directions

- [x] 6.1 Write `tests/test_km_publish_portability.sh` with a `km-unrepaired-tree` declaration naming
      v1.51 and the real result of the run in 2.2.
- [x] 6.2 Case: the override is honoured and the resolved interpreter is reported.
- [x] 6.3 Case: an override that cannot work is refused, named, and not searched past.
- [x] 6.4 Case: discovery with an empty `PATH` and no usable prefix refuses, naming the platform, the
      minimum version and the override.
- [x] 6.5 Case: discovery succeeds from `PATH` alone with no package-manager prefix present.
- [x] 6.6 Case: an interpreter below the floor is rejected, using the host's real 3.9.
- [x] 6.7 Case: a missing `pdftotext` with a guards sidecar refuses and names the binary; a missing
      `pdfinfo` warns and names it; a missing `pdftotext` without a guards sidecar does not refuse.
- [x] 6.8 Case: the pin is present and is a pinned specifier rather than a bare name.
- [x] 6.9 Case: the environment path resolves outside the repository by default and follows the
      override.
- [x] 6.10 Case: the unrepaired script from `main` fails as recorded, and the repaired script
      succeeds on the same input, which is the pair that makes 2.2 evidence.
- [x] 6.11 Case: the fixture hub with an environment directory fails the unrepaired scan naming the
      path, and passes the repaired scan; and the repaired scan still reports a genuinely untracked
      monitored file, so the exemption did not blind the block.
- [x] 6.12 Leave `tests/test_km_publish_guards.sh` untouched.
- [x] 6.13 Case: the unrepaired note-index walk indexes a markdown file placed inside the environment
      and the repaired one does not, on the same fixture with the same file present; and a markdown
      file outside the environment is still indexed, so the exclusion is not a blanket one. Record the
      unrepaired result in the suite's `km-unrepaired-tree` declaration with the other two.
- [x] 6.14 Normalise the change's own added prose to the house form used by the recent versions, which
      is dash-free. Pre-existing sentences are left verbatim.

## 7. Update the whole governed surface

- [x] 7.1 Repair the *One renderer, shared* paragraph in the *Rendering an issuable artifact* section
      with the portability contract and the platform statement. (PP: platform support is claimed only
      where it was exercised)
- [x] 7.2 Graft the generalised rule into the Standard Maintainer section beside its siblings.
- [x] 7.3 Update all three distributed copies of the `km-publish` skill identically, so the parity
      check holds.
- [x] 7.4 Flip the frontmatter title, timestamp, H1 and lead to v1.51 drafted-and-unpublished,
      preserving the published v1.50, v1.49 and v1.48 descriptions verbatim.
- [x] 7.5 Add the v1.51 version row, citing F-10, quoting the hardcoded discovery and the wrong error
      message as they stood, and stating supported, unverified and unproved plainly.
- [x] 7.6 Do not quote a draft declaration token inside the row's description, because two
      publication-status checks search the whole description rather than its opening. Describe it
      instead.

## 8. Verify

- [x] 8.1 `openspec validate audit-publisher-portability --strict`.
- [x] 8.2 The new suite, run directly.
- [x] 8.3 `python3 tools/km-release-gate.py`, exit 0.
- [x] 8.4 The canonical leakage instrument over the final tree, both halves, with file counts.
- [x] 8.5 `git diff --check`.
- [x] 8.6 Review the complete diff, stage explicit paths, commit with the attribution trailer, do not
      push.
- [x] 8.7 Re-derive the version row's date from the commit that carries it, and reconcile the
      frontmatter timestamp with it, rather than taking a date from anyone.
