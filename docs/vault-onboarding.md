# Onboarding a vault with `/km-vault-upgrade`

Operator guide: what merging the skill changes for deployments that already exist, how to update
them, and — the part that decides whether a run works at all — **which directory each command is
executed from**.

Descriptive guidance. Where this conflicts with [`../STANDARD.md`](../STANDARD.md), the Standard
governs.

---

## 1. What merging changes, and what it does not

Merging adds the skill to the **factory**. It changes **no deployment**. Nothing in `~/km` moves
until you do the two steps in §2 and §3.

The reason is a rule worth stating plainly, because it is the thing people get wrong:

> **A template is a mint-time artifact, not a live link.** Editing a template changes what the
> *next* hub or tier is minted from. It never reaches one already minted. Retrofitting an existing
> tier or hub is an explicit, owner-authorized act.

| Changed by this PR | Reaches automatically | An existing deployment must |
|---|---|---|
| `skills/km-vault-upgrade/` — the new canonical skill | nothing | create the symlink (§3) |
| `skills/km-supervise/_KM_Supervisor_template/README.md` — new "Workspace-level skills" section | **newly minted** Supervisor tiers only | copy the section into the live `_KM_Supervisor/README.md` (§2) |
| `tests/`, `openspec/`, `README.md` | factory only | nothing |
| `template/` — the reference hub | *untouched by this change* | **nothing. No hub needs any action.** |

Per-hub skills (`km-intake`, `km-gather`, `km-propose`, `km-start`, `km-handover`, `km-brief`,
`km-publish`) are a different class and are not affected: hubs receive them as copies from
`template/` at initiation, and the factory's parity suite governs those copies.

---

## 2. Update an existing Supervisor tier

Your live `_KM_Supervisor/README.md` was minted from the older template and does not carry the
"Workspace-level skills: linked, never copied" section. Add it.

The Supervisor tier's change rule is its own — **owner authorization in session plus a git commit
stating the reason**, no proposal ceremony:

```bash
cd ~/km/_KM_Supervisor
# copy the new section from the standard checkout's tier template:
#   <checkout>/skills/km-supervise/_KM_Supervisor_template/README.md
#   → the "## Workspace-level skills: linked, never copied" section
git add README.md
git commit -m "adopt: workspace-level skill deployment section (linked, never copied)"
```

Skip this only if you accept that a future session has no written rule telling it links are
required. The skill health-checks its own link either way (§6), but the tier README is where the
rule lives for *every* workspace-level skill, not just this one.

---

## 3. Deploy the skill — a symlink, never a copy

One canonical copy lives in the standard checkout. The estate points at it.

```bash
CHECKOUT="$HOME/home/Research/AI Harness/km_standard_glassity"   # your standard checkout
mkdir -p ~/km/.claude/skills
ln -sfn "$CHECKOUT/skills/km-vault-upgrade" ~/km/.claude/skills/km-vault-upgrade

# verify: must print a symlink whose target ends in /skills/km-vault-upgrade
ls -l ~/km/.claude/skills/km-vault-upgrade
test -L ~/km/.claude/skills/km-vault-upgrade && echo "OK: link" || echo "WRONG: not a link"
```

Do the same for the other workspace-level skills if they are not already linked:

```bash
for s in km-init km-supervise; do
  ln -sfn "$CHECKOUT/skills/$s" ~/km/.claude/skills/"$s"
done
```

**Why a link and not a copy.** A copied skill inside a deployed estate is the drift class this
standard has already measured — the one skill copy without a parity check was the one that
drifted — and no factory check reaches a copy sitting in `~/km`. A link keeps every session on the
checkout's governed text, and updating the skill becomes `git pull` in the checkout.

**If you find a real directory there instead of a link,** that is copy-deploy residue. Do not
delete it blindly: diff it against the canonical copy first, carry over anything that is genuinely
yours, then replace it with the link.

---

## 4. Where each command runs — ingest vs. distribute

This is the part to get right. **Two roots, and the proposal is the boundary between them.**

| Command | Run from | Why |
|---|---|---|
| `/km-vault-upgrade <vault-path>` | **workspace root** — `~/km` | Estate session. Reads `_KM_Supervisor/`, writes the catalogue and ledger there, dispatches into hubs |
| `/km-supervise` | **workspace root** — `~/km` | Estate tier; routes one source across several hubs |
| `/km-init` | **workspace root** — `~/km` | Hubs are created as children of the workspace root |
| `/km-gather` | **inside the receiving hub** — e.g. `~/km/glassity` | Writes a proposal into *that hub's* `changes/` |
| `/km-intake` | **inside the receiving hub** | Applies or rejects proposals from *that hub's* `changes/` |
| `/km-handover` | **inside the receiving hub** | Per-hub close-out |
| `hub-scan.sh`, `build-indexes.sh` | **inside the hub** | They derive the hub from their own location |

