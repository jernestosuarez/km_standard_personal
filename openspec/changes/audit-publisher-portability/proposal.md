## Why

This repository is being forked and handed to an external party. `tools/km-publish.sh` is one of the
few pieces of executable tooling the standard ships, and as it stands it runs on exactly one class of
machine: macOS on Apple Silicon with Homebrew. Everywhere else it fails on its first bootstrap and
tells the operator to run a command that does not exist there. This is audit finding **F-10**.

Every claim below was verified first-hand against published `main` at `44622d5` rather than taken
from the report, and one of the report's own statements was found to understate the defect.

- **Interpreter discovery is one hardcoded path.** The bootstrap reads
  `BREWPY="$(ls -1 /opt/homebrew/bin/python3.1* 2>/dev/null | grep -v config | tail -1 || true)"`.
  `/opt/homebrew` is the Apple Silicon Homebrew prefix. Intel macOS Homebrew installs under
  `/usr/local`, and Linux has no Homebrew prefix at all. Nothing else is consulted, so a usable
  interpreter sitting first on `PATH` is never seen.
- **The failure message is wrong for most of the world.** It reads
  `ERROR: no Homebrew python3. One-off setup:  brew install python@3.12 pango gdk-pixbuf libffi`.
  On Linux `brew` is not the package manager, and on a machine carrying a perfectly usable Python
  the diagnosis names the wrong thing entirely. **Run against a host whose Homebrew glob returns
  nothing, the script exits 1 with that message while `python3.12` is first on `PATH`.**
- **The dependency is unpinned.** `"$VENV/bin/pip" install --quiet weasyprint` resolves to whatever
  is current on the day, so the same script produces different renderers over time. The same class
  cost this repository once already: the MCP surface at v1.40, where an unpinned install silently
  resolved to a major version whose interface the code did not use.
- **The virtual environment is created inside the repository and is not ignored.** `VENV="$TOOLS/.venv"`
  resolves to `tools/.venv`, and `git check-ignore -v tools/.venv` exits 1 with no output: no rule
  covers it. Running the publisher dirties the working tree of the repository that ships it.
- **The shipped hub scan does not exempt it, and the consequence is an error rather than noise.**
  `template/hub-scan.sh` contains zero occurrences of `.venv`. Its `[ INTEGRITY ]` block runs
  `git status --porcelain` over a denylist that excludes only the working areas, so an environment
  under a hub's `tools/` is monitored. **Verified in a fixture hub built from `template/`: with
  `tools/.venv/` present the block prints `! UNCOMMITTED OR UNTRACKED MONITORED FILES` naming the
  path, calls `err`, and the scan exits 1.** `hub-scan.sh` is the standard's enforced session-start
  entry point, so a hub that renders one document fails its own integrity check at the start of
  every session afterwards, and the remedy an operator reaches for is committing a virtual
  environment into a governed hub.
- **Two external binaries are called with no presence check.** `pdfinfo "$OUT"` and
  `pdftotext "$OUT" "$TXTFILE"` are both invoked with their errors discarded. A missing `pdfinfo`
  yields a build line reading `(? pages)` and a `PAGES` rule that warns it could not be checked; a
  missing `pdftotext` yields empty extracted text, which the guard runner refuses with a message
  that asks whether `pdftotext` is installed rather than a check that knew before rendering.

## What Changes

- **Interpreter discovery becomes portable and overridable.** An explicit `KM_PUBLISH_PYTHON` names
  an interpreter and is honoured before any search. Otherwise the script searches `PATH` for the
  usual names newest-first, then a short list of conventional install prefixes for the platforms
  where a package manager commonly installs outside a non-login shell's `PATH`. A candidate is
  accepted only when it satisfies the renderer's own stated requirement and can build a virtual
  environment.
- **The minimum Python version is stated because it was measured, not assumed.** The pinned wheel's
  own metadata declares `Requires-Python: >=3.10`, read from the installed distribution rather than
  from documentation. Discovery therefore rejects anything below 3.10, which on the authoring host
  means `/usr/bin/python3` at 3.9.6 is correctly refused while `python3.12` is accepted.
- **The failure message names the platform, the requirement, what was tried, and the override**, and
  gives an install line for the platform it is actually running on. The macOS SIP note is kept as a
  macOS note rather than as the whole error, because it is true and it is the non-obvious part.
- **The dependency is pinned** to a single version, with the pin held in one named variable, its
  reason recorded beside it, and an existing environment whose installed version does not match the
  pin rebuilt rather than used.
- **The virtual environment moves out of the tree** to a per-user cache directory, overridable with
  `KM_PUBLISH_VENV`. The in-tree path is additionally ignored and exempted, because an operator can
  point the override back inside a tree and because hubs created before this version carry the old
  ignore file.
- **The external binaries are checked before rendering**, with `pdftotext` required when the source
  has a guards sidecar and `pdfinfo` reported as a named warning when absent.
- **A `--preflight` subcommand** resolves the interpreter, reports the pin, the environment path and
  the binaries, and refuses on anything that would fail a real build. It is what makes the bootstrap
  testable without a render.
- **A new suite, `tests/test_km_publish_portability.sh`**, proves each of those in both directions,
  including a run of the unrepaired script from published `main` and a run of the unrepaired
  `hub-scan.sh` against a fixture hub carrying an environment directory.
- `tests/test_km_publish_guards.sh` is **not touched**. It exercises the guard engine, which this
  change does not alter.
- Not **BREAKING** for a hub's content or governance. It is behaviour-changing for an operator in
  one respect, stated plainly: the environment is no longer created at `tools/.venv`, so the first
  build after adoption bootstraps once more into the new location.

## Capabilities

### New Capabilities

- `publisher-portability`: what a shipped executable tool must do about interpreter discovery,
  dependency pinning, generated state, external binaries, and honest platform claims.

### Modified Capabilities

None.

## Impact

- **Affected material**: `tools/km-publish.sh`; `.gitignore`; `template/.gitignore`;
  `template/hub-scan.sh`; the three distributed copies of the `km-publish` skill
  (`skills/km-publish/SKILL.md`, `template/.claude/skills/km-publish/SKILL.md`,
  `template/.agents/skills/km-publish/SKILL.md`); `tests/test_km_publish_portability.sh` (new); the
  *Rendering an issuable artifact* and Standard Maintainer sections, the frontmatter, the H1, the
  lead and the v1.51 row of `STANDARD.md`.
- **Affected deployments**: every hub or Supervisor tier that renders documents. The adoption action
  is the tool copy and the ignore rule; no hub content, frontmatter, ontology or governance rule
  changes.
- **Not in scope**: replacing WeasyPrint, supporting Windows natively, vendoring native libraries, or
  adding a lockfile for the renderer's transitive dependencies.
- **Not in scope**: an end-to-end render inside the release gate. The gate would then need network
  access and a native library stack, and a check that cannot run is worse than one that is absent.
- **Owner boundary unchanged**: this change drafts and verifies. Publication is the owner's decision.
