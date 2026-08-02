# Skill: km-init — Initialize a New Knowledge Hub

You have been invoked as `/km-init`. Create a new governed knowledge hub by copying and
customising the reference template from this standard.

---

## Step 0 — The value gate. Ask this before anything else.

**Do not collect inputs, create directories, or copy a single file until this passes.**

Ask:

> **Name 3–5 questions this hub must answer that you cannot answer today. Tie each one to a
> decision it serves or a cost it avoids.**

Then test each answer:

| Answer | Verdict |
|---|---|
| "Which of our commitments are at risk this quarter, and who owns each?" → drives the weekly steering call | ✅ Real — a decision depends on it |
| "What did we agree with the client on pricing, and when?" → avoids re-litigating settled terms | ✅ Real — a cost is avoided |
| "It would be useful to have everything about the project in one place" | ❌ Not a question. Push back. |
| "To document the project" | ❌ That is an activity, not a question. Push back. |

**If the owner cannot produce them, stop. Say so plainly and do not scaffold:**

> "I can't set this hub up yet. If we can't name the questions it has to answer, the problem isn't
> missing structure — it's that the value isn't defined, and a hub won't fix that. It would pass
> every integrity check and still answer nothing anyone needed. Come back when you can name three."

This gate is the whole point. **Every other control in this standard measures correctness — whether
the hub is internally consistent, committed, well-formed. None of them measures whether it is
worth anything.** A hub can scan perfectly green and be useless. This is the only check that catches
that, and it only works before the directory exists — afterwards, sunk cost argues for keeping it.

Record the questions; they populate the **Competency questions** table in `01_project-brief.md`
(Step 4) and are re-checked by `/km-start`.

**The one exception:** a hub created purely as an archive of record, where the owner explicitly
accepts it answers no live question. Record that decision in `00_about.md` in the owner's own words.
Do not invent questions to satisfy the gate — a fabricated competency question is worse than none,
because it makes a useless hub look justified.

---

## Step 1 — Collect inputs

Ask the user for all of the following in one message:

- **Project name** — full human-readable name (e.g. "Q3 Product Launch")
- **Hub owner** — first and last name of the person responsible for approvals
- **Organisation name** — the organisation running this initiative
- **Unit / team name** — the specific team creating this hub
- **Your role / title** — job title of the person setting up this hub
- **Description** — one sentence: what this initiative is and what the hub tracks
- **Scope (in)** — one sentence: what is explicitly in scope for this hub
- **Scope (out)** — one sentence: what is explicitly excluded
- **About-me file (optional)** — a file path or pasted text describing the initiator's background,
  goals for this hub, and working preferences. If not available now, these sections can be filled
  in later via `/km-propose`.
- **Target path** — absolute path where the hub directory should be created
  (default: suggest `<current directory>/<project-slug>`)

Derive from the project name:
- `SLUG` = lowercase, spaces → hyphens, strip punctuation (e.g. "Q3 Product Launch" → `q3-product-launch`)
- `INIT_DATE` = today's date as `YYYY-MM-DD`

Confirm all values with the user before proceeding.

---

## Step 1.5 — Process about-me content (if provided)

**If the user provided a file path:**
1. Read the file in full (PDF, DOCX, TXT, or MD)
2. Extract three things:
   - **`INITIATOR_GOALS`** — why this hub was created; what the initiator wants to accomplish
   - **`INITIATOR_CONTEXT`** — role background, unit description, institutional context
   - **`INITIATOR_AGENT_NOTES`** — working preferences, how to interact, tone or format preferences
3. Show the extracted content to the user and confirm before proceeding

**If the user pasted text:**
Use the pasted content as the source; extract the same three fields.

**If no about-me was provided:**
Set all three fields to: `_To be added — use /km-propose to populate this section._`

---

## Step 2 — Locate the template

This skill lives at `<KM_STANDARD_ROOT>/skills/km-init/SKILL.md`. The reference template is at
`<KM_STANDARD_ROOT>/template/`.

Resolve `<KM_STANDARD_ROOT>` as the grandparent of the directory containing this SKILL.md file
(i.e. go up: `km-init/` → `skills/` → standard root).

