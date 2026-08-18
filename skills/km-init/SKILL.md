---
name: km-init
description: Use when standing up a new knowledge hub, or adopting a directory that already exists into this standard. /km-init runs the purpose interview, scaffolds what is missing, mints the agent, and registers the hub.
---

# Skill: km-init — Initialize or Adopt a Knowledge Hub

You have been invoked as `/km-init`. Produce a governed knowledge hub's **definition** by running
the purpose interview, and stand up whatever the directory does not already have.

## Two entry conditions, one interview

| Mode | Entry condition | What it writes |
|---|---|---|
| **`/km-init <path>`** (create) | No hub exists at the path | The full scaffold from `template/`, the deployment binding, the agent definition, the registry row |
| **`/km-init --adopt <path>`** (adopt) | A directory already exists and is not an initiated hub | The hub definition, the scope guard, the registry row, and **only** the scaffold files that are absent |

The **adoption mode** exists because a control that makes existing artifacts non-conformant must
ship with the act that makes them conformant (STANDARD.md → "A gate needs a route back"). A hub
whose `km-deployment.md` carries no `initiation-interview` date never scans green, and before this
mode there was no way to give it one without hand-writing the record. Two rules bound the mode and
neither is negotiable:

- **The interview is run, never waived.** Adoption is not a stamp. Writing an
  `initiation-interview` date onto a hub nobody interviewed forges the exact evidence the gate asks
  for, and it is worse than the red scan it replaces, because a red scan is honest.
- **Only what is absent is written.** Never overwrite existing hub content, and never overwrite the
  canonical provenance the hub already records — a hub records the revision it was *built* from, and
  re-pinning it is a separate governed act. List everything the pass added.

A directory can be quarantined by two different scans: its own (`hub-scan.sh` `[ DEPLOYMENT ]`, for
the missing interview record) and, where a supervisor tier exists, the estate's (for absence from
the hub registry). **One interview clears both.** Clearing one and not the other leaves the hub
non-conformant with a check nobody was watching, so never stop halfway.

Run Steps 0, 0.5 and 1 in **both** modes. In adopt mode, skip Step 3 (directory creation) and Step
4's file copying except for genuinely missing files, and follow Step 4.7 for what to write.

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

**In adopt mode the gate is harder to hold, and matters more.** The directory is already there,
often with real content in it, and every instinct argues for initiating whatever exists. Adoption is
therefore also the moment to conclude that a directory should **not** become a hub — that it is a
folder of files, and governing it buys nothing. An adoption pass that has never once returned that
answer is not being run honestly. Say it plainly when it is the answer, and leave the directory
alone.

Record the questions; they populate the **Competency questions** table in `01_project-brief.md`
(Step 4) and are re-checked by `/km-start`.

**The one exception:** a hub created purely as an archive of record, where the owner explicitly
accepts it answers no live question. Record that decision in `00_about.md` in the owner's own words.
Do not invent questions to satisfy the gate — a fabricated competency question is worse than none,
because it makes a useless hub look justified.

---

## Step 0.5 — Look before asking

**Read what already exists before putting a single question to the owner.**

- **The directory itself** — numbered documents, `CLAUDE.md`/`AGENTS.md` and any scope statement in
  them, `km-deployment.md`, `README.md`, `sources/`, `changes/`, entity notes.
- **The workspace**, where a supervisor tier is present — the hub registry, the relationship graph,
  the decision log for any prior owner ruling on this subject, the unrouted backlog and any parked
  register.

**Pre-fill every interview answer you can defend from that evidence, and present each pre-fill with
its source.** The owner confirms or corrects a pre-fill instead of dictating from zero. Then **state
plainly which answers you could not pre-fill** — those are the real questions, and they are what the
owner's attention is for.

This matters most in adopt mode, where the evidence is richest: a directory holding two years of
content has already demonstrated its purpose, its scope and its audiences, and the interview's job
there is to have the owner **ratify what the content shows**, not reconstruct it from memory.

**A pre-fill is a proposal, not an answer.** Only the owner's confirmation is recorded. Never write
an unconfirmed pre-fill into the hub definition as though it had been given: the point of the step is
to spend the owner's attention on what the record cannot answer, and a pre-fill that becomes the
answer by default spends none of it and fabricates the definition instead.

---

## Step 1 — The purpose interview (structured Q&A, v1.25; extended in v1.28)

