---
type: architecture-decision
title: AD-004 — AWS secrets spine and tenant-scoped GitHub broker
description: Selects v1 hub hosting, Git credential brokerage, run-lease revocation, key and secret lifecycle, and break-glass access.
tags: [glassity, security, architecture, secrets, github, credentials, kms, ad-004]
resource: glassity/decisions/
timestamp: 2026-08-28
lifecycle: active
---

# AD-004 — AWS secrets spine and tenant-scoped GitHub broker

## Status

**Approved by the accountable owner on 2026-08-28.** This resolves AD-004 at the security-design layer only. It does not assert that GitHub repositories, the broker, run leases, egress policy, KMS keys, secret rotation, break-glass controls, audit events, or tests exist, and it does not approve application implementation, production release, customer residency terms, or residual risk.

This decision also selects private GitHub.com repositories as the v1 tenant-hub host. That hosting fact and its residency consequence were approved explicitly rather than inherited from the credential mechanism.

## Operational provenance and selection

Glassity's established platform evidence records AWS EKS in `eu-west-1` and AWS Secrets Manager synchronized through External Secrets Operator (`KM-Glassity-Company/working-docs/product/product-knowledge.md`). The Glassity CEO also named HashiCorp Vault and Supabase as components of the Junox work-stream on 2026-08-19 (Company-hub commit `5acde5519dfac2e0f4b4464af3618bcf4141343c`, Junox change and glossary entries). That statement is component evidence, not a formal secrets-platform selection.

V1 selects **AWS Secrets Manager** as the secret system of record, AWS KMS customer-managed keys for the applicable AWS encryption boundaries, AWS workload identity for trusted services, and a Glassity credential broker for run-scoped authority. HashiCorp Vault remains a governed replacement candidate; a builder may not introduce it without an amendment proving equivalent issuance, audit, rotation, revocation, availability, and migration behavior.

## Decision in two sentences

A worker obtains an opaque, short-lived Glassity run credential bound server-side to exactly one `run_id`, `tenant_id`, GitHub repository ID, and approved ref set; the worker never receives a GitHub App private key, installation token, Supabase secret key, database administrator credential, or KMS-capable credential.

Every Git operation passes through the broker and an active run-lease check, while direct GitHub egress is denied; the credential becomes unusable atomically at the authoritative terminal-state transition for normal or abnormal termination, with physical failure detection bounded independently to 30 seconds.

## Tenant-hub hosting and residency

V1 uses one private GitHub.com repository per tenant as the system of record for governed knowledge. Those repositories may contain only the Standard's Git-side record classes:

- digests and claims;
- governed decisions;
- classified extracts from customer vaults; and
- resolvable pointers and their governance metadata.

Raw uploads, complete customer vaults, app objects and events, pending answers, secrets, provider tokens, session bindings, and raw restricted telemetry do not enter GitHub. Classification and minimization happen before a governed extract is proposed for the hub; Git hosting never expands what the record boundary permits.

GitHub documents that GitHub.com data is stored in the USA by default. The `eu-west-1` operational selection in AD-001 and AD-003 therefore does not apply to tenant-hub repository data, and this decision introduces a US-hosting consequence for the listed governed-knowledge classes, including classified extracts. It creates no customer-facing residency promise.

GitHub Enterprise Cloud with data residency on `GHE.com`, using its EU region, is the governed upgrade path if a customer or commercial commitment later requires regional repository storage. GitHub documents that repository content is stored in the selected region and that limited administrative, support, telemetry, and optional-feature data may still be stored or transferred outside it. A residency commitment therefore requires legal/privacy review, a governed amendment, contract-compatible feature review, and migration evidence before affected customer content enters the hub.

The accountable commercial owner must be shown this GitHub.com residency consequence together with AD-001's self-hosted execution cost before v1 scope, pricing, or customer commitments are approved. The decision and presentation are recorded by role; no personal name belongs in the Glassity overlay.

## Broker and run-lease contract

