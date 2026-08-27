# Maintaining the Glassity Edition

Maintaining this repository is different from operating a knowledge hub. A hub applies the
Standard. A Standard maintainer changes the package that hubs may later choose to adopt.

## Authority and records

- [`../STANDARD.md`](../STANDARD.md) is normative.
- [`../rfcs/`](../rfcs/README.md) holds dated design records. An RFC is not rewritten to make its
  original prediction agree with later implementation.
- [`../openspec/`](../openspec/) holds governed proposals and implementation evidence.
- [`../CHANGELOG.md`](../CHANGELOG.md) identifies the Glassity baseline and future edition releases.

Guides and diagrams are descriptive. If they conflict with the Standard, the Standard governs and
the descriptive surface must be corrected.

## Change discipline

1. State the proposed behavioral change and its authority before editing normative material.
2. For a defect, reproduce it on the unrepaired tree and commit the failing case before the repair.
3. Make the smallest change that satisfies the accepted proposal.
4. Stage exact paths. Do not use blanket staging in a populated working tree.
5. Run the authoritative release gate directly and record its exit status.
6. Preserve evidence, including negative or inconclusive results, in the change record.

The authoritative command is:

```bash
python3 tools/km-release-gate.py
```

A cached task, piped command, partial suite, duration, or hosted-job label is not a substitute for
the direct gate verdict. Exit `0` is pass, `1` is fail, and `2` is refused. Neither fail nor refused
may be reported as green.

## Editions and releases

This fork currently inherits KM Standard v1.64 without a Glassity-specific normative divergence.
Do not assign a Glassity version merely for documentation, branding, or repository maintenance.
When Glassity accepts a substantive change, update the normative record, evidence, changelog, badge,
and release identity together. A published version number is never reused.

## Before publication

Confirm that the working tree is stable throughout the gate, all new or changed checks carry the
required unrepaired-tree declaration, relative links resolve, the edition boundary is explicit,
and no organization-specific material has leaked into the vendor-neutral Standard surface.
