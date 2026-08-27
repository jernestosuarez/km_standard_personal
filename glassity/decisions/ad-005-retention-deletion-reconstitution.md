---
type: architecture-decision
title: AD-005 — retention, offboarding deletion, and governed erasure
description: Selects the v1 data inventory, retention defaults, noticed offboarding, legal-hold boundary, extract reconstitution, provider-expiry tracking, and deletion proof.
tags: [glassity, security, architecture, retention, deletion, erasure, gdpr, ad-005]
resource: glassity/decisions/
timestamp: 2026-08-28
lifecycle: active
---

# AD-005 — retention, offboarding deletion, and governed erasure

## Status

**Approved by the accountable owner on 2026-08-28 as security-design input with conditional legal/privacy defaults.** This resolves AD-005 at the design layer only. It does not assert that an inventory, export, freeze, deletion worker, repository reconstitution tool, lifecycle rule, provider integration, notice, legal-hold register, verification job, or certificate exists. It does not approve production persistence, a data-processing agreement, legal basis, customer terms, runtime implementation, release, or residual risk.

Glassity acts as a processor for customer-vault content under the design assumption approved here, and the customer supplies controller instructions. That role allocation, the 30-day return window, operational-audit period, certificate period, subprocessor terms, and any statutory exceptions remain conditional until the accountable legal/privacy authority reviews them and the customer agreement and data-processing agreement adopt them. The external-review queue discipline already used by the estate must carry this review; the existing queue record does not itself prove that a privacy or DPA review occurred.

## Decision in plain terms

At service end, Glassity immediately terminates the tenant's app, worker, queue, and credential access and freezes every store in the tenant's erasure map. The controller receives recorded notice of a conditional 30-day return-or-delete window and a recorded reminder seven days before it expires; absent another controller instruction, deletion starts on day 30.

Deletion is not complete when a row, object, session, or repository first disappears. The case remains **completion pending** until every mapped primary, derived, versioned, backup, log, and provider path has reached its verified expiry, including GitHub's 90-day repository-recovery window; only then is the final non-content deletion certificate dated.

## Authority and legally conditional defaults

The authenticated controller may instruct **return then delete**, **delete now**, or a legally required scoped hold. A prompt, uploaded document, model output, tenant user without the contractual role, support request, or ordinary application API cannot create, alter, or cancel an instruction.

| Policy point | Conditional v1 default | Authority and consequence |
|---|---|---|
| No-instruction offboarding | 30 calendar days frozen for return, then deletion starts | Accountable owner approved as an engineering default; legal/privacy and the DPA may shorten, remove, or replace it. |
| First notice | At service end (`D0`) | Must name the freeze, options, deadline, affected tenant, and evidence/correlation ID. |
| Reminder notice | `D+23`, seven days before automatic deletion starts | Automatic deletion cannot execute without evidence of both notices. Missing evidence keeps data frozen, raises an owner/legal alert, and requires a recorded correction; it never restores access or processing. |
| Return instruction | Encrypted export made available within 10 business days; deletion starts after confirmed delivery or expiry of the delivery window | The DPA may set another service level. Glassity's export staging expires after seven days and is deleted within 24 hours of receipt or expiry. |
| Immediate deletion instruction | Deletion execution starts within 24 hours | Provider and backup windows still control verified completion. |
| Tenant-linked operational audit | Maximum 90 days after deletion starts, plus provider purge latency | Conditional privacy/security balance; the final agreement may change it. Restricted payloads are never permitted in audit. |
| Final deletion certificate | Conditional six-year retention, non-content only | Legal/privacy must confirm or replace this period. The certificate cannot contain customer content, extracts, paths, prompts, answers, or provider tokens. |

If a controller or applicable law requires a deadline shorter than a selected provider can prove, the provider architecture must change through a governed amendment before Glassity accepts that commitment. A contractual promise cannot make GitHub's recovery window, a backup recovery point, or a subprocessor lifecycle cease to exist.

## Required tenant data inventory and erasure map