The credential broker is a privileged service, not a convenience helper. It concentrates the GitHub App private key, run-lease authority, repository mapping, and every tenant's governed write path and is treated as a TM-018 target.

1. The run controller creates an authoritative run record containing the authenticated actor, tenant, worker identity, approved policy decision, repository ID, allowed refs, expected base ref, issue time, absolute expiry, heartbeat state, and revocation state. Client fields, prompts, paths, Git remotes, and model output cannot create or widen this record.
2. A dedicated broker workload identity may read only the GitHub App secret and broker configuration it requires. The worker's workload identity cannot read Secrets Manager values, use KMS keys, mint GitHub tokens, or reach GitHub directly.
3. The controller delivers the worker a random opaque run credential through an in-memory or `tmpfs` mount with restrictive permissions, never through source, an image, a prompt, telemetry, a command-line argument, or a persistent environment file. The broker requires both that credential and the expected isolated workload identity.
4. The worker configures Git against an internal smart-HTTP broker endpoint. The broker ignores any worker-supplied remote and resolves the tenant, repository, and ref set only from the active run record.
5. For provider access, the broker mints a GitHub App installation access token restricted with `repository_ids` to exactly one repository and with only `metadata:read` and `contents:write`. The token exists only in broker memory, is never returned to the worker, and is revoked and discarded when its operation or run ends.
6. Network policy, DNS/egress policy, and the worker tool policy deny direct access to GitHub Git and API endpoints. A test-only canary proves the broker is the only permitted Git transport.
7. Every attempted operation emits a minimized, tamper-evident audit event with actor, worker identity, run, tenant, repository, ref, requested operation, policy decision, lease result, provider outcome, correlation ID, and credential identifier or hash. No secret, pack content, classified extract, or provider token is logged.

The broker must be horizontally safe but logically fail closed: one authoritative lease state, idempotent issuance/revocation, no local-only authorization cache that outlives a lease, and no provider call if the lease store or audit prerequisite is unavailable. Broker administrators cannot silently rewrite tenant-to-repository mappings or mint an unrecorded run; such changes require separate privileged roles, approval, and audit.

## Termination and mid-operation revocation

The authoritative run-state transition and final Git ref publication are serialized against the same run record. This gives one observable ordering: either an allowed ref update completes before termination, or termination wins and no later ref update is permitted.

- **Normal termination:** the controller stops new operations, waits for or cancels any operation before its final publication point, revokes the run lease synchronously, requests GitHub-token revocation, destroys the worker and transient storage, emits the terminal audit event, and only then marks the run complete.
- **Abnormal termination:** Kubernetes termination or eviction events invoke the same external controller path. A 10-second heartbeat supplies the independent fallback; three missed heartbeats produce a terminal transition, giving a maximum 30-second physical-failure detection bound. The dying worker is not trusted to revoke itself.
- **Streaming revocation:** incoming Git data is staged in isolated transient storage and cannot update a GitHub ref while streaming. The broker re-checks the lease during transfer and immediately before publication. Revocation closes the stream, cancels provider transfer, deletes staging, and returns failure.
- **Atomic visibility:** final ref publication and terminal-state mutation use the same per-run serialization rule and an expected-old-ref comparison. A partial or interrupted pack transfer cannot update a visible ref; a publication already inside its final serialized section finishes before the run may become terminal, and its outcome is audited.

GitHub token revocation is attempted immediately. If GitHub is unavailable, the Glassity lease and egress boundary still make the worker credential unusable; the broker quarantines the repository/run from new work, clears the provider token from memory, raises an alert, retries revocation, and relies only as a final backstop on GitHub's one-hour token expiry. Provider expiry is not the primary revocation control.

## Common issuance, rotation, and revocation spine

Every credential class has a named issuer, consumer, scope, storage location, maximum lifetime or rotation interval, revocation path, audit identity, and compromise action. A missing field blocks issuance.

