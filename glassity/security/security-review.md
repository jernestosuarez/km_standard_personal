---
type: security-review
title: Glassity knowledge layer — Phase S0 security review
description: Review record and implementation gate for the proposed multi-tenant knowledge layer.
tags: [glassity, security, review, phase-s0]
resource: glassity/security/
timestamp: 2026-08-27
lifecycle: active
---

# Glassity knowledge layer — Phase S0 security review

## Review status

**Disposition (2026-08-27):** Owner-authorized Supervisor commit `f21bf3e` approves Phase S0 as security-design input only. No control is asserted as present in a deployed system; no residual risk, runtime implementation, or release is approved. AD-001 and AD-002 were subsequently resolved at the design layer; AD-003 through AD-005 remain blocking.

## Scope and method

Reviewed the proposed system in the approved design using data flows, trust boundaries, STRIDE, and agentic-AI abuse cases. Each threat maps to a binding requirement and future verification evidence in `threat-model.md`. Primary guidance was accessed 2026-08-27.

## Artifact and version reviewed

| Artifact | Version/evidence |
|---|---|
| Adaptation design | Supervisor commit `b8d1244` |
| Estate decision | Glassity Company commit `d7c5dd319b59357e66aed34b8d635741d352a603` |
| Threat model | `glassity/security/threat-model.md`, Phase S0, 2026-08-27 |
| Core contracts | `STANDARD.md`; `components/km-cockpit/SPEC.md`; named core skills |

## Mandatory-topic coverage

| Topic | Threats | Requirements | Verification |
|---|---|---|---|
| Authentication, authorization, tenant context, negative tests | TM-001, TM-011 | SEC-001, SEC-002, SEC-015 | VER-001, VER-002, VER-012 |
| Path/symlink traversal and Git credentials | TM-002, TM-003 | SEC-003, SEC-004, SEC-005 | VER-003, VER-004 |
| Injection, tool misuse, excessive agency | TM-004, TM-005, TM-014 | SEC-006, SEC-007, SEC-008, SEC-015 | VER-005, VER-006, VER-012 |
| Worker permissions, egress, skills supply chain | TM-005, TM-013, TM-016 | SEC-008, SEC-017, SEC-018 | VER-006, VER-014, VER-015 |
| Upload malware/archive bombs | TM-006 | SEC-009 | VER-007 |
| XSS and CSRF | TM-007 | SEC-010 | VER-008 |
| Encryption, keys, secrets, retention/deletion | TM-008, TM-014, TM-017 | SEC-011, SEC-012, SEC-019 | VER-009, VER-016 |
| Concurrency, replay, retryable pickup/idempotent governed effects | TM-010 | SEC-014 | VER-011 |
| Audit attribution and safe logging | TM-009, TM-015 | SEC-005, SEC-013 | VER-004, VER-010 |
| Availability and data exfiltration | TM-012, TM-014 | SEC-008, SEC-016 | VER-006, VER-013 |
| Privileged operator/service compromise | TM-018 | SEC-002, SEC-004, SEC-005, SEC-008, SEC-012, SEC-013 | VER-002, VER-004, VER-006, VER-009, VER-010 |

## Findings register

