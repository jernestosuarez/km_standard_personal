# Adopting the KM Standard

The KM Standard gives a team a governed knowledge hub made from ordinary Markdown files and Git.
It is designed for knowledge that must remain understandable to people, usable by AI assistants,
portable between tools, and auditable over time.

## Is it a good fit?

Adopt it when a project needs retained evidence, explicit decisions, visible provenance, and a
repeatable way to turn incoming material into reviewed knowledge. It is especially useful when the
same body of knowledge must support both human work and AI-assisted workflows without making an AI
vendor or knowledge platform the system of record.

The Standard does not replace the systems that own source records. Those records stay in their
systems of record. The hub retains governed evidence, claims, decisions, and working knowledge,
with links back to authoritative sources.

## Initialize one hub

1. Read the purpose and governance sections of [`../STANDARD.md`](../STANDARD.md).
2. Copy [`../template/`](../template/) into the initiative workspace, or use
   [`km-init`](../skills/km-init/SKILL.md) with an assistant that supports skills.
3. Replace the placeholders and record the inherited Standard version and source in
   `km-deployment.md`.
4. Initialize Git, commit the scaffold, and run `hub-scan.sh`.
5. Add material through `_inbox/`, review proposals in `changes/`, and stage later changes by exact
   path.

The scaffold commit is the one point at which adding the whole new hub is expected. After that,
follow the Standard's explicit-staging rule.

## Work with the hub

At the start of a session, run the hub scan and read the handover. Intake files are digested and
filed; changes to governed knowledge are proposed before they are accepted. Decisions, risks,
stakeholders, milestones, partners, corrections, relationships, claims, and source systems have
their own entity-note homes instead of being hidden in summary tables.

AI assistance is optional. The shipped skills automate mechanical steps, but the Markdown and Git
workflow remains usable without them.

## When to add a Supervisor

One hub does not need a Supervisor tier. Add the minimum Supervisor tier when the workspace runs
more than one hub or a source must be routed across hub boundaries. Start with the registry, estate
queue, inbox, and Git history described in the Standard; add more capability only against a named
need. See [`km-supervise`](../skills/km-supervise/SKILL.md).

## Know what you adopted

This repository is the **Glassity Edition - based on KM Standard v1.64**. The inherited normative
baseline is v1.64. Repository presentation and guidance do not change that baseline. A future
Glassity version should identify an accepted substantive divergence explicitly; adopting that later
version would be a decision, not a background update.