| Credential/key class | Issuance and scope | Rotation and revocation |
|---|---|---|
| Worker Git authority | Broker run credential; one tenant, run, repository, and approved ref set | Absolute maximum run lifetime 60 minutes; renewable only while the authoritative lease is active; synchronous lease revocation at terminal state |
| GitHub App private key | GitHub-issued root stored in Secrets Manager; broker role only | Rotate at least every 90 days with overlap and validation; delete the old GitHub key after cutover; rotate immediately on suspected exposure |
| GitHub installation token | Minted in broker memory for one repository and minimum permissions | Revoke after operation/run and discard; one-hour provider expiry is only a backstop |
| KMS keys | Separate symmetric customer-managed keys per environment and at least separate quarantine and clean-storage boundaries; service principals only | Enable 365-day automatic key-material rotation; new key and governed re-encryption/migration on compromise or boundary change |
| Supabase elevated key | New-style Supabase secret key in Secrets Manager; dedicated administrative backend only | Rotate at least every 90 days through create, deploy, verify, delete-old; immediate replacement on suspicion; legacy `service_role` is not selected for new use |
| Tenant-session store credential | Dedicated least-privilege PostgreSQL role in Secrets Manager; authorization resolver only; no superuser, ownership, or `BYPASSRLS` | Rotate at least every 30 days with overlapping credentials and connection draining; revoke immediately on compromise or resolver retirement |
| Break-glass role | Named human through enterprise SSO, phishing-resistant MFA, two-person approval, incident/change ticket, and a separate least-privilege AWS role | No standing shared secret; maximum 30-minute session; immediate session disable, alerts, access review, and rotation of every retrieved or exposed secret |

Supabase secret and legacy `service_role` keys bypass RLS. They are prohibited from workers, browsers, normal tenant HTTP paths, the tenant-session resolver, Git tooling, and generic support utilities. Administrative calls use a dedicated backend with prior authorization and audit; where direct PostgreSQL access suffices, the elevated Supabase key is not issued at all.

AWS KMS grants may support bounded service use, but they are not the run-lease or immediate-revocation mechanism because grant creation and revocation are eventually consistent. Likewise, AWS STS and EKS workload credentials support trusted-service identity but do not replace the broker lease for worker authority.

## Break-glass consequences

There is no application override, shared administrator password, reusable emergency token, or direct worker escape hatch. Break-glass access is denied unless the human identity, second approver, ticket, target resources, allowed operations, and 30-minute expiry are all present.

Activation pauses new affected-tenant runs, alerts security and the accountable owner, and records every API and secret-read event. Closure requires session revocation, confirmation that no run or credential remains active, rotation of any secret material that was revealed, an access-log review, a dated incident outcome, and an owner decision for any residual risk. Break-glass cannot relabel quarantined content, bypass tenant attribution, or silently alter a governed hub.

## Required proof

The future broker, worker, infrastructure, and secret-management contracts must provide:

- tenant-A credentials denied against tenant-B repositories for clone, fetch, object write, branch creation, force push, tag creation, deletion, and API access;
- mutation canaries for changed tenant, repository, remote, ref, base ref, run, workload identity, permission set, and expired or revoked lease;
- proof that direct GitHub egress and direct Secrets Manager/KMS/Supabase access are unavailable from the worker;
- normal completion, pod deletion, eviction, process crash, controller restart, lease-store outage, broker restart, and missed-heartbeat cases with measured revocation times;
- a mid-stream revocation case that terminates transfer, deletes staging, and proves no target ref or tag becomes visible afterward;
- a final-publication race matrix proving the expected-old-ref and terminal transition have one linear ordering and never produce a post-terminal ref update;
- GitHub-revocation outage evidence proving the worker remains denied, the run/repository is quarantined, alerting occurs, and retry/expiry is observed;
- inspection proving provider keys and tokens never enter worker environment, disk, prompt, logs, command arguments, tool output, crash dumps, or persistent volumes;
- rotation tests proving old GitHub, Supabase, and database credentials are rejected after cutover and KMS rotation preserves authorized decrypt while denied roles remain denied;
- broker-compromise canaries proving its workload role cannot reach unrelated secrets, repositories, AWS accounts, tenant stores, or KMS boundaries and that unauthorized mapping/issuance attempts alert; and
- break-glass denial without every approval field, expiry at 30 minutes, complete audit evidence, affected-run pause, and post-use rotation/review.

