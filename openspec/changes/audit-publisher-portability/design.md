# Design

## Context

The standard is mostly documents. `tools/km-publish.sh` is one of the few places where it ships an
executable, and an executable makes claims about the world that a document does not have to. This one
claimed, by the shape of its code rather than in words, that every host is Apple Silicon macOS with
Homebrew installed. The claim was invisible until someone forked the repository, which is what is
about to happen.

The bootstrap block is nine lines long and carries five separate defects. That density is not a
coincidence: bootstrap code is written once on the author's machine, succeeds there, and is never
exercised again on that machine because the environment it builds persists. The author's host is the
only host it is ever tested on, and the failure branch is the branch that never runs.

## Goals / Non-Goals

**Goals.**

- The publisher runs, or refuses with a message an operator can act on, on any host with a Python the
  renderer supports.
- The renderer is the same renderer next month as it is today.
- Running the publisher leaves the tree exactly as it found it, in the canonical repository and in
  every hub that inherits the scan.
- The bootstrap is testable without a network, without a render, and without the native library stack.
- Every platform claim in the shipped text is one that was exercised, or is labelled as one that was
  not.

**Non-Goals.**

- Supporting Windows natively. WeasyPrint's native dependency stack on Windows is a different
  problem, and claiming it without exercising it is the defect this change exists to remove.
- Vendoring or building native libraries. The script finds an interpreter; it does not become a
  package manager.
- A lockfile over the renderer's transitive dependencies. The pin closes the version-drift class the
  audit names. A full lock is a larger decision about how this repository distributes software, and
  it belongs to a change that is about that.
- An end-to-end render inside the release gate. See *Risks* below.

## Decisions

### Discovery: an explicit override first, then a search, and a floor that was measured

An operator who knows which interpreter they want must be able to say so, because no search is
cleverer than a person with a working environment. `KM_PUBLISH_PYTHON` is therefore consulted before
anything else, and when it is set and unusable the script refuses rather than silently searching past
it: an override that is quietly ignored is worse than no override, because the operator's evidence
about what happened is now false.

The search is `PATH` first, newest interpreter name first, then a small list of conventional prefixes
(`/opt/homebrew/bin`, `/usr/local/bin`, `/usr/bin`, `/opt/local/bin`). The prefixes exist for one
real case rather than for completeness: a package manager installs outside the `PATH` a non-login
shell inherits, which is precisely the Intel-macOS-Homebrew shape the current code half-handles and
gets wrong.

**The floor is 3.10 because the pinned wheel says so.** It was read from the installed distribution's
own metadata (`Requires-Python: >=3.10` for `weasyprint 69.0`), not from documentation and not from a
guess. The consequence is visible on the authoring host: `/usr/bin/python3` is 3.9.6 and is correctly
refused, while `python3.12` is accepted. A candidate must also import `venv` and `ensurepip`, because
several Linux distributions ship a `python3` that cannot create a virtual environment, and finding out
at `python3 -m venv` produces an error about `ensurepip` rather than about the interpreter.

### The message names the platform, and the SIP note survives as a note

The old error was not merely unhelpful, it was a wrong diagnosis stated confidently, and the operator
most likely to hit it is the one least able to see past it. The replacement names what host it is on
(`uname -s`/`uname -m`), what it needs, what it looked at, and the override. The install line is
selected by platform.

The macOS SIP sentence in the old text is real knowledge and is kept. Under System Integrity
Protection the dynamic loader strips `DYLD_*` from processes launched from protected system paths, so
`/usr/bin/python3` cannot find the Homebrew `libgobject` that WeasyPrint's `cffi` bindings load. That
is worth telling a macOS operator and worth telling nobody else, so it appears in the macOS branch.

### The pin is a variable with its reason beside it