| ID | Type | Severity | Finding | Owner | Required disposition |
|---|---|---|---|---|---|
| F-001 | Resolved design decision | critical | Production execution is self-hosted in Glassity-controlled infrastructure; Anthropic retains the control-plane/model data path, and managed development is synthetic-only. | Accountable owner + security reviewer | Closed at design layer by [AD-001](../decisions/ad-001-self-hosted-production-execution.md); VER-015 remains required. |
| F-002 | Resolved design decision | critical | Supabase Auth proves identity; a server-side active-tenant binding and forced PostgreSQL RLS enforce tenant isolation. | Accountable owner + app security owner | Closed at design layer by [AD-002](../decisions/ad-002-supabase-session-postgres-rls.md); VER-001/002 remain required. |
| F-003 | Missing design decision | high | Quarantine, scanner, storage/region, and archive policy are unselected. | Accountable owner + security reviewer | Resolve AD-003 before upload contract work. |
| F-004 | Missing design decision | critical | Git credential, secret/key, rotation, and revocation architecture are unselected. | Accountable owner + security reviewer | Resolve AD-004 before governed writes. |
| F-005 | Missing design decision | high | Retention/deletion authority and periods are unselected. | Accountable owner + legal/privacy authority | Resolve AD-005 before production persistence. |
| F-006 | Contract requirement | critical | Future contracts must encode tenant authorization, pointer re-authorization, path confinement, isolated answers, and commit attribution. | Contract author | Encode SEC-002–005 and SEC-014/015. |
| F-007 | Contract requirement | critical | Future worker contract must encode untrusted-data handling, external tool policy, isolation, egress denial, and skill verification. | Contract author | Encode SEC-006–008 and SEC-017/018. |
| F-008 | Runtime conformance | critical | Runtime evidence for tenant denial, sandbox, injection, upload, browser, retryable pickup/idempotent effects, retention/deletion, and consumption controls is absent. | Implementation owner | Produce VER-002, VER-005–008, VER-011–016 before release. |
| F-009 | Owner-only residual risk | high | Scanner coverage, provider data path, and retention exceptions can leave residual risk after conformance. | Accountable owner | Use the documented residual-risk policy with evidence and expiry. |

## Architecture decisions required

AD-001 is resolved in [its governed decision record](../decisions/ad-001-self-hosted-production-execution.md), and AD-002 is resolved in [its governed decision record](../decisions/ad-002-supabase-session-postgres-rls.md). AD-003 through AD-005 remain blocking decisions. Their owners, gates, and consequences are in `threat-model.md`; this prevents a later builder selecting storage, region, secret management, retention, or risk posture by implication.

## Implementation gates

1. **Complete — Phase S0 design review:** Owner-authorized Supervisor disposition approved this threat model and review record as security-design input only, without accepting residual risk.
2. Owners resolve AD-003 through AD-005 in governed records; AD-001 and AD-002 are complete at the design layer only.
3. Future contracts encode applicable SEC identifiers and reference their TM/VER mappings.
4. Before release, evidence satisfies VER-001 through VER-016, including independent cross-tenant negative tests.
5. A release reviewer confirms no model, upload, tool output, or client tenant value becomes authority.

## Future conformance evidence

VER-001 through VER-016, selected-mode responsibility documentation, immutable build/dependency evidence, tenant-safe test results, retention/deletion and provider-lifecycle evidence, privileged-service access/revocation evidence, access-controlled audit samples, and owner decisions for any residual risk are required. Evidence must exclude secrets, raw restricted uploads, and production credentials.

## Out-of-scope risks

This review does not select provider capabilities, legal basis, residency, retention values, incident response, browser framework, or staffing. The existing core localhost cockpit is not reviewed as a hosted multi-tenant system; the approved design requires a re-realized web contract later.

## Reviewer checklist

- [x] Reviewed requirements: flows and boundaries match the approved design and record boundary.
- [x] Reviewed requirements: every TM identifier maps to SEC/VER and every SEC/VER has a use.
- [x] Reviewed requirements: the selected self-hosted responsibility boundary is visible; execution remains blocked by unresolved decisions and conformance.
- [x] Reviewed requirements: the selected identity, sole server-side tenant fact, forced-RLS boundary, and every-route negative-test oracle are visible; no control is claimed as implemented.
- [x] Reviewed requirements: unknowns remain findings rather than security-treatment claims.
- [x] Reviewed requirements: tenant isolation, injection, worker agency, uploads, browser, Git, secrets, retention, replay, audit, supply chain, availability, exfiltration, pointer, and logging controls are specified fail closed.
- [x] Reviewed disposition: no residual risk is accepted here.

## Verdict

APPROVED AS SECURITY-DESIGN INPUT — IMPLEMENTATION NOT APPROVED

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