After resolving the root, derive and validate the canonical provenance before creating the target:

```bash
KM_STANDARD_REVISION="$(git -C "$KM_STANDARD_ROOT" rev-parse HEAD)"
KM_STANDARD_SOURCE="$(git -C "$KM_STANDARD_ROOT" remote get-url origin 2>/dev/null || printf 'unresolved')"
KM_STANDARD_VERSION="$(sed -n 's/^\*\*Current version: v\([^*]*\)\*\*.*/\1/p' "$KM_STANDARD_ROOT/README.md" | head -1)"
```

`KM_STANDARD_REVISION` must be the full 40-character lowercase Git revision and
`KM_STANDARD_VERSION` must be non-empty. Stop before creating the hub if either value is invalid.
`KM_STANDARD_SOURCE` records the configured origin when available and `unresolved` otherwise; never
invent a source URL.

If the target path already exists and contains files, stop and ask the user to confirm before
overwriting anything.

---

## Step 3 — Create the hub directory structure

```bash
TARGET="<target-path>"
mkdir -p "$TARGET"/.claude/agents
mkdir -p "$TARGET"/.claude/skills/km-intake
mkdir -p "$TARGET"/.claude/skills/km-propose
mkdir -p "$TARGET"/.claude/skills/km-handover
mkdir -p "$TARGET"/.claude/skills/km-gather
mkdir -p "$TARGET"/.claude/skills/km-start
mkdir -p "$TARGET"/.claude/skills/km-brief
mkdir -p "$TARGET"/_inbox
mkdir -p "$TARGET"/changes
mkdir -p "$TARGET"/reconciliation/_disputes
mkdir -p "$TARGET"/sources/docs
mkdir -p "$TARGET"/working-docs
mkdir -p "$TARGET"/shareable
mkdir -p "$TARGET"/assets/architecture
mkdir -p "$TARGET"/decisions
mkdir -p "$TARGET"/risks
mkdir -p "$TARGET"/stakeholders
mkdir -p "$TARGET"/milestones
mkdir -p "$TARGET"/partners
mkdir -p "$TARGET"/corrections
mkdir -p "$TARGET"/relationships
mkdir -p "$TARGET"/archive
```

Every hub is a git repository — this is a hard requirement of the standard's integrity model (see
`hub-scan.sh`, Rule 3 in `STANDARD.md`). Initialize it now:

```bash
cd "$TARGET" && git init
```

---

## Step 4 — Copy and populate files

For every file listed below, read the source from `template/`, replace all placeholders, and write
to the target path.

**Placeholder map:**

| Placeholder | Value |
|---|---|
| `{{PROJECT_NAME}}` | Project name (as provided) |
| `{{PROJECT_SLUG}}` | SLUG derived above |
| `{{HUB_OWNER}}` | Hub owner full name |
| `{{ORG_NAME}}` | Organisation name |
| `{{UNIT_NAME}}` | Unit / team name |
| `{{INITIATOR_ROLE}}` | Initiator's role / title |
| `{{INITIATOR_GOALS}}` | Why this hub was created (from about-me or placeholder) |
| `{{INITIATOR_CONTEXT}}` | Role and unit context (from about-me or placeholder) |
| `{{INITIATOR_AGENT_NOTES}}` | Agent working notes (from about-me or placeholder) |
| `{{DESCRIPTION}}` | One-sentence description |
| `{{SCOPE_IN}}` | In-scope statement |
| `{{SCOPE_OUT}}` | Out-of-scope statement |
| `{{INIT_DATE}}` | Today's date (YYYY-MM-DD) |
| `{{KM_STANDARD_VERSION}}` | Canonical KM Standard version derived in Step 2 |
| `{{KM_STANDARD_REVISION}}` | Full canonical Git revision derived in Step 2 |
| `{{KM_STANDARD_SOURCE}}` | Canonical origin URL, or `unresolved`, derived in Step 2 |
| Competency questions | The 3–5 questions from **Step 0**, written into `01_project-brief.md` → **Competency questions** (one row each: question · decision/cost it serves · answerable today = N · last verified = INIT_DATE) |