No tenant may enter production until a machine-readable erasure map covers every store and derived representation. Each entry names:

- data class and owning system;
- tenant, object, source, and lineage identifiers used to find every copy;
- primary, version, replica, projection, cache, index, embedding, queue, log, export, backup, mirror, and provider path;
- controller/processor role and subprocessor, if any;
- freeze control and authorized deletion mechanism;
- deletion-start deadline, provider/backup expiry, and verification query;
- restoration behavior and mandatory replay of the deletion ledger;
- evidence produced without preserving the deleted content; and
- legal-hold behavior, authority, review date, and resumption rule.

The map is a release control, not documentation written after a request arrives. Adding a vector index, knowledge graph, search service, analytics export, Git mirror, provider feature, EventBridge archive, log sink, backup copy, or new model data path fails closed until its map entry and deletion proof exist. An erasure that cleans Git but leaves an embedding, projection, event payload, clone, or restored backup is a failed erasure.

## Whole-tenant offboarding state machine

1. **Active → frozen (`D0`).** Revoke human sessions, memberships, tenant routes, worker scheduling, pending-answer pickup, broker leases, Git publication, upload capabilities, queue consumers, API keys, and tenant-specific exports. Stop all tenant processing except the governed return, deletion, legal-hold, and verification procedures. Record the first notice.
2. **Frozen return window (`D0`–`D+30`).** Every mapped primary and derived store is inaccessible and read-only outside the privileged procedure. No worker, ordinary operator, retry queue, scheduled job, projection builder, model call, or customer application path may read or change it. Record the day-23 reminder.
3. **Deletion executing.** Begin within 24 hours of a delete-now instruction, confirmed return, expired export delivery, or the day-30 default. Record each store's request, provider acknowledgement, verification result, exception, retry, and expected final date.
4. **Completion pending.** Primary access is gone, but at least one provider recovery, backup, log, version, finding, mirror, or legal-hold clock remains. The case shows every pending store and `pending_until` date; it cannot display “deleted” or issue the final certificate.
5. **Complete.** A scheduled verifier actually runs at or after the latest pending date, repeats every map query, confirms that no unapproved copy or recoverable path remains, and records the non-content final certificate. A missed, failed, or ambiguous check remains pending and alerts; elapsed time alone never completes a case.

Whole-tenant GitHub deletion inherits the same 90-day caveat as extract erasure: the repository may disappear from ordinary access immediately but the case remains pending while GitHub permits restoration.

## Engineering defaults by store

Deadlines below run from **deletion start**, not from service end. They are maximum engineering bounds unless a shorter controller/DPA instruction applies.

