---
type: security-threat-model
title: Glassity knowledge layer — Phase S0 threat model
description: Pre-implementation threat model for the proposed multi-tenant knowledge layer.
tags: [glassity, security, threat-model, phase-s0]
resource: glassity/security/
timestamp: 2026-08-27
lifecycle: active
---

# Glassity knowledge layer — Phase S0 threat model

## Status and scope

**Status:** Owner-authorized Supervisor disposition, commit `f21bf3e` (2026-08-27): “Approve Phase S0 as security-design input only. No residual risk, runtime implementation, or release is approved.” This is binding security-design input. No application, infrastructure, contract, or runtime security control is present in this repository. AD-001 through AD-005 remain blocking and unselected.

Scope begins at browser submission of an upload, domain-event envelope, or owner answer and ends at a governed tenant-hub record, audit event, or consumed answer. It models both unselected worker modes: Anthropic managed execution and Glassity self-hosted sandbox execution.

## Authoritative inputs

- Approved Glassity app-adaptation design, Supervisor commit `b8d1244`, sections 3–9.
- Estate a4 evidence: Glassity Company commit `d7c5dd319b59357e66aed34b8d635741d352a603`.
- `STANDARD.md` record boundary: operational records stay with their owning systems; Git holds governed knowledge and pointers.
- `components/km-cockpit/SPEC.md`: the surface captures answers but never executes; consumption governs execution.
- Core skills `km-init`, `km-intake`, `km-propose`, `km-brief`, `km-start`, and `km-handover`.

## System context

The browser authenticates through an unselected IAM/session layer. The app/API authorizes uploads, persists domain objects and events in the app database/event store, records an authorized pointer envelope through the inbound adapter, and sends that envelope to a tenant inbox. One worker context runs core skills for one tenant and may use the Claude control plane/API. Raw uploads remain in object/document storage; tenant Git holds digests, claims, decisions, classified extracts, and pointers; pending answers are delivered to the worker with retryable at-least-once pickup and result acknowledgement. Idempotency and trace-before-finalization prevent duplicate governed effects and lost answers. The accountable owner approves governance and is the only residual-risk acceptor.

## Actors and attacker classes

| Actor/class | Authority or attack capability |
|---|---|
| Tenant user | Submits content and reads authorized tenant resources. |
| Accountable owner | Gives governed decisions and may accept documented residual risk. |
| App/API and worker | Proposed policy-enforcement and skill-execution components. |
| Claude control plane/API | External model service receiving only mode-authorized data. |
| Malicious tenant user | Attempts tenant escape, browser abuse, replay, and upload abuse. |
| Malicious uploaded-content author | Embeds instructions, malware, traversal, archive bombs, or exfiltration lures. |
| Compromised credential, skill, or dependency source | Attempts impersonation, supply-chain change, or worker escalation. |
| Network attacker | Attempts session theft, tampering, replay, and availability exhaustion. |
| Malicious or compromised privileged operator/service | Attempts to bypass tenant policy, alter audit evidence, misuse secrets, or widen worker access. |

## Asset and data classification

| Asset | Classification | System of record | Required property |
|---|---|---|---|
| Raw uploads | tenant record; possibly malicious/restricted | object/document storage by content hash | never copied to Git; quarantined first |
| App objects/events | operational record | app database or event store | tenant-scoped integrity |
| Digests, claims, decisions, extracts, pointers | governed knowledge | per-tenant Git hub | governed lifecycle and attributable commits |
| Pending answers | unconsumed operational state | isolated per-tenant answer store | retryable pickup; idempotent governed effect and trace-before-finalization |
| Session/tenant claims | sensitive security data | IAM/session layer | validated server-side |
| Git/API credentials | secret | selected secret boundary | per-session and scoped |
| Audit/telemetry | audit record | selected telemetry store | attributable and minimized |

## Data-flow diagram