The hub's definition is **produced by an interview, never assumed**. Run it as batched
structured questions — three or four per round, one decision per question, in the order below —
and record the answers verbatim; they populate the **Hub definition** in `km-deployment.md`,
the scope guard in `CLAUDE.md`/`AGENTS.md`, and (where a supervisor tier exists) the hub's
registry row. The interview date is stamped into `km-deployment.md` as `initiation-interview`;
**without it the hub is quarantined — `hub-scan.sh` reports an error and the hub never scans
green.**

**Round 1 — identity and purpose:**

- **Project name** — full human-readable name (e.g. "Q3 Product Launch")
- **Hub owner** — first and last name of the person responsible for approvals
- **Organisation name** — the organisation running this initiative
- **Unit / team name** — the specific team creating this hub
- **Your role / title** — job title of the person setting up this hub
- **Description (purpose)** — one sentence: what this initiative is and what the hub tracks

**Round 2 — the scope guard.** Ask for a rule an agent can apply to an inbound source, not a
description of the subject:

- **Scope (in)** — the condition under which a source is **admitted** to this hub, phrased as an
  admission rule ("anything bearing on X's delivery, commitments or counterparties"), not as a
  topic label.
- **Scope (out)**, and **hard exclusions** — what is excluded, and specifically what this hub
  **refuses even when a routing keyword matches**. Keyword matching is how a source reaches a hub
  in the first place, so an exclusion never stated against a matching keyword never fires. Push for
  a real one: a scope guard with no "out" guards nothing, and an "out" that names a subject area
  rather than a refusal is barely better.
- **Routing keywords** — 5–10 lowercase, comma-separated terms that mark a source as this
  hub's business. They feed the supervisor's hub registry and the decision surface's per-hub
  attribution, and they are written into `km-deployment.md` as `routing-keywords`, where
  `hub-scan.sh` requires a substituted, non-empty value.

**Round 3 — audiences and surfaces.** A deployment has three surfaces (STANDARD.md → "The
decision surface: three surfaces"): the **audience** surface (generated knowledge shaped per
function, no machinery), the **owner** surface (only the decisions waiting on a person), the
**practitioner** surface (the hub itself). Ask:

- **Who will consume this hub's knowledge**, and which surface does each get? (e.g. "the
  steering group — audience surface, monthly brief; the owner — owner surface; the project
  team — practitioner".) Record one line per audience.
- **Owner cadence** — how often will the owner sit with the decision queue, and on which
  answer surface? Ask recommendation-first, per the interaction contract: **a deployed
  cockpit (recommended)** — the owner surface is what decides whether a deployment survives,
  and the cockpit is the standard's reference implementation of it
  (`components/km-cockpit/`) — then chat or the clearing skill; all remain equally valid
  answer channels. Planning the surface here is mandatory; deploying the cockpit remains an
  explicit act with its own deployment step, but the default recommendation is the cockpit.

**Round 4 — the knowledge-vs-records boundary (Rule 6, elicited, not assumed).** The access
vocabulary exists in the standard; this conversation is what applies it. Ask:

- **What material is knowledge here** — claims this hub curates, adjudicates and republishes —
  **and what is records** — operational data that stays in the systems that master it, with
  the hub holding claims and resolvable pointers only? Walk the owner's named sources: for
  each, knowledge or record?
- **Evidence expectations** — which source classes will this hub trust at face value, and
  which always need owner confirmation? (Anchor on the evidence order: subject-confirmed >
  owner-statement > independent sources > systems of record > unresolvable references.)

**Round 5 — posture and connections:**

- **Sensitivity posture** — are `sensitivity: restricted` or `accessClass: restricted` classes
  expected in this hub, and which **outbound surfaces** are planned (`shareable/`, a published
  reading site, a generated brief)? A yes makes the outbound lint set part of initiation rather
  than a retrofit, and, where the hub species axes are in use, declares `station` and `exposure`
  now. Discovering a restricted class after an outbound surface exists is the expensive order: the
  material has already travelled, and the check that would have stopped it arrives afterwards.
