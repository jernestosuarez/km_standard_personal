---
name: km-publish
description: Use when a document held in this hub must be issued outward as a rendered PDF. /km-publish builds it from committed source through the shared renderer and its guards.
---

# Skill: km-publish — Issue an Outward-Facing Artifact from the Hub

You have been invoked as `/km-publish`. Render an issuable document (PDF) from an editable source held in
this hub, using the shared renderer tool. Governed by the standard's *Artifact Generation (Push) —
Rendering an issuable artifact* section.

**Division of labour:** `km-brief` (and the normal proposal workflow) decides *what a document says*. This
skill turns committed content into an *issuable artifact*. Neither bypasses the other.

## Modes

| Invocation | Action |
|---|---|
| `/km-publish <slug>` | Build the document in `working-docs/…/<slug>/` |
| `/km-publish new <slug>` | Scaffold a new publishable document |
| `/km-publish list` | List publishable documents in this hub |

## Build

1. Locate `working-docs/…/<slug>/` — it must contain a `<NAME>.html` source. Run its `build.sh`, or call
   the shared tool directly: `bash <tools-path>/km-publish.sh <source.html> <output.pdf>`. In a multi-hub
   workspace the tool lives once at the supervisor tier (`../_KM_Supervisor/tools/`); a standalone hub
   keeps it in its own `tools/`.
2. **Guards are not optional output** — if the build reports `GUARD FAIL`, the artifact must not be issued,
   and the failure is surfaced to the hub owner verbatim. Guards encode corrections; a failing guard means
   a rebuild tried to reintroduce a defect the source exists to prevent.
3. **`GUARD REFUSED` is not a pass and not a failure — it is a guard that could not be evaluated.** The
   runner refuses (exit 2) on a pattern it cannot compile, a boundary construct the matching tool proves
   inert, extracted text that came back empty, a guards file that reads as empty or asserts no rules, and
   an unrecognised verb. Fix the guards file or the environment and rebuild; never issue the artifact on a
   refusal, and never delete the offending rule to get past it.
4. Visually verify at least the first and last page (`pdftoppm` → read the images). A page count is not a
   layout check.
5. If the artifact is being **issued externally**, log it in `sources/publication-log.md` with the commit it
   was generated from. Drafting-content changes still go through proposal/approval first.

## Scaffold (`new <slug>`)

Create `working-docs/<topic>/<slug>/` with:
- `<NAME>.html` — self-contained source (content + CSS in one file; `@page` for the paper size;
  `<div class="pb">` for page breaks; per-page footer carrying the issue date)
- `<NAME>.guards` — **required when a correction motivated the document**; otherwise optional. One rule
  per line, applied to the rendered PDF's extracted text: `FORBID <regex>` / `REQUIRE <regex>` /
  `FORBID-WORD <regex>` / `REQUIRE-WORD <regex>` / `PAGES <n>`; `#` comments. **Use the `-WORD` forms for
  whole-word matching, never `\b`**: the runner probes any boundary construct against the tool that will
  actually run it and refuses when it proves inert, because an ignored boundary matches nothing and
  nothing is also what a clean document looks like
- `build.sh` — thin wrapper: `exec bash <relative-tools-path>/km-publish.sh <NAME>.html <OUTPUT>.pdf`
- `README.md` — what the document is, what the guards protect, who issues it

## Rules

- **The rendered file is never the master — until the owner edits it.** Never edit a PDF; edit the
  source and rebuild. **Exception:** if the hub owner has hand-edited a rendered artifact, that file
  becomes the baseline — never regenerate over it; make further changes surgically inside it,
  matching the owner's formatting; keep the generator/source for provenance only and record the
  inversion in the document's `README.md`.
- **Artifacts stay in the hub.** Create outputs only under the hub tree; a skill or tool default
  that points elsewhere (Desktop, Downloads) is overridden by the hub's location rules. Copies
  outside the hub only on explicit owner request.
- **Never weaken or delete a guard to make a build pass.** A guard change is a hub change — it needs the
  hub owner, because each guard traces to a correction.
- **Facts in the source must match the hub docs.** Where a document restates something a numbered doc
  holds, the hub doc is the record; on divergence, stop and surface it.
- Renderer is WeasyPrint via the shared tool, which bootstraps itself at a **pinned** version into a
  virtual environment **outside the hub tree** (added in v1.51, drafted and unpublished; binds
  nothing until its own owner push). Office-suite "export to PDF" is a preview, never an issue path
  — it drops page breaks and background fills.

## Environment (added in v1.51, drafted and unpublished)

Run `bash <tools-path>/km-publish.sh --preflight <NAME>.html` before a first build on a new machine,
or when a build fails in a way that looks environmental. It resolves the interpreter, reports the pin
and the environment path, checks the external binaries, installs nothing, and renders nothing.

- **The interpreter is discovered, not hardcoded.** `KM_PUBLISH_PYTHON` names one explicitly and is
  honoured before any search; an override that cannot work is refused by name rather than searched
  past. Otherwise `PATH` is searched newest-first, then the conventional install prefixes. The
  minimum is **CPython 3.10**, which is what the pinned renderer's own metadata declares.
- **The environment lives outside the tree**, under the user's cache directory, keyed by the pinned
  version, and `KM_PUBLISH_VENV` relocates it. **Never commit a virtual environment to the hub**, and
  if you find one in a hub that predates v1.51, delete it: it is ignored and exempt from
  `[ INTEGRITY ]`, so removing it changes nothing the hub asserts.
- **`pdftotext` and `pdfinfo` (poppler) are checked before rendering.** `pdftotext` is required when
  the source has a `.guards` sidecar, because guards are applied to extracted text; a missing
  `pdfinfo` warns and the build proceeds, with the page count and any `PAGES` rule reported as
  unevaluated.
- **Platforms:** macOS on Apple Silicon is exercised. Linux, Intel macOS and other Unix hosts are
  **written and unverified**: the path is portable by construction and was not run there. Native
  Windows is out of scope.