| Store or path | Execution default | Verified completion rule |
|---|---|---|
| Human IAM, tenant memberships, `tenant_sessions`, API routes | Revoke at `D0`; delete tenant bindings within 24 hours of deletion start | No valid session, membership, route, refresh path, or server binding can resolve the tenant. |
| Worker runs, sandboxes, transient files, broker staging and leases | Stop at `D0`; sweep within one hour; normal per-run cleanup also occurs within one hour of terminal state | No pod, process, volume, staging object, lease, provider token, or scheduled retry remains. These paths have no backup. |
| Pending answers, delivery queues, dead-letter queues and idempotency state | Freeze at `D0`; purge within 24 hours of deletion start | Zero live, delayed, retryable, acknowledged, or dead-letter item resolves to the tenant; consumers cannot recreate one. |
| App database objects, domain events, tenant-session data and source pointers | Freeze at `D0`; delete tenant partitions/rows or reconstitute content-bearing event partitions within seven days | Production-role and administrative verification return zero customer content and zero live pointer; only the non-content deletion record remains. |
| Projections, reading surfaces, caches, search, analytics, embeddings and future knowledge graph | Freeze invalidation at `D0`; delete and rebuild from the surviving source set within seven days | Independent lineage queries find no excluded or tenant content, and a canary proves a missed derived store fails the case. |
| S3 quarantine and clean objects, tags, current/noncurrent versions and delete markers | Issue explicit version-ID deletion within 24 hours; use a seven-day lifecycle rule only as a safety net | `ListObjectVersions` and inventory evidence show zero tenant version and delete marker in both buckets. A delete marker alone is failure. Completion is no later than seven days absent a documented provider incident. |
| Private tenant GitHub repository, refs and history | Disable through the broker and submit repository deletion within 24 hours; forks and unmanaged mirrors are prohibited | Repository and installation mapping are inaccessible, no fork/mirror exists, and a verifier after the provider's 90-day recovery window confirms it is not listed as restorable. |
| Supabase/PostgreSQL and AWS recovery points, PITR, snapshots and exported backups | Register the deletion in a restore-before-release ledger; configure every tenant-bearing recovery path to expire within 35 days; unmanaged dumps are prohibited | Provider inventories show no recovery point beyond the bound and no `EXPIRED`, failed, locked, copied, or orphaned recovery point remains. Every restore replays the deletion ledger before network or user access. |
| GuardDuty S3 scan tags, EventBridge results, findings and exports | Tags disappear with all S3 versions; do not create an indefinite EventBridge archive or finding export by default; delete any mapped export within seven days | Event/result archives and exports return zero tenant record. If GuardDuty generated a finding, completion remains pending for its 90-day provider retention unless a verified earlier deletion is available. |
| CloudWatch/application/security audit | Never log restricted payloads; remove tenant-linked events at the conditional 90-day maximum and retain the lower setting through provider purge | Query returns zero tenant-linked event after CloudWatch's documented purge latency, normally up to 72 hours. A legal hold may retain only named events. |
| Anthropic Managed Agents control plane | Delete each session within one hour of terminal run; at offboarding enumerate and delete all tenant sessions and independently scoped files, memories, vaults or other resources within 24 hours | Provider delete acknowledgements are recorded and list/get calls no longer return the resources. Session deletion alone is failure if an independently retained file or memory remains. Contractual provider exceptions are named, scoped, and pending rather than assumed away. |
| Return/export staging | Encrypt, bind to the controller's authorized recipient, make available for seven days, then delete within 24 hours of receipt or expiry | Staging object, versions, key, presigned access and delivery metadata are gone; the delivered customer copy is outside Glassity's stores and responsibility is stated in the handover. |
| Tenant-specific secrets or credentials | Revoke at `D0`; delete from Secrets Manager within 24 hours after no deletion job needs them; rotate any shared secret exposed during the procedure | Secret/version inventory and access tests prove no tenant credential works. Shared KMS and service keys remain only where they encrypt other active tenants and carry no tenant content themselves. |

Supabase's selected plan must keep database backup or PITR retention at or below the 35-day architecture maximum; its current documented daily-backup options are 7, 14, or up to 30 days. AWS backup plans, copies, vault locks, access points, and cross-region/cross-account recovery points must fit the same bound or be rejected before production.

## Individual-extract erasure by repository reconstitution

Ordinary correction, supersession, withdrawal, or governance disagreement uses the Standard's tombstone and append-only record. A tombstone is not erasure and is never described as one.

Legally compelled erasure is supported as a rare, expensive, governed procedure—not an end-user or ordinary application API:

