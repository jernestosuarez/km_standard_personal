---
title: Glassity record authority matrix contract
description: Normative closed record-authority boundary for Glassity foundation contracts.
tags: [glassity, contracts, authority]
---

# Glassity record authority matrix contract

## Purpose

The authority matrix fixes which system is authoritative for every v1 data class and what, if anything, may be represented in a tenant hub. It is a closed set: adding a class, removing a class, or changing a mapping requires a governed amendment to this contract. Producers cannot extend the matrix in an envelope or deployment binding.

## Normative authority table

| Data class | System of record | Permitted tenant-hub representation |
|---|---|---|
| `raw_upload` | `object_storage` | content-addressed `pointer` only |
| `app_object` | `application_database` | `pointer`, `digest`, `claim`, or `decision` |
| `app_event` | `event_store` | `pointer`, `digest`, `claim`, or `decision` |
| `digest` | `tenant_hub` | `governed_digest` |
| `claim` | `tenant_hub` | `governed_claim` |
| `decision` | `tenant_hub` | `governed_decision` |
| `classified_extract` | `tenant_hub` | `classified_text_extract` |
| `pointer` | `tenant_hub` | `resolvable_pointer` |
| `owner_queue` | `tenant_hub` | `governed_queue_record` |
| `execution_record` | `tenant_hub` | `governed_execution_record` |
| `pending_answer` | `pending_answer_store` | `none_until_pull` |
| `audit_event` | `audit_store` | `non_content_evidence_pointer` |

`pending_answer` remains outside the governed record until the core `pull` behavior consumes it. `raw_upload`, `app_object`, `app_event`, and `pending_answer` must never name the tenant hub as their system of record.

Every row also declares one or more producer roles, envelope types, classification-policy references, a retention-policy reference, and forbidden locations. Producer roles are limited to `inbound_adapter`, `core_intake`, `cockpit`, `worker`, and `audit_service`. Envelope types are limited to `upload_pointer`, `domain_event`, and the explicit non-envelope value `none`.

## Validation

The Draft 2020-12 schema validates the closed document and row shapes. The semantic validator independently requires exactly one row for every class in the normative table and compares the system-of-record and permitted-representation mappings exactly. This separation gives closed-set failures stable contract reasons rather than schema-engine-dependent messages.

- A missing class is `AUTHORITY_SET_INCOMPLETE`.
- An unknown class or duplicate class occurrence is `AUTHORITY_SET_UNKNOWN`.
- A changed system of record or permitted representation set is `AUTHORITY_SYSTEM_MISMATCH`.

Order is not authoritative. A representation array is compared as a set, but duplicates within scalar arrays are schema-invalid. A new class or mapping is never accepted as a compatible extension; it first requires a governed amendment to the contract, schema, fixture, validator constant, and canaries.
