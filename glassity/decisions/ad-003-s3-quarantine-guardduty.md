---
type: architecture-decision
title: AD-003 — S3 quarantine and GuardDuty malware scanning
description: Selects the v1 upload quarantine, scanner, archive limits, tenant quotas, object storage, and operational region.
tags: [glassity, security, architecture, uploads, malware, s3, guardduty, ad-003]
resource: glassity/decisions/
timestamp: 2026-08-27
lifecycle: active
---

# AD-003 — S3 quarantine and GuardDuty malware scanning

## Status

**Approved by the accountable owner on 2026-08-27.** This resolves AD-003 at the security-design layer only. It does not assert that buckets, upload capabilities, validators, quotas, GuardDuty protection, alarms, promotion logic, or tests exist, and it does not approve application implementation, production release, scanner exceptions, or residual risk.

## Operational provenance and boundary

Glassity's established production and staging platform runs in AWS `eu-west-1` (`KM-Glassity-Company/02_context-scope.md` and `KM-Glassity-Company/working-docs/product/product-knowledge.md`). V1 quarantine, scanning, and clean object storage therefore run in `eu-west-1` as an owner-confirmed operational fact.

This region selection is not a customer-facing residency promise. Contractual residency, transfer, and location commitments remain decisions for the accountable commercial and privacy authorities. A future customer commitment that requires another region must enter through a governed amendment and equivalent regional security evidence.

## Decision

V1 uses separate private Amazon S3 general-purpose buckets for **quarantine** and **clean** objects in `eu-west-1`, with GuardDuty Malware Protection for S3 enabled on the quarantine bucket. An object becomes eligible for clean storage only when the exact immutable S3 object version passes both Glassity's independent structural policy and a GuardDuty result of `NO_THREATS_FOUND`.

Every other outcome fails closed. There is no manual override in the application, administration console, support tooling, or worker. A scanner exception can exist only as an owner-approved residual-risk decision with expiry, compensating controls, and a separate governed treatment path; it cannot relabel or promote an object that failed this pipeline.

## Upload and storage flow

1. The authenticated API applies AD-002 tenant authorization and reserves the requested bytes and one attempt against the tenant's quota before issuing an upload capability.
2. The API issues a 10-minute AWS Signature Version 4 presigned POST bound to one opaque tenant/upload key in the quarantine bucket, an allowed content type, declared SHA-256 checksum, and the 1 GiB size ceiling. The application records and accepts only the first completed S3 version for that upload ID; repeated or replaced versions remain quarantined and unreferenced.
3. The quarantine bucket blocks public access and grants no read path to the browser, normal application role, clean-content reader, or worker. Only the upload capability, structural-validator role, GuardDuty role, and narrowly scoped quarantine operations may access it.
4. Immediately after upload, Glassity verifies the recorded object version, byte count, checksum, declared type, detected type, and tenant quota. For ZIP files, a hardened no-execute preflight reads metadata and the central directory without extracting file contents and applies every Glassity limit below.
5. GuardDuty scans every new quarantine object. Its EventBridge result is handled idempotently because delivery is at least once. A missing, late, duplicate, or contradictory event never creates a clean result.
6. Promotion requires the same upload ID, S3 version, checksum, a passing Glassity policy result, a matching GuardDuty EventBridge result of `NO_THREATS_FOUND`, and the matching managed clean tag on that object version. The promotion service copies the object to the clean bucket under a content-hash key, records provenance and both verdicts, and makes only the clean pointer available to later authorization.
7. Extraction, when later required, occurs only from the clean content-hash object in an isolated tenant context. Streaming counters re-enforce entry count, expanded bytes, ratio, paths, and file types during extraction so forged ZIP metadata cannot bypass preflight.

Both buckets use S3 versioning, Block Public Access, bucket-owner-enforced object ownership, access logging/audit events, and encryption with AWS KMS. AD-004 selects and governs the KMS keys and IAM credentials; AD-005 selects quarantine, clean-object, version, log, and backup retention/deletion periods.

## Glassity limits

These limits are enforced by Glassity before promotion and independently of GuardDuty. GuardDuty quotas and `UNSUPPORTED` reasons are backstops, not application policy.

| Limit | V1 value | Enforcement |
|---|---:|---|
| Raw object size | 1 GiB | Presigned POST condition, recorded reservation, and post-upload byte check |
| Archive formats | ZIP only | Magic bytes and extension/type agreement; RAR, 7z, tar, gzip and other containers rejected |
| Archive encryption | none | Password-protected or encrypted entries rejected with instructions to re-export unencrypted |
| Archive nesting | one outer ZIP only | Any archive entry by magic or type is rejected; no nested archive extraction |
| Entries per ZIP | 10,000 | Central-directory preflight and streaming extraction counter |
| Total extracted size | 5 GiB | Declared-size preflight and streaming expanded-byte counter |
| Single extracted file | 250 MiB | Declared-size preflight and streaming per-file counter |
| Compression ratio | maximum 100:1 per entry and aggregate | Declared-size preflight and streaming compressed/expanded counters |
| Path depth | maximum 20 segments | Normalized-path validation before extraction |
| Paths and entry kinds | regular relative files only | Absolute paths, traversal, empty/ambiguous names, symlinks, hard links, devices and executable entry types rejected |