1. Receive an authenticated, recorded controller instruction naming the lawful scope. The accountable owner approves execution. A named executor and a different named verifier receive time-bounded privileged access under the AD-004 discipline.
2. Freeze the tenant hub, broker publication, worker runs, queues, projections, and every mapped derivative. Create a restricted exclusion manifest from stable source/content/lineage identifiers; the final certificate retains only its digest and non-content counts.
3. Construct a new private repository deterministically by replaying every reachable approved ref and commit under one versioned transformation. Remove only the instructed content and derived content; add non-content tombstones where governance requires them. Preserve all unaffected file bytes, modes, authorship, timestamps, messages, parent topology, and refs. Affected commit IDs necessarily change, so produce a complete old-to-new commit map in restricted transient evidence.
4. Run an independent verifier that recomputes the transformation and proves, commit by commit and ref by ref, that every tree differs only by the approved exclusion and non-content tombstone rule. It checks commit/ref counts, parent mapping, modes, metadata, and absence of the excluded bytes, identifiers, paths, and derived values. Any unexplained difference aborts the switch.
5. Under a serialized privileged change, disable the old repository, bind the broker to the verified replacement repository, run read/write canaries, and only then restore governed operation. Delete the old repository and all transient maps, bundles, clones, staging, and credentials.
6. Execute the same exclusion across the entire erasure map: app rows/events, pending answers, projections, reading surfaces, indexes, embeddings/graphs, exports, scan/audit data where applicable, mirrors, and backups. Register the deletion in the restore-before-release ledger.
7. Record **erasure executed, completion pending until `<date>`** with one pending date per store. At every expiry, a scheduled check actually runs. The final non-content certificate is issued only when the old GitHub repository has passed its 90-day recovery window and every other mapped path is verified absent or is a valid, scoped legal-hold exception.

In-place history rewriting is rejected. It is difficult to prove against hidden refs, caches, clones, and provider recovery paths and makes the same repository appear clean while old objects may remain. Reconstitution gives the verifier two immutable candidates and a deterministic transformation to compare.

## Legal hold: the only retention override

A hold exists only where applicable law requires retention. A controller instruction invoking a hold must identify that legal requirement. The hold must name the issuing authority, legal basis, exact tenant/data/store scope, start time, access policy, reason deletion cannot proceed, and a mandatory review date no more than 90 days away. It is approved by the accountable owner with legal/privacy authority.

The hold suspends deletion only for the named data. Everything outside its scope follows the normal clocks; “hold tenant” or “keep everything in case” is invalid. Held data remains inaccessible to the app, worker, model, analytics, search, export, and ordinary operators and is processed only as the stated law permits. Every review renews, narrows, or ends the hold in writing. When it ends, deletion resumes from the paused store and the pending dates are recalculated.

## Evidence and certificate contract

The procedure maintains a non-content case record from instruction through completion. It includes controller instruction and authentication evidence, owner approval, named executor/verifier, both offboarding notices and delivery evidence, erasure-map version, transformation/tool version, store requests and acknowledgements, expected and actual expiry dates, verification queries and outcomes, exceptions/holds, retries, and evidence digests.

The case record can say `frozen`, `deletion_executing`, `completion_pending`, `legal_hold_scoped`, or `complete`. It cannot say “deleted” as a synonym for request accepted, row hidden, object delete marker created, repository inaccessible, session archived, backup disassociated, or time elapsed.

The final certificate is dated only after the latest successful verification. It names what ceased to exist, where, the instruction and procedure identifiers, actual completion time per store, scoped lawful exceptions, verifier identity, and evidence digests. It contains no deleted content or reversible locator. Certificate retention is itself mapped and follows the conditional period approved above.

## Required proof

VER-016 and the future deletion contract require at least:

- a complete-store canary that fails when any primary, version, queue, projection, embedding/index, log, export, mirror, backup, provider file, memory, or session is omitted from the erasure map;
- day-zero tests proving app, worker, queue, upload, broker, model and customer access are terminal while export/deletion access remains separately governed;
- notice tests proving the day-zero and day-23 evidence exist and that missing evidence blocks automatic execution and alerts without reopening the tenant;
- S3 cases proving current versions, noncurrent versions and delete markers are all enumerated and permanently removed;
- backup/PITR restore tests proving the deletion ledger runs before restored data can serve traffic and that failed, locked, copied, orphaned, or expired recovery points keep the case pending;
- whole-repository deletion evidence through GitHub's 90-day recovery window and an expiry check that runs rather than infers;
- deterministic reconstitution fixtures with one excluded extract and multiple unaffected commits/refs, proving only allowed tree changes, complete old/new mapping, independent verification, atomic broker switch, and old-repository deletion;
- mutation canaries that alter an unrelated file, metadata field, parent, ref, projection, embedding, or event and force reconstitution verification to fail;
- Anthropic cases proving session, produced files, uploaded files, memory/vault resources and abnormal-run remnants are independently enumerated and deleted;
- GuardDuty/EventBridge/CloudWatch cases proving no indefinite archive exists, provider findings and purge latency remain pending, and exported results are mapped;
- scoped legal-hold cases proving unrelated data still deletes, review expiry alerts, access remains denied, and deletion resumes when the hold ends; and
- certificate tests proving no completion while any pending date, failed query, missing notice, unknown store, restore path, provider exception, or legal-hold review is unresolved.