**Files to copy (with placeholder substitution):**

```
template/CLAUDE.md                         → <target>/CLAUDE.md
   ⤷ After copying: if the workspace root contains `_KM_Supervisor/`, KEEP the "Estate binding"
     section and verify its four relative paths resolve from the new hub. If there is no
     `_KM_Supervisor/`, DELETE the section — a dangling estate binding is worse than none.
template/AGENTS.md                         → <target>/AGENTS.md
template/HANDOVER.md                       → <target>/HANDOVER.md
template/sources.config.md                 → <target>/sources.config.md
template/README.md                         → <target>/README.md
template/km-deployment.md                  → <target>/km-deployment.md
template/00_about.md                       → <target>/00_about.md
template/01_project-brief.md               → <target>/01_project-brief.md
template/02_context-scope.md               → <target>/02_context-scope.md
template/03_roadmap-milestones.md          → <target>/03_roadmap-milestones.md
template/04_stakeholders.md                → <target>/04_stakeholders.md
template/05_partnerships-pipeline.md       → <target>/05_partnerships-pipeline.md
template/06_risks-decisions.md             → <target>/06_risks-decisions.md
template/07_glossary.md                    → <target>/07_glossary.md
template/_inbox/README.md                  → <target>/_inbox/README.md
template/changes/PROPOSAL_TEMPLATE.md      → <target>/changes/PROPOSAL_TEMPLATE.md
template/changes/APPROVAL_TEMPLATE.md      → <target>/changes/APPROVAL_TEMPLATE.md
template/reconciliation/README.md          → <target>/reconciliation/README.md
template/sources/transcript-index.md       → <target>/sources/transcript-index.md
template/sources/publication-log.md        → <target>/sources/publication-log.md
template/working-docs/README.md            → <target>/working-docs/README.md
template/shareable/README.md               → <target>/shareable/README.md
template/context.jsonld                    → <target>/context.jsonld
template/decisions/TEMPLATE.md             → <target>/decisions/TEMPLATE.md
template/risks/TEMPLATE.md                 → <target>/risks/TEMPLATE.md
template/stakeholders/TEMPLATE.md          → <target>/stakeholders/TEMPLATE.md
template/milestones/TEMPLATE.md            → <target>/milestones/TEMPLATE.md
template/partners/TEMPLATE.md              → <target>/partners/TEMPLATE.md
```