Allowed v1 leaf types are Markdown/plain text, CSV, JSON, YAML, PDF, DOCX, XLSX, PPTX, PNG, JPEG, WebP and GIF, with exact extension, MIME and magic-signature agreement where applicable. Macro-enabled Office files, HTML, scripts, binaries and unknown types are rejected. Adding a format is a reviewed policy change, not a runtime flag.

## Per-tenant quotas

Quota reservation happens before an upload capability is issued. Rejected, malicious, unsupported, failed and abandoned uploads count toward attempt and byte budgets so an attacker cannot obtain free scanner work by failing.

| Quota | V1 value |
|---|---:|
| Raw upload bytes | 5 GiB per tenant per rolling 24 hours |
| Upload attempts | 20 per tenant per rolling 24 hours |
| Concurrent uploads awaiting validation or scan | 2 per tenant |

The API reconciles reserved and actual bytes after completion but never refunds a scanner-triggering attempt. Global backpressure may make these limits stricter during an incident; it cannot silently make them looser.

## Scanner outcomes and customer response

Only `NO_THREATS_FOUND` is a clean GuardDuty result. `THREATS_FOUND`, `UNSUPPORTED`, `ACCESS_DENIED`, `FAILED`, quota exhaustion, permission/tagging failure, service unavailability, missing result, or an unknown future value leaves the object quarantined and inaccessible. An upload has a 60-minute promotion deadline; expiry is terminal for that upload ID, and a later clean event cannot revive or promote it.

Customer messages reveal no malware signature or internal scanner detail. An encrypted or password-protected archive receives a specific instruction to re-export it unencrypted. Other policy or scanner failures receive a stable rejection category, correlation ID, and safe remediation guidance. Retrying requires a new upload ID and counts against quota.

## Required proof

The future upload contract and implementation must provide:

- a structural corpus at each boundary and one unit beyond it: 1 GiB, 10,000 entries, 5 GiB expanded, 250 MiB leaf, 100:1 ratio and 20 path segments;
- encrypted ZIP, nested archive, traversal, absolute path, symlink, hard-link, device, executable, macro-enabled document, type-confusion and malformed-container cases;
- GuardDuty result cases for clean, threat, unsupported, access denied, failed, delayed, duplicate, contradictory, unavailable, quota-exhausted and unknown results;
- tenant-quota cases for bytes, attempts, concurrency, abandoned uploads, retries and tenant-A/tenant-B independence;
- object-version and checksum races proving that a clean verdict for one version cannot promote another;
- IAM negative tests proving quarantine objects are unreadable by browsers, normal app roles, clean readers and workers;
- region/configuration evidence proving both buckets, KMS use, GuardDuty plan, events and alarms are in `eu-west-1`; and
- canaries that make the suite fail if a Glassity limit is removed, a non-clean scanner outcome is mapped to clean, public access is enabled, or an RLS/tenant check is bypassed.

VER-007 is not satisfied by unit fixtures alone: it requires evidence from the selected GuardDuty integration plus the Glassity validator and promotion boundary. VER-013 must prove quota and backpressure behavior without uncontrolled storage or scanning spend.

## Alternatives considered

### Prefix-only quarantine in one bucket

Rejected. A prefix policy leaves clean and hostile objects inside one bucket policy and increases the chance that a reader permission or lifecycle rule crosses the boundary. Separate buckets make the IAM and audit boundary explicit.

### Self-managed ClamAV as the primary scanner

Not selected for v1. It adds signature distribution, scanner availability, scaling and parser-hardening operations when an AWS-native service is available in the established platform. It may be evaluated later as defense in depth, not as a fallback that turns a failed GuardDuty result into clean.

### Manual scanner override

Rejected. A standing override is a social-engineering path around the upload boundary. The application has no override control; only the formal residual-risk process can authorize a separately controlled treatment.

### Larger or multipart bulk imports

Deferred. Customer vault exports may exceed 1 GiB, but bulk onboarding requires its own governed amendment, multipart/staged scanning flow, limits, cost controls and verification. The v1 limit cannot be increased through configuration drift.

## Consequences and gates

- AD-003 is complete at the design layer. SEC-009 and the upload portion of SEC-016 remain unimplemented; VER-007 and upload-related VER-013 evidence remain release blockers.
- Future authority-matrix, inbound-adapter and upload contracts must encode the two-bucket boundary, exact limits, quotas, verdict semantics, content-hash promotion and no-override rule before implementation.
- AD-004 and AD-005 remain unresolved and blocking. No production bucket or credential contract can be finalized until keys, roles, retention and deletion are governed there.
- Customer-facing residency commitments are not created by this decision.
- No residual risk from TM-006, TM-012, TM-014, TM-017 or any other Phase S0 threat is accepted here.

## References

Accessed 2026-08-27:

- [AWS GuardDuty Malware Protection for S3 workflow](https://docs.aws.amazon.com/guardduty/latest/ug/how-malware-protection-for-s3-gdu-works.html)
- [AWS GuardDuty Malware Protection for S3 outcomes](https://docs.aws.amazon.com/guardduty/latest/ug/monitoring-malware-protection-s3-scans-gdu.html)
- [AWS GuardDuty Malware Protection for S3 quotas](https://docs.aws.amazon.com/guardduty/latest/ug/malware-protection-s3-quotas-guardduty.html)
- [AWS GuardDuty S3 feature support](https://docs.aws.amazon.com/guardduty/latest/ug/supported-s3-features-malware-protection-s3.html)
- [AWS S3 presigned uploads and checksums](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html)