## Alternatives considered

### Tombstones as erasure

Rejected. Tombstones preserve the fact and history of a governed change; they do not remove the original bytes from Git history, derived stores, or backups and cannot satisfy a controller deletion instruction.

### Declare individual-extract erasure unsupported

Rejected. Customer vaults inevitably contain personal data, and no intake classifier can guarantee that an extract will never become subject to a lawful deletion instruction. A processor without an erasure path cannot honestly make the required commitment.

### Rewrite history in place

Rejected. Hidden refs, provider caches/recovery, clones, and non-obvious Git objects make an in-place “clean” result difficult to prove. Deterministic replacement-repository construction provides an explicit before/after oracle.

### Delete immediately without a return window

Not selected as the no-instruction default. It removes the controller's Article 28 return choice. A controller may still instruct immediate deletion, and the DPA may replace the conditional 30-day window.

### Retain until someone decides

Rejected. It invents indefinite retention and converts a missing instruction or notice failure into permanent storage. The data stays frozen only for the governed window or a narrow lawful hold.

## Consequences and gates

- AD-001 through AD-005 are complete at the security-design layer. No control is thereby implemented, and VER-001 through VER-016 remain release evidence rather than design claims.
- Production persistence remains blocked until legal/privacy confirms or replaces the conditional periods, controller/processor roles, notices, subprocessor deletion terms, lawful exceptions, and certificate retention in the customer agreement and DPA.
- Future app, database/event, upload, worker, Git broker, audit, backup, model-provider, knowledge-graph/index, export, offboarding, and incident contracts must implement the erasure map and state machine before production.
- Provider terms and plan settings must be verified before onboarding. GitHub's 90-day recovery window and any other subprocessor limit must be disclosed; a shorter customer promise forces an architecture change.
- The accountable commercial owner must receive AD-001's operational cost, AD-004's GitHub residency consequence, and AD-005's conditional retention/deletion consequences together before v1 scope, pricing, or customer commitments are approved.
- No residual risk from TM-017 or any other Phase S0 threat is accepted here. A lawful hold is an authorized processing constraint, not a blanket residual-risk acceptance.

## References

Accessed 2026-08-28:

- [GDPR Article 28 processor return-or-delete obligation](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
- [GitHub deleted-repository recovery window](https://docs.github.com/en/repositories/creating-and-managing-repositories/restoring-a-deleted-repository)
- [GitHub repository deletion](https://docs.github.com/en/repositories/creating-and-managing-repositories/deleting-a-repository)
- [Amazon S3 permanent deletion of versioned objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/DeletingObjectVersions.html)
- [Supabase database backups and retention](https://supabase.com/docs/guides/platform/backups)
- [AWS Backup deletion behavior](https://docs.aws.amazon.com/aws-backup/latest/devguide/deleting-backups.html)
- [GuardDuty Malware Protection for S3 results](https://docs.aws.amazon.com/guardduty/latest/ug/how-malware-protection-for-s3-gdu-works.html)
- [GuardDuty finding retention](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_eventbridge.html)
- [Amazon EventBridge archive retention](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-archive.html)
- [Amazon CloudWatch Logs retention and purge latency](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html)
- [Anthropic API and Managed Agents data retention](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention)
- [Anthropic Managed Agents session deletion](https://platform.claude.com/docs/en/managed-agents/session-operations)
