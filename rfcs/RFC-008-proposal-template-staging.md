---
type: architecture
title: RFC-008 — The proposal template's staging discipline, and two hub-local practices seeking a canonical home
description: Design record for grafting the blanket-add prohibition into the shipped proposal template, ruling on the homeless hub-local practices a deployment's parity wave preserved, and replacing a token-absence acceptance criterion with a presence-measuring check.
tags: [rfc, proposal-template, staging, governance, checks]
timestamp: 2026-08-27
---

# RFC-008 — The proposal template's staging discipline

**Status: DRAFT — normative edits ride v1.64, which is drafted and unpublished.** This document
is a dated design record: it states what was designed, on what authority, with what evidence, on
the day it was written. Disposition lives in [`rfcs/README.md`](README.md), never here.

**Status addendum 2026-08-27: adopted by v1.64, published 2026-08-27 (owner push).** The
paragraph above is the statement of the day this record was written and is left standing, per
this repository's correction pattern for implemented RFCs; the disposition of record is the
index row in [`rfcs/README.md`](README.md).

**Authority:** the deployment owner's direction of 2026-08-27 that the whole canonical backlog
raised by the reference deployment be cleared before a planned fork. The originating registration
is that deployment's standard-tier ledger item of 2026-08-24 (genericised here; no deployment
name, hub, or person is carried).

## The evidence

A reference deployment's estate rule — every commit stages an enumerated set of paths, never a
blanket add, because its tree is cloud-synced and a blanket add resurrects deliberately deleted
governance files — was already canonical doctrine: this standard has carried it as Rule 3, *Stage
explicitly*, since v1.10. What was **not** canonical was the restatement at the point of use. The
shipped proposal template's post-apply steps said *"staging each touched path by name"* and
stopped; the prohibition, and the reason a blanket add is dangerous in synced storage, lived two
thousand lines away in the standard the applying agent is not reading at the moment of the act.

So the deployment's hubs each grew their own local sentence. Measured across the eleven hubs of
that deployment on 2026-08-24: **five differing wordings** of the same prohibition, added by
separate local edits during a parity wave that brought each hub's template to the then-current
canonical shape *"with hub-local steps preserved"*. Eleven local edits of one rule is the
contradiction that raised this RFC: the same obligation, worded five ways, each threatened by the
next template refresh, none of them the canonical text — the exact class §"One canonical copy"
names for skills, met in a governance template.

The same registration carried a second finding, about the **acceptance criterion** used to verify
the wave: the criterion was *"grep finds no blanket-add token in the template"*, and a template
with **no staging step at all** satisfies it perfectly. One hub passed the wave on that criterion
while being the hub that most needed the fix. This is v1.61's rule — *a control whose claim is an
absence must measure an absence* — demonstrated in a conformance criterion rather than an
instrument.

## The three questions, and the design

### 1. The blanket-add prohibition: canonical home is the template's post-apply steps

One sentence is grafted into the shipped `template/changes/PROPOSAL_TEMPLATE.md`, immediately
after the explicit-path staging step it governs, and into the standard's own quoted copy of the
template. The sentence names the act and the mechanism (a deletion in synchronized storage is not
durable; an all-changes add resurrects the files the apply just deleted) and points at Rule 3 as
the home of record. It deliberately does **not** restate Rule 3's full doctrine: the template
carries the one sentence an applying agent needs at the moment of staging, and the standard keeps
the reasoning, so the two cannot drift into two doctrines.

Genericisation note: the deployment wordings named their specific sync product and a pre-commit
guard the canonical template does not ship. The canonical sentence says "synchronized storage"
and claims no guard, because the standard ships none at the hub's commit step; a deployment
that installs one may say so in its own copy under its own governance.

### 2. The manifest-recompute step: no canonical home, and that is a ruling, not an omission

The second homeless practice was a post-apply step — *"Recompute `hub-manifest.md`"* — present in
five of the deployment's hub templates. It seeks no home because its subject is retired:
**v1.63's ruling** (Rule 3, *A hand-maintained integrity manifest is retired*) makes git history
the sole integrity baseline and forbids building any check against a hand-maintained manifest.
A canonical home for the recompute step would re-institutionalise the artifact the ruling
retired, one version later.

Adoption action for a deployed hub: when its proposal template is refreshed from canonical, the
recompute step is **dropped**, in the same act and under the same governance as the manifest's
own removal.

### 3. The acceptance criterion becomes a shipped check that measures presence

`tests/test_proposal_template_staging.sh` holds the shipped template to three findings, each
named: the explicit-path staging step is **present**; the blanket-add prohibition is **present**;
and no blanket-add instruction is present — the absence measured only alongside the presences
that make it meaningful, so a template with no staging step at all can never pass. Both
directions are proved on fixtures, the check refuses rather than passes on a template it cannot
read, and it was run red against the unrepaired tree before the repair was written.

One trade surfaced while writing it, and it is recorded in the check's own header: the absence
arm reads any literal blanket-add token as an instruction, so the prohibition sentence itself
must not quote the token (the v1.55 rule that a quotation is not a directive, met from the other
side — here the quotation would have been read as one). The template names the act; Rule 3 holds
the literal forms.

## What this deliberately does not do

- It adds no new normative rule to the standard: Rule 3 already holds the doctrine, and v1.61
  already holds the absence-measurement rule. This RFC's edits are a restatement at the point of
  use, a ruling of no-home for a retired practice, and one check.
- It does not touch the approval template, the apply flow, or any hub's local template: deployed
  copies converge on the canonical wording by each hub's own refresh, under its own governance.
- It does not mechanise detection of blanket adds at commit time. A pre-commit guard is
  deployment machinery; the standard states the rule and ships the template-side check.