```mermaid
flowchart LR
  B[Browser / owner] -->|DF-001| I[IAM / session]
  I -->|DF-002| A[Glassity app / API]
  B -->|DF-003 authenticated upload| A
  A -->|DF-004| Q[Upload quarantine + scanner]
  Q -->|DF-005| O[Object/document storage]
  A -->|DF-006| D[App database / event store]
  A -->|DF-007 pointer envelope| N[Inbound adapter]
  N -->|DF-008| G[Per-tenant Git hub]
  A -->|DF-009| P[Isolated pending-answer store]
  P -->|DF-010 retryable delivery| W[Worker sandbox]
  W -->|DF-011 result / acknowledgement| P
  W -->|DF-012| G
  W -->|DF-013| C[Claude control plane/API]
  A -->|DF-014| T[Audit/telemetry]
  W -->|DF-015| T
  O -. DF-016 authorized pointer dereference .-> W
```

## Data flows

| ID | Flow | Required property |
|---|---|---|
| DF-001 | Browser → IAM/session | TLS and authenticated actor. |
| DF-002 | IAM/session → app/API | Validated actor and tenant context; client value is not authority. |
| DF-003 | Browser → app/API | Authenticated upload authorization before an upload capability is issued. |
| DF-004 | App/API → quarantine | Opaque key, quotas, no executable processing. |
| DF-005 | Quarantine → object storage | Content hash and fail-closed scanner verdict. |
| DF-006 | App/API → app database/event store | Tenant-scoped domain-object/event persistence. |
| DF-007 | App/API → inbound adapter | Tenant-bound, classified, idempotent pointer envelope; raw content stays in object storage. |
| DF-008 | Adapter → tenant Git inbox | Inbox-only pointer-envelope route and path confinement. |
| DF-009 | App/API → pending answers | CSRF-protected, attributed, idempotent append. |
| DF-010 | Pending-answer store → worker | Retryable at-least-once tenant-bound delivery; duplicate pickup is safe. |
| DF-011 | Worker → pending-answer store | Idempotent governed-result acknowledgement; trace before finalization. |
| DF-012 | Worker → Git hub | Scoped credential and attributable governed write. |
| DF-013 | Worker → Claude API | Minimal permitted data and external tool policy. |
| DF-014 | App/API → telemetry | Auth/authz/mutation outcome without secrets. |
| DF-015 | Worker → telemetry | Run, policy, and attribution outcome without restricted payloads. |
| DF-016 | Object/document storage → worker | Authorized pointer dereference only after tenant/object policy re-authorization; minimal permitted content. |

## Trust boundaries

| ID | Boundary | Required decision/control |
|---|---|---|
| TB-001 | Public browser → edge/app | Authentication, CSRF, XSS, and abuse control. |
| TB-002 | IAM/session → app authorization | Deterministic actor/tenant authorization. |
| TB-003 | Untrusted upload → quarantine/scanner | Content is data, never instruction. |
| TB-004 | App records → governed Git | Pointer envelope and record boundary. |
| TB-005 | App/API/pending store/worker | Per-tenant retryable delivery, idempotent effect, trace-before-finalization, and result acknowledgement. |
| TB-006 | Worker sandbox → resources/tools | Deny-by-default tools, egress, filesystem, credentials. |
| TB-007 | Worker → Claude API | Selected-mode responsibility and data path. |
| TB-008 | Git → commit/audit identity | Scoped credential and attributable action. |
| TB-009 | Services → telemetry | Sanitized, access-controlled audit. |

## Security assumptions

- Tenant identity is not inferred from URL, prompt, path, file, or Git remote; it comes from validated server-side authorization.
- AI output, prompts, retrieved text, uploads, URLs, and tool output are data, never authority.
- Each worker run has one tenant context, no cross-tenant writable volume or Git credential, deny-by-default tools, and egress only by explicit policy.
- Managed and self-hosted execution do not transfer Glassity's authorization, data-minimization, audit, or tenant-isolation obligations.

## Execution-mode responsibilities

