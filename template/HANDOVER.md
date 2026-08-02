---
type: handover
title: Session Handover — {{PROJECT_NAME}} Knowledge Hub
description: Continuity document for agents resuming work on this hub.
tags: [handover, governance, continuity]
resource: ./
timestamp: {{INIT_DATE}}
---

# Session Handover — {{PROJECT_NAME}} Knowledge Hub

**Read this first.** Then read the active agent instructions ([CLAUDE.md](CLAUDE.md) for Claude Code
or [AGENTS.md](AGENTS.md) for Codex) and [README.md](README.md) (hub index).

---

## 1. What this hub is

{{DESCRIPTION}}

**Hub owner:** {{HUB_OWNER}}
**Institutional voice:** authoritative, concise — this hub is a team deliverable, not a personal one.

---

## 2. Hub structure

```
{{PROJECT_SLUG}}/
├── CLAUDE.md / AGENTS.md         working rules + intake workflow
├── HANDOVER.md                   ← you are here
├── README.md                     hub index + skill routing
├── hub-scan.sh                   session-start scan (git-backed integrity)
├── 01_project-brief.md
├── 02_context-scope.md
├── 03_roadmap-milestones.md
├── 04_stakeholders.md
├── 05_partnerships-pipeline.md
├── 06_risks-decisions.md
├── 07_glossary.md
├── _inbox/                       everything lands here first
├── changes/                      proposals + approvals
├── reconciliation/               adjudicated fact ledger
│   └── _disputes/                active disputes, each naming who it is blocked on
├── sources/
│   └── transcript-index.md       provenance index
├── working-docs/                 team-authored outputs
├── shareable/                    sanitised docs for external sharing
└── assets/architecture/          diagrams and visual assets
```

---

## 3. Scope

**In scope:** {{SCOPE_IN}}

**Out of scope:** {{SCOPE_OUT}}

If a fact is borderline, ask {{HUB_OWNER}}.

---

## 4. Conventions

- **Session start:** always run `bash hub-scan.sh` before doing anything else
- **Hub docs (01–07+):** edit only after an approved proposal or explicit real-time confirmation from {{HUB_OWNER}}
- **Committed vs vision:** never promote aspirational content into the roadmap without explicit hub owner approval
- **Reconciliation:** settled facts in `reconciliation/*.md` topic files, excluding `README.md`, are the ground truth — flag contradictions, never silently overwrite
- **End of session:** update section 5 below via `/km-handover` so the next agent picks up cleanly

Full rules: read the active agent instructions for your tool surface.

---

## 5. Current state & open items

> _Updated by the agent at the end of each session via `/km-handover`. Replace this block entirely — do not append._

**As of {{INIT_DATE}} (hub initialised):**

- Hub created via `/km-init` — all template files in place, initial commit made
- No source files processed yet
- No open proposals
- No reconciliation disputes

**Next steps:**
1. Run `bash hub-scan.sh` — should be all-green
2. Edit `01_project-brief.md` with the initiative's actual brief
3. Drop the first source file in `_inbox/` and run `/km-intake`

---

## 6. Data sources

> _Describe where this hub's content comes from — meeting transcripts, shared drives, external databases, MCP servers, etc. Fill in after hub setup._

_[To be filled in by {{HUB_OWNER}} after hub setup]_