VER-004 is not satisfied by token-expiry tests: it requires repository/ref scope, active revocation, mid-operation termination, atomic visibility, and complete commit/audit attribution. VER-009 requires evidence for selected KMS, Secrets Manager, Supabase/database rotation, broker root-secret confinement, and break-glass lifecycle.

## Alternatives considered

### Direct GitHub or AWS credentials in the worker

Rejected. Provider credentials remain valid until revocation or expiry and can be exfiltrated beyond the worker's egress boundary. They cannot supply the required per-operation active-lease decision or atomic terminal-state ordering.

### HashiCorp Vault as the v1 secrets spine

Not selected. Vault provides useful leased-secret and revocation primitives, but the estate evidence does not establish a formal selection, it adds a critical operational control plane, and GitHub still requires a broker or custom integration for exact repository/ref and streaming-publication control. It remains a governed migration candidate.

### Glassity-controlled Git with SSH certificates

Not selected for v1. It offers greater hosting and certificate control but makes Glassity operate a Git service before that cost is justified. GitHub Enterprise Server remains a later option if cloud-hosting or export-control requirements cannot be met by `GHE.com` EU residency.

### KMS grants or STS expiry as run revocation

Rejected. KMS grant changes are eventually consistent, and AWS temporary credentials can outlive the process that obtained them. Both can support trusted services but neither proves immediate worker-authority death.

## Consequences and gates

- AD-004 is complete at the design layer. SEC-004, SEC-005, SEC-008, SEC-011 through SEC-013 remain unimplemented; VER-004, VER-006, VER-009, and VER-010 remain release blockers.
- Future Git, worker, infrastructure, audit, secret-management, and break-glass contracts must encode this broker, lease, hosting, residency, rotation, and revocation boundary before implementation.
- The broker is a critical TM-018 service and requires independent security review, workload isolation, compromise drills, availability design, and audit canaries before governed writes.
- Private GitHub.com hosting of the named governed-knowledge classes is an explicit v1 architecture and US-residency consequence. Customer residency terms require separate commercial/legal authority and may force the governed `GHE.com` EU migration path.
- AD-005 remains unresolved and blocking. No production persistence or repository retention/deletion lifecycle is approved until it is decided.
- No residual risk from TM-002, TM-003, TM-008, TM-009, TM-014, TM-015, TM-018, or any other Phase S0 threat is accepted here.

## References

Accessed 2026-08-28:

- [GitHub App installation token scope and expiry](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app)
- [GitHub App installation token revocation](https://docs.github.com/en/rest/apps/installations#revoke-an-installation-access-token)
- [GitHub Enterprise Cloud with data residency](https://docs.github.com/en/enterprise-cloud@latest/admin/data-residency/about-github-enterprise-cloud-with-data-residency)
- [GitHub storage inside and outside a selected region](https://docs.github.com/en/enterprise-cloud@latest/admin/data-residency/about-storage-of-your-data-with-data-residency)
- [AWS EKS workload identity](https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html)
- [AWS Secrets Manager rotation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html)
- [AWS KMS grants and eventual consistency](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html)
- [AWS KMS automatic rotation](https://docs.aws.amazon.com/kms/latest/developerguide/rotating-keys-enable.html)
- [AWS temporary-credential permission revocation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_disable-perms.html)
- [Supabase API and secret keys](https://supabase.com/docs/guides/getting-started/api-keys)
- [HashiCorp Vault lease and revocation model](https://developer.hashicorp.com/vault/docs/concepts/lease)