One name, `WEASYPRINT_PIN`, holds `weasyprint==69.0`. An environment whose installed version does not
match is rebuilt rather than reused, so changing the pin is sufficient to change what runs, and an
environment left over from before the pin does not survive as a silent third version. The reason is
recorded in the script: v1.40 quarantined the MCP surface after an unpinned install resolved to a
major version whose interface the code did not use, and a renderer is a worse place to learn that
lesson twice because its output is issued outside the organisation.

### The environment leaves the tree, and the tree is defended anyway

The environment goes to `${XDG_CACHE_HOME:-$HOME/.cache}/km-publish/`, keyed by the pinned version,
overridable with `KM_PUBLISH_VENV`.

Out-of-tree was chosen over ignore-in-place, and the reason is adoption rather than taste. An ignore
rule has to reach every tree the tool can run in: the canonical repository, the Supervisor tier, and
every hub, including hubs created before this version whose `.gitignore` is a copy of the old one.
That is an adoption action per deployment, and a deployment that misses it fails its own session-start
scan. Moving the directory fixes every one of those trees at once, with no adoption action beyond
taking the new tool.

The ignore rule and the scan exemption are added **as well**, and this is deliberate belt-and-braces
rather than indecision. Two reasons: `KM_PUBLISH_VENV` lets an operator legitimately point the
environment back inside a tree, and a hub that already ran the old publisher has a `tools/.venv`
sitting there today that no new tool version removes. Defending the tree costs four lines and covers
both.

The scan exemption uses git's `glob` pathspec magic, `:(exclude,glob)**/.venv`, because that is what
was proved to work against the git that runs it. Three other spellings were tried against a fixture
hub and two of them excluded nothing while producing no error, which is the same silent-inertness
class the guard runner's boundary probe exists to catch.

### The binaries are checked before the render, and the two are not the same requirement

`pdftotext` and `pdfinfo` are not equally required and treating them alike would be wrong in one
direction or the other.

- `pdftotext` is **required when the source has a guards sidecar**, and only then. Guards are applied
  to extracted text; without extraction there is no text, and the guard runner correctly refuses. But
  refusing after rendering, with a message that asks whether `pdftotext` is installed, is a worse
  version of a question that could have been answered before any work was done.
- `pdfinfo` is a **named warning**. It supplies the page count, which decorates the build line and
  drives `PAGES`, and `PAGES` is a warning rule by contract. Making a missing `pdfinfo` fatal would
  fail builds that the standard says should succeed.

### `--preflight` is what makes the bootstrap testable

The bootstrap could not be tested before because reaching it required rendering. `--preflight` runs
discovery, reports the pin, the environment path and the binaries, and refuses on anything that would
fail a real build, without installing anything. The suite drives it with a controlled `PATH`, which
is how discovery failure, override honouring, and a missing binary are each proved without breaking
the host.

## Risks / Trade-offs

- **The Linux path is written and not exercised.** There is no Linux host in this session. The code
  is written to be portable and the message carries Debian and Fedora install lines, and every
  statement about Linux in the shipped text says the path is unverified. Stating that is the repair;
  claiming Linux support would be a new instance of the class this version closes.
- **An end-to-end render is not in the gate.** A render needs the network on first run and a native
  library stack always, and a gate check that refuses on a normal developer machine trains people to
  ignore refusals. One render was performed by hand in this session, with the pinned version, and the
  result is recorded in the version row. What remains unproved is that any *other* host renders.
- **Moving the environment costs one re-bootstrap** per operator, and the old `tools/.venv` is left
  in place rather than deleted. A tool that deletes directories it did not create in this run is a
  worse tool than one that leaves a stale directory an operator can remove.
- **A pin goes stale.** It is one variable with its reason beside it, and the alternative that failed
  is the one being repaired.

## Migration

An operator's first build after taking the new tool bootstraps once into the cache directory. Any
existing `tools/.venv` becomes inert and can be deleted by hand; it is ignored and exempted from the
scan either way. Nothing about a hub's content, frontmatter, governance or manifest changes.