The cited Anthropic self-hosted sandbox guidance places the execution environment boundary with the customer operating the sandbox. Therefore, in **self-hosted** mode Glassity is responsible for sandbox image selection and hardening, egress controls, environment and per-session secret handling, tool blast radius, and post-worker data lifecycle, in addition to the common responsibilities below. In **managed** mode, Anthropic provides the managed execution boundary described in its managed-agent documentation, but Glassity still owns deterministic tenant authorization, minimization of content sent to the model, audit attribution, and trust in the configured tools and loaded skills. AD-001 remains blocking until the owner chooses a mode and the responsibility split is recorded.

## Unresolved architecture decisions

| ID | Decision | Owner | Gate | Consequence |
|---|---|---|---|---|
| AD-001 | Select managed or self-hosted execution and responsibility split. | Accountable owner + security reviewer | before worker contract | **Blocking:** no worker contract/runtime. |
| AD-002 | Select IAM/session and tenant-isolation mechanism. | Accountable owner + app security owner | before app/API contract | **Blocking:** no authenticated API/cockpit. |
| AD-003 | Select upload quarantine/scanner, archive policy, storage, and region. | Accountable owner + security reviewer | before upload contract | **Blocking:** no uploads. |
| AD-004 | Select key/secrets and Git credential issuance, rotation, and revocation. | Accountable owner + security reviewer | before Git/worker contract | **Blocking:** no governed writes. |
| AD-005 | Set retention/deletion periods and privacy authority by data class. | Accountable owner + legal/privacy authority | before production persistence | **Blocking:** no production persistence. |

## Threat register

Inherent severity is before required controls. “Block” is a required disposition, not a claim that a control exists.

**Category legend:** STRIDE uses **S**poofing, **T**ampering, **R**epudiation, **I**nformation disclosure, **D**enial of service, and **E**levation of privilege. **AI** marks agentic-AI threats assessed alongside STRIDE.