- **What should move home to this hub** — where the workspace holds material with no home (the
  supervisor's unrouted backlog, a parked register, a routing gap recorded and left open), ask
  which of it belongs here. A hub stood up in a live workspace usually exists *because* something
  had nowhere to go; move it as part of initiation (Step 4.8). Skip this question where no such
  register exists — a first hub has nothing to sweep.
- **Relationships to existing hubs** — candidate edges for the relationship graph, where a
  supervisor tier holds one. Proposed here, confirmed by the owner, never auto-written.

**Closing:**

- **About-me file (optional)** — a file path or pasted text describing the initiator's
  background, goals for this hub, and working preferences. If not available now, these
  sections can be filled in later via `/km-propose`.
- **Target path** — absolute path where the hub directory should be created
  (default: suggest `<current directory>/<project-slug>`)

Derive from the project name:
- `SLUG` = lowercase, spaces → hyphens, strip punctuation (e.g. "Q3 Product Launch" → `q3-product-launch`)
- `INIT_DATE` = today's date as `YYYY-MM-DD`

Confirm all values with the user before proceeding. The interview's outputs are three
artifacts: the **scope guard** (CLAUDE.md/AGENTS.md and `km-deployment.md`), the **hub
manifest** (`km-deployment.md` → Hub definition, `initiation-interview` stamped), and — where
a supervisor tier exists — the **registry row** (Step 4.6).

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

**In adopt mode, do not overwrite provenance the hub already carries.** A hub records the revision
it was *built* from; re-pinning it to a later canonical revision is a separate governed act with its
own authority. Derive the values above only to fill fields that are absent or empty, and report any
divergence between the hub's recorded version and the current one rather than silently closing it.

If the target path already exists and contains files, this is the adopt case: run `--adopt` rather
than overwriting anything. If the user asked for create mode against a populated directory, stop and
ask them to confirm which mode they meant.

---

## Step 3 — Create the hub directory structure (create mode)

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

## Step 4 — Copy and populate files (create mode; adopt mode adds only what is missing, Step 4.7)

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
| `{{DESCRIPTION}}` | One-sentence description (the hub's purpose, from the interview) |
| `{{SCOPE_IN}}` | In-scope statement, phrased as the admission rule (interview Round 2) |
| `{{SCOPE_OUT}}` | Out-of-scope statement (interview Round 2) |
| `{{HARD_EXCLUSIONS}}` | What the hub refuses even when a routing keyword matches (interview Round 2) |
| `{{SENSITIVITY_POSTURE}}` | Expected restricted classes and planned outbound surfaces (interview Round 5) |
| `{{ROUTING_KEYWORDS}}` | Comma-separated lowercase routing keywords (interview Round 2). Must be substituted and non-empty — `hub-scan.sh` `[ DEPLOYMENT ]` errors otherwise |
| `{{AUDIENCE_SURFACES}}` | One line per audience, each mapped to its surface (interview Round 3) |
| `{{OWNER_CADENCE}}` | Owner cadence and answer surface (interview Round 3) |
| `{{KNOWLEDGE_RECORDS_BOUNDARY}}` | The elicited knowledge-vs-records boundary (interview Round 4) |
| `{{EVIDENCE_EXPECTATIONS}}` | The elicited evidence expectations (interview Round 4) |
| `{{INIT_DATE}}` | Today's date (YYYY-MM-DD) — also stamped as `initiation-interview` in `km-deployment.md`; the scan quarantines a hub without it |
| `{{KM_STANDARD_VERSION}}` | Canonical KM Standard version derived in Step 2 |
| `{{KM_STANDARD_REVISION}}` | Full canonical Git revision derived in Step 2 |
| `{{KM_STANDARD_SOURCE}}` | Canonical origin URL, or `unresolved`, derived in Step 2 |
| Competency questions | The 3–5 questions from **Step 0**, written into `01_project-brief.md` → **Competency questions** (one row each: question · decision/cost it serves · answerable today = N · last verified = INIT_DATE) |

**Files to copy (with placeholder substitution):**

```
template/CLAUDE.md                         → <target>/CLAUDE.md
   ⤷ After copying: if the workspace root contains `_KM_Supervisor/`, KEEP the "Estate binding"
     section but BIND ONLY WHAT EXISTS (v1.26): check each bullet's target path from the new
     hub and delete every bullet whose file or directory is not present at the tier — next to a
     minimum tier that leaves only the hub-registry/QUEUE bullet. If there is no
     `_KM_Supervisor/`, DELETE the whole section — a dangling estate binding is worse than none.
     Apply the same pruning to AGENTS.md (the sections are mirrors).
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
template/handover-hooks.sh                 → <target>/handover-hooks.sh
template/.claude/settings.json             → <target>/.claude/settings.json
template/.gitignore                        → <target>/.gitignore
```

`.claude/settings.json` wires the handover hooks (v1.18): a `SessionStart` baseline and a `Stop`
check. It references the
script portably through `$CLAUDE_PROJECT_DIR`, which Claude Code sets to the hub root, so it is copied
verbatim and works wherever the hub is created — never substitute a path into it. The hooks are a
Claude Code mechanism; Codex/AGENTS.md has no equivalent Stop-blocking lifecycle, so there is no
`.agents/settings.json` parallel — the underlying obligation is enforced for both surfaces by the
standard itself and by the read-side surfacing in `hub-scan.sh`.

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

**Make the hub scripts executable:**

```bash
chmod +x "<target>/hub-scan.sh" "<target>/handover-hooks.sh"
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

## Step 4.6 — The supervisor threshold: detect, offer, register (v1.25/v1.26)

**Detection (v1.26).** When at least one hub already exists in the workspace root (the parent
of the target path — a **hub-shaped directory** is one containing `km-deployment.md` or
`hub-scan.sh`), run both checks below, in order.

**(a) Detect a deployed cockpit.** Look for a cockpit deployment manifest — `km-cockpit.json`
at a deployment location (beside any copy of `km-cockpit.py`; the reference location is
`<hub>/cockpit/` pre-tier, `_KM_Supervisor/cockpit/` after). If one is found, **ask the owner
whether to add the new hub to it.** On yes, which path applies depends on the tier, and the
interview report states which one applied:

- **No supervisor tier yet** — the addition rides the tier-minting in (b): the estate queue
  absorbs both hubs' decision rows, the cockpit manifest re-points its `queue_path` at the
  estate queue (and gains `hub_registry_path`), and the registry-derived hub map picks up the
  new hub from its registry row. One config change, no rebuild.
- **Tier already exists** — confirm the new hub's registry row (the Registration step below):
  the cockpit's hub map derives from the registry, so the row is all it needs and nothing else
  is done.

**(b) Recommend the supervisor tier.** If there is **no `_KM_Supervisor/`**, the threshold is
crossed — the standard advises the supervisor tier the moment there is more than one hub. Put
it recommendation-first, per the interaction contract:

> "This workspace now holds two hubs and no supervisor tier. The standard advises one at the
> second hub — estate state (the owner queue, cross-hub decisions) has nowhere correct to live
> inside a hub. **Recommended: mint the minimum tier now** — it is four small things: a hub
> registry, an estate queue, an inbox, and its own git history. Alternative: **not yet** — the
> advice and your decline are recorded."

If **yes**: create `_KM_Supervisor/` at the workspace root from
`skills/km-supervise/_KM_Supervisor_template/` — copy `hub-registry.md`, `QUEUE.md`, `README.md`
(the conditions table) and `_inbox/README.md`, substitute `{{INIT_DATE}}`, `git init` and
commit; write a registry row for **each** hub found (this one and the pre-existing ones, from
their `km-deployment.md` interview records — a pre-existing hub with no interview record gets
status `repo`, a note that its interview is owed, and **a named next act: `/km-init --adopt` on
that directory**, which is what clears it; never leave the demotion as the end of the story); and
complete any cockpit addition agreed in (a) by re-pointing the manifest. If **not yet**: record the
recommendation and the owner's decline in the report; the threshold rule is advice the standard
gives, never an act performed silently.

**Registration (v1.25).** If `_KM_Supervisor/` exists (pre-existing or just minted), append the
new hub's row to `_KM_Supervisor/hub-registry.md` from the interview's answers:

```
| <hub-directory-name> | hub | <hub owner> | <routing keywords> |
```

The registry is the estate's routing map and the decision surface's attribution source; a hub
missing from it is quarantined by the estate's own scan. If no supervisor tier exists (the
owner declined, or this is the first hub), skip registration — single-hub deployments carry
their routing keywords in `km-deployment.md`, where the decision surface reads them directly.

---

## Step 4.7 — Adopt mode: what to write into a directory that already exists

**Applies only to `--adopt`.** Skip in create mode.

1. **Scaffold only what is absent.** Compare the directory against `template/` and add only files
   that are missing: the numbered documents it lacks, `hub-scan.sh`, `build-indexes.sh`,
   `handover-hooks.sh`, `.claude/settings.json`, `HANDOVER.md`, `context.jsonld`, `changes/` and its
   two templates, `_inbox/README.md`, the entity folders and their `TEMPLATE.md` files, `.gitignore`.
   **Never overwrite an existing file.** `git init` only if the directory is not already a
   repository. List every file added.
2. **Write the hub definition into `km-deployment.md`** — the `initiation-interview` date (today,
   `YYYY-MM-DD`, which is what lifts the standard's quarantine), `routing-keywords`, and the **Hub
   definition** body section from the interview's answers. Preserve every provenance and deployment
   field the binding already carries, including `deployment-state` and any organization or
   enterprise binding: this step adds the interview record to an existing binding, it does not reset
   the hub.
3. **Write the scope guard** into `CLAUDE.md` and `AGENTS.md` (mirrors — apply to both) as the
   admission rule plus the hard exclusions, in the owner's own words. Where a scope statement
   already exists and the interview changed it, replace it and say so in the report.
4. **Write the competency questions** into `01_project-brief.md`.
5. **Mint the agent definition** if the hub has none (Step 4.5), and register the hub (Step 4.6) —
   the registry row is what lifts the estate's quarantine.
6. **Verify both gates cleared.** Run the hub's scan and, where a supervisor tier exists, the
   estate's. If the hub's inherited `hub-scan.sh` predates the `[ DEPLOYMENT ]` interview check, it
   cannot report the gate at all: say so explicitly rather than reporting a pass the scan never
   performed, and verify the frontmatter by reading it.

---

## Step 4.8 — Move home what was parked (where a register exists)

If Round 5 identified material parked elsewhere for want of a home — items in the supervisor's
unrouted backlog, a parked register, an open routing gap this hub closes — move it now, through the
receiving hub's normal intake, and close the register rows it came from. Leaving it parked after its
home exists outlives the backlog's own reason for existing, and a register nobody drains stops being
read. Where no such register exists, skip this step.

---

## Step 5 — Initial commit

```bash
cd "<target-path>" && git add -A && git commit -m "init: hub scaffold"
```

This is the baseline every future `hub-scan.sh` integrity check diffs against — no separate manifest
file to compute.

**Create mode only.** The blanket add is safe here for the one reason STANDARD.md gives (*Rule 3 →
Stage explicitly*): nothing has been deleted yet and the tree holds only what the template put
there. **In adopt mode neither holds** — the directory has its own history, possibly its own pending
deletions and its own uncommitted work — so stage the paths this pass wrote, by name, and commit
them with the reason. Never sweep an existing hub's unrelated working state into an initiation
commit.

---

## Step 6 — Run hub-scan.sh

```bash
cd "<target-path>" && bash hub-scan.sh
```

All sections should show OK, and `[ DEPLOYMENT ]` must not print `HUB NOT INITIATED`. If any section
reports an issue, investigate and resolve before reporting success. Common first-run issues:
- Frontmatter missing → a template file was not populated correctly
- Integrity flagged as uncommitted/untracked → the initial commit (Step 5) wasn't made, or a file was
  written after it
- `HUB NOT INITIATED`, or a `routing-keywords` error → `km-deployment.md` still carries an
  unsubstituted `{{INIT_DATE}}` or `{{ROUTING_KEYWORDS}}`; both are gated, and a placeholder cannot
  pass either check

In adopt mode the hub may be running an **inherited copy** of `hub-scan.sh` that predates the
`[ DEPLOYMENT ]` interview check, in which case the scan cannot report the gate at all. Say so
explicitly rather than reporting a pass the scan never performed, verify the binding by reading its
frontmatter, and note that updating the hub's scan script is an adoption act under that hub's own
governance, not something this skill does behind the owner's back.

---

## Step 7 — Report to user

Restate the **competency questions** the hub was created to answer, and note that
`/km-start` will re-check them. They are the hub's reason to exist; the owner should
see them again at the moment the hub is handed over.


Report:
- Hub created at (or adopted at): `<target-path>`, and which mode ran
- Files created: list them. In adopt mode list **only** what was added, and state explicitly what
  was left untouched
- Agent minted: `.claude/agents/<AGENT_NAME>.md`
- Deployment state: `canonical` (create mode), or the state preserved from the existing binding
- Which quarantines cleared: the hub's own `[ DEPLOYMENT ]` gate, and the estate registry gate where
  a supervisor tier exists. Name any that did not clear, and why
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

**Name what reconciliation finds, out loud.** When seeding surfaces contradictions in the
owner's own material — two prices for one product, two dates for one decision — that finding is
the clearest early evidence the system does something: say so to the owner (or the customer)
explicitly, during onboarding, rather than resolving it quietly. Reconciliation is a selling
point, not only a control.

**Bulk corpora (directional, run once — not yet a normative pattern).** When the seed is not a
handful of named documents but a large corpus (thousands of files), the proven shape so far is:
catalogue without opening restricted material → agree the knowledge-vs-records boundary with
the owner (the Round 4 interview, applied to the corpus) → split by domain → parallel readers,
each briefed with that boundary and a per-reader confidentiality brief → one extract per domain
→ then the entity layer. Treat this as guidance to adapt, not procedure to follow; a second run
is what turns it into one.
