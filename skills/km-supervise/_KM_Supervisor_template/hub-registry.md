---
type: index
title: Hub Registry — Supervisor
description: Map of every initiative folder in this workspace, its hub/repo/merged status, owner, and routing keywords.
tags: [supervisor, registry, index]
timestamp: {{INIT_DATE}}
---

# Hub Registry

Status values: `hub` (an initiated hub), `repo` (a plain folder, not yet a hub), and `merged` (a
tombstoned hub absorbed into another; added in v1.35). The `Merged into`
column is empty for `hub` and `repo` rows and names the survivor folder for a `merged` row. A
`merged` row stays in the registry rather than being deleted: a hub-shaped directory absent from the
registry is quarantined by the estate scan, and a tombstoned hub must report a tombstone, not a
quarantine.

| Folder | Status (hub/repo/merged) | Owner | Routing keywords | Merged into |
|---|---|---|---|---|
| | | | | |