| ID | Category | Assets/flows | Scenario | Impact | Likelihood | Inherent severity | Required controls | Verification | Disposition | Residual risk |
|---|---|---|---|---|---|---|---|---|---|---|
| TM-001 | S/E | session, DF-001/002 | Forged/stolen session selects another tenant. | cross-tenant disclosure/write | medium | critical | SEC-001, SEC-002 | VER-001, VER-002 | block | owner-only after evidence |
| TM-002 | T/E | Git, DF-008/012 | Traversal/symlink reaches another path or hub. | integrity/disclosure | medium | high | SEC-003, SEC-004 | VER-003 | block | none before conformance |
| TM-003 | I/E | Git credential, DF-012 | Shared/overbroad credential writes another tenant hub. | cross-tenant integrity | medium | critical | SEC-004, SEC-005 | VER-004 | block | owner-only after evidence |
| TM-004 | AI | uploads, DF-003–008 | Direct/indirect injection is treated as instruction. | tool misuse/exfiltration | high | critical | SEC-006, SEC-007 | VER-005 | block | model output never substitutes for policy |
| TM-005 | AI/E | worker, DF-010–013 | Excessive agency invokes unapproved tools or egress. | loss/exfiltration | medium | critical | SEC-007, SEC-008 | VER-006 | block | none before conformance |
| TM-006 | T/I | upload, DF-004/005 | Malware/archive bomb reaches parser or worker. | compromise/DoS | high | high | SEC-009 | VER-007 | block | owner decides scanner exceptions only |
| TM-007 | I/T | browser, DF-001/009 | XSS/CSRF reads or submits another user's answer. | disclosure/unauthorized answer | medium | high | SEC-010 | VER-008 | block | none before browser conformance |
| TM-008 | I | stores, DF-001–012 | Weak transport/storage encryption or keys. | disclosure | medium | high | SEC-011, SEC-012 | VER-009 | block | owner-only exception |
| TM-009 | I/R | logs, DF-014/015 | Telemetry leaks secrets/restricted data or lacks identity. | disclosure/non-repudiation | medium | high | SEC-013 | VER-010 | block | none before audit review |
| TM-010 | T/R | answers, DF-009–011 | Retry/race causes duplicate governed effect or lost answer. | incorrect governed state | medium | high | SEC-014 | VER-011 | block | none before conformance |
| TM-011 | I/E | pointers, DF-007/008/016 | Pointer is resolved without source authorization. | record leakage | medium | high | SEC-002, SEC-015 | VER-012 | block | none before adapter contract |
| TM-012 | D | edge/upload/worker | Exhaustion, decompression, or model-call abuse. | outage/cost abuse | high | high | SEC-016 | VER-013 | block | capacity threshold needs owner decision |
| TM-013 | T/E | skills/repository | Tampered skill/dependency changes worker behavior. | arbitrary action/exfiltration | medium | critical | SEC-017 | VER-014 | block | none before skill loading |
| TM-014 | I | worker/API, DF-013 | Prompt/tool output exfiltrates tenant data. | restricted-data disclosure | medium | critical | SEC-006, SEC-008, SEC-015 | VER-005, VER-006, VER-012 | block | owner-only after evidence |
| TM-015 | R/T | commits, DF-012/015 | Commit lacks actor/tenant/action attribution. | unaccountable governance | medium | high | SEC-005, SEC-013 | VER-004, VER-010 | block | none before governed writes |
| TM-016 | S/I | mode, TB-007 | Managed/self-hosted gap leaves a boundary unowned. | systemic disclosure/compromise | medium | critical | SEC-018 | VER-015 | blocking decision | owner must select mode |
| TM-017 | I/D | all retention stores | Retention/deletion failure preserves tenant data or fails to remove it from a selected store, backup, or provider lifecycle. | disclosure/non-compliance | medium | high | SEC-019 | VER-016 | block | owner-only after policy/evidence |
| TM-018 | S/T/R/E | privileged app/operator service, TB-002/006/008 | A malicious or compromised privileged operator/service bypasses tenant policy, misuses a credential or secret, widens worker access, or alters attribution. | cross-tenant compromise/unaccountable writes | low | critical | SEC-002, SEC-004, SEC-005, SEC-008, SEC-012, SEC-013 | VER-002, VER-004, VER-006, VER-009, VER-010 | block | owner-only after evidence |

## Security requirements

| ID | Binding requirement |
|---|---|
| SEC-001 | Authenticate every request through selected IAM; validate issuer, audience, expiry, and session binding server-side. |
| SEC-002 | Deterministically enforce tenant/object authorization at every API, pointer, answer, Git, and worker boundary; deny absent/mismatched context. |
| SEC-003 | Canonicalize and confine repository paths; reject traversal, symlink escape, absolute paths, and unapproved remotes. |
| SEC-004 | Issue per-session tenant-scoped Git credentials; never share writable credentials or volumes across tenants. |
| SEC-005 | Bind each governed write to tenant, authenticated actor, worker run, policy decision, and credential identity. |
| SEC-006 | Treat prompts, uploads, retrieved text, model output, URLs, and tool output as untrusted data; never grant authority from them. |
| SEC-007 | Enforce tool policy outside the model: deny by default, allow named tools/arguments only, require governed authorization for consequential action. |
| SEC-008 | Isolate each tenant worker run; deny cross-tenant filesystem, credentials, processes, and egress except explicit policy. |
| SEC-009 | Quarantine uploads outside executable paths; enforce type/size/count/archive limits and fail-closed malware scanning before extraction. |
| SEC-010 | Apply output encoding/sanitization, framework-appropriate CSP, CSRF defenses, secure sessions, and origin checks. |
| SEC-011 | Require current TLS and encryption at rest for records, knowledge, secrets, and backups under selected-provider responsibility. |
| SEC-012 | Keep secrets only in selected secret management; scope, rotate, revoke, audit, and exclude from Git, prompts, client state, and telemetry. |
| SEC-013 | Emit tamper-evident, access-controlled audit events with actor, tenant, action, object/pointer, decision, and correlation ID; redact secrets/restricted payloads. |
| SEC-014 | Permit retryable at-least-once pending-answer delivery, but make governed effects and result acknowledgement idempotent per tenant; write the trace before finalization and reject replay keys. |
| SEC-015 | Re-authorize pointer resolution at use time and pass only minimal authorized content to worker/model. |
| SEC-016 | Apply bounded request/upload/job/model-call quotas, backpressure, decompression limits, and abuse monitoring; fail closed on limits. |
| SEC-017 | Verify approved skill set and repository revision before worker execution; pin/review dependencies and reject untrusted skill change. |
| SEC-018 | Document selected execution mode, data paths, sandbox guarantees, responsibilities, incident handling, and compensating controls before deployment. |
| SEC-019 | Define and enforce approved retention, deletion, backup-expiry, and deletion-verification obligations for every store and provider data path; block production persistence until AD-005 is decided. |