**Ingest** — catalogue, boundary interviews, batch planning, extraction routing, ledger writes —
is one estate session at `~/km`.

**Distribute** — proposal review, apply, crystallize, index, scan, handover — is one session
*per receiving hub*, rooted in that hub.

```
~/km                    ← /km-vault-upgrade runs HERE (ingest, orchestration)
├── .claude/skills/     ← symlinks to the standard checkout
├── _KM_Supervisor/     ← catalogue, campaign-ledger.json, QUEUE, registry
├── glassity/           ← /km-gather, /km-intake, /km-handover run HERE (distribute)
│   └── changes/        ← the boundary: estate writes proposals in, hub applies them
└── personal/           ← same, per hub
```

The estate session **writes proposals into** a hub's `changes/`. It never applies them. The hub's
own session does that, through the hub's own flow. Crossing that line is the one thing the skill's
governing principles forbid outright.

**Most common mistake:** running `/km-gather` from `~/km`. There is no hub there, so there is no
`changes/` to write to. `cd` into the receiving hub first.

---

## 5. Running a campaign

```bash
cd ~/km
/km-vault-upgrade ~/home            # the vault to onboard
```

**First run** registers the vault as a SourceSystem, then catalogues it mechanically. Expect to be
asked for rulings on the domain summary — exclusions, routes, quarantines — not per-file
questions.

**Every later run resumes.** The catalogue's `## Campaign state` table plus the ledger say where
each batch stands; a cold session reads them and continues. You never re-answer a settled ruling.

**The campaign holds on you in exactly three places** (per source content):

1. **Date gate** — mtime-only files, confirmed in bulk once per domain at batch planning.
2. **Boundary interview** — one per domain, before its first batch. An uninterviewed domain blocks
   its batch and surfaces as a `QUEUE.md` row rather than stalling silently.
3. **Proposal approval** — per domain, in the receiving hub.

Governance acts carry their own authorization where the steps state it: registration commits,
first-time ledger adoption, FLAG rulings on changed sources, source-of-record selection for
duplicate subtrees, and the confirmation after a `/km-supervise --dry-run`.

**Per batch, the loop is:** estate session extracts and dispatches one proposal per domain → you
review in the hub → hub session applies (exact-path staging, `KM-Agent:` trailer,
`build-indexes.sh`, `hub-scan.sh` green) → estate session writes ledger rows and updates campaign
state → next batch.

**Close** happens when every planned batch is applied: competency questions re-checked and flipped
N→Y only with a pointable fact, `/km-handover` per hub, ingestion rows cleared from `QUEUE.md`,
and any superseded hand-written plan retired (`lifecycle: retired`) pointing at the closing commit.

**Re-running against a changed vault is safe.** Sources whose content hash matches their ledger row
are skipped; changed ones are FLAGged for your ruling; new ones enter batch planning. Nothing is
re-proposed silently.

---

## 6. What the skill checks about itself

Step 0 of every run health-checks its own deployment before any campaign work: `.claude/skills/km-vault-upgrade`
must be a symlink into a standard checkout's `skills/` tree. Missing → it offers to create the
link as an owner-authorized act. A **copy** in its place → reported as drift risk with replacement
offered, never left silently. It reports the same for `km-init` and `km-supervise`.

So §3 is the one-time manual step; after that the skill keeps its own deployment honest, and a
newly minted Supervisor tier gets the links at mint time.

---

## 7. Where the campaign's files live

| Artifact | Path | Governed? |
|---|---|---|
| Catalogue | `~/km/_KM_Supervisor/_inbox/vault-catalogue-<date>.md` | yes — committed |
| Campaign ledger | `~/km/_KM_Supervisor/campaign-ledger.json` | yes — created only on explicit adoption |
| Campaign state | the catalogue's `## Campaign state` table | yes |
| Proposals | `<hub>/changes/` | yes — hub's own flow |
| Corrections from rejections | `<hub>/corrections/` | yes |
| Out-of-scope facts | `~/km/_KM_Supervisor/_unrouted/<theme>.md` | yes |
| Batch staging, dry-run tables, intermediates | `_scratch/` | no — git-ignored, declared lifetime |
| The source vault | wherever it is | **read-only. Never modified.** |

Formats for the ledger, catalogue, and campaign-state table are defined once, in
[`../skills/km-vault-upgrade/ledger-format.md`](../skills/km-vault-upgrade/ledger-format.md).

---

## 8. Related

- [`../skills/km-vault-upgrade/SKILL.md`](../skills/km-vault-upgrade/SKILL.md) — the skill itself
- [`../skills/km-vault-upgrade/ledger-format.md`](../skills/km-vault-upgrade/ledger-format.md) — ledger and catalogue contract
- [`adopting.md`](adopting.md) — adopting the Standard generally
- [`../STANDARD.md`](../STANDARD.md) — normative architecture