`context.jsonld` and the five `TEMPLATE.md` files only need `{{PROJECT_SLUG}}` (and, for the templates,
no other substitution — they're producer-facing templates, not populated docs).

**Files to copy verbatim (no substitution):**

```
template/hub-scan.sh                       → <target>/hub-scan.sh
template/build-indexes.sh                  → <target>/build-indexes.sh
template/.gitignore                        → <target>/.gitignore
```

**Skills to embed in the new hub:**

```
template/.claude/skills/km-intake/SKILL.md   → <target>/.claude/skills/km-intake/SKILL.md
template/.claude/skills/km-propose/SKILL.md  → <target>/.claude/skills/km-propose/SKILL.md
template/.claude/skills/km-handover/SKILL.md → <target>/.claude/skills/km-handover/SKILL.md
template/.claude/skills/km-gather/SKILL.md   → <target>/.claude/skills/km-gather/SKILL.md
template/.claude/skills/km-start/SKILL.md    → <target>/.claude/skills/km-start/SKILL.md
template/.claude/skills/km-brief/SKILL.md    → <target>/.claude/skills/km-brief/SKILL.md
```

(Copy the `.agents/skills/` mirror too if the team also uses an AGENTS.md-compatible agent.)

**Empty directory markers:**

Create a `.gitkeep` file in each of these:
```
<target>/reconciliation/_disputes/.gitkeep
<target>/sources/docs/.gitkeep
<target>/assets/architecture/.gitkeep
```

**Make hub-scan.sh executable:**

```bash
chmod +x "<target>/hub-scan.sh"
```

After populating all files, search for any remaining `{{` in the target directory and flag any
that were not substituted.

---

## Step 4.5 — Mint the hub's agent definition (Agent Tier, added v1.7)

Every hub carries exactly one named agent definition — see `STANDARD.md` §"Agent Tier."

1. Derive `AGENT_NAME` = `km-<SLUG>` (same collapsing rule as `SLUG` in Step 1: lowercase, every run
   of non-alphanumeric characters → single hyphen, strip leading/trailing hyphens).
2. Copy `template/.claude/agents/km-AGENT.md.template` → `<target>/.claude/agents/<AGENT_NAME>.md`,
   substituting:
   - `{{AGENT_NAME}}` → `AGENT_NAME`
   - `{{AGENT_DESCRIPTION}}` → one sentence, e.g. `"Hub agent for {{PROJECT_NAME}}."`
   - `{{KM_TIER}}` → `hub`
   - `{{KM_SCOPE}}` → `.` (this hub's own root)
   - `{{SKILLS_LIST}}` → the skills actually copied into `.claude/skills/` in Step 4, comma-separated
   - `{{HUB_OR_ESTATE_NAME}}` → `{{PROJECT_NAME}}`
3. If a `_KM_Supervisor/` (or equivalent Supervisor tier) exists at the workspace root and it has
   `build-agent-registry.sh`, run it now so the new agent is discoverable immediately. If no
   Supervisor tier exists, the hub's agent still mints — a single-hub deployment's agent scope is
   simply the hub itself (`scope_enforcement: convention` either way; see `STANDARD.md`).

---

## Step 5 — Initial commit

```bash
cd "<target-path>" && git add -A && git commit -m "init: hub scaffold"
```

This is the baseline every future `hub-scan.sh` integrity check diffs against — no separate manifest
file to compute.

---

## Step 6 — Run hub-scan.sh

```bash
cd "<target-path>" && bash hub-scan.sh
```

All sections should show OK. If any section reports an issue, investigate and resolve before
reporting success. Common first-run issues:
- Frontmatter missing → a template file was not populated correctly
- Integrity flagged as uncommitted/untracked → the initial commit (Step 5) wasn't made, or a file was
  written after it

---

## Step 7 — Report to user

Restate the **competency questions** the hub was created to answer, and note that
`/km-start` will re-check them. They are the hub's reason to exist; the owner should
see them again at the moment the hub is handed over.


Report:
- Hub created at: `<target-path>`
- Files created: list them
- Agent minted: `.claude/agents/<AGENT_NAME>.md`
- Deployment state: `canonical`
- Initial scan: all sections OK (or list issues)

Suggest next steps:
1. Open the hub with your agent tool — skills ready: `/km-start` (session audit), `/km-intake`, `/km-propose`, `/km-gather`, `/km-handover`
2. Edit `01_project-brief.md` with the initiative's actual brief
3. Drop the first source file in `_inbox/` and run `/km-intake`
4. Add a remote and push if off-machine backup/collaboration is wanted (`git remote add origin <url> && git push -u origin main`)

---

## Notes

- This skill runs `git init` and the initial commit (Steps 3 and 5) — git is a hard requirement of the standard's integrity model, not optional
- If the user wants to add `08`–`10` docs, do so after init as separate files
- The template's reconciliation topic files are intentionally absent — they are created as needed when disputes arise
- `hub-scan.sh` may show `[INBOX]` as not present if it doesn't check for that section — this is fine until files are dropped

---

## Step 8 — Offer to seed by curation (optional)

A fresh hub is stub docs saying "content to be populated". Filling them by hand is the slowest
possible start, and the expert's time is better spent **reviewing** than **drafting**.

Offer:

> "I can take a first pass at `01`–`07` and the initial entity notes from sources you name — existing
> docs, wikis, schemas, past decks. You review and correct rather than writing from blank. Want me
> to?"

If yes, run `/km-gather` against the named sources and produce proposals through the normal flow —
**curation does not bypass governance.** The owner reviews and refines; nothing is applied unapproved.

**Be honest about what this buys.** Curation accelerates **construction only**. It does nothing for
maintenance — and maintenance, not modelling, is what kills these programs. A hub seeded in an hour
and never reviewed again is worse than an empty one, because it looks authoritative. Do not oversell
this step.
