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
| `skills/km-supervise/_KM_Supervisor_template/` — "Estate-tier skills" section, plus new `CLAUDE.md` and `AGENTS.md` | **newly minted** Supervisor tiers only | copy all three into the live `_KM_Supervisor/` (§2) |
| `tests/`, `openspec/`, `README.md` | factory only | nothing |
| `template/` — the reference hub | *untouched by this change* | **nothing. No hub needs any action.** |

Per-hub skills (`km-intake`, `km-gather`, `km-propose`, `km-start`, `km-handover`, `km-brief`,
`km-publish`) are a different class and are not affected: hubs receive them as copies from
`template/` at initiation, and the factory's parity suite governs those copies.

---

## 2. Update an existing Supervisor tier

Your live `_KM_Supervisor/` was minted from an older template. It is missing three things: the
"Estate-tier skills" section in `README.md`, and the `CLAUDE.md`/`AGENTS.md` scope-guard pair that
makes the tier a properly constituted unit — the same shape every hub already has.

The Supervisor tier's change rule is its own — **owner authorization in session plus a git commit
stating the reason**, no proposal ceremony:

```bash
CHECKOUT="$HOME/home/Research/AI Harness/km_standard_glassity"   # your standard checkout
TPL="$CHECKOUT/skills/km-supervise/_KM_Supervisor_template"
cd ~/km/_KM_Supervisor

cp "$TPL/CLAUDE.md" "$TPL/AGENTS.md" .        # substitute {{INIT_DATE}} with today's date
# then copy the "## Estate-tier skills: linked here, never copied, never at the workspace root"
# section from "$TPL/README.md" into your own README.md

git add CLAUDE.md AGENTS.md README.md
git commit -m "adopt: tier scope guard and estate-tier skill deployment rule"
```

The `CLAUDE.md`/`AGENTS.md` pair declares the tier's **routing** scope — which hub owns what — not
an admission rule; a hub admits sources, this tier routes between them. Without it the tier is a
git repo with no scope statement, which is why the skill's link was originally put in the wrong
place: nothing at either level said where a governed unit begins.

---

## 3. Deploy the skill — a symlink inside the tier, never a copy

One canonical copy lives in the standard checkout. The **Supervisor tier** points at it.

```bash
CHECKOUT="$HOME/home/Research/AI Harness/km_standard_glassity"   # your standard checkout
TIER=~/km/_KM_Supervisor

mkdir -p "$TIER/.claude/skills"
ln -sfn "$CHECKOUT/skills/km-vault-upgrade" "$TIER/.claude/skills/km-vault-upgrade"

# and the AGENTS.md-surface mirror, if this estate runs one
mkdir -p "$TIER/.agents/skills"
ln -sfn "$CHECKOUT/skills/km-vault-upgrade" "$TIER/.agents/skills/km-vault-upgrade"

# verify: must print a symlink whose target ends in /skills/km-vault-upgrade
ls -l "$TIER/.claude/skills/km-vault-upgrade"
test -L "$TIER/.claude/skills/km-vault-upgrade" && echo "OK: link" || echo "WRONG: not a link"
```

Do the same for the other estate-tier skills if they are not already linked:

```bash
for s in km-init km-supervise; do
  ln -sfn "$CHECKOUT/skills/$s" "$TIER/.claude/skills/$s"
  ln -sfn "$CHECKOUT/skills/$s" "$TIER/.agents/skills/$s"
done
```

**Why inside the tier and not at `~/km`.** The tier is the estate's governed unit: a git
repository, with a change rule, holding estate state, and now carrying its own
`CLAUDE.md`/`AGENTS.md` — structurally the same shape as a hub, which is where every other skill
in this standard sits beside its scope guard. `~/km` is an ordinary folder, not a repository: a
`.claude/` there is untracked by anything, reached by no scan, and orphaned from any scope guard.

**Why a link and not a copy.** A copied skill inside a deployment is the drift class this standard
has already measured — the one skill copy without a parity check was the one that drifted — and no
factory check reaches a copy. A link keeps every session on the checkout's governed text, and
updating the skill becomes `git pull` in the checkout.

**If you find a real directory instead of a link,** that is copy-deploy residue. Do not delete it
blindly: diff it against the canonical copy first, carry over anything genuinely yours, then
replace it with the link. **If you find a link at `~/km/.claude/skills/`** — the location an
earlier revision of this guide named — move it into the tier and remove the orphaned `.claude/`.

---

## 4. Where each command runs — ingest vs. distribute

This is the part to get right. **Two roots, and the proposal is the boundary between them.**

| Command | Run from | Why |
|---|---|---|
| `/km-vault-upgrade <vault-path>` | **the tier** — `~/km/_KM_Supervisor` | Estate session. Its git repo; writes the catalogue and ledger here, dispatches into hubs at `../` |
| `/km-supervise` | **the tier** — `~/km/_KM_Supervisor` | Estate tier; routes one source across several hubs |
| `/km-init` | **workspace root** — `~/km` | The exception: it *creates* hubs (and the tier itself) as children of the workspace root |
| `/km-gather` | **inside the receiving hub** — e.g. `~/km/glassity` | Writes a proposal into *that hub's* `changes/` |
| `/km-intake` | **inside the receiving hub** | Applies or rejects proposals from *that hub's* `changes/` |
| `/km-handover` | **inside the receiving hub** | Per-hub close-out |
| `hub-scan.sh`, `build-indexes.sh` | **inside the hub** | They derive the hub from their own location |

**Ingest** — catalogue, boundary interviews, batch planning, extraction routing, ledger writes —
is one estate session in `~/km/_KM_Supervisor`.

**Distribute** — proposal review, apply, crystallize, index, scan, handover — is one session
*per receiving hub*, rooted in that hub.

```
~/km                      ← an ordinary folder: not a repo, nothing runs here
├── _KM_Supervisor/       ← /km-vault-upgrade and /km-supervise run HERE (ingest)
│   ├── CLAUDE.md  AGENTS.md      ← the tier's scope guard
│   ├── .claude/skills/   ← symlinks to the standard checkout
│   ├── .agents/skills/   ← the AGENTS.md-surface mirror
│   ├── hub-registry.md  QUEUE.md  campaign-ledger.json
│   └── _inbox/           ← the catalogue
├── glassity/             ← /km-gather, /km-intake, /km-handover run HERE (distribute)
│   └── changes/          ← the boundary: estate writes proposals in, hub applies them
└── personal/             ← same, per hub
```

From the tier, a hub is `../glassity/`. The estate session **writes proposals into** a hub's
`changes/` and never applies them; the hub's own session does that, through the hub's own flow.
Crossing that line is the one thing the skill's governing principles forbid outright.

**Most common mistake:** running `/km-gather` from `~/km` or from the tier. There is no hub at
either, so there is no `changes/` to write to. `cd` into the receiving hub first.

---

## 5. Running a campaign

```bash
cd ~/km/_KM_Supervisor
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
