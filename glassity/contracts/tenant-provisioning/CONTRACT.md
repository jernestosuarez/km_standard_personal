---
title: Glassity tenant provisioning contract
description: Normative tenant binding, erasure-map, receipt, and inbound-envelope boundary.
tags: [glassity, contracts, provisioning]
---

# Glassity tenant provisioning contract

## Deployment binding

Every tenant deployment has one versioned binding. It pins the canonical Standard commit and approved Glassity overlay, refers to rather than embeds the operator profile and tenant policies, identifies the repository and approved refs without a credential-bearing URL, fixes the operational region, and records lifecycle evidence.

The lifecycle vocabulary is exactly `active`, `frozen`, `deletion_executing`, `completion_pending`, and `complete`. A legal hold is a separate scoped marker, not a lifecycle state. It may coexist with any lifecycle value and never restores or weakens access prohibited by that lifecycle.

## Per-tenant erasure map

Every binding embeds a complete erasure map. The required categories are `iam_session`, `worker_transient`, `pending_answer_queue`, `app_database_event`, `derived_projection_index`, `s3_object_version`, `github_repository`, `backup_recovery`, `scan_event_finding`, `audit_log`, `anthropic_control_plane`, `export_staging`, and `tenant_secret`.

Each entry identifies its data classes, owning system, tenant/source/lineage selectors, primary or derived locations, freeze control, deletion mechanism and start bound, provider or backup expiry, verification query, restore-time deletion-ledger behavior, non-content evidence, and scoped legal-hold behavior. Missing, duplicate, or unknown categories make the map incomplete. The embedded map must carry the binding's tenant and deployment identities.

## Provisioning receipt

The provisioning receipt records the declared two-commit sequence: core `km-init` creates the complete canonical hub, then the Glassity provisioner applies the deployment binding and approved overlay. Its `overlay_parent_commit` must equal its `canonical_initialization_commit`; its tenant, deployment, canonical pin, and overlay revision must match the binding; and its binding and embedded erasure-map digests are recomputed rather than trusted.

This is a **declared parent relationship**, not evidence that either commit exists or that one commit is an ancestor of the other. The validator never shells out to Git and does not inspect repository objects, trees, attribution, or signatures. Actual Git ancestry and commit contents remain later conformance work.

This contract defines specification artifacts only. It does not provision a tenant, operate a repository, execute deletion, or prove runtime isolation or erasure conformance.