## Verification catalogue

| ID | Future evidence |
|---|---|
| VER-001 | Reject forged, expired, wrong-audience, and session-fixed credentials. |
| VER-002 | Cross-tenant negative tests reject a valid actor from another tenant on every route/object. |
| VER-003 | Traversal/symlink corpus proves Git and inbox confinement. |
| VER-004 | Credential/commit tests prove session scope, revocation, and complete attribution. |
| VER-005 | Injection corpus proves content cannot change tenant, policy, tool, or release decision. |
| VER-006 | Sandbox tests prove denied tools, commands, paths, credentials, and egress are unavailable. |
| VER-007 | Upload corpus covers malware signals, nested/archive bombs, malformed types, quotas, and scanner failure. |
| VER-008 | Browser tests cover XSS, CSRF, session flags, origin handling, and authorized answer submission. |
| VER-009 | Configuration tests prove TLS, encryption responsibility, key scope, rotation, and revocation. |
| VER-010 | Audit inspection proves attribution/redaction for permitted and denied requests. |
| VER-011 | Concurrent/replay tests prove retryable at-least-once pickup produces one idempotent governed effect and trace-first finalization. |
| VER-012 | Pointer tests prove authorization at creation and dereference, including cross-tenant denial. |
| VER-013 | Load/abuse tests prove limits/backpressure without uncontrolled job/model spend. |
| VER-014 | Supply-chain tests reject altered skill manifests, unexpected revision, and unapproved dependencies. |
| VER-015 | Selected-mode review maps provider and Glassity responsibilities to tested sandbox/data boundaries. |
| VER-016 | Retention/deletion tests and provider evidence prove deletion requests, backup expiry, and exceptions follow the AD-005 policy. |

## Residual-risk policy

No Phase S0 threat is accepted. The 2026-08-27 security-design disposition accepts no residual risk. Only the accountable owner may accept a residual risk through a governed, dated decision naming affected tenant/data class, rationale, expiry/review date, compensating controls, and verification evidence. The security reviewer may recommend but cannot accept risk.

## Maintenance triggers

Re-review before a change to tenant model, IAM, execution mode, model/tool capability, skill set, storage/region, upload parser, Git credential model, retention rule, browser framework, pointer policy, or material incident. Re-run affected verification before release.

## References

Accessed 2026-08-27:

- [OWASP Threat Modeling](https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html)
- [OWASP LLM Prompt Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html)
- [OWASP Agentic Top 10](https://genai.owasp.org/2025/12/09/owasp-top-10-for-agentic-applications-the-benchmark-for-agentic-security-in-the-age-of-autonomous-ai/)
- [OWASP File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
- [OWASP CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [NIST AI RMF and Generative AI Profile](https://www.nist.gov/itl/ai-risk-management-framework)
- [Anthropic self-hosted sandbox security](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security)
- [Anthropic tools](https://platform.claude.com/docs/en/managed-agents/tools)
- [Anthropic skills](https://platform.claude.com/docs/en/managed-agents/skills)
